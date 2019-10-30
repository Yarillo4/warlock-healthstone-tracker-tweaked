local HSTBlizzUI, C, L = unpack(select(2, ...))
local MODULE_NAME = "BlizzPartyUI"

local PLUGIN = LibStub("WarlockHealthstoneTracker-1.0", 1)

---------------------------------------------
-- CONSTANTS
---------------------------------------------
local HEALTHSTONE_TEXTURE_SCALING = 0.1


---------------------------------------------
-- UTILITIES
---------------------------------------------
local function createHealthstoneTexture(frame)
    frame.Healthstone = CreateFrame("Frame", nil, frame)
    frame.Healthstone:SetFrameStrata("HIGH")
    frame.Healthstone:SetHeight(16)
    frame.Healthstone:SetWidth(16)
    frame.Healthstone:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -2, 0)
    frame.Healthstone.texture = frame.Healthstone:CreateTexture(nil, "Artwork", nil)
    frame.Healthstone.texture:SetTexture("Interface\\ICONS\\INV_Stone_04")
    frame.Healthstone.texture:SetAllPoints()
    frame.Healthstone.texture:SetTexCoord(0+HEALTHSTONE_TEXTURE_SCALING, 1-HEALTHSTONE_TEXTURE_SCALING, 0+HEALTHSTONE_TEXTURE_SCALING, 1-HEALTHSTONE_TEXTURE_SCALING)
    frame.Healthstone:Hide()
end

local function updatePartyMemberHealthstone(event, unitName, hasHealthstone)
    --@debug@
    HSTBlizzUI:debug(unitName, "ShowPartyHealthstones", C:is("ShowPartyHealthstones"), "inParty", UnitInParty(unitName), "hasHealthstone", hasHealthstone)
    --@end-debug@

    if ( C:is("ShowPartyHealthstones") and UnitInParty(unitName) ) then
        for i = 1,MAX_PARTY_MEMBERS do
            local unit = "party"..i
            if ( UnitExists(unit) and unitName == UnitName(unit) ) then
                _G["PartyMemberFrame"..i].Healthstone:SetShown(hasHealthstone)
            end
        end
    end
end

local function showHideHealthstone(self)
    if ( not self ) then
        return
    end

    if ( C:is("ShowPartyHealthstones") ) then
        local unit = "party" .. self:GetID()
        if ( UnitExists(unit) ) then
            if ( PLUGIN:PlayerHasHealthstone(UnitName(unit)) ) then
                --@alpha@
                HSTBlizzUI:debug("Show healthstone for", unit)
                --@end-alpha@
                self.Healthstone:Show()
            else
                --@alpha@
                HSTBlizzUI:debug("Hide healthstone for", unit)
                --@end-alpha@
                self.Healthstone:Hide()
            end
        end
    else
        self.Healthstone:Hide()
    end
end


local function updatePartyMemebersOnOptionsChanged(event, option, oldValue, newValue)
    if ( option == "ShowPartyHealthstones" ) then
        for i = 1,MAX_PARTY_MEMBERS do
            showHideHealthstone(_G["PartyMemberFrame"..i])
        end
    end
end

---------------------------------------------
-- INITIALIZE
---------------------------------------------
HSTBlizzUI.RegisterCallback(MODULE_NAME, "initialize", function()
    --@debug@
    HSTBlizzUI:debug("initalize module", MODULE_NAME)
    --@end-debug@

    -- Create healthstone texture for partyframe
    for i = 1,MAX_PARTY_MEMBERS do
        createHealthstoneTexture(_G["PartyMemberFrame"..i])
    end

    -- Update healthstone icons when PartyMemberFrame updates
    hooksecurefunc("PartyMemberFrame_UpdateMember", showHideHealthstone)

    -- Receive healthstone updates
    PLUGIN.RegisterCallback(MODULE_NAME, "updateUnitHealthstone", updatePartyMemberHealthstone)

    -- Receive option changed updates
    HSTBlizzUI.RegisterCallback(MODULE_NAME, "optionsChanged", updatePartyMemebersOnOptionsChanged)
end)