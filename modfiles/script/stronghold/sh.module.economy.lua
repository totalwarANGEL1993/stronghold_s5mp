---
--- Economy Script
---
--- This script implements all calculations reguarding tax, payment, honor
--- and reputation and privides calculation callbacks for external changes.
---

Stronghold = Stronghold or {};

Stronghold.Economy = {
    Data = {},
    Config = {},
    Text = {},
};

-- -------------------------------------------------------------------------- --
-- API

--- Gives influence points to the player.
--- @param _PlayerID integer ID of player
--- @param _Amount integer influence points
function AddPlayerInfluence(_PlayerID, _Amount)
    Stronghold.Economy:AddPlayerInfluencePoints(_PlayerID, _Amount)
end

--- Returns the influence points of the player.
--- @param _PlayerID integer ID of player
--- @return integer Amount influence points
function GetPlayerInfluence(_PlayerID)
    return Stronghold.Economy:GetPlayerInfluencePoints(_PlayerID);
end

--- Returns the max influence points of the player.
--- @param _PlayerID integer ID of player
--- @return integer Amount Max influence points
function GetPlayerMaxInfluencePoints(_PlayerID)
    return Stronghold.Economy:GetPlayerInfluencePointsPointsLimit(_PlayerID);
end

--- Gives knowledge to the player.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Knowledge points
function AddKnowledge(_PlayerID, _Amount)
    Stronghold.Economy:AddPlayerKnowledge(_PlayerID, _Amount)
end

-- Returns the knowledge of the player.
--- @param _PlayerID integer ID of player
--- @return integer Amount Knowledge points
function GetKnowledge(_PlayerID)
    return Stronghold.Economy:GetPlayerKnowledge(_PlayerID);
end

--- Returns the max knowledge points of the player.
--- @param _PlayerID integer ID of player
--- @return integer Amount Max knowledge points
function GetPlayerMaxKnowledgePoints(_PlayerID)
    return Stronghold.Economy:GetPlayerKnowledgePointsLimit(_PlayerID);
end

--- Returns the tax penalty for the player.
--- @param _PlayerID integer ID of player
--- @param _TaxHeight integer Tax height
--- @return integer Penalty Reputation penalty
function GetPlayerTaxPenalty(_PlayerID, _TaxHeight)
    return Stronghold.Economy:CalculateReputationTaxPenaltyAmount(_PlayerID, _TaxHeight);
end

--- Returns the current honor income of the player.
--- @param _PlayerID integer ID of player
--- @return integer Income Honor income
function GetHonorIncome(_PlayerID)
    return Stronghold.Economy:GetHonorIncome(_PlayerID);
end

--- Returns the current reputation income of the player.
--- @param _PlayerID integer ID of player
--- @return integer Income Reputation income
function GetReputationIncome(_PlayerID)
    return Stronghold.Economy:GetReputationIncome(_PlayerID);
end

--- Creates a pile of wood that can be extracted with serfs.
--- @param _Entity string Scriptname of entiry
--- @param _Resources integer Amount of resource
function CreateWoodPile(_Entity, _Resources)
    Stronghold.Economy:CreateWoodPile(_Entity, _Resources);
end

--- Destroys a wood pile.
--- @param _Entity string Scriptname of entiry
function DestroyWoodPile(_Entity)
    Stronghold.Economy:DestroyWoodPile(_Entity);
end

--- Returns if the entity is a wood pile.
--- @return boolean IsPile Entity is pile
function IsWoodPile(_Entity)
    return Stronghold.Economy:IsWoodPile(_Entity);
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

--- Calculates the maximum reputation of the player.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Current maximum
--- @return integer Limit Maximum reputation
function GameCallback_SH_Calculate_ReputationMax(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates how much reputation a player looses at the payday.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Amount of reputation
--- @return integer Reputation Amount of reputation
function GameCallback_SH_Calculate_ReputationDecrease(_PlayerID, _Amount)
    return _Amount;
end

--- Calulates how much reputation the player looses by external causes.
--- @param _PlayerID integer ID of player
--- @return integer Reputation Amount of reputation
function GameCallback_SH_Calculate_ExternalReputationDecrease(_PlayerID)
    return 0;
end

--- Calculates how much reputation a player gains at the payday.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Amount of reputation
--- @return integer Reputation Amount of reputation
function GameCallback_SH_Calculate_ReputationIncrease(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates how much reputation is gained by dynamic causes at the payday.
--- @param _PlayerID integer ID of player
--- @param _Type integer Type of building
--- @param _Amount integer Amount of reputation
--- @return integer Reputation Amount of reputation
function GameCallback_SH_Calculate_ServiceReputationIncrease(_PlayerID, _Type, _Amount)
    return _Amount;
end

--- Calulates how much reputation is gained by external causes.
--- @param _PlayerID integer ID of player
--- @return integer Reputation Amount of reputation
function GameCallback_SH_Calculate_ExternalReputationIncrease(_PlayerID)
    return 0;
end

--- Calculates how much honor a player gains at the payday.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Amount of honor
--- @return integer Honor Amount of honor
function GameCallback_SH_Calculate_HonorIncrease(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates how much honor is gained by dynamic causes at the payday.
--- @param _PlayerID integer ID of player
--- @param _Type integer Type of building
--- @param _Amount integer Amount of honor
--- @return integer Honor Amount of honor
function GameCallback_SH_Calculate_ServiceHonorIncrease(_PlayerID, _Type, _Amount)
    return _Amount;
end

--- Calulates how much honor is gained by external causes.
--- @param _PlayerID integer ID of player
--- @return integer Honor Amount of honor
function GameCallback_SH_Calculate_ExternalHonorIncrease(_PlayerID)
    return 0;
end

--- Calculates how much tax money the player earns on the payday.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Income
--- @return integer Income Income
function GameCallback_SH_Calculate_TotalPaydayIncome(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates how much upkeep a player must pay on the payday.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Upkeep
--- @return integer Upkeep Upkeep
function GameCallback_SH_Calculate_TotalPaydayUpkeep(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates how much upkeep the player earns from the type of worker.
--- @param _PlayerID integer ID of player
--- @param _PayerType integer Type of entity
--- @param _Amount integer Upkeep
--- @return integer Upkeep Upkeep
function GameCallback_SH_Calculate_PaydayIncome(_PlayerID, _PayerType, _Amount)
    -- TODO: Not implemented
    return _Amount;
end

--- Calculates how much upkeep the player has to pay for the unit type.
--- @param _PlayerID integer ID of player
--- @param _UnitType integer Type of entity
--- @param _Amount integer Upkeep
--- @return integer Upkeep Upkeep
function GameCallback_SH_Calculate_PaydayUpkeep(_PlayerID, _UnitType, _Amount)
    return _Amount;
end

--- Calculates how many resources are mined by the building.
--- @param _PlayerID integer ID of player
--- @param _BuildingID integer ID of building
--- @param _SourceID integer ID of resource entity
--- @param _ResourceType integer Type of resource
--- @param _Amount integer Amount of resource
--- @param _Remaining integer Remaining resources
--- @return integer Amount Amount of resource
--- @return integer Remaining Remaining resources
function GameCallback_SH_Calculate_ResourceMined(_PlayerID, _BuildingID, _SourceID, _ResourceType, _Amount, _Remaining)
    return _Amount, _Remaining;
end

--- Calculates how many resources are extracted by the serf.
--- @param _PlayerID integer ID of player
--- @param _SerfID integer ID of serf
--- @param _SourceID integer ID of resource entity
--- @param _ResourceType integer Type of resource
--- @param _Amount integer Amount of resource
--- @param _Remaining integer Remaining resources
--- @return integer Amount Amount of resource
--- @return integer Remaining Remaining resources
function GameCallback_SH_Calculate_SerfExtraction(_PlayerID, _SerfID, _SourceID, _ResourceType, _Amount, _Remaining)
    return _Amount, _Remaining;
end

--- Calculates how many resources are refined by the building.
--- @param _PlayerID integer ID of player
--- @param _BuildingID integer ID of building
--- @param _ResourceType integer Type of resource
--- @param _Amount integer Amount of resource
--- @return integer Amount Amount of resource
function GameCallback_SH_Calculate_ResourceRefined(_PlayerID, _BuildingID, _ResourceType, _Amount)
    return _Amount;
end

--- Calculates how many influence the player gains.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Amount of influence
--- @return integer Amount Amount of influence
function GameCallback_SH_Calculate_InfluenceIncrease(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates how much knowledge a player gains.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Amount of knowledge
--- @return integer Amount Amount of knowledge
function GameCallback_SH_Calculate_KnowledgeIncrease(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates the hunger penalty
--- @param _PlayerID integer ID of player
--- @param _Amount number Current penalty
--- @return number Adjusted Adjusted penalty
function GameCallback_SH_Calculate_HungerPenalty(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates the homlessness penalty.
--- @param _PlayerID integer ID of player
--- @param _Amount number Current penalty
--- @return number Adjusted Adjusted penalty
function GameCallback_SH_Calculate_SleepPenalty(_PlayerID, _Amount)
    return _Amount;
end

--- Called whenever a player gained knowledge.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Amount of knowledge
function GameCallback_SH_Logic_KnowledgeGained(_PlayerID, _Amount)
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Economy:Install()
    for i= 1, GetMaxPlayers() do
        CUtil.AddToPlayersMotivationSoftcap(i, 1);

        self.Data[i] = {
            InfluencePoints = 0,
            KnowledgePoints = 0,

            IncomeMoney = 0,
            UpkeepMoney = 0,
            UpkeepDetails = {},

            TemporaryFarm = 0,
            TemporarHouse = 0,

            IncomeReputation = 0,
            IncomeReputationSingle = 0,
            ReputationDetails = {
                TaxBonus = 0,
                Housing = 0,
                HousingCounter = 0,
                Providing = 0,
                ProvidingCounter = 0,
                BeverageCounter = 0,
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
                HousingCounter = 0,
                Providing = 0,
                ProvidingCounter = 0,
                BeverageCounter = 0,
                Buildings = 0,
                Criminals = 0,
                OtherBonus = 0,
            },
        };
    end

    self.Data.WoodPiles = {};

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

function Stronghold.Economy:OnEverySecond()
    self:ControlWoodPiles();
end

function Stronghold.Economy:OncePerSecond(_PlayerID)
    -- Influence
    self:GainInfluencePoints(_PlayerID);
    -- Knowledge
    self:GainKnowledgePoints(_PlayerID);
    -- Reputation
    self:CalculateReputationIncrease(_PlayerID);
    self:CalculateReputationDecrease(_PlayerID);
    -- Honor
    self:CalculateHonorIncome(_PlayerID);
    -- Upkeep
    self:UpdateFindViewAmount(_PlayerID)
end

function Stronghold.Economy:OncePerTurn(_PlayerID)
    -- Income, Reputation, Honor
    self:CalculateReputationBonusAmount(_PlayerID);
    self:UpdateIncomeAndUpkeep(_PlayerID);
end

function Stronghold.Economy:OnEntityCreated(_EntityID)
    -- Initalize motivation
    if Logic.IsWorker(_EntityID) == 1 then
        self:SetSettlersMotivation(_EntityID);
    end
end

function Stronghold.Economy:OnUnknownTask(_EntityID)
    local AdvanceType;
    AdvanceType = self:OnUnknownTaskInFarm(_EntityID);
    if AdvanceType ~= nil then
        return AdvanceType;
    end
    AdvanceType = self:OnUnknownTaskInHouse(_EntityID);
    if AdvanceType ~= nil then
        return AdvanceType;
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
        Stronghold.Player:SetPlayerReputationLimit(_PlayerID, MaxReputation);

        -- Calculate reputation bonus
        local ReputationPlus = 0;
        if self.Data[_PlayerID].ReputationDetails.Housing > 0 then
            ReputationPlus = ReputationPlus + math.floor(self.Data[_PlayerID].ReputationDetails.Housing);
        end
        if self.Data[_PlayerID].ReputationDetails.Providing > 0 then
            ReputationPlus = ReputationPlus + math.floor(self.Data[_PlayerID].ReputationDetails.Providing);
        end
        if self.Data[_PlayerID].ReputationDetails.TaxBonus > 0 then
            ReputationPlus = ReputationPlus + math.floor(self.Data[_PlayerID].ReputationDetails.TaxBonus);
        end
        if self.Data[_PlayerID].ReputationDetails.Buildings > 0 then
            ReputationPlus = ReputationPlus + math.floor(self.Data[_PlayerID].ReputationDetails.Buildings);
        end
        if self.Data[_PlayerID].ReputationDetails.OtherBonus > 0 then
            ReputationPlus = ReputationPlus + math.floor(self.Data[_PlayerID].ReputationDetails.OtherBonus);
        end
        ReputationPlus = GameCallback_SH_Calculate_ReputationIncrease(_PlayerID, ReputationPlus);

        -- Calculate reputation penalty
        local ReputationMinus = 0;
        if self.Data[_PlayerID].ReputationDetails.Homelessness > 0 then
            ReputationMinus = ReputationMinus + math.floor(self.Data[_PlayerID].ReputationDetails.Homelessness);
        end
        if self.Data[_PlayerID].ReputationDetails.Hunger > 0 then
            ReputationMinus = ReputationMinus + math.floor(self.Data[_PlayerID].ReputationDetails.Hunger);
        end
        if self.Data[_PlayerID].ReputationDetails.TaxPenalty > 0 then
            ReputationMinus = ReputationMinus + math.floor(self.Data[_PlayerID].ReputationDetails.TaxPenalty);
        end
        if self.Data[_PlayerID].ReputationDetails.Criminals > 0 then
            ReputationMinus = ReputationMinus + math.floor(self.Data[_PlayerID].ReputationDetails.Criminals);
        end
        if self.Data[_PlayerID].ReputationDetails.Rats > 0 then
            ReputationMinus = ReputationMinus + math.floor(self.Data[_PlayerID].ReputationDetails.Rats);
        end
        if self.Data[_PlayerID].ReputationDetails.OtherMalus > 0 then
            ReputationMinus = ReputationMinus + math.floor(self.Data[_PlayerID].ReputationDetails.OtherMalus);
        end
        ReputationMinus = GameCallback_SH_Calculate_ReputationDecrease(_PlayerID, ReputationMinus);

        -- Calculate honor
        local HonorPlus = 0;
        if self.Data[_PlayerID].HonorDetails.Housing > 0 then
            HonorPlus = HonorPlus + math.floor(self.Data[_PlayerID].HonorDetails.Housing);
        end
        if self.Data[_PlayerID].HonorDetails.Providing > 0 then
            HonorPlus = HonorPlus + math.floor(self.Data[_PlayerID].HonorDetails.Providing);
        end
        if self.Data[_PlayerID].HonorDetails.TaxBonus > 0 then
            HonorPlus = HonorPlus + math.floor(self.Data[_PlayerID].HonorDetails.TaxBonus);
        end
        if self.Data[_PlayerID].HonorDetails.Buildings > 0 then
            HonorPlus = HonorPlus + math.floor(self.Data[_PlayerID].HonorDetails.Buildings);
        end
        if self.Data[_PlayerID].HonorDetails.OtherBonus > 0 then
            HonorPlus = HonorPlus + math.floor(self.Data[_PlayerID].HonorDetails.OtherBonus);
        end
        HonorPlus = GameCallback_SH_Calculate_HonorIncrease(_PlayerID, HonorPlus);

        local Upkeep = self:CalculateMoneyUpkeep(_PlayerID);
        local Income = self:CalculateMoneyIncome(_PlayerID);

        self.Data[_PlayerID].IncomeMoney = Income;
        self.Data[_PlayerID].UpkeepMoney = Upkeep;
        local IncomeReputation = ReputationPlus -ReputationMinus;
        self.Data[_PlayerID].IncomeReputation = math.floor(IncomeReputation);
        self.Data[_PlayerID].IncomeHonor = math.floor(HonorPlus);
    end
end

-- Calculate reputation increase
-- Reputation is produced by buildings and units.
-- Reputation can only increase if there are pepole at the fortress.
function Stronghold.Economy:CalculateReputationIncrease(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local WorkerCount = Logic.GetNumberOfAttractedWorker(_PlayerID);
        if WorkerCount > 0 then
            -- Tax height
            local TaxtHeight = GetTaxHeight(_PlayerID);
            self.Data[_PlayerID].ReputationDetails.TaxBonus = 0;
            if TaxtHeight == 1 then
                local TaxEffect = self.Config.Income.TaxEffect;
                local TaxBonus = TaxEffect[TaxtHeight].Reputation or 0;
                self.Data[_PlayerID].ReputationDetails.TaxBonus = TaxBonus;
            end

            -- Feeding settlers
            local FarmBonus = self.Data[_PlayerID].ReputationDetails.ProvidingCounter;
            local TavernBonus = self.Data[_PlayerID].ReputationDetails.BeverageCounter;
            local Providing = (FarmBonus + TavernBonus) / math.max(WorkerCount, 1);
            Providing = math.max(Providing, 0);
            if Providing >= 0 then
                self.Data[_PlayerID].ReputationDetails.Providing = Providing;
            end

            -- Housing settlers
            local HouseBonus = self.Data[_PlayerID].ReputationDetails.HousingCounter;
            local Housing = HouseBonus / math.max(WorkerCount, 1);
            Housing = math.max(Housing, 0);
            if Housing >= 0 then
                self.Data[_PlayerID].ReputationDetails.Housing = Housing;
            end

            -- Building bonuses
            local Beauty = 0;
            for k, v in pairs(self.Config.Income.Static) do
                local Buildings = GetBuildingsOfType(_PlayerID, k, true);
                local BuildingIncome = (Buildings[1] * v.Reputation);
                Beauty = Beauty + BuildingIncome;
            end
            self.Data[_PlayerID].ReputationDetails.Buildings = Beauty;
        else
            -- Reset all caches
            self.Data[_PlayerID].ReputationDetails.TaxBonus = 0;
            self.Data[_PlayerID].ReputationDetails.ProvidingCounter = 0;
            self.Data[_PlayerID].ReputationDetails.BeverageCounter = 0;
            self.Data[_PlayerID].ReputationDetails.Providing = 0;
            self.Data[_PlayerID].ReputationDetails.HousingCounter = 0;
            self.Data[_PlayerID].ReputationDetails.Housing = 0;
            self.Data[_PlayerID].ReputationDetails.Buildings = 0;
            self.Data[_PlayerID].ReputationDetails.OtherBonus = 0;
        end
    end
end

function Stronghold.Economy:CalculateReputationTechnologyBonus(_PlayerID, _Type)
    local Bonus = 0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        if self.Config.Income.Dynamic[_Type] then
            for Technology, Data in pairs(self.Config.Income.TechnologyEffect) do
                if Logic.IsTechnologyResearched(_PlayerID, Technology) == 1 then
                    if Data[_Type] then
                        Bonus = Bonus + (Data[_Type].Reputation or 0);
                    end
                end
            end
        end
    end
    return Bonus;
end

function Stronghold.Economy:CalculateReputationUpgradeFactor(_PlayerID, _Type)
    local Factor = 1.0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        if self.Config.Income.Dynamic[_Type].Reputation then
            Factor = Factor + (self.Config.Income.Dynamic[_Type].Reputation or 0);
        end
    end
    return Factor;
end

function Stronghold.Economy:CalculateReputationIncomeUpgradeBonus(_PlayerID, _EntityType)
    local Bonus = 0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        if self.Config.Income.Dynamic[_EntityType].Reputation then
            Bonus = self.Config.Income.Dynamic[_EntityType].Reputation or 0;
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
        local WorkerCount = Logic.GetNumberOfAttractedWorker(_PlayerID);
        if WorkerCount > 0 then
            local Rank = GetRank(_PlayerID) +1;
            local MaxRank = Stronghold.Player.Config.Base.MaxRank +1;

            -- Tax height
            local TaxPenalty = self:CalculateReputationTaxPenaltyAmount(
                _PlayerID,
                GetTaxHeight(_PlayerID)
            );
            self.Data[_PlayerID].ReputationDetails.TaxPenalty = TaxPenalty;

            -- Penalty for no food
            local NoFarm = self:GetNumberOfWorkerWithoutFarm(_PlayerID);
            local HungerPenalty = NoFarm * self.Config.Income.HungerFactor;
            local PenaltyFactor = self.Config.Income.PenaltyFactor;
            HungerPenalty = HungerPenalty + PenaltyFactor * (Rank / MaxRank);
            HungerPenalty = math.max(HungerPenalty, 0);
            HungerPenalty = GameCallback_SH_Calculate_HungerPenalty(_PlayerID, HungerPenalty);
            self.Data[_PlayerID].ReputationDetails.Hunger = math.min(HungerPenalty, 8);

            -- Penalty for no house
            local NoHouse = self:GetNumberOfWorkerWithoutHouse(_PlayerID);
            local SleepPenalty = NoHouse * self.Config.Income.InsomniaFactor;
            local PenaltyFactor = self.Config.Income.PenaltyFactor;
            SleepPenalty = SleepPenalty + PenaltyFactor * (Rank / MaxRank);
            SleepPenalty = math.max(SleepPenalty, 0);
            SleepPenalty = GameCallback_SH_Calculate_SleepPenalty(_PlayerID, SleepPenalty);
            self.Data[_PlayerID].ReputationDetails.Homelessness = math.min(SleepPenalty, 8);
        else
            -- Reset all caches
            self.Data[_PlayerID].ReputationDetails.TaxPenalty = 0;
            self.Data[_PlayerID].ReputationDetails.Hunger = 0;
            self.Data[_PlayerID].ReputationDetails.Homelessness = 0;
            self.Data[_PlayerID].ReputationDetails.Criminals = 0;
            self.Data[_PlayerID].ReputationDetails.Rats = 0;
            self.Data[_PlayerID].ReputationDetails.OtherMalus = 0;
        end
    end
end

function Stronghold.Economy:GetNumberOfWorkerWithoutFarm(_PlayerID)
    local Amount = Logic.GetNumberOfWorkerWithoutEatPlace(_PlayerID);
    if self.Data[_PlayerID].TemporaryFarm > 0 then
        Amount = math.max(Amount - self.Data[_PlayerID].TemporaryFarm, 0);
    end
    return Amount;
end

function Stronghold.Economy:AddTemporaryEatingPlace(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        self.Data[_PlayerID].TemporaryFarm = self.Data[_PlayerID].TemporaryFarm + _Amount;
    end
end

function Stronghold.Economy:GetNumberOfWorkerWithoutHouse(_PlayerID)
    local Amount = Logic.GetNumberOfWorkerWithoutSleepPlace(_PlayerID);
    if self.Data[_PlayerID].TemporaryFarm > 0 then
        Amount = math.max(Amount - self.Data[_PlayerID].TemporaryHouse, 0);
    end
    return Amount;
end

function Stronghold.Economy:AddTemporarySleepingPlace(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        self.Data[_PlayerID].TemporaryHouse = self.Data[_PlayerID].TemporaryHouse + _Amount;
    end
end

function Stronghold.Economy:CalculateReputationBonusAmount(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Special, ReputationOneshot;
        -- External bonus
        Special = GameCallback_SH_Calculate_ExternalReputationIncrease(_PlayerID);
        ReputationOneshot = self.Data[_PlayerID].IncomeReputationSingle;
        if ReputationOneshot > 0 then
            Special = Special + ReputationOneshot;
        end
        self.Data[_PlayerID].ReputationDetails.OtherBonus = Special;

        -- External malus
        Special = GameCallback_SH_Calculate_ExternalReputationDecrease(_PlayerID);
        local Criminals = Stronghold.Populace:GetReputationLossByCriminals(_PlayerID);
        local Rats = Stronghold.Populace:GetReputationLossByRats(_PlayerID);
        self.Data[_PlayerID].ReputationDetails.Criminals = Criminals;
        self.Data[_PlayerID].ReputationDetails.Rats = Rats;
        self.Data[_PlayerID].ReputationDetails.OtherMalus = Special - Criminals - Rats;
        ReputationOneshot = self.Data[_PlayerID].IncomeReputationSingle;
        if ReputationOneshot < 0 then
            Special = Special + ((-1) * ReputationOneshot);
        end
        self.Data[_PlayerID].ReputationDetails.OtherMalus = Special;
    end
    return 0;
end

function Stronghold.Economy:CalculateReputationTaxPenaltyAmount(_PlayerID, _TaxHeight)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Penalty = 0;
        if _TaxHeight > 1 then
            Penalty = (self.Config.Income.TaxEffect[_TaxHeight].Reputation or 0) * -1;
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
        if GetNobleID(_PlayerID) ~= 0 then
            local WorkerCount = Logic.GetNumberOfAttractedWorker(_PlayerID);
            if WorkerCount > 0 then
                -- Tax height
                local TaxHight = GetTaxHeight(_PlayerID);
                local TaxBonus = (self.Config.Income.TaxEffect[TaxHight].Honor or 0);
                self.Data[_PlayerID].HonorDetails.TaxBonus = TaxBonus;

                -- Feeding settlers
                local FarmBonus = self.Data[_PlayerID].HonorDetails.ProvidingCounter;
                local TavernBonus = self.Data[_PlayerID].HonorDetails.BeverageCounter;
                local Providing = (FarmBonus + TavernBonus) / math.max(WorkerCount, 1);
                if Providing >= 0 then
                    self.Data[_PlayerID].HonorDetails.Providing = Providing;
                end

                -- Housing settlers
                local HouseBonus = self.Data[_PlayerID].HonorDetails.HousingCounter;
                local Housing = HouseBonus / math.max(WorkerCount, 1);
                if Housing >= 0 then
                    self.Data[_PlayerID].HonorDetails.Housing = Housing;
                end

                -- Buildings bonuses
                local Beauty = 0;
                for k, v in pairs(self.Config.Income.Static) do
                    local Buildings = GetBuildingsOfType(_PlayerID, k, true);
                    local BuildingBonus = (Buildings[1] * v.Honor);
                    Beauty = Beauty + BuildingBonus
                end
                self.Data[_PlayerID].HonorDetails.Buildings = Beauty;

                -- External calculations
                local Special = GameCallback_SH_Calculate_ExternalHonorIncrease(_PlayerID);
                local HonorOneshot = self.Data[_PlayerID].IncomeHonorSingle;
                self.Data[_PlayerID].HonorDetails.OtherBonus = Special + HonorOneshot;
            else
                -- Reset all caches
                self.Data[_PlayerID].HonorDetails.Buildings = 0;
                self.Data[_PlayerID].HonorDetails.TaxBonus = 0;
                self.Data[_PlayerID].HonorDetails.HousingCounter = 0;
                self.Data[_PlayerID].HonorDetails.Housing = 0;
                self.Data[_PlayerID].HonorDetails.ProvidingCounter = 0;
                self.Data[_PlayerID].HonorDetails.BeverageCounter = 0;
                self.Data[_PlayerID].HonorDetails.Providing = 0;
                self.Data[_PlayerID].HonorDetails.Criminals = 0;
                self.Data[_PlayerID].HonorDetails.OtherBonus = 0;
            end
        end
    end
end

function Stronghold.Economy:CalculateHonorTechnologyBonus(_PlayerID, _Type)
    local Bonus = 0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        if self.Config.Income.Dynamic[_Type] then
            for Technology, Data in pairs(self.Config.Income.TechnologyEffect) do
                if Logic.IsTechnologyResearched(_PlayerID, Technology) == 1 then
                    if Data[_Type] then
                        Bonus = Bonus + (Data[_Type].Honor or 0);
                    end
                end
            end
        end
    end
    return Bonus;
end

function Stronghold.Economy:CalculateHonorUpgradeFactor(_PlayerID, _Type)
    local Factor = 1.0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        if self.Config.Income.Dynamic[_Type].Honor then
            Factor = Factor + (self.Config.Income.Dynamic[_Type].Honor or 0);
        end
    end
    return Factor;
end

-- Calculate tax income
-- The tax income is mostly unchanged. A worker pays x gold times the tax level.
-- If scale is researched, then taxes are increased by 5%.
function Stronghold.Economy:CalculateMoneyIncome(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local TaxPerWorker = Logic.GetPlayerRegularTaxPerWorker(_PlayerID);
        local WorkerAmount = Logic.GetNumberOfAttractedWorker(_PlayerID);
        local Income = TaxPerWorker * WorkerAmount;
        if Logic.IsTechnologyResearched(_PlayerID,Technologies.T_Scale) == 1 then
            Income = Income * self.Config.Income.ScaleBonusFactor;
        end
        Income = GameCallback_SH_Calculate_TotalPaydayIncome(_PlayerID, Income);
        return math.floor(Income + 0.5);
    end
    return 0;
end

-- Calculate unit upkeep
-- The upkeep is not for the leader himself.
function Stronghold.Economy:CalculateMoneyUpkeep(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Upkeep = Logic.GetPlayerPaydayLeaderCosts(_PlayerID);
        Upkeep = GameCallback_SH_Calculate_TotalPaydayUpkeep(_PlayerID, Upkeep);
        for Type, _ in pairs (Stronghold.Unit.Config.Troops) do
            local Leaders = GetLeadersOfType(_PlayerID, Type);
            if Leaders[1] > 0 then
                local UnitCost = Logic.LeaderGetUpkeepCost(Leaders[2]);
                Upkeep = Upkeep - (UnitCost * Leaders[1]);
                UnitCost = GameCallback_SH_Calculate_PaydayUpkeep(_PlayerID, Type, UnitCost * Leaders[1]);
                Upkeep = Upkeep + UnitCost;
            end
            local Cannons = GetCannonsOfType(_PlayerID, Type);
            if Cannons[1] > 0 then
                local UnitCost = Logic.LeaderGetUpkeepCost(Cannons[2]);
                Upkeep = Upkeep - (UnitCost * Cannons[1]);
                UnitCost = GameCallback_SH_Calculate_PaydayUpkeep(_PlayerID, Type, UnitCost * Cannons[1]);
                Upkeep = Upkeep + UnitCost;
            end
        end
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
-- Influence Points

function Stronghold.Economy:AddPlayerInfluencePoints(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local InfluencePoints = self:GetPlayerInfluencePoints(_PlayerID);
        InfluencePoints = math.max(InfluencePoints + _Amount, 0);
        InfluencePoints = math.min(InfluencePoints, self:GetPlayerInfluencePointsPointsLimit(_PlayerID));
        self.Data[_PlayerID].InfluencePoints = InfluencePoints;
    end
end

function Stronghold.Economy:GetPlayerInfluencePoints(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        return self.Data[_PlayerID].InfluencePoints;
    end
    return 0;
end

function Stronghold.Economy:GetPlayerInfluencePointsPointsLimit(_PlayerID)
    return self.Config.Income.MaxInfluencePoints;
end

function Stronghold.Economy:GainInfluencePoints(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local InfluencePoints = 0;
        local WorkerCount = Logic.GetNumberOfAttractedWorker(_PlayerID);
        local FestivalLevel = GetFestivalLevel(_PlayerID);
        local NobleID = GetNobleID(_PlayerID);
        local CastleID = GetHeadquarterID(_PlayerID);
        if WorkerCount > 0 then
            if  (NobleID ~= 0 and CastleID ~= 0 and FestivalLevel > 0)
            and not IsBuildingBeingUpgraded(CastleID) then
                local Reputation = GetReputation(_PlayerID);
                local Rank = GetRank(_PlayerID);
                local BaseInfluence = self.Config.Income.InfluenceBase;
                local RankInfluence = self.Config.Income.InfluenceRank;
                local Influence = BaseInfluence + (RankInfluence * Rank);
                -- Hard cap influence base groth
                if Influence > self.Config.Income.InfluenceRiseCap then
                    Influence = self.Config.Income.InfluenceRiseCap;
                end
                InfluencePoints = Influence * math.log(12 * Reputation);
            else
                self.Data[_PlayerID].InfluencePoints = 0;
            end
        end
        InfluencePoints = GameCallback_SH_Calculate_InfluenceIncrease(_PlayerID, InfluencePoints);
        self:AddPlayerInfluencePoints(_PlayerID, InfluencePoints);
    end
end

-- -------------------------------------------------------------------------- --
-- Providing

function Stronghold.Economy:OnUnknownTaskInFarm(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if IsPlayer(PlayerID) then
        if  Logic.IsSettler(_EntityID) == 1
        and Logic.IsSettlerAtFarm(_EntityID) == 1 then
            local RationLevel = GetRationLevel(PlayerID);
            local BuildingID = Logic.GetSettlersFarm(_EntityID);
            local EntityType = Logic.GetEntityType(BuildingID);
            if EntityType == Entities.PB_Farm1
            or EntityType == Entities.PB_Farm2
            or EntityType == Entities.PB_Farm3 then
                local TechBonus, UpgradeFactor, RationEffect, EaterCounter;

                -- Reputation
                TechBonus = self:CalculateReputationTechnologyBonus(PlayerID, EntityType);
                UpgradeFactor = self:CalculateReputationUpgradeFactor(PlayerID, EntityType);
                RationEffect = self.Config.Income.Rations[RationLevel].Reputation or 0;
                EaterCounter = 0;
                if RationEffect + TechBonus ~= 0 then
                    EaterCounter = self.Data[PlayerID].ReputationDetails.ProvidingCounter;
                    EaterCounter = EaterCounter + ((RationEffect + TechBonus) * UpgradeFactor);
                    EaterCounter = GameCallback_SH_Calculate_ServiceReputationIncrease(PlayerID, EntityType, EaterCounter);
                end
                self.Data[PlayerID].ReputationDetails.ProvidingCounter = EaterCounter;

                -- Honor
                TechBonus = self:CalculateHonorTechnologyBonus(PlayerID, EntityType);
                UpgradeFactor = self:CalculateHonorUpgradeFactor(PlayerID, EntityType);
                RationEffect = (self.Config.Income.Rations[RationLevel].Honor or 0);
                EaterCounter = 0;
                if RationEffect + TechBonus ~= 0 then
                    EaterCounter = self.Data[PlayerID].HonorDetails.ProvidingCounter;
                    EaterCounter = EaterCounter + ((RationEffect + TechBonus) * UpgradeFactor);
                    EaterCounter = GameCallback_SH_Calculate_ServiceHonorIncrease(PlayerID, EntityType, EaterCounter);
                end
                self.Data[PlayerID].HonorDetails.ProvidingCounter = EaterCounter;

                -- Stamina
                local Factor = self.Config.Income.Rations[RationLevel].Stamina or 0;
                local MaxStamina = CEntity.GetMaxStamina(_EntityID);
                local Stamina = CEntity.GetCurrentStamina(_EntityID);
                SetEntityStamina(_EntityID, Stamina + (MaxStamina * Factor));

                return TaskAdvancementType.Immediately;
            end
        end
    end
end

function Stronghold.Economy:OnUnknownTaskInTavern(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if IsPlayer(PlayerID) then
        if  Logic.IsSettler(_EntityID) == 1
        and Logic.IsSettlerAtFarm(_EntityID) == 1 then
            local BeverageLevel = GetBeverageLevel(PlayerID);
            local BuildingID = Logic.GetSettlersFarm(_EntityID);
            local EntityType = Logic.GetEntityType(BuildingID);
            if EntityType == Entities.PB_Tavern1
            or EntityType == Entities.PB_Tavern2 then
                local TechBonus, UpgradeFactor, BeverageEffect, DrinkerCounter;

                -- Reputation
                TechBonus = self:CalculateReputationTechnologyBonus(PlayerID, EntityType);
                UpgradeFactor = self:CalculateReputationUpgradeFactor(PlayerID, EntityType);
                BeverageEffect = self.Config.Income.Beverage[BeverageLevel].Reputation or 0;
                DrinkerCounter = 0;
                if BeverageEffect + TechBonus ~= 0 then
                    DrinkerCounter = self.Data[PlayerID].ReputationDetails.BeverageCounter;
                    DrinkerCounter = DrinkerCounter + ((BeverageEffect + TechBonus) * UpgradeFactor);
                    DrinkerCounter = GameCallback_SH_Calculate_ServiceReputationIncrease(PlayerID, EntityType, DrinkerCounter);
                end
                self.Data[PlayerID].ReputationDetails.BeverageCounter = DrinkerCounter;

                -- Honor
                TechBonus = self:CalculateHonorTechnologyBonus(PlayerID, EntityType);
                UpgradeFactor = self:CalculateHonorUpgradeFactor(PlayerID, EntityType);
                BeverageEffect = 0;
                DrinkerCounter = 0;
                -- (The tavern mirrors reputation onto honor if technology
                --  T_Instruments is researched.)
                if Logic.IsTechnologyResearched(PlayerID, Technologies.T_Instruments) == 1 then
                    BeverageEffect = self.Config.Income.Beverage[BeverageLevel].Reputation or 0;
                end
                if BeverageEffect + TechBonus ~= 0 then
                    DrinkerCounter = self.Data[PlayerID].HonorDetails.BeverageCounter;
                    DrinkerCounter = DrinkerCounter + ((BeverageEffect + TechBonus) * UpgradeFactor);
                    DrinkerCounter = GameCallback_SH_Calculate_ServiceHonorIncrease(PlayerID, EntityType, DrinkerCounter);
                end
                self.Data[PlayerID].HonorDetails.BeverageCounter = DrinkerCounter;

                -- Stamina
                local Factor = self.Config.Income.Beverage[BeverageLevel].Stamina or 0;
                local MaxStamina = CEntity.GetMaxStamina(_EntityID);
                local Stamina = CEntity.GetCurrentStamina(_EntityID);
                SetEntityStamina(_EntityID, Stamina + (MaxStamina * Factor));

                return TaskAdvancementType.Immediately;
            end
        end
    end
end

function Stronghold.Economy:OnUnknownTaskInHouse(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if IsPlayer(PlayerID) then
        if  Logic.IsSettler(_EntityID) == 1
        and Logic.IsSettlerAtResidence(_EntityID) == 1 then
            local SleepTimeLevel = GetSleepTimeLevel(PlayerID);
            local BuildingID = Logic.GetSettlersResidence(_EntityID);
            local EntityType = Logic.GetEntityType(BuildingID);
            if EntityType == Entities.PB_Residence1
            or EntityType == Entities.PB_Residence2
            or EntityType == Entities.PB_Residence3 then
                local TechBonus, UpgradeFactor, SleepEffect, SleepCounter;

                -- Reputation
                TechBonus = self:CalculateReputationTechnologyBonus(PlayerID, EntityType);
                UpgradeFactor = self:CalculateReputationUpgradeFactor(PlayerID, EntityType);
                SleepEffect = self.Config.Income.SleepTime[SleepTimeLevel].Reputation or 0;
                SleepCounter = 0;
                if SleepEffect + TechBonus ~= 0 then
                    SleepCounter = self.Data[PlayerID].ReputationDetails.HousingCounter;
                    SleepCounter = SleepCounter + ((SleepEffect + TechBonus) * UpgradeFactor);
                    SleepCounter = GameCallback_SH_Calculate_ServiceReputationIncrease(PlayerID, EntityType, SleepCounter);
                end
                self.Data[PlayerID].ReputationDetails.HousingCounter = SleepCounter;

                -- Honor
                TechBonus = self:CalculateHonorTechnologyBonus(PlayerID, EntityType);
                UpgradeFactor = self:CalculateHonorUpgradeFactor(PlayerID, EntityType);
                SleepEffect = (self.Config.Income.SleepTime[SleepTimeLevel].Honor or 0);
                SleepCounter = 0;
                if SleepEffect + TechBonus ~= 0 then
                    SleepCounter = self.Data[PlayerID].HonorDetails.HousingCounter;
                    SleepCounter = SleepCounter + ((SleepEffect + TechBonus) * UpgradeFactor);
                    SleepCounter = GameCallback_SH_Calculate_ServiceHonorIncrease(PlayerID, EntityType, SleepCounter);
                end
                self.Data[PlayerID].HonorDetails.HousingCounter = SleepCounter;

                -- Stamina
                local Factor = self.Config.Income.SleepTime[SleepTimeLevel].Stamina or 0;
                local MaxStamina = CEntity.GetMaxStamina(_EntityID);
                local Stamina = CEntity.GetCurrentStamina(_EntityID);
                SetEntityStamina(_EntityID, Stamina + (MaxStamina * Factor));

                return TaskAdvancementType.Immediately;
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Knowledge Points

function Stronghold.Economy:AddPlayerKnowledge(_PlayerID, _Amount)
    if _Amount > 0 then
        Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.Knowledge, _Amount);
    elseif _Amount < 0 then
        Logic.SubFromPlayersGlobalResource(_PlayerID, ResourceType.Knowledge, _Amount);
    end
    GameCallback_SH_Logic_KnowledgeGained(_PlayerID, _Amount);
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
        local ScholarList = GetWorkersOfType(_PlayerID, Entities.PU_Scholar);
        for i= 2, ScholarList[1] +1 do
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
            Stronghold.Player:SetPlayerReputation(PlayerID, 50);
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
-- Wood Piles

function Stronghold.Economy:CreateWoodPile(_Entity, _Resources)
    assert(type(_Entity) == "string");
    assert(type(_Resources) == "number");
    local x,y,z = Logic.EntityGetPos(GetID(_Entity));
    local PileID = Logic.CreateEntity(Entities.XD_Rock3, x, y, 0, 0);
    Logic.SetEntityName(PileID, _Entity.."_WoodPile");
    Logic.SetModelAndAnimSet(PileID, Models.Effects_XF_ExtractStone);
    local ResID = ReplaceEntity(_Entity, Entities.XD_ResourceTree);
    Logic.SetModelAndAnimSet(ResID, Models.XD_SignalFire1);
    Logic.SetResourceDoodadGoodAmount(GetID(_Entity), _Resources*15);

    self.Data.WoodPiles[_Entity] = {
        ResourceEntity = _Entity,
        PileEntity = _Entity.."_WoodPile",
        ResourceLimit = _Resources*14,
    };
end

function Stronghold.Economy:DestroyWoodPile(_Entity)
    if self.Data.WoodPiles[_Entity] then
        local Data = self.Data.WoodPiles[_Entity];
        local x,y,z = Logic.EntityGetPos(GetID(Data.ResourceEntity));
        DestroyEntity(Data.ResourceEntity);
        DestroyEntity(Data.PileEntity);
        Logic.CreateEffect(GGL_Effects.FXCrushBuilding, x, y, 0);
        self.Data.WoodPiles[_Entity] = nil;
    end
end

function Stronghold.Economy:IsWoodPile(_Entity)
    if type(_Entity) == "number" then
        _Entity = Logic.GetEntityName(_Entity);
    end
    return self.Data.WoodPiles[_Entity] ~= nil;
end

function Stronghold.Economy:ControlWoodPiles()
    for Entity, Data in pairs(self.Data.WoodPiles) do
        local ID = GetID(Entity);
        if Logic.GetResourceDoodadGoodAmount(ID) <= Data.ResourceLimit then
            self:DestroyWoodPile(Entity);
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

    -- External changes
    Amount, Remaining = GameCallback_SH_Calculate_SerfExtraction(_PlayerID, _SerfID, _SourceID, _ResourceType, Amount, Remaining);
    -- Reduce resource in trees
    if _ResourceType == ResourceType.WoodRaw and Remaining > 46 then
        if not self:IsWoodPile(_SourceID) then
            Remaining = 46;
        end
    end

    if Remaining ~= ResourceAmount then
        Logic.SetResourceDoodadGoodAmount(_SourceID, Remaining);
    end

    -- Raw silver becomes raw wood
    if _ResourceType == ResourceType.SilverRaw then
        Logic.SubFromPlayersGlobalResource(_PlayerID, ResourceType.SilverRaw, Amount);
        Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.WoodRaw, Amount);
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
    end
    if _ResourceType == ResourceType.IronRaw then
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PickAxeIron) == 1 then
            Amount = Amount + self.Config.Resource.Mining.PickaxeIronBonus;
        end
    end
    if _ResourceType == ResourceType.StoneRaw then
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PickAxeStone) == 1 then
            Amount = Amount + self.Config.Resource.Mining.PickaxeStoneBonus;
        end
    end
    if _ResourceType == ResourceType.SulfurRaw then
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PickAxeSulfur) == 1 then
            Amount = Amount + self.Config.Resource.Mining.PickaxeSulfurBonus;
        end
    end
    if _ResourceType == ResourceType.WoodRaw then
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_PickAxeWood) == 1 then
            Amount = Amount + self.Config.Resource.Mining.PickaxeWoodBonus;
        end
    end

    -- External changes
    Amount, Remaining = GameCallback_SH_Calculate_ResourceMined(_PlayerID, _BuildingID, _SourceID, _ResourceType, Amount, Remaining);

    if Remaining ~= ResourceAmount then
        Logic.SetResourceDoodadGoodAmount(_SourceID, Remaining);
    end
    -- Raw silver becomes raw wood
    if _ResourceType == ResourceType.SilverRaw then
        Logic.SubFromPlayersGlobalResource(_PlayerID, ResourceType.SilverRaw, Amount);
        Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.WoodRaw, Amount);
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
        Stronghold.Economy:UpdateFindViewButtons();
        GUIUpdate_SocialResource(1);
        GUIUpdate_SocialResource(2);
        GUIUpdate_SocialResource(3);
        -- GUIUpdate_SocialResource(4);
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
    if ScreenSize[2] < 960 then
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
        if IsPlayer(_PlayerID) then
            Stronghold.Economy.Data[_PlayerID].HonorDetails.ProvidingCounter = 0;
            Stronghold.Economy.Data[_PlayerID].HonorDetails.BeverageCounter = 0;
            Stronghold.Economy.Data[_PlayerID].HonorDetails.HousingCounter = 0;
            Stronghold.Economy.Data[_PlayerID].ReputationDetails.ProvidingCounter = 0;
            Stronghold.Economy.Data[_PlayerID].ReputationDetails.BeverageCounter = 0;
            Stronghold.Economy.Data[_PlayerID].ReputationDetails.HousingCounter = 0;

            Stronghold.Economy.Data[_PlayerID].IncomeReputationSingle = 0;
            Stronghold.Economy.Data[_PlayerID].IncomeHonorSingle = 0;
            Stronghold.Economy.Data[_PlayerID].TemporaryFarm = 0;
            Stronghold.Economy.Data[_PlayerID].TemporaryHouse = 0;
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

    Overwrite.CreateOverwrite("GUIUpdate_TaxWorkerAmount", function()
        local PlayerID = GetLocalPlayerID();
        if not IsPlayer(PlayerID) then
            return Overwrite.CallOriginal();
        end
        local NumerOfWorkers = Logic.GetNumberOfAttractedWorker(PlayerID);
        XGUIEng.SetText( "TaxWorkerAmount", ""..NumerOfWorkers);
    end);

    Overwrite.CreateOverwrite("GUIUpdate_ResidencePlaces", function()
        Overwrite.CallOriginal();
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local ScreenSize = {GUI.GetScreenSize()};
        if ScreenSize[2] < 960 then
            XGUIEng.SetWidgetPosition(CurrentWidgetID, 0, 0);
        end
    end);

    Overwrite.CreateOverwrite("GUIUpdate_FarmPlaces", function()
        Overwrite.CallOriginal();
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local ScreenSize = {GUI.GetScreenSize()};
        if ScreenSize[2] < 960 then
            XGUIEng.SetWidgetPosition(CurrentWidgetID, 0, 0);
        end
    end);

    Overwrite.CreateOverwrite("GUIUpdate_ResourceAmount", function(_Type, _RefinedFlag)
        Overwrite.CallOriginal();
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local ScreenSize = {GUI.GetScreenSize()};
        if ScreenSize[2] < 960 then
            local y = (_Type == ResourceType.Gold and 2) or 0;
            XGUIEng.SetWidgetPosition(CurrentWidgetID, 39, y);
        end
    end);

    function GUIUpdate_Population()
        local PlayerID = GetLocalPlayerID();
        local Usage = GetCivilAttractionUsage(PlayerID);
        local Limit = GetCivilAttractionLimit(PlayerID);
        local Color = (Usage < Limit and "") or " @color:255,120,120,255 ";
        XGUIEng.SetText("PopulationPlaces", Color.. " @ra " ..Usage.. "/" ..Limit);
        local ScreenSize = {GUI.GetScreenSize()};
        if ScreenSize[2] < 960 then
            XGUIEng.SetWidgetPosition("PopulationPlaces", 0, 0);
        end
    end

    function GUIUpdate_Military()
        local PlayerID = GetLocalPlayerID();
        local Usage = GetMilitaryAttractionUsage(PlayerID);
        local Limit = GetMilitaryAttractionLimit(PlayerID);
        local Color = (Usage < Limit and "") or " @color:255,120,120,255 ";
        XGUIEng.SetText("MilitaryPlaces", Color.. " @ra " ..Usage.. "/" ..Limit);
        local ScreenSize = {GUI.GetScreenSize()};
        if ScreenSize[2] < 960 then
            XGUIEng.SetWidgetPosition("MilitaryPlaces", 0, 0);
        end
    end

    function GUIUpdate_Slaves()
        local PlayerID = GetLocalPlayerID();
        local CivilUsage = GetCivilAttractionUsage(PlayerID);
        local CivilLimit = GetCivilAttractionLimit(PlayerID);
        local SlaveUsage = GetSlaveAttractionUsage(PlayerID);
        local SlaveLimit = GetSlaveAttractionLimit(PlayerID);
        local Color = " @color:255,120,120,255 ";
        if SlaveUsage < SlaveLimit and CivilUsage < CivilLimit then
            Color = "";
        end
        XGUIEng.SetText("SlavePlaces", Color.. " @ra " ..SlaveUsage.. "/" ..SlaveLimit);
        local ScreenSize = {GUI.GetScreenSize()};
        if ScreenSize[2] < 960 then
            XGUIEng.SetWidgetPosition("SlavePlaces", 0, 0);
        end
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
        Upkeep = Upkeep + self:GetUpkeepForSpearmen(_PlayerID);
    elseif _Key == "MenuTop/Find_sword" then
        Upkeep = Upkeep + self:GetUpkeepForSwordmen(_PlayerID);
    elseif _Key == "MenuTop/Find_bow" then
        Upkeep = Upkeep + self:GetUpkeepForBowmen(_PlayerID);
    elseif _Key == "MenuTop/Find_cannon" then
        Upkeep = Upkeep + self:GetUpkeepForCannons(_PlayerID);
    elseif _Key == "MenuTop/Find_lightcavalry" then
        Upkeep = Upkeep + self:GetUpkeepForLightCavalry(_PlayerID);
    elseif _Key == "MenuTop/Find_heavycavalry" then
        Upkeep = Upkeep + self:GetUpkeepForHeavyCavalry(_PlayerID);
    elseif _Key == "AOMenuTop/Find_rifle" then
        Upkeep = Upkeep + self:GetUpkeepForRiflemen(_PlayerID);
    elseif _Key == "AOMenuTop/Find_scout" then
        Upkeep = Upkeep + self:GetUpkeepForScouts(_PlayerID);
    elseif _Key == "AOMenuTop/Find_Thief" then
        Upkeep = Upkeep + self:GetUpkeepForRouges(_PlayerID);
    else
        return false;
    end

    local UpkeepText = XGUIEng.GetStringTableText("sh_text/UI_FindView");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text .. string.format(UpkeepText, Upkeep));
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

function Stronghold.Economy:GetUpkeepForSpearmen(_PlayerID)
    if not IsPlayer(_PlayerID) then
        return 0;
    end
    return (self.Data[_PlayerID].UpkeepDetails[Entities.CU_TemplarLeaderPoleArm1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm2] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm3] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderPoleArm4] or 0);
end

function Stronghold.Economy:GetUpkeepForSwordmen(_PlayerID)
    if not IsPlayer(_PlayerID) then
        return 0;
    end
    return (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BanditLeaderSword1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BanditLeaderSword2] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BanditLeaderSword3] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BlackKnight_LeaderMace1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BlackKnight_LeaderMace2] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.CU_Barbarian_LeaderClub1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.CU_Barbarian_LeaderClub2] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.CU_Evil_LeaderBearman1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderAxe1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderAxe2] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderAxe3] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderAxe4] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword2] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword3] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderSword4] or 0);
end

function Stronghold.Economy:GetUpkeepForBowmen(_PlayerID)
    if not IsPlayer(_PlayerID) then
        return 0;
    end
    return (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BanditLeaderBow1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.CU_Evil_LeaderSkirmisher1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow2] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow3] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderBow4] or 0);
end

function Stronghold.Economy:GetUpkeepForCannons(_PlayerID)
    if not IsPlayer(_PlayerID) then
        return 0;
    end
    return (self.Data[_PlayerID].UpkeepDetails[Entities.CV_Cannon1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.CV_Cannon2] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon2] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon3] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon4] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon7] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PV_Cannon8] or 0);
end

function Stronghold.Economy:GetUpkeepForLightCavalry(_PlayerID)
    if not IsPlayer(_PlayerID) then
        return 0;
    end
    return (self.Data[_PlayerID].UpkeepDetails[Entities.CU_BanditLeaderCavalry1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.CU_TemplarLeaderCavalry1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderCavalry1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderCavalry2] or 0);
end

function Stronghold.Economy:GetUpkeepForHeavyCavalry(_PlayerID)
    if not IsPlayer(_PlayerID) then
        return 0;
    end
    return (self.Data[_PlayerID].UpkeepDetails[Entities.CU_TemplarLeaderHeavyCavalry1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderHeavyCavalry1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderHeavyCavalry2] or 0);
end

function Stronghold.Economy:GetUpkeepForRiflemen(_PlayerID)
    if not IsPlayer(_PlayerID) then
        return 0;
    end
    return (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderRifle1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_LeaderRifle2] or 0);
end

function Stronghold.Economy:GetUpkeepForScouts(_PlayerID)
    if not IsPlayer(_PlayerID) then
        return 0;
    end
    return (self.Data[_PlayerID].UpkeepDetails[Entities.PU_Scout] or 0);
end

function Stronghold.Economy:GetUpkeepForRouges(_PlayerID)
    if not IsPlayer(_PlayerID) then
        return 0;
    end
    return (self.Data[_PlayerID].UpkeepDetails[Entities.CU_Assassin_LeaderKnife1] or 0) +
           (self.Data[_PlayerID].UpkeepDetails[Entities.PU_Thief] or 0);
end

function Stronghold.Economy:UpdateFindViewAmount(_PlayerID)
    for _, TypeList in pairs(self.Config.SelectCategoryMapping) do
        for _, Type in pairs(TypeList) do
            local Costs = 0;
            local Leaders = GetLeadersOfType(_PlayerID, Type);
            if Leaders[1] > 0 then
                Costs = Logic.LeaderGetUpkeepCost(Leaders[2]) * Leaders[1];
            end
            self.Data[_PlayerID].UpkeepDetails[Type] = Costs;
        end
    end
end

function Stronghold.Economy:UpdateFindViewButtons()
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    local Upkeep;

    PlayerID = (PlayerID == 0 and GuiPlayer) or PlayerID;
    if PlayerID == 17 then
        XGUIEng.ShowAllSubWidgets("FindView", 0);
        return;
    end

    XGUIEng.ShowWidget("FindView", 1);
    Upkeep = self:GetUpkeepForSpearmen(PlayerID);
    XGUIEng.ShowWidget("FindSpearmen", (Upkeep > 0 and 1) or 0);
    Upkeep = self:GetUpkeepForSwordmen(PlayerID);
    XGUIEng.ShowWidget("FindSwordmen", (Upkeep > 0 and 1) or 0);
    Upkeep = self:GetUpkeepForBowmen(PlayerID);
    XGUIEng.ShowWidget("FindBowmen", (Upkeep > 0 and 1) or 0);
    Upkeep = self:GetUpkeepForCannons(PlayerID);
    XGUIEng.ShowWidget("FindCannon", (Upkeep > 0 and 1) or 0);
    Upkeep = self:GetUpkeepForLightCavalry(PlayerID);
    XGUIEng.ShowWidget("FindLightCavalry", (Upkeep > 0 and 1) or 0);
    Upkeep = self:GetUpkeepForHeavyCavalry(PlayerID);
    XGUIEng.ShowWidget("FindHeavyCavalry", (Upkeep > 0 and 1) or 0);
    Upkeep = self:GetUpkeepForRiflemen(PlayerID);
    XGUIEng.ShowWidget("FindRiflemen", (Upkeep > 0 and 1) or 0);
    Upkeep = self:GetUpkeepForScouts(PlayerID);
    XGUIEng.ShowWidget("FindScout", (Upkeep > 0 and 1) or 0);
    Upkeep = self:GetUpkeepForRouges(PlayerID);
    XGUIEng.ShowWidget("FindThief", (Upkeep > 0 and 1) or 0);
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
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local PlayerID = Logic.EntityGetPlayer(EntityID);

    PlayerID = (PlayerID == 0 and GuiPlayer) or PlayerID;
    if PlayerID == 17 then
        return;
    end

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
            XGUIEng.SetWidgetSize("TooltipTop", 172, 430);
            XGUIEng.SetWidgetPositionAndSize("TooltipTopText", 4, 3, 164, 427);
            XGUIEng.SetWidgetSize("TooltipTopBackground", 172, 430);
            XGUIEng.SetMaterialTexture("TooltipTopBackground", 1, ExtGraphic);
        else
            -- Get Text
            local Text = self:FormatPaydayClockText(_PlayerID);
            AmendText = " @cr @cr " .. Placeholder.Replace(Text);
            -- Resize
            XGUIEng.SetWidgetSize("TooltipTop", 172, 104);
            XGUIEng.SetWidgetPositionAndSize("TooltipTopText", 4, 3, 164, 101);
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
        ((ihon < 0 and "{scarlet}") or "{green}+") ..ihon,
        -- Reputation
        ((irep < 0 and "{scarlet}") or "{green}+") ..irep
    );
end

function Stronghold.Economy:FormatExtendedPaydayClockText(_PlayerID)
    local Language = GetLanguage();
    local Screen = {GUI.GetScreenSize()};
    local div = string.rep("-", (Screen[1] >= 1900 and 22) or (Screen[1] >= 1200 and 11) or 0);

    local ihon = math.floor(self.Data[_PlayerID].IncomeHonor);
    local htb  = math.floor(self.Data[_PlayerID].HonorDetails.TaxBonus);
    local hbb  = math.floor(self.Data[_PlayerID].HonorDetails.Buildings);
    local hho  = math.floor(self.Data[_PlayerID].HonorDetails.Housing);
    local hpr  = math.floor(self.Data[_PlayerID].HonorDetails.Providing);
    local hob  = math.floor(self.Data[_PlayerID].HonorDetails.OtherBonus);

    local irep = math.floor(self.Data[_PlayerID].IncomeReputation);
    local ptb  = math.floor(self.Data[_PlayerID].ReputationDetails.TaxBonus);
    local pbb  = math.floor(self.Data[_PlayerID].ReputationDetails.Buildings);
    local ppr  = math.floor(self.Data[_PlayerID].ReputationDetails.Providing);
    local pho  = math.floor(self.Data[_PlayerID].ReputationDetails.Housing);
    local pob  = math.floor(self.Data[_PlayerID].ReputationDetails.OtherBonus);
    local ptp  = (-1) * math.floor(self.Data[_PlayerID].ReputationDetails.TaxPenalty);
    local phu  = (-1) * math.floor(self.Data[_PlayerID].ReputationDetails.Hunger);
    local phs  = (-1) * math.floor(self.Data[_PlayerID].ReputationDetails.Homelessness);
    local pcr  = (-1) * math.floor(self.Data[_PlayerID].ReputationDetails.Criminals);
    local prt  = (-1) * math.floor(self.Data[_PlayerID].ReputationDetails.Rats);
    local pop  = (-1) * math.floor(self.Data[_PlayerID].ReputationDetails.OtherMalus);

    return string.format(
        self.Text.PaydayClock[2][Language],
        -- Honor
        ((htb > 0 and "{green}+") or "{white}") ..string.format("%.0f", htb),
        ((hbb > 0 and "{green}+") or "{white}") ..string.format("%.0f", hbb),
        ((hpr > 0 and "{green}+") or "{white}") ..string.format("%.0f", hpr),
        ((hho > 0 and "{green}+") or "{white}") ..string.format("%.0f", hho),
        ((hob > 0 and "{green}+") or "{white}") ..string.format("%.0f", hob),
        div,
        --
        ((ihon < 0 and "{scarlet}") or "{green}+") ..ihon,
        --
        ((ptb > 0 and "{green}+") or "{white}") ..string.format("%.0f", ptb),
        ((pbb > 0 and "{green}+") or "{white}") ..string.format("%.0f", pbb),
        ((ppr > 0 and "{green}+") or "{white}") ..string.format("%.0f", ppr),
        ((pho > 0 and "{green}+") or "{white}") ..string.format("%.0f", pho),
        ((pob > 0 and "{green}+") or "{white}") ..string.format("%.0f", pob),
        div,
        --
        ((ptp < 0 and "{scarlet}") or "{white}") ..string.format("%.0f", ptp),
        ((phu < 0 and "{scarlet}") or "{white}") ..string.format("%.0f", phu),
        ((phs < 0 and "{scarlet}") or "{white}") ..string.format("%.0f", phs),
        ((pcr < 0 and "{scarlet}") or "{white}") ..string.format("%.0f", pcr),
        ((prt < 0 and "{scarlet}") or "{white}") ..string.format("%.0f", prt),
        ((pop < 0 and "{scarlet}") or "{white}") ..string.format("%.0f", pop),
        div,
        --
        ((irep < 0 and "{scarlet}") or "{green}+") ..irep
    );
end

