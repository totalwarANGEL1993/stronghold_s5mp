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

    -- Open up named gates on the map.
    -- (PTGate1, PTGate2, ...)
    PeaceTimeOpenGates = true,

    -- Fill resource piles with resources
    -- (value of resources or 0 to not change)
    MapStartFillClay = 4000,
    MapStartFillStone = 4000,
    MapStartFillIron = 2000,
    MapStartFillSulfur = 2000,
    MapStartFillWood = 1200,

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
        UseWeatherSet("DesertWeatherSet");
        AddPeriodicSummer(470);
        AddPeriodicRain(120);
        AddPeriodicWinter(240);
        AddPeriodicRain(120);
        LocalMusic.UseSet = MEDITERANEANMUSIC;

        for i= 1, 8 do
            SVLib.SetInvisibility(GetID("Blockade" ..i), true);
        end
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        for i= 1, 10 do
            ForbidTechnology(Technologies.B_Palisade, i);
            ForbidTechnology(Technologies.B_Wall, i);
        end
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
        for i= 1, 8 do
            DestroyEntity("BlockadeWood" ..i);
            DestroyEntity("Blockade" ..i);
        end
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
        UseWeatherSet("DesertWeatherSet");
    end,
}

