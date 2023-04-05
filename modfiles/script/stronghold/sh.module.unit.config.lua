--- 
--- Config for Units
--- 

Stronghold.Unit.Config = {
    -- Spear --

    [Entities.PU_LeaderPoleArm1]            = {
        Button            = "Buy_LeaderSpear",
        TextNormal        = {
            de = "{cr}{white}Ihr Götter, welch Memmen befehlen unsere Schar? Zum Krieg zusammengekehrt, das Gerümpel des Landes.{cr}",
            en = "{cr}{white}Ye gods, what wretches command our troop? Sweeping together for the war, the junk of the country.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Costs             = {
            [1] = {0, 60, 0, 50, 0, 0, 0},
            [2] = {0, 5, 0, 10, 0, 0, 0},
        },
        Right             = PlayerRight.LeaderPoleArm1,
        IsCivil           = false,
        Upkeep            = 15,
        Turns             = 75,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderPoleArm2]            = {
        Button            = "Buy_LeaderSpear",
        TextNormal        = {
            de = "{cr}{white}Leichte Speerträger, die nur gegen Kavallerie eingesetzt werden sollten.{cr}",
            en = "{cr}{white}Light spearmen that should only be used against cavalry.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Sägemühle",
            en = "@color:244,184,0 requires:{white}#Rank#, Sawmill",
        },
        Costs             = {
            [1] = {5, 75, 0, 55, 0, 10, 0},
            [2] = {0, 10, 0, 10, 0, 5, 0},
        },
        Right             = PlayerRight.LeaderPoleArm2,
        IsCivil           = false,
        Upkeep            = 20,
        Turns             = 100,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderPoleArm3]            = {
        Button            = "Buy_LeaderSpear",
        TextNormal        = {
            de = "{cr}{white}Diese Männer führen eine Streitlanze gegen Kavallerie, können aber auch Schwertkämpfer beschäftigen.{cr}",
            en = "{cr}{white}Diese Männer führen eine Streitlanze gegen Kavallerie, können aber auch Schwertkämpfer beschäftigen.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Garnison, Sägemühle",
            en = "@color:244,184,0 requires:{white}#Rank#, Garnison, Sawmill",
        },
        Costs             = {
            [1] = {10, 170, 0, 60, 0, 15, 0},
            [2] = {0, 65, 0, 35, 0, 5, 0},
        },
        Right             = PlayerRight.LeaderPoleArm3,
        IsCivil           = false,
        Upkeep            = 40,
        Turns             = 150,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderPoleArm4]            = {
        Button            = "Buy_LeaderSpear",
        TextNormal        = {
            de = "{cr}{white}Hellebardiere sind stark gegen Kavallerie und können dank guter Rüstung die Position lange halten.{cr}",
            en = "{cr}{white}Halberdiers are strong against cavalry and can hold their position for a long time thanks to good armor.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Garnison, Sägewerk",
            en = "@color:244,184,0 requires:{white}#Rank#, Garnison, Lumber Mill",
        },
        Costs             = {
            [1] = {10, 235, 0, 75, 0, 35, 0},
            [2] = {0, 78, 0, 40, 0, 12, 0},
        },
        Right             = PlayerRight.PU_LeaderPoleArm4,
        IsCivil           = false,
        Upkeep            = 45,
        Turns             = 150,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Sword  --

    [Entities.PU_LeaderSword1]              = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{cr}{white}Statt mit ihrem \"Schwert\" könnten diese Männer genauso gut mit einem Buttermesser in die Schlacht ziehen.{cr}",
            en = "{cr}{white}{cr}Instead of using their \"sword\" these men might as well go into battle with a butter knife.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Costs             = {
            [1] = {6, 100, 0, 0, 0, 50, 0},
            [2] = {0, 20, 0, 0, 0, 15, 0},
        },
        Right             = PlayerRight.LeaderSword1,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 100,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderSword2]              = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{cr}{white}Breitschwertkämpfer können gegen Speerträger und Fernkämpfer eingesetzt werden.{cr}",
            en = "{cr}{white}{cr}Broadswordsmen can be used against spearmen and ranged troops.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Schmiede",
            en = "@color:244,184,0 requires:{white}#Rank#, Smithy",
        },
        Costs             = {
            [1] = {10, 170, 0, 0, 0, 75, 0},
            [2] = {0, 50, 0, 0, 0, 35, 0},
        },
        Right             = PlayerRight.LeaderSword2,
        IsCivil           = false,
        Upkeep            = 40,
        Turns             = 125,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith1, Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderSword3]              = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{cr}{white}Erfahrene und gut ausgerüstete Soldaten, die mit Infanterie kurzen Prozess machen.{cr}",
            en = "{cr}{white}Experienced and well-equipped soldiers who make short work of infantry.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Garnison, Grobschmiede",
            en = "@color:244,184,0 requires:{white}#Rank#, Garnison, Blacksmith",
        },
        Costs             = {
            [1] = {20, 230, 0, 0, 0, 95, 0},
            [2] = {0, 65, 0, 0, 0, 50, 0},
        },
        Right             = PlayerRight.LeaderSword3,
        IsCivil           = false,
        Upkeep            = 60,
        Turns             = 150,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderSword4]              = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{cr}{white}Bastardschwertkämpfer sind die Elite unter den Nahkämpfern und stark gegen alle anderen Fußsolldaten.{cr}",
            en = "{cr}{white}{cr}Elite Swordsmen are the best of the best and strong against all other foot soldiers.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Garnison, Feinschmiede",
            en = "@color:244,184,0 requires:{white}#Rank#, Garnison, Finishing Smithy",
        },
        Costs             = {
            [1] = {20, 285, 0, 0, 0, 100, 0},
            [2] = {0, 85, 0, 0, 0, 65, 0},
        },
        Right             = PlayerRight.LeaderSword4,
        IsCivil           = false,
        Upkeep            = 65,
        Turns             = 150,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },

    -- Bow --

    [Entities.PU_LeaderBow1]                = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{cr}{white}Diese leichten Bogenschützen sind in großen Gruppen effektiv gegen leichte Infanterie.{cr}",
            en = "{cr}{white}These light archers are effective against light infantry in large groups.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Costs             = {
            [1] = {4, 90, 0, 60, 0, 0, 0},
            [2] = {0, 10, 0, 10, 0, 0, 0},
        },
        Right             = PlayerRight.LeaderBow1,
        IsCivil           = false,
        Upkeep            = 20,
        Turns             = 75,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },
    [Entities.PU_LeaderBow2]                = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{cr}{white}Diese professionellen Bogenschützen sind effektiv gegen andere leicht gepanterte Truppen.{cr}",
            en = "{cr}{white}These professional archers are effective against other lightly armored troops.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Sägemühle",
            en = "@color:244,184,0 requires:{white}#Rank#, Sawmill",
        },
        Costs             = {
            [1] = {6, 130, 0, 75, 0, 0, 0},
            [2] = {0, 15, 0, 15, 0, 0, 0},
        },
        Right             = PlayerRight.LeaderBow2,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 100,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderBow3]                = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{cr}{white}Armbrustschützen können viel Schaden austeilen, brauchen allergins Schutz durch Nahkämpfer.{cr}",
            en = "{cr}{white}Crossbowmen can deal a lot of damage but need to be guarded with melee troops.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Schießanlage, Sägemühle",
            en = "@color:244,184,0 requires:{white}#Rank#, Archery, Sawmill",
        },
        Costs             = {
            [1] = {12, 230, 0, 35, 0, 45, 0},
            [2] = {0, 65, 0, 18, 0, 32, 0},
        },
        Right             = PlayerRight.LeaderBow3,
        IsCivil           = false,
        Upkeep            = 45,
        Turns             = 150,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderBow4]                = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{cr}{white}Die hochmittelalterliche Armbrust ist sehr stark gegen Infanterie.{cr}",
            en = "{cr}{white}The high medieval crossbow is very strong against foot soldiers.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Schießanlage, Sägewerk",
            en = "@color:244,184,0 requires:{white}#Rank#, Archery, Lumber Mill",
        },
        Costs             = {
            [1] = {16, 300, 0, 40, 0, 55, 0},
            [2] = {0, 80, 0, 25, 0, 40, 0},
        },
        Right             = PlayerRight.LeaderBow4,
        IsCivil           = false,
        Upkeep            = 50,
        Turns             = 150,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Rifle --

    [Entities.PU_LeaderRifle1]              = {
        Button            = "Buy_LeaderRifle",
        TextNormal        = {
            de = "{cr}{white}Scharfschützen sind gut gegen alle anderen Truppen, werden im Nahkampf jedoch niedergemetzelt.{cr}",
            en = "{cr}{white}{cr}Sharpshooters are good to use against all other troops, but should stay out of close combat.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Büchsenmacher",
            en = "@color:244,184,0 requires:{white}#Rank#, Gunsmith's Shop",
        },
        Costs             = {
            [1] = {28, 340, 0, 20, 0, 0, 60},
            [2] = {0, 75, 0, 10, 0, 0, 35},
        },
        Right             = PlayerRight.LeaderRifle1,
        IsCivil           = false,
        Upkeep            = 70,
        Turns             = 150,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop1, Entities.PB_GunsmithWorkshop2},
    },
    [Entities.PU_LeaderRifle2]              = {
        Button            = "Buy_LeaderRifle",
        TextNormal        = {
            de = "{cr}{white}Die Musketenschützen haben Feuerrate gegen Schaden gegen alle anderen Truppentypen eingetauscht.{cr}",
            en = "{cr}{white}The Musketeers traded a higher firerate for collosal damage against all other troop types.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Schießanlage, Büchsenmanufaktur",
            en = "@color:244,184,0 requires:{white}#Rank#, Archery, Gun Factory",
        },
        Costs             = {
            [1] = {36, 420, 0, 0, 0, 35, 75},
            [2] = {0, 85, 0, 0, 0, 15, 35},
        },
        Right             = PlayerRight.LeaderRifle2,
        IsCivil           = false,
        Upkeep            = 90,
        Turns             = 200,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_GunsmithWorkshop2},
    },

    -- Cavalry --

    [Entities.PU_LeaderCavalry1]            = {
        Button            = "Buy_LeaderCavalryLight",
        TextNormal        = {
            de = "{cr}{white}Berittene Bogenschützen sind schnell und stark gegen leichte Truppen.{cr}",
            en = "{cr}{white}Mounted archers are fast and strong against light troops.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Sägewerk",
            en = "@color:244,184,0 requires:{white}#Rank#, Lumber Mill",
        },
        Costs             = {
            [1] = {12, 220, 0, 45, 0, 25, 0},
            [2] = {0, 65, 0, 20, 0, 10, 0},
        },
        Right             = PlayerRight.LeaderCavalry1,
        IsCivil           = false,
        Upkeep            = 50,
        Turns             = 125,
        Soldiers          = 5,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },
    [Entities.PU_LeaderCavalry2]            = {
        Button            = "Buy_LeaderCavalryLight",
        TextNormal        = {
            de = "{cr}{white}Zu Pferde sind Armbrustschützen nicht weniger tödlich gegen Infanterie, dafür aber schneller zu Fuß.{cr}",
            en = "{cr}{white}Mounted crossbowmen are no less deadly against infantry, but are faster on foot.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Sägewerk",
            en = "@color:244,184,0 requires:{white}#Rank#, Lumber Mill",
        },
        Costs             = {
            [1] = {12, 265, 0, 20, 0, 50, 0},
            [2] = {0, 80, 0, 20, 0, 10, 0},
        },
        Right             = PlayerRight.LeaderCavalry2,
        IsCivil           = false,
        Upkeep            = 60,
        Turns             = 125,
        Soldiers          = 5,
        RecruiterBuilding = {Entities.PB_Stable1, Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Sawmill2},
    },

    -- Heavy Cavalry --
    [Entities.PU_LeaderHeavyCavalry1]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        TextNormal        = {
            de = "{cr}{white}Die berittenen Schwertkämpfer können feindliche Infanterie - besonders Schwertkämpfer - auseinander nehmen.{cr}",
            en = "{cr}{white}The mounted swordsmen can slice apart enemy infantry very well. Especially swordsmen will fall to their hands.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Reitanlage, Feinschmiede",
            en = "@color:244,184,0 requires:{white}#Rank#, Stables, Finishing Smithy",
        },
        Costs             = {
            [1] = {40, 320, 0, 0, 0, 90, 0},
            [2] = {0, 100, 0, 0, 0, 30, 0},
        },
        Right             = PlayerRight.LeaderHeavyCavalry1,
        IsCivil           = false,
        Upkeep            = 70,
        Turns             = 200,
        Soldiers          = 5,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },
    [Entities.PU_LeaderHeavyCavalry2]       = {
        Button            = "Buy_LeaderCavalryHeavy",
        TextNormal        = {
            de = "{cr}{white}Diese brutalen Krieger schwingen zu Pferde die Axt und hacken die feindlichen Truppen in Stücke.{cr}",
            en = "{cr}{white}These brutal warriors wield axes on horseback and enjoy choping enemy troops to pieces.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Reitanlage, Feinschmiede",
            en = "@color:244,184,0 requires:{white}#Rank#, Stables, Finishing Smithy",
        },
        Costs             = {
            [1] = {40, 430, 0, 0, 0, 110, 0},
            [2] = {0, 120, 0, 0, 0, 40, 0},
        },
        Right             = PlayerRight.LeaderHeavyCavalry2,
        IsCivil           = false,
        Upkeep            = 80,
        Turns             = 200,
        Soldiers          = 5,
        RecruiterBuilding = {Entities.PB_Stable2},
        ProviderBuilding  = {Entities.PB_Blacksmith3},
    },

    -- Cannons --

    [Entities.PV_Cannon1]                   = {
        Button            = "Buy_Cannon1",
        TextNormal        = {
            de = "{cr}{white}Die Bombarde ist stark gegen Einheiten.{cr}",
            en = "{cr}{white}The bombard is strong against units.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Kanonengießerei, Alchemistenhütte",
            en = "@color:244,184,0 requires:{white}#Rank#, Foundry, Alchemist's Hut",
        },
        Costs             = {
            [1] = {25, 450, 0, 50, 0, 300, 150},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Cannon1,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 0,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon2]                   = {
        Button            = "Buy_Cannon2",
        TextNormal        = {
            de = "{cr}{white}Die Bronzekanone ist stark gegen Gebäude.{cr}",
            en = "{cr}{white}The bronze cannon is strong against buildings.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Kanonengießerei, Alchemistenhütte",
            en = "@color:244,184,0 requires:{white}#Rank#, Foundry, Alchemist's Hut",
        },
        Costs             = {
            [1] = {25, 450, 0, 50, 0, 150, 300},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Cannon2,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 0,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry1, Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon3]                   = {
        Button            = "Buy_Cannon3",
        TextNormal        = {
            de = "{cr}{white}Eine schwere Kanone, die gegen Einheiten eingesetzt wird.{cr}",
            en = "{cr}{white}A heavy cannon used against military units.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Kanonenmanufaktur, Laboratorium",
            en = "@color:244,184,0 requires:{white}#Rank#, Cannon Factory, Laboratory",
        },
        Costs             = {
            [1] = {50, 950, 0, 100, 0, 600, 450},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Cannon3,
        IsCivil           = false,
        Upkeep            = 100,
        Turns             = 0,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },
    [Entities.PV_Cannon4]                   = {
        Button            = "Buy_Cannon4",
        TextNormal        = {
            de = "{cr}{white}Diese schwere Kanone ist besonders effizient bei der Zerstörung von Gebäuden.{cr}",
            en = "{cr}{white}This heavy cannon is particularly efficient at destroying buildings.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Kanonenmanufaktur, Laboratorium",
            en = "@color:244,184,0 requires:{white}#Rank#, Cannon Factory, Laboratory",
        },
        Costs             = {
            [1] = {50, 950, 0, 100, 0, 450, 600},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Cannon4,
        IsCivil           = false,
        Upkeep            = 100,
        Turns             = 0,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Foundry2},
        ProviderBuilding  = {},
    },

    -- Special units --

    [Entities.PU_Scout]                     = {
        Button            = "Buy_Scout",
        TextNormal        = {
            de = "{cr}{white}Kundschafter können für Euch Informationen beschaffen, Rohstoffe finden und Gebiete aufdecken.{cr}",
            en = "{cr}{white}{cr}Scouts can gather information for you, find raw materials and uncover areas.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Costs             = {
            [1] = {0, 150, 0, 50, 0, 50, 0},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Scout,
        IsCivil           = false,
        Upkeep            = 50,
        Turns             = 150,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Tavern1, Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },
    [Entities.PU_Thief]                     = {
        Button            = "Buy_Thief",
        TextNormal        = {
            de = "{cr}{white}Mancher Krimineller arbeitet lieber für Euch, als Euch zu beklauen. Lehrt ihnen später den Umgang mit Sprengstoff.{cr}",
            en = "{cr}{white}Some criminals would rather work for you than steal from you. Teaches them later how to use explosives.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Wirtshaus",
            en = "@color:244,184,0 requires:{white}#Rank#, Inn",
        },
        Costs             = {
            [1] = {30, 500, 0, 0, 0, 100, 100},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Thief,
        IsCivil           = false,
        Upkeep            = 100,
        Turns             = 250,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Tavern2},
        ProviderBuilding  = {},
    },
    [Entities.PU_Serf]                      = {
        Button            = "Buy_Serf",
        TextNormal        = {
            de = "{cr}{white}{cr}",
            en = "{cr}{white}{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Costs             = {
            [1] = {0, 50, 0, 0, 0, 0, 0},
            [2] = {0, 0, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.Serf,
        IsCivil           = true,
        Upkeep            = 0,
        Turns             = 25,
        Soldiers          = 0,
        RecruiterBuilding = {Entities.PB_Headquarters1, Entities.PB_Headquarters2, Entities.PB_Headquarters3},
        ProviderBuilding  = {},
    },

    -- Bandits --

    [Entities.CU_BanditLeaderSword2]        = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{cr}{white}Räuber und Wegelagerer, die ihre Äxte gut gegen andere Infanterie einsetzen können.{cr}",
            en = "{cr}{white}Raiders and highwaymen who are good at using their axes against other infantry.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Schmiede",
            en = "@color:244,184,0 requires:{white}#Rank#, Smithy",
        },
        Costs             = {
            [1] = {7, 120, 0, 10, 0, 50, 0},
            [2] = {0, 25, 0, 5, 0, 15, 0},
        },
        Right             = PlayerRight.BanditSword2,
        IsCivil           = false,
        Upkeep            = 40,
        Turns             = 75,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BanditLeaderSword1]        = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{cr}{white}Diese erfahrenen Gesetzlosen schwingen die Axt und schnetzeln sich durch feindliche Infanterie.{cr}",
            en = "{cr}{white}These experienced outlaws wield their ax and slice through the lines of the enemy.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Grobschmiede",
            en = "@color:244,184,0 requires:{white}#Rank#, Blacksmith",
        },
        Costs             = {
            [1] = {18, 260, 0, 0, 0, 65, 0},
            [2] = {0, 70, 0, 10, 0, 35, 0},
        },
        Right             = PlayerRight.BanditSword1,
        IsCivil           = false,
        Upkeep            = 75,
        Turns             = 125,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
    [Entities.CU_BanditLeaderBow1]          = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{cr}{white}Diese Bogenschützen sind den Kampf gewöhnt und darum excellent gegen leicht gepanzerte Truppen.{cr}",
            en = "{cr}{white}These archers are used to combat and are therefore excellent against lightly armored troops.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Sägemühle",
            en = "@color:244,184,0 requires:{white}#Rank#, Sawmill",
        },
        Costs             = {
            [1] = {5, 100, 0, 70, 0, 0, 0},
            [2] = {0, 12, 0, 12, 0, 0, 0},
        },
        Right             = PlayerRight.BanditBow1,
        IsCivil           = false,
        Upkeep            = 40,
        Turns             = 75,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {},
    },

    -- Barbarians --

    [Entities.CU_Barbarian_LeaderClub2]     = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{cr}{white}Barbarenkrieger sind effektiv gegen gepanzerte Truppen und ihre Nagelkeulen können tiefe Wunden reißen.{cr}",
            en = "{cr}{white}Barbarian warriors are effective against armored troops, and their spiked clubs can inflict deep wounds.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white} #Rank#",
            en = "@color:244,184,0 requires:{white} #Rank#",
        },
        Costs             = {
            [1] = {8, 95, 0, 40, 0, 30, 0},
            [2] = {0, 12, 0, 18, 0, 12, 0},
        },
        Right             = PlayerRight.Barbarian2,
        IsCivil           = false,
        Upkeep            = 25,
        Turns             = 100,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_Barbarian_LeaderClub1]     = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{cr}{white}Diese Elitekrieger sind gut gegen gepanzerte Truppen und können hohen kritischen Schaden austeilen.{cr}",
            en = "{cr}{white}These elite warriors are good against armored troops and can deal high critical damage.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Garnison, Schmiede",
            en = "@color:244,184,0 requires:{white}#Rank#, Garnison, Smithy",
        },
        Costs             = {
            [1] = {22, 170, 0, 75, 0, 45, 0},
            [2] = {0, 45, 0, 35, 0, 25, 0},
        },
        Right             = PlayerRight.Barbarian1,
        IsCivil           = false,
        Upkeep            = 50,
        Turns             = 150,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith1, Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Black Knights --

    [Entities.CU_BlackKnight_LeaderMace2]   = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{cr}{white}Diese Truppen setzt man am Besten gegen gepanzerte Truppen ein.{cr}",
            en = "{cr}{white}{cr}These troops are best used against armored troops.",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Schmiede",
            en = "@color:244,184,0 requires:{white}#Rank#, Smithy",
        },
        Costs             = {
            [1] = {7, 135, 0, 0, 0, 45, 0},
            [2] = {0, 30, 0, 0, 0, 15, 0},
        },
        Right             = PlayerRight.BlackKnight2,
        IsCivil           = false,
        Upkeep            = 40,
        Turns             = 100,
        Soldiers          = 12,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {},
    },
    [Entities.CU_BlackKnight_LeaderMace1]   = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{cr}{white}Die edlen schwarzen Ritter können mit ihren Keulen Rüstungen verbeulen und ein wahrer Albtraum werden.{cr}",
            en = "{cr}{white}The noble black knights can dent armor with their clubs and become a real nightmare.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Garnison, Grobschmiede",
            en = "@color:244,184,0 requires:{white}#Rank#, Garnison, Blacksmith",
        },
        Costs             = {
            [1] = {18, 250, 0, 0, 0, 85, 0},
            [2] = {0, 72, 0, 0, 0, 40, 0},
        },
        Right             = PlayerRight.BlackKnight1,
        IsCivil           = false,
        Upkeep            = 65,
        Turns             = 150,
        Soldiers          = 6,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },

    -- Shrouded --

    [Entities.CU_Evil_LeaderBearman1]       = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {
            de = "{cr}{white}Fanatiker in rituellen Bärenkostümen, die keine Gnade für gewöhnliche Infantrie aufbringen wird.{cr}",
            en = "{cr}{white}Fanatics in ritual bear costumes who will show no mercy to ordinary infantry.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Sägemühle",
            en = "@color:244,184,0 requires:{white}#Rank#, Sawmill",
        },
        Costs             = {
            [1] = {6, 65, 0, 140, 0, 30, 0},
            [2] = {0, 5, 0, 15, 0, 5, 0},
        },
        Right             = PlayerRight.Bearman,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 175,
        Soldiers          = 16,
        RecruiterBuilding = {Entities.PB_Barracks1, Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },
    [Entities.CU_Evil_LeaderSkirmisher1]    = {
        Button            = "Buy_LeaderBow",
        TextNormal        = {
            de = "{cr}{white}Nicht weniger fanatisch als die Bärenmenschen sind auch die Speerwerfer stark gegen gewöhnliche Truppen.{cr}",
            en = "{cr}{white}No less fanatical than the bearmen, the javelin throwers are strong against common troops.{cr}",
        },
        TextDisabled      = {
            de = "@color:244,184,0 benötigt:{white}#Rank#, Sägemühle",
            en = "@color:244,184,0 requires:{white}#Rank#, Sawmill",
        },
        Costs             = {
            [1] = {3, 80, 0, 180, 0, 0, 0},
            [2] = {0, 5, 0, 25, 0, 0, 0},
        },
        Right             = PlayerRight.Skirmisher,
        IsCivil           = false,
        Upkeep            = 30,
        Turns             = 175,
        Soldiers          = 16,
        RecruiterBuilding = {Entities.PB_Archery1, Entities.PB_Archery2},
        ProviderBuilding  = {Entities.PB_Sawmill1, Entities.PB_Sawmill2},
    },

    -- Kerberos Budyguard --

    [Entities.CU_BlackKnight]              = {
        Button            = "Buy_LeaderSword",
        TextNormal        = {de = "{cr}{white}ERROR{cr}", en = "{cr}{white}ERROR{cr}",},
        TextDisabled      = {de = "ERROR #Rank#", en = "ERROR #Rank#",},
        Costs             = {
            [1] = {0, 0, 0, 0, 0, 0, 0},
            [2] = {10, 150, 0, 0, 0, 0, 0},
        },
        Right             = PlayerRight.BlackKnight3,
        IsCivil           = false,
        Upkeep            = 0,
        Turns             = 0,
        Soldiers          = 3,
        RecruiterBuilding = {Entities.PB_Barracks2},
        ProviderBuilding  = {Entities.PB_Blacksmith2, Entities.PB_Blacksmith3},
    },
}

function Stronghold.Unit.Config:Get(_Type, _PlayerID)
    if not _PlayerID or not IsHumanPlayer(_PlayerID) then
        return self[_Type];
    end
    return Stronghold.Recruitment.Data[_PlayerID].Config[_Type];
end

