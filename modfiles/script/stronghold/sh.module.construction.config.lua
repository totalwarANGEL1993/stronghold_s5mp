--- 
--- Configuration for construction limits
--- 

Stronghold.Construction.Config = {
    TowerDistance = 1500,

    -- Check types for construction technology
    TypesToCheckForConstruction = {
        [Technologies.B_Beautification01] = {Entities.PB_Beautification01},
        [Technologies.B_Beautification02] = {Entities.PB_Beautification02},
        [Technologies.B_Beautification03] = {Entities.PB_Beautification03},
        [Technologies.B_Beautification04] = {Entities.PB_Beautification04},
        [Technologies.B_Beautification05] = {Entities.PB_Beautification05},
        [Technologies.B_Beautification06] = {Entities.PB_Beautification06},
        [Technologies.B_Beautification07] = {Entities.PB_Beautification07},
        [Technologies.B_Beautification08] = {Entities.PB_Beautification08},
        [Technologies.B_Beautification09] = {Entities.PB_Beautification09},
        [Technologies.B_Beautification10] = {Entities.PB_Beautification10},
        [Technologies.B_Beautification11] = {Entities.PB_Beautification11},
        [Technologies.B_Beautification12] = {Entities.PB_Beautification12},

        [Technologies.B_Barracks]         = {Entities.PB_Barracks1, Entities.PB_Barracks2,},
        [Technologies.B_Archery]          = {Entities.PB_Archery1, Entities.PB_Archery2,},
        [Technologies.B_Stables]          = {Entities.PB_Stable1, Entities.PB_Stable2,},
        [Technologies.B_Monastery]        = {Entities.PB_Monastery1, Entities.PB_Monastery2, Entities.PB_Monastery3},
        [Technologies.B_PowerPlant]       = {Entities.PB_PowerPlant1},
    },

    -- Check types for upgrade technologies
    TypesToCheckForUpgrade = {
        [Technologies.UP1_Barracks]  = {Entities.PB_Barracks2,},
        [Technologies.UP1_Archery]   = {Entities.PB_Archery2,},
        [Technologies.UP1_Stables]   = {Entities.PB_Stable2,},
        [Technologies.UP1_Monastery] = {Entities.PB_Monastery2, Entities.PB_Monastery3},
        [Technologies.UP2_Monastery] = {Entities.PB_Monastery1, Entities.PB_Monastery3},
        [Technologies.UP1_Market]    = {Entities.PB_Market2},
    },

    -- Building construction restricted by rights
    -- FIXME: Beautifications?
    RightsToCheckForConstruction = {
        [Technologies.B_Tavern]       = PlayerRight.Tavern,
        [Technologies.B_Archery]      = PlayerRight.ShootingRange,
        [Technologies.B_Barracks]     = PlayerRight.Barracks,
        [Technologies.B_Stables]      = PlayerRight.Barn,
        [Technologies.B_Foundry]      = PlayerRight.Foundry,
    },

    -- Building upgrade restricted by rights
    RightsToCheckForUpgrade = {
        [Technologies.UP1_Tower]      = PlayerRight.BallistaTower,
        [Technologies.UP2_Tower]      = PlayerRight.CannonTower,
        [Technologies.UP1_Market]     = PlayerRight.Market,
        [Technologies.UP1_Tavern]     = PlayerRight.Inn,
        [Technologies.UP1_University] = PlayerRight.University,
        [Technologies.UP1_Resicende]  = PlayerRight.Cottage,
        [Technologies.UP2_Resicende]  = PlayerRight.Manor,
        [Technologies.UP1_Farm]       = PlayerRight.Mill,
        [Technologies.UP2_Farm]       = PlayerRight.Estate,
        [Technologies.UP1_Archery]    = PlayerRight.Archery,
        [Technologies.UP1_Barracks]   = PlayerRight.Garnison,
        [Technologies.UP1_Stables]    = PlayerRight.Stable,
        [Technologies.UP1_Foundry]    = PlayerRight.CannonFactory,
    },
}

