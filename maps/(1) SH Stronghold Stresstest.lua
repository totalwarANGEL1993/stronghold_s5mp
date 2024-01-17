SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 1,

    -- ###################################################################### --
    -- #                             CONFIG                                 # --
    -- ###################################################################### --

    -- Disable standard victory condition?
    -- (Game is not lost when the HQ falls)
    DisableDefaultWinCondition = false,
    -- Disable rule configuration?
    DisableRuleConfiguration = true;

    -- Peacetime in minutes
    PeaceTime = 0,
    -- Open up named gates on the map.
    -- (PTGate1, PTGate2, ...)
    PeaceTimeOpenGates = true,

    -- Serfs
    StartingSerfs = 6,

    -- Fill resource piles with resources
    -- (value of resources or 0 to not change)
    MapStartFillClay = 4000,
    MapStartFillStone = 4000,
    MapStartFillIron = 4000,
    MapStartFillSulfur = 4000,
    MapStartFillWood = 4000,

    -- Rank
    Rank = {
        Initial = 0,
        Final = 7,
    },

    -- Setup heroes allowed
    AllowedHeroes = {
        -- Dario
        [Entities.PU_Hero1c]             = true,
        -- Pilgrim
        [Entities.PU_Hero2]              = true,
        -- Salim
        [Entities.PU_Hero3]              = true,
        -- Erec
        [Entities.PU_Hero4]              = true,
        -- Ari
        [Entities.PU_Hero5]              = true,
        -- Helias
        [Entities.PU_Hero6]              = true,
        -- Kerberos
        [Entities.CU_BlackKnight]        = false,
        -- Mary
        [Entities.CU_Mary_de_Mortfichet] = false,
        -- Varg
        [Entities.CU_Barbarian_Hero]     = false,
        -- Drake
        [Entities.PU_Hero10]             = true,
        -- Yuki
        [Entities.PU_Hero11]             = true,
        -- Kala
        [Entities.CU_Evil_Queen]         = true,
    },

    -- ###################################################################### --
    -- #                            CALLBACKS                               # --
    -- ###################################################################### --

    -- Called when map is loaded
    OnMapStart = function()
        UseWeatherSet("EuropeanWeatherSet");
        LocalMusic.UseSet = EUROPEMUSIC;

        SetupPlayer(2, 9);
        SetupPlayer(3, 9);
        SetupPlayer(4, 9);
        SetupPlayer(5, 9);
        SetupPlayer(6, 9);
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        Game.GameTimeSetFactor(20);
        Game.ShowFPS(1);
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
        UseWeatherSet("EuropeanWeatherSet");
    end,
}

