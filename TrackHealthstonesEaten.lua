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

    local isPlayer = bit.band(srcFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
    if ( event == "SPELL_HEAL" and isPlayer ) then
        local spellId, spellName, spellSchool, healAmount, overhealing, absorbed, critical = select(12, ...)

        if ( HST.HEALTHSTONES_BY_NAME[spellName] ) then
            --[[
                Normally players of the opposite faction are considered hostile, even when not pvp flagged.
                Dueling players however are also considered hostile. This makes it difficult to differentiate
                between a dueling player and players of the opposite faction.

                Best we can do is only report when playerHasHealthstone OR isFriendly
            ]]
            local isFriendly = bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) > 0
            if ( HST.playersWithHealthstones[srcName] or isFriendly ) then
                HST.playersWithHealthstones[srcName] = nil
                HST.pluginCallbacks:Fire("updateUnitHealthstone", srcName, false)

                if ( C:is("EnableHealthstoneConsumedMessage") ) then
                    print(srcName, L_UNIT_ATE_HEALTHSTONE)
                else
                    HST:Debug(srcName, L_UNIT_ATE_HEALTHSTONE)
                end
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

    -- Watch combat log for healthstone consumption
    HST.RegisterEvent(MODULE_NAME, "COMBAT_LOG_EVENT_UNFILTERED", function(event)
        trackHealthstoneUsage(CombatLogGetCurrentEventInfo())
    end)
end)
