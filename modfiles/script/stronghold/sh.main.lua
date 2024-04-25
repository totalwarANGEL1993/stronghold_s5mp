---
--- Main Script
---
--- This script manages all components of the stronghold mod.
---

Stronghold = {
    Version = "0.7.5",
    Shared = {
        DelayedAction = {},
        HQInfo = {},
    },
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

--- Returns all entities of the type of the player.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type or 0
--- @param _IsConstructed boolean Only fully constructed
--- @return table List List of results
function GetEntitiesOfType(_PlayerID, _Type, _IsConstructed)
    return Stronghold:GetEntitiesOfType(_PlayerID, _Type, _IsConstructed);
end

--- Returns all buildings of the type of the player.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type or 0
--- @param _IsConstructed boolean Only fully constructed
--- @return table List List of results
function GetBuildingsOfType(_PlayerID, _Type, _IsConstructed)
    return Stronghold:GetBuildingsOfType(_PlayerID, _Type, _IsConstructed, nil);
end

--- Returns all walls of the type of the player.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type or 0
--- @param _IsConstructed boolean Only fully constructed
--- @return table List List of results
function GetFortificationOfType(_PlayerID, _Type, _IsConstructed)
    return Stronghold:GetFortificationOfType(_PlayerID, _Type, _IsConstructed == true);
end

--- Returns all workplaces of the type of the player.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type or 0
--- @param _IsConstructed boolean Only fully constructed
--- @return table List List of results
function GetWorkplacesOfType(_PlayerID, _Type, _IsConstructed)
    return Stronghold:GetWorkplacesOfType(_PlayerID, _Type, _IsConstructed == true);
end

--- Returns all workplaces of the type of the player.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type or 0
--- @param _IsConstructed boolean Only fully constructed
--- @return table List List of results
function GetCathedralsOfType(_PlayerID, _Type, _IsConstructed)
    return Stronghold:GetCathedralsOfType(_PlayerID, _Type, _IsConstructed == true);
end

--- Returns all settlers of the type of the player.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type or 0
--- @return table List List of results
function GetSettlersOfType(_PlayerID, _Type)
    return Stronghold:GetSettlersOfType(_PlayerID, _Type);
end

--- Returns all leaders of the type of the player.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type or 0
--- @return table List List of results
function GetLeadersOfType(_PlayerID, _Type)
    return Stronghold:GetLeadersOfType(_PlayerID, _Type);
end

--- Returns all siege engines of the type of the player.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type or 0
--- @return table List List of results
function GetCannonsOfType(_PlayerID, _Type)
    return Stronghold:GetCannonsOfType(_PlayerID, _Type);
end

--- Returns all workers of the type of the player.
--- @param _PlayerID integer ID of player
--- @param _Type integer Entity type or 0
--- @return table List List of results
function GetWorkersOfType(_PlayerID, _Type)
    return Stronghold:GetWorkersOfType(_PlayerID, _Type);
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

--- Triggered when the income of a player is calculated.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Amount
--- @return integer Income Amount of money
function GameCallback_SH_Calculate_Payday(_PlayerID, _Amount)
    return _Amount;
end

--- Triggered when battle damage is calculated.
--- @param _AttackerID integer ID of attacker
--- @param _AttackedID integer ID of attacked
--- @param _Damage integer Damage before calculation
--- @return integer Damage Altered battle damage
function GameCallback_SH_Calculate_BattleDamage(_AttackerID, _AttackedID, _Damage)
    return _Damage;
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

    -- Player 0 building fix
    Score.Player[0] = Score.Player[0] or {};
	Score.Player[0]["buildings"] = Score.Player[0]["buildings"] or 0;
	Score.Player[0]["all"] = Score.Player[0]["all"] or 0;

    if not CMod then
        Message("The S5 Community Server is required!");
        return false;
    end

    self:InitPlayerEntityRecord();
    Camera.ZoomSetFactorMax(2.0);
    GUI.ClearSelection();

    self.Utils:OverwriteLogicTools();
    self.Utils:OverwriteInterfaceTools();
    self.Player:Install();
    self.Rights:Install();
    self.Economy:Install();
    self.Trade:Install();
    self.Construction:Install();
    self.Building:Install();
    self.Recruit:Install();
    self.Hero:Install();
    self.Unit:Install();
    self.Attraction:Install();
    self.Populace:Install();
    self.Province:Install();
    self.Statistic:Install();
    self.Multiplayer:Install();
    self.AI:Install();
    self.Mercenary:Install();
    self.Trap:Install();
    self.Wall:Install();

    self:OverwritePayday();
    self:OverwritePlacementCheck();
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
    self.Player:OnSaveGameLoaded();
    self.Rights:OnSaveGameLoaded();
    self.Construction:OnSaveGameLoaded();
    self.Building:OnSaveGameLoaded();
    self.Recruit:OnSaveGameLoaded();
    self.Economy:OnSaveGameLoaded();
    self.Trade:OnSaveGameLoaded();
    self.Hero:OnSaveGameLoaded();
    self.Unit:OnSaveGameLoaded();
    self.Attraction:OnSaveGameLoaded();
    self.Populace:OnSaveGameLoaded();
    self.Province:OnSaveGameLoaded();
    self.Statistic:OnSaveGameLoaded();
    self.Multiplayer:OnSaveGameLoaded();
    self.AI:OnSaveGameLoaded();
    self.Mercenary:OnSaveGameLoaded();
    self.Trap:OnSaveGameLoaded();
    self.Wall:OnSaveGameLoaded();

    self:OverrideStringTableText();

    -- AoD fix
    CEntity.EnableLogicAoEDamage();
    CEntity.EnableDamageClassAoEDamage();
    return true;
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
-- Trigger

function Stronghold:StartTriggers()
    Job.Second(function()
        local Players = GetMaxPlayers();
        for i= 1, Players do
            Stronghold.Player:PlayerDefeatCondition(i);
        end
        Stronghold.Building:OnEverySecond();
        Stronghold.Province:OnEverySecond();
        Stronghold.Trap:OnEverySecond();
    end);

    Job.Turn(function()
        -- Send versions to all other players
        -- (Multiplayer only)
        Stronghold.Multiplayer:BroadcastStrongholdVersion();

        -- Player jobs on each turn
        local Players = GetMaxPlayers();
        for PlayerID = 1, Players do
            Stronghold.AI:OnEveryTurn(PlayerID);
            Stronghold.Attraction:OnEveryTurn(PlayerID);
            Stronghold.Economy:OncePerTurn(PlayerID);
            Stronghold.Mercenary:OnEveryTurn(PlayerID);
            Stronghold.Rights:OnEveryTurn(PlayerID);
            Stronghold.Recruit:OnEveryTurn(PlayerID);
        end
        Stronghold.AI:OnEveryTurnNoPlayer();

        -- Player jobs on modified turns
        --- @diagnostic disable-next-line: undefined-field
        for PlayerID = 1, Players do
            --- @diagnostic disable-next-line: undefined-field
            local TimeMod = math.mod(Logic.GetCurrentTurn(), 10);
            --- @diagnostic disable-next-line: undefined-field
            local PlayerMod = math.mod(PlayerID, 10);
            if TimeMod == PlayerMod then
                Stronghold:ClearPlayerRecordCache(PlayerID);
                Stronghold.Player:OncePerSecond(PlayerID);
                Stronghold.Populace:OncePerSecond(PlayerID);
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
        Stronghold.Populace:OnEntityCreated(EntityID);
        Stronghold.Building:OnEntityCreated(EntityID);
        Stronghold.Economy:OnEntityCreated(EntityID);
        Stronghold.Hero:OnEntityCreated(EntityID);
        Stronghold.Unit:OnEntityCreated(EntityID);
        Stronghold.Wall:OnEntityCreated(EntityID);
    end);

    Job.Destroy(function()
        local EntityID = Event.GetEntityID();
        Stronghold:RemoveEntityFromPlayerRecordOnDestroy(EntityID);
        Stronghold.Populace:OnEntityDestroyed(EntityID);
        Stronghold.Building:OnEntityDestroyed(EntityID);
        Stronghold.Construction:OnEntityDestroyed(EntityID);
        Stronghold.Unit:OnEntityDestroyed(EntityID);
        Stronghold.Wall:OnEntityDestroyed(EntityID);
    end);

    Job.Trade(function()
        Stronghold.Trade:OnGoodsTraded();
    end);

    Job.Hurt(function()
        local Attacker = Event.GetEntityID1();
        local Attacked = Event.GetEntityID2();
        Stronghold:OnEntityHurtEntity(Attacker, Attacked);
        Stronghold.Unit:OnEntityHurt(Attacker, Attacked);
    end);

    Job.Diplomacy(function()
        local Player1 = Event.GetSourcePlayerID();
        local Player2 = Event.GetTargetPlayerID();
        local State = Event.GetDiplomacyState();
        Stronghold.Trap:OnDiplomacyChanged(Player1, Player2, State);
    end);
end

function Stronghold:OnEntityHurtEntity(_AttackerID, _AttackedID)
    local AttackerPlayer = Logic.EntityGetPlayer(_AttackerID);
    local AttackerType = Logic.GetEntityType(_AttackerID);
    local AttackedPlayer = Logic.EntityGetPlayer(_AttackedID);
    local AttackedType = Logic.GetEntityType(_AttackedID);
    if _AttackerID and _AttackedID then
        -- Get attacker ID
        local ID = _AttackedID;
        if Logic.IsEntityInCategory(ID, EntityCategories.Leader) == 1 then
            local Soldiers = {Logic.GetSoldiersAttachedToLeader(ID)};
            if Soldiers[1] > 0 then
                ID = Soldiers[Soldiers[1]+1];
            end
        end
        if Logic.GetEntityHealth(ID) > 0 then
            -- Save in attack memory
            Stronghold.Player:RegisterAttack(AttackedPlayer, _AttackedID, _AttackerID, 15);
            local Damage = CEntity.HurtTrigger.GetDamage();
            local DamageClass = CInterface.Logic.GetEntityTypeDamageClass(AttackerType);
            -- Vigilante
            if Logic.IsBuilding(_AttackerID) == 1 then
                if Logic.IsTechnologyResearched(AttackerPlayer, Technologies.T_Vigilante) == 1 then
                    Damage = Damage * 3;
                end
            end
            -- External
            Damage = GameCallback_SH_Calculate_BattleDamage(_AttackerID, _AttackedID, Damage);
            -- prevent eco harrasment
            if DamageClass == 0 or DamageClass == 1 then
                if Logic.IsEntityInCategory(_AttackedID, EntityCategories.Worker) == 1
                or Logic.IsEntityInCategory(_AttackedID, EntityCategories.Workplace) == 1
                or AttackedType == Entities.PU_Serf then
                    Damage = 1;
                end
            end
            CEntity.HurtTrigger.SetDamage(math.ceil(Damage));
        end
    end
end

-- Payday updater
function Stronghold:OverwritePayday()
    GameCallback_PaydayPayed = function(_PlayerID, _Amount)
        if _Amount ~= nil and IsPlayer(_PlayerID) then
            -- Change frequency on next payday
            if  Logic.IsTechnologyResearched(_PlayerID,Technologies.T_BookKeeping) == 1
            and CUtil.Payday_GetFrequency(_PlayerID) == Stronghold.Player.Config.Payday.Base then
                CUtil.Payday_SetFrequency(_PlayerID, Stronghold.Player.Config.Payday.Improved);
            end

            -- Execute payday
            return Stronghold.Player:OnPlayerPayday(_PlayerID);
        end
        return 0;
    end
end

function Stronghold:OverwritePlacementCheck()
    if CMod then
        GameCallback_PlaceBuildingAdditionalCheck = function(_Type, _x, _y, _rotation, _isBuildOn)
            local PlayerID = GUI.GetPlayerID();
            if IsPlayer(PlayerID) then
                if not Stronghold.Construction:OnPlacementCheck(PlayerID, _Type, _x, _y, _rotation, _isBuildOn) then
                    return false;
                end
                if not Stronghold.Trap:OnPlacementCheck(PlayerID, _Type, _x, _y, _rotation, _isBuildOn) then
                    return false;
                end
                if not Stronghold.Wall:OnPlacementCheck(PlayerID, _Type, _x, _y, _rotation, _isBuildOn) then
                    return false;
                end
            end
            return true;
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Entity Record

function Stronghold:InitPlayerEntityRecord()
    for i= 1, GetMaxPlayers() do
        self.Record[i] = {
            Cache = {},
            --
            All = {},
            Building = {},
            Monastery = {},
            Farm = {},
            Fortification = {},
            House = {},
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
    local EntityType = Logic.GetEntityType(_EntityID);
    local TypeName = Logic.GetEntityTypeName(EntityType);
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
                if Logic.IsEntityInCategory(_EntityID, EntityCategories.Farm) == 1 then
                    self.Record[PlayerID].Farm[_EntityID] = true;
                end
                if Logic.IsEntityInCategory(_EntityID, EntityCategories.Residence) == 1 then
                    self.Record[PlayerID].House[_EntityID] = true;
                end
                if string.find(TypeName, "Monastery") then
                    self.Record[PlayerID].Monastery[_EntityID] = true;
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
        self.Record[PlayerID].Farm[_EntityID] = nil;
        self.Record[PlayerID].Fortification[_EntityID] = nil;
        self.Record[PlayerID].House[_EntityID] = nil;
        self.Record[PlayerID].Monastery[_EntityID] = nil;
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
    if IsPlayer(_PlayerID) then
        -- Use cache if valid
        local Key = _Group.. "_" .._Type.. "_" ..tostring(_IsConstructed);
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
    if IsPlayer(_PlayerID) then
        -- Use cache if valid
        local Key = _Group.. "_" .._Type.. "_" ..tostring(_IsConstructed);
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

function Stronghold:GetCathedralsOfType(_PlayerID, _Type, _IsConstructed)
    return self:GetBuildingsOfType(_PlayerID, _Type, _IsConstructed == true, "Monastery");
end

function Stronghold:GetFarmsOfType(_PlayerID, _Type, _IsConstructed)
    if _Type == 0 then
        local Key = "Farm_0_nil";
        if self.Record[_PlayerID].Cache[Key] then
            return self.Record[_PlayerID].Cache[Key];
        end
        local FarmList = {};
        local Farm1 = self:GetBuildingsOfType(_PlayerID, Entities.PB_Farm1, _IsConstructed == true, "Farm");
        table.remove(Farm1, 1);
        FarmList = CopyTable(Farm1, FarmList);
        local Farm2 = self:GetBuildingsOfType(_PlayerID, Entities.PB_Farm2, _IsConstructed == true, "Farm");
        table.remove(Farm2, 1);
        FarmList = CopyTable(Farm2, FarmList);
        local Farm3 = self:GetBuildingsOfType(_PlayerID, Entities.PB_Farm3, _IsConstructed == true, "Farm");
        table.remove(Farm3, 1);
        FarmList = CopyTable(Farm3, FarmList);
        local Tavern1 = self:GetBuildingsOfType(_PlayerID, Entities.PB_Tavern1, _IsConstructed == true, "Farm");
        table.remove(Tavern1, 1);
        FarmList = CopyTable(Tavern1, FarmList);
        local Tavern2 = self:GetBuildingsOfType(_PlayerID, Entities.PB_Tavern2, _IsConstructed == true, "Farm");
        table.remove(Tavern2, 1);
        FarmList = CopyTable(Tavern2, FarmList);
        table.insert(FarmList, 1, table.getn(FarmList));
        self.Record[_PlayerID].Cache[Key] = FarmList;
        return FarmList;
    end
    return self:GetBuildingsOfType(_PlayerID, _Type, _IsConstructed == true, "Farm");
end

function Stronghold:GetHousesOfType(_PlayerID, _Type, _IsConstructed)
    if _Type == 0 then
        local Key = "House_0_nil";
        if self.Record[_PlayerID].Cache[Key] then
            return self.Record[_PlayerID].Cache[Key];
        end
        local HouseList = {};
        local House1 = self:GetBuildingsOfType(_PlayerID, Entities.PB_Residence1, _IsConstructed == true, "House");
        table.remove(House1, 1);
        HouseList = CopyTable(House1, HouseList);
        local House2 = self:GetBuildingsOfType(_PlayerID, Entities.PB_Residence2, _IsConstructed == true, "House");
        table.remove(House2, 1);
        HouseList = CopyTable(House2, HouseList);
        local House3 = self:GetBuildingsOfType(_PlayerID, Entities.PB_Residence3, _IsConstructed == true, "House");
        table.remove(House3, 1);
        HouseList = CopyTable(House3, HouseList);
        table.insert(HouseList, 1, table.getn(HouseList));
        self.Record[_PlayerID].Cache[Key] = HouseList;
        return HouseList;
    end
    return self:GetBuildingsOfType(_PlayerID, _Type, _IsConstructed == true, "House");
end

function Stronghold:GetSettlersOfType(_PlayerID, _Type, _Group)
    _Group = _Group or "Settler";
    local List = {0};
    if IsPlayer(_PlayerID) then
        -- Use cache if valid
        local Key = _Group.. "_" .._Type.. "_nil";
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
        self.Building:OnSelectSerf(EntityID);
        self.Building:OnHeadquarterSelected(EntityID);
        self.Building:OnMonasterySelected(EntityID);
        self.Building:OnAlchemistSelected(EntityID);
        self.Building:OnTowerSelected(EntityID);
        self.Building:OnTavernSelected(EntityID);
        self.Trap:OnTrapSelected(EntityID);
        self.Wall:OnWallSelected(EntityID);

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
        Stronghold.Building:OnConstructionComplete(_EntityID, _PlayerID);
        Stronghold.Province:OnBuildingConstructed(_EntityID, _PlayerID);
        Stronghold.Populace:OnConstructionComplete(_EntityID, _PlayerID);
        Stronghold.Trap:OnTrapConstructed(_EntityID, _PlayerID);
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
        Stronghold.Wall:OnWallOrPalisadeUpgraded(_BuildingID);
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

