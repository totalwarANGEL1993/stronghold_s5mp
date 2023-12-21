--- 
--- Config for Units
--- 

Stronghold.Unit.Config = {
    -- Spear --

    [Entities.PU_LeaderPoleArm1]            = {
        Button            = "Buy_LeaderSpear",
        Costs             = {
            [1] = {0, 14, 0, 35, 0, 0, 0},
            [2] = {0, 4, 0, 13, 0, 0, 0},
        },
        Right             = PlayerRight.SpearMilitia,
        IsCivil           = false,
        Upkeep            = 15,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderPoleArm2]            = {
        Button            = "Buy_LeaderSpear",
        Costs             = {
            [1] = {2, 30, 0, 40, 0, 6, 0},
            [2] = {0, 7, 0, 15, 0, 5, 0},
        },
        Right             = PlayerRight.SpearLancer,
        IsCivil           = false,
        Upkeep            = 20,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderPoleArm3]            = {
        Button            = "Buy_LeaderSpear",
        Costs             = {
            [1] = {10, 110, 0, 80, 0, 20, 0},
            [2] = {0, 80, 0, 90, 0, 10, 0},
        },
        Right             = PlayerRight.SpearLandsknecht,
        IsCivil           = false,
        Upkeep            = 40,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderPoleArm4]            = {
        Button            = "Buy_LeaderSpear",
        Costs             = {
            [1] = {15, 130, 0, 105, 0, 35, 0},
            [2] = {0, 90, 0, 100, 0, 24, 0},
        },
        Right             = PlayerRight.SpearHalberdier,
        IsCivil           = false,
        Upkeep            = 50,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Sword  --

    [Entities.PU_LeaderSword1]              = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {5, 50, 0, 0, 0, 60, 0},
            [2] = {0, 10, 0, 0, 0, 15, 0},
        },
        Right             = PlayerRight.SwordMilitia,
        IsCivil           = false,
        Upkeep            = 30,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderSword2]              = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {8, 120, 0, 0, 0, 90, 0},
            [2] = {0, 20, 0, 0, 0, 40, 0},
        },
        Right             = PlayerRight.SwordSquire,
        IsCivil           = false,
        Upkeep            = 40,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith1, Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderSword3]              = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {20, 150, 0, 0, 0, 125, 0},
            [2] = {0, 60, 0, 0, 0, 140, 0},
        },
        Right             = PlayerRight.SwordLong,
        IsCivil           = false,
        Upkeep            = 60,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderSword4]              = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {25, 175, 0, 0, 0, 135, 0},
            [2] = {0, 70, 0, 0, 0, 150, 0},
        },
        Right             = PlayerRight.SwordGuardist,
        IsCivil           = false,
        Upkeep            = 70,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Bow --

    [Entities.PU_LeaderBow1]                = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {3, 30, 0, 30, 0, 0, 0},
            [2] = {0, 8, 0, 15, 0, 0, 0},
        },
        Right             = PlayerRight.ArcherMilitia,
        IsCivil           = false,
        Upkeep            = 20,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderBow2]                = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {4, 40, 0, 48, 0, 0, 0},
            [2] = {0, 10, 0, 20, 0, 0, 0},
        },
        Right             = PlayerRight.ArcherLongbow,
        IsCivil           = false,
        Upkeep            = 30,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderBow3]                = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {12, 140, 0, 40, 0, 65, 0},
            [2] = {0, 35, 0, 15, 0, 35, 0},
        },
        Right             = PlayerRight.ArcherCrossbow,
        IsCivil           = false,
        Upkeep            = 45,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderBow4]                = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {16, 180, 0, 80, 0, 105, 0},
            [2] = {0, 70, 0, 30, 0, 80, 0},
        },
        Right             = PlayerRight.ArcherPavease,
        IsCivil           = false,
        Upkeep            = 55,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Rifle --

    [Entities.PU_LeaderRifle1]              = {
        Button            = "Buy_LeaderRifle",
        Costs             = {
            [1] = {16, 350, 0, 30, 0, 0, 100},
            [2] = {0, 120, 0, 15, 0, 0, 50},
        },
        Right             = PlayerRight.RifleHandgunner,
        IsCivil           = false,
        Upkeep            = 40,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop1, Entities.PB_GunsmithWorkshop2},
    },
    [Entities.PU_LeaderRifle2]              = {
        Button            = "Buy_LeaderRifle",
        Costs             = {
            [1] = {28, 500, 0, 30, 0, 30, 150},
            [2] = {0, 165, 0, 15, 0, 15, 85},
        },
        Right             = PlayerRight.RifleMusketman,
        IsCivil           = false,
        Upkeep            = 70,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop2},
    },

    -- Cavalry --

    [Entities.PU_LeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        Costs             = {
            [1] = {12, 180, 0, 45, 0, 30, 0},
            [2] = {0, 90, 0, 30, 0, 20, 0},
        },
        Right             = PlayerRight.CavalryBow,
        IsCivil           = false,
        Upkeep            = 50,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderCavalry2]            = {
        Button            = "Buy_LeaderCavalryLight",
        Costs             = {
            [1] = {18, 200, 0, 20, 0, 50, 0},
            [2] = {0, 95, 0, 40, 0, 30, 0},
        },
        Right             = PlayerRight.CavalryCrossbow,
        IsCivil           = false,
        Upkeep            = 60,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Heavy Cavalry --
    [Entities.PU_LeaderHeavyCavalry1]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        Costs             = {
            [1] = {26, 300, 0, 0, 0, 120, 0},
            [2] = {0, 115, 0, 0, 0, 65, 0},
        },
        Right             = PlayerRight.CavalrySword,
        IsCivil           = false,
        Upkeep            = 75,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderHeavyCavalry2]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        Costs             = {
            [1] = {32, 400, 0, 0, 0, 150, 0},
            [2] = {0, 130, 0, 0, 0, 85, 0},
        },
        Right             = PlayerRight.CavalryAxe,
        IsCivil           = false,
        Upkeep            = 85,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },

    -- Cannons --

    [Entities.CV_Cannon1]                   = {
        Button            = "Buy_Cannon1",
        Costs             = {
            [1] = {19, 350, 0, 65, 0, 125, 250},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.BigBombardCannon,
        IsCivil           = false,
        Upkeep            = 35,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.CV_Cannon2]                   = {
        Button            = "Buy_Cannon3",
        Costs             = {
            [1] = {38, 700, 0, 130, 0, 300, 500},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.DschihadCannon,
        IsCivil           = false,
        Upkeep            = 100,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon1]                   = {
        Button            = "Buy_Cannon1",
        Costs             = {
            [1] = {16, 300, 0, 50, 0, 100, 200},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.BombardCannon,
        IsCivil           = false,
        Upkeep            = 30,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon2]                   = {
        Button            = "Buy_Cannon2",
        Costs             = {
            [1] = {16, 300, 0, 50, 0, 200, 100},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.BronzeCannon,
        IsCivil           = false,
        Upkeep            = 30,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon3]                   = {
        Button            = "Buy_Cannon3",
        Costs             = {
            [1] = {32, 600, 0, 100, 0, 250, 400},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.IronCannon,
        IsCivil           = false,
        Upkeep            = 90,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon4]                   = {
        Button            = "Buy_Cannon4",
        Costs             = {
            [1] = {32, 600, 0, 100, 0, 400, 250},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.SiegeCannon,
        IsCivil           = false,
        Upkeep            = 90,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },

    -- Special units --

    [Entities.PU_Scout]                     = {
        Button            = "Buy_Scout",
        Costs             = {
            [1] = {0, 100, 0, 50, 0, 50, 0},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Scout,
        IsCivil           = true,
        Upkeep            = 50,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Tavern1, Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },
    [Entities.PU_Thief]                     = {
        Button            = "Buy_Thief",
        Costs             = {
            [1] = {15, 350, 0, 0, 0, 75, 75},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Thief,
        IsCivil           = true,
        Upkeep            = 100,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },
    [Entities.PU_Serf]                      = {
        Button            = "Buy_Serf",
        Costs             = {
            [1] = {0, 50, 0, 0, 0, 0, 0},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Serf,
        IsCivil           = true,
        IsSlave           = true,
        Upkeep            = 0,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Headquarters1, Entities.PB_Headquarters2, Entities.PB_Headquarters3},
        ProviderBuilding  = {},
    },

    -- Crusader --

    [Entities.CU_Templar_LeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        Costs             = {
            [1] = {12, 180, 0, 20, 0, 40, 0},
            [2] = {0, 95, 0, 20, 0, 15, 0},
        },
        Right             = PlayerRight.CavalryCrusader,
        IsCivil           = false,
        Upkeep            = 55,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },
    [Entities.CU_Templar_LeaderHeavyCavalry1]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        Costs             = {
            [1] = {26, 250, 0, 0, 0, 100, 0},
            [2] = {0, 65, 0, 0, 0, 34, 0},
        },
        Right             = PlayerRight.CavalryTemplar,
        IsCivil           = false,
        Upkeep            = 85,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },
    [Entities.CU_Templar_LeaderPoleArm1]            = {
        Button            = "Buy_LeaderSpear",
        Costs             = {
            [1] = {10, 110, 0, 80, 0, 20, 0},
            [2] = {0, 40, 0, 44, 0, 6, 0},
        },
        Right             = PlayerRight.SpearLandsknecht,
        IsCivil           = false,
        Upkeep            = 40,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Huscarls --

    [Entities.CU_BanditLeaderSword2]        = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {10, 130, 0, 10, 0, 50, 0},
            [2] = {0, 50, 0, 8, 0, 36, 0},
        },
        Right             = PlayerRight.BerserkWeak,
        IsCivil           = false,
        Upkeep            = 50,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderSword1]        = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {16, 220, 0, 0, 0, 74, 0},
            [2] = {0, 70, 0, 42, 0, 64, 0},
        },
        Right             = PlayerRight.BerserkStrong,
        IsCivil           = false,
        Upkeep            = 75,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Bandits --

    [Entities.CU_BanditLeaderSword3]        = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {0, 50, 0, 0, 0, 60, 0},
            [2] = {0, 10, 0, 0, 0, 30, 0},
        },
        Right             = PlayerRight.BanditSword,
        IsCivil           = false,
        Upkeep            = 30,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderBow1]          = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {4, 40, 0, 48, 0, 0, 0},
            [2] = {0, 10, 0, 18, 0, 0, 0},
        },
        Right             = PlayerRight.BanditBow,
        IsCivil           = false,
        Upkeep            = 20,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        Costs             = {
            [1] = {18, 200, 0, 20, 0, 50, 0},
            [2] = {0, 95, 0, 40, 0, 30, 0},
        },
        Right             = PlayerRight.CavalryRanger,
        IsCivil           = false,
        Upkeep            = 65,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Barbarians --

    [Entities.CU_Barbarian_LeaderClub2]     = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {14, 70, 0, 40, 0, 30, 0},
            [2] = {0, 20, 0, 20, 0, 12, 0},
        },
        Right             = PlayerRight.BarbarianWeak,
        IsCivil           = false,
        Upkeep            = 45,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_Barbarian_LeaderClub1]     = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {28, 100, 0, 60, 0, 35, 0},
            [2] = {0, 32, 0, 25, 0, 20, 0},
        },
        Right             = PlayerRight.BarbarianStrong,
        IsCivil           = false,
        Upkeep            = 60,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith1, Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Black Knights --

    [Entities.CU_BlackKnight_LeaderMace2]   = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {8, 120, 0, 0, 0, 70, 0},
            [2] = {0, 25, 0, 0, 0, 35, 0},
        },
        Right             = PlayerRight.BlackKnightWeak,
        IsCivil           = false,
        Upkeep            = 35,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BlackKnight_LeaderMace1]   = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {16, 200, 0, 0, 0, 120, 0},
            [2] = {0, 45, 0, 0, 0, 55, 0},
        },
        Right             = PlayerRight.BlackKnightStrong,
        IsCivil           = false,
        Upkeep            = 55,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Shrouded --

    [Entities.CU_Evil_LeaderBearman1]       = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {4, 75, 0, 130, 0, 30, 0},
            [2] = {0, 3, 0, 10, 0, 7, 0},
        },
        Right             = PlayerRight.Bearman,
        IsCivil           = false,
        Upkeep            = 50,
        Soldiers          = 16,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.CU_Evil_LeaderSkirmisher1]    = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {5, 90, 0, 150, 0, 0, 0},
            [2] = {0, 4, 0, 17, 0, 0, 0},
        },
        Right             = PlayerRight.Skirmisher,
        IsCivil           = false,
        Upkeep            = 50,
        Soldiers          = 16,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Kerberos Bodyguard --

    [Entities.CU_BlackKnight]              = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {0, 0, 0, 0, 0, 0, 0},
            [2] = {10, 150, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.BlackKnightGuard,
        IsCivil           = false,
        Upkeep            = 0,
        Soldiers          = 3,
        RecruiterBuilding = {},
        ProviderBuilding  = {},
    },
}

function Stronghold.Unit.Config:Get(_Type, _PlayerID)
    if not _PlayerID or not IsPlayer(_PlayerID) then
        return self[_Type];
    end
    return Stronghold.Recruit.Data[_PlayerID].Config[_Type];
end

