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

    -- Peacetime in minutes
    PeaceTime = 0,

    -- Serfs
    StartingSerfs = 6,

    -- Fill resource piles with resources
    -- (value of resources or 0 to not change)
    MapStartFillClay = 1000,
    MapStartFillStone = 1000,
    MapStartFillIron = 400,
    MapStartFillSulfur = 250,
    MapStartFillWood = 0,

    -- Rank
    Rank = {
        Initial = 0,
        Final = 7,
    },

    -- Resources
    -- {Honor, Gold, Clay, Wood, Stone, Iron, Sulfur}
    Resources = {[1] = {0, 300, 800, 500, 550, 0, 0}},

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

        InitalizePlayer2();
        InitalizePlayer7();
        SetHostile(1,6);
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        Cinematic.SetMCButtonCount(8);
        BriefingExposition();
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

-- Player 2 -- 

function InitalizePlayer2()
    SetupAiPlayer(2, 6, 0);
    SetHostile(1, 2);
    Job.Second(ControllPlayer2Mines);
    InitalizePlayer2Refillers();
    InitalizePlayer2Armies();
end

function ControllPlayer2AttackArmies()
    -- Check defeated
    if not IsExisting("HQ2") then
        return true;
    end
    -- Check 5 seconds passed
    if math.mod(math.floor(Logic.GetTime()), 5) ~= 0 then
        return;
    end
    -- Check bridge build
    local Position = GetPosition("BridgeCheck1");
    local _, BridgeID = Logic.GetEntitiesInArea(Entities.PB_Bridge1, Position.X, Position.Y, 1000, 1);
    if not BridgeID or Logic.IsConstructionComplete(BridgeID) ~= 1 then
        return;
    end

    -- Control attacker 1
    if AiArmy.HasFullStrength(P2AttackArmy1) then
        if AiArmy.IsArmyDoingNothing(P2AttackArmy1) then
            AiArmy.PushCommand(P2AttackArmy1, AiArmy.CreateCommand(AiArmyCommand.Move, "BridgeWP1"), false);
            AiArmy.PushCommand(P2AttackArmy1, AiArmy.CreateCommand(AiArmyCommand.Move, "BridgeWP2"), false);
            AiArmy.PushCommand(P2AttackArmy1, AiArmy.CreateCommand(AiArmyCommand.Move, "SplitWP1"), false);
            AiArmy.PushCommand(P2AttackArmy1, AiArmy.CreateCommand(AiArmyCommand.Move, "BaseWP1"), false);
            AiArmy.PushCommand(P2AttackArmy1, AiArmy.CreateCommand(AiArmyCommand.Move, "HQWP1"), false);
            AiArmy.PushCommand(P2AttackArmy1, AiArmy.CreateCommand(AiArmyCommand.Battle, "HQWP1"), false);
            AiArmy.PushCommand(P2AttackArmy1, AiArmy.CreateCommand(AiArmyCommand.Move, "P2RP1"), false);
        end
    end
    -- Controll attacker 2
    if AiArmy.HasFullStrength(P2AttackArmy2) then
        if AiArmy.IsArmyDoingNothing(P2AttackArmy2) then
            AiArmy.PushCommand(P2AttackArmy2, AiArmy.CreateCommand(AiArmyCommand.Move, "BridgeWP1"), false);
            AiArmy.PushCommand(P2AttackArmy2, AiArmy.CreateCommand(AiArmyCommand.Move, "BridgeWP2"), false);
            AiArmy.PushCommand(P2AttackArmy2, AiArmy.CreateCommand(AiArmyCommand.Move, "SplitWP2"), false);
            AiArmy.PushCommand(P2AttackArmy2, AiArmy.CreateCommand(AiArmyCommand.Move, "BaseWP2"), false);
            AiArmy.PushCommand(P2AttackArmy2, AiArmy.CreateCommand(AiArmyCommand.Move, "HQWP1"), false);
            AiArmy.PushCommand(P2AttackArmy2, AiArmy.CreateCommand(AiArmyCommand.Battle, "HQWP1"), false);
            AiArmy.PushCommand(P2AttackArmy2, AiArmy.CreateCommand(AiArmyCommand.Move, "P2RP1"), false);
        end
    end
end

function ControllPlayer2DefendArmies()
    -- Check defeated
    if not IsExisting("HQ2") then
        return true;
    end
    -- Check 5 seconds passed
    if math.mod(math.floor(Logic.GetTime()), 5) ~= 0 then
        return;
    end

    -- Control defender 1
    if AiArmy.HasFullStrength(P2DefendArmy1) then
        if AiArmy.IsArmyDoingNothing(P2DefendArmy1) then
            AiArmy.PushCommand(P2DefendArmy1, AiArmy.CreateCommand(AiArmyCommand.Move, "P2PP2"), false);
            AiArmy.PushCommand(P2DefendArmy1, AiArmy.CreateCommand(AiArmyCommand.Wait, 2*60), false);
            AiArmy.PushCommand(P2DefendArmy1, AiArmy.CreateCommand(AiArmyCommand.Move, "P2PP1"), false);
            AiArmy.PushCommand(P2DefendArmy1, AiArmy.CreateCommand(AiArmyCommand.Wait, 2*60), false);
            AiArmy.PushCommand(P2DefendArmy1, AiArmy.CreateCommand(AiArmyCommand.Move, "P2PP3"), false);
            AiArmy.PushCommand(P2DefendArmy1, AiArmy.CreateCommand(AiArmyCommand.Wait, 2*60), false);
            AiArmy.PushCommand(P2DefendArmy1, AiArmy.CreateCommand(AiArmyCommand.Move, "P2PP4"), false);
            AiArmy.PushCommand(P2DefendArmy1, AiArmy.CreateCommand(AiArmyCommand.Wait, 2*60), false);
        end
    end
    -- Controll defender 2
    if AiArmy.HasFullStrength(P2DefendArmy2) then
        if AiArmy.IsArmyDoingNothing(P2DefendArmy2) then
            AiArmy.PushCommand(P2DefendArmy2, AiArmy.CreateCommand(AiArmyCommand.Move, "P2PP4"), false);
            AiArmy.PushCommand(P2DefendArmy2, AiArmy.CreateCommand(AiArmyCommand.Wait, 2*60), false);
            AiArmy.PushCommand(P2DefendArmy2, AiArmy.CreateCommand(AiArmyCommand.Move, "P2PP3"), false);
            AiArmy.PushCommand(P2DefendArmy2, AiArmy.CreateCommand(AiArmyCommand.Wait, 2*60), false);
            AiArmy.PushCommand(P2DefendArmy2, AiArmy.CreateCommand(AiArmyCommand.Move, "P2PP1"), false);
            AiArmy.PushCommand(P2DefendArmy2, AiArmy.CreateCommand(AiArmyCommand.Wait, 2*60), false);
            AiArmy.PushCommand(P2DefendArmy2, AiArmy.CreateCommand(AiArmyCommand.Move, "P2PP2"), false);
            AiArmy.PushCommand(P2DefendArmy2, AiArmy.CreateCommand(AiArmyCommand.Wait, 2*60), false);
        end
    end
end

function ControllPlayer2Mines()
    if not IsExisting("HQ2") then
        DestroyEntity("P2ClayPit1");
        DestroyEntity("P2StonePit1");
        DestroyEntity("P2IronPit1");
        return true;
    end
    if not IsExisting("P2ClayMine1") then
        DestroyEntity("P2ClayPit1");
    end
    if not IsExisting("P2StoneMine1") then
        DestroyEntity("P2StonePit1");
    end
    if not IsExisting("P2IronMine1") then
        DestroyEntity("P2IronPit1");
    end
end

function InitalizePlayer2Armies()
    -- Attacking Armies
    P2AttackArmy1 = AiArmy.New(2, 12, GetPosition("P2RP1"), 2500);
    P2AttackArmy2 = AiArmy.New(2, 12, GetPosition("P2PP3"), 2500);
    -- Defending Armies
    P2DefendArmy1 = AiArmy.New(2, 8, GetPosition("P2RP1"), 4000);
    P2DefendArmy2 = AiArmy.New(2, 8, GetPosition("P2RP2"), 4000);
    P2DefendArmy3 = AiArmy.New(2, 4, GetPosition("P2PP4"), 5000);

    -- Restrict types
    AiArmy.SetAllowedTypes(P2AttackArmy1, GetPlayer2AttackerArmyTypes());
    AiArmy.SetAllowedTypes(P2AttackArmy2, GetPlayer2AttackerArmyTypes());
    AiArmy.SetAllowedTypes(P2DefendArmy1, GetPlayer2DefenderArmyTypes());
    AiArmy.SetAllowedTypes(P2DefendArmy2, GetPlayer2DefenderArmyTypes());

    -- Connect to refiller
    AiArmyRefiller.AddArmy(P2Refiller1, P2AttackArmy1);
    AiArmyRefiller.AddArmy(P2Refiller2, P2AttackArmy1);
    AiArmyRefiller.AddArmy(P2Refiller3, P2AttackArmy1);
    AiArmyRefiller.AddArmy(P2Refiller4, P2AttackArmy1);
    AiArmyRefiller.AddArmy(P2Refiller5, P2AttackArmy1);
    AiArmyRefiller.AddArmy(P2Refiller6, P2AttackArmy1);
    AiArmyRefiller.AddArmy(P2Refiller1, P2AttackArmy2);
    AiArmyRefiller.AddArmy(P2Refiller2, P2AttackArmy2);
    AiArmyRefiller.AddArmy(P2Refiller3, P2AttackArmy2);
    AiArmyRefiller.AddArmy(P2Refiller4, P2AttackArmy2);
    AiArmyRefiller.AddArmy(P2Refiller5, P2AttackArmy2);
    AiArmyRefiller.AddArmy(P2Refiller6, P2AttackArmy2);
    AiArmyRefiller.AddArmy(P2Refiller1, P2DefendArmy1);
    AiArmyRefiller.AddArmy(P2Refiller2, P2DefendArmy1);
    AiArmyRefiller.AddArmy(P2Refiller3, P2DefendArmy1);
    AiArmyRefiller.AddArmy(P2Refiller4, P2DefendArmy1);
    AiArmyRefiller.AddArmy(P2Refiller5, P2DefendArmy1);
    AiArmyRefiller.AddArmy(P2Refiller6, P2DefendArmy1);
    AiArmyRefiller.AddArmy(P2Refiller1, P2DefendArmy2);
    AiArmyRefiller.AddArmy(P2Refiller2, P2DefendArmy2);
    AiArmyRefiller.AddArmy(P2Refiller3, P2DefendArmy2);
    AiArmyRefiller.AddArmy(P2Refiller4, P2DefendArmy2);
    AiArmyRefiller.AddArmy(P2Refiller5, P2DefendArmy2);
    AiArmyRefiller.AddArmy(P2Refiller6, P2DefendArmy2);
    AiArmyRefiller.AddArmy(P2Refiller7, P2DefendArmy3);

    -- Add Controllers
    Job.Second(ControllPlayer2AttackArmies);
    Job.Second(ControllPlayer2DefendArmies);
end

function GetPlayer2AttackerArmyTypes()
    return {
        Entities.PU_LeaderPoleArm1,
        Entities.PU_LeaderAxe3,
        Entities.PU_LeaderBow1,
        Entities.PU_LeaderRifle1,
        Entities.PU_LeaderHeavyCavalry2,
        Entities.PV_Cannon3,
        Entities.PV_Cannon4,
    };
end

function GetPlayer2DefenderArmyTypes()
    return {
        Entities.PU_LeaderAxe2,
        Entities.PU_LeaderPoleArm3,
        Entities.PU_LeaderBow3,
        Entities.PU_LeaderRifle1,
        Entities.PU_LeaderCavalry2,
        Entities.PV_Cannon3,
    };
end

function InitalizePlayer2Refillers()
    P2Refiller1 = AiArmyRefiller.CreateSpawner{
        ScriptName   = "P2Barracks1",
        SpawnPoint   = "P2Barracks1Spawn",
        SpawnTimer   = 30,
        Sequentially = true,
        Endlessly    = true,
        AllowedTypes = {
            {Entities.PU_LeaderPoleArm1, 3},
            {Entities.PU_LeaderAxe2, 3},
            {Entities.PU_LeaderPoleArm1, 3},
        },
    };
    P2Refiller2 = AiArmyRefiller.CreateSpawner{
        ScriptName   = "P2Barracks2",
        SpawnPoint   = "P2Barracks2Spawn",
        SpawnTimer   = 30,
        Sequentially = true,
        Endlessly    = true,
        AllowedTypes = {
            {Entities.PU_LeaderAxe3, 3},
            {Entities.PU_LeaderPoleArm3, 3},
        },
    };
    P2Refiller3 = AiArmyRefiller.CreateSpawner{
        ScriptName   = "P2Archery1",
        SpawnPoint   = "P2Archery1Spawn",
        SpawnTimer   = 30,
        Sequentially = true,
        Endlessly    = true,
        AllowedTypes = {
            {Entities.PU_LeaderBow1, 3},
        },
    };
    P2Refiller4 = AiArmyRefiller.CreateSpawner{
        ScriptName   = "P2Archery2",
        SpawnPoint   = "P2Archery2Spawn",
        SpawnTimer   = 30,
        Sequentially = true,
        Endlessly    = true,
        AllowedTypes = {
            {Entities.PU_LeaderBow3, 3},
            {Entities.PU_LeaderRifle1, 3},
            {Entities.PU_LeaderBow3, 3},
        },
    };
    P2Refiller5 = AiArmyRefiller.CreateSpawner{
        ScriptName   = "P2Stable1",
        SpawnPoint   = "P2Stable1Spawn",
        SpawnTimer   = 30,
        Sequentially = true,
        Endlessly    = true,
        AllowedTypes = {
            {Entities.PU_LeaderCavalry2, 3},
            {Entities.PU_LeaderHeavyCavalry2, 3},
            {Entities.PU_LeaderCavalry2, 3},
        },
    };
    P2Refiller6 = AiArmyRefiller.CreateSpawner{
        ScriptName   = "P2Foundry1",
        SpawnPoint   = "P2Foundry1Spawn",
        SpawnTimer   = 30,
        Sequentially = true,
        Endlessly    = true,
        AllowedTypes = {
            {Entities.PV_Cannon3, 0},
            {Entities.PV_Cannon4, 0},
            {Entities.PV_Cannon3, 0},
        },
    };
    P2Refiller7 = AiArmyRefiller.CreateSpawner{
        ScriptName   = "HQ2",
        SpawnPoint   = "HQ2Spawn",
        SpawnTimer   = 30,
        SpawnAmount  = 4,
        Sequentially = true,
        Endlessly    = true,
        AllowedTypes = {
            {Entities.CU_BlackKnight_LeaderMace1, 3},
        },
    };
end

-- Player 7 --

function InitalizePlayer7()
    SetHostile(1, 7);

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
        ReplaceEntity("npcTrader" ..i, Entities.XD_ScriptEntity);
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

    local QuestTitle = XGUIEng.GetStringTableText("map_sh_demo/Quest_Harbor_1_Title");
    local QuestText  = XGUIEng.GetStringTableText("map_sh_demo/Quest_Harbor_1_Text");
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
        ReplaceEntity("npcTrader" ..i, Entities.CU_Trader);
    end

    local QuestTitle = XGUIEng.GetStringTableText("map_sh_demo/Quest_Harbor_2_Title");
    local QuestText  = XGUIEng.GetStringTableText("map_sh_demo/Quest_Harbor_2_Text");
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
    CreateShipMerchant1();
    CreateShipMerchant2();
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
-- #                               MERCHANTS                                # --
-- ########################################################################## --

function CreateShipMerchant1()
    local ScriptName = "trader1";
    NonPlayerMerchant.Create {ScriptName = ScriptName};
    NonPlayerMerchant.AddResourceOffer(ScriptName, ResourceType.Gold, 1000, {Stone = 1000}, 5, 2*60);
    NonPlayerMerchant.AddResourceOffer(ScriptName, ResourceType.Sulfur, 250, {Gold = 1000}, 3, 2*60);
    NonPlayerMerchant.AddResourceOffer(ScriptName, ResourceType.Iron, 500, {Gold = 1000}, 3, 2*60);
    NonPlayerMerchant.Activate(ScriptName);
end

function CreateShipMerchant2()
    local ScriptName = "trader2";
    NonPlayerMerchant.Create {ScriptName = ScriptName};
    NonPlayerMerchant.AddResourceOffer(ScriptName, ResourceType.Gold, 500, {Wood = 1500}, 5, 2*60);
    NonPlayerMerchant.AddResourceOffer(ScriptName, ResourceType.Gold, 500, {Clay = 1200}, 5, 2*60);
    NonPlayerMerchant.AddResourceOffer(ScriptName, ResourceType.Stone, 1000, {Gold = 1000}, 3, 2*60);
    NonPlayerMerchant.Activate(ScriptName);
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
        Target   = "HQ1",
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
        Target   = "HQ1",
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

