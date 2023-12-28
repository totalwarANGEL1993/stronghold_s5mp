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

        Animals = {},
        AnimalsBlacklist = {},

        Heroes = {},
        Delinquents = {Sequence = 0,},
        Armies = {Sequence = 0,},
    },
    Config = {},
};

function Stronghold.AI:Install()
    Display.SetPlayerColorMapping(GetVagabondPlayerID(), GetVagabondPlayerColor());
    Display.SetPlayerColorMapping(GetNeutralPlayerID(), GetNeutralPlayerColor());
    for PlayerID = 1, GetMaxHumanPlayers() do
        SetHostile(PlayerID, GetVagabondPlayerID());
        SetNeutral(PlayerID, GetNeutralPlayerID());
    end

    self:OverwriteAiTargetConfig();
    self:OverwriteAiSpeedConfig();
    self:InitAnimals();

    Job.Second(function()
        Stronghold.AI:ControlAiPlayerHeroes();
    end);
end

function Stronghold.AI:OnSaveGameLoaded()
    Display.SetPlayerColorMapping(GetVagabondPlayerID(), GetVagabondPlayerColor());
    Display.SetPlayerColorMapping(GetNeutralPlayerID(), GetNeutralPlayerColor());
end

function Stronghold.AI:OncePerSecond(_PlayerID)
    -- Control animals
    if GetNeutralPlayerID() == _PlayerID then
        self:ControlMigratoryAnimal();
    end
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
        AiArmy.Delete(Data.AttackArmyID);
        AiArmy.Delete(Data.DefendArmyID);

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
            ScriptName    = _ScriptName,
            SpawnPoint    = (IsExisting(_ScriptName.. "Spawn") and _ScriptName.. "Spawn") or nil,
            SpawnAmount   = _Amount,
            SpawnTimer    = _Time,
            Sequentially  = true,
            Endlessly     = true,
            AllowedTypes  = Troops,
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
    local TargetTable = CopyTable(arg);
    table.insert(TargetTable, 1, table.getn(TargetTable));
    if Stronghold.AI.Data.Delinquents[_ID] then
        local Data = Stronghold.AI.Data.Delinquents[_ID];
        -- Check if target is allready contained
        for i= Data.AttackTargets[1] +1, 2, -1 do
            if Data.AttackTargets[i][Data.AttackTargets[i][1]] == TargetTable[TargetTable[1] +1] then
                return;
            end
        end
        -- Add to targets
        table.insert(Data.AttackTargets, TargetTable);
        Data.AttackTargets[1] = Data.AttackTargets[1] + 1;
        Stronghold.AI.Data.Delinquents[_ID] = Data;
    end
end

--- Removes all attack targets from the camp.
--- @param _ID integer ID of camp
function DelinquentsCampClearTargets(_ID)
    if Stronghold.AI.Data.Delinquents[_ID] then
        Stronghold.AI.Data.Delinquents[_ID].AttackTargets = {0};
    end
end

--- Adds guard positions to the camp.
--- @param _ID integer ID of camp
--- @param _Position string|table List of targets
function DelinquentsCampAddGuardPositions(_ID, _Position)
    if Stronghold.AI.Data.Delinquents[_ID] then
        local Data = Stronghold.AI.Data.Delinquents[_ID];
        -- Check if target is allready contained
        for i= Data.DefendTargets[1] +1, 2, -1 do
            if Data.DefendTargets[i] == _Position then
                return;
            end
        end
        -- Add to targets
        table.insert(Data.DefendTargets, _Position);
        Data.DefendTargets[1] = Data.DefendTargets[1] + 1;
        Stronghold.AI.Data.Delinquents[_ID] = Data;
    end
end

--- Removes all guard positions from the camp.
--- @param _ID integer ID of camp
function DelinquentsCampClearGuardPositions(_ID)
    if Stronghold.AI.Data.Delinquents[_ID] then
        Stronghold.AI.Data.Delinquents[_ID].DefendTargets = {0};
    end
end

--- Sets if a camp is attacking it's targets.
--- @param _ID integer ID of camp
--- @param _Flag boolean Camp does attack
function DelinquentsCampActivateAttack(_ID, _Flag)
    if Stronghold.AI.Data.Delinquents[_ID] then
        Stronghold.AI.Data.Delinquents[_ID].AttackAllowed = _Flag == true;
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
    Data.AttackAllowed = false;
    Data.AttackTargets = {0};
    Data.DefendTargets = {0};
    Data.AttackCommandID = 0;
    Data.DefendCommandID = 0;

    -- Attack army
    local AttackArmyID = AiArmy.New(
        Data.PlayerID,
        math.ceil((Data.Strength or 4)/2),
        Data.HomePosition,
        Data.RodeLength or 3500
    );
    AiArmy.SetFormationController(AttackArmyID, function (_ID)
        Stronghold.Unit:SetFormationOnCreate(_ID);
    end);
    Data.AttackArmyID = AttackArmyID;

    -- Defend army
    local DefendArmyID = AiArmy.New(
        Data.PlayerID,
        math.floor((Data.Strength or 4)/2),
        Data.HomePosition,
        Data.RodeLength or 3500
    );
    AiArmy.SetFormationController(DefendArmyID, function (_ID)
        Stronghold.Unit:SetFormationOnCreate(_ID);
    end);
    Data.DefendArmyID = DefendArmyID;

    self.Data.Delinquents[Data.ID] = Data;
    Job.Second(function(_ID)
        return Stronghold.AI:DelinquentsCampController(_ID);
    end, Data.ID)
    return Data.ID;
end

function Stronghold.AI:DelinquentsCampController(_ID)
    -- Check is alive
    if not DelinquentsCampIsAlive(_ID) then
        return true;
    end

    -- Control attacking
    local AttackArmyID = self.Data.Delinquents[_ID].AttackArmyID or 0;
    if AttackArmyID > 0 then
        if AiArmy.IsArmyDoingNothing(AttackArmyID) then
            if self.Data.Delinquents[_ID].AttackAllowed then
                local RodeLength = AiArmy.GetRodeLength(AttackArmyID);
                local Targets = self.Data.Delinquents[_ID].AttackTargets;
                if Targets[1] > 0 then
                    local Index = math.random(2, Targets[1] +1);
                    local Target = Targets[Index];
                    local Position = GetPosition(Target);
                    local Enemies = AiArmy.GetEnemiesInCircle(AttackArmyID, Position, RodeLength);
                    if Enemies[1] then
                        AiArmy.ClearCommands(AttackArmyID);
                        AiArmy.PushCommand(AttackArmyID, AiArmy.CreateCommand(AiArmyCommand.Advance, Target), false);
                        AiArmy.PushCommand(AttackArmyID, AiArmy.CreateCommand(AiArmyCommand.Battle, Target), false);
                        AiArmy.PushCommand(AttackArmyID, AiArmy.CreateCommand(AiArmyCommand.Move), false);
                    end
                end
            else
                local HomePosition = AiArmy.GetHomePosition(AttackArmyID);
                AiArmy.PushCommand(AttackArmyID, AiArmy.CreateCommand(AiArmyCommand.Move, HomePosition), false);
                AiArmy.PushCommand(AttackArmyID, AiArmy.CreateCommand(AiArmyCommand.Wait, 30, HomePosition), false);
            end
        end
    end

    -- Control defending
    local DefendArmyID = self.Data.Delinquents[_ID].DefendArmyID or 0;
    if DefendArmyID > 0 then
        if AiArmy.IsArmyDoingNothing(DefendArmyID) then
            local HomePosition = AiArmy.GetHomePosition(DefendArmyID);
            local GuardPos = CopyTable(self.Data.Delinquents[_ID].DefendTargets);
            local PositionCount = table.remove(GuardPos, 1);
            if PositionCount > 0 then
                GuardPos = ShuffleTable(GuardPos);
                AiArmy.ClearCommands(DefendArmyID);
                for i= 1, PositionCount + 1 do
                    AiArmy.PushCommand(DefendArmyID, AiArmy.CreateCommand(AiArmyCommand.Move, GuardPos[i]), false);
                    AiArmy.PushCommand(DefendArmyID, AiArmy.CreateCommand(AiArmyCommand.Wait, 3*60, GuardPos[i]), false);
                end
            else
                AiArmy.PushCommand(DefendArmyID, AiArmy.CreateCommand(AiArmyCommand.Move, HomePosition), false);
                AiArmy.PushCommand(DefendArmyID, AiArmy.CreateCommand(AiArmyCommand.Wait, 3*60, HomePosition), false);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Animal AI

--- Creates an animal.
--- @param _PlayerID integer ID of owner
--- @param _Type integer Type of animal
--- @param _Position table Position of animal
--- @param _Orientation number Orientation
--- @return string ScriptName Name of created animal
function CreateAnimal(_PlayerID, _Type, _Position, _Orientation)
    local ScriptName;
    if Stronghold.AI.Config.MigratoryAnimal[_Type] then
        local ID = Logic.CreateEntity(
            _Type,
            _Position.X, _Position.Y,
            _Orientation or 0,
            _PlayerID
        );
        ScriptName = CreateNameForEntity(ID);
    end
    return ScriptName;
end

--- Creates an animal NPC that is controlled by the AI.
--- @param _Type integer Type of animal
--- @param _Position table Position of animal
--- @param _Orientation number Orientation
--- @return string ScriptName Name of created animal
function CreateAutonomousAnimal(_Type, _Position, _Orientation)
    local ScriptName;
    if Stronghold.AI.Config.MigratoryAnimal[_Type] then
        local ID = Logic.CreateEntity(
            _Type,
            _Position.X, _Position.Y,
            _Orientation or 0,
            GetNeutralPlayerID()
        );
        ScriptName = CreateNameForEntity(ID);
        StartControlAnimalAutonoumous(ScriptName);
    end
    return ScriptName;
end

--- Enables AI controlling for the animal NPC.
--- @param _ScriptName string Script name
function StartControlAnimalAutonoumous(_ScriptName)
    Stronghold.AI:RegisterMigratoryAnimal(GetID(_ScriptName));
end

--- Disables AI controlling for the animal NPC.
--- @param _ScriptName string Script name
function StopControlAnimalAutonoumous(_ScriptName)
    Stronghold.AI:RegisterMigratoryAnimal(GetID(_ScriptName));
end

function Stronghold.AI:InitAnimals()
    for Type,_ in pairs(self.Config.MigratoryAnimal) do
        local TypeFilter = CEntityIterator.OfTypeFilter(Type);
        for EntityID in CEntityIterator.Iterator(TypeFilter) do
            self:UnregisterMigratoryAnimal(EntityID);
            self:RegisterMigratoryAnimal(EntityID);
        end
    end
end

function Stronghold.AI:RegisterMigratoryAnimal(_Entity)
    local EntityID = (type(_Entity) ~= "number" and GetID(_Entity)) or _Entity;
    local Type = Logic.GetEntityType(EntityID);
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    if PlayerID ~= 0 and self.Config.MigratoryAnimal[Type] then
        local ScriptName = Logic.GetEntityName(EntityID);
        if not ScriptName or not self.Data.AnimalsBlacklist[ScriptName] then
            local ID = ChangePlayer(EntityID, GetNeutralPlayerID());
            ScriptName = CreateNameForEntity(ID);
            self.Data.Animals[ScriptName] = {
                HomePosition = GetPosition(ID),
                Chance = self.Config.MigratoryAnimal[Type][3],
                MinArea = self.Config.MigratoryAnimal[Type][1],
                MaxArea = self.Config.MigratoryAnimal[Type][2],
                Fleeing = 0,
            };
            return ID;
        end
    end
    return 0;
end

function Stronghold.AI:UnregisterMigratoryAnimal(_Entity)
    local ScriptName = _Entity;
    if type(ScriptName) ~= "string" then
        ScriptName = Logic.GetEntityName(_Entity);
    end
    if self.Data.Animals[ScriptName] then
        self.Data.Animals[ScriptName] = nil;
    end
end

function Stronghold.AI:GetAnimalScareMongerID(_EntityID)
    local AllPlayers = {1,2,3,4,5,6,7,8};
    for i= 9, GetMaxAmountOfPlayer() do
        table.insert(AllPlayers, i);
    end
    local Position = GetPosition(_EntityID);
    local RangeFilter = CEntityIterator.InRangeFilter(Position.X, Position.Y, 1000);
    local PlayerFilter = CEntityIterator.OfAnyPlayerFilter(unpack(AllPlayers));
    local OtherEntitiesNear = 0;
    for OtherID in CEntityIterator.Iterator(RangeFilter, PlayerFilter) do
        OtherEntitiesNear = OtherEntitiesNear + 1;
        if OtherEntitiesNear > 1 then
            return OtherID;
        end
    end
    return 0;
end

function Stronghold.AI:ControlMigratoryAnimal()
    for ScriptName, Data in pairs(self.Data.Animals) do
        local ID = GetID(ScriptName);
        if not IsExisting(ID) then
            self.Data.Animals[ScriptName] = nil;
        else
            if GetDistance(ID, Data.HomePosition) > Data.MaxArea then
                Logic.MoveSettler(ID, Data.HomePosition.X, Data.HomePosition.Y);
            else
                self.Data.Animals[ScriptName].Fleeing = math.max(Data.Fleeing - 1, 0);
                if Data.Fleeing == 0 and Logic.IsEntityMoving(ID) == false then
                    if math.random(1, 100) <= Data.Chance then
                        local Angle = math.random(1, 360);
                        local Distance = math.random(Data.MinArea, Data.MaxArea);
                        Position = GetCirclePosition(Data.HomePosition, Distance, Angle);
                        if IsValidPosition(Position) then
                            Logic.MoveSettler(ID, Position.X, Position.Y);
                        end
                    end
                else
                    if Data.Fleeing <= 0 then
                        local ScareMonger = self:GetAnimalScareMongerID(ID);
                        if ScareMonger ~= 0 then
                            local Angle = GetAngleBetween(ID, ScareMonger);
                            Position = GetCirclePosition(ScareMonger, Data.MinArea, Angle);
                            if IsValidPosition(Position) then
                                Logic.MoveSettler(ID, Position.X, Position.Y);
                            end
                            self.Data.Animals[ScriptName].Fleeing = 10;
                        end
                    end
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Player config

--- Returns the player ID reserved for the vagabond player.
--- @return integer PlayerID ID of enemy player
function GetVagabondPlayerID()
    return Stronghold.AI.Config.VagabondPlayerID;
end

--- Returns the player color of the bandit player.
--- @return integer ColorID ID of color
function GetVagabondPlayerColor()
    return Stronghold.AI.Config.VagabondPlayerColor;
end

--- Changes the bandit player. The passive player must be Max Human Player + 1.
--- @param _PlayerID integer ID of player
function SetVagabondPlayerID(_PlayerID)
    local MaxHumanPlayers = GetMaxHumanPlayers();
    assert(_PlayerID == MaxHumanPlayers +1, "Enemy player must be " ..(MaxHumanPlayers +1).. "!");
    Stronghold.AI.Config.VagabondPlayerID = _PlayerID;
end

--- Changes the bandit player color.
--- @param _ColorID integer ID of color
function SetVagabondPlayerColor(_ColorID)
    Stronghold.AI.Config.VagabondPlayerColor = _ColorID;
    Display.SetPlayerColorMapping(GetVagabondPlayerID(), _ColorID);
end

--- Returns the player ID reserved for the passive player.
--- @return integer PlayerID ID of neutral player
function GetNeutralPlayerID()
    return Stronghold.AI.Config.NeutralPlayerID;
end

--- Returns the neutral player color.
--- @return integer ColorID ID of color
function GetNeutralPlayerColor()
    return Stronghold.AI.Config.NeutralPlayerColor;
end

--- Changes the passive player. The passive player must be Max Human Player + 2.
--- @param _PlayerID integer ID of player
function SetNeutralPlayerID(_PlayerID)
    local MaxHumanPlayers = GetMaxHumanPlayers();
    assert(_PlayerID == MaxHumanPlayers +2, "Neutral player must be " ..(MaxHumanPlayers +2).. "!");
    Stronghold.AI.Config.NeutralPlayerID = _PlayerID;
    if Logic.GetTime() > 0 then
        Stronghold.AI:InitAnimals();
    end
end

--- Changes the neutral player color.
--- @param _ColorID integer ID of color
function SetNeutralPlayerColor(_ColorID)
    Stronghold.AI.Config.NeutralPlayerColor = _ColorID;
    Display.SetPlayerColorMapping(GetNeutralPlayerColor(), _ColorID);
end

-- -------------------------------------------------------------------------- --
-- Army config

function Stronghold.AI:OverwriteAiTargetConfig()
    for Type,_ in pairs(self.Config.AttackTargetBlacklist) do
        GetEntitiesOfDiplomacyStateInArea_BlacklistedTypes[Type] = true;
    end

    AiArmyTargetingConfig.Spear = {
        ["CavalryHeavy"] = 40,
        ["CavalryLight"] = 30,
        ["EvilLeader"] = 30,
        ["Hero"] = 20,
        ["MilitaryBuilding"] = 10,
        ["DefendableBuilding"] = 0,
        ["Sword"] = 0,
        ["Cannon"] = 0,
    }
    AiArmyTargetingConfig.CavalryLight = {
        [Entities.CU_Barbarian_LeaderClub1] = 40,
        [Entities.CU_Barbarian_LeaderClub2] = 40,

        ["Cannon"] = 30,
        ["Spear"] = 20,
        ["Sword"] = 20,
        ["Hero"] = 10,
        ["DefendableBuilding"] = 0,
        ["CavalryHeavy"] = 0,
        ["CavalryLight"] = 0,
        ["Rifle"] = 0,
    }
    AiArmyTargetingConfig.Bow = {
        [Entities.CU_Barbarian_LeaderClub1] = 40,
        [Entities.CU_Barbarian_LeaderClub2] = 40,

        ["MilitaryBuilding"] = 40,
        ["Cannon"] = 40,
        ["CavalryHeavy"] = 30,
        ["CavalryLight"] = 20,
        ["Spear"] = 20,
        ["Hero"] = 10,
        ["DefendableBuilding"] = 0,
        ["Rifle"] = 0,
        ["Sword"] = 0,
    }
    AiArmyTargetingConfig.Rifle = {
        [Entities.CU_Barbarian_LeaderClub1] = 40,
        [Entities.CU_Barbarian_LeaderClub2] = 40,

        ["Cannon"] = 50,
        ["EvilLeader"] = 50,
        ["LongRange"] = 40,
        ["Spear"] = 30,
        ["Hero"] = 20,
        ["CavalryHeavy"] = 10,
        ["Sword"] = 10,
        ["DefendableBuilding"] = 0,
        ["MilitaryBuilding"] = 0,
    }
    AiArmyTargetingConfig.Mace = {
        ["MilitaryBuilding"] = 30,
        ["CavalryHeavy"] = 30,
        ["Sword"] = 20,
        ["DefendableBuilding"] = 10,
        ["Cannon"] = 10,
        ["Rifle"] = 0,
        ["Spear"] = 0,
    }

    AiArmyTargetingTypeMapping = {
        [Entities.CU_Barbarian_LeaderClub1] = AiArmyTargetingConfig.Mace,
        [Entities.CU_Barbarian_LeaderClub2] = AiArmyTargetingConfig.Mace,
        [Entities.CU_BlackKnight_LeaderMace1] = AiArmyTargetingConfig.Mace,
        [Entities.CU_BlackKnight_LeaderMace2] = AiArmyTargetingConfig.Mace,
        [Entities.CU_BanditLeaderSword1] = AiArmyTargetingConfig.CavalryHeavy,
        [Entities.CU_BanditLeaderSword2] = AiArmyTargetingConfig.CavalryHeavy,
        [Entities.CV_Cannon1] = AiArmyTargetingConfig.TroopCannon,
        [Entities.CV_Cannon2] = AiArmyTargetingConfig.TroopCannon,
        [Entities.PV_Cannon1] = AiArmyTargetingConfig.TroopCannon,
        [Entities.PV_Cannon2] = AiArmyTargetingConfig.BuildingCannon,
        [Entities.PV_Cannon3] = AiArmyTargetingConfig.TroopCannon,
        [Entities.PV_Cannon4] = AiArmyTargetingConfig.BuildingCannon,
        [Entities.PV_Cannon7] = AiArmyTargetingConfig.TroopCannon,
        [Entities.PV_Cannon8] = AiArmyTargetingConfig.TroopCannon,
    }
end

function Stronghold.AI:OverwriteAiSpeedConfig()
    AiArmyConstants.BaseSpeed = {
        ["Bow"] = 360,
        ["CavalryLight"] = 570,
        ["CavalryHeavy"] = 520,
        ["Hero"] = 400,
        ["Rifle"] = 360,

        [Entities.CU_Barbarian_LeaderClub1] = 400,
        [Entities.CU_Barbarian_LeaderClub2] = 400,
        [Entities.CV_Cannon1] = 345,
        [Entities.CV_Cannon2] = 345,
        [Entities.PV_Cannon1] = 300,
        [Entities.PV_Cannon2] = 250,
        [Entities.PV_Cannon3] = 200,
        [Entities.PV_Cannon4] = 150,
        [Entities.PV_Cannon7] = 300,
        [Entities.PV_Cannon8] = 345,

        ["_Others"] = 360,
    };

    AiArmyConstants.SpeedWeighting = {
        ["CavalryLight"] = 0.4,
        ["CavalryHeavy"] = 0.4,

        [Entities.CU_Barbarian_LeaderClub1] = 0.9,
        [Entities.CU_Barbarian_LeaderClub2] = 0.9,
        [Entities.CV_Cannon1] = 0.6,
        [Entities.CV_Cannon2] = 0.6,
        [Entities.PV_Cannon1] = 0.6,
        [Entities.PV_Cannon2] = 0.5,
        [Entities.PV_Cannon3] = 0.3,
        [Entities.PV_Cannon4] = 0.2,
        [Entities.PV_Cannon7] = 0.6,
        [Entities.PV_Cannon8] = 0.6,

        ["_Others"] = 1.0
    };
end

-- -------------------------------------------------------------------------- --
-- Hero

function Stronghold.AI:ControlAiPlayerHeroes()
    for PlayerID = 1, GetMaxPlayers() do
        if IsAIPlayer(PlayerID) then
            if not self.Data.Heroes[PlayerID] then
                self.Data.Heroes[PlayerID] = {State = 1}
            end

            local HeroID = GetNobleID(PlayerID);
            local Type = Logic.GetEntityType(HeroID);
            if IsEntityValid(HeroID) then
                local DoorPos = GetHeadquarterEntrance(PlayerID);
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
                local ID = Logic.CreateEntity(Entities.XD_Bomb2, x, y, 0, _PlayerID);
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
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilityBuildCannon);
    local CurrentCharge = Logic.HeroGetAbilityChargeSeconds(_HeroID, Abilities.AbilityBuildCannon);
    if CurrentCharge >= RechargeTime then
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
                Logic.HeroSetAbilityChargeSeconds(_HeroID, Abilities.AbilityBuildCannon, 0);
                SVLib.SetInvisibility(ID, true);
            end
            -- Attack enemies
            if not IsFighting(_HeroID) then
                local EnemyPos = GetPosition(FarEnemyList[1]);
                Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
            end
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
    local HeroPos = GetPosition(_HeroID);
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
    local HeroPos = GetPosition(_HeroID);
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

