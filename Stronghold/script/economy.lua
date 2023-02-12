---
--- Economy Script
---
--- This script implements all calculations reguarding tax, payment, honor
--- and reputation and privides calculation callbacks for external changes.
---
--- Defined game callbacks:
--- - <number> GameCallback_Calculate_ReputationMax(_PlayerID, _Amount)
---   Allows to overwrite the max reputation.
---
--- - <number> GameCallback_Calculate_ReputationIncrease(_PlayerID, _CurrentAmount)
---   Allows to overwrite the reputation income.
---
--- - <number> GameCallback_Calculate_DynamicReputationIncrease(_PlayerID, _BuildingID, _WorkerID, _CurrentAmount)
---   Allows to overwrite the reputation income from settlers.
---
--- - <number> GameCallback_Calculate_StaticReputationIncrease(_PlayerID, _Type, _CurrentAmount)
---   Allows to overwrite the reputation income from buildings.
---
--- - <number> GameCallback_Calculate_ReputationIncreaseExternal(_PlayerID)
---   Allows to overwrite the external income.
---   
--- - <number> GameCallback_Calculate_ReputationDecrease(_PlayerID, _CurrentAmount)
---   Allows to overwrite the reputation malus.
---   
--- - <number> GameCallback_Calculate_ReputationDecreaseExternal(_PlayerID)
---   Allows to overwrite the external reputation malus.
---   
--- - <number> GameCallback_Calculate_HonorIncrease(_PlayerID, _CurrentAmount)
---   Allows to overwrite the honor income.
---
--- - <number> GameCallback_Calculate_DynamicHonorIncrease(_PlayerID, _BuildingID, _WorkerID, _CurrentAmount)
---   Allows to overwrite the honor income from settlers.
---
--- - <number> GameCallback_Calculate_StaticHonorIncrease(_PlayerID, _Type, _CurrentAmount)
---   Allows to overwrite the honor income from buildings.
---   
--- - <number> GameCallback_Calculate_HonorIncreaseSpecial(_PlayerID)
---   Allows to overwrite the external honor income.
---   
--- - <number> GameCallback_Calculate_TotalPaydayIncome(_PlayerID, _CurrentAmount)
---   Allows to overwrite the total money income.
---   
--- - <number> GameCallback_Calculate_TotalPaydayUpkeep(_PlayerID, _CurrentAmount)
---   Allows to overwrite the total upkeep.
---   
--- - <number> GameCallback_Calculate_PaydayUpkeep(_PlayerID, _UnitType, _CurrentAmount)
---   Allows to overwite the upkeep of a unit type.
---
--- - <number> GameCallback_Calculate_MeasureIncrease(_PlayerID, _CurrentAmount)
---   Allows to overwrite the measure points income.
---

Stronghold = Stronghold or {};

Stronghold.Economy = {
    Data = {},
    Config = {
        MaxMeasurePoints = 5000,
        MaxReputation = 200,
        TaxPerWorker = 5,
        Income = {
            TaxEffect = {
                [1] = {Honor = 4, Reputation = 10,},
                [2] = {Honor = 2, Reputation = -2,},
                [3] = {Honor = 1, Reputation = -4,},
                [4] = {Honor = 0, Reputation = -8,},
                [5] = {Honor = 0, Reputation = -12,},
            },

            Dynamic = {
                [Entities.PB_Farm2]      = {Honor = 0.12, Reputation = 0.03,},
                [Entities.PB_Farm3]      = {Honor = 0.18, Reputation = 0.06,},
                ---
                [Entities.PB_Residence2] = {Honor = 0, Reputation = 0.15,},
                [Entities.PB_Residence3] = {Honor = 0, Reputation = 0.24,},
                ---
                [Entities.PB_Tavern1]    = {Honor = 0, Reputation = 0.35,},
                [Entities.PB_Tavern2]    = {Honor = 0, Reputation = 0.45,},
            },
            Static = {
                [Entities.PB_Beautification04] = {Honor = 1, Reputation = 1,},
                [Entities.PB_Beautification06] = {Honor = 1, Reputation = 1,},
                [Entities.PB_Beautification09] = {Honor = 1, Reputation = 1,},
                ---
                [Entities.PB_Beautification01] = {Honor = 2, Reputation = 1,},
                [Entities.PB_Beautification02] = {Honor = 2, Reputation = 1,},
                [Entities.PB_Beautification12] = {Honor = 2, Reputation = 1,},
                ---
                [Entities.PB_Beautification05] = {Honor = 3, Reputation = 1,},
                [Entities.PB_Beautification07] = {Honor = 3, Reputation = 1,},
                [Entities.PB_Beautification08] = {Honor = 3, Reputation = 1,},
                ---
                [Entities.PB_Beautification03] = {Honor = 4, Reputation = 1,},
                [Entities.PB_Beautification10] = {Honor = 4, Reputation = 1,},
                [Entities.PB_Beautification11] = {Honor = 4, Reputation = 1,},
                ---
                [Entities.PB_Headquarters2]    = {Honor =  6, Reputation = 0,},
                [Entities.PB_Headquarters3]    = {Honor = 12, Reputation = 0,},
                ---
                [Entities.PB_VillageCenter2]   = {Honor = 0, Reputation = 3,},
                [Entities.PB_VillageCenter3]   = {Honor = 0, Reputation = 6,},
                ---
                [Entities.PB_Monastery1]       = {Honor = 0, Reputation = 6,},
                [Entities.PB_Monastery2]       = {Honor = 0, Reputation = 9,},
                [Entities.PB_Monastery3]       = {Honor = 0, Reputation = 12,},
            },
        }
    }
};

function Stronghold.Economy:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {
            MeasurePoints = 0,

            IncomeMoney = 0,
            UpkeepMoney = 0,
            UpkeepDetails = {},

            IncomeReputation = 0,
            ReputationDetails = {
                TaxBonus = 0,
                Housing = 0,
                Providing = 0,
                Buildings = 0,
                OtherBonus = 0,
                TaxPenalty = 0,
                Homelessness = 0,
                Hunger = 0,
                OtherMalus = 0,
            },

            IncomeHonor = 0,
            HonorDetails = {
                TaxBonus = 0,
                Housing = 0,
                Providing = 0,
                Buildings = 0,
                OtherBonus = 0,
            },
        };
    end

    self:StartTriggers();

    self:OverrideFindViewUpdate();
    self:OverrideTaxAndPayStatistics();
    self:OverridePaydayClockTooltip();
end

function Stronghold.Economy:OnSaveGameLoaded()
end

function Stronghold.Economy:GetStaticTypeConfiguration(_Type)
    return Stronghold.Economy.Config.Income.Static[_Type];
end

function Stronghold.Economy:GetDynamicTypeConfiguration(_Type)
    return Stronghold.Economy.Config.Income.Dynamic[_Type];
end

--- Gives measure points to the player.
function AddPlayerMeasrue(_PlayerID, _Amount)
    Stronghold.Economy:AddPlayerMeasure(_PlayerID, _Amount)
end

--- Returns the measure points of the player.
function GetPlayerMeasrue(_PlayerID)
    return Stronghold.Economy:GetPlayerMeasure(_PlayerID);
end

--- Returns the max measure points of the player.
function GetPlayerMaxMeasrue(_PlayerID)
    return Stronghold.Economy:GetPlayerMeasureLimit(_PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

function GameCallback_Calculate_ReputationMax(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_Calculate_ReputationDecrease(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_Calculate_ReputationDecreaseExternal(_PlayerID)
    return 0;
end

function GameCallback_Calculate_ReputationIncrease(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_Calculate_StaticReputationIncrease(_PlayerID, _Type, _Amount)
    return _Amount;
end

function GameCallback_Calculate_DynamicReputationIncrease(_PlayerID, _BuildingID, _WorkerID, _Amount)
    return _Amount;
end

function GameCallback_Calculate_ReputationIncreaseExternal(_PlayerID)
    return 0;
end

function GameCallback_Calculate_HonorIncrease(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_Calculate_StaticHonorIncrease(_PlayerID, _Type, _Amount)
    return _Amount;
end

function GameCallback_Calculate_DynamicHonorIncrease(_PlayerID, _BuildingID, _WorkerID, _Amount)
    return _Amount;
end

function GameCallback_Calculate_HonorIncreaseSpecial(_PlayerID)
    return 0;
end

function GameCallback_Calculate_TotalPaydayIncome(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_Calculate_TotalPaydayUpkeep(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_Calculate_PaydayUpkeep(_PlayerID, _UnitType, _Amount)
    return _Amount;
end

function GameCallback_Calculate_MeasureIncrease(_PlayerID, _Amount)
    return _Amount;
end

-- -------------------------------------------------------------------------- --
-- Income & Upkeep

function Stronghold.Economy:UpdateIncomeAndUpkeep(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        local MaxReputation = self.Config.MaxReputation;
        MaxReputation = GameCallback_Calculate_ReputationMax(_PlayerID, MaxReputation);
        Stronghold:SetPlayerReputationLimit(_PlayerID, MaxReputation);

        -- Calculate reputation bonus
        local ReputationPlus = 0;
        self:CalculateReputationIncrease(_PlayerID);
        if self.Data[_PlayerID].ReputationDetails.Housing > 0 then
            ReputationPlus = ReputationPlus + self.Data[_PlayerID].ReputationDetails.Housing;
        end
        if self.Data[_PlayerID].ReputationDetails.Providing > 0 then
            ReputationPlus = ReputationPlus + self.Data[_PlayerID].ReputationDetails.Providing;
        end
        if self.Data[_PlayerID].ReputationDetails.TaxBonus > 0 then
            ReputationPlus = ReputationPlus + self.Data[_PlayerID].ReputationDetails.TaxBonus;
        end
        if self.Data[_PlayerID].ReputationDetails.Buildings > 0 then
            ReputationPlus = ReputationPlus + self.Data[_PlayerID].ReputationDetails.Buildings;
        end
        if self.Data[_PlayerID].ReputationDetails.OtherBonus > 0 then
            ReputationPlus = ReputationPlus + self.Data[_PlayerID].ReputationDetails.OtherBonus;
        end
        ReputationPlus = GameCallback_Calculate_ReputationIncrease(_PlayerID, ReputationPlus);

        -- Calculate reputation penalty
        local ReputationMinus = 0;
        self:CalculateReputationDecrease(_PlayerID);
        if self.Data[_PlayerID].ReputationDetails.Homelessness > 0 then
            ReputationMinus = ReputationMinus + self.Data[_PlayerID].ReputationDetails.Homelessness;
        end
        if self.Data[_PlayerID].ReputationDetails.Hunger > 0 then
            ReputationMinus = ReputationMinus + self.Data[_PlayerID].ReputationDetails.Hunger;
        end
        if self.Data[_PlayerID].ReputationDetails.TaxPenalty > 0 then
            ReputationMinus = ReputationMinus + self.Data[_PlayerID].ReputationDetails.TaxPenalty;
        end
        if self.Data[_PlayerID].ReputationDetails.OtherMalus > 0 then
            ReputationMinus = ReputationMinus + self.Data[_PlayerID].ReputationDetails.OtherMalus;
        end
        ReputationMinus = GameCallback_Calculate_ReputationDecrease(_PlayerID, ReputationMinus);

        -- Calculate honor
        local HonorPlus = 0;
        self:CalculateHonorIncome(_PlayerID);
        if self.Data[_PlayerID].HonorDetails.Housing > 0 then
            HonorPlus = HonorPlus + self.Data[_PlayerID].HonorDetails.Housing;
        end
        if self.Data[_PlayerID].HonorDetails.Providing > 0 then
            HonorPlus = HonorPlus + self.Data[_PlayerID].HonorDetails.Providing;
        end
        if self.Data[_PlayerID].HonorDetails.TaxBonus > 0 then
            HonorPlus = HonorPlus + self.Data[_PlayerID].HonorDetails.TaxBonus;
        end
        if self.Data[_PlayerID].HonorDetails.Buildings > 0 then
            HonorPlus = HonorPlus + self.Data[_PlayerID].HonorDetails.Buildings;
        end
        if self.Data[_PlayerID].HonorDetails.OtherBonus > 0 then
            HonorPlus = HonorPlus + self.Data[_PlayerID].HonorDetails.OtherBonus;
        end
        HonorPlus = GameCallback_Calculate_HonorIncrease(_PlayerID, HonorPlus);

        local Upkeep = self:CalculateMoneyUpkeep(_PlayerID);
        local Income = self:CalculateMoneyIncome(_PlayerID);

        self.Data[_PlayerID].IncomeMoney = Income;
        self.Data[_PlayerID].UpkeepMoney = Upkeep;
        self.Data[_PlayerID].IncomeReputation = math.floor((ReputationPlus - ReputationMinus) + 0.5);
        self.Data[_PlayerID].IncomeHonor = math.floor(HonorPlus + 0.5);
    end
end

-- Calculate reputation increase
-- Reputation is produced by buildings and units.
-- Reputation can only increase if there are pepole at the fortress.
function Stronghold.Economy:CalculateReputationIncrease(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        local Income = 0;
        local WorkerList = GetAllWorker(_PlayerID, 0);
        if table.getn(WorkerList) > 0 then
            -- Tax height
            local TaxtHeight = Stronghold.Players[_PlayerID].TaxHeight;
            if TaxtHeight == 1 then
                local TaxEffect = self.Config.Income.TaxEffect;
                local TaxBonus = TaxEffect[TaxtHeight].Reputation;
                self.Data[_PlayerID].ReputationDetails.TaxBonus = TaxBonus;
                Income = Income + TaxBonus;
            end

            -- Care for the settlers
            local Providing = 0;
            local Housing = 0;
            for k, v in pairs(WorkerList) do
                local FarmID = Logic.GetSettlersFarm(v);
                if FarmID ~= 0 then
                    local Bonus = 0;
                    local Type = Logic.GetEntityType(FarmID);
                    if self.Config.Income.Dynamic[Type] then
                        Bonus = self.Config.Income.Dynamic[Type].Reputation;
                        Bonus = GameCallback_Calculate_DynamicReputationIncrease(_PlayerID, FarmID, v, Bonus);
                        Providing = Providing + Bonus;
                        Income = Income + Bonus;
                    end
                end
                local ResidenceID = Logic.GetSettlersResidence(v);
                if ResidenceID ~= 0 then
                    local Bonus = 0;
                    local Type = Logic.GetEntityType(ResidenceID);
                    if self.Config.Income.Dynamic[Type] then
                        Bonus = self.Config.Income.Dynamic[Type].Reputation;
                        Bonus = GameCallback_Calculate_DynamicReputationIncrease(_PlayerID, ResidenceID, v, Bonus);
                        Housing = Housing + Bonus;
                        Income = Income + Bonus;
                    end
                end
            end
            self.Data[_PlayerID].ReputationDetails.Providing = Providing;
            self.Data[_PlayerID].ReputationDetails.Housing = Housing;

            -- Building bonuses
            local Beauty = 0;
            for k, v in pairs(self.Config.Income.Static) do
                local Buildings = GetValidEntitiesOfType(_PlayerID, k);
                for i= table.getn(Buildings), 1, -1 do
                    if Logic.GetBuildingWorkPlaceLimit(Buildings[i]) > 0 then
                        if Logic.GetBuildingWorkPlaceUsage(Buildings[i]) == 0 then
                            table.remove(Buildings, i);
                        end
                    end
                end
                local BuildingIncome = (table.getn(Buildings) * v.Reputation);
                BuildingIncome = GameCallback_Calculate_StaticReputationIncrease(_PlayerID, k, BuildingIncome);
                Income = Income + BuildingIncome;
                Beauty = Beauty + BuildingIncome;
            end
            self.Data[_PlayerID].ReputationDetails.Buildings = Beauty;

            -- External calculations
            local Special = GameCallback_Calculate_ReputationIncreaseExternal(_PlayerID);
            self.Data[_PlayerID].ReputationDetails.OtherBonus = Special;
        end
    end
end

-- Calculate reputation decrease
-- A fixed penalty for the tax hight and the amout of workers the player didn't
-- provide a farm or house are negative factors.
-- Reputation can only decrease if there are pepole at the fortress.
function Stronghold.Economy:CalculateReputationDecrease(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        local Decrease = 0;
        local WorkerCount = Logic.GetNumberOfAttractedWorker(_PlayerID);
        if WorkerCount > 0 then
            -- Tax height
            local TaxPenalty = self:CalculateReputationTaxPenaltyAmount(
                _PlayerID,
                Stronghold.Players[_PlayerID].TaxHeight
            );
            self.Data[_PlayerID].ReputationDetails.TaxPenalty = TaxPenalty;
            Decrease = TaxPenalty;

            -- Care for the settlers
            local NoFarm = Logic.GetNumberOfWorkerWithoutEatPlace(_PlayerID);
            local NoFarmPenalty = 15 * ((1.005 ^ NoFarm) -1);
            self.Data[_PlayerID].ReputationDetails.Hunger = NoFarmPenalty;
            local NoHouse = Logic.GetNumberOfWorkerWithoutSleepPlace(_PlayerID);
            local NoHousePenalty = 10 * ((1.005 ^ NoHouse) -1);
            self.Data[_PlayerID].ReputationDetails.Homelessness = NoHousePenalty;
            Decrease = Decrease + NoFarmPenalty + NoHousePenalty;

            -- External calculations
            local Special = GameCallback_Calculate_ReputationDecreaseExternal(_PlayerID);
            self.Data[_PlayerID].ReputationDetails.OtherMalus = Special;
        end
    end
end

function Stronghold.Economy:CalculateReputationTaxPenaltyAmount(_PlayerID, _TaxtHeight)
    if Stronghold.Players[_PlayerID] then
        local WorkerCount = Logic.GetNumberOfAttractedWorker(_PlayerID);
        local Penalty = 0;
        if _TaxtHeight > 1 then
            local Rank = Stronghold.Players[_PlayerID].Rank;
            local TaxEffect = self.Config.Income.TaxEffect[_TaxtHeight].Reputation * -1;
            Penalty = TaxEffect * ((1.016 + (0.002 * (Rank-1))) ^ WorkerCount);
        end
        return math.floor(Penalty);
    end
    return 0;
end

-- Calculate honor income
-- Honor is influenced by tax, buildings and units.
-- A player can only gain honor if they have workers and a laird.
function Stronghold.Economy:CalculateHonorIncome(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        local Income = 0;
        if GetID(Stronghold.Players[_PlayerID].LordScriptName) ~= 0 then
            local WorkerList = GetAllWorker(_PlayerID, 0);
            if table.getn(WorkerList) > 0 then
                -- Tax height
                local TaxHight = Stronghold.Players[_PlayerID].TaxHeight;
                local TaxBonus = self.Config.Income.TaxEffect[TaxHight].Honor;
                self.Data[_PlayerID].HonorDetails.TaxBonus = TaxBonus;
                Income = Income + TaxBonus;

                -- Care for the settlers
                local Housing = 0;
                local Providing = 0;
                for k, v in pairs(WorkerList) do
                    local FarmID = Logic.GetSettlersFarm(v);
                    if FarmID ~= 0 then
                        local Bonus = 0;
                        local Type = Logic.GetEntityType(FarmID);
                        if self.Config.Income.Dynamic[Type] then
                            Bonus = self.Config.Income.Dynamic[Type].Honor;
                            Bonus = GameCallback_Calculate_DynamicHonorIncrease(_PlayerID, FarmID, v, Bonus);
                            Providing = Providing + Bonus;
                            Income = Income + Bonus;
                        end
                    end
                    local ResidenceID = Logic.GetSettlersResidence(v);
                    if ResidenceID ~= 0 then
                        local Bonus = 0;
                        local Type = Logic.GetEntityType(ResidenceID);
                        if self.Config.Income.Dynamic[Type] then
                            Bonus = self.Config.Income.Dynamic[Type].Honor;
                            Bonus = GameCallback_Calculate_DynamicHonorIncrease(_PlayerID, ResidenceID, v, Bonus);
                            Housing = Housing + Bonus;
                            Income = Income + Bonus;
                        end
                    end
                end
                self.Data[_PlayerID].HonorDetails.Providing = Providing;
                self.Data[_PlayerID].HonorDetails.Housing = Housing;

                -- Buildings bonuses
                local Beauty = 0;
                for k, v in pairs(self.Config.Income.Static) do
                    local Buildings = GetValidEntitiesOfType(_PlayerID, k);
                    for i= table.getn(Buildings), 1, -1 do
                        local WorkplaceLimit = Logic.GetBuildingWorkPlaceLimit(Buildings[i]);
                        if WorkplaceLimit then
                            if Logic.GetBuildingWorkPlaceUsage(Buildings[i]) < WorkplaceLimit then
                                table.remove(Buildings, i);
                            end
                        end
                    end
                    local BuildingBonus = (table.getn(Buildings) * v.Honor);
                    BuildingBonus = GameCallback_Calculate_StaticHonorIncrease(_PlayerID, k, BuildingBonus);
                    Beauty = Beauty + BuildingBonus
                    Income = Income + BuildingBonus;
                end
                self.Data[_PlayerID].HonorDetails.Buildings = Beauty;

                -- External calculations
                local Special = GameCallback_Calculate_HonorIncreaseSpecial(_PlayerID);
                self.Data[_PlayerID].HonorDetails.OtherBonus = Special;
            end
        end
    end
end

-- Calculate tax income
-- The tax income is mostly unchanged. A worker pays 5 gold times the tax level.
function Stronghold.Economy:CalculateMoneyIncome(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        local WorkerList = GetAllWorker(_PlayerID, 0);
        local TaxHeight = Stronghold.Players[_PlayerID].TaxHeight;
        local PerWorker = self.Config.TaxPerWorker;
        local Income = (table.getn(WorkerList) * PerWorker) * (TaxHeight -1);
        Income = GameCallback_Calculate_TotalPaydayIncome(_PlayerID, Income);
        return math.floor(Income + 0.5);
    end
    return 0;
end

-- Calculate unit upkeep
-- The upkeep is not for the leader himself. Soldiers are also incluced in the
-- calculation. The upkeep decreases if the group looses soldiers.
function Stronghold.Economy:CalculateMoneyUpkeep(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        local Upkeep = 0;
        for k, v in pairs(Stronghold.Unit.Config.Units) do
            local Military = GetValidEntitiesOfType(_PlayerID, k);
            -- Calculate regular upkeep
            local TypeUpkeep = 0;
            for i= 1, table.getn(Military) do
                local UnitUpkeep = v.Upkeep;
                local SoldiersMax = Logic.LeaderGetMaxNumberOfSoldiers(Military[i]);
                local SoldiersCur = Logic.LeaderGetNumberOfSoldiers(Military[i]);
                if SoldiersMax > 0 then
                    UnitUpkeep = math.ceil(UnitUpkeep * ((SoldiersCur +1) / (SoldiersMax +1)));
                end
                TypeUpkeep = TypeUpkeep + UnitUpkeep;
            end
            -- External calculations
            TypeUpkeep = GameCallback_Calculate_PaydayUpkeep(_PlayerID, k, TypeUpkeep)

            self.Data[_PlayerID].UpkeepDetails[k] = TypeUpkeep;
            Upkeep = Upkeep + TypeUpkeep;
        end
        -- External
        Upkeep = GameCallback_Calculate_TotalPaydayUpkeep(_PlayerID, Upkeep);
        return math.floor(Upkeep + 0.5);
    end
    return 0;
end

-- -------------------------------------------------------------------------- --
-- Measure Points

function Stronghold.Economy:AddPlayerMeasure(_PlayerID, _Amount)
    if Stronghold:IsPlayer(_PlayerID) then
        local MeasurePoints = self:GetPlayerMeasure(_PlayerID);
        MeasurePoints = math.max(MeasurePoints + _Amount, 0);
        MeasurePoints = math.min(MeasurePoints, self.Config.MaxMeasurePoints);
        self.Data[_PlayerID].MeasurePoints = MeasurePoints;
    end
end

function Stronghold.Economy:GetPlayerMeasure(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].MeasurePoints;
    end
    return 0;
end

function Stronghold.Economy:GetPlayerMeasureLimit(_PlayerID)
    return self.Config.MaxMeasurePoints;
end

function Stronghold.Economy:GainMeasurePoints(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        local MeasurePoints = 0;
        for k, v in pairs(GetAllWorker(_PlayerID, 0)) do
            if Logic.IsSettlerAtWork(v) == 1 then
                MeasurePoints = MeasurePoints + 0.5;
            end
        end
        MeasurePoints = GameCallback_Calculate_MeasureIncrease(_PlayerID, MeasurePoints);
        self:AddPlayerMeasure(_PlayerID, MeasurePoints);
    end
end

-- -------------------------------------------------------------------------- --
-- UI

function Stronghold.Economy:OverrideFindViewUpdate()
    self.Orig_GUIUpdate_FindView = GUIUpdate_FindView;
    GUIUpdate_FindView = function()
        Stronghold.Economy.Orig_GUIUpdate_FindView();

        local PlayerID = GUI.GetPlayerID();
        if PlayerID == 17 then
            local EntityID = GUI.GetSelectedEntity();
            PlayerID = Logic.EntityGetPlayer(EntityID);
        end
        local x = Logic.WorldGetSize() / 2;
        local y = Logic.WorldGetSize() / 2;

        XGUIEng.ShowWidget("FindView", 1);
        if Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Serf) > 0 then
            XGUIEng.ShowWidget("Find_IdleSerf", 1);
        end
        if Logic.IsPlayerEntityOfCategoryInArea(PlayerID, x, y, Logic.WorldGetSize(), "Spear") == 1 then
		    XGUIEng.ShowWidget("FindSpearmen", 1);
        end
        if Logic.IsPlayerEntityOfCategoryInArea(PlayerID, x, y, Logic.WorldGetSize(), "Sword") == 1 then
            XGUIEng.ShowWidget("FindSwordmen", 1);
        end
        if Logic.IsPlayerEntityOfCategoryInArea(PlayerID, x, y, Logic.WorldGetSize(), "Bow") == 1 then
            XGUIEng.ShowWidget("FindBowmen", 1);
        end
        if Logic.IsPlayerEntityOfCategoryInArea(PlayerID, x, y, Logic.WorldGetSize(), "Cannon") == 1 then
            XGUIEng.ShowWidget("FindCannon", 1);
        end
        if Logic.IsPlayerEntityOfCategoryInArea(PlayerID, x, y, Logic.WorldGetSize(), "CavalryLight") == 1 then
            XGUIEng.ShowWidget("FindLightCavalry", 1);
        end
        if Logic.IsPlayerEntityOfCategoryInArea(PlayerID, x, y, Logic.WorldGetSize(), "CavalryHeavy") == 1 then
            XGUIEng.ShowWidget("FindHeavyCavalry", 1);
        end
        if Logic.IsPlayerEntityOfCategoryInArea(PlayerID, x, y, Logic.WorldGetSize(), "Rifle") == 1 then
            XGUIEng.ShowWidget("FindRiflemen", 1);
        end
        if Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Scout) > 0 then
            XGUIEng.ShowWidget("FindScout", 1);
        end
        if Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Thief) > 0 then
            XGUIEng.ShowWidget("FindThief", 1);
        end

        Stronghold.Economy:HonorMenu();
	end
end

function Stronghold.Economy:HonorMenu()
    local PlayerID = Stronghold:GetLocalPlayerID();

    local Reputation = 100;
    local ReputationLimit = 200;
    local Honor = 0;
    local MaxHonor = Stronghold.Config.Rule.MaxHonor;
    if Stronghold:IsPlayer(PlayerID) then
        Reputation = Stronghold:GetPlayerReputation(PlayerID);
        ReputationLimit = Stronghold:GetPlayerReputationLimit(PlayerID);
        Honor = Stronghold.Players[PlayerID].Honor;
    end

    local ScreenSize = {GUI.GetScreenSize()}
    local WOffset = math.max(145 * (1024/ScreenSize[1]), 135);
    local YOffset = (11 * (ScreenSize[2]/1080));
	XGUIEng.ShowWidget("GCWindow", 1);
	XGUIEng.ShowAllSubWidgets("GCWindow", 0);
	XGUIEng.ShowWidget("GCWindowNew", 1);
	XGUIEng.ShowAllSubWidgets("GCWindowNew", 0);
    XGUIEng.ShowWidget("GCWindowWelcome", 1);
	XGUIEng.SetWidgetPositionAndSize("GCWindow", ScreenSize[1], YOffset, WOffset, 45);
	XGUIEng.SetWidgetPositionAndSize("GCWindowWelcome", 0, 0, WOffset, 0);
	XGUIEng.SetText(
        "GCWindowWelcome",
        Honor.. "/" ..MaxHonor.. " @cr " ..Reputation.. "/" ..ReputationLimit
    );
end

function Stronghold.Economy:OverridePaydayClockTooltip()
    GUITooltip_Payday_Orig_StrongholdEco = GUITooltip_Payday
    GUITooltip_Payday = function()
        local PlayerID = Stronghold:GetLocalPlayerID();
        if not Stronghold.Economy.Data[PlayerID] then
            return GUITooltip_Payday_Orig_StrongholdEco();
        end

        local PaydayTime = math.floor((Logic.GetPlayerPaydayTimeLeft(PlayerID)/1000) + 0.5);
        local Honor = Stronghold.Economy.Data[PlayerID].IncomeHonor;
        local Reputation = Stronghold.Economy.Data[PlayerID].IncomeReputation;

        local TextCol = " @color:255,255,255 ";
        local GreenCol = " @color:173,255,47 ";
        local RepuColor = GreenCol;

        if Reputation < 0 then
            RepuColor = " @color:255,32,32 ";
        else
            Reputation = "+" .. Reputation;
        end
        if Honor >= 0 then
            Honor = "+" .. Honor;
        end

        XGUIEng.SetText(
            "TooltipTopText",
            " @color:180,180,180 Zahltag @cr " ..TextCol.. " " ..PaydayTime..
            " Sekunden verbleiben @cr Ihr erhaltet: @cr "..
            RepuColor.. " " ..Reputation.. " " ..TextCol.. " Beliebtheit @cr "..
            GreenCol.. " " ..Honor.. " " ..TextCol.. " Ehre"
        );
    end
end

function Stronghold.Economy:OverrideTaxAndPayStatistics()
    GUIUpdate_TaxPaydayIncome_Orig_StrongholdEco = GUIUpdate_TaxPaydayIncome;
    GUIUpdate_TaxPaydayIncome = function()
		local PlayerID = Stronghold:GetLocalPlayerID();
        if not Stronghold.Economy.Data[PlayerID] then
            return GUIUpdate_TaxPaydayIncome_Orig_StrongholdEco();
        end

        local Income = Stronghold.Economy.Data[PlayerID].IncomeMoney;
        local Upkeep = Stronghold.Economy.Data[PlayerID].UpkeepMoney;
        if Income - Upkeep < 0 then
			XGUIEng.SetText( "SumOfPayday", " @color:255,32,32 @ra "..(Income-Upkeep));
			XGUIEng.SetText( "TaxSumOfPayday", " @color:255,32,32 @ra "..(Income-Upkeep));
		else
			XGUIEng.SetText( "SumOfPayday", " @color:173,255,47 @ra +"..(Income-Upkeep));
			XGUIEng.SetText( "TaxSumOfPayday", " @color:173,255,47 @ra +"..(Income-Upkeep));
		end
	end

    GUIUpdate_TaxSumOfTaxes_Orig_StrongholdEco = GUIUpdate_TaxSumOfTaxes;
	GUIUpdate_TaxSumOfTaxes = function()
		local PlayerID = Stronghold:GetLocalPlayerID();
        if not Stronghold.Economy.Data[PlayerID] then
            return GUIUpdate_TaxSumOfTaxes_Orig_StrongholdEco();
        end

        local Income = Stronghold.Economy.Data[PlayerID].IncomeMoney;
        XGUIEng.SetText( "TaxWorkerSumOfTaxes", " @color:173,255,47 @ra " ..Income);
	end

    GUIUpdate_TaxLeaderCosts_Orig_StrongholdEco = GUIUpdate_TaxLeaderCosts;
	GUIUpdate_TaxLeaderCosts = function()
		local PlayerID = Stronghold:GetLocalPlayerID();
        if not Stronghold.Economy.Data[PlayerID] then
            return GUIUpdate_TaxLeaderCosts_Orig_StrongholdEco();
        end

        local Upkeep = Stronghold.Economy.Data[PlayerID].UpkeepMoney;
        XGUIEng.SetText( "TaxLeaderSumOfPay", " @color:255,32,32 @ra "..Upkeep);
	end

    GUIUpdate_AverageMotivation_Orig_StrongholdEco = GUIUpdate_AverageMotivation;
    GUIUpdate_AverageMotivation = function()
        local PlayerID = Stronghold:GetLocalPlayerID();
        if not Stronghold.Economy.Data[PlayerID] or not Stronghold:IsPlayer(PlayerID) then
            return GUIUpdate_AverageMotivation_Orig_StrongholdEco();
        end
        local Reputation = Stronghold:GetPlayerReputation(PlayerID)
        local ReputationLimit = Stronghold:GetPlayerReputationLimit(PlayerID)
        -- Icon
        local TexturePath = "data/graphics/textures/gui/";
        if Reputation < 70 then
            TexturePath = TexturePath .. "i_res_motiv_worse.png";
        elseif Reputation >= 70 and Reputation < 100 then
            TexturePath = TexturePath .. "i_res_motiv_bad.png";
        elseif Reputation >= 100 and Reputation < 150 then
            TexturePath = TexturePath .. "i_res_motiv_good.png";
        elseif Reputation >= 150 then
            TexturePath = TexturePath .. "i_res_motiv_fine.png";
        end
        XGUIEng.SetMaterialTexture("IconMotivation", 0, TexturePath);
        -- Text
        XGUIEng.SetWidgetPosition("AverageMotivation", 40, 118);
		XGUIEng.SetText("AverageMotivation", "@center " ..Reputation.. "/" ..ReputationLimit);
	end
end

function Stronghold.Economy:PrintTooltipGenericForEcoGeneral(_PlayerID, _Key)
    if _Key == "MenuHeadquarter/TaxWorker" then
        XGUIEng.SetText(
            gvGUI_WidgetID.TooltipBottomText,
            " @color:180,180,180 Steuern @color:255,255,255 @cr Jeder "..
            " Arbeiter entrichtet Euch zum Zahltag seine Steuer. Wägt "..
            " ab, ob Ihr sie schonen oder schröpfen wollt."
        );
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return true;
    elseif _Key == "MenuHeadquarter/TaxLeader" then
        XGUIEng.SetText(
            gvGUI_WidgetID.TooltipBottomText,
            " @color:180,180,180 Sold @color:255,255,255 @cr Am Zahltag "..
            " wird der Sold der Soldaten fällig. Ihr könnt so viele "..
            " haben, wie ihr wollt, müsst sie aber bezahlen können."
        );
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return true;
    elseif _Key == "MenuResources/population" then
        XGUIEng.SetText(
            gvGUI_WidgetID.TooltipBottomText,
            " @color:180,180,180 Bevölkerung @color:255,255,255 @cr Zur "..
            "Bevölkerung zählen alle Arbeiter, Leibeigene, Kundschafter "..
            "und Diebe. Baut die Burg aus, um mehr Volk anzulocken."
        );
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return true;
    elseif _Key == "MenuResources/Motivation" then
        local Text = " @color:180,180,180 Beliebtheit @color:255,255,255 @cr ";
        local Reputation = Stronghold.Players[_PlayerID].Reputation;
        if Reputation <= 30 then
            Text = Text .. "Sir, Ihr seid eine Katastrophe! Die Leute verlassen die Burg!";
        elseif Reputation > 30 and Reputation < 70 then
            Text = Text .. "Wenn man Euch etwas zuruft, ist es meistens etwas unanständiges.";
        elseif Reputation >= 70 and Reputation < 90 then
            Text = Text .. "Der Pöbel tuschelt hinter vorgehaltener Hand über Euch.";
        elseif Reputation >= 90 and Reputation < 150 then
            Text = Text .. "Die Leute sind zufrieden mit Eurer Herrschaft, Milord.";
        elseif Reputation >= 150 then
            Text = Text .. "Ihr seid unglaublich, Sir! Das Volk verehrt Euch.";
        end

        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return true;
    else
        return false;
    end
end

function Stronghold.Economy:PrintTooltipGenericForFindView(_PlayerID, _Key)
    local Text = XGUIEng.GetStringTableText(_Key);
    local Upkeep = 0;

    if _Key == "MenuTop/Find_spear" then
        local SpeerT1 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm1] or 0;
        local SpeerT2 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm2] or 0;
        local SpeerT3 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm3] or 0;
        local SpeerT4 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm4] or 0;
        Upkeep = SpeerT1+SpeerT2+SpeerT3+SpeerT4;
    elseif _Key == "MenuTop/Find_sword" then
        local SwordT1 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword1] or 0;
        local SwordT2 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword2] or 0;
        local SwordT3 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword3] or 0;
        local SwordT4 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword4] or 0;
        Upkeep = SwordT1+SwordT2+SwordT3+SwordT4;
    elseif _Key == "MenuTop/Find_bow" then
        local BowT1 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow1] or 0;
        local BowT2 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow2] or 0;
        local BowT3 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow3] or 0;
        local BowT4 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow4] or 0;
        Upkeep = BowT1+BowT2+BowT3+BowT4;
    elseif _Key == "MenuTop/Find_cannon" then
        local CannonT1 = self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon1] or 0;
        local CannonT2 = self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon2] or 0;
        local CannonT3 = self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon3] or 0;
        local CannonT4 = self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon4] or 0;
        Upkeep = CannonT1+CannonT2+CannonT3+CannonT4;
    elseif _Key == "MenuTop/Find_lightcavalry" then
        local LCavT1 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderCavalry1] or 0;
        local LcavT2 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderCavalry2] or 0;
        Upkeep = LCavT1+LcavT2;
    elseif _Key == "MenuTop/Find_heavycavalry" then
        local SCavT1 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderHeavyCavalry1] or 0;
        local ScavT2 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderHeavyCavalry2] or 0;
        Upkeep = SCavT1+ScavT2;
    elseif _Key == "AOMenuTop/Find_rifle" then
        local RifleT1 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderRifle1] or 0;
        local RifleT2 = self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderRifle2] or 0;
        Upkeep = RifleT1+RifleT2;
    elseif _Key == "AOMenuTop/Find_scout" then
        Upkeep = self.Data[_PlayerID].UpkeepDetails[Entities.PU_Scout] or 0;
    elseif _Key == "AOMenuTop/Find_Thief" then
        Upkeep = self.Data[_PlayerID].UpkeepDetails[Entities.PU_Thief] or 0;
    else
        return false;
    end

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text.. " @cr Unterhalt: @color:255,32,32 " ..Upkeep.. " @color:255,255,255 Taler");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

-- -------------------------------------------------------------------------- --
-- Trigger

function Stronghold.Economy:StartTriggers()
    Job.Turn(function()
        local Players = table.getn(Score.Player);
        ---@diagnostic disable-next-line: undefined-field
        local PlayerID = math.mod(math.floor(Logic.GetTime() * 10), Players);
        Stronghold.Economy:UpdateIncomeAndUpkeep(PlayerID);
        Stronghold.Economy:GainMeasurePoints(PlayerID);
    end);
end

