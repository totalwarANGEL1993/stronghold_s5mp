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

