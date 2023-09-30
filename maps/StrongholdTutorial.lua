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
    -- (script name becomes amout e.g. 4000 for 4000 resources)
    MapStartFillClay = true,
    MapStartFillStone = true,
    MapStartFillIron = true,
    MapStartFillSulfur = true,
    MapStartFillWood = true,

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
        ForbidTechnology(Technologies.B_Bridge, 1);
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
    local ArrowPos_Military = {240, 674};
    local ArrowPos_Slaves = {240, 686};
    local ArrowPos_Civil = {240, 698};
    local ArrowPos_Care = {240, 712};

    Tutorial.AddMessage {
        Text        = "Lasst mich Euch die neuen Elemente des Interfaces "..
                      "erklären.",
    }
    Tutorial.AddMessage {
        Text        = "Diese Ansicht zeigt die sozialen Resourcen. Mit ihnen "..
                      "erforscht Ihr Technologien, schaltet neue Ränge frei "..
                      "und macht Euer Volk zufrieden.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_NewRes
    }
    Tutorial.AddMessage {
        Text        = "{scarlet}Ehre{white} steht für Euer ansehen beim "..
                      "Adelsstand. Sie ist nötig, um Truppen auszubilden, "..
                      "den Adligen in einenhöheren Stand zu erheben und "..
                      "viele andere Dinge. Prunkbauten, Ziergebäude und "..
                      "verschiedene Maßnahmen gereichen Euch an Ehre.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_NewRes
    }
    Tutorial.AddMessage {
        Text        = "{scarlet}Beliebtheit{white} gibt an, wie es um Euer "..
                      "Ansehen beim Volk bestellt ist. Fällt das Ansehen, "..
                      "seid Ihr bald allein auf der Burg. Die Versorgung, "..
                      "die Steuer, Verbrechensbekämpfung und Effekte von "..
                      "einigen Spezialgebäuden beeinflussen die Beliebtheit.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_NewRes
    }
    Tutorial.AddMessage {
        Text        = "{scarlet}Wissen{white} erlaubt die Erforschung von "..
                      "Technologien. Es wird in Euren Bildungseinrichtungen "..
                      "erzeugt. Eure Gelehrten arbeiten unermütlich, um Euch "..
                      "den nötigen Vorteil zu verschaffen.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_NewRes
    }
    Tutorial.AddMessage {
        Text        = "Habt Ihr genug Ehre erlangt und die Bedingungen für "..
                      "die Beförderung erfüllt, könnt Ihr hier euren Adligen "..
                      "{scarlet}in einen neuen Stand{white} erheben.",
        Arrow       = ArrowPos_Promote
    }
    Tutorial.AddMessage {
        Text        = "Achtet darauf, Euer Volk {scarlet}zu versorgen{white} "..
                      "oder sie werden schnell unzufrieden. Die Kosten von "..
                      "Haus und Hof sind in diesem Spielmodus verbilligt. "..
                      "{scarlet}Ausbau{white} ermöglicht Euch schneller an "..
                      "Ansehen und Ehre zu gelangen.",
        Arrow       = ArrowPos_Care
    }
    Tutorial.AddMessage {
        Text        = "Diese Anzeige gibt an, wie viele Menschen unter Eurer "..
                      "Herrschaft leben. Arbeiter, Diebe, Kundschafter aber "..
                      "auch Verbrecher zählen zu Eurer Bevölkerung. {scarlet}"..
                      "Baut die Burg aus oder besetzt Dörfer,{white} um mehr "..
                      "Volk aufnehmen zu können.",
        Arrow       = ArrowPos_Civil
    }
    Tutorial.AddMessage {
        Text        = "Knechte sind Unfreie und zählen weder als Bevölkerung "..
                      "noch als Militär. Die Anzahl an Knechten, die Ihr "..
                      "besitzen könnt, {scarlet}steigt mit jedem weiteren "..
                      "Titel, den Euer Adliger erreicht.",
        Arrow       = ArrowPos_Slaves
    }
    Tutorial.AddMessage {
        Text        = "Hier seht Ihr, wie stark Euer Heer ist und wie groß "..
                      "es noch werden kann. Alle Soldaten und Kanonen zählen "..
                      "als Militär. {scarlet}Baut die Burg aus oder errichtet "..
                      "Rekrutierungsgebäude,{white} um Eure Heeresstärke zu "..
                      "erhöhen.",
        Arrow       = ArrowPos_Military
    }
    Tutorial.AddMessage {
        Text        = "Die Zahltagsuhr zeigt Euch an, wie lange Ihr bis zum "..
                      "nächsten Geld warten müsst. {scarlet} Der Zahltag ist "..
                      "in diesem Spielmodus alle 90 Sekunden.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_Clock
    }
    Tutorial.AddMessage {
        Text        = "Die Uhr gibt nicht nur die Zeit bis zum Zahltag an. "..
                      "Hier seht Ihr auch, {scarlet}wie sich Beliebtheit und "..
                      "Ehre verändern werden. {white} Ihr könnt mehr Details "..
                      "sehen, wenn Ihr STRG gedrückt haltet.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_Clock
    }
    Tutorial.AddMessage {
        Text        = "Beliebtheit und Ehre verändern sich {scarlet}niemals "..
                      "{white}sofort sondern {scarlet}ausschließlich{white} "..
                      "am Zahltag! Die einzige Außnahme ist Yuki, die Euch "..
                      "einmalig Bonusbeliebtheit gewährt.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_Clock
    }
    Tutorial.AddMessage {
        Text        = "Hier findet Ihr wie gewohnt Eure untätigen Knechte.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_FindSerf
    }
    Tutorial.AddMessage {
        Text        = "Ebenso könnt Ihr auch Eure Truppen ausfindig machen. "..
                      "Zusätzlich zeigt der Tooltip jedes Button an, wie "..
                      "viel Sold Ihr für die Einheitenart ausgebt.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_FindTroops
    }
    Tutorial.AddMessage {
        Text        = "Lasst uns nun einen Blick in die Burg werfen.",
        Action      = function(_Page)
            ChangePlayer("HQ1", 1);
        end
    }
end

function Tutorial_AddCastleInterfaceSection()
    local ArrowPos_RallyPoint = {675, 625};
    local ArrowPos_Treasury = {317, 575};
    local ArrowPos_Measure = {362, 575};
    local ArrowPos_BuyNoble = {350, 700};
    local ArrowPos_Tax = {517, 692};

    Tutorial.AddMessage {
        Text        = "Bitte selektiert nun die Burg!",
        Condition   = function(_Page)
            return IsEntitySelected("HQ1");
        end,
    }
    Tutorial.AddMessage {
        Text        = "Die Burg besitzt nun zwei Ansichten. Neben der "..
                      "gewohnten gibt es auch eine zweite, die Euch in die "..
                      "Lage versetzt, Maßnahmen zu erlassen.",
    }
    Tutorial.AddMessage {
        Text        = "Diese Registerkarte zeigt Eure Schatzkammer an. Hier "..
                      "stellt Ihr Steuern ein, kauft Knechte und erhaltet "..
                      "Auskunft über Einnahmen und Ausgaben.",
        Arrow       = ArrowPos_Treasury,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Diese Registerkarte wechselt zu den Maßnahmen. Mit "..
                      "ihnen könnt Ihr verschiedene Vorteile erhalten. Es "..
                      "funktioniert ähnlich wie die Kirche.",
        Arrow       = ArrowPos_Measure,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Anders als Ihr es gewohnt seid, könnt Ihr sofort die "..
                      "Steuern einstellen. Aber gebt acht, {scarlet}denn der "..
                      "Pöbel wird hohe Steuern nicht mögen.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_Tax,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Dieser Button ermöglich Euch, {scarlet}Sammelpunkte "..
                      "{white} festzulegen. In Gebäuden produzierte Truppen "..
                      "werden zur Position laufen. Im Falle der Burg, werden "..
                      "Knechte {scarlet}automatisch Resourcen abbauen.",
        Arrow       = ArrowPos_RallyPoint,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Ihr platziert einen Sammelpunkt, {scarlet}indem Ihr "..
                      "rechts auf die Spielwelt klickt, nachdem die Maus zu "..
                      "einer Hand mit einer Flagge wurde. {white} Das klappt "..
                      "nur, wenn die Position erreichbar ist.",
    }
    Tutorial.AddMessage {
        Text        = "Probiert es einmal aus! Um einen Sammelpunkt zu "..
                      "setzen, müsst Ihr rechts auf eine von dem "..
                      "Gebäude erreichbare Position klicken.",
        Condition   = function(_Data)
            return gvTutorial_RallyPointSet;
        end
    }
    Tutorial.AddMessage {
        Text        = "Gut gemacht! Künftig ausgebildete Knechte werden zu "..
                      "der markierten Position gehen!",
    }
    Tutorial.AddMessage {
        Text        = "Nun ist es an der Zeit, Euren Adligen zu wählen. "..
                      "{scarlet} Ohne einen Adligen könnt Ihr kein Militär "..
                      "anheuern! {white}Fällt der Adlige im Kampf, {scarlet}"..
                      "findet Ihr ihn oder sie vor Eurer Burg.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_BuyNoble,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Öffnet das Menü und sucht Euch einen Adligen aus! Für "..
                      "das Bestehen dieser Einführung ist es unherheblich, "..
                      "welchen Adligen Ihr wählt.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_BuyNoble,
        Condition   = function(_Data)
            return gvTutorial_HeroSelected;
        end
    }
    Tutorial.AddMessage {
        Text        = "Jeder Adlige besitzt andere Eigenschaften. Ihr tut "..
                    "gut daran, einen Adligen zu wählen, {scarlet}der zu "..
                    "Eurem Spielstil passt. {white} Jeder hat individuelle "..
                    "Vorteile gegenüber den anderen.",
        Action      = function(_Data)
            Tutorial_AddHeroSelectedSection();
        end
    }
end

function Tutorial_AddHeroSelectedSection()
    Tutorial.AddMessage {
        Text        = "Ihr habt Euch für " ..gvGender.Name.. " entschieden. "..
                    "Auf, auf, selektiert " ..gvGender.Pronome[2].. "!",
        Condition   = function(_Data)
            return IsEntitySelected(Stronghold:GetPlayerHero(1));
        end
    }
    Tutorial.AddMessage {
        Text        = "Nun solltet Ihr jedoch endlich die Späher anhören..."
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
    Tutorial_AddMilitarySection();
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
        Text        = "Ihr habt Euren ersten Hauptmann erhalten. Die "..
                      "leichte Kavalerie sollte man nicht unterschätzen!",
    }
    Tutorial.AddMessage {
        Text        = "Wählt den Trupp an, um fortzufahren!",
        Condition   = function(_Data)
            return IsEntitySelected("Scout");
        end
    }
    Tutorial.AddMessage {
        Text        = "Hier könnt Ihr wie gewohnt direkte Befehle an die "..
                      "Soldaten erteilen.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_Commands,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Sollten Soldaten des Hauptmannes fallen, könnt Ihr "..
                      "mit diesem Button bei einem entsprechenden Gebäude "..
                      "neue Soldaten anwerben.{scarlet} Mit STRG könnt Ihr "..
                      "den Trupp voll auffüllen.",
        Arrow       = ArrowPos_BuySoldier,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Diese Anzeige gibt die Gesundheit des Hauptmannes an.",
        Arrow       = ArrowPos_Health,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Hier seht Ihr die Erfahrung des Hauptmannes.{scarlet} "..
                      "Erfahrene Hauptmänner führen ihre Truppen besser.",
        Arrow       = ArrowPos_Experience,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Diese Zahlen geben die Truppenstärke an. Fast alle "..
                      "Militäreinheiten und Kerberos verfügen über Soldaten.",
        Arrow       = ArrowPos_TroopSize,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Hier seht Ihr die Verteidigung des Trupps. Sie wird "..
                      "erlittenen Schaden reduzieren.",
        Arrow       = ArrowPos_Armor,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Die Angriffskraft gibt den Schaden an, den ein Trupp "..
                      "austeilen kann. Die Angriffskraft wird mit der Rüstung"..
                      "des Angriffsziels verrechnet.",
        Arrow       = ArrowPos_Damage,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Und schließich der Unterhalt. Eure Einheiten werden "..
                      "unterschiedlich viel Sold verlangen. Der Unterhalt "..
                      "richtet sich nach {scarlet}der Truppenart{white} und "..
                      "{scarlet}der Anzahl an Soldaten.",
        Arrow       = ArrowPos_Upkeep,
        ArrowWidget = "TutorialArrowRight",
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Natürlich könnt Ihr Truppen entlassen, wenn Ihr sie "..
                      "nicht mehr benötigt.{scarlet} Haltet STRG und sie "..
                      "werden noch schneller entlassen.",
        Arrow       = ArrowPos_Expel,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("Scout"));
        end
    }
end

function Tutorial_AddProvisionSection()
    Tutorial.AddMessage {
        Text        = "Es ist an der Zeit, dass ich Euch erkläre, wie Ihr "..
                      "Eure Burg zu führen habt.",
    }
    Tutorial.AddMessage {
        Text        = "Eure Gebäude werden noch immer von Knechten gebaut. "..
                      "Manche Gebäude sind an einen Titel gebunden. {scarlet}"..
                      " Ihr seht die Bedigungen im Tooltip. {white} Ebenso "..
                      " sind Technologien u.a. an den Titel gebunden.",
        Action      = function(_Data)
            Logic.ResumeAllEntities();
            if Logic.GetEntityType(Stronghold:GetPlayerHero(1)) ~= Entities.PU_Hero2 then
                ReplaceEntity("AutoBomb1", Entities.XD_Bomb1);
                ReplaceEntity("AutoBomb2", Entities.XD_Bomb1);
                ReplaceEntity("AutoBomb3", Entities.XD_Bomb1);
            end
            AddResourcesToPlayer(1, {
                [ResourceType.GoldRaw]   = 1500,
                [ResourceType.ClayRaw]   = 1000,
                [ResourceType.WoodRaw]   = 800,
                [ResourceType.StoneRaw]  = 550,
            });
        end
    }
    Tutorial.AddMessage {
        Text        = "Nicht weit von Euer Burg gibt es ein Lehmvorkommen. "..
                      "Beginnen wir damit, dass Ihr es ausbeutet. Baut "..
                      "eine Lehmgrube an der markierten Stelle!",
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
        Text        = "Schaut, die Bergmänner kommen auf die Burg. Doch was "..
                      "ist das? Sie sind nicht zufrieden! Wenn das so weiter "..
                      "geht, werden sie sehr schnell wieder gehen! Macht "..
                      "nicht den Fehler den Pöbel zu unterschätzen!",
        Action      = function(_Data)
            Logic.DestroyEffect(gvTutorial_ClayMinePointer);
        end,
    }
    Tutorial.AddMessage {
        Text        = "Schnell, stellt ihnen Haus und Hof bereit! Wenn sie "..
                      "essen und schlafen können, sind sie zufriedener.",
        Condition   = function(_Data)
            local NoFarm = Logic.GetNumberOfWorkerWithoutEatPlace(1);
            local NoHouse = Logic.GetNumberOfWorkerWithoutSleepPlace(1);
            return NoFarm == 0 and NoHouse == 0;
        end
    }
    Tutorial.AddMessage {
        Text        = "Das sieht schon besser aus! Allerdings wird dies noch "..
                      "nicht reichen. Ihr werdet schon mehr tun müssen. "..
                      "Ziergebäude bauen, Technologien erforschen.... Denkt "..
                      "an das, was ich Euch bereits beigebracht habe.",
    }
    Tutorial.AddMessage {
        Text        = "Versucht, die Abzüge auf die Beliebtheit am Zahltag "..
                      "auszugleichen und lockt insgesamt 15 Arbeiter ("..
                      "keine Knechte) an!",
        Condition   = function(_Data)
            local WorkerCount = Logic.GetNumberOfAttractedWorker(1);
            local Reputation = GetReputationIncome(1);
            return WorkerCount >= 15 and Reputation >= 0;
        end
    }
    Tutorial.AddMessage {
        Text        = "Die neuen Arbeiter spülen frisches Gold in Eurer. "..
                      "Stadtsäckel. Fianzen, die Ihr bitter benötigen, um "..
                      "Truppen auszuheben. Aber als herkömmlicher Adliger "..
                      "könnt Ihr nur Eure Knechte bewaffnen.",
    }
    Tutorial.AddMessage {
        Text        = "Erhebt Euren Adligen in den Rang eines Kastellan!",
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
        Text        = "Jeder Rang bringt neue Rechte und Pflichten mit sich. "..
                      "Das Volk wird ebenfalls immer schwieriger zufrieden "..
                      "zu stellen. Sobald Ihr das Fürstentum erreicht, "..
                      "{scarlet} müsst Ihr Euch um die Strafverfolgung "..
                      "kümmern!",
    }
    Tutorial.AddMessage {
        Text        = "Arbeiter werden {scarlet}das Gesetz brechen. {white} "..
                      "Verbrecher nicht zu fangen, {scarlet}ruiniert schnell "..
                      "Euer Ansehen! {white}Versucht sie schnell zu fangen. "..
                      "{scarlet} Lasst dazu bewaffnete Knechte Wache "..
                      "schieben oder baut Aussichtstürme!",
    }
end

function Tutorial_AddMilitarySection()
    Tutorial.AddMessage {
        Text        = "Soldaten werden in Rekrutierungsgebäuden angeworben. "..
                      "Errichtet eine Kaserne!",
        Condition   = function(_Data)
            local Barracks = GetPlayerEntities(1, Entities.PB_Barracks1);
            if Barracks[1] and Logic.IsConstructionComplete(Barracks[1]) == 1 then
                return true;
            end
        end
    }
    Tutorial.AddMessage {
        Text        = "Wundervoll! Im Rang eines Kastellan seid Ihr nun in "..
                      "der Lage, Speerträger auszurüsten. Sie sind schwach "..
                      "aber billig und können in Massen in die Schlacht "..
                      "geworfen werden.",
    }
    Tutorial.AddMessage {
        Text        = "Rekrutiert einen Trupp Speerträger!",
        Condition   = function(_Data)
            return Logic.GetNumberOfEntitiesOfTypeOfPlayer(1, Entities.PB_LeaderPoleArm1) > 0;
        end
    }
    Tutorial.AddMessage {
        Text        = "Truppen werden in eine {scarlet}Produktionskette "..
                      "{white}eingereiht. Jeder Einheitentyp hat eine eigene "..
                      "Kette. Ihr könnt somit {scarlet}mehrere Truppentypen "..
                      "gleichzeitig ausbilden. {white}Allerdings müsst Ihr "..
                      "den nötigen Rang haben.",
    }
    Tutorial.AddMessage {
        Text        = "Kanonen bilden eine Ausnahme. Sie werden so gebaut, "..
                      "wie Ihr es gewohnt seid. Kanonen belegen Plätze "..
                      "{scarlet}sobald sie in Auftrag gegeben werden.",
    }
    Tutorial.AddMessage {
        Text        = "Ihr werdet Eure neuen Truppen schon bald brauchen. "..
                      "{scarlet}Die Wegelagerer haben von uns Notiz genommen "..
                      "und planen einen Angriff auf eure Burg! {white}Die "..
                      "Gelegenheit, das Erlernte anzuwenden!",
        Action      = function(_Data)
            ReplaceEntity("BridgeBarrier", Entities.XD_Rock7);
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
        Text        = "Schaut, eine Provinz! Manche Dorfzentren gewähren "..
                      "Euch die Hoheit über eine Länderei. {scarlet}Sie "..
                      "produzieren Beliebtheit, Ehre oder Rohstoffe zum "..
                      "Zahltag, gewähren mehr Platz für das Militär {white}"..
                      "oder verleihen andere missionsabhängige Boni.",
    }
    Tutorial.AddMessage {
        Text        = "Nehmt die Provinz ein, um zu erfahren, welchen Bonus "..
                      "sie für Euch bereit hält! ",
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
        Text        = "Meinen Glückwunsch, Hochwohlgeboren! Ihr habt die "..
                      "Einführung in {scarlet}Stronghold {white} erfolgreich "..
                      "gemeistert. Ihr könnt das Spiel nun beenden oder die "..
                      "Mission zu Ende spielen.",
        Action      = function(_Data)
            ReplaceEntity("GateDude", Entities.CU_PoleArmIdle);
        end,
    }
    Tutorial.AddMessage {
        Text        = "Egal wie Ihr Euch entscheidet, ich werde erst mal "..
                      "Kalkofe von der Südseeinsel herunter werfen und mich "..
                      "anschließend selbst dort breit machen! Gehabt Euch "..
                      "wohl, Hochwohlgeboren!",
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
        Message("Der Turmwärter wird nun mit Euch sprechen!");
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

-- ########################################################################## --
-- #                                ENEMY                                   # --
-- ########################################################################## --

-- The final boss is implemented using the cerberus army. Most of the troofs
-- defent - it is a tutorial after all - and one normal army attacks.
function CreatePlayer2()
    CreatePlayer2Armies();
end

function CreatePlayer2Armies()
    gvP2HQSpawner = SpawnerCreate("HQ2", "HQ2Spawn");
    SpawnerSetQuantity(gvP2HQSpawner, 3);
    SpawnerSetFrequency(gvP2HQSpawner, 3*60);
    SpawnerSetTypesToSpawn(gvP2HQSpawner,
        Entities.CU_BlackKnight_LeaderMace2);

    gvP2BarracksSpawner = SpawnerCreate("P2Barracks1", "P2Barracks1Spawn");
    SpawnerSetQuantity(gvP2BarracksSpawner, 1);
    SpawnerSetFrequency(gvP2BarracksSpawner, 2*60);
    SpawnerSetTypesToSpawn(gvP2BarracksSpawner,
        Entities.PU_LeaderPoleArm2,
        Entities.PU_LeaderSword3);

    gvP2ArcherySpawner = SpawnerCreate("P2Archery1", "P2Archery1Spawn");
    SpawnerSetQuantity(gvP2BarracksSpawner, 2);
    SpawnerSetFrequency(gvP2ArcherySpawner, 3*60);
    SpawnerSetTypesToSpawn(gvP2ArcherySpawner,
        Entities.PU_LeaderBow2,
        Entities.PU_LeaderBow3);

    gvP2StableSpawner = SpawnerCreate("P2Stable1", "P2Stable1Spawn");
    SpawnerSetQuantity(gvP2BarracksSpawner, 1);
    SpawnerSetFrequency(gvP2StableSpawner, 4*60);
    SpawnerSetTypesToSpawn(gvP2StableSpawner,
        Entities.PU_LeaderHeavyCavalry1);

    gvP2FoundrySpawner = SpawnerCreate("P2Foundry1", "P2Foundry1Spawn");
    SpawnerSetQuantity(gvP2BarracksSpawner, 1);
    SpawnerSetFrequency(gvP2FoundrySpawner, 3*60);
    SpawnerSetTypesToSpawn(gvP2FoundrySpawner,
        Entities.PV_Cannon1);

    ---

    gvP2Army1 = ArmyCreate(2, 8, GetPosition("P2OuterPos"), 3000);
    ArmyAddAttackTarget(gvP2Army1, "P2AttackPath1", "PlayerHome");
    ArmySetSpawners(gvP2Army1,
        gvP2HQSpawner, gvP2BarracksSpawner, gvP2ArcherySpawner,
        gvP2StableSpawner, gvP2FoundrySpawner);

    for i= 2, 7 do
        _G["gvP2Army"..i] = ArmyCreate(2, 3, GetPosition("P2DefPos1"), 5000);
        ArmyAddGuardPosition(_G["gvP2Army"..i], "P2DefPos1");
        ArmyAddGuardPosition(_G["gvP2Army"..i], "P2DefPos2");
        ArmyAddGuardPosition(_G["gvP2Army"..i], "P2DefPos3");
        ArmyAddGuardPosition(_G["gvP2Army"..i], "P2DefPos4");
        ArmyAddGuardPosition(_G["gvP2Army"..i], "P2DefPos5");
        ArmyAddGuardPosition(_G["gvP2Army"..i], "P2DefPos6");
        ArmyAddGuardPosition(_G["gvP2Army"..i], "P2DefPos7");
        ArmyAddGuardPosition(_G["gvP2Army"..i], "P2DefPos8");
        ArmySetSpawners(_G["gvP2Army"..i],
            gvP2HQSpawner, gvP2BarracksSpawner, gvP2ArcherySpawner,
            gvP2StableSpawner, gvP2FoundrySpawner);
    end
    ArmySynchronize(gvP2Army2, gvP2Army3, gvP2Army4, gvP2Army5, gvP2Army6, gvP2Army7);

    SetHostile(1, 2);
    MakeInvulnerable("Scorillo");
    Job.Second(function()
        if not IsExisting("HQ2") then
            MakeVulnerable("Scorillo");
            return true;
        end
    end);
end

-- The splitter group is implementet as standard bandit camp. They have the
-- ability to attack the player.
function CreatePlayer3()
    local Generators = {};
    table.insert(Generators, CreateTroopSpawner(
        3, "HQ3", GetPosition("HQ3Spawn"), 3, 60, 2000,
        Entities.PU_LeaderBow1
    ));
    for i= 1,3 do
        table.insert(Generators, CreateTroopSpawner(
            3, "P3Tent" ..i, nil, 1, 2*60, 2000,
            Entities.PU_LeaderPoleArm1
        ));
    end

    gvPlayer3Camp = CreateOutlawCamp(
        3, GetPosition("BanditCampPos"), GetPosition("PlayerHome"),
        2500, 3, 10*60, unpack(Generators)
    );

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
    local Briefing = {};
    local AP,ASP,AMC = BriefingSystem.AddPages(Briefing);

    AP {
        Title    = "Mentor",
        Text     = "Willkommen, weiser Herrscher! Ich bin Euer Mentor und "..
                   "werde Euch unterweisen. Es gibt viele Neuerungen, die "..
                   "Ihr erlernen müsst, wenn es Euer Begehr ist, im Kampf "..
                   "siegreich hervorzugehen.",
        Target   = "HQ1",
        Duration = 10,
        NoSkip   = true,
    }
    AP {
        Title    = "Mentor",
        Text     = "Es sieht so aus, als sei eine Revolte gegen die Krone "..
                   "im vollem Gange. Der Kaiser hat Euch entsandt, in der "..
                   " entlegensten Provinz des Reiches für Ordnung zu sorgen.",
        Target   = "HQ2",
        Duration = 10,
        Explore  = 6000,
        MiniMap  = true,
        Signal   = true,
        NoSkip   = true,
        Action   = function()
            Move("Scout", "ScoutPos");
        end
    }
    AP {
        Title    = "Mentor",
        Text     = "Seht nur, die Späher sind zurückgekehrt. Sie bringen "..
                   "gewiss Kunde von dem, was sich hier zugetragen hat...",
        Target   = "ScoutPos",
        Duration = 6,
        NoSkip   = true,
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
        Text     = "Die Provinz ist in Aufruhr. Es heißt, es habe einen "..
                   "Aufstand gegeben. Sprecht, was habt Ihr zu berichten?",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "Anführer der Späher",
        Text     = gvGender.Address.. ", Es sieht so aus, als habe ein alter "..
                   "Feind seine Macht wiedererlangt.",
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }
    AP {
        Title    = "Anführer der Späher",
        Text     = "Der Schwarze Ritter Scorillo hat erneut eine große Armee "..
                   "um sich geschaart. Es hat den Anschein, als wolle er den "..
                   "Kaiser stürzen und selbst die Macht ergreifen.",
        Target   = "Scorillo",
        Explore  = 6000,
        CloseUp  = true,
        MiniMap  = true,
        Signal   = true,
    }
    AP {
        Title    = gvGender.Name,
        Text     = "Und ich dachte, der Kerl wäre tot. Warum müssen die "..
                   "eigentlich immer wieder aufstehen...",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "Anführer der Späher",
        Text     = "Entschuldigt, " ..gvGender.Address.. ", aber das kann "..
                   "ich Euch nicht beantworten.",
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }
    AP {
        Title    = "Anführer der Späher",
        Text     = "Der Feind ist allerdings nicht so geeint, wie es den "..
                   "Anschein hat. Eine Splittergruppe von Scorillos Armee "..
                   "hat diesen alten Turm bezogen und blockiert die Straße. "..
                   "Sie machen keinen Unterschied zwischen Freund und Feind.",
        Target   = "HQ3",
        Explore  = 4000,
        MiniMap  = true,
        Signal   = true,
    }
    AP {
        Title    = "Anführer der Späher",
        Text     = "Außerdem ist die große Brücke dem letztem Erdbeben zum "..
                   "Opfer gefallen. Beide Zugänge zur Burg des Verräters "..
                   "sind abgeschnitten. Ihr müsst einen Weg finden, sie "..
                   "wiederherzustellen, oder niemand wird Scorillo stoppen!",
        Target   = "BridgePos",
        Explore  = 4000,
        MiniMap  = true,
        Signal   = true,
    }
    AP {
        Title    = gvGender.Name,
        Text     = "Na, das könnt Ihr getroßt mir überlassen.",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "Anführer der Späher",
        Text     = "Ich bin voller Zuversicht, " ..gvGender.Address.. "! Ich "..
                   "und meine Leute unterstehen Eurem Befehl.",
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }

    Briefing.Finished = function(_Data)
        ChangePlayer(GetID(_Npc.ScriptName), 1);
        Tutorial_StartPart2();
        Logic.AddQuest(
            1, 1, MAINQUEST_OPEN, "Schatten der Vergangenheit",
            "Zerstört die Schwarze Festung und tötet Scorillo. Diesmal "..
            "wird es endgültig sein!", 1);
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
        Title    = "Turmwärter",
        Text     = "Ah, endlich frei! Wisst Ihr wie eingeschlafene Füße "..
                   "schmecken? Ungefähr so wie das Zeug, was mir vorgesetzt "..
                   "wurde. Wäh!",
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }
    AP {
        Title    = gvGender.Name,
        Text     = "Und wer war Ihr noch mal?",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "Turmwärter",
        Text     = "Ich war der Wärter des Turms, den Eure Leute zerstört "..
                   "haben. Das war einmal eine Zollstation, bevor die "..
                   "Schergen dieses Irren Scorillo alles übernommen haben.",
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }
    AP {
        Title    = "Turmwärter",
        Text     = "Wegen diesem Mann bin ich hier. Ich handele im Auftrag "..
                   "des Kaisers. Ich soll mich dem Aufstand annehmen.",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "Turmwärter",
        Text     = "Die Brücke ist bei einem Erdbeben eingestürzt. Wenn ich "..
                   "das Tor öffne, dann quetschen sich die bösen Jungs hier "..
                   "durch. Dann ist Polen offen! Das Tor bleibt zu, bis die "..
                   "Brücke wieder aufgebaut ist.",
        Target   = "BridgePos",
        Explore  = 4000,
        CloseUp  = false,
    }
    AP {
        Title    = gvGender.Name,
        Text     = "Na gut, dann werde ich mich zuerst darum kümmern.",
        Target   = _HeroID,
        CloseUp  = true,
    }

    Briefing.Finished = function(_Data)
        AllowTechnology(Technologies.B_Bridge, 1);
        Job.Second(Tutorial_BridgeBuildTrigger);
        Logic.AddQuest(
            1, 2, SUBQUEST_OPEN, "Brückenbau",
            "Baut die zerstörte Brücke wieder auf! Bereitet Euch auf schwere "..
            "Angriffe des Gegners vor!", 1);
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
        Text     = "Ich habe die Brücke wieder aufbauen lassen. Damit ist "..
                   "Eure Bedingung erfüllt. Offnet jetzt das Tor!",
        Target   = _HeroID,
        CloseUp  = true,
    }
    AP {
        Title    = "Turmwärter",
        Text     = "So soll es sein, " ..gvGender.Address.. "! Nun da sie "..
                   "nicht mehr diesen Weg nehmen müssen, kann ich das Tor "..
                    "ruhigen Gewissens aufsperren.",
        Target   = _Npc.ScriptName,
        CloseUp  = true,
    }

    Briefing.Finished = function(_Data)
        ReplaceEntity("BanditGate", Entities.XD_PalisadeGate2);
    end
    BriefingSystem.Start(1, "BriefingGuardian1", Briefing);
end

