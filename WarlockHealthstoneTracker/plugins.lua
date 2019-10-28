local HST, C, L = unpack(select(2, ...))

local PLUGIN = LibStub:NewLibrary(HST.ADDON_NAME.."-1.0", 1)

HST.pluginCallbacks = LibStub("CallbackHandler-1.0"):New(PLUGIN)

function PLUGIN:PlayerHasHealthstone(playerName)
    return HST:PlayerHasHealthstone(playerName)
end
