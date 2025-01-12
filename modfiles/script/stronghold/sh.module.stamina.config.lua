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

        RestingRecovery = {
            ["TL_MILITARY_IDLE"] = 0.01,
            ["TL_SERF_IDLE"] = 0.01,
            ["TL_THIEF_IDLE"] = 0.01,
            ["TL_VEHICLE_IDLE"] = 0,
        },
        BattleDrain = {
            ["TL_BATTLE"] = -0.0075,
            ["TL_BATTLE_AXE"] = -0.0055,
            ["TL_BATTLE_BEAR"] = -0.0060,
            ["TL_BATTLE_BOW"] = -0.0050,
            ["TL_BATTLE_CROSSBOW"] = -0.0040,
            ["TL_BATTLE_CLAW"] = -0.0065,
            ["TL_BATTLE_DOG"] = -0.0060,
            ["TL_BATTLE_KNIGHT"] = -0.0055,
            ["TL_BATTLE_HERO"] = 0,
            ["TL_BATTLE_HEROBOW"] = 0,
            ["TL_BATTLE_HEROCLAW"] = 0,
            ["TL_BATTLE_HEROMACE"] = 0,
            ["TL_BATTLE_HERORIFLE"] = 0,
            ["TL_BATTLE_LION"] = -0.0060,
            ["TL_BATTLE_MACE"] = -0.0075,
            ["TL_BATTLE_POLEARM"] = -0.0055,
            ["TL_BATTLE_RIFLE"] = -0.0075,
            ["TL_BATTLE_SERF"] = 0.0095,
            ["TL_BATTLE_SKIRMISHER"] = -0.0055,
            ["TL_BATTLE_SWORD"] = -0.0085,
            ["TL_BATTLE_WOLF"] = -0.0060,
            ["TL_BATTLE_VEHICLE"] = 0,
        },
        RunningDrain = {
            ["TL_ASSASSIN_WALK_BATTLE"] = -0.0035,
            ["TL_FORMATION_BATTLE"] = -0.0035,
            ["TL_LEADER_WALK_BATTLE"] = -0.0035,
            ["TL_SERF_BUILD"] = -0.0015,
            ["TL_SERF_EXTRACT_RESOURCE"] = -0.0015,
            ["TL_SERF_EXTRACT_WOOD"] = -0.0015,
            ["TL_SERF_GO_TO_CONSTRUCTION_SITE"] = -0.0035,
            ["TL_SERF_GO_TO_RESOURCE"] = -0.0035,
            ["TL_SERF_GO_TO_TREE"] = -0.0035,
            ["TL_SERF_TURN_INTO_BATTLE_SERF"] = -0.0035,
            ["TL_START_BATTLE"] = -0.0035,
            ["TL_SERF_WALK_BATTLE"] = -0.0035,
        },
        IgnoredTypes = {
            [Entities.PU_Bear_Deco] = true,
            [Entities.PU_Criminal_Deco] = true,
            [Entities.PU_Dog_Deco] = true,
            [Entities.PU_Hawk_Deco] = true,
            [Entities.PU_Rat_Deco] = true,
            [Entities.PU_Watchman_Deco] = true,
        },
    }
};

