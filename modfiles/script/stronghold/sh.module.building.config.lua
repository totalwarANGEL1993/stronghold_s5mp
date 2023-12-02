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
}

Stronghold.Building.Config.Turrets = {
    [Entities.PB_Headquarters1] = {
        {Entities.CB_Turret1, 600, -50},
        {Entities.CB_Turret1, 675, 230},
        {Entities.CB_Turret1, 600, 135},
    },
    [Entities.PB_Headquarters2] = {
        {Entities.CB_Turret2, 600, -50},
        {Entities.CB_Turret2, 675, 230},
        {Entities.CB_Turret2, 600, 135},
    },
    [Entities.PB_Headquarters3] = {
        {Entities.CB_Turret3, 600, -50},
        {Entities.CB_Turret3, 675, 230},
        {Entities.CB_Turret3, 600, 135},
    },
}

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

Stronghold.Building.Config.CornerForSegment = {
    [Entities.PB_DarkWallStraightGate_Closed]   = Entities.PB_DarkWallCorner,
    [Entities.PB_DarkWallStraightGate]          = Entities.PB_DarkWallCorner,
    [Entities.PB_DarkWallDistorted]             = Entities.PB_DarkWallCorner,
    [Entities.PB_DarkWallStraight]              = Entities.PB_DarkWallCorner,
    [Entities.PB_PalisadeStraightGate_Closed]   = Entities.PB_PalisadeCorner,
    [Entities.PB_PalisadeStraightGate]          = Entities.PB_PalisadeCorner,
    [Entities.PB_PalisadeDistorted]             = Entities.PB_PalisadeCorner,
    [Entities.PB_PalisadeStraight]              = Entities.PB_PalisadeCorner,
    [Entities.PB_WallStraightGate_Closed]       = Entities.PB_WallCorner,
    [Entities.PB_WallStraightGate]              = Entities.PB_WallCorner,
    [Entities.PB_WallDistorted]                 = Entities.PB_WallCorner,
    [Entities.PB_WallStraight]                  = Entities.PB_WallCorner,
}

Stronghold.Building.Config.OpenToClosedGate = {
    [Entities.PB_DarkWallStraightGate]          = Entities.PB_DarkWallStraightGate_Closed,
    [Entities.PB_PalisadeStraightGate]          = Entities.PB_PalisadeStraightGate_Closed,
    [Entities.PB_WallStraightGate]              = Entities.PB_WallStraightGate_Closed,
}

Stronghold.Building.Config.ClosedToOpenGate = {
    [Entities.PB_DarkWallStraightGate_Closed]   = Entities.PB_DarkWallStraightGate,
    [Entities.PB_PalisadeStraightGate_Closed]   = Entities.PB_PalisadeStraightGate,
    [Entities.PB_WallStraightGate_Closed]       = Entities.PB_WallStraightGate,
}

Stronghold.Building.Config.GateToWall = {
    [Entities.PB_DarkWallStraightGate_Closed]   = Entities.PB_DarkWallDistorted,
    [Entities.PB_PalisadeStraightGate_Closed]   = Entities.PB_PalisadeDistorted,
    [Entities.PB_WallStraightGate_Closed]       = Entities.PB_WallDistorted,
    [Entities.PB_DarkWallStraightGate]          = Entities.PB_DarkWallDistorted,
    [Entities.PB_PalisadeStraightGate]          = Entities.PB_PalisadeDistorted,
    [Entities.PB_WallStraightGate]              = Entities.PB_WallDistorted,
}

Stronghold.Building.Config.WallToGate = {
    [Entities.PB_DarkWallDistorted]             = Entities.PB_DarkWallStraightGate_Closed,
    [Entities.PB_PalisadeDistorted]             = Entities.PB_PalisadeStraightGate_Closed,
    [Entities.PB_WallDistorted]                 = Entities.PB_WallStraightGate_Closed,
}

Stronghold.Building.Config.WallToDarkWall = {
    [Entities.PB_WallStraightGate_Closed]       = Entities.PB_DarkWallStraightGate_Closed,
    [Entities.PB_WallStraightGate]              = Entities.PB_DarkWallStraightGate,
    [Entities.PB_WallDistorted]                 = Entities.PB_DarkWallDistorted,
    [Entities.PB_WallStraight]                  = Entities.PB_DarkWallStraight,
}

Stronghold.Building.Config.LegalWallType = {
    [Entities.PB_DarkWallStraightGate_Closed]   = true,
    [Entities.PB_DarkWallStraightGate]          = true,
    [Entities.PB_DarkWallDistorted]             = true,
    [Entities.PB_DarkWallStraight]              = true,
    [Entities.PB_PalisadeStraightGate_Closed]   = true,
    [Entities.PB_PalisadeStraightGate]          = true,
    [Entities.PB_PalisadeDistorted]             = true,
    [Entities.PB_PalisadeStraight]              = true,
    [Entities.PB_WallStraightGate_Closed]       = true,
    [Entities.PB_WallStraightGate]              = true,
    [Entities.PB_WallDistorted]                 = true,
    [Entities.PB_WallStraight]                  = true,
}

Stronghold.Building.Config.OpenGateType = {
    [Entities.PB_DarkWallStraightGate]          = true,
    [Entities.PB_PalisadeStraightGate]          = true,
    [Entities.PB_WallStraightGate]              = true,
}

Stronghold.Building.Config.ClosedGateType = {
    [Entities.PB_DarkWallStraightGate_Closed]   = true,
    [Entities.PB_PalisadeStraightGate_Closed]   = true,
    [Entities.PB_WallStraightGate_Closed]       = true,
}

Stronghold.Building.Config.WallSegmentType = {
    [Entities.PB_DarkWallDistorted]             = true,
    [Entities.PB_PalisadeDistorted]             = true,
    [Entities.PB_WallDistorted]                 = true,
}

Stronghold.Building.Config.WoddenWallTypes = {
    [Entities.PB_PalisadeStraightGate_Closed]   = true,
    [Entities.PB_PalisadeStraightGate]          = true,
    [Entities.PB_PalisadeDistorted]             = true,
    [Entities.PB_PalisadeStraight]              = true,
}

Stronghold.Building.Config.StoneWallTypes = {
    [Entities.PB_DarkWallStraightGate_Closed]   = true,
    [Entities.PB_DarkWallStraightGate]          = true,
    [Entities.PB_DarkWallDistorted]             = true,
    [Entities.PB_DarkWallStraight]              = true,
    [Entities.PB_WallStraightGate_Closed]       = true,
    [Entities.PB_WallStraightGate]              = true,
    [Entities.PB_WallDistorted]                 = true,
    [Entities.PB_WallStraight]                  = true,
}

Stronghold.Building.Config.RecuitIndexRecuitShortcut = {
    [1] = "A",
    [2] = "S",
    [3] = "D",
    [4] = "F",
    [5] = "G",
    [6] = "H",
    [7] = "J",
    [8] = "K",
}

