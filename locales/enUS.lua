local ADDON_NAME = ...

local silent = false
--@debug@
silent = true -- do not show localization errors in dev
--@end-debug@

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true --[[isDefault]], silent)

if not L then
    return
end

--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true)@
