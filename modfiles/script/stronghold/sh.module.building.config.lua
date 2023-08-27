--- 
--- Configuration for the buildings
--- 

Stronghold.Building.Config.Headquarters = {
    DraconicPunishmentHonorBonus = 0.20,
    DraconicPunishmentReputationBonus = 0.20,
    DrecorativeSkullHonorBonus = 0.20,
    DrecorativeSkullReputationBonus = 0.20,
    TjostingArmorHonorBonus = 0.20,
    TjostingArmorReputationBonus = 0.20,

    [BlessCategories.Construction] = {
        Reputation = -15,
        Honor = 0,

        Text = "sh_menuheadquarter/blesssettlers1",
    },
    [BlessCategories.Research] = {
        Reputation = 5,
        Honor = 5,

        Text = "sh_menuheadquarter/blesssettlers2",
    },
    [BlessCategories.Weapons] = {
        Reputation = 0,
        Honor = 15,

        Text = "sh_menuheadquarter/blesssettlers3",
    },
    [BlessCategories.Financial] = {
        Reputation = 15,
        Honor = 0,

        Text = "sh_menuheadquarter/blesssettlers4",
    },
    [BlessCategories.Canonisation] = {
        Reputation = -45,
        Honor = 150,

        Text = "sh_menuheadquarter/blesssettlers5",
    },
}

Stronghold.Building.Config.Monastery = {
    SundayAssemblyHonorBonus = 2,
    SundayAssemblyReputationBonus = 2,
    HolyRelicsHonorBonus = 2,
    HolyRelicsReputationBonus = 2,
    PopalBlessingHonorBonus = 2,
    PopalBlessingReputationBonus = 2,

    [BlessCategories.Construction] = {
        Reputation = 8,
        Honor = 0,

        Text = "sh_menumonastery/blesssettlers1",
    },
    [BlessCategories.Research] = {
        Reputation = 0,
        Honor = 8,

        Text = "sh_menumonastery/blesssettlers2",
    },
    [BlessCategories.Weapons] = {
        Reputation = 16,
        Honor = 0,

        Text = "sh_menumonastery/blesssettlers3",
    },
    [BlessCategories.Financial] = {
        Reputation = 0,
        Honor = 16,

        Text = "sh_menumonastery/blesssettlers4",
    },
    [BlessCategories.Canonisation] = {
        Reputation = 12,
        Honor = 12,

        Text = "sh_menumonastery/blesssettlers5",
    },
}

