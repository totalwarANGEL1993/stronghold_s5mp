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
                PlayerRight.FoodDistribution,
                PlayerRight.MeasureFolkloreFeast,
                PlayerRight.MeasureOrgy,
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
                PlayerRight.Serf,
                ---
                PlayerRight.Beautification4,
                PlayerRight.Beautification6,
                PlayerRight.Beautification9,
                ---
                PlayerRight.BlackKnightGuard,
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
                PlayerRight.ArchitectShop,
                PlayerRight.Bridge,
                ---
                PlayerRight.Palisade,
                ---
                PlayerRight.Barracks,
                PlayerRight.SpearMilitia,
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
                PlayerRight.SwordMilitia,
                PlayerRight.BanditSwordWeak,
                PlayerRight.SpearLancer,
                ---
                PlayerRight.ShootingRange,
                PlayerRight.ArcherMilitia,
                PlayerRight.BanditBow,
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
                PlayerRight.Tavern,
                PlayerRight.Scout,
                ---
                PlayerRight.Garnison,
                PlayerRight.SpearLandsknecht,
                PlayerRight.SpearHalberdier,
                PlayerRight.SwordSquire,
                PlayerRight.BarbarianWeak,
                PlayerRight.BlackKnightWeak,
                ---
                PlayerRight.ArcherLongbow,
                ---
                PlayerRight.Barn,
                PlayerRight.CavalryHobilar,
                PlayerRight.CavalryCrusader,
                ---
                PlayerRight.Foundry,
                PlayerRight.BronzeCannon,
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
                PlayerRight.ClayGallery,
                PlayerRight.IronGallery,
                PlayerRight.StoneGallery,
                PlayerRight.SulfurGallery,
                PlayerRight.Market,
                PlayerRight.Bank,
                ---
                PlayerRight.BallistaTower,
                ---
                PlayerRight.Bearman,
                PlayerRight.Skirmisher,
                ---
                PlayerRight.Archery,
                PlayerRight.ArcherCrossbow,
                PlayerRight.GunWorkshop,
                PlayerRight.RifleHandgunner,
                ---
                PlayerRight.BombardCannon,
            },
        },
        [PlayerRank.Count]    = {
            Costs  = {100, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Buildings, 12},
                {PlayerDuty.Beautification, 1, 12},
            },
            Rights = {
                PlayerRight.University,
                PlayerRight.TownCenter,
                PlayerRight.Cathedral,
                PlayerRight.Brickworks,
                PlayerRight.LumberMill,
                PlayerRight.MasonWorkshop,
                PlayerRight.WeatherTower,
                PlayerRight.Manor,
                PlayerRight.Estate,
                ---
                PlayerRight.Wall,
                ---
                PlayerRight.SwordLong,
                PlayerRight.SwordGuardist,
                PlayerRight.BanditSwordStrong,
                PlayerRight.BarbarianStrong,
                PlayerRight.BlackKnightStrong,
                ---
                PlayerRight.Thief,
                PlayerRight.Inn,
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
                ---
                PlayerRight.Laboratory,
                PlayerRight.FinishingSmithy,
                PlayerRight.ClayMine,
                PlayerRight.IronMine,
                PlayerRight.StoneMine,
                PlayerRight.SulfurMine,
                ---
                PlayerRight.ArcherPavease,
                ---
                PlayerRight.Stables,
                PlayerRight.CavalryKnight,
                PlayerRight.CavalryTemplar,
                ---
                PlayerRight.CannonFactory,
                PlayerRight.SiegeCannon,
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
                PlayerRight.PowerPlant,
                PlayerRight.CannonTower,
                ---
                PlayerRight.GunFactory,
                PlayerRight.RifleMusketman,
                ---
                PlayerRight.IronCannon,
            },
        },
    }
}

