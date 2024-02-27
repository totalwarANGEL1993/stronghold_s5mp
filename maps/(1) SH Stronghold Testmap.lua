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
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        CreateProvince1();
        CreateProvince2();
        CreateProvince3();

        CreateCamp1();
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
        UseWeatherSet("EuropeanWeatherSet");
    end,
}

-- -------------------------------------------------------------------------- --
-- Camps

function CreateCamp1()
    gvTestCamp1 = DelinquentsCampCreate {
        PlayerID        = 2,
        HomePosition    = "TestCamp1Home",
        Strength        = 6,
        RodeLength      = 2500,
    };

    DelinquentsCampAddSpawner(
        gvTestCamp1, "TestCamp1", 30, 2,
        {Entities.PU_LeaderPoleArm1, 3},
        {Entities.PU_LeaderBow1, 3},
        {Entities.PU_LeaderSword1, 3}
    );

    DelinquentsCampAddTarget(gvTestCamp1, "PlayerHome");
    DelinquentsCampActivateAttack(gvTestCamp1, false);
end

-- -------------------------------------------------------------------------- --
-- Provinces

function CreateProvince1()
    CreateEncouragingProvince(
        "Oasis de Lune",
        "Province1Pos",
        0.10,
        0.5
    );
end

function CreateProvince2()
    CreateSlaveProvince(
        "Oasis de Sene",
        "Province2Pos",
        4,
        0.5
    );
end

function CreateProvince3()
    CreateResourceProvince(
        "la Source de Mystere",
        "Province3Pos",
        ResourceType.IronRaw,
        200,
        0.5
    );
end

