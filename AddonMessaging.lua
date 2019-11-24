local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "AddonMessaging"


---------------------------------------------
-- CONSTANTS
---------------------------------------------
local ADDON_MESSAGE_PREFIX = "HST#349620"
local PLAYER_NAME = UnitName("player")
local PLAYER_FULLNAME = table.concat({UnitFullName("player")},"-")


---------------------------------------------
-- VARIABLES
---------------------------------------------
local previouslyInParty = false


---------------------------------------------
-- UTILITIES
---------------------------------------------
local function tobool(value)
    return string.lower(value) == "true"
end

local function createBatches(array, batchSize)
    local batches = {}

    local count, currentBatch = 0, 0
    for _,value in ipairs(array) do
        if ( count == 0 ) then
            tinsert(batches, {})
            currentBatch = currentBatch + 1
        end
        tinsert(batches[currentBatch], value)
        count = (count + 1) % batchSize
    end

    return batches
end

local function send(prefix, message, distribution, target)
    --@alpha@
    print(">", prefix, "   ", distribution, target, message)
    --@end-alpha@
    C_ChatInfo.SendAddonMessage(prefix, message, distribution, target)
end


---------------------------------------------
-- SYNC
---------------------------------------------
function HST:SendSync()
    -- HST#139912   SYNC:1
    if ( C:is("DistributedCacheEnabled") ) then
        if ( UnitInParty("player") ) then
            local message = { "SYNC", 1 }
            send(ADDON_MESSAGE_PREFIX, table.concat(message, ":"), "RAID")
        end
    end
end

local function handleSync(sender, version, ...)
    if ( not C:is("DistributedCacheEnabled") ) then
        return
    end

    local playersWithHealthstones = {}
    for unitname,_ in pairs(HST.playersWithHealthstones) do
        if ( UnitInRaid(unitname) or UnitInParty(unitname) or unitname == PLAYER_NAME ) then
            tinsert(playersWithHealthstones, unitname)
        end
    end

    HST:SendDump(playersWithHealthstones, sender)
end


---------------------------------------------
-- DUMP
---------------------------------------------
function HST:SendDump(playersWithHealthstones, target)
    -- HST#139912   DUMP:1:player1,player2
    if ( C:is("DistributedCacheEnabled") ) then
        local batches = createBatches(playersWithHealthstones, 10)
        for _,batch in ipairs(batches) do
            local message = { "DUMP", 1, table.concat(batch, ",") }
            send(ADDON_MESSAGE_PREFIX, table.concat(message, ":"), "WHISPER", target)
        end
    end
end

local function handleDump(sender, version, ...)
    if ( not C:is("DistributedCacheEnabled") ) then
        return
    end

    -- Update my cache with these details
    if ( version == 1 ) then
        local players = ...
        players = strsplit(",", players)
        for _,unitname in ipairs(players) do
            HST:SetPlayerHealthstone(nil, unitname, true, false, true --[[doNotSendDistributedCacheUpdate]])
        end
    end
end


---------------------------------------------
-- CACHEUPDATE
---------------------------------------------
function HST:SendCacheUpdate(timestamp, unitname, hasHealthstone, isForced)
    -- HST#139912   CACHEUPDATE:1:timestamp:isForced:unitname:hasHealthstone
    if ( C:is("DistributedCacheEnabled") ) then
        if ( UnitInRaid(unitname) or UnitInParty(unitname) ) then
            local message = { "CACHEUPDATE", 1, timestamp, tostring(isForced), unitname, tostring(hasHealthstone) }
            send(ADDON_MESSAGE_PREFIX, table.concat(message, ":"), "RAID")
        end
    end
end

local function handleCacheUpdate(sender, version, ...)
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
-- HANDLERS
---------------------------------------------
local function handleAddonMessage(event, prefix, message, distribution, sender)
    if ( prefix == ADDON_MESSAGE_PREFIX ) then
        --@alpha@
        print("<", prefix, "   ", distribution, sender, message)
        --@end-alpha@

        -- Do not respond to your own messages
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
                handleCacheUpdate(sender, version, unpack(args))
            elseif ( msgtype == "SYNC" ) then
                handleSync(sender, version, unpack(args))
            elseif ( msgtype == "DUMP" ) then
                handleDump(sender, version, unpack(args))
            end
        end
    end
end

local function handlePlayerLogin()
    previouslyInParty = UnitInParty("player")

    -- Synchronize CACHE upon login
    if ( previouslyInParty ) then
        HST:SendSync()
    end
end

local function handleGroupUpdate()
    -- Request SYNC if we were not previously in a group
    if ( not previouslyInParty ) then
        HST:SendSync()
        -- Immediately send CACHEUPDATE for yourself
        HST:SendCacheUpdate(GetServerTime(), PLAYER_NAME, HST:PlayerHasHealthstone(unitname), false --[[ isForced ]])
    end

    -- Update to reflect current in party status
    previouslyInParty = UnitInParty("player")
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

    -- Send sync on login
    HST.RegisterEvent(MODULE_NAME, "PLAYER_LOGIN", handlePlayerLogin)

    -- Send sync on joining a party/raid
    HST.RegisterEvent(MODULE_NAME, "GROUP_ROSTER_UPDATE", handleGroupUpdate)
end)


--@do-not-package@
---------------------------------------------
-- TESTS
---------------------------------------------
local function assertEqual(actual, expected, message)
    assert(actual == expected, string.format("%s. Expected: %s, Actual: %s", message, expected, actual))
end

-- No values, batch 2
local array = {}
local batches = createBatches(array, 2)
assertEqual(#batches, 0, "No values in batches of 2, should result in 0 batches")
-- 1 value, batch 2
array = {1}
batches = createBatches(array, 2)
assertEqual(#batches, 1, "1 value in batches of 2, should result in 1 batch")
assertEqual(#batches[1], 1, "1 value in batches of 2. Batch 1, should have 1 element")
assertEqual(batches[1][1], 1, "1 value in batches of 2. Batch 1 element 1, should be 1")
-- 2 value, batch 2
array = {1,2}
batches = createBatches(array, 2)
assertEqual(#batches, 1, "2 value in batches of 2, should result in 1 batch")
assertEqual(#batches[1], 2, "2 value in batches of 2. Batch 1, should have 2 elements")
assertEqual(batches[1][1], 1, "2 value in batches of 2. Batch 1 element 1, should be 1")
assertEqual(batches[1][2], 2, "2 value in batches of 2. Batch 1 element 2, should be 2")
-- 3 value, batch 3
array = {1,2,3}
batches = createBatches(array, 2)
assertEqual(#batches, 2, "3 value in batches of 2, should result in 2 batches")
assertEqual(#batches[1], 2, "3 value in batches of 2. Batch 1, should have 2 elements")
assertEqual(batches[1][1], 1, "3 value in batches of 2. Batch 1 element 1, should be 1")
assertEqual(batches[1][2], 2, "3 value in batches of 2. Batch 1 element 2, should be 2")
assertEqual(#batches[2], 1, "3 value in batches of 2. Batch 2, should have 1 element")
assertEqual(batches[2][1], 3, "3 value in batches of 2. Batch 2 element 1, should be 3")
-- 3 value, batch 1
array = {1,2,3}
batches = createBatches(array, 1)
assertEqual(#batches, 3, "3 value in batches of 1, should result in 2 batches")
assertEqual(#batches[1], 1, "3 value in batches of 1. Batch 1, should have 2 elements")
assertEqual(batches[1][1], 1, "3 value in batches of 1. Batch 1 element 1, should be 1")
assertEqual(#batches[2], 1, "3 value in batches of 1. Batch 2, should have 1 element")
assertEqual(batches[2][1], 2, "3 value in batches of 1. Batch 2 element 1, should be 2")
assertEqual(#batches[3], 1, "3 value in batches of 1. Batch 2, should have 1 element")
assertEqual(batches[3][1], 3, "3 value in batches of 1. Batch 3 element 1, should be 3")
--@end-do-not-package@
