--- 
--- Config for heroes
--- 

-- Hero 1 properties
Stronghold.Hero.Config.Hero1 = {
    InfluenceFactor = 1.5,
    MilitaryFactor = 1.1,
    TradeBonusFactor = 0.5,
}
-- Hero 2 properties
Stronghold.Hero.Config.Hero2 = {
    MinerExtractionBonus = 2,
    TowerBonusFactor = 1.2,
    TowerDistance = 1000,
}
-- Hero 3 properties
Stronghold.Hero.Config.Hero3 = {
    CannonPlaceReduction = 2,
    MercenaryFactor = 1,
    TrainExperience = 0,
    CannonTypes = {
        Entities.CV_Cannon1,
        Entities.CV_Cannon2,
        Entities.PV_Cannon1,
        Entities.PV_Cannon2,
        Entities.PV_Cannon3,
        Entities.PV_Cannon4,
        Entities.PV_Cannon7,
        Entities.PV_Cannon8,
    },
}
-- Hero 4 properties
Stronghold.Hero.Config.Hero4 = {
    TrainExperience = 400,
    BonusSlaves = 2,
}
-- Hero 5 properties
Stronghold.Hero.Config.Hero5 = {
    TaxIncomeFactor = 1.3,
    MinerMineralChance = 10,
    SerfMineralChance = 20,
    SerfWoodBonus = 1,
}
-- Hero 6 properties
Stronghold.Hero.Config.Hero6 = {
    CrimeRateFactor = 0.85,
    FilthRateFactor = 0.85,
    SermonHonorBonus = 3,
    SermonReputationBonus = 3,
    ConversionFrequency = 400,
    ConversionArea = 600,
}
-- Hero 7 properties
Stronghold.Hero.Config.Hero7 = {
    ReputationCap = 175,
    ReputationLossFactor = 0.70,
}
-- Hero 8 properties
Stronghold.Hero.Config.Hero8 = {
    UpkeepFactor = 0.5,
}
-- Hero 9 properties
Stronghold.Hero.Config.Hero9 = {
    TavernEfficiency = 1.5,
    WolfHonorRate = 0.08,
    MilitaryFactor = 1.1,
}
-- Hero 10 properties
Stronghold.Hero.Config.Hero10 = {
    UpkeepFactor = 0.70,
    RefiningBonus = 1,
    BonusSlaves = 2,
}
-- Hero 11 properties
Stronghold.Hero.Config.Hero11 = {
    TradeBonusFactor = 0.5,
    InitialReputation = 25,
    ReputationCap = 300,
}
-- Hero 12 properties
Stronghold.Hero.Config.Hero12 = {
    PopulationFactor = 1.2,
}

-- Text overwrite
Stronghold.Hero.Config.Hero = {
    Name = {
        [Entities.PU_Hero1c]             = nil,
        [Entities.PU_Hero2]              = nil,
        [Entities.PU_Hero3]              = nil,
        [Entities.PU_Hero4]              = nil,
        [Entities.PU_Hero5]              = nil,
        [Entities.PU_Hero6]              = nil,
        [Entities.CU_Mary_de_Mortfichet] = nil,
        [Entities.CU_BlackKnight]        = nil,
        [Entities.CU_Barbarian_Hero]     = nil,
        [Entities.PU_Hero10]             = nil,
        [Entities.PU_Hero11]             = nil,
        [Entities.CU_Evil_Queen]         = nil,
    },
    Biography = {
        [Entities.PU_Hero1c]             = nil,
        [Entities.PU_Hero2]              = nil,
        [Entities.PU_Hero3]              = nil,
        [Entities.PU_Hero4]              = nil,
        [Entities.PU_Hero5]              = nil,
        [Entities.PU_Hero6]              = nil,
        [Entities.CU_Mary_de_Mortfichet] = nil,
        [Entities.CU_BlackKnight]        = nil,
        [Entities.CU_Barbarian_Hero]     = nil,
        [Entities.PU_Hero10]             = nil,
        [Entities.PU_Hero11]             = nil,
        [Entities.CU_Evil_Queen]         = nil,
    },
    Description = {
        [Entities.PU_Hero1c]             = nil,
        [Entities.PU_Hero2]              = nil,
        [Entities.PU_Hero3]              = nil,
        [Entities.PU_Hero4]              = nil,
        [Entities.PU_Hero5]              = nil,
        [Entities.PU_Hero6]              = nil,
        [Entities.CU_BlackKnight]        = nil,
        [Entities.CU_Mary_de_Mortfichet] = nil,
        [Entities.CU_Barbarian_Hero]     = nil,
        [Entities.PU_Hero10]             = nil,
        [Entities.PU_Hero11]             = nil,
        [Entities.CU_Evil_Queen]         = nil,
    }
}

-- Configure dark replacements
Stronghold.Hero.Config.DarkBuildingReplacements = {
    [UpgradeCategories.BallistaTower] = UpgradeCategories.DarkBallistaTower,
    [UpgradeCategories.CannonTower] = UpgradeCategories.DarkCannonTower,
    [UpgradeCategories.Tower] = UpgradeCategories.DarkTower,
    [UpgradeCategories.Wall] = UpgradeCategories.DarkWall,
    [UpgradeCategories.WatchTower] = UpgradeCategories.DarkWatchTower,
}

-- Tower upgrade categories
Stronghold.Hero.Config.TowerPlacementDistanceCheck = {
    [UpgradeCategories.DarkBallistaTower] = true,
    [UpgradeCategories.DarkCannonTower] = true,
    [UpgradeCategories.DarkWatchTower] = true,
    [UpgradeCategories.DarkTower] = true,
    [UpgradeCategories.Tower] = true,
    [UpgradeCategories.BallistaTower] = true,
    [UpgradeCategories.CannonTower] = true,
    [UpgradeCategories.WatchTower] = true,
}

