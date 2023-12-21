---
--- Construction Script
--- 
--- This script implements construction and upgrade of buildings and their
--- respective limitations.
---
--- - <number> GameCallback_SH_Calculate_MinimalTowerDistance(_PlayerID, _CurrentAmount)
---   Allows to overwrite the minimum distance between towers
---

Stronghold = Stronghold or {};

Stronghold.Construction = {
    Data = {},
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- Game Callbacks

--- Calculates the minimum distance between towers.
--- @param _PlayerID integer ID of player
--- @param _CurrentAmount integer Distance
--- @return integer Distance Distance
function GameCallback_SH_Calculate_MinimalTowerDistance(_PlayerID, _CurrentAmount)
    return Stronghold.Construction.Config.TowerDistance;
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Construction:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {};
    end
    self:OverwriteCallbacks();
    self:InitBuildingLimits();
    self:InitBarracksBuildingLimits(-1);
    self:StartCheckTowerDistanceCallback();
    self:InitLightBricks();
    self:SetWallConstructionSiteModel();

    Job.Second(function()
        Stronghold.Construction:IterateWallReplacer();
    end);
end

function Stronghold.Construction:OnSaveGameLoaded()
end

function Stronghold.Construction:OnEntityDestroyed(_EntityID)
    -- Reset military building limit
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    self:InitBarracksBuildingLimits(PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Wall

function Stronghold.Construction:SetWallConstructionSiteModel()
    local Iterator = CEntityIterator.OfTypeFilter(Entities.XD_WallConstructionSite);
    for EntityID in CEntityIterator.Iterator(Iterator) do
        Logic.SetModelAndAnimSet(EntityID, Models.XD_RuinFragment6);
    end
end

function Stronghold.Construction:IterateWallReplacer()
    for Replacer, Replacement in pairs(self.Config.WallReplacerMap) do
        local Iterator = CEntityIterator.OfTypeFilter(Replacer);
        for EntityID in CEntityIterator.Iterator(Iterator) do
            local PlayerID = Logic.EntityGetPlayer(EntityID);
            if IsPlayer(PlayerID) then
                local TypeName = Logic.GetEntityTypeName(Replacement);
                local Orientation = Logic.GetEntityOrientation(EntityID);
                local SiteOrientation = Orientation + ((string.find(TypeName, "Gate") and 45) or 0);
                local x,y,z = Logic.EntityGetPos(EntityID);
                local SiteID = Logic.CreateEntity(Entities.XD_WallConstructionSite, x, y, SiteOrientation, PlayerID);
                Logic.SetModelAndAnimSet(SiteID, Models.XD_RuinFragment6);
                local WallID = Logic.CreateEntity(Replacement, x, y, Orientation, PlayerID);
                DestroyEntity(EntityID);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Text

function Stronghold.Construction:GetBuildingEffects(_Type, _Technology)
    local EffectText = "";
    local TechnologyName = KeyOf(_Technology, Technologies);
    local EffectStringTable = XGUIEng.GetStringTableText("sh_effects/BuildingEffect_" ..TechnologyName);
    if EffectStringTable then
        EffectText = XGUIEng.GetStringTableText("sh_text/TooltipEffect") .. EffectStringTable;
    else
        local Effects = Stronghold.Economy:GetStaticTypeConfiguration(_Type);
        if Effects then
            if Effects.Reputation > 0 then
                local ReputationText = XGUIEng.GetStringTableText("sh_names/Reputation");
                EffectText = EffectText.. "+" ..Effects.Reputation.. " " ..ReputationText .. " ";
            end
            if Effects.Honor > 0 then
                local HonorText = XGUIEng.GetStringTableText("sh_names/Silver");
                EffectText = EffectText.. "+" ..Effects.Honor.. " " ..HonorText;
            end
            if EffectText ~= "" then
                local EffectDesc = XGUIEng.GetStringTableText("sh_text/TooltipEffect");
                EffectText = EffectDesc .. EffectText;
            end
        end
    end
    return EffectText;
end

function Stronghold.Construction:GetBuildingLimit(_PlayerID, _Type)
    local LimitText = "";
    local BuildingMax = EntityTracker.GetLimitOfType(_Type, _PlayerID);
    if BuildingMax > -1 then
        local BuildingCount = EntityTracker.GetUsageOfType(_Type, _PlayerID, true);
        LimitText = "(" ..BuildingCount.. "/" ..BuildingMax.. ")";
    end
    return LimitText;
end

function Stronghold.Construction:GetBuildingRequiredRank(_PlayerID, _Technology, _Text, _IsUpgrade)
    local RankName = GetRankName(0, _PlayerID);
    local Right = self.Config.RightsToCheckForConstruction[_Technology];
    if _IsUpgrade then
        Right = self.Config.RightsToCheckForUpgrade[_Technology];
    end
    if Right then
        local RequiredRank = GetRankRequired(_PlayerID, Right);
        RankName = GetRankName(RequiredRank, _PlayerID);
    end
    return string.gsub(_Text, "#Rank#", RankName);
end

-- -------------------------------------------------------------------------- --
-- Construction

function Stronghold.Construction:PrintTooltipConstructionButton(_UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut)
    local PlayerID = GetLocalPlayerID();
    if not IsPlayer(PlayerID) then
        return false;
    end
    local IsForbidden = false;

    -- Get default text
    local ForbiddenText = XGUIEng.GetStringTableText("MenuGeneric/BuildingNotAvailable")
    local NormalText = XGUIEng.GetStringTableText(_KeyNormal);
    local DisabledText = XGUIEng.GetStringTableText(_KeyDisabled);
    local DefaultText = NormalText;
    if XGUIEng.IsButtonDisabled(XGUIEng.GetCurrentWidgetID()) == 1 then
        DefaultText = DisabledText;
        if _Technology and Logic.GetTechnologyState(PlayerID, _Technology) == 0 then
            DefaultText = ForbiddenText;
            IsForbidden = true;
        end
    end

    -- Create costs tooltip
    local CostString = "";
    local ShortCutToolTip = "";
    local Type = Logic.GetBuildingTypeByUpgradeCategory(_UpgradeCategory, PlayerID);
    local TypeName = Logic.GetEntityTypeName(Type);
    if _Technology ==  nil then
        _Technology = Technologies[string.sub(TypeName, 2)];
    end
    if not IsForbidden then
        Logic.FillBuildingCostsTable(Type, InterfaceGlobals.CostTable);
        CostString = InterfaceTool_CreateCostString(InterfaceGlobals.CostTable);
        if _ShortCut then
            ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name")..
                ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]"
        end
        DefaultText = string.format(
            self:GetBuildingRequiredRank(PlayerID, _Technology, DefaultText),
            self:GetBuildingLimit(PlayerID, Type),
            self:GetBuildingEffects(Type, _Technology)
        );
    end

    -- Set text
    local Text = DefaultText;
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
    return true;
end

-- Update buttons in serf menu
-- for some reason most of the beautification buttons call the update of the
-- upgrade button instead of the construction button. A classical case of the
-- infamos "BB-Logic".... To avoid boilerplate we outsource the changes.
function Stronghold.Construction:UpdateSerfConstructionButtons(_PlayerID, _Button, _Technology)
    -- Kerberos/Kala hack
    local HeroID = Stronghold:GetPlayerHero(_PlayerID);
    local HeroType = Logic.GetEntityType(HeroID);
    local Technology = _Technology;
    if HeroType == Entities.CU_BlackKnight or HeroType == Entities.CU_Evil_Queen then
        if self.Config.TechnologyAlternateHack[Technology] then
            Technology = self.Config.TechnologyAlternateHack[Technology];
        end
    end

    -- HACK: Hide unused buttons
    if _Button == "Build_Tower" then
        XGUIEng.ShowWidget(_Button, 0);
        return;
    end

    -- Get right and technology
    local Disable = false;
    local CheckList = Stronghold.Construction.Config.TypesToCheckForConstruction[Technology];
    local CheckRight = Stronghold.Construction.Config.RightsToCheckForConstruction[_Technology];
    if not CheckRight or not CheckList or not CheckList[1] then
        return false;
    end

    -- Check limit
    local Limit = -1;
    if CheckList then
        Limit = EntityTracker.GetLimitOfType(CheckList[1], _PlayerID);
    end
    if Limit > -1 then
        Disable = EntityTracker.IsLimitOfTypeReached(CheckList[1], _PlayerID, true);
    end
    -- Check right
    local Right = Stronghold.Rights:GetRankRequiredForRight(_PlayerID, CheckRight);
    if Right > 0 and GetRank(_PlayerID) < Right then
        Disable = true;
    end
    -- Check technology
    if not Disable then
        if Logic.GetTechnologyState(_PlayerID, _Technology) < 2 then
            Disable = true;
        end
    end

    if Disable then
        XGUIEng.DisableButton(_Button, 1);
        return true;
    end
    return false;
end

function Stronghold.Construction:UpdateSerfUpgradeButtons(_Button, _Technology)
    local PlayerID = GUI.GetPlayerID();
    if IsPlayer(PlayerID) then
        if not Stronghold.Construction:UpdateSerfConstructionButtons(PlayerID, _Button, _Technology) then
            return self:UpdateBuildingUpgradeButtons(_Button, _Technology);
        end
    end
    return false;
end

-- -------------------------------------------------------------------------- --
-- Upgrade Button

function Stronghold.Construction:PrintBuildingUpgradeButtonTooltip(_Type, _KeyDisabled, _KeyNormal, _Technology)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) then
        return false;
    end
    local IsForbidden = false;

    -- Kerberos/Kala hack
    local HeroID = Stronghold:GetPlayerHero(PlayerID);
    local HeroType = Logic.GetEntityType(HeroID);
    local Technology = _Technology;
    if HeroType == Entities.CU_BlackKnight or HeroType == Entities.CU_Evil_Queen then
        if self.Config.TechnologyAlternateHack[Technology] then
            Technology = self.Config.TechnologyAlternateHack[Technology];
        end
    end

    -- Get default text
    local ForbiddenText = XGUIEng.GetStringTableText("MenuGeneric/BuildingNotAvailable");
    local NormalText = XGUIEng.GetStringTableText(_KeyNormal);
    local DisabledText = XGUIEng.GetStringTableText(_KeyDisabled);
    local DefaultText = NormalText;
    if XGUIEng.IsButtonDisabled(XGUIEng.GetCurrentWidgetID()) == 1 then
        DefaultText = DisabledText;
        if Technology and Logic.GetTechnologyState(PlayerID, Technology) == 0 then
            DefaultText = ForbiddenText;
            IsForbidden = true;
        end
    end

    -- Create costs tooltip
    local CostString = "";
    local ShortCutToolTip = "";
    if not IsForbidden then
        local UpgradeLevel = Logic.GetUpgradeLevelForBuilding(EntityID);
        local CheckTechnologies = Stronghold.Construction.Config.TypesToCheckForUpgrade[Technology] or {};
        Logic.FillBuildingUpgradeCostsTable(_Type, InterfaceGlobals.CostTable);
        CostString = InterfaceTool_CreateCostString(InterfaceGlobals.CostTable);
        ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name")..
            ": [" .. XGUIEng.GetStringTableText("KeyBindings/UpgradeBuilding") .. "]"
        DefaultText = string.format(
            self:GetBuildingRequiredRank(PlayerID, Technology, DefaultText, true),
            self:GetBuildingLimit(PlayerID, CheckTechnologies[UpgradeLevel +2]),
            self:GetBuildingEffects(CheckTechnologies[UpgradeLevel +2], Technology)
        );
    end

    -- Set text
    local Text = DefaultText;
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
    return true;
end

function Stronghold.Construction:UpdateBuildingUpgradeButtons(_Button, _Technology)
    local PlayerID = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local UpgradeLevel = Logic.GetUpgradeLevelForBuilding(EntityID);
    -- Kerberos/Kala hack
    local HeroID = Stronghold:GetPlayerHero(PlayerID);
    local HeroType = Logic.GetEntityType(HeroID);
    local Technology = _Technology;
    if HeroType == Entities.CU_BlackKnight or HeroType == Entities.CU_Evil_Queen then
        if self.Config.TechnologyAlternateHack[Technology] then
            Technology = self.Config.TechnologyAlternateHack[Technology];
        end
    end

    if IsPlayer(PlayerID) then
        local Disable = false;
        local CheckTechnologies = Stronghold.Construction.Config.TypesToCheckForUpgrade[Technology] or {};
        local CheckRight = Stronghold.Construction.Config.RightsToCheckForUpgrade[_Technology];
        if not CheckRight or not CheckTechnologies or not CheckTechnologies[1] then
            return false;
        end

        -- Check limit
        local Limit = EntityTracker.GetLimitOfType(CheckTechnologies[UpgradeLevel +2], PlayerID);
        if Limit > -1 then
            Disable = EntityTracker.IsLimitOfTypeReached(CheckTechnologies[UpgradeLevel +2], PlayerID, true);
        end
        -- Check right
        local Right = Stronghold.Rights:GetRankRequiredForRight(PlayerID, CheckRight);
        if Right > 0 and GetRank(PlayerID) < Right then
            Disable = true;
        end
        -- Check technology
        if not Disable then
            if Logic.GetTechnologyState(PlayerID, _Technology) < 2 then
                Disable = true;
            end
        end

        if Disable then
            XGUIEng.DisableButton(_Button, 1);
            return true;
        end
    end
    return false;
end

-- -------------------------------------------------------------------------- --
-- Light Bricks

function Stronghold.Construction:InitLightBricks()
    if CMod then
        GameCallback_ConstructBuilding = function(_SiteID, _SerfCount, _Amount)
            local PlayerID = Logic.EntityGetPlayer(_SiteID);
            if Logic.IsTechnologyResearched(PlayerID, Technologies.T_LightBricks) == 1 then
                _Amount = (_Amount * self.Config.LightBricksFactor) or _Amount;
            end
            return _Amount;
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Soft Tower Limit

function Stronghold.Construction:StartCheckTowerDistanceCallback()
    -- Check tower placement
    -- Prevents towers from being placed if another tower of the same player is
    -- to close. Type of tower does not matter.
    if CMod then
        GameCallback_PlaceBuildingAdditionalCheck = function(_Type, _x, _y, _rotation, _isBuildOn)
            local PlayerID = GUI.GetPlayerID();
            local Allowed = true;
            if IsPlayer(PlayerID) then
                local UpCat = Logic.GetUpgradeCategoryByBuildingType(_Type);
                if Allowed and Stronghold.Construction.Config.TowerPlacementDistanceCheck[UpCat] then
                    local AreaSize = Stronghold.Construction.Config.TowerDistance;
                    AreaSize = GameCallback_SH_Calculate_MinimalTowerDistance(PlayerID, AreaSize);
                    if Stronghold.Construction:AreTowersOfPlayerInArea(PlayerID, _x, _y, AreaSize) then
                        Allowed = false;
                    end
                end
            end
            return Allowed;
        end
    end
end

function Stronghold.Construction:AreTowersOfPlayerInArea(_PlayerID, _X, _Y, _AreaSize)
    local DarkTower1 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower1, _X, _Y, _AreaSize, 1)};
    local DarkTower2 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower2, _X, _Y, _AreaSize, 1)};
    local DarkTower3 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower3, _X, _Y, _AreaSize, 1)};
    local DarkTower4 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower4, _X, _Y, _AreaSize, 1)};
    local Tower1 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower1, _X, _Y, _AreaSize, 1)};
    local Tower2 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower2, _X, _Y, _AreaSize, 1)};
    local Tower3 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower3, _X, _Y, _AreaSize, 1)};
    local Tower4 = {Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower4, _X, _Y, _AreaSize, 1)};
    return Tower1[1] + Tower2[1] + Tower3[1] + Tower4[1] + DarkTower1[1] + DarkTower2[1] + DarkTower3[1] + DarkTower4[1] > 0;
end

-- -------------------------------------------------------------------------- --
-- Building Limit

-- Setup the building limit for some building types.
-- (The tracker only handles the tracking and not the UI!)
function Stronghold.Construction:InitBuildingLimits()
    -- Keep
    EntityTracker.SetLimitOfType(Entities.PB_Headquarters1, 1);
    EntityTracker.SetLimitOfType(Entities.PB_Headquarters2, 1);
    EntityTracker.SetLimitOfType(Entities.PB_Headquarters3, 1);

    -- Beautifications
    EntityTracker.SetLimitOfType(Entities.PB_Beautification04, 6);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification06, 6);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification09, 6);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification01, 3);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification02, 3);
    EntityTracker.SetLimitOfType(Entities.PB_Beautification12, 3);
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
end

function Stronghold.Construction:OverwriteCallbacks()
    Overwrite.CreateOverwrite("GUIAction_PlaceBuilding", function(_UpgradeCategory)
        CPlaceBuilding.SetRotation(0);
        Overwrite.CallOriginal();
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Logic_PlayerPromoted", function(_PlayerID, _OldRank, _NewRank)
        Overwrite.CallOriginal();
        Stronghold.Construction:InitBarracksBuildingLimits(_PlayerID);
    end);

    Overwrite.CreateOverwrite("GameCallback_GUI_OnConstructionButtonsUpdated", function(_PlayerID)
        Overwrite.CallOriginal();
        if GUI.GetPlayerID() == _PlayerID or _PlayerID == 17 then
            GUIUpdate_BuildingButtons("Build_Mercenary", Technologies.B_Mercenary);
            GUIUpdate_BuildingButtons("Build_BallistaTower", Technologies.B_BallistaTower);
            GUIUpdate_BuildingButtons("Build_CannonTower", Technologies.B_CannonTower);
        end
    end);

    Overwrite.CreateOverwrite("GameCallback_GUI_OnUpgradeButtonsUpdated", function(_PlayerID)
        Overwrite.CallOriginal();
        if GUI.GetPlayerID() == _PlayerID or _PlayerID == 17 then
            GUIUpdate_UpgradeButtons("Upgrade_Outpost1", Technologies.UP1_Outpost);
            GUIUpdate_UpgradeButtons("Upgrade_Outpost2", Technologies.UP2_Outpost);
        end
    end);
end

function Stronghold.Construction:InitBarracksBuildingLimits(_PlayerID)
    -- Call for all players
    if _PlayerID == -1 then
        for i= 1, GetMaxAmountOfPlayer() do
            self:InitBarracksBuildingLimits(i);
        end
        return;
    end
    -- Break on invalid player
    if not IsPlayer(_PlayerID) then
        return;
    end
    local Rank = GetRank(_PlayerID);

    -- Set limit of recruiter buildings
    local RecruiterLimit = self.Config.RecruitBuildingAmounts[Rank +1];
    EntityTracker.SetLimitOfType(Entities.PB_Barracks1, RecruiterLimit, _PlayerID);
    EntityTracker.SetLimitOfType(Entities.PB_Barracks2, RecruiterLimit, _PlayerID);
    EntityTracker.SetLimitOfType(Entities.PB_Archery1, RecruiterLimit, _PlayerID);
    EntityTracker.SetLimitOfType(Entities.PB_Archery2, RecruiterLimit, _PlayerID);
    EntityTracker.SetLimitOfType(Entities.PB_Stable1, RecruiterLimit, _PlayerID);
    EntityTracker.SetLimitOfType(Entities.PB_Stable2, RecruiterLimit, _PlayerID);
    EntityTracker.SetLimitOfType(Entities.PB_MercenaryCamp1, RecruiterLimit, _PlayerID);

    -- Set limit of smelter buildings
    local SmelterLimit = self.Config.SmeltingBuildingAmounts[Rank +1];
    EntityTracker.SetLimitOfType(Entities.PB_Foundry1, SmelterLimit, _PlayerID);
    EntityTracker.SetLimitOfType(Entities.PB_Foundry2, SmelterLimit, _PlayerID);
end

