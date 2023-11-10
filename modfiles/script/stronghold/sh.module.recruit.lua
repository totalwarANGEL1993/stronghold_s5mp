--- 
--- Recruitment Script
--- 

Stronghold = Stronghold or {};

Stronghold.Recruit = Stronghold.Recruit or {
    SyncEvents = {},
    Data = {},
    Config = {},
};

function Stronghold.Recruit:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            BuyLock = false,
            BuyTimeStamp = 0,
            Config = CopyTable(Stronghold.Unit.Config),
            Roster = {},
            AutoFill = {},
            TrainingLeaders = {},
            ForgeRegister = {},
        };
        self:InitDefaultRoster(i);
    end
    self:CreateBuildingButtonHandlers();
    self:InitAutoFillButtons();
    self:OverwriteBuySerfAction();
    self:OverrideCalculateMilitaryUsage();
end

function Stronghold.Recruit:OnSaveGameLoaded()
end

function Stronghold.Recruit:CreateBuildingButtonHandlers()
    self.SyncEvents = {
        ReleaseBuyLock = 1,
        BuyUnit = 3,
        BuyCannon = 2,
        ToggleAutoFill = 4,
    };
    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            WriteSyncCallToLog("Recruit", _Action, _PlayerID, unpack(arg));

            if _Action == Stronghold.Recruit.SyncEvents.ReleaseBuyLock then
                if Stronghold.Recruit.Data[_PlayerID] then
                    Stronghold.Recruit.Data[_PlayerID].BuyLock = false;
                end
            elseif _Action == Stronghold.Recruit.SyncEvents.BuyCannon then
                Stronghold.Unit:PayUnit(_PlayerID, arg[1], 0);
                self:RegisterCannonOrder(_PlayerID, arg[3], arg[1]);
                if GUI.GetPlayerID() == _PlayerID then
                    Syncer.InvokeEvent(self.NetworkCall, self.SyncEvents.ReleaseBuyLock);
                end
            elseif _Action == Stronghold.Recruit.SyncEvents.BuyUnit then
                Stronghold.Unit:PayUnit(_PlayerID, arg[1], arg[2]);
                if GUI.GetPlayerID() == _PlayerID then
                    Syncer.InvokeEvent(self.NetworkCall, self.SyncEvents.ReleaseBuyLock);
                end
            elseif _Action == Stronghold.Recruit.SyncEvents.ToggleAutoFill then
                local Current = Stronghold.Recruit.Data[_PlayerID].AutoFill[arg[1]];
                Stronghold.Recruit.Data[_PlayerID].AutoFill[arg[1]] = not Current;
            end
        end
    );
end

function Stronghold.Recruit:OnEntityCreated(_EntityID)
    -- Recruit units
    self:UnitRecruiterController(_EntityID);
end

function Stronghold.Recruit:OnEveryTurn(_PlayerID)
    -- Auto recruit soldiers
    self:SoldierRecruiterController(_PlayerID);
    -- Cannon progress
    self:ControlCannonProducers(_PlayerID);
end

-- -------------------------------------------------------------------------- --

function Stronghold.Recruit:InitDefaultRoster(_PlayerID)
    if self.Data[_PlayerID] then
        self.Data[_PlayerID].Roster = CopyTable(self.Config.DefaultRoster);
    end
end

function Stronghold.Recruit:IsUnitAllowed(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.Unit.Config:Get(_Type, PlayerID);
    if Config then
        if not Stronghold.Rights:IsRightLockedForPlayer(PlayerID, Config.Right) then
            return Stronghold.Rights:GetRankRequiredForRight(PlayerID, Config.Right) >= 0;
        end
    end
    return false;
end

function Stronghold.Recruit:HasSufficientRecruiterBuilding(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.Unit.Config:Get(_Type, PlayerID);
    if Config then
        local Providers = table.getn(Config.RecruiterBuilding);
        if Providers == 0 then
            return false;
        end
        for i= 1, Providers do
            local BuildingType = Config.RecruiterBuilding[i];
            local Buildings = Stronghold:GetBuildingsOfType(PlayerID, BuildingType, true);
            if table.getn(Buildings) > 0 then
                return true;
            end
        end
    end
    return false;
end

function Stronghold.Recruit:HasSufficientProviderBuilding(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.Unit.Config:Get(_Type, PlayerID);
    if Config then
        local Providers = table.getn(Config.ProviderBuilding);
        if Providers == 0 then
            return true;
        end
        for i= 1, Providers do
            local BuildingType = Config.ProviderBuilding[i];
            local Buildings = Stronghold:GetBuildingsOfType(PlayerID, BuildingType, true);
            if table.getn(Buildings) > 0 then
                return true;
            end
        end
    end
    return false;
end

function Stronghold.Recruit:HasSufficientRank(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.Unit.Config:Get(_Type, PlayerID);
    if Config then
        if GetRank(PlayerID) >= GetRankRequired(PlayerID, Config.Right) then
            return true;
        end
    end
    return false;
end

function Stronghold.Recruit:GetLeaderTrainingAtBuilding(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if IsPlayer(PlayerID) then
        local LeaderIDs = {0};
        for LeaderID,_ in pairs(self.Data[PlayerID].TrainingLeaders) do
            local BarracksID = Logic.LeaderGetBarrack(LeaderID);
            if BarracksID == _EntityID then
                table.insert(LeaderIDs, LeaderID);
                LeaderIDs[1] = LeaderIDs[1] + 1;
            end
        end
        return LeaderIDs;
    end
    return 0;
end

function Stronghold.Recruit:GetLeaderCosts(_PlayerID, _Type, _SoldierAmount)
    local Costs = {};
    local Config = Stronghold.Unit.Config:Get(_Type, _PlayerID);
    if Config then
        _SoldierAmount = _SoldierAmount or Config.Soldiers;
        Costs = CopyTable(Config.Costs[1]);
        Costs = CreateCostTable(unpack(Costs));

        -- Effect Slave Penny
        if _Type == Entities.PU_Serf then
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SlavePenny) == 1 then
                local Factor = self.Config.SlavePenny.CostsFactor;
                Costs[ResourceType.Gold] = math.floor((Costs[ResourceType.Gold] * Factor) + 0.5);
            end
        end

        Costs = Stronghold.Hero:ApplyLeaderCostPassiveAbility(_PlayerID, _Type, Costs);
        if _SoldierAmount and _SoldierAmount > 0 then
            local SoldierCosts = self:GetSoldierCostsByLeaderType(_PlayerID, _Type, _SoldierAmount);
            Costs = MergeCostTable(Costs, SoldierCosts);
        end
    end
    return Costs;
end

function Stronghold.Recruit:GetSoldierCostsByLeaderType(_PlayerID, _Type, _Amount)
    local Costs = {};
    local Config = Stronghold.Unit.Config:Get(_Type, _PlayerID);
    if Config then
        Costs = CopyTable(Config.Costs[2]);
        for i= 2, 7 do
            Costs[i] = Costs[i] * (_Amount or Config.Soldiers);
        end
        Costs = CreateCostTable(unpack(Costs));
        Costs = Stronghold.Hero:ApplySoldierCostPassiveAbility(_PlayerID, _Type, Costs);
    end
    return Costs;
end

-- -------------------------------------------------------------------------- --
-- Button Actions

function Stronghold.Recruit:BuyUnitAction(_Index, _WidgetID, _PlayerID, _EntityID, _UpgradeCategory, _EntityType)
    -- Prevent click spam
    if self.Data[_PlayerID].BuyTimeStamp + 3 >= Logic.GetCurrentTurn()
    or self.Data[_PlayerID].BuyLock then
        return;
    end
    -- Check is foundry
    if string.find(Logic.GetEntityTypeName(Logic.GetEntityType(_EntityID)), "PB_Foundry") ~= nil then
        return;
    end
    -- Check if full
    local LeaderIDs = self:GetLeaderTrainingAtBuilding(_EntityID);
    if LeaderIDs[1] >= 3 then
        return;
    end
    -- Check places
    local Places = GetMilitaryPlacesUsedByUnit(_EntityType, 1);
    if _EntityType == Entities.PU_Serf then
        if not HasPlayerSpaceForSlave(_PlayerID) then
            Sound.PlayFeedbackSound(Sounds.VoicesSerf_SERF_No_rnd_01, 100);
            Message(XGUIEng.GetStringTableText("sh_text/Player_SerfLimit"));
            return true;
        end
    else
        if not HasPlayerSpaceForUnits(_PlayerID, Places) then
            Sound.PlayFeedbackSound(Sounds.VoicesLeader_LEADER_NO_rnd_01, 100);
            Message(XGUIEng.GetStringTableText("sh_text/Player_MilitaryLimit"));
            return true;
        end
    end
    -- Pay costs
    local Costs = Stronghold.Recruit:GetLeaderCosts(_PlayerID, _EntityType, 0);
    if HasPlayerEnoughResourcesFeedback(_PlayerID, Costs) == 0 then
        return;
    end
    self.Data[_PlayerID].BuyLock = true;
    self.Data[_PlayerID].BuyTimeStamp = Logic.GetCurrentTurn();
    Syncer.InvokeEvent(
        self.NetworkCall,
        self.SyncEvents.BuyUnit,
        _EntityType,
        0,
        _EntityID
    );
    -- Buy unit
    if _UpgradeCategory == UpgradeCategories.Serf then
        GUI.BuySerf(_EntityID);
    else
        if not IsAIPlayer(_PlayerID) then
            GUI.DeactivateAutoFillAtBarracks(_EntityID);
        end
        GUIAction_BuyMilitaryUnit(_UpgradeCategory);
    end
end

function Stronghold.Recruit:BuyCannonAction(_Index, _WidgetID, _PlayerID, _EntityID, _UpgradeCategory, _EntityType)
    -- Prevent click spam
    if self.Data[_PlayerID].BuyTimeStamp + 3 >= Logic.GetCurrentTurn()
    or self.Data[_PlayerID].BuyLock then
        return;
    end
    -- Check is foundry
    if string.find(Logic.GetEntityTypeName(Logic.GetEntityType(_EntityID)), "PB_Foundry") == nil then
        return;
    end
    -- Check if full
    if InterfaceTool_IsBuildingDoingSomething(_EntityID) then
        return;
    end
    -- Check places
    local Places = GetMilitaryPlacesUsedByUnit(_EntityType, 1);
    if not HasPlayerSpaceForUnits(_PlayerID, Places) then
        Sound.PlayFeedbackSound(Sounds.VoicesLeader_LEADER_NO_rnd_01, 100);
        Message(XGUIEng.GetStringTableText("sh_text/Player_MilitaryLimit"));
        return true;
    end
    -- Check has worker
    local Worker = {Logic.GetAttachedWorkersToBuilding(_EntityID)};
    if not Worker[1] or (Worker[1] > 0 and Logic.IsSettlerAtWork(Worker[2]) == 0) then
        Sound.PlayQueuedFeedbackSound(Sounds.VoicesWorker_WORKER_FunnyNo_rnd_01, 100);
        Message(XGUIEng.GetStringTableText("sh_text/Player_NoWorker"));
        return;
    end
    -- Pay costs
    local Costs = Stronghold.Recruit:GetLeaderCosts(_PlayerID, _EntityType, 0);
    if HasPlayerEnoughResourcesFeedback(_PlayerID, Costs) == 0 then
        return;
    end
    self.Data[_PlayerID].BuyLock = true;
    self.Data[_PlayerID].BuyTimeStamp = Logic.GetCurrentTurn();
    Syncer.InvokeEvent(
        self.NetworkCall,
        self.SyncEvents.BuyCannon,
        _EntityType,
        0,
        _EntityID
    );
    -- Buy unit
    GUIAction_BuyCannon(_EntityType, _UpgradeCategory);
end

function Stronghold.Recruit:BuyUnitTooltip(_Index, _WidgetID, _PlayerID, _EntityID, _EntityType)
    local Text = "";
    local CostsText = "";
    local Shortcut = "";
    if not self:IsUnitAllowed(_EntityID, _EntityType) then
        Text = XGUIEng.GetStringTableText("MenuGeneric/UnitNotAvailable");
    else
        local TypeName = Logic.GetEntityTypeName(_EntityType);
        local Config = Stronghold.Unit.Config:Get(_EntityType, _PlayerID);
        local AutoFillActive = Stronghold.Recruit.Data[_PlayerID].AutoFill[_EntityID] == true;
        local Soldiers = (AutoFillActive and Config.Soldiers) or 0;
        local Costs = Stronghold.Recruit:GetLeaderCosts(_PlayerID, _EntityType, Soldiers);
        CostsText = FormatCostString(_PlayerID, Costs);
        local Name = " @color:180,180,180,255 " ..XGUIEng.GetStringTableText("names/".. TypeName);
        Text = Name.. " @cr " ..XGUIEng.GetStringTableText("sh_description/Unit_" ..TypeName.. "_normal");
        if XGUIEng.IsButtonDisabled(_WidgetID) == 1 then
            local DisabledText = XGUIEng.GetStringTableText("sh_description/Unit_" ..TypeName.. "_disabled");
            local Rank = Stronghold.Rights:GetRankRequiredForRight(_PlayerID, Config.Right);
            local RankName = GetRankName(Rank, _PlayerID);
            DisabledText = string.gsub(DisabledText, "#Rank#", RankName);
            Text = Text.. " @cr " ..DisabledText;
        end
        local KeyText = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [%s]";
        local KeyName = Stronghold.Building.Config.RecuitIndexRecuitShortcut[_Index];
        Shortcut = string.format(KeyText, KeyName);
    end

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180,255 " ..Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostsText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, Shortcut);
end

function Stronghold.Recruit:BuyUnitUpdate(_Index, _WidgetID, _PlayerID, _EntityID, _EntityType, _IconSource)
    if _IconSource then
        XGUIEng.TransferMaterials(_IconSource, _WidgetID);
    end
    local Disabled = 1;
    if  self:IsUnitAllowed(_EntityID, _EntityType)
    and self:HasSufficientRecruiterBuilding(_EntityID, _EntityType)
    and self:HasSufficientProviderBuilding(_EntityID, _EntityType)
    and self:HasSufficientRank(_EntityID, _EntityType) then
        Disabled = 0;
    end
    XGUIEng.DisableButton(_WidgetID, Disabled);
end

-- -------------------------------------------------------------------------- --
-- Castle

function Stronghold.Recruit:OverwriteBuySerfAction()
    GUIAction_BuySerf = function()
        local PlayerID = GetLocalPlayerID();
        local GuiPlayer = GUI.GetPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        if GuiPlayer == 17 or not IsExisting(EntityID) then
            return;
        end
        Stronghold.Recruit:BuySerfAction(PlayerID, EntityID);
    end

    GUITooltip_BuySerf = function()
        local PlayerID = GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
            return;
        end
        Stronghold.Recruit:BuySerfTooltip(PlayerID, EntityID);
    end

    GUIUpdate_BuySerf = function()
        local PlayerID = GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
            return;
        end
        Stronghold.Recruit:BuySerfUpdate(PlayerID, EntityID);
    end
end

function Stronghold.Recruit:BuySerfAction(_PlayerID, _EntityID)
    local WidgetID = "Buy_Serf";
    Stronghold.Recruit:BuyUnitAction(1, WidgetID, _PlayerID, _EntityID, UpgradeCategories.Serf, Entities.PU_Serf);
end

function Stronghold.Recruit:BuySerfTooltip(_PlayerID, _EntityID)
    local GuiPlayer = GetLocalPlayerID();
    if not IsPlayer(GuiPlayer) then
        return false;
    end
    local Text = "";
    local CostText = "";
    local Shortcut = "";
    if not self:IsUnitAllowed(_EntityID, Entities.PU_Serf) then
        Text = XGUIEng.GetStringTableText("MenuGeneric/UnitNotAvailable");
    else
        local Config = Stronghold.Unit.Config:Get(Entities.PU_Serf);
        local Costs = CreateCostTable(unpack(Config.Costs[1]));
        if Logic.IsTechnologyResearched(GuiPlayer, Technologies.T_SlavePenny) == 1 then
            local Factor = Stronghold.Recruit.Config.SlavePenny.CostsFactor;
            Costs[ResourceType.Gold] = math.floor((Costs[ResourceType.Gold] * Factor) + 0.5);
        end
        Text = XGUIEng.GetStringTableText("sh_menuheadquarter/buyserf");
        Shortcut = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText("KeyBindings/BuyUnits1") .. "]";
        CostText = FormatCostString(GuiPlayer, Costs);
    end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostText);
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, Shortcut);
end

function Stronghold.Recruit:BuySerfUpdate(_PlayerID, _EntityID)
    local WidgetID = "Buy_Serf";
    Stronghold.Recruit:BuyUnitUpdate(1, WidgetID, _PlayerID, _EntityID, Entities.PU_Serf, nil);
end

-- -------------------------------------------------------------------------- --
-- Barracks

function GUIAction_BuyMeleeUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if GuiPlayer == 17 or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyMeleeUnitAction(PlayerID, EntityID, _Index);
end

function GUITooltip_BuyMeleeUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyMeleeUnitTooltip(PlayerID, EntityID, _Index);
end

function GUIUpdate_BuyMeleeUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyMeleeUnitUpdate(PlayerID, EntityID, _Index);
end

function Stronghold.Recruit:OnBarracksSelected(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Barracks1 and Type ~= Entities.PB_Barracks2 then
        return;
    end
    for i= 1, 8 do
        local Visble = (self.Data[PlayerID].Roster.Melee[i] and 1) or 0;
        XGUIEng.ShowWidget("Buy_MeleeUnit" ..i, Visble);
        GUIUpdate_BuyMeleeUnit(i);
    end
    XGUIEng.ShowWidget("RallyPoint", 1);
    XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Recruit:BuyMeleeUnitAction(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_MeleeUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Melee[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    if Amount > 0 and XGUIEng.IsButtonDisabled(WidgetID) == 0 then
        Stronghold.Recruit:BuyUnitAction(_Index, WidgetID, _PlayerID, _EntityID, UpgradeCategory, EntityType);
    end
end

function Stronghold.Recruit:BuyMeleeUnitTooltip(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_MeleeUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Melee[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitTooltip(_Index, WidgetID, _PlayerID, _EntityID, EntityType);
end

function Stronghold.Recruit:BuyMeleeUnitUpdate(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_MeleeUnit" .._Index;
    if not self.Data[_PlayerID].Roster.Melee[_Index] then
        XGUIEng.ShowWidget(WidgetID, 0);
        return;
    end
    local UpgradeCategory = self.Data[_PlayerID].Roster.Melee[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    local Config = Stronghold.Unit.Config:Get(EntityType, PlayerID);
    Stronghold.Recruit:BuyUnitUpdate(_Index, WidgetID, _PlayerID, _EntityID, EntityType, Config.Button);
end

-- -------------------------------------------------------------------------- --
-- Archery

function GUIAction_BuyRangedUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if GuiPlayer == 17 or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyRangedUnitAction(PlayerID, EntityID, _Index);
end

function GUITooltip_BuyRangedUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyRangedUnitTooltip(PlayerID, EntityID, _Index);
end

function GUIUpdate_BuyRangedUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyRangedUnitUpdate(PlayerID, EntityID, _Index);
end

function Stronghold.Recruit:OnArcherySelected(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Archery1 and Type ~= Entities.PB_Archery2 then
        return;
    end
    for i= 1, 8 do
        local Visble = (self.Data[PlayerID].Roster.Ranged[i] and 1) or 0;
        XGUIEng.ShowWidget("Buy_RangedUnit" ..i, Visble);
        GUIUpdate_BuyRangedUnit(i);
    end
    XGUIEng.ShowWidget("RallyPoint", 1);
    XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Recruit:BuyRangedUnitAction(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_RangedUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Ranged[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    if Amount > 0 and XGUIEng.IsButtonDisabled(WidgetID) == 0 then
        Stronghold.Recruit:BuyUnitAction(_Index, WidgetID, _PlayerID, _EntityID, UpgradeCategory, EntityType);
    end
end

function Stronghold.Recruit:BuyRangedUnitTooltip(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_RangedUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Ranged[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitTooltip(_Index, WidgetID, _PlayerID, _EntityID, EntityType);
end

function Stronghold.Recruit:BuyRangedUnitUpdate(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_RangedUnit" .._Index;
    if not self.Data[_PlayerID].Roster.Ranged[_Index] then
        XGUIEng.ShowWidget(WidgetID, 0);
        return;
    end
    local UpgradeCategory = self.Data[_PlayerID].Roster.Ranged[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    local Config = Stronghold.Unit.Config:Get(EntityType, PlayerID);
    Stronghold.Recruit:BuyUnitUpdate(_Index, WidgetID, _PlayerID, _EntityID, EntityType, Config.Button);
end

-- -------------------------------------------------------------------------- --
-- Stable

function GUIAction_BuyCavalryUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if GuiPlayer == 17 or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCavalryUnitAction(PlayerID, EntityID, _Index);
end

function GUITooltip_BuyCavalryUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCavalryUnitTooltip(PlayerID, EntityID, _Index);
end

function GUIUpdate_BuyCavalryUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCavalryUnitUpdate(PlayerID, EntityID, _Index);
end

function Stronghold.Recruit:OnStableSelected(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Stable1 and Type ~= Entities.PB_Stable2 then
        return;
    end
    for i= 1, 8 do
        local Visble = (self.Data[PlayerID].Roster.Cavalry[i] and 1) or 0;
        XGUIEng.ShowWidget("Buy_CavalryUnit" ..i, Visble);
        GUIUpdate_BuyCavalryUnit(i);
    end
    XGUIEng.ShowWidget("RallyPoint", 1);
    XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Recruit:BuyCavalryUnitAction(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CavalryUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cavalry[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    if Amount > 0 and XGUIEng.IsButtonDisabled(WidgetID) == 0 then
        Stronghold.Recruit:BuyUnitAction(_Index, WidgetID, _PlayerID, _EntityID, UpgradeCategory, EntityType);
    end
end

function Stronghold.Recruit:BuyCavalryUnitTooltip(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CavalryUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cavalry[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitTooltip(_Index, WidgetID, _PlayerID, _EntityID, EntityType);
end

function Stronghold.Recruit:BuyCavalryUnitUpdate(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CavalryUnit" .._Index;
    if not self.Data[_PlayerID].Roster.Cavalry[_Index] then
        XGUIEng.ShowWidget(WidgetID, 0);
        return;
    end
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cavalry[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    local Config = Stronghold.Unit.Config:Get(EntityType, PlayerID);
    Stronghold.Recruit:BuyUnitUpdate(_Index, WidgetID, _PlayerID, _EntityID, EntityType, Config.Button);
end

-- -------------------------------------------------------------------------- --
-- Foundry

function GUIAction_BuyCannonUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if GuiPlayer == 17 or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCannonUnitAction(PlayerID, EntityID, _Index);
end

function GUITooltip_BuyCannonUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCannonUnitTooltip(PlayerID, EntityID, _Index);
end

function GUIUpdate_BuyCannonUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCannonUnitUpdate(PlayerID, EntityID, _Index);
end

function Stronghold.Recruit:OnFoundrySelected(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Foundry1 and Type ~= Entities.PB_Foundry2 then
        return;
    end
    for i= 1, 8 do
        local Visble = (self.Data[PlayerID].Roster.Cannon[i] and 1) or 0;
        XGUIEng.ShowWidget("Buy_CannonUnit" ..i, Visble);
        GUIUpdate_BuyCannonUnit(i);
    end
    XGUIEng.ShowWidget("Buy_Cannon1", 0);
    XGUIEng.ShowWidget("Buy_Cannon2", 0);
    XGUIEng.ShowWidget("Buy_Cannon3", 0);
    XGUIEng.ShowWidget("Buy_Cannon4", 0);
    XGUIEng.ShowWidget("RallyPoint", 1);
    XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Recruit:BuyCannonUnitAction(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CannonUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cannon[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    if Amount > 0 and XGUIEng.IsButtonDisabled(WidgetID) == 0 then
        Stronghold.Recruit:BuyCannonAction(_Index, WidgetID, _PlayerID, _EntityID, UpgradeCategory, EntityType);
    end
end

function Stronghold.Recruit:BuyCannonUnitTooltip(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CannonUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cannon[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitTooltip(_Index, WidgetID, _PlayerID, _EntityID, EntityType);
end

function Stronghold.Recruit:BuyCannonUnitUpdate(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CannonUnit" .._Index;
    if not self.Data[_PlayerID].Roster.Cannon[_Index] then
        XGUIEng.ShowWidget(WidgetID, 0);
        return;
    end
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cannon[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    local Config = Stronghold.Unit.Config:Get(EntityType, PlayerID);
    Stronghold.Recruit:BuyUnitUpdate(_Index, WidgetID, _PlayerID, _EntityID, EntityType, Config.Button);
end

-- -------------------------------------------------------------------------- --
-- Tavern

function GUIAction_BuyTavernUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if GuiPlayer == 17 or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyTavernUnitAction(PlayerID, EntityID, _Index);
end

function GUITooltip_BuyTavernUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyTavernUnitTooltip(PlayerID, EntityID, _Index);
end

function GUIUpdate_BuyTavernUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyTavernUnitUpdate(PlayerID, EntityID, _Index);
end

function Stronghold.Recruit:OnTavernSelected(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Tavern1 and Type ~= Entities.PB_Tavern2 then
        return;
    end
    for i= 1, 2 do
        local Visble = (self.Data[PlayerID].Roster.Tavern[i] and 1) or 0;
        XGUIEng.ShowWidget("Buy_TavernUnit" ..i, Visble);
        GUIUpdate_BuyTavernUnit(i);
    end
    XGUIEng.ShowWidget("RallyPoint", 1);
    XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Recruit:BuyTavernUnitAction(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_TavernUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Tavern[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    if Amount > 0 and XGUIEng.IsButtonDisabled(WidgetID) == 0 then
        Stronghold.Recruit:BuyUnitAction(_Index, WidgetID, _PlayerID, _EntityID, UpgradeCategory, EntityType);
    end
end

function Stronghold.Recruit:BuyTavernUnitTooltip(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_TavernUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Tavern[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitTooltip(_Index, WidgetID, _PlayerID, _EntityID, EntityType);
end

function Stronghold.Recruit:BuyTavernUnitUpdate(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_TavernUnit" .._Index;
    if not self.Data[_PlayerID].Roster.Tavern[_Index] then
        XGUIEng.ShowWidget(WidgetID, 0);
        return;
    end
    local UpgradeCategory = self.Data[_PlayerID].Roster.Tavern[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    local Config = Stronghold.Unit.Config:Get(EntityType, PlayerID);
    Stronghold.Recruit:BuyUnitUpdate(_Index, WidgetID, _PlayerID, _EntityID, EntityType, Config.Button);
end

-- -------------------------------------------------------------------------- --
-- Auto Fill

function Stronghold.Recruit:InitAutoFillButtons()
    GUIAction_ToggleAutoFill = function()
        local BuildingID = GUI.GetSelectedEntity();
        local PlayerID = Logic.EntityGetPlayer(BuildingID);
        if Stronghold.Recruit.Data[PlayerID] then
            Syncer.InvokeEvent(
                self.NetworkCall,
                self.SyncEvents.ToggleAutoFill,
                BuildingID
            );
        end
    end

    GUIUpdate_ToggleGroupRecruitingButtons = function()
        local BuildingID = GUI.GetSelectedEntity();
        if BuildingID then
            local PlayerID = Logic.EntityGetPlayer(BuildingID);
            local AutoFillActive = Logic.IsAutoFillActive(BuildingID) == 1;
            if Stronghold.Recruit.Data[PlayerID] then
                AutoFillActive = Stronghold.Recruit.Data[PlayerID].AutoFill[BuildingID] == true;
            end
            if AutoFillActive then
                XGUIEng.ShowWidget(gvGUI_WidgetID.RecruitSingleLeader, 1);
                XGUIEng.ShowWidget(gvGUI_WidgetID.RecruitGroups, 0);
            else
                XGUIEng.ShowWidget(gvGUI_WidgetID.RecruitGroups, 1);
                XGUIEng.ShowWidget(gvGUI_WidgetID.RecruitSingleLeader, 0);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Cannon Spam

function Stronghold.Recruit:OverrideCalculateMilitaryUsage()
    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MilitaryAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        local CannonPlaces = Stronghold.Recruit:GetOccupiedSpacesFromCannonsInProgress(_PlayerID);
        return CurrentAmount + CannonPlaces;
    end);
end

-- Registers a foundry for checking the forging process.
function Stronghold.Recruit:RegisterCannonOrder(_PlayerID, _BarracksID, _Type)
    if self.Data[_PlayerID] then
        self.Data[_PlayerID].ForgeRegister[_BarracksID] = _Type;
    end
end

-- Checks the forging process in all registered foundries.
function Stronghold.Recruit:ControlCannonProducers(_PlayerID)
    if self.Data[_PlayerID] then
        for k,v in pairs(self.Data[_PlayerID].ForgeRegister) do
            if not IsExisting(k) or Logic.GetCannonProgress(k) == 100 then
                self.Data[_PlayerID].ForgeRegister[k] = nil;
            end
        end
    end
end

-- Returns the places occupied by cannons currently in production.
function Stronghold.Recruit:GetOccupiedSpacesFromCannonsInProgress(_PlayerID)
    local Places = 0;
    if self.Data[_PlayerID] then
        for k,v in pairs(self.Data[_PlayerID].ForgeRegister) do
            local Size = GetMilitaryPlacesUsedByUnit(v, 1);
            -- Salim passive skill
            if Stronghold.Hero:HasValidLordOfType(_PlayerID, Entities.PU_Hero3) then
                Size = math.floor((Size * Stronghold.Hero.Config.Hero3.UnitPlaceFactor) + 0.5);
            end
            Places = Places + Size;
        end
    end
    return Places;
end

-- -------------------------------------------------------------------------- --
-- Recruit military

function Stronghold.Recruit:UnitRecruiterController(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if IsPlayer(PlayerID) then
        -- Activate autofill
        if Logic.IsBuilding(_EntityID) == 1 then
            GUI.DeactivateAutoFillAtBarracks(_EntityID);
            self.Data[PlayerID].AutoFill[_EntityID] = true;
        end
        -- Add training leader
        if Logic.IsLeader(_EntityID) == 1 then
            local Experience = Stronghold.Hero:ApplyExperiencePassiveAbility(PlayerID, _EntityID, 0);
            if Experience > 0 then
                CEntity.SetLeaderExperience(_EntityID, Experience);
            end
            self.Data[PlayerID].TrainingLeaders[_EntityID] = 0;
        end
        -- Scale units
        if Logic.GetEntityType(_EntityID) == Entities.CV_Cannon1 then
            SVLib.SetEntitySize(_EntityID, 1.35);
            -- Logic.SetSpeedFactor(_EntityID, 1.35);
        end
        if Logic.GetEntityType(_EntityID) == Entities.CV_Cannon2 then
            SVLib.SetEntitySize(_EntityID, 0.65);
            -- Logic.SetSpeedFactor(_EntityID, 0.65);
        end
    end
end

function Stronghold.Recruit:SoldierRecruiterController(_PlayerID)
    if IsPlayer(_PlayerID) then
        -- Update training leaders
        for LeaderID,_ in pairs(self.Data[_PlayerID].TrainingLeaders) do
            local BarracksID = Logic.LeaderGetBarrack(LeaderID);
            if BarracksID == 0 then
                if self.Data[_PlayerID].TrainingLeaders[LeaderID] then
                    BarracksID = self.Data[_PlayerID].TrainingLeaders[LeaderID];
                    self.Data[_PlayerID].TrainingLeaders[LeaderID] = nil;
                    if IsExisting(BarracksID) and self.Data[_PlayerID].AutoFill[BarracksID] then
                        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(LeaderID);
                        local Soldiers = Logic.LeaderGetNumberOfSoldiers(LeaderID);
                        local SoldierAmount = MaxSoldiers - Soldiers;
                        if SoldierAmount > 0 then
                            -- Buy soldiers normally for human players
                            if not IsAIPlayer(_PlayerID) then
                                local EntityType = Logic.GetEntityType(LeaderID);
                                local Places = GetMilitaryPlacesUsedByUnit(EntityType, 1);
                                local Costs = self:GetSoldierCostsByLeaderType(_PlayerID, EntityType, 1);
                                if GUI.GetPlayerID() == _PlayerID then
                                    local MiitaryLimit = GetMilitaryAttractionLimit(_PlayerID);
                                    local MiitaryUsage = GetMilitaryAttractionUsage(_PlayerID);
                                    local MilitarySpace = MiitaryLimit - MiitaryUsage;
                                    for i= 1, SoldierAmount do
                                        if  MilitarySpace >= Places and HasEnoughResources(_PlayerID, Costs) then
                                            Stronghold.Unit:PaySoldiers(_PlayerID, EntityType, 1);
                                            GUI.BuySoldier(LeaderID);
                                            MilitarySpace = MilitarySpace - Places;
                                        end
                                    end
                                end
                            -- Just create soldiers for AI players
                            else
                                local MaxHealth = Logic.GetEntityMaxHealth(LeaderID);
                                local Health = Logic.GetEntityHealth(LeaderID);
                                local Task = Logic.GetCurrentTaskList(LeaderID);
                                if  Health > 0 and Health < MaxHealth and Task
                                and (not string.find(Task, "BATTLE") and not string.find(Task, "DIE")) then
                                    Tools.CreateSoldiersForLeader(LeaderID, SoldierAmount);
                                end
                            end
                        end
                    end
                end
            else
                self.Data[_PlayerID].TrainingLeaders[LeaderID] = BarracksID;
            end
        end
    end
end

