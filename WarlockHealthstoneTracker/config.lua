local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "config.lua"


---------------------------------------------
-- LOCALIZATION
---------------------------------------------
local L_ADDON_NAME = L["Warlock Healthstone Tracker"]
local L_ADDON_DESCRIPTION = L["Track healthstones used by party & raid members"]
local L_ENABLE_DEBUGGING = L["Enable Debugging"]
local L_LOG_CONSUMED_HEALTHSTONES = L["Enable healthstone consumed message"]
local L_LOG_CONSUMED_HEALTHSTONES_DESCRIPTION = L["Display a message in chat when a party or raid member consumes a healthstone. Only visible to you."]
local L_GENERAL = GENERAL
local L_CACHE = L["Cache"]
local L_CACHE_DESCRIPTION = L["Party and Raid members with healthstones"]
local L_PARTY = PARTY
local L_RAID = RAID

---------------------------------------------
-- OPTIONS
---------------------------------------------
C.DEFAULT_DB = {
    ["Version"] = 1,
    ["Debug"] = false,
    ["EnableHealthstoneConsumedMessage"] = true
}

function C:is(option)
    return WarlockHealthstoneTrackerDB and WarlockHealthstoneTrackerDB[option]
end


function HST:debug(...)
    if ( C:is("Debug") ) then
        print("[" .. HST.ADDON_NAME .. "]", ...)
    end
end

local function getOption(info)
    if ( WarlockHealthstoneTrackerDB ) then
        return WarlockHealthstoneTrackerDB[info.arg] --options:GetOption(info.arg)
    end
end

local function setOption(info, value)
    if ( WarlockHealthstoneTrackerDB ) then
        WarlockHealthstoneTrackerDB[info.arg] = value --options:SetOption(info.arg, value)
    end
end

local function getUnitName(info)
    if ( UnitExists(info.arg) ) then
        return UnitName(info.arg)
    end
    return info.arg
end

local function getCache(info)
    if ( UnitExists(info.arg) ) then
        local unitname = UnitName(info.arg)
        return HST.playersWithHealthstones[unitname] == true
    end
    return false
end

local function setCache(info, value)
    if ( UnitExists(info.arg) ) then
        local unitname = UnitName(info.arg)
        HST.playersWithHealthstones[unitname] = (value) and value or nil -- true or nil
        HST.pluginCallbacks:Fire("updateUnitHealthstone", unitname, value)
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
                --@debug@
                debug = {
                    order = 9002,
                    type = "toggle",
                    name = L_ENABLE_DEBUGGING,
                    set = setOption,
                    get = getOption,
                    width = "full",
                    arg = "Debug"
                },
                --@end-debug@
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
                party = {
                    order = 10,
                    type = "group",
                    inline = true,
                    name = L_PARTY,
                    args = {
                        player = {
                            order = 1,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "player"
                        },
                        party1 = {
                            order = 10,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "party1"
                        },
                        party2 = {
                            order = 20,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "party2"
                        },
                        party3 = {
                            order = 30,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "party3"
                        },
                        party4 = {
                            order = 40,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "party4"
                        },
                    },
                },
                raid = {
                    order = 20,
                    type = "group",
                    inline = true,
                    name = L_RAID,
                    args = {
                        raid1 = {
                            order = 10,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid1"
                        },
                        raid2 = {
                            order = 20,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid2"
                        },
                        raid3 = {
                            order = 30,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid3"
                        },
                        raid4 = {
                            order = 40,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid4"
                        },
                        raid5 = {
                            order = 50,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid5"
                        },
                        raid6 = {
                            order = 60,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid6"
                        },
                        raid7 = {
                            order = 70,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid7"
                        },
                        raid8 = {
                            order = 80,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid8"
                        },
                        raid9 = {
                            order = 90,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid9"
                        },
                        raid10 = {
                            order = 100,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid10"
                        },
                        raid11 = {
                            order = 110,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid11"
                        },
                        raid12 = {
                            order = 120,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid12"
                        },
                        raid13 = {
                            order = 130,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid13"
                        },
                        raid14 = {
                            order = 140,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid14"
                        },
                        raid15 = {
                            order = 150,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid15"
                        },
                        raid16 = {
                            order = 160,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid16"
                        },
                        raid17 = {
                            order = 170,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid17"
                        },
                        raid18 = {
                            order = 180,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid18"
                        },
                        raid19 = {
                            order = 190,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid19"
                        },
                        raid20 = {
                            order = 200,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid20"
                        },
                        raid21 = {
                            order = 210,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid21"
                        },
                        raid22 = {
                            order = 220,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid22"
                        },
                        raid23 = {
                            order = 230,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid23"
                        },
                        raid24 = {
                            order = 240,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid24"
                        },
                        raid25 = {
                            order = 250,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid25"
                        },
                        raid26 = {
                            order = 260,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid26"
                        },
                        raid27 = {
                            order = 270,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid27"
                        },
                        raid28 = {
                            order = 280,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid28"
                        },
                        raid29 = {
                            order = 290,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid29"
                        },
                        raid30 = {
                            order = 300,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid30"
                        },
                        raid31 = {
                            order = 310,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid31"
                        },
                        raid32 = {
                            order = 320,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid32"
                        },
                        raid33 = {
                            order = 330,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid33"
                        },
                        raid34 = {
                            order = 340,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid34"
                        },
                        raid35 = {
                            order = 350,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid35"
                        },
                        raid36 = {
                            order = 360,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid36"
                        },
                        raid37 = {
                            order = 370,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid37"
                        },
                        raid38 = {
                            order = 380,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid38"
                        },
                        raid39 = {
                            order = 390,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid39"
                        },
                        raid40 = {
                            order = 400,
                            type = "toggle",
                            name = getUnitName,
                            set = setCache,
                            get = getCache,
                            disabled = function(info) return not UnitExists(info.arg) end,
                            width = "normal",
                            arg = "raid40"
                        },
                    },
                },
            },
        },
    },
})

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local configPanes = {}
configPanes.general = AceConfigDialog:AddToBlizOptions(HST.ADDON_NAME, HST.ADDON_NAME, nil, "general")
configPanes.cache = AceConfigDialog:AddToBlizOptions(HST.ADDON_NAME, L_CACHE, HST.ADDON_NAME, "cache")

--[[
OptionsPanel.okay = function (self, perControlCallback)
    function applyChanges(self)
        if ( self.newValue ~= self.value ) then
            addon:debug(self.var, "=", self.newValue)
            self:SetValue(self.newValue)
        end
    end

    addon:debug("applying changes")
    applyChanges(AutoQuestWatchCheckBox)
    applyChanges(QuickQuestCompleteCheckBox)
    applyChanges(DebugCheckBox)
end

OptionsPanel.cancel = function (self, perControlCallback)
    function revertChanges(self)
        addon:debug(self.var, "=", self.value)
        self:SetValue(self.value)
    end

    addon:debug("reverting changes")
    revertChanges(AutoQuestWatchCheckBox)
    revertChanges(QuickQuestCompleteCheckBox)
    revertChanges(DebugCheckBox)
end]]

---------------------------------------------
-- INITIALIZE
---------------------------------------------

HST.RegisterCallback(MODULE_NAME, "initialize", function()
    --@debug@
    HST:debug("initalize module", MODULE_NAME)
    --@end-debug@
end)