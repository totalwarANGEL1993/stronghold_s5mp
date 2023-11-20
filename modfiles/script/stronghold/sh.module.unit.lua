--- 
--- Unit script
---
--- This script implements al unit specific actions and overwrites their
--- selection menus. Also properties like costs, needed rank, upkeep are
--- also defined here.
--- 

Stronghold = Stronghold or {};

Stronghold.Unit = {
    SyncEvents = {},
    Data = {},
    Config = {},
}

function Stronghold.Unit:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            BuyTimeStamp = 0,
            BuyLock = false,
        };
    end
    self:CreateUnitButtonHandlers();
    self:StartSerfHealingJob();
    self:OverwriteScoutFindResources();
end

function Stronghold.Unit:OnSaveGameLoaded()
end

function Stronghold.Unit:CreateUnitButtonHandlers()
    self.SyncEvents = {
        ReleaseBuyLock = 1,
        BuySoldier = 2,
        PayCosts = 3,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            WriteSyncCallToLog("Unit", _Action, _PlayerID, unpack(arg));

            if _Action == Stronghold.Unit.SyncEvents.ReleaseBuyLock then
                if Stronghold.Unit.Data[_PlayerID] then
                    Stronghold.Unit.Data[_PlayerID].BuyLock = false;
                end
            elseif _Action == Stronghold.Unit.SyncEvents.BuySoldier then
                Stronghold.Unit:PaySoldiers(_PlayerID, arg[1], arg[2]);
                if GUI.GetPlayerID() == _PlayerID then
                    Syncer.InvokeEvent(self.NetworkCall, self.SyncEvents.ReleaseBuyLock);
                end
            elseif _Action == Stronghold.Unit.SyncEvents.PayCosts then
                Stronghold.Unit:PayCosts(_PlayerID, unpack(arg));
                if GUI.GetPlayerID() == _PlayerID then
                    Syncer.InvokeEvent(self.NetworkCall, self.SyncEvents.ReleaseBuyLock);
                end
            end
        end
    );
end

function Stronghold.Unit:PayUnit(_PlayerID, _Type, _SoldierAmount)
    local Costs = Stronghold.Recruit:GetLeaderCosts(_PlayerID, _Type, _SoldierAmount);
    RemoveResourcesFromPlayer(_PlayerID, Costs);
end

function Stronghold.Unit:PaySoldiers(_PlayerID, _Type, _SoldierAmount)
    local Costs = Stronghold.Recruit:GetSoldierCostsByLeaderType(_PlayerID, _Type, _SoldierAmount);
    RemoveResourcesFromPlayer(_PlayerID, Costs);
end

function Stronghold.Unit:PayCosts(_PlayerID, _Honor, _Gold, _Clay, _Wood, _Stone, _Iron, _Sulfur, _Knowledge)
    local Costs = CreateCostTable(_Honor, _Gold, _Clay, _Wood, _Stone, _Iron, _Sulfur, _Knowledge);
    RemoveResourcesFromPlayer(_PlayerID, Costs);
end

function Stronghold.Unit:OnEntityCreated(_EntityID)
    -- Change formation
    if Logic.IsLeader(_EntityID) == 1 then
        Stronghold.Unit:SetFormationOnCreate(_EntityID);
    end
end

function Stronghold.Unit:OncePerSecond(_PlayerID)
    -- Heal entities
    self:StartSerfHealingJob(_PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Scout

function Stronghold.Unit:OverwriteScoutFindResources()
    GUIAction_ScoutFindResources = function()
        GUI.ActivatePlaceBombCommandState();
    end
end

-- -------------------------------------------------------------------------- --
-- Set formation

function Stronghold.Unit:SetFormationOnCreate(_ID)
    if Logic.IsLeader(_ID) == 0 then
        return;
    end

    -- Line formation
    if Logic.GetEntityType(_ID) == Entities.CU_BlackKnight_LeaderMace1
    or Logic.GetEntityType(_ID) == Entities.CU_BlackKnight_LeaderMace2
    or Logic.GetEntityType(_ID) == Entities.CU_CrusaderLeaderCavalry1
    or Logic.GetEntityType(_ID) == Entities.CU_TemplarLeaderCavalry1
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderSword2
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderSword3
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderSword4
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderRifle1
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderRifle2
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderPoleArm3
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderPoleArm4
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderBow3
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderBow4
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderCavalry1
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderCavalry2 then
        Logic.LeaderChangeFormationType(_ID, 4);
        return;
    end

    -- Arrow formation
    if Logic.GetEntityType(_ID) == Entities.PU_LeaderHeavyCavalry1
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderHeavyCavalry2 then
        Logic.LeaderChangeFormationType(_ID, 6);
        return;
    end

    -- Default: Horde formation
    Logic.LeaderChangeFormationType(_ID, 9);
end

-- -------------------------------------------------------------------------- --
-- Heal units

function Stronghold.Unit:StartSerfHealingJob(_PlayerID)
    if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PublicRecovery) == 1 then
        -- Heal sefs
        for k, EntityID in pairs(GetPlayerEntities(_PlayerID, Entities.PU_Serf)) do
            local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
            local Health = Logic.GetEntityHealth(EntityID);
            local Task = Logic.GetCurrentTaskList(EntityID);
            if Health > 0 and Health < MaxHealth and (not Task or not string.find(Task, "DIE")) then
                Logic.HealEntity(EntityID, math.min(MaxHealth-Health, 2));
            end
        end
        -- Heal militia
        for k, EntityID in pairs(GetPlayerEntities(_PlayerID, Entities.PU_BattleSerf)) do
            local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
            local Health = Logic.GetEntityHealth(EntityID);
            local Task = Logic.GetCurrentTaskList(EntityID);
            if Health > 0 and Health < MaxHealth and (not Task or not string.find(Task, "DIE")) then
                Logic.HealEntity(EntityID, math.min(MaxHealth-Health, 2));
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Buy soldiers single

function Stronghold.Unit:BuySoldierButtonAction()
    -- Check modifier pressed
    local SelectedLeader = {GUI.GetSelectedEntities()};
    if  XGUIEng.IsModifierPressed(Keys.ModifierControl)== 1
    and table.getn(SelectedLeader) > 1 then
        return Stronghold.Unit:BuySoldierButtonActionForMultipleLeaders();
    end
    -- Check player
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = GetLocalPlayerID();
    if not IsPlayer(PlayerID) or GuiPlayer ~= PlayerID then
        return true;
    end
    -- Check buy lock
    if self.Data[PlayerID].BuyTimeStamp + 2 >= Logic.GetCurrentTurn()
    or self.Data[PlayerID].BuyLock then
        return true;
    end
    -- Check is leader
    local EntityID = SelectedLeader[1];
    local Type = Logic.GetEntityType(EntityID);
    if Logic.IsLeader(EntityID) == 0 and Type ~= Entities.CU_BlackKnight then
        return true;
    end
    -- Check needs soldiers
    local BuyAmount = 0;
    local CurrentSoldiers = Logic.LeaderGetNumberOfSoldiers(EntityID);
    local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(EntityID);
    if CurrentSoldiers < MaxSoldiers then
        BuyAmount = 1;
        if XGUIEng.IsModifierPressed(Keys.ModifierControl)== 1 then
            local MiitaryLimit = GetMilitaryAttractionLimit(PlayerID);
            local MiitaryUsage = GetMilitaryAttractionUsage(PlayerID);
            local MilitarySpace = MiitaryLimit - MiitaryUsage;
            BuyAmount = math.min(MaxSoldiers - CurrentSoldiers, MilitarySpace);
        end
    end
    if BuyAmount < 1 then
        return true;
    end
    -- Check space
    if not HasPlayerSpaceForUnits(PlayerID, BuyAmount) then
        if Logic.GetEntityType(EntityID) ~= Entities.CU_BlackKnight then
            GUI.SendPopulationLimitReachedFeedbackEvent(PlayerID);
            return true;
        end
    end
    -- Check costs
    local Costs = Stronghold.Recruit:GetSoldierCostsByLeaderType(PlayerID, Type, BuyAmount);
    if InterfaceTool_HasPlayerEnoughResources_Feedback(Costs) == 0 then
        return true;
    end
    -- Buy soldiers
    self.Data[PlayerID].BuyLock = true;
    self.Data[PlayerID].BuyTimeStamp = Logic.GetCurrentTurn();
    Syncer.InvokeEvent(
        Stronghold.Unit.NetworkCall,
        Stronghold.Unit.SyncEvents.BuySoldier,
        Type,
        BuyAmount,
        EntityID
    );
    for i= 1, BuyAmount do
        GUI.BuySoldier(EntityID);
    end
    return true;
end

function Stronghold.Unit:BuySoldierButtonTooltip(_KeyNormal, _KeyDisabled, _ShortCut)
    -- Check modifier pressed
    local SelectedLeader = {GUI.GetSelectedEntities()};
    if  XGUIEng.IsModifierPressed(Keys.ModifierControl)== 1
    and table.getn(SelectedLeader) > 1 then
        return Stronghold.Unit:BuySoldierButtonTooltipForMultipleLeaders(_KeyNormal, _KeyDisabled, _ShortCut);
    end
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) then
        return false;
    end
    if GuiPlayer ~= PlayerID then
        return true;
    end

    local BuyAmount = 1;
    if XGUIEng.IsModifierPressed(Keys.ModifierControl)== 1 then
        local CurrentSoldiers = Logic.LeaderGetNumberOfSoldiers(EntityID);
        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(EntityID);
        BuyAmount = MaxSoldiers - CurrentSoldiers;
    end

    local Type = Logic.GetEntityType(EntityID);
    local Costs = Stronghold.Recruit:GetSoldierCostsByLeaderType(PlayerID, Type, BuyAmount);

    local Index = (BuyAmount > 1 and "All") or "Single";
    local Text = XGUIEng.GetStringTableText("sh_text/UI_Recruit" ..Index);
    local CostText = FormatCostString(PlayerID, Costs);
    local NeededPlaces = GetMilitaryPlacesUsedByUnit(Type, 1);
    CostText = CostText .. XGUIEng.GetStringTableText("InGameMessages/GUI_NamePlaces") .. ": " .. NeededPlaces;
    if BuyAmount == 0 then
        CostText = "";
    end
    if _KeyNormal == "MenuCommandsGeneric/Buy_Soldier" then
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostText);
    end
    return true;
end

function Stronghold.Unit:BuySoldierButtonUpdate()
    -- Check modifier pressed
    local SelectedLeader = {GUI.GetSelectedEntities()};
    if  XGUIEng.IsModifierPressed(Keys.ModifierControl)== 1
    and table.getn(SelectedLeader) > 1 then
        return Stronghold.Unit:BuySoldierButtonUpdateForMultipleLeaders();
    end
    local PlayerID = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local Type = Logic.GetEntityType(EntityID);
    if IsPlayer(PlayerID) then
        local BarracksID = Logic.LeaderGetNearbyBarracks(EntityID);
        local MaxHealth = Logic.GetEntityMaxHealth(BarracksID);
        local Health = Logic.GetEntityHealth(BarracksID);
        local CurrentSoldiers = Logic.LeaderGetNumberOfSoldiers(EntityID);
        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(EntityID);
        local IsConstructed = Logic.IsConstructionComplete(BarracksID) == 1;
        if BarracksID == 0 or CurrentSoldiers == MaxSoldiers
        or Health / MaxHealth <= 0.2 or not IsConstructed then
            XGUIEng.DisableButton("Buy_Soldier_Button", 1);
        else
            if Type == Entities.CU_BlackKnight then
                XGUIEng.DisableButton("Buy_Soldier_Button", 0);
            else
                if not Stronghold.Unit.Config:Get(Type, PlayerID)
                or Logic.IsLeader(EntityID) == 0 then
                    XGUIEng.DisableButton("Buy_Soldier_Button", 1);
                else
                    XGUIEng.DisableButton("Buy_Soldier_Button", 0);
                end
            end
        end
        return true;
    end
    return false;
end

-- -------------------------------------------------------------------------- --
-- Buy soldiers multiple

function Stronghold.Unit:BuySoldierButtonActionForMultipleLeaders()
    -- Check player
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = GetLocalPlayerID();
    if not IsPlayer(PlayerID) or GuiPlayer ~= PlayerID then
        return true;
    end
    -- Check buy lock
    if self.Data[PlayerID].BuyTimeStamp + 2 >= Logic.GetCurrentTurn()
    or self.Data[PlayerID].BuyLock then
        return true;
    end
    -- Get leaders to fill
    local SelectedLeader = {GUI.GetSelectedEntities()};
    for i= table.getn(SelectedLeader), 1, -1 do
        if Logic.IsLeader(SelectedLeader[i]) == 0 then
            table.remove(SelectedLeader, i);
        end
    end
    if table.getn(SelectedLeader) == 0 then
        return true;
    end
    -- Buy soldiers
    local MiitaryLimit = GetMilitaryAttractionLimit(PlayerID);
    local MiitaryUsage = GetMilitaryAttractionUsage(PlayerID);
    local MilitarySpace = MiitaryLimit - MiitaryUsage;
    local MergedCosts = CreateCostTable(0, 0, 0, 0, 0, 0, 0, 0);
    for i= 1, table.getn(SelectedLeader) do
        local EntityType = Logic.GetEntityType(SelectedLeader[i]);
        local Places = GetMilitaryPlacesUsedByUnit(EntityType, 1);
        local CurrentSoldiers = Logic.LeaderGetNumberOfSoldiers(SelectedLeader[i]);
        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(SelectedLeader[i]);
        for j= 1, MaxSoldiers - CurrentSoldiers do
            if MilitarySpace >= Places then
                local Costs = Stronghold.Recruit:GetSoldierCostsByLeaderType(PlayerID, EntityType, 1);
                MergedCosts = MergeCostTable(MergedCosts, Costs);
                GUI.BuySoldier(SelectedLeader[i]);
                MilitarySpace = MilitarySpace - Places;
            end
        end
    end
    -- Pay costs
    self.Data[PlayerID].BuyLock = true;
    self.Data[PlayerID].BuyTimeStamp = Logic.GetCurrentTurn();
    Syncer.InvokeEvent(
        Stronghold.Unit.NetworkCall,
        Stronghold.Unit.SyncEvents.PayCosts,
        MergedCosts[ResourceType.Honor] or 0,
        MergedCosts[ResourceType.Gold] or 0,
        MergedCosts[ResourceType.Clay] or 0,
        MergedCosts[ResourceType.Wood] or 0,
        MergedCosts[ResourceType.Stone] or 0,
        MergedCosts[ResourceType.Iron] or 0,
        MergedCosts[ResourceType.Sulfur] or 0,
        MergedCosts[ResourceType.Knowledge] or 0
    );
    return true;
end

function Stronghold.Unit:BuySoldierButtonTooltipForMultipleLeaders(_KeyNormal, _KeyDisabled, _ShortCut)
    -- Check player
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = GetLocalPlayerID();
    if not IsPlayer(PlayerID) or GuiPlayer ~= PlayerID then
        return true;
    end
    -- Get costs
    local MergedCosts = CreateCostTable(0, 0, 0, 0, 0, 0, 0, 0);
    local SelectedLeader = {GUI.GetSelectedEntities()};
    for i= table.getn(SelectedLeader), 1, -1 do
        if Logic.IsLeader(SelectedLeader[i]) == 1 then
            local EntityType = Logic.GetEntityType(SelectedLeader[i]);
            local CurrentSoldiers = Logic.LeaderGetNumberOfSoldiers(SelectedLeader[i]);
            local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(SelectedLeader[i]);
            local BuyAmount = MaxSoldiers - CurrentSoldiers;
            if MaxSoldiers - CurrentSoldiers > 0 then
                local Costs = Stronghold.Recruit:GetSoldierCostsByLeaderType(PlayerID, EntityType, BuyAmount);
                MergedCosts = MergeCostTable(MergedCosts, Costs);
            end
        end
    end
    -- Write tooltip
    local Text = XGUIEng.GetStringTableText("sh_text/UI_RecruitAll");
    local CostText = FormatCostString(PlayerID, MergedCosts);
    if _KeyNormal == "MenuCommandsGeneric/Buy_Soldier" then
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostText);
    end
    return true;
end

function Stronghold.Unit:BuySoldierButtonUpdateForMultipleLeaders()
    -- Check player
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = GetLocalPlayerID();
    if not IsPlayer(PlayerID) or GuiPlayer ~= PlayerID then
        return true;
    end
    -- Get weakened groups
    local LeaderList = {};
    local SelectedLeader = {GUI.GetSelectedEntities()};
    for i= table.getn(SelectedLeader), 1, -1 do
        if Logic.IsLeader(SelectedLeader[i]) == 1 then
            local CurrentSoldiers = Logic.LeaderGetNumberOfSoldiers(SelectedLeader[i]);
            local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(SelectedLeader[i]);
            local BarracksID = Logic.LeaderGetNearbyBarracks(SelectedLeader[i]);
            local MaxHealth = Logic.GetEntityMaxHealth(BarracksID);
            local Health = Logic.GetEntityHealth(BarracksID);
            local IsConstructed = Logic.IsConstructionComplete(BarracksID) == 1;
            if BarracksID ~= 0 and MaxSoldiers - CurrentSoldiers > 0
            and Health / MaxHealth > 0.2 and IsConstructed then
                table.insert(LeaderList, SelectedLeader[i]);
            end
        end
    end
    -- Enable/disable
    if SelectedLeader[1] then
        XGUIEng.DisableButton("Buy_Soldier_Button", 0);
    else
        XGUIEng.DisableButton("Buy_Soldier_Button", 1);
    end
    return true;
end

