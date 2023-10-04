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
--- - <number> GameCallback_SH_Calculate_Payday(_PlayerID, _Amount)
---   Called after the payday is done.
--- 
--- - GameCallback_SH_Logic_HonorGained(_PlayerID, _Amount)
---   Called after a player gained honor.
--- 
--- - GameCallback_SH_Logic_ReputationGained(_PlayerID, _Amount)
---   Called after a player gained reputation.
--- 
--- - GameCallback_SH_GoodsTraded(_PlayerID, _BuildingID, _BuyType, _BuyAmount, _SellType, _SellAmount)
---   Called after a trade has concluded.
--- 
--- - <number> GameCallback_SH_Calculate_PurchaseMinPriceFactor(_PlayerID, _Resource)
---   Calculates the minimum of the purchase price factor of the resource.
--- 
--- - <number> GameCallback_SH_Calculate_PurchaseMaxPriceFactor(_PlayerID, _Resource)
---   Calculates the maximum of the purchase price factor of the resource.
--- 
--- - <number> GameCallback_SH_Calculate_SellMinPriceFactor(_PlayerID, _Resource)
---   Calculates the minimum of the sell price factor of the resource.
--- 
--- - <number> GameCallback_SH_Calculate_SellMaxPriceFactor(_PlayerID, _Resource)
---   Calculates the maximum of the sell price factor of the resource.
--- 
--- - <number> GameCallback_SH_Calculate_BattleDamage(_AttackerID, _AttackedID, _Damage)
---   Calculates the damage of an attack
---
--- - GameCallback_SH_Logic_OnPlayerInitialized(_PlayerID, _IsAI)
---   Called after the player is initialized.
---

Stronghold = {
    Version = "0.2.3",
    Shared = {
        DelayedAction = {},
        HQInfo = {},
    },
    Players = {},
    Record = {},
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- Main Script

-- Default game start callback if not set in map
GameCallback_OnGameStart = GameCallback_OnGameStart or function()
    -- Load default scripts
	Script.Load(Folders.MapTools.."Ai\\Support.lua");
	Script.Load("Data\\Script\\MapTools\\MultiPlayer\\MultiplayerTools.lua");
	Script.Load("Data\\Script\\MapTools\\Tools.lua");
	Script.Load("Data\\Script\\MapTools\\WeatherSets.lua");
	IncludeGlobals("GlobalMissionScripts");
    IncludeGlobals("Conditions");
    IncludeGlobals("Counter");
	IncludeGlobals("Explore");
	IncludeGlobals("Comfort");

    gvMission = {}
	gvMission.PlayerID = GUI.GetPlayerID();
    Music.Stop();

    -- Do default multiplayer stuff
	MultiplayerTools.InitCameraPositionsForPlayers();
	MultiplayerTools.SetUpGameLogicOnMPGameConfig();
	MultiplayerTools.GiveBuyableHerosToHumanPlayer(0);
	if XNetwork.Manager_DoesExist() == 0 then
		for i=1,4,1 do
			MultiplayerTools.DeleteFastGameStuff(i);
		end
		local PlayerID = GUI.GetPlayerID();
		Logic.PlayerSetIsHumanFlag(PlayerID, 1);
		Logic.PlayerSetGameStateToPlaying(PlayerID);
	end

    -- Set default weather
    UseWeatherSet("EuropeanWeatherSet");
    AddPeriodicSummer(10);

    -- Start stronghold mod
    SetupStronghold();
    local Players = Syncer.GetActivePlayers();
    for i= 1, table.getn(Players) do
        SetupPlayer(Players[i]);
    end
    if SHS5MP_RulesDefinition.DisableRuleConfiguration then
        SetupStrongholdMultiplayerConfig(SHS5MP_RulesDefinition);
    else
        ShowStrongholdConfiguration(SHS5MP_RulesDefinition);
    end
end

-- Must remain empty in the script because it is called by the game.
Mission_InitWeatherGfxSets = Mission_InitWeatherGfxSets or function ()
end

-- -------------------------------------------------------------------------- --
-- API

--- Starts the Stronghold script.
function SetupStronghold()
    Stronghold:Init();
end

--- Returns the GUI player. If the owner of an selected entity differs from the
--- GUI player then the owner player ID is returned.
--- @return number Player ID of player
function GetLocalPlayerID()
    return Stronghold:GetLocalPlayerID();
end

--- Sets the inital rank for all players.
--- (Must be done *before* setting up players because it changes the config!)
--- @param _Rank number ID of rank
function SetInitialRank(_Rank)
    Stronghold:SetInitialRank(_Rank);
end

--- Creates a new player.
--- @param _PlayerID number  ID of player
--- @param _Serfs?   number  Amount of serfs
function SetupPlayer(_PlayerID, _Serfs)
    if not IsPlayer(_PlayerID) then
        Stronghold:AddPlayer(_PlayerID, false, _Serfs);
    end
end

--- Creates a new AI player.
--- @param _PlayerID number  ID of player
--- @param _Serfs?   number  Amount of serfs
--- @param _HeroType? number Type of hero
function SetupAiPlayer(_PlayerID, _Serfs, _HeroType)
    if not IsPlayer(_PlayerID) then
        Stronghold:AddPlayer(_PlayerID, true, _Serfs, _HeroType);
    end
end

--- Returns if a player is a player.
--- @param _PlayerID number ID of player
--- @return boolean IsPlayer Is human player
function IsPlayer(_PlayerID)
    return Stronghold:IsPlayer(_PlayerID);
end

--- Returns if a player is a AI player.
--- @param _PlayerID number ID of player
--- @return boolean IsPlayer Is AI player
function IsAIPlayer(_PlayerID)
    return Stronghold:IsAIPlayer(_PlayerID);
end

--- Returns if a player is a player and is initalized.
--- (A player is initalized when the headquarters is placed.)
--- @param _PlayerID number ID of player
--- @return boolean IsInitalized Is initalized player
function IsPlayerInitalized(_PlayerID)
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

--- Returns the max amount of usable player IDs.
--- @return number Amount Amount of player IDs
function GetMaxPlayers()
    return Stronghold:GetMaxAmountOfPlayersPossible();
end

--- Returns the max amount of human usable player IDs.
--- @return number Amount Amount of human players
function GetMaxHumanPlayers()
    return Stronghold:GetMaxAmountOfHumanPlayersPossible();
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

function GameCallback_SH_Calculate_Payday(_PlayerID, _Amount)
    return _Amount
end

function GameCallback_SH_Logic_HonorGained(_PlayerID, _Amount)
end

function GameCallback_SH_Logic_ReputationGained(_PlayerID, _Amount)
end

function GameCallback_SH_GoodsTraded(_PlayerID, _EntityID, _BuyType, _BuyAmount, _SellType, _SellAmount)
end

function GameCallback_SH_Calculate_PurchaseMinPriceFactor(_PlayerID, _Resource)
    return Stronghold.Config.Trade[_Resource][1] or 0.75;
end

function GameCallback_SH_Calculate_PurchaseMaxPriceFactor(_PlayerID, _Resource)
    return Stronghold.Config.Trade[_Resource][2] or 1.25;
end

function GameCallback_SH_Calculate_SellMinPriceFactor(_PlayerID, _Resource)
    return Stronghold.Config.Trade[_Resource][3] or 0.75;
end

function GameCallback_SH_Calculate_SellMaxPriceFactor(_PlayerID, _Resource)
    return Stronghold.Config.Trade[_Resource][4] or 1.25;
end

function GameCallback_SH_Calculate_BattleDamage(_AttackerID, _AttackedID, _Damage)
    return _Damage;
end

function GameCallback_SH_Logic_OnPlayerInitialized(_PlayerID, _IsAI)
end

-- -------------------------------------------------------------------------- --
-- Main

-- Starts the script
function Stronghold:Init()
    Archive.Install();
    Placeholder.Install();
    Syncer.Install();
    EntityTracker.Install();
    BuyHero.Install();
    Extension.Install();
    FreeCam.SetToggleable(true);

    if not CMod then
        Message("The S5 Community Server is required!");
        return false;
    end

    self:InitPlayerEntityRecord();
    Camera.ZoomSetFactorMax(2.0);
    GUI.SetTaxLevel(0);
    GUI.ClearSelection();
    ResourceType.Honor = ResourceType.Silver;

    self.Utils:OverwriteInterfaceTools();
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
    self.Statistic:Install();
    self.Multiplayer:Install();
    self.AI:Install();

    self:SetupPaydayForAllPlayers();
    self:ConfigurePaydayForAllPlayers();
    self:StartTurnDelayTrigger();
    self:StartPlayerPaydayUpdater();
    self:UnlockAllTechnologies();
    self:StartTriggers();

    self:OverrideStringTableText();
    self:OverrideWidgetActions();
    self:OverrideWidgetTooltips();
    self:OverrideWidgetUpdates();
    self:OverwriteCommonCallbacks();

    -- AoD fix
    CEntity.EnableLogicAoEDamage();
    CEntity.EnableDamageClassAoEDamage();
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

    Camera.ZoomSetFactorMax(2.0);
    GUI.ClearSelection();
    ResourceType.Honor = ResourceType.Silver;

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
    self.Statistic:OnSaveGameLoaded();
    self.Multiplayer:OnSaveGameLoaded();
    self.AI:OnSaveGameLoaded();

    self:SetupPaydayForAllPlayers();
    self:ConfigurePaydayForAllPlayers();
    self:OverrideStringTableText();

    -- AoD fix
    CEntity.EnableLogicAoEDamage();
    CEntity.EnableDamageClassAoEDamage();
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
function Stronghold:AddPlayer(_PlayerID, _IsAI, _Serfs, _HeroType)
    local LordName = "LordP" .._PlayerID;
    local HQName = "HQ" .._PlayerID;

    -- Create player data
    self.Players[_PlayerID] = {
        IsInitalized = false,
        IsAI = _IsAI == true,
        LordScriptName = LordName,
        HQScriptName = HQName,
        DoorPos = nil;

        TaxHeight = 3,
        ReputationLimit = 200,
        Reputation = 100,

        InvulnerabilityInfoShown = false,
        VulnerabilityInfoShown = true,
        AttackMemory = {},
    };

    if CNetwork then
        SendEvent.SetTaxes(_PlayerID, 0);
    end

    Job.Turn(function(_PlayerID, _Serfs, _HeroType)
        return Stronghold:WaitForInitalizePlayer(_PlayerID, _Serfs, _HeroType);
    end, _PlayerID, _Serfs, _HeroType);
end

function Stronghold:WaitForInitalizePlayer(_PlayerID, _Serfs, _HeroType)
    local HQID = self:GetPlayerHeadquarter(_PlayerID);
    if  Logic.IsEntityInCategory(HQID, EntityCategories.Headquarters) == 1
    and Logic.IsConstructionComplete(HQID) == 1 then
        self:InitalizePlayer(_PlayerID, _Serfs, _HeroType);
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

function Stronghold:IsAIPlayer(_PlayerID)
    local Player = self:GetPlayer(_PlayerID);
    return Player and Player.IsAI == true;
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

function Stronghold:InitalizePlayer(_PlayerID, _Serfs, _HeroType)
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
    Logic.CreateEntity(Entities.XD_Camp_Internal, CampPos.X, CampPos.Y, 0, _PlayerID);
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

    SetRank(_PlayerID, self.Config.Base.InitialRank);
    self.Players[_PlayerID].IsInitalized = true;

    self:InitalizeAiPlayer(_PlayerID, _HeroType);
    GameCallback_SH_Logic_OnPlayerInitialized(_PlayerID, self:IsAIPlayer(_PlayerID));
end

function Stronghold:InitalizeAiPlayer(_PlayerID, _HeroType)
    if self:IsAIPlayer(_PlayerID) then
        local Position = self.Players[_PlayerID].DoorPos;
        local Type = _HeroType or Entities.CU_Hero13;
        PlayerCreateNoble(_PlayerID, Type, Position);
        local HeroID = GetID(Stronghold.Players[_PlayerID].LordScriptName);
        Logic.RotateEntity(HeroID, 180);
    end
end

function Stronghold:UnlockAllTechnologies()
    for i= 1, GetMaxPlayers() do
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
        ResearchTechnology(Technologies.UP2_Headquarter, i);
    end
end

function Stronghold:GetMaxAmountOfPlayersPossible()
    return self.Config.Base.MaxPossiblePlayers;
end

function Stronghold:SetMaxAmountOfPlayersPossible(_Max)
    assert(_Max < 16);
    self.Config.Base.MaxPossiblePlayers = _Max;
end

function Stronghold:GetMaxAmountOfHumanPlayersPossible()
    return self.Config.Base.MaxHumanPlayers;
end

function Stronghold:SetMaxAmountOfHumanPlayersPossible(_Max)
    assert(_Max < 14);
    self.Config.Base.MaxHumanPlayers = _Max;
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
    -- Send versions to all other players
    -- (Multiplayer only)
    self.Multiplayer:BroadcastStrongholdVersion();

    local Players = GetMaxPlayers();
    -- Player jobs on each turn
    for i= 1, Players do
        self.Attraction:UpdatePlayerCivilAttractionUsage(i);
        self.Hero:EntityAttackedController(i);
        self.Hero:HeliasConvertController(i);
        self.Hero:YukiShurikenConterController(i);
        self.Rights:OnlineHelpUpdate(i, "OnlineHelpButton", Technologies.T_OnlineHelp);
        self.Recruitment:ControlProductionQueues(i);
        self.Recruitment:ControlCannonProducers(i);
    end
    -- Player jobs on modified turns
    ---@diagnostic disable-next-line: undefined-field
    local PlayerID = math.mod(Logic.GetCurrentTurn(), Players);
    self.Attraction:ManageCriminalsOfPlayer(PlayerID);
    self.Attraction:UpdatePlayerCivilAttractionLimit(PlayerID);
    self.Building:FoundryCannonAutoRepair(PlayerID);
    self.Economy:UpdateIncomeAndUpkeep(PlayerID);
    self.Economy:GainMeasurePoints(PlayerID);
    self.Economy:GainKnowledgePoints(PlayerID);
    self.Hero:VargWolvesController(PlayerID);
end

function Stronghold:OnEverySecond()
    local Players = GetMaxPlayers();
    for i= 1, Players do
        self:PlayerDefeatCondition(i);
        self.Building:CannonToRallyPointController(i);
    end
    self.Province:ControlProvince();
end

function Stronghold:OnEntityCreated()
    local EntityID = Event.GetEntityID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);

    self:AddEntityToPlayerRecordOnCreate(EntityID);
    if Logic.IsBuilding(EntityID) == 1 then
        if GUI.GetPlayerID() == PlayerID then
            self:OnSelectionMenuChanged(EntityID);
            self.Construction:OnBuildingPlaced(EntityID);
        end
    end
    if Logic.IsSettler(EntityID) == 1 then
        self.Hero:ConfigurePlayersHeroPet(EntityID);
        if GUI.GetPlayerID() == PlayerID then
            self:OnSelectionMenuChanged(EntityID);
        end
    end
    self.Building:OnWallOrPalisadeCreated(EntityID);
    self.Building:OnUnitCreated(EntityID);
    self.Economy:SetSettlersMotivation(EntityID);
    self.Unit:SetFormationOnCreate(EntityID);
    self.Recruitment:InitQueuesForProducer(EntityID);
    self.Recruitment:OnUnitCreated(EntityID);
end

function Stronghold:OnEntityDestroyed()
    local EntityID = Event.GetEntityID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    self:RemoveEntityFromPlayerRecordOnDestroy(EntityID);
    self.Building:OnRallyPointHolderDestroyed(PlayerID, EntityID);
    self.Building:OnWallOrPalisadeDestroyed(EntityID);
end

function Stronghold:OnEntityHurtEntity()
    local Attacker = Event.GetEntityID1();
    local AttackerPlayer = Logic.EntityGetPlayer(Attacker);
    local AttackerType = Logic.GetEntityType(Attacker);
    local Attacked = Event.GetEntityID2();
    local AttackedPlayer = Logic.EntityGetPlayer(Attacked);
    local AttackedType = Logic.GetEntityType(Attacked);
    if Attacker and Attacked then
        -- Get attacker ID
        local ID = Attacked;
        if Logic.IsEntityInCategory(ID, EntityCategories.Leader) == 1 then
            local Soldiers = {Logic.GetSoldiersAttachedToLeader(ID)};
            if Soldiers[1] > 0 then
                ID = Soldiers[Soldiers[1]+1];
            end
        end
        if Logic.GetEntityHealth(ID) > 0 then
            -- Save in attack memory
            if self.Players[AttackedPlayer] then
                self.Players[AttackedPlayer].AttackMemory[Attacked] = {15, Attacker};
            end
            local Damage = CEntity.HurtTrigger.GetDamage();
            local DamageSource = CEntity.HurtTrigger.GetDamageSourceType();
            -- prevent serf harrasment
            if DamageSource == CEntity.HurtTrigger.DamageSources.BOMB
            or Logic.IsHero(Attacker) == 1 then
                if AttackedType == Entities.PU_Serf then
                    Damage = 1;
                end
            end
            -- Vigilante
            if Logic.IsBuilding(Attacker) == 1 then
                if Logic.IsTechnologyResearched(AttackerPlayer, Technologies.T_Vigilante) == 1 then
                    Damage = Damage * 3;
                end
            end
            -- External
            Damage = GameCallback_SH_Calculate_BattleDamage(Attacker, Attacked, Damage);
            CEntity.HurtTrigger.SetDamage(math.ceil(Damage));
        end
    end
end

function Stronghold:OnGoodsTraded()
    local BuyType = Event.GetBuyResource();
    local BuyAmount = Event.GetBuyAmount();
    local SellType = Event.GetSellResource();
    local SellAmount = Event.GetSellAmount();
    local EntityID = Event.GetEntityID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);

    local PurchasePrice = Logic.GetCurrentPrice(PlayerID, BuyType);
    self:ManipulateGoodPurchasePrice(PlayerID, BuyType, PurchasePrice);
    local SellPrice = Logic.GetCurrentPrice(PlayerID, SellType);
    self:ManipulateGoodSellPrice(PlayerID, SellType, SellPrice);

    GameCallback_SH_GoodsTraded(PlayerID, EntityID, BuyType, BuyAmount, SellType, SellAmount)
end

function Stronghold:ManipulateGoodPurchasePrice(_PlayerID, _Resource, _Price)
    local MinBuyCap = GameCallback_SH_Calculate_PurchaseMinPriceFactor(_PlayerID, _Resource);
    local MaxBuyCap = GameCallback_SH_Calculate_PurchaseMaxPriceFactor(_PlayerID, _Resource);
    Logic.SetCurrentPrice(_PlayerID, _Resource, math.max(math.min(_Price, MaxBuyCap), MinBuyCap));
end

function Stronghold:ManipulateGoodSellPrice(_PlayerID, _Resource, _Price)
    local MinSellCap = GameCallback_SH_Calculate_SellMinPriceFactor(_PlayerID, _Resource);
    local MaxSellCap = GameCallback_SH_Calculate_SellMaxPriceFactor(_PlayerID, _Resource);
    Logic.SetCurrentPrice(_PlayerID, _Resource, math.max(math.min(_Price, MaxSellCap), MinSellCap));
end

-- -------------------------------------------------------------------------- --
-- Defeat Condition

-- The player is defeated when the headquarter is destroyed. This is not so
-- much like Stronghold but having 1 super strong hero as the main target
-- might be a bit risky.
function Stronghold:PlayerDefeatCondition(_PlayerID)
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
                if not self:IsAIPlayer(_PlayerID) then
                    self.Players[_PlayerID].InvulnerabilityInfoShown = true;
                    Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
                    local PlayerName = UserTool_GetPlayerName(_PlayerID);
                    local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
                    Message(string.format(
                        XGUIEng.GetStringTableText("sh_text/Player_IsProtected"),
                        PlayerColor,
                        PlayerName
                    ));
                end
            end
        end
    else
        if Logic.IsEntityInCategory(HQID, EntityCategories.Headquarters) == 1 then
            self.Players[_PlayerID].InvulnerabilityInfoShown = false;
            if IsExisting(self.Players[_PlayerID].HQScriptName) then
                MakeVulnerable(self.Players[_PlayerID].HQScriptName);
            end
            if not self.Players[_PlayerID].VulnerabilityInfoShown then
                if not self:IsAIPlayer(_PlayerID) then
                    self.Players[_PlayerID].VulnerabilityInfoShown = true;
                    Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
                    local PlayerName = UserTool_GetPlayerName(_PlayerID);
                    local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
                    Message(string.format(
                        XGUIEng.GetStringTableText("sh_text/Player_IsVulnerable"),
                        PlayerColor,
                        PlayerName
                    ));
                end
            end
        end
    end

    -- Check HQ
    if not IsExisting(HQID) and Logic.PlayerGetGameState(_PlayerID) == 1 then
        Logic.PlayerSetGameStateToLost(_PlayerID);

        local PlayerName = UserTool_GetPlayerName(_PlayerID);
        local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
        Message(string.format(
            XGUIEng.GetStringTableText("sh_text/Player_IsDead"),
            PlayerColor,
            PlayerName
        ));
    end
end

-- -------------------------------------------------------------------------- --
-- Entity Record

function Stronghold:InitPlayerEntityRecord()
    for i= 1, GetMaxPlayers() do
        self.Record[i] = {
            All = {},
            Building = {},
            Fortification = {},
            Workplace = {},
            Settler = {},
            Leader = {},
            Cannon = {},
            Worker = {},
        };

        for k,v in pairs(GetPlayerEntities(i, 0)) do
            self:AddEntityToPlayerRecordOnCreate(v);
        end
    end
end

function Stronghold:AddEntityToPlayerRecordOnCreate(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if self.Record[PlayerID] then
        if Logic.IsBuilding(_EntityID) == 1 or Logic.IsSettler(_EntityID) == 1 then
            -- Insert to all
            self.Record[PlayerID].All[_EntityID] = true;
            -- Insert to buildings
            if Logic.IsBuilding(_EntityID) == 1 then
                self.Record[PlayerID].Building[_EntityID] = true;
                if Logic.IsEntityInCategory(_EntityID, EntityCategories.MilitaryBuilding) == 1 then
                    self.Record[PlayerID].Fortification[_EntityID] = true;
                end
                if Logic.GetBuildingWorkPlaceLimit(_EntityID) > 0 then
                    self.Record[PlayerID].Workplace[_EntityID] = true;
                end
            end
            -- Insert to settlers
            if Logic.IsSettler(_EntityID) == 1 then
                self.Record[PlayerID].Settler[_EntityID] = true;
                if (Logic.IsLeader(_EntityID) == 1 and Logic.IsHero(_EntityID) == 0)
                or Logic.IsEntityInCategory(_EntityID, EntityCategories.Cannon) == 1 then
                    self.Record[PlayerID].Leader[_EntityID] = true;
                end
                if Logic.IsEntityInCategory(_EntityID, EntityCategories.Cannon) == 1 then
                    self.Record[PlayerID].Cannon[_EntityID] = true;
                end
                if Logic.IsWorker(_EntityID) == 1 then
                    self.Record[PlayerID].Worker[_EntityID] = true;
                end
            end
        end
    end
end

function Stronghold:RemoveEntityFromPlayerRecordOnDestroy(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if self.Record[PlayerID] then
        self.Record[PlayerID].All[_EntityID] = nil;
        self.Record[PlayerID].Building[_EntityID] = nil;
        self.Record[PlayerID].Fortification[_EntityID] = nil;
        self.Record[PlayerID].Workplace[_EntityID] = nil;
        self.Record[PlayerID].Settler[_EntityID] = nil;
        self.Record[PlayerID].Leader[_EntityID] = nil;
        self.Record[PlayerID].Cannon[_EntityID] = nil;
        self.Record[PlayerID].Worker[_EntityID] = nil;
    end
end

function Stronghold:GetEntitiesOfType(_PlayerID, _Type, _IsConstructed, _Group)
    _Group = _Group or "All";
    local List = {};
    if self:IsPlayer(_PlayerID) then
        for ID,_ in pairs(self.Record[_PlayerID][_Group]) do
            if IsExisting(ID) then
                if _Type == 0 or Logic.GetEntityType(ID) == _Type then
                    if Logic.IsBuilding(ID) == 1 then
                        if not _IsConstructed or Logic.IsConstructionComplete(ID) == 1 then
                            table.insert(List, ID);
                        end
                    else
                        table.insert(List, ID);
                    end
                end
            end
        end
    end
    return List;
end

function Stronghold:GetBuildingsOfType(_PlayerID, _Type, _IsConstructed, _Group)
    _Group = _Group or "Building";
    local List = {};
    if self:IsPlayer(_PlayerID) then
        for ID,_ in pairs(self.Record[_PlayerID][_Group]) do
            if IsExisting(ID) then
                if _Type == 0 or Logic.GetEntityType(ID) == _Type then
                    if not _IsConstructed or Logic.IsConstructionComplete(ID) == 1 then
                        table.insert(List, ID);
                    end
                end
            end
        end
    end
    return List;
end

function Stronghold:GetFortificationOfType(_PlayerID, _Type, _IsConstructed)
    return self:GetBuildingsOfType(_PlayerID, _Type, _IsConstructed == true, "Fortification");
end

function Stronghold:GetWorkplacesOfType(_PlayerID, _Type, _IsConstructed)
    return self:GetBuildingsOfType(_PlayerID, _Type, _IsConstructed == true, "Workplace");
end

function Stronghold:GetSettlersOfType(_PlayerID, _Type, _Group)
    _Group = _Group or "Settler";
    local List = {};
    if self:IsPlayer(_PlayerID) then
        for ID,_ in pairs(self.Record[_PlayerID][_Group]) do
            if IsExisting(ID) then
                if _Type == 0 or Logic.GetEntityType(ID) == _Type then
                    table.insert(List, ID);
                end
            end
        end
    end
    return List;
end

function Stronghold:GetLeadersOfType(_PlayerID, _Type)
    return self:GetSettlersOfType(_PlayerID, _Type, "Leader");
end

function Stronghold:GetCannonsOfType(_PlayerID, _Type)
    return self:GetSettlersOfType(_PlayerID, _Type, "Cannon");
end

function Stronghold:GetWorkersOfType(_PlayerID, _Type)
    return self:GetSettlersOfType(_PlayerID, _Type, "Worker");
end

-- -------------------------------------------------------------------------- --
-- Payday

function Stronghold:SetupPaydayForAllPlayers()
    for i= 1, GetMaxPlayers() do
        CUtil.Payday_SetActive(i, true);
    end
end

function Stronghold:ConfigurePaydayForAllPlayers()
    for i= 1, GetMaxPlayers() do
        if Logic.IsTechnologyResearched(i,Technologies.T_BookKeeping) == 0 then
            CUtil.Payday_SetFrequency(i, self.Config.Payday.Base);
        else
            CUtil.Payday_SetFrequency(i, self.Config.Payday.Improved);
        end
    end
end

-- Payday updater
function Stronghold:StartPlayerPaydayUpdater()
    GameCallback_PaydayPayed = function(_PlayerID, _Amount)
        if _Amount ~= nil and IsPlayer(_PlayerID) then
            -- Change frequency on next payday
            if  Logic.IsTechnologyResearched(_PlayerID,Technologies.T_BookKeeping) == 1
            and CUtil.Payday_GetFrequency(_PlayerID) == self.Config.Payday.Base then
                CUtil.Payday_SetFrequency(_PlayerID, self.Config.Payday.Improved);
            end

            -- Execute payday
            return Stronghold:OnPlayerPayday(_PlayerID);
        end
        return 0;
    end
end

-- Payday controller
-- Applies everything that is happening on the payday.
function Stronghold:OnPlayerPayday(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        -- Do not calculate for AI
        if self:IsAIPlayer(_PlayerID) then
            return 0;
        end

        -- First regular payday
        if Logic.GetNumberOfAttractedWorker(_PlayerID) > 0 and Logic.GetTime() > 1 then
            self.Players[_PlayerID].HasHadRegularPayday = true;
        end

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

        -- Tax and Upkeep
        local Income = Stronghold.Economy.Data[_PlayerID].IncomeMoney;
        local Upkeep = Stronghold.Economy.Data[_PlayerID].UpkeepMoney;
        return GameCallback_SH_Calculate_Payday(_PlayerID, Income - Upkeep);
    end
end

-- -------------------------------------------------------------------------- --
-- Honor

function Stronghold:AddPlayerHonor(_PlayerID, _Amount)
    if _Amount > 0 then
        Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.Silver, _Amount);
    elseif _Amount < 0 then
        Logic.SubFromPlayersGlobalResource(_PlayerID, ResourceType.Silver, (-1) * _Amount);
    end
    GameCallback_SH_Logic_HonorGained(_PlayerID, _Amount);
end

function Stronghold:GetPlayerHonor(_PlayerID)
    return Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Silver);
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
        GameCallback_SH_Logic_ReputationGained(_PlayerID, _Amount);
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

function Stronghold:OverrideStringTableText()
    local Text;
    Text = XGUIEng.GetStringTableText("sh_text/Player_UpgradeStronghold");
    CUtil.SetStringTableText("InGameMessages/GUI_PlayerXHasUpgradeHisKeep", Text);
    Text = XGUIEng.GetStringTableText("sh_text/Player_UpgradeFortress");
    CUtil.SetStringTableText("InGameMessages/GUI_PlayerXHasUpgradeHisCastle", Text);
end

-- Menu update
-- This calls all updates of the selection menu when selection has changed.
function Stronghold:OnSelectionMenuChanged(_EntityID)
    local GuiPlayer = self:GetLocalPlayerID();
    local SelectedID = GUI.GetSelectedEntity();
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if GuiPlayer ~= 17 and GuiPlayer ~= PlayerID then
        return;
    end

    self.Building:OnHeadquarterSelected(SelectedID);
    self.Building:OnMonasterySelected(SelectedID);
    self.Building:OnAlchemistSelected(SelectedID);
    self.Building:OnTowerSelected(SelectedID);
    self.Building:OnVillageCenterSelected(SelectedID);
    self.Building:OnWallSelected(SelectedID);

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
        Stronghold.Building:OnWallOrPalisadeUpgraded(_BuildingID);
    end);

    Overwrite.CreateOverwrite("GameCallback_OnTransactionComplete", function(_BuildingID)
        Overwrite.CallOriginal();
        Stronghold:OnSelectionMenuChanged(_BuildingID);
    end);

    GUIUpdate_RecruitQueueButton = function(_Button, _Technology)
    end

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
        if GUI.GetPlayerID() ~= 17 then
            if  not Stronghold.Recruitment:OnBarracksSettlerUpgradeTechnologyClicked(_Technology)
            and not Stronghold.Recruitment:OnArcherySettlerUpgradeTechnologyClicked(_Technology)
            and not Stronghold.Recruitment:OnStableSettlerUpgradeTechnologyClicked(_Technology) then
                Overwrite.CallOriginal();
            end
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

    Overwrite.CreateOverwrite("GUITooltip_ConstructBuilding", function( _UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut)
        local GuiPlayer = GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        Overwrite.CallOriginal();
        Stronghold.Construction:PrintTooltipConstructionButton(_UpgradeCategory, _KeyNormal, _KeyDisabled, _Technology, _ShortCut);
    end);

    Overwrite.CreateOverwrite("GUITooltip_Payday", function()
        local PlayerID = GetLocalPlayerID();
        local PaydayTimeLeft = math.ceil(Logic.GetPlayerPaydayTimeLeft(PlayerID)/1000);
        local PaydayFrequency = Logic.GetPlayerPaydayFrequency(PlayerID);
        local PaydayCosts = Logic.GetPlayerPaydayCost(PlayerID);

        local TooltipString = string.format(
            " @color:200,200,200,255 %s @cr %d @color:255,255,255,255 %s ",
            XGUIEng.GetStringTableText("IngameMenu/NameTaxday"),
            PaydayTimeLeft,
            XGUIEng.GetStringTableText("IngameMenu/TimeUntilTaxday")
        );
        local AmendText = Stronghold.Economy:CreatePaydayClockTooltipText(PlayerID);
        TooltipString = TooltipString .. AmendText;
        XGUIEng.SetText("TooltipTopText", TooltipString);
    end);

    Overwrite.CreateOverwrite("GUITooltip_Generic", function(_Key)
        local PlayerID = GetLocalPlayerID();
        local EntityID = GUI.GetSelectedEntity();
        if not IsPlayer(PlayerID) then
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
        if not IsPlayer(PlayerID) then
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

