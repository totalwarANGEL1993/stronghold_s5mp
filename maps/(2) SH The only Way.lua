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
    DisableRuleConfiguration = false;
    -- Disable game start timer?
    -- (Requires rule config to be disabled!)
    DisableGameStartTimer = false;

    -- Open up named gates on the map.
    -- (PTGate1, PTGate2, ...)
    PeaceTimeOpenGates = true,

    -- Fill resource piles with resources
    -- (value of resources or 0 to not change)
    MapStartFillClay = 2000,
    MapStartFillStone = 2000,
    MapStartFillIron = 500,
    MapStartFillSulfur = 500,
    MapStartFillWood = 12000,

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
        [Entities.CU_BlackKnight]        = true,
        -- Mary
        [Entities.CU_Mary_de_Mortfichet] = true,
        -- Varg
        [Entities.CU_Barbarian_Hero]     = true,
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
        UseWeatherSet("EvelanceWeatherSet");
        AddPeriodicSummer(350);
        AddPeriodicRain(90);
        LocalMusic.UseSet = EVELANCEMUSIC;
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        ForbidTechnology(Technologies.B_PowerPlant, 1);
        ForbidTechnology(Technologies.B_PowerPlant, 2);

        SVLib.SetInvisibility(GetID("Blockade1"), true);
        SVLib.SetInvisibility(GetID("Blockade2"), true);
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
        AllowTechnology(Technologies.B_PowerPlant, 1);
        AllowTechnology(Technologies.B_PowerPlant, 2);

        DestroyEntity("Blockade1");
        DestroyEntity("Blockade2");
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
        UseWeatherSet("EvelanceWeatherSet");
    end,
}

