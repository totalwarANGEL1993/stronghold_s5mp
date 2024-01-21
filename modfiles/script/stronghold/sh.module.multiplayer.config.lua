--- 
--- Multiplayer configuration
--- 

Stronghold.Multiplayer.Config.DefaultSettings = {
    Version = 1,

    -- Peacetime in minutes
    Mode = 0,

    -- Disable standard victory condition?
    -- (Game is not lost when the HQ falls)
    DisableDefaultWinCondition = false,
    -- Disable rule configuration?
    DisableRuleConfiguration = false;
    -- Disable game start timer?
    -- (Requires rule config to be disabled!)
    DisableGameStartTimer = false;

    -- Peacetime in minutes
    PeaceTime = nil,
    -- Open up named gates on the map.
    -- (PTGate1, PTGate2, ...)
    PeaceTimeOpenGates = true,

    -- Serfs
    StartingSerfs = 9,

    -- Fill resource piles with resources
    -- (value of resources or 0 to not change)
    MapStartFillClay = 2000,
    MapStartFillStone = 2000,
    MapStartFillIron = 2000,
    MapStartFillSulfur = 2000,
    MapStartFillWood = 2000,

    -- Rank
    Rank = {
        Initial = 0,
        Final = 7,
    },

    -- Resources
    -- {Honor, Gold, Clay, Wood, Stone, Iron, Sulfur}
    Resources = {
        [1] = {  0, 1000, 1200, 1500,  550,   0,    0},
        [2] = { 50, 2000, 2400, 3000, 1100, 600,    0},
        [3] = {300, 8000, 4800, 6000, 3300, 1800, 900},
    },

    -- Setup heroes allowed
    AllowedHeroes = {
        -- Dario
        [Entities.PU_Hero1c]             = true,
        -- Pilgrim
        [Entities.PU_Hero2]              = true,
        -- Salim
        [Entities.PU_Hero3]              = true,
        -- Erec
        [Entities.PU_Hero4]              = true,
        -- Ari
        [Entities.PU_Hero5]              = true,
        -- Helias
        [Entities.PU_Hero6]              = true,
        -- Kerberos
        [Entities.CU_BlackKnight]        = true,
        -- Mary
        [Entities.CU_Mary_de_Mortfichet] = true,
        -- Varg
        [Entities.CU_Barbarian_Hero]     = true,
        -- Drake
        [Entities.PU_Hero10]             = true,
        -- Yuki
        [Entities.PU_Hero11]             = true,
        -- Kala
        [Entities.CU_Evil_Queen]         = true,
    },
}

