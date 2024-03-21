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
    -- (value of resources or 0 to not change)
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

        ReplaceEntity("DrawBridge1", Entities.XD_DrawBridgeOpen1);
        ReplaceEntity("Isabella1", Entities.XD_ScriptEntity);
        MakeInvulnerable(GetID("ImposterMayor5"));

        Difficulty_Selected = 0;
        Difficulty_NetEvent = Syncer.CreateEvent(function(_PlayerID, _Selected)
            Difficulty_Selected = _Selected;
        end);
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        SetPlayerName(5, "Bishof");
        SetPlayerName(7, "Räuber");

        ForbidTechnology(Technologies.B_Mercenary, 1);
        ForbidTechnology(Technologies.B_Mercenary, 2);

        SetFriendly(1, 2);

        SetNeutral(1, 3);
        SetNeutral(1, 4);
        SetNeutral(1, 5);
        SetNeutral(2, 3);
        SetNeutral(2, 4);
        SetNeutral(2, 5);

        SetHostile(1, 7);
        SetHostile(2, 7);

        Lib.Require("module/entity/EntityMover");
        Lib.Require("module/cinematic/BriefingSystem");
        Lib.Require("module/io/NonPlayerCharacter");
        BriefingSystem.SetMCButtonCount(8);

        Main1Quest_Init();
        Mayor1Quest_Init();
        TraitorRevengeQuest_Init();
        FindSheepsQuest_Init();
        DrawBridgeQuest_Init();

        Difficulty_BriefingSelectDifficulty();
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
    end,
}

-- ########################################################################## --
-- #                               DIFFICULTY                               # --
-- ########################################################################## --

function Difficulty_SetEasy()
    Message("Easy difficulty selected")
end

function Difficulty_SetNormal()
    Message("Normal difficulty selected")
end

function Difficulty_SetHard()
    Message("Hard difficulty selected")
end

function Difficulty_SetManiac()
    Message("Maniac difficulty selected")
end

function Difficulty_BriefingSelectDifficulty()
    local PlayerID = GUI.GetPlayerID();
    local HostPlayerID = Syncer.GetHostPlayerID();
    local PalPlayerID = (HostPlayerID == 1 and 2) or 1;
    if PlayerID ~= HostPlayerID and PlayerID ~= PalPlayerID then
        return;
    end

    local Briefing = {};
    local AP, ASP, AMC = BriefingSystem.AddPages(Briefing);

    AP {
        Name        = "ChoicePage",
        Title       = "map_sh_midsummerrevolution/BriefingSelectDifficulty_1_Title",
        Text        = "map_sh_midsummerrevolution/BriefingSelectDifficulty_1_Text",
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
        Target      = "HQ1",
        NoSkip      = true,
        Duration    = 10,
    }
    AP("FaderPage");

    AP {
        Name        = "ChoseMedium",
        Title       = "map_sh_midsummerrevolution/BriefingSelectDifficulty_4_Title",
        Text        = "map_sh_midsummerrevolution/BriefingSelectDifficulty_4_Text",
        Target      = "HQ1",
        NoSkip      = true,
        Duration    = 10,
    }
    AP("FaderPage");

    AP {
        Name        = "ChoseHard",
        Title       = "map_sh_midsummerrevolution/BriefingSelectDifficulty_6_Title",
        Text        = "map_sh_midsummerrevolution/BriefingSelectDifficulty_6_Text",
        Target      = "HQ1",
        NoSkip      = true,
        Duration    = 10,
    }
    AP("FaderPage");

    AP {
        Name        = "ChoseManiac",
        Title       = "map_sh_midsummerrevolution/BriefingSelectDifficulty_8_Title",
        Text        = "map_sh_midsummerrevolution/BriefingSelectDifficulty_8_Text",
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
        if GUI.GetPlayerID() == Syncer.GetHostPlayerID() then
            local Selected = BriefingSystem.GetSelectedAnswer("ChoicePage", 1);
            Syncer.InvokeEvent(Difficulty_NetEvent, Selected);
        end
    end

    -- Change briefing for the other player
    if PlayerID == PalPlayerID then
        Briefing[1].Title = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_1_Title";
        Briefing[1].Text = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_1_Text";
        Briefing[1].DisableSkipping = true;
        Briefing[1].MC = nil;
        Briefing[2].Title = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_2_Title";
        Briefing[2].Text = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_2_Text";
        Briefing[4].Title = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_4_Title";
        Briefing[4].Text = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_4_Text";
        Briefing[6].Title = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_6_Title";
        Briefing[6].Text = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_6_Text";
        Briefing[8].Title = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_8_Title";
        Briefing[8].Text = "map_sh_midsummerrevolution/BriefingSelectDifficulty_Pal_8_Text";
    end
    BriefingSystem.Start(HostPlayerID, "BriefingSelectDifficulty_Host", Briefing);
    BriefingSystem.Start(PalPlayerID, "BriefingSelectDifficulty_Pal", Briefing);
end

-- ########################################################################## --
-- #                                 ENEMY                                  # --
-- ########################################################################## --



-- ########################################################################## --
-- #                                TRADER                                  # --
-- ########################################################################## --

function Trader_CreateNpcTrader1()

end

function Trader_CreateNpcTrader2()

end

function Trader_CreateNpcTrader3()

end

-- ########################################################################## --
-- #                                QUESTS                                  # --
-- ########################################################################## --

-- Main --------------------------------------------------------------------- --

MainQuest_ID = 1;
MainQuest_Done = 0;

function Main1Quest_Init()
    Job.Second(Main1Quest_WaitForDifficultySelection);
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
        if XNetwork.Manager_DoesExist() == 0 then
            DestroyEntity("HQ2");
        end
        -- TODO: Setup enemies here
        return true;
    end
end

function MainQuest_RevealEnemyCoalition()
    SetPlayerName(2, "Erzherzog Dovbar");
    SetPlayerName(3, "Dovbars linke Hand");
    SetPlayerName(4, "Dovbars rechte Hand");
end

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
        local PlayerID = GUI.GetPlayerID();
        if PlayerID == 1 or PlayerID == 2 then
            local Msg = "Ihr habt 5000 Taler erhalten.";
            Message(Msg);
        end
    end
    Logic.SetQuestType(1, Mayor1Quest_ID, SUBQUEST_CLOSED, 1);
    Logic.SetQuestType(2, Mayor1Quest_ID, SUBQUEST_CLOSED, 1);
    Mayor1Quest_IsDone = 1;
    Trader_CreateNpcTrader1();
end

function Mayor1Quest_AddToJournal()
    local Title = "Isabellas Verschwinden";
    local Text  = "Die Frau von Dustin Ravage ist verschwunden. Mutmaßlich wurde sie entführt. Niemand weiß, wohin die Entführer geflohen sind. {cr}{cr}- Findet die Entführer von Isabella {cr}- Bringt Isabella zu Dustin zurück";
    for PlayerID = 1, 2 do
        Logic.AddQuest(
            PlayerID,
            Mayor1Quest_ID,
            SUBQUEST_OPEN,
            Placeholder.Replace(Title),
            Placeholder.Replace(Text),
            1
        );
    end
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
        Title       = "Dustin Ravage",
        Text        = "Ihr müsst mir helfen! Mein armes Weib wurde entführt. Sie kamen in der Nacht und haben sie mitgenommen! Bitte, rettet mein Weib!",
        Target      = "Mayor1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "Natürlich helfe ich Euch! In welche Richtung sind sie geflohen? Ich brauche Anhaltspunkte.",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "Dustin Ravage",
        Text        = "Ich kann Euch nur sagen, dass sie in den Süden gegangen sind. Bitte, beeilt Euch und rettet Isabella!",
        Target      = "Mayor1",
        CloseUp     = true,
    }

    Briefing.Finished = function(_PlayerID)
        Mayor1Quest_AddToJournal();
        Mayor1Quest_WifeQuestStarted = 1;
        if TraitorRevengeQuest_IsDone == 1 then
            RescueWifeQuest_Init();
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
            Text        = "Ich habe Euch Euer Weib wiedergebracht.",
            Target      = _HeroID,
            CloseUp     = true,
        }
        AP {
            Title       = "Dustin Ravage",
            Text        = "Wunderbar! Dafür sollt Ihr Reich belohnt werden!",
            Target      = "Mayor1",
            CloseUp     = true,
        }
        AP {
            Title       = "Isabella",
            Text        = "Mögt Ihr in der Hölle brennen, zusammen mit meinem Mann!",
            Target      = "Isabella1",
            CloseUp     = true,
        }
    else
        AP {
            Title       = HeroName,
            Text        = "Ich muss Euch leider mitteilen, dass ich Isabella nicht mehr retten konnte.",
            Target      = _HeroID,
            CloseUp     = true,
        }
        AP {
            Title       = "Dustin Ravage",
            Text        = "Was? Wie tragisch! Was ist denn mit ihr geschenen? Was haben diese Verbrecher ihr angetan?",
            Target      = "Mayor1",
            CloseUp     = true,
        }
        AP {
            Title       = HeroName,
            Text        = "Glaubt mir, das wollt Ihr nicht wissen! Ich ließ sie im Meer bestatten.",
            Target      = _HeroID,
            CloseUp     = true,
        }
    end

    AP {
        Title       = "Dustin Ravage",
        Text        = "Ihr solltet vielleicht meinen Markt aufsuchen. Vielleicht findet Ihr etwas Interessantes...",
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
    SetNeutral(1,7);
    SetNeutral(2,7);
    ReplaceEntity("Traitor1", Entities.XD_ScriptEntity);
    ReplaceEntity("VC_Blockade", Entities.XD_ScriptEntity);
    TraitorRevengeQuest_IsDone = 1;
    if Mayor1Quest_WifeQuestStarted == 1 then
        RescueWifeQuest_Init();
    end
end

function TraitorRevengeQuest_DestroyBanditsController()
    if not IsExisting("BanditTower1") then
        TraitorRevengeQuest_CreateTraitor1Npc2();
        return true;
    end
end

function TraitorRevengeQuest_AddToJournal()
    local Title = "Blutige Rache";
    local Text  = "Ihr seid auf den ehemaligen Anführer einer Räuberbande gestoßen. Er wurde von seinen ehemaligen Kampfgefährten verraten und will nun Rache. Gewährt sie ihm und er wird Euch reichlich belohnen. {cr}{cr}- Vernichtet die Räuberbande";
    for PlayerID = 1, 2 do
        Logic.AddQuest(
            PlayerID,
            TraitorRevengeQuest_ID,
            SUBQUEST_OPEN,
            Placeholder.Replace(Title),
            Placeholder.Replace(Text),
            1
        );
    end
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
        Text        = "Wieso steht ein bewaffneter Mann einfach so in der Gegend herum?",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "Rachsüchtiger Hauptmann",
        Text        = "Weil er von seinen eigenen Leuten verraten wurde!",
        Target      = "Traitor1",
        CloseUp     = true,
    }
    AP {
        Title       = "Rachsüchtiger Hauptmann",
        Text        = "Diese verfluchten Hurensöhne haben mich verraten! Dafür will ich sie leiden sehen!",
        Target      = "BanditTower1",
        CloseUp     = false,
    }
    AP {
        Title       = "Rachsüchtiger Hauptmann",
        Text        = "Wenn Ihr mir helft, werde ich diesen Steinschlag hinter mir wegräumen.",
        Target      = "Traitor1",
        CloseUp     = true,
    }

    Briefing.Finished = function(_PlayerID)
        TraitorRevengeQuest_AddToJournal();
        ReplaceEntity("BanditBarrier", Entities.XD_Rock7);
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
        Text        = "Ich habe mich um Eure ehemalige Bande gekümmert.",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "Rachsüchtiger Hauptmann",
        Text        = "Ich hoffe, sie haben gelitten! Ich danke Euch. Nun werde ich meinen Teil unserer Abmachung erfüllen!",
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
        local Msg = "Isabella ist sicher zu ihrem Ehemann zurückgekehrt.";
        if RescueWifeQuest_IsDone == 2 then
            Msg = "Isabella hat ein neues Leben angefangen! Ihr habt 300 Ehre erhalten.";
        end
        Message(Msg);
    end

    if RescueWifeQuest_IsDone == 1 then
        Move("Isabella1", "Isabella1Pos1");
    else
        MoveAndVanish("Isabella1", "Isabella1Pos2");
        AddHonor(1, 300);
        AddHonor(2, 300);
    end
    NonPlayerCharacter.Delete("Isabella1");
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
    local Title = "Eine unangenehme Wahrheit";
    local Text  = "Nachdem Ihr die Entführer beseitigt habt, erfahrt Ihr die Wahrheit. Isabella wurde nicht entführt, sondern ist vor Dustin geflohen, weil sie seine Mishandlungen nicht mehr ertragen konnte. {cr}{cr}- Eskortiert Isabella in ein neues Leben";
    for PlayerID = 1, 2 do
        Logic.AddQuest(
            PlayerID,
            RescueWifeQuest_ID,
            SUBQUEST_OPEN,
            Placeholder.Replace(Title),
            Placeholder.Replace(Text),
            1
        );
    end
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
                local Msg = "Ich vertraue Euch und Eurem Urteil.";
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
        Text        = "Fürchtet Euch nicht, nun seid Ihr gerettet! Ich habe diese miesen Entführer beseitigt. Ihr könnt heimkehren.",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "Isabella",
        Text        = "Was habt Ihr getan?! Sie haben mich nicht entführt, ich habe sie angeheuert! Mein Ehemann ist ein brutales Schwein. Er schlägt mich, immer dann wenn etwas nicht nach seinem Plan läuft. Ich habe das nicht mehr ausgehalten! Bitte, bringt mich nicht zurück zu meinem Mann!",
        Target      = "Isabella1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "Was soll ich nur machen...",
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

FindSheepQuest_ID = 6;
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
        local Msg = "Alle Schafe sind wieder in ihrem Gehege angekommen!";
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
                    local Msg = "Ein Schaf macht sich auf den Heimweg!";
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
    local Title = "Entlaufene Schafe";
    local Text  = "Ein Bauer ist außer sich vor Wut. Weil seine Knechte nicht aufgepasst haben, sind 5 seiner preisgekrönten Tiere entkommen. {cr}{cr}- Sucht die entlaufenen Schafe {cr}- Bringt die Schafe zurück in ihr Gehege";
    for PlayerID = 1, 2 do
        Logic.AddQuest(
            PlayerID,
            FindSheepQuest_ID,
            SUBQUEST_OPEN,
            Placeholder.Replace(Title),
            Placeholder.Replace(Text),
            1
        );
    end
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
                local Msg = "Na wartet, ich knüpfe euch an euren Schnürschuhen auf, ihr Vollpfosten!";
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
        Title       = "Erregter Bauer",
        Text        = "Arrgh... diese Taugenichtse! Da passt man einmal nicht auf und dann das...",
        Target      = "AngryFarmer1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "Was ist denn geschehen? Wie kann ich helfen?",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "Erregter Bauer",
        Text        = "Diese Knechte sind dumm wie Bohnenstroh? Nichts als Durchzug zwischen den Ohren! Fünf meiner preisgekrönten Schafe sind abgehauen! Könnt Ihr Euch vorstellen, was das für ein Schaden ist?",
        Target      = "AngryFarmer1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "Ich werde Eure Schafe für Euch finden.",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "Erregter Bauer",
        Text        = "Denen werde ich die Ohren langziehen! Die gesamte Mannschaft war wohl wieder im Puff sich die Sorgen davonblasen lassen! Na wartet, ihr Dünnbrettbohrer, wenn ich mit euch fertig bin!",
        Target      = "AngryFarmer1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "Hm... der beruhigt sich bestimmt nicht so schnell...",
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
        Title       = "Glücklicher Bauer",
        Text        = "Danke das Ihr meine Schafe zurückgebracht habt. Die Knechte haben übrigens ihre Lektion gelernt und werden in Zukunft besser aufpassen.",
        Target      = "AngryFarmer1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "Hab ich doch gern gemacht...",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "Glücklicher Bauer",
        Text        = "Ihr solltet vielleicht mit unserem Händler sprechen. Vielleicht findet Ihr etwas Interessantes...",
        Target      = "NPCTrader1",
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
    Logic.SetQuestType(1, RescueWifeQuest_ID, SUBQUEST_CLOSED, 1);
    Logic.SetQuestType(2, RescueWifeQuest_ID, SUBQUEST_CLOSED, 1);
    ReplaceEntity("DrawBridge1", Entities.PB_DrawBridgeClosed1);
    DrawBridgeQuest_IsDone = 0;

    local PlayerID = GUI.GetPlayerID();
    if PlayerID == 1 or PlayerID == 2 then
        XGUIEng.ShowWidget("TradeWindow", 0);
        local Msg = "Der Wächter hat die Brücke heruntergelassen.";
        Message(Msg);
    end
end

function DrawBridgeQuest_AddTribute()
    local Msg = "Bezahlt 7500 Taler, damit der Wächter die Brücke herunterlässt.";
    Logic.AddTribute(1, DrawBridgeQuest_Player1ID, 0, 0, Msg, ResourceType.Gold, 7500);
    Logic.AddTribute(2, DrawBridgeQuest_Player2ID, 0, 0, Msg, ResourceType.Gold, 7500);
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
    local Title = "Ein raffgieriger Wächter";
    local Text  = "Eine hochgezogene Brücke verwehrt Euch den Zugang zu wichtigen Resourcen. Ihr habt keine andere Wahl, Ihr müsst die Münzen sprechen lassen. {cr}{cr}- Bezahlt den Tribut, damit die Brücke heruntergelassen wird";
    for PlayerID = 1, 2 do
        Logic.AddQuest(
            PlayerID,
            DrawBridgeQuest_ID,
            SUBQUEST_OPEN,
            Placeholder.Replace(Title),
            Placeholder.Replace(Text),
            1
        );
    end
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
        Title       = "Gieriger Wächter",
        Text        = "Was wollt Ihr? Hier durch? Na das wird teuer!",
        Target      = "BridgeGuard1",
        CloseUp     = true,
    }
    AP {
        Title       = HeroName,
        Text        = "Orch nö, das ist doch so ein überstrapaziertes Klischee...",
        Target      = _HeroID,
        CloseUp     = true,
    }
    AP {
        Title       = "Gieriger Wächter",
        Text        = "Kann ich auch nicht ändern! Ich bin nur Statist.",
        Target      = "BridgeGuard1",
        CloseUp     = true,
    }

    Briefing.Finished = function(_PlayerID)
        DrawBridgeQuest_AddTribute();
        DrawBridgeQuest_AddToJournal();
    end
    BriefingSystem.Start(PlayerID, "BriefingGuard1", Briefing);
end

