--- 
--- Mercenary Script
--- 

Stronghold = Stronghold or {};

Stronghold.Mercenary = Stronghold.Mercenary or {
    SyncEvents = {},
    Data = {
        BoughtMercenaries = {}
    },
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- API

--- Adds to the current contingent of hireable mercenaries.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type
--- @param _Amount integer Amount to increase
function AddToMercenaryContingent(_PlayerID, _Type, _Amount)
    Stronghold.Mercenary:AddToMercenaryContingent(_PlayerID, _Type, _Amount);
end

--- Returns the current amount of hireable mercenaries.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type
--- @return integer
function GetMercenaryContingent(_PlayerID, _Type)
    return Stronghold.Mercenary:GetMercenaryContingent(_PlayerID, _Type);
end

--- Returns the current maximum of hirable mercenaries.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type
--- @return integer
function GetMaxMercenaryContingent(_PlayerID, _Type)
    return Stronghold.Mercenary:GetMaxMercenaryContingent(_PlayerID, _Type);
end

--- Returns the current cost factor for mercenaries.
--- @return number Factor Cost factor
function GetMercenaryCostFactor()
    return Stronghold.Mercenary:GetMercenaryCostFactor();
end

--- Changes the cost factor for mercenaries.
--- @param _Factor number Factor
function SetMercenaryCostFactor(_Factor)
    Stronghold.Mercenary:SetMercenaryCostFactor(_Factor);
end

--- Returns the current costs for the unit type.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type
--- @param _Soldiers integer Soldier amount
--- @return table Costs Costs table
function GetMercenaryUnitCosts(_PlayerID, _Type, _Soldiers)
    return Stronghold.Mercenary:GetInflatedUnitCosts(_PlayerID, _Type, _Soldiers);
end

function IsMercenaryUnit(_Entity)
    return Stronghold.Mercenary:IsMercenaryUnit(_Entity);
end

function SetMercenaryUnit(_Entity, _Flag)
    return Stronghold.Mercenary:SetMercenaryUnit(_Entity, _Flag);
end

-- -------------------------------------------------------------------------- --
-- Game Callback

function GameCallback_SH_Calculate_MercenaryCostFactor(_PlayerID, _Type, _Factor)
    return _Factor;
end

function GameCallback_SH_Calculate_MercenaryCapacityFactor(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_MercenaryRechargeTimer(_PlayerID, _Recharge)
    return _Recharge;
end

function GameCallback_SH_Calculate_MercenaryExperience(_PlayerID, _Type, _Amount)
    return _Amount;
end

-- -------------------------------------------------------------------------- --
-- Main

function Stronghold.Mercenary:Install()
    for PlayerID = 1, GetMaxPlayers() do
        self.Data[PlayerID] = {
            Roster = {},
            Contingent = {},
            RecruitCommands = {},
            Units = {},
        };
    end

    self:CreateBuildingButtonHandlers();
    self:OverwriteCallbacks();
end

function Stronghold.Mercenary:OnSaveGameLoaded()
end

function Stronghold.Mercenary:CreateBuildingButtonHandlers()
    self.SyncEvents = {
        BuyMercenary = 1,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Mercenary.SyncEvents.BuyMercenary then
                Stronghold.Mercenary:RegisterRecruitCommand(_PlayerID, arg[1], arg[2], arg[3], arg[4]);
            end
        end
    );
end

function Stronghold.Mercenary:OncePerSecond(_PlayerID)
    self:RefillMercenaryOffers(_PlayerID);
end

function Stronghold.Mercenary:OnEveryTurn(_PlayerID)
    self:RecruitCommandController(_PlayerID);
end

-- -------------------------------------------------------------------------- --
-- GUI

function GUIAction_BuyMercenaryUnit(_Index)
    local WidgetID = "Buy_MercenaryUnit" .._Index;
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if PlayerID ~= GuiPlayer or not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Mercenary:BuyMercenaryUnitAction(WidgetID, _Index, PlayerID, EntityID);
end

function GUITooltip_BuyMercenaryUnit(_Index)
    local WidgetID = "Buy_MercenaryUnit" .._Index;
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Mercenary:BuyMercenaryUnitTooltip(WidgetID, _Index, PlayerID, EntityID);
end

function GUIUpdate_BuyMercenaryUnit(_Index)
    local WidgetID = "Buy_MercenaryUnit" .._Index;
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        XGUIEng.ShowWidget(WidgetID, 0);
        return;
    end
    Stronghold.Mercenary:BuyMercenaryUnitUpdate(WidgetID, _Index, PlayerID, EntityID);
end

function Stronghold.Mercenary:BuyMercenaryUnitAction(_WidgetID, _Index, _PlayerID, _EntityID)
    local UpgradeCategory = self.Data[_PlayerID].Roster[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    if Amount > 0 and XGUIEng.IsButtonDisabled(_WidgetID) == 0 then
        local UnitConfig = Stronghold.Unit.Config.Troops:GetConfig(EntityType, _PlayerID);
        if XGUIEng.IsButtonDisabled(_WidgetID) == 1 then
            return true;
        end
        if not CanBuildingProduceUnit(_PlayerID, _EntityID, EntityType, true) then
            return false;
        end
        Syncer.InvokeEvent(
            self.NetworkCall,
            self.SyncEvents.BuyMercenary,
            _Index,
            EntityType,
            UnitConfig.Soldiers,
            _EntityID
        );
        return true;
    end
    return false;
end

function Stronghold.Mercenary:BuyMercenaryUnitTooltip(_WidgetID, _Index, _PlayerID, _EntityID)
    local UpgradeCategory = self.Data[_PlayerID].Roster[_Index];
    local _, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    local UnitConfig = Stronghold.Unit.Config.Troops:GetConfig(EntityType, _PlayerID);
    local CostFactor = self.Config.CostFactor;
    local Costs = self:GetInflatedUnitCosts(_PlayerID, EntityType, UnitConfig.Soldiers);

    -- Tooltip
    local Text = "";
    local CostsText = "";
    local Shortcut = "";
    if not Stronghold.Recruit:IsUnitAllowed(_EntityID, EntityType) then
        Text = XGUIEng.GetStringTableText("MenuGeneric/UnitNotAvailable");
    else
        local TypeName = Logic.GetEntityTypeName(EntityType);
        CostsText = FormatCostString(_PlayerID, Costs);
        local NeededPlaces = GetMilitaryPlacesUsedByUnit(_PlayerID, EntityType, UnitConfig.Soldiers + 1);
        CostsText = CostsText .. XGUIEng.GetStringTableText("InGameMessages/GUI_NamePlaces") .. ": " .. NeededPlaces;
        local Name = " @color:180,180,180,255 " ..XGUIEng.GetStringTableText("names/".. TypeName);
        Text = Name.. " @cr " ..XGUIEng.GetStringTableText("sh_description/Unit_" ..TypeName.. "_normal");
        if XGUIEng.IsButtonDisabled(_WidgetID) == 1 then
            local DisabledText = XGUIEng.GetStringTableText("sh_description/Unit_" ..TypeName.. "_disabled_mercenary");
            local Rank = Stronghold.Rights:GetRankRequiredForRight(_PlayerID, UnitConfig.Right);
            local RankName = GetRankName(Rank, _PlayerID);
            DisabledText = string.gsub(DisabledText, "#Rank#", RankName);
            Text = Text.. " @cr " ..DisabledText;
        end
        local KeyText = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [%s]";
        local KeyName = Stronghold.Building.Config.RecuitIndexRecuitShortcut[_Index];
        Shortcut = string.format(KeyText, KeyName);
    end

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180,255 " ..Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostsText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, Shortcut);
end

function Stronghold.Mercenary:BuyMercenaryUnitUpdate(_WidgetID, _Index, _PlayerID, _EntityID)
    local AmountWidgetID = "Amount_MercenaryUnit" .._Index;
    if not self.Data[_PlayerID].Roster[_Index] then
        XGUIEng.ShowWidget(_WidgetID, 0);
        XGUIEng.ShowWidget(AmountWidgetID, 0);
        return;
    end
    local UpgradeCategory = self.Data[_PlayerID].Roster[_Index];
    local _, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    local UnitConfig = Stronghold.Unit.Config.Troops:GetConfig(EntityType, _PlayerID);
    local Contingent = self.Data[_PlayerID].Contingent[EntityType];

    -- Button
    local DisabledFlag = 1;
    if  Stronghold.Recruit:IsUnitAllowed(_EntityID, EntityType)
    and Stronghold.Recruit:HasSufficientRank(_EntityID, EntityType) then
        DisabledFlag = 0;
    end
    if Contingent.Amount < 1 then
        DisabledFlag = 1;
    end
    XGUIEng.TransferMaterials(UnitConfig.Button, _WidgetID);
    XGUIEng.DisableButton(_WidgetID, DisabledFlag);
    -- Offer count
    XGUIEng.ShowWidget(AmountWidgetID, 1);
    XGUIEng.SetTextByValue(AmountWidgetID, math.floor(Contingent.Amount));
end

function Stronghold.Mercenary:OnMercenaryCampSelected(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_MercenaryCamp1 then
        return;
    end
    if Logic.IsConstructionComplete(_EntityID) == 1 then
        XGUIEng.ShowWidget("Mercenary", 1);
        XGUIEng.ShowWidget("Commands_Mercenary", 1);
        for i= 1, 30 do
            local Visble = (self.Data[PlayerID].Roster[i] and 1) or 0;
            XGUIEng.ShowWidget("Buy_MercenaryUnit" ..i, Visble);
            GUIUpdate_BuyMercenaryUnit(i);
        end
        XGUIEng.ShowWidget("RallyPoint", 1);
        XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
    else
        XGUIEng.ShowWidget("Mercenary", 0);
    end
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Mercenary:ExecuteBuyUnitKeybindForMercenary(_Key, _PlayerID, _EntityID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Type = Logic.GetEntityType(_EntityID);
        if Type == Entities.PB_MercenaryCamp1 then
            if Logic.IsConstructionComplete(_EntityID) == 1 then
                GUIAction_BuyMercenaryUnit(_Key);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Queue

function Stronghold.Mercenary:RegisterRecruitCommand(_PlayerID, _Index, _Type, _Soldiers, _BuildingID)
    if IsPlayer(_PlayerID) then
        if Logic.EntityGetPlayer(_BuildingID) == _PlayerID then
            table.insert(self.Data[_PlayerID].RecruitCommands, {
                _Index,
                _Type,
                _Soldiers,
                _BuildingID,
            });
        end
    end
end

function Stronghold.Mercenary:RecruitCommandController(_PlayerID)
    if IsPlayer(_PlayerID) then
        --- @diagnostic disable-next-line: undefined-field
        if math.mod(Logic.GetCurrentTurn(), 5) == 0 then
            -- Recruit leader
            while self.Data[_PlayerID].RecruitCommands[1] do
                local Command = table.remove(self.Data[_PlayerID].RecruitCommands, 1);
                if CanBuildingProduceUnit(_PlayerID, Command[4], Command[2], false) then
                    self:BuyMercenaryOffer(_PlayerID, Command[1], Command[2], Command[3], Command[4]);
                    break;
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Mercenary Offers

function Stronghold.Mercenary:OverwriteCallbacks()
    Overwrite.CreateOverwrite("GameCallback_Logic_BuyHero_OnHeroSelected", function(_PlayerID, _ID, _Type)
        Overwrite.CallOriginal();
        Stronghold.Mercenary:InitMercenaryRoster(_PlayerID);
    end);
end

function Stronghold.Mercenary:AddToMercenaryContingent(_PlayerID, _Type, _Amount)
    if IsPlayer(_PlayerID) then
        local Data = self.Data[_PlayerID].Contingent[_Type];
        if Data then
            self.Data[_PlayerID].Contingent[_Type].Amount = Data.Amount + _Amount;
            if Data.Amount < 0 then
                self.Data[_PlayerID].Contingent[_Type].Amount = 0;
            end
        end
    end
end

function Stronghold.Mercenary:GetMercenaryContingent(_PlayerID, _Type)
    if IsPlayer(_PlayerID) then
        local Data = self.Data[_PlayerID].Contingent[_Type];
        if Data then
            return Data.Amount;
        end
    end
    return 0;
end

function Stronghold.Mercenary:GetMaxMercenaryContingent(_PlayerID, _Type)
    if IsPlayer(_PlayerID) then
        local Data = self.Data[_PlayerID].Contingent[_Type];
        if Data then
            local MaxAmount = Data.MaxAmount;
            MaxAmount = GameCallback_SH_Calculate_MercenaryCapacityFactor(_PlayerID, MaxAmount);
            return MaxAmount;
        end
    end
    return 0;
end

function Stronghold.Mercenary:GetMercenaryCostFactor()
    return self.Config.CostFactor;
end

function Stronghold.Mercenary:SetMercenaryCostFactor(_Factor)
    self.Config.CostFactor = _Factor;
    if self.Config.CostFactor < 0.1 then
        self.Config.CostFactor = 0.1;
    end
end

function Stronghold.Mercenary:BuyMercenaryOffer(_PlayerID, _Index, _Type, _Soldiers, _BuildingID)
    local UnitConfig = Stronghold.Unit.Config.Troops:GetConfig(_Type, _PlayerID);
    assert(UnitConfig ~= nil);
    local Contingent = self.Data[_PlayerID].Contingent[_Type];
    assert(UnitConfig ~= nil);

    -- Create unit
    local Costs = self:GetInflatedUnitCosts(_PlayerID, _Type, _Soldiers);
    if HasEnoughResources(_PlayerID, Costs) then
        local Places = GetMilitaryPlacesUsedByUnit(_PlayerID, _Type, _Soldiers);
        if HasPlayerSpaceForUnits(_PlayerID, Places) then
            if Contingent.Amount <= 0 then
                return;
            end
            local Position = GetCirclePosition(_BuildingID, 600, 180);
            local ID = AI.Entity_CreateFormation(
                _PlayerID, _Type, nil, _Soldiers, Position.X, Position.Y, 0, 0, 0, 0
            );
            local Experience = GameCallback_SH_Calculate_MercenaryExperience(_PlayerID, _Type, 1000);
            CEntity.SetLeaderExperience(ID, Experience);
            self.Data[_PlayerID].Contingent[_Type].Amount = Contingent.Amount - 1;
            Logic.MoveSettler(ID, Position.X, Position.Y, -1);
            RemoveResourcesFromPlayer(_PlayerID, Costs);
            self:SetMercenaryUnit(ID, true);
        end
    end
    -- Force UI update
    if GUI.GetPlayerID() == _PlayerID or GUI.GetPlayerID() == 17 then
        if IsEntitySelected(_BuildingID) then
            GUIUpdate_BuyMercenaryUnit(_Index);
        end
    end
end

function Stronghold.Mercenary:SetMercenaryUnit(_Entity, _Flag)
    local ID = GetID(_Entity);
    self.Data.BoughtMercenaries[ID] = _Flag;
end

function Stronghold.Mercenary:IsMercenaryUnit(_Entity)
    local ID = GetID(_Entity);
    return self.Data.BoughtMercenaries[ID] == true;
end

function Stronghold.Mercenary:RefillMercenaryOffers(_PlayerID)
    if IsPlayer(_PlayerID) then
        local MercenaryCamps = GetBuildingsOfType(_PlayerID, Entities.PB_MercenaryCamp1, true);
        if MercenaryCamps[1] > 0 then
            for Type, Data in pairs(self.Data[_PlayerID].Contingent) do
                local Config = self.Config:Get(Type);
                assert(Config ~= nil);
                local MaxAmountBase = Config.MaxAmount;
                local MaxAmountBonus = math.max(MercenaryCamps[1] -1, 0) * self.Config.QuantityFactor;
                local MaxAmount = MaxAmountBase + (MaxAmountBase * MaxAmountBonus);
                MaxAmount = GameCallback_SH_Calculate_MercenaryCapacityFactor(_PlayerID, MaxAmount);
                self.Data[_PlayerID].Contingent[Type].MaxAmount = math.floor(MaxAmount);
                if Data.Amount < MaxAmount then
                    local Recharge = 1;
                    Recharge = GameCallback_SH_Calculate_MercenaryRechargeTimer(_PlayerID, Recharge);
                    self.Data[_PlayerID].Contingent[Type].RefillTimer = Data.RefillTimer + Recharge;
                    if Data.RefillTimer >= Config.RefillTime then
                        self.Data[_PlayerID].Contingent[Type].Amount = Data.Amount + 1;
                        self.Data[_PlayerID].Contingent[Type].RefillTimer = 0;
                    end
                end
            end
        end
    end
end

function Stronghold.Mercenary:GetInflatedUnitCosts(_PlayerID, _Type, _Soldiers)
    local CostFactor = self.Config.CostFactor;
    CostFactor = GameCallback_SH_Calculate_MercenaryCostFactor(_PlayerID, _Type, CostFactor);
    local Costs = GetLeaderCosts(_PlayerID, _Type, _Soldiers);
    Costs[ResourceType.Silver] = (Costs[ResourceType.Silver] or 0);
    Costs[ResourceType.Gold]   = math.floor((Costs[ResourceType.Gold] or 0) * CostFactor);
    Costs[ResourceType.Clay]   = math.floor((Costs[ResourceType.Clay] or 0) * CostFactor);
    Costs[ResourceType.Wood]   = math.floor((Costs[ResourceType.Wood] or 0) * CostFactor);
    Costs[ResourceType.Stone]  = math.floor((Costs[ResourceType.Stone] or 0) * CostFactor);
    Costs[ResourceType.Iron]   = math.floor((Costs[ResourceType.Iron] or 0) * CostFactor);
    Costs[ResourceType.Sulfur] = math.floor((Costs[ResourceType.Sulfur] or 0) * CostFactor);
    return Costs;
end

function Stronghold.Mercenary:InitMercenaryRoster(_PlayerID)
    if IsPlayer(_PlayerID) then
        -- Init mercenary roster
        self.Data[_PlayerID].Roster = {};
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_Assassins) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.AssassinLeaderKnife1);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_Axemen) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.LeaderAxe2);
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.LeaderAxe3);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_Bandits) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.BanditLeaderSword1);
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.BanditLeaderBow1);
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.BanditLeaderCavalry1);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_Barbarians) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.BarbarianLeader2);
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.BarbarianLeader1);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_BlackKnights) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.BlackKnightLeader2);
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.BlackKnightLeader1);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_Cannons) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.Cannon5);
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.Cannon6);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_EliteCavalry) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.LeaderCavalry2);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_EliteKnighty) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.LeaderHeavyCavalry2);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_EliteCrossbow) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.LeaderBow4);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_EliteLongbow) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.LeaderBow2);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_EliteRifle) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.LeaderRifle2);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_EliteSpear) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.LeaderPoleArm4);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_EliteSword) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.LeaderSword4);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_Lancer) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.LeaderPoleArm2);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_Evil) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.BearmanLeader1);
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.SkirmisherLeader1);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_Templars) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.TemplarLeaderPoleArm1);
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.TemplarLeaderCavalry1);
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.TemplarLeaderHeavyCavalry1);
        end
        if not HasPlayerUnlockedPerk(_PlayerID, HeroPerks.Unit_SwordMilitia) then
            table.insert(self.Data[_PlayerID].Roster, UpgradeCategories.LeaderSword1);
        end

        -- Init mercenary contingent
        self.Data[_PlayerID].Contingent = {};
        for _, UpgradeCategory in ipairs(self.Data[_PlayerID].Roster) do
            local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
            if Amount > 0 then
                local Config = self.Config:Get(EntityType);
                self.Data[_PlayerID].Contingent[EntityType] = {
                    Amount = Config.MaxAmount,
                    MaxAmount = Config.MaxAmount,
                    RefillTimer = 0,
                };
            end
        end
    end
end

