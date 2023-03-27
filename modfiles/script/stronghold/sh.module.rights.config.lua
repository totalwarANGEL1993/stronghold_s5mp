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
                PlayerRight.VillageCenter,
                -- DO NOT MOVE THIS!!! --

                PlayerRight.Keep,
                PlayerRight.Fortress,
                PlayerRight.Zitadel,
                PlayerRight.MeasureLevyTax,
                PlayerRight.Serf,
                ---
                PlayerRight.WatchTower,
                PlayerRight.Barracks,
                PlayerRight.LeaderPoleArm1,
                PlayerRight.BlackKnight3,
                ---
                PlayerRight.University,
                PlayerRight.Chapel,
                PlayerRight.Church,
                PlayerRight.Cathedral,
                ---
                PlayerRight.Brickmaker,
                PlayerRight.Sawmill,
                PlayerRight.MasonHut,
                PlayerRight.ArchitectShop,
                PlayerRight.Bridge,
                PlayerRight.WeatherTower,
                PlayerRight.Store,
                PlayerRight.ClayGallery,
                PlayerRight.IronGallery,
                PlayerRight.StoneGallery,
                PlayerRight.SulfurGallery,
                PlayerRight.ClayMine,
                PlayerRight.IronMine,
                PlayerRight.StoneMine,
                PlayerRight.SulfurMine,
            },
        },
        [PlayerRank.Mayor]    = {
            Costs  = {10, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Cathedral, 0},
                {PlayerDuty.Settlers, 1, Entities.PU_Serf, 12},
            },
            Rights = {
                PlayerRight.MeasureLawAndOrder,
                PlayerRight.Cottage,
                PlayerRight.Mill,
                PlayerRight.Alchemist,
                PlayerRight.Smithy,
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
                ---
                PlayerRight.Tavern,
                PlayerRight.Scout,
            },
        },
        [PlayerRank.Earl]     = {
            Costs  = {25, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Headquarters, 1},
                {PlayerDuty.Technology, Technologies.GT_Trading},
            },
            Rights = {
                PlayerRight.MeasureWelcomeCulture,
                ---
                PlayerRight.Manor,
                PlayerRight.Estate,
                PlayerRight.Market,
                PlayerRight.Blacksmith,
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
            },
        },
        [PlayerRank.Baron]    = {
            Costs  = {50, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Cathedral, 1},
                {PlayerDuty.Settlers, 1, Entities.PU_Smith, 6},
                {PlayerDuty.Soldiers, 50},
            },
            Rights = {
                PlayerRight.MeasureFolkloreFeast,
                ---
                PlayerRight.Laboratory,
                PlayerRight.FinishingSmithy,
                PlayerRight.Brickworks,
                PlayerRight.LumberMill,
                PlayerRight.MasonWorkshop,
                PlayerRight.TownCenter,
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
                {PlayerDuty.Buildings, 8},
                {PlayerDuty.Beautification, 1, 12},
            },
            Rights = {
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
                PlayerRight.Bank,
                PlayerRight.PowerPlant,
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
                ---
                PlayerRight.Stables,
                PlayerRight.LeaderHeavyCavalry1,
                PlayerRight.LeaderHeavyCavalry2,
                ---
                PlayerRight.CannonTower,
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

