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
        [Entities.PB_Bank2] = 3,
        [Entities.PB_Brickworks1] = 4;
        [Entities.PB_Brickworks2] = 5;
        [Entities.PB_StoneMason1] = 4;
        [Entities.PB_StoneMason2] = 5;
        [Entities.PB_Sawmill1] = 4;
        [Entities.PB_Sawmill2] = 5;
        [Entities.PB_Blacksmith1] = 3;
        [Entities.PB_Blacksmith2] = 3;
        [Entities.PB_Blacksmith3] = 4;
        [Entities.PB_Alchemist1] = 3;
        [Entities.PB_Alchemist2] = 4;
        [Entities.PB_GunsmithWorkshop1] = 3;
        [Entities.PB_GunsmithWorkshop2] = 4;
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
    MaxReputation = 200,
    HungerFactor = 16.000,
    InsomniaFactor = 16.000,
    --
    MaxKnowledgePoints = 5000,
    KnowledgePointsPerWorker = 12,
    BetterStudiesFactor = 1.200,
    --
    MaxInfluencePoints = 5000,
    InfluenceWorkerFactor = 1,
    InfluenceHardCap = 18,
    InfluenceBase = 6,
    InfluenceRank = 1,
    --
    TaxEffect = {
        [1] = {Honor = 4, Reputation =  1,},
        [2] = {Honor = 2, Reputation = -2,},
        [3] = {Honor = 1, Reputation = -4,},
        [4] = {Honor = 0, Reputation = -6,},
        [5] = {Honor = 0, Reputation = -8,},
    },
    TaxPerWorker = 5,
    ScaleBonusFactor = 1.15,
    DebentureBonus = 1,
    CoinageBonus = 1,

    Rations = {
        [2] = {Honor = 0, Reputation = nil, Stamina = 0.50},
        [3] = {Honor = 1, Reputation = nil, Stamina = 0.25},
        [4] = {Honor = 2, Reputation = nil, Stamina = 0.10},
        -- deprecated
        [0] = {Honor = 0, Reputation = nil, Stamina = 0.50},
        [1] = {Honor = 0, Reputation = nil, Stamina = 0.50},
    },
    SleepTime = {
        [2] = {Honor = nil, Reputation = 0, Stamina = 0.50},
        [3] = {Honor = nil, Reputation = 1, Stamina = 0.25},
        [4] = {Honor = nil, Reputation = 2, Stamina = 0.10},
        -- deprecated
        [0] = {Honor = nil, Reputation = 0, Stamina = 0.50},
        [1] = {Honor = nil, Reputation = 0, Stamina = 0.50},
    },
    Beverage = {
        [0] = {Honor = nil, Reputation = 1, Stamina = 0.50},
        [1] = {Honor = nil, Reputation = 2, Stamina = 0.40},
        [2] = {Honor = nil, Reputation = 3, Stamina = 0.30},
        [3] = {Honor = nil, Reputation = 4, Stamina = 0.20},
        [4] = {Honor = nil, Reputation = 5, Stamina = 0.10},
    },
    Festival = {
        [0] = {Honor =  0, Reputation = nil, BaseCost =   0,},
        [1] = {Honor =  5, Reputation = nil, BaseCost =  25,},
        [2] = {Honor = 10, Reputation = nil, BaseCost =  50,},
        [3] = {Honor = 20, Reputation = nil, BaseCost = 100,},
        [4] = {Honor = 30, Reputation = nil, BaseCost = 150,},
        [5] = {Honor = 40, Reputation = nil, BaseCost = 200,},
        [6] = {Honor = 50, Reputation = nil, BaseCost = 250,},
    },
    Sermon = {
        [0] = {Honor = nil, Reputation = 0, CostFactor =    0,},
        [1] = {Honor = nil, Reputation = 1, CostFactor = 1.00,},
        [2] = {Honor = nil, Reputation = 2, CostFactor = 1.50,},
        [3] = {Honor = nil, Reputation = 3, CostFactor = 2.00,},
        [4] = {Honor = nil, Reputation = 4, CostFactor = 2.50,},
        [5] = {Honor = nil, Reputation = 5, CostFactor = 3.00,},
        [6] = {Honor = nil, Reputation = 6, CostFactor = 3.50,},
    },

    TechnologyEffect = {
        [Technologies.T_CropCycle]   = {
            [Entities.PB_Farm1]      = {Honor = 1, Reputation = 0,},
            [Entities.PB_Farm2]      = {Honor = 1, Reputation = 0,},
            [Entities.PB_Farm3]      = {Honor = 1, Reputation = 0,},
        },
        [Technologies.T_Spice]       = {
            [Entities.PB_Farm1]      = {Honor = 1, Reputation = 0,},
            [Entities.PB_Farm2]      = {Honor = 1, Reputation = 0,},
            [Entities.PB_Farm3]      = {Honor = 1, Reputation = 0,},
        },
        [Technologies.T_Hearthfire]  = {
            [Entities.PB_Residence1] = {Honor = 0, Reputation = 1,},
            [Entities.PB_Residence2] = {Honor = 0, Reputation = 1,},
            [Entities.PB_Residence3] = {Honor = 0, Reputation = 1,},
        },
        [Technologies.T_RoomKeys]    = {
            [Entities.PB_Residence1] = {Honor = 0, Reputation = 1,},
            [Entities.PB_Residence2] = {Honor = 0, Reputation = 1,},
            [Entities.PB_Residence3] = {Honor = 0, Reputation = 1,},
        },
        [Technologies.T_Instruments] = {
            [Entities.PB_Tavern1]    = {Honor = 0, Reputation = 0,},
            [Entities.PB_Tavern2]    = {Honor = 0, Reputation = 0,},
        },
    },

    Dynamic = {
        [Entities.PB_Farm1]      = {Honor = 1.0, Reputation = 0,},
        [Entities.PB_Farm2]      = {Honor = 1.5, Reputation = 0,},
        [Entities.PB_Farm3]      = {Honor = 2.0, Reputation = 0,},
        --
        [Entities.PB_Residence1] = {Honor = 0, Reputation = 1.0,},
        [Entities.PB_Residence2] = {Honor = 0, Reputation = 1.5,},
        [Entities.PB_Residence3] = {Honor = 0, Reputation = 2.0,},
        --
        [Entities.PB_Tavern1]    = {Honor = 1.0, Reputation = 1.0,},
        [Entities.PB_Tavern2]    = {Honor = 2.0, Reputation = 2.0,},
    },
    Static = {
        [Entities.PB_Beautification04]  = {Honor = 1, Reputation = 0,},
        [Entities.PB_Beautification06]  = {Honor = 1, Reputation = 0,},
        [Entities.PB_Beautification09]  = {Honor = 1, Reputation = 0,},
        --
        [Entities.PB_Beautification01]  = {Honor = 1, Reputation = 0,},
        [Entities.PB_Beautification02]  = {Honor = 1, Reputation = 0,},
        [Entities.PB_Beautification12]  = {Honor = 1, Reputation = 0,},
        --
        [Entities.PB_Beautification05]  = {Honor = 1, Reputation = 0,},
        [Entities.PB_Beautification07]  = {Honor = 1, Reputation = 0,},
        [Entities.PB_Beautification08]  = {Honor = 1, Reputation = 0,},
        --
        [Entities.PB_Beautification03]  = {Honor = 1, Reputation = 0,},
        [Entities.PB_Beautification10]  = {Honor = 1, Reputation = 0,},
        [Entities.PB_Beautification11]  = {Honor = 1, Reputation = 0,},
        --
        [Entities.PB_Monastery1]        = {Honor = 0, Reputation = 0,},
        [Entities.PB_Monastery2]        = {Honor = 0, Reputation = 0,},
        [Entities.PB_Monastery3]        = {Honor = 0, Reputation = 0,},
        --
        [Entities.PB_ExecutionerPlace1] = {Honor = 0, Reputation = 2,},
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
        Entities.CU_Assassin_LeaderKnife1,
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

