--- 
--- Building Script
---
--- This script implements special properties of building.
--- Including:
--- - Building menus
--- - Building rally points
--- - Govermental Measures
--- - Church prayers
---
--- Defined game callbacks:
--- - <number> GameCallback_SH_Calculate_HonorFromSermon(_PlayerID, _BlessCategory, _CurrentAmount)
---   Allows to overwrite the honor gained from sermons.
---
--- - <number> GameCallback_SH_Calculate_ReputationFromSermon(_PlayerID, _BlessCategory, _CurrentAmount)
---   Allows to overwrite the reputation gained from sermons.
--- 

Stronghold = Stronghold or {};

Stronghold.Building = Stronghold.Building or {
    SyncEvents = {},
    Data = {},
    Config = {},
    Text = {},
}

function Stronghold.Building:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            Measure = {},
            RallyPoint = {},

            HeadquarterLastWidgetID = 0,
        };
    end

    self:CreateBuildingButtonHandlers();
    self:OverrideHeadquarterButtons();
    self:OverrideManualButtonUpdate();
    self:OverrideSellBuildingAction();
    self:OverrideShiftRightClick();
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
        EnqueueSerf = 2,
        BlessSettlers = 4,
        MeasureTaken = 5,
        RallyPoint = 6,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Building.SyncEvents.ChangeTax then
                Stronghold.Building:HeadquartersButtonChangeTax(_PlayerID, arg[1]);
            end
            if _Action == Stronghold.Building.SyncEvents.EnqueueSerf then
                if arg[5] then
                    Stronghold.Recruitment:AbortLatestQueueEntry(_PlayerID, arg[4], Logic.GetEntityName(arg[1]));
                else
                    Stronghold.Recruitment:OrderUnit(_PlayerID, arg[4], arg[2], arg[1], arg[3]);
                end
            end
            if _Action == Stronghold.Building.SyncEvents.BlessSettlers then
                Stronghold.Building:MonasteryBlessSettlers(_PlayerID, arg[1]);
            end
            if _Action == Stronghold.Building.SyncEvents.MeasureTaken then
                Stronghold.Building:HeadquartersBlessSettlers(_PlayerID, arg[1]);
            end
            if _Action == Stronghold.Building.SyncEvents.RallyPoint then
                Stronghold.Building:PlaceRallyPoint(_PlayerID, arg[1], arg[2], arg[3]);
            end
        end
    );
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

function GameCallback_SH_Calculate_HonorFromSermon(_PlayerID, _BlessCategory, _CurrentAmount)
    return _CurrentAmount;
end

function GameCallback_SH_Calculate_ReputationFromSermon(_PlayerID, _BlessCategory, _CurrentAmount)
    return _CurrentAmount;
end

-- -------------------------------------------------------------------------- --
-- Headquarters

function Stronghold.Building:HeadquartersButtonChangeTax(_PlayerID, _Level)
    if IsPlayer(_PlayerID) then
        Stronghold.Players[_PlayerID].TaxHeight = math.min(math.max(_Level +1, 0), 5);
    end
end

-- Regular Headquarters

function Stronghold.Building:OverrideHeadquarterButtons()
    Overwrite.CreateOverwrite("GUIAction_SetTaxes", function(_Level)
        Stronghold.Building:AdjustTax(_Level);
    end);

    Overwrite.CreateOverwrite("GUIUpdate_TaxesButtons", function()
        local PlayerID = GetLocalPlayerID();
        local TaxLevel = Stronghold.Players[PlayerID].TaxHeight -1;
        XGUIEng.UnHighLightGroup(gvGUI_WidgetID.InGame, "taxesgroup");
        XGUIEng.HighLightButton(gvGUI_WidgetID.TaxesButtons[TaxLevel], 1);
    end);

    Overwrite.CreateOverwrite("GUIAction_BuySerf", function()
        Stronghold.Building:HeadquartersBuySerf();
    end);

    Overwrite.CreateOverwrite("GUITooltip_BuySerf", function()
        Stronghold.Building:HeadquartersBuySerfTooltip();
    end);

    GUIAction_CallMilitia = function()
        XGUIEng.ShowWidget("BuyHeroWindow", 1);
    end

    GUIAction_BackToWork = function()
    end
end

function Stronghold.Building:AdjustTax(_Level)
    local GuiPlayer = GetLocalPlayerID();
    local PlayerID = GUI.GetPlayerID();
    if GuiPlayer ~= PlayerID then
        return false;
    end
    if not Stronghold.Building.Data[PlayerID] then
        return false;
    end
    Syncer.InvokeEvent(
        Stronghold.Building.NetworkCall,
        Stronghold.Building.SyncEvents.ChangeTax,
        _Level
    );
    return true;
end

function Stronghold.Building:HeadquartersBuySerf()
    local GuiPlayer = GetLocalPlayerID();
    local PlayerID = GUI.GetPlayerID();
    if Stronghold.Players[PlayerID].BuyUnitLock then
        return false;
    end

    local Config = Stronghold.Unit.Config:Get(Entities.PU_Serf);
    local Costs = CreateCostTable(unpack(Config.Costs[1]));
    if Logic.IsTechnologyResearched(GuiPlayer, Technologies.T_SlavePenny) == 1 then
        local Factor = Stronghold.Recruitment.Config.SlavePenny.CostsFactor;
        Costs[ResourceType.Gold] = math.floor((Costs[ResourceType.Gold] * Factor) + 0.5);
    end
    if InterfaceTool_HasPlayerEnoughResources_Feedback(Costs) == 0 then
        return false;
    end

    Stronghold.Players[PlayerID].BuyUnitLock = true;
    Syncer.InvokeEvent(
        Stronghold.Building.NetworkCall,
        Stronghold.Building.SyncEvents.EnqueueSerf,
        GetID(Stronghold.Players[PlayerID].HQScriptName),
        Entities.PU_Serf,
        false,
        "Buy_Serf",
        XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1
    );
    return true;
end

function Stronghold.Building:HeadquartersBuySerfTooltip()
    local GuiPlayer = GetLocalPlayerID();
    if not IsPlayer(GuiPlayer) then
        return false;
    end
    local Config = Stronghold.Unit.Config:Get(Entities.PU_Serf);
    local Costs = CreateCostTable(unpack(Config.Costs[1]));
    if Logic.IsTechnologyResearched(GuiPlayer, Technologies.T_SlavePenny) == 1 then
        local Factor = Stronghold.Recruitment.Config.SlavePenny.CostsFactor;
        Costs[ResourceType.Gold] = math.floor((Costs[ResourceType.Gold] * Factor) + 0.5);
    end
	local CostString = FormatCostString(GuiPlayer, Costs);
    local ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText("KeyBindings/BuyUnits1") .. "]";
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString);
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText,"sh_menuheadquarter/buyserf");
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
    return true;
end

function Stronghold.Building:OnHeadquarterSelected(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if not IsPlayer(PlayerID)
    or Logic.IsEntityInCategory(_EntityID, EntityCategories.Headquarters) == 0 then
        return;
    end

    XGUIEng.ShowWidget("BuildingTabs", 1);
    XGUIEng.ShowWidget("Buy_Serf_Recharge", 1);
    XGUIEng.ShowWidget("Buy_Serf_Amount", 1);
    -- XGUIEng.SetWidgetPositionAndSize("Research_Tracking", 4, 38, 31, 31);

    local LastWidgetID = self.Data[PlayerID].HeadquarterLastWidgetID;
    if LastWidgetID == 0 then
        LastWidgetID = gvGUI_WidgetID.ToBuildingCommandMenu;
    end
    self:HeadquartersChangeBuildingTabsGuiAction(PlayerID, _EntityID, LastWidgetID);
end

function Stronghold.Building:PrintHeadquartersTaxButtonsTooltip(_PlayerID, _EntityID, _Key)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Headquarters) == 0 then
        return false;
    end
    if GetLocalPlayerID() ~= _PlayerID then
        return false;
    end

    -- Map index
    local Index = -1;
    if _Key == "sh_menuheadquarter/SetVeryLowTaxes" then
        Index = 1;
    elseif _Key == "sh_menuheadquarter/SetLowTaxes" then
        Index = 2;
    elseif _Key == "sh_menuheadquarter/SetNormalTaxes" then
        Index = 3;
    elseif _Key == "sh_menuheadquarter/SetHighTaxes" then
        Index = 4;
    elseif _Key == "sh_menuheadquarter/SetVeryHighTaxes" then
        Index = 5;
    elseif _Key == "sh_menuheadquarter/CallMilitia" then
        Index = 0;
    else
        return false;
    end

    -- Set Text
    local Text = XGUIEng.GetStringTableText(_Key);
    if Index > 0 then
        local Effects = Stronghold.Economy.Config.Income.TaxEffect[Index];
        local EffectText = " @cr " ..XGUIEng.GetStringTableText("sh_text/TooltipEnable");
        if Effects.Reputation ~= 0 then
            local Unit = XGUIEng.GetStringTableText("sh_names/Reputation");
            local ReputationEffect = Effects.Reputation;
            local Operator = "+";
            if Effects.Reputation < 0 then
                Operator = "";
                ReputationEffect = (-1) * GetPlayerTaxPenalty(_PlayerID, Index);
            end
            EffectText = EffectText.. Operator ..ReputationEffect.. " " ..Unit.. " ";
        end
        if Effects.Honor ~= 0 then
            local Unit = XGUIEng.GetStringTableText("sh_names/Honor");
            local Operator = (Effects.Honor >= 0 and "+") or "";
            EffectText = EffectText.. Operator ..Effects.Honor.. " " ..Unit;
        end
        Text = string.format(Text, EffectText);
    elseif Index == 0 then
        Text = XGUIEng.GetStringTableText("sh_menuheadquarter/buy_hero");
    end

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

function Stronghold.Building:HeadquartersShowNormalControls(_PlayerID, _EntityID, _WidgetID)
    XGUIEng.HighLightButton("ToBuildingCommandMenu", 0);
    XGUIEng.HighLightButton("ToBuildingSettlersMenu", 1);
    XGUIEng.ShowWidget("Headquarter", 1);
    XGUIEng.ShowWidget("Monastery", 0);
    XGUIEng.ShowWidget("WorkerInBuilding", 0);

    XGUIEng.SetWidgetPosition("TaxesAndPayStatistics", 105, 35);
    XGUIEng.SetWidgetPosition("HQTaxes", 143, 5);

    XGUIEng.ShowWidget("Buy_Hero", 0);
    XGUIEng.ShowWidget("HQ_Militia", 1);
    XGUIEng.SetWidgetPosition("HQ_Militia", 35, 0);
    XGUIEng.TransferMaterials("Buy_Hero", "HQ_CallMilitia");
    XGUIEng.TransferMaterials("Statistics_SubSettlers_Motivation", "HQ_BackToWork");

    -- TODO: Proper disable in singleplayer!
    -- local ShowBuyHero = XNetwork.Manager_DoesExist()
    XGUIEng.ShowWidget("HQ_CallMilitia", 1);
    XGUIEng.ShowWidget("HQ_BackToWork", 0);
end

-- Mesures (Blessings)

function Stronghold.Building:HeadquartersBlessSettlers(_PlayerID, _BlessCategory)
    local MeasurePoints = Stronghold.Economy:GetPlayerMeasurePoints(_PlayerID);
    -- Prevent click spamming
    if MeasurePoints == 0 then
        return;
    end

    -- Remove allMeasure points
    Stronghold.Economy:AddPlayerMeasurePoints(_PlayerID, (-1) * MeasurePoints);
    -- Update recharge factor
    local CurrentRank = math.max(GetRank(_PlayerID), 1);
    -- Show message
    local Language = GetLanguage();
    local TextKey = self.Config.Headquarters[_BlessCategory].Text;
    Message(XGUIEng.GetStringTableText(TextKey.. "_message"));

    -- Execute effects
    local Effects = Stronghold.Building.Config.Headquarters[_BlessCategory];
    local Reputation = Effects.Reputation;
    if Reputation > 0 then
        local Factor = 1.0;
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DraconicPunishment) == 1 then
            Factor = Factor + self.Config.Headquarters.DraconicPunishmentReputationBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DecorativeSkull) == 1 then
            Factor = Factor + self.Config.Headquarters.DecorativeSkullReputationBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PopalBlessing) == 1 then
            Factor = Factor + self.Config.Headquarters.PopalBlessingReputationBonus;
        end
        Reputation = Reputation * Factor;
    end
    local Honor = Effects.Honor;
    if Honor > 0 then
        local Factor = 1.0;
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DraconicPunishment) == 1 then
            Factor = Factor + self.Config.Headquarters.DraconicPunishmentHonorBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DecorativeSkull) == 1 then
            Factor = Factor + self.Config.Headquarters.DecorativeSkullHonorBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_TjostingArmor) == 1 then
            Factor = Factor + self.Config.Headquarters.TjostingArmorHonorBonus;
        end
        Honor = Honor * Factor;
    end
    Stronghold.Economy:AddOneTimeReputation(_PlayerID, Reputation);
    Stronghold.Economy:AddOneTimeHonor(_PlayerID, Honor);

    if _BlessCategory == BlessCategories.Construction then
        local MsgText = XGUIEng.GetStringTableText("sh_menuheadquarter/blesssettlers1_message_2");
        local RandomTax, Min, Max = 0, 4, 8;
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DraconicPunishment) == 1 then
            Min = Min + 1;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DecorativeSkull) == 1 then
            Max = Max + 1;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PopalBlessing) == 1 then
            Min = Min + 1;
            Max = Max + 1;
        end
        for i= 1, Logic.GetNumberOfAttractedWorker(_PlayerID) do
            RandomTax = RandomTax + math.random(Min, Max);
        end
        Message(string.format(MsgText, RandomTax));
        Sound.PlayGUISound(Sounds.LevyTaxes, 100);
        AddGold(_PlayerID, RandomTax);

    elseif _BlessCategory == BlessCategories.Financial then
        local Workplaces = Stronghold:GetWorkplacesOfType(_PlayerID, 0, true);
        for i= 1, table.getn(Workplaces) do
            local Workers = {Logic.GetAttachedWorkersToBuilding(Workplaces[i])};
            if Workers[1] > 0 and Logic.IsConstructionComplete(Workplaces[i]) == 1 then
                local x,y,z = Logic.EntityGetPos(Workplaces[i]);
                Logic.CreateEffect(GGL_Effects.FXYukiFireworksJoy, x, y, 0);
            end
        end
    end
end

function Stronghold.Building:HeadquartersBlessSettlersGuiAction(_PlayerID, _EntityID, _BlessCategory)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Headquarters) == 0 then
        return false;
    end
    if Stronghold.Economy:GetPlayerMeasurePoints(_PlayerID) < GetPlayerMaxMeasurePoints(_PlayerID) then
        Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_COMMENT_BadPlay_rnd_01, 100);
        Message(XGUIEng.GetStringTableText("sh_menuheadquarter/blesssettlers_error"));
        return true;
    end

    Syncer.InvokeEvent(
        Stronghold.Building.NetworkCall,
        Stronghold.Building.SyncEvents.MeasureTaken,
        _BlessCategory
    );
    return true;
end

function Stronghold.Building:HeadquartersBlessSettlersGuiTooltip(_PlayerID, _EntityID, _TooltipDisabled, _TooltipNormal, _TooltipResearched, _ShortCut)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Headquarters) == 0 then
        return false;
    end

    -- Map technology and bless category
    local BlessCategory = -1;
    local Right = -1;
    if _TooltipNormal == "sh_menumonastery/BlessSettlers1_normal" then
        BlessCategory = BlessCategories.Construction;
        Right = PlayerRight.MeasureLevyTax;
    elseif _TooltipNormal == "sh_menumonastery/BlessSettlers2_normal" then
        BlessCategory = BlessCategories.Research;
        Right = PlayerRight.MeasureLawAndOrder;
    elseif _TooltipNormal == "sh_menumonastery/BlessSettlers3_normal" then
        BlessCategory = BlessCategories.Weapons;
        Right = PlayerRight.FoodDistribution;
    elseif _TooltipNormal == "sh_menumonastery/BlessSettlers4_normal" then
        BlessCategory = BlessCategories.Financial;
        Right = PlayerRight.MeasureFolkloreFeast;
    elseif _TooltipNormal == "sh_menumonastery/BlessSettlers5_normal" then
        BlessCategory = BlessCategories.Canonisation;
        Right = PlayerRight.MeasureOrgy;
    else
        return false;
    end

    local Text = "";
    if not IsRightUnlockable(_PlayerID, Right) then
        Text = XGUIEng.GetStringTableText("MenuGeneric/TechnologyNotAvailable");
    else
        local EffectText = "";
        local Effects = Stronghold.Building.Config.Headquarters[BlessCategory];
        if Effects.Reputation ~= 0 then
            local Name = XGUIEng.GetStringTableText("sh_names/Reputation");
            local Operator = (Effects.Reputation >= 0 and "+") or "";
            local Reputation = Effects.Reputation;
            local Factor = 1.0;
            if Reputation > 0 then
                if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DraconicPunishment) == 1 then
                    Factor = Factor + self.Config.Headquarters.DraconicPunishmentReputationBonus;
                end
                if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DecorativeSkull) == 1 then
                    Factor = Factor + self.Config.Headquarters.DrecorativeSkullReputationBonus;
                end
                if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_TjostingArmor) == 1 then
                    Factor = Factor + self.Config.Headquarters.TjostingArmorReputationBonus;
                end
            end
            EffectText = EffectText .. Operator .. math.floor((Reputation * Factor) + 0.5).. " " ..Name.. " ";
        end
        if Effects.Honor ~= 0 then
            local Name = XGUIEng.GetStringTableText("sh_names/Honor");
            local Operator = (Effects.Honor >= 0 and "+") or "";
            local Honor = Effects.Honor;
            local Factor = 1.0;
            if Honor > 0 then
                if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DraconicPunishment) == 1 then
                    Factor = Factor + self.Config.Headquarters.DraconicPunishmentHonorBonus;
                end
                if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DecorativeSkull) == 1 then
                    Factor = Factor + self.Config.Headquarters.DecorativeSkullHonorBonus;
                end
                if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_TjostingArmor) == 1 then
                    Factor = Factor + self.Config.Headquarters.TjostingArmorHonorBonus;
                end
            end
            EffectText = EffectText .. Operator .. math.floor((Honor * Factor) + 0.5).. " " ..Name;
        end

        local MainKey = self.Config.Headquarters[BlessCategory].Text;
        local TextKey = MainKey.. "_normal";
        if XGUIEng.IsButtonDisabled(XGUIEng.GetCurrentWidgetID()) == 1 then
            TextKey = MainKey.. "_disabled";
        end
        Text = string.format(XGUIEng.GetStringTableText(TextKey), EffectText);
    end
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Placeholder.Replace(Text));
    return true;
end

function Stronghold.Building:HeadquartersBlessSettlersGuiUpdate(_PlayerID, _EntityID, _Button)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Headquarters) == 0 then
        return false;
    end
    local Level = Logic.GetUpgradeLevelForBuilding(_EntityID);
    local ButtonDisabled = 0;
    if _Button == "BlessSettlers1" then
        if Level < 0 or not IsRightUnlockable(_PlayerID, PlayerRight.MeasureLevyTax) then
            ButtonDisabled = 1;
        end
    elseif _Button == "BlessSettlers2" then
        if Level < 0 or not IsRightUnlockable(_PlayerID, PlayerRight.MeasureLawAndOrder) then
            ButtonDisabled = 1;
        end
    elseif _Button == "BlessSettlers3" then
        if Level < 1 or not IsRightUnlockable(_PlayerID, PlayerRight.FoodDistribution) then
            ButtonDisabled = 1;
        end
    elseif _Button == "BlessSettlers4" then
        if Level < 1 or not IsRightUnlockable(_PlayerID, PlayerRight.MeasureFolkloreFeast) then
            ButtonDisabled = 1;
        end
    elseif _Button == "BlessSettlers5" then
        if Level < 2 or not IsRightUnlockable(_PlayerID, PlayerRight.MeasureOrgy) then
            ButtonDisabled = 1;
        end
    elseif _Button == "Research_DraconicPunishment" then
        local TechState = Logic.GetTechnologyState(_PlayerID, Technologies.T_DraconicPunishment);
        local Required = Logic.IsTechnologyResearched(_PlayerID, Technologies.T_BetterStudies) == 1;
        if Level < 0 or TechState == 0 or not Required then
            ButtonDisabled = 1;
        end
    elseif _Button == "Research_DecorativeSkull" then
        local TechState = Logic.GetTechnologyState(_PlayerID, Technologies.T_DecorativeSkull);
        local Required = Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DraconicPunishment) == 1;
        if Level < 1 or TechState == 0 or not Required then
            ButtonDisabled = 1;
        end
    elseif _Button == "Research_TjostingArmor" then
        local TechState = Logic.GetTechnologyState(_PlayerID, Technologies.T_TjostingArmor);
        local Required = Logic.IsTechnologyResearched(_PlayerID, Technologies.T_DecorativeSkull) == 1;
        if Level < 2 or TechState == 0 or not Required then
            ButtonDisabled = 1;
        end
    end
    XGUIEng.DisableButton(_Button, ButtonDisabled);
    return true;
end

function Stronghold.Building:HeadquartersFaithProgressGuiUpdate(_PlayerID, _EntityID, _WidgetID)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Headquarters) == 0 then
        return false;
    end
    local ValueMax = GetPlayerMaxMeasurePoints(_PlayerID);
    local Value = Stronghold.Economy:GetPlayerMeasurePoints(_PlayerID);
    XGUIEng.SetProgressBarValues(_WidgetID, Value, ValueMax);
    return true;
end

function Stronghold.Building:HeadquartersShowMonasteryControls(_PlayerID, _EntityID, _WidgetID)
    XGUIEng.HighLightButton("ToBuildingCommandMenu", 1);
    XGUIEng.HighLightButton("ToBuildingSettlersMenu", 0);
    XGUIEng.ShowWidget("Headquarter", 0);
    XGUIEng.ShowWidget("Monastery", 1);
    XGUIEng.ShowWidget("WorkerInBuilding", 0);
    XGUIEng.ShowWidget("Upgrade_Monastery1", 0);
    XGUIEng.ShowWidget("Upgrade_Monastery2", 0);
    XGUIEng.ShowWidget("Research_SundayAssembly", 0);
    XGUIEng.ShowWidget("Research_HolyRelics", 0);
    XGUIEng.ShowWidget("Research_PopalBlessing", 0);
    XGUIEng.ShowWidget("Research_DraconicPunishment", 1);
    XGUIEng.ShowWidget("Research_DecorativeSkull", 1);
    XGUIEng.ShowWidget("Research_TjostingArmor", 1);

    XGUIEng.TransferMaterials("Levy_Duties", "BlessSettlers1");
    XGUIEng.TransferMaterials("Research_Laws", "BlessSettlers2");
    XGUIEng.TransferMaterials("Alms_Source", "BlessSettlers3");
    XGUIEng.TransferMaterials("Statistics_SubSettlers_Motivation", "BlessSettlers4");
    XGUIEng.TransferMaterials("Build_Tavern", "BlessSettlers5");

    self:HeadquartersBlessSettlersGuiUpdate(_PlayerID, _EntityID, "BlessSettlers1");
    self:HeadquartersBlessSettlersGuiUpdate(_PlayerID, _EntityID, "BlessSettlers2");
    self:HeadquartersBlessSettlersGuiUpdate(_PlayerID, _EntityID, "BlessSettlers3");
    self:HeadquartersBlessSettlersGuiUpdate(_PlayerID, _EntityID, "BlessSettlers4");
    self:HeadquartersBlessSettlersGuiUpdate(_PlayerID, _EntityID, "BlessSettlers5");
    self:HeadquartersBlessSettlersGuiUpdate(_PlayerID, _EntityID, "Research_DraconicPunishment");
    self:HeadquartersBlessSettlersGuiUpdate(_PlayerID, _EntityID, "Research_DecorativeSkull");
    self:HeadquartersBlessSettlersGuiUpdate(_PlayerID, _EntityID, "Research_TjostingArmor");
end

-- Sub menu

function Stronghold.Building:HeadquartersChangeBuildingTabsGuiAction(_PlayerID, _EntityID, _WidgetID)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Headquarters) == 0 then
        return false;
    end
    if _WidgetID == gvGUI_WidgetID.ToBuildingCommandMenu then
        self.Data[_PlayerID].HeadquarterLastWidgetID = _WidgetID;
        self:HeadquartersShowNormalControls(_PlayerID, _EntityID, _WidgetID);
    elseif _WidgetID == gvGUI_WidgetID.ToBuildingSettlersMenu then
        self.Data[_PlayerID].HeadquarterLastWidgetID = _WidgetID;
        self:HeadquartersShowMonasteryControls(_PlayerID, _EntityID, _WidgetID);
    end
    return true;
end

function Stronghold.Building:HeadquartersBuildingTabsGuiTooltip(_PlayerID, _EntityID, _Key)
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

-- -------------------------------------------------------------------------- --
-- Monastery

function Stronghold.Building:MonasteryBlessSettlers(_PlayerID, _BlessCategory)
    local CurrentFaith = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Faith);
    Logic.SubFromPlayersGlobalResource(_PlayerID, ResourceType.Faith, CurrentFaith);

    local BlessData = self.Config.Monastery[_BlessCategory];
    if BlessData.Reputation > 0 then
        local Reputation = BlessData.Reputation;
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SundayAssembly) == 1 then
            Reputation = Reputation + self.Config.Monastery.SundayAssemblyReputationBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_HolyRelics) == 1 then
            Reputation = Reputation + self.Config.Monastery.HolyRelicsReputationBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PopalBlessing) == 1 then
            Reputation = Reputation + self.Config.Monastery.PopalBlessingReputationBonus;
        end
        Reputation = GameCallback_SH_Calculate_ReputationFromSermon(_PlayerID, _BlessCategory, Reputation);
        Stronghold.Economy:AddOneTimeReputation(_PlayerID, math.floor(Reputation + 0.5));
    end
    if BlessData.Honor > 0 then
        local Honor = BlessData.Honor;
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SundayAssembly) == 1 then
            Honor = Honor + self.Config.Monastery.SundayAssemblyHonorBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_HolyRelics) == 1 then
            Honor = Honor + self.Config.Monastery.HolyRelicsHonorBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PopalBlessing) == 1 then
            Honor = Honor + self.Config.Monastery.PopalBlessingHonorBonus;
        end
        Honor = GameCallback_SH_Calculate_HonorFromSermon(_PlayerID, _BlessCategory, Honor);
        Stronghold.Economy:AddOneTimeHonor(_PlayerID, math.floor(Honor + 0.5));
    end

    if GUI.GetPlayerID() == _PlayerID then
        local TextKey = self.Config.Monastery[_BlessCategory].Text;
        Message(XGUIEng.GetStringTableText(TextKey.. "_message"));
        Sound.PlayGUISound(Sounds.Buildings_Monastery, 0);
        Sound.PlayFeedbackSound(Sounds.VoicesMentor_INFO_SettlersBlessed_rnd_01, 0);
    end
end

function Stronghold.Building:OnMonasterySelected(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if not IsPlayer(PlayerID)
    or Logic.GetUpgradeCategoryByBuildingType(Type) ~= UpgradeCategories.Monastery then
        return;
    end

    local Level = Logic.GetUpgradeLevelForBuilding(_EntityID);
    if Level == 1 then
        XGUIEng.ShowWidget("Upgrade_Monastery2", 1);
    end
    if Level == 0 then
        XGUIEng.ShowWidget("Upgrade_Monastery1", 1);
    end
    XGUIEng.ShowWidget("Research_SundayAssembly", 1);
    XGUIEng.ShowWidget("Research_HolyRelics", 1);
    XGUIEng.ShowWidget("Research_PopalBlessing", 1);
    XGUIEng.ShowWidget("Research_DraconicPunishment", 0);
    XGUIEng.ShowWidget("Research_DecorativeSkull", 0);
    XGUIEng.ShowWidget("Research_TjostingArmor", 0);
    XGUIEng.TransferMaterials("BlessSettlers1Source", "BlessSettlers1");
    XGUIEng.TransferMaterials("BlessSettlers2Source", "BlessSettlers2");
    XGUIEng.TransferMaterials("BlessSettlers3Source", "BlessSettlers3");
    XGUIEng.TransferMaterials("BlessSettlers4Source", "BlessSettlers4");
    XGUIEng.TransferMaterials("BlessSettlers5Source", "BlessSettlers5");
end

function Stronghold.Building:MonasteryBlessSettlersGuiAction(_PlayerID, _EntityID, _BlessCategory)
    local Type = Logic.GetEntityType(_EntityID);
    if Logic.GetUpgradeCategoryByBuildingType(Type) ~= UpgradeCategories.Monastery then
        return false;
    end

    local CurrentFaith = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Faith);
    local BlessCosts = Logic.GetBlessCostByBlessCategory(_BlessCategory);
    if BlessCosts <= CurrentFaith then
        Syncer.InvokeEvent(
            Stronghold.Building.NetworkCall,
            Stronghold.Building.SyncEvents.BlessSettlers,
            _BlessCategory
        );
    else
        GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughFaith"));
        Sound.PlayFeedbackSound(Sounds.VoicesMentor_INFO_MonksNeedMoreTime_rnd_01, 0);
    end
    return true;
end

function Stronghold.Building:MonasteryBlessSettlersGuiTooltip(_PlayerID, _EntityID, _TooltipDisabled, _TooltipNormal, _TooltipResearched, _ShortCut)
    local Type = Logic.GetEntityType(_EntityID);
    if Logic.GetUpgradeCategoryByBuildingType(Type) ~= UpgradeCategories.Monastery then
        return false;
    end

    -- Map technology and bless category
    local BlessCategory = -1;
    local Technology = -1;
    if _TooltipNormal == "sh_menumonastery/BlessSettlers1_normal" then
        BlessCategory = BlessCategories.Construction;
        Technology = Technologies.T_BlessSettlers1;
    elseif _TooltipNormal == "sh_menumonastery/BlessSettlers2_normal" then
        BlessCategory = BlessCategories.Research;
        Technology = Technologies.T_BlessSettlers2;
    elseif _TooltipNormal == "sh_menumonastery/BlessSettlers3_normal" then
        BlessCategory = BlessCategories.Weapons;
        Technology = Technologies.T_BlessSettlers3;
    elseif _TooltipNormal == "sh_menumonastery/BlessSettlers4_normal" then
        BlessCategory = BlessCategories.Financial;
        Technology = Technologies.T_BlessSettlers4;
    elseif _TooltipNormal == "sh_menumonastery/BlessSettlers5_normal" then
        BlessCategory = BlessCategories.Canonisation;
        Technology = Technologies.T_BlessSettlers5;
    else
        return false;
    end

    local Text = "";
    if Logic.GetTechnologyState(_PlayerID, Technology) == 0 then
        Text = XGUIEng.GetStringTableText("MenuGeneric/TechnologyNotAvailable");
    else
        local EffectText = "";
        local Effects = Stronghold.Building.Config.Monastery[BlessCategory];
        if Effects.Reputation > 0 then
            local Name = XGUIEng.GetStringTableText("sh_names/Reputation");
            local Reputation = Effects.Reputation;
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SundayAssembly) == 1 then
                Reputation = Reputation + self.Config.Monastery.SundayAssemblyReputationBonus;
            end
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_HolyRelics) == 1 then
                Reputation = Reputation + self.Config.Monastery.HolyRelicsReputationBonus;
            end
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PopalBlessing) == 1 then
                Reputation = Reputation + self.Config.Monastery.PopalBlessingReputationBonus;
            end
            Reputation = GameCallback_SH_Calculate_ReputationFromSermon(_PlayerID, BlessCategory, Reputation);
            EffectText = EffectText.. "+" ..math.floor(Reputation + 0.5).. " " ..Name.. " ";
        end
        if Effects.Honor > 0 then
            local Name = XGUIEng.GetStringTableText("sh_names/Honor");
            local Honor = Effects.Honor;
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SundayAssembly) == 1 then
                Honor = Honor + self.Config.Monastery.SundayAssemblyHonorBonus;
            end
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_HolyRelics) == 1 then
                Honor = Honor + self.Config.Monastery.HolyRelicsHonorBonus;
            end
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PopalBlessing) == 1 then
                Honor = Honor + self.Config.Monastery.PopalBlessingHonorBonus;
            end
            Honor = GameCallback_SH_Calculate_HonorFromSermon(_PlayerID, BlessCategory, Honor);
            EffectText = EffectText.. "+" ..math.floor(Honor + 0.5).. " " ..Name;
        end

        local MainKey = self.Config.Monastery[BlessCategory].Text;
        local TextKey = MainKey.. "_normal";
        if XGUIEng.IsButtonDisabled(XGUIEng.GetCurrentWidgetID()) == 1 then
            TextKey = MainKey.. "_disabled";
        end
        Text = string.format(XGUIEng.GetStringTableText(TextKey), EffectText);
    end
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Placeholder.Replace(Text));
    return true;
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
    local Type = Logic.GetEntityType(_EntityID);
    if Logic.GetUpgradeCategoryByBuildingType(Type) == UpgradeCategories.DarkTower then
        XGUIEng.ShowWidget("Tower", 1);
        InterfaceTool_UpdateUpgradeButtons(Type, UpgradeCategories.DarkTower, "Upgrade_Tower");
    end
end

-- -------------------------------------------------------------------------- --
-- Rally Points

function Stronghold.Building:OverrideShiftRightClick()
    InputCallback_ShiftRightClick_Orig_SH = InputCallback_ShiftRightClick;
    InputCallback_ShiftRightClick = function()
        if Stronghold.Building:OnShiftRightClick() then
            return true;
        end
        return InputCallback_ShiftRightClick_Orig_SH();
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
        SendEvent.SerfExtractResource(_SerfID, Type, x, y);
        return;
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

function Stronghold.Building:PlaceRallyPoint(_PlayerID, _EntityID, _X, _Y)
    if self.Data[_PlayerID] then
        -- Create position entity
        local ScriptName = CreateNameForEntity(_EntityID);
        local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, _X, _Y, 0, _PlayerID);
        -- Check connectivity
        if not ArePositionsConnected(ID, _EntityID) then
            DestroyEntity(ID);
            return;
        end
        -- Set visibility
        SVLib.SetInvisibility(ID, GetLocalPlayerID() ~= _PlayerID);
        Logic.SetModelAndAnimSet(ID, Models.Banners_XB_LargeFull);
        Logic.SetEntityExplorationRange(ID, 1);
        -- Save new entity
        DestroyEntity(self.Data[_PlayerID].RallyPoint[ScriptName]);
        self.Data[_PlayerID].RallyPoint[ScriptName] = ID;
    end
end

function Stronghold.Building:CanHaveRallyPoint(_Building)
    local ID = GetID(_Building);
    local Type = Logic.GetEntityType(ID);
    if Type == Entities.PB_Archery1 or Type == Entities.PB_Archery2
    or Type == Entities.PB_Barracks1 or Type == Entities.PB_Barracks2
    or Type == Entities.PB_Stable1 or Type == Entities.PB_Stable2
    -- or Type == Entities.PB_Foundry1 or Type == Entities.PB_Foundry2
    or Type == Entities.PB_Headquarters1 or Type == Entities.PB_Headquarters2
    or Type == Entities.PB_Headquarters3 then
        return true;
    end
    return false;
end

function Stronghold.Building:OnShiftRightClick()
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if self.Data[PlayerID] then
        if self:CanHaveRallyPoint(EntityID) then
            local x,y = GUI.Debug_GetMapPositionUnderMouse();
            if x ~= -1 and y ~= -1 then
                Syncer.InvokeEvent(
                    Stronghold.Building.NetworkCall,
                    Stronghold.Building.SyncEvents.RallyPoint,
                    EntityID,
                    x,
                    y
                );
                return true;
            end
        end
    end
    return false;
end

function Stronghold.Building:OnRallyPointHolderDestroyed(_PlayerID, _EntityID)
    if self.Data[_PlayerID] then
        local ScriptName = CreateNameForEntity(_EntityID);
        if self.Data[_PlayerID].RallyPoint[ScriptName] and not IsExisting(ScriptName) then
            DestroyEntity(self.Data[_PlayerID].RallyPoint[ScriptName]);
            self.Data[_PlayerID].RallyPoint[ScriptName] = nil;
        end
    end
end

function Stronghold.Building:OnRallyPointHolderSelected(_PlayerID, _EntityID)
    if self.Data[_PlayerID] then
        -- Hide all rally points of the player
        for k,v in pairs(self.Data[_PlayerID].RallyPoint) do
            if IsExisting(v) then
                SVLib.SetInvisibility(v, true);
                Logic.SetEntityExplorationRange(v, 0);
            end
        end
        -- Display the rally point of the building
        if _EntityID and IsExisting(_EntityID) then
            local ScriptName = CreateNameForEntity(_EntityID);
            if self.Data[_PlayerID].RallyPoint[ScriptName] then
                local ID = GetID(self.Data[_PlayerID].RallyPoint[ScriptName]);
                SVLib.SetInvisibility(ID, GetLocalPlayerID() ~= _PlayerID);
                Logic.SetEntityExplorationRange(ID, 1);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Foundry

function Stronghold.Building:FoundryCannonAutoRepair(_PlayerID)
    if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_AutoRepair) == 1 then
        local Cannons = Stronghold:GetCannonsOfType(_PlayerID, 0);
        for i= 1, table.getn(Cannons) do
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
        Sound.PlayGUISound(Sounds.klick_rnd_1, 0);
        Stronghold.Building:ExecuteBuyUnitKeybindForBarracks(_Key, _PlayerID, _EntityID);
        Stronghold.Building:ExecuteBuyUnitKeybindForArchery(_Key, _PlayerID, _EntityID);
        Stronghold.Building:ExecuteBuyUnitKeybindForStable(_Key, _PlayerID, _EntityID);
    end

    Input.KeyBindDown(Keys.A, "Stronghold_KeyBindings_BuyUnit(1, GUI.GetPlayerID(), GUI.GetSelectedEntity())", 2);
    Input.KeyBindDown(Keys.S, "Stronghold_KeyBindings_BuyUnit(2, GUI.GetPlayerID(), GUI.GetSelectedEntity())", 2);
    Input.KeyBindDown(Keys.D, "Stronghold_KeyBindings_BuyUnit(3, GUI.GetPlayerID(), GUI.GetSelectedEntity())", 2);
    Input.KeyBindDown(Keys.F, "Stronghold_KeyBindings_BuyUnit(4, GUI.GetPlayerID(), GUI.GetSelectedEntity())", 2);
    Input.KeyBindDown(Keys.G, "Stronghold_KeyBindings_BuyUnit(5, GUI.GetPlayerID(), GUI.GetSelectedEntity())", 2);
    Input.KeyBindDown(Keys.H, "Stronghold_KeyBindings_BuyUnit(6, GUI.GetPlayerID(), GUI.GetSelectedEntity())", 2);
end

function Stronghold.Building:ExecuteBuyUnitKeybindForBarracks(_Key, _PlayerID, _EntityID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Type = Logic.GetEntityType(_EntityID);
        if Type == Entities.PB_Barracks1 or Type == Entities.PB_Barracks2 then
            if Logic.IsConstructionComplete(_EntityID) == 1 then
                if _Key == 1 and XGUIEng.IsButtonDisabled("Research_UpgradeSword1") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeSword1);
                elseif _Key == 2 and XGUIEng.IsButtonDisabled("Research_UpgradeSword2") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeSword2);
                elseif _Key == 3 and XGUIEng.IsButtonDisabled("Research_UpgradeSword3") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeSword3);
                elseif _Key == 4 and XGUIEng.IsButtonDisabled("Research_UpgradeSpear1") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeSpear1);
                elseif _Key == 4 and XGUIEng.IsButtonDisabled("Research_UpgradeSpear2") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeSpear2);
                elseif _Key == 4 and XGUIEng.IsButtonDisabled("Research_UpgradeSpear3") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeSpear3);
                end
            end
        end
    end
end

function Stronghold.Building:ExecuteBuyUnitKeybindForArchery(_Key, _PlayerID, _EntityID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Type = Logic.GetEntityType(_EntityID);
        if Type == Entities.PB_Archery1 or Type == Entities.PB_Archery2 then
            if Logic.IsConstructionComplete(_EntityID) == 1 then
                if _Key == 1 and XGUIEng.IsButtonDisabled("Research_UpgradeBow1") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeBow1);
                elseif _Key == 2 and XGUIEng.IsButtonDisabled("Research_UpgradeBow2") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeBow2);
                elseif _Key == 3 and XGUIEng.IsButtonDisabled("Research_UpgradeBow3") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeBow3);
                elseif _Key == 4 and XGUIEng.IsButtonDisabled("Research_UpgradeRifle1") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeRifle1);
                end
            end
        end
    end
end

function Stronghold.Building:ExecuteBuyUnitKeybindForStable(_Key, _PlayerID, _EntityID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Type = Logic.GetEntityType(_EntityID);
        if Type == Entities.PB_Stable1 or Type == Entities.PB_Stable2 then
            if Logic.IsConstructionComplete(_EntityID) == 1 then
                if _Key == 1 and XGUIEng.IsButtonDisabled("Research_UpgradeCavalryLight1") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeLightCavalry1);
                elseif _Key == 2 and XGUIEng.IsButtonDisabled("Research_UpgradeCavalryHeavy1") == 0 then
                    GUIAction_ReserachTechnology(Technologies.T_UpgradeHeavyCavalry1);
                end
            end
        end
    end
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

