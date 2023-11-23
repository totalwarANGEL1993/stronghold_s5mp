SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 2,

    -- ###################################################################### --
    -- #                             CONFIG                                 # --
    -- ###################################################################### --

    -- Disable standard victory condition?
    -- (Game is not lost when the HQ falls)
    DisableDefaultWinCondition = true,
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
    Resources = {0, 0, 0, 0, 0, 0, 0},

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

        Lib.Require("module/ai/AiArmyManager");
        Lib.Require("module/cinematic/BriefingSystem");
        Lib.Require("module/cinematic/BriefingSystem");
        Lib.Require("module/io/NonPlayerCharacter");
        Lib.Require("module/io/NonPlayerMerchant");
        Lib.Require("module/tutorial/Tutorial");

        Tutorial.Install();
        LockRank(1, 0);
        ForbidTechnology(Technologies.B_MasterBuilderWorkshop, 1);
        ForbidTechnology(Technologies.B_Palisade, 1);
        ForbidTechnology(Technologies.B_PowerPlant, 1);
        ForbidTechnology(Technologies.B_Wall, 1);
        ForbidTechnology(Technologies.T_FreeCamera, 1);

        ChangePlayer("HQ1", 8);
        Tools.CreateSoldiersForLeader(GetID("Scout"), 3);
        for k,v in pairs(GetPlayerEntities(1, Entities.PU_Serf)) do
            Logic.SuspendEntity(v);
        end

        BriefingTutorialIntro();
        Tutorial_OverwriteCallbacks();
        Tutorial_CreateProvince()

        CreatePlayer2();
        CreatePlayer3();
    end,

    -- Called after game start timer is over
    OnGameStart = function()
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
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
        gvTutorial_HeroSelected = true;
        local TypeName = Logic.GetEntityTypeName(_Type);
        gvGender.Name = XGUIEng.GetStringTableText("Names/" ..TypeName);
        if GetGender(_Type) == Gender.Female then
            gvGender.Pronome = {"sie", "sie", "ihr", "ihre"};
            gvGender.Address = "Milady";
        end
    end);

    -- For claiming a province
    Overwrite.CreateOverwrite("GameCallback_SH_Logic_OnProvinceClaimed", function(_PlayerID, _ProvinceID, _BuildingID)
        Overwrite.CallOriginal();
        gvTutorial_ProvinceClaimed = true;
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
    local ArrowPos_Military = {240, 686};
    local ArrowPos_Slaves = {240, 698};
    local ArrowPos_Civil = {240, 674};
    local ArrowPos_Care = {240, 712};

    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_1",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_2",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_3",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_4",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_5",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_NewRes,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_6",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_NewRes,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_7",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_NewRes,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_8",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_NewRes,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_9",
        Arrow       = ArrowPos_Promote,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_10",
        Arrow       = ArrowPos_Care,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_11",
        Arrow       = ArrowPos_Civil,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_13",
        Arrow       = ArrowPos_Military,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_12",
        Arrow       = ArrowPos_Slaves,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_14",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_Clock,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_15",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_Clock,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_16",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_Clock,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_17",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_FindSerf,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_18",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_FindTroops,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainInterface_19",
        Action      = function(_Page)
            ChangePlayer("HQ1", 1);
        end,
    }
end
-- Sound.Play2DSound( Sounds.Smith01,0 )
function Tutorial_AddCastleInterfaceSection()
    local ArrowPos_RallyPoint = {675, 625};
    local ArrowPos_Treasury = {317, 575};
    local ArrowPos_Measure = {362, 575};
    local ArrowPos_BuyNoble = {350, 700};
    local ArrowPos_Tax = {517, 692};
    local ArrowPos_Measures_Row = {522, 635};
    local ArrowPos_Measures_Bar = {522, 680};

    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_1",
        Condition   = function(_Page)
            return IsEntitySelected("HQ1");
        end,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_2",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_3",
        Arrow       = ArrowPos_Treasury,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_5",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_Tax,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_6",
        Arrow       = ArrowPos_RallyPoint,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_7",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_8",
        Condition   = function(_Data)
            return gvTutorial_RallyPointSet;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_9",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_10",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_BuyNoble,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_11",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_BuyNoble,
        Condition   = function(_Data)
            return gvTutorial_HeroSelected;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_12",
        Action      = function(_Data)
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_4",
        Arrow       = ArrowPos_Measure,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_13",
        Arrow       = ArrowPos_Measure,
        Condition   = function(_Data)
            local WidgetID = Stronghold.Building:GetLastSelectedHeadquarterTab(1);
            return WidgetID == gvGUI_WidgetID.ToBuildingSettlersMenu;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_14",
        Arrow       = ArrowPos_Measures_Row,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainCastle_15",
        Arrow       = ArrowPos_Measures_Bar,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
            Tutorial_AddHeroSelectedSection();
        end
    }
end

function Tutorial_AddHeroSelectedSection()
    local Text = XGUIEng.GetStringTableText("sh_tutorial/ExplainCastle_16");
    Tutorial.AddMessage {
        Text        = string.format(Text, gvGender.Name, gvGender.Pronome[2]),
        Condition   = function(_Data)
            return IsEntitySelected(Stronghold:GetPlayerHero(1));
        end
    }
end

-- Part 2 ------------------------------------------------------------------- --

function Tutorial_StartPart2()
    Tutorial.Stop();
    Tutorial.SetCallback(function()
        Job.Second(Tutorial_StartPart3Trigger);
    end);
    Tutorial_AddUnitSelectionSection();
    Tutorial_AddProvisionSection();
    Tutorial_AddExplainBarracks();
    Tutorial.Start();
end

function Tutorial_AddUnitSelectionSection()
    local ArrowPos_TroopSize = {740, 672};
    local ArrowPos_Armor = {740, 692};
    local ArrowPos_Damage = {740, 710};
    local ArrowPos_Upkeep = {740, 726};
    local ArrowPos_Experience = {740, 652};
    local ArrowPos_Health = {740, 640};
    local ArrowPos_Expel = {720, 700};
    local ArrowPos_BuySoldier = {318, 700};
    local ArrowPos_Commands = {380, 700};

    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_1",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_2",
        Condition   = function(_Data)
            return IsEntitySelected("Scout");
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_3",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_Commands,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_4",
        Arrow       = ArrowPos_BuySoldier,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_5",
        Arrow       = ArrowPos_Health,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_6",
        Arrow       = ArrowPos_Experience,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_7",
        Arrow       = ArrowPos_TroopSize,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_8",
        Arrow       = ArrowPos_Armor,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_9",
        Arrow       = ArrowPos_Damage,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_10",
        Arrow       = ArrowPos_Upkeep,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainUnit_11",
        Arrow       = ArrowPos_Expel,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
end

function Tutorial_AddProvisionSection()
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_1",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_2",
        Action      = function(_Data)
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
        Action      = function(_Data)
            local Position = GetPosition("ClayMinePointer");
            gvTutorial_ClayMinePointer = Logic.CreateEffect(GGL_Effects.FXTerrainPointer, Position.X, Position.Y, 0);
        end,
        Condition   = function(_Data)
            local n, ID = Logic.GetEntities(Entities.PB_ClayMine1, 1);
            return n > 0 and Logic.IsConstructionComplete(ID) == 1;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_4",
        Action      = function(_Data)
            Logic.DestroyEffect(gvTutorial_ClayMinePointer);
        end,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_5",
        Condition   = function(_Data)
            local NoFarm = Logic.GetNumberOfWorkerWithoutEatPlace(1);
            local NoHouse = Logic.GetNumberOfWorkerWithoutSleepPlace(1);
            return NoFarm == 0 and NoHouse == 0;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_6",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_7",
        Condition   = function(_Data)
            local WorkerCount = Logic.GetNumberOfAttractedWorker(1);
            local Reputation = GetReputationIncome(1);
            return WorkerCount >= 15 and Reputation >= 0;
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_8",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_9",
        Action      = function(_Data)
            LockRank(1, 8);
        end,
        Condition   = function(_Data)
            if GetRank(1) >= 1 then
                return true;
            end
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_10",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_11",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainManage_12",
    }
end

function Tutorial_AddExplainBarracks()
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainRecruit_1",
        Condition   = function(_Data)
            local Barracks = GetPlayerEntities(1, Entities.PB_Barracks1);
            if Barracks[1] and Logic.IsConstructionComplete(Barracks[1]) == 1 then
                return true;
            end
        end
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainRecruit_2",
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
        Action      = function(_Data)
            ReplaceEntity("BridgeBarrier", Entities.XD_Rock7);
            DelinquentsCampActivateAttack(gvPlayer3Camp, true);
        end,
    }
end

-- Part 3 ------------------------------------------------------------------- --

function Tutorial_StartPart3()
    Tutorial.Stop();
    Tutorial.SetCallback(function()
        Job.Second(Tutorial_StartPart4Trigger);
        MakeVulnerable("P3Tower");
    end);

    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainProvince_1",
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/ExplainProvince_2",
        Condition   = function(_Data)
            return Logic.GetNumberOfEntitiesOfTypeOfPlayer(1, Entities.PB_VillageCenter1) > 0 or
                   Logic.GetNumberOfEntitiesOfTypeOfPlayer(1, Entities.PB_VillageCenter2) > 0 or
                   Logic.GetNumberOfEntitiesOfTypeOfPlayer(1, Entities.PB_VillageCenter3) > 0;
        end
    }

    Tutorial.Start();
end

function Tutorial_StartPart3Trigger()
    local x,y,z = Logic.EntityGetPos(GetID("VillagePos"));
    local Amount = Logic.GetPlayerEntitiesInArea(1, 0, x, y, 1500, 16);
    if Amount > 1 then
        Tutorial_StartPart3();
        return true;
    end
end

-- Part 4 ------------------------------------------------------------------- --

function Tutorial_StartPart4()
    Tutorial.Stop();
    Tutorial.SetCallback(function()
        BriefingGuardian1Npc();
        Job.Second(Tutorial_CheckVictory);
    end);

    Tutorial.AddMessage {
        Text        = "sh_tutorial/TutorialEnd_1",
        Action      = function(_Data)
            ReplaceEntity("GateDude", Entities.CU_PoleArmIdle);
        end,
    }
    Tutorial.AddMessage {
        Text        = "sh_tutorial/TutorialEnd_2",
    }
    Tutorial.Start();
end

function Tutorial_StartPart4Trigger()
    if not IsExisting("HQ3") then
        Tutorial_StartPart4();
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
        -- Not a stronghold AI so nuke manually.
        for k,v in pairs(GetPlayerEntities(2,0)) do
            DestroyEntity(v);
        end
        Victory(1);
        return true;
    end
end

-- ########################################################################## --
-- #                                ENEMY                                   # --
-- ########################################################################## --

-- The final boss is implemented using the cerberus army. Most of the troofs
-- defent - it is a tutorial after all - and one normal army attacks.
function CreatePlayer2()
    CreatePlayer2Armies();
end

function CreatePlayer2Armies()
    gvP2HQSpawner       = AiArmyRefiller.CreateSpawner {
        ScriptName      = "HQ2",
        SpawnPoint      = "HQ2Spawn",
        SpawnAmount     = 3,
        SpawnTimer      = 3*60,
        AllowedTypes    = {
            {Entities.CU_BlackKnight_LeaderMace2, 3},
        }
    };

    gvP2BarracksSpawner = AiArmyRefiller.CreateSpawner {
        ScriptName      = "P2Barracks1",
        SpawnPoint      = "P2Barracks1Spawn",
        SpawnAmount     = 1,
        SpawnTimer      = 3*60,
        AllowedTypes    = {
            {Entities.PU_LeaderPoleArm2, 3},
            {Entities.PU_LeaderSword3, 3},
        }
    };

    gvP2ArcherySpawner  = AiArmyRefiller.CreateSpawner {
        ScriptName      = "P2Archery1",
        SpawnPoint      = "P2Archery1Spawn",
        SpawnAmount     = 2,
        SpawnTimer      = 3*60,
        AllowedTypes    = {
            {Entities.PU_LeaderBow2, 3},
            {Entities.PU_LeaderBow3, 3},
        }
    };

    gvP2StableSpawner   = AiArmyRefiller.CreateSpawner {
        ScriptName      = "P2Stable1",
        SpawnPoint      = "P2Stable1Spawn",
        SpawnAmount     = 1,
        SpawnTimer      = 3*60,
        AllowedTypes    = {
            {Entities.PU_LeaderHeavyCavalry1, 3},
        }
    };

    gvP2FoundrySpawner  = AiArmyRefiller.CreateSpawner {
        ScriptName      = "P2Foundry1",
        SpawnPoint      = "P2Foundry1Spawn",
        SpawnAmount     = 3,
        SpawnTimer      = 3*60,
        AllowedTypes    = {
            {Entities.PV_Cannon1, 0},
        }
    };

    ---

    local ArmyID = AiArmy.New(2, 8, GetPosition("P2OuterPos"), 3000);
    AiArmy.SetFormationController(ArmyID, CustomTroopFomrationController);
    AiArmyRefiller.AddArmy(gvP2BarracksSpawner, ArmyID);
    AiArmyRefiller.AddArmy(gvP2ArcherySpawner, ArmyID);
    AiArmyRefiller.AddArmy(gvP2StableSpawner, ArmyID);
    AiArmyRefiller.AddArmy(gvP2FoundrySpawner, ArmyID);
    AiArmyRefiller.AddArmy(gvP2HQSpawner, ArmyID);

    gvP2Army1 = AiArmyManager.Create(ArmyID);
    AiArmyManager.AddAttackTargetPath(gvP2Army1, "P2OuterPos", "P2AttackPath1", "PlayerHome");


    for i= 2, 7 do
        ArmyID = AiArmy.New(2, 3, GetPosition("P2DefPos1"), 5000);
        AiArmy.SetFormationController(ArmyID, CustomTroopFomrationController);
        AiArmyRefiller.AddArmy(gvP2BarracksSpawner, ArmyID);
        AiArmyRefiller.AddArmy(gvP2ArcherySpawner, ArmyID);
        AiArmyRefiller.AddArmy(gvP2StableSpawner, ArmyID);
        AiArmyRefiller.AddArmy(gvP2FoundrySpawner, ArmyID);
        AiArmyRefiller.AddArmy(gvP2HQSpawner, ArmyID);

        _G["gvP2Army"..i] = AiArmyManager.Create(ArmyID);
        AiArmyManager.AddGuardPosition(_G["gvP2Army"..i], "P2DefPos1");
        AiArmyManager.AddGuardPosition(_G["gvP2Army"..i], "P2DefPos2");
        AiArmyManager.AddGuardPosition(_G["gvP2Army"..i], "P2DefPos3");
        AiArmyManager.AddGuardPosition(_G["gvP2Army"..i], "P2DefPos4");
        AiArmyManager.AddGuardPosition(_G["gvP2Army"..i], "P2DefPos5");
        AiArmyManager.AddGuardPosition(_G["gvP2Army"..i], "P2DefPos6");
        AiArmyManager.AddGuardPosition(_G["gvP2Army"..i], "P2DefPos7");
        AiArmyManager.AddGuardPosition(_G["gvP2Army"..i], "P2DefPos8");
    end
    --- @diagnostic disable-next-line: undefined-global
    AiArmyManager.Synchronize(gvP2Army2, gvP2Army3, gvP2Army4, gvP2Army5, gvP2Army6, gvP2Army7);


    SetHostile(1, 2);
    MakeInvulnerable("Scorillo");
    Job.Second(function()
        if not IsExisting("HQ2") then
            MakeVulnerable("Scorillo");
            return true;
        end
    end);
end

-- Overwrite formation selection
function CustomTroopFomrationController(_ID)
    Stronghold.Unit:SetFormationOnCreate(_ID);
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
    DelinquentsCampAddSpawner(CampID, "HQ3", 2*60, 1, Entities.PU_LeaderBow1);
    DelinquentsCampAddSpawner(CampID, "P3Tent1", 2*60, 1, Entities.PU_LeaderPoleArm1);
    DelinquentsCampAddSpawner(CampID, "P3Tent2", 2*60, 1, Entities.PU_LeaderPoleArm1);
    DelinquentsCampAddSpawner(CampID, "P3Tent3", 2*60, 1, Entities.PU_LeaderPoleArm1);
    DelinquentsCampAddTarget(CampID, "PlayerHome");
    DelinquentsCampActivateAttack(CampID, false);

    gvPlayer3Camp = CampID;
    SetHostile(1, 3);
    MakeInvulnerable("HQ3");
    MakeInvulnerable("P3Tower");
    Job.Second(function()
        if  not IsExisting("P3Tent1") and not IsExisting("P3Tent2")
        and not IsExisting("P3Tent3") and not IsExisting("P3Tower") then
            MakeVulnerable("HQ3");
            return true;
        end
    end);
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
        FaderAlpha  = 1,
        Duration    = 0,
        Target      = "CamPos3",
        Rotation    = -45,
        Distance    = 1000,
        Angle       = 5,
    }
    AP {
        Text        = "map_sh_tutorial/BriefingTutorialIntro_2_Text",
        Flight      = true,
        NoSkip      = true,
        FadeIn      = 3,
        Duration    = 18,
        Target      = "CamPos4",
        Rotation    = -55,
        Distance    = 4000,
        Angle       = 10,
    }
    AP {
        NoSkip      = true,
        Duration    = 0,
        Target      = "CamPos2",
        Rotation    = -35,
        Distance    = 7000,
        Height      = 1300,
        Angle       = 5,
    }
    AP {
        Text        = "map_sh_tutorial/BriefingTutorialIntro_4_Text",
        Flight      = true,
        NoSkip      = true,
        Duration    = 25,
        Target      = "CamPos1",
        Rotation    = -55,
        Distance    = 10000,
        Height      = 3000,
        Angle       = 8,
    }
    AP {
        NoSkip      = true,
        Duration    = 0,
        Target      = "CamPos6",
        Rotation    = -135,
        Distance    = 4500,
        Angle       = 12,
    }
    AP {
        Text        = "map_sh_tutorial/BriefingTutorialIntro_6_Text",
        Flight      = true,
        NoSkip      = true,
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
        Tutorial_StartPart1();
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
        AllowTechnology(Technologies.B_MasterBuilderWorkshop, 1);
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

