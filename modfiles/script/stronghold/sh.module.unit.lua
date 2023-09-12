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
end

function Stronghold.Unit:OnSaveGameLoaded()
end

function Stronghold.Unit:CreateUnitButtonHandlers()
    self.SyncEvents = {
        BuySoldier = 1,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Unit.SyncEvents.BuySoldier then
                Stronghold.Unit:RefillUnit(_PlayerID, arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8], arg[9]);
            end
        end
    );
end

function Stronghold.Unit:StartSerfHealingJob()
    Job.Second(function()
        for i= 1, table.getn(Score.Player) do
            if Logic.IsTechnologyResearched(i, Technologies.T_PublicRecovery) == 1 then
                -- Heal sefs
                for k, EntityID in pairs(GetPlayerEntities(i, Entities.PU_Serf)) do
                    local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
                    local Health = Logic.GetEntityHealth(EntityID);
                    local Task = Logic.GetCurrentTaskList(EntityID);
                    if Health > 0 and Health < MaxHealth and (not Task or not string.find(Task, "DIE")) then
                        Logic.HealEntity(EntityID, math.min(MaxHealth-Health, 2));
                    end
                end
                -- Heal militia
                for k, EntityID in pairs(GetPlayerEntities(i, Entities.PU_BattleSerf)) do
                    local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
                    local Health = Logic.GetEntityHealth(EntityID);
                    local Task = Logic.GetCurrentTaskList(EntityID);
                    if Health > 0 and Health < MaxHealth and (not Task or not string.find(Task, "DIE")) then
                        Logic.HealEntity(EntityID, math.min(MaxHealth-Health, 2));
                    end
                end
            end
        end
    end);
end

-- -------------------------------------------------------------------------- --
-- Buy Unit (Logic)

function Stronghold.Unit:PayUnit(_PlayerID, _Type, _SoldierAmount)
    local Costs = Stronghold.Recruitment:GetLeaderCosts(_PlayerID, _Type, _SoldierAmount);
    RemoveResourcesFromPlayer(_PlayerID, Costs);
    Stronghold.Players[_PlayerID].BuyUnitLock = nil;
end

function Stronghold.Unit:RefillUnit(_PlayerID, _UnitID, _Amount, _Honor, _Gold, _Clay, _Wood, _Stone, _Iron, _Sulfur)
    if IsPlayer(_PlayerID) then
        local LeaderType = Logic.GetEntityType(_UnitID);
        if Stronghold.Unit.Config:Get(LeaderType, _PlayerID) then
            if Logic.GetEntityHealth(_UnitID) > 0 then
                local Task = Logic.GetCurrentTaskList(_UnitID);
                if not Task or (not string.find(Task, "DIE") and not string.find(Task, "BATTLE")) then
                    local BuildingID = Logic.LeaderGetNearbyBarracks(_UnitID);
                    if Logic.IsConstructionComplete(BuildingID) == 0 then
                        return;
                    end
                    local Position = self:GetBarracksDoorPosition((BuildingID ~= 0 and BuildingID) or _UnitID);

                    local Costs = CreateCostTable(unpack({
                        _Honor or 0,
                        _Gold or 0,
                        _Clay or 0,
                        _Wood or 0,
                        _Stone or 0,
                        _Iron or 0,
                        _Sulfur or 0
                    }));

                    RemoveResourcesFromPlayer(_PlayerID, Costs);
                    for i= 1, _Amount do
                        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(_UnitID);
                        local Soldiers = Logic.LeaderGetNumberOfSoldiers(_UnitID);
                        if Soldiers < MaxSoldiers then
                            local SoldierType = Logic.LeaderGetSoldiersType(_UnitID);
                            Logic.CreateEntity(SoldierType, Position.X, Position.Y, 0, _PlayerID);
                            Tools.AttachSoldiersToLeader(_UnitID, 1);
                        end
                    end
                end
            end
        end
        Stronghold.Players[_PlayerID].BuyUnitLock = nil;
    end
end

function Stronghold.Unit:SetFormationOnCreate(_ID)
    if Logic.IsLeader(_ID) == 0 then
        return;
    end

    -- Line formation
    if Logic.GetEntityType(_ID) == Entities.CU_BanditLeaderBow1
    or Logic.GetEntityType(_ID) == Entities.CU_BlackKnight_LeaderMace1
    or Logic.GetEntityType(_ID) == Entities.CU_BlackKnight_LeaderMace2
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
-- Buy Unit (UI)

function Stronghold.Unit:BuySoldierButtonAction()
    local Language = GetLanguage();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) then
        return true;
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
    if BuyAmount < 1 then
        return true;
    end
    if  not Stronghold.Attraction:HasPlayerSpaceForUnits(PlayerID, BuyAmount)
    and not Logic.GetEntityType(EntityID) == Entities.CU_BlackKnight then
        Sound.PlayQueuedFeedbackSound(Sounds.VoicesLeader_LEADER_NO_rnd_01, 100);
        Message(XGUIEng.GetStringTableText("sh_text/UI_MilitaryLimit"));
        return true;
    end

    local Type = Logic.GetEntityType(EntityID);
    local Costs = Stronghold.Recruitment:GetSoldierCostsByLeaderType(PlayerID, Type, BuyAmount);
    if InterfaceTool_HasPlayerEnoughResources_Feedback(Costs) == 0 then
        return true;
    end

    local Task = Logic.GetCurrentTaskList(EntityID);
    if Task and (string.find(Task, "BATTLE") or string.find(Task, "DIE")) then
        return true;
    end

    Stronghold.Players[PlayerID].BuyUnitLock = true;
    Syncer.InvokeEvent(
        Stronghold.Unit.NetworkCall,
        Stronghold.Unit.SyncEvents.BuySoldier,
        EntityID,
        BuyAmount,
        Costs[ResourceType.Honor],
        Costs[ResourceType.Gold],
        Costs[ResourceType.Clay],
        Costs[ResourceType.Wood],
        Costs[ResourceType.Stone],
        Costs[ResourceType.Iron],
        Costs[ResourceType.Sulfur]
    );
    return true;
end

function Stronghold.Unit:BuySoldierButtonTooltip(_KeyNormal, _KeyDisabled, _ShortCut)
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
    local Costs = Stronghold.Recruitment:GetSoldierCostsByLeaderType(PlayerID, Type, BuyAmount);

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
    local PlayerID = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local Type = Logic.GetEntityType(EntityID);
    if IsPlayer(PlayerID) then
        local BarracksID = Logic.LeaderGetNearbyBarracks(EntityID);
        local CurrentSoldiers = Logic.LeaderGetNumberOfSoldiers(EntityID);
        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(EntityID);
        if BarracksID == 0 or CurrentSoldiers == MaxSoldiers then
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

function Stronghold.Unit:GetBarracksDoorPosition(_BarracksID)
    local PlayerID = Logic.EntityGetPlayer(_BarracksID);
    local Position = Stronghold.Players[PlayerID].DoorPos;

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
-- Expel

function Stronghold.Unit:ExpelSettlerButtonTooltip(_Key)
    local PlayerID = GetLocalPlayerID();
    if IsPlayer(PlayerID) then
        if _Key == "MenuCommandsGeneric/expel" then
            local Index = (XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1 and "All") or "Single";
            local Text = XGUIEng.GetStringTableText("sh_text/UI_Expell" ..Index);
            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
            return true;
        end
    end
    return false;
end

function Stronghold.Unit:ExpelSettlerButtonAction()
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) then
        return true;
    end
    if GuiPlayer ~= PlayerID then
        return true;
    end

    -- Stops the player from expeling workers to get new with full energy.
    if Logic.IsWorker(EntityID) == 1 and Logic.GetSettlersWorkBuilding(EntityID) ~= 0 then
        return true;
    end
    if XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1 then
        local Selected = {GUI.GetSelectedEntities()};
        GUI.ClearSelection();
        for i= 1, table.getn(Selected) do
            if Logic.IsHero(Selected[i]) == 0 then
                if Logic.IsLeader(Selected[i]) == 1 then
                    local Soldiers = {Logic.GetSoldiersAttachedToLeader(Selected[i])};
                    for j= 2, Soldiers[1] +1 do
                        GUI.ExpelSettler(Soldiers[j]);
                    end
                end
                GUI.ExpelSettler(Selected[i]);
            end
        end
        return true;
    end
    return false;
end

