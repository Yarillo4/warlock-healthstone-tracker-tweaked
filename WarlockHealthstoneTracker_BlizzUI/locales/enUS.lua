local ADDON_NAME = ...

local silent = false
--@debug@
silent = true -- do not show localization errors in dev
--@end-debug@

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true --[[isDefault]], silent)

if not L then
    return
end

--@localization(locale="enUS", format="lua_addititve_table", same-key-is-true=true, namespace="BlizzUI")@
--@localization(locale="enUS", format="lua_addititve_table", same-key-is-true=true, namespace="Common")@
