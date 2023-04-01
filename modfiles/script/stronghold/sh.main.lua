---
--- Main Script
---
--- This script implements everything reguarding the player.
---
--- Managed by the script:
--- - Players honor
--- - Players reputation
--- - Players payday
--- - Defeat condition
--- - Shared UI stuff
--- - automatic archive loading
--- - trade
---
--- Defined game callbacks:
--- - GameCallback_Logic_Payday(_PlayerID)
---   Called after the payday is done.
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
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- API

--- Starts the Stronghold script.
function SetupStronghold()
    Stronghold:Init();
end

--- Sets the inital rank for all players.
--- (Must be done *before* setting up players because it changes the config!)
--- @param _Rank number ID of rank
function SetInitialRank(_Rank)
    Stronghold:SetInitialRank(_Rank);
end

--- Creates a new human player.
--- @param _PlayerID number ID of player
--- @param _Serfs?   number Amount of serfs
function SetupHumanPlayer(_PlayerID, _Serfs)
    if not IsHumanPlayer(_PlayerID) then
        Stronghold:AddPlayer(_PlayerID, _Serfs);
    end
end

--- Returns the GUI player. If the owner of an selected entity differs from the
--- GUI player then the owner player ID is returned.
--- @return number Player ID of player
function GetLocalPlayerID()
    return Stronghold:GetLocalPlayerID();
end

--- Returns if a player is a human player.
--- @param _PlayerID number ID of player
--- @return boolean IsPlayer Is human player
function IsHumanPlayer(_PlayerID)
    return Stronghold:IsPlayer(_PlayerID);
end

--- Returns if a player is a human player and is initalized.
--- (A player is initalized when the headquarters is placed.)
--- @param _PlayerID number ID of player
--- @return boolean IsInitalized Is initalized player
function IsHumanPlayerInitalized(_PlayerID)
    return Stronghold:IsPlayerInitalized(_PlayerID);
end

--- Gives reputation to the player.
--- @param _PlayerID number ID of player
--- @param _Amount   number Amount of Reputation
function AddReputation(_PlayerID, _Amount)
    Stronghold:AddPlayerReputation(_PlayerID, _Amount)
end

--- Returns the reputation of the player.
--- @param _PlayerID number ID of player
--- @return number Amount Amount of reputation
function GetReputation(_PlayerID)
    return Stronghold:GetPlayerReputation(_PlayerID);
end

--- Returns the max reputation of the player.
--- @param _PlayerID number ID of player
--- @return number Amount Limit of reputation
function GetMaxReputation(_PlayerID)
    return Stronghold:GetPlayerReputationLimit(_PlayerID);
end

--- Adds honor to the player.
--- @param _PlayerID number ID of player
--- @param _Amount   number Amount of Honor
function AddHonor(_PlayerID, _Amount)
    Stronghold:AddPlayerHonor(_PlayerID, _Amount);
end

--- Returns the amount of honor of the player.
--- @param _PlayerID number ID of player
--- @return number Amount Amount of honor
function GetHonor(_PlayerID)
    return Stronghold:GetPlayerHonor(_PlayerID);
end

--- Returns the ID of the players headquarter.
--- @param _PlayerID number ID of player
--- @return number ID ID of Headquarters
function GetHeadquarterID(_PlayerID)
    return Stronghold:GetPlayerHeadquarter(_PlayerID);
end

--- Alters the purchase price of the resource.
--- @param _PlayerID number ID of player
--- @param _Resource number Resource type
--- @param _Price    number Price factor
function SetPurchasePrice(_PlayerID, _Resource, _Price)
    Stronghold:ManipulateGoodPurchasePrice(_PlayerID, _Resource, _Price);
end

--- Alters the selling price of the resource.
--- @param _PlayerID number ID of player
--- @param _Resource number Resource type
--- @param _Price    number Price factor
function SetSellingPrice(_PlayerID, _Resource, _Price)
    Stronghold:ManipulateGoodSellPrice(_PlayerID, _Resource, _Price);
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

function GameCallback_Logic_Payday(_PlayerID)
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

    self.Rights:Install();
    self.Economy:Install();
    self.Construction:Install();
    self.Building:Install();
    self.Recruitment:Install();
    self.Hero:Install();
    self.Unit:Install();
    self.Attraction:Install();
    self.Spawner:Install();
    self.Outlaw:Install();
    self.Province:Install();

    self:StartTurnDelayTrigger();
    self:StartPlayerPaydayUpdater();
    self:UnlockAllTechnologies();
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
    -- FIXME: Do I still need next line?
    Archive.Push("stronghold_s5mp.bba");
    Archive.ReloadGUI("data\\menu\\projects\\ingame.xml");
    Archive.ReloadEntities();

    Stronghold:AddDelayedAction(1, function(_PlayerID)
        Stronghold:LoadGUIElements(_PlayerID);
    end, GUI.GetPlayerID());
    -- Force UI update
    GUI.ClearSelection();
    -- Init new resource
    ResourceType.Honor = 20;

    -- Call save game stuff
    self.Rights:OnSaveGameLoaded();
    self.Construction:OnSaveGameLoaded();
    self.Building:OnSaveGameLoaded();
    self.Recruitment:OnSaveGameLoaded();
    self.Economy:OnSaveGameLoaded();
    self.Hero:OnSaveGameLoaded();
    self.Unit:OnSaveGameLoaded();
    self.Attraction:OnSaveGameLoaded();
    self.Spawner:OnSaveGameLoaded();
    self.Outlaw:OnSaveGameLoaded();
    self.Province:OnSaveGameLoaded();

    -- Change texts
    self:OverrideStringTableText();
    return true;
end

-- -------------------------------------------------------------------------- --
-- Initalize Player

function Stronghold:SetInitialRank(_Rank)
    assert(_Rank >= PlayerRank.Commoner and _Rank <= PlayerRank.Duke, "Invalid rank!");
    for k,v in pairs(self.Players) do
        assert(false, "A player was already setup!");
    end
    self.Config.Base.InitialRank = _Rank;
end

-- Add player
-- This function adds a new player.
function Stronghold:AddPlayer(_PlayerID, _Serfs)
    local LordName = "LordP" .._PlayerID;
    local HQName = "HQ" .._PlayerID;

    -- Create player data
    self.Players[_PlayerID] = {
        IsInitalized = false,
        LordScriptName = LordName,
        HQScriptName = HQName,
        DoorPos = nil;

        TaxHeight = 3,
        ReputationLimit = 200,
        Reputation = 100,
        Honor = 0,
        IncomeHonor = 0,

        InvulnerabilityInfoShown = false,
        VulnerabilityInfoShown = true,
        AttackMemory = {},
    };

    if CNetwork then
        SendEvent.SetTaxes(_PlayerID, 0);
    end

    Job.Turn(function(_PlayerID, _Serfs)
        return Stronghold:WaitForInitalizePlayer(_PlayerID, _Serfs);
    end, _PlayerID, _Serfs);
end

function Stronghold:WaitForInitalizePlayer(_PlayerID, _Serfs)
    local HQID = self:GetPlayerHeadquarter(_PlayerID);
    if  Logic.IsEntityInCategory(HQID, EntityCategories.Headquarters) == 1
    and Logic.IsConstructionComplete(HQID) == 1 then
        self:InitalizePlayer(_PlayerID, _Serfs);
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

function Stronghold:GetPlayerHero(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return GetID(self.Players[_PlayerID].LordScriptName);
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

function Stronghold:InitalizePlayer(_PlayerID, _Serfs)
    local HQName = "HQ" .._PlayerID;
    local DoorPosName = "DoorP" .._PlayerID;
    local CampName = "CampP" .._PlayerID;

    -- Replace headquarters
    local HQID = GetID(self.Players[_PlayerID].HQScriptName);
    ReplaceEntity(HQID, Logic.GetEntityType(HQID));

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
    local SerfCount = _Serfs or self.Config.Base.StartingSerfs;
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
    SetRank(_PlayerID, self.Config.Base.InitialRank);
    AddHonor(_PlayerID, self.Config.Base.InitialResources[1]);

    self.Players[_PlayerID].IsInitalized = true;
end

function Stronghold:UnlockAllTechnologies()
    for i= 1, table.getn(Score.Player) do
        ResearchTechnology(Technologies.GT_Alchemy, i);
        ResearchTechnology(Technologies.GT_Alloying, i);
        ResearchTechnology(Technologies.GT_Architecture, i);
        ResearchTechnology(Technologies.GT_Binocular, i);
        ResearchTechnology(Technologies.GT_ChainBlock, i);
        ResearchTechnology(Technologies.GT_Chemistry, i);
        ResearchTechnology(Technologies.GT_Construction, i);
        ResearchTechnology(Technologies.GT_GearWheel, i);
        ResearchTechnology(Technologies.GT_Library, i);
        ResearchTechnology(Technologies.GT_Literacy, i);
        ResearchTechnology(Technologies.GT_Matchlock, i);
        ResearchTechnology(Technologies.GT_Mathematics, i);
        ResearchTechnology(Technologies.GT_Mercenaries, i);
        ResearchTechnology(Technologies.GT_Metallurgy, i);
        ResearchTechnology(Technologies.GT_Printing, i);
        ResearchTechnology(Technologies.GT_PulledBarrel, i);
        ResearchTechnology(Technologies.GT_StandingArmy, i);
        ResearchTechnology(Technologies.GT_Strategies, i);
        ResearchTechnology(Technologies.GT_Tactics, i);
        ResearchTechnology(Technologies.GT_Trading, i);
        ResearchTechnology(Technologies.GT_Trading, i);
        ResearchTechnology(Technologies.T_ChangeWeather, i);
        ResearchTechnology(Technologies.T_WeatherForecast, i);
    end
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
        Stronghold.Attraction:UpdatePlayerCivilAttractionUsage(i);
        Stronghold.Hero:EntityAttackedController(i);
        Stronghold.Hero:HeliasConvertController(i);
        Stronghold.Economy:ShowHeadquartersDetail(i);
        Stronghold.Rights:OnlineHelpUpdate(i, "OnlineHelpButton", Technologies.T_OnlineHelp);
        Stronghold.Recruitment:ControlProductionQueues(i);
        Stronghold.Recruitment:ControlCannonProducers(i);
    end
    -- Player jobs on modified turns
    ---@diagnostic disable-next-line: undefined-field
    local PlayerID = math.mod(math.floor(Logic.GetTime() * 10), Players);
    Stronghold.Attraction:ManageCriminalsOfPlayer(PlayerID);
    Stronghold.Attraction:UpdatePlayerCivilAttractionLimit(PlayerID);
    Stronghold.Economy:UpdateIncomeAndUpkeep(PlayerID);
    Stronghold.Economy:GainMeasurePoints(PlayerID);
    Stronghold.Hero:VargWolvesController(PlayerID);
end

function Stronghold:OnEverySecond()
    local Players = table.getn(Score.Player);
    for i= 1, Players do
        self:PlayerDefeatCondition(i);
    end
    Stronghold.Province:ControlProvince();
end

function Stronghold:OnEntityCreated()
    local EntityID = Event.GetEntityID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);

    if Logic.IsBuilding(EntityID) == 1 then
        if GUI.GetPlayerID() == PlayerID then
            self:OnSelectionMenuChanged(EntityID);
        end
    end
    if Logic.IsSettler(EntityID) == 1 then
        Stronghold.Hero:ConfigurePlayersHeroPet(EntityID);
    end
    Stronghold.Unit:SetFormationOnCreate(EntityID);
    Stronghold.Province:OnBuildingCreated(EntityID, PlayerID);
    Stronghold.Recruitment:InitQueuesForProducer(EntityID);
end

function Stronghold:OnEntityDestroyed()
    local EntityID = Event.GetEntityID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    Stronghold.Building:OnRallyPointHolderDestroyed(PlayerID, EntityID);
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
                -- 
                self.Players[_PlayerID].InvulnerabilityInfoShown = true;
                Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
                -- 
                local PlayerName = UserTool_GetPlayerName(_PlayerID);
                local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
                Message(string.format(
                    self.Text.Player[1][Language],
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
                -- 
                self.Players[_PlayerID].VulnerabilityInfoShown = true;
                Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
                -- 
                local PlayerName = UserTool_GetPlayerName(_PlayerID);
                local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
                Message(string.format(
                    self.Text.Player[2][Language],
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
            self.Text.Player[3][Language],
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
            Stronghold.Attraction:UpdateMotivationOfPlayersWorkers(_PlayerID, ReputationIncome);
        end);

        -- Honor
        local Honor = Stronghold.Economy.Data[_PlayerID].IncomeHonor;
        self:AddPlayerHonor(_PlayerID, Honor);

        -- Payday done
        GameCallback_Logic_Payday(_PlayerID);
    end
end

-- -------------------------------------------------------------------------- --
-- Honor

function Stronghold:AddPlayerHonor(_PlayerID, _Amount)
    if self:IsPlayer(_PlayerID) then
        self.Players[_PlayerID].Honor = self.Players[_PlayerID].Honor + _Amount;
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
    local Text;

    Text = self.Text.HQUpgrade[1][Lang];
    CUtil.SetStringTableText("InGameMessages/GUI_PlayerXHasUpgradeHisKeep", Text);
    Text = self.Text.HQUpgrade[2][Lang];
    CUtil.SetStringTableText("InGameMessages/GUI_PlayerXHasUpgradeHisCastle", Text);

    Text = self.Text.Bandit[2][Lang];
    CUtil.SetStringTableText("names/CU_BanditLeaderSword1", Text);
    Text = self.Text.Bandit[1][Lang];
    CUtil.SetStringTableText("names/CU_BanditLeaderSword2", Text);

    Text = self.Text.BlackKnight[2][Lang];
    CUtil.SetStringTableText("names/CU_BlackKnight_LeaderMace1", Text);
    Text = self.Text.BlackKnight[1][Lang];
    CUtil.SetStringTableText("names/CU_BlackKnight_LeaderMace2", Text);

    Text = self.Text.Barbarian[2][Lang];
    CUtil.SetStringTableText("names/CU_Barbarian_LeaderClub1", Text);
    Text = self.Text.Barbarian[1][Lang];
    CUtil.SetStringTableText("names/CU_Barbarian_LeaderClub2", Text);

    Text = self.Text.Spearman[1][Lang];
    CUtil.SetStringTableText("names/PU_LeaderPoleArm1", Text);
    Text = self.Text.Spearman[2][Lang];
    CUtil.SetStringTableText("names/PU_LeaderPoleArm3", Text);

    Text = self.Text.Knight[1][Lang];
    CUtil.SetStringTableText("names/PU_LeaderHeavyCavalry1", Text);
    Text = self.Text.Knight[2][Lang];
    CUtil.SetStringTableText("names/PU_LeaderHeavyCavalry2", Text);
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

    self.Building:OnHeadquarterSelected(SelectedID);
    self.Building:OnMonasterySelected(SelectedID);
    self.Building:OnAlchemistSelected(SelectedID);

    self.Construction:OnSelectSerf(SelectedID);

    self.Hero:OnSelectLeader(SelectedID);
    self.Hero:OnSelectHero(SelectedID);

    self.Recruitment:OnBarracksSelected(SelectedID);
    self.Recruitment:OnArcherySelected(SelectedID);
    self.Recruitment:OnStableSelected(SelectedID);
    self.Recruitment:OnFoundrySelected(SelectedID);
    self.Recruitment:OnTavernSelected(SelectedID);
end

function Stronghold:OverwriteCommonCallbacks()
    Overwrite.CreateOverwrite("GameCallback_GUI_SelectionChanged", function()
        Overwrite.CallOriginal();
        local EntityID = GUI.GetSelectedEntity();
        local GuiPlayer = GetLocalPlayerID();
        Stronghold.Building:OnRallyPointHolderSelected(GuiPlayer, EntityID);
        Stronghold:OnSelectionMenuChanged(EntityID);
    end);

    Overwrite.CreateOverwrite("GameCallback_OnBuildingConstructionComplete", function(_EntityID, _PlayerID)
        Overwrite.CallOriginal();
        Stronghold:OnSelectionMenuChanged(_EntityID);
        Stronghold.Province:OnBuildingConstructed(_EntityID, _PlayerID);
    end);

    Overwrite.CreateOverwrite("GameCallback_OnBuildingUpgradeComplete", function(_EntityIDOld, _EntityIDNew)
        Overwrite.CallOriginal();
        local PlayerID = Logic.EntityGetPlayer(_EntityIDNew);
        Stronghold:OnSelectionMenuChanged(_EntityIDNew);
        Stronghold.Province:OnBuildingUpgraded(_EntityIDNew, PlayerID);
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
        Stronghold.Rights:OnlineHelpAction();
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
        local PlayerID = GetLocalPlayerID();
        if not Stronghold.Building:HeadquartersChangeBuildingTabsGuiAction(PlayerID, EntityID, _WidgetID) then
            Overwrite.CallOriginal();
        end
    end);

    Overwrite.CreateOverwrite("GUIAction_BlessSettlers", function(_BlessCategory)
        local GuiPlayer = GetLocalPlayerID();
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
        local PlayerID = GetLocalPlayerID();
        Overwrite.CallOriginal();
        Stronghold.Recruitment:UpdateTavernBuyUnitTooltip(PlayerID, _UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut);
        Stronghold.Recruitment:UpdateFoundryBuyUnitTooltip(PlayerID, _UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut);
    end);

    Overwrite.CreateOverwrite("GUITooltip_BlessSettlers", function(_TooltipDisabled, _TooltipNormal, _TooltipResearched, _ShortCut)
        local GuiPlayer = GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        Overwrite.CallOriginal();
        Stronghold.Building:MonasteryBlessSettlersGuiTooltip(GuiPlayer, EntityID, _TooltipDisabled, _TooltipNormal, _TooltipResearched, _ShortCut);
        Stronghold.Building:HeadquartersBlessSettlersGuiTooltip(GuiPlayer, EntityID, _TooltipDisabled, _TooltipNormal, _TooltipResearched, _ShortCut);
    end);

    Overwrite.CreateOverwrite( "GUITooltip_ConstructBuilding", function( _UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut)
        local GuiPlayer = GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        Overwrite.CallOriginal();
        Stronghold.Construction:PrintTooltipConstructionButton(_UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut);
    end);

    Overwrite.CreateOverwrite("GUITooltip_Generic", function(_Key)
        local PlayerID = GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        if not IsHumanPlayer(PlayerID) then
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
            TooltipSet = Stronghold.Rights:OnlineHelpTooltip(_Key);
        end
        if not TooltipSet then
            return Overwrite.CallOriginal();
        end
    end);

    Overwrite.CreateOverwrite("GUITooltip_ResearchTechnologies", function(_Technology, _TextKey, _ShortCut)
        local PlayerID = GetLocalPlayerID();
        if not IsHumanPlayer(PlayerID) then
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
        local PlayerID = GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        Overwrite.CallOriginal();
        Stronghold.Rights:OnlineHelpUpdate(PlayerID, _Button, _Technology);
        Stronghold.Construction:UpdateSerfConstructionButtons(PlayerID, _Button, _Technology);
        Stronghold.Building:OnAlchemistSelected(EntityID);
        Stronghold.Construction:OnSelectSerf(EntityID);
        Stronghold.Building:HeadquartersBlessSettlersGuiUpdate(PlayerID, EntityID, _Button);
    end);

    Overwrite.CreateOverwrite("GUITooltip_UpgradeBuilding", function(_Type, _KeyNormal, _KeyDisabled, _Technology, _ShortCut)
        Overwrite.CallOriginal();
        Stronghold.Construction:PrintBuildingUpgradeButtonTooltip(_Type, _KeyNormal, _KeyDisabled, _Technology);
    end);

    Overwrite.CreateOverwrite("GUIUpdate_UpgradeButtons", function(_Button, _Technology)
        Overwrite.CallOriginal();
        if string.find(_Button, "Beautification") then
            Stronghold.Construction:UpdateSerfUpgradeButtons(_Button, _Technology);
        else
            Stronghold.Construction:UpdateBuildingUpgradeButtons(_Button, _Technology);
        end
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
        local PlayerID = GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        Overwrite.CallOriginal();
        Stronghold.Building:HeadquartersFaithProgressGuiUpdate(PlayerID, EntityID, WidgetID);
    end);
end

