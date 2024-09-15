SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 1,

    -- ###################################################################### --
    -- #                             CONFIG                                 # --
    -- ###################################################################### --

    -- Disable standard victory condition?
    DisableDefaultWinCondition = true,
    -- Disable rule configuration?
    DisableRuleConfiguration = true,

    -- Peacetime in minutes (only needed for fixed peacetimes or singleplayer)
    PeaceTime = 0,

    -- Fill resource piles with resources
    -- (Entities with scriptnames are ignored. Set to 0 to deactivate.)
    MapStartFillClay = 1000,
    MapStartFillStone = 1000,
    MapStartFillIron = 500,
    MapStartFillSulfur = 500,
    MapStartFillWood = 20000,

    -- Rank
    Rank = {
        Initial = 0,
        Final = 7,
    },

    -- Resources
    -- {Honor, Gold, Clay, Wood, Stone, Iron, Sulfur}
    Resources = {
        [1] = {  0,    0,    0,    0,    0,    0,    0},
        -- unbenutzt
        [2] = { 50, 2000, 2400, 3000, 1100,  600,    0},
        [3] = {300, 8000, 4800, 6000, 3300, 1800,  900},
    },

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
        LocalMusic.UseSet = EUROPEMUSIC;
        AddPeriodicSummer(490);
        AddPeriodicRain(60);
        AddPeriodicSummer(120);
        AddPeriodicRain(60);
        AddPeriodicWinter(500);
        AddPeriodicRain(60);

        ReplaceEntity("DrawBridge1", Entities.XD_DrawBridgeOpen1);
        ReplaceEntity("Isabella1", Entities.XD_ScriptEntity);
        MakeInvulnerable(GetID("ImposterMayor5"));

        Lib.Require("comfort/MoveAndVanish");
        Lib.Require("comfort/StartCountdown");
        Lib.Require("module/entity/EntityMover");
        Lib.Require("module/cinematic/BriefingSystem");
        Lib.Require("module/io/NonPlayerCharacter");
        Lib.Require("module/io/NonPlayerMerchant");
        BriefingSystem.SetMCButtonCount(8);

        Difficulty_Selected = 0;
        Difficulty_NetEvent = Syncer.CreateEvent(function(_PlayerID, _Selected)
            Difficulty_Selected = _Selected;
        end);
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        SetPlayerName(5, XGUIEng.GetStringTableText("map_sh_midsummerrevolution/Player5Name"));
        SetPlayerName(7, XGUIEng.GetStringTableText("map_sh_midsummerrevolution/Player7Name"));

        ForbidTechnology(Technologies.B_Mercenary, 1);
        ForbidTechnology(Technologies.B_Mercenary, 2);
        Logic.PlayerReAttachAllWorker(8);

        SetFriendly(1, 2);

        SetNeutral(1, 3);
        SetNeutral(1, 4);
        SetNeutral(1, 5);
        SetNeutral(1, 7);
        SetNeutral(2, 3);
        SetNeutral(2, 4);
        SetNeutral(2, 5);
        SetNeutral(2, 7);

        Main1Quest_Init();
        Difficulty_BriefingSelectDifficulty();
        Main1Quest_BriefingIntro();
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
    end,
}

-- ########################################################################## --
-- #                               CHEAT FOES                               # --
-- ########################################################################## --

function KillPlayer3()
    DestroyEntity("HQ3");
end

function KillPlayer4()
    DestroyEntity("HQ4");
end

function KillPlayer5()
    DestroyEntity("ImposterMayor5");
    DestroyEntity("P5_BC1");
    DestroyEntity("P5_AC1");
    DestroyEntity("P5_ST1");
    DestroyEntity("P5_FD1");
end

function KillPlayer6_1()
    DestroyEntity("P6CTBastille1");
    DestroyEntity("P6CTBastille2");
    DestroyEntity("P6CTBastille3");
    DestroyEntity("P6CTBastille4");
    DestroyEntity("P6CTBastille5");
end

function KillPlayer6_2()
    DestroyEntity("P6LRBastille1");
    DestroyEntity("P6LRBastille2");
    DestroyEntity("P6LRBastille3");
    DestroyEntity("P6LRBastille4");
    DestroyEntity("P6LRBastille5");
    DestroyEntity("P6RRBastille1");
    DestroyEntity("P6RRBastille2");
    DestroyEntity("P6RRBastille3");
    DestroyEntity("P6RRBastille4");
    DestroyEntity("P6RRBastille5");
end

function KillPlayer6_3()
    DestroyEntity("HQ6");
end

-- ########################################################################## --
-- #                               DIFFICULTY                               # --
-- ########################################################################## --

Difficulty_InitialPeaceTime = 50*60;
Difficulty_Selected = 1;

function Difficulty_SetEasy()
    AddHonor(1, 15);
    Tools.GiveResouces(1, 1000, 1200, 1500, 550, 300, 0);
    AddHonor(2, 15);
    Tools.GiveResouces(2, 1000, 1200, 1500, 550, 300, 0);

    -- For testing
    -- Difficulty_InitialPeaceTime = 1*60;
    -- ReplaceEntity("VC_Blockade", Entities.XD_ScriptEntity);
end

function Difficulty_SetNormal()
    Tools.GiveResouces(1, 900, 1000, 1200, 550, 0, 0);
    Tools.GiveResouces(2, 900, 1000, 1200, 550, 0, 0);

    Difficulty_InitialPeaceTime = 40*60;
    Difficulty_Selected = 2;
end

function Difficulty_SetHard()
    Tools.GiveResouces(1, 750, 900, 1000, 0, 0, 0);
    Tools.GiveResouces(2, 750, 900, 1000, 0, 0, 0);

    Difficulty_InitialPeaceTime = 30*60;
    Difficulty_Selected = 3;
end

function Difficulty_SetManiac()
    Tools.GiveResouces(1, 600, 750, 900, 0, 0, 0);
    Tools.GiveResouces(2, 600, 750, 900, 0, 0, 0);

    Difficulty_InitialPeaceTime = 30*60;
    Difficulty_Selected = 4;
end

function Difficulty_BriefingSelectDifficulty()
    local HostPlayerID = Syncer.GetHostPlayerID();
    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
    };
    local AP, ASP, AMC = BriefingSystem.AddPages(Briefing);

    AP {
        Name        = "ChoicePage",
        Title       = "map_sh_midsummerrevolution/BriefingSelectDifficulty_1_Title",
        Text        = "map_sh_midsummerrevolution/BriefingSelectDifficulty_1_Text",
        TitleAlter  = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_1_Title",
        TextAlter   = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_1_Text",
        Target      = "HQ1",
        MC          = {
            {"map_sh_midsummerrevolution/BriefingSelectDifficulty_1_Option_1", "ChoseEasy"},
            {"map_sh_midsummerrevolution/BriefingSelectDifficulty_1_Option_2", "ChoseMedium"},
            {"map_sh_midsummerrevolution/BriefingSelectDifficulty_1_Option_3", "ChoseHard"},
            {"map_sh_midsummerrevolution/BriefingSelectDifficulty_1_Option_4", "ChoseManiac"},
        }
    }

    AP {
        Name        = "ChoseEasy",
        Title       = "map_sh_midsummerrevolution/BriefingSelectDifficulty_2_Title",
        Text        = "map_sh_midsummerrevolution/BriefingSelectDifficulty_2_Text",
        TitleAlter  = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_2_Title",
        TextAlter   = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_2_Text",
        Target      = "HQ1",
        NoSkip      = true,
        Duration    = 10,
    }
    AP("FaderPage");

    AP {
        Name        = "ChoseMedium",
        Title       = "map_sh_midsummerrevolution/BriefingSelectDifficulty_4_Title",
        Text        = "map_sh_midsummerrevolution/BriefingSelectDifficulty_4_Text",
        TitleAlter  = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_4_Title",
        TextAlter   = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_4_Text",
        Target      = "HQ1",
        NoSkip      = true,
        Duration    = 10,
    }
    AP("FaderPage");

    AP {
        Name        = "ChoseHard",
        Title       = "map_sh_midsummerrevolution/BriefingSelectDifficulty_6_Title",
        Text        = "map_sh_midsummerrevolution/BriefingSelectDifficulty_6_Text",
        TitleAlter  = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_6_Title",
        TextAlter   = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_6_Text",
        Target      = "HQ1",
        NoSkip      = true,
        Duration    = 10,
    }
    AP("FaderPage");

    AP {
        Name        = "ChoseManiac",
        Title       = "map_sh_midsummerrevolution/BriefingSelectDifficulty_8_Title",
        Text        = "map_sh_midsummerrevolution/BriefingSelectDifficulty_8_Text",
        TitleAlter  = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_8_Title",
        TextAlter   = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_8_Text",
        Target      = "HQ1",
        NoSkip      = true,
        Duration    = 10,
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
        Syncer.InvokeEvent(Difficulty_NetEvent, Selected);
    end
    BriefingSystem.Start(HostPlayerID, "BriefingSelectDifficulty", Briefing, 1, 2);
end

-- ########################################################################## --
-- #                                 ENEMY                                  # --
-- ########################################################################## --

-- Player 6 --------------------------------------------------------------------

Enemy_Player6_BuildingPositions = {};
Enemy_Player6_Stage = 1;
Enemy_Player6_IsDefeated = 0;

-- Spawners --

-- Creates the first stage of the final enemy.
function Enemy_InitPlayer6_1()
    SetupAiPlayer(6, 0, 0);

    Enemy_Player6_Stage = 1;

    local Strength = 6 + (3 * (Difficulty_Selected -1));
    local RespawnTime = math.ceil(180 / (Difficulty_Selected ^ (1.2)));

    local AllowedUnitsBastille = {
        Entities.CU_BlackKnight_LeaderMace2,
        Entities.PU_LeaderPoleArm3,
        Entities.PV_Cannon2,
        Entities.PU_LeaderBow3,
        Entities.CU_BlackKnight_LeaderMace2,
        Entities.PU_LeaderBow3
    };
    if Difficulty_Selected >= 3 then
        AllowedUnitsBastille = {
            Entities.PU_LeaderPoleArm4,
            Entities.CU_BlackKnight_LeaderMace1,
            Entities.PV_Cannon2,
            Entities.PU_LeaderBow4,
            Entities.CU_BlackKnight_LeaderMace1,
            Entities.PU_LeaderBow4,
            Entities.PV_Cannon2,
        };
    end

    Enemy_Player6Camp1 = DelinquentsCampCreate {
        PlayerID     = 6,
        HomePosition = "P6DefPos1",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player6Camp1, "P6CTBastille1", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp1, "P6CTBastille2", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp1, "P6CTBastille3", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp1, "P6CTBastille4", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp1, "P6CTBastille5", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddGuardPositions(Enemy_Player6Camp1, "P6DefPos1", "P6DefPos2");
    DelinquentsCampAddTarget(
        Enemy_Player6Camp1,
        "SBWP2", "P3DefPos1", "SBWP1", "SWP1", "SWP2","SWP3", "SWP4", "SWP5",
        "Player1Home", "NWP6", "NWP5", "Player2Home"
    );

    Enemy_Player6Camp2 = DelinquentsCampCreate {
        PlayerID     = 6,
        HomePosition = "P6DefPos2",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player6Camp2, "P6CTBastille1", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp2, "P6CTBastille2", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp2, "P6CTBastille3", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp2, "P6CTBastille4", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp2, "P6CTBastille5", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddGuardPositions(Enemy_Player6Camp2, "P6DefPos1", "P6DefPos2");
    DelinquentsCampAddTarget(
        Enemy_Player6Camp2,
        "NBWP2", "P3DefPos2", "NBWP1", "NWP1", "NWP2", "NWP3", "NWP4", "NWP5",
        "Player2Home", "NWP5", "NWP6", "SWP4", "SWP5", "Player1Home"
    );

    DelinquentsCampActivateAttack(Enemy_Player6Camp1, true);
    DelinquentsCampActivateAttack(Enemy_Player6Camp2, true);

    Job.Second(Enemy_Player6_CheckPlayerDefeated);
end

-- Creates the second stage of the final enemy.
function Enemy_InitPlayer6_2()
    Enemy_Player6_Stage = 2;

    local Strength = 6 + (2 * (Difficulty_Selected -1));
    local RespawnTime = math.ceil(180 / (Difficulty_Selected ^ (1.2)));

    local AllowedUnitsBastille = {
        Entities.CU_BlackKnight_LeaderMace2,
        Entities.PU_LeaderPoleArm3,
        Entities.PV_Cannon4,
        Entities.PU_LeaderHeavyCavalry1,
        Entities.PU_LeaderHeavyCavalry1,
        Entities.PU_LeaderBow3,
        Entities.PV_Cannon3,
        Entities.CU_BlackKnight_LeaderMace2,
        Entities.PU_LeaderBow3,
    };
    if Difficulty_Selected >= 3 then
        AllowedUnitsBastille = {
            Entities.PU_LeaderPoleArm4,
            Entities.PV_Cannon4,
            Entities.CU_BlackKnight_LeaderMace1,
            Entities.PU_LeaderHeavyCavalry2,
            Entities.PU_LeaderBow4,
            Entities.CV_Cannon2,
            Entities.PU_LeaderHeavyCavalry2,
            Entities.CU_BlackKnight_LeaderMace1,
            Entities.PU_LeaderBow4,
        };
    end

    Enemy_Player6Camp3 = DelinquentsCampCreate {
        PlayerID     = 6,
        HomePosition = "P6DefPos3",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player6Camp3, "P6LRBastille1", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp3, "P6LRBastille2", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp3, "P6LRBastille3", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp3, "P6LRBastille4", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp3, "P6LRBastille5", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddGuardPositions(Enemy_Player6Camp3, "P2DefPos3", "P2DefPos4");
    DelinquentsCampAddTarget(
        Enemy_Player6Camp3,
        "P2DefPos3", "SBWP2", "P3DefPos1", "SBWP1", "SWP1", "SWP2", "SWP3",
        "SWP4", "SWP5", "Player1Home", "NWP6", "NWP5", "Player2Home"
    );

    Enemy_Player6Camp4 = DelinquentsCampCreate {
        PlayerID     = 6,
        HomePosition = "P6DefPos4",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player6Camp4, "P6LRBastille1", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp4, "P6LRBastille2", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp4, "P6LRBastille3", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp4, "P6LRBastille4", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp4, "P6LRBastille5", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddGuardPositions(Enemy_Player6Camp4, "P2DefPos3", "P2DefPos4");
    DelinquentsCampAddTarget(
        Enemy_Player6Camp4,
        "P2DefPos3", "SBWP2", "P3DefPos1", "SBWP1", "SWP1", "SWP2", "SWP3",
        "SWP4", "SWP5", "Player1Home", "NWP6", "NWP5", "Player2Home"
    );

    Enemy_Player6Camp5 = DelinquentsCampCreate {
        PlayerID     = 6,
        HomePosition = "P6DefPos5",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player6Camp5, "P6RRBastille1", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp5, "P6RRBastille2", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp5, "P6RRBastille3", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp5, "P6RRBastille4", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp5, "P6RRBastille5", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddGuardPositions(Enemy_Player6Camp5, "P2DefPos5", "P2DefPos6");
    DelinquentsCampAddTarget(
        Enemy_Player6Camp5,
        "P2DefPos5", "NBWP2", "P3DefPos2", "NBWP1", "NWP1","NWP2", "NWP3",
        "NWP4", "NWP5", "Player2Home", "NWP5", "NWP6", "SWP4", "SWP5",
        "Player1Home"
    );

    Enemy_Player6Camp6 = DelinquentsCampCreate {
        PlayerID     = 6,
        HomePosition = "P6DefPos6",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player6Camp6, "P6RRBastille1", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp6, "P6RRBastille2", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp6, "P6RRBastille3", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp6, "P6RRBastille4", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player6Camp6, "P6RRBastille5", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddGuardPositions(Enemy_Player6Camp6, "P2DefPos5", "P2DefPos6");
    DelinquentsCampAddTarget(
        Enemy_Player6Camp6,
        "P2DefPos5", "NBWP2", "P3DefPos2", "NBWP1", "NWP1", "NWP2", "NWP3",
        "NWP4", "NWP5", "Player2Home", "NWP5", "NWP6", "SWP4", "SWP5",
        "Player1Home"
    );

    DelinquentsCampActivateAttack(Enemy_Player6Camp3, true);
    DelinquentsCampActivateAttack(Enemy_Player6Camp4, true);
    DelinquentsCampActivateAttack(Enemy_Player6Camp5, true);
    DelinquentsCampActivateAttack(Enemy_Player6Camp6, true);

    Enemy_Player6_SaveSpawnerBuildings_2_1();
    Enemy_Player6_SaveSpawnerBuildings_2_2();
    -- To make player 6 not too boring...
    if Difficulty_Selected >= 2 then
        Job.Second(Enemy_Player6_RestoreSpawnersInFog_2_1);
        Job.Second(Enemy_Player6_RestoreSpawnersInFog_2_2);
    end
end

-- Creates the third stage of the final enemy.
function Enemy_InitPlayer6_3()
    Enemy_Player6_Stage = 3;

    local Strength = 16 + (4 * (Difficulty_Selected -1));
    local RespawnTime = math.ceil(180 / (Difficulty_Selected ^ (1.2)));

    local AllowedUnitsCastle = {
        Entities.CU_BlackKnight_LeaderMace2,
        Entities.PU_LeaderPoleArm3,
        Entities.PV_Cannon3,
        Entities.PU_LeaderBow3,
        Entities.PU_LeaderRifle1,
        Entities.CU_BlackKnight_LeaderMace2,
        Entities.PU_LeaderBow3,
        Entities.PU_LeaderRifle1,
        Entities.PV_Cannon3,
    };
    if Difficulty_Selected >= 3 then
        AllowedUnitsCastle = {
            Entities.PU_LeaderPoleArm4,
            Entities.CU_BlackKnight_LeaderMace1,
            Entities.CV_Cannon2,
            Entities.PU_LeaderBow4,
            Entities.PU_LeaderRifle2,
            Entities.CU_BlackKnight_LeaderMace1,
            Entities.PU_LeaderBow4,
            Entities.PU_LeaderRifle2,
            Entities.CV_Cannon2
        };
    end

    Enemy_Player6Camp7 = DelinquentsCampCreate {
        PlayerID     = 6,
        HomePosition = "DoorP6",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player6Camp7, "HQ6", RespawnTime, 2, unpack(AllowedUnitsCastle));
    DelinquentsCampAddGuardPositions(Enemy_Player6Camp7, "DoorP6", "P6DefPos7");
    DelinquentsCampAddTarget(
        Enemy_Player6Camp7,
        "P2DefPos5", "P2DefPos3", "SBWP2", "P3DefPos1", "SBWP1", "SWP1", "SWP2",
        "SWP3", "SWP4", "SWP5", "Player1Home", "NWP6", "NWP5", "Player2Home"
    );

    Enemy_Player6Camp8 = DelinquentsCampCreate {
        PlayerID     = 6,
        HomePosition = "DoorP6",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player6Camp8, "HQ6", RespawnTime, 2, unpack(AllowedUnitsCastle));
    DelinquentsCampAddGuardPositions(Enemy_Player6Camp8, "DoorP6", "P6DefPos8");
    DelinquentsCampAddTarget(
        Enemy_Player6Camp8,
        "P2DefPos6", "P2DefPos5", "NBWP2", "P3DefPos2", "NBWP1", "NWP1", "NWP2",
        "NWP3", "NWP4", "NWP5", "Player2Home", "NWP5", "NWP6", "SWP4", "SWP5",
        "Player1Home"
    );

    DelinquentsCampActivateAttack(Enemy_Player6Camp7, true);
    DelinquentsCampActivateAttack(Enemy_Player6Camp8, true);

    Enemy_Player6_SaveSpawnerBuildings_2_3();
    -- To make player 6 not too boring...
    if Difficulty_Selected >= 1 then
        Job.Second(Enemy_Player6_RestoreSpawnersInFog_2_3);
    end
end

-- Checks on HQ and deactivates final spawners.
function Enemy_Player6_CheckPlayerDefeated()
    if not IsExisting("HQ6") then
        DelinquentsCampDestroy(Enemy_Player6Camp1);
        DelinquentsCampDestroy(Enemy_Player6Camp2);
        DelinquentsCampDestroy(Enemy_Player6Camp3);
        DelinquentsCampDestroy(Enemy_Player6Camp4);
        DelinquentsCampDestroy(Enemy_Player6Camp5);
        DelinquentsCampDestroy(Enemy_Player6Camp6);
        DelinquentsCampDestroy(Enemy_Player6Camp7);
        DelinquentsCampDestroy(Enemy_Player6Camp8);

        for ScriptName, _ in pairs(Enemy_Player6_BuildingPositions[1]) do
            SetHealth(ScriptName, 0);
        end
        for ScriptName, _ in pairs(Enemy_Player6_BuildingPositions[2]) do
            SetHealth(ScriptName, 0);
        end
        for ScriptName, _ in pairs(Enemy_Player6_BuildingPositions[3]) do
            SetHealth(ScriptName, 0);
        end
        DestroyEntity("LordP6");

        Enemy_Player6_IsDefeated = 1;
        return true;
    end
end

-- Stage Starters --

function Enemy_Player6_StartStage1()
    if Enemy_Player4_IsDefeated == 1 and Enemy_Player3_IsDefeated == 1 then
        for i= 1, 5 do
            ChangePlayer("P6CTBastille" ..i, 6);
        end
        for i= 1, 7 do
            ChangePlayer("P6CTTower" ..i, 6);
        end
        Enemy_InitPlayer6_1();

        ReplaceEntity("P6MG1", Entities.XD_DarkWallStraightGate);
        ReplaceEntity("P6MG2", Entities.XD_DarkWallStraightGate);
        ReplaceEntity("P3LG2", Entities.XD_DarkWallStraightGate);
        ReplaceEntity("P4RG2", Entities.XD_DarkWallStraightGate);
        DestroyEntity("P6Barrier1");
        DestroyEntity("P6Barrier2");
        SetHostile(1,6);
        SetHostile(2,6);

        Job.Second(Enemy_Player6_StartStage2);
        return true;
    end
end

function Enemy_Player6_StartStage2()
    local Fulfulled = true;
    for i= 1, 5 do
        if IsExisting("P6CTBastille" ..i) then
            Fulfulled = false;
            break;
        end
    end
    if Fulfulled then
        for i= 1, 5 do
            ChangePlayer("P6RRBastille" ..i, 6);
            ChangePlayer("P6LRBastille" ..i, 6);
        end
        for i= 1, 8 do
            ChangePlayer("P6RRTower" ..i, 6);
            ChangePlayer("P6LRTower" ..i, 6);
        end
        Enemy_InitPlayer6_2();

        ReplaceEntity("P6RG1", Entities.XD_DarkWallStraightGate);
        ReplaceEntity("P6LG1", Entities.XD_DarkWallStraightGate);

        Job.Second(Enemy_Player6_StartStage3);
        return true;
    end
end

function Enemy_Player6_StartStage3()
    local Fulfulled = true;
    for i= 1, 5 do
        if IsExisting("P6RRBastille" ..i) or IsExisting("P6LRBastille" ..i) then
            Fulfulled = false;
            break;
        end
    end
    if Fulfulled then
        for i= 1, 16 do
            ChangePlayer("P6FITower" ..i, 6);
        end
        Enemy_InitPlayer6_3();

        ReplaceEntity("P6MG3", Entities.XD_DarkWallStraightGate);
        ReplaceEntity("P6MG4", Entities.XD_DarkWallStraightGate);
        ReplaceEntity("P6LG2", Entities.XD_DarkWallStraightGate);
        ReplaceEntity("P6RG2", Entities.XD_DarkWallStraightGate);
        ReplaceEntity("P6FG1", Entities.XD_DarkWallStraightGate);
        ReplaceEntity("P6FG2", Entities.XD_DarkWallStraightGate);
        return true;
    end
end

-- Rebuilding --

-- Saves the buildings of the left wing.
function Enemy_Player6_SaveSpawnerBuildings_2_1()
    local Buildings = {
        "P6LRBastille1", "P6LRBastille2", "P6LRBastille3", "P6LRBastille4",
        "P6LRBastille5", "P6LRTower1", "P6LRTower2", "P6LRTower3", "P6LRTower4",
        "P6LRTower5", "P6LRTower6", "P6LRTower7", "P6LRTower8",
    };

    Enemy_Player6_BuildingPositions[1] = {};
    for _,ScriptName in pairs(Buildings) do
        local Position = GetPosition(ScriptName);
        local Type = Logic.GetEntityType(GetID(ScriptName));
        local Orientation = Logic.GetEntityOrientation(GetID(ScriptName));
        Enemy_Player6_BuildingPositions[1][ScriptName] = {
            Position.X, Position.Y, Type, Orientation
        };
    end
end

-- Restores the buildings of the left wing as long as HQ exists.
function Enemy_Player6_RestoreSpawnersInFog_2_1()
    -- End job after buildings are killed
    if not IsExisting("HQ6") then
        return true;
    end
    -- Restore buildings in fog
    for ScriptName, Data in pairs(Enemy_Player6_BuildingPositions[1]) do
        if not IsExisting(ScriptName) then
            if  Logic.IsMapPositionExplored(1, Data[1], Data[2]) == 0
            and Logic.IsMapPositionExplored(2, Data[1], Data[2]) == 0 then
                local ID = Logic.CreateEntity(Data[3], Data[1], Data[2], Data[4], 5);
                Logic.SetEntityName(ID, ScriptName);
            end
        end
    end
end

-- Saves the buildings of the right wing.
function Enemy_Player6_SaveSpawnerBuildings_2_2()
    local Buildings = {
        "P6RRBastille1", "P6RRBastille2", "P6RRBastille3", "P6RRBastille4",
        "P6RRBastille5", "P6RRTower1", "P6RRTower2", "P6RRTower3", "P6RRTower4",
        "P6RRTower5", "P6RRTower6", "P6RRTower7", "P6RRTower8",
    };

    Enemy_Player6_BuildingPositions[2] = {};
    for _,ScriptName in pairs(Buildings) do
        local Position = GetPosition(ScriptName);
        local Type = Logic.GetEntityType(GetID(ScriptName));
        local Orientation = Logic.GetEntityOrientation(GetID(ScriptName));
        Enemy_Player6_BuildingPositions[2][ScriptName] = {
            Position.X, Position.Y, Type, Orientation
        };
    end
end

-- Restores the buildings of the right wing as long as HQ exists.
function Enemy_Player6_RestoreSpawnersInFog_2_2()
    -- End job after buildings are killed
    if not IsExisting("HQ6") then
        return true;
    end
    -- Restore buildings in fog
    for ScriptName, Data in pairs(Enemy_Player6_BuildingPositions[2]) do
        if not IsExisting(ScriptName) then
            if  Logic.IsMapPositionExplored(1, Data[1], Data[2]) == 0
            and Logic.IsMapPositionExplored(2, Data[1], Data[2]) == 0 then
                local ID = Logic.CreateEntity(Data[3], Data[1], Data[2], Data[4], 5);
                Logic.SetEntityName(ID, ScriptName);
            end
        end
    end
end

-- Saves the buildings of the right wing.
function Enemy_Player6_SaveSpawnerBuildings_2_3()
    local Buildings = {
        "P6FITower1", "P6FITower2", "P6FITower3", "P6FITower4", "P6FITower5", "P6FITower6", 
        "P6FITower7", "P6FITower8", "P6FITower9", "P6FITower10", "P6FITower11", "P6FITower12", 
        "P6FITower13", "P6FITower14", "P6FITower15", "P6FITower16"
    };

    Enemy_Player6_BuildingPositions[3] = {};
    for _,ScriptName in pairs(Buildings) do
        local Position = GetPosition(ScriptName);
        local Type = Logic.GetEntityType(GetID(ScriptName));
        local Orientation = Logic.GetEntityOrientation(GetID(ScriptName));
        Enemy_Player6_BuildingPositions[3][ScriptName] = {
            Position.X, Position.Y, Type, Orientation
        };
    end
end

-- Restores the buildings of the right wing as long as HQ exists.
function Enemy_Player6_RestoreSpawnersInFog_2_3()
    -- End job after buildings are killed
    if not IsExisting("HQ6") then
        return true;
    end
    -- Restore buildings in fog
    for ScriptName, Data in pairs(Enemy_Player6_BuildingPositions[3]) do
        if not IsExisting(ScriptName) then
            if  Logic.IsMapPositionExplored(1, Data[1], Data[2]) == 0
            and Logic.IsMapPositionExplored(2, Data[1], Data[2]) == 0 then
                local ID = Logic.CreateEntity(Data[3], Data[1], Data[2], Data[4], 5);
                Logic.SetEntityName(ID, ScriptName);
            end
        end
    end
end

-- Player 3 --------------------------------------------------------------------

Enemy_Player3_BuildingPositions = {};
Enemy_Player3_IsDefeated = 0;

function Enemy_InitPlayer3()
    SetupAiPlayer(3, 0, 0);

    local Strength = 8 + (3 * (Difficulty_Selected -1));
    local RespawnTime = math.ceil(180 / (Difficulty_Selected ^ (1.2)));

    local AllowedUnitsBastille = {
        Entities.CU_Barbarian_LeaderClub2,
        Entities.PU_LeaderPoleArm3,
        Entities.PV_Cannon4,
        Entities.PU_LeaderBow3,
        Entities.CU_Barbarian_LeaderClub2,
    };
    if Difficulty_Selected >= 3 then
        AllowedUnitsBastille = {
            Entities.PU_LeaderPoleArm4,
            Entities.CU_Barbarian_LeaderClub1,
            Entities.PV_Cannon4,
            Entities.PU_LeaderBow4,
            Entities.CU_Barbarian_LeaderClub1,
            Entities.PV_Cannon4,
        };
    end

    local AllowedUnitsHQ = {
        Entities.PU_LeaderCavalry1,
        Entities.PU_LeaderHeavyCavalry1,
        Entities.PV_Cannon3,
        Entities.PU_LeaderCavalry1,
        Entities.PU_LeaderBow3,
    };
    if Difficulty_Selected >= 3 then
        AllowedUnitsHQ = {
            Entities.PU_LeaderCavalry2,
            Entities.PV_Cannon7,
            Entities.PU_LeaderHeavyCavalry2,
            Entities.PU_LeaderBow4,
        };
    end

    Enemy_Player3Camp1 = DelinquentsCampCreate {
        PlayerID     = 3,
        HomePosition = "P3DefPos1",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player3Camp1, "P3Bastille1", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player3Camp1, "P3Bastille2", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player3Camp1, "P3Bastille3", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player3Camp1, "HQ3", RespawnTime, 3, unpack(AllowedUnitsHQ));
    DelinquentsCampAddGuardPositions(Enemy_Player3Camp1, "P3DefPos1", "P3DefPos2");
    DelinquentsCampAddTarget(
        Enemy_Player3Camp1,
        "P3DefPos2", "SBWP1", "SWP1", "SWP2", "SWP3", "SWP4", "SWP5",
        "Player1Home", "NWP6", "NWP5", "Player2Home"
    );
    DelinquentsCampActivateAttack(Enemy_Player3Camp1, true);

    Job.Second(Enemy_Player3_CheckIsDefeated);
    Enemy_Player3_SaveSpawnerBuildings();
    -- To make player 3 not too boring...
    if Difficulty_Selected >= 4 then
        Job.Second(Enemy_Player3_RestoreSpawnersInFog);
    end
end

function Enemy_Player3_SaveSpawnerBuildings()
    for _,ScriptName in pairs{"P3Bastille1","P3Bastille2","P3Bastille3"} do
        local Position = GetPosition(ScriptName);
        local Type = Logic.GetEntityType(GetID(ScriptName));
        local Orientation = Logic.GetEntityOrientation(GetID(ScriptName));
        Enemy_Player3_BuildingPositions[ScriptName] = {
            Position.X, Position.Y, Type, Orientation
        };
    end
end

function Enemy_Player3_CheckIsDefeated()
    if (not IsExisting("HQ3")) then
        DelinquentsCampDestroy(Enemy_Player3Camp1);
        for ScriptName, _ in pairs(Enemy_Player3_BuildingPositions) do
            SetHealth(ScriptName, 0);
        end
        DestroyEntity("LordP3");
        Enemy_Player3_IsDefeated = 1;

        local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/Player3Defeated");
        Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
        Message(Msg);
        return true;
    end
end

function Enemy_Player3_RestoreSpawnersInFog()
    -- End job after HQ is killed
    if Enemy_Player3_IsDefeated == 1 then
        return true;
    end
    -- Restore buildings in fog
    for ScriptName, Data in pairs(Enemy_Player3_BuildingPositions) do
        if not IsExisting(ScriptName) then
            if  Logic.IsMapPositionExplored(1, Data[1], Data[2]) == 0
            and Logic.IsMapPositionExplored(2, Data[1], Data[2]) == 0 then
                local ID = Logic.CreateEntity(Data[3], Data[1], Data[2], Data[4], 5);
                Logic.SetEntityName(ID, ScriptName);
            end
        end
    end
end

function Enemy_Player3_State1()
    for i= 1, 3 do
        ChangePlayer("P3Bastille" ..i, 3);
    end
    for i= 1, 6 do
        ChangePlayer("P3Tower" ..i, 3);
    end
    Enemy_InitPlayer3();

    ReplaceEntity("P3LG1", Entities.XD_DarkWallStraightGate);
    SetHostile(1,3);
    SetHostile(2,3);
end

-- Player 4 --------------------------------------------------------------------

Enemy_Player4_BuildingPositions = {};
Enemy_Player4_IsDefeated = 0;

function Enemy_InitPlayer4()
    SetupAiPlayer(4, 0, 0);

    local Strength = 8 + (3 * (Difficulty_Selected -1));
    local RespawnTime = math.ceil(180 / (Difficulty_Selected ^ (1.2)));

    local AllowedUnitsBastille = {
        Entities.PU_LeaderPoleArm3,
        Entities.PU_LeaderSword3,
        Entities.PU_LeaderBow3,
        Entities.PV_Cannon4,
        Entities.PU_LeaderPoleArm3,
    };
    if Difficulty_Selected >= 3 then
        AllowedUnitsBastille = {
            Entities.PU_LeaderPoleArm4,
            Entities.PU_LeaderSword4,
            Entities.PV_Cannon4,
            Entities.PU_LeaderBow4,
            Entities.PV_Cannon4,
            Entities.PU_LeaderSword4,
        };
    end

    local AllowedUnitsHQ = {
        Entities.PU_LeaderCavalry1,
        Entities.PU_LeaderHeavyCavalry1,
        Entities.PV_Cannon3,
        Entities.PU_LeaderCavalry1,
        Entities.PU_LeaderRifle1,
    };
    if Difficulty_Selected >= 3 then
        AllowedUnitsHQ = {
            Entities.PU_LeaderCavalry2,
            Entities.PV_Cannon7,
            Entities.PU_LeaderHeavyCavalry2,
            Entities.PV_Cannon8,
            Entities.PU_LeaderRifle2,
        };
    end

    Enemy_Player4Camp1 = DelinquentsCampCreate {
        PlayerID     = 4,
        HomePosition = "P4DefPos1",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player4Camp1, "P4Bastille1", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player4Camp1, "P4Bastille2", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player4Camp1, "P4Bastille3", RespawnTime, 1, unpack(AllowedUnitsBastille));
    DelinquentsCampAddSpawner(Enemy_Player4Camp1, "HQ4", RespawnTime, 3, unpack(AllowedUnitsHQ));
    DelinquentsCampAddGuardPositions(Enemy_Player4Camp1, "P4DefPos1", "P4DefPos2");
    DelinquentsCampAddTarget(
        Enemy_Player4Camp1,
        "P4DefPos2", "NBWP1", "NWP1", "NWP2", "NWP3", "NWP4", "NWP5",
        "Player2Home", "NWP5", "NWP6", "SWP4", "SWP5", "Player1Home"
    );
    DelinquentsCampActivateAttack(Enemy_Player4Camp1, true);

    Job.Second(Enemy_Player4_CheckIsDefeated);
    Enemy_Player4_SaveSpawnerBuildings();
    -- To make player 4 not too boring...
    if Difficulty_Selected >= 4 then
        Job.Second(Enemy_Player4_SaveSpawnerBuildings);
    end
end

function Enemy_Player4_SaveSpawnerBuildings()
    for _,ScriptName in pairs{"P4Bastille1","P4Bastille2","P4Bastille3"} do
        local Position = GetPosition(ScriptName);
        local Type = Logic.GetEntityType(GetID(ScriptName));
        local Orientation = Logic.GetEntityOrientation(GetID(ScriptName));
        Enemy_Player4_BuildingPositions[ScriptName] = {
            Position.X, Position.Y, Type, Orientation
        };
    end
end

function Enemy_Player4_CheckIsDefeated()
    if (not IsExisting("HQ4")) then
        DelinquentsCampDestroy(Enemy_Player4Camp1);
        for ScriptName, _ in pairs(Enemy_Player4_BuildingPositions) do
            SetHealth(ScriptName, 0);
        end
        DestroyEntity("LordP4");
        Enemy_Player4_IsDefeated = 1;

        local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/Player4Defeated");
        Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
        Message(Msg);
        return true;
    end
end

function Enemy_Player4_RestoreSpawnersInFog()
    -- End job after HQ is killed
    if Enemy_Player4_IsDefeated == 1 then
        return true;
    end
    -- Restore buildings in fog
    for ScriptName, Data in pairs(Enemy_Player4_BuildingPositions) do
        if not IsExisting(ScriptName) then
            if  Logic.IsMapPositionExplored(1, Data[1], Data[2]) == 0
            and Logic.IsMapPositionExplored(2, Data[1], Data[2]) == 0 then
                local ID = Logic.CreateEntity(Data[3], Data[1], Data[2], Data[4], 5);
                Logic.SetEntityName(ID, ScriptName);
            end
        end
    end
end

function Enemy_Player4_State1()
    for i= 1, 3 do
        ChangePlayer("P4Bastille" ..i, 4);
    end
    for i= 1, 6 do
        ChangePlayer("P4Tower" ..i, 4);
    end
    Enemy_InitPlayer4();

    ReplaceEntity("P4RG1", Entities.XD_DarkWallStraightGate);
    SetHostile(1,4);
    SetHostile(2,4);
end

-- Player 5 --------------------------------------------------------------------

Enemy_Player5_BuildingPositions = {};
Enemy_Player5_IsDefeated = 0;

function Enemy_Player5_Init()
    local Strength = 8 + (4 * (Difficulty_Selected -1));
    local RespawnTime = math.ceil(180 / (Difficulty_Selected ^ (1.2)));

    -- Select types
    local AllowedMelee = {Entities.PU_LeaderPoleArm2, Entities.PU_LeaderSword2, Entities.PU_LeaderPoleArm2};
    if Difficulty_Selected >= 3 then
        AllowedMelee = {Entities.CU_TemplarLeaderPoleArm1, Entities.PU_LeaderSword4, Entities.PU_LeaderSword4};
    end
    local AllowedRanged = {Entities.PU_LeaderBow2, Entities.PU_LeaderRifle1};
    if Difficulty_Selected >= 3 then
        AllowedRanged = {Entities.PU_LeaderBow4, Entities.PU_LeaderRifle2};
    end
    local AllowedCavalry = {Entities.PU_LeaderCavalry1, Entities.PU_LeaderHeavyCavalry1, Entities.PU_LeaderCavalry1};
    if Difficulty_Selected >= 3 then
        AllowedCavalry = {Entities.CU_TemplarLeaderCavalry1, Entities.CU_TemplarLeaderHeavyCavalry1};
    end
    local AllowedCannons = {Entities.PV_Cannon1, Entities.PV_Cannon2};
    if Difficulty_Selected >= 3 then
        AllowedCannons = {Entities.PV_Cannon3, Entities.PV_Cannon4};
    end

    -- Create enemies for player 1
    Enemy_Player5Camp1 = DelinquentsCampCreate {
        PlayerID     = 5,
        HomePosition = "P5DefPos4",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player5Camp1, "P5_BC1", RespawnTime, 2, unpack(AllowedMelee));
    DelinquentsCampAddSpawner(Enemy_Player5Camp1, "P5_AC1", RespawnTime, 1, unpack(AllowedRanged));
    DelinquentsCampAddSpawner(Enemy_Player5Camp1, "P5_ST1", RespawnTime, 1, unpack(AllowedCavalry));
    DelinquentsCampAddSpawner(Enemy_Player5Camp1, "P5_FD1", RespawnTime, 2, unpack(AllowedCannons));
    DelinquentsCampAddGuardPositions(Enemy_Player5Camp1, "P5DefPos1", "P5DefPos2", "P5DefPos3", "P5DefPos4");
    DelinquentsCampAddTarget(Enemy_Player5Camp1, "P5DefPos2", "NWP1", "NWP2", "NWP3", "NWP4", "NWP5", "Player2Home");
    DelinquentsCampAddTarget(Enemy_Player5Camp1, "P5DefPos1", "MWP1", "MWP2", "MWP3", "SWP4", "SWP5", "Player1Home");

    -- Create enemies for player 2
    Enemy_Player5Camp2 = DelinquentsCampCreate {
        PlayerID     = 5,
        HomePosition = "P5DefPos3",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player5Camp2, "P5_BC1", RespawnTime, 2, unpack(AllowedMelee));
    DelinquentsCampAddSpawner(Enemy_Player5Camp2, "P5_FD1", RespawnTime, 1, unpack(AllowedCannons));
    DelinquentsCampAddSpawner(Enemy_Player5Camp2, "P5_ST1", RespawnTime, 1, unpack(AllowedCavalry));
    DelinquentsCampAddSpawner(Enemy_Player5Camp2, "P5_AC1", RespawnTime, 2, unpack(AllowedRanged));
    DelinquentsCampAddGuardPositions(Enemy_Player5Camp2, "P5DefPos1", "P5DefPos2", "P5DefPos3", "P5DefPos4");
    DelinquentsCampAddTarget(Enemy_Player5Camp2, "P5DefPos1", "MWP1", "MWP2", "MWP3", "SWP4", "SWP5", "Player1Home");
    DelinquentsCampAddTarget(Enemy_Player5Camp2, "P5DefPos2", "NWP1", "NWP2", "NWP3", "NWP4", "NWP5", "Player2Home");

    Enemy_Player5_SaveSpawnerBuildings();
    -- To make player 5 not too boring...
    if Difficulty_Selected >= 4 then
        Job.Second(Enemy_Player5_RestoreSpawnersInFog);
    end
    Job.Second(Enemy_Player5_CheckIsDefeated);
end

function Enemy_Player5_SaveSpawnerBuildings()
    local BuildingList = {"P5_BC1","P5_AC1","P5_ST1","P5_FD1"};
    for i= 1, 18 do
        table.insert(BuildingList, "P5Tower" ..i);
    end
    for _,ScriptName in pairs(BuildingList) do
        local Position = GetPosition(ScriptName);
        local Type = Logic.GetEntityType(GetID(ScriptName));
        local Orientation = Logic.GetEntityOrientation(GetID(ScriptName));
        Enemy_Player5_BuildingPositions[ScriptName] = {
            Position.X, Position.Y, Type, Orientation
        };
    end
end

function Enemy_Player5_RestoreSpawnersInFog()
    -- End job after imposter is killed
    if Enemy_Player5_IsDefeated == 1 then
        return true;
    end
    -- Restore buildings in fog
    for ScriptName, Data in pairs(Enemy_Player5_BuildingPositions) do
        if not IsExisting(ScriptName) then
            if  Logic.IsMapPositionExplored(1, Data[1], Data[2]) == 0
            and Logic.IsMapPositionExplored(2, Data[1], Data[2]) == 0 then
                local ID = Logic.CreateEntity(Data[3], Data[1], Data[2], Data[4], 5);
                Logic.SetEntityName(ID, ScriptName);
            end
        end
    end
end

function Enemy_Player5_CheckIsDefeated()
    if (not IsExisting("ImposterMayor5")) then
        DelinquentsCampDestroy(Enemy_Player5Camp1);
        DelinquentsCampDestroy(Enemy_Player5Camp2);
        for ScriptName, _ in pairs(Enemy_Player5_BuildingPositions) do
            SetHealth(ScriptName, 0);
        end
        Enemy_Player5_IsDefeated = 1;
        SetNeutral(1,5);

        local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/Player5Defeated");
        Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
        Message(Msg);
        return true;
    end
    -- Control imposter vulnerability
    if  not IsExisting("P5_BC1") and not IsExisting("P5_AC1")
    and not IsExisting("P5_ST1") and not IsExisting("P5_FD1") then
        MakeVulnerable("ImposterMayor5");
    else
        MakeInvulnerable("ImposterMayor5");
    end
end

-- Player 7 --------------------------------------------------------------------

function Enemy_Player7_Init()
    local Strength = 4 + (2 * (Difficulty_Selected -1));
    local Respawn = math.ceil(180 / (Difficulty_Selected ^ (1.3)));
    local AllowedTroops = {
        {Entities.PU_LeaderPoleArm1, 3},
        {Entities.PU_LeaderBow1, 3},
        {Entities.PU_LeaderBow1, 3},
        {Entities.CU_BanditLeaderSword3, 3},
        {Entities.PU_LeaderPoleArm1, 3},
    };
    if Difficulty_Selected >= 3 then
        AllowedTroops = {
            {Entities.PU_LeaderPoleArm3, 3},
            {Entities.CU_BanditLeaderBow1, 3},
            {Entities.PU_LeaderBow3, 3},
            {Entities.CU_BanditLeaderSword1, 3},
            {Entities.PU_LeaderRifle1, 3},
        };
    end

    Enemy_Player7Camp1 = DelinquentsCampCreate {
        PlayerID     = 7,
        HomePosition = "P7DefPos1",
        Strength     = Strength,
    };
    DelinquentsCampAddSpawner(Enemy_Player7Camp1, "BanditTower1", Respawn, 2, unpack(AllowedTroops));
    DelinquentsCampAddTarget(Enemy_Player7Camp1, "SSWP1", "SSWP2", "SWP4", "SWP5", "Player1Home");
    DelinquentsCampAddTarget(Enemy_Player7Camp1, "SSWP1", "SSWP2", "SWP4", "SWP5", "NWP5", "NWP6", "Player2Home");
end

-- ########################################################################## --
-- #                              MAIN QUEST                                # --
-- ########################################################################## --

-- Main --------------------------------------------------------------------- --

MainQuest_ID = 1;
MainQuest_Done = 0;

function Main1Quest_Init()
    Job.Second(Main1Quest_WaitForDifficultySelection);
    Job.Second(Main1Quest_IsPlayer5Defeated);
end

function Main1Quest_InitFinalEnemyMinions()
    Main1Quest_JournalStage3();
    Enemy_Player3_State1();
    Enemy_Player4_State1();
    Job.Second(Enemy_Player6_StartStage1);
    Job.Second(Main1Quest_IsPlayer6Defeated);
    Trader_CreateNpcTrader3();
end

function Main1Quest_WaitForDifficultySelection()
    if Difficulty_Selected ~= 0 then
        if Difficulty_Selected == 1 then
            Difficulty_SetEasy();
        elseif Difficulty_Selected == 2 then
            Difficulty_SetNormal();
        elseif Difficulty_Selected == 3 then
            Difficulty_SetHard();
        elseif Difficulty_Selected == 4 then
            Difficulty_SetManiac();
        end

        -- Delete player 2 in singleplayer
        if XNetwork.Manager_DoesExist() == 0 then
            DestroyEntity("HQ2");
        end

        Enemy_Player5_Init();
        Enemy_Player7_Init();
        return true;
    end
end

function Main1Quest_IsPlayer5Defeated()
    if Enemy_Player5_IsDefeated == 1 then
        Main1Quest_ReleaseTheBishop();
        Main1Quest_JournalStage2();
        return true;
    end
end

function Main1Quest_IsPlayer6Defeated()
    if not IsExisting("HQ6") then
        Main1Quest_BriefingOutro();
        return true;
    end
end

function Main1Quest_PeaceTimeOver()
    -- Make player 5 aggressive
    DelinquentsCampActivateAttack(Enemy_Player5Camp1, true);
    DelinquentsCampActivateAttack(Enemy_Player5Camp2, true);
    ReplaceEntity("P5NG1", Entities.XD_WallStraightGate);
    ReplaceEntity("P5SG1", Entities.XD_WallStraightGate);
    MakeVulnerable("P5NG1");
    MakeVulnerable("P5SG1");
    SetHostile(1, 5);
    SetHostile(2, 5);
end

function Main1Quest_ReleaseTheBishop()
    local Position = GetPosition("BishopPos1");
    local ID = Logic.CreateEntity(Entities.CU_BishopIdle, Position.X, Position.Y, 0, 8);
    Logic.SetEntityName(ID, "Bishop");
    Move("Bishop", "BishopPos2");
    Job.Second(function()
        if IsNear("Bishop", "BishopPos2", 50) then
            Main1Quest_CreateBishop1Npc1();
            return true;
        end
    end);
end

function Main1Quest_CreateBishop1Npc1()
    NonPlayerCharacter.Create {
        ScriptName = "Bishop",
        Callback   = Main1Quest_BriefingBishop1,
    }
    NonPlayerCharacter.Activate("Bishop");
end

function Main1Quest_RevealEnemyCoalition()
    SetPlayerName(6, XGUIEng.GetStringTableText("map_sh_midsummerrevolution/Player3Name"));
    SetPlayerName(3, XGUIEng.GetStringTableText("map_sh_midsummerrevolution/Player4Name"));
    SetPlayerName(4, XGUIEng.GetStringTableText("map_sh_midsummerrevolution/Player6Name"));
end

function Main1Quest_JournalStage1()
    local Title = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/MainQuest_Stage1_Title");
    local Text  = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/MainQuest_Stage1_Text");
    Logic.AddQuest(1, MainQuest_ID, MAINQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
    Logic.AddQuest(2, MainQuest_ID, MAINQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
end

function Main1Quest_JournalStage2()
    local Title = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/MainQuest_Stage2_Title");
    local Text  = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/MainQuest_Stage2_Text");
    Logic.AddQuest(1, MainQuest_ID, MAINQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
    Logic.AddQuest(2, MainQuest_ID, MAINQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
end

function Main1Quest_JournalStage3()
    local Title = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/MainQuest_Stage3_Title");
    local Text  = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/MainQuest_Stage3_Text");
    Logic.AddQuest(1, MainQuest_ID, MAINQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
    Logic.AddQuest(2, MainQuest_ID, MAINQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
end

function Main1Quest_BriefingIntro()
    local HostPlayerID = Syncer.GetHostPlayerID();
    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
        ResetCamera = false,
    };
    local AP, ASP = BriefingSystem.AddPages(Briefing);

    AP {
        NoSkip      = true,
        Duration    = 0.1,
        FaderAlpha  = 1,
        Target      = "icam_5",
        Rotation    = -115,
        Distance    = 9000,
        Angle       = 4,
    }
    AP {
        Text        = "map_sh_midsummerrevolution/BriefingIntro_1_Text",
        Flight      = true,
        NoSkip      = true,
        FadeIn      = 3,
        Duration    = 23,
        Target      = "icam_6",
        Rotation    = -155,
        Distance    = 7500,
        Angle       = 8,
    }
    AP {
        NoSkip      = true,
        Duration    = 0,
        Target      = "icam_8",
        Rotation    = -120,
        Distance    = 1700,
        Angle       = 8,
    }
    AP {
        Text        = "map_sh_midsummerrevolution/BriefingIntro_2_Text",
        Flight      = true,
        NoSkip      = true,
        Duration    = 20,
        Target      = "icam_7",
        Rotation    = -80,
        Distance    = 1500,
        Angle       = 18,
    }
    AP {
        NoSkip      = true,
        Duration    = 0,
        Target      = "icam_1",
        Rotation    = 140,
        Distance    = 2600,
        Angle       = 22,
    }
    AP {
        Text        = "map_sh_midsummerrevolution/BriefingIntro_3_Text",
        Flight      = true,
        NoSkip      = true,
        Duration    = 20,
        Target      = "icam_2",
        Rotation    = 170,
        Distance    = 2000,
        Angle       = 11,
    }
    AP {
        NoSkip      = true,
        Duration    = 0,
        Target      = "icam_4",
        Rotation    = 135,
        Distance    = 11500,
        Angle       = 30,
    }
    AP {
        Text        = "map_sh_midsummerrevolution/BriefingIntro_4_Text",
        Flight      = true,
        NoSkip      = true,
        Duration    = 20,
        Target      = "icam_4",
        Rotation    = 135,
        Distance    = 13500,
        Angle       = 30,
    }
    AP {
        NoSkip      = true,
        Duration    = 0,
        Target      = "icam_3",
        Rotation    = -55,
        Distance    = 14000,
        Angle       = 8,
    }
    AP {
        Text        = "map_sh_midsummerrevolution/BriefingIntro_5_Text",
        Flight      = true,
        NoSkip      = true,
        FadeOut     = 3,
        Duration    = 23,
        Target      = "icam_3",
        Rotation    = -35,
        Distance    = 14000,
        Angle       = 8,
    }

    Briefing.Finished = function()
        Main1Quest_JournalStage1();
        StartCountdown(Difficulty_InitialPeaceTime, Main1Quest_PeaceTimeOver, true);

        Mayor1Quest_Init();
        TraitorRevengeQuest_Init();
        FindSheepsQuest_Init();
        DrawBridgeQuest_Init();
    end
    BriefingSystem.Start(HostPlayerID, "BriefingIntro", Briefing, 1, 2);
end

function Main1Quest_BriefingOutro()
    local MainPlayerID = (Logic.PlayerGetGameState(1) == 1 and 1) or 2;

    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
        ResetCamera = true,
    };
    local AP, ASP = BriefingSystem.AddPages(Briefing);

    AP {
        NoSkip      = true,
        Duration    = 0.1,
        FaderAlpha  = 1,
        Target      = "ocam_1",
        Rotation    = -20,
        Distance    = 16000,
        Angle       = 4,
    }
    AP {
        Text        = "map_sh_midsummerrevolution/BriefingOutro_1_Text",
        Flight      = true,
        NoSkip      = true,
        FadeIn      = 3,
        Duration    = 23,
        Target      = "ocam_2",
        Rotation    = -10,
        Distance    = 15000,
        Angle       = 8,
    }
    AP {
        NoSkip      = true,
        Duration    = 0,
        Target      = "ocam_4",
        Rotation    = -135,
        Distance    = 6000,
        Angle       = 24,
    }
    AP {
        Text        = "map_sh_midsummerrevolution/BriefingOutro_2_Text",
        Flight      = true,
        NoSkip      = true,
        Duration    = 20,
        Target      = "ocam_3",
        Rotation    = -45,
        Distance    = 7000,
        Angle       = 30,
    }
    AP {
        NoSkip      = true,
        Duration    = 0,
        Target      = "ocam_5",
        Rotation    = -75,
        Distance    = 6000,
        Height      = -3500,
        Angle       = 24,
    }
    AP {
        Text        = "map_sh_midsummerrevolution/BriefingOutro_3_Text",
        Flight      = true,
        NoSkip      = true,
        Duration    = 20,
        Target      = "ocam_6",
        Rotation    = -25,
        Distance    = 6000,
        Height      = -5500,
        Angle       = 19,
    }
    AP {
        NoSkip      = true,
        Duration    = 0,
        Target      = "ocam_7",
        Rotation    = 40,
        Distance    = 20000,
        Height      = -8000,
        Angle       = 14,
    }
    AP {
        Text        = "map_sh_midsummerrevolution/BriefingOutro_4_Text",
        Flight      = true,
        NoSkip      = true,
        Duration    = 23,
        FadeOut     = 3,
        Target      = "ocam_7",
        Rotation    = 40,
        Distance    = 26000,
        Height      = -4000,
        Angle       = 18,
    }

    Briefing.Finished = function()
        Logic.PlayerSetGameStateToWon(1);
        Logic.PlayerSetGameStateToWon(2);
    end
    BriefingSystem.Start(MainPlayerID, "BriefingOutro", Briefing, 1, 2);
end

function Main1Quest_BriefingBishop1(_Npc, _HeroID)
    local PlayerID = Logic.EntityGetPlayer(_HeroID);
    local HeroType = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(HeroType);
    local HeroName = XGUIEng.GetStringTableText("Names/".. TypeName);

    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
        ResetCamera = true,
    };
    local AP, ASP = BriefingSystem.AddPages(Briefing);

    AP {
        Title       = "map_sh_midsummerrevolution/BriefingBishop1_1_Title",
        Text        = "map_sh_midsummerrevolution/BriefingBishop1_1_Text",
        Target      = "Bishop",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingBishop1_2_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingBishop1_3_Title",
        Text        = "map_sh_midsummerrevolution/BriefingBishop1_3_Text",
        Target      = "Bishop",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingBishop1_4_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingBishop1_5_Title",
        Text        = "map_sh_midsummerrevolution/BriefingBishop1_5_Text",
        Target      = "Bishop",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingBishop1_6_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingBishop1_7_Title",
        Text        = "map_sh_midsummerrevolution/BriefingBishop1_7_Text",
        Target      = "Bishop",
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingBishop1_8_Title",
        Text        = "map_sh_midsummerrevolution/BriefingBishop1_8_Text",
        Target      = "Garek1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingBishop1_9_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }

    Briefing.Finished = function()
        Main1Quest_InitFinalEnemyMinions();
    end
    BriefingSystem.Start(PlayerID, "BriefingBishop1", Briefing);
end

-- ########################################################################## --
-- #                              SUB QUESTS                                # --
-- ########################################################################## --

-- Mayor 1 ------------------------------------------------------------------ --

Mayor1Quest_ID = 2;
Mayor1Quest_WifeQuestStarted = 0;
Mayor1Quest_IsDone = 0;

function Mayor1Quest_Init()
    Mayor1Quest_CreateMayor1Npc1();
    Job.Second(Mayor1Quest_RescureWifeController);
end

function Mayor1Quest_RescureWifeController()
    if RescueWifeQuest_IsDone ~= 0 then
        Mayor1Quest_CreateMayor1Npc2();
        return true;
    end
end

function Mayor1Quest_Done()
    if RescueWifeQuest_Done == 1 then
        AddGold(1, 5000);
        AddGold(2, 5000);
        Move("Isabella1", "Isabella1Pos1");
        local PlayerID = GUI.GetPlayerID();
        if PlayerID == 1 or PlayerID == 2 then
            local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestDustin_MsgReward");
            Message(Msg);
        end
    end
    Logic.SetQuestType(1, Mayor1Quest_ID, SUBQUEST_CLOSED, 1);
    Logic.SetQuestType(2, Mayor1Quest_ID, SUBQUEST_CLOSED, 1);
    Mayor1Quest_IsDone = 1;
    Trader_CreateNpcTrader1();
end

function Mayor1Quest_AddToJournal()
    local Title = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestDustin_Title");
    local Text  = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestDustin_Text");
    Logic.AddQuest(1, Mayor1Quest_ID, SUBQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
    Logic.AddQuest(2, Mayor1Quest_ID, SUBQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
end

function Mayor1Quest_CreateMayor1Npc1()
    NonPlayerCharacter.Create {
        ScriptName = "Mayor1",
        Callback   = Mayor1Quest_BriefingDustin1,
    }
    NonPlayerCharacter.Activate("Mayor1");
end

function Mayor1Quest_CreateMayor1Npc2()
    NonPlayerCharacter.Create {
        ScriptName = "Mayor1",
        Callback   = Mayor1Quest_BriefingDustin2,
    }
    NonPlayerCharacter.Activate("Mayor1");
end

function Mayor1Quest_BriefingDustin1(_Npc, _HeroID)
    local PlayerID = Logic.EntityGetPlayer(_HeroID);
    local HeroType = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(HeroType);
    local HeroName = XGUIEng.GetStringTableText("Names/".. TypeName);

    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
        ResetCamera = true,
    };
    local AP, ASP = BriefingSystem.AddPages(Briefing);

    AP {
        Title       = "map_sh_midsummerrevolution/BriefingDustin1_1_Title",
        Text        = "map_sh_midsummerrevolution/BriefingDustin1_1_Text",
        Target      = "Mayor1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingDustin1_2_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingDustin1_3_Title",
        Text        = "map_sh_midsummerrevolution/BriefingDustin1_3_Text",
        Target      = "Mayor1",
        CloseUp     = true,
    }

    Briefing.Finished = function(_PlayerID)
        Mayor1Quest_AddToJournal();
        Mayor1Quest_WifeQuestStarted = 1;
        if TraitorRevengeQuest_IsDone == 1 then
            RescueWifeQuest_Init();
            local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestDustin_MsgIsabella");
            Message(Msg);
        end
    end
    BriefingSystem.Start(PlayerID, "BriefingDustin1", Briefing);
end

function Mayor1Quest_BriefingDustin2(_Npc, _HeroID)
    local PlayerID = Logic.EntityGetPlayer(_HeroID);
    local HeroType = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(HeroType);
    local HeroName = XGUIEng.GetStringTableText("Names/".. TypeName);

    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
        ResetCamera = true,
    };
    local AP, ASP = BriefingSystem.AddPages(Briefing);

    if RescueWifeQuest_IsDone == 1 then
        AP {
            Title       = HeroName,
            Text        = "map_sh_midsummerrevolution/BriefingDustin2_1a_Text",
            Target      = _HeroID,
            CloseUp     = true,
        }
        AP {
            Title       = "map_sh_midsummerrevolution/BriefingDustin2_2a_Title",
            Text        = "map_sh_midsummerrevolution/BriefingDustin2_2a_Text",
            Target      = "Mayor1",
            CloseUp     = true,
        }
        AP {
            Title       = "map_sh_midsummerrevolution/BriefingDustin2_3a_Title",
            Text        = "map_sh_midsummerrevolution/BriefingDustin2_3a_Text",
            Target      = "Isabella1",
            CloseUp     = true,
        }
    else
        AP {
            Title       = HeroName,
            Text        = "map_sh_midsummerrevolution/BriefingDustin2_1b_Text",
            Target      = _HeroID,
            CloseUp     = true,
        }
        AP {
            Title       = "map_sh_midsummerrevolution/BriefingDustin2_2b_Title",
            Text        = "map_sh_midsummerrevolution/BriefingDustin2_2b_Text",
            Target      = "Mayor1",
            CloseUp     = true,
        }
        AP {
            Title       = HeroName,
            Text        = "map_sh_midsummerrevolution/BriefingDustin2_3b_Text",
            Target      = _HeroID,
            CloseUp     = true,
        }
    end

    AP {
        Title       = "map_sh_midsummerrevolution/BriefingDustin2_4_Title",
        Text        = "map_sh_midsummerrevolution/BriefingDustin2_4_Text",
        Target      = "NPCTrader1",
        CloseUp     = true,
    }

    Briefing.Finished = function(_PlayerID)
        Mayor1Quest_Done();
    end
    BriefingSystem.Start(PlayerID, "BriefingDustin2", Briefing);
end

-- Traitor ------------------------------------------------------------------ --

TraitorRevengeQuest_ID = 4;
TraitorRevengeQuest_IsDone = 0;

function TraitorRevengeQuest_Init()
    TraitorRevengeQuest_CreateTraitor1Npc1();
    Job.Second(TraitorRevengeQuest_DestroyBanditsController)
end

function TraitorRevengeQuest_Done()
    -- make castle ruin accessible
    ReplaceEntity("Traitor1", Entities.XD_ScriptEntity);
    ReplaceEntity("VC_Blockade", Entities.XD_ScriptEntity);
    -- make player 7 neutral to humans
    SetNeutral(1,7);
    SetNeutral(2,7);
    -- destroy remaining bandits
    for k,v in pairs(GetPlayerEntities(7, 0)) do
        DestroyEntity(v);
    end
    -- continue quests
    TraitorRevengeQuest_IsDone = 1;
    Logic.SetQuestType(1, TraitorRevengeQuest_ID, SUBQUEST_CLOSED, 1);
    Logic.SetQuestType(2, TraitorRevengeQuest_ID, SUBQUEST_CLOSED, 1);
    if Mayor1Quest_WifeQuestStarted == 1 then
        RescueWifeQuest_Init();
        local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestTraitor_MsgIsabella");
        Message(Msg);
    end
end

function TraitorRevengeQuest_DestroyBanditsController()
    if not IsExisting("BanditTower1") then
        for i= 1, 5 do
            SetHealth("OutlawTower" ..i, 0);
        end
        TraitorRevengeQuest_CreateTraitor1Npc2();
        DelinquentsCampDestroy(Enemy_Player7Camp1);
        return true;
    end
end

function TraitorRevengeQuest_AddToJournal()
    local Title = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestTraitor_Title");
    local Text  = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestTraitor_Text");
    Logic.AddQuest(1, TraitorRevengeQuest_ID, SUBQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
    Logic.AddQuest(2, TraitorRevengeQuest_ID, SUBQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
end

function TraitorRevengeQuest_CreateTraitor1Npc1()
    NonPlayerCharacter.Create {
        ScriptName = "Traitor1",
        Callback   = TraitorRevengeQuest_BriefingTraitor1,
    }
    NonPlayerCharacter.Activate("Traitor1");
end

function TraitorRevengeQuest_CreateTraitor1Npc2()
    NonPlayerCharacter.Create {
        ScriptName = "Traitor1",
        Callback   = TraitorRevengeQuest_BriefingTraitor2,
    }
    NonPlayerCharacter.Activate("Traitor1");
end

function TraitorRevengeQuest_BriefingTraitor1(_Npc, _HeroID)
    local PlayerID = Logic.EntityGetPlayer(_HeroID);
    local HeroType = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(HeroType);
    local HeroName = XGUIEng.GetStringTableText("Names/".. TypeName);

    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
        ResetCamera = true,
    };
    local AP, ASP = BriefingSystem.AddPages(Briefing);

    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingTraitor1_1_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingTraitor1_2_Title",
        Text        = "map_sh_midsummerrevolution/BriefingTraitor1_2_Text",
        Target      = "Traitor1",
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingTraitor1_2_Title",
        Text        = "map_sh_midsummerrevolution/BriefingTraitor1_3_Text",
        Target      = "BanditTower1",
        CloseUp     = false,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingTraitor1_2_Title",
        Text        = "map_sh_midsummerrevolution/BriefingTraitor1_4_Text",
        Target      = "Traitor1",
        CloseUp     = true,
    }

    Briefing.Finished = function(_PlayerID)
        TraitorRevengeQuest_AddToJournal();
        ReplaceEntity("BanditBarrier", Entities.XD_Rock7);
        DelinquentsCampActivateAttack(Enemy_Player7Camp1, true);
        SetHostile(1, 7);
        SetHostile(2, 7);
    end
    BriefingSystem.Start(PlayerID, "BriefingTraitor1", Briefing);
end

function TraitorRevengeQuest_BriefingTraitor2(_Npc, _HeroID)
    local PlayerID = Logic.EntityGetPlayer(_HeroID);
    local HeroType = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(HeroType);
    local HeroName = XGUIEng.GetStringTableText("Names/".. TypeName);

    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
        ResetCamera = true,
    };
    local AP, ASP = BriefingSystem.AddPages(Briefing);

    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingTraitor2_1_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingTraitor2_2_Title",
        Text        = "map_sh_midsummerrevolution/BriefingTraitor2_2_Text",
        Target      = "Traitor1",
        CloseUp     = true,
    }

    Briefing.Finished = function(_PlayerID)
        TraitorRevengeQuest_Done();
    end
    BriefingSystem.Start(PlayerID, "BriefingTraitor2", Briefing);
end

-- Rescue Wife -------------------------------------------------------------- --

RescueWifeQuest_ID = 5;
RescueWifeQuest_IsDone = 0;

function RescueWifeQuest_Init()
    ReplaceEntity("Isabella1", Entities.CU_Princess);
    RescueWifeQuest_CreateIsabella1Npc1();
    Job.Second(RescueWifeQuest_ArrivedController);
end

function RescueWifeQuest_Done()
    local PlayerID = GUI.GetPlayerID();
    if PlayerID == 1 or PlayerID == 2 then
        local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestIsabella_MsgSolveA");
        if RescueWifeQuest_IsDone == 2 then
            Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestIsabella_MsgSolveB");
        end
        Message(Msg);
    end

    NonPlayerCharacter.Delete("Isabella1");
    if RescueWifeQuest_IsDone == 1 then
        Move("Isabella1", "Isabella1Pos1");
    else
        MoveAndVanish("Isabella1", "Isabella1Pos2");
        AddHonor(1, 300);
        AddHonor(2, 300);
    end
    Logic.SetQuestType(1, RescueWifeQuest_ID, SUBQUEST_CLOSED, 1);
    Logic.SetQuestType(2, RescueWifeQuest_ID, SUBQUEST_CLOSED, 1);
end

function RescueWifeQuest_ArrivedController()
    if IsNear("Isabella1", "Isabella1Pos1", 1000) then
        RescueWifeQuest_IsDone = 1;
    end
    if IsNear("Isabella1", "Isabella1Pos2", 1000) then
        RescueWifeQuest_IsDone = 2;
    end
    if RescueWifeQuest_IsDone ~= 0 then
        RescueWifeQuest_Done();
        return true;
    end
end

function RescueWifeQuest_AddToJournal()
    local Title = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestIsabella_Title");
    local Text  = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestIsabella_Text");
    Logic.AddQuest(1, RescueWifeQuest_ID, SUBQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
    Logic.AddQuest(2, RescueWifeQuest_ID, SUBQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
end

function RescueWifeQuest_CreateIsabella1Npc1()
    NonPlayerCharacter.Create {
        ScriptName = "Isabella1",
        Callback   = RescueWifeQuest_BriefingIsabella1,
    }
    NonPlayerCharacter.Activate("Isabella1");
end

function RescueWifeQuest_CreateIsabella1Npc2()
    NonPlayerCharacter.Create {
        ScriptName  = "Isabella1",
        Follow      = true,
        Target      = "Isabella1Pos1",
        Callback    = function()
        end,
        WayCallback = function(_Npc, _HeroID)
            local PlayerID = GUI.GetPlayerID();
            if PlayerID == 1 or PlayerID == 2 then
                local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestIsabella_MsgTrust");
                Message(Msg);
            end
        end,
    }
    NonPlayerCharacter.Activate("Isabella1");
end

function RescueWifeQuest_BriefingIsabella1(_Npc, _HeroID)
    local PlayerID = Logic.EntityGetPlayer(_HeroID);
    local HeroType = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(HeroType);
    local HeroName = XGUIEng.GetStringTableText("Names/".. TypeName);

    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
        ResetCamera = true,
    };
    local AP, ASP = BriefingSystem.AddPages(Briefing);

    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingIsabella1_1_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingIsabella1_2_Title",
        Text        = "map_sh_midsummerrevolution/BriefingIsabella1_2_Text",
        Target      = "Isabella1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingIsabella1_3_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }

    Briefing.Finished = function(_PlayerID)
        RescueWifeQuest_AddToJournal();
        RescueWifeQuest_CreateIsabella1Npc2();
    end
    BriefingSystem.Start(PlayerID, "BriefingIsabella1", Briefing);
end

-- Find Sheeps -------------------------------------------------------------- --

FindSheepQuest_ID = 3;
FindSheepQuest_SheepArrivalCounter = 0;
FindSheepQuest_IsDone = 0;

function FindSheepsQuest_Init()
    FindSheepsQuest_CreateFarmer1Npc1();
end

function FindSheepsQuest_Done()
    Logic.SetQuestType(1, FindSheepQuest_ID, SUBQUEST_CLOSED, 1);
    Logic.SetQuestType(2, FindSheepQuest_ID, SUBQUEST_CLOSED, 1);
    NonPlayerCharacter.Delete("AngryFarmer1");
    FindSheepQuest_IsDone = 1;
    FindSheepsQuest_CreateFarmer1Npc3();

    local PlayerID = GUI.GetPlayerID();
    if PlayerID == 1 or PlayerID == 2 then
        local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestSheeps_MsgReady");
        Message(Msg);
    end
end

function FindSheepsQuest_CreateEscapedSheepNpcs()
    for i= 1, 5 do
        NonPlayerCharacter.Create {
            ScriptName = "Sheep" ..i,
            Callback   = function(_Npc, _HeroID)
                local PlayerID = GUI.GetPlayerID();
                if PlayerID == 1 or PlayerID == 2 then
                    local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestSheeps_MsgFound");
                    Message(Msg);
                end
                Job.Second(function(_ScriptName)
                    local ID = GetID(_ScriptName);
                    if Logic.IsEntityMoving(ID) == false then
                        Move(ID, _ScriptName.. "Pos");
                    end
                    if not IsExisting(ID) or IsNear(ID, _ScriptName.. "Pos", 100) then
                        FindSheepQuest_SheepArrivalCounter = FindSheepQuest_SheepArrivalCounter + 1;
                        if FindSheepQuest_SheepArrivalCounter >= 5 then
                            FindSheepsQuest_Done();
                        end
                        return true;
                    end
                end, _Npc.ScriptName);
            end,
        }
        NonPlayerCharacter.Activate("Sheep" ..i);
    end
end

function FindSheepsQuest_AddToJournal()
    local Title = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestSheeps_Title");
    local Text  = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestSheeps_Text");
    Logic.AddQuest(1, FindSheepQuest_ID, SUBQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
    Logic.AddQuest(2, FindSheepQuest_ID, SUBQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
end

function FindSheepsQuest_CreateFarmer1Npc1()
    NonPlayerCharacter.Create {
        ScriptName = "AngryFarmer1",
        Callback   = FindSheepsQuest_BriefingFarmer1,
    }
    NonPlayerCharacter.Activate("AngryFarmer1");
end

function FindSheepsQuest_CreateFarmer1Npc2()
    NonPlayerCharacter.Create {
        ScriptName = "AngryFarmer1",
        Callback   = function (_Npc, _HeroID)
            local PlayerID = Logic.EntityGetPlayer(_HeroID);
            if PlayerID == GUI.GetPlayerID() then
                local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestSheeps_MsgAngry");
                Message(Msg);
            end
            FindSheepsQuest_CreateFarmer1Npc2();
        end,
    }
    NonPlayerCharacter.Activate("AngryFarmer1");
end

function FindSheepsQuest_CreateFarmer1Npc3()
    NonPlayerCharacter.Create {
        ScriptName = "AngryFarmer1",
        Callback   = FindSheepsQuest_BriefingFarmer2,
    }
    NonPlayerCharacter.Activate("AngryFarmer1");
end

function FindSheepsQuest_BriefingFarmer1(_Npc, _HeroID)
    local PlayerID = Logic.EntityGetPlayer(_HeroID);
    local HeroType = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(HeroType);
    local HeroName = XGUIEng.GetStringTableText("Names/".. TypeName);

    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
        ResetCamera = true,
    };
    local AP, ASP = BriefingSystem.AddPages(Briefing);

    AP {
        Title       = "map_sh_midsummerrevolution/BriefingFarmer1_1_Title",
        Text        = "map_sh_midsummerrevolution/BriefingFarmer1_1_Text",
        Target      = "AngryFarmer1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingFarmer1_2_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingFarmer1_3_Title",
        Text        = "map_sh_midsummerrevolution/BriefingFarmer1_3_Text",
        Target      = "AngryFarmer1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingFarmer1_4_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingFarmer1_5_Title",
        Text        = "map_sh_midsummerrevolution/BriefingFarmer1_5_Text",
        Target      = "AngryFarmer1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingFarmer1_6_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }

    Briefing.Finished = function(_PlayerID)
        FindSheepsQuest_AddToJournal();
        FindSheepsQuest_CreateEscapedSheepNpcs();
        FindSheepsQuest_CreateFarmer1Npc2();
    end
    BriefingSystem.Start(PlayerID, "BriefingFarmer1", Briefing);
end

function FindSheepsQuest_BriefingFarmer2(_Npc, _HeroID)
    local PlayerID = Logic.EntityGetPlayer(_HeroID);
    local HeroType = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(HeroType);
    local HeroName = XGUIEng.GetStringTableText("Names/".. TypeName);

    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
        ResetCamera = true,
    };
    local AP, ASP = BriefingSystem.AddPages(Briefing);

    AP {
        Title       = "map_sh_midsummerrevolution/BriefingFarmer2_1_Title",
        Text        = "map_sh_midsummerrevolution/BriefingFarmer2_1_Text",
        Target      = "AngryFarmer1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingFarmer2_2_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingFarmer2_3_Title",
        Text        = "map_sh_midsummerrevolution/BriefingFarmer2_3_Text",
        Target      = "NPCTrader2",
        CloseUp     = true,
    }

    Briefing.Finished = function(_PlayerID)
        Trader_CreateNpcTrader2();
    end
    BriefingSystem.Start(PlayerID, "BriefingFarmer2", Briefing);
end

-- Draw Bridge -------------------------------------------------------------- --

DrawBridgeQuest_ID = 6;
DrawBridgeQuest_Player1ID = 1;
DrawBridgeQuest_Player2ID = 2;
DrawBridgeQuest_TributePayed = 0;
DrawBridgeQuest_IsDone = 0;

function DrawBridgeQuest_Init()
    DrawBridgeQuest_CreateGuard1Npc1();
    Job.Tribute(DrawBridgeQuest_FulfillTribute);
end

function DrawBridgeQuest_Done()
    Logic.SetQuestType(1, DrawBridgeQuest_ID, SUBQUEST_CLOSED, 1);
    Logic.SetQuestType(2, DrawBridgeQuest_ID, SUBQUEST_CLOSED, 1);
    ReplaceEntity("DrawBridge1", Entities.PB_DrawBridgeClosed1);
    DrawBridgeQuest_IsDone = 0;

    local PlayerID = GUI.GetPlayerID();
    if PlayerID == 1 or PlayerID == 2 then
        XGUIEng.ShowWidget("TradeWindow", 0);
        local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestGuard_MsgBridge");
        Message(Msg);
    end
end

function DrawBridgeQuest_AddTribute()
    local Tribute = 2500 * Difficulty_Selected;
    local Msg = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestGuard_Tribute");
    Logic.AddTribute(1, DrawBridgeQuest_Player1ID, 0, 0, string.format(Msg, Tribute), ResourceType.Gold, Tribute);
    Logic.AddTribute(2, DrawBridgeQuest_Player2ID, 0, 0, string.format(Msg, Tribute), ResourceType.Gold, Tribute);
end

function DrawBridgeQuest_FulfillTribute()
    local TributeID = Event.GetTributeUniqueID();
    if TributeID == DrawBridgeQuest_Player1ID then
        Logic.RemoveTribute(2, DrawBridgeQuest_Player2ID);
        DrawBridgeQuest_TributePayed = 1;
        DrawBridgeQuest_Done();
        return true;
    end
    if TributeID == DrawBridgeQuest_Player2ID then
        Logic.RemoveTribute(1, DrawBridgeQuest_Player1ID);
        DrawBridgeQuest_TributePayed = 1;
        DrawBridgeQuest_Done();
        return true;
    end
end

function DrawBridgeQuest_AddToJournal()
    local Title = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestGuard_Title");
    local Text  = XGUIEng.GetStringTableText("map_sh_midsummerrevolution/SubquestGuard_Text");
    Logic.AddQuest(1, DrawBridgeQuest_ID, SUBQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
    Logic.AddQuest(2, DrawBridgeQuest_ID, SUBQUEST_OPEN, Placeholder.Replace(Title), Placeholder.Replace(Text), 1);
end

function DrawBridgeQuest_CreateGuard1Npc1()
    NonPlayerCharacter.Create {
        ScriptName = "BridgeGuard1",
        Callback   = DrawBridgeQuest_BriefingGuard1,
    }
    NonPlayerCharacter.Activate("BridgeGuard1");
end

function DrawBridgeQuest_BriefingGuard1(_Npc, _HeroID)
    local PlayerID = Logic.EntityGetPlayer(_HeroID);
    local HeroType = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(HeroType);
    local HeroName = XGUIEng.GetStringTableText("Names/".. TypeName);

    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
        ResetCamera = true,
    };
    local AP, ASP = BriefingSystem.AddPages(Briefing);

    AP {
        Title       = "map_sh_midsummerrevolution/BriefingGuard1_1_Title",
        Text        = "map_sh_midsummerrevolution/BriefingGuard1_1_Text",
        Target      = "BridgeGuard1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "map_sh_midsummerrevolution/BriefingGuard1_2_Text",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "map_sh_midsummerrevolution/BriefingGuard1_3_Title",
        Text        = "map_sh_midsummerrevolution/BriefingGuard1_3_Text",
        Target      = "BridgeGuard1",
        CloseUp     = true,
    }

    Briefing.Finished = function(_PlayerID)
        DrawBridgeQuest_AddTribute();
        DrawBridgeQuest_AddToJournal();
    end
    BriefingSystem.Start(PlayerID, "BriefingGuard1", Briefing);
end

-- ########################################################################## --
-- #                                TRADER                                  # --
-- ########################################################################## --

function Trader_CreateNpcTrader1()
    local CostAmount = 250 * Difficulty_Selected;
    NonPlayerMerchant.Create {
        ScriptName  = "NPCTrader1",
    }
    NonPlayerMerchant.AddResourceOffer("NPCTrader1", ResourceType.Sulfur, 250, {Iron = CostAmount}, 3, 5*60);
    NonPlayerMerchant.Activate("NPCTrader1");
end

function Trader_CreateNpcTrader2()
    local CostAmount = 350 * Difficulty_Selected;
    NonPlayerMerchant.Create {
        ScriptName  = "NPCTrader2",
    }
    NonPlayerMerchant.AddResourceOffer("NPCTrader2", ResourceType.Stone, 500, {Wood = CostAmount}, 5, 3*60);
    NonPlayerMerchant.AddResourceOffer("NPCTrader2", ResourceType.Iron, 500, {Clay = CostAmount}, 5, 3*60);
    NonPlayerMerchant.Activate("NPCTrader2");
end

function Trader_CreateNpcTrader3()
    local CostAmount = 2500 * Difficulty_Selected;
    NonPlayerMerchant.Create {
        ScriptName  = "Garek1",
    }
    NonPlayerMerchant.AddTechnologyOffer("Garek1", Technologies.B_Mercenary, {Gold = CostAmount});
    NonPlayerMerchant.Activate("Garek1");
end

