--- 
--- Config for Units
--- 

Stronghold.Unit.Config = {
    -- Spear --

    [Entities.PU_LeaderPoleArm1]            = {
        Button            = "Buy_LeaderSpear",
        Costs             = {
            [1] = {0, 14, 0, 35, 0, 0, 0},
            [2] = {0, 3, 0, 10, 0, 0, 0},
        },
        Right             = PlayerRight.LeaderPoleArm1,
        IsCivil           = false,
        Upkeep            = 15,
        Turns             = 65,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderPoleArm2]            = {
        Button            = "Buy_LeaderSpear",
        Costs             = {
            [1] = {2, 30, 0, 40, 0, 6, 0},
            [2] = {0, 5, 0, 10, 0, 2, 0},
        },
        Right             = PlayerRight.LeaderPoleArm2,
        IsCivil           = false,
        Upkeep            = 20,
        Turns             = 80,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderPoleArm3]            = {
        Button            = "Buy_LeaderSpear",
        Costs             = {
            [1] = {10, 140, 0, 80, 0, 20, 0},
            [2] = {0, 60, 0, 45, 0, 5, 0},
        },
        Right             = PlayerRight.LeaderPoleArm3,
        IsCivil           = false,
        Upkeep            = 40,
        Turns             = 175,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderPoleArm4]            = {
        Button            = "Buy_LeaderSpear",
        Costs             = {
            [1] = {10, 180, 0, 105, 0, 35, 0},
            [2] = {0, 65, 0, 50, 0, 12, 0},
        },
        Right             = PlayerRight.LeaderPoleArm4,
        IsCivil           = false,
        Upkeep            = 45,
        Turns             = 175,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Sword  --

    [Entities.PU_LeaderSword1]              = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {5, 45, 0, 0, 0, 60, 0},
            [2] = {0, 8, 0, 0, 0, 15, 0},
        },
        Right             = PlayerRight.LeaderSword1,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 80,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderSword2]              = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {8, 120, 0, 0, 0, 90, 0},
            [2] = {0, 20, 0, 0, 0, 40, 0},
        },
        Right             = PlayerRight.LeaderSword2,
        IsCivil           = false,
        Upkeep            = 40,
        Turns             = 90,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith1, Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderSword3]              = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {20, 180, 0, 0, 0, 125, 0},
            [2] = {0, 32, 0, 0, 0, 70, 0},
        },
        Right             = PlayerRight.LeaderSword3,
        IsCivil           = false,
        Upkeep            = 60,
        Turns             = 160,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderSword4]              = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {20, 200, 0, 0, 0, 140, 0},
            [2] = {0, 36, 0, 0, 0, 80, 0},
        },
        Right             = PlayerRight.LeaderSword4,
        IsCivil           = false,
        Upkeep            = 65,
        Turns             = 160,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Bow --

    [Entities.PU_LeaderBow1]                = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {3, 40, 0, 30, 0, 0, 0},
            [2] = {0, 7, 0, 10, 0, 0, 0},
        },
        Right             = PlayerRight.LeaderBow1,
        IsCivil           = false,
        Upkeep            = 20,
        Turns             = 75,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderBow2]                = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {4, 80, 0, 55, 0, 0, 0},
            [2] = {0, 14, 0, 15, 0, 0, 0},
        },
        Right             = PlayerRight.LeaderBow2,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 85,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderBow3]                = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {12, 200, 0, 35, 0, 45, 0},
            [2] = {0, 65, 0, 16, 0, 30, 0},
        },
        Right             = PlayerRight.LeaderBow3,
        IsCivil           = false,
        Upkeep            = 45,
        Turns             = 175,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderBow4]                = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {16, 250, 0, 40, 0, 50, 0},
            [2] = {0, 70, 0, 22, 0, 36, 0},
        },
        Right             = PlayerRight.LeaderBow4,
        IsCivil           = false,
        Upkeep            = 55,
        Turns             = 175,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Rifle --

    [Entities.PU_LeaderRifle1]              = {
        Button            = "Buy_LeaderRifle",
        Costs             = {
            [1] = {16, 290, 0, 30, 0, 0, 80},
            [2] = {0, 95, 0, 15, 0, 0, 40},
        },
        Right             = PlayerRight.LeaderRifle1,
        IsCivil           = false,
        Upkeep            = 40,
        Turns             = 120,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop1, Entities.PB_GunsmithWorkshop2},
    },
    [Entities.PU_LeaderRifle2]              = {
        Button            = "Buy_LeaderRifle",
        Costs             = {
            [1] = {28, 420, 0, 30, 0, 30, 110},
            [2] = {0, 120, 0, 15, 0, 15, 75},
        },
        Right             = PlayerRight.LeaderRifle2,
        IsCivil           = false,
        Upkeep            = 70,
        Turns             = 170,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop2},
    },

    -- Cavalry --

    [Entities.PU_LeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        Costs             = {
            [1] = {12, 210, 0, 45, 0, 30, 0},
            [2] = {0, 140, 0, 30, 0, 20, 0},
        },
        Right             = PlayerRight.LeaderCavalry1,
        IsCivil           = false,
        Upkeep            = 50,
        Turns             = 125,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderCavalry2]            = {
        Button            = "Buy_LeaderCavalryLight",
        Costs             = {
            [1] = {12, 265, 0, 20, 0, 50, 0},
            [2] = {0, 165, 0, 40, 0, 30, 0},
        },
        Right             = PlayerRight.LeaderCavalry2,
        IsCivil           = false,
        Upkeep            = 60,
        Turns             = 125,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Heavy Cavalry --
    [Entities.PU_LeaderHeavyCavalry1]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        Costs             = {
            [1] = {26, 450, 0, 0, 0, 120, 0},
            [2] = {0, 155, 0, 0, 0, 65, 0},
        },
        Right             = PlayerRight.LeaderHeavyCavalry1,
        IsCivil           = false,
        Upkeep            = 75,
        Turns             = 200,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderHeavyCavalry2]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        Costs             = {
            [1] = {26, 500, 0, 0, 0, 150, 0},
            [2] = {0, 180, 0, 0, 0, 85, 0},
        },
        Right             = PlayerRight.LeaderHeavyCavalry2,
        IsCivil           = false,
        Upkeep            = 85,
        Turns             = 200,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },

    -- Cannons --

    [Entities.PV_Cannon1]                   = {
        Button            = "Buy_Cannon1",
        Costs             = {
            [1] = {16, 450, 0, 50, 0, 150, 300},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Cannon1,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 0,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon2]                   = {
        Button            = "Buy_Cannon2",
        Costs             = {
            [1] = {16, 450, 0, 50, 0, 300, 150},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Cannon2,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 0,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon3]                   = {
        Button            = "Buy_Cannon3",
        Costs             = {
            [1] = {32, 950, 0, 100, 0, 450, 600},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Cannon3,
        IsCivil           = false,
        Upkeep            = 90,
        Turns             = 0,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon4]                   = {
        Button            = "Buy_Cannon4",
        Costs             = {
            [1] = {32, 950, 0, 100, 0, 600, 450},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Cannon4,
        IsCivil           = false,
        Upkeep            = 90,
        Turns             = 0,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },

    -- Special units --

    [Entities.PU_Scout]                     = {
        Button            = "Buy_Scout",
        Costs             = {
            [1] = {0, 150, 0, 50, 0, 50, 0},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Scout,
        IsCivil           = false,
        Upkeep            = 50,
        Turns             = 150,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Tavern1, Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },
    [Entities.PU_Thief]                     = {
        Button            = "Buy_Thief",
        Costs             = {
            [1] = {15, 500, 0, 0, 0, 100, 100},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Thief,
        IsCivil           = false,
        Upkeep            = 100,
        Turns             = 250,
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
        Upkeep            = 0,
        Turns             = 80,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Headquarters1, Entities.PB_Headquarters2, Entities.PB_Headquarters3},
        ProviderBuilding  = {},
    },

    -- Bandits --

    [Entities.CU_BanditLeaderSword2]        = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {8, 130, 0, 10, 0, 50, 0},
            [2] = {0, 24, 0, 4, 0, 18, 0},
        },
        Right             = PlayerRight.BanditSword2,
        IsCivil           = false,
        Upkeep            = 50,
        Turns             = 65,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderSword1]        = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {16, 250, 0, 0, 0, 74, 0},
            [2] = {0, 40, 0, 16, 0, 32, 0},
        },
        Right             = PlayerRight.BanditSword1,
        IsCivil           = false,
        Upkeep            = 75,
        Turns             = 150,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.CU_BanditLeaderBow1]          = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {6, 90, 0, 68, 0, 0, 0},
            [2] = {0, 25, 0, 28, 0, 0, 0},
        },
        Right             = PlayerRight.BanditBow1,
        IsCivil           = false,
        Upkeep            = 40,
        Turns             = 75,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },

    -- Barbarians --

    [Entities.CU_Barbarian_LeaderClub2]     = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {12, 94, 0, 40, 0, 30, 0},
            [2] = {0, 25, 0, 15, 0, 10, 0},
        },
        Right             = PlayerRight.Barbarian2,
        IsCivil           = false,
        Upkeep            = 45,
        Turns             = 80,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_Barbarian_LeaderClub1]     = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {25, 115, 0, 60, 0, 35, 0},
            [2] = {0, 30, 0, 20, 0, 15, 0},
        },
        Right             = PlayerRight.Barbarian1,
        IsCivil           = false,
        Upkeep            = 60,
        Turns             = 125,
        Soldiers          = 12,
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
        Right             = PlayerRight.BlackKnight2,
        IsCivil           = false,
        Upkeep            = 35,
        Turns             = 100,
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
        Right             = PlayerRight.BlackKnight1,
        IsCivil           = false,
        Upkeep            = 55,
        Turns             = 150,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Shrouded --

    [Entities.CU_Evil_LeaderBearman1]       = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {2, 70, 0, 140, 0, 35, 0},
            [2] = {0, 2, 0, 20, 0, 5, 0},
        },
        Right             = PlayerRight.Bearman,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 80,
        Soldiers          = 16,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.CU_Evil_LeaderSkirmisher1]    = {
        Button            = "Buy_LeaderBow",
        Costs             = {
            [1] = {3, 80, 0, 175, 0, 0, 0},
            [2] = {0, 3, 0, 25, 0, 0, 0},
        },
        Right             = PlayerRight.Skirmisher,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 80,
        Soldiers          = 16,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Kerberos Budyguard --

    [Entities.CU_BlackKnight]              = {
        Button            = "Buy_LeaderSword",
        Costs             = {
            [1] = {0, 0, 0, 0, 0, 0, 0},
            [2] = {10, 150, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.BlackKnight3,
        IsCivil           = false,
        Upkeep            = 0,
        Turns             = 5,
        Soldiers          = 3,
        RecruiterBuilding = {},
        ProviderBuilding  = {},
    },
}

function Stronghold.Unit.Config:Get(_Type, _PlayerID)
    if not _PlayerID or not IsPlayer(_PlayerID) then
        return self[_Type];
    end
    return Stronghold.Recruitment.Data[_PlayerID].Config[_Type];
end

