--- 
--- 
--- 

Stronghold.Attraction.Config.Attraction = {
    -- THIS MUST BE IN SYNC WITH ENTITY DEFINITION XML!
    HQCivil = {[1] = 75, [2] = 100, [3] = 125},
    VCCivil = {[1] = 35, [2] = 50, [3] = 65},
    -- This is freely changeable in Lua
    HQMilitary = {[1] = 60, [2] = 90, [3] = 120},
    VCMilitary = {[1] = 0, [2] = 0, [3] = 0},
}

Stronghold.Attraction.Config.Crime = {
    Unveil = {
        Points = 180,
        Area = 3500,
        SoldierRate = 2,
        BuildingRate = 4,
        TownGuardFactor = 1.5,
    },
    Effects = {
        TheftAmount = {Min = 25, Max = 75},
        ReputationDamage = 4,
    },
    Convert = {
        Chance = 5,
        Rate = 1.0,
        TimeBetween = 10
    },
}

Stronghold.Attraction.Config.UsedSpace = {
    [Entities.CU_BanditLeaderSword1] = 1,
    [Entities.CU_BanditLeaderSword2] = 1,
    [Entities.CU_Barbarian_LeaderClub1] = 1,
    [Entities.CU_Barbarian_LeaderClub2] = 1,
    [Entities.CU_BlackKnight_LeaderMace1] = 1,
    [Entities.CU_BlackKnight_LeaderMace2] = 1,
    [Entities.CU_Evil_LeaderBearman1] = 1,
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
    [Entities.CU_Evil_LeaderSkirmisher1] = 1,
    [Entities.PU_LeaderBow1] = 1,
    [Entities.PU_LeaderBow2] = 1,
    [Entities.PU_LeaderBow3] = 1,
    [Entities.PU_LeaderBow4] = 1,
    [Entities.PU_LeaderRifle1] = 2,
    [Entities.PU_LeaderRifle2] = 2,
    ---
    [Entities.PU_LeaderCavalry1] = 1,
    [Entities.PU_LeaderCavalry2] = 1,
    [Entities.PU_LeaderHeavyCavalry1] = 3,
    [Entities.PU_LeaderHeavyCavalry2] = 3,
    ---
    [Entities.PV_Cannon1] = 10,
    [Entities.PV_Cannon2] = 10,
    [Entities.PV_Cannon3] = 20,
    [Entities.PV_Cannon4] = 20,
    ---
    [Entities.PU_Scout] = 1,
    [Entities.PU_Thief] = 5,
    ---
    [Entities.PU_Serf] = 1,
}

