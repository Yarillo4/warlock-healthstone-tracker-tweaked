local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "TrackHealthstonesCreated"


---------------------------------------------
-- CONSTANTS
---------------------------------------------
local CREATE_HEALTHSTONE_SPELLIDS = { 5699, 6201, 6202, 11729, 11730 }


---------------------------------------------
-- VARIABLES
---------------------------------------------
local createHealthstoneSpellsByName = {}


---------------------------------------------
-- TRACK HEALTHSTONE CREATED
---------------------------------------------
local function trackHealthstoneCreated(...)
    local timestamp, event, hideCaster, srcGuid, srcName, srcFlags, srcRaidFlags, dstGuid, dstName, dstFlags, dstRaidFlags = ...

    local isPlayer = bit.band(srcFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
    if ( event == "SPELL_CAST_SUCCESS" and isPlayer ) then
        local spellName = select(13, ...)

        local isFriendly = bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) > 0
        --@debug@
        HST:debug("trackHealthstoneCreated", srcName, spellName, createHealthstoneSpellsByName[spellName], isFriendly)
        --@end-debug@
        if ( spellName and createHealthstoneSpellsByName[spellName] and isFriendly ) then
            HST:debug(srcName, "successfully casted", spellName)
            HST:SetPlayerHealthstone(timestamp, srcName, true)
        end
    end
end


---------------------------------------------
-- INITIALIZE
---------------------------------------------
HST.RegisterCallback(MODULE_NAME, "initialize", function()
    --@alpha@
    HST:debug("initalize module", MODULE_NAME)
    --@end-alpha@

    -- Watch combat log for healthstone created
    HST.RegisterEvent(MODULE_NAME, "COMBAT_LOG_EVENT_UNFILTERED", function(event)
        trackHealthstoneCreated(CombatLogGetCurrentEventInfo())
    end)

    -- Convert list of create healthstone spellIDs to spellNames
    for _,spellId in ipairs(CREATE_HEALTHSTONE_SPELLIDS) do
        local spellName = GetSpellInfo(spellId)
        createHealthstoneSpellsByName[spellName] = true
    end
end)
