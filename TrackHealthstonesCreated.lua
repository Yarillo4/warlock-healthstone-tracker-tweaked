local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "TrackHealthstonesCreated"


---------------------------------------------
-- CONSTANTS
---------------------------------------------
local CREATE_HEALTHSTONE_SPELLIDS = { 5699, 6201, 6202, 11729, 11730 }
local PLAYER_NAME = UnitName("player")


---------------------------------------------
-- VARIABLES
---------------------------------------------
local createHealthstoneSpellsByName = {}
local healthstonesByItemId = {}


---------------------------------------------
-- TRACK HEALTHSTONE CREATED
---------------------------------------------
local function trackHealthstoneCreated(...)
    local timestamp, event, hideCaster, srcGuid, srcName, srcFlags, srcRaidFlags, dstGuid, dstName, dstFlags, dstRaidFlags = ...

    local isPlayer = bit.band(srcFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
    if ( event == "SPELL_CAST_SUCCESS" and isPlayer ) then
        local spellName = select(13, ...)

        local isFriendly = bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) > 0
        HST:trace(MODULE_NAME, "trackHealthstoneCreated", srcName, spellName, createHealthstoneSpellsByName[spellName], isFriendly)
        if ( spellName and createHealthstoneSpellsByName[spellName] and isFriendly ) then
            HST:debug(srcName, "successfully casted", spellName)
            HST:SetPlayerHealthstone(timestamp, srcName, true)
        end
    end
end

local function checkPlayerInventoryForHealthstone(...)
    for bagId = 0,4 do
        for slotId = 1,GetContainerNumSlots(bagId) do
            local itemId = GetContainerItemID(bagId, slotId)
            if ( itemId and healthstonesByItemId[itemId] ) then
                HST:SetPlayerHealthstone(nil, PLAYER_NAME, true)
                return
            end
        end
    end

    HST:SetPlayerHealthstone(nil, PLAYER_NAME, false)
end


---------------------------------------------
-- INITIALIZE
---------------------------------------------
HST.RegisterCallback(MODULE_NAME, "initialize", function()
    -- Watch combat log for healthstone created
    HST.RegisterEvent(MODULE_NAME, "COMBAT_LOG_EVENT_UNFILTERED", function(event)
        trackHealthstoneCreated(CombatLogGetCurrentEventInfo())
    end)

    -- Convert list of create healthstone spellIDs to spellNames
    for _,spellId in ipairs(CREATE_HEALTHSTONE_SPELLIDS) do
        local spellName = GetSpellInfo(spellId)
        createHealthstoneSpellsByName[spellName] = true
    end

    -- Check player bags for healstone upon zoning in
    HST.RegisterEvent(MODULE_NAME, "PLAYER_ENTERING_WORLD", checkPlayerInventoryForHealthstone)

    -- Convert list of create healthstone itemIds to a map
    for _,itemId in ipairs(HST.HEALTHSTONES_BY_ITEMID) do
        healthstonesByItemId[itemId] = true
    end
end)
