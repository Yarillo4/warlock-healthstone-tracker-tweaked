local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "TrackHealthstonesCreated"


---------------------------------------------
-- CONSTANTS
---------------------------------------------
local CREATE_HEALTHSTONE_BY_SPELLID = {
    [5699] = true,
    [6201] = true,
    [6202] = true,
    [11729] = true,
    [11730] = true,
}


---------------------------------------------
-- TRACK HEALTHSTONE CREATED
---------------------------------------------
local function trackHealthstoneCreated(...)
    local timestamp, event, hideCaster, srcGuid, srcName, srcFlags, srcRaidFlags, dstGuid, dstName, dstFlags, dstRaidFlags = ...

    if ( srcName == "Malicene" ) then
        local isPlayer = bit.band(srcFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
        if ( event == "SPELL_CAST_SUCCESS" and isPlayer ) then
            local spellName = select(13, ...)
            local spellId = select(7, GetSpellInfo(spellName))

            local isFriendly = bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) > 0
            if ( spellId and CREATE_HEALTHSTONE_BY_SPELLID[spellId] and isFriendly ) then
                HST:debug(srcName, "successfully casted", spellName)
                HST.playersWithHealthstones[srcName] = true
                HST.pluginCallbacks:Fire("updateUnitHealthstone", srcName, true)
            end
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
end)
