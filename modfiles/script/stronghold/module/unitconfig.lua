--- 
--- Unit config
---

Stronghold = Stronghold or {};

Stronghold.UnitConfig = Stronghold.UnitConfig or {
    Data = {},
};

function Stronghold.UnitConfig:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {
            Config = CopyTable(Stronghold.UnitConfig.Units),
        };
    end
end

function Stronghold.UnitConfig:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --

function Stronghold.UnitConfig:GetConfig(_Type, _PlayerID)
    if not _PlayerID or not self.Data[_PlayerID] then
        return self.Units[_Type];
    end
    return Stronghold.Recruitment.Data[_PlayerID].Config[_Type];
end

Stronghold.UnitConfig.Units = {
    -- Spear Tier 1 --
    [Entities.PU_LeaderPoleArm1]            = {
        Button            = "Buy_LeaderSpear",
        TextNormal        = {
            de = "{grey}Speerträger{cr}{white}Billige Truppen, die höchstens als Kanonenfutter taugen.{cr}",
            en = "{grey}Spearman{cr}{white}Cheap troops, good only as cannon fodder.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Soldiers          = 12,
        Costs             = {
            [1] = {0, 50, 0, 40, 0, 0, 0},
            [2] = {0, 5, 0, 10, 0, 0, 0},
        },
        Rank              = 1,
        Allowed           = true,
        Upkeep            = 15,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    -- Spear Tier 2 --
    [Entities.PU_LeaderPoleArm2]            = {
        Button            = "Buy_LeaderSpear",
        TextNormal        = {
            de = "{grey}Lanzenträger{cr}{white}Leichte Speerträger, die nur gegen Kavallerie eingesetzt werden sollten.{cr}",
            en = "{grey}Lancer{cr}{white}Light spearmen that should only be used against cavalry.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Sägemühle",
            en = "@color:244,184,0 requires:{white} #Rank#, Sawmill",
        },
        Soldiers          = 12,
        Costs             = {
            [1] = {5, 65, 0, 50, 0, 0, 0},
            [2] = {0, 5, 0, 15, 0, 0, 0},
        },
        Rank              = 2,
        Allowed           = true,
        Upkeep            = 20,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    -- Spear Tier 3 --
    [Entities.PU_LeaderPoleArm3]            = {
        Button            = "Buy_LeaderSpear",
        TextNormal        = {
            de = "{grey}Landsknecht{cr}{white}Diese Männer führen eine Streitlanze gegen Kavallerie, können aber auch Schwertkämpfer beschäftigen.{cr}",
            en = "{grey}Battle Lancer{cr}{white}Diese Männer führen eine Streitlanze gegen Kavallerie, können aber auch Schwertkämpfer beschäftigen.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Garnison, Sägemühle",
            en = "@color:244,184,0 requires:{white} #Rank#, Garnison, Sawmill",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {10, 150, 0, 70, 0, 10, 0},
            [2] = {0, 65, 0, 40, 0, 5, 0},
        },
        Rank              = 3,
        Allowed           = true,
        Upkeep            = 40,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    -- Spear Tier 4 --
    [Entities.PU_LeaderPoleArm4]            = {
        Button            = "Buy_LeaderSpear",
        TextNormal        = {
            de = "{grey}Hellebardier{cr}{white}Hellebardiere sind stark gegen Kavallerie und können dank guter Rüstung die Position lange halten.{cr}",
            en = "{grey}Halberdier{cr}{white}Halberdiers are strong against cavalry and can hold their position for a long time thanks to good armor.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Garnison, Sägewerk",
            en = "@color:244,184,0 requires:{white} #Rank#, Garnison, Lumber Mill",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {15, 200, 0, 80, 0, 20, 0},
            [2] = {0, 75, 0, 45, 0, 10, 0},
        },
        Rank              = 3,
        Allowed           = true,
        Upkeep            = 50,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Sword Tier 1 --
    [Entities.PU_LeaderSword1]              = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}Kurzschwertkämpfer{cr}{white}Statt mit ihrem \"Schwert\" könnten diese Männer genauso gut mit einem Buttermesser in die Schlacht ziehen.{cr}",
            en = "{grey}Shortswordman{cr}{white}{cr}Instead of using their \"sword\" these men might as well go into battle with a butter knife.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Soldiers          = 12,
        Costs             = {
            [1] = {6, 100, 0, 0, 0, 50, 0},
            [2] = {0, 15, 0, 0, 0, 10, 0},
        },
        Rank              = 2,
        Allowed           = true,
        Upkeep            = 20,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderSword2]        = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}Wegelagerer{cr}{white}Räuber und Wegelagerer, die ihre Äxte gut gegen andere Infanterie einsetzen können.{cr}",
            en = "{grey}Highwayman{cr}{white}Raiders and highwaymen who are good at using their axes against other infantry.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Schmiede",
            en = "@color:244,184,0 requires:{white} #Rank#, Smithy",
        },
        Soldiers          = 12,
        Costs             = {
            [1] = {7, 120, 0, 0, 0, 50, 0},
            [2] = {0, 15, 0, 0, 0, 10, 0},
        },
        Rank              = 2,
        Allowed           = true,
        Upkeep            = 30,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_Barbarian_LeaderClub2]     = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}Barbarenkrieger{cr}{white}Barbarenkrieger sind effektiv gegen gepanzerte Truppen und ihre Nagelkeulen können tiefe Wunden reißen.{cr}",
            en = "{grey}Barbarian Warrior{cr}{white}Barbarian warriors are effective against armored troops, and their spiked clubs can inflict deep wounds.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Soldiers          = 12,
        Costs             = {
            [1] = {8, 110, 0, 20, 0, 20, 0},
            [2] = {0, 20, 0, 5, 0, 10, 0},
        },
        Rank              = 2,
        Allowed           = true,
        Upkeep            = 30,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BlackKnight_LeaderMace2]   = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}Schwarzer Ritter{cr}{white}Diese Truppen setzt man am Besten gegen gepanzerte Truppen ein.{cr}",
            en = "{grey}Black Knight{cr}{white}{cr}These troops are best used against armored troops.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Schmiede",
            en = "@color:244,184,0 requires:{white} #Rank#, Smithy",
        },
        Soldiers          = 12,
        Costs             = {
            [1] = {7, 100, 0, 0, 0, 40, 0},
            [2] = {0, 25, 0, 0, 0, 15, 0},
        },
        Rank              = 2,
        Allowed           = true,
        Upkeep            = 30,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    -- Sword Tier 2 --
    [Entities.PU_LeaderSword2]              = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}Breitschwertkämpfer{cr}{white}Breitschwertkämpfer können gegen Speerträger und Fernkämpfer eingesetzt werden.{cr}",
            en = "{grey}Broadswordman{cr}{white}{cr}Broadswordsmen can be used against spearmen and ranged troops.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Schmiede",
            en = "@color:244,184,0 requires:{white} #Rank#, Smithy",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {10, 150, 0, 0, 0, 60, 0},
            [2] = {0, 50, 0, 0, 0, 35, 0},
        },
        Rank              = 4,
        Allowed           = true,
        Upkeep            = 35,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith1, Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    -- Sword Tier 3 --
    [Entities.PU_LeaderSword3]              = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}Langschwertkämpfer{cr}{white}Erfahrene und gut ausgerüstete Soldaten, die mit Infanterie kurzen Prozess machen.{cr}",
            en = "{grey}Longswordman{cr}{white}Experienced and well-equipped soldiers who make short work of infantry.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Garnison, Grobschmiede",
            en = "@color:244,184,0 requires:{white} #Rank#, Garnison, Blacksmith",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {20, 230, 0, 0, 0, 70, 0},
            [2] = {0, 60, 0, 0, 0, 45, 0},
        },
        Rank              = 5,
        Allowed           = true,
        Upkeep            = 60,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.CU_Barbarian_LeaderClub1]     = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}Elitekrieger der Barbaren{cr}{white}Diese Elitekrieger sind gut gegen gepanzerte Truppen und können hohen kritischen Schaden austeilen.{cr}",
            en = "{grey}Elite of the Barbarians{cr}{white}These elite warriors are good against armored troops and can deal high critical damage.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Garnison, Schmiede",
            en = "@color:244,184,0 requires:{white} #Rank#, Garnison, Smithy",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {22, 200, 0, 40, 0, 30, 0},
            [2] = {0, 55, 0, 35, 0, 15, 0},
        },
        Rank              = 5,
        Allowed           = true,
        Upkeep            = 40,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith1, Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.CU_BlackKnight_LeaderMace1]   = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}Edler Schwarzer Ritter{cr}{white}Die edlen schwarzen Ritter können mit ihren Keulen Rüstungen verbeulen und ein wahrer Albtraum werden.{cr}",
            en = "{grey}Black Knight Elite{cr}{white}The noble black knights can dent armor with their clubs and become a real nightmare.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Garnison, Grobschmiede",
            en = "@color:244,184,0 requires:{white} #Rank#, Garnison, Blacksmith",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {18, 200, 0, 0, 0, 70, 0},
            [2] = {0, 65, 0, 0, 0, 45, 0},
        },
        Rank              = 5,
        Allowed           = true,
        Upkeep            = 35,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.CU_BanditLeaderSword1]        = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}Banditenkrieger{cr}{white}Diese erfahrenen Gesetzlosen schwingen die Axt und schnetzeln sich durch feindliche Infanterie.{cr}",
            en = "{grey}Bandit Warrior{cr}{white}These experienced outlaws wield their ax and slice through the lines of the enemy.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Grobschmiede",
            en = "@color:244,184,0 requires:{white} #Rank#, Blacksmith",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {18, 200, 0, 0, 0, 65, 0},
            [2] = {0, 60, 0, 0, 0, 40, 0},
        },
        Rank              = 5,
        Allowed           = true,
        Upkeep            = 35,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.CU_Evil_LeaderBearman1]       = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}Bärenmensch{cr}{white}Fanatiker in rituellen Bärenkostümen, die keine Gnade für gewöhnliche Infantrie aufbringen wird.{cr}",
            en = "{grey}Bearman{cr}{white}Fanatics in ritual bear costumes who will show no mercy to ordinary infantry.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Sägemühle",
            en = "@color:244,184,0 requires:{white} #Rank#, Sawmill",
        },
        Soldiers          = 16,
        Costs             = {
            [1] = {12, 70, 0, 180, 0, 40, 0},
            [2] = {0, 15, 0, 70, 0, 25, 0},
        },
        Rank              = 4,
        Allowed           = true,
        Upkeep            = 45,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    -- Sword Tier 4 --
    [Entities.PU_LeaderSword4]              = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}Bastardschwertkämpfer{cr}{white}Bastardschwertkämpfer sind die Elite unter den Nahkämpfern und stark gegen alle anderen Fußsolldaten.{cr}",
            en = "{grey}Elite Swordman{cr}{white}{cr}Elite Swordsmen are the best of the best and strong against all other foot soldiers.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Garnison, Feinschmiede",
            en = "@color:244,184,0 requires:{white} #Rank#, Garnison, Finishing Smithy",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {30, 275, 0, 0, 0, 85, 0},
            [2] = {0, 75, 0, 0, 0, 60, 0},
        },
        Rank              = 5,
        Allowed           = true,
        Upkeep            = 75,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },

    -- Bow Tier 1 --
    [Entities.PU_LeaderBow1]                = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{grey}Kurzbogenschütze{cr}{white}Diese leichten Bogenschützen sind in großen Gruppen effektiv gegen leichte Infanterie.{cr}",
            en = "{grey}Shortbowman{cr}{white}These light archers are effective against light infantry in large groups.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Soldiers          = 12,
        Costs             = {
            [1] = {4, 90, 0, 60, 0, 0, 0},
            [2] = {0, 10, 0, 10, 0, 0, 0},
        },
        Allowed           = true,
        Rank              = 2,
        Upkeep            = 15,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderBow1]          = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{grey}Banditenbogenschütze{cr}{white}Diese Bogenschützen sind den Kampf gewöhnt und darum excellent gegen leicht gepanzerte Truppen.{cr}",
            en = "{grey}Outlaw Bowman{cr}{white}These archers are used to combat and are therefore excellent against lightly armored troops.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Sägemühle",
            en = "@color:244,184,0 requires:{white} #Rank#, Sawmill",
        },
        Soldiers          = 12,
        Costs             = {
            [1] = {5, 80, 0, 55, 0, 0, 0},
            [2] = {0, 15, 0, 15, 0, 0, 0},
        },
        Allowed           = true,
        Rank              = 2,
        Upkeep            = 20,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },
    -- Bow Tier 2 --
    [Entities.PU_LeaderBow2]                = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{grey}Langbogenschütze{cr}{white}Diese professionellen Bogenschützen sind effektiv gegen andere leicht gepanterte Truppen.{cr}",
            en = "{grey}Longbowman{cr}{white}These professional archers are effective against other lightly armored troops.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Sägemühle",
            en = "@color:244,184,0 requires:{white} #Rank#, Sawmill",
        },
        Soldiers          = 12,
        Costs             = {
            [1] = {6, 110, 0, 70, 0, 0, 0},
            [2] = {0, 20, 0, 20, 0, 0, 0},
        },
        Allowed           = true,
        Rank              = 2,
        Upkeep            = 20,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    -- Bow Tier 3 --
    [Entities.PU_LeaderBow3]                = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{grey}Armbrustschütze{cr}{white}Armbrustschützen können viel Schaden austeilen, brauchen aber lange um nachzuladen.{cr}",
            en = "{grey}Crossbowman{cr}{white}Crossbowmen can deal a lot of damage but take a long time to reload.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Schießanlage, Sägemühle",
            en = "@color:244,184,0 requires:{white} #Rank#, Archery, Sawmill",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {12, 250, 0, 35, 0, 35, 0},
            [2] = {0, 60, 0, 15, 0, 25, 0},
        },
        Allowed           = true,
        Rank              = 3,
        Upkeep            = 50,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.CU_Evil_LeaderSkirmisher1]    = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{grey}Speerwerfer{cr}{white}Nicht weniger fanatisch als die Bärenmenschen sind auch die Speerwerfer stark gegen gewöhnliche Truppen.{cr}",
            en = "{grey}Javelin Thrower{cr}{white}No less fanatical than the bearmen, the javelin throwers are strong against common troops.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Sägemühle",
            en = "@color:244,184,0 requires:{white} #Rank#, Sawmill",
        },
        Soldiers          = 16,
        Costs             = {
            [1] = {8, 100, 0, 180, 0, 0, 0},
            [2] = {0, 30, 0, 70, 0, 0, 0},
        },
        Allowed           = true,
        Rank              = 4,
        Upkeep            = 35,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    -- Bow Tier 4 --
    [Entities.PU_LeaderBow4]                = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{grey}Arbaleastschütze{cr}{white}Die hochmittelalterliche Armbrust ist sehr stark gegen Infanterie aber auch sehr langsam.{cr}",
            en = "{grey}Heavy Crossbowman{cr}{white}The high medieval crossbow is very strong against foot soldiers but also very slow.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Schießanlage, Sägewerk",
            en = "@color:244,184,0 requires:{white} #Rank#, Archery, Lumber Mill",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {16, 300, 0, 40, 0, 45, 0},
            [2] = {0, 75, 0, 20, 0, 35, 0},
        },
        Allowed           = true,
        Rank              = 6,
        Upkeep            = 50,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Rifle Tier 1 --
    [Entities.PU_LeaderRifle1]              = {
        Button            = "Buy_LeaderRifle",
        TextNormal        = {
            de = "{grey}Leichter Scharfschütze{cr}{white}Scharfschützen sind gut gegen alle anderen Truppen, werden im Nahkampf jedoch niedergemetzelt.{cr}",
            en = "{grey}Light Sharpshooter{cr}{white}{cr}Sharpshooters are good to use against all other troops, but should stay out of close combat.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Büchsenmacher",
            en = "@color:244,184,0 requires:{white} #Rank#, Gunsmith's Shop",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {35, 250, 0, 20, 0, 0, 50},
            [2] = {0, 60, 0, 20, 0, 0, 30},
        },
        Allowed           = true,
        Rank              = 5,
        Upkeep            = 50,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop1, Entities.PB_GunsmithWorkshop2},
    },
    -- Rifle Tier 1 --
    [Entities.PU_LeaderRifle2]              = {
        Button            = "Buy_LeaderRifle",
        TextNormal        = {
            de = "{grey}Schwerer Scharfschütze{cr}{white}Die schweren Scharfschützen haben Feuerrate gegen Schaden gegen alle anderen Truppentypen eingetauscht.{cr}",
            en = "{grey}Heavy Sharpshooter{cr}{white}The heavy sharpshooters traded a higher firerate for collosal damage against all other troop types.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Schießanlage, Büchsenmanufaktur",
            en = "@color:244,184,0 requires:{white} #Rank#, Archery, Gun Factory",
        },
        Soldiers          = 6,
        Costs             = {
            [1] = {50, 300, 0, 0, 0, 20, 60},
            [2] = {0, 70, 0, 0, 0, 20, 30},
        },
        Allowed           = true,
        Rank              = 7,
        Upkeep            = 80,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop2},
    },

    -- Cavalry Tier 1 --
    [Entities.PU_LeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        TextNormal        = {
            de = "{grey}Berittener Bogenschütze{cr}{white}Berittene Bogenschützen sind schnell und stark gegen leichte Truppen.{cr}",
            en = "{grey}Mounted Archer{cr}{white}Mounted archers are fast and strong against light troops.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Sägewerk",
            en = "@color:244,184,0 requires:{white} #Rank#, Lumber Mill",
        },
        Soldiers          = 5,
        Costs             = {
            [1] = {12, 200, 0, 40, 0, 20, 0},
            [2] = {0, 60, 0, 15, 0, 5, 0},
        },
        Allowed           = true,
        Rank              = 4,
        Upkeep            = 25,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },
    -- Cavalry Tier 2 --
    [Entities.PU_LeaderCavalry2]            = {
        Button            = "Buy_LeaderCavalryLight",
        TextNormal        = {
            de = "{grey}Berittener Armbrustschütze{cr}{white}Zu Pferde sind Armbrustschützen nicht weniger tödlich gegen Infanterie, dafür aber schneller zu Fuß.{cr}",
            en = "{grey}Mounted Crossbowman{cr}{white}Mounted crossbowmen are no less deadly against infantry, but are faster on foot.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Sägewerk",
            en = "@color:244,184,0 requires:{white} #Rank#, Lumber Mill",
        },
        Soldiers          = 5,
        Costs             = {
            [1] = {24, 250, 0, 20, 0, 50, 0},
            [2] = {0, 80, 0, 20, 0, 10, 0},
        },
        Allowed           = true,
        Rank              = 4,
        Upkeep            = 40,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },
    -- Heavy Cavalry Tier 1 --
    [Entities.PU_LeaderHeavyCavalry1]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        TextNormal        = {
            de = "{grey}Berittener Schwertkämpfer{cr}{white}Die berittenen Schwertkämpfer können feindliche Infanterie - besonders Schwertkämpfer - auseinander nehmen.{cr}",
            en = "{grey}Mounted Swordman{cr}{white}The mounted swordsmen can slice apart enemy infantry very well. Especially swordsmen will fall to their hands.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Reitanlage, Feinschmiede",
            en = "@color:244,184,0 requires:{white} #Rank#, Stables, Finishing Smithy",
        },
        Soldiers          = 5,
        Costs             = {
            [1] = {40, 300, 0, 0, 0, 90, 0},
            [2] = {0, 100, 0, 0, 0, 30, 0},
        },
        Allowed           = true,
        Rank              = 6,
        Upkeep            = 70,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },
    -- Heavy Cavalry Tier 2 --
    [Entities.PU_LeaderHeavyCavalry2]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        TextNormal        = {
            de = "{grey}Berittener Axtkämpfer{cr}{white}Diese brutalen Krieger schwingen zu Pferde die Axt und hacken die feindlichen Truppen in Stücke.{cr}",
            en = "{grey}Mounted Axeman{cr}{white}These brutal warriors wield axes on horseback and enjoy choping enemy troops to pieces.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Reitanlage, Feinschmiede",
            en = "@color:244,184,0 requires:{white} #Rank#, Stables, Finishing Smithy",
        },
        Soldiers          = 5,
        Costs             = {
            [1] = {50, 400, 0, 0, 0, 110, 0},
            [2] = {0, 120, 0, 0, 0, 40, 0},
        },
        Allowed           = true,
        Rank              = 6,
        Upkeep            = 90,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },

    -- Cannons --
    [Entities.PV_Cannon1]                   = {
        Button            = "Buy_Cannon1",
        TextNormal        = {
            de = "{grey}Bombarde{cr}{white}Die Bombarde ist stark gegen Einheiten.{cr}",
            en = "{grey}Bombarde{cr}{white}The bombard is strong against units.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Kanonengießerei, Alchemistenhütte",
            en = "@color:244,184,0 requires:{white} #Rank#, Foundry, Alchemist's Hut",
        },
        Costs             = {
            [1] = {25, 350, 0, 50, 0, 250, 100},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Allowed           = true,
        Rank              = 4,
        Upkeep            = 30,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon2]                   = {
        Button            = "Buy_Cannon2",
        TextNormal        = {
            de = "{grey}Bronzekanone{cr}{white}Die Bronzekanone ist stark gegen Gebäude.{cr}",
            en = "{grey}Bronze Cannon{cr}{white}The bronze cannon is strong against buildings.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Kanonengießerei, Alchemistenhütte",
            en = "@color:244,184,0 requires:{white} #Rank#, Foundry, Alchemist's Hut",
        },
        Costs             = {
            [1] = {25, 350, 0, 50, 0, 100, 250},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Allowed           = true,
        Rank              = 4,
        Upkeep            = 50,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon3]                   = {
        Button            = "Buy_Cannon3",
        TextNormal        = {
            de = "{grey}Eisenkanone{cr}{white}Eine schwere Kanone, die gegen Einheiten eingesetzt wird.{cr}",
            en = "{grey}Iron Cannon{cr}{white}A heavy cannon used against military units.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Kanonenmanufaktur, Laboratorium",
            en = "@color:244,184,0 requires:{white} #Rank#, Cannon Factory, Laboratory",
        },
        Costs             = {
            [1] = {50, 950, 0, 100, 0, 600, 450},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Allowed           = true,
        Rank              = 7,
        Upkeep            = 100,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon4]                   = {
        Button            = "Buy_Cannon4",
        TextNormal        = {
            de = "{grey}Belagerungskanone{cr}{white}Diese schwere Kanone ist besonders effizient bei der Zerstörung von Gebäuden.{cr}",
            en = "{grey}Siege Cannon{cr}{white}This heavy cannon is particularly efficient at destroying buildings.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Kanonenmanufaktur, Laboratorium",
            en = "@color:244,184,0 requires:{white} #Rank#, Cannon Factory, Laboratory",
        },
        Costs             = {
            [1] = {50, 950, 0, 100, 0, 450, 600},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Allowed           = true,
        Rank              = 7,
        Upkeep            = 120,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },

    -- Special units
    [Entities.PU_Scout]                     = {
        Button            = "Buy_Scout",
        TextNormal        = {
            de = "{grey}Kundschafter{cr}{white}Kundschafter können für Euch Informationen beschaffen, Rohstoffe finden und Gebiete aufdecken.{cr}",
            en = "{grey}Scout{cr}{white}{cr}Scouts can gather information for you, find raw materials and uncover areas.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Costs             = {
            [1] = {0, 150, 0, 50, 0, 50, 0},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Allowed           = true,
        IsCivil           = true,
        Rank              = 2,
        Upkeep            = 10,
        Turns             = 150,
        Places            = 1,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Tavern1, Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },
    [Entities.PU_Thief]                     = {
        Button            = "Buy_Thief",
        TextNormal        = {
            de = "{grey}Dieb{cr}{white}Mancher Krimineller arbeitet lieber für Euch, als Euch zu beklauen. Lehrt ihnen später den Umgang mit Sprengstoff.{cr}",
            en = "{grey}Thief{cr}{white}Some criminals would rather work for you than steal from you. Teaches them later how to use explosives.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#, Wirtshaus",
            en = "@color:244,184,0 requires:{white} #Rank#, Inn",
        },
        Costs             = {
            [1] = {30, 500, 0, 0, 0, 100, 100},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Allowed           = true,
        IsCivil           = true,
        Rank              = 4,
        Upkeep            = 50,
        Turns             = 500,
        Places            = 5,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },
    [Entities.PU_Serf]                      = {
        Button            = "Buy_Serf",
        TextNormal        = {
            de = "{grey}Leibeigener{cr}{white}{cr}",
            en = "{grey}Serf{cr}{white}{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Costs             = {
            [1] = {0, 50, 0, 0, 0, 0, 0},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Rank              = 1,
        Allowed           = true,
        IsCivil           = true,
        Upkeep            = 0,
        Turns             = 25,
        Places            = 1,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Headquarters1, Entities.PB_Headquarters2, Entities.PB_Headquarters3},
        ProviderBuilding  = {},
    },

    -- Kerberos (Bodyguard passive skill)
    [Entities.CU_BlackKnight]              = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{grey}ERROR{cr}{white}YOU SHOULD NEVER SEE THIS!{cr}",
            en = "{grey}ERROR{cr}{white}YOU SHOULD NEVER SEE THIS!{cr}",
        },
        TextDisabled      = {
            de = "{grey}ERROR{cr}{white}YOU SHOULD NEVER SEE THIS!{cr} #Rank#",
            en = "{grey}ERROR{cr}{white}YOU SHOULD NEVER SEE THIS!{cr} #Rank#",
        },
        Costs             = {
            [1] = {0, 0, 0, 0, 0, 0, 0},
            [2] = {15, 300, 0, 0, 0, 0, 0},
        },
        Rank              = 5,
        Allowed           = true,
        Upkeep            = 0,
        Turns             = 0,
        Places            = 1,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
};

