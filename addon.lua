local ADDON_NAME, ADDON = ...
local MODULE_NAME = "addon.lua"

ADDON[1] = {} -- HST, Addon
ADDON[2] = {} -- C, Config
ADDON[3] = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true) -- L, Locale
local HST, C, L = unpack(ADDON)

--@debug@
_G["HST"] = HST --Expose internals on the Plugin lib
--@end-debug@


---------------------------------------------
-- CONSTANTS
---------------------------------------------
HST.ADDON_NAME = ADDON_NAME
HST.VERSION = GetAddOnMetadata(ADDON_NAME, "Version")

HST.HEALTHSTONES_BY_ITEMID = { 5509, 5510, 5511, 5512, 9421, 19004, 19005, 19006, 19007, 19008, 19009, 19010, 19011, 19012, 19013 }
HST.HEALTHSTONES_BY_NAME = {} -- Localized healthstone names are loaded at runtime using GetItemInfo(itemId)
HST.HEALTHSTONES_HP = {
    [5512]  = 100,
    [19004] = 110,
    [19005] = 120,
    [5511]  = 250,
    [19006] = 275,
    [19007] = 300,
    [5509]  = 500,
    [19008] = 550,
    [19009] = 600,
    [5510]  = 800,
    [19010] = 880,
    [19011] = 960,
    [9421]  = 1200,
    [19012] = 1320,
    [19013] = 1440,
}

HST.IS_RELEASE_VERSION = HST.VERSION:match("^%d+.%d+.%d+$") ~= nil
--@debug@
HST.IS_RELEASE_VERSION = false
--@end-debug@



---------------------------------------------
-- VARIABLES
---------------------------------------------
HST.playersWithHealthstones = {}


---------------------------------------------
-- METHODS
---------------------------------------------
function HST:SetPlayerHealthstone(timestamp, unitname, hasHealthstone, isForced, doNotSendDistributedCacheUpdate)
    isForced = isForced or false
    timestamp = timestamp or GetServerTime()

    self.playersWithHealthstones[unitname] = hasHealthstone and true or nil
    self.pluginCallbacks:Fire("updateUnitHealthstone", unitname, hasHealthstone)

    if ( doNotSendDistributedCacheUpdate ) then
        return
    end

    HST:SendCacheUpdate(timestamp, unitname, hasHealthstone, isForced)
end

function HST:PlayerHasHealthstone(unitname)
    return HST.playersWithHealthstones[unitname] == true
end

function HST:debug(...)
    if ( C:is("Debug") ) then
        print("[" .. HST.ADDON_NAME .. "]", ...)
    end
end

function HST:trace(...)
    --@alpha@
    HST:debug(...)
    --@end-alpha@
end


---------------------------------------------
-- CACHE
---------------------------------------------
local function loadCache()
    local cache = WarlockHealthstoneTrackerCache
    WarlockHealthstoneTrackerCache = nil

    if ( cache ) then
        if ( cache.version == nil or cache.version == 1 ) then
            if ( cache.expiresAt > time() ) then
                for _,unitName in ipairs(cache.healthstones) do
                    HST:SetPlayerHealthstone(nil, unitName, true, false --[[isForced]], true --[[doNotSendDistributedCacheUpdate]])
                end
            end
        end
    end
end

local function writeCache()
    local healthstones = {}
    for unitName,_ in pairs(HST.playersWithHealthstones) do
        tinsert(healthstones, unitName)
    end

    WarlockHealthstoneTrackerCache = {
        version = 1,
        expiresAt = time() + 60,
        healthstones = healthstones
    }
end


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
--@debug@
LoadAddOn("Blizzard_DebugTools")
--@end-debug@

local GetItemInfoAsync = LibStub("GetItemInfoAsync-1.0")
HST.RegisterCallback(MODULE_NAME, "initialize", function(event)
    -- Initialize HealthstoneNames from itemId. (automatic localization)
    for _,itemID in pairs(HST.HEALTHSTONES_BY_ITEMID) do
        GetItemInfoAsync(itemID, function(itemName, ...)
            HST.HEALTHSTONES_BY_NAME[itemName] = true
        end)
    end
end)

HST.RegisterEvent(MODULE_NAME, "ADDON_LOADED", function(event, addonName)
    if ( addonName == HST.ADDON_NAME ) then
        HST.UnregisterEvent(MODULE_NAME, "ADDON_LOADED")

        if ( not WarlockHealthstoneTrackerDB ) then
            --@alpha@
            print("[" .. HST.ADDON_NAME .. "]", "DB not found, using default configurations")
            --@end-alpha@
            WarlockHealthstoneTrackerDB = C.DEFAULT_DB
        end
        C:upgradeDB()

        -- Register debug listener for all options
        local i = next(WarlockHealthstoneTrackerDB)
        while ( i ) do
            C:RegisterListener(i, function(...) HST:debug(...) end)
            i = next(WarlockHealthstoneTrackerDB, i)
        end

        -- Initialize addon modules
        HST.callbacks:Fire("initialize")

        -- Load cache
        loadCache()

        -- Write cache on logout
        HST.RegisterEvent(MODULE_NAME, "PLAYER_LOGOUT", writeCache)
    end
end)
