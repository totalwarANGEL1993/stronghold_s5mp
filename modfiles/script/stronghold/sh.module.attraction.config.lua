--- 
--- Configuration for the attraction system
--- 

Stronghold.Attraction.Config.Attraction = {
    -- Civil attration limit
    -- THIS MUST BE IN SYNC WITH ENTITY DEFINITION XML!
    HQCivil = {[1] = 50, [2] = 75, [3] = 100},
    VCCivil = {[1] = 35, [2] = 50, [3] = 65},
    -- Military attraction limit
    -- This is freely changeable in Lua
    HQMilitary = {[1] = 50, [2] = 75, [3] = 100},
    BBMilitary = {[1] = 15, [2] = 30},
    -- Serf attraction limit
    -- This is freely changeable in Lua
    SlaveLimit = 24,
    RankSlaveBonus = 6,
}

Stronghold.Attraction.Config.Crime = {
    Unveil = {
        Points = 120,
        SerfArea = 3000,
        TowerArea = 4500,
        SerfRate = 2.1,
        TowerRate = 3.5,
        TownGuardFactor = 1.5,
    },
    Effects = {
        TheftAmount = {Min = 25, Max = 75},
        ReputationDamage = 2,
    },
    Convert = {
        Chance = 3,
        Rate = 1.0,
        MaxPerCycle = 5,
        TimeBetween = 20,
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
    [Entities.PU_LeaderBow4] = 1,
    [Entities.PU_LeaderRifle1] = 2,
    [Entities.PU_LeaderRifle2] = 2,
    ---
    [Entities.CU_CrusaderLeaderCavalry1] = 1,
    [Entities.CU_TemplarLeaderCavalry1] = 2,
    [Entities.CU_RangerLeaderCavalry1] = 2,
    [Entities.PU_LeaderCavalry1] = 2,
    [Entities.PU_LeaderCavalry2] = 2,
    [Entities.PU_LeaderHeavyCavalry1] = 3,
    [Entities.PU_LeaderHeavyCavalry2] = 3,
    ---
    [Entities.PV_Cannon1] = 8,
    [Entities.PV_Cannon2] = 8,
    [Entities.PV_Cannon3] = 8,
    [Entities.PV_Cannon4] = 8,
    [Entities.CV_Cannon1] = 8,
    [Entities.CV_Cannon2] = 8,
    ---
    [Entities.PU_Scout] = 1,
    [Entities.PU_Thief] = 5,
    ---
    [Entities.PU_BattleSerf] = 1,
    [Entities.PU_Serf] = 1,
}

