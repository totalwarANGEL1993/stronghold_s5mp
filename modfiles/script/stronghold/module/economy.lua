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
                [4] = {Honor = 0, Reputation = -10,},
                [5] = {Honor = 0, Reputation = -16,},
            },

            Dynamic = {
                [Entities.PB_Farm2]      = {Honor = 0.15, Reputation = 0.06,},
                [Entities.PB_Farm3]      = {Honor = 0.21, Reputation = 0.09,},
                ---
                [Entities.PB_Residence2] = {Honor = 0.06, Reputation = 0.15,},
                [Entities.PB_Residence3] = {Honor = 0.09, Reputation = 0.21,},
                ---
                [Entities.PB_Tavern1]    = {Honor = 0, Reputation = 0.40,},
                [Entities.PB_Tavern2]    = {Honor = 0, Reputation = 0.50,},
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
                [Entities.PB_Monastery1]       = {Honor = 0, Reputation = 6,},
                [Entities.PB_Monastery2]       = {Honor = 0, Reputation = 9,},
                [Entities.PB_Monastery3]       = {Honor = 0, Reputation = 12,},
            },
        },

        Text = {
            CourtClerk = {
                [1] = {
                    de = "Hofschreiber",
                    en = "Court Clerk",
                },
                [2] = {
                    de = "{white}Erwartete Ehre: %s{cr}"..
                         "{none}___{grey}Steuer: %s{cr}"..
                         "{none}___{grey}Gebäude: %s{cr}"..
                         "{none}___{grey}Versorgung: %s{cr}"..
                         "{none}___{grey}Obdach: %s{cr}"..
                         "{none}___{grey}Spezial: %s{cr}{cr}"..
                         "{white}Erwartete Beliebtheit: %s{cr}"..
                         "{none}___{grey}Steuer: %s{cr}"..
                         "{none}___{grey}Gesetz: %s{cr}"..
                         "{none}___{grey}Gebäude: %s{cr}"..
                         "{none}___{grey}Versorgung: %s{cr}"..
                         "{none}___{grey}Obdach: %s{cr}"..
                         "{none}___{grey}Spezial: %s",
                    en = "{white}Expected Honor: %s{cr}"..
                         "{none}___{grey}Tax: %s{cr}"..
                         "{none}___{grey}Buildings: %s{cr}"..
                         "{none}___{grey}Providing: %s{cr}"..
                         "{none}___{grey}Housing: %s{cr}"..
                         "{none}___{grey}Special: %s{cr}{cr}"..
                         "{white}Expected Reputation: %s{cr}"..
                         "{none}___{grey}Tax: %s{cr}"..
                         "{none}___{grey}Law & Order: %s{cr}"..
                         "{none}___{grey}Buildings: %s{cr}"..
                         "{none}___{grey}Providing: %s{cr}"..
                         "{none}___{grey}Housing: %s{cr}"..
                         "{none}___{grey}Special: %s",
                },
            }
        },

        UI = {
            FindView = {
                Upkeep = {
                    de = " @cr Unterhalt: @color:255,32,32 %d @color:255,255,255 Taler",
                    en = " @cr Unterhalt: @color:255,32,32 %d @color:255,255,255 Gold",
                }
            },
            Overview = {
                Military = {
                    de = "@color:180,180,180 Militär @color:255,255,255 @cr "..
                         "Zum Militär zählen Soldaten, Kanonen, Kundschafter "..
                         "und Diebe. Baut Eure Burg aus und erreicht höhere "..
                         "Ränge, um das Limit zu erhöhen.",
                    en = "@color:180,180,180 Military @color:255,255,255 @cr The "..
                         "includes all soldiers, cannons, scouts and thieves. "..
                         "Upgrade your  castle and reach higher ranks to increase "..
                         "the limit.",
                },
                Population = {
                    de = "@color:180,180,180 Bevölkerung @color:255,255,255 @cr "..
                         "Zur Bevölkerung zählen alle Arbeiter, Leibeigene und "..
                         "Verbrecher. Baut die Burg aus oder nehmt Dörfer ein, "..
                         "um mehr Volk anzulocken.",
                    en = "@color:180,180,180 Population @color:255,255,255 @cr The "..
                         "population consists of all workers, serfs and criminals. "..
                         "Upgrade your castle or build village centers to attract "..
                         "more population.",
                },
                TaxLeader = {
                    de = "@color:180,180,180 Sold @color:255,255,255 @cr Am Zahltag "..
                         "wird der Sold der Soldaten fällig. Der Sold ist für jeden "..
                         "Truppentyp unterschiedlich.",
                    en = "@color:180,180,180 Upkeep @color:255,255,255 @cr On the "..
                         "payday your soldiers get their wages. How much you pay "..
                         "is different for each unit type.",
                },
                TaxWorker = {
                    de = "@color:180,180,180 Steuern @color:255,255,255 @cr Jeder "..
                         "Arbeiter entrichtet Euch zum Zahltag seine Steuer. Wägt "..
                         "ab, ob Ihr sie schonen oder schröpfen wollt.",
                    en = "@color:180,180,180 Taxes @color:255,255,255 @cr Each worker "..
                         "has to pay their taxes on the payday. Decide whether you "..
                         "want to protect them or exploit them.",
                },
            }
        },
    }
};

function Stronghold.Economy:Install()
    for i= 1, table.getn(Score.Player) do
        CUtil.AddToPlayersMotivationSoftcap(i, 1);

        self.Data[i] = {
            MeasurePoints = 0,

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

    self:OverrideFindViewUpdate();
    self:OverrideTaxAndPayStatistics();
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
        if self.Data[_PlayerID].ReputationDetails.Criminals > 0 then
            ReputationMinus = ReputationMinus + self.Data[_PlayerID].ReputationDetails.Criminals;
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
        self.Data[_PlayerID].IncomeReputation = math.floor((ReputationPlus - ReputationMinus)+ 0.5);
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
            local ReputationOneshot = self.Data[_PlayerID].IncomeReputationSingle;
            if ReputationOneshot > 0 then
                Special = Special + ReputationOneshot;
            end
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
            local NoFarmPenalty = 15 * ((1.0080 ^ NoFarm) -1);
            self.Data[_PlayerID].ReputationDetails.Hunger = NoFarmPenalty;
            local NoHouse = Logic.GetNumberOfWorkerWithoutSleepPlace(_PlayerID);
            local NoHousePenalty = 10 * ((1.0075 ^ NoHouse) -1);
            self.Data[_PlayerID].ReputationDetails.Homelessness = NoHousePenalty;
            Decrease = Decrease + NoFarmPenalty + NoHousePenalty;

            -- External calculations
            local Special = GameCallback_Calculate_ReputationDecreaseExternal(_PlayerID);
            local Criminals = Stronghold.Attraction:GetReputationLossByCriminals(_PlayerID);
            self.Data[_PlayerID].ReputationDetails.Criminals = Criminals;
            self.Data[_PlayerID].ReputationDetails.OtherMalus = Special - Criminals;
            local ReputationOneshot = self.Data[_PlayerID].IncomeReputationSingle;
            if ReputationOneshot < 0 then
                Special = Special + ((-1) * ReputationOneshot);
            end
            self.Data[_PlayerID].ReputationDetails.OtherMalus = Special;
        end
    end
end

function Stronghold.Economy:CalculateReputationTaxPenaltyAmount(_PlayerID, _TaxtHeight)
    if Stronghold.Players[_PlayerID] then
        local WorkerCount = Logic.GetNumberOfAttractedWorker(_PlayerID);
        local Penalty = 0;
        if _TaxtHeight > 1 then
            local TaxEffect = self.Config.Income.TaxEffect[_TaxtHeight].Reputation * -1;
            Penalty = TaxEffect * (1 + ((WorkerCount/95) + (0.42 * (GetRank(_PlayerID) -1))));
        end
        return math.floor(Penalty);
    end
    return 0;
end

-- Calculate honor income
-- Honor is influenced by tax, buildings and units.
-- A player can only gain honor if they have workers and a noble.
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
                local HonorOneshot = self.Data[_PlayerID].IncomeHonorSingle;
                self.Data[_PlayerID].HonorDetails.OtherBonus = Special + HonorOneshot;
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
        for k, v in pairs(Stronghold.Unit.Config) do
            if type(k) == "number" then
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
        end
        -- External
        Upkeep = GameCallback_Calculate_TotalPaydayUpkeep(_PlayerID, Upkeep);
        return math.floor(Upkeep + 0.5);
    end
    return 0;
end

function Stronghold.Economy:AddOneTimeHonor(_PlayerID, _Amount)
    if Stronghold:IsPlayer(_PlayerID) then
        local Old = self.Data[_PlayerID].IncomeHonorSingle;
        self.Data[_PlayerID].IncomeHonorSingle = Old + _Amount;
    end
end

function Stronghold.Economy:AddOneTimeReputation(_PlayerID, _Amount)
    if Stronghold:IsPlayer(_PlayerID) then
        local Old = self.Data[_PlayerID].IncomeReputationSingle;
        self.Data[_PlayerID].IncomeReputationSingle = Old + _Amount;
    end
end

-- -------------------------------------------------------------------------- --
-- Measure Points

function Stronghold.Economy:AddPlayerMeasure(_PlayerID, _Amount)
    if Stronghold:IsPlayer(_PlayerID) then
        local MeasurePoints = self:GetPlayerMeasure(_PlayerID);
        MeasurePoints = math.max(MeasurePoints + _Amount, 0);
        MeasurePoints = math.min(MeasurePoints, self:GetPlayerMeasureLimit(_PlayerID));
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
        local CurrentRank = GetRank(_PlayerID)
        local MeasurePoints = 0;
        for k, v in pairs(GetAllWorker(_PlayerID, 0)) do
            if Logic.IsSettlerAtWork(v) == 1 then
                MeasurePoints = MeasurePoints + ((10 * 0.1) * (1.1 - (CurrentRank/10)));
            end
        end
        MeasurePoints = GameCallback_Calculate_MeasureIncrease(_PlayerID, MeasurePoints);
        self:AddPlayerMeasure(_PlayerID, MeasurePoints);
    end
end

-- -------------------------------------------------------------------------- --
-- UI

function Stronghold.Economy:OverrideFindViewUpdate()
    Overwrite.CreateOverwrite("GUIUpdate_FindView", function()
        Overwrite.CallOriginal();
        local PlayerID = GUI.GetPlayerID();
        if PlayerID == 17 then
            local EntityID = GUI.GetSelectedEntity();
            PlayerID = Logic.EntityGetPlayer(EntityID);
        end
        XGUIEng.ShowWidget("FindView", 1);
        XGUIEng.ShowAllSubWidgets("FindView", 1);
        Stronghold.Economy:HonorMenu();
    end);
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

function Stronghold.Economy:HonorMenu()
    local PlayerID = Stronghold:GetLocalPlayerID();

    local Reputation = 100;
    local ReputationLimit = 200;
    local Honor = 0;
    local MaxHonor = Stronghold.Config.Base.MaxHonor;
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
    XGUIEng.SetTextColor("GCWindowWelcome", 255, 255, 255);
    if Game.GameTimeGetFactor() == 0 then
        XGUIEng.SetTextColor("GCWindowWelcome", 80, 80, 80);
    end
end

function Stronghold.Economy:OverrideTaxAndPayStatistics()
    Overwrite.CreateOverwrite("GameCallback_Logic_Payday", function(_PlayerID)
        Overwrite.CallOriginal();
        -- Remove the one time bonuses
        if Stronghold.Economy.Data[_PlayerID] then
            Stronghold.Economy.Data[_PlayerID].IncomeReputationSingle = 0;
            Stronghold.Economy.Data[_PlayerID].IncomeHonorSingle = 0;
        end
    end);

    Overwrite.CreateOverwrite("GameCallback_Logic_CriminalCatched", function(_PlayerID, _OldEntityID, _BuildingID)
        Overwrite.CallOriginal();
        if Stronghold.Economy.Data[_PlayerID] then
            Stronghold.Economy:AddOneTimeHonor(_PlayerID, 1);
        end
    end);

    Overwrite.CreateOverwrite("GUIUpdate_TaxPaydayIncome", function()
        local PlayerID = Stronghold:GetLocalPlayerID();
        if not Stronghold.Economy.Data[PlayerID] then
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
        local PlayerID = Stronghold:GetLocalPlayerID();
        if not Stronghold.Economy.Data[PlayerID] then
            return Overwrite.CallOriginal();
        end
        local Income = Stronghold.Economy.Data[PlayerID].IncomeMoney;
        XGUIEng.SetText( "TaxWorkerSumOfTaxes", " @color:173,255,47 @ra " ..Income);
    end);

    Overwrite.CreateOverwrite("GUIUpdate_TaxLeaderCosts", function()
        local PlayerID = Stronghold:GetLocalPlayerID();
        if not Stronghold.Economy.Data[PlayerID] then
            return Overwrite.CallOriginal();
        end
        local Upkeep = Stronghold.Economy.Data[PlayerID].UpkeepMoney;
        XGUIEng.SetText( "TaxLeaderSumOfPay", " @color:255,32,32 @ra "..Upkeep);
    end);

    Overwrite.CreateOverwrite("GUIUpdate_AverageMotivation", function()
        local PlayerID = Stronghold:GetLocalPlayerID();
        if not Stronghold:IsPlayer(PlayerID) then
            return Overwrite.CallOriginal();
        end
        XGUIEng.SetMaterialTexture("IconMotivation", 0, "graphics/textures/gui/i_res_arms.png");
        XGUIEng.SetWidgetPosition("IconMotivation", 12, 120);
        XGUIEng.SetWidgetSize("IconMotivation", 18, 18);

        local Usage = Stronghold.Attraction:GetPlayerMilitaryAttractionUsage(PlayerID);
        local Limit = Stronghold.Attraction:GetPlayerMilitaryAttractionLimit(PlayerID);
        XGUIEng.SetText("AverageMotivation", "@ra " ..Usage.. "/" ..Limit);
        XGUIEng.SetWidgetPositionAndSize("AverageMotivation", 37, 118, 53, 15);
		XGUIEng.SetTextColor("AverageMotivation", 115, 125, 125);
    end);
end

function Stronghold.Economy:PrintTooltipGenericForEcoGeneral(_PlayerID, _Key)
    local Language = GetLanguage();
    if _Key == "MenuHeadquarter/TaxWorker" then
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, self.Config.UI.Overview.TaxWorker[Language]);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return true;
    elseif _Key == "MenuHeadquarter/TaxLeader" then
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, self.Config.UI.Overview.TaxLeader[Language]);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return true;
    elseif _Key == "MenuResources/population" then
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, self.Config.UI.Overview.Population[Language]);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return true;
    elseif _Key == "MenuResources/Motivation" then
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, self.Config.UI.Overview.Military[Language]);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return true;
    else
        return false;
    end
end

function Stronghold.Economy:PrintTooltipGenericForFindView(_PlayerID, _Key)
    local Language = GetLanguage();
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

    local UpkeepText = string.format(self.Config.UI.FindView.Upkeep[Language], Upkeep);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text .. UpkeepText);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
    return true;
end

-- -------------------------------------------------------------------------- --
-- HQ Details

function Stronghold.Economy:ShowHeadquartersDetail(_PlayerID)
    local GuiPlayer = GUI.GetPlayerID();
    if Stronghold:IsPlayer(_PlayerID) then
        if GuiPlayer == 17 or GuiPlayer == _PlayerID then
            local Selected = GUI.GetSelectedEntity();
            if Selected == GetID(Stronghold.Players[_PlayerID].HQScriptName) then
                local Language = GetLanguage();
                local Headline = self.Config.Text.CourtClerk[1][Language];
                local Content = self:CreateHeadquarterDetailsText(_PlayerID);
                ShowInfoWindow(Headline, Content);
            end
        end
    end
end

function Stronghold.Economy:CreateHeadquarterDetailsText(_PlayerID)
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
        self.Config.Text.CourtClerk[2][Language],
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

