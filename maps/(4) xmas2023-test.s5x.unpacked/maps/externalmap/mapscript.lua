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

function OnMapStart()
    SetupStronghold();
    local Players = Syncer.GetActivePlayers();
    for i= 1, table.getn(Players) do
        SetupPlayer(Players[i]);
    end
    if SHS5MP_RulesDefinition.DisableRuleConfiguration then
        SetupStrongholdMultiplayerConfig(SHS5MP_RulesDefinition);
    else
        ShowStrongholdConfiguration(SHS5MP_RulesDefinition);
    end

    for i= 1, 4 do
        Tools.GiveResouces(i, 999999, 999999, 999999, 999999, 999999, 999999);
        AddHonor(i, 1000);
    end
    StartTestStuff();
end

-- -------------------------------------------------------------------------- --

function GameCallback_OnGameStart()
	Script.Load(Folders.MapTools.."Ai\\Support.lua");
	Script.Load("Data\\Script\\MapTools\\MultiPlayer\\MultiplayerTools.lua");
	Script.Load("Data\\Script\\MapTools\\Tools.lua");
	Script.Load("Data\\Script\\MapTools\\WeatherSets.lua");
	IncludeGlobals("Comfort");

	Script.Load("E:/Siedler/Projekte/stronghold_s5mp/maps/(4) xmas2023-test.s5x.unpacked/maps/externalmap/script/main.lua");

	MultiplayerTools.InitCameraPositionsForPlayers();
	MultiplayerTools.SetUpGameLogicOnMPGameConfig();
	MultiplayerTools.GiveBuyableHerosToHumanPlayer(0);

	if XNetwork.Manager_DoesExist() == 0 then
		for i=1,2,1 do
			MultiplayerTools.DeleteFastGameStuff(i);
		end
		local PlayerID = GUI.GetPlayerID();
		Logic.PlayerSetIsHumanFlag(PlayerID, 1);
		Logic.PlayerSetGameStateToPlaying(PlayerID);
	end

    AddPeriodicSummer(60);
    Mission_InitWeatherGfxSets();
    LocalMusic.UseSet = DARKMOORMUSIC;

    OnMapStart();
end

function Mission_InitWeatherGfxSets()
    SetupNormalWeatherGfxSet();
end

