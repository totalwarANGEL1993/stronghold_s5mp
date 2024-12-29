--- 
--- Configuration for the buildings
--- 

Stronghold.Building.Config.Civil = {
    TaxButtons = {
        [0] = "SetVeryLowTaxes",
        [1] = "SetLowTaxes",
        [2] = "SetNormalTaxes",
        [3] = "SetHighTaxes",
        [4] = "SetVeryHighTaxes",
    },
    RationButtons = {
        [0] = "FarmRationsLevel0",
        [1] = "FarmRationsLevel1",
        [2] = "FarmRationsLevel2",
        [3] = "FarmRationsLevel3",
        [4] = "FarmRationsLevel4",
    },
    SleepButtons = {
        [0] = "ResidenceSleepLevel0",
        [1] = "ResidenceSleepLevel1",
        [2] = "ResidenceSleepLevel2",
        [3] = "ResidenceSleepLevel3",
        [4] = "ResidenceSleepLevel4",
    },
    BeverageButtons = {
        [0] = "TavernBeverageLevel0",
        [1] = "TavernBeverageLevel1",
        [2] = "TavernBeverageLevel2",
        [3] = "TavernBeverageLevel3",
        [4] = "TavernBeverageLevel4",
    },
    FestivalButtons = {
        [0] = "KeepFestivalLevel0",
        [1] = "KeepFestivalLevel1",
        [2] = "KeepFestivalLevel2",
        [3] = "KeepFestivalLevel3",
        [4] = "KeepFestivalLevel4",
        [5] = "KeepFestivalLevel5",
        [6] = "KeepFestivalLevel6",
    },
    SermonButtons = {
        [0] = "CathedralServiceLevel0",
        [1] = "CathedralServiceLevel1",
        [2] = "CathedralServiceLevel2",
        [3] = "CathedralServiceLevel3",
        [4] = "CathedralServiceLevel4",
        [5] = "CathedralServiceLevel5",
        [6] = "CathedralServiceLevel6",
    },
}

Stronghold.Building.Config.WeatherChange = {
    TimeBetweenChanges = 5 * 60,
    Technologies = {
        [Technologies.T_MakeSummer] = true,
        [Technologies.T_MakeRain] = true,
        [Technologies.T_MakeSnow] = true,
    },
}

Stronghold.Building.Config.Turrets = {
    [Entities.PB_Headquarters1] = {
        {Entities.CB_Turret1, 200, 0},
        {Entities.CB_Turret1, 300, 230},
        {Entities.CB_Turret1, 300, 135},
    },
    [Entities.PB_Headquarters2] = {
        {Entities.CB_Turret2, 200, 0},
        {Entities.CB_Turret2, 300, 230},
        {Entities.CB_Turret2, 300, 135},
    },
    [Entities.PB_Headquarters3] = {
        {Entities.CB_Turret3, 200, 0},
        {Entities.CB_Turret3, 300, 230},
        {Entities.CB_Turret3, 300, 135},
    },
    [Entities.PB_Outpost1] = {
        {Entities.CB_Turret1, 0, 0},
    },
    [Entities.PB_Outpost2] = {
        {Entities.CB_Turret1, 300, 225},
        {Entities.CB_Turret1, 300, 45},
    },
    [Entities.PB_Outpost3] = {
        {Entities.CB_Turret1, 200, 0},
        {Entities.CB_Turret1, 300, 230},
        {Entities.CB_Turret1, 300, 135},
    },
}

-- Dictionary of building types for fortress upgrade
Stronghold.Building.Config.CastleBuildingUpgradeRequirements = {
    [Entities.PB_Alchemist1]                = true,
    [Entities.PB_Alchemist2]                = true,
    [Entities.PB_Bank1]                     = true,
    [Entities.PB_Bank2]                     = true,
    [Entities.PB_Blacksmith1]               = true,
    [Entities.PB_Blacksmith2]               = true,
    [Entities.PB_Blacksmith3]               = true,
    [Entities.PB_Brickworks1]               = true,
    [Entities.PB_Brickworks2]               = true,
    [Entities.PB_GunsmithWorkshop1]         = true,
    [Entities.PB_GunsmithWorkshop2]         = true,
    [Entities.PB_StoneMason1]               = true,
    [Entities.PB_StoneMason2]               = true,
    [Entities.PB_Sawmill1]                  = true,
    [Entities.PB_Sawmill2]                  = true,
}

-- Dictionary of building creation bonuses
Stronghold.Building.Config.BuildingCreationBonus = {
    [Entities.PB_Beautification01] = {Honor = 0, Reputation = 2},
    [Entities.PB_Beautification02] = {Honor = 0, Reputation = 2},
    [Entities.PB_Beautification03] = {Honor = 0, Reputation = 2},
    [Entities.PB_Beautification04] = {Honor = 0, Reputation = 2},
    [Entities.PB_Beautification05] = {Honor = 0, Reputation = 2},
    [Entities.PB_Beautification06] = {Honor = 0, Reputation = 2},
    [Entities.PB_Beautification07] = {Honor = 0, Reputation = 2},
    [Entities.PB_Beautification08] = {Honor = 0, Reputation = 2},
    [Entities.PB_Beautification09] = {Honor = 0, Reputation = 2},
    [Entities.PB_Beautification10] = {Honor = 0, Reputation = 2},
    [Entities.PB_Beautification11] = {Honor = 0, Reputation = 2},
    [Entities.PB_Beautification12] = {Honor = 0, Reputation = 2},
    [Entities.PB_Headquarters1]    = {Honor = 0, Reputation = 0},
    [Entities.PB_Headquarters2]    = {Honor = 0, Reputation = 0},
    [Entities.PB_Headquarters3]    = {Honor = 0, Reputation = 0},
    [Entities.PB_Monastery1]       = {Honor = 0, Reputation = 8},
    [Entities.PB_Monastery2]       = {Honor = 0, Reputation = 12},
    [Entities.PB_Monastery3]       = {Honor = 0, Reputation = 16},
}

-- Dictionary of towers that might be on a construction site
Stronghold.Building.Config.TowerTypes = {
    [Entities.PB_DarkTower2] = true,
    [Entities.PB_DarkTower3] = true,
    [Entities.PB_Tower2] = true,
    [Entities.PB_Tower3] = true,
}

Stronghold.Building.Config.RecuitIndexRecuitShortcut = {
    [1]  = "A",
    [2]  = "S",
    [3]  = "D",
    [4]  = "F",
    [5]  = "G",
    [6]  = "H",
    [7]  = "J",
    [8]  = "K",
    [9]  = "L",
    [10] = "Y",
    [11] = "X",
    [12] = "C",
    [13] = "V",
    [14] = "B",
    [15] = "N",
    [16] = "M",
    [17] = "Q",
    [18] = "W",
    [19] = "E",
    [20] = "R",
    [21] = "T",
    [22] = "Z",
    [23] = "U",
    [24] = "I",
    [25] = "O",
    [26] = "P",
    [27] = "Ä", -- Might not work with english keyboards...
    [28] = "Ö", -- Might not work with english keyboards...
    [29] = "Ü", -- Might not work with english keyboards...
    [30] = ";", -- Might not work with english keyboards...
}

