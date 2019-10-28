local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "TrackHealthstonesTraded"

--[[
    This module tracks the state of a trade using the TRADE_SHOW, TRADE_CLOSED,
    TRADE_PLAYER_ITEM_CHANGED, and TRADE_TARGET_ITEM_CHANGED events. This alone
    however is not enough.

    Validating trade success requires us to additionally monitor specific messages
    using UI_ERROR_MESSAGE and UI_INFO_MESSAGE events.
]]


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

---------------------------------------------
-- TRACK HEALTHSTONE TRADES
---------------------------------------------
local tradeUnitName = nil
local itemsBeingTraded = {}
local pendingHealthstoneTradeUnitName = nil

local function initializeTrade()
    tradeUnitName = UnitName("NPC")
end

local function updateTrade(slot)
    if (slot) then
        local itemLink = GetTradePlayerItemLink(slot);
        if ( itemLink ) then
             trace("Trading", itemLink)
             local itemID = tonumber(itemLink:match("item:(%d+)"))
             itemsBeingTraded[slot] = itemID
        else
             itemsBeingTraded[slot] = nil
        end
    end
end

local function prepareTradeFinalization()
    -- Confirm trade completion
    local tradeUnitName, itemsBeingTraded = aura_env.tradeUnitName, aura_env.itemsBeingTraded
    if ( tradeUnitName ) then
        -- trade contained healthstone
        if ( containsAnyValue(itemsBeingTraded, HST.HEALTHSTONES_BY_ITEMID) ) then
             trace("Closing healthstone trade with ", tradeUnitName, ". pending finalization")
             pendingHealthstoneTradeUnitName = tradeUnitName
        end
    end

    itemsBeingTraded = {}
    tradeUnitName = nil
end

local function validateTradeSuccess(...)
    if ( not pendingHealthstoneTradeUnitName ) then
        return
    end

    -- Only take action for ERR_TRADE* messages
    local msgid, msg = ...
    if ( msgid and GetGameMessageInfo(msgid):sub(1,#"ERR_TRADE") == "ERR_TRADE" ) then
        if ( msg == ERR_TRADE_COMPLETE or msg == ERR_TRADE_TARGET_MAX_COUNT_EXCEEDED or msg == ERR_TRADE_TARGET_MAX_LIMIT_CATEGORY_COUNT_EXCEEDED_IS ) then
            -- Successful trade
            HST:debug("Finalized successful trade with ", pendingHealthstoneTradeUnitName)
            HST.playersWithHealthstones[pendingHealthstoneTradeUnitName] = true

            if ( UnitInParty(pendingHealthstoneTradeUnitName) ) then
                HST.pluginCallbacks:Fire("updatePartyMemberHealthstone", pendingHealthstoneTradeUnitName, true)
            end
            if ( UnitInRaid(pendingHealthstoneTradeUnitName) ) then
                HST.pluginCallbacks:Fire("updateRaidMemberHealthstone", pendingHealthstoneTradeUnitName, true)
            end
        else
            -- failed trade
            HST:debug("Trade failed with", pendingHealthstoneTradeUnitName)
        end

        pendingHealthstoneTradeUnitName = nil
    end
end


---------------------------------------------
-- INITIALIZE
---------------------------------------------
HST.RegisterCallback(MODULE_NAME, "initialize", function()
    -- Track trade state
    HST.RegisterEvent(MODULE_NAME, "TRADE_SHOW", initializeTrade)
    HST.RegisterEvent(MODULE_NAME, "TRADE_PLAYER_ITEM_CHANGED", updateTrade)
    --HST.RegisterEvent(MODULE_NAME, "TRADE_TARGET_ITEM_CHANGED", updateTrade)
    HST.RegisterEvent(MODULE_NAME, "TRADE_CLOSED", prepareTradeFinalization)

    -- Validate whether trade was successful or not.
    HST.RegisterEvent(MODULE_NAME, "UI_ERROR_MESSAGE", validateTradeSuccess)
    HST.RegisterEvent(MODULE_NAME, "UI_INFO_MESSAGE", validateTradeSuccess)
end)
