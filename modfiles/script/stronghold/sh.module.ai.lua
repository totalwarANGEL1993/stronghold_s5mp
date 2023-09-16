---
--- AI Enemy
---
--- Allows to create armies and define targets for them. To simplyfy things,
--- armies and managers are mold together.
---
--- TODO: Implement additional things needed for an AI player that acts on
--- its own (based on predefined behaviors, of course).
---

Stronghold = Stronghold or {};

Stronghold.AI = {
    Data = {
        ArmySequence = 0,
        SpawnerSequence = 0,

        Players = {},
        Armies = {},
        Spawner = {},
    },
    Config = {},
};

-- -------------------------------------------------------------------------- --
-- API

--- Creates a new army.
--- @param _PlayerID integer   Owner of army
--- @param _Strength integer   Maximum amount of leaders
--- @param _Position table     Home position of army
--- @param _RodeLength integer Rode length of army
--- @return integer ID of army
function ArmyCreate(_PlayerID, _Strength, _Position, _RodeLength)
    return Stronghold.AI:CreateArmy(_PlayerID, _Strength, _Position, _RodeLength);
end

--- Deletes a army.
--- @param _ArmyID integer ID of army
function ArmyDestroy(_ArmyID)
    Stronghold.AI:DeleteArmy(_ArmyID);
end

--- Synchronizes the actions of all armies.
--- @param ... integer     List of other armies
function ArmySynchronize(...)
    Stronghold.AI:SynchronizeArmies(unpack(arg));
end

--- Desynchronizes all passed armies.
--- @param ... integer     List of other armies
function ArmyDesynchronize(...)
    Stronghold.AI:DesynchronizeArmies(unpack(arg));
end

--- Returns if the army has full strength.
--- @param _ArmyID integer ID of army
--- @return boolean IsFull Army is full
function ArmyHasFullStrength(_ArmyID)
    return Stronghold.AI:HasArmyFullStrength(_ArmyID);
end

--- Adds a leader to the army.
--- @param _ArmyID integer  ID of army
--- @param _TroopID integer ID of leader
--- @return boolean Added Leader was added
function ArmyAddTroop(_ArmyID, _TroopID)
    return Stronghold.AI:AddTroopToArmy(_ArmyID, _TroopID);
end

--- Spawns a leader and adds it to the army.
--- @param _ArmyID integer  ID of army
--- @param _Type integer    Type of leader
--- @param _Position string Spawn location
--- @param _Exp integer?    Experience
--- @return boolean Spawned Leader was spawned
function ArmySpawnTroop(_ArmyID, _Type, _Position, _Exp)
    return Stronghold.AI:SpawnTroopForArmy(_ArmyID, _Type, _Position, _Exp);
end

--- Adds a new attack path to the army.
--- The last entry in the list is the attack target.
--- @param _ArmyID integer ID of army
--- @param ... string      List of path entries
function ArmyAddAttackTarget(_ArmyID, ...)
    Stronghold.AI:AddArmyAttackTarget(_ArmyID, unpack(arg));
end

--- Removes a attack target from the army.
--- @param _ArmyID integer ID of army
--- @param _Target string  Scriptname of target
function ArmyRemoveAttackTarget(_ArmyID, _Target)
    Stronghold.AI:DeleteArmyAttackTarget(_ArmyID, _Target);
end

--- Adds a new guard position to the army.
--- @param _ArmyID integer ID of army
--- @param _Target string  Scriptname of target
function ArmyAddGuardPosition(_ArmyID, _Target)
    Stronghold.AI:AddArmyGuardPosition(_ArmyID, _Target);
end

--- Removes a guard position from the army.
--- @param _ArmyID integer ID of army
--- @param _Target string  Scriptname of target
function ArmyRemoveGuardPosition(_ArmyID, _Target)
    Stronghold.AI:DeleteArmyGuardPosition(_ArmyID, _Target);
end

--- Sets the spawners of the army.
---
--- Previous spawners will be removed.
--- @param _ArmyID integer ID of army
--- @param ... integer     List of spawner IDs
function ArmySetSpawners(_ArmyID, ...)
    Stronghold.AI:SetArmySpawner(_ArmyID, unpack(arg));
end

--- Creates a new spawner.
--- @param _ScriptName string Scriptname of building
--- @param _SpawnPoint string Scriptname of spawnpoint
--- @return integer ID ID of spawner
function SpawnerCreate(_ScriptName, _SpawnPoint)
    return Stronghold.AI:CreateSpawner(_ScriptName, _SpawnPoint)
end

--- Deletes a spawner.
--- @param _SpawnerID integer ID of spawner
function SpawnerDelete(_SpawnerID)
    Stronghold.AI:DeleteSpawner(_SpawnerID);
end

--- Changes the list of types to be spawned.
--- @param _SpawnerID integer ID of spawner
--- @param ... integer        List of types to spawn
function SpawnerSetTypesToSpawn(_SpawnerID, ...)
    Stronghold.AI:SetSpawnerTypes(_SpawnerID, unpack(arg));
end

--- Changes the time between spawn cycles.
--- @param _SpawnerID integer ID of spawner
--- @param _Time integer      Time between spawns
function SpawnerSetFrequency(_SpawnerID, _Time)
    Stronghold.AI:SetSpawnerFrequency(_SpawnerID, _Time);
end

--- Changes the maximum amount to be spawned per cycle.
--- @param _SpawnerID integer ID of spawner
--- @param _Amount integer    Maximum quantity
function SpawnerSetQuantity(_SpawnerID, _Amount)
    Stronghold.AI:SetSpawnerQuantity(_SpawnerID, _Amount);
end

-- -------------------------------------------------------------------------- --
-- Main

function Stronghold.AI:Install()
end

function Stronghold.AI:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --
-- Player

-- TODO

-- -------------------------------------------------------------------------- --
-- Army

function Stronghold.AI:CreateArmy(_PlayerID, _Strength, _Position, _RodeLength)
    self.Data.ArmySequence = self.Data.ArmySequence + 1;
    local ID = self.Data.ArmySequence;

    local ArmyID = AiArmy.New(_PlayerID, _Strength, _Position, _RodeLength);
    local ManagerID = AiArmyManager.Create(ArmyID);
    AiArmy.SetFormationController(ArmyID, self:GetArmyFormationManager());
    AiArmyManager.SetGuardTime(ManagerID, 3*60);

    self.Data.Armies[ID] = {ArmyID, ManagerID};
    return ID;
end

function Stronghold.AI:DeleteArmy(_ArmyID)
    if self.Data.Armies[_ArmyID] then
        local ArmyID = self.Data.Armies[_ArmyID][1];
        local ManagerID = self.Data.Armies[_ArmyID][2];
        AiArmyManager.Delete(ManagerID);
        AiArmy.Delete(ArmyID);
        self.Data.Armies[_ArmyID] = nil;
    end
end

function Stronghold.AI:SynchronizeArmies(_ArmyID, ...)
    if self.Data.Armies[_ArmyID] then
        local ManagerID = self.Data.Armies[_ArmyID][2];
        local OtherList = {};
        for i= 1, table.getn(arg) do
            for k,v in pairs(self.Data.Armies) do
                if k ~= _ArmyID and k == arg[i] then
                    table.insert(OtherList, v[2]);
                end
            end
        end
        AiArmyManager.Synchronize(ManagerID, unpack(OtherList));
    end
end

function Stronghold.AI:DesynchronizeArmies(_ArmyID, ...)
    if self.Data.Armies[_ArmyID] then
        local ManagerID = self.Data.Armies[_ArmyID][2];
        local OtherList = {};
        for i= 1, table.getn(arg) do
            for k,v in pairs(self.Data.Armies) do
                if k ~= _ArmyID and k == arg[i] then
                    table.insert(OtherList, v[2]);
                end
            end
        end
        AiArmyManager.Desynchronize(ManagerID, unpack(OtherList));
    end
end

function Stronghold.AI:HasArmyFullStrength(_ArmyID)
    if self.Data.Armies[_ArmyID] then
        local ArmyID = self.Data.Armies[_ArmyID][1];
        return AiArmy.HasFullStrength(ArmyID);
    end
    return false;
end

function Stronghold.AI:AddTroopToArmy(_ArmyID, _TroopID)
    if self.Data.Armies[_ArmyID] then
        local ArmyID = self.Data.Armies[_ArmyID][1];
        return AiArmy.AddTroop(ArmyID, _TroopID, true);
    end
    return false;
end

function Stronghold.AI:SpawnTroopForArmy(_ArmyID, _Type, _Position, _Exp)
    if self.Data.Armies[_ArmyID] then
        local ArmyID = self.Data.Armies[_ArmyID][1];
        return AiArmy.SpawnTroop(ArmyID, _Type, _Position, _Exp);
    end
    return false;
end

function Stronghold.AI:AddArmyAttackTarget(_ArmyID, ...)
    if self.Data.Armies[_ArmyID] then
        local ManagerID = self.Data.Armies[_ArmyID][2];
        --- @diagnostic disable-next-line: param-type-mismatch
        AiArmyManager.AddAttackTarget(ManagerID, arg);
    end
end

function Stronghold.AI:DeleteArmyAttackTarget(_ArmyID, _Target)
    if self.Data.Armies[_ArmyID] then
        local ManagerID = self.Data.Armies[_ArmyID][2];
        AiArmyManager.RemoveAttackTarget(ManagerID, _Target);
    end
end

function Stronghold.AI:AddArmyGuardPosition(_ArmyID, _Target)
    if self.Data.Armies[_ArmyID] then
        local ManagerID = self.Data.Armies[_ArmyID][2];
        AiArmyManager.AddGuardPosition(ManagerID, _Target);
    end
end

function Stronghold.AI:DeleteArmyGuardPosition(_ArmyID, _Target)
    if self.Data.Armies[_ArmyID] then
        local ManagerID = self.Data.Armies[_ArmyID][2];
        AiArmyManager.RemoveGuardPosition(ManagerID, _Target)
    end
end

function Stronghold.AI:SetArmySpawner(_ArmyID, ...)
    if self.Data.Armies[_ArmyID] then
        local ArmyID = self.Data.Armies[_ArmyID][1];
        for k,v in pairs(self.Data.Spawner) do
            AiTroopSpawner.RemoveArmy(v[1], ArmyID);
            for i= 1, table.getn(arg) do
                if k == arg[i] then
                    AiTroopSpawner.AddArmy(v[1], ArmyID);
                end
            end
        end
    end
end

function Stronghold.AI:GetArmyFormationManager()
    return function(_Army, _TroopID)
        Stronghold.Unit:SetFormationOnCreate(_TroopID);
    end
end

-- -------------------------------------------------------------------------- --
-- Spawner

function Stronghold.AI:CreateSpawner(_ScriptName, _SpawnPoint)
    self.Data.SpawnerSequence = self.Data.SpawnerSequence + 1;
    local ID = self.Data.SpawnerSequence;

    local SpawnerID = AiTroopSpawner.Create {
        ScriptName = _ScriptName,
        SpawnPoint = _SpawnPoint,
        MaxSpawn   = 3,
    }

    self.Data.Spawner[ID] = {SpawnerID};
    return ID;
end

function Stronghold.AI:DeleteSpawner(_SpawnerID)
    if self.Data.Spawner[_SpawnerID] then
        local SpawnerID = self.Data.Spawner[_SpawnerID][1];
        AiTroopSpawner.Delete(SpawnerID);
        self.Data.Spawner[_SpawnerID] = nil;
    end
end

function Stronghold.AI:SetSpawnerTypes(_SpawnerID, ...)
    if self.Data.Spawner[_SpawnerID] then
        local SpawnerID = self.Data.Spawner[_SpawnerID][1];
        AiTroopSpawner.ClearAllowedTypes(SpawnerID);
        for i= 1, table.getn(arg) do
            --- @diagnostic disable-next-line: param-type-mismatch
            AiTroopSpawner.AddAllowedTypes(SpawnerID, arg[i], 0)
        end
    end
end

function Stronghold.AI:SetSpawnerFrequency(_SpawnerID, _Time)
    if self.Data.Spawner[_SpawnerID] then
        local SpawnerID = self.Data.Spawner[_SpawnerID][1];
        AiTroopSpawner.SetSpawnTime(SpawnerID, _Time);
    end
end

function Stronghold.AI:SetSpawnerQuantity(_SpawnerID, _Amount)
    if self.Data.Spawner[_SpawnerID] then
        local SpawnerID = self.Data.Spawner[_SpawnerID][1];
        AiTroopSpawner.SetSpawnAmount(SpawnerID, _Amount);
    end
end

