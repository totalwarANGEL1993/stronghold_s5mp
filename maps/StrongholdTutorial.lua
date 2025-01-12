SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 3,

    -- ###################################################################### --
    -- #                             CONFIG                                 # --
    -- ###################################################################### --

    -- Disable standard victory condition?
    -- (Game is not lost when the HQ falls)
    DisableDefaultWinCondition = true,
    -- Disable rule configuration?
    DisableRuleConfiguration = true;

    -- Peacetime in minutes
    PeaceTime = 0,
    -- Open up named gates on the map.
    -- (PTGate1, PTGate2, ...)
    PeaceTimeOpenGates = true,

    -- Serfs
    StartingSerfs = 3,
    -- Fill resource piles with resources
    -- (value of resources or 0 to not change)
    MapStartFillClay = 400,
    MapStartFillStone = 400,
    MapStartFillIron = 400,
    MapStartFillSulfur = 400,
    MapStartFillWood = 400,

    -- Rank
    Rank = {
        Initial = 0,
        Final = 7,
    },

    -- Resources
    -- {Honor, Gold, Clay, Wood, Stone, Iron, Sulfur}
    Resources = {[1] = {0, 0, 0, 0, 0, 0, 0}},

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

        Lib.Require("module/cinematic/BriefingSystem");
        Lib.Require("module/cinematic/BriefingSystem");
        Lib.Require("module/io/NonPlayerCharacter");
        Lib.Require("module/io/NonPlayerMerchant");
        Lib.Require("module/tutorial/Tutorial");

        Tutorial.Install();
        LockRank(1, 0);
        ForbidTechnology(Technologies.T_FreeCamera, 1);

        LockPlayerRight(1, PlayerRight.Scout);
        LockPlayerRight(1, PlayerRight.Thief);
        LockPlayerRight(1, PlayerRight.ArchitectShop);
        LockPlayerRight(1, PlayerRight.PowerPlant);

        gvTutorial_Skip = false;
        BriefingTutorialIntro();
        Tutorial_OverwriteCallbacks();
        Tutorial_CreateProvince();

        CreatePlayer2();
        CreatePlayer3();
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        ChangePlayer("HQ1", 8);
        Tools.CreateSoldiersForLeader(GetID("Scout"), 3);
        SetupAiPlayer(2, 0, 0);
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
-- #                               TUTORIAL                                 # --
-- ########################################################################## --

gvGender = {
    Name = "Dario",
    Address = "Milord",
    Pronome = {"er", "ihn", "sein", "seine"},
}

function Tutorial_OverwriteCallbacks()
    -- For setting a rallypint
    Overwrite.CreateOverwrite("GameCallback_SH_Logic_RallyPointPlaced", function(_PlayerID, _EntityID, _X, _Y, _Initial)
        Overwrite.CallOriginal();
        gvTutorial_RallyPointSet = _Initial ~= true;
    end);

    -- For selecting the hero
    Overwrite.CreateOverwrite("GameCallback_Logic_BuyHero_OnHeroSelected", function(_PlayerID, _EntityID, _Type)
        Overwrite.CallOriginal();
        local TypeName = Logic.GetEntityTypeName(_Type);
        gvGender.Name = XGUIEng.GetStringTableText("Names/" ..TypeName);
        if GetGender(_Type) == Gender.Female then
            gvGender.Pronome = {"sie", "sie", "ihr", "ihre"};
            gvGender.Address = "Milady";
        end
        gvTutorial_HeroSelected = true;
    end);

    -- For claiming a province
    Overwrite.CreateOverwrite("GameCallback_SH_Logic_OnProvinceClaimed", function(_PlayerID, _ProvinceID, _BuildingID)
        Overwrite.CallOriginal();
        gvTutorial_ProvinceClaimed = true;
    end);

    -- For when player runs in a trap
    Overwrite.CreateOverwrite("GameCallback_SH_Logic_OnSpawnTrapTriggered", function(_PlayerID, _Type, _X, _Y, ...)
        Overwrite.CallOriginal();
        if _PlayerID == 2 or _PlayerID == 3 then
            gvTutorial_OnEnemyTrapActivated = true;
            gvTutorial_TrapX = _X;
            gvTutorial_TrapY = _Y;
        end
    end);

    -- For when player runs in a trap
    Overwrite.CreateOverwrite("GameCallback_SH_Logic_OnAoETrapTriggered", function(_PlayerID, _Type, _X, _Y)
        Overwrite.CallOriginal();
        if _PlayerID == 2 or _PlayerID == 3 then
            gvTutorial_OnEnemyTrapActivated = true;
            gvTutorial_TrapX = _X;
            gvTutorial_TrapY = _Y;
        end
    end);

    -- For when player selects a perk
    Overwrite.CreateOverwrite("GameCallback_SH_Logic_OnPerkUnlocked", function(_PlayerID, _PerkID)
        Overwrite.CallOriginal();
        if gvTutorial_PlayerCanChoosePerk then
            gvTutorial_OnPlayerChosePerk = true;
        end
    end);
end

function Tutorial_CreateProvince()
    CreateResourceProvince(
        "Gut Doppelkorn",
        "VillagePos",
        ResourceType.GoldRaw,
        500,
        0.5,
        "ProvinceHut1",
        "ProvinceHut2",
        "ProvinceHut3",
        "ProvinceHut4",
        "ProvinceHut5",
        "ProvinceHut6"
    );
end

-- Part 1 ------------------------------------------------------------------- --

function Tutorial_StartPart1()
    Tutorial.Stop();
    Tutorial.SetCallback(function()
        BriefingScoutNpc();
    end);
    Tutorial_AddMainInterfaceSection();
    Tutorial_AddCastleInterfaceSection();
    Tutorial.Start();
end

function Tutorial_AddMainInterfaceSection()
    local ArrowPos_Clock = {495, 85};
    local ArrowPos_FindSerf = {545, 60};
    local ArrowPos_FindTroops = {581, 60};
    local ArrowPos_NewRes = {930, 60};
    local ArrowPos_Promote = {135, 690};
    local ArrowPos_Military = {240, 674};
    local ArrowPos_Slaves = {240, 698};
    local ArrowPos_Civil = {240, 686};
    local ArrowPos_Care = {240, 712};

    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_1",
        ClickCatcher = true,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_2",
        ClickCatcher = true,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_3",
        ClickCatcher = true,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_4",
        ClickCatcher = true,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_5",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_NewRes,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_6",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_NewRes,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_7",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_NewRes,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_8",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_NewRes,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_9",
        ClickCatcher = true,
        Arrow        = ArrowPos_Promote,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_10",
        ClickCatcher = true,
        Arrow        = ArrowPos_Care,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_13",
        ClickCatcher = true,
        Arrow        = ArrowPos_Military,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_11",
        ClickCatcher = true,
        Arrow        = ArrowPos_Civil,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_12",
        ClickCatcher = true,
        Arrow        = ArrowPos_Slaves,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_14",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_Clock,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_15",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_Clock,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_16",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_Clock,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_17",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_FindSerf,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainInterface_18",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_FindTroops,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_19",
        ClickCatcher = true,
        Action      = function(_Page)
            ChangePlayer("HQ1", 1);
        end,
    }
end

function Tutorial_AddCastleInterfaceSection()
    local ArrowPos_RallyPoint = {675, 625};
    local ArrowPos_Treasury = {668, 575};
    local ArrowPos_Measure = {698, 575};
    local ArrowPos_BuyNoble = {350, 700};
    local ArrowPos_Tax = {517, 692};
    local ArrowPos_Measures_Row = {520, 635};
    local ArrowPos_Measures_Bar = {520, 680};

    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_1",
        Condition    = function(_Page)
            return IsEntitySelected("HQ1");
        end
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_2",
        ClickCatcher = true,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_3",
        ClickCatcher = true,
        Arrow        = ArrowPos_Treasury,
        ArrowUpdate = function(_Data)
            return IsEntitySelected(GetHeadquarterID(1));
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_5",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_Tax,
        ArrowUpdate = function(_Data)
            return IsEntitySelected(GetHeadquarterID(1));
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_6",
        ClickCatcher = true,
        Arrow        = ArrowPos_RallyPoint,
        ArrowUpdate = function(_Data)
            return IsEntitySelected(GetHeadquarterID(1));
        end,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_7",
        ClickCatcher = true,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_8",
        Condition    = function(_Data)
            return gvTutorial_RallyPointSet;
        end
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_9",
        ClickCatcher = true,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_10",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_BuyNoble,
        ArrowUpdate = function(_Data)
            return IsEntitySelected(GetHeadquarterID(1));
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_11",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_BuyNoble,
        ArrowUpdate = function(_Data)
            return IsEntitySelected(GetHeadquarterID(1));
        end,
        Condition    = function(_Data)
            return gvTutorial_HeroSelected;
        end
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_12",
        ClickCatcher = true,
        Action       = function(_Data)
            Tutorial_AddHeroSelectedSection();
        end
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_4",
        ClickCatcher = true,
        Arrow        = ArrowPos_Measure,
        ArrowUpdate = function(_Data)
            return IsEntitySelected(GetHeadquarterID(1));
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_13",
        Arrow        = ArrowPos_Measure,
        ArrowUpdate = function(_Data)
            return IsEntitySelected(GetHeadquarterID(1));
        end,
        ClickCatcher = true,
        Condition    = function(_Data)
            local WidgetID = Stronghold.Building:GetLastSelectedKeepTab(1);
            return WidgetID == gvGUI_WidgetID.ToBuildingSettlersMenu;
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_14",
        Arrow        = ArrowPos_Measures_Row,
        ArrowUpdate = function(_Data)
            return IsEntitySelected(GetHeadquarterID(1));
        end,
        ClickCatcher = true,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainCastle_15",
        Arrow        = ArrowPos_Measures_Bar,
        ArrowUpdate = function(_Data)
            return IsEntitySelected(GetHeadquarterID(1));
        end,
        ClickCatcher = true,
    }
end

function Tutorial_AddHeroSelectedSection()
    local Text = XGUIEng.GetStringTableText("sh_tutorial/ExplainCastle_16");
    Tutorial.AddMessage {
        Text         = string.format(Text, gvGender.Name, gvGender.Pronome[2]),
        Condition    = function(_Data)
            return IsEntitySelected(GetNobleID(1));
        end
    }
end

-- Part 2 ------------------------------------------------------------------- --

function Tutorial_StartPart2()
    Tutorial.Stop();
    Tutorial.SetCallback(function()
        Job.Second(Tutorial_StartOutpostTrigger);
    end);
    Tutorial_AddUnitSelectionSection();
    Tutorial_AddProvisionSection();
    Tutorial_AddExplainBarracks();
    Tutorial.Start();
end

function Tutorial_AddUnitSelectionSection()
    local ArrowPos_Status = {740, 672};
    local ArrowPos_TroopSize = {740, 684};
    local ArrowPos_Armor = {740, 705};
    local ArrowPos_Damage = {740, 720};
    local ArrowPos_Upkeep = {740, 735};
    local ArrowPos_Health = {740, 650};
    local ArrowPos_Experience = {740, 642};
    local ArrowPos_Expel = {720, 700};
    local ArrowPos_BuySoldier = {318, 700};
    local ArrowPos_Commands = {380, 700};
    local ArrowPos_Pace = {720, 626};

    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_1",
        ClickCatcher = true,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_2",
        Condition   = function(_Data)
            return IsEntitySelected("Scout");
        end
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_3",
        ClickCatcher = true,
        ArrowWidget  = "TutorialArrowUp",
        Arrow        = ArrowPos_Commands,
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_4",
        ClickCatcher = true,
        Arrow        = ArrowPos_BuySoldier,
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_5",
        ClickCatcher = true,
        Arrow        = ArrowPos_Experience,
        ArrowWidget  = "TutorialArrowRight",
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_6",
        ClickCatcher = true,
        Arrow        = ArrowPos_Health,
        ArrowWidget  = "TutorialArrowRight",
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_7",
        ClickCatcher = true,
        Arrow        = ArrowPos_Status,
        ArrowWidget  = "TutorialArrowRight",
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_8",
        ClickCatcher = true,
        Arrow        = ArrowPos_Status,
        ArrowWidget  = "TutorialArrowRight",
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_9",
        ClickCatcher = true,
        Arrow        = ArrowPos_Status,
        ArrowWidget  = "TutorialArrowRight",
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_10",
        ClickCatcher = true,
        Arrow        = ArrowPos_Pace,
        ArrowWidget  = "TutorialArrowUp",
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_11",
        ClickCatcher = true,
        Arrow        = ArrowPos_TroopSize,
        ArrowWidget  = "TutorialArrowRight",
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_12",
        ClickCatcher = true,
        Arrow        = ArrowPos_Armor,
        ArrowWidget  = "TutorialArrowRight",
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_13",
        ClickCatcher = true,
        Arrow        = ArrowPos_Damage,
        ArrowWidget  = "TutorialArrowRight",
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_14",
        ClickCatcher = true,
        Arrow        = ArrowPos_Upkeep,
        ArrowWidget  = "TutorialArrowRight",
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainUnit_15",
        ClickCatcher = true,
        Arrow        = ArrowPos_Expel,
        ArrowUpdate = function(_Data)
            return IsEntitySelected("Scout");
        end,
    }
end

function Tutorial_AddProvisionSection()
    local ArrowPos_BuyNoble = {350, 700};

    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainManage_1",
        ClickCatcher = true,
    }
    Tutorial.AddMessage {
        Text         = "sh_tutorial/ExplainManage_2",
        ClickCatcher = true,
        Action       = function(_Data)
            Logic.ResumeAllEntities();
            AddResourcesToPlayer(1, {
                [ResourceType.GoldRaw]   = 1500,
                [ResourceType.ClayRaw]   = 1000,
                [ResourceType.WoodRaw]   = 800,
                [ResourceType.StoneRaw]  = 550,
            });
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_3",
        Condition   = function(_Data)
            local SerfAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(1, Entities.PU_Serf);
            return SerfAmount >= 9;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_4",
        Action      = function(_Data)
            local Position = GetPosition("ClayMinePointer");
            gvTutorial_ClayMinePointer = Logic.CreateEffect(GGL_Effects.FXTerrainPointer, Position.X, Position.Y, 0);
        end,
        Condition   = function(_Data)
            local _, ID1 = Logic.GetPlayerEntities(1, Entities.PB_ClayMine1, 1);
            local _, ID2 = Logic.GetPlayerEntities(1, Entities.PB_ClayMine2, 1);
            local _, ID3 = Logic.GetPlayerEntities(1, Entities.PB_ClayMine3, 1);
            return (ID1 and Logic.IsConstructionComplete(ID1) == 1) or
                   (ID2 and Logic.IsConstructionComplete(ID2) == 1) or
                   (ID3 and Logic.IsConstructionComplete(ID3) == 1);
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_5",
        SlowMotion  = true,
        Action      = function(_Data)
            Logic.DestroyEffect(gvTutorial_ClayMinePointer);
        end,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_6",
        Condition   = function(_Data)
            local NoFarm = Logic.GetNumberOfWorkerWithoutEatPlace(1);
            local NoHouse = Logic.GetNumberOfWorkerWithoutSleepPlace(1);
            return NoFarm == 0 and NoHouse == 0;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_7",
        SlowMotion  = true,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_8",
        Condition   = function(_Data)
            local WorkerCount = Logic.GetNumberOfAttractedWorker(1);
            local Reputation = GetReputationIncome(1);
            return WorkerCount >= 15 and Reputation >= 0;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_9",
        SlowMotion  = true,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_10",
        Action      = function(_Data)
            gvTutorial_PlayerCanChoosePerk = true;
            LockRank(1, 8);
        end,
        Condition   = function(_Data)
            return GetRank(1) >= 1;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_11",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_12",
        SlowMotion  = true,
        Arrow       = ArrowPos_BuyNoble,
        ArrowWidget  = "TutorialArrowUp",
        ArrowUpdate = function(_Data)
            return IsEntitySelected(GetHeadquarterID(1));
        end,
        Condition   = function(_Data)
            return XGUIEng.IsWidgetShown("HeroPerkWindow") == 0 and
                   gvTutorial_OnPlayerChosePerk == true
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_13",
        SlowMotion  = true,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_14",
        SlowMotion  = true,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_15",
        SlowMotion  = true,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_16",
        SlowMotion  = true,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_17",
        Condition   = function(_Data)
            local _, ID1 = Logic.GetPlayerEntities(1, Entities.PB_Monastery1, 1);
            local _, ID2 = Logic.GetPlayerEntities(1, Entities.PB_Monastery2, 1);
            local _, ID3 = Logic.GetPlayerEntities(1, Entities.PB_Monastery3, 1);
            return (ID1 and Logic.IsConstructionComplete(ID1) == 1) or
                   (ID2 and Logic.IsConstructionComplete(ID2) == 1) or
                   (ID3 and Logic.IsConstructionComplete(ID3) == 1);
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_18",
        Condition   = function(_Data)
            return GetRank(1) >= 2;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_19",
        Condition   = function(_Data)
            local _, ID1 = Logic.GetPlayerEntities(1, Entities.PB_Headquarters2, 1);
            local _, ID2 = Logic.GetPlayerEntities(1, Entities.PB_Headquarters3, 1);
            return (ID1 and Logic.IsConstructionComplete(ID1) == 1) or
                   (ID2 and Logic.IsConstructionComplete(ID2) == 1);
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_20",
        Condition   = function(_Data)
            local _, ID1 = Logic.GetPlayerEntities(1, Entities.PB_University1, 1);
            local _, ID2 = Logic.GetPlayerEntities(1, Entities.PB_University2, 1);
            return (ID1 and Logic.IsConstructionComplete(ID1) == 1) or
                   (ID2 and Logic.IsConstructionComplete(ID2) == 1);
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_21",
        SlowMotion  = true,
        Action      = function(_Data)
            local Position = GetPosition("P2AttackPath3");
            Tools.ExploreArea(Position.X, Position.Y, 10);
            Camera.ScrollSetLookAt(Position.X, Position.Y);
        end,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_22",
    }
end

function Tutorial_AddExplainBarracks()
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainRecruit_1",
        Condition   = function(_Data)
            local _, ID1 = Logic.GetPlayerEntities(1, Entities.PB_Barracks1, 1);
            local _, ID2 = Logic.GetPlayerEntities(1, Entities.PB_Barracks2, 1);
            return (ID1 and Logic.IsConstructionComplete(ID1) == 1) or
                   (ID2 and Logic.IsConstructionComplete(ID2) == 1);
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainRecruit_2",
        SlowMotion  = true,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainRecruit_3",
        Condition   = function(_Data)
            local LeaderList = Stronghold:GetLeadersOfType(1, 0);
            for i= table.getn(LeaderList), 1, -1 do
                if IsTraining(LeaderList[i]) then
                    table.remove(LeaderList, i);
                end
            end
            return table.getn(LeaderList) >= 3;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainRecruit_4",
        SlowMotion  = true,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainRecruit_5",
        Action      = function(_Data)
            ReplaceEntity("BridgeBarrier", Entities.XD_Rock7);
            DelinquentsCampActivateAttack(gvPlayer3Camp, true);
        end,
    }
end

-- Part 3 ------------------------------------------------------------------- --

function Tutorial_StartOutpost()
    Tutorial.Stop();
    Tutorial.SetCallback(function()
        Job.Second(Tutorial_StartTrapTrigger);
        Job.Second(Tutorial_StartClosedPitTrigger);
        Job.Second(Tutorial_EpilogeTrigger);
        MakeVulnerable("P3Tower");
    end);

    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainProvince_1",
        SlowMotion  = true,
        Action      = function(_Data)
            local Position = GetPosition("VillagePos");
            Tools.ExploreArea(Position.X, Position.Y, 10);
            Camera.ScrollSetLookAt(Position.X, Position.Y);
        end,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainProvince_2",
        SlowMotion  = true,
    }

    Tutorial.Start();
end

function Tutorial_StartOutpostTrigger()
    local x,y,z = Logic.EntityGetPos(GetID("VillagePos"));
    local Amount = Logic.GetPlayerEntitiesInArea(1, 0, x, y, 1500, 16);
    if Amount > 1 then
        Tutorial_StartOutpost();
        return true;
    end
end

function Tutorial_StartTrap()
    Tutorial.Stop();
    Tutorial.SetCallback(function()
        UnlockPlayerRight(1, PlayerRight.Thief);
    end);

    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainTrap_1",
        SlowMotion  = true,
        Action      = function(_Data)
            Camera.ScrollSetLookAt(gvTutorial_TrapX, gvTutorial_TrapY);
        end,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainTrap_2",
        SlowMotion  = true,
        Action      = function(_Data)
            gvTutorial_OnTrapTutorialOver = true;
        end,
    }
    Tutorial.Start();
end

function Tutorial_StartTrapTrigger()
    if  not gvTutorial_OnTrapTutorialOver
    and gvTutorial_OnEnemyTrapActivated then
        Tutorial_StartTrap();
        return true;
    end
end

function Tutorial_StartClosedPit()
    Tutorial.Stop();
    Tutorial.SetCallback(function()
        Job.Second(Tutorial_EpilogeTrigger);
        UnlockPlayerRight(1, PlayerRight.Scout);
    end);

    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainScout_1",
        SlowMotion  = true,
        Action      = function(_Data)
            local Position = GetPosition("ClosedPit1Pos");
            Tools.ExploreArea(Position.X, Position.Y, 10);
            Camera.ScrollSetLookAt(Position.X, Position.Y);
        end,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainScout_2",
        SlowMotion  = true,
        Action      = function(_Data)
            gvTutorial_OnPitTutorialOver = true;
        end,
    }
    Tutorial.Start();
end

function Tutorial_StartClosedPitTrigger()
    if  not gvTutorial_OnPitTutorialOver
    and AreEntitiesInArea(1, 0, GetPosition("ClosedPit1Pos"), 8000, 1) then
        Tutorial_StartClosedPit();
        return true;
    end
end

-- End ---------------------------------------------------------------------- --

function Tutorial_Epiloge()
    Tutorial.Stop();
    Tutorial.SetCallback(function()
        BriefingGuardian1Npc();
        Job.Second(Tutorial_CheckVictory);
    end);

    Tutorial.AddMessage {
        Text        = "sh_tutorial/TutorialEnd_1",
        SlowMotion  = true,
        Action      = function(_Data)
            ReplaceEntity("GateDude", Entities.CU_PoleArmIdle);
        end,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/TutorialEnd_2",
        SlowMotion  = true,
    }
    Tutorial.Start();
end

function Tutorial_EpilogeTrigger()
    if not IsExisting("HQ3") and gvTutorial_OnTrapTutorialOver and gvTutorial_OnPitTutorialOver then
        Tutorial_Epiloge();
        return true;
    end
end

function Tutorial_BridgeBuildTrigger()
    local n, EntityID = Logic.GetEntities(Entities.PB_Bridge3, 1);
    if n > 0 and Logic.IsConstructionComplete(EntityID) == 1 then
        BriefingGuardian2Npc();
        Message(XGUIEng.GetStringTableText("map_sh_tutorial/Info_GateGuardian"));
        Logic.SetQuestType(1, 2, SUBQUEST_CLOSED, 1);
        return true;
    end
end

function Tutorial_CheckVictory()
    if not IsExisting("Scorillo") then
        Victory(1);
        return true;
    end
end

function Tutorial_SkipExplainations()
    -- Prepare player 1
    for k,v in pairs(GetPlayerEntities(1, Entities.PU_Serf)) do
        Logic.ResumeEntity(v);
    end
    DestroyEntity("Scout");
    ChangePlayer("HQ1", 1);
    LockRank(1, 8);
    UnlockPlayerRight(1, PlayerRight.Scout);
    UnlockPlayerRight(1, PlayerRight.Thief);
    Tools.GiveResouces(1, 5000, 4000, 2500, 3000, 3000, 3000);
    AddHonor(1, 1000);
    -- Delete player 3
    for k,v in pairs(GetPlayerEntities(3, 0)) do
        DestroyEntity(v);
    end
    -- Start post tutorial content
    ReplaceEntity("BridgeBarrier", Entities.XD_Rock7);
    ReplaceEntity("GateDude", Entities.CU_PoleArmIdle);
    BriefingGuardian1Npc();
    Job.Second(Tutorial_CheckVictory);
end

-- ########################################################################## --
-- #                                ENEMY                                   # --
-- ########################################################################## --

-- The final boss is implemented using the cerberus army. Most of the troofs
-- defent - it is a tutorial after all - and one normal army attacks.
function CreatePlayer2()
    CreatePlayer2Spawner();
    CreatePlayer2Armies();
end

function CreatePlayer2Spawner()
    gvP2HQSpawner       = AiArmyRefiller.CreateSpawner {
        ScriptName      = "HQ2",
        SpawnPoint      = "HQ2Spawn",
        SpawnAmount     = 4,
        SpawnTimer      = 3*60,
        AllowedTypes    = {
            {Entities.CU_BlackKnight_LeaderMace1, 3},
        }
    };

    gvP2Barracks1Spawner = AiArmyRefiller.CreateSpawner {
        ScriptName      = "P2Barracks1",
        SpawnPoint      = "P2Barracks1Spawn",
        SpawnAmount     = 2,
        SpawnTimer      = 3*60,
        AllowedTypes    = {
            {Entities.PU_LeaderPoleArm4, 3},
            {Entities.PU_LeaderSword4, 3},
        }
    };

    gvP2Barracks2Spawner = AiArmyRefiller.CreateSpawner {
        ScriptName      = "P2Barracks2",
        SpawnPoint      = "P2Barracks2Spawn",
        SpawnAmount     = 2,
        SpawnTimer      = 3*60,
        AllowedTypes    = {
            {Entities.PU_LeaderPoleArm4, 3},
            {Entities.PU_LeaderSword4, 3},
        }
    };

    gvP2ArcherySpawner  = AiArmyRefiller.CreateSpawner {
        ScriptName      = "P2Archery1",
        SpawnPoint      = "P2Archery1Spawn",
        SpawnAmount     = 2,
        SpawnTimer      = 3*60,
        AllowedTypes    = {
            {Entities.PU_LeaderRifle2, 3},
            {Entities.PU_LeaderBow3, 3},
        }
    };

    gvP2StableSpawner   = AiArmyRefiller.CreateSpawner {
        ScriptName      = "P2Stable1",
        SpawnPoint      = "P2Stable1Spawn",
        SpawnAmount     = 2,
        SpawnTimer      = 3*60,
        AllowedTypes    = {
            {Entities.PU_LeaderCavalry2, 3},
            {Entities.PU_LeaderHeavyCavalry2, 3},
        }
    };

    gvP2FoundrySpawner  = AiArmyRefiller.CreateSpawner {
        ScriptName      = "P2Foundry1",
        SpawnPoint      = "P2Foundry1Spawn",
        SpawnAmount     = 3,
        SpawnTimer      = 3*60,
        AllowedTypes    = {
            {Entities.PV_Cannon3, 0},
            {Entities.PV_Cannon4, 0},
        }
    };
end

function CreatePlayer2Armies()
    local ArmyID = AiArmy.New(2, 16, GetPosition("P2OuterPos"), 3000);
    AiArmy.SetAllowedTypes(ArmyID, {
        Entities.CU_BlackKnight_LeaderMace1,
        Entities.PU_LeaderSword4,
        Entities.PU_LeaderBow3,
        Entities.PU_LeaderHeavyCavalry2,
        Entities.PV_Cannon4,
    });
    gvP2Army1 = ArmyID;
    AiArmy.SetTroopFormationController(ArmyID, CustomTroopFomrationController);
    AiArmyRefiller.AddArmy(gvP2Barracks1Spawner, ArmyID);
    AiArmyRefiller.AddArmy(gvP2Barracks2Spawner, ArmyID);
    AiArmyRefiller.AddArmy(gvP2ArcherySpawner, ArmyID);
    AiArmyRefiller.AddArmy(gvP2StableSpawner, ArmyID);
    AiArmyRefiller.AddArmy(gvP2FoundrySpawner, ArmyID);
    AiArmyRefiller.AddArmy(gvP2HQSpawner, ArmyID);
    Job.Second(ControllPlayer2Attacker, ArmyID);

    for i= 2, 8 do
        local Positions = {6,"P2DefPos1","P2DefPos2","P2DefPos3","P2DefPos4","P2DefPos5","P2DefPos6"};
        local Position = GetPosition(Positions[math.random(1, Positions[1]) +1]);
        ArmyID = AiArmy.New(2, 8, Position, 5000);
        AiArmy.SetAllowedTypes(ArmyID, {
            Entities.CU_BlackKnight_LeaderMace1,
            Entities.PU_LeaderPoleArm4,
            Entities.PU_LeaderRifle2,
            Entities.PU_LeaderCavalry2,
            Entities.PV_Cannon3,
        });
        _G["gvP2Army"..i] = ArmyID;
        AiArmy.SetTroopFormationController(ArmyID, CustomTroopFomrationController);
        AiArmyRefiller.AddArmy(gvP2Barracks1Spawner, ArmyID);
        AiArmyRefiller.AddArmy(gvP2Barracks2Spawner, ArmyID);
        AiArmyRefiller.AddArmy(gvP2ArcherySpawner, ArmyID);
        AiArmyRefiller.AddArmy(gvP2StableSpawner, ArmyID);
        AiArmyRefiller.AddArmy(gvP2FoundrySpawner, ArmyID);
        AiArmyRefiller.AddArmy(gvP2HQSpawner, ArmyID);
        Job.Second(ControllPlayer2Defender, ArmyID);
    end

    SetHostile(1, 2);
    MakeInvulnerable("Scorillo");
    Job.Second(function()
        if not IsExisting("HQ2") then
            MakeVulnerable("Scorillo");
            return true;
        end
    end);
end

function ControllPlayer2Attacker(_ArmyID)
    if not IsExisting("HQ2") then
        return true;
    end
    if AiArmy.IsArmyDoingNothing(_ArmyID) then
        AiArmy.ClearCommands(_ArmyID);
        AiArmy.PushCommand(_ArmyID, AiArmy.CreateCommand(AiArmyCommand.Advance, "P2OuterPos"), false);
        AiArmy.PushCommand(_ArmyID, AiArmy.CreateCommand(AiArmyCommand.Advance, "P2AttackPath1"), false);
        AiArmy.PushCommand(_ArmyID, AiArmy.CreateCommand(AiArmyCommand.Advance, "P2AttackPath2"), false);
        AiArmy.PushCommand(_ArmyID, AiArmy.CreateCommand(AiArmyCommand.Advance, "P2AttackPath3"), false);
        AiArmy.PushCommand(_ArmyID, AiArmy.CreateCommand(AiArmyCommand.Advance, "PlayerHome"), false);
        AiArmy.PushCommand(_ArmyID, AiArmy.CreateCommand(AiArmyCommand.Battle), false);
        AiArmy.PushCommand(_ArmyID, AiArmy.CreateCommand(AiArmyCommand.Fallback), false);
    end
end

function ControllPlayer2Defender(_ArmyID)
    if not IsExisting("HQ2") then
        return true;
    end
    if AiArmy.IsArmyDoingNothing(_ArmyID) then
        local Positions = {"P2DefPos1","P2DefPos2","P2DefPos3","P2DefPos4","P2DefPos5","P2DefPos6"};
        for _, Position in ipairs(ShuffleTable(Positions)) do
            AiArmy.PushCommand(_ArmyID, AiArmy.CreateCommand(AiArmyCommand.Move, Position), false);
            AiArmy.PushCommand(_ArmyID, AiArmy.CreateCommand(AiArmyCommand.Wait, 3*60), false);
        end
    end
end

-- The splitter group is implementet as standard bandit camp. They have the
-- ability to attack the player.
function CreatePlayer3()
    local CampID = DelinquentsCampCreate {
        PlayerID        = 3,
        HomePosition    = "HQ3Spawn",
        Strength        = 7,
        RodeLength      = 2500,
    };
    DelinquentsCampAddSpawner(CampID, "HQ3", 2*60, 2, Entities.CU_BanditLeaderBow1);
    DelinquentsCampAddSpawner(CampID, "P3Tent1", 2*60, 1, Entities.PU_LeaderPoleArm3);
    DelinquentsCampAddSpawner(CampID, "P3Tent2", 2*60, 1, Entities.CU_BanditLeaderSword3);
    DelinquentsCampAddSpawner(CampID, "P3Tent3", 2*60, 1, Entities.PU_LeaderSword2);
    DelinquentsCampAddTarget(CampID, "PlayerHome");
    DelinquentsCampActivateAttack(CampID, false);

    gvPlayer3Camp = CampID;
    SetHostile(1, 3);
    MakeInvulnerable("HQ3");
    Job.Second(function()
        if  not IsExisting("P3Tent1") and not IsExisting("P3Tent2")
        and not IsExisting("P3Tent3") then
            MakeVulnerable("HQ3");
            return true;
        end
    end);
end

-- Overwrite formation selection
function CustomTroopFomrationController(_ID)
    Stronghold.Unit:SetFormationOnCreate(_ID);
end

-- ########################################################################## --
-- #                               BRIEFING                                 # --
-- ########################################################################## --

function BriefingTutorialIntro()
    local Briefing = {
        RenderFoW = false,
        RenderSky = true,
    };
    local AP,ASP,AMC = BriefingSystem.AddPages(Briefing);

    -- Exposition
    AP {
        Flight      = true,
        NoSkip      = true,
        Duration    = 0.1,
        FaderAlpha  = 1,
        Target      = "CamPos3",
        Rotation    = -60,
        Distance    = 1800,
        Angle       = 10,
    }
    AP {
        Text        = "map_sh_tutorial/BriefingTutorialIntro_2_Text",
        Flight      = true,
        NoSkip      = true,
        FadeIn      = 3,
        Duration    = 18,
        Target      = "CamPos4",
        Rotation    = -35,
        Distance    = 2600,
        Angle       = 14,
    }
    AP {
        NoSkip      = true,
        Duration    = 0.1,
        FaderAlpha  = 1,
        Target      = "CamPos1",
        Rotation    = -25,
        Distance    = 7000,
        Height      = 0,
        Angle       = 8,
        Action      = function()
            -- TODO: Needs a proper function to do that for AI players!
            SVLib.SetInvisibility(GetID("CampP2"), true);
        end
    }
    AP {
        Text        = "map_sh_tutorial/BriefingTutorialIntro_4_Text",
        Flight      = true,
        NoSkip      = true,
        Duration    = 25,
        Target      = "CamPos2",
        Rotation    = -65,
        Distance    = 7000,
        Height      = 0,
        Angle       = 14,
    }
    AP {
        NoSkip      = true,
        Duration    = 0.1,
        FaderAlpha  = 1,
        Target      = "CamPos6",
        Rotation    = -135,
        Distance    = 4500,
        Angle       = 12,
    }
    AP {
        Text        = "map_sh_tutorial/BriefingTutorialIntro_6_Text",
        Flight      = true,
        NoSkip      = true,
        FadeIn      = 0.1,
        FadeOut     = 3,
        Duration    = 23,
        Target      = "CamPos5",
        Rotation    = -45,
        Distance    = 4500,
        Angle       = 12,
        Action      = function()
            Move("Scout", "ScoutPos");
        end
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
        LookAt("Scout", "HQ1");
        for k,v in pairs(GetPlayerEntities(1, Entities.PU_Serf)) do
            Logic.SuspendEntity(v);
        end
        if gvTutorial_Skip then
            Tutorial_SkipExplainations();
        else
            Tutorial_StartPart1();
        end
    end
    BriefingSystem.Start(1, "BriefingTutorialIntro", Briefing);
end

-- -------------------------------------------------------------------------- --

function BriefingScoutNpc()
    NonPlayerCharacter.Create {
        ScriptName = "Scout",
        Callback   = BriefingScout
    }
    NonPlayerCharacter.Activate("Scout");
end

function BriefingScout(_Npc, _HeroID)
    local Briefing = {};
    local AP,ASP,AMC = BriefingSystem.AddPages(Briefing);

    AP {
        Title    = gvGender.Name,
        Text     = "map_sh_tutorial/BriefingScout_1_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "map_sh_tutorial/BriefingScout_2_Title",
        Text     = string.format(XGUIEng.GetStringTableText("map_sh_tutorial/BriefingScout_2_Text"), gvGender.Address),
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }
    AP {
        Title    = "map_sh_tutorial/BriefingScout_2_Title",
        Text     = "map_sh_tutorial/BriefingScout_3_Text",
        Target   = "Scorillo",
        Explore  = 6000,
        CloseUp  = true,
        MiniMap  = true,
        Signal   = true,
    }
    AP {
        Title    = gvGender.Name,
        Text     = "map_sh_tutorial/BriefingScout_4_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "map_sh_tutorial/BriefingScout_2_Title",
        Text     = string.format(XGUIEng.GetStringTableText("map_sh_tutorial/BriefingScout_5_Text"), gvGender.Address),
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }
    AP {
        Title    = "map_sh_tutorial/BriefingScout_2_Title",
        Text     = "map_sh_tutorial/BriefingScout_6_Text",
        Target   = "HQ3",
        Explore  = 4000,
        MiniMap  = true,
        Signal   = true,
    }
    AP {
        Title    = "map_sh_tutorial/BriefingScout_2_Title",
        Text     = "map_sh_tutorial/BriefingScout_7_Text",
        Target   = "BridgePos",
        Explore  = 4000,
        MiniMap  = true,
        Signal   = true,
    }
    AP {
        Title    = gvGender.Name,
        Text     = "map_sh_tutorial/BriefingScout_8_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "map_sh_tutorial/BriefingScout_2_Title",
        Text     = string.format(XGUIEng.GetStringTableText("map_sh_tutorial/BriefingScout_9_Text"), gvGender.Address),
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }

    Briefing.Finished = function(_Data)
        ChangePlayer(GetID(_Npc.ScriptName), 1);
        Tutorial_StartPart2();
        local Title = XGUIEng.GetStringTableText("map_sh_tutorial/Quest_Main_1_Title");
        local Text  = XGUIEng.GetStringTableText("map_sh_tutorial/Quest_Main_1_Text");
        Logic.AddQuest(1, 1, MAINQUEST_OPEN, Title, Text, 1);
    end
    BriefingSystem.Start(1, "BriefingScout", Briefing);
end

-- -------------------------------------------------------------------------- --

function BriefingGuardian1Npc()
    NonPlayerCharacter.Create {
        ScriptName = "GateDude",
        Callback   = BriefingGuardian1
    }
    NonPlayerCharacter.Activate("GateDude");
end

function BriefingGuardian1(_Npc, _HeroID)
    local Briefing = {};
    local AP,ASP,AMC = BriefingSystem.AddPages(Briefing);

    AP {
        Title    = "map_sh_tutorial/BriefingGuardian1_1_Title",
        Text     = "map_sh_tutorial/BriefingGuardian1_1_Text",
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }
    AP {
        Title    = gvGender.Name,
        Text     = "map_sh_tutorial/BriefingGuardian1_2_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "map_sh_tutorial/BriefingGuardian1_3_Title",
        Text     = "map_sh_tutorial/BriefingGuardian1_3_Text",
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }
    AP {
        Title    = gvGender.Name,
        Text     = "map_sh_tutorial/BriefingGuardian1_4_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "map_sh_tutorial/BriefingGuardian1_5_Title",
        Text     = "map_sh_tutorial/BriefingGuardian1_5_Text",
        Target   = "BridgePos",
        Explore  = 4000,
        CloseUp  = false,
    }
    AP {
        Title    = gvGender.Name,
        Text     = "map_sh_tutorial/BriefingGuardian1_6_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }

    Briefing.Finished = function(_Data)
        UnlockPlayerRight(1, PlayerRight.ArchitectShop);
        Job.Second(Tutorial_BridgeBuildTrigger);
        local Title = XGUIEng.GetStringTableText("map_sh_tutorial/Quest_Sub_1_Title");
        local Text  = XGUIEng.GetStringTableText("map_sh_tutorial/Quest_Sub_1_Text");
        Logic.AddQuest(1, 2, SUBQUEST_OPEN, Title, Text, 1);
    end
    BriefingSystem.Start(1, "BriefingGuardian1", Briefing);
end

-- -------------------------------------------------------------------------- --

function BriefingGuardian2Npc()
    NonPlayerCharacter.Create {
        ScriptName = "GateDude",
        Callback   = BriefingGuardian2
    }
    NonPlayerCharacter.Activate("GateDude");
end

function BriefingGuardian2(_Npc, _HeroID)
    local Briefing = {};
    local AP,ASP,AMC = BriefingSystem.AddPages(Briefing);

    AP {
        Title    = gvGender.Name,
        Text     = "map_sh_tutorial/BriefingGuardian2_1_Text",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "map_sh_tutorial/BriefingGuardian2_2_Title",
        Text     = string.format(XGUIEng.GetStringTableText("map_sh_tutorial/BriefingGuardian2_2_Text"), gvGender.Address),
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }

    Briefing.Finished = function(_Data)
        ReplaceEntity("BanditGate", Entities.XD_PalisadeGate2);
    end
    BriefingSystem.Start(1, "BriefingGuardian1", Briefing);
end

