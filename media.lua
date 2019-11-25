local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "config.lua"

HST.Media = {}

---------------------------------------------
-- UTILITIES
---------------------------------------------
local function createTextureIcon(texture, oX, oY, tL, tR, tT, tB)
    local path, tW, tH = unpack(texture)
    return "|T" .. table.concat({ path, 0, 0, oX, oY, tW, tH, tL, tR, tT, tB }, ":") .. "|t"
end

function HST.Media:formatClass(unitname)
    local class = select(2,UnitClass(unitname))
    if ( class ) then
        return HST.Media.CLASS_TEXTURE_ICONS[class] .. " " .. GetClassColorObj(class):WrapTextInColorCode(unitname)
    else
        return unitname
    end
end


---------------------------------------------
-- TEXTURES
---------------------------------------------
local LFGROLE_TEXTURE = { [[Interface\LFGFrame\LFGROLE]], 64, 16 }
local CLASSICON_TEXTURE = { [[Interface\GLUES\CHARACTERCREATE\UI-CharacterCreate-Classes]], 256, 256 }


---------------------------------------------
-- TEXTURES ICONS
---------------------------------------------
HST.Media.ROLE_TEXTURE_ICONS = {
    TANK = createTextureIcon(LFGROLE_TEXTURE, 0, 0, 32, 48, 0, 16),
    HEALER = createTextureIcon(LFGROLE_TEXTURE, 0, 0, 48, 64, 0, 16),
    DAMAGER = createTextureIcon(LFGROLE_TEXTURE, 0, 0, 16, 32, 0, 16),
}
HST.Media.CLASS_TEXTURE_ICONS = {
    WARRIOR = createTextureIcon(CLASSICON_TEXTURE, 0, 0, 0, 64, 0, 64),
    MAGE = createTextureIcon(CLASSICON_TEXTURE, 0, 0, 64, 128, 0, 64),
    ROGUE = createTextureIcon(CLASSICON_TEXTURE, 0, 0, 128, 192, 0, 64),
    DRUID = createTextureIcon(CLASSICON_TEXTURE, 0, 0, 192, 256, 0, 64),
    HUNTER = createTextureIcon(CLASSICON_TEXTURE, 0, 0, 0, 64, 64, 128),
    SHAMAN = createTextureIcon(CLASSICON_TEXTURE, 0, 0, 64, 128, 64, 128),
    PRIEST = createTextureIcon(CLASSICON_TEXTURE, 0, 0, 128, 192, 64, 128),
    WARLOCK = createTextureIcon(CLASSICON_TEXTURE, 0, 0, 192, 256, 64, 128),
    PALADIN = createTextureIcon(CLASSICON_TEXTURE, 0, 0, 0, 64, 128, 192),
}
