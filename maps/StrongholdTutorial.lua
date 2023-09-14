SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 1,

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

        BriefingTutorialIntro();
        Tutorial_OverwriteCallbacks();
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
    Pronome = {"er", "sein", "seine"},
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
            gvGender.Pronome = {"sie", "ihr", "ihre"};
            gvGender.Address = "Milady";
        end
    end);
end

-- Part 1 ------------------------------------------------------------------- --

function Tutorial_StartPart1()
    Tutorial.Stop();
    Tutorial.SetCallback(function()
        NonPlayerCharacter.Create {
            ScriptName = "Scout",
            Callback   = BriefingScout
        }
        NonPlayerCharacter.Activate("Scout");
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
    local ArrowPos_Military = {240, 680};
    local ArrowPos_Civil = {240, 695};
    local ArrowPos_Care = {240, 705};

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
                      "Adelsstand. Sie wird benötigt, um Truppen auszuheben, "..
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
                      "Spezialgebäuden beeinflussen die Beliebtheit.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_NewRes
    }
    Tutorial.AddMessage {
        Text        = "{scarlet}Wissen{white} erlaubt die Erforschung von "..
                      "Technologien. Es wird in Euren Bildungseinrichtungen "..
                      "erzeugt. Die üblichen Technologien der Hochschule "..
                      "gibt es nicht mehr, sie haben jedoch würdigen Ersatz "..
                      "bekommen, der Euch massive Vorteile bringt.",
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
                      "Herrschaft leben. Arbeiter, Diebe, Knechte, "..
                      "Kundschafter aber auch Verbrecher zählen zu Eurer "..
                      "Bevölkerung. {scarlet}Baut die Burg aus oder besetzt "..
                      "Dörfer,{white} um mehr Volk aufnehmen zu können.",
        Arrow       = ArrowPos_Civil
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
        Text        = "Die Uhr gibt nicht nur die Zeit bis zum Zahltag an. "..
                      "Hier seht Ihr auch, {scarlet}wie sich Beliebtheit und "..
                      "Ehre{white} verändern werden. Ihr könnt mehr Details "..
                      "sehen, wenn Ihr {scarlet}STRG gedrückt haltet.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_Clock
    }
    Tutorial.AddMessage {
        Text        = "Beliebtheit und Ehre verändern sich {scarlet}niemals "..
                      "{white}sofort sondern {scarlet}ausschließlich{white} "..
                      "am Zahltag!",
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
                      "gewohnten gibt es auch eine zweite, wo Ihr Maßnahmen "..
                      "erlassen könnt.",
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
        Text        = "Probiert es einmal aus! Um einen Sammelpunkt zu "..
                      "setzen, müsst Ihr {scarlet}rechts auf eine von dem "..
                      "Gebäude erreichbare{white} Position klicken.",
        Condition   = function(_Data)
            return gvTutorial_RallyPointSet;
        end
    }
    Tutorial.AddMessage {
        Text        = "Gut gemacht! Künftig ausgebildete Knechte werden zu "..
                      "der markierten Position gehen!",
    }
    Tutorial.AddMessage {
        Text        = "Nun ist es an der Zeit, Euren Adligen zu wählen. Es "..
                      "ist für diese Einführung unerheblich, welchen Adligen "..
                      "Ihr als Euren Avatar bestimmt.",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_BuyNoble,
        Action      = function(_Data)
            GUI.ClearSelection();
            GUI.SelectEntity(GetID("HQ1"));
        end
    }
    Tutorial.AddMessage {
        Text        = "Öffnet das Menü und sucht Euch einen Adligen aus!",
        ArrowWidget = "TutorialArrowUp",
        Arrow       = ArrowPos_BuyNoble,
        Condition   = function(_Data)
            return gvTutorial_HeroSelected;
        end
    }
    Tutorial.AddMessage {
        Text        = "Jeder Adlige besitzt andere Eigenschaften. Ihr tut "..
                      "gut daran, einen Adligen zu wählen, {scarlet}der zu "..
                      "Eurem Spielstil passt.",
    }
    Tutorial.AddMessage {
        Text        = "Selektiert nun Euren Adligen!",
        Condition   = function(_Data)
            return IsEntitySelected(Stronghold:GetPlayerHero(1));
        end
    }
    Tutorial.AddMessage {
        Text        = "Nun solltet Ihr jedoch endlich die Späher anhören...",
    }
end

-- Part 2 ------------------------------------------------------------------- --

function Tutorial_StartPart2()
    Tutorial.Stop();
    Tutorial.SetCallback(function()
        
    end);
    Tutorial_AddUnitSelectionSection();
    Tutorial_AddProvisionSection();
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
        Action      = function(_Data)
            Logic.ResumeAllEntities(1);
            if Logic.GetEntityType(Stronghold:GetPlayerHero(1)) ~= Entities.PU_Hero2 then
                ReplaceEntity("AutoBomb1", Entities.XD_Bomb1);
                ReplaceEntity("AutoBomb2", Entities.XD_Bomb1);
                ReplaceEntity("AutoBomb3", Entities.XD_Bomb1);
            end
            AddResourcesToPlayer(1, {
                [ResourceType.GoldRaw]   = 1000,
                [ResourceType.ClayRaw]   = 2500,
                [ResourceType.WoodRaw]   = 2000,
                [ResourceType.StoneRaw]  = 1000,
                [ResourceType.IronRaw]   = 500,
                [ResourceType.SulfurRaw] = 500,
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
        Text        = "Versucht, Eure Beliebtheit auf 110 zu steigern und "..
                      "lockt insgesamt 20 Arbeiter an!",
        Condition   = function(_Data)
            local WorkerCount = Logic.GetNumberOfAttractedWorker(1);
            local Reputation = GetReputation(1);
            return WorkerCount >= 20 and Reputation >= 110;
        end
    }
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
                   "im vollem Gange. Der König hat Euch entsandt, in der "..
                   " entlegensten Provinz des Reiches für Ordnung zu sorgen.",
        Target   = "HQ2",
        Duration = 10,
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
        ChangePlayer("HQ1", 8);
    end
    Briefing.Finished = function(_Data)
        LookAt("Scout", "HQ1");
        Logic.SuspendAllEntities(1);
        ForbidTechnology(Technologies.T_FreeCamera);
        Tutorial_StartPart1();
    end
    BriefingSystem.Start(1, "BriefingTutorialIntro", Briefing);
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
        Target   = "Scout",
        CloseUp  = true,
    }
    AP {
        Title    = "Anführer der Späher",
        Text     = "Der Schwarze Ritter Scorillo hat erneut eine große Armee "..
                   "um sich geschaart. Es hat den Anschein, als wolle er den "..
                   "König stürzen und selbst die Macht ergreifen.",
        Target   = "Scorillo",
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
        Target   = "Scout",
        CloseUp  = true,
    }
    AP {
        Title    = "Anführer der Späher",
        Text     = "Der Feind ist allerdings nicht so geeint, wie es den "..
                   "Anschein hat. Eine Splittergruppe von Scorillos Armee "..
                   "hat diesen alten Turm bezogen und blockiert die Straße. "..
                   "Sie machen keinen Unterschied zwischen Freund und Feind.",
        Target   = "HQ3",
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
        Text     = "Ich bin voller Zuversicht, " ..gvGender.Address.. "! Ich"..
                   "und meine Leute unterstehen Eurem Befehl.",
        Target   = "Scout",
        CloseUp  = true,
    }

    Briefing.Finished = function(_Data)
        ChangePlayer(GetID("Scout"), 1);
        Tools.CreateSoldiersForLeader(GetID("Scout"), 3);
        Tutorial_StartPart2();
    end
    BriefingSystem.Start(1, "BriefingScout", Briefing);
end


