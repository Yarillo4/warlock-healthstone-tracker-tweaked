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
local function updateListViewFrame()
    local frame = WarlockHealthstoneTrackerListView
    frame.namePool:ReleaseAll()

    if ( frame:IsShown() ) then
        local previous = WarlockHealthstoneTrackerListView.TitleBar
        for _,name in pairs(playersThatNeedHealthstones) do
            local fontstring = frame.namePool:Acquire()
            fontstring:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0)
            fontstring:SetPoint("RIGHT", previous)
            fontstring:SetJustifyH("LEFT");
            fontstring:SetText(name)
            fontstring:Show()
            previous = fontstring
        end

        -- resize frame to encompass all strings
        -- if currentHeight < desiredHeight :: resize
        -- else :: frame:SetPoint("BOTTOM", previous)
    end
end

local function updatePartyRaidHealthstone(event, unitName, hasHealthstone)
    --@debug@
    HST:debug(unitName, "ShowPartyHealthstones", C:is("ShowPartyHealthstones"), "inParty", UnitInParty(unitName), "hasHealthstone", hasHealthstone)
    --@end-debug@

    --if ( C:is("ListViewEnabled") ) then
        if hasHealthstone then  -- remove from list
            --@alpha@
            HST:debug(unitName, "has healthstone. Removing from list view")
            --@end-alpha@
            for i = 1, #playersThatNeedHealthstones do
                if ( playersThatNeedHealthstones[i] == unitName ) then
                    tremove(playersThatNeedHealthstones, i)
                    break
                end
            end

        elseif ( UnitInParty(unitName) or UnitInRaid(unitName) or unitName == UnitName("player") ) then  -- add to list
            --@alpha@
            HST:debug(unitName, "does not have healthstone. Adding to list view")
            --@end-alpha@
            tinsert(playersThatNeedHealthstones, unitName)
        end

        updateListViewFrame()
    --end
end


--[[local function handleOptionsChanged(event, option, newValue)
    if ( option == "ListView.Enabled") then
        WarlockHealthstoneTrackerListView:SetShown(newVlalue)
        upateListViewFrame()

    elseif ( option == "ListView.Locked" ) then
        WarlockHealthstoneTrackerListViewHeader:SetMovable(not newValue)
        WarlockHealthstoneTrackerListViewHeader:SetResizable(not newValue)
        WarlockHealthstoneTrackerListView.resize:SetShown(not newValue)
        WarlockHealthstoneTrackerListView.resize:SetMovable(not newValue)

    elseif ( option == "ListView.Anchor" ) then
        WarlockHealthstoneTrackerListViewHeader:ClearAllPoints()
        WarlockHealthstoneTrackerListViewHeader:SetPoint(newValue)

    elseif ( option == "ListViewFrame.Width" ) then
        if ( newValue < MINIMUM_FRAME_WIDTH ) then
            newValue = MINIMUM_FRAME_WIDTH
        end
        WarlockHealthstoneTrackerListViewHeader:SetWidth(newValue)

    elseif ( option == "ListViewFrame.DesiredHeight" ) then
        -- If currentHeight < desiredHeight :: resize

    end
end]]


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

    --WarlockHealthstoneTrackerListView:SetMovable(false)

    -- Receive healthstone updates
    PLUGIN.RegisterCallback(MODULE_NAME, "updateUnitHealthstone", updatePartyRaidHealthstone)

    -- Receive option changed updates
    --HST.RegisterCallback(MODULE_NAME, "optionsChanged", handleOptionsChanged)
end)
