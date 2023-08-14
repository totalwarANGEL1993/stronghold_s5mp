--- 
--- Configuration for economy script
--- 

Stronghold.Economy.Config.Resource = {
    Mining = {
        [Entities.PB_ClayMine1] = 4,
        [Entities.PB_ClayMine2] = 5,
        [Entities.PB_ClayMine3] = 6,
        [Entities.PB_IronMine1] = 4,
        [Entities.PB_IronMine2] = 5,
        [Entities.PB_IronMine3] = 6,
        [Entities.PB_StoneMine1] = 4,
        [Entities.PB_StoneMine2] = 5,
        [Entities.PB_StoneMine3] = 6,
        [Entities.PB_SulfurMine1] = 4,
        [Entities.PB_SulfurMine2] = 5,
        [Entities.PB_SulfurMine3] = 6,
    },
    Refining = {
        [Entities.PB_Bank1] = 2,
        [Entities.PB_Bank2] = 2,
        [Entities.PB_Brickworks1] = 4;
        [Entities.PB_Brickworks2] = 4;
        [Entities.PB_StoneMason1] = 4;
        [Entities.PB_StoneMason2] = 4;
        [Entities.PB_Sawmill1] = 4;
        [Entities.PB_Sawmill2] = 4;
        [Entities.PB_Blacksmith1] = 4;
        [Entities.PB_Blacksmith2] = 4;
        [Entities.PB_Blacksmith3] = 4;
        [Entities.PB_Alchemist1] = 4;
        [Entities.PB_Alchemist2] = 4;
        [Entities.PB_GunsmithWorkshop1] = 4;
        [Entities.PB_GunsmithWorkshop2] = 4;
    },
}

Stronghold.Economy.Config.Income = {
    MaxMeasruePoints = 5000,
    MaxKnowledgePoints = 5000,
    MaxReputation = 200,
    TaxPerWorker = 6,
    ScaleBonusFactor = 1.05,
    DebentureBonusFactor = 1,
    CoinageBonusFactor = 1,
    KnowledgePointsPerWorker = 8,
    BetterStudiesFactor = 1.3,

    TaxEffect = {
        [1] = {Honor = 4, Reputation = 12,},
        [2] = {Honor = 2, Reputation = -3,},
        [3] = {Honor = 1, Reputation = -6,},
        [4] = {Honor = 0, Reputation = -14,},
        [5] = {Honor = 0, Reputation = -20,},
    },

    TechnologyEffect = {
        [Technologies.T_CropCycle]   = {
            [Entities.PB_Farm2]      = {Honor = 0.09, Reputation = 0.03,},
            [Entities.PB_Farm3]      = {Honor = 0.12, Reputation = 0.06,},
        },
        [Technologies.T_Spice]       = {
            [Entities.PB_Farm2]      = {Honor = 0.18, Reputation = 0.06,},
            [Entities.PB_Farm3]      = {Honor = 0.21, Reputation = 0.09,},
        },
        [Technologies.T_Hearthfire]  = {
            [Entities.PB_Residence2] = {Honor = 0.03, Reputation = 0.09,},
            [Entities.PB_Residence3] = {Honor = 0.06, Reputation = 0.12,},
        },
        [Technologies.T_RoomKeys]    = {
            [Entities.PB_Residence2] = {Honor = 0.06, Reputation = 0.18,},
            [Entities.PB_Residence3] = {Honor = 0.09, Reputation = 0.21,},
        },
        [Technologies.T_Instruments] = {
            [Entities.PB_Tavern1]    = {Honor = 0.25, Reputation = 0.0,},
            [Entities.PB_Tavern2]    = {Honor = 0.30, Reputation = 0.0,},
        },
    },

    Dynamic = {
        [Entities.PB_Farm2]      = {Honor = 0.12, Reputation = 0.06,},
        [Entities.PB_Farm3]      = {Honor = 0.18, Reputation = 0.09,},
        ---
        [Entities.PB_Residence2] = {Honor = 0.06, Reputation = 0.12,},
        [Entities.PB_Residence3] = {Honor = 0.09, Reputation = 0.18,},
        ---
        [Entities.PB_Tavern1]    = {Honor = 0, Reputation = 0.40,},
        [Entities.PB_Tavern2]    = {Honor = 0, Reputation = 0.55,},
    },
    Static = {
        [Entities.PB_Beautification04] = {Honor = 1, Reputation = 1,},
        [Entities.PB_Beautification06] = {Honor = 1, Reputation = 1,},
        [Entities.PB_Beautification09] = {Honor = 1, Reputation = 1,},
        ---
        [Entities.PB_Beautification01] = {Honor = 2, Reputation = 1,},
        [Entities.PB_Beautification02] = {Honor = 2, Reputation = 1,},
        [Entities.PB_Beautification12] = {Honor = 2, Reputation = 1,},
        ---
        [Entities.PB_Beautification05] = {Honor = 3, Reputation = 1,},
        [Entities.PB_Beautification07] = {Honor = 3, Reputation = 1,},
        [Entities.PB_Beautification08] = {Honor = 3, Reputation = 1,},
        ---
        [Entities.PB_Beautification03] = {Honor = 4, Reputation = 1,},
        [Entities.PB_Beautification10] = {Honor = 4, Reputation = 1,},
        [Entities.PB_Beautification11] = {Honor = 4, Reputation = 1,},
        ---
        [Entities.PB_Headquarters2]    = {Honor =  6, Reputation = 0,},
        [Entities.PB_Headquarters3]    = {Honor = 12, Reputation = 0,},
        ---
        [Entities.PB_Monastery1]       = {Honor = 0, Reputation = 6,},
        [Entities.PB_Monastery2]       = {Honor = 0, Reputation = 9,},
        [Entities.PB_Monastery3]       = {Honor = 0, Reputation = 12,},
    },
}

Stronghold.Economy.Config.CategoryMapping = {
    [UpgradeCategories.LeaderSword] = {
        Entities.CU_BanditLeaderSword1,
        Entities.CU_BanditLeaderSword2,
        Entities.CU_Barbarian_LeaderClub1,
        Entities.CU_Barbarian_LeaderClub2,
        Entities.CU_BlackKnight_LeaderMace1,
        Entities.CU_BlackKnight_LeaderMace2,
        Entities.CU_Evil_LeaderBearman1,
        Entities.PU_LeaderSword1,
        Entities.PU_LeaderSword2,
        Entities.PU_LeaderSword3,
        Entities.PU_LeaderSword4,
    },
    [UpgradeCategories.LeaderPoleArm] = {
        Entities.PU_LeaderPoleArm1,
        Entities.PU_LeaderPoleArm2,
        Entities.PU_LeaderPoleArm3,
        Entities.PU_LeaderPoleArm4,
    },
    [UpgradeCategories.LeaderBow] = {
        Entities.CU_BanditLeaderBow1,
        Entities.CU_Evil_LeaderSkirmisher1,
        Entities.PU_LeaderBow1,
        Entities.PU_LeaderBow2,
        Entities.PU_LeaderBow3,
        Entities.PU_LeaderBow4,
    },
    [UpgradeCategories.LeaderCavalry] = {
        Entities.PU_LeaderCavalry1,
        Entities.PU_LeaderCavalry2,
    },
    [UpgradeCategories.LeaderHeavyCavalry] = {
        Entities.PU_LeaderHeavyCavalry1,
        Entities.PU_LeaderHeavyCavalry2,
    },
    [UpgradeCategories.LeaderRifle] = {
        Entities.PU_LeaderRifle1,
        Entities.PU_LeaderRifle2,
    },
    [UpgradeCategories.Scout] = {
        Entities.PU_Scout,
    },
    [UpgradeCategories.Thief] = {
        Entities.PU_Thief,
    },
    [UpgradeCategories.Cannon1] = {
        Entities.PV_LeaderCannon1,
        Entities.PV_LeaderCannon2,
        Entities.PV_LeaderCannon3,
        Entities.PV_LeaderCannon4,
    },
}

