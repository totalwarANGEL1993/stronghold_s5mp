---
--- Main Script
---
--- This script manages all components of the stronghold mod.
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
--- - GameCallback_SH_Logic_OnPlayerInitialized(_PlayerID, _CastleID, _IsAI)
---   Called after the player is initialized.
---
--- - GameCallback_SH_Logic_OnHeadquarterReceived(_PlayerID, _CastleID)
---   Called after the player has received their headquarter.
---

Stronghold = {
    Version = "0.6.16",
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
        local Serfs = SHS5MP_RulesDefinition.SerfAmount;
        SetupPlayer(Players[i], Serfs);
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
---
--- This must be called before calling anything else!
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

--- Creates a new player and configures them as AI player.
---
--- A player configured as AI ignores honor and reputation, will not have any
--- criminals and basically can cheat as they want.
---
--- A AI player can not be initialized without a headquarter!
--- @param _PlayerID integer ID of player
--- @param _Serfs? integer Amount of serfs
--- @param _HeroType? integer Type of hero
function SetupAiPlayer(_PlayerID, _Serfs, _HeroType)
    if not IsPlayer(_PlayerID) then
        Stronghold:AddPlayer(_PlayerID, true, _Serfs, _HeroType);
    end
end

--- Destroys a player and deletes all entities belonging to them.
--- @param _PlayerID integer ID of player
function DestructPlayer(_PlayerID)
    if IsPlayer(_PlayerID) then
        Stronghold:ForcedSelfDesctruct(_PlayerID);
    end
end

--- Sets a player as defeated and deletes all entities.
--- @param _PlayerID integer ID of player
function DefeatPlayer(_PlayerID)
    if IsPlayer(_PlayerID) then
        Stronghold:DefeatPlayer(_PlayerID);
    end
end

--- Returns if a player is a human player.
--- @param _PlayerID integer ID of player
--- @return boolean IsPlayer Is human player
function IsPlayer(_PlayerID)
    return Stronghold:IsPlayer(_PlayerID);
end

--- Returns if a player is an AI player.
--- @param _PlayerID integer ID of player
--- @return boolean IsPlayer Is AI player
function IsAIPlayer(_PlayerID)
    return Stronghold:IsAIPlayer(_PlayerID);
end

--- Returns if a player has been initialized.
--- @param _PlayerID integer ID of player
--- @return boolean IsInitalized Is initalized player
function IsPlayerInitalized(_PlayerID)
    return Stronghold:IsPlayerInitalized(_PlayerID);
end

--- Gives reputation to the player.
--- @param _PlayerID integer ID of player
--- @param _Amount   integer Amount of Reputation
function AddReputation(_PlayerID, _Amount)
    Stronghold:AddPlayerReputation(_PlayerID, _Amount)
end

--- Returns the reputation of the player.
--- @param _PlayerID integer ID of player
--- @return integer Amount Amount of reputation
function GetReputation(_PlayerID)
    return Stronghold:GetPlayerReputation(_PlayerID);
end

--- Returns the max reputation of the player.
--- @param _PlayerID integer ID of player
--- @return integer Amount Limit of reputation
function GetMaxReputation(_PlayerID)
    return Stronghold:GetPlayerReputationLimit(_PlayerID);
end

--- Adds honor to the player.
--- @param _PlayerID integer ID of player
--- @param _Amount   integer Amount of Honor
function AddHonor(_PlayerID, _Amount)
    Stronghold:AddPlayerHonor(_PlayerID, _Amount);
end

--- Returns the amount of honor of the player.
--- @param _PlayerID integer ID of player
--- @return integer Amount Amount of honor
function GetHonor(_PlayerID)
    return Stronghold:GetPlayerHonor(_PlayerID);
end

--- Returns the ID of the players headquarter.
--- @param _PlayerID integer ID of player
--- @return integer ID ID of Headquarters
function GetHeadquarterID(_PlayerID)
    return Stronghold:GetPlayerHeadquarter(_PlayerID);
end

--- Returns the ID of the players hero.
--- @param _PlayerID integer ID of player
--- @return integer ID ID of hero
function GetNobleID(_PlayerID)
    return Stronghold:GetPlayerHero(_PlayerID);
end

--- Alters the purchase price of the resource.
--- @param _PlayerID integer ID of player
--- @param _Resource integer Resource type
--- @param _Price    number Price factor
function SetPurchasePrice(_PlayerID, _Resource, _Price)
    Stronghold:ManipulateGoodPurchasePrice(_PlayerID, _Resource, _Price);
end

--- Alters the selling price of the resource.
--- @param _PlayerID integer ID of player
--- @param _Resource integer Resource type
--- @param _Price    number Price factor
function SetSellingPrice(_PlayerID, _Resource, _Price)
    Stronghold:ManipulateGoodSellPrice(_PlayerID, _Resource, _Price);
end

--- Returns the max amount of usable player IDs.
--- @return integer Amount Amount of player IDs
function GetMaxPlayers()
    return Stronghold:GetMaxAmountOfPlayersPossible();
end

--- Returns the max amount of human usable player IDs.
--- @return integer Amount Amount of human players
function GetMaxHumanPlayers()
    return Stronghold:GetMaxAmountOfHumanPlayersPossible();
end

--- Writes a log entry into the server log.
--- @param _Msg string Text of log message
--- @param ... any Optional text parameters
function WriteToLog(_Msg, ...)
    arg = arg or {};
    Stronghold:WriteToLog(_Msg, unpack(arg));
end

--- Writes an sync call to the server log.
--- @param _Module string Name of module
--- @param _Action integer ID of action
--- @param _PlayerID integer ID of player
--- @param ... any Optional text parameters
function WriteSyncCallToLog(_Module, _Action, _PlayerID, ...)
    arg = arg or {};
    local ParameterString = "";
    for i= 1, table.getn(arg) do
        if i > 1 then
            ParameterString = ParameterString .. ",";
        end
        ParameterString = ParameterString .. tostring(arg[i]);
    end
    Stronghold:WriteToLog(Stronghold.Config.Logging.SyncCall, _Module, _Action, _PlayerID, ParameterString);
end

--- Writes an entity creation to the server log.
--- @param _PlayerID integer ID of player
--- @param _EntityID integer ID of entity
--- @param _Type string|integer type of entity
function WriteEntityCreatedToLog(_PlayerID, _EntityID, _Type)
    local Type = _Type;
    if type(Type) == "number" then
        Type = Logic.GetEntityTypeName(Type);
    end
    Stronghold:WriteToLog(Stronghold.Config.Logging.EntityCreated, _PlayerID, _EntityID, Type);
end

--- Writes given resources to the server log.
--- @param _PlayerID integer ID of player
--- @param _Type string|integer type of resource
--- @param _Amount integer Amount of resource
function WriteResourcesGainedToLog(_PlayerID, _Type, _Amount)
    local Type = _Type;
    if type(Type) == "number" then
        Type = KeyOf(Type, ResourceType);
    end
    Stronghold:WriteToLog(Stronghold.Config.Logging.Resource, _PlayerID, Type, _Amount);
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

function GameCallback_SH_Logic_OnPlayerInitialized(_PlayerID, _CastleID, _IsAI)
end

function GameCallback_SH_Logic_OnHeadquarterReceived(_PlayerID, _CastleID)
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

    self.Utils:OverwriteInterfaceTools();
    self.Rights:Install();
    self.Economy:Install();
    self.Construction:Install();
    self.Building:Install();
    self.Recruit:Install();
    self.Hero:Install();
    self.Unit:Install();
    self.Attraction:Install();
    self.Province:Install();
    self.Statistic:Install();
    self.Multiplayer:Install();
    self.AI:Install();
    self.Mercenary:Install();

    self:SetupPaydayForAllPlayers();
    self:ConfigurePaydayForAllPlayers();
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

    -- Call save game stuff
    self.Rights:OnSaveGameLoaded();
    self.Construction:OnSaveGameLoaded();
    self.Building:OnSaveGameLoaded();
    self.Recruit:OnSaveGameLoaded();
    self.Economy:OnSaveGameLoaded();
    self.Hero:OnSaveGameLoaded();
    self.Unit:OnSaveGameLoaded();
    self.Attraction:OnSaveGameLoaded();
    self.Province:OnSaveGameLoaded();
    self.Statistic:OnSaveGameLoaded();
    self.Multiplayer:OnSaveGameLoaded();
    self.AI:OnSaveGameLoaded();
    self.Mercenary:OnSaveGameLoaded();

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
        CampPos = nil;

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

function Stronghold:IsPlayerHQCreated(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Players[_PlayerID].HQCreated == true;
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

function Stronghold:InitalizePlayerWithoutHeadquarters(_PlayerID, _StartPosition, _HeroType, _SerfAmount)
    assert(
        not IsAIPlayer(_PlayerID),
        "Only human players can be initalized without a headquarter!"
    );

    -- Set rank
    SetRank(_PlayerID, self.Config.Base.InitialRank);
    -- Create hero and serfs
    if _StartPosition and _HeroType then
        -- Hero
        local _, HeroID = Logic.GetPlayerEntities(_PlayerID, _HeroType, 1);
        if IsExisting(HeroID) then
            PlayerSetupNoble(_PlayerID, HeroID, _HeroType);
        else
            PlayerCreateNoble(_PlayerID, _HeroType, _StartPosition);
        end
        Camera.ScrollSetLookAt(_StartPosition.X, _StartPosition.Y);
        -- Serfs
        local NobleID = self:GetPlayerHero(_PlayerID);
        self:InitalizePlayersSerfs(_PlayerID, _SerfAmount, _StartPosition, NobleID);
    end
    Logic.PlayerSetGameStateToPlaying(_PlayerID);

    Job.Second(function(_PlayerID)
        return Stronghold:WaitForPlayersHeadquarterConstructed(_PlayerID);
    end, _PlayerID);

    -- Save player initialized
    self.Players[_PlayerID].IsInitalized = true;
    GameCallback_SH_Logic_OnPlayerInitialized(_PlayerID, 0, self:IsAIPlayer(_PlayerID));
end

function Stronghold:InitalizePlayerWithHeadquarters(_PlayerID, _Serfs, _HeroType)
    local CastleID = GetID("HQ" .._PlayerID);

    self:InitalizePlayersHeadquarter(_PlayerID);
    self:InitalizePlayersSerfs(_PlayerID, _Serfs);

    -- Set rank
    SetRank(_PlayerID, self.Config.Base.InitialRank);

    Logic.PlayerSetGameStateToPlaying(_PlayerID);
    self:InitalizeAiPlayer(_PlayerID, _HeroType);

    -- Save player initialized
    self.Players[_PlayerID].IsInitalized = true;
    GameCallback_SH_Logic_OnPlayerInitialized(_PlayerID, CastleID, self:IsAIPlayer(_PlayerID));
end

function Stronghold:InitalizeAiPlayer(_PlayerID, _HeroType)
    if self:IsAIPlayer(_PlayerID) then
        local Position = self.Players[_PlayerID].DoorPos;
        local Type = _HeroType or Entities.CU_Hero13;
        PlayerCreateNoble(_PlayerID, Type, Position);
        local HeroID = GetID(Stronghold.Players[_PlayerID].LordScriptName);
        Logic.RotateEntity(HeroID, 180);
        Logic.PlayerSetIsHumanFlag(_PlayerID, 0);
    end
end

function Stronghold:InitalizePlayersHeadquarter(_PlayerID)
    local HQName = self.Players[_PlayerID].HQScriptName;
    local DoorPosName = "DoorP" .._PlayerID;
    local CampName = "CampP" .._PlayerID;

    -- Get headquarters
    local CastleID = GetID(self.Players[_PlayerID].HQScriptName);
    if CastleID == 0 then
        local _, HQ1ID = Logic.GetPlayerEntities(_PlayerID, Entities.PB_Headquarters1, 1);
        CastleID = (HQ1ID ~= nil and HQ1ID ~= 0 and HQ1ID) or CastleID;
        local _, HQ2ID = Logic.GetPlayerEntities(_PlayerID, Entities.PB_Headquarters2, 1);
        CastleID = (HQ2ID ~= nil and HQ2ID ~= 0 and HQ2ID) or CastleID;
        local _, HQ3ID = Logic.GetPlayerEntities(_PlayerID, Entities.PB_Headquarters3, 1);
        CastleID = (HQ3ID ~= nil and HQ3ID ~= 0 and HQ3ID) or CastleID;
    end
    local Orientation = Logic.GetEntityOrientation(CastleID);
    assert(CastleID ~= 0);
    Logic.SetEntityName(CastleID, HQName);

    -- Fix castle upgrade message
    if Logic.GetUpgradeLevelForBuilding(CastleID) < 1 then
        Logic.SetTechnologyState(_PlayerID, Technologies.UP1_Headquarter, 1);
    end
    if Logic.GetUpgradeLevelForBuilding(CastleID) < 2 then
        Logic.SetTechnologyState(_PlayerID, Technologies.UP2_Headquarter, 1);
    end

    -- Create door pos
    local ID, DoorPos;
    if not IsExisting(DoorPosName) then
        DoorPos = GetCirclePosition(HQName, 800, 180);
        if (Orientation >= 45 and Orientation <= 135) then
            DoorPos.X = DoorPos.X + 150;
        end
        if (Orientation >= 225 and Orientation <= 315) then
            DoorPos.X = DoorPos.X - 150;
        end
        ID = Logic.CreateEntity(Entities.XD_BuildBlockScriptEntity, DoorPos.X, DoorPos.Y, Orientation, 0);
        WriteEntityCreatedToLog(0, ID, Logic.GetEntityType(ID));
        Logic.SetEntityName(ID, DoorPosName);
        self.Players[_PlayerID].DoorPos = DoorPos;
    else
        ID = ReplaceEntity(DoorPosName, Entities.XD_BuildBlockScriptEntity);
        DoorPos = GetPosition(DoorPosName);
        self.Players[_PlayerID].DoorPos = DoorPos;
    end

    -- Create camp Pos
    ID = Logic.CreateEntity(Entities.XD_ScriptEntity, DoorPos.X, DoorPos.Y, Orientation, _PlayerID);
    WriteEntityCreatedToLog(_PlayerID, ID, Logic.GetEntityType(ID));
    local CampPos = GetCirclePosition(ID, 400, 160);
    self.Players[_PlayerID].CampPos = CampPos;
    DestroyEntity(ID);
    -- Create camp
    ID = Logic.CreateEntity(Entities.XD_BuildBlockScriptEntity, CampPos.X, CampPos.Y, 0, 0);
    WriteEntityCreatedToLog(_PlayerID, ID, Logic.GetEntityType(ID));
    Logic.SetModelAndAnimSet(ID, Models.XD_LargeCampFire);
    SVLib.SetInvisibility(ID, false);
    Logic.SetEntityName(ID, CampName);

    -- Create turrets
    self.Building:CreateTurretsForBuilding(CastleID);

    -- Register
    self.Players[_PlayerID].HQCreated = true;

    Job.Second(function(_PlayerID)
        return Stronghold:WaitForPlayersHeadquarterDestroyed(_PlayerID);
    end, _PlayerID);
    GameCallback_SH_Logic_OnHeadquarterReceived(_PlayerID, CastleID)
end

function Stronghold:InitalizePlayersSerfs(_PlayerID, _Serfs, _CampPos, _LookAt)
    local CampName = _LookAt or ("CampP" .._PlayerID);
    local CampPos = _CampPos or self.Players[_PlayerID].CampPos;

    -- Create serfs
    local SerfCount = _Serfs or self.Config.Base.StartingSerfs;
    for i= 1, SerfCount do
        local SerfPos = GetCirclePosition(CampPos, 250, (360/SerfCount) * i);
        ID = Logic.CreateEntity(Entities.PU_Serf, SerfPos.X, SerfPos.Y, 360 - ((360/SerfCount) * i), _PlayerID);
        WriteEntityCreatedToLog(_PlayerID, ID, Logic.GetEntityType(ID));
        LookAt(ID, CampName);
    end
end

-- This job is waiting to initalize a player.
--
-- To initialize a player, one of 3 conditions must be fulfilled:
-- * Player has a fully constructed headquarter
-- * Player as a specific hero
-- * Player has any hero
function Stronghold:WaitForInitalizePlayer(_PlayerID, _Serfs, _HeroType)
    local CastleID = self:GetPlayerHeadquarter(_PlayerID);
    -- Initalize by headquarters
    if (Logic.IsBuilding(CastleID) == 1 and Logic.IsConstructionComplete(CastleID) == 1) then
        self:InitalizePlayerWithHeadquarters(_PlayerID, _Serfs, _HeroType);
        return true;
    end
    -- Initalize with specific hero
    if _HeroType and Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, _HeroType) == 1 then
        local _, HeroID = Logic.GetPlayerEntities(_PlayerID, _HeroType, 1);
        local Position = GetPosition(HeroID);
        self:InitalizePlayerWithoutHeadquarters(_PlayerID, Position, _HeroType, _Serfs);
        return true;
    end
    -- Initalize with any hero
    local HeroList = {};
    Logic.GetHeroes(_PlayerID, HeroList);
    if HeroList[1] then
        local HeroType = Logic.GetEntityType(HeroList[1]);
        local Position = GetPosition(HeroList[1]);
        self:InitalizePlayerWithoutHeadquarters(_PlayerID, Position, HeroType, _Serfs);
        return true;
    end
    return false;
end

-- This job is waiting for a headquarter to be fully constructed. If a player
-- starts out with only a hero then the first fully constructed headquarter
-- is set as the players castle.
-- If the headquarter is destroyed later and the hero is still alive, they will
-- gradually loose health until they die or a headquarter is build.
function Stronghold:WaitForPlayersHeadquarterConstructed(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        if self.Config.DefeatModes.Annihilation then
            return true;
        end
        if self.Players[_PlayerID].IsDefeated then
            return true;
        end
        local CastleID = GetID(self.Players[_PlayerID].HQScriptName);
        if CastleID == 0 then
            local _, HQ1ID = Logic.GetPlayerEntities(_PlayerID, Entities.PB_Headquarters1, 1);
            CastleID = (HQ1ID ~= nil and HQ1ID ~= 0 and HQ1ID) or CastleID;
            local _, HQ2ID = Logic.GetPlayerEntities(_PlayerID, Entities.PB_Headquarters2, 1);
            CastleID = (HQ2ID ~= nil and HQ2ID ~= 0 and HQ2ID) or CastleID;
            local _, HQ3ID = Logic.GetPlayerEntities(_PlayerID, Entities.PB_Headquarters3, 1);
            CastleID = (HQ3ID ~= nil and HQ3ID ~= 0 and HQ3ID) or CastleID;
        end
        if  CastleID ~= 0 and Logic.IsBuilding(CastleID) == 1
        and Logic.IsConstructionComplete(CastleID) == 1 then
            self:InitalizePlayersHeadquarter(_PlayerID);

            Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
            local PlayerName = UserTool_GetPlayerName(_PlayerID);
            local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
            Message(string.format(
                XGUIEng.GetStringTableText("sh_text/Player_CastleBuild"),
                PlayerColor,
                PlayerName
            ));
            return true;
        end
    end
    return false;
end

function Stronghold:WaitForPlayerHeroSlowlyDies(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        if self.Config.DefeatModes.Annihilation then
            return true;
        end
        if self.Config.DefeatModes.LastManStanding then
            return true;
        end
        if self.Players[_PlayerID].IsDefeated then
            return true;
        end
        if GetID(self.Players[_PlayerID].HQScriptName) ~= 0 then
            return true;
        end
        if self:IsPlayerHQCreated(_PlayerID) then
            local HeroID = self:GetPlayerHero(_PlayerID);
            local HeroHealth = Logic.GetEntityHealth(HeroID);
            if IsExisting(HeroID) then
                Logic.HurtEntity(HeroID, math.min(HeroHealth, 2));
            end
        end
    end
    return false;
end

-- This job is waiting for the headquarter being destroyed to clean up stuff
-- that is left behind.
function Stronghold:WaitForPlayersHeadquarterDestroyed(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        if not IsExisting(self:GetPlayerHeadquarter(_PlayerID)) then
            -- Rebuild castle job
            Job.Turn(function(_PlayerID)
                return Stronghold:WaitForPlayersHeadquarterConstructed(_PlayerID);
            end, _PlayerID);
            -- Sudden Death job
            Job.Turn(function(_PlayerID)
                return Stronghold:WaitForPlayerHeroSlowlyDies(_PlayerID);
            end, _PlayerID);

            DestroyEntity("DoorP" .._PlayerID);
            DestroyEntity("CampP" .._PlayerID);

            Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
            local PlayerName = UserTool_GetPlayerName(_PlayerID);
            local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
            Message(string.format(
                XGUIEng.GetStringTableText("sh_text/Player_CastleLost"),
                PlayerColor,
                PlayerName
            ));
            return true;
        end
    end
    return false;
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
-- Logging

function Stronghold:WriteToLog(_Msg, ...)
    local LogMethod;
    -- get log method
    if CLogger then
        LogMethod = CLogger.Log;
    elseif LuaDebugger then
        LogMethod = LuaDebugger.Log;
    end
    -- print log
    if LogMethod then
        if arg and arg[1] then
            LogMethod(string.format(_Msg, unpack(arg)));
        else
            LogMethod(_Msg);
        end
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

-- -------------------------------------------------------------------------- --
-- Trigger

function Stronghold:StartTriggers()
    Job.Second(function()
        local Players = GetMaxPlayers();
        for i= 1, Players do
            Stronghold:PlayerDefeatCondition(i);
        end
        Stronghold.Building:OnEverySecond();
        Stronghold.Province:OnEverySecond();
    end);

    Job.Turn(function()
        Stronghold:DelayedActionController();
        -- Send versions to all other players
        -- (Multiplayer only)
        Stronghold.Multiplayer:BroadcastStrongholdVersion();

        -- Player jobs on each turn
        local Players = GetMaxPlayers();
        for PlayerID = 1, Players do
            Stronghold.Attraction:OnEveryTurn(PlayerID);
            Stronghold.Economy:OncePerTurn(PlayerID);
            Stronghold.Mercenary:OnEveryTurn(PlayerID);
            Stronghold.Rights:OnEveryTurn(PlayerID);
            Stronghold.Recruit:OnEveryTurn(PlayerID);
        end
        -- Player jobs on modified turns
        --- @diagnostic disable-next-line: undefined-field
        for PlayerID = 1, Players do
            --- @diagnostic disable-next-line: undefined-field
            local TimeMod = math.mod(Logic.GetCurrentTurn(), 10);
            --- @diagnostic disable-next-line: undefined-field
            local PlayerMod = math.mod(PlayerID, 10);
            if TimeMod == PlayerMod then
                Stronghold:ClearPlayerRecordCache(PlayerID);
                Stronghold.Attraction:OncePerSecond(PlayerID);
                Stronghold.Building:OncePerSecond(PlayerID);
                Stronghold.Economy:OncePerSecond(PlayerID);
                Stronghold.Hero:OncePerSecond(PlayerID);
                Stronghold.Mercenary:OncePerSecond(PlayerID);
                Stronghold.Unit:OncePerSecond(PlayerID);
            end
        end
    end);

    Job.Create(function()
        local EntityID = Event.GetEntityID();
        Stronghold:AddEntityToPlayerRecordOnCreate(EntityID);
        Stronghold:OnSelectionMenuChanged(EntityID);
        Stronghold.Attraction:OnEntityCreated(EntityID);
        Stronghold.Building:OnEntityCreated(EntityID);
        Stronghold.Economy:OnEntityCreated(EntityID);
        Stronghold.Hero:OnEntityCreated(EntityID);
        Stronghold.Unit:OnEntityCreated(EntityID);
        Stronghold.Recruit:OnEntityCreated(EntityID);
    end);

    Job.Destroy(function()
        local EntityID = Event.GetEntityID();
        Stronghold:RemoveEntityFromPlayerRecordOnDestroy(EntityID);
        Stronghold.Attraction:OnEntityDestroyed(EntityID);
        Stronghold.Building:OnEntityDestroyed(EntityID);
        Stronghold.Construction:OnEntityDestroyed(EntityID);
    end);

    Job.Trade(function()
        local BuyType = Event.GetBuyResource();
        local BuyAmount = Event.GetBuyAmount();
        local SellType = Event.GetSellResource();
        local SellAmount = Event.GetSellAmount();
        local EntityID = Event.GetEntityID();
        local PlayerID = Logic.EntityGetPlayer(EntityID);

        local PurchasePrice = Logic.GetCurrentPrice(PlayerID, BuyType);
        Stronghold:ManipulateGoodPurchasePrice(PlayerID, BuyType, PurchasePrice);
        local SellPrice = Logic.GetCurrentPrice(PlayerID, SellType);
        Stronghold:ManipulateGoodSellPrice(PlayerID, SellType, SellPrice);

        GameCallback_SH_GoodsTraded(PlayerID, EntityID, BuyType, BuyAmount, SellType, SellAmount);
    end);

    Job.Hurt(function()
        Stronghold:OnEntityHurtEntity();
    end);
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
            local DamageClass = CInterface.Logic.GetEntityTypeDamageClass(AttackerType);
            -- Vigilante
            if Logic.IsBuilding(Attacker) == 1 then
                if Logic.IsTechnologyResearched(AttackerPlayer, Technologies.T_Vigilante) == 1 then
                    Damage = Damage * 3;
                end
            end
            -- External
            Damage = GameCallback_SH_Calculate_BattleDamage(Attacker, Attacked, Damage);
            -- prevent eco harrasment
            if DamageClass == 0 or DamageClass == 1 then
                if Logic.IsEntityInCategory(Attacked, EntityCategories.Worker) == 1
                or Logic.IsEntityInCategory(Attacked, EntityCategories.Workplace) == 1
                or AttackedType == Entities.PU_Serf then
                    Damage = 1;
                end
            end
            CEntity.HurtTrigger.SetDamage(math.ceil(Damage));
        end
    end
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
    if not IsDefaultVictoryConditionActive() then
        return;
    end
    local HeroName = self.Players[_PlayerID].LordScriptName;
    local CastleName = self.Players[_PlayerID].HQScriptName;

    local PlayerIsDefeated = false;
    if self.Config.DefeatModes.Annihilation then
        local MaxDistance = self.Config.Base.MaxHeroDistance;
        local HeroAtCastle = false;
        if IsEntityValid(HeroName) and GetDistance(HeroName, CastleName) <= MaxDistance then
            HeroAtCastle = true;
        end

        local HQID = self:GetPlayerHeadquarter(_PlayerID);
        if HeroAtCastle then
            self.Players[_PlayerID].VulnerabilityInfoShown = false;
            if IsExisting(HQID) then
                MakeInvulnerable(CastleName);
            end
            if not self.Players[_PlayerID].InvulnerabilityInfoShown then
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
        else
            self.Players[_PlayerID].InvulnerabilityInfoShown = false;
            if IsExisting(CastleName) then
                MakeVulnerable(CastleName);
            end
            if not self.Players[_PlayerID].VulnerabilityInfoShown then
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

        if  not IsExisting("HQ" .._PlayerID)
        and Logic.PlayerGetGameState(_PlayerID) == 1 then
            PlayerIsDefeated = true;
        end
    elseif self.Config.DefeatModes.LastManStanding then
        if  Logic.GetNumberOfAttractedSoldiers(_PlayerID) == 0
        and not IsEntityValid(HeroName)
        and not IsExisting("HQ" .._PlayerID) then
            PlayerIsDefeated = true;
        end
    else
        if  not IsExisting("HQ" .._PlayerID)
        and not IsEntityValid(HeroName)
        and Logic.PlayerGetGameState(_PlayerID) == 1 then
            PlayerIsDefeated = true;
        end
    end

    if PlayerIsDefeated then
        self:DefeatPlayer(_PlayerID);
    end
end

function Stronghold:DefeatPlayer(_PlayerID)
    self.Players[_PlayerID].IsDefeated = true;
    self:ForcedSelfDesctruct(_PlayerID);

    local PlayerName = UserTool_GetPlayerName(_PlayerID);
    local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
    Message(string.format(
        XGUIEng.GetStringTableText("sh_text/Player_IsDead"),
        PlayerColor,
        PlayerName
    ));
end

-- Deletes all player entities safely.
function Stronghold:ForcedSelfDesctruct(_PlayerID)
    Logic.PlayerSetGameStateToLost(_PlayerID);

    local DestroyLaterTypes = {
        [Entities.PB_Headquarters1] = true;
        [Entities.PB_Headquarters2] = true;
        [Entities.PB_Headquarters3] = true;
        [Entities.PB_Market1] = true;
        [Entities.PB_Market2] = true;
        [Entities.PB_Outpost1] = true;
        [Entities.PB_Outpost2] = true;
        [Entities.PB_Outpost3] = true;
        [Entities.PB_ClayMine1] = true;
        [Entities.PB_ClayMine2] = true;
        [Entities.PB_ClayMine3] = true;
        [Entities.PB_IronMine1] = true;
        [Entities.PB_IronMine2] = true;
        [Entities.PB_IronMine3] = true;
        [Entities.PB_StoneMine1] = true;
        [Entities.PB_StoneMine2] = true;
        [Entities.PB_StoneMine3] = true;
        [Entities.PB_SulfurMine1] = true;
        [Entities.PB_SulfurMine2] = true;
        [Entities.PB_SulfurMine3] = true;
    };

    local DestroyNeverTypes = {
        [Entities.CU_Barbarian_Hero] = true;
        [Entities.CU_BlackKnight] = true;
        [Entities.CU_Evil_Queen] = true;
        [Entities.CU_Mary_de_Mortfichet] = true;
        [Entities.CU_Hero13] = true;
        [Entities.PU_Hero1] = true;
        [Entities.PU_Hero1a] = true;
        [Entities.PU_Hero1b] = true;
        [Entities.PU_Hero1c] = true;
        [Entities.PU_Hero2] = true;
        [Entities.PU_Hero3] = true;
        [Entities.PU_Hero4] = true;
        [Entities.PU_Hero5] = true;
        [Entities.PU_Hero6] = true;
        [Entities.PU_Hero10] = true;
        [Entities.PU_Hero11] = true;
    };

    -- Singleplayer
    for _, Type in pairs(Entities) do
        if not DestroyLaterTypes[Type] and not DestroyNeverTypes[Type] then
            self:ForcedSelfDesctructHelper(_PlayerID, Type);
        end;
    end;
    for Type, _ in pairs(DestroyLaterTypes) do
        self:ForcedSelfDesctructHelper(_PlayerID, Type);
    end;
end

function Stronghold:ForcedSelfDesctructHelper(_PlayerID, _Type)
	while true do
		local TempTable = {Logic.GetPlayerEntities(_PlayerID, _Type, 48)};
		for j = 1,TempTable[1] + 1, 1 do
			Logic.DestroyEntity(TempTable[j]);
		end;
		if TempTable[1] == 0 then
			break;
		end;
	end;
end;

-- -------------------------------------------------------------------------- --
-- Entity Record

function Stronghold:InitPlayerEntityRecord()
    for i= 1, GetMaxPlayers() do
        self.Record[i] = {
            Cache = {},
            --
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

function Stronghold:ClearPlayerRecordCache(_PlayerID)
    if self.Record[_PlayerID] then
        self.Record[_PlayerID].Cache = {};
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
    local List = {0};
    if self:IsPlayer(_PlayerID) then
        -- Use cache if valid
        local Key = _Group.. "_" .._Type.. "_" .._Group.. "_" ..tostring(_IsConstructed);
        if self.Record[_PlayerID].Cache[Key] then
            return self.Record[_PlayerID].Cache[Key];
        end
        -- Find entities
        for ID,_ in pairs(self.Record[_PlayerID][_Group]) do
            if IsExisting(ID) then
                local Type = Logic.GetEntityType(ID);
                local TypeName = Logic.GetEntityTypeName(Type);
                if _Type == 0 or Type == _Type then
                    if Logic.IsBuilding(ID) == 1 then
                        if string.find(TypeName, "CB_") or string.find(TypeName, "PB_") then
                            local Appropiate = true;
                            if _IsConstructed and Logic.IsConstructionComplete(ID) == 0 then
                                Appropiate = false;
                            end
                            if Appropiate then
                                table.insert(List, ID);
                                List[1] = List[1] + 1;
                            end
                        end
                    elseif Logic.IsSettler(ID) == 1 then
                        if string.find(TypeName, "CU_") or string.find(TypeName, "CV_")
                        or string.find(TypeName, "PU_") or string.find(TypeName, "PV_") then
                            table.insert(List, ID);
                            List[1] = List[1] + 1;
                        end
                    end
                end
            end
        end
        -- Save cache
        self.Record[_PlayerID].Cache[Key] = List;
    end
    return List;
end

function Stronghold:GetBuildingsOfType(_PlayerID, _Type, _IsConstructed, _Group)
    _Group = _Group or "Building";
    local List = {0};
    if self:IsPlayer(_PlayerID) then
        -- Use cache if valid
        local Key = _Group.. "_" .._Type.. "_" .._Group.. "_" ..tostring(_IsConstructed);
        if self.Record[_PlayerID].Cache[Key] then
            return self.Record[_PlayerID].Cache[Key];
        end
        -- Find entities
        for ID,_ in pairs(self.Record[_PlayerID][_Group]) do
            if IsExisting(ID) and Logic.IsBuilding(ID) == 1 then
                local Type = Logic.GetEntityType(ID);
                local TypeName = Logic.GetEntityTypeName(Type);
                if _Type == 0 or Type == _Type then
                    if string.find(TypeName, "CB_") or string.find(TypeName, "PB_") then
                        local Appropiate = true;
                        if _IsConstructed and Logic.IsConstructionComplete(ID) == 0 then
                            Appropiate = false;
                        end
                        if Appropiate then
                            table.insert(List, ID);
                            List[1] = List[1] + 1;
                        end
                    end
                end
            end
        end
        -- Save cache
        self.Record[_PlayerID].Cache[Key] = List;
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
    local List = {0};
    if self:IsPlayer(_PlayerID) then
        -- Use cache if valid
        local Key = _Group.. "_" .._Type.. "_" .._Group.. "_nil";
        if self.Record[_PlayerID].Cache[Key] then
            return self.Record[_PlayerID].Cache[Key];
        end
        -- Find entities
        for ID,_ in pairs(self.Record[_PlayerID][_Group]) do
            if IsExisting(ID) and Logic.IsSettler(ID) == 1 then
                local Type = Logic.GetEntityType(ID);
                local TypeName = Logic.GetEntityTypeName(Type);
                if _Type == 0 or Type == _Type then
                    if string.find(TypeName, "CU_") or string.find(TypeName, "CV_")
                    or string.find(TypeName, "PU_") or string.find(TypeName, "PV_") then
                        table.insert(List, ID);
                        List[1] = List[1] + 1;
                    end
                end
            end
        end
        -- Save cache
        self.Record[_PlayerID].Cache[Key] = List;
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
        WriteResourcesGainedToLog(_PlayerID, "Silver", _Amount);
    elseif _Amount < 0 then
        Logic.SubFromPlayersGlobalResource(_PlayerID, ResourceType.Silver, (-1) * _Amount);
        WriteResourcesGainedToLog(_PlayerID, "Silver", (-1) * _Amount);
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
    local SelectedID = GUI.GetSelectedEntity();
    -- Check selected entity is the same as passed entity
    -- (That should never happen in theory)
    local EntityID = _EntityID;
    if SelectedID ~= _EntityID then
        EntityID = SelectedID;
    end

    if EntityID then
        self.Building:OnHeadquarterSelected(EntityID);
        self.Building:OnMonasterySelected(EntityID);
        self.Building:OnAlchemistSelected(EntityID);
        self.Building:OnTowerSelected(EntityID);
        self.Building:OnWallSelected(EntityID);
        self.Building:OnSelectSerf(EntityID);

        self.Hero:OnSelectLeader(EntityID);
        self.Hero:OnSelectHero(EntityID);

        self.Mercenary:OnMercenaryCampSelected(EntityID);

        self.Recruit:OnBarracksSelected(EntityID);
        self.Recruit:OnArcherySelected(EntityID);
        self.Recruit:OnStableSelected(EntityID);
        self.Recruit:OnFoundrySelected(EntityID);
        self.Recruit:OnTavernSelected(EntityID);

        gvStronghold_LastSelectedEntity = EntityID;
    end
end

function Stronghold:OverwriteCommonCallbacks()
    Overwrite.CreateOverwrite("GameCallback_GUI_SelectionChanged", function()
        Overwrite.CallOriginal();
        local EntityID = GUI.GetSelectedEntity();
        local PlayerID = GUI.GetPlayerID();
        Stronghold.Building:OnRallyPointHolderSelected(PlayerID, EntityID);
        Stronghold:OnSelectionMenuChanged(EntityID);
    end);

    Overwrite.CreateOverwrite("GameCallback_OnBuildingConstructionComplete", function(_EntityID, _PlayerID)
        Overwrite.CallOriginal();
        Stronghold:OnSelectionMenuChanged(_EntityID);
        Stronghold.Building:SetIgnoreRallyPointSelectionCancel(_PlayerID);
        Stronghold.Building:CreateTurretsForBuilding(_EntityID);
        Stronghold.Province:OnBuildingConstructed(_EntityID, _PlayerID);
    end);

    Overwrite.CreateOverwrite("GameCallback_OnBuildingUpgradeComplete", function(_EntityIDOld, _EntityIDNew)
        Overwrite.CallOriginal();
        local PlayerID = Logic.EntityGetPlayer(_EntityIDNew);
        Stronghold:OnSelectionMenuChanged(_EntityIDNew);
        Stronghold.Building:SetIgnoreRallyPointSelectionCancel(PlayerID);
        Stronghold.Building:DestroyTurretsOfBuilding(_EntityIDOld);
        Stronghold.Building:CreateTurretsForBuilding(_EntityIDNew);
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

    Overwrite.CreateOverwrite("GUIAction_BuySoldier", function()
        if not Stronghold.Unit:BuySoldierButtonAction() then
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
    Overwrite.CreateOverwrite("GUITooltip_BuySoldier", function(_KeyNormal, _KeyDisabled, _ShortCut)
        Overwrite.CallOriginal();
        Stronghold.Unit:BuySoldierButtonTooltip(_KeyNormal, _KeyDisabled, _ShortCut);
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

