--- 
--- Config for hero perks
--- 

Stronghold.Hero.Perk.Config = {}

Stronghold.Hero.Perk.Config.UI = {
    FlavorText = {
        [Entities.PU_Hero1]              = "sh_text/Biography_PU_Hero1c",
        [Entities.PU_Hero1a]             = "sh_text/Biography_PU_Hero1c",
        [Entities.PU_Hero1b]             = "sh_text/Biography_PU_Hero1c",
        [Entities.PU_Hero1c]             = "sh_text/Biography_PU_Hero1c",
        [Entities.PU_Hero2]              = "sh_text/Biography_PU_Hero2",
        [Entities.PU_Hero3]              = "sh_text/Biography_PU_Hero3",
        [Entities.PU_Hero4]              = "sh_text/Biography_PU_Hero4",
        [Entities.PU_Hero5]              = "sh_text/Biography_PU_Hero5",
        [Entities.PU_Hero6]              = "sh_text/Biography_PU_Hero6",
        [Entities.CU_BlackKnight]        = "sh_text/Biography_CU_BlackKnight",
        [Entities.CU_Mary_de_Mortfichet] = "sh_text/Biography_CU_Mary_de_Mortfichet",
        [Entities.CU_Barbarian_Hero]     = "sh_text/Biography_CU_Barbarian_Hero",
        [Entities.PU_Hero10]             = "sh_text/Biography_PU_Hero10",
        [Entities.PU_Hero11]             = "sh_text/Biography_PU_Hero11",
        [Entities.CU_Evil_Queen]         = "sh_text/Biography_CU_Evil_Queen",
    },
    Portraits = {
        [Entities.PU_Hero1]              = "graphics/textures/gui/hero_sel_dario.png",
        [Entities.PU_Hero1a]             = "graphics/textures/gui/hero_sel_dario.png",
        [Entities.PU_Hero1b]             = "graphics/textures/gui/hero_sel_dario.png",
        [Entities.PU_Hero1c]             = "graphics/textures/gui/hero_sel_dario.png",
        [Entities.PU_Hero2]              = "graphics/textures/gui/hero_sel_pilgrim.png",
        [Entities.PU_Hero3]              = "graphics/textures/gui/hero_sel_salim.png",
        [Entities.PU_Hero4]              = "graphics/textures/gui/hero_sel_erek.png",
        [Entities.PU_Hero5]              = "graphics/textures/gui/hero_sel_ari.png",
        [Entities.PU_Hero6]              = "graphics/textures/gui/hero_sel_helias.png",
        [Entities.CU_BlackKnight]        = "graphics/textures/gui/hero_sel_kerb.png",
        [Entities.CU_Mary_de_Mortfichet] = "graphics/textures/gui/hero_sel_mort.png",
        [Entities.CU_Barbarian_Hero]     = "graphics/textures/gui/hero_sel_varg.png",
        [Entities.PU_Hero10]             = "graphics/textures/gui/hero_sel_drake.png",
        [Entities.PU_Hero11]             = "graphics/textures/gui/hero_sel_yuki.png",
        [Entities.CU_Evil_Queen]         = "graphics/textures/gui/hero_sel_kala.png",
    },

    RankToRow = {
        [0] = 1,
        [1] = 2,
        [4] = 3,
        [7] = 4
    },
}

Stronghold.Hero.Perk.Config.Perks = {
    -- Units --

    [HeroPerks.Unit_Bandits] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_Bandits",
        Data = {}
    },
    [HeroPerks.Unit_Kingsguard] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_Kingsguard",
        Data = {}
    },
    [HeroPerks.Unit_Cannons] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_Cannons",
        Data = {}
    },
    [HeroPerks.Unit_EliteCavalry] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_EliteCavalry",
        Data = {}
    },
    [HeroPerks.Unit_Templars] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_Templars",
        Data = {}
    },
    [HeroPerks.Unit_Barbarians] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_Barbarians",
        Data = {}
    },
    [HeroPerks.Unit_Evil] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_Evil",
        Data = {}
    },
    [HeroPerks.Unit_EliteLongbow] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_EliteLongbow",
        Data = {}
    },
    [HeroPerks.Unit_EliteCrossbow] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_EliteCrossbow",
        Data = {}
    },
    [HeroPerks.Unit_SwordMilitia] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_SwordMilitia",
        Data = {}
    },
    [HeroPerks.Unit_Lancer] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_Lancer",
        Data = {}
    },
    [HeroPerks.Unit_Axemen] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_Axemen",
        Data = {}
    },
    [HeroPerks.Unit_BlackKnights] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_BlackKnights",
        Data = {}
    },
    [HeroPerks.Unit_EliteRifle] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_EliteRifle",
        Data = {}
    },
    [HeroPerks.Unit_Assassins] = {
        Icon = "HeroPerkTier1ButtonSource1",
        Text = "sh_perks/Unit_Assassins",
        Data = {}
    },

    -- Hero Abilities --

    [HeroPerks.Hero1_Ability] = {
        Icon = "Hero1_ProtectUnits",
        Text = "MenuHero1/command_protectunits",
        Data = {}
    },
    [HeroPerks.Hero2_Ability] = {
        Icon = "Hero2_BuildCannon",
        Text = "MenuHero2/command_buildcannon",
        Data = {}
    },
    [HeroPerks.Hero3_Ability] = {
        Icon = "Hero3_BuildTrap",
        Text = "MenuHero3/command_buildTrap",
        Data = {}
    },
    [HeroPerks.Hero4_Ability] = {
        Icon = "Hero4_CircularAttack",
        Text = "MenuHero4/command_circularattack",
        Data = {}
    },
    [HeroPerks.Hero5_Ability] = {
        Icon = "Hero5_ArrowRain",
        Text = "sh_text/Skill_1_PU_Hero5",
        Data = {}
    },
    [HeroPerks.Hero6_Ability] = {
        Icon = "Hero6_Bless",
        Text = "MenuHero6/command_bless",
        Data = {}
    },
    [HeroPerks.Hero7_Ability] = {
        Icon = "Hero7_Madness",
        Text = "sh_text/Skill_1_CU_BlackKnight",
        Data = {}
    },
    [HeroPerks.Hero8_Ability] = {
        Icon = "Hero8_MoraleDamage",
        Text = "sh_text/Skill_1_CU_Mary_de_Mortfichet",
        Data = {}
    },
    [HeroPerks.Hero9_Ability] = {
        Icon = "Hero9_CallWolfs",
        Text = "MenuHero9/command_callwolfs",
        Data = {}
    },
    [HeroPerks.Hero10_Ability] = {
        Icon = "Hero10_LongRangeAura",
        Text = "AOMenuHero10/command_longrangeaura",
        Data = {}
    },
    [HeroPerks.Hero11_Ability] = {
        Icon = "Hero11_FireworksFear",
        Text = "AOMenuHero11/command_FireworksFear",
        Data = {}
    },
    [HeroPerks.Hero12_Ability] = {
        Icon = "Hero12_PoisonRange",
        Text = "AOMenuHero12/command_PoisonRange",
        Data = {}
    },

    -- Generic Tier 1 --

    [HeroPerks.Generic_MineSupervisor] = {
        Icon = "HeroPerkTier1ButtonSource4",
        Text = "sh_perks/Generic_Tier1_Perk1",
        Data = {
            RequiredRank = 1,
            Amount = 1,
        }
    },
    [HeroPerks.Generic_TightBelt] = {
        Icon = "HeroPerkTier2ButtonSource6",
        Text = "sh_perks/Generic_Tier1_Perk2",
        Data = {
            RequiredRank = 1,
            Factor = 0.9,
        }
    },
    [HeroPerks.Generic_Educated] = {
        Icon = "HeroPerkTier1ButtonSource9",
        Text = "sh_perks/Generic_Tier1_Perk3",
        Data = {
            RequiredRank = 1,
            Factor = 1.1,
        }
    },
    [HeroPerks.Generic_HouseTax] = {
        Icon = "HeroPerkTier1ButtonSource6",
        Text = "sh_perks/Generic_Tier1_Perk4",
        Data = {
            RequiredRank = 1,
            Bonus = 1,
        }
    },
    [HeroPerks.Generic_FarmTax] = {
        Icon = "HeroPerkTier1ButtonSource6",
        Text = "sh_perks/Generic_Tier1_Perk5",
        Data = {
            RequiredRank = 1,
            Bonus = 1,
        }
    },
    [HeroPerks.Generic_AlarmBoost] = {
        Icon = "HeroPerkTier1ButtonSource7",
        Text = "sh_perks/Generic_Tier1_Perk6",
        Data = {
            RequiredRank = 1,
            DamageFactor = 1.3,
        }
    },
    [HeroPerks.Generic_InspiringPresence] = {
        Icon = "HeroPerkTier1ButtonSource7",
        Text = "sh_perks/Generic_Tier1_Perk7",
        Data = {
            RequiredRank = 1,
            DamageFactor = 1.1,
        }
    },
    [HeroPerks.Generic_MoodCannon] = {
        Icon = "HeroPerkTier2ButtonSource5",
        Text = "sh_perks/Generic_Tier1_Perk8",
        Data = {
            RequiredRank = 1,
            Factor = 1.01,
        }
    },
    [HeroPerks.Generic_Pyrotechnican] = {
        Icon = "HeroPerkTier1ButtonSource4",
        Text = "sh_perks/Generic_Tier1_Perk9",
        Data = {
            RequiredRank = 1,
            MinResource = 10,
            MaxResource = 25,
        }
    },

    -- Generic Tier 2 --

    [HeroPerks.Generic_MiddleClassLover] = {
        Icon = "HeroPerkTier1ButtonSource5",
        Text = "sh_perks/Generic_Tier2_Perk1",
        Data = {
            RequiredRank = 4,
            Bonus = 1,
        }
    },
    [HeroPerks.Generic_QuantityDiscount] = {
        Icon = "HeroPerkTier1ButtonSource2",
        Text = "sh_perks/Generic_Tier2_Perk2",
        Data = {
            RequiredRank = 4,
            Factor = 1.2,
        }
    },
    [HeroPerks.Generic_ConstructionIndustry] = {
        Icon = "HeroPerkTier1ButtonSource5",
        Text = "sh_perks/Generic_Tier2_Perk3",
        Data = {
            RequiredRank = 4,
            Bonus = 2,
            ResourceTypes = {
                [ResourceType.Clay] = true,
                [ResourceType.Stone] = true,
            }
        }
    },
    [HeroPerks.Generic_PhilosophersStone] = {
        Icon = "HeroPerkTier1ButtonSource5",
        Text = "sh_perks/Generic_Tier2_Perk4",
        Data = {
            RequiredRank = 4,
            Bonus = 1,
            ResourceTypes = {
                [ResourceType.Iron] = true,
                [ResourceType.Sulfur] = true,
            }
        }
    },
    [HeroPerks.Generic_Bureaucrat] = {
        Icon = "HeroPerkTier1ButtonSource6",
        Text = "sh_perks/Generic_Tier2_Perk5",
        Data = {
            RequiredRank = 4,
            ReputationFactor = 1.05,
            TaxFactor = 1.1,
        }
    },
    [HeroPerks.Generic_Benefactor] = {
        Icon = "HeroPerkTier2ButtonSource2",
        Text = "sh_perks/Generic_Tier2_Perk6",
        Data = {
            RequiredRank = 4,
            HonorFactor = 1.05,
            TaxFactor = 0.9,
        }
    },
    [HeroPerks.Generic_BeastMaster] = {
        Icon = "HeroPerkTier2ButtonSource7",
        Text = "sh_perks/Generic_Tier2_Perk7",
        Data = {
            RequiredRank = 4,
            DamageTakenFactor = 0.8,
            DamageDeltFactor = 1.2,
            EntityTypes = {
                [Entities.PU_Bear_Cage] = true,
                [Entities.PU_Dog_Cage] = true,
            },
        }
    },
    [HeroPerks.Generic_Convocation] = {
        Icon = "HeroPerkTier2ButtonSource4",
        Text = "sh_perks/Generic_Tier2_Perk8",
        Data = {
            RequiredRank = 4,
            MilitaryFactor = 1.1,
            PopulationFactor = 0.9,
        }
    },
    [HeroPerks.Generic_ForeignLegion] = {
        Icon = "HeroPerkTier1ButtonSource3",
        Text = "sh_perks/Generic_Tier2_Perk9",
        Data = {
            RequiredRank = 4,
            RechargeFactor = 1.3,
            CostFactor = 1.15,
        }
    },

    -- Generic Tier 3 --

    [HeroPerks.Generic_ManFlayer] = {
        Icon = "HeroPerkTier2ButtonSource3",
        Text = "sh_perks/Generic_Tier3_Perk1",
        Data = {
            RequiredRank = 7,
            BonusFactor = 2.0,
            MalusFactor = 0.5,
        }
    },
    [HeroPerks.Generic_NumberJuggler] = {
        Icon = "HeroPerkTier1ButtonSource6",
        Text = "sh_perks/Generic_Tier3_Perk2",
        Data = {
            RequiredRank = 7,
            Gross = 4,
            ResourceTypes = {
                [ResourceType.Gold] = true,
            }
        }
    },
    [HeroPerks.Generic_HonorTheFallen] = {
        Icon = "HeroPerkTier1ButtonSource10",
        Text = "sh_perks/Generic_Tier3_Perk3",
        Data = {
            RequiredRank = 7,
            Factor = 0.5,
        }
    },
    [HeroPerks.Generic_EfficiencyStrategist] = {
        Icon = "HeroPerkTier2ButtonSource3",
        Text = "sh_perks/Generic_Tier3_Perk4",
        Data = {
            RequiredRank = 7,
            Chance = 10,
            Refine = -1,
            Resource = 1,
        }
    },
    [HeroPerks.Generic_BelieverInScience] = {
        Icon = "HeroPerkTier1ButtonSource9",
        Text = "sh_perks/Generic_Tier3_Perk5",
        Data = {
            RequiredRank = 7,
            Chance = 10,
            Faith = 3,
        }
    },
    [HeroPerks.Generic_WarScars] = {
        Icon = "HeroPerkTier1ButtonSource3",
        Text = "sh_perks/Generic_Tier3_Perk6",
        Data = {
            RequiredRank = 7,
            Factor = 0.7,
        }
    },
    [HeroPerks.Generic_Haggler] = {
        Icon = "HeroPerkTier1ButtonSource2",
        Text = "sh_perks/Generic_Tier3_Perk7",
        Data = {
            RequiredRank = 7,
            Factor = 0.7,
        }
    },
    [HeroPerks.Generic_ExperienceValue] = {
        Icon = "HeroPerkTier1ButtonSource8",
        Text = "sh_perks/Generic_Tier3_Perk8",
        Data = {
            RequiredRank = 7,
            GrossFactor = 0.05,
        }
    },
    [HeroPerks.Generic_Shielded] = {
        Icon = "HeroPerkTier1ButtonSource8",
        Text = "sh_perks/Generic_Tier3_Perk9",
        Data = {
            RequiredRank = 7,
            DamageFactor = 0.7,
            DamageClasses = {
                [DamageClasses.DC_TroopCannon] = true,
                [DamageClasses.DC_SiegeCannon] = true,
                [DamageClasses.DC_Turret] = true,
            },
        }
    },

    -- Hero 1 --

    [HeroPerks.Hero1_SolemnAuthority] = {
        Icon = "HeroPerkHeroButtonSource1",
        Text = "sh_perks/Hero1_Perk1",
        Data = {
            RequiredRank = 1,
            Factor = 1.5,
        }
    },
    [HeroPerks.Hero1_SocialCare] = {
        Icon = "HeroPerkHeroButtonSource1",
        Text = "sh_perks/Hero1_Perk2",
        Data = {
            RequiredRank = 4,
            HonorFactor = 1.1,
            TaxFactor = 0.8,
        }
    },
    [HeroPerks.Hero1_Mobilization] = {
        Icon = "HeroPerkHeroButtonSource1",
        Text = "sh_perks/Hero1_Perk3",
        Data = {
            RequiredRank = 7,
            MilitaryFactor = 1.2,
            PopulationFactor = 0.8,
        }
    },

    -- Hero 2 --

    [HeroPerks.Hero2_Demolitionist] = {
        Icon = "HeroPerkHeroButtonSource5",
        Text = "sh_perks/Hero2_Perk1",
        Data = {
            RequiredRank = 1,
            MinResource = 25,
            MaxResource = 50,
        }
    },
    [HeroPerks.Hero2_ExtractResources] = {
        Icon = "HeroPerkHeroButtonSource5",
        Text = "sh_perks/Hero2_Perk2",
        Data = {
            RequiredRank = 4,
            Amount = 2,
        }
    },
    [HeroPerks.Hero2_FortressMaster] = {
        Icon = "HeroPerkHeroButtonSource5",
        Text = "sh_perks/Hero2_Perk3",
        Data = {
            RequiredRank = 7,
            Factor = 0.8,
        }
    },

    -- Hero 3 --

    [HeroPerks.Hero3_MasterOfArts] = {
        Icon = "HeroPerkHeroButtonSource2",
        Text = "sh_perks/Hero3_Perk1",
        Data = {
            RequiredRank = 1,
            Factor = 1.3,
        }
    },
    [HeroPerks.Hero3_AtileryExperte] = {
        Icon = "HeroPerkHeroButtonSource2",
        Text = "sh_perks/Hero3_Perk2",
        Data = {
            RequiredRank = 4,
            Amount = 2,
        }
    },
    [HeroPerks.Hero3_MercenaryBoost] = {
        Icon = "HeroPerkHeroButtonSource2",
        Text = "sh_perks/Hero3_Perk3",
        Data = {
            RequiredRank = 7,
            CapactyFactor = 1.2,
            ExperienceOverwrite = 0,
            FactorOverwrite = 1,
        }
    },

    -- Hero 4 --

    [HeroPerks.Hero4_ExperiencedInstructor] = {
        Icon = "HeroPerkHeroButtonSource3",
        Text = "sh_perks/Hero3_Perk1",
        Data = {
            RequiredRank = 1,
            Amount = 400,
            EntityTypes = {
                [Entities.CU_BanditLeaderSword1] = true,
                [Entities.CU_BanditLeaderSword2] = true,
                [Entities.CU_BanditLeaderSword3] = true,
                [Entities.CU_Barbarian_LeaderClub1] = true,
                [Entities.CU_Barbarian_LeaderClub2] = true,
                [Entities.CU_BlackKnight_LeaderMace1] = true,
                [Entities.CU_BlackKnight_LeaderMace2] = true,
                [Entities.CU_Evil_LeaderBearman1] = true,
                [Entities.PU_LeaderPoleArm1] = true,
                [Entities.PU_LeaderPoleArm2] = true,
                [Entities.PU_LeaderPoleArm3] = true,
                [Entities.PU_LeaderPoleArm4] = true,
                [Entities.PU_LeaderSword1] = true,
                [Entities.PU_LeaderSword2] = true,
                [Entities.PU_LeaderSword3] = true,
                [Entities.PU_LeaderSword4] = true,
            },
        }
    },
    [HeroPerks.Hero4_GrandMaster] = {
        Icon = "HeroPerkHeroButtonSource3",
        Text = "sh_perks/Hero3_Perk2",
        Data = {
            RequiredRank = 4,
            Amount = 200,
            EntityTypes = {
                [Entities.CU_TemplarLeaderHeavyCavalry1] = true,
                [Entities.PU_LeaderHeavyCavalry1] = true,
                [Entities.PU_LeaderHeavyCavalry2] = true,
            },
        }
    },
    [HeroPerks.Hero4_Marschall] = {
        Icon = "HeroPerkHeroButtonSource3",
        Text = "sh_perks/Hero3_Perk3",
        Data = {
            RequiredRank = 7,
            Factor = 0.5,
            EntityTypes = {
                [Entities.CU_TemplarLeaderHeavyCavalry1] = true,
                [Entities.PU_LeaderHeavyCavalry1] = true,
                [Entities.PU_LeaderHeavyCavalry2] = true,
            },
            DamageClasses = {
                [DamageClasses.DC_Halberd] = true,
                [DamageClasses.DC_Pole] = true,
            }
        }
    },

    -- Hero 5 --

    [HeroPerks.Hero5_ChildOfNature] = {
        Icon = "HeroPerkHeroButtonSource6",
        Text = "sh_perks/Hero5_Perk1",
        Data = {
            RequiredRank = 1,
            PreservationChance = 10,
            PreservationAmount = 1,
            WoodBonus = 1,
        }
    },
    [HeroPerks.Hero5_TaxBonus] = {
        Icon = "HeroPerkHeroButtonSource6",
        Text = "sh_perks/Hero5_Perk2",
        Data = {
            RequiredRank = 4,
            Bonus = 1.3,
        }
    },
    [HeroPerks.Hero5_HubertusBlessing] = {
        Icon = "HeroPerkHeroButtonSource6",
        Text = "sh_perks/Hero5_Perk3",
        Data = {
            RequiredRank = 7,
            DamageFactor = 0.7,
            EntityTypes = {
                [Entities.CU_BanditLeaderBow1] = true,
                [Entities.CU_BanditLeaderCavalry1] = true,
                [Entities.CU_BanditLeaderSword3] = true,
            }
        }
    },

    -- Hero 6 --

    [HeroPerks.Hero6_Confessor] = {
        Icon = "HeroPerkHeroButtonSource4",
        Text = "sh_perks/Hero6_Perk1",
        Data = {
            RequiredRank = 1,
            CrimeFactor = 0.7,
            FilthFactor = 0.7,
        }
    },
    [HeroPerks.Hero6_ConvertSettler] = {
        Icon = "HeroPerkHeroButtonSource4",
        Text = "sh_perks/Hero6_Perk3",
        Data = {
            RequiredRank = 4,
            Chance = 4,
            Area = 600,
        }
    },
    [HeroPerks.Hero6_Preacher] = {
        Icon = "HeroPerkHeroButtonSource4",
        Text = "sh_perks/Hero6_Perk2",
        Data = {
            RequiredRank = 7,
            Bonus = 6,
        }
    },

    -- Hero 7 --

    [HeroPerks.Hero7_Tyrant] = {
        Icon = "HeroPerkHeroButtonSource9",
        Text = "sh_perks/Hero7_Perk1",
        Data = {
            RequiredRank = 1,
            MaxReputation = 175,
            Factor = 0.8,
        }
    },
    [HeroPerks.Hero7_Moloch] = {
        Icon = "HeroPerkHeroButtonSource9",
        Text = "sh_perks/Hero7_Perk2",
        Data = {
            RequiredRank = 4,
        }
    },
    [HeroPerks.Hero7_ArmyOfDarkness] = {
        Icon = "HeroPerkHeroButtonSource9",
        Text = "sh_perks/Hero7_Perk3",
        Data = {
            RequiredRank = 7,
            Factor = 0.7,
            EntityTypes = {
                [Entities.CU_BlackKnight_LeaderMace1] = true,
                [Entities.CU_BlackKnight_LeaderMace2] = true,
            },
        }
    },
    -- This one can not be unlocked because it's hardcoded!
    [HeroPerks.Hero7_Paranoid] = {
        Icon = "HeroPerkHeroButtonSource9",
        Text = "sh_perks/Hero7_Perk0",
        Data = {}
    },

    -- Hero 8 --

    [HeroPerks.Hero8_SlaveMaster] = {
        Icon = "HeroPerkHeroButtonSource7",
        Text = "sh_perks/Hero8_Perk1",
        Data = {
            RequiredRank = 1,
            Amount = 2,
        }
    },
    [HeroPerks.Hero8_AgentMaster] = {
        Icon = "HeroPerkHeroButtonSource7",
        Text = "sh_perks/Hero8_Perk2",
        Data = {
            RequiredRank = 4,
            Factor = 0.5,
            EntityTypes = {
                [Entities.PU_Scout] = true,
                [Entities.PU_Thief] = true,
            },
        }
    },
    [HeroPerks.Hero8_AssassinMaster] = {
        Icon = "HeroPerkHeroButtonSource7",
        Text = "sh_perks/Hero8_Perk3",
        Data = {
            RequiredRank = 7,
            DamageDeltFactor = 1.5,
            EntityTypes = {
                [Entities.CU_Assassin_LeaderKnife1] = true,
                [Entities.CU_Assassin_SoldierKnife1] = true,
            },
        }
    },
    -- This one can not be unlocked because it's hardcoded!
    [HeroPerks.Hero8_Underhanded] = {
        Icon = "HeroPerkHeroButtonSource7",
        Text = "sh_perks/Hero8_Perk0",
        Data = {}
    },

    -- Hero 9 --

    [HeroPerks.Hero9_CriticalDrinker] = {
        Icon = "HeroPerkHeroButtonSource8",
        Text = "sh_perks/Hero9_Perk1",
        Data = {
            RequiredRank = 1,
            ReputationFactor = 1.5,
            HonorFactor = 1.5,
        }
    },
    [HeroPerks.Hero9_BerserkerRage] = {
        Icon = "HeroPerkHeroButtonSource8",
        Text = "sh_perks/Hero9_Perk2",
        Data = {
            RequiredRank = 4,
            DamageTakenFactor = 1.1,
            DamageDeltFactor = 1.25,
            EntityTypes = {
                [Entities.CU_Barbarian_LeaderClub1] = true,
                [Entities.CU_Barbarian_SoldierClub1] = true,
                [Entities.CU_Barbarian_LeaderClub2] = true,
                [Entities.CU_Barbarian_SoldierClub2] = true,
            },
        }
    },
    [HeroPerks.Hero9_Mobilization] = {
        Icon = "HeroPerkHeroButtonSource8",
        Text = "sh_perks/Hero9_Perk3",
        Data = {
            RequiredRank = 7,
            MilitaryFactor = 1.2,
            DamageTakenFactor = 1.05,
        }
    },

    -- Hero 10 --

    [HeroPerks.Hero10_SlaveMaster] = {
        Icon = "HeroPerkHeroButtonSource10",
        Text = "sh_perks/Hero10_Perk1",
        Data = {
            RequiredRank = 1,
            Amount = 2,
        }
    },
    [HeroPerks.Hero10_MusketeersOath] = {
        Icon = "HeroPerkHeroButtonSource10",
        Text = "sh_perks/Hero10_Perk2",
        Data = {
            RequiredRank = 4,
            Factor = 0.7,
        }
    },
    [HeroPerks.Hero10_GunManufacturer] = {
        Icon = "HeroPerkHeroButtonSource10",
        Text = "sh_perks/Hero10_Perk3",
        Data = {
            RequiredRank = 7,
            Bonus = 3,
            EntityTypes = {
                [Entities.PB_GunsmithWorkshop1] = true,
                [Entities.PB_GunsmithWorkshop2] = true
            },
            ResourceTypes = {
                [ResourceType.Sulfur] = true,
            },
        }
    },

    -- Hero 11 --

    [HeroPerks.Hero11_UseShuriken] = {
        Icon = "HeroPerkHeroButtonSource11",
        Text = "sh_perks/Hero11_Perk2",
        Data = {
            RequiredRank = 1,
            Chance = 8,
        }
    },
    [HeroPerks.Hero11_LandOfTheSmile] = {
        Icon = "HeroPerkHeroButtonSource11",
        Text = "sh_perks/Hero11_Perk1",
        Data = {
            RequiredRank = 4,
            MaxReputation = 300;
            Reputation = 25,
        }
    },
    [HeroPerks.Hero11_TradeMaster] = {
        Icon = "HeroPerkHeroButtonSource11",
        Text = "sh_perks/Hero11_Perk3",
        Data = {
            RequiredRank = 7,
            FactorBonus = 0.015,
            FactorDiv = 1000
        }
    },

    -- Hero 12 --

    [HeroPerks.Hero12_FertilityIcon] = {
        Icon = "HeroPerkHeroButtonSource12",
        Text = "sh_perks/Hero12_Perk1",
        Data = {
            RequiredRank = 1,
            PopulationFactor = 1.2,
            TaxFactor = 0.8,
        }
    },
    [HeroPerks.Hero12_Moloch] = {
        Icon = "HeroPerkHeroButtonSource12",
        Text = "sh_perks/Hero12_Perk2",
        Data = {
            RequiredRank = 4,
        }
    },
    [HeroPerks.Hero12_MothersComfort] = {
        Icon = "HeroPerkHeroButtonSource12",
        Text = "sh_perks/Hero12_Perk3",
        Data = {
            RequiredRank = 7,
            DamageTakenFactor = 0.5,
            EntityTypes = {
                [Entities.CU_Evil_LeaderBearman1] = true,
                [Entities.CU_Evil_SoldierBearman1] = true,
                [Entities.CU_Evil_LeaderSkirmisher1] = true,
                [Entities.CU_Evil_SoldierSkirmisher1] = true,
            },
            DamageClasses = {
                [DamageClasses.DC_TroopCannon] = true,
                [DamageClasses.DC_SiegeCannon] = true,
                [DamageClasses.DC_Turret] = true,
                [DamageClasses.DC_Bullet] = true,
            },
        }
    },
}

function Stronghold.Hero.Perk.Config:GetPerkConfig(_Perk)
    if self.Perks[_Perk] then
        local Config = self.Perks[_Perk];
        Config.Data.RequiredRank = Config.Data.RequiredRank or 0;
        return Config
    end
    return nil;
end

