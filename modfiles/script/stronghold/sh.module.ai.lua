---
--- AI Enemy
---

Stronghold = Stronghold or {};

Stronghold.AI = {
    Data = {
        ArmySequence = 0,
        SpawnerSequence = 0,

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
    self:InitMigratoryAnimals();

    Job.Second(function()
        Stronghold.AI:ControlAiPlayerHeroes();
    end);
end

function Stronghold.AI:OnSaveGameLoaded()
    Display.SetPlayerColorMapping(GetVagabondPlayerID(), GetVagabondPlayerColor());
    Display.SetPlayerColorMapping(GetNeutralPlayerID(), GetNeutralPlayerColor());
end

function Stronghold.AI:OncePerTurn(_PlayerID)
    -- Control animals
    self:ControlMigratoryAnimal();
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
    --- @diagnostic disable-next-line: undefined-field
    local AttackArmyID = self.Data.Delinquents[_ID].AttackArmyID or 0;
    if AttackArmyID > 0 then
        if AiArmy.IsArmyDoingNothing(AttackArmyID) then
            --- @diagnostic disable-next-line: undefined-field
            if self.Data.Delinquents[_ID].AttackAllowed then
                local RodeLength = AiArmy.GetRodeLength(AttackArmyID);
                --- @diagnostic disable-next-line: undefined-field
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
    --- @diagnostic disable-next-line: undefined-field
    local DefendArmyID = self.Data.Delinquents[_ID].DefendArmyID or 0;
    if DefendArmyID > 0 then
        if AiArmy.IsArmyDoingNothing(DefendArmyID) then
            local HomePosition = AiArmy.GetHomePosition(DefendArmyID);
            --- @diagnostic disable-next-line: undefined-field
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

