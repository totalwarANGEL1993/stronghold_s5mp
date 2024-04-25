--- 
--- Configuration for the mercenaries
--- 

Stronghold.Mercenary.Config = {
    CostFactor = 1.5,
    QuantityFactor = 0.35,

    Units = {
        [Entities.PU_LeaderPoleArm1]            = {
            Button     = "Buy_LeaderSpear",
            RefillTime = 60,
            MaxAmount  = 6,
        },
        [Entities.PU_LeaderPoleArm2]            = {
            Button     = "Buy_LeaderSpear",
            RefillTime = 60,
            MaxAmount  = 5,
        },
        [Entities.PU_LeaderPoleArm3]            = {
            Button     = "Buy_LeaderSpear",
            RefillTime = 150,
            MaxAmount  = 2,
        },
        [Entities.PU_LeaderPoleArm4]            = {
            Button     = "Buy_LeaderSpear",
            RefillTime = 180,
            MaxAmount  = 2,
        },
        [Entities.PU_LeaderSword1]              = {
            Button     = "Buy_LeaderSword",
            RefillTime = 60,
            MaxAmount  = 6,
        },
        [Entities.PU_LeaderSword2]              = {
            Button     = "Buy_LeaderSword",
            RefillTime = 60,
            MaxAmount  = 5,
        },
        [Entities.PU_LeaderSword3]              = {
            Button     = "Buy_LeaderSword",
            RefillTime = 150,
            MaxAmount  = 2,
        },
        [Entities.PU_LeaderSword4]              = {
            Button     = "Buy_LeaderSword",
            RefillTime = 180,
            MaxAmount  = 2,
        },
        [Entities.PU_LeaderBow1]                = {
            Button     = "Buy_LeaderBow",
            RefillTime = 60,
            MaxAmount  = 6,
        },
        [Entities.PU_LeaderBow2]                = {
            Button     = "Buy_LeaderBow",
            RefillTime = 60,
            MaxAmount  = 5,
        },
        [Entities.PU_LeaderBow3]                = {
            Button     = "Buy_LeaderBow",
            RefillTime = 150,
            MaxAmount  = 2,
        },
        [Entities.PU_LeaderBow4]                = {
            Button     = "Buy_LeaderBow",
            RefillTime = 180,
            MaxAmount  = 2,
        },
        [Entities.PU_LeaderRifle1]              = {
            Button     = "Buy_LeaderRifle",
            RefillTime = 180,
            MaxAmount  = 4,
        },
        [Entities.PU_LeaderRifle2]              = {
            Button     = "Buy_LeaderRifle",
            RefillTime = 210,
            MaxAmount  = 2,
        },
        [Entities.PU_LeaderCavalry1]            = {
            Button     = "Buy_LeaderCavalryLight",
            RefillTime = 180,
            MaxAmount  = 4,
        },
        [Entities.PU_LeaderCavalry2]            = {
            Button     = "Buy_LeaderCavalryLight",
            RefillTime = 180,
            MaxAmount  = 3,
        },
        [Entities.PU_LeaderHeavyCavalry1]       = {
            Button     = "Buy_LeaderCavalryHeavy",
            RefillTime = 210,
            MaxAmount  = 4,
        },
        [Entities.PU_LeaderHeavyCavalry2]       = {
            Button     = "Buy_LeaderCavalryHeavy",
            RefillTime = 210,
            MaxAmount  = 3,
        },
        [Entities.CV_Cannon1]                   = {
            Button     = "Buy_Cannon3",
            RefillTime = 180,
            MaxAmount  = 1,
        },
        [Entities.CV_Cannon2]                   = {
            Button     = "Buy_Cannon3",
            RefillTime = 180,
            MaxAmount  = 1,
        },
        [Entities.PV_Cannon1]                   = {
            Button     = "Buy_Cannon1",
            RefillTime = 120,
            MaxAmount  = 3,
        },
        [Entities.PV_Cannon2]                   = {
            Button     = "Buy_Cannon2",
            RefillTime = 120,
            MaxAmount  = 3,
        },
        [Entities.PV_Cannon3]                   = {
            Button     = "Buy_Cannon3",
            RefillTime = 180,
            MaxAmount  = 1,
        },
        [Entities.PV_Cannon4]                   = {
            Button     = "Buy_Cannon4",
            RefillTime = 180,
            MaxAmount  = 1,
        },
        [Entities.PV_Cannon7]                   = {
            Button     = "Buy_Cannon1",
            RefillTime = 120,
            MaxAmount  = 3,
        },
        [Entities.PV_Cannon8]                   = {
            Button     = "Buy_Cannon3",
            RefillTime = 180,
            MaxAmount  = 1,
        },
        [Entities.PU_Scout]                     = {
            Button     = "Buy_Scout",
            RefillTime = 30,
            MaxAmount  = 6,
        },
        [Entities.PU_Thief]                     = {
            Button     = "Buy_Thief",
            RefillTime = 30,
            MaxAmount  = 6,
        },
        [Entities.CU_Assassin_LeaderKnife1]      = {
            Button     = "Buy_Thief",
            RefillTime = 30,
            MaxAmount  = 2,
        },
        [Entities.PU_Serf]                      = {
            Button     = "Buy_Serf",
            RefillTime = 30,
            MaxAmount  = 18,
        },
        [Entities.CU_BanditLeaderSword2]        = {
            Button     = "Buy_LeaderSword",
            RefillTime = 90,
            MaxAmount  = 4,
        },
        [Entities.CU_BanditLeaderSword1]        = {
            Button     = "Buy_LeaderSword",
            RefillTime = 180,
            MaxAmount  = 2,
        },
        [Entities.CU_BanditLeaderSword3]        = {
            Button     = "Buy_LeaderSword",
            RefillTime = 60,
            MaxAmount  = 6,
        },
        [Entities.CU_BanditLeaderBow1]          = {
            Button     = "Buy_LeaderBow",
            RefillTime = 90,
            MaxAmount  = 4,
        },
        [Entities.CU_BanditLeaderCavalry1]      = {
            Button     = "Buy_LeaderCavalryLight",
            RefillTime = 150,
            MaxAmount  = 2,
        },
        [Entities.CU_Barbarian_LeaderClub2]     = {
            Button     = "Buy_LeaderSword",
            RefillTime = 90,
            MaxAmount  = 4,
        },
        [Entities.CU_Barbarian_LeaderClub1]     = {
            Button     = "Buy_LeaderSword",
            RefillTime = 150,
            MaxAmount  = 2,
        },
        [Entities.CU_BlackKnight_LeaderMace2]   = {
            Button     = "Buy_LeaderSword",
            RefillTime = 90,
            MaxAmount  = 4,
        },
        [Entities.CU_BlackKnight_LeaderMace1]   = {
            Button     = "Buy_LeaderSword",
            RefillTime = 150,
            MaxAmount  = 2,
        },
        [Entities.CU_Evil_LeaderBearman1]       = {
            Button     = "Buy_LeaderSword",
            RefillTime = 180,
            MaxAmount  = 5,
        },
        [Entities.CU_Evil_LeaderSkirmisher1]    = {
            Button     = "Buy_LeaderBow",
            RefillTime = 180,
            MaxAmount  = 5,
        },
        [Entities.CU_TemplarLeaderPoleArm1]    = {
            Button     = "Buy_LeaderSpear",
            RefillTime = 180,
            MaxAmount  = 3,
        },
        [Entities.CU_TemplarLeaderCavalry1]    = {
            Button     = "Buy_LeaderCavalryLight",
            RefillTime = 180,
            MaxAmount  = 3,
        },
        [Entities.CU_TemplarLeaderHeavyCavalry1]    = {
            Button     = "Buy_LeaderCavalryHeavy",
            RefillTime = 210,
            MaxAmount  = 3,
        },
    },
}

function Stronghold.Mercenary.Config:Get(_Type)
    return self.Units[_Type];
end

