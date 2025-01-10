--- 
--- Config for Stamina
--- 

Stronghold.Stamina.Config = {
    VagabondPlayerID = 7,
    VagabondPlayerColor = 14,
    NeutralPlayerID = 8,
    NeutralPlayerColor = 14,

    Movement = {
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
    },
};

