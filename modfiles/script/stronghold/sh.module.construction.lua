---
--- Construction Script
--- 
--- This script implements construction and upgrade of buildings and their
--- respective limitations.
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
--- @param _UpgradeCategory integer Upgrade category
--- @param _CurrentAmount integer Distance
--- @return integer Distance Distance
function GameCallback_SH_Calculate_MinimalConstructionDistance(_PlayerID, _UpgradeCategory, _CurrentAmount)
    return _CurrentAmount;
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
            local TypeName = Logic.GetEntityTypeName(Replacement);
            local Orientation = Logic.GetEntityOrientation(EntityID);
            local SiteOrientation = Orientation - ((string.find(TypeName, "Gate") and 45) or 0);
            local x,y,z = Logic.EntityGetPos(EntityID);
            local SiteID = Logic.CreateEntity(Entities.XD_WallConstructionSite, x, y, SiteOrientation, 0);
            Logic.SetModelAndAnimSet(SiteID, Models.XD_RuinFragment6);
            local PlayerID = Logic.EntityGetPlayer(EntityID);
            if IsPlayer(PlayerID) then
                Logic.CreateEntity(Replacement, x, y, Orientation, PlayerID);
            end
            DestroyEntity(EntityID);
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Text

function Stronghold.Construction:GetBuildingEffects(_Type, _Technology)
    local EffectText = "";
    local PlayerID = GetLocalPlayerID();
    local TechnologyName = KeyOf(_Technology, Technologies);
    local EffectStringTable = XGUIEng.GetStringTableText("sh_effects/BuildingEffect_" ..TechnologyName);
    if EffectStringTable then
        EffectText = XGUIEng.GetStringTableText("sh_text/TooltipEffect") .. EffectStringTable;
    else
        local ReputationText = XGUIEng.GetStringTableText("sh_text/Reputation");
        local HonorText = XGUIEng.GetStringTableText("sh_text/Silver");
        local TextInstantly = " " .. XGUIEng.GetStringTableText("sh_text/TooltipEffectInstantly");
        local TextOngoing = " " .. XGUIEng.GetStringTableText("sh_text/TooltipEffectOngoing");

        -- Info about single time bonuses
        local Bonuses = Stronghold.Building.Config.BuildingCreationBonus[_Type];
        local IsApplied = Stronghold.Building:IsBuildingCreationBonusApplied(PlayerID, _Type);
        if Bonuses and not IsApplied then
            if Bonuses.Reputation > 0 then
                local Seperator = (EffectText ~= "" and ", ") or "";
                EffectText = EffectText .. Seperator.. " +" ..Bonuses.Reputation.. " " ..ReputationText .. " " .. TextInstantly;
            end
            if Bonuses.Honor > 0 then
                local Seperator = (EffectText ~= "" and ", ") or "";
                EffectText = EffectText .. Seperator.. " +" ..Bonuses.Honor.. " " ..HonorText .. " " .. TextInstantly;
            end
        end
        -- Info about ongoing production
        local Effects = Stronghold.Economy:GetStaticTypeConfiguration(_Type);
        if Effects then
            if Effects.Reputation > 0 then
                local Seperator = (EffectText ~= "" and ", ") or "";
                EffectText = EffectText .. Seperator.. " +" ..Effects.Reputation.. " " ..ReputationText .. " " .. TextOngoing;
            end
            if Effects.Honor > 0 then
                local Seperator = (EffectText ~= "" and ", ") or "";
                EffectText = EffectText .. Seperator .. " +" ..Effects.Honor.. " " ..HonorText .. " " .. TextOngoing;
            end
        end

        if EffectText ~= "" then
            local EffectDesc = XGUIEng.GetStringTableText("sh_text/TooltipEffect");
            EffectText = EffectDesc .. EffectText;
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
    local EntityID = GUI.GetSelectedEntity();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    if GuiPlayer ~= 17 and GuiPlayer ~= PlayerID then
        return false;
    end
    if not IsPlayer(PlayerID) then
        return false;
    end
    local IsForbidden = false;

    local InputUpgradeCategory = _UpgradeCategory;
    local UpgradeCategory = _UpgradeCategory;
    if self.Config.FastBuildUpCatToNormalUpCat[UpgradeCategory] then
        UpgradeCategory = self.Config.FastBuildUpCatToNormalUpCat[UpgradeCategory];
    end

    -- Get default text
    local ForbiddenText = XGUIEng.GetStringTableText("MenuGeneric/BuildingNotAvailable");
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
    local Type = Logic.GetBuildingTypeByUpgradeCategory(InputUpgradeCategory, PlayerID);
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
        local Level = GetUpgradeLevelByEntityType(Type);
        local LevelText = (Level > 0 and " [Level: " ..(Level +1).. "] ") or "";
        DefaultText = string.format(
            self:GetBuildingRequiredRank(PlayerID, _Technology, DefaultText),
            LevelText .. self:GetBuildingLimit(PlayerID, Type),
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
    local Technology = _Technology;
    local HeroType = Logic.GetEntityType(GetNobleID(_PlayerID));
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
    if Right > 0 and (GetRank(_PlayerID) < Right or IsRightLockedForPlayer(_PlayerID, Right)) then
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
    local EntityID = GUI.GetSelectedEntity();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    if GuiPlayer ~= 17 and GuiPlayer ~= PlayerID then
        return false;
    end
    if not IsPlayer(PlayerID) then
        return false;
    end
    local IsForbidden = false;

    -- Kerberos/Kala hack
    local HeroID = GetNobleID(PlayerID);
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
    local EntityID = GUI.GetSelectedEntity();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    if GuiPlayer ~= 17 and GuiPlayer ~= PlayerID then
        return false;
    end

    local UpgradeLevel = Logic.GetUpgradeLevelForBuilding(EntityID);
    -- Kerberos/Kala hack
    local HeroID = GetNobleID(PlayerID);
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
        if Right > 0 and (GetRank(PlayerID) < Right or IsRightLockedForPlayer(PlayerID, Right)) then
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
-- Construction Distances

function Stronghold.Construction:OnPlacementCheck(_PlayerID, _Type, _X, _Y, _Rotation, _IsBuildOn)
    local UpCat = Logic.GetUpgradeCategoryByBuildingType(_Type);
    -- Check distance to buildings of same category
    if self.Config.PlacementDistanceCheck[UpCat] then
        local AreaSize = self.Config.PlacementDistanceCheck[UpCat];
        AreaSize = GameCallback_SH_Calculate_MinimalConstructionDistance(_PlayerID, UpCat, AreaSize);
        if self:AreBuildingsOfPlayerInArea(_PlayerID, UpCat, _X, _Y, AreaSize) then
            return false;
        end
    end
    -- Check distance to enemies
    if self.Config.EnemyDistanceCheck[UpCat] then
        local AreaSize = self.Config.EnemyDistanceCheck[UpCat];
        if AreEnemiesInArea(_PlayerID, {X= _X, Y= _Y}, AreaSize) then
            return false;
        end
    end
    return true;
end

function Stronghold.Construction:AreBuildingsOfPlayerInArea(_PlayerID, _UpgradeCategory, _X, _Y, _AreaSize)
    local UpgradeCategories = {Logic.GetBuildingTypesInUpgradeCategory(_UpgradeCategory)};
    for i= 2, UpgradeCategories[1] +1 do
        local Building = {Logic.GetPlayerEntitiesInArea(_PlayerID, UpgradeCategories[i], _X, _Y, _AreaSize, 1)};
        if Building[1] > 0 then
            return true;
        end
    end
    return false;
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
    EntityTracker.SetLimitOfType(Entities.PB_Beautification04, 1); -- 6
    EntityTracker.SetLimitOfType(Entities.PB_Beautification06, 1); -- 6
    EntityTracker.SetLimitOfType(Entities.PB_Beautification09, 1); -- 6
    EntityTracker.SetLimitOfType(Entities.PB_Beautification01, 1); -- 3
    EntityTracker.SetLimitOfType(Entities.PB_Beautification02, 1); -- 3
    EntityTracker.SetLimitOfType(Entities.PB_Beautification12, 1); -- 3
    EntityTracker.SetLimitOfType(Entities.PB_Beautification05, 1); -- 2
    EntityTracker.SetLimitOfType(Entities.PB_Beautification07, 1); -- 2
    EntityTracker.SetLimitOfType(Entities.PB_Beautification08, 1); -- 2
    EntityTracker.SetLimitOfType(Entities.PB_Beautification03, 1); -- 1
    EntityTracker.SetLimitOfType(Entities.PB_Beautification10, 1); -- 1
    EntityTracker.SetLimitOfType(Entities.PB_Beautification11, 1); -- 1

    -- Civil buildings
    EntityTracker.SetLimitOfType(Entities.PB_Monastery1, 1);
    EntityTracker.SetLimitOfType(Entities.PB_Monastery2, 1);
    EntityTracker.SetLimitOfType(Entities.PB_Monastery3, 1);
    EntityTracker.SetLimitOfType(Entities.PB_Market2, 3);
    EntityTracker.SetLimitOfType(Entities.PB_PowerPlant1, 1);
    EntityTracker.SetLimitOfType(Entities.PB_ExecutionerPlace1, 1);
end

function Stronghold.Construction:OverwriteCallbacks()
    self.Orig_GUIAction_PlaceBuilding = GUIAction_PlaceBuilding;
    GUIAction_PlaceBuilding = function(_UpgradeCategory)
        local UpgradeCategory = _UpgradeCategory;
        local GuiPlayer = GUI.GetPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        local PlayerID = Logic.EntityGetPlayer(EntityID);
        if GuiPlayer ~= 17 and GuiPlayer ~= PlayerID then
            return;
        end
        if XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1 then
            UpgradeCategory = Stronghold.Construction:GetFastBuildUpgradeCategory(PlayerID, _UpgradeCategory);
        end
        CPlaceBuilding.SetRotation(0);
        Stronghold.Construction.Orig_GUIAction_PlaceBuilding(UpgradeCategory);
    end

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

-- -------------------------------------------------------------------------- --
-- Fast Build

function Stronghold.Construction:GetFastBuildUpgradeCategory(_PlayerID, _UpgradeCategory)
    local UpgradeCategory = _UpgradeCategory;
    if self.Config.NormalUpCatToFastBuildUpCat[UpgradeCategory] then
        for i= 1, table.getn(self.Config.NormalUpCatToFastBuildUpCat[UpgradeCategory]) do
            local HigherUpgradeCategory = self.Config.NormalUpCatToFastBuildUpCat[UpgradeCategory][i];
            local NeededRight = self.Config.FastBuildUpCatToRight[HigherUpgradeCategory];
            if HasRight(_PlayerID, NeededRight) then
                UpgradeCategory = HigherUpgradeCategory;
                break;
            end
        end
    end
    return UpgradeCategory;
end

