--- 
--- Outlaw Script
--- 
--- This implements a simple script for non player camps that can be 
--- hostile to all players. Those camps will spawn troops over time and
--- if they get large enough they launch a attack to the closest
--- headquarters or to a specified player.
---
--- They will NOT target inteligently. They are just simple mobs. Their
--- purpose is just to be a inconvenience and not a serious threat. 
--- 

Stronghold = Stronghold or {};

Stronghold.Outlaw = {
    Data = {
        CampSequenceID = 0,
    },
    Config = {},
}

function Stronghold.Outlaw:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            Camps = {},
        };
    end
end

function Stronghold.Outlaw:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --

--- Defines a camp consisting of multiple spawners.
function CreateOutlawCamp(_PlayerID, _HomePosition, _AtkTarget, _AtkArea, _AtkStrength, _AttackDelay, ...)
    local HomePosition = _HomePosition;
    if type(HomePosition) ~= "table" then
        HomePosition = GetPosition(HomePosition);
    end
    local AttackPosition = _AtkTarget;
    if type(AttackPosition) ~= "table" then
        AttackPosition = GetPosition(AttackPosition);
    end
    return Stronghold.Outlaw:CreateCamp(_PlayerID, HomePosition, AttackPosition, _AtkArea, _AtkStrength, _AttackDelay, unpack(arg));
end

--- Deletes an outlaw camp.
function DestroyOutlawCamp(_PlayerID, _CampID)
    return Stronghold.Outlaw:DestroyCamp(_PlayerID, _CampID);
end

--- Adds a new spawner to a camp.
function AddSpawnerToOutlawCamp(_PlayerID, _CampID, _SpawnerID)
    Stronghold.Outlaw:AddSpawner(_PlayerID, _CampID, _SpawnerID);
end

--- Removes an spawner from a camp.
function RemoveSpawnerFromOutlawCamp(_PlayerID, _CampID, _SpawnerID)
    Stronghold.Outlaw:RemoveSpawner(_PlayerID, _CampID, _SpawnerID);
end

--- Allows a camp to send an attack.
function AllowAttackForOutlawCamp(_PlayerID, _CampID, _CanAttack)
    Stronghold.Outlaw:SetAttackAllowed(_PlayerID, _CampID, _CanAttack);
end

--- Changes the attack strength of an outlaw camp.
function SetAttackStrengthOfOutlawCamp(_PlayerID, _CampID, _Strength)
    Stronghold.Outlaw:SetAttackStrength(_PlayerID, _CampID, _Strength);
end

--- Sets the time between two attacks.
function SetAttackDelayOfOutlawCamp(_PlayerID, _CampID, _AtkDelay)
    Stronghold.Outlaw:SetAttackDelay(_PlayerID, _CampID, _AtkDelay);
end

-- Changes the attack target of the outlaw camp.
function SetAttackTargetOfOutlawCamp(_PlayerID, _CampID, _AtkTarget)
    local AttackPosition = _AtkTarget;
    if type(AttackPosition) ~= "table" then
        AttackPosition = GetPosition(AttackPosition);
    end
    Stronghold.Outlaw:SetAttackTarget(_PlayerID, _CampID, AttackPosition);
end

-- -------------------------------------------------------------------------- --

--- A camp starts an attack.
function GameCallback_SH_Logic_OutlawAttackStarted(_PlayerID, _CampID)
end

--- The attack troops of a camp arrived at the target.
function GameCallback_SH_Logic_OutlawAttackArrived(_PlayerID, _CampID)
end

--- An attack of a camp ended.
function GameCallback_SH_Logic_OutlawAttackFinished(_PlayerID, _CampID, _AttackResult)
end

-- -------------------------------------------------------------------------- --

function Stronghold.Outlaw:CreateCamp(_PlayerID, _HomePosition, _AtkTarget, _AtkArea, _AtkStrength, _AtkDelay, ...)
    self.Data.CampSequenceID = self.Data.CampSequenceID +1;
    local Camp = {
        SpawnerList = arg,
        Troops = {},
        State = OutlawAttackState.RecruitUnits,

        ID = self.Data.CampSequenceID,
        PlayerID = _PlayerID,
        Position = _HomePosition,
        AttackTarget = _AtkTarget,
        ActionArea = _AtkArea,
        AttackStrength = _AtkStrength,
        AttackDelay = _AtkDelay,
        AttackTimer = _AtkDelay,
        Anchor = nil,
        IsDefeated = false,
        CanAttack = true,
    };

    local JobID = Job.Turn(function(_PlayerID, _CampID)
        ---@diagnostic disable-next-line: undefined-field
        local PlayerID = math.mod(
            Logic.GetCurrentTurn(),
            GetMaxPlayers()
        );
        if PlayerID == _PlayerID then
            Stronghold.Outlaw:ControlCamp(_PlayerID, _CampID);
        end
    end, _PlayerID, Camp.ID);
    Camp.JobID = JobID;

    self.Data[_PlayerID].Camps[Camp.ID] = Camp;
    return Camp.ID;
end

function Stronghold.Outlaw:DestroyCamp(_PlayerID, _CampID)
    if self.Data[_PlayerID].Camps[_CampID] then
        local Data = self.Data[_PlayerID].Camps[_CampID];
        if JobIsRunning(Data.JobID) then
            EndJob(Data.JobID);
        end
        for i= table.getn(Data.Troops), 1, -1 do
            DestroyEntity(Data.Troops[i]);
        end
        self.Data[_PlayerID].Camps[_CampID] = nil;
    end
end

function Stronghold.Outlaw:SetAttackTarget(_PlayerID, _CampID, _AtkTarget)
    if self.Data[_PlayerID].Camps[_CampID] then
        self.Data[_PlayerID].Camps[_CampID].AttackTarget = _AtkTarget;
    end
end

function Stronghold.Outlaw:SetAttackDelay(_PlayerID, _CampID, _AtkDelay)
    if self.Data[_PlayerID].Camps[_CampID] then
        self.Data[_PlayerID].Camps[_CampID].AttackDelay = _AtkDelay;
        self.Data[_PlayerID].Camps[_CampID].AttackTimer = _AtkDelay;
    end
end

function Stronghold.Outlaw:SetAttackStrength(_PlayerID, _CampID, _AtkStrength)
    if self.Data[_PlayerID].Camps[_CampID] then
        self.Data[_PlayerID].Camps[_CampID].AttackStrength = _AtkStrength;
    end
end

function Stronghold.Outlaw:SetAttackArea(_PlayerID, _CampID, _AtkArea)
    if self.Data[_PlayerID].Camps[_CampID] then
        self.Data[_PlayerID].Camps[_CampID].ActionArea = _AtkArea;
    end
end

function Stronghold.Outlaw:SetAttackAllowed(_PlayerID, _CampID, _CanAttack)
    if self.Data[_PlayerID].Camps[_CampID] then
        self.Data[_PlayerID].Camps[_CampID].CanAttack = _CanAttack == true;
    end
end

function Stronghold.Outlaw:AddSpawner(_PlayerID, _CampID, _SpawnerID)
    if self.Data[_PlayerID].Camps[_CampID] then
        if not IsInTable(_SpawnerID, self.Data[_PlayerID].Camps[_CampID].SpawnerList) then
            table.insert(self.Data[_PlayerID].Camps[_CampID].SpawnerList, _SpawnerID);
        end
    end
end

function Stronghold.Outlaw:RemoveSpawner(_PlayerID, _CampID, _SpawnerID)
    if self.Data[_PlayerID].Camps[_CampID] then
        for i= table.getn(self.Data[_PlayerID].Camps[_CampID].SpawnerList), 1, -1 do
            if self.Data[_PlayerID].Camps[_CampID].SpawnerList[i] == _SpawnerID then
                table.remove(self.Data[_PlayerID].Camps[_CampID].SpawnerList, i);
                break;
            end
        end
    end
end

function Stronghold.Outlaw:GetRaidStrength(_PlayerID, _CampID)
    if self.Data[_PlayerID].Camps[_CampID] then
        local MaxStrength = self.Data[_PlayerID].Camps[_CampID].AttackStrength;
        local Strength = 0;
        for i= table.getn(self.Data[_PlayerID].Camps[_CampID].Troops), 1, -1 do
            local ID = self.Data[_PlayerID].Camps[_CampID].Troops[i];
            local SoldiersMax = Logic.LeaderGetMaxNumberOfSoldiers(ID);
            local SoldiersNow = Logic.LeaderGetNumberOfSoldiers(ID);
            if SoldiersMax > 0 then
                Strength = Strength + (SoldiersNow/SoldiersMax);
            else
                Strength = Strength + 1;
            end
        end
        return Strength / MaxStrength;
    end
    return 0;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Outlaw:ControlCamp(_PlayerID, _CampID)
    if self.Data[_PlayerID].Camps[_CampID] then
        local Data = self.Data[_PlayerID].Camps[_CampID];

        -- Check defeated
        if Data.IsDefeated then
            return true;
        end
        -- Check spawner
        for i= table.getn(Data.SpawnerList), 1, -1 do
            if not IsTroopSpawnerExisting(_PlayerID, Data.SpawnerList[i]) then
                table.remove(self.Data[_PlayerID].Camps[_CampID].SpawnerList, i);
            end
        end
        if table.getn(Data.SpawnerList) == 0 then
            self.Data[_PlayerID].Camps[_CampID].IsDefeated = true;
        end
        -- Check troops
        for i= table.getn(Data.Troops), 1, -1 do
            if not IsExisting(Data.Troops[i]) then
                table.remove(self.Data[_PlayerID].Camps[_CampID].Troops, i);
            end
        end

        if not Data.IsDefeated then
            if Data.State == OutlawAttackState.RecruitUnits then
                self:ExecuteRecruitUnitsBehavior(_PlayerID, _CampID);
            elseif Data.State == OutlawAttackState.DefendBase then
                self:ExecuteDefendBaseBehavior(_PlayerID, _CampID);
            elseif Data.State == OutlawAttackState.AdvanceUnits then
                self:ExecuteAdvanceUnitsBehavior(_PlayerID, _CampID);
            elseif Data.State == OutlawAttackState.StandGround then
                self:ExecuteStandGroundBehavior(_PlayerID, _CampID);
            elseif Data.State == OutlawAttackState.PillageArea then
                self:ExecutePillageAreaBehavior(_PlayerID, _CampID);
            elseif Data.State == OutlawAttackState.RetreatHome then
                self:ExecuteRetreatHomeBehavior(_PlayerID, _CampID);
            end
        end
    end
end

function Stronghold.Outlaw:ExecuteRecruitUnitsBehavior(_PlayerID, _CampID)
    if self.Data[_PlayerID].Camps[_CampID] then
        local Data = self.Data[_PlayerID].Camps[_CampID];
        -- Check for enemies
        local EnemyID = Stronghold.Spawner:GetNextEnemy(_PlayerID, Data.Position, Data.ActionArea);
        if EnemyID ~= 0 then
            self.Data[_PlayerID].Camps[_CampID].State = OutlawAttackState.DefendBase;
            return;
        end
        -- Refill weakened troops
        for i= table.getn(Data.Troops), 1, -1 do
            local ID = self.Data[_PlayerID].Camps[_CampID].Troops[i];
            local Task = Logic.GetCurrentTaskList(ID);
            if (not Task or (not string.find(Task, "BATTLE") and not string.find(Task, "DIE"))) then
                if  Logic.LeaderGetNumberOfSoldiers(ID) < Logic.LeaderGetMaxNumberOfSoldiers(ID)
                and not AreEnemiesInArea(_PlayerID, ID, 2400)
                and GetDistance(ID, Data.Position) <= 1200 then
                    Tools.CreateSoldiersForLeader(ID, 1);
                end
            end
        end
        if Data.CanAttack then
            -- Start attack if possible
            if table.getn(Data.Troops) >= Data.AttackStrength then
                EnemyID = Stronghold.Spawner:GetNextEnemy(_PlayerID, Data.AttackTarget, Data.ActionArea);
                if EnemyID ~= 0 then
                    self.Data[_PlayerID].Camps[_CampID].AttackTimer = Data.AttackTimer -1;
                    if Data.AttackTimer <= 0 then
                        self.Data[_PlayerID].Camps[_CampID].AttackTimer = 0;
                        self.Data[_PlayerID].Camps[_CampID].State = OutlawAttackState.AdvanceUnits;
                        GameCallback_SH_Logic_OutlawAttackStarted(_PlayerID, _CampID);
                    end
                end
                return;
            end
            -- Get troops for attack
            for i= table.getn(Data.SpawnerList), 1, -1 do
                if HasSpawnerFullStrength(_PlayerID, Data.SpawnerList[i]) then
                    local ID = GetTroopFromSpawner(_PlayerID, Data.SpawnerList[i]);
                    table.insert(self.Data[_PlayerID].Camps[_CampID].Troops, ID);
                end
                if table.getn(Data.Troops) >= Data.AttackStrength then
                    break;
                end
            end
        end
    end
end

function Stronghold.Outlaw:ExecuteDefendBaseBehavior(_PlayerID, _CampID)
    if self.Data[_PlayerID].Camps[_CampID] then
        local Data = self.Data[_PlayerID].Camps[_CampID];
        -- Check in defend area
        for i= table.getn(self.Data[_PlayerID].Camps[_CampID].Troops), 1, -1 do
            local ID = self.Data[_PlayerID].Camps[_CampID].Troops[i];
            if GetDistance(ID, Data.Position) > Data.ActionArea then
                Logic.MoveSettler(ID, Data.Position.X, Data.Position.Y);
            end
        end
        -- Check need to defend
        local EnemyID = Stronghold.Spawner:GetNextEnemy(_PlayerID, Data.Position, Data.ActionArea);
        if EnemyID ~= 0 then
            for i= table.getn(self.Data[_PlayerID].Camps[_CampID].Troops), 1, -1 do
                local ID = self.Data[_PlayerID].Camps[_CampID].Troops[i];
                local Task = Logic.GetCurrentTaskList(ID);
                if  (not Task or (not string.find(Task, "BATTLE") and not string.find(Task, "DIE"))) then
                    if Logic.IsEntityInCategory(ID, EntityCategories.Melee) == 1 then
                        local x,y,z = Logic.EntityGetPos(EnemyID);
                        Logic.GroupAttackMove(ID, x, y);
                    else
                        Logic.GroupAttack(ID, EnemyID);
                    end
                end
            end
        else
            self.Data[_PlayerID].Camps[_CampID].State = OutlawAttackState.RecruitUnits;
        end
    end
end

function Stronghold.Outlaw:ExecuteAdvanceUnitsBehavior(_PlayerID, _CampID)
    if self.Data[_PlayerID].Camps[_CampID] then
        local Data = self.Data[_PlayerID].Camps[_CampID];
        -- Check if attack is defeated
        if self:GetRaidStrength(_PlayerID, _CampID) < 0.3 then
            self.Data[_PlayerID].Camps[_CampID].State = OutlawAttackState.RetreatHome;
            return;
        end
        -- Check if attack arrived
        for i= table.getn(Data.Troops), 1, -1 do
            if GetDistance(Data.Troops[i], Data.AttackTarget) <= Data.ActionArea then
                self.Data[_PlayerID].Camps[_CampID].State = OutlawAttackState.PillageArea;
                GameCallback_SH_Logic_OutlawAttackArrived(_PlayerID, _CampID);
                return;
            end
        end
        -- Check enemies
        local ArmyPosition = GetGeometricCenter(unpack(Data.Troops));
        local EnemyID = Stronghold.Spawner:GetNextEnemy(_PlayerID, ArmyPosition, Data.ActionArea);
        if EnemyID ~= 0 then
            self.Data[_PlayerID].Camps[_CampID].Anchor = ArmyPosition;
            self.Data[_PlayerID].Camps[_CampID].State = OutlawAttackState.StandGround;
            return;
        end
        -- Move troops to attack target
        for i= table.getn(Data.Troops), 1, -1 do
            if GetDistance(Data.Troops[i], ArmyPosition) > 1200 then
                self.Data[_PlayerID].Camps[_CampID].Anchor = ArmyPosition;
                self.Data[_PlayerID].Camps[_CampID].State = OutlawAttackState.StandGround;
                return;
            end
            if Logic.IsEntityMoving(Data.Troops[i]) == false then
                Logic.GroupAttackMove(Data.Troops[i], Data.AttackTarget.X, Data.AttackTarget.Y);
            end
        end
    end
end

function Stronghold.Outlaw:ExecuteStandGroundBehavior(_PlayerID, _CampID)
    if self.Data[_PlayerID].Camps[_CampID] then
        local Data = self.Data[_PlayerID].Camps[_CampID];
        -- Check if attack is defeated
        if self:GetRaidStrength(_PlayerID, _CampID) < 0.3 then
            self.Data[_PlayerID].Camps[_CampID].Anchor = nil;
            self.Data[_PlayerID].Camps[_CampID].State = OutlawAttackState.RetreatHome;
            return;
        end
        -- Save distances to anchor
        local AnchorDistance = {};
        for i= table.getn(Data.Troops), 1, -1 do
            AnchorDistance[Data.Troops[i]] = GetDistance(Data.Troops[i], Data.Anchor);
        end
        -- Gather at anchor
        local EnemyID = Stronghold.Spawner:GetNextEnemy(_PlayerID, Data.Anchor, Data.ActionArea);
        if EnemyID == 0 then
            local IsDone = true;
            for i= table.getn(Data.Troops), 1, -1 do
                if AnchorDistance[Data.Troops[i]] > 1200 then
                    IsDone = false;
                    break;
                end
            end
            if IsDone then
                self.Data[_PlayerID].Camps[_CampID].Anchor = nil;
                self.Data[_PlayerID].Camps[_CampID].State = OutlawAttackState.AdvanceUnits;
            else
                for i= table.getn(Data.Troops), 1, -1 do
                    if AnchorDistance[Data.Troops[i]] > 1200 then
                        Logic.MoveSettler(Data.Troops[i], Data.Anchor.X, Data.Anchor.Y);
                    else
                        Logic.GroupStand(Data.Troops[i]);
                    end
                end
            end
            return;
        end
        -- Defend anchor
        local x,y,z = Logic.EntityGetPos(EnemyID);
        for i= table.getn(Data.Troops), 1, -1 do
            local ID = self.Data[_PlayerID].Camps[_CampID].Troops[i];
            local Task = Logic.GetCurrentTaskList(ID);
            if AnchorDistance[Data.Troops[i]] > Data.ActionArea then
                if IsFighting(ID) or Logic.IsEntityMoving(ID) == false then
                    Logic.MoveSettler(Data.Troops[i], Data.Anchor.X, Data.Anchor.Y);
                end
            else
                if (not string.find(Task or "", "BATTLE") and not string.find(Task or "", "DIE")) then
                    if Logic.IsEntityInCategory(Data.Troops[i], EntityCategories.Melee) == 1 then
                        Logic.GroupAttackMove(Data.Troops[i], x, y);
                    else
                        Logic.GroupAttack(Data.Troops[i], EnemyID);
                    end
                end
            end
        end
    end
end

function Stronghold.Outlaw:ExecutePillageAreaBehavior(_PlayerID, _CampID)
    if self.Data[_PlayerID].Camps[_CampID] then
        local Data = self.Data[_PlayerID].Camps[_CampID];
        -- Check if attack is defeated
        local AttackDone = 2;
        if self:GetRaidStrength(_PlayerID, _CampID) >= 0.3 then
            AttackDone = 1;
            -- Search for enemies to kill
            for i= table.getn(Data.Troops), 1, -1 do
                if GetDistance(Data.Troops[i], Data.AttackTarget) > Data.ActionArea then
                    Logic.MoveSettler(Data.Troops[i], Data.AttackTarget.X, Data.AttackTarget.Y);
                    AttackDone = 0;
                else
                    local Task = Logic.GetCurrentTaskList(Data.Troops[i]);
                    local EnemyID = Stronghold.Spawner:GetNextEnemy(_PlayerID, Data.AttackTarget, Data.ActionArea);
                    if EnemyID ~= 0 then
                        local x,y,z = Logic.EntityGetPos(EnemyID);
                        if (not string.find(Task or "", "BATTLE") and not string.find(Task or "", "DIE")) then
                            if Logic.IsEntityInCategory(Data.Troops[i], EntityCategories.Melee) == 1 then
                                Logic.GroupAttackMove(Data.Troops[i], x, y);
                            else
                                Logic.GroupAttack(Data.Troops[i], EnemyID);
                            end
                        end
                        AttackDone = 0;
                    end
                end
            end
        end
        -- End attack if done
        if AttackDone ~= 0 then
            self.Data[_PlayerID].Camps[_CampID].State = OutlawAttackState.RetreatHome;
            for i= table.getn(Data.Troops), 1, -1 do
                Logic.MoveSettler(Data.Troops[i], Data.Position.X, Data.Position.Y);
            end
            GameCallback_SH_Logic_OutlawAttackFinished(_PlayerID, _CampID, AttackDone);
        end
    end
end

function Stronghold.Outlaw:ExecuteRetreatHomeBehavior(_PlayerID, _CampID)
    if self.Data[_PlayerID].Camps[_CampID] then
        local Data = self.Data[_PlayerID].Camps[_CampID];
        -- Move troops back
        if table.getn(Data.Troops) > 0 then
            for i= table.getn(Data.Troops), 1, -1 do
                if GetDistance(Data.Troops[i], Data.Position) > 500 then
                    if Logic.IsEntityMoving(Data.Troops[i]) == false then
                        Logic.MoveSettler(Data.Troops[i], Data.Position.X, Data.Position.Y);
                    end
                else
                    DestroyEntity(Data.Troops[i]);
                end
            end
        -- Prepare for next attack
        else
            self.Data[_PlayerID].Camps[_CampID].State = OutlawAttackState.RecruitUnits;
            self.Data[_PlayerID].Camps[_CampID].AttackTimer = Data.AttackDelay;
        end
    end
end

