local HSTBlizzUI, C, L = unpack(select(2, ...))
local MODULE_NAME = "config.lua"


---------------------------------------------
-- LOCALIZATION
---------------------------------------------
local L_ADDON_NAME = L["Warlock Healthstone Tracker - BlizzUI Plugin"]
local L_ADDON_DESCRIPTION = L["Plugin that displays healthstone status on BlizzUI party and raid frames"]
local L_BLIZZ_UI = L["Blizzard UI"]
local L_SHOW_PARTY_HEALTHSTONES = L["Show healthstones for party members"]
local L_SHOW_PARTY_HEALTHSTONES_DESCRIPTION = L["Display healthstone icon on Blizzard party frames"]
local L_SHOW_RAID_HEALTHSTONES = L["Show healthstones for raid members"]
local L_SHOW_RAID_HEALTHSTONES_DESCRIPTION = L["Display healthstone icon on Blizzard raid frames"]
local L_DEBUG = L["Debug"]
local L_DEBUG_DESCRIPTION = L["Enable debugging"]


---------------------------------------------
-- OPTIONS
---------------------------------------------
local PlayerIsWarlock =(select(3, UnitClass("player")) == 9)

C.DEFAULT_DB = {
    ["Version"] = 1,
    ["ShowPartyHealthstones"] = PlayerIsWarlock, -- enabled for warlocks by default
    ["ShowRaidHealthstones"] = PlayerIsWarlock, -- enabled for warlocks by default
    ["Debug"] = false,
}

function C:is(option)
    return WarlockHealthstoneTracker_BlizzUIDB and WarlockHealthstoneTracker_BlizzUIDB[option]
end


function HSTBlizzUI:debug(...)
    if ( C:is("Debug") ) then
        print("[" .. HSTBlizzUI.ADDON_NAME .. "]", ...)
    end
end


---------------------------------------------
-- CONFIG
---------------------------------------------
local function getOption(info)
    if ( WarlockHealthstoneTracker_BlizzUIDB ) then
        return WarlockHealthstoneTracker_BlizzUIDB[info.arg]
    end
end

local function setOption(info, value)
    if ( WarlockHealthstoneTracker_BlizzUIDB ) then
        WarlockHealthstoneTracker_BlizzUIDB[info.arg] = value
    end
end

local AceConfig = LibStub("AceConfig-3.0")
AceConfig:RegisterOptionsTable(HSTBlizzUI.ADDON_NAME, {
    type = "group",
    name = L_ADDON_NAME,
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
        showPartyHealthstones = {
            order = 10,
            type = "toggle",
            name = L_SHOW_PARTY_HEALTHSTONES,
            desc = L_SHOW_PARTY_HEALTHSTONES_DESCRIPTION,
            set = setOption,
            get = getOption,
            width = "full",
            arg = "ShowPartyHealthstones"
        },
        showRaidHealthstones = {
            order = 20,
            type = "toggle",
            name = L_SHOW_RAID_HEALTHSTONES,
            desc = L_SHOW_RAID_HEALTHSTONES_DESCRIPTION,
            set = setOption,
            get = getOption,
            width = "full",
            arg = "ShowRaidHealthstones"
        },
        debug = {
            order = 9002,
            type = "toggle",
            name = L_DEBUG,
            desc = L_DEBUG_DESCRIPTION,
            set = setOption,
            get = getOption,
            width = "normal",
            arg = "Debug"
        },
    },
})

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local configPanes = {}
configPanes.general = AceConfigDialog:AddToBlizOptions(HSTBlizzUI.ADDON_NAME, L_BLIZZ_UI, "WarlockHealthstoneTracker")


---------------------------------------------
-- INITIALIZE
---------------------------------------------
HSTBlizzUI.RegisterCallback(MODULE_NAME, "initialize", function()
    --@debug@
    HSTBlizzUI:debug("initalize module", MODULE_NAME)
    --@end-debug@
end)
