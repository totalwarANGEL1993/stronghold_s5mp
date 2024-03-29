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
        [Entities.PB_SulfurMine1] = 3,
        [Entities.PB_SulfurMine2] = 4,
        [Entities.PB_SulfurMine3] = 5,

        PickaxeClayBonus = 1,
        PickaxeStoneBonus = 1,
        PickaxeIronBonus = 1,
        PickaxeSulfurBonus = 1,
        SustainableClayMining = 1,
        SustainableStoneMining = 1,
        SustainableIronMining = 1,
        SustainableSulfurMining = 1,
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
        [Entities.PB_Blacksmith1] = 3;
        [Entities.PB_Blacksmith2] = 3;
        [Entities.PB_Blacksmith3] = 3;
        [Entities.PB_Alchemist1] = 3;
        [Entities.PB_Alchemist2] = 3;
        [Entities.PB_GunsmithWorkshop1] = 3;
        [Entities.PB_GunsmithWorkshop2] = 3;
    },
    Extracting = {
        [ResourceType.GoldRaw] = 1,
        [ResourceType.ClayRaw] = 2,
        [ResourceType.WoodRaw] = 3,
        [ResourceType.StoneRaw] = 2,
        [ResourceType.IronRaw] = 2,
        [ResourceType.SulfurRaw] = 2,

        SharpAxeBonus = 1,
        HardHandleBonus = 1,
    },
}

Stronghold.Economy.Config.Income = {
    MaxInfluencePoints = 5000,
    MaxKnowledgePoints = 5000,
    MaxReputation = 200,
    TaxPerWorker = 5,
    ScaleBonusFactor = 1.15,
    DebentureBonus = 1,
    CoinageBonus = 1,
    KnowledgePointsPerWorker = 12,
    BetterStudiesFactor = 1.2,
    InfluenceWorkerFactor = 0.98,
    InfluenceHardCap = 25,
    InfluenceBase = 12,
    InfluenceRank = 3,
    HungerFactor = 1.0105,
    HungerMultiplier = 10,
    InsomniaFactor = 1.0095,
    InsomniaMultiplier = 15,

    TaxEffect = {
        [1] = {Honor = 4, Reputation = 10,},
        [2] = {Honor = 2, Reputation = -1,},
        [3] = {Honor = 1, Reputation = -2,},
        [4] = {Honor = 0, Reputation = -4,},
        [5] = {Honor = 0, Reputation = -8,},
        WorkerFactor = 0.021,
        RankFactor = 1.05,
    },

    TechnologyEffect = {
        [Technologies.T_CropCycle]   = {
            [Entities.PB_Farm1]      = {Honor =    0, Reputation =    0,},
            [Entities.PB_Farm2]      = {Honor = 0.08, Reputation =    0,},
            [Entities.PB_Farm3]      = {Honor = 0.14, Reputation =    0,},
        },
        [Technologies.T_Spice]       = {
            [Entities.PB_Farm1]      = {Honor =    0, Reputation =    0,},
            [Entities.PB_Farm2]      = {Honor = 0.08, Reputation =    0,},
            [Entities.PB_Farm3]      = {Honor = 0.14, Reputation =    0,},
        },
        [Technologies.T_Hearthfire]  = {
            [Entities.PB_Residence1] = {Honor =    0, Reputation =    0,},
            [Entities.PB_Residence2] = {Honor =    0, Reputation = 0.09,},
            [Entities.PB_Residence3] = {Honor =    0, Reputation = 0.12,},
        },
        [Technologies.T_RoomKeys]    = {
            [Entities.PB_Residence1] = {Honor =    0, Reputation =    0,},
            [Entities.PB_Residence2] = {Honor =    0, Reputation = 0.09,},
            [Entities.PB_Residence3] = {Honor =    0, Reputation = 0.12,},
        },
        [Technologies.T_Instruments] = {
            [Entities.PB_Tavern1]    = {Honor = 0.35, Reputation =    0,},
            [Entities.PB_Tavern2]    = {Honor = 0.20, Reputation =    0,},
        },
    },

    Dynamic = {
        [Entities.PB_Farm1]      = {Honor =    0, Reputation =    0,},
        [Entities.PB_Farm2]      = {Honor = 0.12, Reputation =    0,},
        [Entities.PB_Farm3]      = {Honor = 0.18, Reputation =    0,},
        ---
        [Entities.PB_Residence1] = {Honor =    0, Reputation =    0,},
        [Entities.PB_Residence2] = {Honor =    0, Reputation = 0.09,},
        [Entities.PB_Residence3] = {Honor =    0, Reputation = 0.12,},
        ---
        [Entities.PB_Tavern1]    = {Honor =    0, Reputation = 0.35,},
        [Entities.PB_Tavern2]    = {Honor =    0, Reputation = 0.20,},
    },
    Static = {
        [Entities.PB_Beautification04]  = {Honor = 1, Reputation = 1,},
        [Entities.PB_Beautification06]  = {Honor = 1, Reputation = 1,},
        [Entities.PB_Beautification09]  = {Honor = 1, Reputation = 1,},
        ---
        [Entities.PB_Beautification01]  = {Honor = 2, Reputation = 1,},
        [Entities.PB_Beautification02]  = {Honor = 2, Reputation = 1,},
        [Entities.PB_Beautification12]  = {Honor = 2, Reputation = 1,},
        ---
        [Entities.PB_Beautification05]  = {Honor = 3, Reputation = 1,},
        [Entities.PB_Beautification07]  = {Honor = 3, Reputation = 1,},
        [Entities.PB_Beautification08]  = {Honor = 3, Reputation = 1,},
        ---
        [Entities.PB_Beautification03]  = {Honor = 6, Reputation = 1,},
        [Entities.PB_Beautification10]  = {Honor = 6, Reputation = 1,},
        [Entities.PB_Beautification11]  = {Honor = 6, Reputation = 1,},
        ---
        [Entities.PB_Monastery1]        = {Honor = 0, Reputation = 6,},
        [Entities.PB_Monastery2]        = {Honor = 0, Reputation = 9,},
        [Entities.PB_Monastery3]        = {Honor = 0, Reputation = 12,},
        ---
        [Entities.PB_ExecutionerPlace1] = {Honor = 10, Reputation = 10,},
    },
}

Stronghold.Economy.Config.SelectCategoryMapping = {
    [UpgradeCategories.Serf] = {
        Entities.PU_BattleSerf,
        Entities.PU_Serf,
    },
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
        Entities.CU_BanditLeaderCavalry1,
        Entities.CU_TemplarLeaderCavalry1,
        Entities.PU_LeaderCavalry1,
        Entities.PU_LeaderCavalry2,
    },
    [UpgradeCategories.LeaderHeavyCavalry] = {
        Entities.CU_TemplarLeaderHeavyCavalry1,
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
        Entities.CV_Cannon1,
        Entities.CV_Cannon2,
        Entities.PV_Cannon1,
        Entities.PV_Cannon2,
        Entities.PV_Cannon3,
        Entities.PV_Cannon4,
        Entities.PV_Cannon7,
        Entities.PV_Cannon8,
    },
}

