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
        SuddenDeath = true,
        LastManStanding = false,
        Annihilation = false,
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
}

