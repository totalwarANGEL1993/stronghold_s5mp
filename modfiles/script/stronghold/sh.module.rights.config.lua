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
                -- DO NOT MOVE THIS!!! --
                PlayerRight.House,
                PlayerRight.Farm,
                PlayerRight.ClayPit,
                PlayerRight.IronPit,
                PlayerRight.StonePit,
                PlayerRight.SulfurPit,
                PlayerRight.Highschool,
                PlayerRight.University,
                PlayerRight.VillageCenter,
                -- DO NOT MOVE THIS!!! --

                PlayerRight.Keep,
                PlayerRight.MeasureLevyTax,
                PlayerRight.Serf,
                ---
                PlayerRight.Chapel,
                ---
                PlayerRight.Barracks,
                PlayerRight.LeaderPoleArm1,
                PlayerRight.BlackKnight3,
                ---
                PlayerRight.Beautification4,
                PlayerRight.Beautification6,
                PlayerRight.Beautification9,
            },
        },
        [PlayerRank.Mayor]    = {
            Costs  = {10, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Cathedral, 0},
                {PlayerDuty.Settlers, 1, Entities.PU_Serf, 18},
            },
            Rights = {
                PlayerRight.MeasureLawAndOrder,
                PlayerRight.Fortress,
                PlayerRight.Cottage,
                PlayerRight.Mill,
                PlayerRight.Brickmaker,
                PlayerRight.Sawmill,
                PlayerRight.Store,
                PlayerRight.WatchTower,
                ---
                PlayerRight.LeaderSword1,
                PlayerRight.BanditSword2,
                PlayerRight.Barbarian2,
                PlayerRight.BlackKnight2,
                PlayerRight.LeaderPoleArm2,
                ---
                PlayerRight.ShootingRange,
                PlayerRight.LeaderBow1,
                PlayerRight.BanditBow1,
            },
        },
        [PlayerRank.Earl]     = {
            Costs  = {25, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Headquarters, 1},
                -- {PlayerDuty.Technology, Technologies.GT_Trading},
                {PlayerDuty.Buildings, 6},
            },
            Rights = {
                PlayerRight.MeasureWelcomeCulture,
                ---
                PlayerRight.Church,
                PlayerRight.Manor,
                PlayerRight.Estate,
                PlayerRight.Market,
                PlayerRight.Smithy,
                PlayerRight.MasonHut,
                PlayerRight.ArchitectShop,
                PlayerRight.Bridge,
                PlayerRight.Tavern,
                PlayerRight.Scout,
                ---
                PlayerRight.Garnison,
                PlayerRight.LeaderPoleArm3,
                PlayerRight.LeaderPoleArm4,
                PlayerRight.LeaderSword2,
                ---
                PlayerRight.LeaderBow2,
                ---
                PlayerRight.Foundry,
                PlayerRight.Cannon1,
                PlayerRight.Cannon2,
                ---
                PlayerRight.Beautification1,
                PlayerRight.Beautification2,
                PlayerRight.Beautification12,
            },
        },
        [PlayerRank.Baron]    = {
            Costs  = {50, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Cathedral, 1},
                {PlayerDuty.Soldiers, 50},
            },
            Rights = {
                PlayerRight.MeasureFolkloreFeast,
                ---
                PlayerRight.TownCenter,
                PlayerRight.Blacksmith,
                PlayerRight.Alchemist,
                PlayerRight.WeatherTower,
                PlayerRight.ClayGallery,
                PlayerRight.IronGallery,
                PlayerRight.StoneGallery,
                PlayerRight.SulfurGallery,
                PlayerRight.PowerPlant,
                ---
                PlayerRight.BallistaTower,
                ---
                PlayerRight.Bearman,
                ---
                PlayerRight.Archery,
                PlayerRight.LeaderBow3,
                PlayerRight.LeaderBow4,
                PlayerRight.Skirmisher,
            },
        },
        [PlayerRank.Count]    = {
            Costs  = {100, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Buildings, 12},
                {PlayerDuty.Beautification, 1, 12},
            },
            Rights = {
                PlayerRight.Cathedral,
                PlayerRight.Bank,
                PlayerRight.Brickworks,
                PlayerRight.LumberMill,
                PlayerRight.MasonWorkshop,
                ---
                PlayerRight.LeaderSword3,
                PlayerRight.LeaderSword4,
                PlayerRight.BanditSword1,
                PlayerRight.Barbarian1,
                PlayerRight.BlackKnight1,
                ---
                PlayerRight.Barn,
                PlayerRight.LeaderCavalry1,
                PlayerRight.LeaderCavalry2,
                ---
                PlayerRight.Thief,
                PlayerRight.Inn,
                ---
                PlayerRight.GunWorkshop,
                PlayerRight.LeaderRifle1,
                ---
                PlayerRight.Beautification5,
                PlayerRight.Beautification7,
                PlayerRight.Beautification8,
            },
        },
        [PlayerRank.Margrave] = {
            Costs  = {200, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Settlers, 2, 75},
                {PlayerDuty.Cathedral, 2},
            },
            Rights = {
                PlayerRight.Zitadel,
                PlayerRight.MeasureOrgy,
                ---
                PlayerRight.Laboratory,
                PlayerRight.FinishingSmithy,
                ---
                PlayerRight.Stables,
                PlayerRight.LeaderHeavyCavalry1,
                PlayerRight.LeaderHeavyCavalry2,
                ---
                PlayerRight.CannonTower,
                ---
                PlayerRight.Beautification3,
                PlayerRight.Beautification10,
                PlayerRight.Beautification11,
            },
        },
        [PlayerRank.Duke]     = {
            Costs  = {300, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Headquarters, 2},
                {PlayerDuty.Settlers, 2, 100},
                {PlayerDuty.Beautification, 2},
            },
            Rights = {
                PlayerRight.CityCenter,
                PlayerRight.Treasury,
                PlayerRight.ClayMine,
                PlayerRight.IronMine,
                PlayerRight.StoneMine,
                PlayerRight.SulfurMine,
                ---
                PlayerRight.GunFactory,
                PlayerRight.LeaderRifle2,
                ---
                PlayerRight.CannonFactory,
                PlayerRight.Cannon3,
                PlayerRight.Cannon4,
            },
        },
    }
}

