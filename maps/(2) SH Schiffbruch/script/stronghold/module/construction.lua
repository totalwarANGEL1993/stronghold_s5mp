---
--- Construction Script
--- 
--- This script implements construction and upgrade of buildings and their
--- respective limitations.
---

Stronghold = Stronghold or {};

Stronghold.Construction = {
    Data = {},
    Config = {
        TowerDistance = 1500,
        TypesToCheckForConstruction = {
            [Technologies.B_Beautification01] = {Entities.PB_Beautification01},
            [Technologies.B_Beautification02] = {Entities.PB_Beautification02},
            [Technologies.B_Beautification03] = {Entities.PB_Beautification03},
            [Technologies.B_Beautification04] = {Entities.PB_Beautification04},
            [Technologies.B_Beautification05] = {Entities.PB_Beautification05},
            [Technologies.B_Beautification06] = {Entities.PB_Beautification06},
            [Technologies.B_Beautification07] = {Entities.PB_Beautification07},
            [Technologies.B_Beautification08] = {Entities.PB_Beautification08},
            [Technologies.B_Beautification09] = {Entities.PB_Beautification09},
            [Technologies.B_Beautification10] = {Entities.PB_Beautification10},
            [Technologies.B_Beautification11] = {Entities.PB_Beautification11},
            [Technologies.B_Beautification12] = {Entities.PB_Beautification12},

            [Technologies.B_Barracks]         = {Entities.PB_Barracks1, Entities.PB_Barracks2,},
            [Technologies.B_Archery]          = {Entities.PB_Archery1, Entities.PB_Archery2,},
            [Technologies.B_Stables]          = {Entities.PB_Stable1, Entities.PB_Stable2,},
            [Technologies.B_Monastery]        = {Entities.PB_Monastery1, Entities.PB_Monastery2, Entities.PB_Monastery3},
            [Technologies.B_PowerPlant]       = {Entities.PB_PowerPlant1},
        },
        TypesToCheckForUpgrade = {
            [Technologies.UP1_Barracks]  = {Entities.PB_Barracks2,},
            [Technologies.UP1_Archery]   = {Entities.PB_Archery2,},
            [Technologies.UP1_Stables]   = {Entities.PB_Stable2,},
            [Technologies.UP1_Monastery] = {Entities.PB_Monastery2, Entities.PB_Monastery3},
            [Technologies.UP2_Monastery] = {Entities.PB_Monastery1, Entities.PB_Monastery3},
            [Technologies.UP1_Market]    = {Entities.PB_Market2},
        },
    }
}

function Stronghold.Construction:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {};
    end
    -- Don't let EMS fuck with my script...
    if EMS then
        function EMS.RD.Rules.Markets:Evaluate(self) end
    end

    self:InitBuildingLimits();
    self:OverridePlaceBuildingAction();
end

function Stronghold.Construction:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --
-- Construction

function Stronghold.Construction:PrintTooltipConstructionButton(_UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut)
    local Language = GetLanguage();
    local PlayerID = Stronghold:GetLocalPlayerID();
    if not Stronghold:IsPlayer(PlayerID) then
        return false;
    end
    local IsForbidden = false;

    -- Get default text
    local ForbiddenText = GetSeparatedTooltipText("MenuGeneric/BuildingNotAvailable")
    local NormalText = GetSeparatedTooltipText(_KeyNormal);
    local DisabledText = GetSeparatedTooltipText(_KeyDisabled);
    local DefaultText = NormalText;
    if XGUIEng.IsButtonDisabled(XGUIEng.GetCurrentWidgetID()) == 1 then
        DefaultText = DisabledText;
        if _Technology and Logic.GetTechnologyState(PlayerID, _Technology) == 0 then
            DefaultText = ForbiddenText;
            IsForbidden = true;
        end
    end

    local CostString = "";
    local ShortCutToolTip = "";
    local Type = Logic.GetBuildingTypeByUpgradeCategory(_UpgradeCategory, PlayerID);
    if not IsForbidden then
        Logic.FillBuildingCostsTable(Type, InterfaceGlobals.CostTable);
        CostString = InterfaceTool_CreateCostString(InterfaceGlobals.CostTable);
        if _ShortCut then
            ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name")..
                ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]"
        end
    end

    local Text = DefaultText[1] .. " @cr " .. DefaultText[2];
    if not IsForbidden then
        -- Effect text
        local EffectText = "";
        local Effects = Stronghold.Economy:GetStaticTypeConfiguration(Type);
        if Effects then
            if Effects.Reputation > 0 then
                EffectText = EffectText.. "+" ..Effects.Reputation.. " " ..Stronghold.Config.UI.Reputation[Language] .. " ";
            end
            if Effects.Honor > 0 then
                EffectText = EffectText.. "+" ..Effects.Honor.. " " ..Stronghold.Config.UI.Honor[Language];
            end
            if EffectText ~= "" then
                EffectText = " @cr @color:244,184,0 bewirkt: @color:255,255,255 " ..EffectText;
            end
        end

        if Logic.GetUpgradeCategoryByBuildingType(Type) == UpgradeCategories.Tavern then
            EffectText = " @cr @color:244,184,0 bewirkt: @color:255,255,255 "..
                            " Beliebtheit für jeden Gast";
        end

        local BuildingMax = EntityTracker.GetLimitOfType(Type);
        if BuildingMax > -1 then
            local BuildingCount = EntityTracker.GetUsageOfType(PlayerID, Type);
            Text = DefaultText[1].. " (" ..BuildingCount.. "/" ..BuildingMax.. ") @cr " .. DefaultText[2];
        else
            Text = DefaultText[1] .. " @cr " .. DefaultText[2];
        end

        for i= 3, table.getn(DefaultText) do
            Text = Text .. " @cr " .. DefaultText[i];
        end
        Text = Text .. EffectText;
    end

    -- Set text
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
    return true;
end

function Stronghold.Construction:UpdateSerfUpgradeButtons(_Button, _Technology)
    local PlayerID = Stronghold:GetLocalPlayerID();
    if Stronghold:IsPlayer(PlayerID) then
        if not Stronghold.Construction:UpdateSerfConstructionButtons(PlayerID, _Button, _Technology) then
            local LimitReached = false;
            local CheckList = Stronghold.Construction.Config.TypesToCheckForUpgrade[_Technology] or {};

            local Type = Logic.GetEntityType(GUI.GetSelectedEntity()) +1;
            local Limit = EntityTracker.GetLimitOfType(Type);
            local Usage = 0;
            if Limit > -1 then
                for i= 1, table.getn(CheckList) do
                    Usage = Usage + EntityTracker.GetUsageOfType(PlayerID, CheckList[i]);
                end
                LimitReached = Limit <= Usage;
            end

            if LimitReached then
                XGUIEng.DisableButton(_Button, 1);
                return true;
            end
        end
    end
    return false;
end

-- Update buttons in serf menu
-- for some reason most of the beautification buttons call the update of the
-- upgrade button instead of the construction button. A classical case of the
-- infamos "BB-Logic".... To avoid boilerplate we outsource the changes.
function Stronghold.Construction:UpdateSerfConstructionButtons(_PlayerID, _Button, _Technology)
    local LimitReached = false;
    local CheckList = Stronghold.Construction.Config.TypesToCheckForConstruction[_Technology];

    local Usage = 0;
    local Limit = -1;
    if CheckList then
        Limit = EntityTracker.GetLimitOfType(CheckList[1]);
    end
    if Limit > -1 then
        for i= 1, table.getn(CheckList) do
            Usage = Usage + EntityTracker.GetUsageOfType(_PlayerID, CheckList[i]);
        end
        LimitReached = Limit <= Usage;
    end

    if LimitReached then
        XGUIEng.DisableButton(_Button, 1);
        return true;
    end
    return false;
end

-- -------------------------------------------------------------------------- --
-- Upgrade Button

function Stronghold.Construction:PrintBuildingUpgradeButtonTooltip(_Type, _KeyDisabled, _KeyNormal, _Technology)
    local Language = GetLanguage();
    local PlayerID = GUI.GetPlayerID();
    if not Stronghold:IsPlayer(PlayerID) then
        return false;
    end
    local IsForbidden = false;

    -- Get default text
    local ForbiddenText = GetSeparatedTooltipText("MenuGeneric/BuildingNotAvailable");
    local NormalText = GetSeparatedTooltipText(_KeyNormal);
    local DisabledText = GetSeparatedTooltipText(_KeyDisabled);
    local DefaultText = NormalText;
    if XGUIEng.IsButtonDisabled(XGUIEng.GetCurrentWidgetID()) == 1 then
        DefaultText = DisabledText;
        if _Technology and Logic.GetTechnologyState(PlayerID, _Technology) == 0 then
            DefaultText = ForbiddenText;
            IsForbidden = true;
        end
    end

    local CostString = "";
    local ShortCutToolTip = "";
    if not IsForbidden then
        Logic.FillBuildingUpgradeCostsTable(_Type, InterfaceGlobals.CostTable);
        CostString = InterfaceTool_CreateCostString(InterfaceGlobals.CostTable);
        ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name")..
            ": [" .. XGUIEng.GetStringTableText("KeyBindings/UpgradeBuilding") .. "]"
    end

    local Text = DefaultText[1] .. " @cr " .. DefaultText[2];
    if not IsForbidden then
        local EffectText = "";
        local Effects = Stronghold.Economy:GetStaticTypeConfiguration(_Type +1);
        if Effects then
            if Effects.Reputation > 0 then
                EffectText = EffectText.. "+" ..Effects.Reputation.. " " ..Stronghold.Config.UI.Reputation[Language] .. " ";
            end
            if Effects.Honor > 0 then
                EffectText = EffectText.. "+" ..Effects.Honor.. " " ..Stronghold.Config.UI.Honor[Language];
            end
            if EffectText ~= "" then
                EffectText = " @cr @color:244,184,0 bewirkt: @color:255,255,255 " ..EffectText;
            end
        end

        if Logic.GetUpgradeCategoryByBuildingType(_Type) == UpgradeCategories.Tavern then
            EffectText = " @cr @color:244,184,0 bewirkt: @color:255,255,255 "..
                         " Beliebtheit für jeden Gast";
        end
        if Logic.GetUpgradeCategoryByBuildingType(_Type) == UpgradeCategories.Farm then
            EffectText = " @cr @color:244,184,0 bewirkt: @color:255,255,255 "..
                         " Ehre und Beliebtheit für jeden Gast";
        end
        if Logic.GetUpgradeCategoryByBuildingType(_Type) == UpgradeCategories.Residence then
            EffectText = " @cr @color:244,184,0 bewirkt: @color:255,255,255 "..
                         " Beliebtheit für jeden Gast";
        end

        -- Building limit
        local BuildingMax = EntityTracker.GetLimitOfType(_Type +1);
        if BuildingMax > -1 then
            local BuildingCount = EntityTracker.GetUsageOfType(PlayerID, _Type +1);
            Text = DefaultText[1].. " (" ..BuildingCount.. "/" ..BuildingMax.. ") @cr " .. DefaultText[2];
        else
            Text = DefaultText[1] .. " @cr " .. DefaultText[2];
        end

        for i= 3, table.getn(DefaultText) do
            Text = Text .. " @cr " .. DefaultText[i];
        end
        Text = Text .. EffectText;
    end

    -- Set text
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
    return true;
end

-- -------------------------------------------------------------------------- --
-- Soft Tower Limit

-- Check tower placement (Community Server)
-- Prevents towers from being placed if another tower of the same player is
-- to close. Type of tower does not matter.
function Stronghold.Construction:StartCheckTowerDistanceCallback()
    if not GameCallback_PlaceBuildingAdditionalCheck then
        return false;
    end
    self.Orig_GameCallback_PlaceBuildingAdditionalCheck = GameCallback_PlaceBuildingAdditionalCheck;
    GameCallback_PlaceBuildingAdditionalCheck = function(_ucat, _x, _y, _rotation, _isBuildOn)
        local PlayerID = GUI.GetPlayerID();
        local Allowed = Stronghold.Construction.Orig_GameCallback_PlaceBuildingAdditionalCheck(_ucat, _x, _y, _rotation, _isBuildOn);
        if Stronghold:IsPlayer(PlayerID) then
            if Allowed and _ucat == EntityCategories.Tower then
                local AreaSize = self.Config.TowerDistance;
                if self:AreTowersOfPlayerInArea(PlayerID, _x, _y, AreaSize) then
                    Allowed = false;
                end
            end
        end
        return Allowed;
    end
    return true;
end

-- Check tower placement (Vanilla)
-- Prevents towers from being placed if another tower of the same player is
-- to close. Type of tower does not matter.
-- Does overwrite place building and find view but only if the initalization
-- for the community server variant previously failed.
function Stronghold.Construction:OverridePlaceBuildingAction()
    if self:StartCheckTowerDistanceCallback() then
        return;
    end

    Overwrite.CreateOverwrite("GUIAction_PlaceBuilding", function(_UpgradeCategory)
        local PlayerID = Stronghold:GetLocalPlayerID();
        Overwrite.CallOriginal();
        Stronghold.Construction.Data[PlayerID].LastPlacedUpgradeCategory = _UpgradeCategory;
        return false;
    end);

    Overwrite.CreateOverwrite("GUIUpdate_FindView", function()
        Overwrite.CallOriginal();
        local PlayerID = Stronghold:GetLocalPlayerID();
        Stronghold.Construction:CancelBuildingPlacementForUpgradeCategory(
            PlayerID,
            Stronghold.Construction.Data[PlayerID].LastPlacedUpgradeCategory
        );
    end);
end

function Stronghold.Construction:CancelBuildingPlacementForUpgradeCategory(_PlayerID, _UpgradeCategory)
    local StateID = GUI.GetCurrentStateID();
    if StateID == gvGUI_StateID.PlaceBuilding then
        if _UpgradeCategory == UpgradeCategories.Tower then
            AreaSize = self.Config.TowerDistance;
            local x, y = GUI.Debug_GetMapPositionUnderMouse();
            if self:AreTowersOfPlayerInArea(_PlayerID, x, y, AreaSize) then
                Message("Ihr könnt Türme nicht so na aneinander bauen!");
                Sound.PlayQueuedFeedbackSound(Sounds.VoicesSerf_SERF_No_rnd_01, 127);
                self.Data[_PlayerID].LastPlacedUpgradeCategory = nil;
                GUI.CancelState();
            end
        end
    end
end

function Stronghold.Construction:AreTowersOfPlayerInArea(_PlayerID, _X, _Y, _AreaSize)
    local DarkTower1 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower1, _X, _Y, _AreaSize, 1)};
    local DarkTower2 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower2, _X, _Y, _AreaSize, 1)};
    local DarkTower3 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower3, _X, _Y, _AreaSize, 1)};
    local Tower1 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower1, _X, _Y, _AreaSize, 1)};
    local Tower2 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower2, _X, _Y, _AreaSize, 1)};
    local Tower3 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower3, _X, _Y, _AreaSize, 1)};
    return Tower1[1] + Tower2[1] + Tower3[1] + DarkTower1[1] + DarkTower2[1] + DarkTower3[1] > 0;
end

-- -------------------------------------------------------------------------- --
-- Building Limit

-- Setup the building limit for some building types.
-- (The tracker only handles the tracking and not the UI!)
function Stronghold.Construction:InitBuildingLimits()
    -- Beautifications
    EntityTracker.SetLimitOfType(Entities.PB_Beautification04, 6);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification06, 6);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification09, 6);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification01, 4);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification02, 4);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification12, 4);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification05, 2);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification07, 2);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification08, 2);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification03, 1);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification10, 1);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification11, 1);

    -- Civil buildings
    EntityTracker.SetLimitOfType(Entities.PB_Monastery1, 1);
    EntityTracker.SetLimitOfType(Entities.PB_Monastery2, 1);
    EntityTracker.SetLimitOfType(Entities.PB_Monastery3, 1);
    EntityTracker.SetLimitOfType(Entities.PB_Market2, 3);
    EntityTracker.SetLimitOfType(Entities.PB_PowerPlant1, 1);

    -- Military buildings
    EntityTracker.SetLimitOfType(Entities.PB_Barracks1, 6);
    EntityTracker.SetLimitOfType(Entities.PB_Barracks2, 3);
    EntityTracker.SetLimitOfType(Entities.PB_Stable1, 6);
    EntityTracker.SetLimitOfType(Entities.PB_Stable2, 3);
    EntityTracker.SetLimitOfType(Entities.PB_Archery1, 6);
    EntityTracker.SetLimitOfType(Entities.PB_Archery2, 3);
    EntityTracker.SetLimitOfType(Entities.PB_Foundry1, 12);
    EntityTracker.SetLimitOfType(Entities.PB_Foundry2, 12);
end

