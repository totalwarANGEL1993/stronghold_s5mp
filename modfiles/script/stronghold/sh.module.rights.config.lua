--- 
--- Config for Rights
--- 

Stronghold.Rights.Config = {
    RankToTechnology = {
        [PlayerRank.Commoner]   = Technologies.R_Commoner,
        [PlayerRank.Noble]      = Technologies.R_Noble,
        [PlayerRank.Mayor]      = Technologies.R_Steward,
        [PlayerRank.Earl]       = Technologies.R_Bailiff,
        [PlayerRank.Baron]      = Technologies.R_Baron,
        [PlayerRank.Count]      = Technologies.R_Count,
        [PlayerRank.Margrave]   = Technologies.R_Margrave,
        [PlayerRank.Duke]       = Technologies.R_Duke,
    },

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
        [Entities.CU_Hero13]             = Gender.Male,
        [Entities.CU_Hero14]             = Gender.Female,
    },

    Titles = {
        [PlayerRank.Commoner] = {
            Costs  = {0, 0, 0, 0, 0, 0, 0},
            Duties = {},
            Rights = {
                -- DO NOT MOVE THIS!!! --
                PlayerRight.House,
                PlayerRight.Farm,
                PlayerRight.GenericPit,
                PlayerRight.Highschool,
                PlayerRight.VillageCenter,
                -- DO NOT MOVE THIS!!! --

                PlayerRight.Keep,
                PlayerRight.Outpost,
                PlayerRight.Serf,
                ---
                PlayerRight.Beautification4,
                PlayerRight.Beautification6,
                PlayerRight.Beautification9,
                ---
                PlayerRight.Barracks,
                PlayerRight.SpearMilitia,
                PlayerRight.BanditSword,
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
                PlayerRight.SpearLancer,
                PlayerRight.MercenaryCamp,
                PlayerRight.DogCage,
                ---
                PlayerRight.Palisade,
            },
        },
        [PlayerRank.Mayor]    = {
            Costs  = {10, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Cathedral, 0},
            },
            Rights = {
                PlayerRight.Fortress,
                PlayerRight.Fort,
                PlayerRight.Cottage,
                PlayerRight.Mill,
                PlayerRight.Brickmaker,
                PlayerRight.Sawmill,
                PlayerRight.Store,
                PlayerRight.WatchTower,
                ---
                PlayerRight.SwordMilitia,
                PlayerRight.BerserkWeak,
                ---
                PlayerRight.ShootingRange,
                PlayerRight.ArcherMilitia,
            },
        },
        [PlayerRank.Earl]     = {
            Costs  = {25, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Headquarters, 1},
                {PlayerDuty.Workplaces, 6},
            },
            Rights = {
                PlayerRight.TownCenter,
                PlayerRight.Church,
                PlayerRight.Smithy,
                PlayerRight.MasonHut,
                PlayerRight.Tavern,
                PlayerRight.Scout,
                PlayerRight.Traphole,
                ---
                PlayerRight.Garnison,
                PlayerRight.SpearLandsknecht,
                PlayerRight.SwordSquire,
                PlayerRight.BarbarianWeak,
                PlayerRight.BlackKnightWeak,
                ---
                PlayerRight.ArcherLongbow,
                PlayerRight.BanditBow,
                ---
                PlayerRight.Barn,
                PlayerRight.CavalryBow,
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
                {PlayerDuty.Soldiers, 20},
            },
            Rights = {
                PlayerRight.Blacksmith,
                PlayerRight.Alchemist,
                PlayerRight.GenericGallery,
                PlayerRight.Market,
                PlayerRight.Bank,
                ---
                PlayerRight.BallistaTower,
                PlayerRight.FalconryTower,
                ---
                PlayerRight.Bearman,
                PlayerRight.SpearHalberdier,
                PlayerRight.SpearTemplar,
                ---
                PlayerRight.Archery,
                PlayerRight.ArcherCrossbow,
                PlayerRight.Skirmisher,
                PlayerRight.GunWorkshop,
                PlayerRight.RifleHandgunner,
                ---
                PlayerRight.BombardCannon,
                PlayerRight.BigBombardCannon,
            },
        },
        [PlayerRank.Count]    = {
            Costs  = {100, 0, 0, 0, 0, 0, 0},
            Duties = {
                {PlayerDuty.Workplaces, 12},
                {PlayerDuty.Beautification, 1, 6},
            },
            Rights = {
                PlayerRight.University,
                PlayerRight.ExecutionerPlace,
                PlayerRight.CityCenter,
                PlayerRight.Cathedral,
                PlayerRight.Brickworks,
                PlayerRight.LumberMill,
                PlayerRight.MasonWorkshop,
                PlayerRight.WeatherTower,
                PlayerRight.Manor,
                PlayerRight.Estate,
                ---
                PlayerRight.Wall,
                PlayerRight.BearCage,
                ---
                PlayerRight.SwordLong,
                PlayerRight.BerserkStrong,
                PlayerRight.BarbarianStrong,
                PlayerRight.BlackKnightStrong,
                PlayerRight.Assassin,
                ---
                PlayerRight.CavalryCrossbow,
                PlayerRight.CavalryCrusader,
                PlayerRight.CavalryBandit,
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
                {PlayerDuty.Settlers, 2, 50},
                {PlayerDuty.Cathedral, 2},
            },
            Rights = {
                PlayerRight.Zitadel,
                PlayerRight.Bastille,
                ---
                PlayerRight.Laboratory,
                PlayerRight.FinishingSmithy,
                PlayerRight.GenericMine,
                ---
                PlayerRight.SwordGuardist,
                ---
                PlayerRight.ArcherPavease,
                ---
                PlayerRight.Stables,
                PlayerRight.CavalrySword,
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
                {PlayerDuty.Settlers, 2, 75},
                {PlayerDuty.Beautification, 2},
            },
            Rights = {
                PlayerRight.Treasury,
                PlayerRight.PowerPlant,
                PlayerRight.CannonTower,
                PlayerRight.PitchPit,
                ---
                PlayerRight.GunFactory,
                PlayerRight.RifleMusketman,
                PlayerRight.CavalryAxe,
                PlayerRight.CavalryTemplar,
                ---
                PlayerRight.IronCannon,
                PlayerRight.DschihadCannon,
                PlayerRight.AtilleryCannon,
                PlayerRight.GatlingCannon,
            },
        },
    }
}

