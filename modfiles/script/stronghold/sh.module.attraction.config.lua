--- 
--- Configuration for the attraction system
--- 

Stronghold.Attraction.Config.Attraction = {
    -- Civil attration limit
    -- THIS MUST BE IN SYNC WITH ENTITY DEFINITION XML!
    HQCivil = {[1] = 125, [2] = 175, [3] = 225},
    VCCivil = {[1] = 45, [2] = 90, [3] = 135},
    -- Military attraction limit
    -- This is freely changeable in Lua
    HQMilitary = {[1] = 78, [2] = 130, [3] = 195},
    BBMilitary = {[1] = 0, [2] = 26},
    -- Serf attraction limit
    -- This is freely changeable in Lua
    SlaveLimit = 24,
    RankSlaveBonus = 6,
}

Stronghold.Attraction.Config.Crime = {
    Unveil = {
        Points = 120,
        SerfArea = 3000,
        TowerArea = 5000,
        HeroArea = 500,
        SerfRate = 3.0,
        TowerRate = 5.0,
        HeroRate = 60.0,
        TownGuardFactor = 1.5,
    },
    Effects = {
        TheftAmount = {Min = 25, Max = 75},
        ReputationDamage = 4,
    },
    Convert = {
        Chance = 6,
        Rate = 1.0,
        MaxPerCycle = 5,
        TimeBetween = 10,
    },
}

Stronghold.Attraction.Config.ReserveUnits = {
    AttractionFactor = 0.85,
}

Stronghold.Attraction.Config.ForeignSpecialists = {
    AttractionFactor = 0.85,
}

Stronghold.Attraction.Config.UsedSpace = {
    [Entities.CU_BanditLeaderSword1] = 1,
    [Entities.CU_BanditLeaderSword2] = 1,
    [Entities.CU_BanditLeaderSword3] = 1,
    [Entities.CU_Barbarian_LeaderClub1] = 1,
    [Entities.CU_Barbarian_LeaderClub2] = 1,
    [Entities.CU_BlackKnight_LeaderMace1] = 1,
    [Entities.CU_BlackKnight_LeaderMace2] = 1,
    [Entities.CU_Evil_LeaderBearman1] = 1,
    [Entities.CU_TemplarLeaderPoleArm1] = 1,
    [Entities.PU_LeaderPoleArm1] = 1,
    [Entities.PU_LeaderPoleArm2] = 1,
    [Entities.PU_LeaderPoleArm3] = 1,
    [Entities.PU_LeaderPoleArm4] = 1,
    [Entities.PU_LeaderSword1] = 1,
    [Entities.PU_LeaderSword2] = 1,
    [Entities.PU_LeaderSword3] = 1,
    [Entities.PU_LeaderSword4] = 1,
    ---
    [Entities.CU_BanditLeaderBow1] = 1,
    [Entities.CU_BanditLeaderBow2] = 1,
    [Entities.CU_Evil_LeaderSkirmisher1] = 1,
    [Entities.PU_LeaderBow1] = 1,
    [Entities.PU_LeaderBow2] = 1,
    [Entities.PU_LeaderBow3] = 1,
    [Entities.PU_LeaderBow4] = 2,
    [Entities.PU_LeaderRifle1] = 2,
    [Entities.PU_LeaderRifle2] = 2,
    ---
    [Entities.CU_CrusaderLeaderCavalry1] = 1,
    [Entities.CU_TemplarLeaderCavalry1] = 2,
    [Entities.CU_RangerLeaderCavalry1] = 2,
    [Entities.PU_LeaderCavalry1] = 2,
    [Entities.PU_LeaderCavalry2] = 2,
    [Entities.PU_LeaderHeavyCavalry1] = 2,
    [Entities.PU_LeaderHeavyCavalry2] = 2,
    ---
    [Entities.PV_Cannon1] = 4,
    [Entities.PV_Cannon2] = 4,
    [Entities.PV_Cannon3] = 8,
    [Entities.PV_Cannon4] = 8,
    [Entities.CV_Cannon1] = 4,
    [Entities.CV_Cannon2] = 8,
    ---
    [Entities.PU_Scout] = 1,
    [Entities.PU_Thief] = 5,
    ---
    [Entities.PU_BattleSerf] = 1,
    [Entities.PU_Serf] = 1,
    [Entities.CU_BlackKnight] = 1,
}

