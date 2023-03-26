--- 
--- Configuration for economy script
--- 

Stronghold.Economy.Config.Income = {
    MaxMeasurePoints = 5000,
    MaxReputation = 200,
    TaxPerWorker = 5,

    TaxEffect = {
        [1] = {Honor = 4, Reputation = 10,},
        [2] = {Honor = 2, Reputation = -2,},
        [3] = {Honor = 1, Reputation = -4,},
        [4] = {Honor = 0, Reputation = -10,},
        [5] = {Honor = 0, Reputation = -16,},
    },

    Dynamic = {
        [Entities.PB_Farm2]      = {Honor = 0.15, Reputation = 0.06,},
        [Entities.PB_Farm3]      = {Honor = 0.21, Reputation = 0.09,},
        ---
        [Entities.PB_Residence2] = {Honor = 0.06, Reputation = 0.15,},
        [Entities.PB_Residence3] = {Honor = 0.09, Reputation = 0.21,},
        ---
        [Entities.PB_Tavern1]    = {Honor = 0, Reputation = 0.40,},
        [Entities.PB_Tavern2]    = {Honor = 0, Reputation = 0.50,},
    },
    Static = {
        [Entities.PB_Beautification04] = {Honor = 1, Reputation = 1,},
        [Entities.PB_Beautification06] = {Honor = 1, Reputation = 1,},
        [Entities.PB_Beautification09] = {Honor = 1, Reputation = 1,},
        ---
        [Entities.PB_Beautification01] = {Honor = 2, Reputation = 1,},
        [Entities.PB_Beautification02] = {Honor = 2, Reputation = 1,},
        [Entities.PB_Beautification12] = {Honor = 2, Reputation = 1,},
        ---
        [Entities.PB_Beautification05] = {Honor = 3, Reputation = 1,},
        [Entities.PB_Beautification07] = {Honor = 3, Reputation = 1,},
        [Entities.PB_Beautification08] = {Honor = 3, Reputation = 1,},
        ---
        [Entities.PB_Beautification03] = {Honor = 4, Reputation = 1,},
        [Entities.PB_Beautification10] = {Honor = 4, Reputation = 1,},
        [Entities.PB_Beautification11] = {Honor = 4, Reputation = 1,},
        ---
        [Entities.PB_Headquarters2]    = {Honor =  6, Reputation = 0,},
        [Entities.PB_Headquarters3]    = {Honor = 12, Reputation = 0,},
        ---
        [Entities.PB_Monastery1]       = {Honor = 0, Reputation = 6,},
        [Entities.PB_Monastery2]       = {Honor = 0, Reputation = 9,},
        [Entities.PB_Monastery3]       = {Honor = 0, Reputation = 12,},
    },
}

