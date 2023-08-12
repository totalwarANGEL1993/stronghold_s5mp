function StartTestStuff()
    Lib.Require("module/io/NonPlayerCharacter");
    Lib.Require("module/io/NonPlayerMerchant");
    Lib.Require("module/mp/Syncer");
    Lib.Require("module/cinematic/BriefingSystem");
    Lib.Require("module/lua/Overwrite");
    Lib.Require("module/tutorial/Tutorial");

    CreateTestHonorProvince();
    CreateTestReputationProvince();
    CreateTestMilitaryProvince();
    CreateTestResourceProvince();

    Tutorial.Install();
end

function CreateTestHonorProvince()
    CreateHonorProvince("Honor Province", "Povince1Pos", 25, 0.2);
end

function CreateTestReputationProvince()
    CreateReputationProvince("Reputation Province", "Povince2Pos", 10, 0.1);
end

function CreateTestMilitaryProvince()
    CreateMilitaryProvince("Military Province", "Povince3Pos", 30, 0.5);
end

function CreateTestResourceProvince()
    CreateResourceProvince("Resource Province", "Povince4Pos", ResourceType.IronRaw, 300, 0.5);
end

-- -------------------------------------------------------------------------- --

function TutorialTest1()
    Tutorial.AddMessage {
        Text      = "Diese Nachricht kann weggeklicht werden.",
        Arrow     = nil,
        Condition = nil,
        Action    = nil,
    };

    Tutorial.AddMessage {
        Text        = "Diese Nachricht kann weggeklicht werden.",
        ArrowWidget = "TutorialArrowLeft",
        Arrow       = {30,30},
        Condition   = nil,
    };

    g_EnterAllowed = false;
    Tutorial.AddMessage {
        Text      = "Diese Nachricht springt automatisch weiter.",
        Arrow     = nil,
        Condition = function(_Data)
            return g_EnterAllowed;
        end,
        Action    = nil,
    };

    Tutorial.Start();
end

-- -------------------------------------------------------------------------- --

function CreateTestCamp()
    CreateTestSpawners();
    SetHostile(2, 7);

    OutlawCamp1 = CreateOutlawCamp(
        7, "CampCenter", "CampTarget", 2500, 5, 3*60,
        OutlawSpawner1, OutlawSpawner2, OutlawSpawner3, OutlawSpawner4
    );
end

function CreateTestSpawners()
    OutlawSpawner1 = CreateTroopSpawner(
        7, "Camp1", nil, 3, 60, 2500,
        Entities.CU_BanditLeaderSword2,
        Entities.CU_BanditLeaderBow1,
        Entities.PV_Cannon2
    );
    OutlawSpawner2 = CreateTroopSpawner(
        7, "Camp2", nil, 3, 60, 2500,
        Entities.CU_BanditLeaderSword2,
        Entities.CU_BanditLeaderBow1,
        Entities.PV_Cannon2
    );
    OutlawSpawner3 = CreateTroopSpawner(
        7, "Camp3", nil, 3, 60, 2500,
        Entities.CU_BanditLeaderSword2,
        Entities.CU_BanditLeaderBow1,
        Entities.PV_Cannon2
    );
    OutlawSpawner4 = CreateTroopSpawner(
        7, "Camp4", nil, 3, 60, 2500,
        Entities.CU_BanditLeaderSword2,
        Entities.CU_BanditLeaderBow1,
        Entities.PV_Cannon2
    );
end

function CreateTestArmy()
    SetHostile(1, 5);
    local Position = GetPosition("OP2_DoorPos");
    TestArmyID = AiArmy.New(5, 10, Position, 3500);

    local TroopID = Tools.CreateGroup(5, Entities.PU_LeaderSword4, 8, Position.X, Position.Y, 0);
    AiArmy.AddTroop(TestArmyID, TroopID);
    local TroopID = Tools.CreateGroup(5, Entities.PU_LeaderBow4, 8, Position.X, Position.Y, 0);
    AiArmy.AddTroop(TestArmyID, TroopID);
    local TroopID = Tools.CreateGroup(5, Entities.PU_LeaderRifle2, 8, Position.X, Position.Y, 0);
    AiArmy.AddTroop(TestArmyID, TroopID);
    local TroopID = Tools.CreateGroup(5, Entities.PV_Cannon4, 4, Position.X, Position.Y, 0);
    AiArmy.AddTroop(TestArmyID, TroopID);
end

function ReinforceTestArmy()
    local Position = GetPosition("OP2_DoorPos");
    AiArmy.SpawnTroop(TestArmyID, Entities.PU_LeaderSword4, Position, 3);
    AiArmy.SpawnTroop(TestArmyID, Entities.PU_LeaderBow4, Position, 3);
    AiArmy.SpawnTroop(TestArmyID, Entities.PU_LeaderRifle2, Position, 3);
    AiArmy.SpawnTroop(TestArmyID, Entities.PV_Cannon4, Position, 3);
end

function AttackWithTestArmy()
    AiArmy.SetPosition(TestArmyID, Stronghold.Players[1].DoorPos);
end

function CreateMerchantNpc()
    Message("{scarlet}It{blue}just{yellow}work's{white}!")
    NonPlayerMerchant.Create {
        ScriptName  = "Wolf",
    };
    NonPlayerMerchant.AddResourceOffer("Wolf", ResourceType.Iron, 500, {Gold = 450}, 5, 60);
    NonPlayerMerchant.Activate("Wolf");
end

function CreateBriefingNpc()
    Message("NPC created")
    NonPlayerCharacter.Create {
        ScriptName  = "Wolf",
        Callback    = function()
            CreateStartBriefing(1, "Test1");
        end,
    };
    NonPlayerCharacter.Activate("Wolf");
end

function CreateStartBriefing(_PlayerID, _Name)
    local Briefing = {};
    local AP, ASP, AMC = BriefingSystem.AddPages(Briefing);

    ASP("LordP1", "Page 1", "Test page number 1.", true);
    AMC("Wolf", "Page 2", "Test page number 2.", true, nil, "Option1", "Option1", "Option2", "Option2");

    ASP("Option1", "LordP1", "Page 4", "Test page number 4.", true);
    ASP("LordP1", "Page 5", "{scarlet}Test page number 5.", true);
    AP();
    
    AP {
        Name    = "Option2",
        Title   = "Page 6",
        Text    = "Test page number 6.",
        Target  = "Wolf",
        MiniMap = true
    }
    AP {
        Title   = "Page 6",
        Text    = "Test page number 6.",
        Target  = "Wolf",
        MiniMap = false
    }
    AP {
        Title   = "Page 6",
        Text    = "Test page number 6.",
        Target  = "Wolf",
        MiniMap = true
    }

    BriefingSystem.Start(_PlayerID, _Name, Briefing);
end

function CreateStartBriefing2(_PlayerID, _Name)
    local Briefing = {};
    local AP, ASP, AMC = BriefingSystem.AddPages(Briefing);

    AP {
        Text         = "Test 123 Test 123 Test 123 Test 123 Test 123",
        Target       = "Wolf",
        DialogCamera = true,
    }

    AP {
        Target       = "Wolf",
        Duration     = 3,
        FadeOut      = 3,
        DialogCamera = true,
    }

    AP {
        Target       = "Wolf",
        Duration     = 0.1,
        FaderAlpha   = 1,
        DialogCamera = true,
    }

    AP {
        Target       = "Wolf",
        Duration     = 3,
        FadeIn       = 3,
        DialogCamera = true,
    }

    AP {
        Text         = "Test 456 Test 456 Test 456 Test 456 Test 456",
        Target       = "Wolf",
        DialogCamera = true,
    }

    BriefingSystem.Start(_PlayerID, _Name, Briefing);
end