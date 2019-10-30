local HSTBlizzUI, C, L = unpack(select(2, ...))
local MODULE_NAME = "BlizzPartyUI"

local PLUGIN = LibStub("WarlockHealthstoneTracker-1.0", 1)


---------------------------------------------
-- UTILITIES
---------------------------------------------
local function createHealthstoneTexture(frame)
    frame.HealthstoneIcon = frame:CreateTexture(nil, "Artwork", nil)
    frame.HealthstoneIcon:SetHeight(16)
    frame.HealthstoneIcon:SetWidth(16)
    frame.HealthstoneIcon:SetTexture("Interface\\ICONS\\INV_Stone_04")
    frame.HealthstoneIcon:SetPoint("TOPLEFT", _G[frame:GetName().."HealthBar"], "TOPRIGHT", 4, 0)
    frame.HealthstoneIcon:Hide()
end

local function updatePartyMemberHealthstone(unitName, hasHealthstone)
    if ( C:is("ShowPartyHealthstones") and UnitInParty(unitName) ) then
        for i = 1,MAX_PARTY_MEMBERS do
            local unit = "party"..i
            if ( UnitExists(unit) and unitName == UnitName(unit) ) then
                _G["PartyMemberFrame"..i].HealthstoneIcon:SetShown(hasHealthstone)
            end
        end
    end
end

local function showHideHealthstoneIcon(self)
    if ( not self ) then
        return
    end

    if ( C:is("ShowPartyHealthstones") ) then
        local unit = "party" .. self:GetID()
        if ( UnitExists(unit) ) then
            if ( PLUGIN:PlayerHasHealthstone(UnitName(unit)) ) then
                self.HealthstoneIcon:Show()
            else
                self.HealthstoneIcon:Hide()
            end
        end
    else
        self.HealthstoneIcon:Hide()
    end
end


local function updatePartyMemebersOnOptionsChanged(option, oldValue, newValue)
    if ( option == "ShowPartyHealthstones" ) then
        for i = 1,MAX_PARTY_MEMBERS do
            showHideHealthstoneIcon(_G["PartyMemberFrame"..i])
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
    hooksecurefunc("PartyMemberFrame_UpdateMember", showHideHealthstoneIcon)

    -- Receive healthstone updates
    PLUGIN.RegisterCallback(MODULE_NAME, "updateUnitHealthstone", updatePartyMemberHealthstone)

    -- Receive option changed updates
    HSTBlizzUI.RegisterCallback(MODULE_NAME, "optionsChanged", updatePartyMemebersOnOptionsChanged)
end)