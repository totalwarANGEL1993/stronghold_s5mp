--- 
--- Config for Rights
--- 

Stronghold.Rights.Config = {
    Gender = {
        [Entities.PU_Hero1]              = Gender.Male,
        [Entities.PU_Hero1a]             = Gender.Male,
        [Entities.PU_Hero1b]             = Gender.Male,
        [Entities.PU_Hero1c]             = Gender.Male,
        [Entities.PU_Hero2]              = Gender.Male,
        [Entities.PU_Hero3]              = Gender.Male,
        [Entities.PU_Hero4]              = Gender.Male,
        [Entities.PU_Hero5]              = Gender.Female,
        [Entities.PU_Hero6]              = Gender.Male,
        [Entities.CU_BlackKnight]        = Gender.Male,
        [Entities.CU_Mary_de_Mortfichet] = Gender.Female,
        [Entities.CU_Barbarian_Hero]     = Gender.Male,
        [Entities.PU_Hero10]             = Gender.Male,
        [Entities.PU_Hero11]             = Gender.Female,
        [Entities.CU_Evil_Queen]         = Gender.Female,
    },

    Titles = {
        [PlayerRank.Noble]    = {
            Costs  = {0, 0, 0, 0, 0, 0, 0},
            Duties = {},
            Rights = {
                PlayerRight.MeasureLevyTax,
                PlayerRight.LeaderPoleArm1,
                PlayerRight.Serf,
                PlayerRight.Scout,

                PlayerRight.BlackKnight3,
            },
        },
        [PlayerRank.Mayor]    = {
            Costs  = {10, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Cathedral, 0},
            },
            Rights = {
                PlayerRight.MeasureLawAndOrder,
                PlayerRight.LeaderBow1,

                PlayerRight.LeaderSword1,
                PlayerRight.BanditBow1,
                PlayerRight.BanditSword2,
                PlayerRight.Barbarian2,
                PlayerRight.BlackKnight2,
                PlayerRight.LeaderPoleArm2,
            },
        },
        [PlayerRank.Earl]     = {
            Costs  = {25, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Technology, Technologies.GT_Trading},
                {PlayerDuty.Headquarters, 1},
            },
            Rights = {
                PlayerRight.MeasureWelcomeCulture,
                PlayerRight.LeaderPoleArm3,
                PlayerRight.LeaderSword2,
                PlayerRight.Cannon1,
                PlayerRight.Cannon2,
                PlayerRight.Thief,

                PlayerRight.LeaderBow2,
                PlayerRight.LeaderPoleArm4,
            },
        },
        [PlayerRank.Baron]    = {
            Costs  = {50, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Settlers, 2, 50},
                {PlayerDuty.Buildings, 2, 8},
            },
            Rights = {
                PlayerRight.MeasureFolkloreFeast,
                PlayerRight.LeaderBow3,
                PlayerRight.LeaderBow4,

                PlayerRight.Bearman1,
                PlayerRight.Skirmisher,
            },
        },
        [PlayerRank.Count]    = {
            Costs  = {100, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Beautification, 1, 12},
                {PlayerDuty.Cathedral, 1},
            },
            Rights = {
                PlayerRight.LeaderRifle1,
                PlayerRight.LeaderCavalry1,
                PlayerRight.LeaderSword3,

                PlayerRight.LeaderCavalry2,
                PlayerRight.LeaderSword4,
                PlayerRight.BanditSword1,
                PlayerRight.Barbarian1,
                PlayerRight.BlackKnight1,
            },
        },
        [PlayerRank.Margrave] = {
            Costs  = {200, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Settlers, 2, 75},
                {PlayerDuty.Cathedral, 2},
            },
            Rights = {
                PlayerRight.MeasureOrgy,
                PlayerRight.LeaderHeavyCavalry1,

                PlayerRight.LeaderHeavyCavalry2,
            },
        },
        [PlayerRank.Duke]     = {
            Costs  = {300, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Settlers, 2, 100},
                {PlayerDuty.Beautification, 2},
                {PlayerDuty.Headquarters, 2},
            },
            Rights = {
                PlayerRight.LeaderRifle2,
                PlayerRight.Cannon3,
                PlayerRight.Cannon4,
            },
        },
    }
}