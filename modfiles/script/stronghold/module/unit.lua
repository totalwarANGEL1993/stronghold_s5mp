--- 
--- Unit script
---
--- This script implements al unit specific actions and overwrites their
--- selection menus. Also properties like costs, needed rank, upkeep and
--- if they are allowed are defined here.
--- 

Stronghold = Stronghold or {};

Stronghold.Unit = {
    SyncEvents = {},
    Data = {},
    Config = {
        UI = {
            MilitaryLimit = {
                de = "Euere Heeresstärke ist an ihrem Limit, Hochwohlgeboren!",
                en = "Your army strength is at its limit, Your Highness!",
            },
            ExpellSingle = {
                de = "{grey}Einheit entlassen{white}{cr}Entlasst die "..
                     "selektierte Einheit aus ihrem Dienst. Wenn Ihr "..
                     "Soldaten entlasst, geht der Hauptmann zuletzt.",
                en = "{grey}Dismiss unit{white}{cr}Dismiss the unit from "..
                     "their duties. The leader always goes last.",
            },
            ExpellAll = {
                de = "{grey}Alle entlassen{white}{cr}Entlasst alle aktuell "..
                     "selektierten Einheiten aus ihrem Dienst.",
                en = "{grey}Dismiss all{white}{cr}Dismiss all units you "..
                     " currently have selected at once.",
            },
            RecruitSingle = {
                de = "{grey}Soldat rekrutieren{white}{cr}Heuert einen neuen "..
                     "Soldaten für die Gruppe des Haupmannes an.",
                en = "{grey}Buy soldier{white}{cr}Recruit a single soldier "..
                     "for the group of the leader.",
            },
            RecruitAll = {
                de = "{grey}Soldaten rekrutieren{white}{cr}Füllt die Gruppe "..
                     "des Haupmannes mit so vielen Soldaten, wie möglich.",
                en = "{grey}Buy soldiers{white}{cr}Refill the leader's group "..
                     "as much as possible with new soldiers.",
            },
        },

        Units = {
            [Entities.PU_LeaderPoleArm1] = {
                Costs = {
                    [1] = {0, 50, 0, 40, 0, 0, 0},
                    [2] = {0, 5, 0, 10, 0, 0, 0},
                },
                Allowed = true,
                Rank = 1,
                Upkeep = 15,
            },
            [Entities.PU_LeaderPoleArm2] = {
                Costs = {
                    [1] = {5, 75, 0, 50, 0, 0, 0},
                    [2] = {0, 10, 0, 25, 0, 0, 0},
                },
                Allowed = false,
                Rank = 2,
                Upkeep = 20,
            },
            [Entities.PU_LeaderPoleArm3] = {
                Costs = {
                    [1] = {10, 150, 0, 70, 0, 10, 0},
                    [2] = {0, 65, 0, 40, 0, 5, 0},
                },
                Allowed = true,
                Rank = 3,
                Upkeep = 40
            },
            [Entities.PU_LeaderPoleArm4] = {
                Costs = {
                    [1] = {15, 200, 0, 80, 0, 20, 0},
                    [2] = {0, 75, 0, 45, 0, 10, 0},
                },
                Allowed = false,
                Rank = 6,
                Upkeep = 50
            },
            ---
            [Entities.PU_LeaderSword1] = {
                Costs = {
                    [1] = {6, 100, 0, 0, 0, 50, 0},
                    [2] = {0, 15, 0, 0, 0, 10, 0},
                },
                Allowed = false,
                Rank = 2,
                Upkeep = 20,
            },
            [Entities.PU_LeaderSword2] = {
                Costs = {
                    [1] = {10, 150, 0, 0, 0, 60, 0},
                    [2] = {0, 50, 0, 0, 0, 35, 0},
                },
                Allowed = true,
                Rank = 3,
                Upkeep = 35,
            },
            [Entities.PU_LeaderSword3] = {
                Costs = {
                    [1] = {20, 230, 0, 0, 0, 70, 0},
                    [2] = {0, 60, 0, 0, 0, 45, 0},
                },
                Allowed = true,
                Rank = 5,
                Upkeep = 60,
            },
            [Entities.PU_LeaderSword4] = {
                Costs = {
                    [1] = {30, 275, 0, 0, 0, 85, 0},
                    [2] = {0, 75, 0, 0, 0, 60, 0},
                },
                Allowed = false,
                Rank = 7,
                Upkeep = 75,
            },
            ---
            [Entities.PU_LeaderBow1] = {
                Costs = {
                    [1] = {2, 90, 0, 60, 0, 0, 0},
                    [2] = {0, 10, 0, 10, 0, 0, 0},
                },
                Allowed = true,
                Rank = 2,
                Upkeep = 15,
            },
            [Entities.PU_LeaderBow2] = {
                Costs = {
                    [1] = {6, 110, 0, 70, 0, 0, 0},
                    [2] = {0, 20, 0, 20, 0, 0, 0},
                },
                Allowed = false,
                Rank = 2,
                Upkeep = 20,
            },
            [Entities.PU_LeaderBow3] = {
                Costs = {
                    [1] = {12, 250, 0, 35, 0, 35, 0},
                    [2] = {0, 60, 0, 15, 0, 25, 0},
                },
                Allowed = true,
                Rank = 3,
                Upkeep = 35,
            },
            [Entities.PU_LeaderBow4] = {
                Costs = {
                    [1] = {15, 300, 0, 40, 0, 40, 0},
                    [2] = {0, 75, 0, 20, 0, 30, 0},
                },
                Allowed = false,
                Rank = 5,
                Upkeep = 50,
            },
            ---
            [Entities.PV_Cannon1] = {
                Costs = {
                    [1] = {15, 350, 0, 30, 0, 200, 150},
                    [2] = {0, 0, 0, 0, 0, 0, 0},
                },
                Allowed = true,
                Rank = 4,
                Upkeep = 30,
            },
            [Entities.PV_Cannon2] = {
                Costs = {
                    [1] = {15, 350, 0, 30, 0, 200, 150},
                    [2] = {0, 0, 0, 0, 0, 0, 0},
                },
                Allowed = true,
                Rank = 4,
                Upkeep = 50,
            },
            [Entities.PV_Cannon3] = {
                Costs = {
                    [1] = {30, 950, 0, 50, 0, 600, 350},
                    [2] = {0, 0, 0, 0, 0, 0, 0},
                },
                Allowed = true,
                Rank = 7,
                Upkeep = 100,
            },
            [Entities.PV_Cannon4] = {
                Costs = {
                    [1] = {30, 950, 0, 50, 0, 350, 600},
                    [2] = {0, 0, 0, 0, 0, 0, 0},
                },
                Allowed = true,
                Rank = 7,
                Upkeep = 120,
            },
            ---
            [Entities.PU_LeaderCavalry1] = {
                Costs = {
                    [1] = {6, 200, 0, 40, 0, 20, 0},
                    [2] = {0, 60, 0, 15, 0, 5, 0},
                },
                Allowed = true,
                Rank = 4,
                Upkeep = 25,
            },
            [Entities.PU_LeaderCavalry2] = {
                Costs = {
                    [1] = {10, 250, 0, 20, 0, 50, 0},
                    [2] = {0, 80, 0, 20, 0, 10, 0},
                },
                Allowed = false,
                Rank = 6,
                Upkeep = 40,
            },
            ---
            [Entities.PU_LeaderHeavyCavalry1] = {
                Costs = {
                    [1] = {35, 300, 0, 0, 0, 90, 0},
                    [2] = {0, 100, 0, 0, 0, 30, 0},
                },
                Allowed = true,
                Rank = 6,
                Upkeep = 70,
            },
            [Entities.PU_LeaderHeavyCavalry2] = {
                Costs = {
                    [1] = {50, 400, 0, 0, 0, 110, 0},
                    [2] = {0, 120, 0, 0, 0, 40, 0},
                },
                Allowed = false,
                Rank = 7,
                Upkeep = 90,
            },
            ---
            [Entities.PU_LeaderRifle1] = {
                Costs = {
                    [1] = {20, 250, 0, 20, 0, 0, 50},
                    [2] = {0, 60, 0, 20, 0, 0, 30},
                },
                Allowed = true,
                Rank = 5,
                Upkeep = 50,
            },
            [Entities.PU_LeaderRifle2] = {
                Costs = {
                    [1] = {30, 300, 0, 0, 0, 20, 60},
                    [2] = {0, 70, 0, 0, 0, 20, 30},
                },
                Allowed = true,
                Rank = 7,
                Upkeep = 80,
            },
            ---
            [Entities.PU_Scout] = {
                Costs = {
                    [1] = {0, 150, 0, 50, 0, 50, 0},
                    [2] = {0, 0, 0, 0, 0, 0, 0},
                },
                Allowed = true,
                Rank = 2,
                Upkeep = 10,
            },
            [Entities.PU_Thief] = {
                Costs = {
                    [1] = {30, 500, 0, 0, 0, 100, 100},
                    [2] = {0, 0, 0, 0, 0, 0, 0},
                },
                Allowed = true,
                Rank = 4,
                Upkeep = 50,
            },
            ---
            [Entities.PU_Serf] = {
                Costs = {
                    [1] = {0, 50, 0, 0, 0, 0, 0},
                    [2] = {0, 0, 0, 0, 0, 0, 0},
                },
                Allowed = true,
                Rank = 1,
                Upkeep = 0,
            },
        },
    },
}

function Stronghold.Unit:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {};
    end

    Job.Create(function()
        local ID = Event.GetEntityID();
        Stronghold.Unit:SetFormationOnCreate(ID);
    end);
    self:CreateUnitButtonHandlers();
    self:OverrideGUI();
end

function Stronghold.Unit:OnSaveGameLoaded()
end

function Stronghold.Unit:CreateUnitButtonHandlers()
    self.SyncEvents = {
        BuySoldier = 1,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Unit.SyncEvents.BuySoldier then
                Stronghold.Unit:RefillUnit(_PlayerID, arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8], arg[9]);
            end
        end
    );
end

-- -------------------------------------------------------------------------- --
-- Buy Unit (Logic)

function Stronghold.Unit:BuyUnit(_PlayerID, _Type, _BarracksID, _AutoFill)
    if Stronghold:IsPlayer(_PlayerID) then
        if Stronghold.UnitConfig:GetConfig(_Type, _PlayerID) then
            if not IsExisting(_BarracksID) then
                return;
            end
            local Orientation = Logic.GetEntityOrientation(_BarracksID);
            local TypeName = Logic.GetEntityTypeName(_Type);
            local Position = self:GetBarracksDoorPosition(_BarracksID);
            local IsLeader = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Leader) == 1;
            local IsCannon = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Cannon) == 1;
            local CostsLeader = Stronghold.Recruitment:GetLeaderCosts(_PlayerID, _Type, 0);

            -- Passive ability: experienced troops
            local Experience = 0;
            if IsLeader and not IsCannon and Stronghold.Hero:HasValidHeroOfType(_PlayerID, Entities.PU_Hero4) then
                CostsLeader = Stronghold.Hero:ApplyUnitCostPassiveAbility(_PlayerID, _Type, CostsLeader);
                Experience = 3;
            end
            if not TypeName or not string.find(TypeName, "Cannon") then
                RemoveResourcesFromPlayer(_PlayerID, CostsLeader);
                local ID = AI.Entity_CreateFormation(_PlayerID, _Type, 0, 0, Position.X, Position.Y, 0, 0, Experience, 0);
                if ID ~= 0 then
                    if IsLeader and _AutoFill then
                        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(ID);
                        for i= 1, MaxSoldiers do
                            local CostsSoldier = Stronghold.UnitConfig:GetConfig(_Type, _PlayerID).Costs[2];
                            CostsSoldier = Stronghold.Recruitment:GetSoldierCostsByLeaderType(_PlayerID, _Type, 1);
                            -- CostsSoldier[ResourceType.Honor] = 0;
                            if HasEnoughResources(_PlayerID, CostsSoldier) then
                                RemoveResourcesFromPlayer(_PlayerID, CostsSoldier);
                                local SoldierType = Logic.LeaderGetSoldiersType(ID);
                                Logic.CreateEntity(SoldierType, Position.X, Position.Y, 0, _PlayerID);
                                Tools.AttachSoldiersToLeader(ID, 1);
                            end
                        end
                    end
                    Logic.RotateEntity(ID, Orientation +180);
                    self:SetFormationOnCreate(ID);
                end
            else
                self:PayUnit(_PlayerID, _Type);
            end
        end
        Stronghold.Players[_PlayerID].BuyUnitLock = nil;
    end
end

function Stronghold.Unit:PayUnit(_PlayerID, _Type)
    local CostsLeader = Stronghold:CreateCostTable(unpack(Stronghold.UnitConfig:GetConfig(_Type, _PlayerID).Costs[1]));
    local IsLeader = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Leader) == 1;
    local IsCannon = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Cannon) == 1;
    if IsLeader and not IsCannon and Stronghold.Hero:HasValidHeroOfType(_PlayerID, Entities.PU_Hero4) then
        CostsLeader = Stronghold.Hero:ApplyUnitCostPassiveAbility(_PlayerID, _Type, CostsLeader);
    end
    RemoveResourcesFromPlayer(_PlayerID, CostsLeader);
end

function Stronghold.Unit:RefillUnit(_PlayerID, _UnitID, _Amount, _Honor, _Gold, _Clay, _Wood, _Stone, _Iron, _Sulfur)
    if Stronghold:IsPlayer(_PlayerID) then
        local LeaderType = Logic.GetEntityType(_UnitID);
        if Stronghold.UnitConfig:GetConfig(LeaderType, _PlayerID) then
            if Logic.GetEntityHealth(_UnitID) > 0 then
                local Task = Logic.GetCurrentTaskList(_UnitID);
                if not Task or (not string.find(Task, "DIE") and not string.find(Task, "BATTLE")) then
                    local BuildingID = Logic.LeaderGetNearbyBarracks(_UnitID);
                    local Position = self:GetBarracksDoorPosition((BuildingID ~= 0 and BuildingID) or _UnitID);

                    local Costs = Stronghold:CreateCostTable(unpack({
                        _Honor or 0,
                        _Gold or 0,
                        _Clay or 0,
                        _Wood or 0,
                        _Stone or 0,
                        _Iron or 0,
                        _Sulfur or 0
                    }));

                    RemoveResourcesFromPlayer(_PlayerID, Costs);
                    for i= 1, _Amount do
                        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(_UnitID);
                        local Soldiers = Logic.LeaderGetNumberOfSoldiers(_UnitID);
                        if Soldiers < MaxSoldiers then
                            local SoldierType = Logic.LeaderGetSoldiersType(_UnitID);
                            Logic.CreateEntity(SoldierType, Position.X, Position.Y, 0, _PlayerID);
                            Tools.AttachSoldiersToLeader(_UnitID, 1);
                        end
                    end
                end
            end
        end
        Stronghold.Players[_PlayerID].BuyUnitLock = nil;
    end
end

function Stronghold.Unit:SetFormationOnCreate(_ID)
    if Logic.IsLeader(_ID) == 0 then
        return;
    end

    -- Circle formation
    if Logic.GetEntityType(_ID) == Entities.PU_LeaderSword2
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderSword3
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderSword4 then
        Logic.LeaderChangeFormationType(_ID, 5);
        return;
    end

    -- Line formation
    if Logic.GetEntityType(_ID) == Entities.PU_LeaderRifle1
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderRifle2
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderPoleArm3
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderPoleArm4
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderBow3
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderBow4
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderCavalry1
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderCavalry2 then
        Logic.LeaderChangeFormationType(_ID, 4);
        return;
    end

    -- Arrow formation
    if Logic.GetEntityType(_ID) == Entities.PU_LeaderHeavyCavalry1
    or Logic.GetEntityType(_ID) == Entities.PU_LeaderHeavyCavalry2 then
        Logic.LeaderChangeFormationType(_ID, 6);
        return;
    end

    -- Default: Horde formation
    Logic.LeaderChangeFormationType(_ID, 9);
end

-- -------------------------------------------------------------------------- --
-- Buy Unit (UI)

function Stronghold.Unit:BuySoldierButtonAction()
    local Language = GetLanguage();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Stronghold:GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not Stronghold:IsPlayer(PlayerID) then
        return true;
    end
    if GuiPlayer ~= PlayerID then
        return true;
    end

    local BuyAmount = 1;
    if XGUIEng.IsModifierPressed(Keys.ModifierShift)== 1 then
        local CurrentSoldiers = Logic.LeaderGetNumberOfSoldiers(EntityID);
        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(EntityID);
        BuyAmount = MaxSoldiers - CurrentSoldiers;
    end
    if BuyAmount < 1 then
        return true;
    end
    if not Stronghold.Attraction:HasPlayerSpaceForUnits(PlayerID, BuyAmount) then
        Sound.PlayQueuedFeedbackSound(Sounds.VoicesLeader_LEADER_NO_rnd_01, 127);
        Message(self.Config.UI.MilitaryLimit[Language]);
        return true;
    end

    local Type = Logic.GetEntityType(EntityID);
    local Costs = Stronghold.Recruitment:GetSoldierCostsByLeaderType(PlayerID, Type, BuyAmount);
    if not HasPlayerEnoughResourcesFeedback(Costs) then
        return true;
    end

    local Task = Logic.GetCurrentTaskList(EntityID);
    if Task and (string.find(Task, "BATTLE") or string.find(Task, "DIE")) then
        return true;
    end

    Stronghold.Players[PlayerID].BuyUnitLock = true;
    Syncer.InvokeEvent(
        Stronghold.Unit.NetworkCall,
        Stronghold.Unit.SyncEvents.BuySoldier,
        EntityID,
        BuyAmount,
        Costs[ResourceType.Honor],
        Costs[ResourceType.Gold],
        Costs[ResourceType.Clay],
        Costs[ResourceType.Wood],
        Costs[ResourceType.Stone],
        Costs[ResourceType.Iron],
        Costs[ResourceType.Sulfur]
    );
    return true;
end

function Stronghold.Unit:BuySoldierButtonTooltip(_KeyNormal, _KeyDisabled, _ShortCut)
    local Language = GetLanguage();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Stronghold:GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not Stronghold:IsPlayer(PlayerID) then
        return false;
    end
    if GuiPlayer ~= PlayerID then
        return true;
    end

    local BuyAmount = 1;
    if XGUIEng.IsModifierPressed(Keys.ModifierShift)== 1 then
        local CurrentSoldiers = Logic.LeaderGetNumberOfSoldiers(EntityID);
        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(EntityID);
        BuyAmount = MaxSoldiers - CurrentSoldiers;
    end

    local Type = Logic.GetEntityType(EntityID);
    local Costs = Stronghold.Recruitment:GetSoldierCostsByLeaderType(PlayerID, Type, BuyAmount);

    local Index = (BuyAmount > 1 and "All") or "Single";
    local Text = Placeholder.Replace(self.Config.UI["Recruit" ..Index][Language]);
    local CostText = FormatCostString(PlayerID, Costs);
    if _KeyNormal == "MenuCommandsGeneric/Buy_Soldier" then
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostText);
    end
    return true;
end

function Stronghold.Unit:BuySoldierButtonUpdate()
    local PlayerID = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local Type = Logic.GetEntityType(EntityID);
    if Stronghold:IsPlayer(PlayerID) then
        local BarracksID = Logic.LeaderGetNearbyBarracks(EntityID);
        local CurrentSoldiers = Logic.LeaderGetNumberOfSoldiers(EntityID);
        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(EntityID);
        if BarracksID == 0 or CurrentSoldiers == MaxSoldiers then
            XGUIEng.DisableButton("Buy_Soldier_Button", 1);
        else
            if Type == Entities.CU_BlackKnight then
                XGUIEng.DisableButton("Buy_Soldier_Button", 0);
            else
                if not Stronghold.UnitConfig:GetConfig(Type, PlayerID)
                or Logic.IsLeader(EntityID) == 0 then
                    XGUIEng.DisableButton("Buy_Soldier_Button", 1);
                else
                    XGUIEng.DisableButton("Buy_Soldier_Button", 0);
                end
            end
        end
        return true;
    end
    return false;
end

function Stronghold.Unit:GetBarracksDoorPosition(_BarracksID)
    local PlayerID = Logic.EntityGetPlayer(_BarracksID);
    local Position = Stronghold.Players[PlayerID].DoorPos;

    local BarracksType = Logic.GetEntityType(_BarracksID);
    if BarracksType == Entities.PB_Barracks1 or BarracksType == Entities.PB_Barracks2 then
        Position = GetCirclePosition(_BarracksID, 900, 180);
    elseif BarracksType == Entities.PB_Archery1 or BarracksType == Entities.PB_Archery2 then
        Position = GetCirclePosition(_BarracksID, 850, 135);
    elseif BarracksType == Entities.PB_Stable1 or BarracksType == Entities.PB_Stable2 then
        Position = GetCirclePosition(_BarracksID, 1000, 165);
    elseif BarracksType == Entities.PB_Foundry1 or BarracksType == Entities.PB_Foundry2 then
        Position = GetCirclePosition(_BarracksID, 1000, 280);
    elseif BarracksType == Entities.PB_Tavern1 or BarracksType == Entities.PB_Tavern2 then
        Position = GetCirclePosition(_BarracksID, 800, 220);
    elseif BarracksType == Entities.PB_VillageCenter1 or
           BarracksType == Entities.PB_VillageCenter2 or
           BarracksType == Entities.PB_VillageCenter3 then
        Position = GetCirclePosition(_BarracksID, 650, 270);
    -- TODO: Add more positions if needed
    end
    return Position;
end

-- -------------------------------------------------------------------------- --
-- Expel

function Stronghold.Unit:ExpelSettlerButtonTooltip(_Key)
    local Language = GetLanguage();
    local PlayerID = Stronghold:GetLocalPlayerID();
    if Stronghold:IsPlayer(PlayerID) then
        if _Key == "MenuCommandsGeneric/expel" then
            local Index = (XGUIEng.IsModifierPressed(Keys.ModifierShift) == 1 and "All") or "Single";
            local Text = Placeholder.Replace(self.Config.UI["Expell" ..Index][Language]);
            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
            return true;
        end
    end
    return false;
end

function Stronghold.Unit:ExpelSettlerButtonAction()
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Stronghold:GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not Stronghold:IsPlayer(PlayerID) then
        return true;
    end
    if GuiPlayer ~= PlayerID then
        return true;
    end

    -- Stops the player from expeling workers to get new with full energy.
    if Logic.IsWorker(EntityID) == 1 and Logic.GetSettlersWorkBuilding(EntityID) ~= 0 then
        return true;
    end
    if XGUIEng.IsModifierPressed(Keys.ModifierShift) == 1 then
        local Selected = {GUI.GetSelectedEntities()};
        GUI.ClearSelection();
        for i= 1, table.getn(Selected) do
            if Logic.IsHero(Selected[i]) == 0 then
                if Logic.IsLeader(Selected[i]) == 1 then
                    local Soldiers = {Logic.GetSoldiersAttachedToLeader(Selected[i])};
                    for j= 2, Soldiers[1] +1 do
                        GUI.ExpelSettler(Soldiers[j]);
                    end
                end
                GUI.ExpelSettler(Selected[i]);
            end
        end
        return true;
    end
    return false;
end

-- -------------------------------------------------------------------------- --
-- UI

function Stronghold.Unit:OverrideGUI()
    Overwrite.CreateOverwrite(
        "GUIAction_BuySoldier",
        function()
            if not Stronghold.Unit:BuySoldierButtonAction() then
                Overwrite.CallOriginal();
            end
        end
    );

    Overwrite.CreateOverwrite(
        "GUIUpdate_BuySoldierButton",
        function()
            Overwrite.CallOriginal();
            return Stronghold.Unit:BuySoldierButtonUpdate();
        end
    );

    Overwrite.CreateOverwrite(
        "GUITooltip_NormalButton",
        function(_Key)
            Overwrite.CallOriginal();
            Stronghold.Unit:ExpelSettlerButtonTooltip(_Key);
        end
    );

    Overwrite.CreateOverwrite(
        "GUIAction_ExpelSettler",
        function()
            if not Stronghold.Unit:ExpelSettlerButtonAction() then
                Overwrite.CallOriginal();
            end
        end
    );

    Overwrite.CreateOverwrite(
        "GUITooltip_BuySoldier",
        function(_KeyNormal, _KeyDisabled, _ShortCut)
            Overwrite.CallOriginal();
            Stronghold.Unit:BuySoldierButtonTooltip(_KeyNormal, _KeyDisabled, _ShortCut);
        end
    );
end

