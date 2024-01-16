--- 
--- Configuration for the civil system
--- 

Stronghold.Populace.Config.CivilDuties = {
    Rats = {
        TowerVisionArea = 5000,
        HeroVisionArea = 300,
        WorkerRate = 0.09,
        FilthRate = 1.0,
        CatchChance = 10,
        MaxPerCycle = 5,
        TimeBetween = 12,
        ReputationDamage = 2,
    },
    Crime = {
        TowerVisionArea = 5000,
        HeroVisionArea = 300,
        WorkerRate = 0.09,
        CrimeRate = 1.5,
        ExecutionerRate = 0.6,
        MaxPerCycle = 3,
        TimeBetween = 20,
        TheftAmount = {Min = 25, Max = 75},
        ReputationDamage = 2,
    },
}

Stronghold.Populace.Config.FakeHeroTypes = {
    [Entities.PU_Criminal_Deco] = true,
    [Entities.PU_Rat_Deco] = true,
    [Entities.PU_Watchman_Deco] = true,
}

