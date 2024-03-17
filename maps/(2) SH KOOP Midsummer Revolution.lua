SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 1,

    -- ###################################################################### --
    -- #                             CONFIG                                 # --
    -- ###################################################################### --

    -- Disable standard victory condition?
    DisableDefaultWinCondition = true,
    -- Disable rule configuration?
    DisableRuleConfiguration = true,

    -- Peacetime in minutes (only needed for fixed peacetimes or singleplayer)
    PeaceTime = 0,

    -- Fill resource piles with resources
    -- (value of resources or 0 to not change)
    MapStartFillClay = 1000,
    MapStartFillStone = 1000,
    MapStartFillIron = 500,
    MapStartFillSulfur = 500,
    MapStartFillWood = 20000,

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
        UseWeatherSet("EuropeanWeatherSet");
        LocalMusic.UseSet = EUROPEMUSIC;

        Logic.SetModelAndAnimSet(GetID("VC_Blockade"), Models.XD_RockTideland7);
        MakeInvulnerable(GetID("ImposterMayor5"));
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        SetPlayerName(5, "Bishof");
        SetPlayerName(7, "Räuber");

        SetFriendly(1, 2);

        SetNeutral(1, 3);
        SetNeutral(1, 4);
        SetNeutral(1, 5);
        SetNeutral(1, 7);
        SetNeutral(2, 3);
        SetNeutral(2, 4);
        SetNeutral(2, 5);
        SetNeutral(2, 7);
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
    end,
}

function RevealEnemyCoalition()
    SetPlayerName(2, "Erzherzog Dovbar");
    SetPlayerName(3, "Dovbars linke Hand");
    SetPlayerName(4, "Dovbars rechte Hand");
end

