local HST, C, L = unpack(select(2, ...))

local PLUGIN = LibStub:NewLibrary(HST.ADDON_NAME.."-1.0", 1)

HST.pluginCallbacks = LibStub("CallbackHandler-1.0"):New(PLUGIN)

function PLUGIN:PlayerHasHealthstone(playerName)
    return HST.playersWithHealthstones[playerName] == true
end


PLUGIN.RegisterCallback("debug", "updateUnitHealthstone", function(event, unitname, hasHealthstone)
    HST:debug(event, unitname, hasHealthstone)
    --@alpha@
    if ( C:is("Debug") ) then
        DevTools_Dump(HST.playersWithHealthstones)
    end
    --@end-alpha@
end)
