--- 
--- Config for Units
--- 

-- Troops config
Stronghold.Unit.Config.Troops = {
    -- Spear --

    [Entities.PU_LeaderPoleArm1]            = {
        Button            = "Buy_LeaderSpear",
        Right             = PlayerRight.SpearMilitia,
        IsCivil           = false,
        Upkeep            = 15,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderPoleArm2]            = {
        Button            = "Buy_LeaderSpear",
        Right             = PlayerRight.SpearLancer,
        IsCivil           = false,
        Upkeep            = 20,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderPoleArm3]            = {
        Button            = "Buy_LeaderSpear",
        Right             = PlayerRight.SpearLandsknecht,
        IsCivil           = false,
        Upkeep            = 40,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderPoleArm4]            = {
        Button            = "Buy_LeaderSpear",
        Right             = PlayerRight.SpearHalberdier,
        IsCivil           = false,
        Upkeep            = 50,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Sword  --

    [Entities.PU_LeaderSword1]              = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.SwordMilitia,
        IsCivil           = false,
        Upkeep            = 30,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderSword2]              = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.SwordSquire,
        IsCivil           = false,
        Upkeep            = 40,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith1, Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderSword3]              = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.SwordLong,
        IsCivil           = false,
        Upkeep            = 60,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderSword4]              = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.SwordGuardist,
        IsCivil           = false,
        Upkeep            = 70,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Bow --

    [Entities.PU_LeaderBow1]                = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.ArcherMilitia,
        IsCivil           = false,
        Upkeep            = 20,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderBow2]                = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.ArcherLongbow,
        IsCivil           = false,
        Upkeep            = 30,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderBow3]                = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.ArcherCrossbow,
        IsCivil           = false,
        Upkeep            = 45,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderBow4]                = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.ArcherPavease,
        IsCivil           = false,
        Upkeep            = 55,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Rifle --

    [Entities.PU_LeaderRifle1]              = {
        Button            = "Buy_LeaderRifle",
        Right             = PlayerRight.RifleHandgunner,
        IsCivil           = false,
        Upkeep            = 40,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop1, Entities.PB_GunsmithWorkshop2},
    },
    [Entities.PU_LeaderRifle2]              = {
        Button            = "Buy_LeaderRifle",
        Right             = PlayerRight.RifleMusketman,
        IsCivil           = false,
        Upkeep            = 70,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop2},
    },

    -- Cavalry --

    [Entities.PU_LeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        Right             = PlayerRight.CavalryBow,
        IsCivil           = false,
        Upkeep            = 50,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderCavalry2]            = {
        Button            = "Buy_LeaderCavalryLight",
        Right             = PlayerRight.CavalryCrossbow,
        IsCivil           = false,
        Upkeep            = 60,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Heavy Cavalry --
    [Entities.PU_LeaderHeavyCavalry1]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        Right             = PlayerRight.CavalrySword,
        IsCivil           = false,
        Upkeep            = 75,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderHeavyCavalry2]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        Right             = PlayerRight.CavalryAxe,
        IsCivil           = false,
        Upkeep            = 85,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },

    -- Cannons --

    [Entities.PV_Cannon7]                   = {
        Button            = "Buy_Cannon1",
        Right             = PlayerRight.BigBombardCannon,
        IsCivil           = false,
        Upkeep            = 35,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon8]                   = {
        Button            = "Buy_Cannon3",
        Right             = PlayerRight.DschihadCannon,
        IsCivil           = false,
        Upkeep            = 100,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.CV_Cannon1]                   = {
        Button            = "Buy_Cannon4",
        Right             = PlayerRight.AtilleryCannon,
        IsCivil           = false,
        Upkeep            = 200,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.CV_Cannon2]                   = {
        Button            = "Buy_Cannon4",
        Right             = PlayerRight.GatlingCannon,
        IsCivil           = false,
        Upkeep            = 200,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon1]                   = {
        Button            = "Buy_Cannon1",
        Right             = PlayerRight.BombardCannon,
        IsCivil           = false,
        Upkeep            = 30,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon2]                   = {
        Button            = "Buy_Cannon2",
        Right             = PlayerRight.BronzeCannon,
        IsCivil           = false,
        Upkeep            = 30,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon3]                   = {
        Button            = "Buy_Cannon3",
        Right             = PlayerRight.IronCannon,
        IsCivil           = false,
        Upkeep            = 90,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon4]                   = {
        Button            = "Buy_Cannon4",
        Right             = PlayerRight.SiegeCannon,
        IsCivil           = false,
        Upkeep            = 90,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },

    -- Special units --

    [Entities.PU_Scout]                     = {
        Button            = "Buy_Scout",
        Right             = PlayerRight.Scout,
        IsCivil           = true,
        Upkeep            = 25,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Tavern1, Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },
    [Entities.PU_Thief]                     = {
        Button            = "Buy_Thief",
        Right             = PlayerRight.Thief,
        IsCivil           = true,
        Upkeep            = 50,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },
    [Entities.PU_Serf]                      = {
        Button            = "Buy_Serf",
        Right             = PlayerRight.Serf,
        IsCivil           = true,
        IsSlave           = true,
        Upkeep            = 0,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Headquarters1, Entities.PB_Headquarters2, Entities.PB_Headquarters3},
        ProviderBuilding  = {},
    },

    -- Crusader --

    [Entities.CU_TemplarLeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        Right             = PlayerRight.CavalryCrusader,
        IsCivil           = false,
        Upkeep            = 55,
        Soldiers          = 5,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },
    [Entities.CU_TemplarLeaderHeavyCavalry1]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        Right             = PlayerRight.CavalryTemplar,
        IsCivil           = false,
        Upkeep            = 85,
        Soldiers          = 5,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },
    [Entities.CU_TemplarLeaderPoleArm1]            = {
        Button            = "Buy_LeaderSpear",
        Right             = PlayerRight.SpearTemplar,
        IsCivil           = false,
        Upkeep            = 45,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Huscarls --

    [Entities.CU_BanditLeaderSword2]        = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BerserkWeak,
        IsCivil           = false,
        Upkeep            = 50,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderSword1]        = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BerserkStrong,
        IsCivil           = false,
        Upkeep            = 75,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Bandits --

    [Entities.CU_BanditLeaderSword3]        = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BanditSword,
        IsCivil           = false,
        Upkeep            = 30,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderBow1]          = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.BanditBow,
        IsCivil           = false,
        Upkeep            = 20,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        Right             = PlayerRight.CavalryBandit,
        IsCivil           = false,
        Upkeep            = 65,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Barbarians --

    [Entities.CU_Barbarian_LeaderClub2]     = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BarbarianWeak,
        IsCivil           = false,
        Upkeep            = 45,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_Barbarian_LeaderClub1]     = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BarbarianStrong,
        IsCivil           = false,
        Upkeep            = 60,
        Soldiers          = 9,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith1, Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Black Knights --

    [Entities.CU_BlackKnight_LeaderMace2]   = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BlackKnightWeak,
        IsCivil           = false,
        Upkeep            = 35,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BlackKnight_LeaderMace1]   = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BlackKnightStrong,
        IsCivil           = false,
        Upkeep            = 55,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Shrouded --

    [Entities.CU_Evil_LeaderBearman1]       = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.Bearman,
        IsCivil           = false,
        Upkeep            = 50,
        Soldiers          = 16,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.CU_Evil_LeaderSkirmisher1]    = {
        Button            = "Buy_LeaderBow",
        Right             = PlayerRight.Skirmisher,
        IsCivil           = false,
        Upkeep            = 50,
        Soldiers          = 16,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Kerberos Bodyguard --

    [Entities.CU_BlackKnight]              = {
        Button            = "Buy_LeaderSword",
        Right             = PlayerRight.BlackKnightGuard,
        IsCivil           = false,
        Upkeep            = 0,
        Soldiers          = 3,
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
Stronghold.Unit.Config.LeaderToSoldierMap = {
    -- Axe
    [Entities.CU_BanditLeaderSword1] = Entities.CU_BanditSoldierSword1,
    [Entities.CU_BanditLeaderSword2] = Entities.CU_BanditSoldierSword2,
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
    [Entities.CU_BanditLeaderSword3] = Entities.CU_BanditSoldierSword3,
    [Entities.PU_LeaderSword1] = Entities.PU_SoldierSword1,
    [Entities.PU_LeaderSword2] = Entities.PU_SoldierSword2,
    [Entities.PU_LeaderSword3] = Entities.PU_SoldierSword3,
    [Entities.PU_LeaderSword4] = Entities.PU_SoldierSword4,
};

