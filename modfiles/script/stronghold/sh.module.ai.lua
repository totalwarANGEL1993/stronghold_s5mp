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

-- -------------------------------------------------------------------------- --
-- API

-- Players --

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

-- Armies --

--- Creates an battalion.
---
--- #### Configuration
--- * `PlayerID`     - ID of player
--- * `HomePosition` - Position of home
--- * `Strength`     - Strength of battalion
--- * `RodeLength`   - Action radius
---
--- @param _Data table Battalion configuration
--- @return integer ID ID of battalion
function BattalionCreate(_Data)
    return Stronghold.AI:BattalionCreate(_Data);
end

--- Deletes the battalion and kills all troops.
--- @param _ID integer ID of battalion
function BattalionDestroy(_ID)
    Stronghold.AI:BattalionDestroy(_ID)
end

--- Changes the player of the battalion and all attached refillers.
--- @param _ID integer       ID of battalion
--- @param _PlayerID integer New player ID
function BattalionChangePlayer(_ID, _PlayerID)
    Stronghold.AI:BattalionChangePlayer(_ID, _PlayerID)
end

--- Adds a troop to the battalion.
--- @param _ID integer        ID of battalion
--- @param _TroopID integer   ID of troop
--- @param _Reinforce boolean Add as reinforcement
--- @return boolean Added Refiller was added
function BattalionAddTroop(_ID, _TroopID, _Reinforce)
    return Stronghold.AI:BattalionAddTroop(_ID, _TroopID, _Reinforce);
end

--- Kills all troops of the battalion.
--- @param _ID integer ID of battalion
--- @return boolean Removed Troops were removed
function BattalionClearTroops(_ID)
    return Stronghold.AI:BattalionClearTroops(_ID);
end

--- Creates a refiller that spawns troops and add it to the battalion.
--- 
--- A refiller can have a seperate spawnpoint which must be named after the
--- scriptname of the spawner (e.g. "[Scriptname]Spawn").
--- 
--- @param _ID integer        ID of battalion
--- @param _ScriptName string Scriptname of spawner
--- @param _Respawn integer   Time between spawn cycles
--- @param _Amount integer    Troops spawned per cycle
--- @param ... any            List of troop types
--- @return integer ID ID of refiller
function BattalionCreateSpawningRefiller(_ID, _ScriptName, _Respawn, _Amount, ...)
    local RefillerID = Stronghold.AI:BattalionCreateSpawningRefiller(_ID, _ScriptName, _Respawn, _Amount, unpack(arg));
    if RefillerID ~= 0 then
        BattalionAddRefiller(_ID, RefillerID);
    end
    return RefillerID;
end

--- NOT IMPLEMENTED!
function BattalionCreateRecruitingRefiller(_ID, ...)
    local RefillerID = Stronghold.AI:BattalionCreateRecruitingRefiller(_ID, unpack(arg));
    if RefillerID ~= 0 then
        BattalionAddRefiller(_ID, RefillerID);
    end
    return RefillerID;
end

--- Adds an refiller to the battalion.
--- @param _ID integer         ID of battalion
--- @param _RefillerID integer ID of refiller
--- @return boolean Added Refiller was added
function BattalionAddRefiller(_ID, _RefillerID)
    return Stronghold.AI:BattalionAddRefiller(_ID, _RefillerID);
end

--- Removes all refiller from the army.
--- @param _ID integer ID of battalion
--- @return boolean Removed Refillers were removed
function BattalionClearRefiller(_ID)
    return Stronghold.AI:BattalionClearRefiller(_ID);
end

--- Returns if the battalion is existing.
--- @param _ID integer ID of battalion
--- @return boolean IsExisting Battalion is existing
function BattalionIsExisting(_ID)
    return Stronghold.AI:BattalionIsExisting(_ID) ~= nil;
end

--- Returns if the battalion is alive.
--- @param _ID integer ID of battalion
--- @return boolean IsAlive Battalion is alive
function BattalionIsAlive(_ID)
    return Stronghold.AI:BattalionIsAlive(_ID);
end

--- Returns the plan currently active for the battalion.
--- @param _ID integer ID of battalion
--- @return integer Plan Active plan
function BattalionGetPlan(_ID)
    return Stronghold.AI:BattalionPlanGetPlan(_ID);
end

--- Cancels the current plan of the battalion.
--- @param _ID integer ID of battalion
--- @return boolean Canceled Plan is canceled
function BattalionCancelPlan(_ID)
    return Stronghold.AI:Battalion_Plan_CancelPlan(_ID);
end

--- Activates the plan to retreat home.
--- @param _ID integer ID of battalion
--- @return boolean Activated Plan is activated
function BattalionPlanRetreat(_ID)
    return Stronghold.AI:BattalionStartPlanRetreat(_ID);
end

--- Activates the plan to advance to the position.
--- @param _ID integer ID of battalion
--- @param _Target any Advance target
--- @return boolean Activated Plan is activated
function BattalionPlanAdvance(_ID, _Target)
    return Stronghold.AI:BattalionStartPlanAdvance(_ID, _Target);
end

--- Activates the plan to attack the target.
--- @param _ID integer ID of battalion
--- @param _Target any Attack target
--- @return boolean Activated Plan is activated
function BattalionPlanRaid(_ID, _Target)
    return Stronghold.AI:BattalionStartPlanRaid(_ID, _Target);
end

--- Activates the plan to attack any of the targets in order.
--- @param _ID integer    ID of battalion
--- @param _Targets table List of targets
--- @return boolean Activated Plan is activated
function BattalionPlanAttack(_ID, _Targets)
    return Stronghold.AI:BattalionStartPlanAttack(_ID, _Targets);
end

--- Activates the plan to intervene if foes are near positions.
--- @param _ID integer    ID of battalion
--- @param _Targets table List of targets
--- @return boolean Activated Plan is activated
function BattalionPlanIntervene(_ID, _Area, _Targets)
    return Stronghold.AI:BattalionStartPlanIntervene(_ID, _Area, _Targets);
end

--- Activates the plan to patrol between targets for the army.
--- @param _ID integer    ID of battalion
--- @param _Targets table List of targets
--- @return boolean Activated Plan is activated
function BattalionPlanPatrol(_ID, _Targets)
    return Stronghold.AI:BattalionStartPlanPatrol(_ID, _Targets);
end

-- Delinquents --

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
    local SpawnerID = 0;
    if Stronghold.AI.Data.Delinquents[_ID] then
        local Data = Stronghold.AI.Data.Delinquents[_ID];
        local Troops = {};
        for i= 1, table.getn(arg) do
            local Troop = (type(arg[i]) ~= "table" and {arg[i], 0}) or arg[i];
            table.insert(Troops, Troop);
        end

        local AtkTypes = AiArmy.GetAllowedTypes(Data.AttackArmyID);
        AiArmy.SetAllowedTypes(Data.AttackArmyID, CopyTable(Troops, AtkTypes));
        local DefTypes = AiArmy.GetAllowedTypes(Data.AttackArmyID);
        AiArmy.SetAllowedTypes(Data.DefendArmyID, CopyTable(Troops, DefTypes));

        SpawnerID = AiArmyRefiller.Get(_ScriptName);
        if SpawnerID == 0 then
            SpawnerID = AiArmyRefiller.CreateSpawner{
                ScriptName    = _ScriptName,
                SpawnPoint    = (IsExisting(_ScriptName.. "Spawn") and _ScriptName.. "Spawn") or nil,
                SpawnAmount   = _Amount,
                SpawnTimer    = _Time,
                Sequentially  = true,
                Endlessly     = true,
                AllowedTypes  = Troops,
            };
        end
        AiArmyRefiller.AddArmy(SpawnerID, Data.AttackArmyID);
        AiArmyRefiller.AddArmy(SpawnerID, Data.DefendArmyID);
        table.insert(Stronghold.AI.Data.Delinquents[_ID].Spawner, SpawnerID);
    end
    return SpawnerID;
end

--- Returns the ID of the attacking army of the camp.
--- @param _ID integer ID of camp
--- @return integer ID ID of army
function DelinquentsCampGetAttackerArmy(_ID)
    if Stronghold.AI.Data.Delinquents[_ID] then
        return Stronghold.AI.Data.Delinquents[_ID].AttackArmyID;
    end
    return 0;
end

--- Returns the ID of the defending army of the camp.
--- @param _ID integer ID of camp
--- @return integer ID ID of army
function DelinquentsCampGetDefenderArmy(_ID)
    if Stronghold.AI.Data.Delinquents[_ID] then
        return Stronghold.AI.Data.Delinquents[_ID].DefendArmyID;
    end
    return 0;
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
        for i= TargetTable[1] +1, 2, -1 do
            local IsContained = false;
            for j= Data.AttackTargets[1] +1, 2, -1 do
                if Data.AttackTargets[j] == TargetTable[TargetTable[i]] then
                    IsContained = true;
                    break;
                end
            end
            if not IsContained then
                table.insert(Data.AttackTargets, TargetTable[i]);
                Data.AttackTargets[1] = Data.AttackTargets[1] + 1;
            end
        end
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
--- @param ... string|table List of targets
function DelinquentsCampAddGuardPositions(_ID, ...)
    local GuardTable = CopyTable(arg);
    table.insert(GuardTable, 1, table.getn(GuardTable));
    if Stronghold.AI.Data.Delinquents[_ID] then
        local Data = Stronghold.AI.Data.Delinquents[_ID];
        for i= GuardTable[1] +1, 2, -1 do
            local IsContained = false;
            for j= Data.DefendTargets[1] +1, 2, -1 do
                if Data.DefendTargets[j] == GuardTable[GuardTable[i]] then
                    IsContained = true;
                    break;
                end
            end
            if not IsContained then
                table.insert(Data.DefendTargets, GuardTable[i]);
                Data.DefendTargets[1] = Data.DefendTargets[1] + 1;
            end
        end
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

-- -------------------------------------------------------------------------- --
-- Internal

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

function Stronghold.AI:OnEveryTurn(_PlayerID)
end

function Stronghold.AI:OnEveryTurnNoPlayer()
    -- Control animals
    self:ControlMigratoryAnimal();
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
        [Entities.PU_LeaderAxe1] = AiArmyTargetingConfig.CavalryHeavy,
        [Entities.PU_LeaderAxe2] = AiArmyTargetingConfig.CavalryHeavy,
        [Entities.PU_LeaderAxe3] = AiArmyTargetingConfig.CavalryHeavy,
        [Entities.PU_LeaderAxe4] = AiArmyTargetingConfig.CavalryHeavy,
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
-- Battalions

--- Battalion operation plans
--- 
--- @class BattalionPlan 
--- @field None integer Ready for plan
--- @field Retreat integer Fallback to base and then refill (if possible)
--- @field Advance integer Advance to a position and stay
--- @field Raid integer Raid a position, return home and refill (if possible)
--- @field Attack integer Attack on path, return home and refill (if possible)
--- @field Intervene integer Defend multiple positions, return home and refill (if possible)
--- @field Patrol integer Patrol over positions in a endless loop
BattalionPlan = {
    None = 0,
    Retreat = 1,
    Advance = 2,
    Raid = 3,
    Attack = 4,
    Intervene = 5,
    Patrol = 6,
}

function Stronghold.AI:BattalionCreate(_Data)
    local Data = CopyTable(_Data);

    -- Save properties
    self.Data.Armies.Sequence = self.Data.Armies.Sequence +1;
    Data.ID = self.Data.Armies.Sequence;
    assert(Data.PlayerID and Data.PlayerID > 0 and Data.PlayerID < GetMaxPlayers(), "PlayerID is wrong!");
    Data.Plan = BattalionPlan.None;
    Data.Refiller = {};
    if type(Data.HomePosition) ~= "table" then
        Data.HomePosition = GetPosition(Data.HomePosition);
    end

    -- Create army
    local ArmyID = AiArmy.New(
        Data.PlayerID,
        Data.Strength,
        Data.HomePosition,
        Data.RodeLength or 3500
    );
    AiArmy.SetAliveThreshold(ArmyID, 0.0001);
    AiArmy.SetTroopFormationController(ArmyID, function (_ID)
        Stronghold.Unit:SetFormationOnCreate(_ID);
    end);
    Data.ArmyID = ArmyID;
    self.Data.Armies[Data.ID] = Data;

    Job.Second(function(_ID)
        return Stronghold.AI:BattalionController(_ID);
    end, Data.ID)
    return Data.ID;
end

function Stronghold.AI:BattalionDestroy(_ID)
    if self.Data.Armies[_ID] then
        --- @diagnostic disable-next-line: undefined-field
        local ArmyID = self.Data.Armies[_ID].ArmyID;
        local AttackArmy = AiArmy.Get(ArmyID);
        if AttackArmy then
            AttackArmy:Abandon(true);
            AttackArmy:Dispose();
        end
        self.Data.Armies[_ID] = nil;
    end
end

function Stronghold.AI:BattalionChangePlayer(_ID, _PlayerID)
    if self.Data.Armies[_ID] then
        --- @diagnostic disable-next-line: undefined-field
        local ArmyID = self.Data.Armies[_ID].ArmyID;
        AiArmy.ChangePlayer(ArmyID, _PlayerID);
        --- @diagnostic disable-next-line: undefined-field
        for i= 1, table.getn(self.Data.Armies[_ID].Refiller) do
            --- @diagnostic disable-next-line: undefined-field
            local RefillerID = self.Data.Armies[_ID].Refiller[i];
            AiArmyRefiller.ChangePlayer(RefillerID, _PlayerID);
        end
    end
end

function Stronghold.AI:BattalionController(_ID)
    if not self.Data.Armies[_ID] then
        return true;
    end

    local Data = self.Data.Armies[_ID];
    --- @diagnostic disable-next-line: undefined-field
    if AiArmy.IsArmyDoingNothing(Data.ArmyID) then
        --- @diagnostic disable-next-line: inject-field
        self.Data.Armies[_ID].Plan = 0;
    else
        -- Army retreats
        --- @diagnostic disable-next-line: undefined-field
        if Data.Plan > 1 then
            --- @diagnostic disable-next-line: undefined-field
            if AiArmy.IsCommandOfTypeEnqueued(Data.ArmyID, AiArmyCommand.Fallback)
            --- @diagnostic disable-next-line: undefined-field
            or AiArmy.IsCommandOfTypeActive(Data.ArmyID, AiArmyCommand.Refill) then
                --- @diagnostic disable-next-line: inject-field
                self.Data.Armies[_ID].Plan = 1;
            end
        end
    end
end

function Stronghold.AI:BattalionAddTroop(_ID, _TroopID, _Reinforce)
    if self.Data.Armies[_ID] then
        local Data = self.Data.Armies[_ID];
        --- @diagnostic disable-next-line: undefined-field
        return AiArmy.AddTroop(Data.ArmyID, _TroopID, _Reinforce);
    end
    return false;
end

function Stronghold.AI:BattalionClearTroops(_ID)
    if self.Data.Armies[_ID] then
        --- @diagnostic disable-next-line: undefined-field
        local Army = AiArmy.Get(self.Data.Armies[_ID].ArmyID);
        if Army then
            Army:Abandon(true);
        end
    end
    return false;
end

function Stronghold.AI:BattalionCreateSpawningRefiller(_ID, _ScriptName, _Respawn, _Amount, ...)
    if self.Data.Armies[_ID] then
        return AiArmyRefiller.CreateSpawner {
            --- @diagnostic disable-next-line: undefined-field
            PlayerID = self.Data.Armies[_ID].PlayerID,
            ScriptName = _ScriptName,
            SpawnPoint = (IsExisting(_ScriptName .. "Spawn") and _ScriptName .. "Spawn") or nil,
            SpawnAmount = _Amount,
            SpawnTimer = _Respawn,
            AllowedTypes = CopyTable(arg),
        }
    end
    return 0;
end

function Stronghold.AI:BattalionCreateRecruitingRefiller(_ID, ...)
    assert(false, "Not implemented");
    return 0;
end

function Stronghold.AI:BattalionAddRefiller(_ID, _RefillerID)
    if self.Data.Armies[_ID] then
        local Data = self.Data.Armies[_ID];
        --- @diagnostic disable-next-line: undefined-field
        if not IsInTable(_RefillerID, Data.Refiller) then
            --- @diagnostic disable-next-line: undefined-field
            table.insert(self.Data.Armies[_ID].Refiller, _RefillerID);
            --- @diagnostic disable-next-line: undefined-field
            AiArmyRefiller.AddArmy(Data.ArmyID, _RefillerID);
            return true;
        end
    end
    return false;
end

function Stronghold.AI:BattalionClearRefiller(_ID)
    if self.Data.Armies[_ID] then
        local Data = Stronghold.AI.Data.Armies[_ID];
        --- @diagnostic disable-next-line: undefined-field
        for i= 1, table.getn(Data.Refiller) do
            --- @diagnostic disable-next-line: undefined-field
            AiArmyRefiller.RemoveArmy(Data.Refiller[i], Data.ArmyID);
        end
        --- @diagnostic disable-next-line: inject-field
        self.Data.Armies[_ID].Refiller = {};
        return true;
    end
    return false;
end

function Stronghold.AI:BattalionIsExisting(_ID)
    return self.Data.Armies[_ID] ~= nil;
end

function Stronghold.AI:BattalionIsAlive(_ID)
    if not self:BattalionIsExisting(_ID) then
        return false;
    end
    --- @diagnostic disable-next-line: undefined-field
    if not AiArmy.IsInitallyFilled(self.Data.Armies[_ID].ArmyID) then
        return true;
    end
    --- @diagnostic disable-next-line: undefined-field
    if AiArmy.IsAlive(self.Data.Armies[_ID].ArmyID) then
        return true;
    end
    --- @diagnostic disable-next-line: undefined-field
    for i= 2, self.Data.Armies[_ID].Refiller[1] +1 do
        --- @diagnostic disable-next-line: undefined-field
        if AiArmyRefiller.IsAlive(self.Data.Armies[_ID].Refiller[i]) then
            return true;
        end
    end
    return false;
end

function Stronghold.AI:BattalionPlanGetPlan(_ID)
    if self.Data.Armies[_ID] then
        --- @diagnostic disable-next-line: undefined-field
        return self.Data.Armies[_ID].Plan or 0;
    end
    return 0;
end

function Stronghold.AI:Battalion_Plan_CancelPlan(_ID)
    if not self.Data.Armies[_ID] then
        return false;
    end
    --- @diagnostic disable-next-line: undefined-field
    local ArmyID = self.Data.Armies[_ID].ArmyID;
    AiArmy.ClearCommands(ArmyID);
    --- @diagnostic disable-next-line: inject-field
    self.Data.Armies[_ID].Plan = BattalionPlan.None;
    return true;
end

function Stronghold.AI:BattalionStartPlanRetreat(_ID)
    if not self.Data.Armies[_ID] then
        return false;
    end
    local Plan = self:BattalionPlanGetPlan(_ID);
    if Plan ~= 0 then
        return false;
    end

    --- @diagnostic disable-next-line: undefined-field
    local ArmyID = self.Data.Armies[_ID].ArmyID;
    AiArmy.ClearCommands(ArmyID);
    AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Fallback), false);
    AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Refill), false);
    --- @diagnostic disable-next-line: inject-field
    self.Data.Armies[_ID].Plan = BattalionPlan.Retreat;
    return true;
end

function Stronghold.AI:BattalionStartPlanAdvance(_ID, _Target)
    if not self.Data.Armies[_ID] then
        return false;
    end
    local Plan = self:BattalionPlanGetPlan(_ID);
    if Plan ~= 0 then
        return false;
    end

    --- @diagnostic disable-next-line: undefined-field
    local ArmyID = self.Data.Armies[_ID].ArmyID;
    AiArmy.ClearCommands(ArmyID);
    AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Move, _Target), false);
    AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Advance, _Target), false);
    --- @diagnostic disable-next-line: inject-field
    self.Data.Armies[_ID].Plan = BattalionPlan.Advance;
    return true;
end

function Stronghold.AI:BattalionStartPlanRaid(_ID, _Target)
    if not self.Data.Armies[_ID] then
        return false;
    end
    local Plan = self:BattalionPlanGetPlan(_ID);
    if Plan ~= 0 then
        return false;
    end

    --- @diagnostic disable-next-line: undefined-field
    local ArmyID = self.Data.Armies[_ID].ArmyID;
    AiArmy.ClearCommands(ArmyID);
    AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Move, _Target), false);
    AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Battle, _Target), false);
    AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Move), false);
    AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Refill), false);
    --- @diagnostic disable-next-line: inject-field
    self.Data.Armies[_ID].Plan = BattalionPlan.Raid;
    return true;
end

function Stronghold.AI:BattalionStartPlanAttack(_ID, _Targets)
    if not self.Data.Armies[_ID] then
        return false;
    end
    local Plan = self:BattalionPlanGetPlan(_ID);
    if Plan ~= 0 then
        return false;
    end

    --- @diagnostic disable-next-line: undefined-field
    local ArmyID = self.Data.Armies[_ID].ArmyID;
    local PathSize = table.getn(_Targets);
    assert(PathSize > 0, "Attack path is empty!");
    AiArmy.ClearCommands(ArmyID);
    for i= 1, PathSize do
        AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Advance, _Targets[i]), false);
        if i == PathSize then
            AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Battle, _Targets[i]), false);
        end
    end
    AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Move), false);
    AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Refill), false);
    --- @diagnostic disable-next-line: inject-field
    self.Data.Armies[_ID].Plan = BattalionPlan.Attack;
    return true;
end

function Stronghold.AI:BattalionStartPlanIntervene(_ID, _Area, _Targets)
    if not self.Data.Armies[_ID] then
        return false;
    end
    local Plan = self:BattalionPlanGetPlan(_ID);
    if Plan ~= 0 then
        return false;
    end

    --- @diagnostic disable-next-line: undefined-field
    local ArmyID = self.Data.Armies[_ID].ArmyID;
    --- @diagnostic disable-next-line: undefined-field
    local HomePosition = self.Data.Armies[_ID].HomePosition;
    local TargetSize = table.getn(arg);
    assert(TargetSize > 0, "Intervene targets are empty!");
    AiArmy.ClearCommands(ArmyID.ArmyID);
    local ControlCommand = function(_Army, ...)
        local Filter = {"Cannon", "DefendableBuilding", "Hero", "Leader", "MilitaryBuilding", "Serf"};
        local Priority = {};
        -- Get enemies
        for i= 2, table.getn(arg) do
            local Enemies = AiArmy.GetEnemiesInCircle(_Army.ID, arg[i], _Area, Filter);
            if Enemies[1] then
                local Allies = GetAlliesInArea(_Army.PlayerID, GetPosition(arg[i]), _Area);
                table.insert(Priority, {arg[i], Enemies, table.getn(Enemies), table.getn(Allies)});
            end
        end
        -- Priority by enemy to ally ratio
        table.sort(Priority, function(a, b)
            return a[3] - a[4] > b[3] - b[4];
        end);
        -- Create behavior
        if Priority[1] then
            local Position = Priority[1][1];
            AiArmy.PushCommand(_Army.ID, AiArmy.CreateCommand(AiArmyCommand.Refill), false, 1);
            AiArmy.PushCommand(_Army.ID, AiArmy.CreateCommand(AiArmyCommand.Move), false, 1);
            AiArmy.PushCommand(_Army.ID, AiArmy.CreateCommand(AiArmyCommand.Battle, Position), false, 1);
            AiArmy.PushCommand(_Army.ID, AiArmy.CreateCommand(AiArmyCommand.Advance, Position), false, 1);
            return true;
        end
        return false;
    end
    AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Wait, 30, HomePosition), true);
    AiArmy.PushCommand(ArmyID.ArmyID, AiArmy.CreateCommand(AiArmyCommand.Custom, ControlCommand, unpack(_Targets)), true);
    --- @diagnostic disable-next-line: inject-field
    self.Data.Armies[_ID].Plan = BattalionPlan.Intervene;
    return true;
end

function Stronghold.AI:BattalionStartPlanPatrol(_ID, _Targets)
    if not self.Data.Armies[_ID] then
        return false;
    end
    local Plan = self:BattalionPlanGetPlan(_ID);
    if Plan ~= 0 then
        return false;
    end

    --- @diagnostic disable-next-line: undefined-field
    local ArmyID = self.Data.Armies[_ID].ArmyID;
    local PathSize = table.getn(_Targets);
    assert(PathSize > 0, "Patrol path is empty!");
    AiArmy.ClearCommands(ArmyID);
    for i= 1, PathSize do
        AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Move, _Targets[i]), true);
        AiArmy.PushCommand(ArmyID, AiArmy.CreateCommand(AiArmyCommand.Wait, 30, _Targets[i]), true);
    end
    --- @diagnostic disable-next-line: inject-field
    self.Data.Armies[_ID].Plan = BattalionPlan.Patrol;
    return true;
end

-- -------------------------------------------------------------------------- --
-- Delinquents

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
    AiArmy.SetTroopFormationController(AttackArmyID, function (_ID)
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
    AiArmy.SetTroopFormationController(DefendArmyID, function (_ID)
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
                        AiArmy.PushCommand(AttackArmyID, AiArmy.CreateCommand(AiArmyCommand.Move, Target), false);
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

