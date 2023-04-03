--- 
--- Config for the main module.
--- 

Stronghold.Config = {
    Base = {
        InitialResources = {0, 0, 0, 0, 0, 0, 0},
        InitialRank = 0,
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

