local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "TrackHealthstonesEaten"


---------------------------------------------
-- LOCALIZATION
---------------------------------------------
local L_UNIT_ATE_HEALTHSTONE = L["ate a healthstone"];


---------------------------------------------
-- UTILITIES
---------------------------------------------
local function isPlayer(flags)
    return bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end

local function isPartyMember(flags)
    return bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0
end

local function isRaidMember(flags)
    return bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_RAID) > 0
end


---------------------------------------------
-- TRACK HEALTHSTONE CONSUMPTION
---------------------------------------------
local function trackHealthstoneUsage(...)
    local timestamp, event, hideCaster, srcGuid, srcName, srcFlags, srcRaidFlags, dstGuid, dstName, dstFlags, dstRaidFlags = ...
    if ( event == "SPELL_HEAL" ) then
        local spellId, spellName, spellSchool, healAmount, overhealing, absorbed, critical = select(12, ...)
        if ( HST.HEALTHSTONES_BY_NAME[spellName] )then
            HST.playersWithHealthstones[srcName] = nil
            HST.pluginCallbacks:Fire("updateUnitHealthstone", srcName, false)

            if ( C:is("EnableHealthstoneConsumedMessage") ) then
                print(srcName, L_UNIT_ATE_HEALTHSTONE)
            end
        end
    end
end


---------------------------------------------
-- INITIALIZE
---------------------------------------------
HST.RegisterCallback(MODULE_NAME, "initialize", function()
    --@debug@
    HST:debug("initalize module", MODULE_NAME)
    --@end-debug@

    -- Watch combat log for healthstone consumption
    HST.RegisterEvent(MODULE_NAME, "COMBAT_LOG_EVENT_UNFILTERED", function()
        trackHealthstoneUsage(CombatLogGetCurrentEventInfo())
    end)
end)
