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
        self.Data[i] = {};
    end
    self:CreateUnitButtonHandlers();
    self:StartSerfHealingJob();
    self:OverwriteScoutFindResources();
end

function Stronghold.Unit:OnSaveGameLoaded()
end

function Stronghold.Unit:CreateUnitButtonHandlers()
    self.SyncEvents = {
        BuySoldier = 1,
        BuySoldiers = 2,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            WriteSyncCallToLog("Unit", _Action, _PlayerID, unpack(arg));

            if _Action == Stronghold.Unit.SyncEvents.BuySoldier then
                Stronghold.Unit:BuySoldierActionCallback(_PlayerID, arg[3], arg[1], arg[2]);
                Stronghold.Unit:FillHeroGuard(_PlayerID, arg[3], arg[2]);
            elseif _Action == Stronghold.Unit.SyncEvents.BuySoldiers then
                Stronghold.Unit:BuyMultipleSoldierActionCallback(_PlayerID, unpack(arg));
            end
        end
    );
end

function Stronghold.Unit:FillHeroGuard(_PlayerID, _EntityID, _SoldierAmount)
    if Logic.EntityGetPlayer(_EntityID) ~= _PlayerID then
        return;
    end
    local Type = Logic.GetEntityType(_EntityID);
    if _SoldierAmount > 0 and Type == Entities.CU_BlackKnight then
        local Costs = Stronghold.Recruit:GetSoldierCostsByLeaderType(_PlayerID, Type, _SoldierAmount);
        RemoveResourcesFromPlayer(_PlayerID, Costs);
        Tools.CreateSoldiersForLeader(_EntityID, _SoldierAmount);
    end
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
    or Logic.GetEntityType(_ID) == Entities.CU_TemplarLeaderCavalry1
    or Logic.GetEntityType(_ID) == Entities.CU_TemplarLeaderHeavyCavalry1
    or Logic.GetEntityType(_ID) == Entities.CU_TemplarLeaderPoleArm1
    or Logic.GetEntityType(_ID) == Entities.CU_BanditLeaderCavalry1
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
-- Buy soldiers

function Stronghold.Unit:BuySoldierActionCallback(_PlayerID, _EntityID, _LeaderType, _SoldierAmount)
    if Logic.EntityGetPlayer(_EntityID) ~= _PlayerID then
        return;
    end
    -- Abort if barracks is being upgraded
    if IsBuildingBeingUpgraded(Logic.LeaderGetNearbyBarracks(_EntityID)) then
        return;
    end
    -- Buy soldiers for leader if possible
    local Costs = Stronghold.Recruit:GetSoldierCostsByLeaderType(_PlayerID, _LeaderType, 1);
    local MilitaryLimit = GetMilitaryAttractionLimit(_PlayerID);
    local MilitaryUsage = GetMilitaryAttractionUsage(_PlayerID);
    local RequiredPlaces = GetMilitaryPlacesUsedByUnit(_LeaderType, 1);
    local UnitsToBuy = math.floor(math.max(MilitaryLimit - MilitaryUsage, 0) / RequiredPlaces);
    for i= 1, _SoldierAmount do
        if UnitsToBuy > 0 then
            if  HasEnoughResources(_PlayerID, Costs)
            and HasPlayerSpaceForUnits(_PlayerID, RequiredPlaces)
            and _LeaderType ~= Entities.CU_BlackKnight then
                if GUI.GetPlayerID() == _PlayerID then
                    GUI.BuySoldier(_EntityID);
                end
                UnitsToBuy = UnitsToBuy - 1;
            end
        end
    end
end

function Stronghold.Unit:BuyMultipleSoldierActionCallback(_PlayerID, ...)
    if Logic.EntityGetPlayer(arg[1]) ~= _PlayerID then
        return;
    end
    local RefillData = {};
    -- Get all troops to refill
    local MilitaryLimit = GetMilitaryAttractionLimit(_PlayerID);
    local MilitaryUsage = GetMilitaryAttractionUsage(_PlayerID);
    local PlacesLeft = math.max(MilitaryLimit - MilitaryUsage, 0);
    for _,EntityID in pairs(arg) do
        local BarracksID = Logic.LeaderGetNearbyBarracks(EntityID);
        if  IsExisting(BarracksID) and not IsBuildingBeingUpgraded(BarracksID)
        and PlacesLeft > 0 then
            local LeaderType = Logic.GetEntityType(EntityID);
            local RequiredPlaces = GetMilitaryPlacesUsedByUnit(LeaderType, 1);
            local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(EntityID);
            local CurSoldiers = Logic.LeaderGetNumberOfSoldiers(EntityID);
            local SoldiersToBuy = 0;
            for i= 1, (MaxSoldiers - CurSoldiers) do
                if PlacesLeft >= RequiredPlaces then
                    PlacesLeft = PlacesLeft - RequiredPlaces;
                    SoldiersToBuy = SoldiersToBuy + 1;
                end
            end
            if SoldiersToBuy > 0 then
                table.insert(RefillData, {EntityID, LeaderType, SoldiersToBuy});
            end
        end
    end
    -- Pay costs and refill
    for i= 1, table.getn(RefillData) do
        local EntityID = RefillData[i][1];
        local LeaderType = RefillData[i][2];
        local Soldiers = RefillData[i][3];
        local SoldierCosts = Stronghold.Recruit:GetSoldierCostsByLeaderType(_PlayerID, LeaderType, 1);
        for j= 1, Soldiers do
            if HasEnoughResources(_PlayerID, SoldierCosts) then
                if LeaderType ~= Entities.CU_BlackKnight then
                    if GUI.GetPlayerID() == _PlayerID then
                        GUI.BuySoldier(EntityID);
                    end
                else
                    Tools.CreateSoldiersForLeader(EntityID, 1);
                end
            end
        end
    end
end

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
    -- Check is leader
    local EntityID = SelectedLeader[1];
    local Type = Logic.GetEntityType(EntityID);
    if Logic.IsLeader(EntityID) == 0 and Type ~= Entities.CU_BlackKnight then
        return true;
    end
    -- Check if is being upgraded
    if IsBuildingBeingUpgraded(Logic.LeaderGetNearbyBarracks(EntityID)) then
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
            Sound.PlayQueuedFeedbackSound(Sounds.VoicesLeader_LEADER_NO_rnd_01, 100);
            Message(XGUIEng.GetStringTableText("sh_text/UI_MilitaryLimit"));
            return true;
        end
    end
    -- Check costs
    local Costs = Stronghold.Recruit:GetSoldierCostsByLeaderType(PlayerID, Type, BuyAmount);
    if InterfaceTool_HasPlayerEnoughResources_Feedback(Costs) == 0 then
        return true;
    end
    -- Send event
    Syncer.InvokeEvent(
        Stronghold.Unit.NetworkCall,
        Stronghold.Unit.SyncEvents.BuySoldier,
        Type,
        BuyAmount,
        EntityID
    );
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

function Stronghold.Unit:BuySoldierButtonActionForMultipleLeaders()
    -- Check player
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = GetLocalPlayerID();
    if not IsPlayer(PlayerID) or GuiPlayer ~= PlayerID then
        return true;
    end
    -- Get leaders to fill
    local SelectedLeader = {GUI.GetSelectedEntities()};
    for i= table.getn(SelectedLeader), 1, -1 do
        local Type = Logic.GetEntityType(SelectedLeader[i]);
        if Logic.IsLeader(SelectedLeader[i]) == 0 and Type ~= Entities.CU_BlackKnight then
            table.remove(SelectedLeader, i);
        end
    end
    if table.getn(SelectedLeader) == 0 then
        return true;
    end
    -- Get leaders to refill
    local LeaderToRefill = {};
    for i= 1, table.getn(SelectedLeader) do
        local BarracksID = Logic.LeaderGetNearbyBarracks(SelectedLeader[i]);
        if IsExisting(BarracksID) and not IsBuildingBeingUpgraded(BarracksID) then
            local CurrentSoldiers = Logic.LeaderGetNumberOfSoldiers(SelectedLeader[i]);
            local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(SelectedLeader[i]);
            if CurrentSoldiers < MaxSoldiers then
                table.insert(LeaderToRefill, SelectedLeader[i]);
            end
        end
    end
    -- Send event
    if table.getn(LeaderToRefill) > 0 then
        Syncer.InvokeEvent(
            Stronghold.Unit.NetworkCall,
            Stronghold.Unit.SyncEvents.BuySoldiers,
            unpack(LeaderToRefill)
        );
    end
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

