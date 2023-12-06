SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 1,

    -- ###################################################################### --
    -- #                             CONFIG                                 # --
    -- ###################################################################### --

    -- Disable standard victory condition?
    -- (Game is not lost when the HQ falls)
    DisableDefaultWinCondition = false,
    -- Disable rule configuration?
    DisableRuleConfiguration = true;
    -- Disable game start timer?
    -- (Requires rule config to be disabled!)
    DisableGameStartTimer = true;

    -- Peacetime in minutes
    PeaceTime = 0,
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
    Resources = {[1] = {0, 500, 1000, 700, 550, 300, 0}},

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
        [Entities.CU_BlackKnight]        = true,
        -- Mary
        [Entities.CU_Mary_de_Mortfichet] = true,
        -- Varg
        [Entities.CU_Barbarian_Hero]     = true,
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
        UseWeatherSet("EuropeanWeatherSet");
        AddPeriodicSummer(360);
        AddPeriodicRain(90);

        Lib.Require("comfort/StartCountdown");
        Lib.Require("module/ai/AiArmy");
        Lib.Require("module/ai/AiArmyManager");
        Lib.Require("module/ai/AiArmyRefiller");
        Lib.Require("module/cinematic/BriefingSystem");
        Lib.Require("module/trigger/Job");

        ForbidTechnology(Technologies.B_Palisade, 1);
        ForbidTechnology(Technologies.B_Wall, 1);
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        BriefingSystem.SetMCButtonCount(8);
        BriefingSelectDifficulty();
        BriefingExposition();
        StartCheckVictoryCondition();
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
    end,
}

-- ########################################################################## --
-- #                               BRIEFING                                 # --
-- ########################################################################## --

function BriefingSelectDifficulty()
    local Briefing = {};
    local AP, ASP, AMC = BriefingSystem.AddPages(Briefing);

    AP {
        Name        = "ChoicePage",
        Title       = "map_sh_smalldale/BriefingSelectDifficulty_1_Title",
        Text        = "map_sh_smalldale/BriefingSelectDifficulty_1_Text",
        Target      = "HQ1",
        MC          = {
            {"map_sh_smalldale/BriefingSelectDifficulty_1_Option_1", "ChoseEasy"},
            {"map_sh_smalldale/BriefingSelectDifficulty_1_Option_2", "ChoseMedium"},
            {"map_sh_smalldale/BriefingSelectDifficulty_1_Option_3", "ChoseHard"},
            {"map_sh_smalldale/BriefingSelectDifficulty_1_Option_4", "ChoseManiac"},
        }
    }

    AP {
        Name        = "ChoseEasy",
        Title       = "map_sh_smalldale/BriefingSelectDifficulty_2_Title",
        Text        = "map_sh_smalldale/BriefingSelectDifficulty_2_Text",
        Target      = "HQ1",
    }
    AP("FaderPage");

    AP {
        Name        = "ChoseMedium",
        Title       = "map_sh_smalldale/BriefingSelectDifficulty_4_Title",
        Text        = "map_sh_smalldale/BriefingSelectDifficulty_4_Text",
        Target      = "HQ1",
    }
    AP("FaderPage");

    AP {
        Name        = "ChoseHard",
        Title       = "map_sh_smalldale/BriefingSelectDifficulty_6_Title",
        Text        = "map_sh_smalldale/BriefingSelectDifficulty_6_Text",
        Target      = "HQ1",
    }
    AP("FaderPage");

    AP {
        Name        = "ChoseManiac",
        Title       = "map_sh_smalldale/BriefingSelectDifficulty_8_Title",
        Text        = "map_sh_smalldale/BriefingSelectDifficulty_8_Text",
        Target      = "HQ1",
    }

    AP {
        Name        = "FaderPage",
        Target      = "HQ1",
        NoSkip      = true,
        FadeOut     = 3,
        Duration    = 3,
    }

    Briefing.Finished = function()
        local Selected = BriefingSystem.GetSelectedAnswer("ChoicePage", 1);
        if Selected == 1 then
            SetEasyDifficulty();
        elseif Selected == 2 then
            SetNormalDifficulty();
        elseif Selected == 3 then
            SetHardDifficulty();
        elseif Selected == 4 then
            SetManiacDifficulty();
        end
    end
    BriefingSystem.Start(1, "BriefingSelectDifficulty", Briefing);
end

function BriefingExposition()
    local Briefing = {
        NoSkip = false,
    };
    local AP, ASP, AMC = BriefingSystem.AddPages(Briefing);

    AP {
        Target      = "HQ5",
        NoSkip      = true,
        FadeIn      = 3,
        Duration    = 3,
    }
    AP {
        Title   = "map_sh_smalldale/BriefingExposition_1_Title",
        Text    = "map_sh_smalldale/BriefingExposition_1_Text",
        Target  = "HQ5",
        CloseUp = false,
    }
    AP {
        Title   = "map_sh_smalldale/BriefingExposition_2_Title",
        Text    = "map_sh_smalldale/BriefingExposition_2_Text",
        Target  = "HQ2",
        CloseUp = false,
    }
    AP {
        Title   = "map_sh_smalldale/BriefingExposition_3_Title",
        Text    = "map_sh_smalldale/BriefingExposition_3_Text",
        Target  = "HQ1",
        CloseUp = false,
    }
    AP {
        Target      = "HQ1",
        NoSkip      = true,
        FadeOut     = 3,
        Duration    = 3,
    }

    Briefing.Finished = function()
        local QuestTitle = XGUIEng.GetStringTableText("map_sh_smalldale/Quest_1_Title");
        local QuestText  = XGUIEng.GetStringTableText("map_sh_smalldale/Quest_1_Text");
        Logic.AddQuest(PlayerID, 1, MAINQUEST_OPEN, QuestTitle, QuestText, 1);

        StartAiPlayerAggressiveTimer();
        CreateAiPlayer2();
        CreateAiPlayer5();
    end
    BriefingSystem.Start(1, "BriefingExposition", Briefing);
end

function StartCheckVictoryCondition()
    Job.Second(function()
        if not IsExisting("HQ2") and not IsExisting("HQ5") then
            Logic.SetQuestType(1, 1, MAINQUEST_CLOSED, 1);
            Victory();
            return true;
        end
    end)
end

-- ########################################################################## --
-- #                              DIFFICULTY                                # --
-- ########################################################################## --

gv_Difficulty = {
    Level = 1,
    PassiveTime = 30*60,

    Player2 = {
        ArmySize = 3,
        ArmyAmount = 3,
        RespawnAmount = 1,
        RespawnTime = 180,
        Armies = {},
        Spawners = {},
        Types = {
            {Entities.PU_LeaderPoleArm1, 0},
            {Entities.PU_LeaderSword1, 0},
            {Entities.PU_LeaderBow1, 0},
        }
    },
    Player5 = {
        ArmySize = 3,
        ArmyAmount = 3,
        RespawnAmount = 1,
        RespawnTime = 180,
        Armies = {},
        Spawners = {},
        Types = {
            {Entities.PU_LeaderSword1, 0},
            {Entities.PU_LeaderCavalry1, 0},
        }
    }
}

function SetEasyDifficulty()
    gv_Difficulty.Level = 1;
    gv_Difficulty.PassiveTime = 50*60;

    gv_Difficulty.Player2.ArmySize = 4;
    gv_Difficulty.Player2.ArmyAmount = 4;
    gv_Difficulty.Player2.RespawnAmount = 1;
    gv_Difficulty.Player2.RespawnTime = 180;
    gv_Difficulty.Player2.Types = {
        {Entities.PU_LeaderPoleArm1, 0},
        {Entities.PU_LeaderSword1, 0},
        {Entities.PU_LeaderBow1, 0},
    };

    gv_Difficulty.Player5.ArmySize = 4;
    gv_Difficulty.Player5.ArmyAmount = 4;
    gv_Difficulty.Player5.RespawnAmount = 1;
    gv_Difficulty.Player5.RespawnTime = 180;
    gv_Difficulty.Player5.Types = {
        {Entities.PU_LeaderSword1, 0},
        {Entities.PU_LeaderCavalry1, 0},
    }
end

function SetNormalDifficulty()
    gv_Difficulty.Level = 2;
    gv_Difficulty.PassiveTime = 40*60;

    gv_Difficulty.Player2.ArmySize = 4;
    gv_Difficulty.Player2.ArmyAmount = 5;
    gv_Difficulty.Player2.RespawnAmount = 2;
    gv_Difficulty.Player2.RespawnTime = 135;
    gv_Difficulty.Player2.Types = {
        {Entities.PU_LeaderPoleArm2, 1},
        {Entities.PU_LeaderSword2, 1},
        {Entities.PU_LeaderBow2, 1},
        {Entities.PV_Cannon1, 1},
    };

    gv_Difficulty.Player5.ArmySize = 4;
    gv_Difficulty.Player5.ArmyAmount = 5;
    gv_Difficulty.Player5.RespawnAmount = 2;
    gv_Difficulty.Player5.RespawnTime = 135;
    gv_Difficulty.Player5.Types = {
        {Entities.PU_LeaderSword2, 1},
        {Entities.PU_LeaderHeavyCavalry1, 1},
        {Entities.PU_LeaderCavalry1, 1},
        {Entities.PV_Cannon1, 1},
    }
end

function SetHardDifficulty()
    gv_Difficulty.Level = 3;
    gv_Difficulty.PassiveTime = 35*60;

    gv_Difficulty.Player2.ArmySize = 6;
    gv_Difficulty.Player2.ArmyAmount = 7;
    gv_Difficulty.Player2.RespawnAmount = 3;
    gv_Difficulty.Player2.RespawnTime = 90;
    gv_Difficulty.Player2.Types = {
        {Entities.PU_LeaderPoleArm3, 2},
        {Entities.PU_LeaderSword3, 2},
        {Entities.PU_LeaderBow3, 2},
        {Entities.CV_Cannon1, 2},
    };

    gv_Difficulty.Player5.ArmySize = 6;
    gv_Difficulty.Player5.ArmyAmount = 7;
    gv_Difficulty.Player5.RespawnAmount = 3;
    gv_Difficulty.Player5.RespawnTime = 90;
    gv_Difficulty.Player5.Types = {
        {Entities.PU_LeaderSword3, 2},
        {Entities.PU_LeaderHeavyCavalry1, 2},
        {Entities.PU_LeaderCavalry2, 2},
        {Entities.CV_Cannon1, 2},
    }
end

function SetManiacDifficulty()
    gv_Difficulty.Level = 4;
    gv_Difficulty.PassiveTime = 30*60;

    gv_Difficulty.Player2.ArmySize = 8;
    gv_Difficulty.Player2.ArmyAmount = 10;
    gv_Difficulty.Player2.RespawnAmount = 4;
    gv_Difficulty.Player2.RespawnTime = 45;
    gv_Difficulty.Player2.Types = {
        {Entities.PU_LeaderPoleArm4, 3},
        {Entities.PU_LeaderSword4, 3},
        {Entities.PU_LeaderBow4, 3},
        {Entities.CV_Cannon2, 3},
    };

    gv_Difficulty.Player5.ArmySize = 8;
    gv_Difficulty.Player5.ArmyAmount = 10;
    gv_Difficulty.Player5.RespawnAmount = 4;
    gv_Difficulty.Player5.RespawnTime = 45;
    gv_Difficulty.Player5.Types = {
        {Entities.PU_LeaderSword4, 3},
        {Entities.PU_LeaderHeavyCavalry2, 3},
        {Entities.PU_LeaderCavalry2, 3},
        {Entities.CV_Cannon2, 3},
    }
end

-- ########################################################################## --
-- #                                PLAYERS                                 # --
-- ########################################################################## --

function StartAiPlayerAggressiveTimer()
    function MakeAiAggressive()
        for i= 1, table.getn(gv_Difficulty.Player2.Armies) do
            local ManagerID = gv_Difficulty.Player2.Armies[i];
            AiArmyManager.ForbidAttacking(ManagerID, false);
        end
        for i= 1, table.getn(gv_Difficulty.Player5.Armies) do
            local ManagerID = gv_Difficulty.Player5.Armies[i];
            AiArmyManager.ForbidAttacking(ManagerID, false);
        end

        Message("@color:209,52,52,255 Eure Feinde machen ihren Zug!");
        Sound.PlayQueuedFeedbackSound(Sounds.OnKlick_Select_kerberos, 100);
    end
    StartCountdown(gv_Difficulty.PassiveTime, MakeAiAggressive, true);
end

function CreateAiPlayer2()
    SetupAiPlayer(2, 0);
    local HomePosition = GetPosition("DoorP2");
    local SpawnerID;

    -- HQ spawner
    SpawnerID = AiArmyRefiller.CreateSpawner {
        ScriptName = "HQ2",
        SpawnPoint = "DoorP2",
        SpawnAmount = gv_Difficulty.Player2.RespawnAmount,
        SpawnTimer = gv_Difficulty.Player2.RespawnTime,
        AllowedTypes = gv_Difficulty.Player2.Types
    }
    table.insert(gv_Difficulty.Player2.Spawners, SpawnerID);

    -- Barracks spawner
    SpawnerID = AiArmyRefiller.CreateSpawner {
        ScriptName = "P2Barracks1",
        SpawnPoint = "P2Barracks1Spawn",
        SpawnAmount = gv_Difficulty.Player2.RespawnAmount,
        SpawnTimer = gv_Difficulty.Player2.RespawnTime,
        AllowedTypes = gv_Difficulty.Player2.Types
    }
    table.insert(gv_Difficulty.Player2.Spawners, SpawnerID);

    -- Archery spawner
    SpawnerID = AiArmyRefiller.CreateSpawner {
        ScriptName = "P2Archery1",
        SpawnPoint = "P2Archery1Spawn",
        SpawnAmount = gv_Difficulty.Player2.RespawnAmount,
        SpawnTimer = gv_Difficulty.Player2.RespawnTime,
        AllowedTypes = gv_Difficulty.Player2.Types
    }
    table.insert(gv_Difficulty.Player2.Spawners, SpawnerID);

    -- Tent spawners
    if gv_Difficulty.Level > 1 then
        for i= 1, 4 do
            SpawnerID = AiArmyRefiller.CreateSpawner {
                ScriptName = "P2Tent" ..i,
                SpawnAmount = gv_Difficulty.Player2.RespawnAmount,
                SpawnTimer = gv_Difficulty.Player2.RespawnTime,
                AllowedTypes = gv_Difficulty.Player2.Types
            }
            table.insert(gv_Difficulty.Player2.Spawners, SpawnerID);
        end
    end

    -- create armies
    for i= 1, gv_Difficulty.Player2.ArmyAmount do
        local ArmyID = AiArmy.New(2, gv_Difficulty.Player2.ArmySize, HomePosition, 3000);
        AiArmy.SetFormationController(ArmyID, CustomTroopFomrationController);
        local ManagerID = AiArmyManager.Create(ArmyID);

        AiArmyManager.AddAttackTarget(ManagerID, "AttackPos1");
        AiArmyManager.AddAttackTarget(ManagerID, "AttackPos2");
        AiArmyManager.AddAttackTarget(ManagerID, "AttackPos3");

        AiArmyManager.AddGuardPosition(ManagerID, "P2DefPos1");
        AiArmyManager.AddGuardPosition(ManagerID, "P2DefPos2");
        AiArmyManager.AddGuardPosition(ManagerID, "P2DefPos3");
        AiArmyManager.AddGuardPosition(ManagerID, "P2DefPos4");

        for j= 1, table.getn(gv_Difficulty.Player2.Spawners) do
            AiArmyRefiller.AddArmy(gv_Difficulty.Player2.Spawners[j], ArmyID);
        end

        AiArmyManager.ForbidAttacking(ManagerID, true);
        table.insert(gv_Difficulty.Player2.Armies, ManagerID);
    end
    AiArmyManager.Synchronize(unpack(gv_Difficulty.Player2.Armies));

    -- Remove resources
    Job.Destroy(function()
        local ID = Event.GetEntityID();
        if Logic.GetEntityName(ID) == "P2Mine1" then
            DestroyEntity("P2Pit1");
        end
        if Logic.GetEntityName(ID) == "P2Mine2" then
            DestroyEntity("P2Pit2");
        end
        if Logic.GetEntityName(ID) == "P2Mine3" then
            DestroyEntity("P2Pit3");
        end
        if Logic.GetEntityName(ID) == "P2Village1" then
            DestroyEntity("P2VillageSite1");
        end
    end);

    SetHostile(1,2);
end

function CreateAiPlayer5()
    SetupAiPlayer(5, 0);
    local HomePosition = GetPosition("P5DefPos4");
    local SpawnerID;

    -- HQ spawner
    SpawnerID = AiArmyRefiller.CreateSpawner {
        ScriptName = "HQ5",
        SpawnPoint = "DoorP5",
        SpawnAmount = gv_Difficulty.Player5.RespawnAmount,
        SpawnTimer = gv_Difficulty.Player5.RespawnTime,
        AllowedTypes = gv_Difficulty.Player5.Types
    }
    table.insert(gv_Difficulty.Player5.Spawners, SpawnerID);

    -- Stable spawner
    SpawnerID = AiArmyRefiller.CreateSpawner {
        ScriptName = "P5Stable1",
        SpawnPoint = "P5Stable1Spawn",
        SpawnAmount = gv_Difficulty.Player5.RespawnAmount,
        SpawnTimer = gv_Difficulty.Player5.RespawnTime,
        AllowedTypes = gv_Difficulty.Player5.Types
    }
    table.insert(gv_Difficulty.Player5.Spawners, SpawnerID);

    -- Tent spawners
    if gv_Difficulty.Level > 1 then
        for i= 1, 6 do
            SpawnerID = AiArmyRefiller.CreateSpawner {
                ScriptName = "P5Tent" ..i,
                SpawnAmount = gv_Difficulty.Player5.RespawnAmount,
                SpawnTimer = gv_Difficulty.Player5.RespawnTime,
                AllowedTypes = gv_Difficulty.Player5.Types
            }
            table.insert(gv_Difficulty.Player5.Spawners, SpawnerID);
        end
    end

    -- create armies
    for i= 1, gv_Difficulty.Player5.ArmyAmount do
        local ArmyID = AiArmy.New(5, gv_Difficulty.Player5.ArmySize, HomePosition, 3000);
        AiArmy.SetFormationController(ArmyID, CustomTroopFomrationController);
        local ManagerID = AiArmyManager.Create(ArmyID);

        AiArmyManager.AddAttackTarget(ManagerID, "AttackPos1");
        AiArmyManager.AddAttackTarget(ManagerID, "AttackPos2");
        AiArmyManager.AddAttackTarget(ManagerID, "AttackPos3");

        AiArmyManager.AddGuardPosition(ManagerID, "P5DefPos1");
        AiArmyManager.AddGuardPosition(ManagerID, "P5DefPos2");
        AiArmyManager.AddGuardPosition(ManagerID, "P5DefPos3");
        AiArmyManager.AddGuardPosition(ManagerID, "P5DefPos4");

        for j= 1, table.getn(gv_Difficulty.Player5.Spawners) do
            AiArmyRefiller.AddArmy(gv_Difficulty.Player5.Spawners[j], ArmyID);
        end

        AiArmyManager.ForbidAttacking(ManagerID, true);
        table.insert(gv_Difficulty.Player5.Armies, ManagerID);
    end
    AiArmyManager.Synchronize(unpack(gv_Difficulty.Player5.Armies));

    -- Remove resources
    Job.Destroy(function()
        local ID = Event.GetEntityID();
        if Logic.GetEntityName(ID) == "P5Mine1" then
            DestroyEntity("P5Pit1");
        end
        if Logic.GetEntityName(ID) == "P5Mine2" then
            DestroyEntity("P5Pit2");
        end
        if Logic.GetEntityName(ID) == "P5Village1" then
            DestroyEntity("P5VillageSite1");
        end
    end);

    SetHostile(1,5);
end

-- Overwrite formation selection
function CustomTroopFomrationController(_ID)
    Stronghold.Unit:SetFormationOnCreate(_ID);
end

