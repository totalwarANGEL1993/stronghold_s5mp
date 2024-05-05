--- 
--- Config for hero perks
--- 

Stronghold.Hero.Perk.Config = {}

Stronghold.Hero.Perk.Config.Skill = {
    GainedPoints = {
        [1] = 10,
        [2] = 20,
        [3] = 30,
        [4] = 40,
        [5] = 50,
        [6] = 60,
        [7] = 70,
    },
}

Stronghold.Hero.Perk.Config.Perks = {
    -- Units --

    [HeroPerks.Unit_Bandits] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_Kingsguard] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_Cannons] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_EliteCavalry] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_Templars] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_Barbarians] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_Evil] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_EliteLongbow] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_EliteCrossbow] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_SwordMilitia] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_Lancer] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_Axemen] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_BlackKnights] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_EliteRifle] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Unit_Assassins] = {
        Icon = "",
        Text = "",
        Data = {}
    },

    -- Hero Abilities --

    [HeroPerks.Hero1_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Hero2_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Hero3_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Hero4_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Hero5_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Hero6_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Hero7_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Hero8_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Hero9_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Hero10_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Hero11_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },
    [HeroPerks.Hero12_Ability] = {
        Icon = "",
        Text = "",
        Data = {}
    },

    -- Generic Tier 1 --

    [HeroPerks.Generic_MineSupervisor] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Amount = 1,
        }
    },
    [HeroPerks.Generic_TightBelt] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 0.9,
        }
    },
    [HeroPerks.Generic_Educated] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 1.1,
        }
    },
    [HeroPerks.Generic_HouseTax] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Bonus = 1,
        }
    },
    [HeroPerks.Generic_FarmTax] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Bonus = 1,
        }
    },
    [HeroPerks.Generic_AlarmBoost] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            DamageFactor = 1.3,
        }
    },
    [HeroPerks.Generic_InspiringPresence] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            DamageFactor = 1.1,
        }
    },
    [HeroPerks.Generic_MoodCannon] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 1.01,
        }
    },
    [HeroPerks.Generic_Pyrotechnican] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            MinResource = 10,
            MaxResource = 25,
        }
    },

    -- Generic Tier 2 --

    [HeroPerks.Generic_MiddleClassLover] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Bonus = 1,
        }
    },
    [HeroPerks.Generic_QuantityDiscount] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 1.2,
        }
    },
    [HeroPerks.Generic_ConstructionIndustry] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Bonus = 2,
            ResourceTypes = {
                [ResourceType.Clay] = true,
                [ResourceType.Stone] = true,
            }
        }
    },
    [HeroPerks.Generic_PhilosophersStone] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Bonus = 1,
            ResourceTypes = {
                [ResourceType.Iron] = true,
                [ResourceType.Sulfur] = true,
            }
        }
    },
    [HeroPerks.Generic_Bureaucrat] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            ReputationFactor = 1.05,
            TaxFactor = 1.1,
        }
    },
    [HeroPerks.Generic_Benefactor] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            HonorFactor = 1.05,
            TaxFactor = 0.9,
        }
    },
    [HeroPerks.Generic_BeastMaster] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            DamageTakenFactor = 0.8,
            DamageDeltFactor = 1.2,
            EntityTypes = {
                [Entities.PU_Bear_Cage] = true,
                [Entities.PU_Dog_Cage] = true,
            },
        }
    },
    [HeroPerks.Generic_ForeignLegion] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            RechargeFactor = 1.3,
            CostFactor = 1.15,
        }
    },

    -- Generic Tier 3 --

    [HeroPerks.Generic_ManFlayer] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            BonusFactor = 2.0,
            MalusFactor = 0.5,
        }
    },
    [HeroPerks.Generic_NumberJuggler] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Gross = 4,
            ResourceTypes = {
                [ResourceType.Gold] = true,
            }
        }
    },
    [HeroPerks.Generic_HonorTheFallen] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 0.5,
        }
    },
    [HeroPerks.Generic_EfficiencyStrategist] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Chance = 10,
            Refine = -1,
            Resource = 1,
        }
    },
    [HeroPerks.Generic_BelieverInScience] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Chance = 10,
            Faith = 3,
        }
    },
    [HeroPerks.Generic_WarScars] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 0.7,
        }
    },
    [HeroPerks.Generic_Haggler] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 0.7,
        }
    },
    [HeroPerks.Generic_ExperienceValue] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            GrossFactor = 0.05,
        }
    },
    [HeroPerks.Generic_Shielded] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
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
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 1.5,
        }
    },
    [HeroPerks.Hero1_SocialCare] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            HonorFactor = 1.1,
            TaxFactor = 0.8,
        }
    },
    [HeroPerks.Hero1_Mobilization] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            MilitaryFactor = 1.2,
            PopulationFactor = 0.8,
        }
    },

    -- Hero 2 --

    [HeroPerks.Hero2_Demolitionist] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            MinResource = 25,
            MaxResource = 50,
        }
    },
    [HeroPerks.Hero2_ExtractResources] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Amount = 2,
        }
    },
    [HeroPerks.Hero2_FortressMaster] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 0.8,
        }
    },

    -- Hero 3 --

    [HeroPerks.Hero3_MasterOfArts] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 1.3,
        }
    },
    [HeroPerks.Hero3_AtileryExperte] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Amount = 2,
        }
    },
    [HeroPerks.Hero3_MercenaryBoost] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            CapactyFactor = 1.2,
            ExperienceOverwrite = 0,
            FactorOverwrite = 1,
        }
    },

    -- Hero 4 --

    [HeroPerks.Hero4_ExperiencedInstructor] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
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
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Amount = 200,
            EntityTypes = {
                [Entities.CU_TemplarLeaderHeavyCavalry1] = true,
                [Entities.PU_LeaderHeavyCavalry1] = true,
                [Entities.PU_LeaderHeavyCavalry2] = true,
            },
        }
    },
    [HeroPerks.Hero4_Marschall] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
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
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            PreservationChance = 10,
            PreservationAmount = 1,
            WoodBonus = 1,
        }
    },
    [HeroPerks.Hero5_TaxBonus] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Bonus = 1.3,
        }
    },
    [HeroPerks.Hero5_HubertusBlessing] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
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
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            CrimeFactor = 0.7,
            FilthFactor = 0.7,
        }
    },
    [HeroPerks.Hero6_Preacher] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Bonus = 3,
        }
    },
    [HeroPerks.Hero6_ConvertSettler] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Chance = 4,
            Area = 600,
        }
    },

    -- Hero 7 --

    [HeroPerks.Hero7_Tyrant] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            MaxReputation = 175,
            Factor = 0.8,
        }
    },
    [HeroPerks.Hero7_Moloch] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
        }
    },
    [HeroPerks.Hero7_ArmyOfDarkness] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 0.7,
            EntityTypes = {
                [Entities.CU_BlackKnight_LeaderMace1] = true,
                [Entities.CU_BlackKnight_LeaderMace2] = true,
            },
        }
    },
    -- This one can not be unlocked because it's hardcoded!
    [HeroPerks.Hero7_Paranoid] = {
        Icon = "",
        Text = "",
        Data = {}
    },

    -- Hero 8 --

    [HeroPerks.Hero8_SlaveMaster] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Amount = 2,
        }
    },
    [HeroPerks.Hero8_AgentMaster] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 0.5,
            EntityTypes = {
                [Entities.PU_Scout] = true,
                [Entities.PU_Thief] = true,
            },
        }
    },
    [HeroPerks.Hero8_AssassinMaster] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            DamageDeltFactor = 1.5,
            EntityTypes = {
                [Entities.CU_Assassin_LeaderKnife1] = true,
                [Entities.CU_Assassin_SoldierKnife1] = true,
            },
        }
    },
    -- This one can not be unlocked because it's hardcoded!
    [HeroPerks.Hero8_Underhanded] = {
        Icon = "",
        Text = "",
        Data = {}
    },

    -- Hero 9 --

    [HeroPerks.Hero9_CriticalDrinker] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            ReputationFactor = 1.5,
            HonorFactor = 1.5,
        }
    },
    [HeroPerks.Hero9_BerserkerRage] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
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
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            MilitaryFactor = 1.2,
            DamageTakenFactor = 1.05,
        }
    },

    -- Hero 10 --

    [HeroPerks.Hero10_SlaveMaster] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Amount = 2,
        }
    },
    [HeroPerks.Hero10_MusketeersOath] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Factor = 0.7,
        }
    },
    [HeroPerks.Hero10_GunManufacturer] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
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

    [HeroPerks.Hero11_LandOfTheSmile] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            MaxReputation = 300;
            Reputation = 25,
        }
    },
    [HeroPerks.Hero11_UseShuriken] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            Chance = 8,
        }
    },
    [HeroPerks.Hero11_TradeMaster] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            FactorBonus = 0.015,
            FactorDiv = 1000
        }
    },

    -- Hero 12 --

    [HeroPerks.Hero12_FertilityIcon] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
            PopulationFactor = 1.2,
            TaxFactor = 0.8,
        }
    },
    [HeroPerks.Hero12_Moloch] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
        }
    },
    [HeroPerks.Hero12_MothersComfort] = {
        Icon = "",
        Text = "",
        Data = {
            Cost = 1,
            Rank = 0,
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
        Config.Cost = Config.Cost or 0;
        Config.Rank = Config.Rank or 0;
        return Config
    end
    return nil;
end

