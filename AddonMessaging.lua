local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "AddonMessaging"


---------------------------------------------
-- CONSTANTS
---------------------------------------------
local ADDON_MESSAGE_PREFIX = "HST#349620"
local PLAYER_NAME = UnitName("player")
local PLAYER_FULLNAME = table.concat({UnitFullName("player")},"-")


---------------------------------------------
-- UTILITIES
---------------------------------------------
local function tobool(value)
    return string.lower(value) == "true"
end


---------------------------------------------
-- CACHEUPDATE
---------------------------------------------
function HST:SendCacheUpdate(timestamp, unitname, hasHealthstone, isForced)
    -- HST#139912   CACHEUPDATE:1:timestampe:isForced:unitname:hasHealthstone
    if ( C:is("DistributedCacheEnabled") ) then
        local message = { "CACHEUPDATE", 1, timestamp, isForced, unitname, hasHealthstone }
        C_ChatInfo.SendAddonMessage(ADDON_MESSAGE_PREFIX, table.concat(message, ":"), "RAID")
    end
end

local function handleCacheUpdate(version, ...)
    if ( not C:is("DistributedCacheEnabled") ) then
        return
    end

    if ( version == 1 ) then
        local timestamp, isForced, unitname, hasHealthstone = ...
        timestamp = tonumber(timestamp)
        isForced = tobool(isForced)
        hasHealthstone = tobool(hasHealthstone)
        HST:SetPlayerHealthstone(timestamp, unitname, hasHealthstone, isForced, true --[[doNotSendDistributedCacheUpdate]])
    end
end


---------------------------------------------
-- ADDON MESSAGE HANDLER
---------------------------------------------
local function handleAddonMessage(event, prefix, message, distribution, sender)
    if ( prefix == ADDON_MESSAGE_PREFIX ) then
        --@alpha@
        print(prefix, "      ", distribution, sender, message)
        --@end-alpha@

        -- Do not respond to my own messages
        if ( sender == PLAYER_FULLNAME or sender == PLAYER_NAME ) then
            --[===[@non-debug@
            return
            --@end-non-debug@]===]
        end

        local args = {strsplit(":", message)}
        if ( #args >= 2 ) then
            local msgtype = tremove(args, 1)
            local version = tremove(args, 1)
            if ( msgtype == "CACHEUPDATE" ) then
                handleCacheUpdate(version, unpack(args))
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

    -- Register prefix
    C_ChatInfo.RegisterAddonMessagePrefix(ADDON_MESSAGE_PREFIX)

    -- Watch for addon messages
    HST.RegisterEvent(MODULE_NAME, "CHAT_MSG_ADDON", handleAddonMessage)
end)
