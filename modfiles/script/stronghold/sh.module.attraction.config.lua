--- 
--- Configuration for the attraction system
--- 

Stronghold.Attraction.Config.Attraction = {
    -- Civil attration limit
    -- THIS MUST BE IN SYNC WITH ENTITY DEFINITION XML!
    HQCivil = {[1] = 75, [2] = 100, [3] = 125},
    VCCivil = {[1] = 35, [2] =  50, [3] = 65},
    -- Military attraction limit
    -- This is freely changeable in Lua
    HQMilitary = {[1] = 90, [2] = 135, [3] = 180},
    OPMilitary = {[1] = 45, [2] =  70, [3] =  95},
    -- Serf attraction limit
    SlaveLimit = 30,
    RankSlaveBonus = 6,
}

Stronghold.Attraction.Config.UsedSpace = {
    [Entities.CU_BanditLeaderSword1] = 2,
    [Entities.CU_BanditLeaderSword2] = 1,
    [Entities.CU_BanditLeaderSword3] = 1,
    [Entities.CU_Barbarian_LeaderClub1] = 1,
    [Entities.CU_Barbarian_LeaderClub2] = 1,
    [Entities.CU_BlackKnight_LeaderMace1] = 2,
    [Entities.CU_BlackKnight_LeaderMace2] = 1,
    [Entities.CU_Evil_LeaderBearman1] = 1,
    [Entities.CU_TemplarLeaderPoleArm1] = 1,
    [Entities.PU_LeaderPoleArm1] = 1,
    [Entities.PU_LeaderPoleArm2] = 1,
    [Entities.PU_LeaderPoleArm3] = 1,
    [Entities.PU_LeaderPoleArm4] = 1,
    [Entities.PU_LeaderAxe1] = 1,
    [Entities.PU_LeaderAxe2] = 1,
    [Entities.PU_LeaderAxe3] = 2,
    [Entities.PU_LeaderAxe4] = 2,
    [Entities.PU_LeaderSword1] = 1,
    [Entities.PU_LeaderSword2] = 1,
    [Entities.PU_LeaderSword3] = 2,
    [Entities.PU_LeaderSword4] = 2,
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
    [Entities.CU_TemplarLeaderCavalry1] = 1,
    [Entities.CU_TemplarLeaderHeavyCavalry1] = 1,
    [Entities.CU_BanditLeaderCavalry1] = 2,
    [Entities.PU_LeaderCavalry1] = 2,
    [Entities.PU_LeaderCavalry2] = 2,
    [Entities.PU_LeaderHeavyCavalry1] = 2,
    [Entities.PU_LeaderHeavyCavalry2] = 2,
    ---
    [Entities.PV_Cannon1] = 8,
    [Entities.PV_Cannon2] = 8,
    [Entities.PV_Cannon3] = 16,
    [Entities.PV_Cannon4] = 16,
    [Entities.PV_Cannon7] = 8,
    [Entities.PV_Cannon8] = 16,
    [Entities.CV_Cannon1] = 24,
    [Entities.CV_Cannon2] = 16,
    ---
    [Entities.PU_Scout] = 1,
    [Entities.PU_Thief] = 5,
    [Entities.CU_Assassin_LeaderKnife1] = 2,
    ---
    [Entities.PU_BattleSerf] = 1,
    [Entities.PU_Serf] = 1,
    [Entities.CU_BlackKnight] = 0,
}

