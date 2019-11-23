local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "config.lua"


---------------------------------------------
-- CONSTANTS
---------------------------------------------
local IS_CLASSIC = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local IS_HORDE = UnitFactionGroup("player")=="Horde"

local SHAMAN_PALADIN_TEXTURE_ICON = IS_HORDE and HST.Media.CLASS_TEXTURE_ICONS.SHAMAN or HST.Media.CLASS_TEXTURE_ICONS.PALADIN


---------------------------------------------
-- LOCALIZATION
---------------------------------------------
local L_ADDON_NAME = L["Warlock Healthstone Tracker"]
local L_ADDON_DESCRIPTION = L["Track healthstones used by party & raid members"]
local L_DEBUG = L["Debug"]
local L_DEBUG_DESCRIPTION = L["Enable debugging"]
local L_LOG_CONSUMED_HEALTHSTONES = L["Enable healthstone consumed message"]
local L_LOG_CONSUMED_HEALTHSTONES_DESCRIPTION = L["Display a message in chat when a party or raid member consumes a healthstone. Only visible to you."]
local L_GENERAL = GENERAL
local L_CACHE = L["Cache"]
local L_CACHE_DESCRIPTION = L["Party and Raid members with healthstones"]
local L_PARTY = PARTY
local L_RAID = RAID
local L_LISTVIEW = L["List view"]
local L_LISTVIEW_DESCRIPTION = L["View players without healthstones as a simple list"]
local L_ENABLE = ENABLE
local L_LOCK_WINDOW = L["Lock window"]
local L_LOCK_WINDOW_DESCRIPTION = L["Disable dragging and resizing of the window"]
local L_HIDE_WHEN_EMPTY = L["Hide frame when empty"]
local L_HIDE_WHEN_EMPTY_DESCRIPTION = L["Hide list view when everyone has a healthstone"]
local L_HIDE_WHEN_IN_COMBAT = L["Hide frame when in combat"]
local L_HIDE_WHEN_IN_COMBAT_DESCRIPTION = L["Hide list view during combat"]
local L_HIDE_WHEN_NOT_IN_GROUP = L["Hide frame when not in group"]
local L_HIDE_WHEN_NOT_IN_GROUP_DESCRIPTION = L["Hide list view when not in party or raid"]
local L_RESET_DEFAULTS = L["Reset to Defaults"]
local L_RESET_DEFAULTS_DESCRIPTION = L["Reset all options, frame sizing, and position to defaults"]
local L_LISTVIEW_FILTERS = FILTERS
local L_LISTVIEW_FILTER_DESCRIPTION = L["Filters are applied to groups based on group size"]
local L_LISTVIEW_FILTER_GROUPSIZE = L["Group size"]
local L_LISTVIEW_FILTER_GROUPSIZE_DESCRIPTION = L["Filters do not apply to groups with less players than the selected size"]
local L_LISTVIEW_FILTER_GROUPSIZE_2 = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE2PLAYERS
local L_LISTVIEW_FILTER_GROUPSIZE_3 = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE3PLAYERS
local L_LISTVIEW_FILTER_GROUPSIZE_5 = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE5PLAYERS
local L_LISTVIEW_FILTER_GROUPSIZE_10 = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE10PLAYERS
local L_LISTVIEW_FILTER_GROUPSIZE_15 = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE15PLAYERS
local L_LISTVIEW_FILTER_GROUPSIZE_20 = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE20PLAYERS
local L_LISTVIEW_FILTER_GROUPSIZE_40 = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE40PLAYERS
local L_TANK = TANK
local L_LISTVIEW_FILTER_TANK_DESCRIPTION = L["Show players with tank role"]
local L_HEALER = HEALER
local L_LISTVIEW_FILTER_HEALER_DESCRIPTION = L["Show players with healer role"]
local L_DAMAGER = DAMAGER
local L_LISTVIEW_FILTER_DAMAGER_DESCRIPTION = L["Show players with damage role"]
local L_WARRIOR = C_CreatureInfo.GetClassInfo(1).className
local L_LISTVIEW_FILTER_WARRIOR_DESCRIPTION = L["Show all warriors"]
local L_SHAMAN = C_CreatureInfo.GetClassInfo(7).className
local L_LISTVIEW_FILTER_SHAMAN_DESCRIPTION = L["Show all shamans"]
local L_PALADIN = C_CreatureInfo.GetClassInfo(2).className
local L_LISTVIEW_FILTER_PALADIN_DESCRIPTION =  L["Show all paladins"]
local L_HUNTER = C_CreatureInfo.GetClassInfo(3).className
local L_LISTVIEW_FILTER_HUNTER_DESCRIPTION = L["Show all hunters"]
local L_ROGUE = C_CreatureInfo.GetClassInfo(4).className
local L_LISTVIEW_FILTER_ROGUE_DESCRIPTION = L["Show all rogues"]
local L_PRIEST = C_CreatureInfo.GetClassInfo(5).className
local L_LISTVIEW_FILTER_PRIEST_DESCRIPTION = L["Show all priests"]
local L_MAGE = C_CreatureInfo.GetClassInfo(8).className
local L_LISTVIEW_FILTER_MAGE_DESCRIPTION = L["Show all mages"]
local L_WARLOCK = C_CreatureInfo.GetClassInfo(9).className
local L_LISTVIEW_FILTER_WARLOCK_DESCRIPTION = L["Show all warlocks"]
local L_DRUID = C_CreatureInfo.GetClassInfo(11).className
local L_LISTVIEW_FILTER_DRUID_DESCRIPTION = L["Show all druids"]


---------------------------------------------
-- UTILITIES
---------------------------------------------
local function clone(instance)
    local obj = {}
    local k,v = next(instance)
    while ( k ~= nil ) do
        obj[k] = ( type(v) ~= "table" ) and v or clone(v)
        k,v = next(instance, k)
    end
    return obj;
end

local function formatClass(class, str)
    return HST.Media.CLASS_TEXTURE_ICONS[class] .. " " .. GetClassColorObj(class):WrapTextInColorCode(str)
end

---------------------------------------------
-- OPTIONS
---------------------------------------------
C.DEFAULT_DB = {
    ["Version"] = 1,
    ["Debug"] = false,
    ["EnableHealthstoneConsumedMessage"] = true,
    ["DistributedCacheEnabled"] = true,
    ListView = {
        ["Enabled"] = true,
        ["Locked"] = false,
        ["HideWhenEmpty"] = false, -- false by default so initial users can position windows
        ["HideWhenInCombat"] = false,
        ["HideWhenNotInGroup"] = false,
        ["FilterGroupSize"] = 10,
        Filters = {
            ["TANK"] = true,
            ["HEALER"] = true,
            ["DAMAGER"] = true,
            ["DRUID"] = true,
            ["HUNTER"] = true,
            ["MAGE"] = true,
            ["PALADIN"] = true,
            ["PRIEST"] = true,
            ["ROGUE"] = true,
            ["SHAMAN"] = true,
            ["WARLOCK"] = true,
            ["WARRIOR"] = true,
        },
    },
}

local optionListeners = LibStub("CallbackHandler-1.0"):New(C, "RegisterListener", "UnregisterListener", false)

local function setDefaults(DB, DEFAULTS)
    -- find any nil values and set to default values
    for k,v in pairs(DEFAULTS) do
        if ( DB[k] == nil ) then
            if ( type(v) == "table") then
                DB[k] = {}
            else
                DB[k] = v
                HST:debug("")
            end
        end

        if ( type(DB[k]) == "table" ) then
            setDefaults(DB[k], v)
        end
    end

    -- clean up unknown values
    for k,v in pairs(DB) do
        if ( DEFAULTS[k] == nil ) then
            DB[k] = nil
        end
    end
end

function C:upgradeDB()
    if ( WarlockHealthstoneTrackerDB["Version"] == C.DEFAULT_DB["Version"] ) then
        setDefaults(WarlockHealthstoneTrackerDB, C.DEFAULT_DB)
    end
end

function C:is(option)
    return C:get(option) == true
end

function C:get(option)
    if ( WarlockHealthstoneTrackerDB ) then
        -- Walk the path until we have a final value
        local path = { strsplit("./", option) }
        local obj = WarlockHealthstoneTrackerDB
        for _,v in ipairs(path) do
            obj = obj[v]
            if ( obj == nil ) then
                error("Failed to find option '" .. option .. "'")
            end
        end
        return obj
    end

    return nil
end


function HST:debug(...)
    if ( C:is("Debug") ) then
        print("[" .. HST.ADDON_NAME .. "]", ...)
    end
end

local function getOption(info)
    return C:get(info.arg)
end

local function setOption(info, value)
    if ( WarlockHealthstoneTrackerDB ) then
        -- Walk the path until we have a final value
        local path = { strsplit("./", info.arg) }
        local o = WarlockHealthstoneTrackerDB
        local finalArg = tremove(path, #path)
        for _,v in ipairs(path) do
            o = o[v]
        end
        o[finalArg] = value

        optionListeners:Fire(info.arg, value)
    end
end

local function getCacheUnit(info)
    local raidunit, partyunit = unpack(info.arg)
    if ( UnitInRaid("player") ) then
        return raidunit
    else
        return partyunit
    end
end

local function getUnitName(info)
    local unit = getCacheUnit(info)
    if ( UnitExists(unit) ) then
        local class = select(2,UnitClass(unit))
        return formatClass(class, UnitName(unit))
    end
    return unit
end

local function getDisabled(info)
    local unit = getCacheUnit(info)
    return not UnitExists(unit)
end

local function getHidden(info)
    local unit = getCacheUnit(info)
    return unit == nil
end

local function getCache(info)
    local unit = getCacheUnit(info)
    if ( UnitExists(unit) ) then
        local unitname = UnitName(unit)
        return HST.playersWithHealthstones[unitname] == true
    end
    return false
end

local function setCache(info, value)
    local unit = getCacheUnit(info)
    if ( UnitExists(unit) ) then
        local unitname = UnitName(unit)
        HST:SetPlayerHealthstone(nil, unitname, value, true --[[isForced]])
    end
end


---------------------------------------------
-- CONFIG
---------------------------------------------
local AceConfig = LibStub("AceConfig-3.0")
AceConfig:RegisterOptionsTable(HST.ADDON_NAME, {
    type = "group",
    name = L_ADDON_NAME,
    args = {
        general = {
            order = 1,
            type = "group",
            name = L_GENERAL,
            args = {
                resetDefaults = {
                    order = 9000,
                    type = "execute",
                    name = L_RESET_DEFAULTS,
                    desc = L_RESET_DEFAULTS_DESCRIPTION,
                    func = function()
                        WarlockHealthstoneTrackerListView:ClearAllPoints()
                        WarlockHealthstoneTrackerListView:SetPoint("CENTER", UIParent)
                        WarlockHealthstoneTrackerListView:SetSize(150, 100)
                        WarlockHealthstoneTrackerDB = clone(C.DEFAULT_DB)
                        optionListeners:Fire("ListView/Locked", C:get("ListView/Locked"))
                    end
                },
                desc = {
                    order = 1,
                    type = "description",
                    name = L_ADDON_DESCRIPTION,
                    width = "full"
                },
                emptySpace = {
                    order = 3,
                    type = "description",
                    name = " ",
                    width = "full"
                },
                logHealthstonesConsumed = {
                    order = 10,
                    type = "toggle",
                    name = L_LOG_CONSUMED_HEALTHSTONES,
                    desc = L_LOG_CONSUMED_HEALTHSTONES_DESCRIPTION,
                    set = setOption,
                    get = getOption,
                    width = "full",
                    arg = "EnableHealthstoneConsumedMessage"
                },
                debug = {
                    order = 100,
                    type = "toggle",
                    name = L_DEBUG,
                    desc = L_DEBUG_DESCRIPTION,
                    set = setOption,
                    get = getOption,
                    width = "normal",
                    arg = "Debug"
                },
                debug_spacer = {
                    order = 101,
                    type = "description",
                    name = "",
                    width = "double"
                },
                listview = {
                    order = 200,
                    type = "group",
                    inline = true,
                    name = L_LISTVIEW,
                    args = {
                        desc = {
                            order = 1,
                            type = "description",
                            name = L_LISTVIEW_DESCRIPTION,
                            width = "full"
                        },
                        emptySpace = {
                            order = 3,
                            type = "description",
                            name = " ",
                            width = "full"
                        },
                        enable = {
                            order = 10,
                            type = "toggle",
                            name = L_ENABLE,
                            set = setOption,
                            get = getOption,
                            width = "full",
                            arg = "ListView/Enabled"
                        },
                        lock = {
                            order = 20,
                            type = "toggle",
                            name = L_LOCK_WINDOW,
                            desc = L_LOCK_WINDOW_DESCRIPTION,
                            set = setOption,
                            get = getOption,
                            width = "full",
                            arg = "ListView/Locked"
                        },
                        hideWhenEmpty = {
                            order = 30,
                            type = "toggle",
                            name = L_HIDE_WHEN_EMPTY,
                            desc = L_HIDE_WHEN_EMPTY_DESCRIPTION,
                            set = setOption,
                            get = getOption,
                            width = "full",
                            arg = "ListView/HideWhenEmpty"
                        },
                        hideWhenInCombat = {
                            order = 40,
                            type = "toggle",
                            name = L_HIDE_WHEN_IN_COMBAT,
                            desc = L_HIDE_WHEN_IN_COMBAT_DESCRIPTION,
                            set = setOption,
                            get = getOption,
                            width = "full",
                            arg = "ListView/HideWhenInCombat"
                        },
                        hideWhenNotInGroup = {
                            order = 60,
                            type = "toggle",
                            name = L_HIDE_WHEN_NOT_IN_GROUP,
                            desc = L_HIDE_WHEN_NOT_IN_GROUP_DESCRIPTION,
                            set = setOption,
                            get = getOption,
                            width = "full",
                            arg = "ListView/HideWhenNotInGroup"
                        },
                        filters = {
                            order = 1000,
                            type = "group",
                            inline = true,
                            name = L_LISTVIEW_FILTERS,
                            args = {
                                desc = {
                                    order = 1,
                                    type = "description",
                                    name = L_LISTVIEW_FILTER_DESCRIPTION,
                                    width = "full"
                                },
                                filterGroupSize = {
                                    order = 10,
                                    type = "select",
                                    name = L_LISTVIEW_FILTER_GROUPSIZE,
                                    desc = L_LISTVIEW_FILTER_GROUPSIZE_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    values = {
                                        [2] = L_LISTVIEW_FILTER_GROUPSIZE_2,
                                        [3] = L_LISTVIEW_FILTER_GROUPSIZE_3,
                                        [5] = L_LISTVIEW_FILTER_GROUPSIZE_5,
                                        [10] = L_LISTVIEW_FILTER_GROUPSIZE_10,
                                        [15] = L_LISTVIEW_FILTER_GROUPSIZE_15,
                                        [20] = L_LISTVIEW_FILTER_GROUPSIZE_20,
                                        [40] = L_LISTVIEW_FILTER_GROUPSIZE_40,
                                    },
                                    width = "normal",
                                    arg = "ListView/FilterGroupSize"
                                },
                                filterGroupSize_spacer = {
                                    order = 19,
                                    type = "description",
                                    name = "",
                                    width = "double",
                                },
                                filterTank = {
                                    order = 20,
                                    type = "toggle",
                                    name = HST.Media.ROLE_TEXTURE_ICONS.TANK .. " " ..L_TANK,
                                    desc = L_LISTVIEW_FILTER_TANK_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    width = "normal",
                                    arg = "ListView/Filters/TANK"
                                },
                                filterDruid = {
                                    order = 23,
                                    type = "toggle",
                                    name = formatClass("DRUID", L_DRUID),
                                    desc = L_LISTVIEW_FILTER_DRUID_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    width = "normal",
                                    arg = "ListView/Filters/DRUID"
                                },
                                filterHunter = {
                                    order = 26,
                                    type = "toggle",
                                    name = formatClass("HUNTER", L_HUNTER),
                                    desc = L_LISTVIEW_FILTER_HUNTER_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    width = "normal",
                                    arg = "ListView/Filters/HUNTER"
                                },
                                filterHealer = {
                                    order = 30,
                                    type = "toggle",
                                    name = HST.Media.ROLE_TEXTURE_ICONS.HEALER .. " " ..L_HEALER,
                                    desc = L_LISTVIEW_FILTER_HEALER_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    hidden = IS_CLASSIC,
                                    disabled = IS_CLASSIC,
                                    width = "normal",
                                    arg = "ListView/Filters/HEALER"
                                },
                                healerSpacer = {
                                    order = 30,
                                    type = "description",
                                    name = "",
                                    hidden = not IS_CLASSIC,
                                    width = "normal",
                                },
                                filterMage = {
                                    order = 33,
                                    type = "toggle",
                                    name = formatClass("MAGE", L_MAGE),
                                    desc = L_LISTVIEW_FILTER_MAGE_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    width = "normal",
                                    arg = "ListView/Filters/MAGE"
                                },
                                filterPriest = {
                                    order = 36,
                                    type = "toggle",
                                    name = formatClass("PRIEST", L_PRIEST),
                                    desc = L_LISTVIEW_FILTER_PRIEST_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    width = "normal",
                                    arg = "ListView/Filters/PRIEST"
                                },
                                filterDamager= {
                                    order = 40,
                                    type = "toggle",
                                    name = HST.Media.ROLE_TEXTURE_ICONS.DAMAGER .. " " ..L_DAMAGER,
                                    desc = L_LISTVIEW_FILTER_DAMAGER_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    hidden = IS_CLASSIC,
                                    disabled = IS_CLASSIC,
                                    width = "normal",
                                    arg = "ListView/Filters/DAMAGER"
                                },
                                damagerSpacer = {
                                    order = 40,
                                    type = "description",
                                    name = "",
                                    hidden = not IS_CLASSIC,
                                    width = "normal",
                                },
                                filterRogue = {
                                    order = 43,
                                    type = "toggle",
                                    name = formatClass("ROGUE", L_ROGUE),
                                    desc = L_LISTVIEW_FILTER_ROGUE_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    width = "normal",
                                    arg = "ListView/Filters/ROGUE"
                                },
                                filterShamanPaladin = {
                                    order = 46,
                                    type = "toggle",
                                    name = IS_HORDE and formatClass("SHAMAN", L_SHAMAN) or formatClass("PALADIN", L_PALADIN),
                                    desc = IS_HORDE and L_LISTVIEW_FILTER_SHAMAN_DESCRIPTION or L_LISTVIEW_FILTER_PALADIN_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    width = "normal",
                                    arg = IS_HORDE and "ListView/Filters/SHAMAN" or "ListView/Filters/PALADIN"
                                },
                                filterWarlock_prespacer = {
                                    order = 50,
                                    type = "description",
                                    name = "",
                                    width = "normal",
                                },
                                filterWarlock = {
                                    order = 53,
                                    type = "toggle",
                                    name = formatClass("WARLOCK", L_WARLOCK),
                                    desc = L_LISTVIEW_FILTER_WARLOCK_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    width = "normal",
                                    arg = "ListView/Filters/WARLOCK"
                                },
                                filterWarrior = {
                                    order = 56,
                                    type = "toggle",
                                    name = formatClass("WARRIOR", L_WARRIOR),
                                    desc = L_LISTVIEW_FILTER_WARRIOR_DESCRIPTION,
                                    set = setOption,
                                    get = getOption,
                                    width = "normal",
                                    arg = "ListView/Filters/WARRIOR"
                                },
                            },
                        },
                    },
                },
            },
        },
        cache = {
            order = 1,
            type = "group",
            name = L_CACHE,
            args = {
                desc = {
                    order = 1,
                    type = "description",
                    name = L_CACHE_DESCRIPTION,
                    width = "full"
                },
                emptySpace = {
                    order = 3,
                    type = "description",
                    name = " ",
                    width = "full"
                },
                raid1 = {
                    order = 10,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid1", "player" }
                },
                raid2 = {
                    order = 20,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid2", "party1" }
                },
                raid3 = {
                    order = 30,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid3", "party2" }
                },
                raid4 = {
                    order = 40,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid4", "party3" }
                },
                raid5 = {
                    order = 50,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid5", "party4" }
                },
                raid6 = {
                    order = 60,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid6" }
                },
                raid7 = {
                    order = 70,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid7" }
                },
                raid8 = {
                    order = 80,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid8" }
                },
                raid9 = {
                    order = 90,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid9" }
                },
                raid10 = {
                    order = 100,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid10" }
                },
                raid11 = {
                    order = 110,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid11" }
                },
                raid12 = {
                    order = 120,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid12" }
                },
                raid13 = {
                    order = 130,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid13" }
                },
                raid14 = {
                    order = 140,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid14" }
                },
                raid15 = {
                    order = 150,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid15" }
                },
                raid16 = {
                    order = 160,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid16" }
                },
                raid17 = {
                    order = 170,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid17" }
                },
                raid18 = {
                    order = 180,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid18" }
                },
                raid19 = {
                    order = 190,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid19" }
                },
                raid20 = {
                    order = 200,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid20" }
                },
                raid21 = {
                    order = 210,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid21" }
                },
                raid22 = {
                    order = 220,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid22" }
                },
                raid23 = {
                    order = 230,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid23" }
                },
                raid24 = {
                    order = 240,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid24" }
                },
                raid25 = {
                    order = 250,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid25" }
                },
                raid26 = {
                    order = 260,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid26" }
                },
                raid27 = {
                    order = 270,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid27" }
                },
                raid28 = {
                    order = 280,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid28" }
                },
                raid29 = {
                    order = 290,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid29" }
                },
                raid30 = {
                    order = 300,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid30" }
                },
                raid31 = {
                    order = 310,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid31" }
                },
                raid32 = {
                    order = 320,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid32" }
                },
                raid33 = {
                    order = 330,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid33" }
                },
                raid34 = {
                    order = 340,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid34" }
                },
                raid35 = {
                    order = 350,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid35" }
                },
                raid36 = {
                    order = 360,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid36" }
                },
                raid37 = {
                    order = 370,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid37" }
                },
                raid38 = {
                    order = 380,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid38" }
                },
                raid39 = {
                    order = 390,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid39" }
                },
                raid40 = {
                    order = 400,
                    type = "toggle",
                    name = getUnitName,
                    set = setCache,
                    get = getCache,
                    disabled = getDisabled,
                    hidden = getHidden,
                    width = "normal",
                    arg = { "raid40" }
                },
            },
        },
    },
})

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local configPanes = {}
configPanes.general = AceConfigDialog:AddToBlizOptions(HST.ADDON_NAME, HST.ADDON_NAME, nil, "general")
configPanes.cache = AceConfigDialog:AddToBlizOptions(HST.ADDON_NAME, L_CACHE, HST.ADDON_NAME, "cache")


---------------------------------------------
-- INITIALIZE
---------------------------------------------
HST.RegisterCallback(MODULE_NAME, "initialize", function()
    --@alpha@
    HST:debug("initalize module", MODULE_NAME)
    --@end-alpha@
end)
