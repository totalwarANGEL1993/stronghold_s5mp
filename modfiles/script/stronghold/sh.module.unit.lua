--- 
--- Unit script
---
--- This script implements al unit specific actions and overwrites their
--- selection menus. Also properties like costs, needed rank, upkeep are
--- also defined here.
--- 

Stronghold = Stronghold or {};

Stronghold.Unit = {
    Data = {},
    Config = {},
}

function Stronghold.Unit:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            Intoxicated = {},
        };
    end
    self:OverwriteScoutFindResources();
end

function Stronghold.Unit:OnSaveGameLoaded()
end

function Stronghold.Unit:OnEntityCreated(_EntityID)
    -- Change formation
    if Logic.IsLeader(_EntityID) == 1 then
        Stronghold.Unit:SetFormationOnCreate(_EntityID);
    end
end

function Stronghold.Unit:OncePerSecond(_PlayerID)
    -- Heal serfs
    self:SelfhealEntitiesJob(_PlayerID);
    -- Scare enemies
    self:FearmongerJob(_PlayerID);
    -- Intoxication
    self:IntoxicationControllerJob(_PlayerID);
end

function Stronghold.Unit:OnEntityHurt(_AttackerID, _AttackedID)
    -- Intoxication
    self:IntoxicateUnit(_AttackerID, _AttackedID);
end

-- -------------------------------------------------------------------------- --
-- Scout

function Stronghold.Unit:OverwriteScoutFindResources()
    GUIAction_ScoutFindResources = function()
        GUI.ActivatePlaceBombCommandState();
    end
end

-- -------------------------------------------------------------------------- --
-- Category mapping

GetUpgradeCategoryByEntityType_CategoryMap = {
    -- Axe
    [Entities.CU_BanditLeaderSword1] = UpgradeCategories.LeaderAxe1,
    [Entities.CU_BanditSoldierSword1] = UpgradeCategories.SoldierAxe1,
    [Entities.CU_BanditLeaderSword2] = UpgradeCategories.LeaderAxe2,
    [Entities.CU_BanditSoldierSword2] = UpgradeCategories.SoldierAxe2,
    -- Bow
    [Entities.CU_BanditLeaderBow1] = UpgradeCategories.BanditLeaderBow1,
    [Entities.CU_BanditSoldierBow1] = UpgradeCategories.BanditSoldierBow1,
    [Entities.PU_LeaderBow1] = UpgradeCategories.LeaderBow1,
    [Entities.PU_SoldierBow1] = UpgradeCategories.SoldierBow1,
    [Entities.PU_LeaderBow2] = UpgradeCategories.LeaderBow2,
    [Entities.PU_SoldierBow2] = UpgradeCategories.SoldierBow2,
    [Entities.PU_LeaderBow3] = UpgradeCategories.LeaderBow3,
    [Entities.PU_SoldierBow3] = UpgradeCategories.SoldierBow3,
    [Entities.PU_LeaderBow4] = UpgradeCategories.LeaderBow4,
    [Entities.PU_SoldierBow4] = UpgradeCategories.SoldierBow4,
    -- Cannons
    [Entities.CV_Cannon1] = UpgradeCategories.Cannon7,
    [Entities.CV_Cannon2] = UpgradeCategories.Cannon8,
    [Entities.PV_Cannon1] = UpgradeCategories.Cannon1,
    [Entities.PV_Cannon2] = UpgradeCategories.Cannon2,
    [Entities.PV_Cannon3] = UpgradeCategories.Cannon3,
    [Entities.PV_Cannon4] = UpgradeCategories.Cannon4,
    [Entities.PV_Cannon7] = UpgradeCategories.Cannon5,
    [Entities.PV_Cannon8] = UpgradeCategories.Cannon6,
    -- Cavalry Heavy
    [Entities.CU_TemplarLeaderHeavyCavalry1] = UpgradeCategories.TemplarLeaderHeavyCavalry1,
    [Entities.CU_TemplarSoldierHeavyCavalry1] = UpgradeCategories.TemplarSoldierHeavyCavalry1,
    [Entities.PU_LeaderHeavyCavalry1] = UpgradeCategories.LeaderHeavyCavalry1,
    [Entities.PU_SoldierHeavyCavalry1] = UpgradeCategories.SoldierHeavyCavalry1,
    [Entities.PU_LeaderHeavyCavalry2] = UpgradeCategories.LeaderHeavyCavalry2,
    [Entities.PU_SoldierHeavyCavalry2] = UpgradeCategories.SoldierHeavyCavalry2,
    -- Cavalry Light
    [Entities.CU_BanditLeaderCavalry1] = UpgradeCategories.BanditLeaderCavalry1,
    [Entities.CU_BanditSoldierCavalry1] = UpgradeCategories.BanditSoldierCavalry1,
    [Entities.CU_TemplarLeaderCavalry1] = UpgradeCategories.TemplarLeaderCavalry1,
    [Entities.CU_TemplarSoldierCavalry1] = UpgradeCategories.TemplarSoldierCavalry1,
    [Entities.PU_LeaderCavalry1] = UpgradeCategories.LeaderCavalry1,
    [Entities.PU_SoldierCavalry1] = UpgradeCategories.SoldierCavalry1,
    [Entities.PU_LeaderCavalry2] = UpgradeCategories.LeaderCavalry2,
    [Entities.PU_SoldierCavalry2] = UpgradeCategories.SoldierCavalry2,
    -- Mace
    [Entities.CU_Barbarian_LeaderClub1] = UpgradeCategories.BarbarianLeader1,
    [Entities.CU_Barbarian_SoldierClub1] = UpgradeCategories.BarbarianSoldier1,
    [Entities.CU_Barbarian_LeaderClub2] = UpgradeCategories.BarbarianLeader2,
    [Entities.CU_Barbarian_SoldierClub2] = UpgradeCategories.BarbarianSoldier2,
    [Entities.CU_BlackKnight_LeaderMace1] = UpgradeCategories.BlackKnightLeader1,
    [Entities.CU_BlackKnight_SoldierMace1] = UpgradeCategories.BlackKnightSoldier1,
    [Entities.CU_BlackKnight_LeaderMace2] = UpgradeCategories.BlackKnightLeader2,
    [Entities.CU_BlackKnight_SoldierMace2] = UpgradeCategories.BlackKnightSoldier2,
    -- Rifle
    [Entities.PU_LeaderRifle1] = UpgradeCategories.LeaderRifle1,
    [Entities.PU_SoldierRifle1] = UpgradeCategories.SoldierRifle1,
    [Entities.PU_LeaderRifle2] = UpgradeCategories.LeaderRifle2,
    [Entities.PU_SoldierRifle2] = UpgradeCategories.SoldierRifle2,
    -- Shrouded
    [Entities.CU_Evil_LeaderBearman1] = UpgradeCategories.BearmanLeader1,
    [Entities.CU_Evil_SoldierBearman1] = UpgradeCategories.BearmanSoldier1,
    [Entities.CU_Evil_LeaderSkirmisher1] = UpgradeCategories.SkirmisherLeader1,
    [Entities.CU_Evil_SoldierSkirmisher1] = UpgradeCategories.SkirmisherSoldier1,
    -- Spear
    [Entities.CU_TemplarLeaderPoleArm1] = UpgradeCategories.TemplarLeaderPoleArm1,
    [Entities.CU_TemplarSoldierPoleArm1] = UpgradeCategories.TemplarSoldierPoleArm1,
    [Entities.PU_LeaderPoleArm1] = UpgradeCategories.LeaderPoleArm1,
    [Entities.PU_SoldierPoleArm1] = UpgradeCategories.SoldierPoleArm1,
    [Entities.PU_LeaderPoleArm2] = UpgradeCategories.LeaderPoleArm2,
    [Entities.PU_SoldierPoleArm2] = UpgradeCategories.SoldierPoleArm2,
    [Entities.PU_LeaderPoleArm3] = UpgradeCategories.LeaderPoleArm3,
    [Entities.PU_SoldierPoleArm3] = UpgradeCategories.SoldierPoleArm3,
    [Entities.PU_LeaderPoleArm4] = UpgradeCategories.LeaderPoleArm4,
    [Entities.PU_SoldierPoleArm4] = UpgradeCategories.SoldierPoleArm4,
    -- Sword
    [Entities.CU_BanditLeaderSword3] = UpgradeCategories.BanditLeaderSword1,
    [Entities.CU_BanditSoldierSword3] = UpgradeCategories.BanditSoldierSword1,
    [Entities.PU_LeaderSword1] = UpgradeCategories.LeaderSword1,
    [Entities.PU_SoldierSword1] = UpgradeCategories.SoldierSword1,
    [Entities.PU_LeaderSword2] = UpgradeCategories.LeaderSword2,
    [Entities.PU_SoldierSword2] = UpgradeCategories.SoldierSword2,
    [Entities.PU_LeaderSword3] = UpgradeCategories.LeaderSword3,
    [Entities.PU_SoldierSword3] = UpgradeCategories.SoldierSword3,
    [Entities.PU_LeaderSword4] = UpgradeCategories.LeaderSword4,
    [Entities.PU_SoldierSword4] = UpgradeCategories.SoldierSword4,
};

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

function Stronghold.Unit:SelfhealEntitiesJob(_PlayerID)
    if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PublicRecovery) == 1 then
        -- Heal sefs
        for k, EntityID in pairs(GetPlayerEntities(_PlayerID, Entities.PU_Serf)) do
            local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
            local Health = Logic.GetEntityHealth(EntityID);
            local Task = Logic.GetCurrentTaskList(EntityID);
            if Health > 0 and Health < MaxHealth and (not Task or not string.find(Task, "DIE")) then
                Logic.HealEntity(EntityID, math.min(MaxHealth-Health, self.Config.Passive.Selfheal.Serf));
            end
        end
        -- Heal militia
        for k, EntityID in pairs(GetPlayerEntities(_PlayerID, Entities.PU_BattleSerf)) do
            local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
            local Health = Logic.GetEntityHealth(EntityID);
            local Task = Logic.GetCurrentTaskList(EntityID);
            if Health > 0 and Health < MaxHealth and (not Task or not string.find(Task, "DIE")) then
                Logic.HealEntity(EntityID, math.min(MaxHealth-Health, self.Config.Passive.Selfheal.Serf));
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Fearmonger

function Stronghold.Unit:FearmongerJob(_PlayerID)
    -- Bearmen
    for k, EntityID in pairs(GetPlayerEntities(_PlayerID, Entities.CU_Evil_LeaderBearman1)) do
        local Chance = math.random(1, 100);
        if Chance <= self.Config.Passive.Fear.EvilChance then
            local Task = Logic.GetCurrentTaskList(EntityID);
            if (not Task or not string.find(Task, "DIE")) then
                self:FearmongerJobInflictFear(EntityID);
            end
        end
    end
    -- Skirmishers
    for k, EntityID in pairs(GetPlayerEntities(_PlayerID, Entities.CU_Evil_LeaderSkirmisher1)) do
        local Chance = math.random(1, 100);
        if Chance <= self.Config.Passive.Fear.EvilChance then
            local Task = Logic.GetCurrentTaskList(EntityID);
            if (not Task or not string.find(Task, "DIE")) then
                self:FearmongerJobInflictFear(EntityID);
            end
        end
    end
end

function Stronghold.Unit:FearmongerJobInflictFear(_LeaderID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_LeaderID, Abilities.AbilityInflictFear);
    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(_LeaderID, Abilities.AbilityInflictFear);
    if TimeLeft ~= RechargeTime then
        return;
    end
    local PlayerID = Logic.EntityGetPlayer(_LeaderID);
    if not AreEnemiesInArea(PlayerID, GetPosition(_LeaderID), 500) then
        return;
    end
    if XNetwork.Manager_DoesExist() == 1 and SendEvent then
        SendEvent.SettlerInflictFear(_LeaderID);
        return;
    end
    GUI.SettlerInflictFear(_LeaderID);
end

-- -------------------------------------------------------------------------- --
-- Intoxication

function Stronghold.Unit:IntoxicationControllerJob(_PlayerID)
    for EntityID, Data in pairs(self.Data[_PlayerID].Intoxicated) do
        if Data[1] <= 0 or not IsExisting(EntityID) then
            self.Data[_PlayerID].Intoxicated[EntityID] = nil;
        else
            local TargetID = EntityID;
            if Logic.IsLeader(EntityID) == 1 then
                local _, SoldierID = Logic.GetSoldiersAttachedToLeader(EntityID);
                TargetID = (SoldierID and SoldierID) or TargetID;
            end
            if IsExisting(TargetID) then
                local Health = Logic.GetEntityHealth(TargetID);
                local MaxHealth = Logic.GetEntityMaxHealth(TargetID);
                local Factor = self.Config.Passive.Bleeding[Data[2]].Factor;
                if Health > 0 then
                    local Damage = math.ceil(MaxHealth * Factor);
                    Logic.HurtEntity(TargetID, math.min(Health, Damage));
                end
                self.Data[_PlayerID].Intoxicated[EntityID][1] = Data[1] -1;
            else
                self.Data[_PlayerID].Intoxicated[EntityID] = nil;
            end
        end
    end
end

function Stronghold.Unit:IntoxicateUnit(_AttackerID, _AttackedID)
    local AttackerType = Logic.GetEntityType(_AttackerID);
    local AttackedOwner = Logic.EntityGetPlayer(_AttackedID);
    if self.Config.Passive.Bleeding[AttackerType] then
        local TargetID = _AttackedID;
        if Logic.IsEntityInCategory(TargetID, EntityCategories.Soldier) == 1 then
            local LeaderID = SVLib.GetLeaderOfSoldier(TargetID);
            TargetID = (LeaderID and LeaderID) or TargetID;
        end
        if  Logic.IsHero(TargetID) == 0
        and math.random(1, 100) <= self.Config.Passive.Bleeding[AttackerType].Chance
        and not self.Data[AttackedOwner].Intoxicated[TargetID] then
            local Time = self.Config.Passive.Bleeding[AttackerType].Duration;
            self.Data[AttackedOwner].Intoxicated[TargetID] = {Time, AttackerType};
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Buy soldiers

function Stronghold.Unit:BuySoldierButtonAction()
    -- Check modifier pressed
    local SelectedLeader = {GUI.GetSelectedEntities()};
    if  XGUIEng.IsModifierPressed(Keys.ModifierControl)== 1
    and table.getn(SelectedLeader) > 0 then
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
    -- Buy soldier
    GUI.BuySoldier(EntityID);
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
                if not Stronghold.Unit.Config.Troops:GetConfig(Type, PlayerID)
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
                table.insert(LeaderToRefill, {SelectedLeader[i], MaxSoldiers - CurrentSoldiers});
            end
        end
    end
    -- Send event
    for i= 1, table.getn(LeaderToRefill) do
        local LeaderID = LeaderToRefill[i][1];
        local Amount = LeaderToRefill[i][2];
        for j= 1, Amount do
            GUI.BuySoldier(LeaderID);
        end
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

