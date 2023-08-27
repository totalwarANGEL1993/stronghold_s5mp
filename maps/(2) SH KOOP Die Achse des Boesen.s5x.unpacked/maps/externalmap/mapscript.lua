-- ########################################################################## --
-- #                                                                        # --
-- #                                                                        # --
-- #     Mapname:  (2) SH KOOP Die Achse des Bösen                          # --
-- #                                                                        # --
-- #     Author:   totalwarANGEL                                            # --
-- #                                                                        # --
-- #                                                                        # --
-- ########################################################################## --

local Path = "data\\maps\\user\\stronghold_s5mp\\sh.loader.lua";
Script.Load(Path);

local Prefix = "E:/Siedler/Projekte/stronghold_s5mp/maps/(2) SH KOOP Die Achse des Boesen.s5x.unpacked/";
-- Prefix = "";
Script.Load(Prefix.. "maps/externalmap/script/main.lua");
Script.Load(Prefix.. "maps/externalmap/script/kerberos.lua");
Script.Load(Prefix.. "maps/externalmap/script/mary.lua");
Script.Load(Prefix.. "maps/externalmap/script/varg.lua");

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

