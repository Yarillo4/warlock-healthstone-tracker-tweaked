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
local playersThatNeedHealthstones = {} -- list of group members that need healthstones
local useSecureFrames = true -- determines when we can use secure frames or not


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

local function getUnitId(unitname)
    local raidId = UnitInRaid(unitname)
    if ( raidId ) then
        return "raid" .. raidId
    elseif ( UnitIsUnit("player", unitname) ) then
        return "player"
    else
        for i = 1, MAX_PARTY_MEMBERS do
            local unit = "party"..i
            if ( UnitIsUnit(unit, unitname) ) then
                return unit
            end
        end
    end
end

local function formatClass(unitname)
    local class = select(2,UnitClass(unitname))
    if ( class ) then
        return GetClassColorObj(class):WrapTextInColorCode(unitname)
    else
        return unitname
    end
end

local function shouldInclude(unitName)
    -- Always include if raid members is less than the filter apply size
    if ( GetNumGroupMembers() < C:get("ListView/FilterGroupSize") ) then
        return true
    end

    -- Is class enabled?
    local className = select(2, UnitClass(unitName))
    if ( className and C:is("ListView/Filters/" .. className) ) then
        return true
    end


    local raidId = UnitInRaid(unitName)
    if ( raidId ) then
        -- is maintank enabled?
        local raidRole, _, roleName = select(10, GetRaidRosterInfo(raidId))
        if ( raidRole == "MAINTANK" and C:is("ListView/Filters/TANK") ) then
            return true
        end

        -- is role enabled?
        if ( roleName and roleName ~= "NONE" and C:is("ListView/Filters/" .. roleName) ) then
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
        HST:trace(MODULE_NAME, "HIDE", "isEmpty", isEmpty, "inCombat", inCombat, "inParty", inParty)
        WarlockHealthstoneTrackerListView:Hide()
    else
        HST:trace(MODULE_NAME, "SHOW", "isEmpty", isEmpty, "inCombat", inCombat, "inParty", inParty)
        WarlockHealthstoneTrackerListView:Show()
    end
end

local function handleHealthstoneUpdate(event, unitName, hasHealthstone)
    if ( C:is("ListView/Enabled") ) then
        if hasHealthstone then  -- remove from list
            for i = #playersThatNeedHealthstones, 1, -1 do -- proceed in reverse so we are not affected by any removals
                if ( playersThatNeedHealthstones[i] == unitName ) then
                    tremove(playersThatNeedHealthstones, i)
                end
            end

        elseif ( UnitInParty(unitName) or UnitInRaid(unitName) or unitName == UnitName("player") ) then  -- add to list
            --@alpha@
            HST:debug(unitName, "does not have healthstone. Adding to list view")
            --@end-alpha@
            if ( shouldInclude(unitName) ) then
                if ( not contains(playersThatNeedHealthstones, unitName) ) then
                    tinsert(playersThatNeedHealthstones, 1, unitName)
                end
            end
        end

        WarlockHealthstoneTrackerListView.ScrollFrame:Update()
    end
end

local function handleGroupUpdate(event)
    HST:trace(MODULE_NAME, "handleGroupUpdate", event)

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
        if ( shouldInclude(unitname) ) then
            if ( not PLUGIN:PlayerHasHealthstone(unitname) ) then
                tinsert(playersThatNeedHealthstones, 1, unitname)
            end
        end
    end

    -- Update frame
    WarlockHealthstoneTrackerListView.ScrollFrame:Update()
end

local function handleStartEndCombat(event)
    local self = WarlockHealthstoneTrackerListView.ScrollFrame
    local removeButtons = self:GetButtons()
    if ( event == "PLAYER_REGEN_DISABLED" ) then
        -- In combat :: start using insecure frames, hide all secure ones
        useSecureFrames = false

    elseif ( event == "PLAYER_REGEN_ENABLED" ) then
        -- Out of combat :: start using secure frames, hide all insecure ones
        useSecureFrames = true
    end
    local addButtons = self:GetButtons()

    --[[
        There are two major concerns.

            1) Hiding & showing SecureButtons while in combat.
               Buttons must be able to automatically hide and show while in combat in response to combat events.
               This isn't possible with SecureButtons, so as a workaround we use insecure buttons upon entering
               combat, and add them on leaving combat.

            2) Remove the temporary secure status from ListView
               Temporary secure status is set when the frame has secure children, or a secure frame is anchored to it.
               To remove ListView's temporary secure status we must,
                a) Remove the parent for all secure buttons; regardless of their visiblity
                b) Clear anchors for all SecureButton.

        To satisfy both of these conditions we swamp insecure and secure buttons upon enter/leave combat.
    ]]
    if ( removeButtons ~= addButtons ) then
        for i = 1, #removeButtons do
            removeButtons[i]:Hide()
            removeButtons[i]:SetParent(nil)
            removeButtons[i]:ClearAllPoints()
        end
        for i = 1, #addButtons do
            addButtons[i]:SetParent(self:GetParent())
            addButtons[i]:SetAnchors()
        end
    end

    self:Update()
end

local function handleOptionsChanged(option, newValue)
    if ( option == "ListView/Enabled") then
        handleGroupUpdate("OptionChanged")

    elseif ( option == "ListView/Locked" ) then
        WarlockHealthstoneTrackerListView.TitleBar:EnableMouse(not newValue)
        WarlockHealthstoneTrackerListView.ResizeButton:SetShown(not newValue)
        WarlockHealthstoneTrackerListView.ResizeButton:SetMovable(not newValue)
        WarlockHealthstoneTrackerListView:StopMovingOrSizing()

    elseif ( option == "ListView/HideWhenEmpty"
            or option == "ListView/HideWhenInCombat"
            or option == "ListView/HideWhenNotInGroup" ) then
        WarlockHealthstoneTrackerListView.ScrollFrame:Update()

    elseif ( option == "ListView/FilterGroupSize"
            or option == "ListView/Filters/TANK"
            or option == "ListView/Filters/HEALER"
            or option == "ListView/Filters/DAMAGER"
            or option == "ListView/Filters/DRUID"
            or option == "ListView/Filters/HUNTER"
            or option == "ListView/Filters/MAGE"
            or option == "ListView/Filters/PRIEST"
            or option == "ListView/Filters/ROGUE"
            or option == "ListView/Filters/SHAMAN"
            or option == "ListView/Filters/PALADIN"
            or option == "ListView/Filters/WARLOCK"
            or option == "ListView/Filters/WARRIOR" ) then
        handleGroupUpdate("OptionChanged")
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
-- MIXIN: BUTTON
---------------------------------------------
WarlockHealthstoneTrackerListViewButtonMixIn = {}
function WarlockHealthstoneTrackerListViewButtonMixIn:SetAnchors()
    local listView = self:GetParent()
    local scrollFrame = listView.ScrollFrame

    local buttons = self:IsProtected() and scrollFrame.secureButtons or scrollFrame.buttons
    self:SetPoint("RIGHT", listView)
    if self:GetID() == 1 then
        self:SetPoint("TOPLEFT", scrollFrame)
    else
        self:SetPoint("TOPLEFT", buttons[self:GetID() - 1], "BOTTOMLEFT", 0, -BUTTON_MARGIN)
    end
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
    self.secureButtons = {}
end

function WarlockHealthstoneTrackerListViewScrollFrameMixIn:OnVerticalScroll(offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, BUTTON_HEIGHT+BUTTON_MARGIN, self.Update);
end


function WarlockHealthstoneTrackerListViewScrollFrameMixIn:GetButtons()
    local buttons = ( useSecureFrames ) and self.secureButtons or self.buttons
    local template = ( useSecureFrames ) and "WarlockHealthstoneTrackerListViewSecureButtonTemplate" or "WarlockHealthstoneTrackerListViewButtonTemplate"
    return buttons, template
end

function WarlockHealthstoneTrackerListViewScrollFrameMixIn:GetButton(i)
    local buttons, template = self:GetButtons()
    local parent = self:GetParent()

    if ( not buttons[i] ) then
        local button = CreateFrame("Button", nil, parent, template)
        button:SetID(i)
        button:SetHeight(BUTTON_HEIGHT)
        button:SetAnchors()
        button:Hide()
        tinsert(buttons, button)
    end

    return buttons[i]
end

function WarlockHealthstoneTrackerListViewScrollFrameMixIn:OnSizeChanged()
    -- recalculate number of displayed buttons
    self.numDisplayedButtons = math.floor(self:GetHeight() / (BUTTON_HEIGHT+BUTTON_MARGIN))

    -- hide buttons that are no longer needed
    local buttons = self:GetButtons()
    if ( #buttons > self.numDisplayedButtons ) then
        for i = self.numDisplayedButtons, #buttons, 1 do
            buttons[i]:Hide()
        end
    end

    self:Update()
end

function WarlockHealthstoneTrackerListViewScrollFrameMixIn:Update()
    local parent = self:GetParent()

    showHideFrame()
    if ( parent:IsShown() ) then
        local numItems = #playersThatNeedHealthstones
        local numButtons = #self:GetButtons()
        FauxScrollFrame_Update(self, numItems, self.numDisplayedButtons, BUTTON_HEIGHT+BUTTON_MARGIN)

        local offset = FauxScrollFrame_GetOffset(self)
        for i = 1, self.numDisplayedButtons do
            local index = i + offset
            if ( index <= numItems ) then
                local button = self:GetButton(i)
                local name = playersThatNeedHealthstones[index]
                button.Name:SetText(formatClass(name))
                if ( useSecureFrames ) then
                    button:SetAttribute("unit", getUnitId(name))
                end
                button:Show()
            elseif ( index <= numButtons ) then
                local button = self:GetButton(i)
                button:Hide()
            end
        end
    end
end


---------------------------------------------
-- INITIALIZE
---------------------------------------------
HST.RegisterCallback(MODULE_NAME, "initialize", function()
    -- Receive healthstone updates
    PLUGIN.RegisterCallback(HST.ADDON_NAME .. "." .. MODULE_NAME, "updateUnitHealthstone", handleHealthstoneUpdate)

    -- Receive group updates
    HST.RegisterEvent(MODULE_NAME, "PLAYER_ENTERING_WORLD", handleGroupUpdate)
    HST.RegisterEvent(MODULE_NAME, "GROUP_ROSTER_UPDATE", handleGroupUpdate)

    -- Receive combat updates
    HST.RegisterEvent(MODULE_NAME, "PLAYER_REGEN_DISABLED", handleStartEndCombat)
    HST.RegisterEvent(MODULE_NAME, "PLAYER_REGEN_ENABLED", handleStartEndCombat)

    -- Receive options updates
    C.RegisterListener(MODULE_NAME, "ListView/Enabled", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Locked", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/HideWhenEmpty", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/HideWhenInCombat", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/HideWhenNotInGroup", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/FilterGroupSize", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/TANK", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/HEALER", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/DAMAGER", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/DRUID", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/HUNTER", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/MAGE", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/PRIEST", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/ROGUE", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/SHAMAN", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/PALADIN", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/WARLOCK", handleOptionsChanged)
    C.RegisterListener(MODULE_NAME, "ListView/Filters/WARRIOR", handleOptionsChanged)
    handleOptionsChanged("ListView/Locked", C:is("ListView/Locked")) -- #3: List View not locked upon /reload (temporary fix)
end)
