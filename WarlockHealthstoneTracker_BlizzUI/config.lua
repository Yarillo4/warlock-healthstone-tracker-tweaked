local HSTBlizzUI, C, L = unpack(select(2, ...))
local MODULE_NAME = "config.lua"

local AceConfig = LibStub("AceConfig-3.0")
--AceConfig:RegisterOptionsTable(HST.ADDON_NAME, myOptions)


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
        print("[" .. HST.ADDON_NAME .. "]", ...)
    end
end


---------------------------------------------
-- INITIALIZE
---------------------------------------------

HSTBlizzUI.RegisterCallback(MODULE_NAME, "initialize", function()
    --@debug@
    HSTBlizzUI:debug("initalize module", MODULE_NAME)
    --@end-debug@
end)