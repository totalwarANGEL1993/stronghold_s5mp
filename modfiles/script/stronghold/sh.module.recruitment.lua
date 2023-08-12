--- 
--- Recruitment Script
---
--- Recruiting units is done like in Age of Empires. Every unit needs time to
--- be completed. Other units of the same type are enqueued. A building has
--- a queue for each unit it produces.
---
--- Also this script fixes the cannon spam by adding them immediately to the
--- occupied spaces while they are still under construction.
--- 

Stronghold = Stronghold or {};

Stronghold.Recruitment = Stronghold.Recruitment or {
    SyncEvents = {},
    Data = {},
    Config = {},
    Text = {},
};

function Stronghold.Recruitment:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            Config = CopyTable(Stronghold.Unit.Config),
            Roster = {},
            ForgeRegister = {},
            Queues = {
                ["Research_UpgradeSword1"] = {},
                ["Research_UpgradeSword2"] = {},
                ["Research_UpgradeSword3"] = {},
                ["Research_UpgradeSpear1"] = {},
                ["Research_UpgradeSpear2"] = {},
                ["Research_UpgradeSpear3"] = {},
                ---
                ["Research_UpgradeBow1"] = {},
                ["Research_UpgradeBow2"] = {},
                ["Research_UpgradeBow3"] = {},
                ["Research_UpgradeRifle1"] = {},
                ---
                ["Research_UpgradeCavalryLight1"] = {},
                ["Research_UpgradeCavalryHeavy1"] = {},
                ---
                ["Buy_Serf"] = {},
                ["Buy_Scout"] = {},
                ["Buy_Thief"] = {},
            },
        };
        Stronghold.Recruitment:InitQueuesForProducer(GetID("HQ" ..i));
        self:InitDefaultRoster(i);
    end
    self:CreateBuildingButtonHandlers();
    self:OverrideLogic();
end

function Stronghold.Recruitment:OnSaveGameLoaded()
end

function Stronghold.Recruitment:CreateBuildingButtonHandlers()
    self.SyncEvents = {
        BuyCannon = 1,
        EnqueueUnit = 2,
    };
    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Recruitment.SyncEvents.BuyCannon then
                Stronghold.Unit:PayUnit(_PlayerID, arg[1], 0);
                self:RegisterCannonOrder(_PlayerID, arg[2], arg[1]);
            elseif _Action == Stronghold.Recruitment.SyncEvents.EnqueueUnit then
                if arg[5] then
                    self:AbortLatestQueueEntry(_PlayerID, arg[4], Logic.GetEntityName(arg[1]));
                else
                    self:OrderUnit(_PlayerID, arg[4], arg[2], arg[1], arg[3]);
                end
            end
        end
    );
end

function Stronghold.Recruitment:InitDefaultRoster(_PlayerID)
    self.Data[_PlayerID].Roster = {
        -- Barracks
        ["Research_UpgradeSword1"] = Entities.PU_LeaderPoleArm1,
        ["Research_UpgradeSword2"] = Entities.PU_LeaderPoleArm3,
        ["Research_UpgradeSword3"] = Entities.PU_LeaderSword2,
        ["Research_UpgradeSpear1"] = Entities.PU_LeaderSword3,
        ["Research_UpgradeSpear2"] = nil,
        ["Research_UpgradeSpear3"] = nil,
        -- Archery
        ["Research_UpgradeBow1"] = Entities.PU_LeaderBow1,
        ["Research_UpgradeBow2"] = Entities.PU_LeaderBow3,
        ["Research_UpgradeBow3"] = Entities.PU_LeaderRifle1,
        ["Research_UpgradeRifle1"] = Entities.PU_LeaderRifle2,
        -- Stable
        ["Research_UpgradeCavalryLight1"] = Entities.PU_LeaderCavalry1,
        ["Research_UpgradeCavalryHeavy1"] = Entities.PU_LeaderHeavyCavalry1,
        -- Foundry
        ["Buy_Cannon1"] = Entities.PV_Cannon1,
        ["Buy_Cannon2"] = Entities.PV_Cannon2,
        ["Buy_Cannon3"] = Entities.PV_Cannon3,
        ["Buy_Cannon4"] = Entities.PV_Cannon4,
        -- Tavern
        ["Buy_Scout"] = Entities.PU_Scout,
        ["Buy_Thief"] = Entities.PU_Thief,
    };
end

-- -------------------------------------------------------------------------- --

-- DEPRECATED
function Stronghold.Recruitment:IsSufficientRecruiterBuilding(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.Unit.Config:Get(_Type, PlayerID);
    if Config then
        local BuildingType = Logic.GetEntityType(_BuildingID);
        return IsInTable(BuildingType, Config.RecruiterBuilding);
    end
    return false;
end

function Stronghold.Recruitment:HasSufficientRecruiterBuilding(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.Unit.Config:Get(_Type, PlayerID);
    if Config then
        local Providers = table.getn(Config.RecruiterBuilding);
        if Providers == 0 then
            return false;
        end
        for i= 1, Providers do
            local BuildingType = Config.RecruiterBuilding[i];
            local Buildings = Stronghold:GetBuildingsOfType(PlayerID, BuildingType, true);
            if table.getn(Buildings) > 0 then
                return true;
            end
        end
    end
    return false;
end

function Stronghold.Recruitment:HasSufficientProviderBuilding(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.Unit.Config:Get(_Type, PlayerID);
    if Config then
        local Providers = table.getn(Config.ProviderBuilding);
        if Providers == 0 then
            return true;
        end
        for i= 1, Providers do
            local BuildingType = Config.ProviderBuilding[i];
            local Buildings = Stronghold:GetBuildingsOfType(PlayerID, BuildingType, true);
            if table.getn(Buildings) > 0 then
                return true;
            end
        end
    end
    return false;
end

function Stronghold.Recruitment:HasSufficientRank(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.Unit.Config:Get(_Type, PlayerID);
    if Config then
        if GetRank(PlayerID) >= GetRankRequired(PlayerID, Config.Right) then
            return true;
        end
    end
    return false;
end

function Stronghold.Recruitment:IsUnitAllowed(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.Unit.Config:Get(_Type, PlayerID);
    if Config then
        return Stronghold.Rights:GetRankRequiredForRight(PlayerID, Config.Right) > 0;
    end
    return false;
end

function Stronghold.Recruitment:GetLeaderCosts(_PlayerID, _Type, _SoldierAmount)
    local Costs = {};
    local Config = Stronghold.Unit.Config:Get(_Type, _PlayerID);
    if Config then
        _SoldierAmount = _SoldierAmount or Config.Soldiers;

        Costs = CopyTable(Config.Costs[1]);
        Costs = CreateCostTable(unpack(Costs));

        if _Type == Entities.PU_Serf then
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SlavePenny) == 1 then
                Costs[1] = math.floor((Costs[1] * self.Config.SlavePenny.CostsFactor) + 0.5);
            end
        end

        Costs = Stronghold.Hero:ApplyLeaderCostPassiveAbility(_PlayerID, _Type, Costs);
        if _SoldierAmount and _SoldierAmount > 0 then
            local SoldierCosts = self:GetSoldierCostsByLeaderType(_PlayerID, _Type, _SoldierAmount);
            Costs = MergeCostTable(Costs, SoldierCosts);
        end
    end
    return Costs;
end

function Stronghold.Recruitment:GetSoldierCostsByLeaderType(_PlayerID, _Type, _Amount)
    local Costs = {};
    local Config = Stronghold.Unit.Config:Get(_Type, _PlayerID);
    if Config then
        Costs = CopyTable(Config.Costs[2]);
        for i= 2, 7 do
            Costs[i] = Costs[i] * (_Amount or Config.Soldiers);
        end
        Costs = CreateCostTable(unpack(Costs));
        Costs = Stronghold.Hero:ApplySoldierCostPassiveAbility(_PlayerID, _Type, Costs);
    end
    return Costs;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Recruitment:BuyMilitaryUnitFromFoundryAction(_Type, _UpgradeCategory)
    local UnitToRecruit = {
        [Entities.PV_Cannon1] = {"Buy_Cannon1"},
        [Entities.PV_Cannon2] = {"Buy_Cannon2"},
        [Entities.PV_Cannon3] = {"Buy_Cannon3"},
        [Entities.PV_Cannon4] = {"Buy_Cannon4"},
    };
    return self:BuyMilitaryUnitFromRecruiterAction(UnitToRecruit, _Type);
end

function Stronghold.Recruitment:BuyMilitaryUnitFromTavernAction(_UpgradeCategory)
    local _,Type = Logic.GetSettlerTypesInUpgradeCategory(_UpgradeCategory);
    local UnitToRecruit = {
        [Entities.PU_Scout] = {"Buy_Scout"},
        [Entities.PU_Thief] = {"Buy_Thief"},
    };
    return self:BuyMilitaryUnitFromRecruiterAction(UnitToRecruit, Type);
end

function Stronghold.Recruitment:BuyMilitaryUnitFromRecruiterAction(_UnitToRecruit, _Type)
    local GuiPlayer = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local PlayerID = GUI.GetPlayerID();
    local AutoFillActive = Logic.IsAutoFillActive(EntityID) == 1;
    if PlayerID ~= GuiPlayer or not IsPlayer(PlayerID) then
        return false;
    end
    if Stronghold.Players[PlayerID].BuyUnitLock then
        return true;
    end
    if _UnitToRecruit[_Type] then
        -- If the building can have a worker than the worker must be at
        -- the building to recruit units.
        if Logic.GetBuildingWorkPlaceLimit(EntityID) > 0 then
            local Worker = {Logic.GetAttachedWorkersToBuilding(EntityID)};
            if not Worker[1] or (Worker[1] > 0 and Logic.IsSettlerAtWork(Worker[2]) == 0) then
                Sound.PlayQueuedFeedbackSound(Sounds.VoicesWorker_WORKER_FunnyNo_rnd_01, 100);
                Message(XGUIEng.GetStringTableText("sh_text/Player_NoWorker"));
                return true;
            end
        end

        local Button = _UnitToRecruit[_Type][1];
        if self.Data[PlayerID].Roster[Button] then
            local UnitType = self.Data[PlayerID].Roster[Button];
            local Config = Stronghold.Unit.Config:Get(UnitType, PlayerID);
            local Soldiers = (AutoFillActive and Config.Soldiers) or 0;
            local Modifier = XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1;

            local Places = Stronghold.Attraction:GetRequiredSpaceForUnitType(UnitType, Soldiers +1);
            if not Stronghold.Attraction:HasPlayerSpaceForUnits(PlayerID, Places) then
                if not Modifier then
                    Sound.PlayQueuedFeedbackSound(Sounds.VoicesLeader_LEADER_NO_rnd_01, 100);
                    Message(XGUIEng.GetStringTableText("sh_text/Player_MilitaryLimit"));
                    return true;
                end
            end
            local Costs = Stronghold.Recruitment:GetLeaderCosts(PlayerID, UnitType, Soldiers);
            if not Modifier then
                if InterfaceTool_HasPlayerEnoughResources_Feedback(Costs) == 0 then
                    return true;
                end
            end

            Stronghold.Players[PlayerID].BuyUnitLock = true;
            -- For cannons only pay the costs
            if string.find(Button, "Cannon") then
                GUI.BuyCannon(EntityID, _Type);
                XGUIEng.ShowWidget(gvGUI_WidgetID.CannonInProgress,1);
                Syncer.InvokeEvent(
                    self.NetworkCall,
                    self.SyncEvents.BuyCannon,
                    UnitType,
                    EntityID
                );
            -- For other units enqueue them in the queue
            else
                Syncer.InvokeEvent(
                    self.NetworkCall,
                    self.SyncEvents.EnqueueUnit,
                    EntityID,
                    UnitType,
                    false,
                    Button,
                    XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1
                );
            end
            return true;
        end
    end
end

-- -------------------------------------------------------------------------- --

function Stronghold.Recruitment:OnBarracksSettlerUpgradeTechnologyClicked(_Technology)
    local UnitToRecruit = {
        [Technologies.T_UpgradeSword1] = {"Research_UpgradeSword1"},
        [Technologies.T_UpgradeSword2] = {"Research_UpgradeSword2"},
        [Technologies.T_UpgradeSword3] = {"Research_UpgradeSword3"},
        [Technologies.T_UpgradeSpear1] = {"Research_UpgradeSpear1"},
        [Technologies.T_UpgradeSpear2] = {"Research_UpgradeSpear2"},
        [Technologies.T_UpgradeSpear3] = {"Research_UpgradeSpear3"},
    }
    return self:OnRecruiterSettlerUpgradeTechnologyClicked(UnitToRecruit, _Technology);
end

function Stronghold.Recruitment:OnArcherySettlerUpgradeTechnologyClicked(_Technology)
    local UnitToRecruit = {
        [Technologies.T_UpgradeBow1] = {"Research_UpgradeBow1"},
        [Technologies.T_UpgradeBow2] = {"Research_UpgradeBow2"},
        [Technologies.T_UpgradeBow3] = {"Research_UpgradeBow3"},
        [Technologies.T_UpgradeRifle1] = {"Research_UpgradeRifle1"},
    }
    return self:OnRecruiterSettlerUpgradeTechnologyClicked(UnitToRecruit, _Technology);
end

function Stronghold.Recruitment:OnStableSettlerUpgradeTechnologyClicked(_Technology)
    local UnitToRecruit = {
        [Technologies.T_UpgradeLightCavalry1] = {"Research_UpgradeCavalryLight1"},
        [Technologies.T_UpgradeHeavyCavalry1] = {"Research_UpgradeCavalryHeavy1"},
    }
    return self:OnRecruiterSettlerUpgradeTechnologyClicked(UnitToRecruit, _Technology);
end

function Stronghold.Recruitment:OnRecruiterSettlerUpgradeTechnologyClicked(_UnitToRecruit, _Technology)
    local GuiPlayer = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local PlayerID = GUI.GetPlayerID();
    local AutoFillActive = Logic.IsAutoFillActive(EntityID) == 1;
    if PlayerID ~= GuiPlayer or not IsPlayer(PlayerID) then
        return false;
    end
    if Stronghold.Players[PlayerID].BuyUnitLock then
        return true;
    end
    if _UnitToRecruit[_Technology] then
        local Button = _UnitToRecruit[_Technology][1];
        if self.Data[PlayerID].Roster[Button] then
            local UnitType = self.Data[PlayerID].Roster[Button];
            local Config = Stronghold.Unit.Config:Get(UnitType, PlayerID);
            local Soldiers = (AutoFillActive and Config.Soldiers) or 0;
            local Modifier = XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1;

            local Places = Stronghold.Attraction:GetRequiredSpaceForUnitType(UnitType, Soldiers +1);
            if not Stronghold.Attraction:HasPlayerSpaceForUnits(PlayerID, Places) then
                if not Modifier then
                    Sound.PlayQueuedFeedbackSound(Sounds.VoicesLeader_LEADER_NO_rnd_01, 100);
                    Message(XGUIEng.GetStringTableText("sh_text/Player_MilitaryLimit"));
                    return true;
                end
            end
            local Costs = Stronghold.Recruitment:GetLeaderCosts(PlayerID, UnitType, Soldiers);
            if not Modifier then
                if InterfaceTool_HasPlayerEnoughResources_Feedback(Costs) == 0 then
                    return true;
                end
            end
            Stronghold.Players[PlayerID].BuyUnitLock = true;
            Syncer.InvokeEvent(
                self.NetworkCall,
                self.SyncEvents.EnqueueUnit,
                EntityID,
                UnitType,
                AutoFillActive,
                Button,
                XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1
            );
            return true;
        end
    end
    return false;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Recruitment:OnBarracksSelected(_EntityID)
    local ButtonsToUpdate = {
        ["Research_UpgradeSword1"] = {4, 4, 31, 31},
        ["Research_UpgradeSword2"] = {38, 4, 31, 31},
        ["Research_UpgradeSword3"] = {72, 4, 31, 31},
        ["Research_UpgradeSpear1"] = {106, 4, 31, 31},
        ["Research_UpgradeSpear2"] = {140, 4, 31, 31},
        ["Research_UpgradeSpear3"] = {174, 4, 31, 31},
    };
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Barracks1 and Type ~= Entities.PB_Barracks2 then
        return;
    end
    XGUIEng.SetWidgetPositionAndSize("Research_BetterTrainingBarracks", 4, 38, 31, 31);
    XGUIEng.ShowWidget("Buy_LeaderSword", 0);
    XGUIEng.ShowWidget("Buy_LeaderSpear", 0);
    self:OnRecruiterSelected(ButtonsToUpdate, _EntityID);
end

function Stronghold.Recruitment:OnArcherySelected(_EntityID)
    local ButtonsToUpdate = {
        ["Research_UpgradeBow1"] = {4, 4, 31, 31},
        ["Research_UpgradeBow2"] = {38, 4, 31, 31},
        ["Research_UpgradeBow3"] = {72, 4, 31, 31},
        ["Research_UpgradeRifle1"] = {106, 4, 31, 31},
    };
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Archery1 and Type ~= Entities.PB_Archery2 then
        return;
    end
    XGUIEng.SetWidgetPositionAndSize("Research_BetterTrainingArchery", 4, 38, 31, 31);
    XGUIEng.ShowWidget("Buy_LeaderBow", 0);
    XGUIEng.ShowWidget("Buy_LeaderRifle", 0);
    self:OnRecruiterSelected(ButtonsToUpdate, _EntityID);
end

function Stronghold.Recruitment:OnStableSelected(_EntityID)
    local ButtonsToUpdate = {
        ["Research_UpgradeCavalryLight1"] = {4, 4, 31, 31},
        ["Research_UpgradeCavalryHeavy1"] = {38, 4, 31, 31},
    };
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Stable1 and Type ~= Entities.PB_Stable2 then
        return;
    end
    XGUIEng.SetWidgetPositionAndSize("Research_Shoeing", 4, 38, 31, 31);
    XGUIEng.ShowWidget("Buy_LeaderCavalryLight", 0);
    XGUIEng.ShowWidget("Buy_LeaderCavalryHeavy", 0);
    self:OnRecruiterSelected(ButtonsToUpdate, _EntityID);
end

function Stronghold.Recruitment:OnFoundrySelected(_EntityID)
    local ButtonsToUpdate = {
        ["Buy_Cannon1"] = {4, 4, 31, 31},
        ["Buy_Cannon2"] = {38, 4, 31, 31},
        ["Buy_Cannon3"] = {72, 4, 31, 31},
        ["Buy_Cannon4"] = {106, 4, 31, 31},
    };
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Foundry1 and Type ~= Entities.PB_Foundry2 then
        return;
    end
    XGUIEng.SetWidgetPositionAndSize("Research_BetterChassis", 38, 38, 31, 31);
    XGUIEng.SetWidgetPositionAndSize("Research_AutoRepair", 4, 38, 31, 31);
    self:OnRecruiterSelected(ButtonsToUpdate, _EntityID);
end

function Stronghold.Recruitment:OnTavernSelected(_EntityID)
    local ButtonsToUpdate = {
        ["Buy_Scout"] = {4, 4, 31, 31},
        ["Buy_Thief"] = {38, 4, 31, 31},
    };
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Tavern1 and Type ~= Entities.PB_Tavern2 then
        return;
    end
    XGUIEng.ShowWidget("Buy_Scout_Recharge", 1);
    XGUIEng.ShowWidget("Buy_Scout_Amount", 1);
    XGUIEng.ShowWidget("Buy_Thief_Recharge", 1);
    XGUIEng.ShowWidget("Buy_Thief_Amount", 1);
    self:OnRecruiterSelected(ButtonsToUpdate, _EntityID);
end

function Stronghold.Recruitment:OnRecruiterSelected(_ButtonsToUpdate, _EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if not IsPlayer(PlayerID) then
        return;
    end
    for k, v in pairs(_ButtonsToUpdate) do
        XGUIEng.ShowWidget(k.. "_Recharge", 1);
        XGUIEng.ShowWidget(k.. "_Amount", 1);
        XGUIEng.ShowWidget(k, 0);
        if self.Data[PlayerID].Roster[k] then
            local UnitType = self.Data[PlayerID].Roster[k];
            local Config = Stronghold.Unit.Config:Get(UnitType, PlayerID);
            XGUIEng.TransferMaterials(Config.Button, k);
            XGUIEng.SetWidgetPositionAndSize(k.. "_Recharge", v[1], v[2], v[3], v[4]);
            XGUIEng.SetWidgetPositionAndSize(k.. "_Amount", v[1], v[2], v[3], v[4]);
            XGUIEng.SetWidgetPositionAndSize(k, v[1], v[2], v[3], v[4]);
            XGUIEng.ShowWidget(k, 1);

            local Disabled = 1;
            if  self:IsUnitAllowed(_EntityID, UnitType)
            and self:HasSufficientRecruiterBuilding(_EntityID, UnitType)
            and self:HasSufficientProviderBuilding(_EntityID, UnitType)
            and self:HasSufficientRank(_EntityID, UnitType) then
                Disabled = 0;
            end
            XGUIEng.DisableButton(k, Disabled);
        end
    end
end

-- -------------------------------------------------------------------------- --

function Stronghold.Recruitment:UpdateFoundryBuyUnitTooltip(_PlayerID, _UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut)
    local TextToPrint = {
        [UpgradeCategories.Cannon1] = {"Buy_Cannon1"},
        [UpgradeCategories.Cannon2] = {"Buy_Cannon2"},
        [UpgradeCategories.Cannon3] = {"Buy_Cannon3"},
        [UpgradeCategories.Cannon4] = {"Buy_Cannon4"},
    };
    return self:UpdateRecruiterBuyUnitTooltip(TextToPrint, _PlayerID, _UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut);
end

function Stronghold.Recruitment:UpdateTavernBuyUnitTooltip(_PlayerID, _UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut)
    local TextToPrint = {
        [UpgradeCategories.Scout] = {"Buy_Scout"},
        [UpgradeCategories.Thief] = {"Buy_Thief"},
    };
    return self:UpdateRecruiterBuyUnitTooltip(TextToPrint, _PlayerID, _UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut);
end

function Stronghold.Recruitment:UpdateRecruiterBuyUnitTooltip(_TextToPrint, _PlayerID, _UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut)
    local WidgetID = XGUIEng.GetCurrentWidgetID();
    local EntityID = GUI.GetSelectedEntity();
    local Text = "";
    local CostsText = "";

    if _TextToPrint[_UpgradeCategory] then
        local UnitType = self.Data[_PlayerID].Roster[_TextToPrint[_UpgradeCategory][1]];
        local TypeName = Logic.GetEntityTypeName(UnitType);
        local Config = Stronghold.Unit.Config:Get(UnitType, _PlayerID);
        if not self:IsUnitAllowed(EntityID, UnitType) then
            Text = XGUIEng.GetStringTableText("MenuGeneric/UnitNotAvailable");
        else
            local Soldiers = (Logic.IsAutoFillActive(EntityID) == 1 and Config.Soldiers) or 0;
            local Costs = Stronghold.Recruitment:GetLeaderCosts(_PlayerID, UnitType, Soldiers);
            CostsText = FormatCostString(_PlayerID, Costs);
            local Name = " @color:180,180,180,255 " ..XGUIEng.GetStringTableText("names/".. TypeName);
            Text = Name.. " @cr " ..XGUIEng.GetStringTableText("sh_description/Unit_" ..TypeName.. "_normal");
            if XGUIEng.IsButtonDisabled(WidgetID) == 1 then
                local DisabledText = XGUIEng.GetStringTableText("sh_description/Unit_" ..TypeName.. "_disabled");
                local Rank = Stronghold.Rights:GetRankRequiredForRight(_PlayerID, Config.Right);
                local RankName = GetRankName(Rank, _PlayerID);
                DisabledText = string.gsub(DisabledText, "#Rank#", RankName);
                Text = Text.. " @cr " ..DisabledText;
            end
        end
    else
        return false;
    end

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180,255 " .. Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostsText);
    return true;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Recruitment:UpdateUpgradeSettlersBarracksTooltip(_PlayerID, _Technology, _TextKey, _ShortCut)
    local TextToPrint = {
        ["sh_menubarracks/UpgradeSword1"] = {"Research_UpgradeSword1", " [A]"},
        ["sh_menubarracks/UpgradeSword2"] = {"Research_UpgradeSword2", " [S]"},
        ["sh_menubarracks/UpgradeSword3"] = {"Research_UpgradeSword3", " [D]"},
        ["sh_menubarracks/UpgradeSpear1"] = {"Research_UpgradeSpear1", " [F]"},
        ["sh_menubarracks/UpgradeSpear2"] = {"Research_UpgradeSpear2", " [G]"},
        ["sh_menubarracks/UpgradeSpear3"] = {"Research_UpgradeSpear3", " [H]"},
    };
    return self:UpdateUpgradeSettlersRecruiterTooltip(TextToPrint, _PlayerID, _Technology, _TextKey, _ShortCut);
end

function Stronghold.Recruitment:UpdateUpgradeSettlersArcheryTooltip(_PlayerID, _Technology, _TextKey, _ShortCut)
    local TextToPrint = {
        ["sh_menuarchery/UpgradeBow1"] = {"Research_UpgradeBow1", " [A]"},
        ["sh_menuarchery/UpgradeBow2"] = {"Research_UpgradeBow2", " [S]"},
        ["sh_menuarchery/UpgradeBow3"] = {"Research_UpgradeBow3", " [D]"},
        ["sh_menuarchery/UpgradeRifle1"] = {"Research_UpgradeRifle1", " [F]"},
    };
    return self:UpdateUpgradeSettlersRecruiterTooltip(TextToPrint, _PlayerID, _Technology, _TextKey, _ShortCut);
end

function Stronghold.Recruitment:UpdateUpgradeSettlersStableTooltip(_PlayerID, _Technology, _TextKey, _ShortCut)
    local TextToPrint = {
        ["sh_menustable/UpgradeCavalryLight1"] = {"Research_UpgradeCavalryLight1", " [A]"},
        ["sh_menustable/UpgradeCavalryHeavy1"] = {"Research_UpgradeCavalryHeavy1", " [S]"},
    };
    return self:UpdateUpgradeSettlersRecruiterTooltip(TextToPrint, _PlayerID, _Technology, _TextKey, _ShortCut);
end

function Stronghold.Recruitment:UpdateUpgradeSettlersRecruiterTooltip(_TextToPrint, _PlayerID, _Technology, _TextKey, _ShortCut)
    local WidgetID = XGUIEng.GetCurrentWidgetID();
    local EntityID = GUI.GetSelectedEntity();
    local Text = "";
    local ShortcutText = "";
    local CostsText = "";

    if _TextToPrint[_TextKey] then
        local UnitType = self.Data[_PlayerID].Roster[_TextToPrint[_TextKey][1]];
        local TypeName = Logic.GetEntityTypeName(UnitType);
        local Config = Stronghold.Unit.Config:Get(UnitType, _PlayerID);
        if not self:IsUnitAllowed(EntityID, UnitType) then
            Text = XGUIEng.GetStringTableText("MenuGeneric/UnitNotAvailable");
        else
            ShortcutText = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. _TextToPrint[_TextKey][2];
            local Soldiers = (Logic.IsAutoFillActive(EntityID) == 1 and Config.Soldiers) or 0;
            local Costs = Stronghold.Recruitment:GetLeaderCosts(_PlayerID, UnitType, Soldiers);
            CostsText = FormatCostString(_PlayerID, Costs);
            local Name = " @color:180,180,180,255 " ..XGUIEng.GetStringTableText("names/".. TypeName);
            Text = Name.. " @cr " ..XGUIEng.GetStringTableText("sh_description/Unit_" ..TypeName.. "_normal");
            if XGUIEng.IsButtonDisabled(WidgetID) == 1 then
                local DisabledText = XGUIEng.GetStringTableText("sh_description/Unit_" ..TypeName.. "_disabled");
                local RankName = GetRankName(GetRankRequired(_PlayerID, Config.Right), _PlayerID);
                DisabledText = string.gsub(DisabledText, "#Rank#", RankName);
                Text = Text .. " @cr " ..DisabledText;
            end
        end
    else
        return false;
    end

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostsText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortcutText);
    return true;
end

-- -------------------------------------------------------------------------- --
-- Production queues

function Stronghold.Recruitment:ProduceUnitFromQueue(_PlayerID, _Queue, _ScriptName)
    if  self.Data[_PlayerID]
    and self.Data[_PlayerID].Queues[_Queue]
    and self.Data[_PlayerID].Queues[_Queue][_ScriptName] then
        local Data = table.remove(self.Data[_PlayerID].Queues[_Queue][_ScriptName], 1);
        if Data then
            -- Check existing
            if not IsExisting(_ScriptName) then
                return;
            end
            -- Get initial experience
            local Experience = 0;
            if PlayerHasLordOfType(_PlayerID, Entities.PU_Hero4) then
                Experience = Stronghold.Hero.Config.Hero4.TrainExperience;
            end
            -- Create entity
            local Orientation = Logic.GetEntityOrientation(GetID(_ScriptName));
            local Position = Stronghold.Unit:GetBarracksDoorPosition(GetID(_ScriptName));
            local ID = AI.Entity_CreateFormation(
                _PlayerID,
                Data.Type,
                0,
                Data.Soldiers,
                Position.X,
                Position.Y,
                0,
                0,
                Experience,
                Data.Soldiers
            );
            Logic.RotateEntity(ID, Orientation +180);
            -- Change formation
            Stronghold.Unit:SetFormationOnCreate(ID);
            -- Move to rally point
            Stronghold.Building:MoveToRallyPoint(_ScriptName, ID);
        end
    end
end

function Stronghold.Recruitment:CanProduceUnitFromQueue(_PlayerID, _Queue, _ScriptName)
    if  self.Data[_PlayerID]
    and self.Data[_PlayerID].Queues[_Queue]
    and self.Data[_PlayerID].Queues[_Queue][_ScriptName] then
        local Data = self:GetFirstEntryFromQueue(_PlayerID, _Queue, _ScriptName);
        if Data then
            local Places = Data.Places + (Data.Places * Data.Soldiers);
            local Config = Stronghold.Unit.Config:Get(Data.Type, _PlayerID);
            if Config then
                local AttractionLimit = GetMilitaryAttractionLimit(_PlayerID);
                local AttractionUsage = GetMilitaryAttractionUsage(_PlayerID);
                if Config.IsCivil then
                    AttractionLimit = GetCivilAttractionLimit(_PlayerID);
                    AttractionUsage = GetCivilAttractionUsage(_PlayerID);
                end
                return AttractionUsage + Places <= AttractionLimit;
            end
        end
    end
    return false;
end

function Stronghold.Recruitment:OrderUnit(_PlayerID, _Queue, _Type, _BarracksID, _AutoFill)
    if not IsExisting(_BarracksID) then
        Stronghold.Players[_PlayerID].BuyUnitLock = nil;
        return;
    end
    if IsPlayer(_PlayerID) then
        local Config = Stronghold.Unit.Config:Get(_Type, _PlayerID);
        if Config then
            local ScriptName = Logic.GetEntityName(_BarracksID);
            local Soldiers = (_AutoFill and Config.Soldiers) or 0;
            local CostsSoldier = self:GetSoldierCostsByLeaderType(_PlayerID, _Type, Soldiers);
            local CostsLeader = self:GetLeaderCosts(_PlayerID, _Type, 0);
            local Places = Config.Places or Stronghold.Attraction:GetRequiredSpaceForUnitType(_Type);
            local Turns = Stronghold.Hero:ApplyRecruitTimePassiveAbility(_PlayerID, _Type, Config.Turns);
            if _Type == Entities.PU_Serf then
                if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SlavePenny) == 1 then
                    Turns = math.floor((Turns * self.Config.SlavePenny.TimeFactor) + 0.5);
                end
            end

            local CostsMerged = CopyTable(CostsLeader);
            CostsMerged = MergeCostTable(CostsMerged, CostsSoldier);
            if HasEnoughResources(_PlayerID, CostsMerged) then
                self:CreateNewQueueEntry(
                    _PlayerID, _Queue, ScriptName, math.floor(Turns + 0.5), _Type,
                    Soldiers, Config.IsCivil, Places, CostsLeader, CostsSoldier
                );
                self:SubResourcesForUnit(_PlayerID, CostsLeader, CostsSoldier);
            end
        end
        Stronghold.Players[_PlayerID].BuyUnitLock = nil;
    end
end

function Stronghold.Recruitment:SubResourcesForUnit(_PlayerID, _CostsLeader, _CostsSoldier)
    local CostsFull = _CostsLeader;
    for k,v in pairs(_CostsSoldier) do
        CostsFull[k] = (CostsFull[k] or 0) + (v or 0);
    end
    RemoveResourcesFromPlayer(_PlayerID, CostsFull);
end

function Stronghold.Recruitment:RefundUnit(_PlayerID, _CostsLeader, _CostsSoldier)
    local CostsFull = CopyTable(_CostsLeader);
    -- FIXME: For some reason I can not find, the soldier costs are already
    -- added to the leader costs.
    -- for k,v in pairs(_CostsSoldier) do
    --     CostsFull[k] = (CostsFull[k] or 0) + (v or 0);
    -- end
    AddResourcesToPlayer(_PlayerID, CostsFull);
end

function Stronghold.Recruitment:CreateNewQueueEntry(
    _PlayerID, _Queue, _ScriptName, _Time, _Type, _Soldiers, _Civil, _Places,
    _CostsLeader, _CostsSoldier, _Experience
)
    if  self.Data[_PlayerID]
    and self.Data[_PlayerID].Queues[_Queue]
    and self.Data[_PlayerID].Queues[_Queue][_ScriptName] then
        table.insert(self.Data[_PlayerID].Queues[_Queue][_ScriptName], {
            Progress = 0,
            Limit = _Time,
            IsCivil = _Civil == true,
            Type = _Type,
            Experience = _Experience,
            Soldiers = _Soldiers,
            Places = _Places,
            Costs = {
                [1] = _CostsLeader,
                [2] = _CostsSoldier,
            }
        });
    end
end

function Stronghold.Recruitment:GetSizeOfQueue(_PlayerID, _Queue, _ScriptName)
    if  self.Data[_PlayerID]
    and self.Data[_PlayerID].Queues[_Queue]
    and self.Data[_PlayerID].Queues[_Queue][_ScriptName] then
        return table.getn(self.Data[_PlayerID].Queues[_Queue][_ScriptName]);
    end
    return 0;
end

function Stronghold.Recruitment:GetFirstEntryFromQueue(_PlayerID, _Queue, _ScriptName)
    if  self.Data[_PlayerID]
    and self.Data[_PlayerID].Queues[_Queue]
    and self.Data[_PlayerID].Queues[_Queue][_ScriptName] then
        return self.Data[_PlayerID].Queues[_Queue][_ScriptName][1];
    end
end

function Stronghold.Recruitment:AbortLatestQueueEntry(_PlayerID, _Queue, _ScriptName)
    if  self.Data[_PlayerID] then
        -- Remove lock
        Stronghold.Players[_PlayerID].BuyUnitLock = nil;
        -- Refund unit
        if  self.Data[_PlayerID].Queues[_Queue]
        and self.Data[_PlayerID].Queues[_Queue][_ScriptName] then
            local Entry = table.remove(self.Data[_PlayerID].Queues[_Queue][_ScriptName]);
            if Entry then
                self:RefundUnit(_PlayerID, Entry.Costs[1], Entry.Costs[2]);
            end
        end
    end
end

-- Runs the queue and executes unit creation after completion.
function Stronghold.Recruitment:ControlProductionQueues(_PlayerID)
    if self.Data[_PlayerID] then
        for ButtonName,_ in pairs(self.Data[_PlayerID].Queues) do
            for ScriptName, Queue in pairs(self.Data[_PlayerID].Queues[ButtonName]) do
                if not IsExisting(ScriptName) then
                    self.Data[_PlayerID].Queues[ButtonName][ScriptName] = nil;
                else
                    if Queue[1] then
                        if Queue[1].Progress >= Queue[1].Limit then
                            if self:CanProduceUnitFromQueue(_PlayerID, ButtonName, ScriptName) then
                                self:ProduceUnitFromQueue(_PlayerID, ButtonName, ScriptName);
                            else
                                -- Only for cosmetics
                                local Progress = math.floor(Queue[1].Progress * 0.85);
                                self.Data[_PlayerID].Queues[ButtonName][ScriptName][1].Progress = Progress;
                            end
                        else
                            local Health = Logic.GetEntityHealth(GetID(ScriptName));
                            local MaxHealth = Logic.GetEntityMaxHealth(GetID(ScriptName));
                            if Health / MaxHealth >= 0.2 then
                                self.Data[_PlayerID].Queues[ButtonName][ScriptName][1].Progress = Queue[1].Progress + 1;
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Initalizes all queues for the entity if not existing.
function Stronghold.Recruitment:InitQueuesForProducer(_EntityID)
    if not IsExisting(_EntityID) then
        return;
    end
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if self.Data[PlayerID] then
        if self.Config.QueueMapping[Type] then
            local ScriptName = CreateNameForEntity(_EntityID);
            for k,v in pairs(self.Config.QueueMapping[Type]) do
                if not self.Data[PlayerID].Queues[v][ScriptName] then
                    self.Data[PlayerID].Queues[v][ScriptName] = {};
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Cannon Spam

-- Registers a foundry for checking the forging process.
function Stronghold.Recruitment:RegisterCannonOrder(_PlayerID, _BarracksID, _Type)
    if self.Data[_PlayerID] then
        self.Data[_PlayerID].ForgeRegister[_BarracksID] = _Type;
    end
end

-- Checks the forging process in all registered foundries.
function Stronghold.Recruitment:ControlCannonProducers(_PlayerID)
    if self.Data[_PlayerID] then
        for k,v in pairs(self.Data[_PlayerID].ForgeRegister) do
            if not IsExisting(k) or Logic.GetCannonProgress(k) == 100 then
                self.Data[_PlayerID].ForgeRegister[k] = nil;
            end
        end
    end
end

-- Returns the places occupied by cannons currently in production.
function Stronghold.Recruitment:GetOccupiedSpacesFromCannonsInProgress(_PlayerID)
    local Places = 0;
    if self.Data[_PlayerID] then
        for k,v in pairs(self.Data[_PlayerID].ForgeRegister) do
            local Size = Stronghold.Attraction:GetRequiredSpaceForUnitType(v, 1);
            -- Salim passive skill
            if Stronghold.Hero:HasValidLordOfType(_PlayerID, Entities.PU_Hero3) then
                Size = math.floor((Size * Stronghold.Hero.Config.Hero3.UnitPlaceFactor) + 0.5);
            end
            Places = Places + Size;
        end
    end
    return Places;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Recruitment:OverrideLogic()
    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MilitaryAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        local CannonPlaces = Stronghold.Recruitment:GetOccupiedSpacesFromCannonsInProgress(_PlayerID);
        return CurrentAmount + CannonPlaces;
    end);
end

-- Updates the queue progress.
-- (This must be directly in the script because - somehow - nil after a save
-- is loaded - and we don't want that!).
GUIUpdate_BuildingButtons_Recharge = function(_Button, _Technology)
    local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
    local EntityID = GUI.GetSelectedEntity();
    local ScriptName = Logic.GetEntityName(EntityID);
    local PlayerID = GetLocalPlayerID();

    if not Stronghold.Recruitment.Data[PlayerID] then
        XGUIEng.SetMaterialColor(CurrentWidgetID,1,0,0,0,0);
        return;
    end

    local QueueSize = Stronghold.Recruitment:GetSizeOfQueue(PlayerID, _Button, ScriptName);
    local FirstEntry = Stronghold.Recruitment:GetFirstEntryFromQueue(PlayerID, _Button, ScriptName);
    if QueueSize == 0 or not FirstEntry then
        XGUIEng.SetMaterialColor(CurrentWidgetID,1,0,0,0,0);
        XGUIEng.SetText(_Button.. "_Amount", "");
        return;
    end

    local Color = {26, 115, 16, 190};
    if not Stronghold.Recruitment:CanProduceUnitFromQueue(PlayerID, _Button, ScriptName) then
        Color = {214, 44, 24, 190};
    end
    local TimeCharged = FirstEntry.Progress;
    local RechargeTime = FirstEntry.Limit;
    XGUIEng.SetMaterialColor(CurrentWidgetID, 1, unpack(Color));
    XGUIEng.SetProgressBarValues(CurrentWidgetID, TimeCharged, RechargeTime);
    XGUIEng.SetTextByValue(_Button.. "_Amount", QueueSize);
end

