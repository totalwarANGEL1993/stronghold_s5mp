-- ###################################################################################################
-- #                                                                                                 #
-- #                                                                                                 #
-- #     Mapname:  Stronghold Testmap                                                                #
-- #                                                                                                 #
-- #     Author:   totalwarANGEL                                                                     #
-- #                                                                                                 #
-- #                                                                                                 #
-- ###################################################################################################

-- -------------------------------------------------------------------------- --

Script.Load("data\\maps\\user\\stronghold_s5mp\\loader.lua");

function OnMapStart()
    Player_Teams = {[1] = {1}, [2] = {2}};

    Lib.Require("comfort/CreateWoodPile");
    Lib.Require("module/weather/WeatherMaker");

    ---

    SetupStronghold();
    SetupHumanPlayer(1);
    SetupHumanPlayer(2);

    -- Cut off half of the map in Singleplayer
    if XNetwork.Manager_DoesExist() == 0 then
        Message("@color:255,0,0 SINGLEPLAYER MODUS");
        Message("Im Singleplayer sind Brücken und Wetteränderung gesperrt!");
        ForbidTechnology(Technologies.B_Bridge, 1);
        ForbidTechnology(Technologies.T_ChangeWeather, 1);
    end

    StockResourceEntities();
    CreatePilesOfWood();

    SetHostile(1, 7);
    SetHostile(2, 7);
    CreatePassiveBanditCamps();
    CreateAggressiveBanditCamps();

    UseWeatherSet("HighlandsWeatherSet");
    AddPeriodicSummer(360);
    AddPeriodicRain(90);
    LocalMusic.UseSet = HIGHLANDMUSIC;
end

-- Create wood piles
function CreatePilesOfWood()
    local WoodPiles = {Logic.GetEntities(Entities.XD_SingnalFireOff, 48)};
    for i= 2, WoodPiles[1] +1 do
        Logic.SetEntityName(WoodPiles[i], "WoodPile" ..i);
        CreateWoodPile("WoodPile" ..i, 25000);
    end
end

-- Fills resource heaps with additional units.
function StockResourceEntities()
    local ResourceHeapTypes = {
        Entities.XD_Clay1,
        Entities.XD_Iron1,
        Entities.XD_Stone1,
        Entities.XD_Sulfur1,
    }
    for _,Type in pairs(ResourceHeapTypes) do
        local Heaps = {Logic.GetEntities(Type, 48)};
        for i= 2, Heaps[1]+1, 1 do
            Logic.SetResourceDoodadGoodAmount(Heaps[i], 4000);
        end
    end
end

function CreatePassiveBanditCamps()
    for k,v in pairs{1, 3} do
        Treasure.RandomChest("VCCamp" ..v.. "Chest1", 1000, 2000);
        for j= 1, 3 do
            CreateTroopSpawner(
                7, "VCCamp" ..v.. "Tent" ..j, nil, 1, 60, 3000,
                Entities.CU_BanditLeaderSword2,
                Entities.CU_BanditLeaderBow1,
                Entities.CU_BanditLeaderBow1,
                Entities.CU_BanditLeaderBow1,
                Entities.PV_Cannon1
            );
        end
    end
end

function CreateAggressiveBanditCamps()
    for k,v in pairs{2, 4} do
        Treasure.RandomChest("VCCamp" ..v.. "Chest1", 2000, 4000);

        _G["VCCamp" ..v.. "Spawners"] = {};
        for j= 1, 5 do
            local ID = CreateTroopSpawner(
                7, "VCCamp" ..v.. "Tent" ..j, nil, 1, 60, 3000,
                Entities.CU_BanditLeaderSword2,
                Entities.CU_BanditLeaderSword2,
                Entities.CU_BanditLeaderBow1,
                Entities.CU_BanditLeaderBow1,
                Entities.PV_Cannon1
            );
            table.insert(_G["VCCamp" ..v.. "Spawners"], ID);
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
		for i=1,2,1 do
			MultiplayerTools.DeleteFastGameStuff(i);
		end
		local PlayerID = GUI.GetPlayerID();
		Logic.PlayerSetIsHumanFlag(PlayerID, 1);
		Logic.PlayerSetGameStateToPlaying(PlayerID);
	end
    OnMapStart();
end

