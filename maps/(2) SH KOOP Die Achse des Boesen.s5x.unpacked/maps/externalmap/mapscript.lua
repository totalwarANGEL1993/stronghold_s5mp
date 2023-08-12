-- ########################################################################## --
-- #                                                                        # --
-- #                                                                        # --
-- #     Mapname:  (2) KOOP Die Achse des Bösen                             # --
-- #                                                                        # --
-- #     Author:   totalwarANGEL                                            # --
-- #                                                                        # --
-- #                                                                        # --
-- ########################################################################## --

local Path = "data\\maps\\user\\stronghold_s5mp\\sh.loader.lua";
Script.Load(Path);

function OnGameHasBeenStarted()
    Lib.Require("comfort/AreEnemiesInArea");
    Lib.Require("comfort/CreateNameForEntity");
    Lib.Require("module/weather/WeatherMaker");
    Lib.Require("module/ai/AiArmy");
    Lib.Require("module/ai/AiTroopSpawner");
    Lib.Require("module/trigger/Job");

    UseWeatherSet("DesertWeatherSet");
    AddPeriodicSummer(360);
    LocalMusic.UseSet = MEDITERANEANMUSIC;

    ---
    SetupStronghold();
    SetupPlayer(1);
    SetupPlayer(2);
    ShowStrongholdConfiguration();
    ---
    EnemyData.Kerberos:Init();
    EnemyData.Varg:Init();
    EnemyData.Mary:Init();
end

-- -------------------------------------------------------------------------- --

EnemyData = {};

-- ########################################################################## --
-- #    Kerberos                                                            # --
-- ########################################################################## --

EnemyData.Kerberos = {
    ArmyRegister = {},
    BuildingRegister = {},
    SpawnerRegister = {},
    PlayerID = 3,
    HQ = "HQ3",
};

function EnemyData.Kerberos:Init()
    EnemyData:SaveAiPlayerBuildings("Kerberos");
    self:InitSpawners();
    Job.Second(function()
        return EnemyData:AiPlayerBuildingRespawner("Kerberos");
    end);
end

function EnemyData.Kerberos:InitSpawners()
end

-- ########################################################################## --
-- #    Varg                                                                # --
-- ########################################################################## --

EnemyData.Varg = {
    ArmyRegister = {},
    BuildingRegister = {},
    SpawnerRegister = {},
    PlayerID = 4,
    HQ = "HQ4",
};

function EnemyData.Varg:Init()
    EnemyData:SaveAiPlayerBuildings("Varg");
    self:InitSpawners();
    Job.Second(function()
        return EnemyData:AiPlayerBuildingRespawner("Varg");
    end);
end

function EnemyData.Varg:InitSpawners()
    local ArcheryTypes = {
        Entities.PU_LeaderBow2,
        Entities.PU_LeaderBow2,
        Entities.PU_LeaderBow3,
    };
    local BarracksTypes = {
        Entities.CU_Barbarian_LeaderClub1,
        Entities.CU_Barbarian_LeaderClub1,
        Entities.PU_LeaderPoleArm1,
    };
    local CannonTypes = {
        Entities.PV_Cannon1,
    };
    local StablesTypes = {
        Entities.PU_LeaderCavalry1,
    };

    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P4Archery1",
        SpawnPoint = "P4Archery1Spawn",
        AllowedTypes = ArcheryTypes
    });
    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P4Barracks1",
        SpawnPoint = "P4Barracks1Spawn",
        AllowedTypes = BarracksTypes
    });
    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P4Barracks2",
        SpawnPoint = "P4Barracks2Spawn",
        AllowedTypes = BarracksTypes
    });
    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P4Barracks3",
        SpawnPoint = "P4Barracks3Spawn",
        AllowedTypes = BarracksTypes
    });
    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P4Foundry1",
        SpawnPoint = "P4Foundry1Spawn",
        AllowedTypes = CannonTypes
    });
    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P4Stables1",
        SpawnPoint = "P4Stables1Spawn",
        AllowedTypes = StablesTypes
    });
end

-- ########################################################################## --
-- #    Mary                                                                # --
-- ########################################################################## --

EnemyData.Mary = {
    ArmyRegister = {},
    BuildingRegister = {},
    SpawnerRegister = {},
    PlayerID = 5,
    HQ = "HQ5",
};

function EnemyData.Mary:Init()
    EnemyData:SaveAiPlayerBuildings("Mary");
    self:InitSpawners();
    Job.Second(function()
        return EnemyData:AiPlayerBuildingRespawner("Mary");
    end);
end

function EnemyData.Mary:InitSpawners()
    local ArcheryTypes = {
        Entities.PU_LeaderBow4,
    };
    local BarracksTypes = {
        Entities.PU_LeaderPoleArm3,
        Entities.PU_LeaderSword2,
        Entities.PU_LeaderSword2,
    };
    local CannonTypes = {
        Entities.PV_Cannon1,
    };
    local StablesTypes = {
        Entities.PU_LeaderHeavyCavalry1,
    };

    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P5Archery1",
        SpawnPoint = "P5Archery1Spawn",
        AllowedTypes = ArcheryTypes
    });
    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P5Barracks1",
        SpawnPoint = "P5Barracks1Spawn",
        AllowedTypes = BarracksTypes
    });
    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P5Barracks2",
        SpawnPoint = "P5Barracks2Spawn",
        AllowedTypes = BarracksTypes
    });
    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P5Foundry1",
        SpawnPoint = "P5Foundry1Spawn",
        AllowedTypes = CannonTypes
    });
    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P5Foundry2",
        SpawnPoint = "P5Foundry2Spawn",
        AllowedTypes = CannonTypes
    });
    table.insert(self.SpawnerRegister, AiTroopSpawner.Create {
        ScriptName = "P5Stables1",
        SpawnPoint = "P5Stables1Spawn",
        AllowedTypes = StablesTypes
    });
end

-- -------------------------------------------------------------------------- --

function EnemyData:SaveAiPlayerBuildings(_Key)
    local PlayerID = self[_Key].PlayerID;
    self[_Key].BuildingRegister = {};
    for k,v in pairs(GetPlayerEntities(PlayerID, 0)) do
        if Logic.IsBuilding(v) == 1 then
            local ScriptName = CreateNameForEntity(v);
            local Orientation = Logic.GetEntityOrientation(v);
            local x,y,z = Logic.GetEntityOrientation(v);
            local EntityType = Logic.GetEntityType(v);
            table.insert(self[_Key].BuildingRegister, {
                ScriptName, EntityType, x, y, z, Orientation
            });
        end
    end
end

function EnemyData:AiPlayerBuildingRespawner(_Key)
    local PlayerID = self[_Key].PlayerID;
    if not IsExisting(self[_Key].HQ) then
        return true;
    end
    for i= 1, table.getn(self[_Key].BuildingRegister) do
        local Data = self[_Key].BuildingRegister[i];
        if not IsExisting(self[_Key].HQ) then
            if not AreEnemiesInArea(PlayerID, {X= Data[3], Y= Data[4]}, 4500) then
                local ID = Logic.CreateEntity(Data[2], Data[3], Data[4], Data[5], PlayerID);
                Logic.SetEntityName(ID, Data[1]);
            end
        end
    end
    return false;
end

-- -------------------------------------------------------------------------- --

function GameCallback_OnGameStart()
	Script.Load(Folders.MapTools.."Ai\\Support.lua");
	Script.Load("Data\\Script\\MapTools\\MultiPlayer\\MultiplayerTools.lua");
	Script.Load("Data\\Script\\MapTools\\Tools.lua");
	Script.Load("Data\\Script\\MapTools\\WeatherSets.lua");
	IncludeGlobals("Comfort");

	MultiplayerTools.InitCameraPositionsForPlayers();
	MultiplayerTools.SetUpGameLogicOnMPGameConfig();
	MultiplayerTools.GiveBuyableHerosToHumanPlayer(0);

	if XNetwork.Manager_DoesExist() == 0 then
		for i=1,4,1 do
			MultiplayerTools.DeleteFastGameStuff(i);
		end
		local PlayerID = GUI.GetPlayerID();
		Logic.PlayerSetIsHumanFlag(PlayerID, 1);
		Logic.PlayerSetGameStateToPlaying(PlayerID);
	end
    OnGameHasBeenStarted();
end

-- Must remain empty in the script because it is called by the game.
function Mission_InitWeatherGfxSets()
end

