

---
--- Economy Script
---
--- This script implements all calculations reguarding tax, payment, honor
--- and reputation and privides calculation callbacks for external changes.
---
--- Defined game callbacks:
--- - <number> GameCallback_SH_Calculate_ReputationMax(_PlayerID, _Amount)
---   Allows to overwrite the max reputation.
---
--- - <number> GameCallback_SH_Calculate_ReputationIncrease(_PlayerID, _CurrentAmount)
---   Allows to overwrite the reputation income.
---
--- - <number> GameCallback_SH_Calculate_DynamicReputationIncrease(_PlayerID, _BuildingID, _WorkerID, _CurrentAmount)
---   Allows to overwrite the reputation income from settlers.
---
--- - <number> GameCallback_SH_Calculate_StaticReputationIncrease(_PlayerID, _Type, _CurrentAmount)
---   Allows to overwrite the reputation income from buildings.
---
--- - <number> GameCallback_SH_Calculate_ReputationIncreaseExternal(_PlayerID)
---   Allows to overwrite the external income.
---   
--- - <number> GameCallback_SH_Calculate_ReputationDecrease(_PlayerID, _CurrentAmount)
---   Allows to overwrite the reputation malus.
---   
--- - <number> GameCallback_SH_Calculate_ReputationDecreaseExternal(_PlayerID)
---   Allows to overwrite the external reputation malus.
---   
--- - <number> GameCallback_SH_Calculate_HonorIncrease(_PlayerID, _CurrentAmount)
---   Allows to overwrite the honor income.
---
--- - <number> GameCallback_SH_Calculate_DynamicHonorIncrease(_PlayerID, _BuildingID, _WorkerID, _CurrentAmount)
---   Allows to overwrite the honor income from settlers.
---
--- - <number> GameCallback_SH_Calculate_StaticHonorIncrease(_PlayerID, _Type, _CurrentAmount)
---   Allows to overwrite the honor income from buildings.
---   
--- - <number> GameCallback_SH_Calculate_HonorIncreaseSpecial(_PlayerID)
---   Allows to overwrite the external honor income.
---   
--- - <number> GameCallback_SH_Calculate_TotalPaydayIncome(_PlayerID, _CurrentAmount)
---   Allows to overwrite the total money income.
---   
--- - <number> GameCallback_SH_Calculate_TotalPaydayUpkeep(_PlayerID, _CurrentAmount)
---   Allows to overwrite the total upkeep.
---   
--- - <number> GameCallback_SH_Calculate_PaydayUpkeep(_PlayerID, _UnitType, _CurrentAmount)
---   Allows to overwite the upkeep of a unit type.
---
--- - <number> GameCallback_SH_Calculate_MeasureIncrease(_PlayerID, _CurrentAmount)
---   Allows to overwrite the Measure points income.
--- 
--- - <number> GameCallback_SH_Calculate_KnowledgeIncrease(_PlayerID, _Amount)
---   Allows to overwrite the Knowledge points income.
---   
--- - <number>, <number> GameCallback_SH_Calculate_ResourceMined(_PlayerID, _BuildingID, _SourceID, _ResourceType, _Amount, _Remaining)
---   Calculates how much resources are mined.
--- 
--- - <number>, <number> GameCallback_SH_Calculate_SerfExtraction(_PlayerID, _SerfID, _SourceID, _ResourceType, _Amount, _Remaining)
---   Calculates how much resources are excracted by serfs.
--- 
--- - <number> GameCallback_SH_Calculate_ResourceRefined(_PlayerID, _BuildingID, _ResourceType, _Amount)
---   Calculates how much resources are refined.
---

Stronghold = Stronghold or {};

Stronghold.Economy = {
    Data = {},
    Config = {},
    Text = {},
};

-- -------------------------------------------------------------------------- --
-- API

--- Gives Measure points to the player.
function AddPlayerMeasure(_PlayerID, _Amount)
    Stronghold.Economy:AddPlayerMeasurePoints(_PlayerID, _Amount)
end

--- Returns the Measure points of the player.
function GetPlayerMeasure(_PlayerID)
    return Stronghold.Economy:GetPlayerMeasurePoints(_PlayerID);
end

--- Returns the max Measure points of the player.
function GetPlayerMaxMeasurePoints(_PlayerID)
    return Stronghold.Economy:GetPlayerMeasurePointsPointsLimit(_PlayerID);
end

--- Gives knowledge to the player.
function AddKnowledge(_PlayerID, _Amount)
    Stronghold.Economy:AddPlayerKnowledge(_PlayerID, _Amount)
end

-- Returns the knowledge of the player.
function GetKnowledge(_PlayerID)
    return Stronghold.Economy:GetPlayerKnowledge(_PlayerID);
end

--- Returns the max knowledge points of the player.
function GetPlayerMaxKnowledgePoints(_PlayerID)
    return Stronghold.Economy:GetPlayerKnowledgePointsLimit(_PlayerID);
end

--- Returns the tax penalty for the player.
function GetPlayerTaxPenalty(_PlayerID, _TaxtHeight)
    return Stronghold.Economy:CalculateReputationTaxPenaltyAmount(_PlayerID, _TaxtHeight);
end

function GetHonorIncome(_PlayerID)
    return Stronghold.Economy:GetHonorIncome(_PlayerID);
end

function GetReputationIncome(_PlayerID)
    return Stronghold.Economy:GetReputationIncome(_PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

function GameCallback_SH_Calculate_ReputationMax(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_ReputationDecrease(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_ReputationDecreaseExternal(_PlayerID)
    return 0;
end

function GameCallback_SH_Calculate_ReputationIncrease(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_StaticReputationIncrease(_PlayerID, _Type, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_DynamicReputationIncrease(_PlayerID, _BuildingID, _WorkerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_ReputationIncreaseExternal(_PlayerID)
    return 0;
end

function GameCallback_SH_Calculate_HonorIncrease(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_StaticHonorIncrease(_PlayerID, _Type, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_DynamicHonorIncrease(_PlayerID, _BuildingID, _WorkerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_HonorIncreaseSpecial(_PlayerID)
    return 0;
end

function GameCallback_SH_Calculate_TotalPaydayIncome(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_TotalPaydayUpkeep(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_PaydayUpkeep(_PlayerID, _UnitType, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_MeasureIncrease(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_ResourceMined(_PlayerID, _BuildingID, _SourceID, _ResourceType, _Amount, _Remaining)
    return _Amount, _Remaining;
end

function GameCallback_SH_Calculate_SerfExtraction(_PlayerID, _SerfID, _SourceID, _ResourceType, _Amount, _Remaining)
    return _Amount, _Remaining;
end

function GameCallback_SH_Calculate_ResourceRefined(_PlayerID, _BuildingID, _ResourceType, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_KnowledgeIncrease(_PlayerID, _Amount)
    return _Amount;
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Economy:Install()
    for i= 1, GetMaxPlayers() do
        CUtil.AddToPlayersMotivationSoftcap(i, 1);

        self.Data[i] = {
            MeasurePoints = 0,
            KnowledgePoints = 0,

            IncomeMoney = 0,
            UpkeepMoney = 0,
            UpkeepDetails = {},

            IncomeReputation = 0,
            IncomeReputationSingle = 0,
            ReputationDetails = {
                TaxBonus = 0,
                Housing = 0,
                Providing = 0,
                Buildings = 0,
                OtherBonus = 0,
                TaxPenalty = 0,
                Homelessness = 0,
                Hunger = 0,
                Criminals = 0,
                OtherMalus = 0,
            },

            IncomeHonor = 0,
            IncomeHonorSingle = 0,
            HonorDetails = {
                TaxBonus = 0,
                Housing = 0,
                Providing = 0,
                Buildings = 0,
                Criminals = 0,
                OtherBonus = 0,
            },
        };
    end

    self:HonorMenuInit();
    self:OverrideResourceCallbacks();
    self:OverrideFindViewUpdate();
    self:OverrideTaxAndPayStatistics();
    self:OverrideSelectUnitCallbacks();
    self:OverrideKnowledgeProgressUpdate();
end

function Stronghold.Economy:OnSaveGameLoaded()
    self:HonorMenuInit();
end

function Stronghold.Economy:GetStaticTypeConfiguration(_Type)
    return Stronghold.Economy.Config.Income.Static[_Type];
end

function Stronghold.Economy:GetDynamicTypeConfiguration(_Type)
    return Stronghold.Economy.Config.Income.Dynamic[_Type];
end

function Stronghold.Economy:OncePerSecond(_PlayerID)
    -- Measure
    self:GainMeasurePoints(_PlayerID);
    -- Knowledge
    self:GainKnowledgePoints(_PlayerID);
end

function Stronghold.Economy:OncePerTurn(_PlayerID)
    -- Income and Costs
    self:UpdateIncomeAndUpkeep(_PlayerID);
end

function Stronghold.Economy:OnEntityCreated(_EntityID)
    -- Initalize motivation
    if Logic.IsWorker(_EntityID) == 1 then
        self:SetSettlersMotivation(_EntityID);
    end
end

-- -------------------------------------------------------------------------- --
-- Income & Upkeep

function Stronghold.Economy:GetHonorIncome(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        return self.Data[_PlayerID].IncomeHonor;
    end
    return 0;
end

function Stronghold.Economy:GetReputationIncome(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        return self.Data[_PlayerID].IncomeReputation;
    end
    return 0;
end

function Stronghold.Economy:UpdateIncomeAndUpkeep(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local MaxReputation = self.Config.Income.MaxReputation;
        MaxReputation = GameCallback_SH_Calculate_ReputationMax(_PlayerID, MaxReputation);
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
        ReputationPlus = GameCallback_SH_Calculate_ReputationIncrease(_PlayerID, ReputationPlus);

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
        if self.Data[_PlayerID].ReputationDetails.Criminals > 0 then
            ReputationMinus = ReputationMinus + self.Data[_PlayerID].ReputationDetails.Criminals;
        end
        if self.Data[_PlayerID].ReputationDetails.OtherMalus > 0 then
            ReputationMinus = ReputationMinus + self.Data[_PlayerID].ReputationDetails.OtherMalus;
        end
        ReputationMinus = GameCallback_SH_Calculate_ReputationDecrease(_PlayerID, ReputationMinus);

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
        HonorPlus = GameCallback_SH_Calculate_HonorIncrease(_PlayerID, HonorPlus);

        local Upkeep = self:CalculateMoneyUpkeep(_PlayerID);
        local Income = self:CalculateMoneyIncome(_PlayerID);

        self.Data[_PlayerID].IncomeMoney = Income;
        self.Data[_PlayerID].UpkeepMoney = Upkeep;
        self.Data[_PlayerID].IncomeReputation = math.floor((ReputationPlus - ReputationMinus)+ 0.5);
        self.Data[_PlayerID].IncomeHonor = math.floor(HonorPlus + 0.5);
    end
end

-- Calculate reputation increase
-- Reputation is produced by buildings and units.
-- Reputation can only increase if there are pepole at the fortress.
function Stronghold.Economy:CalculateReputationIncrease(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Income = 0;
        local WorkerList = Stronghold:GetWorkersOfType(_PlayerID, 0);
        if table.getn(WorkerList) > 0 then
            -- Tax height
            local TaxtHeight = Stronghold.Players[_PlayerID].TaxHeight;
            self.Data[_PlayerID].ReputationDetails.TaxBonus = 0;
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
                    local Bonus = self:CalculateReputationIncreaseTechnologyBonus(_PlayerID, FarmID, v);
                    Providing = Providing + Bonus;
                    Income = Income + Bonus;
                end
                local ResidenceID = Logic.GetSettlersResidence(v);
                if ResidenceID ~= 0 then
                    local Bonus = self:CalculateReputationIncreaseTechnologyBonus(_PlayerID, ResidenceID, v);
                    Housing = Housing + Bonus;
                    Income = Income + Bonus;
                end
            end
            self.Data[_PlayerID].ReputationDetails.Providing = Providing;
            self.Data[_PlayerID].ReputationDetails.Housing = Housing;

            -- Building bonuses
            local Beauty = 0;
            for k, v in pairs(self.Config.Income.Static) do
                local Buildings = Stronghold:GetBuildingsOfType(_PlayerID, k, true);
                for i= table.getn(Buildings), 1, -1 do
                    if Logic.GetBuildingWorkPlaceLimit(Buildings[i]) > 0 then
                        if Logic.GetBuildingWorkPlaceUsage(Buildings[i]) == 0 then
                            table.remove(Buildings, i);
                        end
                    end
                end
                local BuildingIncome = (table.getn(Buildings) * v.Reputation);
                BuildingIncome = GameCallback_SH_Calculate_StaticReputationIncrease(_PlayerID, k, BuildingIncome);
                Income = Income + BuildingIncome;
                Beauty = Beauty + BuildingIncome;
            end
            self.Data[_PlayerID].ReputationDetails.Buildings = Beauty;

            -- External calculations
            local Special = GameCallback_SH_Calculate_ReputationIncreaseExternal(_PlayerID);
            local ReputationOneshot = self.Data[_PlayerID].IncomeReputationSingle;
            if ReputationOneshot > 0 then
                Special = Special + ReputationOneshot;
            end
            self.Data[_PlayerID].ReputationDetails.OtherBonus = Special;
        else
            -- Reset all caches
            self.Data[_PlayerID].ReputationDetails.TaxBonus = 0;
            self.Data[_PlayerID].ReputationDetails.Providing = 0;
            self.Data[_PlayerID].ReputationDetails.Housing = 0;
            self.Data[_PlayerID].ReputationDetails.Buildings = 0;
            self.Data[_PlayerID].ReputationDetails.OtherBonus = 0;
        end
    end
end

function Stronghold.Economy:CalculateReputationIncreaseTechnologyBonus(_PlayerID, _BuildingID, _WorkerID)
    local Bonus = 0;
    local Type = Logic.GetEntityType(_BuildingID);
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        if self.Config.Income.Dynamic[Type] then
            Bonus = self.Config.Income.Dynamic[Type].Reputation;
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_Hearthfire) == 1 then
                if self.Config.Income.TechnologyEffect[Technologies.T_Hearthfire][Type] then
                    Bonus = Bonus + self.Config.Income.TechnologyEffect[Technologies.T_Hearthfire][Type].Reputation;
                end
            end
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_RoomKeys) == 1 then
                if self.Config.Income.TechnologyEffect[Technologies.T_RoomKeys][Type] then
                    Bonus = Bonus + self.Config.Income.TechnologyEffect[Technologies.T_RoomKeys][Type].Reputation;
                end
            end
            Bonus = GameCallback_SH_Calculate_DynamicReputationIncrease(_PlayerID, _BuildingID, _WorkerID, Bonus);
        end
    end
    return Bonus;
end

-- Calculate reputation decrease
-- A fixed penalty for the tax hight and the amout of workers the player didn't
-- provide a farm or house are negative factors.
-- Reputation can only decrease if there are pepole at the fortress.
function Stronghold.Economy:CalculateReputationDecrease(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
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
            local NoFarmPenalty = 15 * ((1.0080 ^ NoFarm) -1);
            self.Data[_PlayerID].ReputationDetails.Hunger = NoFarmPenalty;
            local NoHouse = Logic.GetNumberOfWorkerWithoutSleepPlace(_PlayerID);
            local NoHousePenalty = 10 * ((1.0075 ^ NoHouse) -1);
            self.Data[_PlayerID].ReputationDetails.Homelessness = NoHousePenalty;
            Decrease = Decrease + NoFarmPenalty + NoHousePenalty;

            -- External calculations
            local Special = GameCallback_SH_Calculate_ReputationDecreaseExternal(_PlayerID);
            local Criminals = Stronghold.Attraction:GetReputationLossByCriminals(_PlayerID);
            self.Data[_PlayerID].ReputationDetails.Criminals = Criminals;
            self.Data[_PlayerID].ReputationDetails.OtherMalus = Special - Criminals;
            local ReputationOneshot = self.Data[_PlayerID].IncomeReputationSingle;
            if ReputationOneshot < 0 then
                Special = Special + ((-1) * ReputationOneshot);
            end
            self.Data[_PlayerID].ReputationDetails.OtherMalus = Special;
        else
            -- Reset all caches
            self.Data[_PlayerID].ReputationDetails.TaxPenalty = 0;
            self.Data[_PlayerID].ReputationDetails.Hunger = 0;
            self.Data[_PlayerID].ReputationDetails.Homelessness = 0;
            self.Data[_PlayerID].ReputationDetails.Criminals = 0;
            self.Data[_PlayerID].ReputationDetails.OtherMalus = 0;
        end
    end
end

function Stronghold.Economy:CalculateReputationTaxPenaltyAmount(_PlayerID, _TaxtHeight)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local WorkerCount = Logic.GetNumberOfAttractedWorker(_PlayerID);
        local Penalty = 0;
        if _TaxtHeight > 1 then
            local Rank = GetRank(_PlayerID);
            local WorkerEffect = self.Config.Income.TaxEffect.WorkerFactor;
            local TaxEffect = self.Config.Income.TaxEffect[_TaxtHeight].Reputation * -1;
            WorkerEffect = WorkerEffect + ((WorkerEffect/10) * Rank);
            Penalty = TaxEffect * (1 + (WorkerCount * WorkerEffect));
            for i= 1, Rank do
                Penalty = Penalty * self.Config.Income.TaxEffect.RankFactor;
            end
        end
        return math.floor(Penalty);
    end
    return 0;
end

-- Calculate honor income
-- Honor is influenced by tax, buildings and units.
-- A player can only gain honor if they have workers and a noble.
function Stronghold.Economy:CalculateHonorIncome(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Income = 0;
        if GetID(Stronghold.Players[_PlayerID].LordScriptName) ~= 0 then
            local WorkerList = Stronghold:GetWorkersOfType(_PlayerID, 0);
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
                        local Bonus = self:CalculateHonorIncomeTechnologyBonus(_PlayerID, FarmID, v);
                        Providing = Providing + Bonus;
                        Income = Income + Bonus;
                    end
                    local ResidenceID = Logic.GetSettlersResidence(v);
                    if ResidenceID ~= 0 then
                        local Bonus = self:CalculateHonorIncomeTechnologyBonus(_PlayerID, ResidenceID, v);
                        Housing = Housing + Bonus;
                        Income = Income + Bonus;
                    end
                end
                self.Data[_PlayerID].HonorDetails.Providing = Providing;
                self.Data[_PlayerID].HonorDetails.Housing = Housing;

                -- Buildings bonuses
                local Beauty = 0;
                for k, v in pairs(self.Config.Income.Static) do
                    local Buildings = Stronghold:GetBuildingsOfType(_PlayerID, k, true);
                    for i= table.getn(Buildings), 1, -1 do
                        local WorkplaceLimit = Logic.GetBuildingWorkPlaceLimit(Buildings[i]);
                        if WorkplaceLimit then
                            if Logic.GetBuildingWorkPlaceUsage(Buildings[i]) < WorkplaceLimit then
                                table.remove(Buildings, i);
                            end
                        end
                    end
                    local BuildingBonus = (table.getn(Buildings) * v.Honor);
                    BuildingBonus = GameCallback_SH_Calculate_StaticHonorIncrease(_PlayerID, k, BuildingBonus);
                    Beauty = Beauty + BuildingBonus
                    Income = Income + BuildingBonus;
                end
                self.Data[_PlayerID].HonorDetails.Buildings = Beauty;

                -- External calculations
                local Special = GameCallback_SH_Calculate_HonorIncreaseSpecial(_PlayerID);
                local HonorOneshot = self.Data[_PlayerID].IncomeHonorSingle;
                self.Data[_PlayerID].HonorDetails.OtherBonus = Special + HonorOneshot;
            else
                -- Reset all caches
                self.Data[_PlayerID].HonorDetails.Buildings = 0;
                self.Data[_PlayerID].HonorDetails.TaxBonus = 0;
                self.Data[_PlayerID].HonorDetails.Housing = 0;
                self.Data[_PlayerID].HonorDetails.Providing = 0;
                self.Data[_PlayerID].HonorDetails.OtherBonus = 0;
            end
        end
    end
end

function Stronghold.Economy:CalculateHonorIncomeTechnologyBonus(_PlayerID, _BuildingID, _WorkerID)
    local Bonus = 0;
    local Type = Logic.GetEntityType(_BuildingID);
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        if self.Config.Income.Dynamic[Type] then
            Bonus = self.Config.Income.Dynamic[Type].Honor;
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_CropCycle) == 1 then
                if self.Config.Income.TechnologyEffect[Technologies.T_CropCycle][Type] then
                    Bonus = Bonus + self.Config.Income.TechnologyEffect[Technologies.T_CropCycle][Type].Honor;
                end
            end
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_Spice) == 1 then
                if self.Config.Income.TechnologyEffect[Technologies.T_Spice][Type] then
                    Bonus = Bonus + self.Config.Income.TechnologyEffect[Technologies.T_Spice][Type].Honor;
                end
            end
            if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_Instruments) == 1 then
                if self.Config.Income.TechnologyEffect[Technologies.T_Instruments][Type] then
                    Bonus = Bonus + self.Config.Income.TechnologyEffect[Technologies.T_Instruments][Type].Honor;
                end
            end
            Bonus = GameCallback_SH_Calculate_DynamicHonorIncrease(_PlayerID, _BuildingID, _WorkerID, Bonus);
        end
    end
    return Bonus;
end

-- Calculate tax income
-- The tax income is mostly unchanged. A worker pays x gold times the tax level.
-- If scale is researched, then taxes are increased by 5%.
function Stronghold.Economy:CalculateMoneyIncome(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local WorkerList = Stronghold:GetWorkersOfType(_PlayerID, 0);
        local TaxHeight = Stronghold.Players[_PlayerID].TaxHeight;
        local PerWorker = self.Config.Income.TaxPerWorker;
        local Income = (table.getn(WorkerList) * PerWorker) * (TaxHeight -1);

        -- Scale
        if Logic.IsTechnologyResearched(_PlayerID,Technologies.T_Scale) == 1 then
            Income = Income * self.Config.Income.ScaleBonusFactor;
        end
        -- External
        Income = GameCallback_SH_Calculate_TotalPaydayIncome(_PlayerID, Income);

        return math.floor(Income + 0.5);
    end
    return 0;
end

-- Calculate unit upkeep
-- The upkeep is not for the leader himself. Soldiers are also incluced in the
-- calculation. The upkeep decreases if the group looses soldiers.
function Stronghold.Economy:CalculateMoneyUpkeep(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Upkeep = 0;
        for k, v in pairs(Stronghold.Unit.Config) do
            if type(k) == "number" then
                local LeaderList = Stronghold:GetLeadersOfType(_PlayerID, k);
                local CannonList = Stronghold:GetCannonsOfType(_PlayerID, k);
                local Military = CopyTable(LeaderList, CannonList);
                -- Calculate regular upkeep
                local TypeUpkeep = 0;
                for i= 1, table.getn(Military) do
                    local SoldiersMax = Logic.LeaderGetMaxNumberOfSoldiers(Military[i]);
                    local SoldiersCur = Logic.LeaderGetNumberOfSoldiers(Military[i]);
                    local UpkeepLeader = math.ceil((v.Upkeep or 0) / 2);
                    local UpkeepSoldier = math.floor(((v.Upkeep or 0) / 2) * ((SoldiersCur +1) / (SoldiersMax +1)));
                    TypeUpkeep = TypeUpkeep + (UpkeepLeader + UpkeepSoldier);
                end
                -- External calculations
                TypeUpkeep = GameCallback_SH_Calculate_PaydayUpkeep(_PlayerID, k, TypeUpkeep)

                self.Data[_PlayerID].UpkeepDetails[k] = TypeUpkeep;
                Upkeep = Upkeep + TypeUpkeep;
            end
        end
        -- External
        Upkeep = GameCallback_SH_Calculate_TotalPaydayUpkeep(_PlayerID, Upkeep);
        return math.floor(Upkeep);
    end
    return 0;
end

function Stronghold.Economy:AddOneTimeHonor(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Old = self.Data[_PlayerID].IncomeHonorSingle;
        self.Data[_PlayerID].IncomeHonorSingle = Old + _Amount;
    end
end

function Stronghold.Economy:AddOneTimeReputation(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Old = self.Data[_PlayerID].IncomeReputationSingle;
        self.Data[_PlayerID].IncomeReputationSingle = Old + _Amount;
    end
end

-- -------------------------------------------------------------------------- --
-- Measure Points

function Stronghold.Economy:AddPlayerMeasurePoints(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local MeasurePoints = self:GetPlayerMeasurePoints(_PlayerID);
        MeasurePoints = math.max(MeasurePoints + _Amount, 0);
        MeasurePoints = math.min(MeasurePoints, self:GetPlayerMeasurePointsPointsLimit(_PlayerID));
        self.Data[_PlayerID].MeasurePoints = MeasurePoints;
    end
end

function Stronghold.Economy:GetPlayerMeasurePoints(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        return self.Data[_PlayerID].MeasurePoints;
    end
    return 0;
end

function Stronghold.Economy:GetPlayerMeasurePointsPointsLimit(_PlayerID)
    return self.Config.Income.MaxMeasurePoints;
end

function Stronghold.Economy:GainMeasurePoints(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local MeasurePoints = 0;
        local WorkerCount = Logic.GetNumberOfAttractedWorker(_PlayerID);
        if WorkerCount > 0 then
            local Reputation = GetReputation(_PlayerID);
            local Rank = GetRank(_PlayerID);
            local BaseInfluence = self.Config.Income.InfluenceBase;
            local RankInfluence = self.Config.Income.InfluenceRank * Rank;
            local WorkerFactor = self.Config.Income.InfluenceWorkerFactor;
            local Influence = BaseInfluence + (RankInfluence * Rank);
            for i= 1, WorkerCount do
                Influence = Influence * WorkerFactor;
            end
            MeasurePoints = Influence * math.log(12 * Reputation);
        end
        MeasurePoints = GameCallback_SH_Calculate_MeasureIncrease(_PlayerID, MeasurePoints);
        self:AddPlayerMeasurePoints(_PlayerID, MeasurePoints);
    end
end

-- -------------------------------------------------------------------------- --
-- Knowledge Points

function Stronghold.Economy:AddPlayerKnowledge(_PlayerID, _Amount)
    if _Amount > 0 then
        Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.Knowledge, _Amount);
        WriteResourcesGainedToLog(_PlayerID, "Knowledge", _Amount);
    elseif _Amount < 0 then
        Logic.SubFromPlayersGlobalResource(_PlayerID, ResourceType.Knowledge, _Amount);
        WriteResourcesGainedToLog(_PlayerID, "Knowledge", (-1) * _Amount);
    end
end

function Stronghold.Economy:GetPlayerKnowledge(_PlayerID)
    return Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Knowledge);
end

function Stronghold.Economy:SetPlayerKnowledgePoints(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) then
        local Knowledge = _Amount;
        Knowledge = math.max(Knowledge + _Amount, 0);
        Knowledge = math.min(Knowledge, self:GetPlayerKnowledgePointsLimit());
        self.Data[_PlayerID].KnowledgePoints = _Amount;
    end
end

function Stronghold.Economy:GetPlayerKnowledgePoints(_PlayerID)
    if IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].KnowledgePoints;
    end
    return 0;
end

function Stronghold.Economy:GetPlayerKnowledgePointsLimit(_PlayerID)
    return self.Config.Income.MaxKnowledgePoints;
end

function Stronghold.Economy:GainKnowledgePoints(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        -- Add points per working scholar
        local ScholarList = Stronghold:GetWorkersOfType(_PlayerID, Entities.PU_Scholar);
        for i= 1, table.getn(ScholarList) do
            if Logic.IsSettlerAtWork(ScholarList[i]) == 1 then
                local BuildingID = Logic.GetSettlersWorkBuilding(ScholarList[i]);
                if not InterfaceTool_IsBuildingDoingSomething(BuildingID) then
                    local Motivation = Logic.GetSettlersMotivation(ScholarList[i]);
                    local CurrentAmount = self:GetPlayerKnowledgePoints(_PlayerID);
                    local Amount = self.Config.Income.KnowledgePointsPerWorker;
                    if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_BetterStudies) == 1 then
                        Amount = Amount * self.Config.Income.BetterStudiesFactor;
                    end
                    Amount = GameCallback_SH_Calculate_KnowledgeIncrease(_PlayerID, Amount);

                    Amount = Amount * Motivation;
                    self:SetPlayerKnowledgePoints(_PlayerID, CurrentAmount + Amount);
                end
            end
        end
        -- Clear points and add 1 knowledge if produced enough
        if self:GetPlayerKnowledgePoints(_PlayerID) >= self:GetPlayerKnowledgePointsLimit(_PlayerID) then
            self:SetPlayerKnowledgePoints(_PlayerID, 0);
            self:AddPlayerKnowledge(_PlayerID, 1);
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Settlers

function Stronghold.Economy:SetSettlersMotivation(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if IsPlayer(PlayerID) and not IsAIPlayer(PlayerID) then
        -- Restore reputation when workers are all gone
        -- (This will restore the reputation when a worker is created so that
        -- the worker won't leave immedaitly after. Workers won't be created
        -- unless the 4 minute lock of the attraction ended. So if a settler
        -- appears and the reputation is below 25 it must be set to 50. This
        -- is a safety mesure to avoid timing problems.)
        if GetReputation(PlayerID) <= 25 then
            Stronghold:SetPlayerReputation(PlayerID, 50);
            return;
        end
        -- Set motivation of settler
        if Logic.IsEntityInCategory(_EntityID, EntityCategories.Worker) == 1 then
            local Motivation = GetReputation(PlayerID) / 100;
            CEntity.SetMotivation(_EntityID, Motivation);
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Resource Mining

function Stronghold.Economy:OverrideResourceCallbacks()
    if GameCallback_GainedResourcesFromMine then
        GameCallback_GainedResourcesFromMine_Orig_SH = GameCallback_GainedResourcesFromMine;
    end
    GameCallback_GainedResourcesFromMine = function(_WorkerID, _SourceID, _ResourceType, _Amount)
        local WorkerID, SourceID, ResourceType, Amount = _WorkerID, _SourceID, _ResourceType, _Amount;
        if GameCallback_GainedResourcesFromMine_Orig_SH then
            WorkerID, SourceID, ResourceType, Amount = GameCallback_GainedResourcesFromMine_Orig_SH(WorkerID, SourceID, ResourceType, Amount);
        end
        local PlayerID = Logic.EntityGetPlayer(WorkerID);
        local BuildingID = Logic.GetSettlersWorkBuilding(WorkerID);
        Amount = Stronghold.Economy:OnMineExtractedResource(PlayerID, BuildingID, SourceID, ResourceType, Amount);
        return WorkerID, SourceID, ResourceType, Amount;
    end

    if GameCallback_GainedResourcesExtended then
        GameCallback_GainedResourcesExtended_Orig_SH = GameCallback_GainedResourcesExtended;
    end
    GameCallback_GainedResourcesExtended = function(_ExtractorID, _SourceID, _ResourceType, _Amount)
        local ExtractorID, SourceID, ResourceType, Amount = _ExtractorID, _SourceID, _ResourceType, _Amount;
        if GameCallback_GainedResourcesExtended_Orig_SH then
            ExtractorID, SourceID, ResourceType, Amount = GameCallback_GainedResourcesExtended_Orig_SH(ExtractorID, SourceID, ResourceType, Amount);
        end
        local PlayerID = Logic.EntityGetPlayer(_ExtractorID);
        if Logic.GetEntityType(_ExtractorID) == Entities.PU_Serf then
            Amount = Stronghold.Economy:OnSerfExtractedResource(PlayerID, ExtractorID, SourceID, ResourceType, Amount);
        end
		return ExtractorID, SourceID, ResourceType, Amount;
	end;

    if GameCallback_RefinedResource then
        GameCallback_RefinedResource_Orig_SH = GameCallback_RefinedResource;
    end
    GameCallback_RefinedResource = function(_WorkerID, _ResourceType, _Amount)
        local WorkerID, ResourceType, Amount = _WorkerID, _ResourceType, _Amount;
        if GameCallback_RefinedResource_Orig_SH then
            WorkerID, ResourceType, Amount = GameCallback_RefinedResource_Orig_SH(WorkerID, ResourceType, Amount);
        end
        local PlayerID = Logic.EntityGetPlayer(WorkerID);
        local BuildingID = Logic.GetSettlersWorkBuilding(WorkerID);
        Amount = Stronghold.Economy:OnWorkplaceRefinedResource(PlayerID, BuildingID, ResourceType, Amount);
        return WorkerID, ResourceType, Amount;
    end
end

function Stronghold.Economy:OnSerfExtractedResource(_PlayerID, _SerfID, _SourceID, _ResourceType, _Amount)
    local Amount = self.Config.Resource.Extracting[_ResourceType] or _Amount;
    local ResourceAmount = Logic.GetResourceDoodadGoodAmount(_SourceID);
    local Remaining = ResourceAmount;

    -- Sharp axes
    if _ResourceType == ResourceType.WoodRaw then
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SharpAxes) == 1 then
            Amount = Amount + self.Config.Resource.Extracting.SharpAxeBonus;
        end
    end
    -- Hard handle
    if _ResourceType == ResourceType.ClayRaw or _ResourceType == ResourceType.StoneRaw
    or _ResourceType == ResourceType.IronRaw or _ResourceType == ResourceType.SulfurRaw then
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_HardHandle) == 1 then
            Amount = Amount + self.Config.Resource.Extracting.HardHandleBonus;
        end
    end

    -- External changes
    Amount, Remaining = GameCallback_SH_Calculate_SerfExtraction(_PlayerID, _SerfID, _SourceID, _ResourceType, Amount, Remaining);
    if Remaining > ResourceAmount then
        Logic.SetResourceDoodadGoodAmount(_SourceID, Remaining);
    end
    return Amount;
end

function Stronghold.Economy:OnMineExtractedResource(_PlayerID, _BuildingID, _SourceID, _ResourceType, _Amount)
    local Type = Logic.GetEntityType(_BuildingID);
    local Amount = self.Config.Resource.Mining[Type] or _Amount;
    local ResourceAmount = Logic.GetResourceDoodadGoodAmount(_SourceID);
    local Remaining = ResourceAmount;

    if _ResourceType == ResourceType.ClayRaw then
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PickAxeClay) == 1 then
            Amount = Amount + self.Config.Resource.Mining.PickaxeClayBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SustainableClayMining) == 1 then
            Remaining = Remaining + self.Config.Resource.Mining.SustainableClayMining;
        end
    end

    if _ResourceType == ResourceType.IronRaw then
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PickAxeIron) == 1 then
            Amount = Amount + self.Config.Resource.Mining.PickaxeIronBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SustainableIronMining) == 1 then
            Remaining = Remaining + self.Config.Resource.Mining.SustainableIronMining;
        end
    end

    if _ResourceType == ResourceType.StoneRaw then
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PickAxeStone) == 1 then
            Amount = Amount + self.Config.Resource.Mining.PickaxeStoneBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SustainableStoneMining) == 1 then
            Remaining = Remaining + self.Config.Resource.Mining.SustainableStoneMining;
        end
    end

    if _ResourceType == ResourceType.SulfurRaw then
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PickAxeSulfur) == 1 then
            Amount = Amount + self.Config.Resource.Mining.PickaxeSulfurBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_SustainableSulfurMining) == 1 then
            Remaining = Remaining + self.Config.Resource.Mining.SustainableSulfurMining;
        end
    end

    -- External changes
    Amount, Remaining = GameCallback_SH_Calculate_ResourceMined(_PlayerID, _BuildingID, _SourceID, _ResourceType, Amount, Remaining);
    if Remaining > ResourceAmount then
        Logic.SetResourceDoodadGoodAmount(_SourceID, Remaining);
    end
    return Amount;
end

function Stronghold.Economy:OnWorkplaceRefinedResource(_PlayerID, _BuildingID, _ResourceType, _Amount)
    local Type = Logic.GetEntityType(_BuildingID);
    local Amount = self.Config.Resource.Refining[Type] or _Amount;

    -- Bank technologies
    if _ResourceType == ResourceType.Gold then
        if Logic.IsTechnologyResearched(_PlayerID,Technologies.T_Debenture) == 1 then
            Amount = Amount + self.Config.Income.DebentureBonus;
        end
        if Logic.IsTechnologyResearched(_PlayerID,Technologies.T_Coinage) == 1 then
            Amount = Amount + self.Config.Income.CoinageBonus;
        end
    end

    -- External changes
    Amount = GameCallback_SH_Calculate_ResourceRefined(_PlayerID, _BuildingID, _ResourceType, Amount);
    return Amount;
end

-- -------------------------------------------------------------------------- --
-- UI

function Stronghold.Economy:OverrideFindViewUpdate()
    Overwrite.CreateOverwrite("GUIUpdate_FindView", function()
        -- FIXME: Can not call original here...
        -- Overwrite.CallOriginal();
        XGUIEng.ShowWidget("FindView", 1);
        XGUIEng.ShowAllSubWidgets("FindView", 1);
        GUIUpdate_SocialResource(1);
        GUIUpdate_SocialResource(2);
        GUIUpdate_SocialResource(3);
    end);
end

function Stronghold.Economy:OverrideKnowledgeProgressUpdate()
    GUIUpdate_KnowledgeProgress = function()
        local PlayerID = GetLocalPlayerID();
        local WidgetID = XGUIEng.GetCurrentWidgetID()
        local Maximum = GetPlayerMaxKnowledgePoints(PlayerID);
        local Current = Stronghold.Economy:GetPlayerKnowledgePoints(PlayerID);
        XGUIEng.SetProgressBarValues(WidgetID, Current, Maximum);
    end
end

function Stronghold.Economy:GetLeaderTypesInUpgradeCategories(...)
    local Result = {};
    for i= 1, table.getn(arg) do
        local UpCatMembers = {Logic.GetSettlerTypesInUpgradeCategory(arg)};
        for j= 2, UpCatMembers[1]+1 do
            table.insert(Result, UpCatMembers[j]);
        end
    end
    return Result;
end

function Stronghold.Economy:HonorMenuInit()
    local ScreenSize = {GUI.GetScreenSize()}
    local TextPos = {0, 1};
    local TextWidth = {0, 0};
    if ScreenSize[2] >= 960 then
        TextWidth[1] = TextWidth[1] - 2;
        TextWidth[2] = TextWidth[2] + 0;
        TextPos[1] = TextPos[1] + 0;
        TextPos[2] = TextPos[2] + 2;
    end
    if ScreenSize[2] >= 1080 then
        TextWidth[1] = TextWidth[1] - 2;
        TextWidth[2] = TextWidth[2] + 0;
        TextPos[1] = TextPos[1] + 0;
        TextPos[2] = TextPos[2] + 3;
    end

	XGUIEng.ShowWidget("SocialResourceView", 1);
    XGUIEng.SetWidgetPositionAndSize("SocialResourceView", 868, 0, 156, 50);
	XGUIEng.ShowAllSubWidgets("SocialResourceView", 0);

    -- Reputation
	XGUIEng.ShowWidget("SocialResource1_Icon", 1);
	XGUIEng.ShowWidget("SocialResource1_Text", 1);
	XGUIEng.ShowWidget("SocialResource1_Tooltip", 1);
    XGUIEng.SetWidgetPositionAndSize("SocialResource1_Tooltip", 0, 22, 60, 13);
    XGUIEng.SetWidgetPositionAndSize("SocialResource1_Icon", 0, 19, 18, 18);
    XGUIEng.SetWidgetPositionAndSize("SocialResource1_Text", 30 + TextPos[1], 19 + TextPos[2], 37 + TextWidth[1], 18 + TextWidth[2]);

    -- Knowledge
    XGUIEng.ShowWidget("SocialResource2_Icon", 1);
	XGUIEng.ShowWidget("SocialResource2_Text", 1);
	XGUIEng.ShowWidget("SocialResource2_Tooltip", 1);
    XGUIEng.SetWidgetPositionAndSize("SocialResource2_Tooltip", 75, 4, 53, 13);
    XGUIEng.SetWidgetPositionAndSize("SocialResource2_Icon", 75, 4, 18, 18);
    XGUIEng.SetWidgetPositionAndSize("SocialResource2_Text", 89 + TextPos[1], 4 + TextPos[2], 26 + TextWidth[1], 18 + TextWidth[2]);

    -- Honor
    XGUIEng.ShowWidget("SocialResource3_Icon", 1);
	XGUIEng.ShowWidget("SocialResource3_Text", 1);
	XGUIEng.ShowWidget("SocialResource3_Tooltip", 1);
    XGUIEng.SetWidgetPositionAndSize("SocialResource3_Tooltip", 0, 4, 60, 13);
    XGUIEng.SetWidgetPositionAndSize("SocialResource3_Icon", 0, 4, 18, 18);
    XGUIEng.SetWidgetPositionAndSize("SocialResource3_Text", 30 + TextPos[1], 4 + TextPos[2], 37 + TextWidth[1], 18 + TextWidth[2]);
end

GUIUpdate_SocialResource = function(_Index)
    local PlayerID = GetLocalPlayerID();
    if _Index == 1 then
        local Reputation = GetReputation(PlayerID);
        local ReputationLimit = GetMaxReputation(PlayerID);
        XGUIEng.SetText("SocialResource1_Text", " @ra " ..Reputation.. "/" ..ReputationLimit);
        XGUIEng.SetTextColor("SocialResource1_Text", 178, 178, 178);
        if Reputation < 50 then
            XGUIEng.SetTextColor("SocialResource1_Text", 255, 120, 120);
        end
    elseif _Index == 2 then
        local Knowledge = GetKnowledge(PlayerID);
        XGUIEng.SetText("SocialResource2_Text", " @ra " ..Knowledge);
        XGUIEng.SetTextColor("SocialResource2_Text", 178, 178, 178);
        if Knowledge == 0 then
            XGUIEng.SetTextColor("SocialResource2_Text", 255, 120, 120);
        end
    elseif _Index == 3 then
        local Honor = GetHonor(PlayerID);
        XGUIEng.SetText("SocialResource3_Text", " @ra " ..Honor);
        XGUIEng.SetTextColor("SocialResource3_Text", 178, 178, 178);
        if Honor == 0 then
            XGUIEng.SetTextColor("SocialResource3_Text", 255, 120, 120);
        end
    end
end

function Stronghold.Economy:OverrideTaxAndPayStatistics()
    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_Payday", function(_PlayerID, _Amount)
        local Amount = Overwrite.CallOriginal();
        -- Remove the one time bonuses
        if IsPlayer(_PlayerID) then
            Stronghold.Economy.Data[_PlayerID].IncomeReputationSingle = 0;
            Stronghold.Economy.Data[_PlayerID].IncomeHonorSingle = 0;
        end
        return Amount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Logic_CriminalCatched", function(_PlayerID, _OldEntityID, _BuildingID)
        Overwrite.CallOriginal();
        if IsPlayer(_PlayerID) then
            Stronghold.Economy:AddOneTimeHonor(_PlayerID, 1);
        end
    end);

    Overwrite.CreateOverwrite("GUIUpdate_TaxPaydayIncome", function()
        local PlayerID = GetLocalPlayerID();
        if not IsPlayer(PlayerID) then
            return Overwrite.CallOriginal();
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
    end);

    Overwrite.CreateOverwrite("GUIUpdate_TaxSumOfTaxes", function()
        local PlayerID = GetLocalPlayerID();
        if not IsPlayer(PlayerID) then
            return Overwrite.CallOriginal();
        end
        local Income = Stronghold.Economy.Data[PlayerID].IncomeMoney;
        XGUIEng.SetText( "TaxWorkerSumOfTaxes", " @color:173,255,47 @ra " ..Income);
    end);

    Overwrite.CreateOverwrite("GUIUpdate_TaxLeaderCosts", function()
        local PlayerID = GetLocalPlayerID();
        if not IsPlayer(PlayerID) then
            return Overwrite.CallOriginal();
        end
        local Upkeep = Stronghold.Economy.Data[PlayerID].UpkeepMoney;
        XGUIEng.SetText( "TaxLeaderSumOfPay", " @color:255,32,32 @ra "..Upkeep);
    end);

    function GUIUpdate_Population()
        local PlayerID = GetLocalPlayerID();
        local Usage = GetCivilAttractionUsage(PlayerID);
        local Limit = GetCivilAttractionLimit(PlayerID);
        local Color = (Usage < Limit and "") or " @color:255,120,120,255 ";
        XGUIEng.SetText("PopulationPlaces", Color.. " @ra " ..Usage.. "/" ..Limit);
    end

    function GUIUpdate_Military()
        local PlayerID = GetLocalPlayerID();
        local Usage = GetMilitaryAttractionUsage(PlayerID);
        local Limit = GetMilitaryAttractionLimit(PlayerID);
        local Color = (Usage < Limit and "") or " @color:255,120,120,255 ";
        XGUIEng.SetText("MilitaryPlaces", Color.. " @ra " ..Usage.. "/" ..Limit);
    end

    function GUIUpdate_Slaves()
        local PlayerID = GetLocalPlayerID();
        local Usage = GetSlaveAttractionUsage(PlayerID);
        local Limit = GetSlaveAttractionLimit(PlayerID);
        local Color = (Usage < Limit and "") or " @color:255,120,120,255 ";
        XGUIEng.SetText("SlavePlaces", Color.. " @ra " ..Usage.. "/" ..Limit);
    end
end

function Stronghold.Economy:PrintTooltipGenericForEcoGeneral(_PlayerID, _Key)
    if _Key == "sh_menuheadquarter/TaxWorker" then
        local Text = XGUIEng.GetStringTableText("sh_text/UI_OverviewTaxWorker")
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return true;
    elseif _Key == "sh_menuheadquarter/TaxLeader" then
        local Text = XGUIEng.GetStringTableText("sh_text/UI_OverviewTaxLeader")
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
        Upkeep = Upkeep +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm2] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm3] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm4] or 0);
    elseif _Key == "MenuTop/Find_sword" then
        Upkeep = Upkeep +
            (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BanditLeaderSword1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BanditLeaderSword2] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BlackKnight_LeaderClub1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BlackKnight_LeaderClub2] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.CU_Barbarian_LeaderMace1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.CU_Barbarian_LeaderMace2] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.CU_Evil_LeaderBearman1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword2] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword3] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword4] or 0);
    elseif _Key == "MenuTop/Find_bow" then
        Upkeep = Upkeep +
            (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BanditLeaderBow1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.CU_Evil_LeaderSkirmisher1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow2] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow3] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow4] or 0);
    elseif _Key == "MenuTop/Find_cannon" then
        Upkeep = Upkeep +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon2] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon3] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon4] or 0);
    elseif _Key == "MenuTop/Find_lightcavalry" then
        Upkeep = Upkeep +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderCavalry1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderCavalry2] or 0);
    elseif _Key == "MenuTop/Find_heavycavalry" then
        Upkeep = Upkeep +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderHeavyCavalry1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderHeavyCavalry2] or 0);
    elseif _Key == "AOMenuTop/Find_rifle" then
        Upkeep = Upkeep +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderRifle1] or 0) +
            (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderRifle2] or 0);
    elseif _Key == "AOMenuTop/Find_scout" then
        Upkeep = self.Data[_PlayerID].UpkeepDetails[Entities.PU_Scout] or 0;
    elseif _Key == "AOMenuTop/Find_Thief" then
        Upkeep = self.Data[_PlayerID].UpkeepDetails[Entities.PU_Thief] or 0;
    else
        return false;
    end

    local UpkeepText = XGUIEng.GetStringTableText("sh_text/UI_FindView");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text .. string.format(UpkeepText, Upkeep));
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

function Stronghold.Economy:OverrideSelectUnitCallbacks()
    KeyBindings_SelectUnit_Orig_SH = KeyBindings_SelectUnit;
    KeyBindings_SelectUnit = function(_UpgradeCategory, _Type)
        if _Type == 1 then
            return KeyBindings_SelectUnit_Orig_SH(_UpgradeCategory, _Type);
        end
        Stronghold.Economy:SelectUnitType(_UpgradeCategory);
    end

    KeyBindings_SelectCannons = function()
        Stronghold.Economy:SelectUnitType(UpgradeCategories.Cannon1);
    end
end

function Stronghold.Economy:SelectUnitType(_UpgradeCategory)
    local PlayerID = GetLocalPlayerID();
    local UnitTypes = Stronghold.Economy.Config.SelectCategoryMapping[_UpgradeCategory] or {};
    local UnitList = {};
    for _, Type in (UnitTypes) do
        for k, v in pairs(GetPlayerEntities(PlayerID, Type)) do
            table.insert(UnitList, v);
        end
    end
    local i = gvKeyBindings_LastSelectedEntityPos;
	i = (i + 1 >= table.getn(UnitList) and 0) or (i+1);
	gvKeyBindings_LastSelectedEntityPos = i;
    if UnitList[1 + i] then
        local x, y, z = Logic.EntityGetPos(UnitList[1 + i]);
        Camera.ScrollSetLookAt(x, y);
        GUI.SetSelectedEntity(UnitList[1 + i]);
    end
end

-- -------------------------------------------------------------------------- --
-- Payday Clock

function Stronghold.Economy:CreatePaydayClockTooltipText(_PlayerID)
    local AmendText = "";
    local ScreenSize = {GUI.GetScreenSize()};
    local Graphic = "data\\graphics\\textures\\gui\\bg_tooltip_top.png";
    local ExtGraphic = "data\\graphics\\textures\\gui\\bg_tooltip_top_ext_768.png";
    if ScreenSize[2] >= 900 then
        ExtGraphic = "data\\graphics\\textures\\gui\\bg_tooltip_top_ext_900.png";
    end
    if ScreenSize[2] >= 1080 then
        ExtGraphic = "data\\graphics\\textures\\gui\\bg_tooltip_top_ext_1080.png";
    end

    if IsPlayer(_PlayerID) then
        if XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1 then
            -- Get Text
            local Text = self:FormatExtendedPaydayClockText(_PlayerID);
            AmendText = " @cr @cr " .. Placeholder.Replace(Text);
            -- Resize
            XGUIEng.SetWidgetSize("TooltipTop", 172, 300);
            XGUIEng.SetWidgetSize("TooltipTopText", 164, 300);
            XGUIEng.SetWidgetSize("TooltipTopBackground", 172, 300);
            XGUIEng.SetMaterialTexture("TooltipTopBackground", 1, ExtGraphic);
        else
            -- Get Text
            local Text = self:FormatPaydayClockText(_PlayerID);
            AmendText = " @cr @cr " .. Placeholder.Replace(Text);
            -- Resize
            XGUIEng.SetWidgetSize("TooltipTop", 172, 104);
            XGUIEng.SetWidgetSize("TooltipTopText", 164, 104);
            XGUIEng.SetWidgetSize("TooltipTopBackground", 172, 104);
            XGUIEng.SetMaterialTexture("TooltipTopBackground", 1, Graphic);
        end
    end
    return AmendText;
end

function Stronghold.Economy:FormatPaydayClockText(_PlayerID)
    local irep = self.Data[_PlayerID].IncomeReputation;
    local ihon = self.Data[_PlayerID].IncomeHonor;

    local Language = GetLanguage();
    return string.format(
        self.Text.PaydayClock[1][Language],
        -- Honor
        ((ihon < 0 and "{scarlet}") or "{green}") ..ihon,
        -- Reputation
        ((irep < 0 and "{scarlet}") or "{green}") ..irep
    );
end

function Stronghold.Economy:FormatExtendedPaydayClockText(_PlayerID)
    local irep = self.Data[_PlayerID].IncomeReputation;

    local ihon = self.Data[_PlayerID].IncomeHonor;
    local hbb  = self.Data[_PlayerID].HonorDetails.Buildings;
    local htb  = self.Data[_PlayerID].HonorDetails.TaxBonus;
    local hho  = self.Data[_PlayerID].HonorDetails.Housing;
    local hpr  = self.Data[_PlayerID].HonorDetails.Providing;
    local hob  = self.Data[_PlayerID].HonorDetails.OtherBonus;

    local pbb  = self.Data[_PlayerID].ReputationDetails.Buildings;
    local ptb  = self.Data[_PlayerID].ReputationDetails.TaxBonus;
    local ptp  = self.Data[_PlayerID].ReputationDetails.TaxPenalty;
    local pho  = self.Data[_PlayerID].ReputationDetails.Housing;
    local phs  = self.Data[_PlayerID].ReputationDetails.Homelessness;
    local ppr  = self.Data[_PlayerID].ReputationDetails.Providing;
    local phu  = self.Data[_PlayerID].ReputationDetails.Hunger;
    local pob  = self.Data[_PlayerID].ReputationDetails.OtherBonus;
    local pcr  = (-1) * self.Data[_PlayerID].ReputationDetails.Criminals;
    local pop  = self.Data[_PlayerID].ReputationDetails.OtherMalus;

    local Language = GetLanguage();
    return string.format(
        self.Text.PaydayClock[2][Language],
        -- Honor
        ((ihon < 0 and "{scarlet}") or "{green}") ..ihon,
        ((htb < 0 and "{scarlet}") or "{green}") ..string.format("%.2f", htb),
        ((hbb < 0 and "{scarlet}") or "{green}") ..string.format("%.2f", hbb),
        ((hpr < 0 and "{scarlet}") or "{green}") ..string.format("%.2f", hpr),
        ((hho < 0 and "{scarlet}") or "{green}") ..string.format("%.2f", hho),
        ((hob < 0 and "{scarlet}") or "{green}") ..string.format("%.2f", hob),
        -- Reputation
        ((irep < 0 and "{scarlet}") or "{green}") ..irep,
        ((ptb-ptp < 0 and "{scarlet}") or "{green}") ..string.format("%.2f", ptb-ptp),
        ((pcr < 0 and "{scarlet}") or "{green}") ..string.format("%.2f", pcr),
        ((pbb < 0 and "{scarlet}") or "{green}") ..string.format("%.2f", pbb),
        ((ppr-phu < 0 and "{scarlet}") or "{green}") ..string.format("%.2f", ppr-phu),
        ((pho-phs < 0 and "{scarlet}") or "{green}") ..string.format("%.2f", pho-phs),
        ((pob-pop < 0 and "{scarlet}") or "{green}") ..string.format("%.2f", pob-pop)
    );
end

