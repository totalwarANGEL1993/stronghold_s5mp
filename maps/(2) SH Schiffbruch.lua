SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 2,

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

    -- Peacetime in minutes
    PeaceTime = 0,
    -- Open up named gates on the map.
    -- (PTGate1, PTGate2, ...)
    PeaceTimeOpenGates = true,

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
        UseWeatherSet("HighlandsWeatherSet");
        AddPeriodicSummer(360);
        AddPeriodicRain(90);
        LocalMusic.UseSet = HIGHLANDMUSIC;
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        SetHostile(1, 7);
        SetHostile(2, 7);
        CreatePassiveBanditCamps();
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
    end,
}

-- -------------------------------------------------------------------------- --

function CreatePassiveBanditCamps()
    for _, Index in pairs{1, 3} do
        Treasure.RandomChest("VCCamp" ..Index.. "Chest1", 1000, 2000);
        local CampID = DelinquentsCampCreate {
            HomePosition = "VCCamp" ..Index.. "Center",
            Strength = 3,
        };
        for j= 1, 3 do
            DelinquentsCampAddSpawner(
                CampID, "VCCamp" ..Index.. "Tent" ..j, 60, 1,
                Entities.CU_BanditLeaderSword2,
                Entities.PU_LeaderBow1,
                Entities.CU_BanditLeaderBow1,
                Entities.PV_Cannon1,
                Entities.PU_LeaderPoleArm1
            );
        end
    end

    for _, Index in pairs{2, 4} do
        Treasure.RandomChest("VCCamp" ..Index.. "Chest1", 2000, 4000);

        local CampID = DelinquentsCampCreate {
            HomePosition = "VCCamp" ..Index.. "Center",
            Strength = 12,
        };
        for j= 1, 5 do
            DelinquentsCampAddSpawner(
                CampID, "VCCamp" ..Index.. "Tent" ..j, 60, 1,
                Entities.CU_BanditLeaderSword2,
                Entities.PU_LeaderBow1,
                Entities.CU_BanditLeaderBow1,
                Entities.PV_Cannon1,
                Entities.PU_LeaderPoleArm1
            );
        end
    end
end

