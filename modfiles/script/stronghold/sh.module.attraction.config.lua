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
    HQMilitary = {[1] = 75, [2] = 100, [3] = 125},
    OPMilitary = {[1] = 40, [2] = 65, [3] = 90},
    -- Serf attraction limit
    SlaveLimit = 30,
    RankSlaveBonus = 6,
}

Stronghold.Attraction.Config.Rats = {
    BaseDirtRate = 0.015,
    UpgradeDirtRade = 0.005,
    DisposalRate = 0.05,
    HawkArea = 5000,
}

Stronghold.Attraction.Config.Crime = {
    Obfuscation = {
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
        Rate = 1.5,
        Executioner = 0.60,
        MaxPerCycle = 5,
        TimeBetween = 10,
    },
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
    [Entities.CU_Templar_LeaderPoleArm1] = 1,
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
    [Entities.PU_LeaderBow4] = 2,
    [Entities.PU_LeaderRifle1] = 2,
    [Entities.PU_LeaderRifle2] = 2,
    ---
    [Entities.CU_Templar_LeaderCavalry1] = 1,
    [Entities.CU_Templar_LeaderHeavyCavalry1] = 2,
    [Entities.CU_BanditLeaderCavalry1] = 2,
    [Entities.PU_LeaderCavalry1] = 2,
    [Entities.PU_LeaderCavalry2] = 2,
    [Entities.PU_LeaderHeavyCavalry1] = 2,
    [Entities.PU_LeaderHeavyCavalry2] = 2,
    ---
    [Entities.PV_Cannon1] = 4,
    [Entities.PV_Cannon2] = 4,
    [Entities.PV_Cannon3] = 8,
    [Entities.PV_Cannon4] = 8,
    [Entities.PV_Cannon7] = 4,
    [Entities.PV_Cannon8] = 8,
    [Entities.CV_Cannon1] = 8,
    [Entities.CV_Cannon2] = 8,
    ---
    [Entities.PU_Scout] = 1,
    [Entities.PU_Thief] = 5,
    ---
    [Entities.PU_BattleSerf] = 1,
    [Entities.PU_Serf] = 1,
    [Entities.CU_BlackKnight] = 1,
}

