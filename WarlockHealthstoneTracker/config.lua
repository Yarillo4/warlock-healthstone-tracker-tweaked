local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "config.lua"

local AceConfig = LibStub("AceConfig-3.0")
--AceConfig:RegisterOptionsTable(HST.ADDON_NAME, myOptions)


C.DEFAULT_DB = {
    ["Version"] = 1,
    ["Debug"] = false,
}

function C:is(option)
    return WarlockHealthstoneTrackerDB and WarlockHealthstoneTrackerDB[option]
end


function HST:debug(...)
    if ( C:is("Debug") ) then
        print("[" .. HST.ADDON_NAME .. "]", ...)
    end
end

--[[local function GetValue(self)
    if ( self.cvar ) then
        return GetCVar(self.cvar)
    elseif ( self.uvar ) then
        return _G[control.uvar]
    else
        return WarlockHealthstoneTrackerDB[self.var]
    end
end

local function SetValue(self, value)
    if not InCombatLockdown() then
        if ( self.cvar ) then
            SetCVar(self.cvar, value)
        elseif ( self.uvar ) then
            _G[control.uvar] = value
        else
            WarlockHealthstoneTrackerDB[self.var] = value
        end
    else
        print("Cannot set value while in combat")
    end
end

-- Checkboxes
local function newCheckbox(parent, var, label, description)
    local check = CreateFrame("CheckButton", "SlainsHealthstoneTracker_Check" .. var, parent, "InterfaceOptionsCheckButtonTemplate")

    check.GetValue = GetValue
    check.SetValue = SetValue
    check:SetScript('OnShow', function (self)
        local checked = self:GetValue()
        self:SetChecked(checked);
        self.value = checked
        self.newValue = checked
    end)
    check:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        self.newValue = checked
    end)
    check.label = _G[check:GetName() .. "Text"]
    check.label:SetText(label)
    check.tooltipText = label
    check.tooltipRequirement = description
    return check
end

local function newCheckboxCVAR(parent, var, label, description)
    local check = newCheckbox(parent, var, label, description)
    check.cvar = var
    return check
end

local function newCheckboxUVAR(parent, var, label, description)
    local check = newCheckbox(parent, var, label, description)
    check.uvar = var
    return check
end

local function newCheckboxVAR(parent, var, label, description)
    local check = newCheckbox(parent, var, label, description)
    check.var = var
    return check
end

-- Create an options panel and insert it into the interface menu
--local OptionsPanel = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
OptionsPanel:Hide()
OptionsPanel:SetAllPoints()
OptionsPanel.name = "Warlock Healthstone Tracker"

local Title = OptionsPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
Title:SetJustifyV('TOP')
Title:SetJustifyH('LEFT')
Title:SetPoint('TOPLEFT', 16, -16)
Title:SetText(OptionsPanel.name)

local SubText = OptionsPanel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
SubText:SetMaxLines(3)
SubText:SetNonSpaceWrap(true)
SubText:SetJustifyV('TOP')
SubText:SetJustifyH('LEFT')
SubText:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -8)
SubText:SetPoint('RIGHT', -32, 0)
SubText:SetText('Track healthstone usage by party members and alert when they can use another')

InterfaceOptions_AddCategory(OptionsPanel, HST.ADDON_NAME)

local DebugCheckBox = newCheckboxVAR(OptionsPanel, DEBUG, "Debug", "Enable debugging of plugin")
DebugCheckBox:SetPoint("TOPLEFT", SubText, "BOTTOMLEFT", 0, -8)

-- Reset button to reset to default options


OptionsPanel.okay = function (self, perControlCallback)
    function applyChanges(self)
        if ( self.newValue ~= self.value ) then
            addon:debug(self.var, "=", self.newValue)
            self:SetValue(self.newValue)
        end
    end

    addon:debug("applying changes")
    applyChanges(AutoQuestWatchCheckBox)
    applyChanges(QuickQuestCompleteCheckBox)
    applyChanges(DebugCheckBox)
end

OptionsPanel.cancel = function (self, perControlCallback)
    function revertChanges(self)
        addon:debug(self.var, "=", self.value)
        self:SetValue(self.value)
    end

    addon:debug("reverting changes")
    revertChanges(AutoQuestWatchCheckBox)
    revertChanges(QuickQuestCompleteCheckBox)
    revertChanges(DebugCheckBox)
end]]

---------------------------------------------
-- INITIALIZE
---------------------------------------------

HST.RegisterCallback(MODULE_NAME, "initialize", function()
end)