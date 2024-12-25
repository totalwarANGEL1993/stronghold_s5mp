--- 
--- Building Script
---
--- This script implements special properties of building.
--- 

Stronghold = Stronghold or {};

Stronghold.Building = Stronghold.Building or {
    SyncEvents = {},
    Data = {
        Turrets = {},
        LastWeatherChange = 0,
    },
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- Game Callbacks

--- Called after a rally point is set.
--- @param _PlayerID integer ID of player
--- @param _EntityID integer ID of entity
--- @param _X number X coordinate
--- @param _Y number Y coordinate
--- @param _Initial boolean Set for the first time
function GameCallback_SH_Logic_RallyPointPlaced(_PlayerID, _EntityID, _X, _Y, _Initial)
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Building:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            Influence = {},
            RallyPoint = {},
            UnitMover = {},
            Corners = {},
            CreationBonus = {},
        };
    end

    self:CreateBuildingButtonHandlers();
    self:OverrideKeepButtons();
    self:OverrideManualButtonUpdate();
    self:OverrideSellBuildingAction();
    self:OverrideShiftRightClick();
    self:OverwriteWeatherTowerButtons();
    self:InitalizeTurretsForExistingBuildings();
    self:InitalizeSerfBuildingTabs();
    self:InitalizeBuyUnitKeybindings();
end

function Stronghold.Building:OnSaveGameLoaded()
    XGUIEng.TransferMaterials("BlessSettlers1", "BlessSettlers1Source");
    XGUIEng.TransferMaterials("BlessSettlers2", "BlessSettlers2Source");
    XGUIEng.TransferMaterials("BlessSettlers3", "BlessSettlers3Source");
    XGUIEng.TransferMaterials("BlessSettlers4", "BlessSettlers4Source");
    XGUIEng.TransferMaterials("BlessSettlers5", "BlessSettlers5Source");

    self:OverrideManualButtonUpdate();
    self:OverrideSellBuildingAction();
    self:InitalizeBuyUnitKeybindings();
end

function Stronghold.Building:CreateBuildingButtonHandlers()
    self.SyncEvents = {
        ChangeTax = 1,
        RallyPoint = 4,
        ChangeWeather = 5,
        ChangeRations = 6,
        ChangeSleepTime = 7,
        ChangeBeverage = 8,
        ChangeFestival = 9,
        ChangeSermon = 10,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Building.SyncEvents.ChangeTax then
                Stronghold.Building:KeepButtonChangeTax(_PlayerID, arg[1]);
            end
            if _Action == Stronghold.Building.SyncEvents.RallyPoint then
                Stronghold.Building:PlaceRallyPoint(_PlayerID, arg[1], arg[2], arg[3], arg[4]);
            end
            if _Action == Stronghold.Building.SyncEvents.ChangeWeather then
                local State = Logic.GetWeatherState();
                Stronghold.Building:OnWeatherStateChanged(_PlayerID, State, arg[1]);
            end
            if _Action == Stronghold.Building.SyncEvents.ChangeRations then
                --- @diagnostic disable-next-line: param-type-mismatch
                SetRationLevel(_PlayerID, arg[1]);
            end
            if _Action == Stronghold.Building.SyncEvents.ChangeSleepTime then
                --- @diagnostic disable-next-line: param-type-mismatch
                SetSleepTimeLevel(_PlayerID, arg[1]);
            end
            if _Action == Stronghold.Building.SyncEvents.ChangeBeverage then
                --- @diagnostic disable-next-line: param-type-mismatch
                SetBeverageLevel(_PlayerID, arg[1]);
            end
            if _Action == Stronghold.Building.SyncEvents.ChangeFestival then
                --- @diagnostic disable-next-line: param-type-mismatch
                SetFestivalLevel(_PlayerID, arg[1]);
            end
            if _Action == Stronghold.Building.SyncEvents.ChangeSermon then
                --- @diagnostic disable-next-line: param-type-mismatch
                SetSermonLevel(_PlayerID, arg[1]);
            end
        end
    );
end

function Stronghold.Building:OnEveryTurn(_PlayerID)
    -- Church service
    self:ControlChurchService(_PlayerID);
    -- Keep festival
    self:ControlKeepFestival(_PlayerID);
end

function Stronghold.Building:OncePerSecond(_PlayerID)
    -- Cannon auto repair
    self:FoundryCannonAutoRepair(_PlayerID);
    -- Castle upgrade
    self:CheckBuildingTechnologyConditions(_PlayerID);
    -- Control rally points
    self:UnitToRallyPointController(_PlayerID);
end

function Stronghold.Building:OnEverySecond()
    -- Control turrets
    self:UpdateTurretsOfBuilding();
end

function Stronghold.Building:OnEntityCreated(_EntityID)
    -- Unit spawned
    self:OnUnitCreated(_EntityID);
end

function Stronghold.Building:OnEntityDestroyed(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    -- Control rally points
    self:OnRallyPointHolderDestroyed(PlayerID, _EntityID);
end

function Stronghold.Building:OnConstructionComplete(_EntityID, _PlayerID)
    -- Turrets
    self:CreateTurretsForBuilding(_EntityID);
    -- Construction bonus
    self:ApplyBuildingCreationBonus(_EntityID);
    -- Rally point
    self:SetIgnoreRallyPointSelectionCancel(_PlayerID);
end

function Stronghold.Building:OnBuildingUpgrade(_EntityID, _PlayerID)
    -- Update turrets
    self:DestroyTurretsOfBuilding(_EntityID);
    self:CreateTurretsForBuilding(_EntityID);
    -- Upgrade bonus
    self:ApplyBuildingCreationBonus(_EntityID);
    -- Rally point
    self:SetIgnoreRallyPointSelectionCancel(_PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Serf menu

function Stronghold.Building:InitalizeSerfBuildingTabs()
	gvGUI_WidgetID.SerfMenus               = XGUIEng.GetWidgetID("Commands_Serf");
    gvGUI_WidgetID.ToSerfConstructionMenu  = XGUIEng.GetWidgetID("SerfToConstructionMenu");
    gvGUI_WidgetID.ToSerfMilitaryMenu      = XGUIEng.GetWidgetID("SerfToMilitaryMenu");
	gvGUI_WidgetID.ToSerfBeatificationMenu = XGUIEng.GetWidgetID("SerfToBeautificationMenu");
    gvGUI_WidgetID.SerfConstructionMenu    = XGUIEng.GetWidgetID("SerfConstructionMenu");
	gvGUI_WidgetID.SerfBeautificationMenu  = XGUIEng.GetWidgetID("SerfBeautificationMenu");
	gvGUI_WidgetID.SerfMilitaryMenu        = XGUIEng.GetWidgetID("SerfMilitaryMenu");

    gvStronghold_LastSelectedSerfMenu = gvGUI_WidgetID.SerfConstructionMenu;

    GUIAction_ToggleSerfMenu = function( _Menu, _status)
        XGUIEng.ShowAllSubWidgets(gvGUI_WidgetID.SerfMenus, 0);
        XGUIEng.UnHighLightGroup(gvGUI_WidgetID.InGame, "BuildingMenuGroup");
        if _Menu == gvGUI_WidgetID.SerfConstructionMenu then
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfBeatificationMenu, 1);
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfMilitaryMenu, 1);
            gvStronghold_LastSelectedSerfMenu = gvGUI_WidgetID.SerfConstructionMenu;
        elseif _Menu == gvGUI_WidgetID.SerfMilitaryMenu then
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfConstructionMenu, 1);
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfBeatificationMenu, 1);
            gvStronghold_LastSelectedSerfMenu = gvGUI_WidgetID.SerfMilitaryMenu;
        else
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfConstructionMenu, 1);
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfMilitaryMenu, 1);
            gvStronghold_LastSelectedSerfMenu = gvGUI_WidgetID.SerfBeautificationMenu;
        end
        XGUIEng.ShowWidget(_Menu, _status);
        XGUIEng.DoManualButtonUpdate(gvGUI_WidgetID.InGame);
    end
end

-- -------------------------------------------------------------------------- --
-- Building Technology

function Stronghold.Building:CheckBuildingTechnologyConditions(_PlayerID)
    local WorkplaceList = GetWorkplacesOfType(_PlayerID, 0, true);

    -- Upgrade keep
    if  Logic.GetTechnologyState(_PlayerID, Technologies.UP1_Headquarter) == 1
    and GetRank(_PlayerID) >= GetRankRequired(_PlayerID, PlayerRight.Fortress)
    and not IsRightLockedForPlayer(_PlayerID, PlayerRight.Fortress)
    and Logic.GetUpgradeLevelForBuilding(GetHeadquarterID(_PlayerID)) < 1 then
        Logic.SetTechnologyState(_PlayerID, Technologies.UP1_Headquarter, 2);
    end

    -- Upgrade Fortress
    -- TODO: Turn this into a propper feature later on?
    if  Logic.GetTechnologyState(_PlayerID, Technologies.UP1_Headquarter) >= 2
    and Logic.GetTechnologyState(_PlayerID, Technologies.UP2_Headquarter) == 1
    and GetRank(_PlayerID) >= GetRankRequired(_PlayerID, PlayerRight.Zitadel)
    and not IsRightLockedForPlayer(_PlayerID, PlayerRight.Zitadel)
    and Logic.GetUpgradeLevelForBuilding(GetHeadquarterID(_PlayerID)) < 2 then
        local BuildingAmount = 0;
        for i= 2, WorkplaceList[1] +1 do
            local Type = Logic.GetEntityType(WorkplaceList[i]);
            if self.Config.CastleBuildingUpgradeRequirements[Type] then
                BuildingAmount = BuildingAmount + 1;
            end
        end
        if BuildingAmount >= 3 then
            Logic.SetTechnologyState(_PlayerID, Technologies.UP2_Headquarter, 2);
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Alchemist

function Stronghold.Building:OnAlchemistSelected(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if not IsPlayer(PlayerID)
    or Logic.GetUpgradeCategoryByBuildingType(Type) ~= UpgradeCategories.Alchemist then
        return;
    end
    XGUIEng.ShowWidget("Research_WeatherForecast", 0);
    XGUIEng.ShowWidget("Research_ChangeWeather", 0);
end

-- -------------------------------------------------------------------------- --
-- Tower

function Stronghold.Building:OnTowerSelected(_EntityID)
    if Logic.IsConstructionComplete(_EntityID) == 1 then
        local Type = Logic.GetEntityType(_EntityID);
        if Type == Entities.PB_DarkTower1 or Type == Entities.PB_Tower1 then
            XGUIEng.ShowWidget("Tower", 1);
            XGUIEng.ShowWidget("Commands_Tower", 1);
            XGUIEng.ShowWidget("Upgrade_Tower1", 0);
            XGUIEng.ShowWidget("Upgrade_Tower2", 0);
            XGUIEng.ShowWidget("Upgrade_Tower3", 1);
            GUIUpdate_UpgradeButtons("Upgrade_Tower3", Technologies.UP3_Tower);
        end
        if Type == Entities.PB_DarkTower2 or Type == Entities.PB_Tower2 then
            XGUIEng.ShowWidget("Tower", 1);
            XGUIEng.ShowWidget("Commands_Tower", 1);
            XGUIEng.ShowWidget("Upgrade_Tower1", 0);
            XGUIEng.ShowWidget("Upgrade_Tower2", 1);
            XGUIEng.ShowWidget("Upgrade_Tower3", 0);
            GUIUpdate_UpgradeButtons("Upgrade_Tower2", Technologies.UP2_Tower);
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Farm

function Stronghold.Building:OnFarmSelected(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    XGUIEng.ShowWidget("FarmRations", 0);
    if Type == Entities.PB_Farm1
    or Type == Entities.PB_Farm2
    or Type == Entities.PB_Farm3 then
        XGUIEng.ShowWidget("FarmRations", 1);
    end
end

function Stronghold.Building:PrintFarmRationButtonsTooltip(_PlayerID, _EntityID, _Key)
    if  Logic.GetEntityType(_EntityID) ~= Entities.PB_Farm1
    and Logic.GetEntityType(_EntityID) ~= Entities.PB_Farm2
    and Logic.GetEntityType(_EntityID) ~= Entities.PB_Farm3 then
        return false;
    end

    local Level = -1;
    if _Key == "sh_menufarm/FarmRationsLevel0" then
        Level = 0;
    elseif _Key == "sh_menufarm/FarmRationsLevel1" then
        Level = 1;
    elseif _Key == "sh_menufarm/FarmRationsLevel2" then
        Level = 2;
    elseif _Key == "sh_menufarm/FarmRationsLevel3" then
        Level = 3;
    elseif _Key == "sh_menufarm/FarmRationsLevel4" then
        Level = 4;
    else
        return false;
    end

    local StringText = XGUIEng.GetStringTableText(_Key);
    local Effects = Stronghold.Economy.Config.Income.Rations[Level];

    local Seperate = false;
    local EffectDesc = " @cr " ..XGUIEng.GetStringTableText("sh_text/TooltipEffect");
    local EffectText = "";
    local OngoingText = XGUIEng.GetStringTableText("sh_text/TooltipEffectOngoing");
    if Effects.Reputation ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Reputation");
        local Operator = (Effects.Reputation >= 0 and "+") or "";
        local Value = string.format("" ..Effects.Reputation, "%.1f");
        EffectText = EffectText.. Operator ..Value.. " " ..Unit.. " " ..OngoingText;
        Seperate = true;
    end
    if Effects.Honor ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Silver");
        local Operator = (Effects.Honor >= 0 and "+") or "";
        local Seperator = (Seperate and ", ") or "";
        local Value = string.format("" ..Effects.Honor, "%.1f");
        EffectText = EffectText..Seperator.. Operator ..Value.. " " ..Unit.. " " ..OngoingText;
    end
    EffectText = (EffectText ~= "" and EffectDesc..EffectText) or EffectText;

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, StringText .. EffectText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

GUIAction_SetRations = function(_Level)
    local BuildingID = GUI.GetSelectedEntity();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(BuildingID);
    if GuiPlayer == PlayerID then
        Syncer.InvokeEvent(
            Stronghold.Building.NetworkCall,
            Stronghold.Building.SyncEvents.ChangeRations,
            _Level
        );
    end
end

GUIUpdate_RationsButtons = function()
    local PlayerID = GUI.GetPlayerID();
    local Level = GetRationLevel(PlayerID);
    -- XGUIEng.SetWidgetPosition("FarmRations", 118, 5);
    XGUIEng.UnHighLightGroup("InGame", "rationsgroup");
    local WidgetID = Stronghold.Building.Config.Civil.RationButtons[Level];
	XGUIEng.HighLightButton(WidgetID, 1);
end

-- -------------------------------------------------------------------------- --
-- Residence

function Stronghold.Building:OnResidenceSelected(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    XGUIEng.ShowWidget("ResidenceSleepTime", 0);
    if Type == Entities.PB_Residence1
    or Type == Entities.PB_Residence2
    or Type == Entities.PB_Residence3 then
        XGUIEng.ShowWidget("ResidenceSleepTime", 1);
    end
end

function Stronghold.Building:PrintResidenceSleepTimeButtonsTooltip(_PlayerID, _EntityID, _Key)
    if  Logic.GetEntityType(_EntityID) ~= Entities.PB_Residence1
    and Logic.GetEntityType(_EntityID) ~= Entities.PB_Residence2
    and Logic.GetEntityType(_EntityID) ~= Entities.PB_Residence3 then
        return false;
    end

    local Level = -1;
    if _Key == "sh_menuresidence/ResidenceSleepLevel0" then
        Level = 0;
    elseif _Key == "sh_menuresidence/ResidenceSleepLevel1" then
        Level = 1;
    elseif _Key == "sh_menuresidence/ResidenceSleepLevel2" then
        Level = 2;
    elseif _Key == "sh_menuresidence/ResidenceSleepLevel3" then
        Level = 3;
    elseif _Key == "sh_menuresidence/ResidenceSleepLevel4" then
        Level = 4;
    else
        return false;
    end

    local StringText = XGUIEng.GetStringTableText(_Key);
    local Effects = Stronghold.Economy.Config.Income.SleepTime[Level];

    local Seperate = false;
    local EffectDesc = " @cr " ..XGUIEng.GetStringTableText("sh_text/TooltipEffect");
    local EffectText = "";
    local OngoingText = XGUIEng.GetStringTableText("sh_text/TooltipEffectOngoing");
    if Effects.Reputation ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Reputation");
        local Operator = (Effects.Reputation >= 0 and "+") or "";
        local Value = string.format("" ..Effects.Reputation, "%.1f");
        EffectText = EffectText.. Operator ..Value.. " " ..Unit.. " " ..OngoingText;
        Seperate = true;
    end
    if Effects.Honor ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Silver");
        local Operator = (Effects.Honor >= 0 and "+") or "";
        local Seperator = (Seperate and ", ") or "";
        local Value = string.format("" ..Effects.Honor, "%.1f");
        EffectText = EffectText..Seperator.. Operator ..Value.. " " ..Unit.. " " ..OngoingText;
    end
    EffectText = (EffectText ~= "" and EffectDesc..EffectText) or EffectText;

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, StringText .. EffectText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

GUIAction_SetSleeptime = function(_Level)
    local BuildingID = GUI.GetSelectedEntity();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(BuildingID);
    if GuiPlayer == PlayerID then
        Syncer.InvokeEvent(
            Stronghold.Building.NetworkCall,
            Stronghold.Building.SyncEvents.ChangeSleepTime,
            _Level
        );
    end
end

GUIUpdate_SleeptimeButtons = function()
    local PlayerID = GUI.GetPlayerID();
    local Level = GetSleepTimeLevel(PlayerID);
    -- XGUIEng.SetWidgetPosition("ResidenceSleepTime", 118, 5);
    XGUIEng.UnHighLightGroup("InGame", "sleeptimegroup");
    local WidgetID = Stronghold.Building.Config.Civil.SleepButtons[Level];
	XGUIEng.HighLightButton(WidgetID, 1);
end

-- -------------------------------------------------------------------------- --
-- Tavern

function Stronghold.Building:OnTavernSelected(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    XGUIEng.ShowWidget("TavernBeverage", 0);
    if Type == Entities.PB_Tavern1
    or Type == Entities.PB_Tavern2 then
        XGUIEng.ShowWidget("TavernBeverage", 1);
        XGUIEng.ShowWidget("BuildingTabs", 1);
    end
end

function Stronghold.Building:PrintTavernBeverageButtonsTooltip(_PlayerID, _EntityID, _Key)
    if  Logic.GetEntityType(_EntityID) ~= Entities.PB_Tavern1
    and Logic.GetEntityType(_EntityID) ~= Entities.PB_Tavern2 then
        return false;
    end

    local Level = -1;
    if _Key == "sh_menutavern/TavernBeverageLevel0" then
        Level = 0;
    elseif _Key == "sh_menutavern/TavernBeverageLevel1" then
        Level = 1;
    elseif _Key == "sh_menutavern/TavernBeverageLevel2" then
        Level = 2;
    elseif _Key == "sh_menutavern/TavernBeverageLevel3" then
        Level = 3;
    elseif _Key == "sh_menutavern/TavernBeverageLevel4" then
        Level = 4;
    else
        return false;
    end

    local StringText = XGUIEng.GetStringTableText(_Key);
    local Effects = Stronghold.Economy.Config.Income.Beverage[Level];

    local Seperate = false;
    local EffectDesc = " @cr " ..XGUIEng.GetStringTableText("sh_text/TooltipEffect");
    local EffectText = "";
    local OngoingText = XGUIEng.GetStringTableText("sh_text/TooltipEffectOngoing");
    if Effects.Reputation ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Reputation");
        local Operator = (Effects.Reputation >= 0 and "+") or "";
        local Value = string.format("" ..Effects.Reputation, "%.1f");
        EffectText = EffectText.. Operator ..Value.. " " ..Unit.. " " ..OngoingText;
        -- (The tavern mirrors reputation onto honor if technology
        --  T_Instruments is researched.)
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_Instruments) == 1 then
            Effects.Honor = Effects.Reputation;
        end
        Seperate = true;
    end
    if Effects.Honor ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Silver");
        local Operator = (Effects.Honor >= 0 and "+") or "";
        local Seperator = (Seperate and ", ") or "";
        local Value = string.format("" ..Effects.Honor, "%.1f");
        EffectText = EffectText..Seperator.. Operator ..Value.. " " ..Unit.. " " ..OngoingText;
    end
    EffectText = (EffectText ~= "" and EffectDesc..EffectText) or EffectText;

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, StringText .. EffectText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

GUIAction_SetBeverage = function(_Level)
    local BuildingID = GUI.GetSelectedEntity();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(BuildingID);
    if GuiPlayer == PlayerID then
        Syncer.InvokeEvent(
            Stronghold.Building.NetworkCall,
            Stronghold.Building.SyncEvents.ChangeBeverage,
            _Level
        );
    end
end

GUIUpdate_BeverageButtons = function()
    local PlayerID = GUI.GetPlayerID();
    local Level = GetBeverageLevel(PlayerID);
    -- XGUIEng.SetWidgetPosition("TavernBeverage", 143, 5);
    XGUIEng.UnHighLightGroup("InGame", "beveragegroup");
    local WidgetID = Stronghold.Building.Config.Civil.BeverageButtons[Level];
	XGUIEng.HighLightButton(WidgetID, 1);
end

-- -------------------------------------------------------------------------- --
-- Keep

function Stronghold.Building:OverrideKeepButtons()
    gvStronghold_LastSelectedHQMenu = gvGUI_WidgetID.ToBuildingCommandMenu;

    Overwrite.CreateOverwrite("GUIAction_SetTaxes", function(_Level)
        local PlayerID = GetLocalPlayerID();
        if not IsPlayer(PlayerID) or GUI.GetPlayerID() == 17 then
            return false;
        end
        Syncer.InvokeEvent(
            Stronghold.Building.NetworkCall,
            Stronghold.Building.SyncEvents.ChangeTax,
            _Level
        );
    end);

    Overwrite.CreateOverwrite("GUIUpdate_TaxesButtons", function()
        local PlayerID = GetLocalPlayerID();
        if PlayerID == 17 then
            return;
        end
        local TaxLevel = GetTaxHeight(PlayerID) -1;
        XGUIEng.UnHighLightGroup(gvGUI_WidgetID.InGame, "taxesgroup");
        XGUIEng.HighLightButton(gvGUI_WidgetID.TaxesButtons[TaxLevel], 1);
    end);

    GUIAction_CallMilitia = function()
        XGUIEng.ShowWidget("BuyHeroWindow", 1);
    end

    GUIAction_BackToWork = function()
        Stronghold.Hero.Perk:PerkWindowOnShow();
    end
end

function Stronghold.Building:ControlKeepFestival(_PlayerID)
    if Logic.GetPlayerPaydayTimeLeft(_PlayerID) < 2000 then
        return;
    end

    local FestivalLevel = GetFestivalLevel(_PlayerID);
    local Level1 = GetBuildingsOfType(_PlayerID, Entities.PB_Headquarters1, true);
    local Level2 = GetBuildingsOfType(_PlayerID, Entities.PB_Headquarters2, true);
    local Level3 = GetBuildingsOfType(_PlayerID, Entities.PB_Headquarters3, true);
    if Level3[1] == 0 and FestivalLevel > 4 then
        SetFestivalLevel(_PlayerID, 4);
        return;
    end
    if Level2[1]+Level3[1] == 0 and FestivalLevel > 2 then
        SetFestivalLevel(_PlayerID, 2);
        return;
    end
    if Level1[1]+Level2[1]+Level3[1] == 0 and FestivalLevel > 0 then
        SetFestivalLevel(_PlayerID, 0);
        return;
    end

    local CurrentInfluence = GetPlayerInfluence(_PlayerID);
    local RequiredInfluence = GetPlayerMaxInfluencePoints(_PlayerID);

    local Costs = GetFestivalCosts(_PlayerID, FestivalLevel);
    local Config = Stronghold.Economy.Config.Income.Festival[FestivalLevel];
    if HasEnoughResources(_PlayerID, Costs) and CurrentInfluence >= RequiredInfluence then
        AddPlayerInfluence(_PlayerID, (-1) * CurrentInfluence);
        RemoveResourcesFromPlayer(_PlayerID, Costs);
        AddReputation(_PlayerID, Config.Reputation or 0);
        AddHonor(_PlayerID, Config.Honor or 0);
        Stronghold.Attraction:UpdateMotivationOfPlayersWorkers(
            _PlayerID, Config.Reputation or 0, true
        );

        if GUI.GetPlayerID() == _PlayerID then
            Message(XGUIEng.GetStringTableText("sh_menukeep/Message_FestivalLevel" ..FestivalLevel));
            Sound.PlayGUISound(Sounds.OnKlick_Select_pilgrim, 0);
            local x,y,z = Logic.EntityGetPos(GetHeadquarterID(_PlayerID));
            Logic.CreateEffect(GGL_Effects.FXYukiFireworksJoy, x, y, 0);
        end
    end
end

function Stronghold.Building:KeepBuildingTabsGuiTooltip(_PlayerID, _EntityID, _Key)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Headquarters) == 0 then
        return false;
    end
    local Text = "";
    if _Key == "MenuBuildingGeneric/ToBuildingcommandmenu" then
        Text = XGUIEng.GetStringTableText("sh_menuheadquarter/submenu_treasury");
    elseif _Key == "MenuBuildingGeneric/tobuildingsettlersmenu" then
        Text = XGUIEng.GetStringTableText("sh_menuheadquarter/submenu_administration");
    else
        return false;
    end
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

function Stronghold.Building:KeepButtonChangeTax(_PlayerID, _Level)
    if IsPlayer(_PlayerID) then
        SetTaxHeight(_PlayerID, math.min(math.max(_Level +1, 1), 5));
    end
end

function Stronghold.Building:OnKeepSelected(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if not IsPlayer(PlayerID) then
        return;
    end
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Headquarters) == 1 then
        if Logic.IsConstructionComplete(_EntityID) == 1 then
            local Type = Logic.GetEntityType(_EntityID);
            local TypeName = Logic.GetEntityTypeName(Type);
            local IsOutpost = string.find(TypeName or "", "PB_Outpost") ~= nil;
            XGUIEng.ShowWidget("BuildingTabs", (IsOutpost and 0) or 1);
            XGUIEng.ShowWidget("RallyPoint", 1);
            XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
            GUIUpdate_BuySerf();
            GUIUpdate_PlaceRallyPoint();
            local WidgetID = gvStronghold_LastSelectedHQMenu;
            self:KeepChangeBuildingTabsGuiAction(PlayerID, _EntityID, WidgetID);
            -- Upgrade buttons
            XGUIEng.ShowWidget("Upgrade_Headquarter1", 0);
            XGUIEng.ShowWidget("Upgrade_Headquarter2", 0);
            XGUIEng.ShowWidget("Upgrade_Outpost1", 0);
            XGUIEng.ShowWidget("Upgrade_Outpost2", 0);
            if Logic.IsConstructionComplete(_EntityID) == 1 then
                if Type == Entities.PB_Headquarters1 then
                    XGUIEng.ShowWidget("Upgrade_Headquarter1", 1);
                elseif Type == Entities.PB_Headquarters2 then
                    XGUIEng.ShowWidget("Upgrade_Headquarter2", 1);
                elseif Type == Entities.PB_Outpost1 then
                    XGUIEng.ShowWidget("Upgrade_Outpost1", 1);
                elseif Type == Entities.PB_Outpost2 then
                    XGUIEng.ShowWidget("Upgrade_Outpost2", 1);
                end
            end
            GUIUpdate_UpgradeButtons("Upgrade_Outpost1", Technologies.UP1_Outpost);
            GUIUpdate_UpgradeButtons("Upgrade_Outpost2", Technologies.UP2_Outpost);
            -- Tracking
            if IsOutpost then
                GUIUpdate_GlobalTechnologiesButtons("Research_Tracking", Technologies.T_Tracking, Entities.PB_Outpost1);
            end
        else
            XGUIEng.ShowWidget("Headquarter", 0);
            XGUIEng.ShowWidget("Keep", 0);
        end
    else
        gvStronghold_LastSelectedHQMenu = gvGUI_WidgetID.ToBuildingCommandMenu;
    end
end

function Stronghold.Building:GetLastSelectedKeepTab(_PlayerID)
    if IsPlayer(_PlayerID) then
        return gvStronghold_LastSelectedHQMenu or gvGUI_WidgetID.ToBuildingCommandMenu;
    end
    return 0;
end

function Stronghold.Building:KeepChangeBuildingTabsGuiAction(_PlayerID, _EntityID, _WidgetID)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Headquarters) == 0 then
        return false;
    end

    local WidgetID = _WidgetID;
    if not WidgetID then
        WidgetID = gvStronghold_LastSelectedHQMenu;
    end
    local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(_EntityID));
    if TypeName and string.find(TypeName, "PB_Outpost") then
        WidgetID = gvGUI_WidgetID.ToBuildingCommandMenu;
    end

    if WidgetID == gvGUI_WidgetID.ToBuildingCommandMenu then
        self:KeepOnToggleHeadquartersCommands(_PlayerID, _EntityID, _WidgetID);
    elseif WidgetID == gvGUI_WidgetID.ToBuildingSettlersMenu then
        gvStronghold_LastSelectedHQMenu = WidgetID;
        self:KeepOnToggleInfluenceCommands(_PlayerID, _EntityID, _WidgetID);
    end
    return true;
end

function Stronghold.Building:KeepOnToggleHeadquartersCommands(_PlayerID, _EntityID, _WidgetID)
    XGUIEng.HighLightButton("ToBuildingCommandMenu", 0);
    XGUIEng.HighLightButton("ToBuildingSettlersMenu", 1);
    XGUIEng.ShowWidget("Keep", 0);
    XGUIEng.ShowWidget("Headquarter", 1);
    XGUIEng.ShowWidget("WorkerInBuilding", 0);

    XGUIEng.ShowWidget("HQTaxes", 1);
    XGUIEng.ShowAllSubWidgets("HQTaxes", 1);
    XGUIEng.SetWidgetPosition("TaxesAndPayStatistics", 105, 35);
    XGUIEng.SetWidgetPosition("HQTaxes", 143, 5);

    XGUIEng.ShowWidget("Buy_Hero", 0);
    XGUIEng.ShowWidget("HQ_Militia", 1);
    XGUIEng.SetWidgetPosition("HQ_Militia", 35, 0);
    XGUIEng.TransferMaterials("Buy_Hero", "HQ_CallMilitia");
    XGUIEng.TransferMaterials("Buy_Hero", "HQ_BackToWork");

    -- TODO: Proper disable in singleplayer!
    -- local ShowBuyHero = XNetwork.Manager_DoesExist() == 1
    XGUIEng.ShowWidget("HQ_CallMilitia", (GetNobleID(_PlayerID) == 0 and 1) or 0);
    XGUIEng.ShowWidget("HQ_BackToWork", (GetNobleID(_PlayerID) ~= 0 and 1) or 0);
    XGUIEng.ShowWidget("RallyPoint", 1);

    gvStronghold_LastSelectedHQMenu = gvGUI_WidgetID.ToBuildingCommandMenu;
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Building:KeepOnToggleInfluenceCommands(_PlayerID, _EntityID, _WidgetID)
    XGUIEng.HighLightButton("ToBuildingCommandMenu", 1);
    XGUIEng.HighLightButton("ToBuildingSettlersMenu", 0);
    XGUIEng.ShowWidget("KeepFestivals", 0);
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PB_Headquarters1
    or Type == Entities.PB_Headquarters2
    or Type == Entities.PB_Headquarters3 then
        XGUIEng.ShowWidget("Headquarter", 0);
        XGUIEng.ShowWidget("Keep", 1);
        XGUIEng.ShowWidget("Commands_Keep", 1);
        XGUIEng.ShowWidget("KeepFestivals", 1);

        -- This must be called here to update upgrade buttons properly!
        local UpgradeCategory = Logic.GetUpgradeCategoryByBuildingType(Type);
        InterfaceTool_UpdateUpgradeButtons(Type, UpgradeCategory, "Upgrade_Keep");

        local Upgrade = Logic.GetUpgradeLevelForBuilding(_EntityID);
        if Upgrade == 1 then
            GUIUpdate_UpgradeButtons("Upgrade_Keep2", Technologies.UP2_Headquarter);
        elseif Upgrade == 0 then
            GUIUpdate_UpgradeButtons("Upgrade_Keep1", Technologies.UP1_Headquarter);
        end

        XGUIEng.ShowWidget("RallyPoint", 0);
        GUIUpdate_PlaceRallyPoint();
    end
end

function Stronghold.Building:PrintKeepTaxButtonsTooltip(_PlayerID, _EntityID, _Key)
    local Type = Logic.GetEntityType(_EntityID);
    if  Type ~= Entities.PB_Headquarters1
    and Type ~= Entities.PB_Headquarters2
    and Type ~= Entities.PB_Headquarters3
    and Type ~= Entities.PB_Outpost1
    and Type ~= Entities.PB_Outpost2
    and Type ~= Entities.PB_Outpost3 then
        return false;
    end

    local Level = -1;
    if _Key == "sh_menuheadquarter/SetVeryLowTaxes" then
        Level = 1;
    elseif _Key == "sh_menuheadquarter/SetLowTaxes" then
        Level = 2;
    elseif _Key == "sh_menuheadquarter/SetNormalTaxes" then
        Level = 3;
    elseif _Key == "sh_menuheadquarter/SetHighTaxes" then
        Level = 4;
    elseif _Key == "sh_menuheadquarter/SetVeryHighTaxes" then
        Level = 5;
    else
        return false;
    end

    local StringText = XGUIEng.GetStringTableText(_Key);
    local Effects = Stronghold.Economy.Config.Income.TaxEffect[Level];

    local Seperate = false;
    local EffectDesc = " @cr " ..XGUIEng.GetStringTableText("sh_text/TooltipEffect");
    local EffectText = "";
    local OngoingText = XGUIEng.GetStringTableText("sh_text/TooltipEffectOngoing");
    if Effects.Reputation ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Reputation");
        local Operator = (Effects.Reputation >= 0 and "+") or "";
        EffectText = EffectText.. Operator ..Effects.Reputation.. " " ..Unit.. " " ..OngoingText;
        Seperate = true;
    end
    if Effects.Honor ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Silver");
        local Operator = (Effects.Honor >= 0 and "+") or "";
        local Seperator = (Seperate and ", ") or "";
        EffectText = EffectText..Seperator.. Operator ..Effects.Honor.. " " ..Unit.. " " ..OngoingText;
    end
    EffectText = (EffectText ~= "" and EffectDesc..EffectText) or EffectText;

    local ButtonText = StringText .. EffectText;
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, ButtonText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

function Stronghold.Building:PrintKeepFestivalButtonsTooltip(_PlayerID, _EntityID, _Key)
    local Type = Logic.GetEntityType(_EntityID);
    if  Type ~= Entities.PB_Headquarters1
    and Type ~= Entities.PB_Headquarters2
    and Type ~= Entities.PB_Headquarters3 then
        return false;
    end

    local Level = -1;
    if _Key == "sh_menukeep/SetFestivalLevel0" then
        Level = 0;
    elseif _Key == "sh_menukeep/SetFestivalLevel1" then
        Level = 1;
    elseif _Key == "sh_menukeep/SetFestivalLevel2" then
        Level = 2;
    elseif _Key == "sh_menukeep/SetFestivalLevel3" then
        Level = 3;
    elseif _Key == "sh_menukeep/SetFestivalLevel4" then
        Level = 4;
    elseif _Key == "sh_menukeep/SetFestivalLevel5" then
        Level = 5;
    elseif _Key == "sh_menukeep/SetFestivalLevel6" then
        Level = 6;
    else
        return false;
    end

    local Button = self.Config.Civil.FestivalButtons[Level];
    local StringText = XGUIEng.GetStringTableText(_Key);
    local CostText = FormatCostString(_PlayerID, GetFestivalCosts(_PlayerID, Level));

    local Seperate = false;
    local Effects = Stronghold.Economy.Config.Income.Festival[Level];
    local EffectDesc = " @cr " ..XGUIEng.GetStringTableText("sh_text/TooltipEffect");
    local EffectText = "";
    local InstantlyText = XGUIEng.GetStringTableText("sh_text/TooltipEffectInstantly");
    if Effects.Reputation ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Reputation");
        local Operator = (Effects.Reputation >= 0 and "+") or "";
        EffectText = EffectText.. Operator ..Effects.Reputation.. " " ..Unit.. " " ..InstantlyText;
        Seperate = true;
    end
    if Effects.Honor ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Silver");
        local Operator = (Effects.Honor >= 0 and "+") or "";
        local Seperator = (Seperate and ", ") or "";
        EffectText = EffectText..Seperator.. Operator ..Effects.Honor.. " " ..Unit.. " " ..InstantlyText;
    end
    EffectText = (EffectText ~= "" and EffectDesc..EffectText) or EffectText;

    local ButtonText = StringText .. EffectText;
    if XGUIEng.IsButtonDisabled(Button) == 1 then
        ButtonText = ButtonText.. " @cr " .. XGUIEng.GetStringTableText(_Key.. "_disabled");
    end

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, ButtonText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

GUIAction_KeepFestival = function(_Level)
    local BuildingID = GUI.GetSelectedEntity();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(BuildingID);
    if GuiPlayer == PlayerID then
        Syncer.InvokeEvent(
            Stronghold.Building.NetworkCall,
            Stronghold.Building.SyncEvents.ChangeFestival,
            _Level
        );
    end
end

GUIUpdate_KeepFestivalButtons = function()
    local BuildingID = GUI.GetSelectedEntity();
    local PlayerID = Logic.EntityGetPlayer(BuildingID);
    local Level = GetFestivalLevel(PlayerID);
    XGUIEng.UnHighLightGroup("InGame", "festivalgroup");
    local WidgetID = Stronghold.Building.Config.Civil.FestivalButtons[Level];
	XGUIEng.HighLightButton(WidgetID, 1);

    local Level3 = GetBuildingsOfType(PlayerID, Entities.PB_Headquarters3, true);
    local Level2 = GetBuildingsOfType(PlayerID, Entities.PB_Headquarters2, true);
    local Level1 = GetBuildingsOfType(PlayerID, Entities.PB_Headquarters1, true);

    XGUIEng.DisableButton("KeepFestivalLevel0", (Level1[1]+Level2[1]+Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("KeepFestivalLevel1", (Level1[1]+Level2[1]+Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("KeepFestivalLevel2", (Level1[1]+Level2[1]+Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("KeepFestivalLevel3", (Level2[1]+Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("KeepFestivalLevel4", (Level2[1]+Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("KeepFestivalLevel5", (Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("KeepFestivalLevel6", (Level3[1] == 0 and 1) or 0);
end

function GUIUpdate_InfluenceProgress()
    local WidgetID = XGUIEng.GetCurrentWidgetID();
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Headquarters) == 0 then
        return false;
    end
    local ValueMax = GetPlayerMaxInfluencePoints(PlayerID);
    local Value = Stronghold.Economy:GetPlayerInfluencePoints(PlayerID);
    XGUIEng.SetProgressBarValues(WidgetID, Value, ValueMax);
end

-- -------------------------------------------------------------------------- --
-- Church

function Stronghold.Building:ControlChurchService(_PlayerID)
    if Logic.GetPlayerPaydayTimeLeft(_PlayerID) < 2000 then
        return;
    end

    local CurrentFaith = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Faith);
    local RequiredFaith = Logic.GetBlessCostByBlessCategory(BlessCategories.Canonisation);

    local SermonLevel = GetSermonLevel(_PlayerID);
    if SermonLevel == 0 then
        Logic.SubFromPlayersGlobalResource(_PlayerID, ResourceType.Faith, CurrentFaith);
        return;
    end

    local Level1 = GetBuildingsOfType(_PlayerID, Entities.PB_Monastery1, true);
    local Level2 = GetBuildingsOfType(_PlayerID, Entities.PB_Monastery2, true);
    local Level3 = GetBuildingsOfType(_PlayerID, Entities.PB_Monastery3, true);
    if Level3[1] == 0 and SermonLevel > 4 then
        SetSermonLevel(_PlayerID, 4);
        return;
    end
    if Level2[1]+Level3[1] == 0 and SermonLevel > 2 then
        SetSermonLevel(_PlayerID, 2);
        return;
    end
    if Level1[1]+Level2[1]+Level3[1] == 0 and SermonLevel > 0 then
        SetSermonLevel(_PlayerID, 0);
        return;
    end

    local Costs = GetSermonCosts(_PlayerID, SermonLevel);
    local Config = Stronghold.Economy.Config.Income.Sermon[SermonLevel];
    if HasEnoughResources(_PlayerID, Costs) and CurrentFaith >= RequiredFaith then
        Logic.SubFromPlayersGlobalResource(_PlayerID, ResourceType.Faith, CurrentFaith);
        RemoveResourcesFromPlayer(_PlayerID, Costs);
        AddReputation(_PlayerID, Config.Reputation or 0);
        AddHonor(_PlayerID, Config.Honor or 0);
        Stronghold.Attraction:UpdateMotivationOfPlayersWorkers(
            _PlayerID, Config.Reputation or 0, true
        );

        if GUI.GetPlayerID() == _PlayerID then
            Message(XGUIEng.GetStringTableText("sh_menucathedral/Message_ServiceLevel" ..SermonLevel));
            Sound.PlayGUISound(Sounds.Buildings_Monastery, 0);
            Sound.PlayFeedbackSound(Sounds.VoicesMentor_INFO_SettlersBlessed_rnd_01, 100);
        end
    end
end

function Stronghold.Building:OnCathedralSelected(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    XGUIEng.ShowWidget("CathedralService", 0);
    if Type == Entities.PB_Monastery1
    or Type == Entities.PB_Monastery2
    or Type == Entities.PB_Monastery3 then
        XGUIEng.ShowWidget("Monastery", 0);
        XGUIEng.ShowWidget("Cathedral", 1);
        XGUIEng.ShowWidget("Commands_Cathedral", 1);
        XGUIEng.ShowWidget("CathedralService", 1);

        -- This must be called here to update upgrade buttons properly!
        local UpgradeCategory = Logic.GetUpgradeCategoryByBuildingType(Type);
        InterfaceTool_UpdateUpgradeButtons(Type, UpgradeCategory, "Upgrade_Cathedral");

        local Upgrade = Logic.GetUpgradeLevelForBuilding(_EntityID);
        if Upgrade == 1 then
            GUIUpdate_UpgradeButtons("Upgrade_Cathedral2", Technologies.UP2_Monastery);
        elseif Upgrade == 0 then
            GUIUpdate_UpgradeButtons("Upgrade_Cathedral1", Technologies.UP1_Monastery);
        end
    end
end

function Stronghold.Building:PrintCathedralSermonButtonsTooltip(_PlayerID, _EntityID, _Key)
    local Type = Logic.GetEntityType(_EntityID);
    if  Type ~= Entities.PB_Monastery1
    and Type ~= Entities.PB_Monastery2
    and Type ~= Entities.PB_Monastery3 then
        return false;
    end

    local Level = -1;
    if _Key == "sh_menucathedral/SetServiceLevel0" then
        Level = 0;
    elseif _Key == "sh_menucathedral/SetServiceLevel1" then
        Level = 1;
    elseif _Key == "sh_menucathedral/SetServiceLevel2" then
        Level = 2;
    elseif _Key == "sh_menucathedral/SetServiceLevel3" then
        Level = 3;
    elseif _Key == "sh_menucathedral/SetServiceLevel4" then
        Level = 4;
    elseif _Key == "sh_menucathedral/SetServiceLevel5" then
        Level = 5;
    elseif _Key == "sh_menucathedral/SetServiceLevel6" then
        Level = 6;
    else
        return false;
    end

    local Button = self.Config.Civil.SermonButtons[Level];
    local StringText = XGUIEng.GetStringTableText(_Key);
    local CostText = FormatCostString(_PlayerID, GetSermonCosts(_PlayerID, Level));

    local Seperate = false;
    local Effects = Stronghold.Economy.Config.Income.Sermon[Level];
    local EffectDesc = " @cr " ..XGUIEng.GetStringTableText("sh_text/TooltipEffect");
    local EffectText = "";
    local InstantlyText = XGUIEng.GetStringTableText("sh_text/TooltipEffectOngoing");
    if Effects.Reputation ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Reputation");
        local Operator = (Effects.Reputation >= 0 and "+") or "";
        EffectText = EffectText .. Operator .. Effects.Reputation.. " " .. Unit .. " " .. InstantlyText;
        Seperate = true;
    end
    if Effects.Honor ~= 0 then
        local Unit = XGUIEng.GetStringTableText("sh_text/Silver");
        local Operator = (Effects.Honor >= 0 and "+") or "";
        local Seperator = (Seperate and ", ") or "";
        EffectText = EffectText..Seperator.. Operator .. Effects.Honor .. " " .. Unit .. " " .. InstantlyText;
    end
    EffectText = (EffectText ~= "" and EffectDesc..EffectText) or EffectText;

    local ButtonText = StringText .. EffectText;
    if XGUIEng.IsButtonDisabled(Button) == 1 then
        ButtonText = ButtonText.. " @cr " .. XGUIEng.GetStringTableText(_Key.. "_disabled");
    end

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, ButtonText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

GUIAction_SetChurchService = function(_Level)
    local BuildingID = GUI.GetSelectedEntity();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(BuildingID);
    if GuiPlayer == PlayerID then
        Syncer.InvokeEvent(
            Stronghold.Building.NetworkCall,
            Stronghold.Building.SyncEvents.ChangeSermon,
            _Level
        );
    end
end

GUIUpdate_ChurchServiceButtons = function()
    local BuildingID = GUI.GetSelectedEntity();
    local PlayerID = Logic.EntityGetPlayer(BuildingID);
    local Level = GetSermonLevel(PlayerID);
    XGUIEng.UnHighLightGroup("InGame", "sermongroup");
    local WidgetID = Stronghold.Building.Config.Civil.SermonButtons[Level];
	XGUIEng.HighLightButton(WidgetID, 1);

    local Level3 = GetBuildingsOfType(PlayerID, Entities.PB_Monastery3, true);
    local Level2 = GetBuildingsOfType(PlayerID, Entities.PB_Monastery2, true);
    local Level1 = GetBuildingsOfType(PlayerID, Entities.PB_Monastery1, true);

    XGUIEng.DisableButton("CathedralServiceLevel0", (Level1[1]+Level2[1]+Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("CathedralServiceLevel1", (Level1[1]+Level2[1]+Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("CathedralServiceLevel2", (Level1[1]+Level2[1]+Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("CathedralServiceLevel3", (Level2[1]+Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("CathedralServiceLevel4", (Level2[1]+Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("CathedralServiceLevel5", (Level3[1] == 0 and 1) or 0);
    XGUIEng.DisableButton("CathedralServiceLevel6", (Level3[1] == 0 and 1) or 0);

    local Upgrade = Logic.GetUpgradeLevelForBuilding(BuildingID);
    if Upgrade == 1 then
        XGUIEng.ShowWidget("Upgrade_Monastery2", 1);
    end
    if Upgrade == 0 then
        XGUIEng.ShowWidget("Upgrade_Monastery1", 1);
    end
end

-- -------------------------------------------------------------------------- --
-- Rally Points

function Stronghold.Building:OverrideShiftRightClick()
    GUIAction_PlaceRallyPoint = function()
        local PlayerID = GUI.GetPlayerID();
        Stronghold.Building:ActivateRallyPointSelection(PlayerID);
        XGUIEng.HighLightButton("ActivateSetRallyPoint", 1);
    end

    GUITooltip_PlaceRallyPoint = function()
        local ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText("KeyBindings/RallyPoint") .. "]";
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
        XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText,"sh_menuheadquarter/rallypoint");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
    end

    GUIUpdate_PlaceRallyPoint = function()
        local GuiPlayer = GUI.GetPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        local PlayerID = Logic.EntityGetPlayer(EntityID);

        -- Control visibility
        local Show = 1;
        if not EntityID or GuiPlayer == 17
        or Logic.IsConstructionComplete(EntityID) == 0
        or not Stronghold.Building:CanBuildingHaveRallyPoint(EntityID) then
            Show = 0;
        end
        -- Control highlight
        local Highlight = 1;
        if Show == 1 and not Stronghold.Building:IsRallyPointSelection(PlayerID) then
            Highlight = 0;
        end

        XGUIEng.ShowWidget("ActivateSetRallyPoint", Show);
        XGUIEng.HighLightButton("ActivateSetRallyPoint", Highlight);
    end
end

function Stronghold.Building:OnRallyPointHolderDestroyed(_PlayerID, _EntityID)
    if IsPlayer(_PlayerID) then
        local ScriptName = CreateNameForEntity(_EntityID);
        if self.Data[_PlayerID].RallyPoint[ScriptName] and not IsExisting(ScriptName) then
            DestroyEntity(self.Data[_PlayerID].RallyPoint[ScriptName]);
            self.Data[_PlayerID].RallyPoint[ScriptName] = nil;
        end
    end
end

function Stronghold.Building:OnUnitCreated(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if IsPlayer(PlayerID) then
        if Logic.IsSettler(_EntityID) == 1 then
            local BuildingID;
            if Logic.IsEntityInCategory(_EntityID, EntityCategories.Serf) == 1 then
                local x,y,z = Logic.EntityGetPos(_EntityID);
                local _,Outpost1ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Outpost1, x, y, 800, 1);
                local _,Outpost2ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Outpost2, x, y, 800, 1);
                local _,Outpost3ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Outpost3, x, y, 800, 1);
                local CastleID = GetHeadquarterID(PlayerID);
                BuildingID = Outpost1ID or Outpost2ID or Outpost3ID or CastleID or 0;
            elseif Logic.IsEntityInCategory(_EntityID, EntityCategories.Cannon) == 1 then
                local x,y,z = Logic.EntityGetPos(_EntityID);
                local _,Foundry1ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Foundry1, x, y, 800, 1);
                local _,Foundry2ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Foundry2, x, y, 800, 1);
                BuildingID = Foundry1ID or Foundry2ID or 0;
            elseif Logic.IsEntityInCategory(_EntityID, EntityCategories.CavalryHeavy) == 1
            or Logic.IsEntityInCategory(_EntityID, EntityCategories.CavalryLight) == 1 then
                local x,y,z = Logic.EntityGetPos(_EntityID);
                local _,Foundry1ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Stable1, x, y, 800, 1);
                local _,Foundry2ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Stable2, x, y, 800, 1);
                BuildingID = Foundry1ID or Foundry2ID or 0;
            elseif Logic.IsEntityInCategory(_EntityID, EntityCategories.Sword) == 1
            or Logic.IsEntityInCategory(_EntityID, EntityCategories.Spear) == 1 then
                local x,y,z = Logic.EntityGetPos(_EntityID);
                local _,Foundry1ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Barracks1, x, y, 800, 1);
                local _,Foundry2ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Barracks2, x, y, 800, 1);
                BuildingID = Foundry1ID or Foundry2ID or 0;
            elseif Logic.IsEntityInCategory(_EntityID, EntityCategories.Bow) == 1
            or Logic.IsEntityInCategory(_EntityID, EntityCategories.Rifle) == 1 then
                local x,y,z = Logic.EntityGetPos(_EntityID);
                local _,Foundry1ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Archery1, x, y, 900, 1);
                local _,Foundry2ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Archery2, x, y, 900, 1);
                BuildingID = Foundry1ID or Foundry2ID or 0;
            elseif Logic.IsEntityInCategory(_EntityID, EntityCategories.Scout) == 1
            or Logic.IsEntityInCategory(_EntityID, EntityCategories.Thief) == 1 then
                local x,y,z = Logic.EntityGetPos(_EntityID);
                local _,Foundry1ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Tavern1, x, y, 600, 1);
                local _,Foundry2ID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Tavern2, x, y, 600, 1);
                BuildingID = Foundry1ID or Foundry2ID or 0;
            end
            if BuildingID and BuildingID ~= 0 then
                table.insert(self.Data[PlayerID].UnitMover, {_EntityID, BuildingID});
            end
        end
    end
end

function Stronghold.Building:UnitToRallyPointController(_PlayerID)
    if IsPlayer(_PlayerID) then
        for i= table.getn(self.Data[_PlayerID].UnitMover), 1, -1 do
            local EntityID = self.Data[_PlayerID].UnitMover[i][1];
            local RecruiterID = self.Data[_PlayerID].UnitMover[i][2];
            if not IsExisting(RecruiterID) or not IsExisting(EntityID) then
                return;
            end
            local Task = Logic.GetCurrentTaskList(EntityID);
            if not Task or (string.find(Task,"IDLE") or string.find(Task,"BATTLE")) then
                local ScriptName = Logic.GetEntityName(RecruiterID);
                self:MoveToRallyPoint(ScriptName, EntityID);
                table.remove(self.Data[_PlayerID].UnitMover, i);
            end
        end
    end
end

function Stronghold.Building:OnRallyPointHolderSelected(_GuiPlayerID, _EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local ScriptName = Logic.GetEntityName(_EntityID);

    -- Cancel rally point on selection changed
    -- (Only for the player)
    if IsPlayer(PlayerID) then
        if Logic.IsConstructionComplete(_EntityID) == 0
        or not self:CanBuildingHaveRallyPoint(_EntityID)
        or not IsExisting(_EntityID) then
            self:CancelRallyPointSelection(PlayerID);
        end
    end

    -- Hide all rally points for viewer
    local ViewerPlayer = (PlayerID == 0 and _GuiPlayerID) or PlayerID;
    if ViewerPlayer == 17 then
        for CurrentPlayerID = 1, GetMaxAmountOfPlayer() do
            if IsPlayer(CurrentPlayerID) then
                for _, HolderID in pairs(self.Data[CurrentPlayerID].RallyPoint) do
                    if IsExisting(HolderID) then
                        SVLib.SetInvisibility(HolderID, true);
                        Logic.SetEntityExplorationRange(HolderID, 0);
                    end
                end
            end
        end
    else
        if IsPlayer(ViewerPlayer) then
            for _,HolderID in pairs(self.Data[ViewerPlayer].RallyPoint) do
                if IsExisting(HolderID) then
                    SVLib.SetInvisibility(HolderID, true);
                    Logic.SetEntityExplorationRange(HolderID, 0);
                end
            end
        end
    end

    -- Show rally point for owner
    if IsPlayer(PlayerID) then
        if _EntityID and IsExisting(_EntityID) then
            if self.Data[PlayerID].RallyPoint[ScriptName] then
                local ID = GetID(self.Data[PlayerID].RallyPoint[ScriptName]);
                local Invisible = PlayerID ~= _GuiPlayerID and _GuiPlayerID ~= 17;
                SVLib.SetInvisibility(ID, Invisible);
                Logic.SetEntityExplorationRange(ID, 1);
            end
        end
    end
end

function Stronghold.Building:MoveToRallyPoint(_Building, _EntityID)
    local Position = self:GetRallyPointPosition(_Building);
    if Position then
        -- Make serf extract nearby resources
        if Logic.IsEntityInCategory(_EntityID, EntityCategories.Serf) == 1 then
            self:CommandSerfToExtractCloseResource(_EntityID, Position.X, Position.Y, 800);
        -- Just move scouts and thieves
        elseif Logic.IsEntityInCategory(_EntityID, EntityCategories.Scout) == 1
        or     Logic.IsEntityInCategory(_EntityID, EntityCategories.Thief) == 1 then
            Logic.MoveSettler(_EntityID, Position.X, Position.Y, -1);
        -- Move soldiers with attack walk
        else
            Logic.GroupAttackMove(_EntityID, Position.X, Position.Y, -1);
        end
    end
end

function Stronghold.Building:GetRallyPointPosition(_Building)
    local PlayerID = Logic.EntityGetPlayer(GetID(_Building));
    local ScriptName = (type(_Building) == "number" and Logic.GetEntityName(_Building)) or _Building;
    if self.Data[PlayerID] and self.Data[PlayerID].RallyPoint[ScriptName] then
        return GetPosition(self.Data[PlayerID].RallyPoint[ScriptName]);
    end
end

function Stronghold.Building:CommandSerfToExtractCloseResource(_SerfID, _x, _y, _Area)
    -- Resource entities
    local Resources = {Logic.GetEntitiesInArea(0, _x, _y, _Area, 1, 16)};
    if Resources[1] > 0 then
        local x,y,z = Logic.EntityGetPos(Resources[2]);
        local Type = Logic.GetResourceDoodadGoodType(Resources[2]);
        local Amount = Logic.GetResourceDoodadGoodAmount(Resources[2]);
        if Amount > 0 then
            SendEvent.SerfExtractResource(_SerfID, Type, x, y);
            return;
        end
    end
    -- Trees
    local Trees = GetTreeAtPosition(_x, _y, _Area, 1);
    if Trees[1] then
        local x,y,z = Logic.EntityGetPos(Trees[1]);
        SendEvent.SerfExtractResource(_SerfID, ResourceType.WoodRaw, x, y);
        return;
    end
    -- Just move
    Logic.MoveSettler(_SerfID, _x, _y, -1);
end

function Stronghold.Building:PlaceRallyPoint(_PlayerID, _EntityID, _X, _Y, _Initial)
    if IsPlayer(_PlayerID) then
        -- Update GUI
        if GUI.GetPlayerID() == _PlayerID then
            GUIUpdate_PlaceRallyPoint();
        end
        -- Check player
        if Logic.EntityGetPlayer(_EntityID) ~= _PlayerID then
            return;
        end
        -- Create position entity
        local ScriptName = CreateNameForEntity(_EntityID);
        local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, _X, _Y, 0, _PlayerID);
        -- Check connectivity
        if not ArePositionsConnected(ID, _EntityID) then
            DestroyEntity(ID);
            return;
        end
        -- Set visibility
        SVLib.SetInvisibility(ID, GUI.GetPlayerID() ~= _PlayerID);
        Logic.SetModelAndAnimSet(ID, Models.Banners_XB_LargeFull);
        Logic.SetEntityExplorationRange(ID, 1);
        -- Save new entity
        DestroyEntity(self.Data[_PlayerID].RallyPoint[ScriptName]);
        self.Data[_PlayerID].RallyPoint[ScriptName] = ID;

        GameCallback_SH_Logic_RallyPointPlaced(_PlayerID, _EntityID, _X, _Y, _Initial);
    end
end

function Stronghold.Building:ActivateRallyPointSelection(_PlayerID)
    if IsPlayer(_PlayerID) then
        if not self.Data[_PlayerID].RallyPoint.IsSelecting then
            self.Data[_PlayerID].RallyPoint.IsSelecting = true;
            GUI.ActivatePatrolCommandState();
            self.Data[_PlayerID].RallyPoint.JobID = Job.Turn(function(_PlayerID)
                return Stronghold.Building:ControlRallyPointSelection(_PlayerID);
            end, _PlayerID);
        end
    end
end

function Stronghold.Building:CancelRallyPointSelection(_PlayerID)
    if IsPlayer(_PlayerID) and GUI.GetPlayerID() == _PlayerID then
        if self.Data[_PlayerID].RallyPoint.IsSelecting then
            self.Data[_PlayerID].RallyPoint.IsSelecting = false;
            GUI.CancelState();
            EndJob(self.Data[_PlayerID].RallyPoint.JobID);
            self.Data[_PlayerID].RallyPoint.JobID = nil;
        end
    end
end

function Stronghold.Building:SendPlaceRallyPointEvent(_X, _Y, _Initial)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if IsPlayer(PlayerID) then
        if self:CanBuildingHaveRallyPoint(EntityID) then
            local x,y = GUI.Debug_GetMapPositionUnderMouse();
            if x ~= -1 and y ~= -1 then
                Syncer.InvokeEvent(
                    Stronghold.Building.NetworkCall,
                    Stronghold.Building.SyncEvents.RallyPoint,
                    EntityID,
                    _X or x,
                    _Y or y,
                    _Initial == true
                );
                return true;
            end
        end
    end
    return false;
end

function Stronghold.Building:ControlRallyPointSelection(_PlayerID)
    if not IsPlayer(_PlayerID) or GUI.GetPlayerID() ~= _PlayerID then
        return true;
    end
    if GUI.GetCurrentStateID() ~= 9 then
        if self.Data[_PlayerID].RallyPoint.IgnoreCancel then
            self.Data[_PlayerID].RallyPoint.IgnoreCancel = false;
            GUI.ActivatePatrolCommandState();
        else
            self.Data[_PlayerID].RallyPoint.IgnoreCancel = false;
            self:CancelRallyPointSelection(_PlayerID);
            self:SendPlaceRallyPointEvent();
            return true;
        end
    end
    return false;
end

function Stronghold.Building:CanBuildingHaveRallyPoint(_Building)
    local ID = GetID(_Building);
    local Type = Logic.GetEntityType(ID);
    if Type == Entities.PB_Archery1 or Type == Entities.PB_Archery2
    or Type == Entities.PB_Barracks1 or Type == Entities.PB_Barracks2
    or Type == Entities.PB_Stable1 or Type == Entities.PB_Stable2
    or Type == Entities.PB_Foundry1 or Type == Entities.PB_Foundry2
    or Type == Entities.PB_Tavern1 or Type == Entities.PB_Tavern2
    or Type == Entities.PB_Headquarters1 or Type == Entities.PB_Headquarters2
    or Type == Entities.PB_Headquarters3
    or Type == Entities.PB_Outpost1 or Type == Entities.PB_Outpost2
    or Type == Entities.PB_Outpost3 then
        return true;
    end
    return false;
end

function Stronghold.Building:IsRallyPointSelection(_PlayerID)
    if IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].RallyPoint.IsSelecting;
    end
    return false;
end

function Stronghold.Building:SetIgnoreRallyPointSelectionCancel(_PlayerID)
    if Logic.GetTime() > 1 then
        if IsPlayer(_PlayerID) then
            if  self.Data[_PlayerID].RallyPoint.IsSelecting
            and GUI.GetPlayerID() == _PlayerID
            and GUI.GetSelectedEntity() ~= nil
            and IsPlayer(_PlayerID) then
                self.Data[_PlayerID].RallyPoint.IgnoreCancel = true;
            end
            GUIUpdate_PlaceRallyPoint();
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Foundry

function Stronghold.Building:FoundryCannonAutoRepair(_PlayerID)
    if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_AutoRepair) == 1 then
        local Cannons = GetCannonsOfType(_PlayerID, 0);
        for i= 2, Cannons[1] +1 do
            local Position = GetPosition(Cannons[i]);
            local MaxHealth = Logic.GetEntityMaxHealth(Cannons[i]);
            local Health = Logic.GetEntityHealth(Cannons[i]);
            if Health > 0 and Health < MaxHealth then
                if AreEntitiesInArea(_PlayerID, Entities.PB_Foundry1, Position, 2500, 1)
                or AreEntitiesInArea(_PlayerID, Entities.PB_Foundry2, Position, 2500, 1) then
                    local Healing = math.min(MaxHealth - Health, 4);
                    Logic.CreateEffect(GGL_Effects.FXSalimHeal, Position.X, Position.Y, 0);
                    Logic.HealEntity(Cannons[i], Healing);
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Keybindings

function Stronghold.Building:InitalizeBuyUnitKeybindings()
    Stronghold_KeyBindings_BuyUnit = function(_Key, _PlayerID, _EntityID)
        if _PlayerID == 17 or gvInterfaceCinematicFlag == 1 then
            return;
        end
        Sound.PlayGUISound(Sounds.klick_rnd_1, 0);
        Stronghold.Building:ExecuteBuyUnitKeybindForBarracks(_Key, _PlayerID, _EntityID);
        Stronghold.Building:ExecuteBuyUnitKeybindForArchery(_Key, _PlayerID, _EntityID);
        Stronghold.Building:ExecuteBuyUnitKeybindForStable(_Key, _PlayerID, _EntityID);
        Stronghold.Building:ExecuteBuyUnitKeybindForFoundry(_Key, _PlayerID, _EntityID);
        Stronghold.Building:ExecuteBuyUnitKeybindForTavern(_Key, _PlayerID, _EntityID);
        Stronghold.Building:ExecuteBuyUnitKeybindForMercenary(_Key, _PlayerID, _EntityID);
    end

    for Index, Key in ipairs(self.Config.RecuitIndexRecuitShortcut) do
        Input.KeyBindDown(Keys[Key], "Stronghold_KeyBindings_BuyUnit(" ..Index.. ", GUI.GetPlayerID(), GUI.GetSelectedEntity())", 2);
    end
end

function Stronghold.Building:ExecuteBuyUnitKeybindForBarracks(_Key, _PlayerID, _EntityID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Type = Logic.GetEntityType(_EntityID);
        if _Key <= 8 and (Type == Entities.PB_Barracks1 or Type == Entities.PB_Barracks2) then
            if  Logic.IsConstructionComplete(_EntityID) == 1
            and not IsBuildingBeingUpgraded(_EntityID) then
                GUIAction_BuyMeleeUnit(_Key);
            end
        end
    end
end

function Stronghold.Building:ExecuteBuyUnitKeybindForArchery(_Key, _PlayerID, _EntityID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Type = Logic.GetEntityType(_EntityID);
        if _Key <= 8 and (Type == Entities.PB_Archery1 or Type == Entities.PB_Archery2) then
            if  Logic.IsConstructionComplete(_EntityID) == 1
            and not IsBuildingBeingUpgraded(_EntityID) then
                GUIAction_BuyRangedUnit(_Key);
            end
        end
    end
end

function Stronghold.Building:ExecuteBuyUnitKeybindForStable(_Key, _PlayerID, _EntityID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Type = Logic.GetEntityType(_EntityID);
        if _Key <= 8 and (Type == Entities.PB_Stable1 or Type == Entities.PB_Stable2) then
            if  Logic.IsConstructionComplete(_EntityID) == 1
            and not IsBuildingBeingUpgraded(_EntityID) then
                GUIAction_BuyCavalryUnit(_Key);
            end
        end
    end
end

function Stronghold.Building:ExecuteBuyUnitKeybindForFoundry(_Key, _PlayerID, _EntityID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Type = Logic.GetEntityType(_EntityID);
        if _Key <= 8 and (Type == Entities.PB_Foundry1 or Type == Entities.PB_Foundry2) then
            if  Logic.IsConstructionComplete(_EntityID) == 1
            and not IsBuildingBeingUpgraded(_EntityID) then
                GUIAction_BuyCannonUnit(_Key);
            end
        end
    end
end

function Stronghold.Building:ExecuteBuyUnitKeybindForTavern(_Key, _PlayerID, _EntityID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Type = Logic.GetEntityType(_EntityID);
        if _Key <= 2 and (Type == Entities.PB_Tavern1 or Type == Entities.PB_Tavern2) then
            if  Logic.IsConstructionComplete(_EntityID) == 1
            and not IsBuildingBeingUpgraded(_EntityID) then
                GUIAction_BuyTavernUnit(_Key);
            end
        end
    end
end

function Stronghold.Building:ExecuteBuyUnitKeybindForMercenary(_Key, _PlayerID, _EntityID)
    Stronghold.Mercenary:ExecuteBuyUnitKeybindForMercenary(_Key, _PlayerID, _EntityID);
end

-- -------------------------------------------------------------------------- --
-- Serf

function Stronghold.Building:OnSelectSerf(_EntityID)
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local EntityType = Logic.GetEntityType(_EntityID);
    if PlayerID == GuiPlayer and EntityType == Entities.PU_Serf then
        if gvStronghold_LastSelectedEntity ~= _EntityID then
            gvStronghold_LastSelectedSerfMenu = gvGUI_WidgetID.SerfConstructionMenu;
        end

        XGUIEng.ShowAllSubWidgets(gvGUI_WidgetID.SerfMenus, 0);
        XGUIEng.UnHighLightGroup(gvGUI_WidgetID.InGame, "BuildingMenuGroup");
        if gvStronghold_LastSelectedSerfMenu == gvGUI_WidgetID.SerfConstructionMenu then
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfMilitaryMenu, 1);
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfBeatificationMenu, 1);
        end
        if gvStronghold_LastSelectedSerfMenu == gvGUI_WidgetID.SerfMilitaryMenu then
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfBeatificationMenu, 1);
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfConstructionMenu, 1);
        end
        if gvStronghold_LastSelectedSerfMenu == gvGUI_WidgetID.SerfBeautificationMenu then
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfConstructionMenu, 1);
            XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfMilitaryMenu, 1);
        end
        XGUIEng.ShowWidget(gvStronghold_LastSelectedSerfMenu, 1);
        XGUIEng.DoManualButtonUpdate(gvGUI_WidgetID.InGame);
    end
end

-- -------------------------------------------------------------------------- --
-- Turrets

function Stronghold.Building:InitalizeTurretsForExistingBuildings()
    for PlayerID = 1, GetMaxPlayers() do
        local Buildings = GetPlayerEntities(PlayerID, 0);
        for i= 1, table.getn(Buildings) do
            self:CreateTurretsForBuilding(Buildings[i]);
        end
    end
end

function Stronghold.Building:CreateTurretsForBuilding(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if self.Config.Turrets[Type] then
        if not self.Data.Turrets[_EntityID] then
            self.Data.Turrets[_EntityID] = {};
            for k,v in pairs(self.Config.Turrets[Type]) do
                local Position = GetCirclePosition(_EntityID, v[2], v[3]);
                local TurretID = Logic.CreateEntity(v[1], Position.X, Position.Y, 0, PlayerID);
                SVLib.SetInvisibility(TurretID, true);
                MakeInvulnerable(TurretID);
                table.insert(self.Data.Turrets[_EntityID], TurretID);
            end
        end
    end
end

function Stronghold.Building:DestroyTurretsOfBuilding(_EntityID)
    if self.Data.Turrets[_EntityID] then
        for i= table.getn(self.Data.Turrets[_EntityID]), 1, -1 do
            DestroyEntity(self.Data.Turrets[_EntityID][i]);
        end
    end
end

function Stronghold.Building:UpdateTurretsOfBuilding()
    for Building, TurretList in pairs(self.Data.Turrets) do
        if not IsExisting(Building) then
            for j= table.getn(TurretList), 1, -1 do
                DestroyEntity(TurretList[j]);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Weather Change

function Stronghold.Building:OverwriteWeatherTowerButtons()
    self.Orig_GUIAction_ChangeWeather = GUIAction_ChangeWeather;
    GUIAction_ChangeWeather = function(_StateID)
        Stronghold.Building:ChangeWeatherAction(_StateID);
    end

    self.Orig_GUITooltip_ResearchTechnologies = GUITooltip_ResearchTechnologies;
    GUITooltip_ResearchTechnologies = function(_Technology, _TextKey, _KeyBind)
        Stronghold.Building.Orig_GUITooltip_ResearchTechnologies(_Technology, _TextKey, _KeyBind);
        Stronghold.Building:ChangeWeatherTooltip(_Technology, _TextKey, _KeyBind);
    end

    self.Orig_GUIUpdate_ChangeWeatherButtons = GUIUpdate_ChangeWeatherButtons;
    GUIUpdate_ChangeWeatherButtons = function(_Button, _Technology, _StateID)
        Stronghold.Building:ChangeWeatherUpdate(_Button, _Technology, _StateID);
    end
end

function Stronghold.Building:SetWeatherChangeDelay(_Delay)
    self.Config.WeatherChange = _Delay;
end

function Stronghold.Building:OnWeatherStateChanged(_PlayerID, _OldState, _NewState)
    local CurrentTime = Logic.GetTime();
    self.Data.LastWeatherChange = CurrentTime;
    if GUI.GetPlayerID() == _PlayerID then
        GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/GUI_WeathermashineActivated"));
        GUI.SetWeather(_NewState);
    end
end

function Stronghold.Building:ChangeWeatherAction(_StateID)
    local PlayerID = GUI.GetPlayerID();
	local CurrentWeatherEnergy = Logic.GetPlayersGlobalResource(PlayerID, ResourceType.WeatherEnergy);
	local NeededWeatherEnergy = Logic.GetEnergyRequiredForWeatherChange();
    if Logic.IsWeatherChangeActive() == true then
		GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/Note_WeatherIsCurrentlyChanging"));
		return;
	end
    if CurrentWeatherEnergy < NeededWeatherEnergy then
		GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/GUI_WeathermashineNotReady"));
	end
    Syncer.InvokeEvent(
        Stronghold.Building.NetworkCall,
        Stronghold.Building.SyncEvents.ChangeWeather,
        _StateID
    );
end

function Stronghold.Building:ChangeWeatherTooltip(_Technology, _TextKey, _KeyBind)
    if not self.Config.WeatherChange.Technologies[_Technology] then
        return;
    end
	local PlayerID = GUI.GetPlayerID();
	local TechState = Logic.GetTechnologyState(PlayerID, _Technology);
	Logic.FillTechnologyCostsTable(_Technology, InterfaceGlobals.CostTable);
	local CostString = InterfaceTool_CreateCostString(InterfaceGlobals.CostTable);
	local TooltipText = " ";
	local ShortCutToolTip = " ";
	local ShowCosts = 1;
    local LastChange = self.Data.LastWeatherChange;
    local ChangeFrequency = self.Config.WeatherChange.TimeBetweenChanges;
    local CurrentTime = Logic.GetTime();

    if TechState == 0 then
		TooltipText =  XGUIEng.GetStringTableText("MenuGeneric/TechnologyNotAvailable");
		ShowCosts = 0;
	elseif TechState == 1 or  TechState == 5 then
		TooltipText =  XGUIEng.GetStringTableText(_TextKey .. "_disabled");
		ShowCosts = 1;
	elseif TechState == 2 or TechState == 3 then
		TooltipText = XGUIEng.GetStringTableText(_TextKey .. "_normal");
		if _KeyBind ~= nil then
			ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText(_KeyBind) .. "]";
		end
	elseif TechState == 4 then
		TooltipText = XGUIEng.GetStringTableText(_TextKey .. "_normal");
		ShowCosts = 1;
	end

    if TechState > 0 then
        if LastChange > 0 and LastChange + ChangeFrequency >= CurrentTime then
            local TimeLeft = LastChange + ChangeFrequency - CurrentTime;
            TooltipText = XGUIEng.GetStringTableText("sh_menuweathermachine/WeatherChangeLocked");
            TooltipText = string.format(TooltipText, TimeLeft);
        end
    end
	if ShowCosts == 0 then
		CostString = " ";
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString);
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, TooltipText);
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
end

function Stronghold.Building:ChangeWeatherUpdate(_Button, _Technology, _StateID)
    local PlayerID = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if Logic.GetEntityType(EntityID) ~= Entities.PB_WeatherTower1 then
        return;
    end
	local TechState = Logic.GetTechnologyState(PlayerID, _Technology);
	local CurrentWeather = Logic.GetWeatherState();
    local LastChange = self.Data.LastWeatherChange;
    local ChangeFrequency = self.Config.WeatherChange.TimeBetweenChanges;
    local CurrentTime = Logic.GetTime();
    -- Disable if same state
    if _StateID == CurrentWeather then
		XGUIEng.DisableButton(_Button, 1);
		return;
	end
    -- Disable if weather is currently changing
    if Logic.IsWeatherChangeActive() == true then
		XGUIEng.DisableButton(_Button, 1);
		return;
	end
    -- Disable/enable based on technology state
    if TechState == 0 then
		XGUIEng.DisableButton(_Button, 1);
	elseif TechState == 1 or TechState == 5 then
		XGUIEng.DisableButton(_Button, 1);
		XGUIEng.ShowWidget(_Button, 1);
	elseif TechState == 2 or TechState == 3 or TechState == 4 then
		XGUIEng.ShowWidget(_Button, 1);
		XGUIEng.DisableButton(_Button, 0);
	end
    -- Disable if it hasn't been long enough since the last change
    if LastChange > 0 and LastChange + ChangeFrequency >= CurrentTime then
        XGUIEng.DisableButton(_Button, 1);
    end
end

-- -------------------------------------------------------------------------- --
-- Creation bonus

function Stronghold.Building:ApplyBuildingCreationBonus(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local BuildingType = Logic.GetEntityType(_EntityID);
    if IsPlayer(PlayerID) then
        local BonusConfig = self.Config.BuildingCreationBonus[BuildingType];
        if BonusConfig and not self.Data[PlayerID].CreationBonus[BuildingType] then
            self.Data[PlayerID].CreationBonus[BuildingType] = true;
            AddReputation(PlayerID, BonusConfig.Reputation or 0);
            AddHonor(PlayerID, BonusConfig.Honor or 0);
            Stronghold.Attraction:UpdateMotivationOfPlayersWorkers(
                PlayerID, BonusConfig.Reputation or 0, true
            );
        end
    end
end

function Stronghold.Building:ResetBuildingCreationBonus(_PlayerID)
    if IsPlayer(_PlayerID) then
        self.Data[_PlayerID].CreationBonus = {};
    end
end

function Stronghold.Building:IsBuildingCreationBonusApplied(_PlayerID, _BuildingType)
    if IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].CreationBonus[_BuildingType] ~= nil;
    end
    return false;
end

-- -------------------------------------------------------------------------- --
-- Building entrance

function Stronghold.Building:GetBarracksDoorPosition(_BarracksID)
    local PlayerID = Logic.EntityGetPlayer(_BarracksID);
    local Position = GetHeadquarterEntrance(PlayerID);

    local BarracksType = Logic.GetEntityType(_BarracksID);
    if BarracksType == Entities.PB_Barracks1 or BarracksType == Entities.PB_Barracks2 then
        Position = GetCirclePosition(_BarracksID, 900, 180);
    elseif BarracksType == Entities.PB_Archery1 or BarracksType == Entities.PB_Archery2 then
        Position = GetCirclePosition(_BarracksID, 800, 180);
    elseif BarracksType == Entities.PB_Stable1 or BarracksType == Entities.PB_Stable2 then
        Position = GetCirclePosition(_BarracksID, 1000, 165);
    elseif BarracksType == Entities.PB_Foundry1 or BarracksType == Entities.PB_Foundry2 then
        Position = GetCirclePosition(_BarracksID, 1000, 280);
    elseif BarracksType == Entities.PB_Tavern1 or BarracksType == Entities.PB_Tavern2 then
        Position = GetCirclePosition(_BarracksID, 800, 220);
    elseif BarracksType == Entities.PB_VillageCenter1 or
           BarracksType == Entities.PB_VillageCenter2 or
           BarracksType == Entities.PB_VillageCenter3 then
        Position = GetCirclePosition(_BarracksID, 650, 270);
    -- TODO: Add more positions if needed
    end
    return Position;
end

-- -------------------------------------------------------------------------- --
-- Dirty Hacks

-- Prevent nasty update when toggle groups is used.
function Stronghold.Building:OverrideManualButtonUpdate()
    self.Orig_XGUIEng_DoManualButtonUpdate = XGUIEng.DoManualButtonUpdate;
    XGUIEng.DoManualButtonUpdate = function(_WidgetID)
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local SingleLeader = XGUIEng.GetWidgetID("Activate_RecruitSingleLeader");
        local FullLeader = XGUIEng.GetWidgetID("Activate_RecruitGroups");
        if WidgetID ~= SingleLeader and WidgetID ~= FullLeader then
            Stronghold.Building.Orig_XGUIEng_DoManualButtonUpdate(_WidgetID);
        end
    end
end

-- Deselect building on demolition to prevent click spamming.
function Stronghold.Building:OverrideSellBuildingAction()
    self.Orig_GUI_SellBuilding = GUI.SellBuilding;
    GUI.SellBuilding = function(_EntityID)
        GUI.DeselectEntity(_EntityID);
        Stronghold.Building.Orig_GUI_SellBuilding(_EntityID);
    end
end

