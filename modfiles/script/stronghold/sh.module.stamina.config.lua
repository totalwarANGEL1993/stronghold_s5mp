--- 
--- Config for Stamina
--- 

Stronghold.Stamina.Config = {
    Movement = {
        RegularSpeedFactor = 0.7,
        AttackSpeedFactor = 1.0,
        RunToWalk = {
            ["TL_ASSASSIN_WALK_BATTLE"] = "TL_ASSASSIN_WALK",
            ["TL_LEADER_WALK_BATTLE"] = "TL_LEADER_WALK",
            ["TL_MILITIA_WALK_BATTLE"] = "TL_MILITIA_WALK",
            ["TL_SERF_WALK_BATTLE"] = "TL_SERF_WALK",
            ["TL_THIEF_WALK_BATTLE"] = "TL_THIEF_WALK",
        },
        WalkToRun = {
            ["TL_ASSASSIN_WALK"] = "TL_ASSASSIN_WALK_BATTLE",
            ["TL_LEADER_WALK"] = "TL_LEADER_WALK_BATTLE",
            ["TL_MILITIA_WALK"] = "TL_MILITIA_WALK_BATTLE",
            ["TL_SERF_WALK"] = "TL_SERF_WALK_BATTLE",
            ["TL_THIEF_WALK"] = "TL_THIEF_WALK_BATTLE",
        },
        IgnoredTypes = {
            [Entities.PU_Bear_Deco] = true,
            [Entities.PU_Criminal_Deco] = true,
            [Entities.PU_Dog_Deco] = true,
            [Entities.PU_Hawk_Deco] = true,
            [Entities.PU_Rat_Deco] = true,
            [Entities.PU_Watchman_Deco] = true,
        },
    },

    Endurance = {
        MaxStaminaThreshold = 3.00,
        FineStaminaThreshold = 1.75,
        GoodStaminaThreshold = 0.75,
        BadStaminaThreshold = 0.25,
        WorseStaminaThreshold = 0.10,

        FineDamageFactor = 1.25,
        GoodDamageFactor = 1.00,
        BadDamageFactor = 0.85,
        WorseDamageFactor = 0.70,

        RestingRecoveryTask = {
            ["TL_MILITARY_IDLE"] = true,
            ["TL_SERF_IDLE"] = true,
            ["TL_THIEF_IDLE"] = true,
            ["TL_VEHICLE_IDLE"] = false,
        },
        BattleDrainTasks = {
            ["TL_BATTLE"] = true,
            ["TL_BATTLE_AXE"] = true,
            ["TL_BATTLE_BEAR"] = false,
            ["TL_BATTLE_BOW"] = true,
            ["TL_BATTLE_CROSSBOW"] = true,
            ["TL_BATTLE_CLAW"] = false,
            ["TL_BATTLE_DOG"] = false,
            ["TL_BATTLE_KNIGHT"] = true,
            ["TL_BATTLE_HERO"] = false,
            ["TL_BATTLE_HEROBOW"] = false,
            ["TL_BATTLE_HEROCLAW"] = false,
            ["TL_BATTLE_HEROMACE"] = false,
            ["TL_BATTLE_HERORIFLE"] = false,
            ["TL_BATTLE_LION"] = true,
            ["TL_BATTLE_MACE"] = true,
            ["TL_BATTLE_POLEARM"] = true,
            ["TL_BATTLE_RIFLE"] = true,
            ["TL_BATTLE_SERF"] = true,
            ["TL_BATTLE_SKIRMISHER"] = true,
            ["TL_BATTLE_SWORD"] = true,
            ["TL_BATTLE_WOLF"] = true,
            ["TL_BATTLE_VEHICLE"] = false,
        },
        RunningDrainTasks = {
            ["TL_ASSASSIN_WALK_BATTLE"] = true,
            ["TL_FORMATION_BATTLE"] = true,
            ["TL_LEADER_WALK_BATTLE"] = true,
            ["TL_SERF_BUILD"] = true,
            ["TL_SERF_EXTRACT_RESOURCE"] = true,
            ["TL_SERF_EXTRACT_WOOD"] = true,
            ["TL_SERF_GO_TO_CONSTRUCTION_SITE"] = true,
            ["TL_SERF_GO_TO_RESOURCE"] = true,
            ["TL_SERF_GO_TO_TREE"] = true,
            ["TL_SERF_TURN_INTO_BATTLE_SERF"] = true,
            ["TL_START_BATTLE"] = true,
            ["TL_SERF_WALK_BATTLE"] = true,
        },

        RestingRecoveryRates = {
            [1] =  0.0100,
            [2] =  0.0100,
            [3] =  0.0100,
            [4] =  0.0100,
        },
        BattleDrainRates = {
            [1] = -0.0070,
            [2] = -0.0055,
            [3] = -0.0040,
            [4] = -0.0025,
        },
        RunningDrainRates = {
            [1] = -0.0030,
            [2] = -0.0025,
            [3] = -0.0020,
            [4] = -0.0015,
        },

        IgnoredTypes = {
            [Entities.PU_Bear_Cage] = true,
            [Entities.PU_Bear_Deco] = true,
            [Entities.PU_BattleSerf] = true,
            [Entities.PU_Criminal_Deco] = true,
            [Entities.PU_Dog_Cage] = true,
            [Entities.PU_Dog_Deco] = true,
            [Entities.PU_Hawk_Deco] = true,
            [Entities.PU_Rat_Deco] = true,
            [Entities.PU_Serf] = true,
            [Entities.PU_Watchman_Deco] = true,
        },
    }
};

