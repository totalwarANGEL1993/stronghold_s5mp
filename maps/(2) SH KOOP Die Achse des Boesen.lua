SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 2,

    -- ###################################################################### --
    -- #                             CONFIG                                 # --
    -- ###################################################################### --

    -- Disable standard victory condition?
    -- (Game is not lost when the HQ falls)
    DisableDefaultWinCondition = false,
    -- Disable rule configuration?
    DisableRuleConfiguration = true;

    -- Peacetime in minutes
    PeaceTime = 30,
    -- Open up named gates on the map.
    -- (PTGate1, PTGate2, ...)
    PeaceTimeOpenGates = true,

    -- Fill resource piles with resources
    -- (value of resources or 0 to not change)
    MapStartFillClay = 4000,
    MapStartFillStone = 4000,
    MapStartFillIron = 4000,
    MapStartFillSulfur = 4000,
    MapStartFillWood = 4000,

    -- Rank
    Rank = {
        Initial = 0,
        Final = 7,
    },

    -- Resources
    -- {Honor, Gold, Clay, Wood, Stone, Iron, Sulfur}
    Resources = {[1] = {0, 1000, 1200, 1500, 550, 0, 0}},

    -- Setup heroes allowed
    AllowedHeroes = {
        -- Dario
        [Entities.PU_Hero1c]             = true,
        -- Pilgrim
        [Entities.PU_Hero2]              = true,
        -- Salim
        [Entities.PU_Hero3]              = true,
        -- Erec
        [Entities.PU_Hero4]              = true,
        -- Ari
        [Entities.PU_Hero5]              = true,
        -- Helias
        [Entities.PU_Hero6]              = true,
        -- Kerberos
        [Entities.CU_BlackKnight]        = false,
        -- Mary
        [Entities.CU_Mary_de_Mortfichet] = false,
        -- Varg
        [Entities.CU_Barbarian_Hero]     = false,
        -- Drake
        [Entities.PU_Hero10]             = true,
        -- Yuki
        [Entities.PU_Hero11]             = true,
        -- Kala
        [Entities.CU_Evil_Queen]         = true,
    },

    -- ###################################################################### --
    -- #                            CALLBACKS                               # --
    -- ###################################################################### --

    -- Called when map is loaded
    OnMapStart = function()
        UseWeatherSet("HighlandsWeatherSet");
        AddPeriodicSummer(360);
        AddPeriodicRain(90);
        LocalMusic.UseSet = HIGHLANDMUSIC;
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        SetHostile(1, 7);
        SetHostile(2, 7);

        CloseGatesKerberos();
        CloseGatesMary();
        CloseGatesVarg();

        SetupAiPlayerMary();
        SetupAiPlayerVarg();
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
        SetHostile(1, 4);
        SetHostile(2, 4);
        SetHostile(1, 5);
        SetHostile(2, 5);

        OpenGatesMary();
        OpenGatesVarg();
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
    end,
}

-- Kerberos --------------------------------------------------------------------

gvKerberos = {
    PlayerID = 3,
    -- Must be programmed differently
    -- SpawnTimer = 180,
    -- SpawnFactor = 1.0,
    -- Experience = 0,
    -- ArmyCount = 4,
    -- ArmySize = 8,
    -- Spawners = {},
    -- Armies = {},
}

function SetupAiPlayerKerberos()
    SetupAiPlayer(gvKerberos.PlayerID, 0);
    SetRank(gvKerberos.PlayerID, 7);

    SetupAiPlayerKerberosSpawner();
    SetupAiPlayerKerberosArmies();
end

function SetupAiPlayerKerberosSpawner()

end

function SetupAiPlayerKerberosArmies()

end

-- Mary ------------------------------------------------------------------------

gvMary = {
    PlayerID = 5,
    SpawnTimer = 180,
    SpawnFactor = 1.0,
    Experience = 0,
    ArmyCount = 6,
    ArmySize = 4,
    Spawners = {},
    Armies = {},
}

function SetupAiPlayerMary()
    SetupAiPlayer(gvMary.PlayerID, 0);
    SetRank(gvMary.PlayerID, 7);

    SetupAiPlayerMarySpawner();
    SetupAiPlayerMaryArmies();

    SVLib.SetInvisibility(GetID("HQ4Ruin"), true);
    StartSimpleJob("CheckMaryHeadquarterExisting");
end

function CheckMaryHeadquarterExisting()
    if not IsExisting("HQ4") then
        SVLib.SetInvisibility(GetID("HQ4Ruin"), false);
        gvMary.IsDefeated = true;
        return true;
    end
end

function SetupAiPlayerMarySpawner()
    -- Barracks
    for i= 1,2 do
        local Spawner = AiArmyRefiller.CreateSpawner {
            ScriptName      = "P5Barracks" ..i,
            SpawnPoint      = "P5Barracks" ..i.. "Spawn",
            SpawnAmount     = math.floor(1 * gvMary.SpawnFactor),
            SpawnTimer      = gvMary.SpawnTimer,
            AllowedTypes    = {
                {Entities.PU_LeaderSword3, gvMary.Experience},
                {Entities.PU_LeaderPoleArm3, gvMary.Experience},
                {Entities.PU_LeaderSword3, gvMary.Experience},
            }
        };
        _G["gvP5SPBarracks" ..i] = Spawner;
        table.insert(gvMary.Spawners, Spawner);
    end
    -- Archery
    for i= 1,2 do
        local Spawner = AiArmyRefiller.CreateSpawner {
            ScriptName      = "P5Archery" ..i,
            SpawnPoint      = "P5Archery" ..i.. "Spawn",
            SpawnAmount     = math.floor(3 * gvMary.SpawnFactor),
            SpawnTimer      = gvMary.SpawnTimer,
            AllowedTypes    = {
                {Entities.PU_LeaderBow4, gvMary.Experience},
            }
        };
        _G["gvP5SPArchery" ..i] = Spawner;
        table.insert(gvMary.Spawners, Spawner);
    end
    -- Stables
    for i= 1,1 do
        local Spawner = AiArmyRefiller.CreateSpawner {
            ScriptName      = "P5Stables" ..i,
            SpawnPoint      = "P5Stables" ..i.. "Spawn",
            SpawnAmount     = math.floor(2 * gvMary.SpawnFactor),
            SpawnTimer      = gvMary.SpawnTimer,
            AllowedTypes    = {
                {Entities.PU_LeaderHeavyCavalry1, gvMary.Experience},
            }
        };
        _G["gvP5SPStables" ..i] = Spawner;
        table.insert(gvMary.Spawners, Spawner);
    end
    -- Foundry
    for i= 1,2 do
        local Spawner = AiArmyRefiller.CreateSpawner {
            ScriptName      = "P5Foundry" ..i,
            SpawnPoint      = "P5Foundry" ..i.. "Spawn",
            SpawnAmount     = math.floor(1 * gvMary.SpawnFactor),
            SpawnTimer      = gvMary.SpawnTimer,
            AllowedTypes    = {
                {Entities.PV_Cannon3, 0},
            }
        };
        _G["gvP5SPFoundry" ..i] = Spawner;
        table.insert(gvMary.Spawners, Spawner);
    end
end

function SetupAiPlayerMaryArmies()

end

-- Varg ------------------------------------------------------------------------

gvVarg = {
    PlayerID = 4,
    IsDefeated = false,
    SpawnTimer = 180,
    SpawnFactor = 1.0,
    Experience = 0,
    ArmyCount = 6,
    ArmySize = 4,
    Spawners = {},
    Armies = {},
}

function SetupAiPlayerVarg()
    SetupAiPlayer(gvVarg.PlayerID, 0);
    SetRank(gvVarg.PlayerID, 7);

    SetupAiPlayerVargSpawner();
    SetupAiPlayerVargArmies();

    SVLib.SetInvisibility(GetID("HQ5Ruin"), true);
    StartSimpleJob("CheckVargHeadquarterExisting");
end

function CheckVargHeadquarterExisting()
    if not IsExisting("HQ5") then
        SVLib.SetInvisibility(GetID("HQ5Ruin"), false);
        gvVarg.IsDefeated = true;
        return true;
    end
end

function SetupAiPlayerVargSpawner()
    -- Barracks
    for i= 1,3 do
        local Spawner = AiArmyRefiller.CreateSpawner {
            ScriptName      = "P4Barracks" ..i,
            SpawnPoint      = "P4Barracks" ..i.. "Spawn",
            SpawnAmount     = math.floor(3 * gvVarg.SpawnFactor),
            SpawnTimer      = gvVarg.SpawnTimer,
            AllowedTypes    = {
                {Entities.CU_Barbarian_LeaderClub2, gvVarg.Experience},
                {Entities.PU_LeaderPoleArm1, gvVarg.Experience},
                {Entities.CU_Barbarian_LeaderClub2, gvVarg.Experience},
            }
        };
        _G["gvP4SPBarracks" ..i] = Spawner;
        table.insert(gvVarg.Spawners, Spawner);
    end
    -- Archery
    for i= 1,1 do
        local Spawner = AiArmyRefiller.CreateSpawner {
            ScriptName      = "P4Archery" ..i,
            SpawnPoint      = "P4Archery" ..i.. "Spawn",
            SpawnAmount     = math.floor(1 * gvVarg.SpawnFactor),
            SpawnTimer      = gvVarg.SpawnTimer,
            AllowedTypes    = {
                {Entities.PU_LeaderBow3, gvVarg.Experience},
            }
        };
        _G["gvP4SPArchery" ..i] = Spawner;
        table.insert(gvVarg.Spawners, Spawner);
    end
    -- Stables
    for i= 1,1 do
        local Spawner = AiArmyRefiller.CreateSpawner {
            ScriptName      = "P4Stables" ..i,
            SpawnPoint      = "P4Stables" ..i.. "Spawn",
            SpawnAmount     = math.floor(1 * gvVarg.SpawnFactor),
            SpawnTimer      = gvVarg.SpawnTimer,
            AllowedTypes    = {
                {Entities.PU_LeaderHeavyCavalry1, gvVarg.Experience},
            }
        };
        _G["gvP4SPStables" ..i] = Spawner;
        table.insert(gvVarg.Spawners, Spawner);
    end
    -- Foundry
    for i= 1,1 do
        local Spawner = AiArmyRefiller.CreateSpawner {
            ScriptName      = "P4Foundry" ..i,
            SpawnPoint      = "P4Foundry" ..i.. "Spawn",
            SpawnAmount     = math.floor(1 * gvVarg.SpawnFactor),
            SpawnTimer      = gvVarg.SpawnTimer,
            AllowedTypes    = {
                {Entities.PV_Cannon1, 0},
            }
        };
        _G["gvP4SPFoundry" ..i] = Spawner;
        table.insert(gvVarg.Spawners, Spawner);
    end
end

function SetupAiPlayerVargArmies()
    for i= 1, gvVarg.ArmyCount do
        local ArmyID = AiArmy.New(2, 8, GetPosition("P2OuterPos"), 5000);
        AiArmy.SetFormationController(ArmyID, CustomTroopFomrationController);
        for j= 1, table.getn(gvVarg.Spawners) do
            AiArmyRefiller.AddArmy(gvVarg.Spawners[j], ArmyID);
        end

        local ManagerID = AiArmyManager.Create(ArmyID);
        for j= 1, 4 do
            AiArmyManager.AddGuardPosition(ManagerID, "P4AreaDef" ..j);
        end
        for j= 1, 5 do
            AiArmyManager.AddAttackTarget(ManagerID, "P4AttackPos" ..j);
        end
        table.insert(gvVarg.Armies, ManagerID);
    end
    AiArmyManager.Synchronize(unpack(gvVarg.Armies));
end

-- Gates -----------------------------------------------------------------------

function CloseGatesKerberos()
    for i= 1,6 do
        ReplaceEntity("P3Gate" ..i, Entities.XD_DarkWallStraightGate_Closed);
    end
end

function OpenGatesKerberos()
    for i= 1,6 do
        ReplaceEntity("P3Gate" ..i, Entities.XD_DarkWallStraightGate);
    end
end

function CloseGatesMary()
    for i= 1,3 do
        ReplaceEntity("P5Gate" ..i, Entities.XD_PalisadeGate1);
    end
end

function OpenGatesMary()
    for i= 1,3 do
        ReplaceEntity("P5Gate" ..i, Entities.XD_PalisadeGate2);
    end
end

function CloseGatesVarg()
    for i= 1,3 do
        ReplaceEntity("P4Gate" ..i, Entities.XD_PalisadeGate1);
    end
end

function OpenGatesVarg()
    for i= 1,3 do
        ReplaceEntity("P4Gate" ..i, Entities.XD_PalisadeGate2);
    end
end

-- Stuff -----------------------------------------------------------------------

-- Overwrite formation selection
function CustomTroopFomrationController(_ID)
    Stronghold.Unit:SetFormationOnCreate(_ID);
end

