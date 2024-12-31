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

    -- Open up named gates on the map.
    -- (PTGate1, PTGate2, ...)
    PeaceTimeOpenGates = true,

    -- Serfs
    StartingSerfs = 6,

    -- Fill resource piles with resources
    -- (value of resources or 0 to not change)
    MapStartFillClay = 1000,
    MapStartFillStone = 1000,
    MapStartFillIron = 400,
    MapStartFillSulfur = 250,
    MapStartFillWood = 4000,

    -- Rank
    Rank = {
        Initial = 0,
        Final = 7,
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

        Lib.Require("module/cinematic/BriefingSystem");
        Lib.Require("module/io/NonPlayerCharacter");
        Lib.Require("module/trigger/Job");
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        SetHostile(1,6);
        SetHostile(1,7);

        Cinematic.SetMCButtonCount(8);
        BriefingExposition();

        InitalizePlayer2();
        InitalizePlayer7();

        HarborQuest_Stage1();
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
        UseWeatherSet("EuropeanWeatherSet");
    end,
}

-- ########################################################################## --
-- #                                ENEMY                                   # --
-- ########################################################################## --

function InitalizePlayer2()
    SetupAiPlayer(2, 6, Entities.CU_Hero13);
    SetHostile(1,2);
end

function InitalizePlayer7()
    SetHostile(1,7);

    for Index = 1, 3 do
        local CampID = DelinquentsCampCreate {
            HomePosition = "banditTent" ..Index,
            Strength = 3,
        };
        DelinquentsCampAddSpawner(
            CampID, "banditTent" ..Index, 60, 1,
            Entities.PU_LeaderAxe2,
            Entities.PU_LeaderPoleArm2,
            Entities.CU_BanditLeaderBow1
        );
        DelinquentsCampAddGuardPositions(CampID, "BanditBase1");
        DelinquentsCampAddGuardPositions(CampID, "BanditBase2");
    end
end

-- ########################################################################## --
-- #                                 QUEST                                  # --
-- ########################################################################## --

-- Harbor Quest --

function HarborQuest_Stage1()
    ReplaceEntity("cog1", Entities.XD_ScriptEntity);
    ReplaceEntity("cog2", Entities.XD_ScriptEntity);
    ReplaceEntity("trader1", Entities.XD_ScriptEntity);
    ReplaceEntity("trader2", Entities.XD_ScriptEntity);
    for i= 1,8 do
        ReplaceEntity("npcTrader", Entities.XD_ScriptEntity);
    end

    NonPlayerCharacter.Create({
        ScriptName      = "Garek",
        Callback        = NpcBriefingGarek1
    });
    NonPlayerCharacter.Activate("Garek");
end

function HarborQuest_Stage2()
    ReplaceEntity("BanditBarrier1", Entities.XD_ScriptEntity);
    ReplaceEntity("Jack", Entities.XD_ScriptEntity);

    local QuestTitle = XGUIEng.GetStringTableText("map_sh_demo/Quest_Habor_1_Title");
    local QuestText  = XGUIEng.GetStringTableText("map_sh_demo/Quest_Habor_1_Text");
    Logic.AddQuest(1, 2, SUBQUEST_OPEN, QuestTitle, QuestText, 1);

    Job.Second(function()
        if  not IsExisting("banditTent1")
        and not IsExisting("banditTent2")
        and not IsExisting("banditTent3") then
            OilQuest_Stage1()
            return true;
        end
    end);
end

function HarborQuest_Stage3()
    ReplaceEntity("cog2", Entities.XD_Cog);
    ReplaceEntity("cog2", Entities.XD_Cog);
    ReplaceEntity("trader1", Entities.CU_Trader);
    ReplaceEntity("trader2", Entities.CU_Trader);
    for i= 1,8 do
        ReplaceEntity("npcTrader", Entities.CU_Trader);
    end

    local QuestTitle = XGUIEng.GetStringTableText("map_sh_demo/Quest_Habor_2_Title");
    local QuestText  = XGUIEng.GetStringTableText("map_sh_demo/Quest_Habor_2_Text");
    Logic.AddQuest(1, 2, SUBQUEST_OPEN, QuestTitle, QuestText, 1);

    Message(XGUIEng.GetStringTableText("map_sh_demo/Msg_TalkGarek"));
    NonPlayerCharacter.Create({
        ScriptName      = "Garek",
        Callback        = NpcBriefingGarek2
    });
    NonPlayerCharacter.Activate("Garek");
end

function HarborQuest_Stage4()
    Logic.SetQuestType(1, 2, SUBQUEST_CLOSED, 1);
end

-- Oil Quest --

function OilQuest_Stage1()
    ReplaceEntity("Jack", Entities.CU_Hermit);
    Message(XGUIEng.GetStringTableText("map_sh_demo/Msg_TalkJack"));
    NonPlayerCharacter.Create({
        ScriptName      = "Jack",
        Callback        = NpcBriefingHermit1
    });
    NonPlayerCharacter.Activate("Jack");
end

function OilQuest_Stage2()
    local QuestTitle = XGUIEng.GetStringTableText("map_sh_demo/Quest_Oil_1_Title");
    local QuestText  = XGUIEng.GetStringTableText("map_sh_demo/Quest_Oil_1_Text");
    Logic.AddQuest(1, 3, SUBQUEST_OPEN, QuestTitle, QuestText, 1);

    local TributeText  = XGUIEng.GetStringTableText("map_sh_demo/Tribute_Oil");
    Logic.AddTribute(1, 1, 0, 0, TributeText,ResourceType.Sulfur, 500);

    Job.Tribute(function()
        local TributeID = Event.GetTributeUniqueID();
        local PlayerID = Event.GetSourcePlayerID();
        if PlayerID == 1 and TributeID == 1 then
            OilQuest_Stage3();
            return true;
        end
    end);
end

function OilQuest_Stage3()
    local QuestTitle = XGUIEng.GetStringTableText("map_sh_demo/Quest_Oil_2_Title");
    local QuestText  = XGUIEng.GetStringTableText("map_sh_demo/Quest_Oil_2_Text");
    Logic.AddQuest(1, 3, SUBQUEST_OPEN, QuestTitle, QuestText, 1);

    Message(XGUIEng.GetStringTableText("map_sh_demo/Msg_TalkJack"));
    NonPlayerCharacter.Create({
        ScriptName      = "Jack",
        Callback        = NpcBriefingHermit2
    });
    NonPlayerCharacter.Activate("Jack");
end

function OilQuest_Stage4()
    Logic.SetQuestType(1, 3, SUBQUEST_CLOSED, 1);
    HarborQuest_Stage3();
end

-- ########################################################################## --
-- #                               BRIEFING                                 # --
-- ########################################################################## --

function BriefingExposition()
    local Briefing = {
        NoSkip = false,
    };
    local AP = BriefingSystem.AddPages(Briefing);

    AP {
        Target   = "HQ5",
        CloseUp  = false,
        NoSkip   = true,
        FadeIn   = 2,
        Duration = 2,
    }
    AP {
        Title    = "map_sh_demo/BriefingExposition_1_Title",
        Text     = "map_sh_demo/BriefingExposition_1_Text",
        Target   = "HQ1",
        CloseUp  = false,
    }
    AP {
        Target   = "HQ5",
        CloseUp  = false,
        NoSkip   = true,
        FadeOut  = 2,
        Duration = 2,
    }

    Briefing.Finished = function()
        local QuestTitle = XGUIEng.GetStringTableText("map_sh_demo/Quest_Main_1_Title");
        local QuestText  = XGUIEng.GetStringTableText("map_sh_demo/Quest_Main_1_Text");
        Logic.AddQuest(1, 1, MAINQUEST_OPEN, QuestTitle, QuestText, 1);
    end
    BriefingSystem.Start(1, "BriefingExposition", Briefing);
end

function NpcBriefingGarek1(_Npc, _HeroID)
    local Briefing = {
        NoSkip = false,
    };
    local AP = BriefingSystem.AddPages(Briefing);
    local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(_HeroID))
    local HeroName = XGUIEng.GetStringTableText("Names/" ..TypeName);

    AP {
        Title    = HeroName,
        Text     = "map_sh_demo/NpcBriefingGarek1_1_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "Garek",
        Text     = "map_sh_demo/NpcBriefingGarek1_2_Text",
        Target   = "Garek",
        CloseUp  = true,
    }
    AP {
        Title    = HeroName,
        Text     = "map_sh_demo/NpcBriefingGarek1_3_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "Garek",
        Text     = "map_sh_demo/NpcBriefingGarek1_4_Text",
        Target   = "Garek",
        CloseUp  = true,
    }

    Briefing.Finished = function()
        HarborQuest_Stage2();
    end
    BriefingSystem.Start(1, "BriefingGarek1", Briefing);
end

function NpcBriefingGarek2(_Npc, _HeroID)
    local Briefing = {
        NoSkip = false,
    };
    local AP = BriefingSystem.AddPages(Briefing);
    local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(_HeroID))
    local HeroName = XGUIEng.GetStringTableText("Names/" ..TypeName);

    AP {
        Title    = HeroName,
        Text     = "map_sh_demo/NpcBriefingGarek2_1_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "Garek",
        Text     = "map_sh_demo/NpcBriefingGarek2_2_Text",
        Target   = "Garek",
        CloseUp  = true,
    }
    AP {
        Title    = "Garek",
        Text     = "map_sh_demo/NpcBriefingGarek2_3_Text",
        Target   = "Garek",
        CloseUp  = true,
    }

    Briefing.Finished = function()
        HarborQuest_Stage4();
    end
    BriefingSystem.Start(1, "BriefingGarek2", Briefing);
end

function NpcBriefingHermit1(_Npc, _HeroID)
    local Briefing = {
        NoSkip = false,
    };
    local AP = BriefingSystem.AddPages(Briefing);
    local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(_HeroID))
    local HeroName = XGUIEng.GetStringTableText("Names/" ..TypeName);

    AP {
        Title    = "Garek",
        Text     = "map_sh_demo/NpcBriefingHermit1_1_Text",
        Target   = "Garek",
        CloseUp  = true,
    }
    AP {
        Title    = HeroName,
        Text     = "map_sh_demo/NpcBriefingHermit1_2_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "Garek",
        Text     = "map_sh_demo/NpcBriefingHermit1_3_Text",
        Target   = "Garek",
        CloseUp  = true,
    }
    AP {
        Title    = HeroName,
        Text     = "map_sh_demo/NpcBriefingHermit1_4_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }

    Briefing.Finished = function()
        OilQuest_Stage2();
    end
    BriefingSystem.Start(1, "BriefingHermit1", Briefing);
end

function NpcBriefingHermit2(_Npc, _HeroID)
    local Briefing = {
        NoSkip = false,
    };
    local AP = BriefingSystem.AddPages(Briefing);
    local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(_HeroID))
    local HeroName = XGUIEng.GetStringTableText("Names/" ..TypeName);


    AP {
        Title    = HeroName,
        Text     = "map_sh_demo/NpcBriefingHermit2_1_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "Garek",
        Text     = "map_sh_demo/NpcBriefingHermit2_2_Text",
        Target   = "Garek",
        CloseUp  = true,
    }
    AP {
        Title    = "Garek",
        Text     = "map_sh_demo/NpcBriefingHermit2_3_Text",
        Target   = "Lighthouse1",
        CloseUp  = false,
        Action   = function()
            ReplaceEntity("Lighthouse1", Entities.CB_Lighthouse_Activated);
        end
    }

    Briefing.Finished = function()
        OilQuest_Stage4();
    end
    BriefingSystem.Start(1, "BriefingHermit1", Briefing);
end

