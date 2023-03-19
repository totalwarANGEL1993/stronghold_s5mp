---
--- Main Script
---
--- This script implements everything reguarding the player.
---
--- Managed by the script:
--- - Players rank
--- - Players honor
--- - Players reputation
--- - Players payday
--- - Players attraction limit
--- - Defeat condition
--- - Shared UI stuff
--- - automatic archive loading
--- - trade
---
--- Defined game callbacks:
--- - GameCallback_Logic_Payday(_PlayerID)
---   Called after the payday is done.
---
--- - GameCallback_Logic_PlayerPromoted(_PlayerID, _OldRank, _NewRank)
---   Called after a player has been promoted.
--- 
--- - GameCallback_Logic_HonorGained(_PlayerID, _Amount)
---   Called after a player gained honor.
--- 
--- - GameCallback_Logic_ReputationGained(_PlayerID, _Amount)
---   Called after a player gained reputation.
--- 
--- - <number> GameCallback_Calculate_PurchaseMinPriceFactor(_PlayerID, _Resource)
---   Calculates the minimum of the purchase price factor of the resource.
--- 
--- - <number> GameCallback_Calculate_PurchaseMaxPriceFactor(_PlayerID, _Resource)
---   Calculates the maximum of the purchase price factor of the resource.
--- 
--- - <number> GameCallback_Calculate_SellMinPriceFactor(_PlayerID, _Resource)
---   Calculates the minimum of the sell price factor of the resource.
--- 
--- - <number> GameCallback_Calculate_SellMaxPriceFactor(_PlayerID, _Resource)
---   Calculates the maximum of the sell price factor of the resource.
---

Stronghold = {
    Shared = {
        DelayedAction = {},
        HQInfo = {},
    },
    Players = {},
    Config = {
        Base = {
            MaxHonor = 9000,
            InitialResources = {0, 1000, 2000, 2500, 850, 100, 100},
            InitialRank = 1,
            MaxRank = 7,
            StartingSerfs = 6,
        },

        Ranks = {
            [1] = {
                Costs = {0, 0, 0, 0, 0, 0, 0},
                Description = nil,
                Condition = function(_PlayerID)
                    return true;
                end,
            },
            [2] = {
                Costs = {10, 0, 0, 0, 0, 0, 0},
                Description = {
                    de = "Kapelle",
                    en = "Chapel"
                },
                Condition = function(_PlayerID)
                    local Chapell1 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Monastery1));
                    local Chapell2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Monastery2);
                    local Chapell3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Monastery3);
                    return Chapell1 + Chapell2 + Chapell3 > 0;
                end,
            },
            [3] = {
                Costs = {25, 0, 0, 0, 0, 0, 0},
                Description = {
                    de = "Handelswesen, Festung",
                    en = "Trading, Fortress"
                },
                Condition = function(_PlayerID)
                    if Logic.IsTechnologyResearched(_PlayerID, Technologies.GT_Trading) == 1 then
                        local CastleID = GetID(Stronghold.Players[_PlayerID].HQScriptName);
                        if Logic.GetEntityType(CastleID) == Entities.PB_Headquarters2
                        or Logic.GetEntityType(CastleID) == Entities.PB_Headquarters3 then
                            return true;
                        end
                    end
                    return false;
                end,
            },
            [4] = {
                Costs = {50, 0, 0, 0, 0, 0, 0},
                Description = {
                    de = "8 Ziergebäude",
                    en = "8 Beautifications"
                },
                Condition = function(_PlayerID)
                    local Beauty01 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification01));
                    local Beauty02 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification02));
                    local Beauty03 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification03));
                    local Beauty04 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification04));
                    local Beauty05 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification05));
                    local Beauty06 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification06));
                    local Beauty07 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification07));
                    local Beauty08 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification08));
                    local Beauty09 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification09));
                    local Beauty10 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification10));
                    local Beauty11 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification11));
                    local Beauty12 = table.getn(GetValidEntitiesOfType(_PlayerID, Entities.PB_Beautification12));
                    return Beauty01 + Beauty02 + Beauty03 + Beauty04 + Beauty05 + Beauty06 +
                           Beauty07 + Beauty08 + Beauty09 + Beauty10 + Beauty11 + Beauty12 >= 8;
                end,
            },
            [5] = {
                Costs = {100, 0, 0, 0, 0, 0, 0},
                Description = {
                    de = "4 Alchemisten, 4 Ziegelbrenner, 4 Sägewerker, 4 Schmiede, 4 Steinmetze",
                    en = "4 Alchemists, 4 Brickmaker, 4 Sawmillworkers, 4 Smiths, 4 Stonemasons"
                },
                Condition = function(_PlayerID)
                    local Workers1 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_BrickMaker);
                    local Workers2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Sawmillworker);
                    local Workers3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Smith);
                    local Workers4 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Stonecutter);
                    local Workers5 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Alchemist);
                    return Workers1 >= 4 and Workers2 >= 4 and Workers3 >= 4 and Workers4 >= 4 and Workers5 >= 4;
                end,
            },
            [6] = {
                Costs = {200, 0, 0, 0, 0, 0, 0},
                Description = {
                    de = "Kathedrale, 45 Arbeiter",
                    en = "Cathedral, 45 Workers"
                },
                Condition = function(_PlayerID)
                    local Workers = Logic.GetNumberOfAttractedWorker(_PlayerID);
                    local Castle3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Monastery3);
                    return Castle3 > 0 and Workers >= 45;
                end,
            },
            [7] = {
                Costs = {300, 0, 0, 0, 0, 0, 0},
                Description = {
                    de = "Alle Ziergebäude, Zitadelle, 65 Arbeiter",
                    en = "All Beautifications, Zitadel, 65 Workers"
                },
                Condition = function(_PlayerID)
                    local IsFulfilled = false;
                    if Logic.GetNumberOfAttractedWorker(_PlayerID) >= 65 then
                        local CastleID = GetID(Stronghold.Players[_PlayerID].HQScriptName);
                        if Logic.GetEntityType(CastleID) == Entities.PB_Headquarters3 then
                            IsFulfilled = true;
                            for i= 1, 12 do
                                local Type = "PB_Beautification" .. ((i < 10 and "0"..i) or i);
                                if table.getn(GetValidEntitiesOfType(_PlayerID, Entities[Type])) < 1 then
                                    IsFulfilled = false;
                                    break;
                                end
                            end
                        end
                    end
                    return IsFulfilled;
                end,
            },
        },

        Gender = {
            [Entities.PU_Hero1]              = 1,
            [Entities.PU_Hero1a]             = 1,
            [Entities.PU_Hero1b]             = 1,
            [Entities.PU_Hero1c]             = 1,
            [Entities.PU_Hero2]              = 1,
            [Entities.PU_Hero3]              = 1,
            [Entities.PU_Hero4]              = 1,
            [Entities.PU_Hero5]              = 2,
            [Entities.PU_Hero6]              = 1,
            [Entities.CU_BlackKnight]        = 1,
            [Entities.CU_Mary_de_Mortfichet] = 2,
            [Entities.CU_Barbarian_Hero]     = 1,
            [Entities.PU_Hero10]             = 1,
            [Entities.PU_Hero11]             = 2,
            [Entities.CU_Evil_Queen]         = 2,
        },

        Trade = {
            -- {buy min, buy max, sell min, sell max}
            [ResourceType.Gold]   = {0.85, 1.25, 0.85, 1.25},
            [ResourceType.Clay]   = {0.80, 1.35, 0.80, 1.35},
            [ResourceType.Wood]   = {0.60, 1.15, 0.60, 1.15},
            [ResourceType.Stone]  = {0.80, 1.35, 0.80, 1.35},
            [ResourceType.Iron]   = {0.90, 1.50, 0.90, 1.50},
            [ResourceType.Sulfur] = {0.95, 1.50, 0.95, 1.50},
        },

        UI = {
            Reputation = {de = "Beliebtheit", en = "Reputation"},
            Honor = {de = "Ehre", en = "Honor"},

            Titles = {
                [1] = {{de = "Edelmann", en = "Nobleman"},
                       {de = "Edelfrau", en = "Noblewoman"}},
                [2] = {{de = "Landvogt", en = "Bailiff"},
                       {de = "Landvögtin", en = "Bailiff"}},
                [3] = {{de = "Fürst", en = "Lord"},
                       {de = "Fürstin", en = "Lady"}},
                [4] = {{de = "Baron", en = "Baron"},
                       {de = "Baronin", en = "Baroness"}},
                [5] = {{de = "Graf", en = "Count"},
                       {de = "Gräfin", en = "Countess"}},
                [6] = {{de = "Markgraf", en = "Margrave"},
                       {de = "Markgräfin", en = "Margravine"}},
                [7] = {{de = "Herzog", en = "Duke"},
                       {de = "Herzogin", en = "Duchess"}},
            },
            Player = {
                [1] = {
                    de = "{grey}Das Haupthaus von %s %s{grey}ist nun geschützt!",
                    en = "{grey}The headquarter of %s %s{grey}is now protected!",
                },
                [2] = {
                    de = "{grey}Das Haupthaus von %s %s{grey} ist nun verwundbar!",
                    en = "{grey}The headquarter of %s %s{grey} is now vulnerable!",
                },
                [3] = {
                    de = "%s %s{grey}wurde besiegt!",
                    en = "%s %s{grey}has been defeated!",
                },
            },
            HQUpgrade = {
                [1] = {
                    de = "@color:233,214,180,255 hat die Burg zu einer Festung ausgebaut",
                    en = "@color:233,214,180,255 has upgraded the keep to a fortress"
                },
                [2] = {
                    de = "@color:233,214,180,255 hat die Festung zu einer Zitadelle ausgebaut",
                    en = "@color:233,214,180,255 has upgraded the fortress to a zitadel"
                },
            },
            Promotion = {
                Player = {
                    de = "Erhebt Euch, %s!",
                    en = "Rise, %!"
                },
                Other = {
                    de = "%s %s {grey} wurde befördert und ist nun{white}%s",
                    en = "%s %s {grey}has been promoted and is now{white}%s"
                },
            }
        },
    },
}

-- -------------------------------------------------------------------------- --
-- API

--- Starts the Stronghold script
function SetupStronghold()
    Stronghold:Init();
end

--- Creates a new human player.
function SetupHumanPlayer(_PlayerID)
    if not Stronghold:IsPlayer(_PlayerID) then
        Stronghold:AddPlayer(_PlayerID);
    end
end

--- Gives reputation to the player.
function AddReputation(_PlayerID, _Amount)
    Stronghold:AddPlayerReputation(_PlayerID, _Amount)
end

--- Returns the reputation of the player.
function GetReputation(_PlayerID)
    return Stronghold:GetPlayerReputation(_PlayerID);
end

--- Returns the max reputation of the player.
function GetMaxReputation(_PlayerID)
    return Stronghold:GetPlayerReputationLimit(_PlayerID);
end

--- Adds honor to the player.
function AddHonor(_PlayerID, _Amount)
    Stronghold:AddPlayerHonor(_PlayerID, _Amount);
end

--- Returns the amount of honor of the player.
function GetHonor(_PlayerID)
    return Stronghold:GetPlayerHonor(_PlayerID);
end

--- Returns the rank of the player.
function GetRank(_PlayerID)
    return Stronghold:GetPlayerRank(_PlayerID);
end

--- Sets the rank of the player.
function SetRank(_PlayerID, _Rank)
    return Stronghold:SetPlayerRank(_PlayerID, _Rank);
end

--- Returns the ID of the players headquarter.
function GetHeadquarterID(_PlayerID)
    return Stronghold:GetPlayerHeadquarter(_PlayerID);
end

--- Alters the purchase price of the resource.
function SetPurchasePrice(_PlayerID, _Resource, _Price)
    Stronghold:ManipulateGoodPurchasePrice(_PlayerID, _Resource, _Price);
end

--- Alters the selling price of the resource.
function SetSellingPrice(_PlayerID, _Resource, _Price)
    Stronghold:ManipulateGoodSellPrice(_PlayerID, _Resource, _Price);
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

function GameCallback_Logic_Payday(_PlayerID)
end

function GameCallback_Logic_PlayerPromoted(_PlayerID, _OldRank, _NewRank)
end

function GameCallback_Logic_HonorGained(_PlayerID, _Amount)
end

function GameCallback_Logic_ReputationGained(_PlayerID, _Amount)
end

function GameCallback_Calculate_PurchaseMinPriceFactor(_PlayerID, _Resource)
    return Stronghold.Config.Trade[_Resource][1] or 0.75;
end

function GameCallback_Calculate_PurchaseMaxPriceFactor(_PlayerID, _Resource)
    return Stronghold.Config.Trade[_Resource][2] or 1.25;
end

function GameCallback_Calculate_SellMinPriceFactor(_PlayerID, _Resource)
    return Stronghold.Config.Trade[_Resource][3] or 0.75;
end

function GameCallback_Calculate_SellMaxPriceFactor(_PlayerID, _Resource)
    return Stronghold.Config.Trade[_Resource][4] or 1.25;
end

-- -------------------------------------------------------------------------- --
-- Main

-- Starts the script
function Stronghold:Init()
    Archive.Install();
    Archive.ReloadEntities();

    Placeholder.Install();
    Syncer.Install(999);
    EntityTracker.Install();
    BuyHero.Install();

    if not CMod then
        Message("The S5 Community Server is required!");
        return false;
    end

    Stronghold:AddDelayedAction(1, function(_PlayerID)
        Stronghold:LoadGUIElements(_PlayerID);
    end, GUI.GetPlayerID());
    GUI.SetTaxLevel(0);
    GUI.ClearSelection();
    ResourceType.Honor = 20;

    self.Economy:Install();
    self.Construction:Install();
    self.Building:Install();
    self.UnitConfig:Install();
    self.Recruitment:Install();
    self.Hero:Install();
    self.Unit:Install();
    self.Attraction:Install();
    self.Spawner:Install();
    self.Outlaw:Install();
    self.Province:Install();

    self:StartTurnDelayTrigger();
    self:StartPlayerPaydayUpdater();
    self:StartTriggers();

    self:OverrideStringTableText();
    self:OverrideWidgetActions();
    self:OverrideWidgetTooltips();
    self:OverrideWidgetUpdates();
    self:OverwriteCommonCallbacks();

    return true;
end

-- Restore game state after load
function Stronghold:OnSaveGameLoaded()
    if not CMod then
        Message("The S5 Community Server is required!");
        return false;
    end
    Archive.ReloadEntities();

    Stronghold:AddDelayedAction(1, function(_PlayerID)
        Stronghold:LoadGUIElements(_PlayerID);
    end, GUI.GetPlayerID());
    GUI.ClearSelection();
    ResourceType.Honor = 20;

    self.Construction:OnSaveGameLoaded();
    self.Building:OnSaveGameLoaded();
    self.UnitConfig:OnSaveGameLoaded();
    self.Recruitment:OnSaveGameLoaded();
    self.Economy:OnSaveGameLoaded();
    self.Hero:OnSaveGameLoaded();
    self.Unit:OnSaveGameLoaded();
    self.Attraction:OnSaveGameLoaded();
    self.Spawner:OnSaveGameLoaded();
    self.Outlaw:OnSaveGameLoaded();
    self.Province:OnSaveGameLoaded();

    self:OverrideStringTableText();
    return true;
end

-- -------------------------------------------------------------------------- --
-- Initalize Player

-- Add player
-- This function adds a new player.
function Stronghold:AddPlayer(_PlayerID)
    local LordName = "LordP" .._PlayerID;
    local HQName = "HQ" .._PlayerID;

    -- Create player data
    self.Players[_PlayerID] = {
        IsInitalized = false,
        LordScriptName = LordName,
        HQScriptName = HQName,
        DoorPos = nil;

        TaxHeight = 3,
        Rank = 1,

        ReputationLimit = 200,
        Reputation = 100,
        Honor = 0,
        IncomeHonor = 0,

        InvulnerabilityInfoShown = false,
        VulnerabilityInfoShown = true,
        AttackMemory = {},
    };

    -- NEVER EVER CHANGE THIS!!!
    BuyHero.SetNumberOfBuyableHeroes(_PlayerID, 1);
    if CNetwork then
        SendEvent.SetTaxes(_PlayerID, 0);
    end

    Job.Turn(function(_PlayerID)
        return Stronghold:WaitForInitalizePlayer(_PlayerID);
    end, _PlayerID);
end

function Stronghold:WaitForInitalizePlayer(_PlayerID)
    local HQID = self:GetPlayerHeadquarter(_PlayerID);
    if  Logic.IsEntityInCategory(HQID, EntityCategories.Headquarters) == 1
    and Logic.IsConstructionComplete(HQID) == 1 then
        self:InitalizePlayer(_PlayerID);
        return true;
    end
    return false;
end

function Stronghold:GetPlayer(_PlayerID)
    return self.Players[_PlayerID];
end

function Stronghold:IsPlayer(_PlayerID)
    return self:GetPlayer(_PlayerID) ~= nil;
end

function Stronghold:IsPlayerInitalized(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self:GetPlayer(_PlayerID).IsInitalized == true;
    end
    return false;
end

function Stronghold:GetPlayerHeadquarter(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return GetID(self.Players[_PlayerID].HQScriptName);
    end
    return 0;
end

function Stronghold:GetLocalPlayerID()
    local EntityID = GUI.GetSelectedEntity();
    local PlayerID1 = GUI.GetPlayerID();
    if CNetwork and EntityID ~= 0 and PlayerID1 == 17 then
        local PlayerID2 = Logic.EntityGetPlayer(EntityID);
        if PlayerID1 ~= PlayerID2 then
            return PlayerID2;
        end
    end
    return PlayerID1;
end

function Stronghold:InitalizePlayer(_PlayerID)
    local HQName = "HQ" .._PlayerID;
    local DoorPosName = "DoorP" .._PlayerID;
    local CampName = "CampP" .._PlayerID;

    -- Create door pos
    local DoorPos = GetCirclePosition(HQName, 800, 180);
    local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, DoorPos.X, DoorPos.Y, 0, 0);
    Logic.SetEntityName(ID, DoorPosName);
    self.Players[_PlayerID].DoorPos = DoorPos;

    -- Create camp Pos
    local CampPos = GetCirclePosition(self.Players[_PlayerID].HQScriptName, 1200, 180);
    ID = Logic.CreateEntity(Entities.XD_ScriptEntity, CampPos.X, CampPos.Y, 0, _PlayerID);
    Logic.SetEntityName(ID, CampName);

    -- Create serfs
    local SerfCount = self.Config.Base.StartingSerfs;
    for i= 1, SerfCount do
        local SerfPos = GetCirclePosition(CampPos, 250, (360/SerfCount) * i);
        local ID = Logic.CreateEntity(Entities.PU_Serf, SerfPos.X, SerfPos.Y, 360 - ((360/SerfCount) * i), _PlayerID);
        LookAt(ID, CampName);
    end
    DestroyEntity(CampName);

    Tools.GiveResouces(
        _PlayerID,
        self.Config.Base.InitialResources[2],
        self.Config.Base.InitialResources[3],
        self.Config.Base.InitialResources[4],
        self.Config.Base.InitialResources[5],
        self.Config.Base.InitialResources[6],
        self.Config.Base.InitialResources[7]
    );
    self:SetPlayerRank(_PlayerID, self.Config.Base.InitialRank);
    self:AddPlayerHonor(_PlayerID, self.Config.Base.InitialResources[1]);

    self.Players[_PlayerID].IsInitalized = true;
end

-- -------------------------------------------------------------------------- --
-- Turn Delay

-- Delays an action by the amount of turns.
-- (Sometimes actions must be delayed a turn to work properly.)
function Stronghold:AddDelayedAction(_Delay, _Function, ...)
    table.insert(self.Shared.DelayedAction, {
        StartTime = Logic.GetTimeMs(),
        Delay     = _Delay,
        Action    = _Function,
        Parameter = arg
    });
end

function Stronghold:DelayedActionController()
    for i= table.getn(self.Shared.DelayedAction), 1, -1 do
        local Data = self.Shared.DelayedAction[i];
        if Logic.GetTimeMs() >= Data.StartTime + (Data.Delay * 100) then
            table.remove(self.Shared.DelayedAction, i);
            if Data.Action then
                Data.Action(unpack(Data.Parameter));
            end
        end
    end
end

function Stronghold:StartTurnDelayTrigger()
    function Stronghold_Trigger_TurnDelay()
        Stronghold:DelayedActionController();
    end
    StartSimpleHiResJob("Stronghold_Trigger_TurnDelay");
end

-- -------------------------------------------------------------------------- --
-- Trigger

function Stronghold:StartTriggers()
    Job.Second(function()
        Stronghold:OnEverySecond();
    end);

    Job.Turn(function()
        Stronghold:OnEveryTurn();
    end);

    Job.Create(function()
        Stronghold:OnEntityCreated();
    end);

    Job.Destroy(function()
        Stronghold:OnEntityDestroyed();
    end);

    Job.Hurt(function()
        Stronghold:OnEntityHurtEntity();
    end);

    Job.Trade(function()
        Stronghold:OnGoodsTraded();
    end);
end

function Stronghold:OnEveryTurn()
    local Players = table.getn(Score.Player);
    -- Player jobs on each turn
    for i= 1, Players do
        Stronghold.Hero:OnlineHelpUpdate(i, "OnlineHelpButton", Technologies.T_OnlineHelp);
        Stronghold.Hero:EntityAttackedController(i);
        Stronghold.Hero:HeliasConvertController(i);
        Stronghold.Economy:ShowHeadquartersDetail(i);
        Stronghold.Recruitment:ControlProductionQueues(i);
    end
    -- Player jobs on modified turns
    ---@diagnostic disable-next-line: undefined-field
    local PlayerID = math.mod(math.floor(Logic.GetTime() * 10), Players);
    Stronghold.Economy:UpdateIncomeAndUpkeep(PlayerID);
    Stronghold.Economy:GainMeasurePoints(PlayerID);
    Stronghold.Hero:VargWolvesController(PlayerID);

    -- Other jobs
    Stronghold.Province:ControlProvince();
end

function Stronghold:OnEverySecond()
    local Players = table.getn(Score.Player);
    for i= 1, Players do
        self:PlayerDefeatCondition(i);
        Stronghold.Attraction:CreateWorkersForPlayer(i);
        Stronghold.Attraction:ManageCriminalsOfPlayer(i);
    end
end

function Stronghold:OnEntityCreated()
    local EntityID = Event.GetEntityID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);

    if Logic.IsBuilding(EntityID) == 1 then
        if GUI.GetPlayerID() == PlayerID then
            self:OnSelectionMenuChanged(EntityID, GUI.GetSelectedEntity());
        end
    end
    if Logic.IsSettler(EntityID) == 1 and GUI.GetPlayerID() == PlayerID then
        Stronghold.Hero:ConfigurePlayersHeroPet(EntityID);
    end
    if Logic.IsBuilding(EntityID) == 1 then
        Stronghold.Attraction:SetBuildingCurrentWorkerAmount(EntityID, 1);
    end
    Stronghold.Unit:SetFormationOnCreate(EntityID);
    Stronghold.Province:OnBuildingCreated(EntityID, PlayerID);
    Stronghold.Recruitment:InitQueuesForProducer(EntityID);
end

function Stronghold:OnEntityDestroyed()
    local EntityID = Event.GetEntityID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);

    Stronghold.Province:OnBuildingDestroyed(EntityID, PlayerID);
end

function Stronghold:OnEntityHurtEntity()
    local Attacker = Event.GetEntityID1();
    local AttackerPlayer = Logic.EntityGetPlayer(Attacker);
    local Attacked = Event.GetEntityID2();
    local AttackedPlayer = Logic.EntityGetPlayer(Attacked);
    if Attacker and Attacked then
        local ID = Attacked;
        if Logic.IsEntityInCategory(ID, EntityCategories.Leader) == 1 then
            local Soldiers = {Logic.GetSoldiersAttachedToLeader(ID)};
            if Soldiers[1] > 0 then
                ID = Soldiers[Soldiers[1]+1];
            end
        end
        if Logic.GetEntityHealth(ID) > 0 then
            if self.Players[AttackedPlayer] then
                self.Players[AttackedPlayer].AttackMemory[Attacked] = {15, Attacker};
            end
        end
    end
end

function Stronghold:OnGoodsTraded()
    local EntityID = Event.GetEntityID();
    local SellTyp = Event.GetSellResource();
    local PurchaseTyp = Event.GetBuyResource();
    local PlayerID = Logic.EntityGetPlayer(EntityID);

    local PurchasePrice = Logic.GetCurrentPrice(PlayerID, PurchaseTyp);
    self:ManipulateGoodPurchasePrice(PlayerID, PurchaseTyp, PurchasePrice);
    local SellPrice = Logic.GetCurrentPrice(PlayerID, SellTyp);
    self:ManipulateGoodSellPrice(PlayerID, SellTyp, SellPrice);
end

function Stronghold:ManipulateGoodPurchasePrice(_PlayerID, _Resource, _Price)
    local MinBuyCap = GameCallback_Calculate_PurchaseMinPriceFactor(_PlayerID, _Resource);
    local MaxBuyCap = GameCallback_Calculate_PurchaseMaxPriceFactor(_PlayerID, _Resource);
    Logic.SetCurrentPrice(_PlayerID, _Resource, math.max(math.min(_Price, MaxBuyCap), MinBuyCap));
end

function Stronghold:ManipulateGoodSellPrice(_PlayerID, _Resource, _Price)
    local MinSellCap = GameCallback_Calculate_SellMinPriceFactor(_PlayerID, _Resource);
    local MaxSellCap = GameCallback_Calculate_SellMaxPriceFactor(_PlayerID, _Resource);
    Logic.SetCurrentPrice(_PlayerID, _Resource, math.max(math.min(_Price, MaxSellCap), MinSellCap));
end

-- -------------------------------------------------------------------------- --
-- Defeat Condition

-- The player is defeated when the headquarter is destroyed. This is not so
-- much like Stronghold but having 1 super strong hero as the main target
-- might be a bit risky.
function Stronghold:PlayerDefeatCondition(_PlayerID)
    local Language = GetLanguage();
    if not self:IsPlayer(_PlayerID) then
        return;
    end

    -- Check lord
    local HeroAlive = false;
    if IsEntityValid(self.Players[_PlayerID].LordScriptName) then
        HeroAlive = true;
    end

    local HQID = self:GetPlayerHeadquarter(_PlayerID);
    if HeroAlive then
        if Logic.IsEntityInCategory(HQID, EntityCategories.Headquarters) == 1 then
            self.Players[_PlayerID].VulnerabilityInfoShown = false;
            if IsExisting(HQID) then
                MakeInvulnerable(self.Players[_PlayerID].HQScriptName);
            end
            if not self.Players[_PlayerID].InvulnerabilityInfoShown then
                self.Players[_PlayerID].InvulnerabilityInfoShown = true;
                Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);

                local PlayerName = UserTool_GetPlayerName(_PlayerID);
                local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
                Message(string.format(
                    self.Config.UI.Player[1][Language],
                    PlayerColor,
                    PlayerName
                ));
            end
        end
    else
        if Logic.IsEntityInCategory(HQID, EntityCategories.Headquarters) == 1 then
            self.Players[_PlayerID].InvulnerabilityInfoShown = false;
            if IsExisting(self.Players[_PlayerID].HQScriptName) then
                MakeVulnerable(self.Players[_PlayerID].HQScriptName);
            end
            if not self.Players[_PlayerID].VulnerabilityInfoShown then
                self.Players[_PlayerID].VulnerabilityInfoShown = true;
                Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);

                local PlayerName = UserTool_GetPlayerName(_PlayerID);
                local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
                Message(string.format(
                    self.Config.UI.Player[2][Language],
                    PlayerColor,
                    PlayerName
                ));
            end
        end
    end

    -- Check HQ
    if not IsExisting(HQID) and Logic.PlayerGetGameState(_PlayerID) == 1 then
        Logic.PlayerSetGameStateToLost(_PlayerID);

        local PlayerName = UserTool_GetPlayerName(_PlayerID);
        local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
        Message(string.format(
            self.Config.UI.Player[3][Language],
            PlayerColor,
            PlayerName
        ));
    end
end

-- -------------------------------------------------------------------------- --
-- Payday

-- Payday updater
-- The real payday is deactivated. We simultate the payday by using a job the
-- old fashioned way.
function Stronghold:StartPlayerPaydayUpdater()

    function Stronghold_Trigger_OnPayday()
        Stronghold.Shared.PaydayTriggerFlag = Stronghold.Shared.PaydayTriggerFlag or {};
        Stronghold.Shared.PaydayOverFlag = Stronghold.Shared.PaydayOverFlag or {};

        for i= 1, table.getn(Score.Player) do
            if Stronghold.Shared.PaydayTriggerFlag[i] == nil then
                Stronghold.Shared.PaydayTriggerFlag[i] = false;
            end
            if Stronghold.Shared.PaydayOverFlag[i] == nil then
                Stronghold.Shared.PaydayOverFlag[i] = false;
            end

            local TimeLeft = Logic.GetPlayerPaydayTimeLeft(i);
            if TimeLeft > 119900 and TimeLeft <= 120000 then
                Stronghold.Shared.PaydayTriggerFlag[i] = true;
            elseif TimeLeft > 119600 and TimeLeft <= 119900 then
                Stronghold.Shared.PaydayTriggerFlag[i] = false;
                Stronghold.Shared.PaydayOverFlag[i] = false;
            end
            if Stronghold.Shared.PaydayTriggerFlag[i] and not Stronghold.Shared.PaydayOverFlag[i] then
                Stronghold:OnPlayerPayday(i);
                Stronghold.Shared.PaydayOverFlag[i] = true;
            end
        end
    end
    StartSimpleHiResJob("Stronghold_Trigger_OnPayday");
end

-- Payday controller
-- Applies everything that is happening on the payday.
function Stronghold:OnPlayerPayday(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        -- First regular payday
        if Logic.GetNumberOfAttractedWorker(_PlayerID) > 0 and Logic.GetTime() > 1 then
            self.Players[_PlayerID].HasHadRegularPayday = true;
        end

        Tools.GiveResouces(_PlayerID, Logic.GetNumberOfLeader(_PlayerID) * 20, 0, 0, 0, 0, 0);
        Tools.GiveResouces(_PlayerID, Stronghold.Economy.Data[_PlayerID].IncomeMoney, 0, 0, 0, 0, 0);
        AddGold(_PlayerID, -Stronghold.Economy.Data[_PlayerID].UpkeepMoney);

        -- Reputation
        local OldReputation = self:GetPlayerReputation(_PlayerID);
        local ReputationIncome = Stronghold.Economy.Data[_PlayerID].IncomeReputation;
        self.Players[_PlayerID].Reputation = OldReputation + ReputationIncome;
        if self.Players[_PlayerID].Reputation > self.Players[_PlayerID].ReputationLimit then
            self.Players[_PlayerID].Reputation = self.Players[_PlayerID].ReputationLimit;
        end
        if self.Players[_PlayerID].Reputation < 0 then
            self.Players[_PlayerID].Reputation = 0;
        end

        -- Attraction
        if self.Players[_PlayerID].Reputation < 50 then
            self.Players[_PlayerID].CivilAttractionLocked = true;
        else
            self.Players[_PlayerID].CivilAttractionLocked = false;
        end

        -- Motivation
        self:AddDelayedAction(1, function()
            Stronghold:UpdateMotivationOfPlayersWorkers(_PlayerID, ReputationIncome);
            Stronghold:ControlReputationAttractionPenalty(_PlayerID);
        end);

        -- Honor
        local Honor = Stronghold.Economy.Data[_PlayerID].IncomeHonor;
        self:AddPlayerHonor(_PlayerID, Honor);

        -- Payday done
        GameCallback_Logic_Payday(_PlayerID);
    end
end

-- -------------------------------------------------------------------------- --
-- Rank

function Stronghold:GetPlayerRank(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Players[_PlayerID].Rank;
    end
    return 0;
end

function Stronghold:GetPlayerRankName(_PlayerID, _Rank)
    local Language = GetLanguage();
    if self:IsPlayer(_PlayerID) then
        local Rank = _Rank or self.Players[_PlayerID].Rank;
        local LordID = GetID(self.Players[_PlayerID].LordScriptName);

        local Gender = 1;
        if LordID ~= 0 then
            Gender = self:GetNobleGender(Logic.GetEntityType(LordID)) or 1;
        end

        local Text = self.Config.UI.Titles[Rank][Gender][Language];
        if type (Text) == "table" then
            Text = Text[Language];
        end
        return Text;
    end
    return (Language == "de" and "Pöbel") or "Rabble";
end

function Stronghold:GetNobleGender(_Type)
    if self.Config.Gender[_Type] then
        return self.Config.Gender[_Type];
    end
    return 1;
end

function Stronghold:SetPlayerRank(_PlayerID, _Rank)
    if self:IsPlayer(_PlayerID) then
        self.Players[_PlayerID].Rank = _Rank;
    end
end

function Stronghold:PromotePlayer(_PlayerID)
    local Language = GetLanguage();
    if self:CanPlayerBePromoted(_PlayerID) then
        local Rank = self:GetPlayerRank(_PlayerID);
        local Costs = Stronghold:CreateCostTable(unpack(self.Config.Ranks[Rank +1].Costs));
        self:SetPlayerRank(_PlayerID, Rank +1);
        RemoveResourcesFromPlayer(_PlayerID, Costs);
        local MsgText = string.format(
            self.Config.UI.Promotion.Player[Language],
            Stronghold:GetPlayerRankName(_PlayerID, Rank +1)
        );
        if GUI.GetPlayerID() == _PlayerID then
            Sound.PlayGUISound(Sounds.OnKlick_Select_pilgrim, 100);
        else
            MsgText = string.format(
                self.Config.UI.Promotion.Other[Language],
                UserTool_GetPlayerName(_PlayerID),
                "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ","),
                Stronghold:GetPlayerRankName(_PlayerID, Rank +1)
            );
        end
        Message(MsgText);
        GameCallback_Logic_PlayerPromoted(_PlayerID, Rank, Rank +1);
    end
end

function Stronghold:CanPlayerBePromoted(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        if IsExisting(self.Players[_PlayerID].LordScriptName) then
            local Rank = self:GetPlayerRank(_PlayerID);
            if Rank == 0 or Rank >= self.Config.Base.MaxRank then
                return false;
            end
            return self.Config.Ranks[Rank +1].Condition(_PlayerID);
        end
    end
    return false;
end

-- -------------------------------------------------------------------------- --
-- Honor

function Stronghold:AddPlayerHonor(_PlayerID, _Amount)
    if self:IsPlayer(_PlayerID) then
        self.Players[_PlayerID].Honor = self.Players[_PlayerID].Honor + _Amount;
        if self.Players[_PlayerID].Honor > self.Config.Base.MaxHonor then
            self.Players[_PlayerID].Honor = self.Config.Base.MaxHonor;
        end
        if self.Players[_PlayerID].Honor < 0 then
            self.Players[_PlayerID].Honor = 0;
        end
        GameCallback_Logic_HonorGained(_PlayerID, _Amount);
    end
end

function Stronghold:GetPlayerHonor(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Players[_PlayerID].Honor;
    end
    return 0;
end

-- -------------------------------------------------------------------------- --
-- Reputation

function Stronghold:AddPlayerReputation(_PlayerID, _Amount)
    if self:IsPlayer(_PlayerID) then
        local Reputation = self:GetPlayerReputation(_PlayerID);
        self:SetPlayerReputation(_PlayerID, Reputation + _Amount);
    end
end

function Stronghold:SetPlayerReputation(_PlayerID, _Amount)
    if self:IsPlayer(_PlayerID) then
        self.Players[_PlayerID].Reputation = _Amount;
        if self.Players[_PlayerID].Reputation > self.Players[_PlayerID].ReputationLimit then
            self.Players[_PlayerID].Reputation = self.Players[_PlayerID].ReputationLimit;
        end
        if self.Players[_PlayerID].Reputation < 0 then
            self.Players[_PlayerID].Reputation = 0;
        end
        GameCallback_Logic_ReputationGained(_PlayerID, _Amount);
    end
end

function Stronghold:SetPlayerReputationLimit(_PlayerID, _Amount)
    if self:IsPlayer(_PlayerID) then
        self.Players[_PlayerID].ReputationLimit = _Amount;
    end
end

function Stronghold:GetPlayerReputationLimit(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Players[_PlayerID].ReputationLimit;
    end
    return 200;
end

function Stronghold:GetPlayerReputation(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Players[_PlayerID].Reputation;
    end
    return 100;
end

function Stronghold:UpdateMotivationOfPlayersWorkers(_PlayerID, _Amount)
    if self:IsPlayer(_PlayerID) then
        for k,v in pairs(GetAllWorker(_PlayerID)) do
            local WorkplaceID = Logic.GetSettlersWorkBuilding(v);
            if  (WorkplaceID ~= nil and WorkplaceID ~= 0)
            and Logic.IsOvertimeActiveAtBuilding(WorkplaceID) == 0
            and Logic.IsAlarmModeActive(WorkplaceID) ~= true then
                local OldMoti = Logic.GetSettlersMotivation(v);
                local NewMoti = math.floor((OldMoti * 100) + 0.5) + _Amount;
                NewMoti = math.min(NewMoti, self.Players[_PlayerID].ReputationLimit);
                NewMoti = math.max(NewMoti, 30);
                CEntity.SetMotivation(v, NewMoti / 100);
            end
        end
    end
end

function Stronghold:ControlReputationAttractionPenalty(_PlayerID)
    local Reputation = self:GetPlayerReputation(_PlayerID);
    local WorkerList = GetAllWorker(_PlayerID);
    local WorkerAmount = table.getn(WorkerList);
    local LeaveAmount = 0;

    -- Restore reputation when workers are all gone
    if  self.Players[_PlayerID].HasHadRegularPayday
    and Logic.GetNumberOfAttractedWorker(_PlayerID) == 0 then
        self:SetPlayerReputation(_PlayerID, math.min(Reputation +12, 75));
        return;
    end

    if Reputation <= 30 then
        -- Get all not already leaving workers
        for i= table.getn(WorkerList), 1, -1 do
            if Logic.GetCurrentTaskList(WorkerList[i]) == "TL_WORKER_LEAVE" then
                table.remove(WorkerList, i);
            end
        end

        -- Make workers leave
        WorkerAmount = table.getn(WorkerList);
        LeaveAmount = math.ceil(WorkerAmount * 0.75);
        while LeaveAmount > 0 do
            if WorkerAmount == 0 then
                break;
            end
            local ID = table.remove(WorkerList, math.random(1, WorkerAmount));
            Logic.SetTaskList(ID, TaskLists.TL_WORKER_LEAVE);
            WorkerAmount = table.getn(WorkerList);
            LeaveAmount = LeaveAmount -1;
        end
    end
end

-- -------------------------------------------------------------------------- --
-- UI Update

function Stronghold:LoadGUIElements(_PlayerID)
    if GUI.GetPlayerID() == _PlayerID then
        XGUIEng.SetMaterialTexture("BackGround_BottomLeft", 1, "graphics/textures/gui/bg_bottom_left2.png");
        XGUIEng.SetMaterialTexture("BackGround_BottomTexture", 0, "graphics/textures/gui/bg_bottom2.png");
        XGUIEng.TransferMaterials("BlessSettlers1", "Research_PickAxe");
        XGUIEng.TransferMaterials("BlessSettlers2", "Research_LightBricks");
        XGUIEng.TransferMaterials("BlessSettlers3", "Research_Taxation");
        XGUIEng.TransferMaterials("BlessSettlers4", "Research_Debenture");
        XGUIEng.TransferMaterials("BlessSettlers5", "Research_Scale");
        Camera.ZoomSetFactorMax(2.0);
    end
end

function Stronghold:OverrideStringTableText()
    local Lang = GetLanguage();
    local KeepText = self.Config.UI.HQUpgrade[1][Lang];
    CUtil.SetStringTableText("InGameMessages/GUI_PlayerXHasUpgradeHisKeep", KeepText);
    local FortressText = self.Config.UI.HQUpgrade[2][Lang];
    CUtil.SetStringTableText("InGameMessages/GUI_PlayerXHasUpgradeHisCastle", FortressText);
end

-- Menu update
-- This calls all updates of the selection menu when selection has changed.
function Stronghold:OnSelectionMenuChanged(_EntityID)
    HideInfoWindow();

    local GuiPlayer = self:GetLocalPlayerID();
    local SelectedID = GUI.GetSelectedEntity();
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if GuiPlayer ~= 17 and GuiPlayer ~= PlayerID then
        return;
    end

    self.Hero:OnSelectLeader(SelectedID);
    self.Hero:OnSelectHero(SelectedID);

    self.Building:OnHeadquarterSelected(SelectedID);
    self.Building:OnMonasterySelected(SelectedID);

    self.Recruitment:OnBarracksSelected(SelectedID);
    self.Recruitment:OnArcherySelected(SelectedID);
    self.Recruitment:OnStableSelected(SelectedID);
    self.Recruitment:OnFoundrySelected(SelectedID);
    self.Recruitment:OnTavernSelected(SelectedID);

    XGUIEng.DisableButton("OnlineHelpButton", 1);
end

function Stronghold:OverwriteCommonCallbacks()
    Overwrite.CreateOverwrite("GameCallback_GUI_SelectionChanged", function()
        Overwrite.CallOriginal();
        local EntityID = GUI.GetSelectedEntity();
        Stronghold:OnSelectionMenuChanged(EntityID);
    end);

    Overwrite.CreateOverwrite("GameCallback_OnBuildingConstructionComplete", function(_EntityID, _PlayerID)
        Overwrite.CallOriginal();
        Stronghold:OnSelectionMenuChanged(_EntityID);
    end);

    Overwrite.CreateOverwrite("GameCallback_OnBuildingUpgradeComplete", function(_EntityIDOld, _EntityIDNew)
        Overwrite.CallOriginal();
        -- Fixes the problem with the building attraction. The currend amount
        -- will be red and then set. After that all workers are reattached.
        local PlayerID = Logic.EntityGetPlayer(_EntityIDNew);
        local Workers = {Logic.GetAttachedWorkersToBuilding(_EntityIDNew)};
        Stronghold.Attraction:SetBuildingCurrentWorkerAmount(_EntityIDNew, Workers[1]);
        Logic.PlayerReAttachAllWorker(PlayerID);
        Stronghold:OnSelectionMenuChanged(_EntityIDNew);
    end);

    Overwrite.CreateOverwrite("GameCallback_OnTechnologyResearched", function(_PlayerID, _Technology, _EntityID)
        Overwrite.CallOriginal();
        Stronghold:OnSelectionMenuChanged(_EntityID);
    end);

    Overwrite.CreateOverwrite("GameCallback_OnCannonConstructionComplete", function(_BuildingID)
        Overwrite.CallOriginal();
        Stronghold:OnSelectionMenuChanged(_BuildingID);
    end);

    Overwrite.CreateOverwrite("GameCallback_OnTransactionComplete", function(_BuildingID)
        Overwrite.CallOriginal();
        Stronghold:OnSelectionMenuChanged(_BuildingID);
    end);

    ---

	self.Orig_Mission_OnSaveGameLoaded = Mission_OnSaveGameLoaded;
	Mission_OnSaveGameLoaded = function()
		Stronghold.Orig_Mission_OnSaveGameLoaded();
        Stronghold:OnSaveGameLoaded();
	end
end

-- Button Action Generic Override
function Stronghold:OverrideWidgetActions()
    Overwrite.CreateOverwrite("GUIAction_OnlineHelp", function()
        Stronghold.Hero:OnlineHelpAction();
    end);

    Overwrite.CreateOverwrite("GUIAction_ReserachTechnology", function(_Technology)
        if  not Stronghold.Recruitment:OnBarracksSettlerUpgradeTechnologyClicked(_Technology)
        and not Stronghold.Recruitment:OnArcherySettlerUpgradeTechnologyClicked(_Technology)
        and not Stronghold.Recruitment:OnStableSettlerUpgradeTechnologyClicked(_Technology) then
            Overwrite.CallOriginal();
        end
    end);

    Overwrite.CreateOverwrite("GUIAction_BuyMilitaryUnit", function(_UpgradeCategory)
        if not Stronghold.Recruitment:BuyMilitaryUnitFromTavernAction(_UpgradeCategory) then
            Overwrite.CallOriginal();
        end
    end);

    Overwrite.CreateOverwrite("GUIAction_BuyCannon", function(_Type, _UpgradeCategory)
        if not Stronghold.Recruitment:BuyMilitaryUnitFromFoundryAction(_Type, _UpgradeCategory) then
            Overwrite.CallOriginal();
        end
    end);

    Overwrite.CreateOverwrite("GUIAction_BuySoldier", function()
        if not Stronghold.Unit:BuySoldierButtonAction() then
            Overwrite.CallOriginal();
        end
    end);

    Overwrite.CreateOverwrite("GUIAction_ExpelSettler", function()
        if not Stronghold.Unit:ExpelSettlerButtonAction() then
            Overwrite.CallOriginal();
        end
    end);

    Overwrite.CreateOverwrite("GUIAction_ChangeBuildingMenu", function(_WidgetID)
        local EntityID = GUI.GetSelectedEntity();
        local PlayerID = Stronghold:GetLocalPlayerID();
        if not Stronghold.Building:HeadquartersChangeBuildingTabsGuiAction(PlayerID, EntityID, _WidgetID) then
            Overwrite.CallOriginal();
        end
    end);

    Overwrite.CreateOverwrite("GUIAction_BlessSettlers", function(_BlessCategory)
        local GuiPlayer = Stronghold:GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        if InterfaceTool_IsBuildingDoingSomething(EntityID) == true then
            return true;
        end
        local ActionCalled = false;
        if not ActionCalled then
            ActionCalled = Stronghold.Building:HeadquartersBlessSettlersGuiAction(GuiPlayer, EntityID, _BlessCategory);
        end
        if not ActionCalled then
            ActionCalled = Stronghold.Building:MonasteryBlessSettlersGuiAction(GuiPlayer, EntityID, _BlessCategory);
        end
        if not ActionCalled then
            Overwrite.CallOriginal();
        end
    end);
end

-- Button Tooltip Generic Override
function Stronghold:OverrideWidgetTooltips()
    Overwrite.CreateOverwrite("GUITooltip_NormalButton", function(_Key)
        Overwrite.CallOriginal();
        Stronghold.Unit:ExpelSettlerButtonTooltip(_Key);
    end);

    Overwrite.CreateOverwrite("GUITooltip_BuySoldier", function(_KeyNormal, _KeyDisabled, _ShortCut)
        Overwrite.CallOriginal();
        Stronghold.Unit:BuySoldierButtonTooltip(_KeyNormal, _KeyDisabled, _ShortCut);
    end);

    Overwrite.CreateOverwrite("GUITooltip_BuyMilitaryUnit", function(_UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut)
        local PlayerID = Stronghold:GetLocalPlayerID();
        Overwrite.CallOriginal();
        Stronghold.Recruitment:UpdateTavernBuyUnitTooltip(PlayerID, _UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut);
        Stronghold.Recruitment:UpdateFoundryBuyUnitTooltip(PlayerID, _UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut);
    end);

    Overwrite.CreateOverwrite("GUITooltip_BlessSettlers", function(_TooltipDisabled, _TooltipNormal, _TooltipResearched, _ShortCut)
        local GuiPlayer = Stronghold:GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        Overwrite.CallOriginal();
        Stronghold.Building:MonasteryBlessSettlersGuiTooltip(GuiPlayer, EntityID, _TooltipDisabled, _TooltipNormal, _TooltipResearched, _ShortCut);
        Stronghold.Building:HeadquartersBlessSettlersGuiTooltip(GuiPlayer, EntityID, _TooltipDisabled, _TooltipNormal, _TooltipResearched, _ShortCut);
    end);

    Overwrite.CreateOverwrite("GUITooltip_Generic", function(_Key)
        local PlayerID = Stronghold:GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        if not Stronghold:IsPlayer(PlayerID) then
            return Overwrite.CallOriginal();
        end
        local TooltipSet = false;
        if not TooltipSet then
            TooltipSet = Stronghold.Economy:PrintTooltipGenericForFindView(PlayerID, _Key);
        end
        if not TooltipSet then
            TooltipSet = Stronghold.Economy:PrintTooltipGenericForEcoGeneral(PlayerID, _Key);
        end
        if not TooltipSet then
            TooltipSet = Stronghold.Building:PrintHeadquartersTaxButtonsTooltip(PlayerID, EntityID, _Key);
        end
        if not TooltipSet then
            TooltipSet = Stronghold.Building:HeadquartersBuildingTabsGuiTooltip(PlayerID, EntityID, _Key);
        end
        if not TooltipSet then
            TooltipSet = Stronghold.Hero:OnlineHelpTooltip(_Key);
        end
        if not TooltipSet then
            return Overwrite.CallOriginal();
        end
    end);

    Overwrite.CreateOverwrite("GUITooltip_ResearchTechnologies", function(_Technology, _TextKey, _ShortCut)
        local PlayerID = Stronghold:GetLocalPlayerID();
        if not Stronghold:IsPlayer(PlayerID) then
            return Overwrite.CallOriginal();
        end
        local TooltipSet = false;
        if not TooltipSet then
            TooltipSet = Stronghold.Recruitment:UpdateUpgradeSettlersBarracksTooltip(PlayerID, _Technology, _TextKey, _ShortCut);
        end
        if not TooltipSet then
            TooltipSet = Stronghold.Recruitment:UpdateUpgradeSettlersArcheryTooltip(PlayerID, _Technology, _TextKey, _ShortCut);
        end
        if not TooltipSet then
            TooltipSet = Stronghold.Recruitment:UpdateUpgradeSettlersStableTooltip(PlayerID, _Technology, _TextKey, _ShortCut);
        end
        if not TooltipSet then
            return Overwrite.CallOriginal();
        end
    end);
end

-- Button Update Generic Override
function Stronghold:OverrideWidgetUpdates()
    Overwrite.CreateOverwrite("GUIUpdate_BuildingButtons", function(_Button, _Technology)
        Overwrite.CallOriginal();
        local PlayerID = self:GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        Stronghold.Hero:OnlineHelpUpdate(PlayerID, _Button, _Technology);
        Stronghold.Building:HeadquartersBlessSettlersGuiUpdate(PlayerID, EntityID, _Button);
    end);

    Overwrite.CreateOverwrite("GUIUpdate_SelectionName", function()
        Overwrite.CallOriginal();
        Stronghold.Hero:PrintSelectionName();
    end);

    Overwrite.CreateOverwrite("GUIUpdate_BuySoldierButton", function()
        Overwrite.CallOriginal();
        return Stronghold.Unit:BuySoldierButtonUpdate();
    end);

    Overwrite.CreateOverwrite("GUIUpdate_FaithProgress", function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local PlayerID = Stronghold:GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        Overwrite.CallOriginal();
        Stronghold.Building:HeadquartersFaithProgressGuiUpdate(PlayerID, EntityID, WidgetID);
    end);
end

