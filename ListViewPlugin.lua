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
local MINIMUM_FRAME_WIDTH = 50
local MINIMUM_FRAME_HEIGHT = 50


---------------------------------------------
-- VARIABLES
---------------------------------------------
local playersThatNeedHealthstones = {}


---------------------------------------------
-- UTILITIES
---------------------------------------------
local function contains(t, value)
    for i,v in ipairs(players) do
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

local function updateListViewFrame()
    local frame = WarlockHealthstoneTrackerListView
    frame.namePool:ReleaseAll()

    showHideFrame()
    if ( frame:IsShown() ) then
        local isFirst = true
        local previous = WarlockHealthstoneTrackerListView.TitleBar
        for _,name in pairs(playersThatNeedHealthstones) do
            local fontstring = frame.namePool:Acquire()
            fontstring:ClearAllPoints()
            fontstring:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", isFirst and 5 or 0, -3)
            fontstring:SetPoint("RIGHT", previous)
            fontstring:SetJustifyH("LEFT");
            fontstring:SetText(name)
            fontstring:Show()
            previous = fontstring
            isFirst = false
        end
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
                tinsert(playersThatNeedHealthstones, unitName)
            end
        end

        updateListViewFrame()
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
        C_Timer.after(1, function() handleGroupUpdate("RETRY_UNKNOWN") end)
    end

    -- Add players without healthstones to list
    for i,unitname in ipairs(players) do
        if ( not PLUGIN:PlayerHasHealthstone(unitname) ) then
            tinsert(playersThatNeedHealthstones, unitname)
        end
    end

    -- Update frame
    updateListViewFrame()
end

local function handleOptionsChanged(option, newValue)
    if ( option == "ListView/Enabled") then
        updateListViewFrame()

    elseif ( option == "ListView/Locked" ) then
        WarlockHealthstoneTrackerListView.TitleBar:EnableMouse(not newValue)
        WarlockHealthstoneTrackerListView.ResizeButton:SetShown(not newValue)
        WarlockHealthstoneTrackerListView.ResizeButton:SetMovable(not newValue)
        WarlockHealthstoneTrackerListView:StopMovingOrSizing()

    elseif ( option == "ListView/HideWhenEmpty"
            or option == "ListView/HideWhenInCombat"
            or option == "ListView/HideWhenNotInGroup" ) then
        updateListViewFrame()
    end
end


---------------------------------------------
-- FRAME FUNCTIONS
---------------------------------------------
WarlockHealthstoneTrackerListViewTitleBarMixIn = {}
function WarlockHealthstoneTrackerListViewTitleBarMixIn:OnDragStart()
    self:GetParent():StartMoving()
end

function WarlockHealthstoneTrackerListViewTitleBarMixIn:OnDragStop()
    self:GetParent():StopMovingOrSizing()
end

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
end)
