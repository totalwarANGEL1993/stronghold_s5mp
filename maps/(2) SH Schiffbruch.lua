SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 4,

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
    MapStartFillIron = 400,
    MapStartFillSulfur = 250,
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
        AddPeriodicSummer(350);
        AddPeriodicRain(90);
        LocalMusic.UseSet = HIGHLANDMUSIC;

        Lib.Require("comfort/StartCountdown");
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        ForbidTechnology(Technologies.B_PowerPlant, 1);
        ForbidTechnology(Technologies.B_PowerPlant, 2);
        CreateBanditCamps();

        StartCountdown(15 * 60, MakeBanditCampsAttack, false);
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
        AllowTechnology(Technologies.B_PowerPlant, 1);
        AllowTechnology(Technologies.B_PowerPlant, 2);
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
        UseWeatherSet("HighlandsWeatherSet");
    end,
}

-- -------------------------------------------------------------------------- --

function CreateBanditCamps()
    for _, Index in pairs{1, 3} do
        Treasure.RandomChest("VCCamp" ..Index.. "Chest1", 1000, 2000);
        local CampID = DelinquentsCampCreate {
            HomePosition = "VCCamp" ..Index.. "Center",
            Strength = 3,
        };
        _G["gvBanditCamp" ..Index] = CampID;

        for j= 1, 3 do
            DelinquentsCampAddSpawner(
                CampID, "VCCamp" ..Index.. "Tent" ..j, 60, 1,
                Entities.PU_LeaderPoleArm1,
                Entities.CU_BanditLeaderBow1,
                Entities.PV_Cannon1,
                Entities.CU_BanditLeaderSword2,
                Entities.CU_BanditLeaderBow1
            );
        end
    end

    for _, Index in pairs{2, 4} do
        Treasure.RandomChest("VCCamp" ..Index.. "Chest1", 2000, 4000);

        local CampID = DelinquentsCampCreate {
            HomePosition = "VCCamp" ..Index.. "Center",
            Strength = 8,
        };
        _G["gvBanditCamp" ..Index] = CampID;

        for j= 1, 6 do
            DelinquentsCampAddSpawner(
                CampID, "VCCamp" ..Index.. "Tent" ..j, 60, 1,
                Entities.CU_BanditLeaderSword2,
                Entities.PU_LeaderPoleArm2,
                Entities.PV_Cannon1,
                Entities.CU_BanditLeaderBow1,
                Entities.PV_Cannon1,
                Entities.PU_LeaderPoleArm2,
                Entities.CU_BanditLeaderSword2,
                Entities.PV_Cannon1
            );
        end

        DelinquentsCampAddTarget(CampID, "VCCamp" ..Index.. "Pos1");
        DelinquentsCampAddTarget(CampID, "VCCamp" ..Index.. "Pos2");
        DelinquentsCampAddTarget(CampID, "VCCamp" ..Index.. "Pos3");
        DelinquentsCampActivateAttack(CampID, false);
    end
end

function MakeBanditCampsAttack()
    --- @diagnostic disable-next-line: undefined-global
    DelinquentsCampActivateAttack(gvBanditCamp2, true);
    --- @diagnostic disable-next-line: undefined-global
    DelinquentsCampActivateAttack(gvBanditCamp4, true);
end

