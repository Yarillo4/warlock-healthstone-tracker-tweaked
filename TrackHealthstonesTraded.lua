local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "TrackHealthstonesTraded"

--[[
    This module tracks the state of a trade using the TRADE_SHOW, TRADE_CLOSED,
    TRADE_PLAYER_ITEM_CHANGED, and TRADE_TARGET_ITEM_CHANGED events. This alone
    however is not enough.

    Validating trade success requires us to additionally monitor specific messages
    using UI_ERROR_MESSAGE and UI_INFO_MESSAGE events.

    UnitName("NPC") becomes available during TRADE_SHOW, however in some circumstances
    TRADE_PLAYER/TARGET_ITEM_CHANGED can fire before TRADE_SHOW. This means that
    UnitName("NPC") == nil. We have to be wary of this
]]


---------------------------------------------
-- VARIABLES
---------------------------------------------
local tradeState = {
    unitName = nil,
    playerItems = {},
    targetItems = {},
}


---------------------------------------------
-- UTILITIES
---------------------------------------------
local function containsValue(tbl, value)
    for _,v in pairs(tbl) do
        if ( value == v ) then
            return true
        end
    end
    return false
end

local function containsAnyValue(tbl, values)
    for _,value in pairs(values) do
        if ( containsValue(tbl, value) ) then
            return true
        end
    end
    return false
end

local function collapseArray(arr)
    -- remove nil values from the array
    for k=1,#arr do
        while (arr[k] == nil) do
            tremove(arr, k)
            if (k >= #arr ) then
                break
            end
        end

        if (k >= #arr ) then
            break
        end
    end

    return arr
end


---------------------------------------------
-- TRACK HEALTHSTONE TRADES
---------------------------------------------
local function getTradeUpdateValuesByType(event)
    if ( event == "TRADE_PLAYER_ITEM_CHANGED" ) then
        return GetTradePlayerItemLink, tradeState.playerItems, (UnitName("player"))
    elseif ( event == "TRADE_TARGET_ITEM_CHANGED" ) then
        return GetTradeTargetItemLink, tradeState.targetItems, tradeState.unitName
    end
    error("Unexpected event type: " .. event)
end

local function initializeTrade(event)
    tradeState.unitName = UnitName("NPC")
    HST:trace(MODULE_NAME, "initializeTrade", "Trading with", tradeState.unitName)

    -- Update cache if target is trading healthstone
    if ( containsAnyValue(tradeState.targetItems, HST.HEALTHSTONES_BY_ITEMID) ) then
        -- Only update if player isn't already known to have a healthstone (cut down on addon message chatter)
        if ( not HST:PlayerHasHealthstone(tradeState.unitName) ) then
            HST:SetPlayerHealthstone(nil, tradeState.unitName, true)
        end
    end
end

local function updateTrade(event, slot)
    local getTradeItemLink, storage, unitname = getTradeUpdateValuesByType(event)

    if (slot) then
        local itemLink = getTradeItemLink(slot);
        HST:trace(MODULE_NAME, "updateTrade", event, slot, itemLink)

        if ( itemLink ) then
            local itemID = tonumber(itemLink:match("item:(%d+)"))
            storage[slot] = itemID

            -- Update cache if unitName is trading healthstone
            if ( containsValue(HST.HEALTHSTONES_BY_ITEMID, itemID) and unitname ) then
                -- Only update if player isn't already known to have a healthstone (cut down on addon message chatter)
                if ( not HST:PlayerHasHealthstone(unitname) ) then
                    HST:SetPlayerHealthstone(nil, unitname, true)
                end
            end
        else
             storage[slot] = nil
        end
    end
end

local function validateTradeSuccess(event, msgid, msg)
    -- Only take action for ERR_TRADE* messages
    if ( msgid and GetGameMessageInfo(msgid):sub(1,#"ERR_TRADE") == "ERR_TRADE" ) then
        tradeState.playerItems = tradeState.playerItems or {}
        tradeState.targetItems = tradeState.targetItems or {}
        HST:trace(MODULE_NAME, "validateTradeSuccess", "tradeState.unitName =", tradeState.unitName)
        HST:trace(MODULE_NAME, "validateTradeSuccess", "tradeState.playerItems =", table.concat(collapseArray(tradeState.playerItems), ","))
        HST:trace(MODULE_NAME, "validateTradeSuccess", "tradeState.targetItems =", table.concat(collapseArray(tradeState.targetItems), ","))

        local player = UnitName("player")
        local target = tradeState.unitName
        local sending = containsAnyValue(tradeState.playerItems, HST.HEALTHSTONES_BY_ITEMID)
        local receiving = containsAnyValue(tradeState.targetItems, HST.HEALTHSTONES_BY_ITEMID)
        HST:debug("Finalizaing trade with", target, "sending =", sending, "receiving =", receiving, "msg =", GetGameMessageInfo(msgid))

        -- Reset trade state
        tradeState = {
            unitName = nil,
            playerItems = {},
            targetItems = {},
        }

        if ( not sending and not receiving ) then
            -- Theres nothing to do if neither sending or receiving
            HST:debug("Not sending or receiving. This isn't a healthstone trade")
            return

        elseif ( sending and receiving ) then
            -- Both player and target have healthstones regardless of trade output, since they are both sending and receiving
            HST:debug("Both sending and receiving, outcome doesn't matter everyone has healthstone")
            HST:SetPlayerHealthstone(nil, player, true)
            HST:SetPlayerHealthstone(nil, target, true)

        elseif ( msg == ERR_TRADE_COMPLETE ) then
            -- Trade was successful, we are either sending OR receiving :: swap sending and receiving
            HST:debug("Successful trade with", target)
            HST:SetPlayerHealthstone(nil, player, receiving)
            HST:SetPlayerHealthstone(nil, target, sending)

        elseif ( msg == ERR_TRADE_TARGET_MAX_COUNT_EXCEEDED ) then
            -- Trade failed, but we can still gather some information. We are either sending OR receiving
            HST:debug("Trade failed with", target .. ". Target has too many of a unique item")
            -- Either way the target has a healtstone
            HST:SetPlayerHealthstone(nil, target, true)
            if ( sending ) then
                -- Player clearly has healthsotne if sending. Cannot be certain if !sending though
                HST:SetPlayerHealthstone(nil, player, true)
            end

        elseif ( msg == ERR_TRADE_MAX_COUNT_EXCEEDED ) then
            -- Trade failed, but we can still gather some information. We are either sending OR receiving
            HST:debug("Trade failed with", target .. ". Player has too many of a unique item")
            -- Either way the player has a healtstone
            HST:SetPlayerHealthstone(nil, player, true)
            if ( receiving ) then
                -- Target clearly has healthstone if receiving. Cannot be certain if !receiving though
                HST:SetPlayerHealthstone(nil, target, true)
            end

        else
            -- Trade failed.
            HST:debug("Trade failed with", target)
        end
    end
end


---------------------------------------------
-- INITIALIZE
---------------------------------------------
HST.RegisterCallback(MODULE_NAME, "initialize", function()
    -- Track trade state
    HST.RegisterEvent(MODULE_NAME, "TRADE_SHOW", initializeTrade)
    HST.RegisterEvent(MODULE_NAME, "TRADE_PLAYER_ITEM_CHANGED", updateTrade)
    HST.RegisterEvent(MODULE_NAME, "TRADE_TARGET_ITEM_CHANGED", updateTrade)

    -- Validate whether trade was successful or not.
    HST.RegisterEvent(MODULE_NAME, "UI_ERROR_MESSAGE", validateTradeSuccess)
    HST.RegisterEvent(MODULE_NAME, "UI_INFO_MESSAGE", validateTradeSuccess)
end)
