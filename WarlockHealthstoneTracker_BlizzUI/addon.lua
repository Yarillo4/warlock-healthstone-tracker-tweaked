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
--@alpha@
LoadAddOn("Blizzard_DebugTools")
--@end-alpha@

HSTBlizzUI.RegisterCallback(MODULE_NAME, "initialize", function(event)
    --@alpha@
    HSTBlizzUI:debug("initalize module", MODULE_NAME)
    --@end-alpha@
end)

HSTBlizzUI.RegisterEvent(MODULE_NAME, "ADDON_LOADED", function(event, addonName)
    if ( addonName == HSTBlizzUI.ADDON_NAME ) then
        HSTBlizzUI.UnregisterEvent(MODULE_NAME, "ADDON_LOADED")

        --@alpha@
        HSTBlizzUI:debug("ADDON_LOADED", addonName)
        --@end-alpha@

        if ( not WarlockHealthstoneTracker_BlizzUIDB ) then
            --@alpha@
            print("[" .. HST.ADDON_NAME .. "]", "DB not found, using default configurations")
            --@end-alpha@
            WarlockHealthstoneTracker_BlizzUIDB = C.DEFAULT_DB
        end

        -- Register debug listener for all options
        local i = next(WarlockHealthstoneTracker_BlizzUIDB)
        while ( i ) do
            C:RegisterListener(i, function(...) HSTBlizzUI:debug(...) end)
            i = next(WarlockHealthstoneTracker_BlizzUIDB, i)
        end

        HSTBlizzUI.callbacks:Fire("initialize")
    end
end)