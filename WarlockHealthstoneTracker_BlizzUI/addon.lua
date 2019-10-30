local ADDON_NAME, ADDON = ...
local MODULE_NAME = "addon.lua"

ADDON[1] = {} -- HSTBlizzUI, Addon
ADDON[2] = {} -- C, Config
ADDON[3] = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME) -- L, Locale
local HSTBlizzUI, C, L = unpack(ADDON)

---------------------------------------------
-- CONSTANTS
---------------------------------------------
HSTBlizzUI.ADDON_NAME = ADDON_NAME
HSTBlizzUI.VERSION = GetAddOnMetadata(ADDON_NAME, "Version")


---------------------------------------------
-- EVENTS & CALLBACKS
---------------------------------------------
HSTBlizzUI.callbacks = LibStub("CallbackHandler-1.0"):New(HSTBlizzUI)
HSTBlizzUI.eventCallbacks = LibStub("CallbackHandler-1.0"):New(HSTBlizzUI, "RegisterEvent", "UnregisterEvent", false)

local frame = CreateFrame("frame")
frame:SetScript("OnEvent", function(self, event, ...)
    HSTBlizzUI.eventCallbacks:Fire(event, ...)
end)

function HSTBlizzUI.eventCallbacks:OnUsed(target, event)
    frame:RegisterEvent(event)
end
function HSTBlizzUI.eventCallbacks:OnUnused(target, event)
    frame:UnregisterEvent(event)
end


---------------------------------------------
-- INITIALIZE
---------------------------------------------
--@debug@
LoadAddOn("Blizzard_DebugTools")
--@end-debug@

HSTBlizzUI.RegisterCallback(MODULE_NAME, "initialize", function(event)
    --@debug@
    HSTBlizzUI:debug("initalize module", MODULE_NAME)
    --@end-debug@
end)

HSTBlizzUI.RegisterEvent(MODULE_NAME, "ADDON_LOADED", function(event, addonName)
    if ( addonName == HSTBlizzUI.ADDON_NAME ) then
        HSTBlizzUI.UnregisterEvent(MODULE_NAME, "ADDON_LOADED")

        --@debug@
        HSTBlizzUI:debug("ADDON_LOADED")
        --@end-debug@

        if ( not WarlockHealthstoneTracker_BlizzUIDB ) then
            HSTBlizzUI:debug("WarlockHealthstoneTracker_BlizzUIDB not found, using defaults")
            WarlockHealthstoneTracker_BlizzUIDB = C.DEFAULT_DB
        end

        HSTBlizzUI.callbacks:Fire("initialize")
    end
end)