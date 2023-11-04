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

        Heroes = {},
        Delinquents = {Sequence = 0,},
        Armies = {Sequence = 0,},
    },
    Config = {},
};

function Stronghold.AI:Install()
    Job.Second(function()
        Stronghold.AI:ControlAiPlayerHeroes();
    end);
end

function Stronghold.AI:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --
-- Delinquents

--- Creates a camp.
---
--- The camp needs spawners to have an army.
---
--- #### Configuration
--- * `PlayerID`     - ID of player (Default: [max human player] +1)
--- * `HomePosition` - Center position of camp
--- * `Strength`     - Strength shared by both armies (Default: 4)
--- * `RodeLength`   - Action shared by both armies (Default: 3500)
---
--- @param _Data table Camp configuration
--- @return integer ID ID of camp
function DelinquentsCampCreate(_Data)
    return Stronghold.AI:CreateDelinquentsCamp(_Data);
end

--- Removes a camp. Soldiers will be deleted, buildings not.
--- @param _ID integer ID of camp
function DelinquentsCampDestroy(_ID)
    if Stronghold.AI.Data.Delinquents[_ID] then
        local Data = Stronghold.AI.Data.Delinquents[_ID];
        AiArmyManager.Delete(Data.AttackManagerID);
        AiArmyManager.Delete(Data.DefendManagerID);

        local AttackArmy = AiArmy.Get(Data.AttackArmyID);
        if AttackArmy then
            AttackArmy:Abadon(true);
            AttackArmy:Dispose();
        end
        local DefendArmy = AiArmy.Get(Data.DefendArmyID);
        if DefendArmy then
            DefendArmy:Abadon(true);
            DefendArmy:Dispose();
        end

        Stronghold.AI.Data.Delinquents[_ID] = nil;
    end
end

--- Checks if a camp has at least one spawner left.
--- @param _ID integer ID of camp
--- @return boolean Alive Camp is alive
function DelinquentsCampIsAlive(_ID)
    if Stronghold.AI.Data.Delinquents[_ID] then
        local Data = Stronghold.AI.Data.Delinquents[_ID];
        for i= 1, table.getn(Data.Spawner) do
            if AiArmyRefiller.IsAlive(Data.Spawner[i]) then
                return true;
            end
        end
    end
    return false;
end

--- Creates a spawner for the camp.
--- @param _ID integer ID of camp
--- @param _ScriptName string Scriptname of spawner
--- @param _Time integer Respawn time
--- @param _Amount integer Amount to spawn
--- @param ... integer|table List of troop types
--- @return integer ID ID of spawner
function DelinquentsCampAddSpawner(_ID, _ScriptName, _Time, _Amount, ...)
    local ID = 0;
    if Stronghold.AI.Data.Delinquents[_ID] then
        local Data = Stronghold.AI.Data.Delinquents[_ID];
        local Troops = {};
        for i= 1, table.getn(arg) do
            local Troop = (type(arg[i]) ~= "table" and {arg[i], 0}) or arg[i];
            table.insert(Troops, Troop);
        end
        ID = AiArmyRefiller.CreateSpawner{
            ScriptName   = _ScriptName,
            SpawnPoint   = (IsExisting(_ScriptName.. "Spawn") and _ScriptName.. "Spawn") or nil,
            SpawnAmount  = _Amount,
            SpawnTimer   = _Time,
            Sequentially = true,
            Endlessly    = true,
            AllowedTypes = Troops,
        }
        AiArmyRefiller.AddArmy(ID, Data.AttackArmyID);
        AiArmyRefiller.AddArmy(ID, Data.DefendArmyID);
        table.insert(Stronghold.AI.Data.Delinquents[_ID].Spawner, ID);
    end
    return ID;
end

--- Removes all spawners from the camp.
--- @param _ID integer ID of camp
function DelinquentsCampClearSpawners(_ID)
    if Stronghold.AI.Data.Delinquents[_ID] then
        local Data = Stronghold.AI.Data.Delinquents[_ID];
        for i= 1, table.getn(Data.Spawner) do
            AiArmyRefiller.DeleteRefiller(Data.Spawner[i]);
        end
        Stronghold.AI.Data.Delinquents[_ID].Spawner = {};
    end
end

--- Adds attack targets to the camp.
---
--- If the target is a table, the last element of it becomes the attack target.
--- @param _ID integer ID of camp
--- @param ... string|table List of targets
function DelinquentsCampAddTarget(_ID, ...)
    if Stronghold.AI.Data.Delinquents[_ID] then
        local Data = Stronghold.AI.Data.Delinquents[_ID];
        AiArmyManager.AddAttackTargetPath(Data.AttackArmyID, unpack(arg));
    end
end

--- Removes all attack targets from the camp.
--- @param _ID integer ID of camp
function DelinquentsCampClearTargets(_ID)
    if Stronghold.AI.Data.Delinquents[_ID] then
        local Data = Stronghold.AI.Data.Delinquents[_ID];
        AiArmyManager.ClearAttackTargets(Data.AttackArmyID);
        AiArmyManager.ClearAttackTargets(Data.DefendArmyID);
    end
end

--- Sets if a camp is attacking it's targets.
--- @param _ID integer ID of camp
--- @param _Flag boolean Camp does attack
function DelinquentsCampActivateAttack(_ID, _Flag)
    if Stronghold.AI.Data.Delinquents[_ID] then
        local Data = Stronghold.AI.Data.Delinquents[_ID];
        AiArmyManager.ForbidAttacking(Data.AttackManagerID, _Flag == true);
    end
end

function Stronghold.AI:CreateDelinquentsCamp(_Data)
    -- Camp Data
    local Data = CopyTable(_Data);
    self.Data.Delinquents.Sequence = self.Data.Delinquents.Sequence +1;
    Data.ID = self.Data.Delinquents.Sequence;
    Data.PlayerID = Data.PlayerID or GetMaxHumanPlayers() +1;
    Data.Spawner = {};
    if type(Data.HomePosition) ~= "table" then
        Data.HomePosition = GetPosition(Data.HomePosition);
    end
    -- Attack army
    local AttackArmyID = AiArmy.New(
        Data.PlayerID,
        math.ceil(Data.Strength/2) or 4,
        Data.HomePosition,
        Data.RodeLength or 3500
    );
    AiArmy.SetFormationController(AttackArmyID, function (_ID)
        Stronghold.Unit:SetFormationOnCreate(_ID);
    end);
    Data.AttackArmyID = AttackArmyID;
    local AttackManagerID = AiArmyManager.Create(AttackArmyID);
    Data.AttackManagerID = AttackManagerID;
    -- Defend army
    local DefendArmyID = AiArmy.New(
        Data.PlayerID,
        math.floor(Data.Strength/2) or 4,
        Data.HomePosition,
        Data.RodeLength or 3500
    );
    AiArmy.SetFormationController(DefendArmyID, function (_ID)
        Stronghold.Unit:SetFormationOnCreate(_ID);
    end);
    Data.DefendArmyID = DefendArmyID;
    local DefendManagerID = AiArmyManager.Create(DefendArmyID);
    Data.DefendManagerID = DefendManagerID;

    AiArmyManager.ForbidAttacking(DefendManagerID, true);
    self.Data.Delinquents[Data.ID] = Data;
    return Data.ID;
end

-- -------------------------------------------------------------------------- --
-- Army

--- Creates a regiment with refillers.
---
--- #### Regiment configuration:
--- * `PlayerID`   - (Required) Owner of army
--- * `Strength`   - (Required) Max amount of leaders
--- * `Position`   - (Required) Position of army
--- * `RodeLength` - (Required) Radius of action
---
--- #### Refiller configuration:
--- * `ScriptName`   - (Required) Scriptname of spawner (Can be a list for multiple spawner entities)
--- * `SpawnPoint`   - (Optional) Scriptname of position (Can be a list but must then as large as scriptname list)
--- * `SpawnAmount`  - (Optional) Max amount to spawn per cycle
--- * `SpawnTimer`   - (Optional) Time between spawn cycles
--- * `Sequentially` - (Optional) Order of spawns is sequentially
--- * `Endlessly`    - (Optional) Spawns repeat infinite
--- * `AllowedTypes` - (Optional) List of types {Type, Experience}
---
--- @param _Data table Regiment properties
--- @return integer ID ID of regiment
function CreateRespawningRegiment(_Data)
    return Stronghold.AI:CreateRespawningRegiment(_Data);
end

--- Creates a normal regiment.
---
--- #### Regiment configuration:
--- * `PlayerID`   - (Required) Owner of army
--- * `Strength`   - (Required) Max amount of leaders
--- * `Position`   - (Required) Position of army
--- * `RodeLength` - (Required) Radius of action
---
--- @param _Data table Regiment properties
--- @return integer ID ID of regiment
function CreateRegiment(_Data)
    return Stronghold.AI:CreateRegiment(_Data);
end

--- Destroys an regiment and removes the troops.
--- @param _ID integer ID of army
function DestroyRegiment(_ID)
    if self.Data.Armies[_ID] then
        -- Delete spawners
        if self.Data.Armies[_ID].Spawners then
            local Spawners = self.Data.Armies[_ID].Spawners;
            for i= 1, table.getn(Spawners) do
                AiArmyRefiller.DeleteRefiller(Spawners[i].ID);
            end
        end
        -- Delete manager
        local ManagerID = self.Data.Armies[_ID].ManagerID;
        AiArmyManager.Delete(ManagerID);
        -- Delete army
        local ArmyID = self.Data.Armies[_ID].ArmyID;
        AiArmyData_ArmyIdToArmyInstance[ArmyID]:Abandon(true);
        for EntityID,_ in pairs(AiArmyData_ArmyIdToArmyInstance[ArmyID].CleanUp) do
            DestroyEntity(EntityID);
        end
        AiArmyData_ArmyIdToArmyInstance[ArmyID] = nil;
    end
end

--- Returns the ID of the army.
--- @param _ID integer ID of regiment
--- @return integer ID ID of army
function GetRegimentArmyID(_ID)
    if Stronghold.AI.Data.Armies[_ID] then
        return Stronghold.AI.Data.Armies[_ID].ArmyID;
    end
    return 0;
end

--- Returns the ID of the army manager.
--- @param _ID integer ID of regiment
--- @return integer ID ID of army manager
function GetRegimentManagerID(_ID)
    if Stronghold.AI.Data.Armies[_ID] then
        return Stronghold.AI.Data.Armies[_ID].ManagerID;
    end
    return 0;
end

--- Returns the ID(s) of refiller(s) of the regiment.
--- @param _ID integer ID of regiment
--- @return integer ... Refiller IDs
function GetRegimentSpawnerID(_ID)
    if Stronghold.AI.Data.Armies[_ID] then
        if Stronghold.AI.Data.Armies[_ID].Spawners then
            local Spawners = {};
            for i= 1, table.getn(Stronghold.AI.Data.Armies[_ID].Spawners) do
                table.insert(Spawners, Stronghold.AI.Data.Armies[_ID].Spawners[i]);
            end
            return unpack(Spawners);
        end
    end
    return 0;
end

function Stronghold.AI:CreateRegiment(_Data)
    self.Data.Armies.Sequence = self.Data.Armies.Sequence + 1;
    local ID = self.Data.Armies.Sequence;

    local Data = CopyTable(_Data);
    assert(Data.PlayerID and Data.PlayerID > 0 and Data.PlayerID <= table.getn(Score.Player));
    assert(Data.Strength and Data.Strength > 0);
    assert(Data.Position and IsValidPosition(Data.Position));
    assert(Data.RodeLength and Data.RodeLength > 0);

    -- Create army
    local ArmyID = AiArmy.New(Data.PlayerID, Data.Strength, Data.Position, Data.RodeLength);
    AiArmy.SetFormationController(ArmyID, function (_ID)
        Stronghold.Unit:SetFormationOnCreate(_ID);
    end);
    Data.ArmyID = ArmyID;
    -- Create manager
    local ManagerID = AiArmyManager.Create(ArmyID);
    Data.ManagerID = ManagerID;

    self.Data.Armies[ID] = Data;
    return ID;
end

function Stronghold.AI:CreateRespawningRegiment(_Data)
    local ID = self:CreateArmy(_Data);
    local Data = self.Data.Armies[ID];

    assert(_Data.ScriptName);
    assert(type(_Data.AllowedTypes) == "table");
    if type(_Data.ScriptName) ~= "table" then
        _Data.ScriptName = {_Data.ScriptName};
    end
    if _Data.SpawnPoint and type(_Data.SpawnPoint) ~= "table" then
        _Data.SpawnPoint = {_Data.SpawnPoint};
    end
    assert(table.getn(_Data.ScriptName) == table.getn(_Data.SpawnPoint));

    Data.Spawners = {};
    for i= 1, table.getn(_Data.ScriptName) do
        Data.Spawners[i].ScriptName = _Data.ScriptName[i];
        if _Data.SpawnPoint then
            Data.Spawners[i].SpawnPoint = _Data.SpawnPoint[i];
        end
        Data.Spawners[i].SpawnAmount = _Data.SpawnAmount;
        Data.Spawners[i].SpawnTimer = _Data.SpawnTimer;
        Data.Spawners[i].Sequentially = _Data.Sequentially;
        Data.Spawners[i].Endlessly = _Data.Endlessly;
        Data.Spawners[i].AllowedTypes = _Data.AllowedTypes;

        local RefillerID = AiArmyRefiller.CreateSpawner(Data.Spawners[i]);
        Data.Spawners[i].ID = RefillerID;
    end

    self.Data.Armies[ID] = Data;
    return ID;
end

function Stronghold.AI:CreateInvadingRegiment(_Data)
    local ID = self:CreateArmy(_Data);
    local Data = self.Data.Armies[ID];

    -- TODO

    self.Data.Armies[ID] = Data;
    return ID;
end

-- -------------------------------------------------------------------------- --
-- Hero

function Stronghold.AI:ControlAiPlayerHeroes()
    for PlayerID = 1, GetMaxPlayers() do
        if IsAIPlayer(PlayerID) then
            if not self.Data.Heroes[PlayerID] then
                self.Data.Heroes[PlayerID] = {State = 1}
            end

            local HeroID = Stronghold:GetPlayerHero(PlayerID);
            local Type = Logic.GetEntityType(HeroID);
            if IsEntityValid(HeroID) then
                local DoorPos = Stronghold.Players[PlayerID].DoorPos;
                local OuterMaxDistance = 6000;
                local InnerMaxDistance = 4000;
                local PeaceDistance = 500;

                -- Find enemies
                if self.Data.Heroes[PlayerID].State == 1 then
                    if AreEnemiesInArea(PlayerID, DoorPos, InnerMaxDistance) then
                        self.Data.Heroes[PlayerID].State = 2;
                    else
                        if GetDistance(HeroID, DoorPos) > PeaceDistance then
                            self.Data.Heroes[PlayerID].State = 3;
                            Logic.MoveSettler(HeroID, DoorPos.X, DoorPos.Y);
                            for k,v in pairs(GetPlayerEntities(PlayerID, Entities.CU_Hero13_Summon)) do
                                Move(v, "DoorP" ..PlayerID);
                            end
                        end
                    end
                -- Battle enemies
                elseif self.Data.Heroes[PlayerID].State == 2 then
                    local MaxDistance = InnerMaxDistance;
                    if IsFighting(HeroID) then
                        MaxDistance = OuterMaxDistance;
                    end
                    if Type == Entities.PU_Hero5 or Type == Entities.PU_Her10 then
                        MaxDistance = MaxDistance - 1500;
                    end
                    if not AreEnemiesInArea(PlayerID, DoorPos, InnerMaxDistance) then
                        self.Data.Heroes[PlayerID].State = 3;
                        Logic.MoveSettler(HeroID, DoorPos.X, DoorPos.Y);
                        for k,v in pairs(GetPlayerEntities(PlayerID, Entities.CU_Hero13_Summon)) do
                            Move(v, "DoorP" ..PlayerID);
                        end
                    else
                        self:ControlAiPlayerHero(PlayerID, HeroID);
                    end
                -- Return home
                elseif self.Data.Heroes[PlayerID].State == 3 then
                    if Logic.IsEntityMoving(HeroID) == false then
                        Logic.MoveSettler(HeroID, DoorPos.X, DoorPos.Y);
                    end
                    if GetDistance(HeroID, DoorPos) <= PeaceDistance then
                        self.Data.Heroes[PlayerID].State = 1;
                    end
                end
            else
                self.Data.Heroes[PlayerID].State = 1;
            end
        end
    end
end

function Stronghold.AI:ControlAiPlayerHero(_PlayerID, _HeroID)
    local Type = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(Type);

    if string.find(TypeName, "^PU_Hero1[abc]+$") then
        self:ControlHero1DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero2 then
        self:ControlHero2DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero3 then
        self:ControlHero3DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero4 then
        self:ControlHero4DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero5 then
        self:ControlHero5DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero6 then
        self:ControlHero6DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.CU_BlackKnight then
        self:ControlHero7DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.CU_Mary_de_Mortfichet then
        self:ControlHero8DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.CU_Barbarian_Hero then
        self:ControlHero9DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero10 then
        self:ControlHero10DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero11 then
        self:ControlHero11DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.CU_Evil_Queen then
        self:ControlHero12DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.CU_Hero13 then
        self:ControlHero13DefendCastle(_PlayerID, _HeroID);
    end
end

-- Hero 1

function Stronghold.AI:ControlHero1DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Scare enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityInflictFear(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 2

function Stronghold.AI:ControlHero2DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Place bomb unter hero
        --- @diagnostic disable-next-line: undefined-field
        if math.mod(math.floor(Logic.GetTime()), 90) == 0 then
            local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
            if table.getn(CloseEnemies) >= 5 then
                local x,y,z = Logic.EntityGetPos(_HeroID);
                local ID = Logic.CreateEntity(Entities.XD_Bomb1, x, y, 0, _PlayerID);
                WriteEntityCreatedToLog(_PlayerID, ID, Logic.GetEntityType(ID));
            end
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 3

function Stronghold.AI:ControlHero3DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Place "trap" near random enemy
        --- @diagnostic disable-next-line: undefined-field
        if math.mod(math.floor(Logic.GetTime()), 90) == 0 then
            local Selected = math.random(1, table.getn(FarEnemyList));
            local EnemyID = FarEnemyList[Selected];
            local x,y,z = Logic.EntityGetPos(EnemyID);
            local ID = Logic.CreateEntity(Entities.XD_Bomb1, x, y, 0, _PlayerID);
            WriteEntityCreatedToLog(_PlayerID, ID, Logic.GetEntityType(ID));
            SVLib.SetInvisibility(ID, true);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 4

function Stronghold.AI:ControlHero4DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Hurt enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityCircularAttack(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 5

function Stronghold.AI:ControlHero5DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Hurt enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1800);
        local Selected = math.random(1, table.getn(CloseEnemies));
        local EnemyID = CloseEnemies[Selected];
        if Logic.IsSettler(EnemyID) == 1 then
            if Logic.IsEntityInCategory(EnemyID, EntityCategories.Soldier) == 1 then
                EnemyID = SVLib.GetLeaderOfSoldier(EnemyID);
            end
            self:HeroTriggerAbilityShuriken(_HeroID, EnemyID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 6

function Stronghold.AI:ControlHero6DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Buff allies
        local AllyAmount = Logic.GetPlayerEntitiesInArea(_PlayerID, 0, HeroPos.X, HeroPos.Y, 1500, 16);
        if AllyAmount > 5 then
            self:HeroTriggerAbilityAffectUnits(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 7

function Stronghold.AI:ControlHero7DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Debuff enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityAffectUnits(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 8

function Stronghold.AI:ControlHero8DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Hurt enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityCircularAttack(_HeroID);
            self:HeroTriggerAbilityAffectUnits(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 9

function Stronghold.AI:ControlHero9DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Summon wolves
        if Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.CU_Barbarian_Hero_wolf) == 0 then
            local EnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 2000);
            if table.getn(EnemyList) > 0 then
                self:HeroTriggerAbilitySummon(_HeroID);
                return;
            end
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);

            local WolfList = GetPlayerEntities(_PlayerID, Entities.CU_Barbarian_Hero_wolf);
            for i= 1, table.getn(WolfList) do
                if not IsFighting(WolfList[i]) then
                    Logic.GroupAttackMove(WolfList[i], EnemyPos.X, EnemyPos.Y);
                end
            end
        end
    end
end

-- Hero 10

function Stronghold.AI:ControlHero10DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Buff allies
        local AllyAmount = Logic.GetPlayerEntitiesInArea(_PlayerID, 0, HeroPos.X, HeroPos.Y, 1500, 16);
        if AllyAmount > 5 then
            self:HeroTriggerAbilityAffectUnits(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 11

function Stronghold.AI:ControlHero11DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Scare enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityInflictFear(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 12

function Stronghold.AI:ControlHero12DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Hurt enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityCircularAttack(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 13

function Stronghold.AI:ControlHero13DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    local HeroPos = GetPosition(_HeroID);
    if table.getn(FarEnemyList) > 0 then
        -- Summon Doppelganger if needed
        if Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.CU_Hero13_Summon) == 0 then
            local EnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 2000);
            if table.getn(EnemyList) > 0 then
                self:HeroTriggerAbilitySummon(_HeroID);
                return;
            end
        end

        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);

            local Doppelganger = GetPlayerEntities(_PlayerID, Entities.CU_Hero13_Summon);
            for i= 1, table.getn(Doppelganger) do
                if not IsFighting(Doppelganger[i]) then
                    Logic.GroupAttackMove(Doppelganger[i], EnemyPos.X, EnemyPos.Y);
                end
            end
        end

        -- Buff allies
        local AllyAmount = Logic.GetPlayerEntitiesInArea(_PlayerID, 0, HeroPos.X, HeroPos.Y, 1500, 16);
        if AllyAmount > 5 then
            self:HeroTriggerAbilityAffectUnits(_HeroID);
        end

        -- Circula attack
        local Doppelganger = GetPlayerEntities(_PlayerID, Entities.CU_Hero13_Summon);
        for i= 1, table.getn(Doppelganger) do
            local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(Doppelganger[i]), 300);
            if table.getn(CloseEnemies) >= 1 then
                self:HeroTriggerAbilityCircularAttack(Doppelganger[i]);
            end
        end
    end
end

-- Helper

function Stronghold.AI:HeroTriggerAbilityInflictFear(_HeroID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilityInflictFear);
    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(_HeroID, Abilities.AbilityInflictFear);
    if TimeLeft ~= RechargeTime then
        return;
    end
    if XNetwork.Manager_DoesExist() == 1 and SendEvent then
        SendEvent.SettlerInflictFear(_HeroID);
        return;
    end
    GUI.SettlerInflictFear(_HeroID);
end

function Stronghold.AI:HeroTriggerAbilityAffectUnits(_HeroID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilityRangedEffect);
    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(_HeroID, Abilities.AbilityRangedEffect);
    if TimeLeft ~= RechargeTime then
        return;
    end
    if XNetwork.Manager_DoesExist() == 1 and SendEvent then
        SendEvent.SettlerAffectUnitsInArea(_HeroID);
        return;
    end
    GUI.SettlerAffectUnitsInArea(_HeroID);
end

function Stronghold.AI:HeroTriggerAbilityCircularAttack(_HeroID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilityCircularAttack);
    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(_HeroID, Abilities.AbilityCircularAttack);
    if TimeLeft ~= RechargeTime then
        return;
    end
    if XNetwork.Manager_DoesExist() == 1 and SendEvent then
        SendEvent.SettlerCircularAttack(_HeroID);
        return;
    end
    GUI.SettlerCircularAttack(_HeroID);
end

function Stronghold.AI:HeroTriggerAbilitySummon(_HeroID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilitySummon);
    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(_HeroID, Abilities.AbilitySummon);
    if TimeLeft ~= RechargeTime then
        return;
    end
    if XNetwork.Manager_DoesExist() == 1 and SendEvent then
        SendEvent.SettlerSummon(_HeroID);
        return;
    end
    GUI.SettlerSummon(_HeroID);
end

function Stronghold.AI:HeroTriggerAbilityShuriken(_HeroID, _TargetID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilityShuriken);
    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(_HeroID, Abilities.AbilityShuriken);
    if TimeLeft ~= RechargeTime then
        return;
    end
    if XNetwork.Manager_DoesExist() == 1 and SendEvent then
        SendEvent.HeroShuriken(_HeroID, _TargetID);
        return;
    end
    GUI.SettlerSummon(_HeroID, _TargetID);
end

