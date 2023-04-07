-- ###################################################################################################
-- #                                                                                                 #
-- #                                                                                                 #
-- #     Mapname:  Stronghold Testmap                                                                #
-- #                                                                                                 #
-- #     Author:   totalwarANGEL                                                                     #
-- #                                                                                                 #
-- #                                                                                                 #
-- ###################################################################################################

local Path = "data\\script\\stronghold\\sh.loader.lua";
Script.Load(Path);

function OnMapStart()
    Lib.Require("module/weather/WeatherMaker");

    UseWeatherSet("DesertWeatherSet");
    AddPeriodicSummer(360);
    LocalMusic.UseSet = MEDITERANEANMUSIC;

    ---
    SetupStronghold();
    SetupHumanPlayer(1);
    SetupHumanPlayer(2);
    SetupHumanPlayer(3);
    SetupHumanPlayer(4);
    ShowStrongholdConfiguration();
    ---

    SetHostile(1,7);
    SetHostile(2,7);
    SetHostile(3,7);
    SetHostile(4,7);

    SetupProvinces();
    SetupCamps();
end

function SetupProvinces()
    CreateHonorProvince(
        "Oasis de Lune",
        "Province1Pos",
        30,
        1.5,
        "Province1Hut1",
        "Province1Hut2",
        "Province1Hut3",
        "Province1Hut4",
        "Province1Hut5",
        "Province1Hut6",
        "Province1Hut7",
        "Province1Hut8"
    );

    CreateHonorProvince(
        "Oasis de Sene",
        "Province2Pos",
        30,
        1.5,
        "Province2Hut1",
        "Province2Hut2",
        "Province2Hut3",
        "Province2Hut4",
        "Province2Hut5",
        "Province2Hut6",
        "Province2Hut7",
        "Province2Hut8"
    );

    CreateResourceProvince(
        "la Source de Mystere",
        "Province3Pos",
        ResourceType.WoodRaw,
        600,
        1.5,
        "Province3Hut1",
        "Province3Hut2"
    )
end

function SetupCamps()
    CreateTroopSpawner(
        7, "Outpost1", nil, 3, 60, 3000,
        Entities.PU_LeaderSword3,
        Entities.PV_Cannon1,
        Entities.PV_Cannon1
    );
    for i= 1, 4 do
        CreateTroopSpawner(
            7, "OP1Tent"..i, nil, 1, 60, 3000,
            Entities.PU_LeaderPoleArm1,
            Entities.PU_LeaderPoleArm1,
            Entities.PU_LeaderBow1
        );
    end

    CreateTroopSpawner(
        7, "Outpost2", nil, 3, 60, 3000,
        Entities.PU_LeaderSword3,
        Entities.PV_Cannon1,
        Entities.PV_Cannon1
    );
    for i= 1, 4 do
        CreateTroopSpawner(
            7, "OP2Tent"..i, nil, 1, 60, 3000,
            Entities.PU_LeaderPoleArm1,
            Entities.PU_LeaderPoleArm1,
            Entities.PU_LeaderBow1
        );
    end
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
    OnMapStart();
end

