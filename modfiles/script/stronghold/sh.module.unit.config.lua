--- 
--- Config for Units
--- 


Stronghold.Unit.Config.Movement = {
    RegularSpeedFactor = 0.7,
    AttackSpeedFactor = 1.0,

    RunToWalk = {
        ["TL_LEADER_WALK_BATTLE"] = "TL_LEADER_WALK",
        ["TL_ASSASSIN_WALK_BATTLE"] = "TL_ASSASSIN_WALK",
        ["TL_SERF_WALK_BATTLE"] = "TL_SERF_WALK",
    },
    WalkToRun = {
        ["TL_LEADER_WALK"] = "TL_LEADER_WALK_BATTLE",
        ["TL_ASSASSIN_WALK"] = "TL_ASSASSIN_WALK_BATTLE",
        ["TL_SERF_WALK"] = "TL_SERF_WALK_BATTLE",
    },
};

-- Troops config
Stronghold.Unit.Config.Troops = {
    -- Spear --

    [Entities.PU_LeaderPoleArm1]            = {
        Button            = "Buy_LeaderSpear",
        Right             = PlayerRight.SpearMilitia,
        IsCivil           = false,
        Soldiers          = 9,
        Tier              = 1,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderPoleArm2]            = {
        Button            = "Buy_LeaderSpear",
        Right             = PlayerRight.SpearLancer,
        IsCivil           = false,
        Soldiers          = 9,
        Tier              = 2,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderPoleArm3]            = {
        Button            = "Buy_LeaderSpear",
        Right             = PlayerRight.SpearLandsknecht,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderPoleArm4]            = {
        Button            = "Buy_LeaderSpear",
        Right             = PlayerRight.SpearHalberdier,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 4,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Sword  --

    [Entities.PU_LeaderSword1]              = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.SwordMilitia,
        IsCivil           = false,
        Soldiers          = 9,
        Tier              = 1,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderSword2]              = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.SwordSquire,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 2,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith1, Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderSword3]              = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.SwordLong,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderSword4]              = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.SwordGuardist,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 4,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Bow --

    [Entities.PU_LeaderBow1]                = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.ArcherMilitia,
        IsCivil           = false,
        Soldiers          = 9,
        Tier              = 1,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderBow2]                = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.ArcherLongbow,
        IsCivil           = false,
        Soldiers          = 9,
        Tier              = 2,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderBow3]                = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.ArcherCrossbow,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderBow4]                = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.ArcherPavease,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 4,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Rifle --

    [Entities.PU_LeaderRifle1]              = {
        Button            = "Buy_LeaderRifle",
        Right             = PlayerRight.RifleHandgunner,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop1, Entities.PB_GunsmithWorkshop2},
    },
    [Entities.PU_LeaderRifle2]              = {
        Button            = "Buy_LeaderRifle",
        Right             = PlayerRight.RifleMusketman,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 4,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop2},
    },

    -- Cavalry --

    [Entities.PU_LeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        Right             = PlayerRight.CavalryBow,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 2,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderCavalry2]            = {
        Button            = "Buy_LeaderCavalryLight",
        Right             = PlayerRight.CavalryCrossbow,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Heavy Cavalry --
    [Entities.PU_LeaderHeavyCavalry1]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        Right             = PlayerRight.CavalrySword,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderHeavyCavalry2]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        Right             = PlayerRight.CavalryAxe,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 4,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },

    -- Cannons --

    [Entities.PV_Cannon7]                   = {
        Button            = "Buy_Cannon1",
        Right             = PlayerRight.BigBombardCannon,
        IsCivil           = false,
        Soldiers          = 0,
        Tier              = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon8]                   = {
        Button            = "Buy_Cannon3",
        Right             = PlayerRight.DschihadCannon,
        IsCivil           = false,
        Soldiers          = 0,
        Tier              = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.CV_Cannon1]                   = {
        Button            = "Buy_Cannon4",
        Right             = PlayerRight.AtilleryCannon,
        IsCivil           = false,
        Soldiers          = 0,
        Tier              = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.CV_Cannon2]                   = {
        Button            = "Buy_Cannon4",
        Right             = PlayerRight.GatlingCannon,
        IsCivil           = false,
        Soldiers          = 0,
        Tier              = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon1]                   = {
        Button            = "Buy_Cannon1",
        Right             = PlayerRight.BombardCannon,
        IsCivil           = false,
        Soldiers          = 0,
        Tier              = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon2]                   = {
        Button            = "Buy_Cannon2",
        Right             = PlayerRight.BronzeCannon,
        IsCivil           = false,
        Soldiers          = 0,
        Tier              = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon3]                   = {
        Button            = "Buy_Cannon3",
        Right             = PlayerRight.IronCannon,
        IsCivil           = false,
        Soldiers          = 0,
        Tier              = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon4]                   = {
        Button            = "Buy_Cannon4",
        Right             = PlayerRight.SiegeCannon,
        IsCivil           = false,
        Soldiers          = 0,
        Tier              = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },

    -- Special units --

    [Entities.PU_Scout]                     = {
        Button            = "Buy_Scout",
        Right             = PlayerRight.Scout,
        IsCivil           = false,
        Soldiers          = 0,
        Tier              = 0,
        RecruiterBuilding = {Entities.PB_Tavern1, Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },
    [Entities.PU_Thief]                     = {
        Button            = "Buy_Thief",
        Right             = PlayerRight.Thief,
        IsCivil           = false,
        Soldiers          = 0,
        Tier              = 0,
        RecruiterBuilding = {Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },
    [Entities.PU_BattleSerf]                = {
        Button            = "Buy_Serf",
        Right             = PlayerRight.Serf,
        IsCivil           = true,
        Soldiers          = 0,
        Tier              = 1,
        RecruiterBuilding = {},
        ProviderBuilding  = {},
    },
    [Entities.PU_Serf]                      = {
        Button            = "Buy_Serf",
        Right             = PlayerRight.Serf,
        IsCivil           = true,
        Soldiers          = 0,
        Tier              = 1,
        RecruiterBuilding = {Entities.PB_Headquarters1, Entities.PB_Headquarters2, Entities.PB_Headquarters3},
        ProviderBuilding  = {},
    },
    [Entities.CU_Assassin_LeaderKnife1]      = {
        Button            = "Buy_Thief",
        Right             = PlayerRight.Assassin,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },

    -- Crusader --

    [Entities.CU_TemplarLeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        Right             = PlayerRight.CavalryCrusader,
        IsCivil           = false,
        Soldiers          = 5,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },
    [Entities.CU_TemplarLeaderHeavyCavalry1]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        Right             = PlayerRight.CavalryTemplar,
        IsCivil           = false,
        Soldiers          = 5,
        Tier              = 4,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },
    [Entities.CU_TemplarLeaderPoleArm1]            = {
        Button            = "Buy_LeaderSpear",
        Right             = PlayerRight.SpearTemplar,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Huscarls --

    [Entities.CU_BanditLeaderSword2]        = {
        Button            = "Buy_LeaderSword",
        Right             = 0,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 2,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderSword1]        = {
        Button            = "Buy_LeaderSword",
        Right             = 0,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderAxe1]                = {
        Button            = "Buy_LeaderSword",
        Right             = 0,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 1,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderAxe2]                = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BerserkWeak,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 2,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderAxe3]                = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BerserkStrong,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderAxe4]                = {
        Button            = "Buy_LeaderSword",
        Right             = 0,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 4,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Bandits --

    [Entities.CU_BanditLeaderSword3]        = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BanditSword,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 1,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderBow1]          = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.BanditBow,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 2,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        Right             = PlayerRight.CavalryBandit,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 3,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Barbarians --

    [Entities.CU_Barbarian_LeaderClub2]     = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BarbarianWeak,
        IsCivil           = false,
        Soldiers          = 9,
        Tier              = 2,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_Barbarian_LeaderClub1]     = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BarbarianStrong,
        IsCivil           = false,
        Soldiers          = 9,
        Tier              = 4,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith1, Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Black Knights --

    [Entities.CU_BlackKnight_LeaderMace2]   = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BlackKnightWeak,
        IsCivil           = false,
        Soldiers          = 6,
        Tier              = 2,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BlackKnight_LeaderMace1]   = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BlackKnightStrong,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 4,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Shrouded --

    [Entities.CU_Evil_LeaderBearman1]       = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.Bearman,
        IsCivil           = false,
        Soldiers          = 16,
        Tier              = 4,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.CU_Evil_LeaderSkirmisher1]    = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.Skirmisher,
        IsCivil           = false,
        Soldiers          = 16,
        Tier              = 4,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Kerberos Bodyguard --

    [Entities.CU_BlackKnight]               = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BlackKnightGuard,
        IsCivil           = false,
        Soldiers          = 3,
        Tier              = 0,
        RecruiterBuilding = {},
        ProviderBuilding  = {},
    },
}

function Stronghold.Unit.Config.Troops:GetConfig(_Type, _PlayerID)
    if not _PlayerID or not IsPlayer(_PlayerID) then
        return self[_Type];
    end
    return Stronghold.Recruit.Data[_PlayerID].Config[_Type];
end

-- Soldier to leader assignment
Stronghold.Unit.Config.EntityToDamageClassMap = {
    -- Animals
    [Entities.CU_AggressiveWolf] = DamageClasses.DC_Beast,
    [Entities.CU_AggressiveBear1] = DamageClasses.DC_Beast,
    [Entities.CU_AggressiveDog1] = DamageClasses.DC_Beast,
    [Entities.CU_AggressiveLion1] = DamageClasses.DC_Beast,
    [Entities.CU_AggressiveLion2] = DamageClasses.DC_Beast,
    [Entities.CU_AggressiveTiger1] = DamageClasses.DC_Beast,
    [Entities.CU_AggressiveWolf1] = DamageClasses.DC_Beast,
    [Entities.CU_AggressiveWolf2] = DamageClasses.DC_Beast,
    [Entities.CU_AggressiveWolf3] = DamageClasses.DC_Beast,
    [Entities.CU_AggressiveWolf4] = DamageClasses.DC_Beast,
    [Entities.PU_Bear_Cage] = DamageClasses.DC_Beast,
    [Entities.PU_Dog_Cage] = DamageClasses.DC_Beast,
    -- Heroes
    [Entities.PU_Hero1] = DamageClasses.DC_Hero,
    [Entities.PU_Hero1a] = DamageClasses.DC_Hero,
    [Entities.PU_Hero1b] = DamageClasses.DC_Hero,
    [Entities.PU_Hero1c] = DamageClasses.DC_Hero,
    [Entities.PU_Hero2] = DamageClasses.DC_Hero,
    [Entities.PU_Hero3] = DamageClasses.DC_Hero,
    [Entities.PU_Hero4] = DamageClasses.DC_Hero,
    [Entities.PU_Hero5] = DamageClasses.DC_Hero,
    [Entities.PU_Hero6] = DamageClasses.DC_Hero,
    [Entities.CU_BlackKnight] = DamageClasses.DC_Hero,
    [Entities.CU_Mary_de_Mortfichet] = DamageClasses.DC_Hero,
    [Entities.CU_Barbarian_Hero] = DamageClasses.DC_Hero,
    [Entities.PU_Hero10] = DamageClasses.DC_Hero,
    [Entities.PU_Hero11] = DamageClasses.DC_Hero,
    [Entities.CU_Evil_Queen] = DamageClasses.DC_Hero,
    [Entities.CU_Hero13] = DamageClasses.DC_Hero,
    [Entities.CU_Hero14] = DamageClasses.DC_Hero,
    -- Summons
    [Entities.CU_Barbarian_Hero_wolf] = DamageClasses.DC_Hero,
    [Entities.CU_Hero13_Summon] = DamageClasses.DC_Hero,
    [Entities.PU_Hero2_Cannon1] = DamageClasses.DC_Hero,
    [Entities.PU_Hero3_TrapCannon] = DamageClasses.DC_Hero,
    [Entities.PU_Hero5_Outlaw] = DamageClasses.DC_Hero,
    -- Specialists
    [Entities.PU_Serf] = DamageClasses.DC_Strike,
    [Entities.PU_Scout] = DamageClasses.DC_Hero,
    [Entities.PU_Thief] = DamageClasses.DC_Hero,
    -- Units
    [Entities.CU_Assassin_LeaderKnife1] = DamageClasses.DC_Slash,
    [Entities.CU_BanditLeaderCavalry1] = DamageClasses.DC_Arrow,
    [Entities.CU_BanditLeaderSword1] = DamageClasses.DC_Strike,
    [Entities.CU_BanditLeaderSword2] = DamageClasses.DC_Strike,
    [Entities.CU_BanditLeaderSword3] = DamageClasses.DC_Slash,
    [Entities.CU_BanditLeaderBow1] = DamageClasses.DC_Arrow,
    [Entities.CU_Barbarian_LeaderClub1] = DamageClasses.DC_Club,
    [Entities.CU_Barbarian_LeaderClub2] = DamageClasses.DC_Club,
    [Entities.CU_BlackKnight_LeaderMace1] = DamageClasses.DC_Mace,
    [Entities.CU_BlackKnight_LeaderMace2] = DamageClasses.DC_Mace,
    [Entities.CU_Evil_LeaderBearman1] = DamageClasses.DC_Evil,
    [Entities.CU_Evil_LeaderSkirmisher1] = DamageClasses.DC_Javelin,
    [Entities.CU_TemplarLeaderCavalry1] = DamageClasses.DC_Bolt,
    [Entities.CU_TemplarLeaderHeavyCavalry1] = DamageClasses.DC_Strike,
    [Entities.CU_TemplarLeaderPoleArm1] = DamageClasses.DC_Pole,
    [Entities.CU_VeteranCaptain] = DamageClasses.DC_Strike,
    [Entities.CU_VeteranLieutenant] = DamageClasses.DC_Strike,
    [Entities.CU_VeteranMajor] = DamageClasses.DC_Strike,
    [Entities.PU_LeaderAxe1] = DamageClasses.DC_Strike,
    [Entities.PU_LeaderAxe2] = DamageClasses.DC_Strike,
    [Entities.PU_LeaderAxe3] = DamageClasses.DC_Strike,
    [Entities.PU_LeaderAxe4] = DamageClasses.DC_Strike,
    [Entities.PU_LeaderBow1] = DamageClasses.DC_Arrow,
    [Entities.PU_LeaderBow2] = DamageClasses.DC_Arrow,
    [Entities.PU_LeaderBow3] = DamageClasses.DC_Bolt,
    [Entities.PU_LeaderBow4] = DamageClasses.DC_BoltStrong,
    [Entities.PU_LeaderCavalry1] = DamageClasses.DC_Arrow,
    [Entities.PU_LeaderCavalry2] = DamageClasses.DC_Bolt,
    [Entities.PU_LeaderHeavyCavalry1] = DamageClasses.DC_Strike,
    [Entities.PU_LeaderHeavyCavalry2] = DamageClasses.DC_Strike,
    [Entities.PU_LeaderPoleArm1] = DamageClasses.DC_Pole,
    [Entities.PU_LeaderPoleArm2] = DamageClasses.DC_Pole,
    [Entities.PU_LeaderPoleArm3] = DamageClasses.DC_Pole,
    [Entities.PU_LeaderPoleArm4] = DamageClasses.DC_Pole,
    [Entities.PU_LeaderRifle1] = DamageClasses.DC_Bullet,
    [Entities.PU_LeaderRifle2] = DamageClasses.DC_Bullet,
    [Entities.PU_LeaderSword1] = DamageClasses.DC_Slash,
    [Entities.PU_LeaderSword2] = DamageClasses.DC_Slash,
    [Entities.PU_LeaderSword3] = DamageClasses.DC_Slash,
    [Entities.PU_LeaderSword4] = DamageClasses.DC_Slash,
    -- Turrets
    [Entities.CB_Evil_Tower1_ArrowLauncher] = DamageClasses.DC_Arrow,
    [Entities.CB_Turret1_ArrowLauncher] = DamageClasses.DC_Arrow,
    [Entities.CB_Turret2_Ballista] = DamageClasses.DC_Turret,
    [Entities.CB_Turret3_Cannon] = DamageClasses.DC_Turret,
    [Entities.PB_DarkTower1_ArrowLauncher] = DamageClasses.DC_Arrow,
    [Entities.PB_DarkTower2_Ballista] = DamageClasses.DC_Turret,
    [Entities.PB_DarkTower3_Cannon] = DamageClasses.DC_Turret,
    [Entities.PB_Tower1_ArrowLauncher] = DamageClasses.DC_Arrow,
    [Entities.PB_Tower2_Ballista] = DamageClasses.DC_Turret,
    [Entities.PB_Tower3_Cannon] = DamageClasses.DC_Turret,
    -- Cannons
    [Entities.CV_Cannon_TEST] = DamageClasses.DC_TroopCannon,
    [Entities.CV_Cannon1] = DamageClasses.DC_Artillery,
    [Entities.CV_Cannon2] = DamageClasses.DC_TroopCannon,
    [Entities.PV_Cannon1] = DamageClasses.DC_TroopCannon,
    [Entities.PV_Cannon2] = DamageClasses.DC_SiegeCannon,
    [Entities.PV_Cannon3] = DamageClasses.DC_TroopCannon,
    [Entities.PV_Cannon4] = DamageClasses.DC_SiegeCannon,
    [Entities.PV_Cannon7] = DamageClasses.DC_TroopCannon,
    [Entities.PV_Cannon8] = DamageClasses.DC_TroopCannon,
}

-- Soldier to leader assignment
Stronghold.Unit.Config.LeaderToSoldierMap = {
    -- Kerberos
    [Entities.CU_BlackKnight] = Entities.CU_BlackKnight_Bodyguard,
    -- Axe
    [Entities.CU_BanditLeaderSword1] = Entities.CU_BanditSoldierSword1,
    [Entities.CU_BanditLeaderSword2] = Entities.CU_BanditSoldierSword2,
    [Entities.PU_LeaderAxe1] = Entities.PU_SoldierAxe1,
    [Entities.PU_LeaderAxe2] = Entities.PU_SoldierAxe2,
    [Entities.PU_LeaderAxe3] = Entities.PU_SoldierAxe3,
    [Entities.PU_LeaderAxe4] = Entities.PU_SoldierAxe4,
    -- Bow
    [Entities.CU_BanditLeaderBow1] = Entities.CU_BanditSoldierBow1,
    [Entities.PU_LeaderBow1] = Entities.PU_SoldierBow1,
    [Entities.PU_LeaderBow2] = Entities.PU_SoldierBow2,
    [Entities.PU_LeaderBow3] = Entities.PU_SoldierBow3,
    [Entities.PU_LeaderBow4] = Entities.PU_SoldierBow4,
    -- Cavalry Heavy
    [Entities.CU_TemplarLeaderHeavyCavalry1] = Entities.CU_TemplarSoldierHeavyCavalry1,
    [Entities.PU_LeaderHeavyCavalry1] = Entities.PU_SoldierHeavyCavalry1,
    [Entities.PU_LeaderHeavyCavalry2] = Entities.PU_SoldierHeavyCavalry2,
    -- Cavalry Light
    [Entities.CU_BanditLeaderCavalry1] = Entities.CU_BanditSoldierCavalry1,
    [Entities.CU_TemplarLeaderCavalry1] = Entities.CU_TemplarSoldierCavalry1,
    [Entities.PU_LeaderCavalry1] = Entities.PU_SoldierCavalry1,
    [Entities.PU_LeaderCavalry2] = Entities.PU_SoldierCavalry2,
    -- Mace
    [Entities.CU_Barbarian_LeaderClub1] = Entities.CU_Barbarian_SoldierClub1,
    [Entities.CU_Barbarian_LeaderClub2] = Entities.CU_Barbarian_SoldierClub2,
    [Entities.CU_BlackKnight_LeaderMace1] = Entities.CU_BlackKnight_SoldierMace1,
    [Entities.CU_BlackKnight_LeaderMace2] = Entities.CU_BlackKnight_SoldierMace2,
    -- Rifle
    [Entities.PU_LeaderRifle1] = Entities.PU_SoldierRifle1,
    [Entities.PU_LeaderRifle2] = Entities.PU_SoldierRifle2,
    -- Shrouded
    [Entities.CU_Evil_LeaderBearman1] = Entities.CU_Evil_SoldierBearman1,
    [Entities.CU_Evil_LeaderSkirmisher1] = Entities.CU_Evil_SoldierSkirmisher1,
    -- Spear
    [Entities.CU_TemplarLeaderPoleArm1] = Entities.CU_TemplarSoldierPoleArm1,
    [Entities.PU_LeaderPoleArm1] = Entities.PU_SoldierPoleArm1,
    [Entities.PU_LeaderPoleArm2] = Entities.PU_SoldierPoleArm2,
    [Entities.PU_LeaderPoleArm3] = Entities.PU_SoldierPoleArm3,
    [Entities.PU_LeaderPoleArm4] = Entities.PU_SoldierPoleArm4,
    -- Sword
    [Entities.CU_Assassin_LeaderKnife1] = Entities.CU_Assassin_SoldierKnife1,
    [Entities.CU_BanditLeaderSword3] = Entities.CU_BanditSoldierSword3,
    [Entities.PU_LeaderSword1] = Entities.PU_SoldierSword1,
    [Entities.PU_LeaderSword2] = Entities.PU_SoldierSword2,
    [Entities.PU_LeaderSword3] = Entities.PU_SoldierSword3,
    [Entities.PU_LeaderSword4] = Entities.PU_SoldierSword4,
};

-- Passive abilities of units
Stronghold.Unit.Config.Passive = {
    Selfheal = {
        [Entities.PU_BattleSerf] = {
            Healing = 2,
        },
        [Entities.PU_Serf] = {
            Healing = 2,
        },
    },
    Fear = {
        [Entities.CU_Evil_LeaderBearman1] = {
            Chance = 10,
        },
        [Entities.CU_Evil_LeaderSkirmisher1] = {
            Chance = 10,
        },
    },
    Cripple = {
        [Entities.CU_BanditLeaderSword1] = {
            Chance = 12,
            Duration = 30,
            Factor = 1.25,
        },
        [Entities.CU_BanditSoldierSword1] = {
            Chance = 12,
            Duration = 30,
            Factor = 1.25,
        },
        [Entities.CU_BanditLeaderSword2] = {
            Chance = 6,
            Duration = 30,
            Factor = 1.25,
        },
        [Entities.CU_BanditSoldierSword2] = {
            Chance = 6,
            Duration = 30,
            Factor = 1.25,
        },
        [Entities.PU_LeaderAxe1] = {
            Chance = 6,
            Duration = 20,
            Factor = 1.25,
        },
        [Entities.PU_SoldierAxe1] = {
            Chance = 6,
            Duration = 20,
            Factor = 1.25,
        },
        [Entities.PU_LeaderAxe2] = {
            Chance = 6,
            Duration = 30,
            Factor = 1.25,
        },
        [Entities.PU_SoldierAxe2] = {
            Chance = 6,
            Duration = 30,
            Factor = 1.25,
        },
        [Entities.PU_LeaderAxe3] = {
            Chance = 12,
            Duration = 30,
            Factor = 1.25,
        },
        [Entities.PU_SoldierAxe3] = {
            Chance = 12,
            Duration = 30,
            Factor = 1.25,
        },
        [Entities.PU_LeaderAxe4] = {
            Chance = 12,
            Duration = 45,
            Factor = 1.25,
        },
        [Entities.PU_SoldierAxe4] = {
            Chance = 12,
            Duration = 45,
            Factor = 1.25,
        },
        [Entities.PU_LeaderSword4] = {
            Chance = 12,
            Duration = 30,
            Factor = 1.25,
        },
        [Entities.PU_SoldierSword4] = {
            Chance = 12,
            Duration = 30,
            Factor = 1.25,
        },
    },
    Sneak = {
        [Entities.CU_Assassin_LeaderKnife1] = {
            Chance = 25,
            Factor = 6.00,
            Angle  = 90,
        },
        [Entities.CU_Assassin_SoldierKnife1] = {
            Chance = 25,
            Factor = 6.00,
            Angle  = 90,
        },
    },
    Circle = {
        [Entities.PU_LeaderPoleArm2] = {
            Melee = 0.5,
            Ranged = 1.25,
        },
        [Entities.PU_SoldierPoleArm2] = {
            Melee = 0.5,
            Ranged = 1.25,
        },
        [Entities.PU_LeaderPoleArm4] = {
            Melee = 0.5,
            Ranged = 1.25,
        },
        [Entities.PU_SoldierPoleArm4] = {
            Melee = 0.5,
            Ranged = 1.25,
        },
    },
    Refund = {
        [Entities.PU_LeaderSword1] = {
            Refund = 0.5
        },
        [Entities.PU_SoldierSword1] = {
            Refund = 0.5
        },
        [Entities.PU_LeaderBow4] = {
            Refund = 0.5
        },
        [Entities.PU_SoldierBow4] = {
            Refund = 0.5
        },
    },
    ComboStar = {
        [Entities.PU_LeaderCavalry2] = {
            MaxTime = 100,
            Bonus = 0.015,
        },
        [Entities.PU_SoldierCavalry2] = {
            MaxTime = 100,
            Bonus = 0.015,
        },
        [Entities.PU_LeaderHeavyCavalry2] = {
            MaxTime = 100,
            Bonus = 0.015,
        },
        [Entities.PU_SoldierHeavyCavalry2] = {
            MaxTime = 100,
            Bonus = 0.015,
        },
    },
}

