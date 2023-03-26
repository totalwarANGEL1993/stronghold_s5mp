--- 
--- Configuration for construction limits
--- 

Stronghold.Construction.Config = {
    TowerDistance = 1500,
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
    TypesToCheckForUpgrade = {
        [Technologies.UP1_Barracks]  = {Entities.PB_Barracks2,},
        [Technologies.UP1_Archery]   = {Entities.PB_Archery2,},
        [Technologies.UP1_Stables]   = {Entities.PB_Stable2,},
        [Technologies.UP1_Monastery] = {Entities.PB_Monastery2, Entities.PB_Monastery3},
        [Technologies.UP2_Monastery] = {Entities.PB_Monastery1, Entities.PB_Monastery3},
        [Technologies.UP1_Market]    = {Entities.PB_Market2},
    },
}

