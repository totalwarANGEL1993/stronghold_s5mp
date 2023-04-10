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
        [PlayerRank.Commoner] = {
            Costs  = {0, 0, 0, 0, 0, 0, 0},
            Duties = {},
            Rights = {
                -- DO NOT MOVE THIS!!! --
                PlayerRight.MeasureLevyTax,
                PlayerRight.MeasureLawAndOrder,
                PlayerRight.MeasureWelcomeCulture,
                PlayerRight.MeasureFolkloreFeast,
                PlayerRight.MeasureOrgy,
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
                PlayerRight.Serf,
                ---
                PlayerRight.Beautification4,
                PlayerRight.Beautification6,
                PlayerRight.Beautification9,
                ---
                PlayerRight.BlackKnight3,
            }
        },
        [PlayerRank.Noble]    = {
            Costs  = {5, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Noble},
                {PlayerDuty.Headquarters, 0},
            },
            Rights = {
                ---
                PlayerRight.Chapel,
                ---
                PlayerRight.Barracks,
                PlayerRight.LeaderPoleArm1,
            },
        },
        [PlayerRank.Mayor]    = {
            Costs  = {10, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Cathedral, 0},
            },
            Rights = {
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
                {PlayerDuty.Buildings, 6},
            },
            Rights = {
                PlayerRight.Church,
                PlayerRight.Smithy,
                PlayerRight.MasonHut,
                PlayerRight.Bank,
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
                PlayerRight.Blacksmith,
                PlayerRight.Alchemist,
                PlayerRight.WeatherTower,
                PlayerRight.Manor,
                PlayerRight.Estate,
                PlayerRight.PowerPlant,
                PlayerRight.ClayGallery,
                PlayerRight.IronGallery,
                PlayerRight.StoneGallery,
                PlayerRight.SulfurGallery,
                ---
                PlayerRight.BallistaTower,
                ---
                PlayerRight.Bearman,
                ---
                PlayerRight.Archery,
                PlayerRight.LeaderBow3,
                PlayerRight.LeaderBow4,
                PlayerRight.Skirmisher,
                ---
                PlayerRight.Cannon1,
            },
        },
        [PlayerRank.Count]    = {
            Costs  = {100, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Buildings, 12},
                {PlayerDuty.Beautification, 1, 12},
            },
            Rights = {
                PlayerRight.TownCenter,
                PlayerRight.Cathedral,
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
                PlayerRight.Market,
                ---
                PlayerRight.Laboratory,
                PlayerRight.FinishingSmithy,
                ---
                PlayerRight.Stables,
                PlayerRight.LeaderHeavyCavalry1,
                PlayerRight.LeaderHeavyCavalry2,
                ---
                PlayerRight.CannonFactory,
                PlayerRight.Cannon4,
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
                PlayerRight.Cannon3,
            },
        },
    }
}

