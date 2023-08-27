

function OnGameHasBeenStarted()
    Lib.Require("comfort/AreEnemiesInArea");
    Lib.Require("comfort/CreateNameForEntity");
    Lib.Require("module/weather/WeatherMaker");
    Lib.Require("module/ai/AiArmy");
    Lib.Require("module/ai/AiTroopSpawner");

    UseWeatherSet("DesertWeatherSet");
    AddPeriodicSummer(360);
    LocalMusic.UseSet = MEDITERANEANMUSIC;

    ---
    SetupStronghold();
    SetupPlayer(1);
    SetupPlayer(2);
    ShowStrongholdConfiguration({
        DisableDefaultWinCondition = true,
        PeaceTimeOpenGates = false,
        MapStartFillClay = false,
        MapStartFillStone = false,
        MapStartFillIron = false,
        MapStartFillSulfur = false,
        MapStartFillWood = false,

        AllowedHeroes = {
            [Entities.PU_Hero1c]             = true,
            [Entities.PU_Hero2]              = true,
            [Entities.PU_Hero3]              = true,
            [Entities.PU_Hero4]              = true,
            [Entities.PU_Hero5]              = true,
            [Entities.PU_Hero6]              = true,
            [Entities.CU_BlackKnight]        = false,
            [Entities.CU_Mary_de_Mortfichet] = false,
            [Entities.CU_Barbarian_Hero]     = false,
            [Entities.PU_Hero10]             = true,
            [Entities.PU_Hero11]             = true,
            [Entities.CU_Evil_Queen]         = true,
        },
    });
    ---
    InitKerberos();
    InitMary();
    InitVarg();
end

