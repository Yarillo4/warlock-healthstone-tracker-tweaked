local ADDON_NAME = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true --[[isDefault]], true --[[silent]])

if not L then
    return
end

--@localization(locale="enUS", format="lua_addititve_table", namespace="BlizzUI", same-key-is-true=true)@