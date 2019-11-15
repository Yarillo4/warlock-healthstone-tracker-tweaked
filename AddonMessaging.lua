local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "AddonMessaging"

HST.Messaging = {}


---------------------------------------------
-- CONSTANTS
---------------------------------------------
local ADDON_MESSAGE_PREFIX = "HST#349620"


---------------------------------------------
-- UTILITIES
---------------------------------------------
local function sendMessage(distributionType, target)
    local distributionType = target == nil and "RAID" or "WHISPER"
    C_ChatInfo.SendAddonMessage(ADDON_MESSAGE_PREFIX, table.concat(message, ":"), distributionType, target)
end

local function handleAddonMessage(event, prefix, message, distribution, sender)
    if ( prefix == ADDON_MESSAGE_PREFIX ) then
        --@alpha@
        HST:debug(prefix, "\t", distribution, sender, message)
        --@end-alpha@
        local args = strsplit(message, ":")
        local msgtype = tremove(args, 0)
        local version = tremove(args, 0)

        if ( msgtype == "CACHEUPDATE" ) then
            HST.Messaging:HandleCacheUpdate(version, unpack(args))
        end
    end
end


---------------------------------------------
-- CACHEUPATE
---------------------------------------------
function HST.Messaging:SendCacheUpdate(timestamp, unitname, hasHealthstone, isForced)
    -- HST#139912   CACHEUPDATE:1:time():false:Jeast:true
    if ( C:is("DistributedCacheEnabled") ) then
        assert(type(unitName) == "string")
        assert(type(hasHealthstone) == "boolean")
        assert(type(isForced) == "boolean")
        local message = { "DUMP", 1, timestamp, isForced, unitname, hasHealthstone }
        C_ChatInfo.SendAddonMessage(ADDON_MESSAGE_PREFIX, table.concat(message, ":"), "RAID")
    end
end

function HST.Messaging:HandleCacheUpdate(timestamp, isForced, unitname, hasHealthstone)
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
    HST.RegisterEvent(MODULE_NAME, "CHAT_MESSAGE_ADDON", handleAddonMessage)
end)
