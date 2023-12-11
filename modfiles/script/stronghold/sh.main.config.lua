--- 
--- Config for the main module.
--- 

Stronghold.Config = {
    Base = {
        MaxPossiblePlayers = 8,
        MaxHumanPlayers = 6,
        MaxHeroDistance = 15000,
        InitialRank = 0,
        MaxRank = 7,
        StartingSerfs = 9,
    },

    DefeatModes = {
        SuddenDeath = false,
        LastManStanding = false,
        Annihilation = true,
    },

    Logging = {
        SyncCall = "SyncCall received ::: Module: %s, Type: %d, Player: %d, Parameter: %s",
        EntityCreated = "Entity created ::: Player: %d, ID: %d, Type: %s",
        Resource = "Resource given ::: Player: %d, Type: %s, Amount: %d",
    },

    Payday = {
        Base = 900,
        Improved = 810,
    },

    Trade = {
        -- {buy min, buy max, sell min, sell max}
        [ResourceType.Gold]   = {0.85, 1.25, 0.85, 1.25},
        [ResourceType.Clay]   = {0.80, 1.35, 0.80, 1.35},
        [ResourceType.Wood]   = {0.60, 1.15, 0.60, 1.15},
        [ResourceType.Stone]  = {0.80, 1.35, 0.80, 1.35},
        [ResourceType.Iron]   = {0.90, 1.50, 0.90, 1.50},
        [ResourceType.Sulfur] = {0.95, 1.50, 0.95, 1.50},
    },
}

