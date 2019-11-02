local ADDON_NAME, ADDON = ...
local MODULE_NAME = "addon.lua"

ADDON[1] = {} -- HST, Addon
ADDON[2] = {} -- C, Config
ADDON[3] = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true) -- L, Locale
local HST, C, L = unpack(ADDON)

---------------------------------------------
-- CONSTANTS
---------------------------------------------
HST.ADDON_NAME = ADDON_NAME
HST.VERSION = GetAddOnMetadata(ADDON_NAME, "Version")

HST.HEALTHSTONES_BY_ITEMID = { 5509, 5510, 5511, 5512, 9421, 19004, 19005, 19006, 19007, 19008, 19009, 19010, 19011, 19012, 19013 }
HST.HEALTHSTONES_BY_NAME = {} -- Localized healthstone names are loaded at runtime using GetItemInfo(itemId)


---------------------------------------------
-- VARIABLES
---------------------------------------------
HST.playersWithHealthstones = {}


---------------------------------------------
-- EVENTS & CALLBACKS
---------------------------------------------
HST.callbacks = LibStub("CallbackHandler-1.0"):New(HST)
HST.eventCallbacks = LibStub("CallbackHandler-1.0"):New(HST, "RegisterEvent", "UnregisterEvent", false)

local frame = CreateFrame("frame")
frame:SetScript("OnEvent", function(self, event, ...)
    HST.eventCallbacks:Fire(event, ...)
end)

function HST.eventCallbacks:OnUsed(target, event)
    frame:RegisterEvent(event)
end
function HST.eventCallbacks:OnUnused(target, event)
    frame:UnregisterEvent(event)
end


---------------------------------------------
-- INITIALIZE
---------------------------------------------
--@alpha@
LoadAddOn("Blizzard_DebugTools")
--@end-alpha@

local GetItemInfoAsync = LibStub("GetItemInfoAsync-1.0")
HST.RegisterCallback(MODULE_NAME, "initialize", function(event)
    --@alpha@
    HST:debug("initalize module", MODULE_NAME)
    --@end-alpha@

    -- Initialize HealthstoneNames from itemId. (automatic localization)
    for _,itemID in pairs(HST.HEALTHSTONES_BY_ITEMID) do
        GetItemInfoAsync(itemID, function(itemName, ...)
            --@alpha@
            HST:debug("Retrieved item", itemID, itemName)
            --@end-alpha@
            HST.HEALTHSTONES_BY_NAME[itemName] = true
        end)
    end
end)

HST.RegisterEvent(MODULE_NAME, "ADDON_LOADED", function(event, addonName)
    if ( addonName == HST.ADDON_NAME ) then
        HST.UnregisterEvent(MODULE_NAME, "ADDON_LOADED")

        --@alpha@
        HST:debug("ADDON_LOADED", addonName)
        --@end-alpha@

        if ( not WarlockHealthstoneTrackerDB ) then
            --@alpha@
            print("[" .. HST.ADDON_NAME .. "]", "DB not found, using default configurations")
            --@end-alpha@
            WarlockHealthstoneTrackerDB = C.DEFAULT_DB
        end

        -- Register debug listener for all options
        local i = next(WarlockHealthstoneTrackerDB)
        while ( i ) do
            C:RegisterListener(i, function(...) HST:debug(...) end)
            i = next(WarlockHealthstoneTrackerDB, i)
        end

        -- Initialize addon modules
        HST.callbacks:Fire("initialize")
    end
end)