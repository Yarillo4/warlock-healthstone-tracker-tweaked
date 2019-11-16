local HST, C, L = unpack(select(2, ...))
local MODULE_NAME = "ListView"

local PLUGIN = LibStub("WarlockHealthstoneTracker-1.0", 1)

---------------------------------------------
-- LOCALIZATION
---------------------------------------------
L_WARLOCK_HEALTHSTONE_TRACKER_NEED_HEALTHSTONES = L["Healthstone Tracker"]


---------------------------------------------
-- CONSTANTS
---------------------------------------------
local BUTTON_HEIGHT = 16
local BUTTON_MARGIN = 0


---------------------------------------------
-- VARIABLES
---------------------------------------------
local playersThatNeedHealthstones = {}


---------------------------------------------
-- UTILITIES
---------------------------------------------
local function contains(t, value)
    for i,v in ipairs(t) do
        if ( v == value ) then
            return true
        end
    end
    return false
end


---------------------------------------------
-- LIST VIEW
---------------------------------------------
local function showHideFrame()
    if ( not C:is("ListView/Enabled") ) then
        WarlockHealthstoneTrackerListView:Hide()
        return
    end

    -- hide when noone needs a healthstone
    local isEmpty = false -- treat isEmpty as false when HideWhenEmpty == false
    if ( C:is("ListView/HideWhenEmpty") ) then
        isEmpty = ( #playersThatNeedHealthstones == 0 )
    end

    -- hide when in combat
    local inCombat = false -- treat inCombat as false when HideWhenInComat == false
    if ( C:is("ListView/HideWhenInCombat") ) then
        inCombat = UnitAffectingCombat("player")
    end

    -- hiding when not in group
    local inParty = true -- treat inParty as true when HideNotInGroup == false
    if ( C:is("ListView/HideWhenNotInGroup") ) then
        inParty = UnitInParty("player")
    end

    if ( isEmpty or inCombat or not inParty ) then
        HST:debug("HIDE", "isEmpty", isEmpty, "inCombat", inCombat, "inParty", inParty)
        WarlockHealthstoneTrackerListView:Hide()
    else
        HST:debug("SHOW", "isEmpty", isEmpty, "inCombat", inCombat, "inParty", inParty)
        WarlockHealthstoneTrackerListView:Show()
    end
end

local function updatePartyRaidHealthstone(event, unitName, hasHealthstone)
    --@debug@
    HST:debug(unitName, "listView", C:is("ListView/Enabled"), "inParty", UnitInParty(unitName), "hasHealthstone", hasHealthstone)
    --@end-debug@

    if ( C:is("ListView/Enabled") ) then
        if hasHealthstone then  -- remove from list
            --@alpha@
            HST:debug(unitName, "has healthstone. Removing from list view")
            --@end-alpha@
            -- #7: List view may show player names more than once
            for i = #playersThatNeedHealthstones, 1, -1 do -- proceed in reverse so we are not affected by any removals
                if ( playersThatNeedHealthstones[i] == unitName ) then
                    tremove(playersThatNeedHealthstones, i)
                end
            end

        elseif ( UnitInParty(unitName) or UnitInRaid(unitName) or unitName == UnitName("player") ) then  -- add to list
            --@alpha@
            HST:debug(unitName, "does not have healthstone. Adding to list view")
            --@end-alpha@
            -- #7: List view may show player names more than once
            if ( not contains(playersThatNeedHealthstones, unitName) ) then
                tinsert(playersThatNeedHealthstones, 1, unitName)
            end
        end

        WarlockHealthstoneTrackerListView.ScrollFrame:Update()
    end
end

local function handleGroupUpdate(event)
    -- Recreate list entirely
    playersThatNeedHealthstones = {}

    -- Load all party/raid members
    local players = { }
    local name
    if ( IsInRaid() ) then
        for i = 1, MAX_RAID_MEMBERS do
            local unit = "raid"..i
            if ( UnitExists(unit) ) then
                local name = UnitName(unit)
                tinsert(players, name)
            end
        end
    elseif ( IsInGroup() ) then
        name = UnitName("player")
        tinsert(players, name)
        for i = 1, MAX_PARTY_MEMBERS do
            local unit = "party"..i
            if ( UnitExists(unit) ) then
                local name = UnitName(unit)
                tinsert(players, name)
            end
        end
    else
        -- not in a group
        local name = UnitName("player")
        tinsert(players, name)
    end

    -- #4: List view showed party member "Unknown"
    if ( event ~= "RETRY_UNKNOWN" and contains(players, UNKNOWNOBJECT) ) then -- Do not retry, if already retrying
        -- Set timer to reinvoke this method in a few seconds
        C_Timer.After(1, function() handleGroupUpdate("RETRY_UNKNOWN") end)
    end

    -- Add players without healthstones to list
    for i,unitname in ipairs(players) do
        if ( not PLUGIN:PlayerHasHealthstone(unitname) ) then
            tinsert(playersThatNeedHealthstones, 1, unitname)
        end
    end

    -- Update frame
    WarlockHealthstoneTrackerListView.ScrollFrame:Update()
end

local function handleOptionsChanged(option, newValue)
    if ( option == "ListView/Enabled") then
        WarlockHealthstoneTrackerListView.ScrollFrame:Update()

    elseif ( option == "ListView/Locked" ) then
        WarlockHealthstoneTrackerListView.TitleBar:EnableMouse(not newValue)
        WarlockHealthstoneTrackerListView.ResizeButton:SetShown(not newValue)
        WarlockHealthstoneTrackerListView.ResizeButton:SetMovable(not newValue)
        WarlockHealthstoneTrackerListView:StopMovingOrSizing()

    elseif ( option == "ListView/HideWhenEmpty"
            or option == "ListView/HideWhenInCombat"
            or option == "ListView/HideWhenNotInGroup" ) then
        WarlockHealthstoneTrackerListView.ScrollFrame:Update()
    end
end


---------------------------------------------
-- MIXIN: TITLE BAR
---------------------------------------------
WarlockHealthstoneTrackerListViewTitleBarMixIn = {}
function WarlockHealthstoneTrackerListViewTitleBarMixIn:OnDragStart()
    self:GetParent():StartMoving()
end

function WarlockHealthstoneTrackerListViewTitleBarMixIn:OnDragStop()
    self:GetParent():StopMovingOrSizing()
end


---------------------------------------------
-- MIXIN: RESIZE BUTTON
---------------------------------------------
WarlockHealthstoneTrackerListViewResizeButtonMixIn = {}
function WarlockHealthstoneTrackerListViewResizeButtonMixIn:OnMouseDown()
    self:SetButtonState("PUSHED", true);
    self:GetHighlightTexture():Hide();
    self:GetParent():StartSizing("BOTTOMRIGHT");
end

function WarlockHealthstoneTrackerListViewResizeButtonMixIn:OnMouseUp()
    self:SetButtonState("NORMAL", false);
    self:GetHighlightTexture():Show();
    self:GetParent():StopMovingOrSizing();
end


---------------------------------------------
-- MIXIN: SCROLL FRAME
---------------------------------------------
WarlockHealthstoneTrackerListViewScrollFrameMixIn = {}
function WarlockHealthstoneTrackerListViewScrollFrameMixIn:OnLoad()
    self.buttons = {}
    self.numDisplayedButtons = 5
end

function WarlockHealthstoneTrackerListViewScrollFrameMixIn:OnVerticalScroll(offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, BUTTON_HEIGHT+BUTTON_MARGIN, self.Update);
end

function WarlockHealthstoneTrackerListViewScrollFrameMixIn:CreateButtons()
    local parent = self:GetParent()

    for i = 1, self.numDisplayedButtons do
        if ( not self.buttons[i] ) then
            local button = CreateFrame("Button", nil, parent, "WarlockHealthstoneTrackerListViewButtonTemplate")
            button:SetHeight(BUTTON_HEIGHT)
            if i == 1 then
                button:SetPoint("TOPLEFT", self)
            else
                button:SetPoint("TOPLEFT", self.buttons[i - 1], "BOTTOMLEFT", 0, -BUTTON_MARGIN)
            end
            button:Hide()
            tinsert(self.buttons, button)
        end
    end
end

function WarlockHealthstoneTrackerListViewScrollFrameMixIn:OnSizeChanged()
    -- recalculate number of displayed buttons
    self.numDisplayedButtons = math.floor(self:GetHeight() / (BUTTON_HEIGHT+BUTTON_MARGIN))

    self:CreateButtons()

    -- hide buttons that are no longer needed
    if ( #self.buttons > self.numDisplayedButtons ) then
        for i = self.numDisplayedButtons, #self.buttons, 1 do
            self.buttons[i]:Hide()
        end
    end

    self:Update()
end

function WarlockHealthstoneTrackerListViewScrollFrameMixIn:Update()
    local parent = self:GetParent()

    showHideFrame()
    if ( parent:IsShown() ) then
        local numItems = #playersThatNeedHealthstones
        FauxScrollFrame_Update(self, numItems, self.numDisplayedButtons, BUTTON_HEIGHT+BUTTON_MARGIN)

        local offset = FauxScrollFrame_GetOffset(self)
        for i = 1, self.numDisplayedButtons do
            local index = i + offset
            local button = self.buttons[i]
            if ( index > numItems ) then
                button:Hide()
            else
                button.Name:SetText(playersThatNeedHealthstones[index])
                button:Show()
            end
        end
    end
end


---------------------------------------------
-- INITIALIZE
---------------------------------------------
HST.RegisterCallback(MODULE_NAME, "initialize", function()
    --@alpha@
    HST:debug("initalize module", MODULE_NAME)
    --@end-alpha@

    -- Receive healthstone updates
    PLUGIN.RegisterCallback(MODULE_NAME, "updateUnitHealthstone", updatePartyRaidHealthstone)

    -- Receive group updates
    HST.RegisterEvent(MODULE_NAME, "PLAYER_ENTERING_WORLD", handleGroupUpdate)
    HST.RegisterEvent(MODULE_NAME, "GROUP_ROSTER_UPDATE", handleGroupUpdate)

    -- Receive combat updates
    HST.RegisterEvent(MODULE_NAME, "PLAYER_REGEN_DISABLED", showHideFrame)
    HST.RegisterEvent(MODULE_NAME, "PLAYER_REGEN_ENABLED", showHideFrame)

    -- Receive options updates
    C.RegisterListener(MODULE_NAME, "ListView/Enabled", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Locked", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/HideWhenEmpty", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/HideWhenInCombat", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/HideWhenNotInGroup", handleOptionsChanged)
    handleOptionsChanged("ListView/Locked", C:is("ListView/Locked")) -- #3: List View not locked upon /reload (temporary fix)

    -- Create initial scroll frame buttons
    WarlockHealthstoneTrackerListView.ScrollFrame:CreateButtons()
end)
