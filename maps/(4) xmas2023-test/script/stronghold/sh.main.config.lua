--- 
--- 
--- 

Stronghold.Config = {
    Base = {
        MaxHonor = 9000,
        InitialResources = {0, 1000, 2000, 2500, 850, 100, 100},
        InitialRank = 1,
        MaxRank = 7,
        StartingSerfs = 6,
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

