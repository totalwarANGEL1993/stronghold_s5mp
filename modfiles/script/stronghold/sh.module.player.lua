--- 
--- Player Script
--- 

Stronghold = Stronghold or {};

Stronghold.Player = Stronghold.Player or {
    Data = {},
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- API

--- Creates a new player.
--- @param _PlayerID number  ID of player
--- @param _Serfs?   number  Amount of serfs
function SetupPlayer(_PlayerID, _Serfs)
    if not IsPlayer(_PlayerID) then
        Stronghold.Player:AddPlayer(_PlayerID, false, _Serfs);
    end
end

--- Resets als caches of the player
--- @param _PlayerID number  ID of player
function ResetPlayer(_PlayerID, _Serfs)
    if not IsPlayer(_PlayerID) then
        Stronghold.Player:ResetPlayer(_PlayerID);
    end
end

--- Returns if a player is an AI player.
--- @param _PlayerID integer ID of player
--- @return boolean IsPlayer Is AI player
function IsAIPlayer(_PlayerID)
    return Stronghold.Player:IsAIPlayer(_PlayerID);
end

--- Creates a new player and configures them as AI player.
---
--- A player configured as AI ignores honor and reputation, will not have any
--- criminals and basically can cheat as they want.
---
--- If an AI player shall not have an hero from the begining, 0 must be passed
--- as hero type. Otherwise the default AI hero (Dovbar) is used.
---
--- A AI player can not be initialized without a headquarter!
--- @param _PlayerID integer ID of player
--- @param _Serfs? integer Amount of serfs
--- @param _HeroType? integer Type of hero
function SetupAiPlayer(_PlayerID, _Serfs, _HeroType)
    if not IsPlayer(_PlayerID) then
        Stronghold.Player:AddPlayer(_PlayerID, true, _Serfs, _HeroType);
    end
end

--- Returns if a player is a human player.
--- @param _PlayerID integer ID of player
--- @return boolean IsPlayer Is human player
function IsPlayer(_PlayerID)
    return Stronghold.Player:IsPlayer(_PlayerID);
end

--- Destroys a player and deletes all entities belonging to them.
--- @param _PlayerID integer ID of player
function DestructPlayer(_PlayerID)
    if IsPlayer(_PlayerID) then
        Stronghold.Player:ForcedSelfDesctruct(_PlayerID);
    end
end

--- Sets a player as defeated and deletes all entities. Also the usual defeat
--- message will be shown.
--- @param _PlayerID integer ID of player
function DefeatPlayer(_PlayerID)
    if IsPlayer(_PlayerID) then
        Stronghold.Player:DefeatPlayer(_PlayerID);
    end
end

--- Returns if a player has been initialized.
--- @param _PlayerID integer ID of player
--- @return boolean IsInitalized Is initalized player
function IsPlayerInitalized(_PlayerID)
    return Stronghold.Player:IsPlayerInitalized(_PlayerID);
end

--- Sets the inital rank for all players.
--- (Must be done *before* setting up players because it changes the config!)
--- @param _Rank number ID of rank
function SetInitialRank(_Rank)
    Stronghold.Player:SetInitialRank(_Rank);
end

--- Gives reputation to the player.
--- @param _PlayerID integer ID of player
--- @param _Amount   integer Amount of Reputation
function AddReputation(_PlayerID, _Amount)
    Stronghold.Player:AddPlayerReputation(_PlayerID, _Amount)
end

--- Returns the reputation of the player.
--- @param _PlayerID integer ID of player
--- @return integer Amount Amount of reputation
function GetReputation(_PlayerID)
    return Stronghold.Player:GetPlayerReputation(_PlayerID);
end

--- Returns the max reputation of the player.
--- @param _PlayerID integer ID of player
--- @return integer Amount Limit of reputation
function GetMaxReputation(_PlayerID)
    return Stronghold.Player:GetPlayerReputationLimit(_PlayerID);
end

--- Adds honor to the player.
--- @param _PlayerID integer ID of player
--- @param _Amount   integer Amount of Honor
function AddHonor(_PlayerID, _Amount)
    Stronghold.Player:AddPlayerHonor(_PlayerID, _Amount);
end

--- Returns the amount of honor of the player.
--- @param _PlayerID integer ID of player
--- @return integer Amount Amount of honor
function GetHonor(_PlayerID)
    return Stronghold.Player:GetPlayerHonor(_PlayerID);
end

--- Returns the ID of the players headquarter.
--- @param _PlayerID integer ID of player
--- @return integer ID ID of Headquarters
function GetHeadquarterID(_PlayerID)
    return Stronghold.Player:GetPlayerHeadquarter(_PlayerID);
end

--- Returns the entrance of the headquarter.
--- @param _PlayerID integer ID of player
--- @return table|nil Position Position of entrance
function GetHeadquarterEntrance(_PlayerID)
    return Stronghold.Player:GetPlayerDoorPos(_PlayerID);
end

--- Returns the ID of the players hero.
--- @param _PlayerID integer ID of player
--- @return integer ID ID of hero
function GetNobleID(_PlayerID)
    return Stronghold.Player:GetPlayerHero(_PlayerID);
end

--- Returns the designated scriptname of the players hero.
--- @param _PlayerID integer ID of player
--- @return string Name Name of hero
function GetNobleScriptname(_PlayerID)
    return Stronghold.Player:GetPlayerHeroName(_PlayerID);
end

--- Returns the max amount of usable player IDs.
--- @return integer Amount Amount of player IDs
function GetMaxPlayers()
    return Stronghold.Player:GetMaxAmountOfPlayersPossible();
end

function SetMaxPlayers(_Max)
    Stronghold.Player:SetMaxAmountOfPlayersPossible(_Max);
end

--- Returns the max amount of human usable player IDs.
--- @return integer Amount Amount of human players
function GetMaxHumanPlayers()
    return Stronghold.Player:GetMaxAmountOfHumanPlayersPossible();
end

function SetMaxHumanPlayers(_Max)
    Stronghold.Player:SetMaxAmountOfHumanPlayersPossible(_Max);
end

--- Returns the tax hight of the player.
---
--- The tax height is between 1 and 5.
--- @param _PlayerID integer ID of player
--- @return integer Height Tax height
function GetTaxHeight(_PlayerID)
    return Stronghold.Player:GetPlayerTaxHeight(_PlayerID) +1;
end

--- Sets the tax height of the player.
---
--- The tax height is between 1 and 5.
--- @param _PlayerID integer ID of player
--- @param _Height integer Tax height
function SetTaxHeight(_PlayerID, _Height)
    Stronghold.Player:SetPlayerTaxHeight(_PlayerID, _Height -1);
end

--- Returns if the game mode is Conservative.
--- @return boolean Mode Is game mode
function IsGameModeConservative()
    return Stronghold.Player.Config.DefeatModes.Conservative;
end

--- Returns if the game mode is Kingsmaker.
--- @return boolean Mode Is game mode
function IsGameModeKingsmaker()
    return Stronghold.Player.Config.DefeatModes.Kingsmaker;
end

--- Returns if the game mode is Annihilation.
--- @return boolean Mode Is game mode
function IsGameModeAnnihilation()
    return Stronghold.Player.Config.DefeatModes.Annihilation;
end

--- Returns if the game mode is Custom.
--- @return boolean Mode Is game mode
function IsGameModeCustom()
    return not IsGameModeConservative() and
           not IsGameModeKingsmaker() and
           not IsGameModeAnnihilation();
end

--- Returns the ration level of all workers.
--- @param _PlayerID integer ID of player
--- @return integer Level Ration level
function GetRationLevel(_PlayerID)
    return Stronghold.Player:GetRationLevel(_PlayerID);
end

--- Changes the ration level of all workers.
--- @param _PlayerID integer ID of player
--- @param _Level integer Ration level
function SetRationLevel(_PlayerID, _Level)
    Stronghold.Player:SetRationLevel(_PlayerID, _Level);
end

--- Returns the sleep time level of all workers.
--- @param _PlayerID integer ID of player
--- @return integer Level Sleep time level
function GetSleepTimeLevel(_PlayerID)
    return Stronghold.Player:GetSleepTimeLevel(_PlayerID);
end

--- Changes the sleep time level of all workers.
--- @param _PlayerID integer ID of player
--- @param _Level integer Sleep time level
function SetSleepTimeLevel(_PlayerID, _Level)
    Stronghold.Player:SetSleepTimeLevel(_PlayerID, _Level);
end

--- Returns the beverage level of all workers.
--- @param _PlayerID integer ID of player
--- @return integer Level Beverage level
function GetBeverageLevel(_PlayerID)
    return Stronghold.Player:GetBeverageLevel(_PlayerID);
end

--- Changes the beverage level of all workers.
--- @param _PlayerID integer ID of player
--- @param _Level integer Beverage level
function SetBeverageLevel(_PlayerID, _Level)
    Stronghold.Player:SetBeverageLevel(_PlayerID, _Level);
end

--- Returns the festival level in the keep
--- @param _PlayerID integer ID of player
--- @return integer Level Sermon level
function GetFestivalLevel(_PlayerID)
    return Stronghold.Player:GetFestivalLevel(_PlayerID);
end

--- Changes the festival level in the keep
--- @param _PlayerID integer ID of player
--- @param _Level integer Sermon level
function SetFestivalLevel(_PlayerID, _Level)
    Stronghold.Player:SetFestivalLevel(_PlayerID, _Level);
end

--- Returns the costs of the festival level in the keep.
--- @param _PlayerID integer ID of player
--- @param _Level integer Sermon level
--- @return table Costs Costs table
function GetFestivalCosts(_PlayerID, _Level)
    return Stronghold.Player:GetFestivalCosts(_PlayerID, _Level);
end

--- Returns the sermon level in the church.
--- @param _PlayerID integer ID of player
--- @return integer Level Sermon level
function GetSermonLevel(_PlayerID)
    return Stronghold.Player:GetSermonLevel(_PlayerID);
end

--- Changes the sermon level in the church.
--- @param _PlayerID integer ID of player
--- @param _Level integer Sermon level
function SetSermonLevel(_PlayerID, _Level)
    Stronghold.Player:SetSermonLevel(_PlayerID, _Level);
end

--- Returns the costs of the sermon level in the church.
--- @param _PlayerID integer ID of player
--- @param _Level integer Sermon level
--- @return table Costs Costs table
function GetSermonCosts(_PlayerID, _Level)
    return Stronghold.Player:GetSermonCosts(_PlayerID, _Level);
end

-- -------------------------------------------------------------------------- --
-- Callbacks

--- Triggered when a player gains honor.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Amount
function GameCallback_SH_Logic_HonorGained(_PlayerID, _Amount)
end

--- Triggered when a player gains reputation.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Amount
function GameCallback_SH_Logic_ReputationGained(_PlayerID, _Amount)
end

--- Triggered when a player is initialized.
---
--- The ID of the castle will be 0 if the player starts without a castle.
--- @param _PlayerID integer ID of player
--- @param _CastleID integer ID of headquarters
--- @param _IsAI boolean Player is AI
function GameCallback_SH_Logic_OnPlayerInitialized(_PlayerID, _CastleID, _IsAI)
end

--- Triggered when a player gets their headquarter.
--- @param _PlayerID integer ID of player
--- @param _CastleID integer ID of headquarters
function GameCallback_SH_Logic_OnHeadquarterReceived(_PlayerID, _CastleID)
end

--- Triggered for each entity that has been attacked recently.
--- @param _PlayerID integer ID of player
--- @param _AttackedID integer ID of attacked entity
--- @param _AttackerID integer ID of attacking entity
--- @param _TimeRemaining integer Time until entry is removed
function GameCallback_SH_Logic_OnAttackRegisterIteration(_PlayerID, _AttackedID, _AttackerID, _TimeRemaining)
end

--- Calculates the costs for the festival.
--- @param _PlayerID integer ID of player
--- @param _MoneyCost integer Money cost
--- @return integer Money Altered money Cost
function GameCallback_SH_CalculateFestivalCosts(_PlayerID, _MoneyCost)
    return _MoneyCost;
end

--- Calculates the costs for the sermon.
--- @param _PlayerID integer ID of player
--- @param _MoneyCost integer Money cost
--- @return integer Money Altered money Cost
function GameCallback_SH_CalculateSermonCosts(_PlayerID, _MoneyCost)
    return _MoneyCost;
end

-- -------------------------------------------------------------------------- --
-- Main

function Stronghold.Player:Install()
    for PlayerID = 1, GetMaxPlayers() do
        self.Data[PlayerID] = {};
    end
    self:SetupPaydayForAllPlayers();
    self:ConfigurePaydayForAllPlayers();
    self:UnlockAllTechnologies();
end

function Stronghold.Player:OnSaveGameLoaded()
    self:SetupPaydayForAllPlayers();
    self:ConfigurePaydayForAllPlayers();
end

function Stronghold.Player:OncePerSecond(_PlayerID)
    -- Attack register
    Stronghold.Player:AttackMemoryController(_PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Game Mode

function Stronghold.Player:ActivateGameModeKingsmaker()
    self.Config.DefeatModes.Conservative = true;
    self.Config.DefeatModes.Kingsmaker = false;
    self.Config.DefeatModes.Annihilation = false;
end

function Stronghold.Player:ActivateGameModeSuddenDeath()
    self.Config.DefeatModes.Conservative = false;
    self.Config.DefeatModes.Kingsmaker = true;
    self.Config.DefeatModes.Annihilation = false;
end

function Stronghold.Player:ActivateGameModeAnnihilation()
    self.Config.DefeatModes.Conservative = false;
    self.Config.DefeatModes.Kingsmaker = false;
    self.Config.DefeatModes.Annihilation = true;
end

-- -------------------------------------------------------------------------- --
-- Player

function Stronghold.Player:SetInitialRank(_Rank)
    assert(_Rank >= PlayerRank.Commoner and _Rank <= PlayerRank.Duke, "Invalid rank!");
    for k,v in pairs(self.Data) do
        if self.Data[k] and self.Data[k].Player.IsInitalized then
            assert(false, "A player was already setup!");
            return;
        end
    end
    self.Config.Base.InitialRank = _Rank;
end

function Stronghold.Player:AddPlayer(_PlayerID, _IsAI, _Serfs, _HeroType)
    local LordName = "LordP" .._PlayerID;
    local HQName = "HQ" .._PlayerID;

    -- Create player data
    self.Data[_PlayerID].Player = {
        IsInitalized = false,
        IsAI = _IsAI == true,
        LordScriptName = LordName,
        HQScriptName = HQName,
        DoorPos = nil,
        CampPos = nil,

        ReputationLimit = 200,
        Reputation = 100,

        Rations = 0,
        SleepTime = 0,
        Beverage = 0,
        Sermon = 0,
        Festival = 0,

        InvulnerabilityInfoShown = false,
        VulnerabilityInfoShown = true,
        AttackMemory = {},
    };

    Job.Turn(function(_PlayerID, _Serfs, _HeroType)
        return Stronghold.Player:WaitForInitalizePlayer(_PlayerID, _Serfs, _HeroType);
    end, _PlayerID, _Serfs, _HeroType);
end

function Stronghold.Player:ResetPlayer(_PlayerID)
    Stronghold.Building:ResetBuildingCreationBonus(_PlayerID);
end

function Stronghold.Player:GetPlayer(_PlayerID)
    if self.Data[_PlayerID] then
        return self.Data[_PlayerID].Player;
    end
end

function Stronghold.Player:IsPlayer(_PlayerID)
    return self:GetPlayer(_PlayerID) ~= nil;
end

function Stronghold.Player:IsAIPlayer(_PlayerID)
    local Player = self:GetPlayer(_PlayerID);
    return Player and Player.IsAI == true;
end

function Stronghold.Player:IsPlayerInitalized(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self:GetPlayer(_PlayerID).IsInitalized == true;
    end
    return false;
end

function Stronghold.Player:IsPlayerHQCreated(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Player.HQCreated == true;
    end
    return false;
end

function Stronghold.Player:GetPlayerHeadquarter(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return GetID(self.Data[_PlayerID].Player.HQScriptName);
    end
    return 0;
end

function Stronghold.Player:GetPlayerDoorPos(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Player.DoorPos;
    end
end

function Stronghold.Player:GetPlayerHero(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return GetID(self.Data[_PlayerID].Player.LordScriptName);
    end
    return 0;
end

function Stronghold.Player:GetPlayerHeroName(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Player.LordScriptName;
    end
end

function Stronghold.Player:GetPlayerTaxHeight(_PlayerID)
    return Logic.GetTaxLevel(_PlayerID);
end

function Stronghold.Player:SetPlayerTaxHeight(_PlayerID, _Height)
    if CNetwork then
        SendEvent.SetTaxes(_PlayerID, _Height);
    else
        GUI.SetTaxLevel(_Height);
    end
end

function Stronghold.Player:InitalizePlayerWithoutHeadquarters(_PlayerID, _StartPosition, _HeroType, _SerfAmount)
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
        return Stronghold.Player:WaitForPlayersHeadquarterConstructed(_PlayerID);
    end, _PlayerID);

    -- Save player initialized
    self.Data[_PlayerID].Player.IsInitalized = true;
    GameCallback_SH_Logic_OnPlayerInitialized(_PlayerID, 0, self:IsAIPlayer(_PlayerID));
end

function Stronghold.Player:InitalizePlayerWithHeadquarters(_PlayerID, _Serfs, _HeroType)
    local CastleID = GetID("HQ" .._PlayerID);

    self:InitalizePlayersHeadquarter(_PlayerID);
    self:InitalizePlayersSerfs(_PlayerID, _Serfs);
    SetRank(_PlayerID, self.Config.Base.InitialRank);
    Logic.PlayerSetGameStateToPlaying(_PlayerID);
    self:InitalizeAiPlayer(_PlayerID, _HeroType);

    -- Save player initialized
    self.Data[_PlayerID].Player.IsInitalized = true;
    GameCallback_SH_Logic_OnPlayerInitialized(_PlayerID, CastleID, self:IsAIPlayer(_PlayerID));
end

function Stronghold.Player:InitalizeAiPlayer(_PlayerID, _HeroType)
    if self:IsAIPlayer(_PlayerID) then
        local Position = self.Data[_PlayerID].Player.DoorPos;
        local Type = _HeroType or Entities.CU_Hero13;
        if Type ~= 0 then
            PlayerCreateNoble(_PlayerID, Type, Position);
            local HeroID = GetID(self.Data[_PlayerID].Player.LordScriptName);
            Logic.RotateEntity(HeroID, 180);
            Logic.PlayerSetIsHumanFlag(_PlayerID, 0);
        end
    end
end

function Stronghold.Player:InitalizePlayersHeadquarter(_PlayerID)
    local HQName = self.Data[_PlayerID].Player.HQScriptName;
    local DoorPosName = "DoorP" .._PlayerID;
    local CampName = "CampP" .._PlayerID;

    -- Get headquarters
    local CastleID = GetID(self.Data[_PlayerID].Player.HQScriptName);
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
        if (Orientation >= 0 and Orientation <= 45)
        or (Orientation >= 225 and Orientation <= 315)
        or  Orientation >= 315 then
            DoorPos.Y = DoorPos.Y + 0;
        else
            DoorPos.Y = DoorPos.Y + 100;
        end
        ID = Logic.CreateEntity(Entities.XD_BuildBlockScriptEntity, DoorPos.X, DoorPos.Y, Orientation, 0);
        Logic.SetEntityName(ID, DoorPosName);
        self.Data[_PlayerID].Player.DoorPos = DoorPos;
    else
        ID = ReplaceEntity(DoorPosName, Entities.XD_BuildBlockScriptEntity);
        DoorPos = GetPosition(DoorPosName);
        self.Data[_PlayerID].Player.DoorPos = DoorPos;
    end

    -- Create camp Pos
    ID = Logic.CreateEntity(Entities.XD_ScriptEntity, DoorPos.X, DoorPos.Y, Orientation, _PlayerID);
    local CampPos = GetCirclePosition(ID, 400, 180);
    self.Data[_PlayerID].Player.CampPos = CampPos;
    DestroyEntity(ID);
    -- Create camp
    ID = Logic.CreateEntity(Entities.XD_BuildBlockScriptEntity, CampPos.X, CampPos.Y, 0, 0);
    Logic.SetEntityName(ID, CampName);
    if Logic.IsEntityInCategory(CastleID, EntityCategories.Headquarters) == 1 then
        Logic.SetModelAndAnimSet(ID, Models.XD_LargeCampFire);
        SVLib.SetInvisibility(ID, false);
    end

    -- Create turrets
    Stronghold.Building:CreateTurretsForBuilding(CastleID);

    -- Register
    self.Data[_PlayerID].Player.HQCreated = true;

    Job.Second(function(_PlayerID)
        return Stronghold.Player:WaitForPlayersHeadquarterDestroyed(_PlayerID);
    end, _PlayerID);
    GameCallback_SH_Logic_OnHeadquarterReceived(_PlayerID, CastleID);
end

function Stronghold.Player:InitalizePlayersSerfs(_PlayerID, _Serfs, _CampPos, _LookAt)
    local CampName = _LookAt or ("CampP" .._PlayerID);
    local CampPos = _CampPos or self.Data[_PlayerID].Player.CampPos;

    -- Create serfs
    local SerfCount = _Serfs or self.Config.Base.StartingSerfs;
    for i= 1, SerfCount do
        local SerfPos = GetCirclePosition(CampPos, 250, (360/SerfCount) * i);
        local ID = Logic.CreateEntity(Entities.PU_Serf, SerfPos.X, SerfPos.Y, 360 - ((360/SerfCount) * i), _PlayerID);
        if IsExisting(CampName) then
            LookAt(ID, CampName);
        end
    end
end

-- This job is waiting to initalize a player.
--
-- To initialize a player, one of 3 conditions must be fulfilled:
-- * Player has a fully constructed headquarter
-- * Player as a specific hero
-- * Player has any hero
function Stronghold.Player:WaitForInitalizePlayer(_PlayerID, _Serfs, _HeroType)
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
    for i= table.getn(HeroList), 1, -1 do
        local Type = Logic.GetEntityType(HeroList[i]);
        if Stronghold.Populace.Config.FakeHeroTypes[Type] then
            table.remove(HeroList, i);
        end
    end
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
function Stronghold.Player:WaitForPlayersHeadquarterConstructed(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        if self.Config.DefeatModes.Conservative then
            return true;
        end
        if self.Data[_PlayerID].Player.IsDefeated then
            return true;
        end
        local CastleID = GetID(self.Data[_PlayerID].Player.HQScriptName);
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
            self:ResurrectPlayerLordForAnnihilation(_PlayerID);

            if not self:IsAIPlayer(_PlayerID) then
                Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
                local PlayerName = UserTool_GetPlayerName(_PlayerID);
                local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
                Message(string.format(
                    XGUIEng.GetStringTableText("sh_text/Player_CastleBuild"),
                    PlayerColor,
                    PlayerName
                ));
            end
            return true;
        end
    end
    return false;
end

function Stronghold.Player:ResurrectPlayerLordForAnnihilation(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        if self.Config.DefeatModes.Annihilation
        or (not self.Config.DefeatModes.Conservative and
            not self.Config.DefeatModes.Kingsmaker) then
            local HeroID = GetNobleID(_PlayerID);
            local Health = Logic.GetEntityHealth(HeroID);
            if HeroID ~= 0 and Health == 0 then
                local DoorPos = GetHeadquarterEntrance(_PlayerID);
                assert(DoorPos ~= nil, "Entrance for players HQ does't exist!");
                local ID = SetPosition(HeroID, DoorPos);
                if Logic.GetEntityType(ID) == Entities.CU_BlackKnight then
                    Logic.LeaderChangeFormationType(ID, 1);
                end
                Logic.HurtEntity(ID, Logic.GetEntityHealth(ID));
            end
        end
    end
end

function Stronghold.Player:WaitForPlayerHeroSlowlyDies(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        if self.Config.DefeatModes.Conservative then
            return true;
        end
        if self.Config.DefeatModes.Annihilation then
            return true;
        end
        if self.Data[_PlayerID].Player.IsDefeated then
            return true;
        end
        if GetID(self.Data[_PlayerID].Player.HQScriptName) ~= 0 then
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
function Stronghold.Player:WaitForPlayersHeadquarterDestroyed(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        if not IsExisting(self:GetPlayerHeadquarter(_PlayerID)) then
            -- Rebuild castle job
            Job.Turn(function(_PlayerID)
                return Stronghold.Player:WaitForPlayersHeadquarterConstructed(_PlayerID);
            end, _PlayerID);
            -- Sudden Death job
            Job.Turn(function(_PlayerID)
                return Stronghold.Player:WaitForPlayerHeroSlowlyDies(_PlayerID);
            end, _PlayerID);

            DestroyEntity("DoorP" .._PlayerID);
            DestroyEntity("CampP" .._PlayerID);

            if not self:IsAIPlayer(_PlayerID) then
                Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
                local PlayerName = UserTool_GetPlayerName(_PlayerID);
                local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
                Message(string.format(
                    XGUIEng.GetStringTableText("sh_text/Player_CastleLost"),
                    PlayerColor,
                    PlayerName
                ));
            end
            return true;
        end
    end
    return false;
end

function Stronghold.Player:UnlockAllTechnologies()
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

function Stronghold.Player:GetMaxAmountOfPlayersPossible()
    return self.Config.Base.MaxPossiblePlayers;
end

function Stronghold.Player:SetMaxAmountOfPlayersPossible(_Max)
    assert(_Max <= 16);
    self.Config.Base.MaxPossiblePlayers = _Max;
end

function Stronghold.Player:GetMaxAmountOfHumanPlayersPossible()
    return self.Config.Base.MaxHumanPlayers;
end

function Stronghold.Player:SetMaxAmountOfHumanPlayersPossible(_Max)
    assert(_Max <= 14 and self.Config.Base.MaxPossiblePlayers - _Max >= 2);
    self.Config.Base.MaxHumanPlayers = _Max;
end

function Stronghold.Player:GetRationLevel(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Player.Rations;
    end
    return 0;
end

function Stronghold.Player:SetRationLevel(_PlayerID, _Level)
    if self:IsPlayer(_PlayerID) then
        _Level = (_Level < 0 and 0) or _Level;
        self.Data[_PlayerID].Player.Rations = _Level;
    end
end

function Stronghold.Player:GetSleepTimeLevel(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Player.SleepTime;
    end
    return 0;
end

function Stronghold.Player:SetSleepTimeLevel(_PlayerID, _Level)
    if self:IsPlayer(_PlayerID) then
        _Level = (_Level < 0 and 0) or _Level;
        self.Data[_PlayerID].Player.SleepTime = _Level;
    end
end

function Stronghold.Player:GetBeverageLevel(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Player.Beverage;
    end
    return 0;
end

function Stronghold.Player:SetBeverageLevel(_PlayerID, _Level)
    if self:IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Player.Beverage = _Level;
    end
end

function Stronghold.Player:GetFestivalLevel(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Player.Festival;
    end
    return 2;
end

function Stronghold.Player:SetFestivalLevel(_PlayerID, _Level)
    if self:IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Player.Festival = _Level;
    end
end

function Stronghold.Player:GetFestivalCosts(_PlayerID, _Level)
    local Costs = {};
    if self:IsPlayer(_PlayerID) then
        local Effects = Stronghold.Economy.Config.Income.Festival[_Level];
        local BaseCost = (Effects and Effects.BaseCost) or 0;
        local Honor = GetHonor(_PlayerID);
        local HonorFactor = Honor / self.Config.Base.FestivalHonorDivisor;
        local Soldiers = Logic.GetNumberOfAttractedSoldiers(_PlayerID);
        local SoldierFactor = Soldiers / self.Config.Base.FestivalSoldierDivisor;
        local MoneyCost = math.floor(BaseCost * (1 + (SoldierFactor + HonorFactor)));
        MoneyCost = GameCallback_SH_CalculateFestivalCosts(_PlayerID, MoneyCost);
        Costs = CreateCostTable(0, MoneyCost, 0, 0, 0, 0, 0, 0);
    end
    return Costs;
end

function Stronghold.Player:GetSermonLevel(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Player.Sermon;
    end
    return 2;
end

function Stronghold.Player:SetSermonLevel(_PlayerID, _Level)
    if self:IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Player.Sermon = _Level;
    end
end

function Stronghold.Player:GetSermonCosts(_PlayerID, _Level)
    local Costs = {};
    if self:IsPlayer(_PlayerID) then
        local Effects = Stronghold.Economy.Config.Income.Sermon[_Level];
        local BaseCost = (Effects and Effects.BaseCost) or 0;
        local WorkerCount = Logic.GetNumberOfAttractedWorker(_PlayerID);
        local MoneyCost = math.ceil(WorkerCount * BaseCost);
        MoneyCost = GameCallback_SH_CalculateSermonCosts(_PlayerID, MoneyCost);
        Costs = CreateCostTable(0, MoneyCost, 0, 0, 0, 0, 0, 0);
    end
    return Costs;
end

-- -------------------------------------------------------------------------- --
-- Attack Memory

function Stronghold.Player:AttackMemoryController(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        for EntityID, Data in pairs(self.Data[_PlayerID].Player.AttackMemory) do
            if not IsExisting(EntityID) then
                self.Data[_PlayerID].Player.AttackMemory[EntityID] = nil;
            else
                self.Data[_PlayerID].Player.AttackMemory[EntityID][1] = Data[1] -1;
                if self.Data[_PlayerID].Player.AttackMemory[EntityID][1] <= 0 then
                    self.Data[_PlayerID].Player.AttackMemory[EntityID] = nil;
                else
                    GameCallback_SH_Logic_OnAttackRegisterIteration(_PlayerID, EntityID, Data[2], Data[1]);
                end
            end
        end
    end
end

function Stronghold.Player:RegisterAttack(_PlayerID, _Attacked, _Attacker, _ValidTime)
    if self:IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Player.AttackMemory[_Attacked] = {_ValidTime, _Attacker};
    end
end

function Stronghold.Player:InvalidateAttackRegister(_PlayerID, _Attacked)
    if self:IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Player.AttackMemory[_Attacked] = nil;
    end
end

-- -------------------------------------------------------------------------- --
-- Payday

function Stronghold.Player:SetupPaydayForAllPlayers()
    for PlayerID = 1, GetMaxPlayers() do
        CUtil.Payday_SetActive(PlayerID, true);
    end
end

function Stronghold.Player:ConfigurePaydayForAllPlayers()
    for PlayerID = 1, GetMaxPlayers() do
        if Logic.IsTechnologyResearched(PlayerID, Technologies.T_BookKeeping) == 0 then
            CUtil.Payday_SetFrequency(PlayerID, self.Config.Payday.Base);
        else
            CUtil.Payday_SetFrequency(PlayerID, self.Config.Payday.Improved);
        end
    end
end

-- Payday controller
-- Applies everything that is happening on the payday.
function Stronghold.Player:OnPlayerPayday(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        -- Do not calculate for AI
        if self:IsAIPlayer(_PlayerID) then
            return 0;
        end

        -- First regular payday
        if Logic.GetNumberOfAttractedWorker(_PlayerID) > 0 and Logic.GetTime() > 1 then
            self.Data[_PlayerID].Player.HasHadRegularPayday = true;
        end

        -- Reputation
        local OldReputation = self:GetPlayerReputation(_PlayerID);
        local ReputationIncome = Stronghold.Economy.Data[_PlayerID].IncomeReputation;
        self.Data[_PlayerID].Player.Reputation = OldReputation + ReputationIncome;
        if self.Data[_PlayerID].Player.Reputation > self.Data[_PlayerID].Player.ReputationLimit then
            self.Data[_PlayerID].Player.Reputation = self.Data[_PlayerID].Player.ReputationLimit;
        end
        if self.Data[_PlayerID].Player.Reputation < 0 then
            self.Data[_PlayerID].Player.Reputation = 0;
        end

        -- Motivation
        Delay.Turn(1, function()
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

function Stronghold.Player:AddPlayerHonor(_PlayerID, _Amount)
    if _Amount > 0 then
        local MaxPossibleHonor = self.Config.Base.MaxHonor - self:GetPlayerHonor(_PlayerID);
        local Amount = math.min(_Amount, math.max(MaxPossibleHonor, 0));
        Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.Silver, Amount);
    elseif _Amount < 0 then
        Logic.SubFromPlayersGlobalResource(_PlayerID, ResourceType.Silver, (-1) * _Amount);
    end
    GameCallback_SH_Logic_HonorGained(_PlayerID, _Amount);
end

function Stronghold.Player:GetPlayerHonor(_PlayerID)
    return Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Silver);
end

-- -------------------------------------------------------------------------- --
-- Reputation

function Stronghold.Player:AddPlayerReputation(_PlayerID, _Amount)
    if self:IsPlayer(_PlayerID) then
        local Reputation = self:GetPlayerReputation(_PlayerID);
        self:SetPlayerReputation(_PlayerID, Reputation + _Amount);
    end
end

function Stronghold.Player:SetPlayerReputation(_PlayerID, _Amount)
    if self:IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Player.Reputation = _Amount;
        if self.Data[_PlayerID].Player.Reputation > self.Data[_PlayerID].Player.ReputationLimit then
            self.Data[_PlayerID].Player.Reputation = self.Data[_PlayerID].Player.ReputationLimit;
        end
        if self.Data[_PlayerID].Player.Reputation < 0 then
            self.Data[_PlayerID].Player.Reputation = 0;
        end
        GameCallback_SH_Logic_ReputationGained(_PlayerID, _Amount);
    end
end

function Stronghold.Player:SetPlayerReputationLimit(_PlayerID, _Amount)
    if self:IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Player.ReputationLimit = _Amount;
    end
end

function Stronghold.Player:GetPlayerReputationLimit(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Player.ReputationLimit;
    end
    return 200;
end

function Stronghold.Player:GetPlayerReputation(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Player.Reputation;
    end
    return 100;
end

-- -------------------------------------------------------------------------- --
-- Defeat Condition

-- The player is defeated when the headquarter is destroyed. This is not so
-- much like Stronghold but having 1 super strong hero as the main target
-- might be a bit risky.
function Stronghold.Player:PlayerDefeatCondition(_PlayerID)
    if not self:IsPlayer(_PlayerID) then
        return;
    end
    if not IsDefaultVictoryConditionActive() then
        return;
    end
    local HeroName = self.Data[_PlayerID].Player.LordScriptName;
    local CastleName = self.Data[_PlayerID].Player.HQScriptName;

    local PlayerIsDefeated = false;
    if self.Config.DefeatModes.Conservative then
        local MaxDistance = self.Config.Base.MaxHeroDistance;
        local HeroAtCastle = false;
        if IsEntityValid(HeroName) and GetDistance(HeroName, CastleName) <= MaxDistance then
            HeroAtCastle = true;
        end

        local HQID = self:GetPlayerHeadquarter(_PlayerID);
        if HeroAtCastle then
            self.Data[_PlayerID].Player.VulnerabilityInfoShown = false;
            if IsExisting(HQID) then
                MakeInvulnerable(CastleName);
            end
            if not self.Data[_PlayerID].Player.InvulnerabilityInfoShown then
                self.Data[_PlayerID].Player.InvulnerabilityInfoShown = true;
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
            self.Data[_PlayerID].Player.InvulnerabilityInfoShown = false;
            if IsExisting(CastleName) then
                MakeVulnerable(CastleName);
            end
            if not self.Data[_PlayerID].Player.VulnerabilityInfoShown then
                self.Data[_PlayerID].Player.VulnerabilityInfoShown = true;
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
    elseif self.Config.DefeatModes.Annihilation then
        local SoldierAmount = Logic.GetNumberOfAttractedSoldiers(_PlayerID);

        -- Deco entities must be explicitly excluded
        SoldierAmount = SoldierAmount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Bear_Deco);
        SoldierAmount = SoldierAmount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Criminal_Deco);
        SoldierAmount = SoldierAmount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Dog_Deco);
        SoldierAmount = SoldierAmount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Hawk_Deco);
        SoldierAmount = SoldierAmount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Rat_Deco);
        SoldierAmount = SoldierAmount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Watchman_Deco);
        -- Cage animals must be explicitly excluded
        SoldierAmount = SoldierAmount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Bear_Cage);
        SoldierAmount = SoldierAmount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Dog_Cage);

        if  SoldierAmount == 0
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

function Stronghold.Player:DefeatPlayer(_PlayerID)
    self.Data[_PlayerID].Player.IsDefeated = true;
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
function Stronghold.Player:ForcedSelfDesctruct(_PlayerID)
    Logic.PlayerSetGameStateToLost(_PlayerID);

    local DestroyLaterTypes = {
        ["PB_Headquarters1"] = true;
        ["PB_Headquarters2"] = true;
        ["PB_Headquarters3"] = true;
        ["PB_Market1"] = true;
        ["PB_Market2"] = true;
        ["PB_Outpost1"] = true;
        ["PB_Outpost2"] = true;
        ["PB_Outpost3"] = true;
        ["PB_LoggingCamp1"] = true;
        ["PB_LoggingCamp2"] = true;
        ["PB_LoggingCamp3"] = true;
        ["PB_ClayMine1"] = true;
        ["PB_ClayMine2"] = true;
        ["PB_ClayMine3"] = true;
        ["PB_IronMine1"] = true;
        ["PB_IronMine2"] = true;
        ["PB_IronMine3"] = true;
        ["PB_StoneMine1"] = true;
        ["PB_StoneMine2"] = true;
        ["PB_StoneMine3"] = true;
        ["PB_SulfurMine1"] = true;
        ["PB_SulfurMine2"] = true;
        ["PB_SulfurMine3"] = true;
    };

    local DestroyNeverTypes = {};

    for Type,_ in pairs(Entities) do
        if not DestroyLaterTypes[Type] and not DestroyNeverTypes[Type] then
            self:ForcedSelfDesctructHelper(_PlayerID, Entities[Type]);
        end;
    end;
    for Type,_ in pairs(DestroyLaterTypes) do
        self:ForcedSelfDesctructHelper(_PlayerID, Entities[Type]);
    end;
end

function Stronghold.Player:ForcedSelfDesctructHelper(_PlayerID, _Type)
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

