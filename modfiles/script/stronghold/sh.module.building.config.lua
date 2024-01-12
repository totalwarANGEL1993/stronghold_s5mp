--- 
--- Configuration for the buildings
--- 

Stronghold.Building.Config.Headquarters = {
    DraconicPunishmentHonorBonus = 0.20,
    DraconicPunishmentReputationBonus = 0.20,
    DecorativeSkullHonorBonus = 0.20,
    DecorativeSkullReputationBonus = 0.20,
    TjostingArmorHonorBonus = 0.20,
    TjostingArmorReputationBonus = 0.20,

    [BlessCategories.Construction] = {
        Reputation = -15,
        Honor = 0,

        Text = "sh_menuheadquarter/blesssettlers1",
    },
    [BlessCategories.Research] = {
        Reputation = 5,
        Honor = 5,

        Text = "sh_menuheadquarter/blesssettlers2",
    },
    [BlessCategories.Weapons] = {
        Reputation = 0,
        Honor = 15,

        Text = "sh_menuheadquarter/blesssettlers3",
    },
    [BlessCategories.Financial] = {
        Reputation = 15,
        Honor = 0,

        Text = "sh_menuheadquarter/blesssettlers4",
    },
    [BlessCategories.Canonisation] = {
        Reputation = -45,
        Honor = 150,

        Text = "sh_menuheadquarter/blesssettlers5",
    },
}

Stronghold.Building.Config.Monastery = {
    SundayAssemblyHonorBonus = 2,
    SundayAssemblyReputationBonus = 2,
    HolyRelicsHonorBonus = 2,
    HolyRelicsReputationBonus = 2,
    PopalBlessingHonorBonus = 2,
    PopalBlessingReputationBonus = 2,

    [BlessCategories.Construction] = {
        Reputation = 8,
        Honor = 0,

        Text = "sh_menumonastery/blesssettlers1",
    },
    [BlessCategories.Research] = {
        Reputation = 0,
        Honor = 8,

        Text = "sh_menumonastery/blesssettlers2",
    },
    [BlessCategories.Weapons] = {
        Reputation = 16,
        Honor = 0,

        Text = "sh_menumonastery/blesssettlers3",
    },
    [BlessCategories.Financial] = {
        Reputation = 0,
        Honor = 16,

        Text = "sh_menumonastery/blesssettlers4",
    },
    [BlessCategories.Canonisation] = {
        Reputation = 12,
        Honor = 12,

        Text = "sh_menumonastery/blesssettlers5",
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
    [23] = "Z",
    [24] = "U",
    [25] = "I",
    [26] = "O",
    [27] = "P",
    [28] = "Ä", -- Might not work with english keyboards...
    [29] = "Ö", -- Might not work with english keyboards...
    [30] = "Ä", -- Might not work with english keyboards...
}

