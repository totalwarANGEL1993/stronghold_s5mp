--- 
--- Spawner Script
---
--- Allows to define spawner buildings that can produce troops. The spawner can
--- have a different player ID as the troops that will be spawned. Troops can
--- be obtained when full and soldiers are refilled automatically. The spawned
--- troops always have max experience.
--- 

Stronghold = Stronghold or {};

Stronghold.Spawner = {
    Data = {
        SpawnerSequenceID = 0,
    },
    Config = {},
}

function Stronghold.Spawner:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {
            Spawner = {},
        };
    end
end

function Stronghold.Spawner:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --

--- Defines an entity as troop spawner.
function CreateTroopSpawner(_PlayerID, _ScriptName, _SpawnPosition, _SpawnMax, _RespawnTime, _DefArea, ...)
    return Stronghold.Spawner:CreateSpawner(_PlayerID, _ScriptName, _SpawnPosition, _SpawnMax, _RespawnTime, _DefArea, unpack(arg));
end

--- Destroys a spawner (not the entity).
function DestroyTroopSpawner(_PlayerID, _SpawnerID)
    return Stronghold.Spawner:DestroySpawner(_PlayerID, _SpawnerID);
end

--- Returns if all troops are spawned and full.
function HasSpawnerFullStrength(_PlayerID, _SpawnerID)
    return Stronghold.Spawner:HasFullStrength(_PlayerID, _SpawnerID);
end

--- Counts all leaders the spawner has produced.
function CountTroopsBySpawner(_PlayerID, _SpawnerID)
    return Stronghold.Spawner:CountTroops(_PlayerID, _SpawnerID);
end

--- Removes a troop from the spawner and returns it.
function GetTroopFromSpawner(_PlayerID, _SpawnerID)
    return Stronghold.Spawner:GetTroop(_PlayerID, _SpawnerID);
end

--- Checks if the spawner is existing.
function IsTroopSpawnerExisting(_PlayerID, _SpawnerID)
    local Data = Stronghold.Spawner.Data[_PlayerID].Spawner[_SpawnerID];
    return IsExisting(Data.ScriptName) == true;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Spawner:CreateSpawner(_PlayerID, _ScriptName, _SpawnPosition, _SpawnMax, _RespawnTime, _DefArea, ...)
    if _SpawnPosition == nil then
        local Position = GetPosition(_ScriptName);
        local ID = AI.Entity_CreateFormation(_PlayerID, Entities.PU_Serf, 0, 0, Position.X, Position.Y, 0, 0, 0, 0);
        local x,y,z = Logic.EntityGetPos(ID);
        DestroyEntity(ID);
        _SpawnPosition = {X= x, Y= y, Z= z};
    end

    assert(_SpawnMax >= self.Config.Values.SpawnMax);
    assert(_RespawnTime >= self.Config.Values.RespawnTime);
    assert(_DefArea >= self.Config.Values.DefArea);

    self.Data.SpawnerSequenceID = self.Data.SpawnerSequenceID +1;
    local Spawner = {
        AllowedTypes = {},
        SpawnedTroops = {},

        ID = self.Data.SpawnerSequenceID,
        ScriptName = _ScriptName,
        DefendArea = _DefArea,
        PlayerID = _PlayerID,
        SpawnPosition = _SpawnPosition,
        MaxAmount = _SpawnMax,
        RespawnTime = _RespawnTime,
        Timer = 0,
        IsDefeated = false,
    };

    local JobID = Job.Second(
        function(_PlayerID, _SpawnerID)
            Stronghold.Spawner:ControlSpawner(_PlayerID, _SpawnerID);
        end,
        _PlayerID,
        Spawner.ID
    );
    Spawner.JobID = JobID;
    Spawner.AllowedTypes = CopyTable(arg);
    self.Data[_PlayerID].Spawner[Spawner.ID] = Spawner;
    return Spawner.ID;
end

function Stronghold.Spawner:DestroySpawner(_PlayerID, _SpawnerID)
    if self.Data[_PlayerID].Spawner[_SpawnerID] then
        if JobIsRunning(self.Data[_PlayerID].Spawner[_SpawnerID].JobID) then
            EndJob(self.Data[_PlayerID].Spawner[_SpawnerID].JobID);
        end
        self.Data[_PlayerID].Spawner[_SpawnerID] = nil;
    end
end

function Stronghold.Spawner:HasFullStrength(_PlayerID, _SpawnerID)
    if self.Data[_PlayerID].Spawner[_SpawnerID] then
        local MaxAmount = self.Data[_PlayerID].Spawner[_SpawnerID].MaxAmount;
        local curAmount = table.getn(self.Data[_PlayerID].Spawner[_SpawnerID].SpawnedTroops);
        if MaxAmount == curAmount then
            for i= curAmount, 1, -1 do
                local ID = self.Data[_PlayerID].Spawner[_SpawnerID].SpawnedTroops[i];
                if Logic.LeaderGetNumberOfSoldiers(ID) < Logic.LeaderGetMaxNumberOfSoldiers(ID) then
                    return false;
                end
            end
            return true;
        end
    end
    return false;
end

function Stronghold.Spawner:CountTroops(_PlayerID, _SpawnerID)
    if self.Data[_PlayerID].Spawner[_SpawnerID] then
        return table.getn(self.Data[_PlayerID].Spawner[_SpawnerID].SpawnedTroops);
    end
    return 0;
end

function Stronghold.Spawner:GetTroop(_PlayerID, _SpawnerID)
    if self.Data[_PlayerID].Spawner[_SpawnerID] then
        return table.remove(self.Data[_PlayerID].Spawner[_SpawnerID].SpawnedTroops, 1);
    end
    return 0;
end

function Stronghold.Spawner:CreateTroop(_PlayerID, _SpawnerID)
    local Data = self.Data[_PlayerID].Spawner[_SpawnerID];
    local ID = AI.Entity_CreateFormation(
        _PlayerID,
        Data.AllowedTypes[math.random(1, table.getn(Data.AllowedTypes))],
        0,
        16,
        Data.SpawnPosition.X,
        Data.SpawnPosition.Y,
        0,
        0,
        self.Config.Values.Experience,
        16
    );
    table.insert(self.Data[_PlayerID].Spawner[_SpawnerID].SpawnedTroops, ID);
    return ID;
end

function Stronghold.Spawner:GetNextEnemy(_PlayerID, _Position, _Area)
    local EnemiesInArea = GetEnemiesInArea(_PlayerID, _Position, _Area);
    table.sort(EnemiesInArea, function(a, b)
        if not a then return true; end
        if not b then return false; end
        return GetDistance(a, _Position) > GetDistance(b, _Position);
    end);
    return EnemiesInArea[1] or 0;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Spawner:ControlSpawner(_PlayerID, _SpawnerID)
    if self.Data[_PlayerID].Spawner[_SpawnerID] then
        local Data = self.Data[_PlayerID].Spawner[_SpawnerID];

        -- Check existing
        if not IsExisting(Data.ScriptName) then
            self.Data[_PlayerID].Spawner[_SpawnerID].IsDefeated = true;
        end
        if Data.IsDefeated and table.getn(Data.SpawnedTroops) == 0 then
            return true;
        end

        -- Check inital spawn
        if not Data.InitalSpawn then
            for i= 1, Data.MaxAmount do
                self:CreateTroop(_PlayerID, _SpawnerID);
            end
            self.Data[_PlayerID].Spawner[_SpawnerID].InitalSpawn = true;
            return;
        end

        -- Spawn troops
        if not Data.IsDefeated and self:CountTroops(_PlayerID, _SpawnerID) < Data.MaxAmount then
            self.Data[_PlayerID].Spawner[_SpawnerID].Timer = Data.Timer -1;
            if Data.Timer <= 0 then
                self.Data[_PlayerID].Spawner[_SpawnerID].Timer = Data.RespawnTime;
                self:CreateTroop(_PlayerID, _SpawnerID);
            end
        end

        -- Update troops
        for i= table.getn(Data.SpawnedTroops), 1, -1 do
            if not IsExisting(Data.SpawnedTroops[i]) then
                table.remove(Data.SpawnedTroops, i);
            end
        end

        -- Attack near enemies or refill soldiers
        local EnemyID = self:GetNextEnemy(_PlayerID, Data.SpawnPosition, Data.DefendArea);
        for i= table.getn(Data.SpawnedTroops), 1, -1 do
            local ID = Data.SpawnedTroops[i];
            local Task = Logic.GetCurrentTaskList(ID);
            if (not Task or (not string.find(Task, "BATTLE") and not string.find(Task, "DIE"))) then
                if EnemyID ~= 0 then
                    local x,y,z = Logic.EntityGetPos(EnemyID);
                    Logic.GroupAttackMove(ID, x, y);
                else
                    if  Logic.LeaderGetNumberOfSoldiers(ID) < Logic.LeaderGetMaxNumberOfSoldiers(ID)
                    and GetDistance(ID, Data.SpawnPosition) <= Data.DefendArea / 2
                    and not Data.IsDefeated then
                        Tools.CreateSoldiersForLeader(ID, 1);
                    end
                end
            end
        end

        -- Check in defend area
        for i= table.getn(Data.SpawnedTroops), 1, -1 do
            local ID = Data.SpawnedTroops[i];
            local Task = Logic.GetCurrentTaskList(ID);
            local Distance = Data.DefendArea;
            if Task and not string.find(Task, "BATTLE") then
                Distance = Data.DefendArea / 2;
            end
            if GetDistance(Data.SpawnedTroops[i], Data.SpawnPosition) > Distance then
                Logic.MoveSettler(Data.SpawnedTroops[i], Data.SpawnPosition.X, Data.SpawnPosition.Y);
            end
        end
    end
end

