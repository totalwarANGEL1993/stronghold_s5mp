-- ###################################################################################################
-- #                                                                                                 #
-- #                                                                                                 #
-- #     Mapname:  Stronghold Testmap                                                                #
-- #                                                                                                 #
-- #     Author:   totalwarANGEL                                                                     #
-- #                                                                                                 #
-- #                                                                                                 #
-- ###################################################################################################

local Path = "data\\maps\\user\\stronghold_s5mp\\sh.loader.lua";
Script.Load(Path);

function OnGameHasBeenStarted()
    Lib.Require("module/weather/WeatherMaker");

    UseWeatherSet("DesertWeatherSet");
    AddPeriodicSummer(360);
    LocalMusic.UseSet = MEDITERANEANMUSIC;

    ---
    SetupStronghold();
    SetupPlayer(1);
    SetupPlayer(2);
    SetupPlayer(3);
    SetupPlayer(4);
    ShowStrongholdConfiguration();
    ---

    GameCallback_SH_Logic_OnPeaceTimeOver = function()
        SetHostile(1,7);
        SetHostile(2,7);
        SetHostile(3,7);
        SetHostile(4,7);

        SetupProvinces();
        SetupCamps();
    end
end

function SetupProvinces()
    local Peacetime = GetSelectedPeacetime();

    CreateHonorProvince(
        "Oasis de Lune",
        "Province1Pos",
        math.floor((30 + (10 * (Peacetime -1))) + 0.5),
        0.5,
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
        math.floor((30 + (10 * (Peacetime -1))) + 0.5),
        0.5,
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
        math.floor((600 + (100 * (Peacetime -1))) + 0.5),
        0.75,
        "Province3Hut1",
        "Province3Hut2"
    )
end

function SetupCamps()
    local Peacetime = GetSelectedPeacetime();
    if Peacetime == 1 then
        SetupCampsWS0();
    elseif Peacetime == 2 then
        SetupCampsWS10();
    elseif Peacetime == 3 then
        SetupCampsWS20();
    elseif Peacetime == 4 then
        SetupCampsWS30();
    else
        SetupCampsWS40();
    end
end

function SetupCampsWS0()
    for j= 1,2 do
        CreateTroopSpawner(
            7, "Outpost" ..j, nil, 3, 120, 3000,
            Entities.PU_LeaderSword2,
            Entities.PU_LeaderBow2,
            Entities.PU_LeaderBow2
        );
        for i= 1, 4 do
            CreateTroopSpawner(
                7, "OP" ..j.. "Tent"..i, nil, 1, 120, 3000,
                Entities.PU_LeaderPoleArm1,
                Entities.PU_LeaderPoleArm1,
                Entities.PU_LeaderBow1
            );
        end
    end
end

function SetupCampsWS10()
    for j= 1,2 do
        ReplaceEntity("OP" ..j.. "Tower1", Entities.PB_Tower2);
        ReplaceEntity("OP" ..j.. "Tower2", Entities.PB_Tower2);
        CreateTroopSpawner(
            7, "Outpost" ..j, nil, 4, 90, 3000,
            Entities.PU_LeaderSword2,
            Entities.PU_LeaderBow2,
            Entities.PU_LeaderBow2
        );
        for i= 1, 4 do
            CreateTroopSpawner(
                7, "OP" ..j.. "Tent"..i, nil, 1, 90, 3000,
                Entities.PU_LeaderPoleArm2,
                Entities.PU_LeaderBow2
            );
        end
    end
end

function SetupCampsWS20()
    for j= 1,2 do
        ReplaceEntity("OP" ..j.. "Tower1", Entities.PB_DarkTower2);
        ReplaceEntity("OP" ..j.. "Tower2", Entities.PB_DarkTower2);
        CreateTroopSpawner(
            7, "Outpost" ..j, nil, 3, 90, 3000,
            Entities.PU_LeaderSword3,
            Entities.PU_LeaderRifle1,
            Entities.PV_Cannon1
        );
        for i= 1, 4 do
            CreateTroopSpawner(
                7, "OP" ..j.. "Tent"..i, nil, 2, 90, 3000,
                Entities.PU_LeaderPoleArm2,
                Entities.PU_LeaderPoleArm2,
                Entities.PU_LeaderBow2
            );
        end
    end
end

function SetupCampsWS30()
    for j= 1,2 do
        ReplaceEntity("OP" ..j.. "Tower1", Entities.PB_Tower3);
        ReplaceEntity("OP" ..j.. "Tower2", Entities.PB_Tower3);
        CreateTroopSpawner(
            7, "Outpost" ..j, nil, 3, 60, 3000,
            Entities.PU_LeaderSword3,
            Entities.PU_LeaderRifle1,
            Entities.PU_LeaderRifle1,
            Entities.PV_Cannon3
        );
        for i= 1, 4 do
            CreateTroopSpawner(
                7, "OP" ..j.. "Tent"..i, nil, 2, 60, 3000,
                Entities.PU_LeaderPoleArm2,
                Entities.PU_LeaderPoleArm2,
                Entities.PV_Cannon1
            );
        end
    end
end

function SetupCampsWS40()
    for j= 1,2 do
        ReplaceEntity("OP" ..j.. "Tower1", Entities.PB_DarkTower3);
        ReplaceEntity("OP" ..j.. "Tower2", Entities.PB_DarkTower3);
        CreateTroopSpawner(
            7, "Outpost" ..j, nil, 4, 60, 3000,
            Entities.PU_LeaderSword3,
            Entities.PU_LeaderRifle2,
            Entities.PV_Cannon3
        );
        for i= 1, 4 do
            CreateTroopSpawner(
                7, "OP" ..j.. "Tent"..i, nil, 2, 60, 3000,
                Entities.PU_LeaderPoleArm2,
                Entities.PU_LeaderRifle1,
                Entities.PV_Cannon1
            );
        end
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
    OnGameHasBeenStarted();
end

-- Must remain empty in the script because it is called by the game.
function Mission_InitWeatherGfxSets()
end

