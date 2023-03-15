--- 
--- Recruitment Script
--- 

Stronghold = Stronghold or {};

Stronghold.Recruitment = Stronghold.Recruitment or {
    SyncEvents = {},
    Data = {},
    Config = {
        UI = {
            MilitaryLimit = {
                de = "Euere Heeresstärke ist an ihrem Limit, Hochwohlgeboren!",
                en = "Your army strength is at its limit, Your Highness!",
            },
        }
    },
};

function Stronghold.Recruitment:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {
            Config = CopyTable(Stronghold.UnitConfig.Units),
            Roster = {}
        };
        self:InitDefaultRoster(i);
    end
    self:CreateBuildingButtonHandlers();
    self:OverrideGUI();
end

function Stronghold.Recruitment:OnSaveGameLoaded()
end

function Stronghold.Recruitment:CreateBuildingButtonHandlers()
    self.SyncEvents = {
        BuyUnit = 1,
    };
    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Recruitment.SyncEvents.BuyUnit then
                Stronghold.Unit:BuyUnit(_PlayerID, arg[2], arg[1], arg[3]);
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

function Stronghold.Recruitment:IsSufficientRecruiterBuilding(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.UnitConfig:GetConfig(_Type, PlayerID);
    if Config then
        local BuildingType = Logic.GetEntityType(_BuildingID);
        return IsInTable(BuildingType, Config.RecruiterBuilding);
    end
    return false;
end

function Stronghold.Recruitment:HasSufficientProviderBuilding(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.UnitConfig:GetConfig(_Type, PlayerID);
    if Config then
        local Providers = table.getn(Config.ProviderBuilding);
        if Providers == 0 then
            return true;
        end
        for i= 1, Providers do
            local BuildingType = Config.ProviderBuilding[i];
            local Buildings = GetValidEntitiesOfType(PlayerID, BuildingType);
            if table.getn(Buildings) > 0 then
                return true;
            end
        end
    end
    return false;
end

function Stronghold.Recruitment:HasSufficientRank(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.UnitConfig:GetConfig(_Type, PlayerID);
    if Config then
        if GetPlayerRank(PlayerID) >= Config.Rank then
            return true;
        end
    end
    return false;
end

function Stronghold.Recruitment:IsUnitAllowed(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.UnitConfig:GetConfig(_Type, PlayerID);
    if Config then
        return Config.Allowed == true;
    end
    return false;
end

function Stronghold.Recruitment:GetLeaderCosts(_PlayerID, _Type, _SoldierAmount)
    local Costs = {};
    local Config = Stronghold.UnitConfig:GetConfig(_Type, _PlayerID);
    if Config then
        Costs = CopyTable(Config.Costs[1]);
        Costs = CreateCostTable(unpack(Costs));
        Costs = Stronghold.Hero:ApplyUnitCostPassiveAbility(_PlayerID, _Type, Costs);
        if _SoldierAmount and _SoldierAmount > 0 then
            local SoldierCosts = self:GetSoldierCostsByLeaderType(_PlayerID, _Type, _SoldierAmount);
            Costs = MergeCostTable(Costs, SoldierCosts);
        end
    end
    return Costs;
end

function Stronghold.Recruitment:GetSoldierCostsByLeaderType(_PlayerID, _Type, _Amount)
    local Costs = {};
    local Config = Stronghold.UnitConfig:GetConfig(_Type, _PlayerID);
    if Config then
        Costs = CopyTable(Config.Costs[2]);
        for i= 2, 7 do
            Costs[i] = Costs[i] * _Amount;
        end
        Costs = CreateCostTable(unpack(Costs));
        Costs = Stronghold.Hero:ApplyUnitCostPassiveAbility(_PlayerID, _Type, Costs);
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
    local Language = GetLanguage();
    local GuiPlayer = Stronghold:GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local PlayerID = GUI.GetPlayerID();
    local AutoFillActive = Logic.IsAutoFillActive(EntityID) == 1;
    if PlayerID ~= GuiPlayer or not Stronghold:IsPlayer(PlayerID) then
        return false;
    end
    if Stronghold.Players[PlayerID].BuyUnitLock then
        return true;
    end
    if _UnitToRecruit[_Type] then
        local Button = _UnitToRecruit[_Type][1];
        if self.Data[PlayerID].Roster[Button] then
            local UnitType = self.Data[PlayerID].Roster[Button];
            local Config = Stronghold.UnitConfig:GetConfig(UnitType, PlayerID);
            local Soldiers = (AutoFillActive and Config.Soldiers) or 0;

            local Places = Stronghold.Attraction:GetMilitarySpaceForUnitType(UnitType, Soldiers +1);
            if not Stronghold.Attraction:HasPlayerSpaceForUnits(PlayerID, Places) then
                Sound.PlayQueuedFeedbackSound(Sounds.VoicesLeader_LEADER_NO_rnd_01, 127);
                Message(self.Config.UI.MilitaryLimit[Language]);
                return true;
            end
            local Costs = Stronghold.Recruitment:GetLeaderCosts(PlayerID, UnitType, Soldiers);
            Costs = Stronghold.Hero:ApplyUnitCostPassiveAbility(PlayerID, UnitType, Costs);
            if HasPlayerEnoughResourcesFeedback(Costs) then
                Stronghold.Players[PlayerID].BuyUnitLock = true;
                if string.find(Button, "Cannon") then
                    GUI.BuyCannon(EntityID, _Type);
		            XGUIEng.ShowWidget(gvGUI_WidgetID.CannonInProgress,1);
                end
                Syncer.InvokeEvent(
                    self.NetworkCall,
                    self.SyncEvents.BuyUnit, EntityID, UnitType, false
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
    local Language = GetLanguage();
    local GuiPlayer = Stronghold:GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local PlayerID = GUI.GetPlayerID();
    local AutoFillActive = Logic.IsAutoFillActive(EntityID) == 1;
    if PlayerID ~= GuiPlayer or not Stronghold:IsPlayer(PlayerID) then
        return false;
    end
    if Stronghold.Players[PlayerID].BuyUnitLock then
        return true;
    end
    if _UnitToRecruit[_Technology] then
        local Button = _UnitToRecruit[_Technology][1];
        if self.Data[PlayerID].Roster[Button] then
            local UnitType = self.Data[PlayerID].Roster[Button];
            local Config = Stronghold.UnitConfig:GetConfig(UnitType, PlayerID);
            local Soldiers = (AutoFillActive and Config.Soldiers) or 0;

            local Places = Stronghold.Attraction:GetMilitarySpaceForUnitType(UnitType, Soldiers +1);
            if not Stronghold.Attraction:HasPlayerSpaceForUnits(PlayerID, Places) then
                Sound.PlayQueuedFeedbackSound(Sounds.VoicesLeader_LEADER_NO_rnd_01, 127);
                Message(self.Config.UI.MilitaryLimit[Language]);
                return true;
            end
            local Costs = Stronghold.Recruitment:GetLeaderCosts(PlayerID, UnitType, Soldiers);
            Costs = Stronghold.Hero:ApplyUnitCostPassiveAbility(PlayerID, UnitType, Costs);
            if HasPlayerEnoughResourcesFeedback(Costs) then
                Stronghold.Players[PlayerID].BuyUnitLock = true;
                Syncer.InvokeEvent(
                    self.NetworkCall,
                    self.SyncEvents.BuyUnit, EntityID, UnitType, AutoFillActive
                );
            end
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
    self:OnRecruiterSelected(ButtonsToUpdate, _EntityID);
end

function Stronghold.Recruitment:OnRecruiterSelected(_ButtonsToUpdate, _EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if not Stronghold:IsPlayer(PlayerID) then
        return;
    end
    for k, v in pairs(_ButtonsToUpdate) do
        XGUIEng.ShowWidget(k, 0);
        if self.Data[PlayerID].Roster[k] then
            local UnitType = self.Data[PlayerID].Roster[k];
            local Config = Stronghold.UnitConfig:GetConfig(UnitType, PlayerID);
            XGUIEng.TransferMaterials(Config.Button, k);
            XGUIEng.SetWidgetPositionAndSize(k, v[1], v[2], v[3], v[4]);
            XGUIEng.ShowWidget(k, 1);

            local Disabled = 1;
            if  self:IsSufficientRecruiterBuilding(_EntityID, UnitType)
            and self:HasSufficientProviderBuilding(_EntityID, UnitType)
            and self:HasSufficientRank(_EntityID, UnitType)
            and self:IsUnitAllowed(_EntityID, UnitType) then
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
        local Config = Stronghold.UnitConfig:GetConfig(UnitType, _PlayerID);
        if not Config.Allowed then
            Text = XGUIEng.GetStringTableText("MenuGeneric/UnitNotAvailable");
        else
            local Soldiers = (Logic.IsAutoFillActive(EntityID) == 1 and Config.Soldiers) or 0;
            local Costs = Stronghold.Recruitment:GetLeaderCosts(_PlayerID, UnitType, Soldiers);
            CostsText = Stronghold:FormatCostString(_PlayerID, Costs);
            Text = Placeholder.Replace(Config.TextNormal[GetLanguage()]);
            if XGUIEng.IsButtonDisabled(WidgetID) == 1 then
                local DisabledText = Placeholder.Replace(Config.TextDisabled[GetLanguage()]);
                local RankName = Stronghold:GetPlayerRankName(_PlayerID, Config.Rank);
                DisabledText = string.gsub(DisabledText, "#Rank#", RankName);
                Text = Text .. DisabledText;
            end
        end
    else
        return false;
    end

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostsText);
    return true;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Recruitment:UpdateUpgradeSettlersBarracksTooltip(_PlayerID, _Technology, _TextKey, _ShortCut)
    local TextToPrint = {
        ["MenuBarracks/UpgradeSword1"] = {"Research_UpgradeSword1", " [A]"},
        ["MenuBarracks/UpgradeSword2"] = {"Research_UpgradeSword2", " [S]"},
        ["MenuBarracks/UpgradeSword3"] = {"Research_UpgradeSword3", " [D]"},
        ["MenuBarracks/UpgradeSpear1"] = {"Research_UpgradeSpear1", " [F]"},
        ["MenuBarracks/UpgradeSpear2"] = {"Research_UpgradeSpear2", " [G]"},
        ["MenuBarracks/UpgradeSpear3"] = {"Research_UpgradeSpear3", " [H]"},
    };
    return self:UpdateUpgradeSettlersRecruiterTooltip(TextToPrint, _PlayerID, _Technology, _TextKey, _ShortCut);
end

function Stronghold.Recruitment:UpdateUpgradeSettlersArcheryTooltip(_PlayerID, _Technology, _TextKey, _ShortCut)
    local TextToPrint = {
        ["MenuArchery/UpgradeBow1"] = {"Research_UpgradeBow1", " [A]"},
        ["MenuArchery/UpgradeBow2"] = {"Research_UpgradeBow2", " [S]"},
        ["MenuArchery/UpgradeBow3"] = {"Research_UpgradeBow3", " [D]"},
        ["AOMenuArchery/UpgradeRifle1"] = {"Research_UpgradeRifle1", " [F]"},
    };
    return self:UpdateUpgradeSettlersRecruiterTooltip(TextToPrint, _PlayerID, _Technology, _TextKey, _ShortCut);
end

function Stronghold.Recruitment:UpdateUpgradeSettlersStableTooltip(_PlayerID, _Technology, _TextKey, _ShortCut)
    local TextToPrint = {
        ["MenuStables/UpgradeCavalryLight1"] = {"Research_UpgradeCavalryLight1", " [A]"},
        ["MenuStables/UpgradeCavalryHeavy1"] = {"Research_UpgradeCavalryHeavy1", " [S]"},
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
        local Config = Stronghold.UnitConfig:GetConfig(UnitType, _PlayerID);
        if not Config.Allowed then
            Text = XGUIEng.GetStringTableText("MenuGeneric/UnitNotAvailable");
        else
            ShortcutText = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. _TextToPrint[_TextKey][2];
            local Soldiers = (Logic.IsAutoFillActive(EntityID) == 1 and Config.Soldiers) or 0;
            local Costs = Stronghold.Recruitment:GetLeaderCosts(_PlayerID, UnitType, Soldiers);
            CostsText = Stronghold:FormatCostString(_PlayerID, Costs);
            Text = Placeholder.Replace(Config.TextNormal[GetLanguage()]);
            if XGUIEng.IsButtonDisabled(WidgetID) == 1 then
                local DisabledText = Placeholder.Replace(Config.TextDisabled[GetLanguage()]);
                local RankName = Stronghold:GetPlayerRankName(_PlayerID, Config.Rank);
                DisabledText = string.gsub(DisabledText, "#Rank#", RankName);
                Text = Text .. DisabledText;
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

function Stronghold.Recruitment:OverrideGUI()
    GUIUpdate_BuildingButtons_Recharge = function(_Button, _Technology)
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()

        local TimeLeft = 50;
        local RechargeTime = 100;
        if TimeLeft == RechargeTime then		
            XGUIEng.SetMaterialColor(CurrentWidgetID,1,0,0,0,0)
            XGUIEng.DisableButton(_Button, 0)
        end
        if TimeLeft < RechargeTime then
            XGUIEng.SetMaterialColor(CurrentWidgetID,1,214,44,24,189)
            XGUIEng.DisableButton(_Button, 1)
        end
        XGUIEng.SetProgressBarValues(CurrentWidgetID, TimeLeft, RechargeTime);
    end
end

