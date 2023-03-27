--- 
--- Config for heroes
--- (Can this be deleted?)
--- 

-- Hero 1 properties
Stronghold.Hero.Config.Hero1 = {
    MeasureFactor = 2.0,
}
-- Hero 2 properties
Stronghold.Hero.Config.Hero2 = {
    -- FIXME
}
-- Hero 3 properties
Stronghold.Hero.Config.Hero3 = {
    UnitCostFactor = 0.9,
}
-- Hero 4 properties
Stronghold.Hero.Config.Hero4 = {
    TrainExperience = 3,
    UnitCostFactor = 1.5,
}
-- Hero 5 properties
Stronghold.Hero.Config.Hero5 = {
    TaxIncomeFactor = 1.3,
}
-- Hero 6 properties
Stronghold.Hero.Config.Hero6 = {
    CrimeRateFactor = 0.75,
    ConversionArea = 600,
    ConversionChance = 3,
    ConversionMax = 1000,
}
-- Hero 7 properties
Stronghold.Hero.Config.Hero7 = {
    ReputationCap = 175,
    ReputationLossFactor = 0.6,
}
-- Hero 8 properties
Stronghold.Hero.Config.Hero8 = {
    UpkeepFactor = 0.5,
}
-- Hero 9 properties
Stronghold.Hero.Config.Hero9 = {
    TavernEfficiency = 2.0,
    WolfHonorRate = 0.05,
}
-- Hero 10 properties
Stronghold.Hero.Config.Hero10 = {
    TrainTimeFactor = 0.5,
    UpkeepFactor = 0.7,
}
-- Hero 11 properties
Stronghold.Hero.Config.Hero11 = {
    UnitCostFactor = 0.9,
    InitialReputation = 100,
    ReputationCap = 300,
}
-- Hero 12 properties
Stronghold.Hero.Config.Hero12 = {
    PupulationFactor = 1.15,
}

Stronghold.Hero.Config.Nobles = {
    {Entities.PU_Hero1c,             true},
    {Entities.PU_Hero2,              true},
    {Entities.PU_Hero3,              true},
    {Entities.PU_Hero4,              true},
    {Entities.PU_Hero5,              true},
    {Entities.PU_Hero6,              true},
    {Entities.CU_BlackKnight,        true},
    {Entities.CU_Mary_de_Mortfichet, true},
    {Entities.CU_Barbarian_Hero,     true},
    {Entities.PU_Hero10,             true},
    {Entities.PU_Hero11,             true},
    {Entities.CU_Evil_Queen,         true},
}

Stronghold.Hero.Config.TypeToBuyHeroButton = {
    [Entities.PU_Hero1c]             = "BuyHeroWindowBuyHero1",
    [Entities.PU_Hero2]              = "BuyHeroWindowBuyHero5",
    [Entities.PU_Hero3]              = "BuyHeroWindowBuyHero4",
    [Entities.PU_Hero4]              = "BuyHeroWindowBuyHero3",
    [Entities.PU_Hero5]              = "BuyHeroWindowBuyHero2",
    [Entities.PU_Hero6]              = "BuyHeroWindowBuyHero6",
    [Entities.CU_Mary_de_Mortfichet] = "BuyHeroWindowBuyHero7",
    [Entities.CU_BlackKnight]        = "BuyHeroWindowBuyHero8",
    [Entities.CU_Barbarian_Hero]     = "BuyHeroWindowBuyHero9",
    [Entities.PU_Hero10]             = "BuyHeroWindowBuyHero10",
    [Entities.PU_Hero11]             = "BuyHeroWindowBuyHero11",
    [Entities.CU_Evil_Queen]         = "BuyHeroWindowBuyHero12",
}

