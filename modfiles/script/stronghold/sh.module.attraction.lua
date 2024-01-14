---
--- Attraction Script
---
--- This script manages the attraction of settlers for the players.
---
--- Attraction limit is split in two. The player has a civil and a military
--- limit. Civil units are all workers and military is the rest.
---

Stronghold = Stronghold or {};

Stronghold.Attraction = {
    Data = {
        HawkHabitats = {}
    },
    Config = {},
    Text = {},
};

-- -------------------------------------------------------------------------- --
-- API

--- Returns the current crime rate of the player.
--- @param _PlayerID integer ID of player
--- @return number Rate Crime rate
function GetCrimeRate(_PlayerID)
    return Stronghold.Attraction:CalculateCrimeRate(_PlayerID);
end

--- Returns the amount of criminals the player has.
--- @param _PlayerID integer ID of player
--- @return integer Amount Amount of criminals
function CountCriminals(_PlayerID)
    return Stronghold.Attraction:CountCriminals(_PlayerID);
end

--- Converts a worker to a criminal.
--- @param _PlayerID integer ID of player
--- @param _BuildingID integer Workplace of worker
--- @param _WorkerID integer ID of worker
function ConvertToCriminal(_PlayerID, _BuildingID, _WorkerID)
    Stronghold.Attraction:ConvertToCriminal(_PlayerID, _BuildingID, _WorkerID);
end

--- Removes a criminal from the map.
--- @param _PlayerID integer ID of player
--- @param _EntityID integer ID of criminal
function RehabilitateCriminal(_PlayerID, _EntityID)
    if Logic.GetEntityType(_EntityID) == Entities.PU_Criminal_Deco then
        DestroyEntity(_EntityID);
    end
end

--- Returns a list of criminals originating from the building.
--- @param _BuildingID integer ID of building
--- @return table Criminals List of criminals
function GetCriminalsOfBuilding(_BuildingID)
    return Stronghold.Attraction:GetCriminalsOfBuilding(_BuildingID);
end

--- Returns if the player can fit another unit.
--- @param _PlayerID integer ID of player
--- @param _Amount integer amount of units
--- @return boolean CanFit Player can fit another unit
function HasPlayerSpaceForUnits(_PlayerID, _Amount)
    return Stronghold.Attraction:HasPlayerSpaceForUnits(_PlayerID, _Amount);
end

--- Returns if the player can fit another slave.
--- @param _PlayerID integer ID of player
--- @return boolean CanFit Player can fit another slave
function HasPlayerSpaceForSlave(_PlayerID)
    return Stronghold.Attraction:HasPlayerSpaceForSlave(_PlayerID);
end

--- Returns the amount of places a unit is occupying.
--- @param _Type integer Type of unit
--- @param _Amount integer amount of units
--- @return integer Amount Places used
function GetMilitaryPlacesUsedByUnit(_Type, _Amount)
    return Stronghold.Attraction:GetRequiredSpaceForUnitType(_Type, _Amount);
end

--- Returns the current military attraction limit of the player.
--- @param _PlayerID integer ID of player
--- @return integer Limit Max military space
function GetMilitaryAttractionLimit(_PlayerID)
    return Stronghold.Attraction:GetPlayerMilitaryAttractionLimit(_PlayerID);
end

--- Returns the current amount of used military space of the player.
--- @param _PlayerID integer ID of player
--- @return integer Usage Used military space
function GetMilitaryAttractionUsage(_PlayerID)
    return Stronghold.Attraction:GetPlayerMilitaryAttractionUsage(_PlayerID);
end

--- Returns the current limit of slaves of the player.
--- @param _PlayerID integer ID of player
--- @return integer Limit Max slave space
function GetSlaveAttractionLimit(_PlayerID)
    return Stronghold.Attraction:GetPlayerSlaveAttractionLimit(_PlayerID);
end

--- Returns the current amount of slaves owned by the player.
--- @param _PlayerID integer ID of player
--- @return integer Usage Used slave space
function GetSlaveAttractionUsage(_PlayerID)
    return Stronghold.Attraction:GetPlayerSlaveAttractionUsage(_PlayerID);
end

--- Returns the current civil attraction limit of the player.
--- @param _PlayerID integer ID of player
--- @return integer Limit Max civil space
function GetCivilAttractionLimit(_PlayerID)
    return Logic.GetPlayerAttractionLimit(_PlayerID);
end

--- Returns the current amount of used civil space of the player.
--- @param _PlayerID integer ID of player
--- @return integer Usage Used civil space
function GetCivilAttractionUsage(_PlayerID)
    return Logic.GetPlayerAttractionUsage(_PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

--- Calculates the limit of military units a player can own.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Current limit
--- @return integer Altered Altered limit
function GameCallback_SH_Calculate_MilitaryAttrationLimit(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates the limit of workers a player can own.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Current limit
--- @return integer Altered Altered limit
function GameCallback_SH_Calculate_CivilAttrationLimit(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates the limit of slaves a player can own.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Current limit
--- @return integer Altered Altered limit
function GameCallback_SH_Calculate_SlaveAttrationLimit(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates how many military units a player currently owns.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Current usage
--- @return integer Altered Altered usage
function GameCallback_SH_Calculate_MilitaryAttrationUsage(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates how many workers a player currently owns.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Current usage
--- @return integer Altered Altered usage
function GameCallback_SH_Calculate_CivilAttrationUsage(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates how many slaves a player currently owns.
--- @param _PlayerID integer ID of player
--- @param _Amount integer Current usage
--- @return integer Altered Altered usage
function GameCallback_SH_Calculate_SlaveAttrationUsage(_PlayerID, _Amount)
    return _Amount;
end

--- Calculates how much space a unit is occupying.
--- @param _PlayerID integer ID of player
--- @param _EntityID integer ID of unit
--- @param _Type integer Type of unit
--- @param _Usage integer Current amount of places
--- @return integer Places Amount of places
function GameCallback_SH_Calculate_UnitPlaces(_PlayerID, _EntityID, _Type, _Usage)
    return _Usage;
end

--- Calculates the crime rate of the player.
--- @param _PlayerID integer ID of player
--- @param _Rate number Current crime rate
--- @return number Altered Alterec crime rate
function GameCallback_SH_Calculate_CrimeRate(_PlayerID, _Rate)
    return _Rate;
end

--- Triggers after a worker has turned into a criminal.
--- @param _PlayerID integer ID of player
--- @param _EntityID integer ID of thief
--- @param _BuildingID integer ID of building
function GameCallback_SH_Logic_CriminalAppeared(_PlayerID, _EntityID, _BuildingID)
end

--- Triggers before a criminal is deleted because he has been catched.
--- @param _PlayerID integer ID of player
--- @param _EntityID integer ID of thief
--- @param _BuildingID integer ID of building
function GameCallback_SH_Logic_CriminalCatched(_PlayerID, _EntityID, _BuildingID)
end

-- -------------------------------------------------------------------------- --
-- Main

function Stronghold.Attraction:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            LastAttempt = 0,
            VirtualSettlers = 0,
            CriminalsCounter = 0,
            Criminals = {0},
            Watchtowers = {0},
            RatData = {},
        };
        -- For each player seperatly to better distribute the computing load
        self.Data.HawkHabitats[i] = {};
    end

    self:InitLogicOverride();
    self:InitalizeHawksForExistingTowers();
    self:InitalizeGuardsForExistingBuildings();
    self:OnPayday();
end

function Stronghold.Attraction:OnSaveGameLoaded()
    self:InitLogicOverride();
end

function Stronghold.Attraction:OnEntityCreated(_EntityID)
    -- Set stamina
    if Logic.IsWorker(_EntityID) == 1 then
        local MaxStamina = CEntity.GetMaxStamina(_EntityID);
        SetEntityStamina(_EntityID, MaxStamina * 0.1);
    end
end

function Stronghold.Attraction:OnEntityDestroyed(_EntityID)
    -- Hawks
    self:OnHawkHabitatDestroyed(_EntityID);
end

function Stronghold.Attraction:OncePerSecond(_PlayerID)
    -- Watchtowers
    self:ManageWatchtowersOfPlayer(_PlayerID);
    -- Criminals
    self:ManageCriminalsOfPlayer(_PlayerID);
    -- Rats
    self:ManageRatsOfPlayer(_PlayerID);
    -- Control hawk
    self:ManageHawksOfPlayer(_PlayerID);
end

function Stronghold.Attraction:OnEveryTurn(_PlayerID)
    -- Update attraction
    self:UpdatePlayerAttractionUsage(_PlayerID);
    -- Worker limit
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Limit, RawLimit = self:GetVirtualPlayerAttractionLimit(_PlayerID);
        CLogic.SetAttractionLimitOffset(_PlayerID, math.max(math.ceil(Limit - RawLimit), 0));
    end
end

function Stronghold.Attraction:InitalizeGuardsForExistingBuildings()
    for PlayerID = 1, GetMaxPlayers() do
        local Buildings = GetPlayerEntities(PlayerID, 0);
        for i= 1, table.getn(Buildings) do
            self:OnWatchtowerBuild(Buildings[i], PlayerID);
            self:OnHawkHabitatCreated(Buildings[i]);
        end
    end
end

function Stronghold.Attraction:OnConstructionComplete(_EntityID, _PlayerID)
    -- Watchtowers
    self:OnWatchtowerBuild(_EntityID, _PlayerID);
end

function Stronghold.Attraction:OnUpgradeComplete(_EntityIDOld, _EntityIDNew)
    local PlayerID = Logic.EntityGetPlayer(_EntityIDNew);
    -- Hawks
    self:OnHawkHabitatCreated(_EntityIDNew);
end

function Stronghold.Attraction:OnPayday()
    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_Payday", function(_PlayerID, _Amount)
        local Amount = Overwrite.CallOriginal();
        Stronghold.Attraction:OnRatPlagueOnPayday(_PlayerID);
        Stronghold.Attraction:StealGoodsOnPayday(_PlayerID);
        Stronghold.Attraction:ResetThievesCycleCounter(_PlayerID);
        return Amount;
    end);
end

-- -------------------------------------------------------------------------- --
-- Virtual Settlers

function Stronghold.Attraction:UpdatePlayerAttractionUsage(_PlayerID)
    if IsPlayerInitalized(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local RealUsage = Stronghold.Attraction.Orig_Logic_GetPlayerAttractionUsage(_PlayerID);
        local Usage = RealUsage;
        -- External
        Usage = GameCallback_SH_Calculate_CivilAttrationUsage(_PlayerID, Usage);
        local FakeUsage = RealUsage - math.floor(Usage + 0.5);
        Stronghold.Attraction.Data[_PlayerID].VirtualSettlers = FakeUsage;
    end
end

function Stronghold.Attraction:InitLogicOverride()
    self.Orig_Logic_GetPlayerAttractionLimit = Logic.GetPlayerAttractionLimit;
    --- @diagnostic disable-next-line: duplicate-set-field
    Logic.GetPlayerAttractionLimit = function(_PlayerID)
        local Limit = self:GetVirtualPlayerAttractionLimit(_PlayerID);
        if Stronghold.Attraction.Data[_PlayerID] then
            Limit = math.max(Limit - Stronghold.Attraction.Data[_PlayerID].VirtualSettlers, 0);
        end
        return Limit;
    end

    self.Orig_Logic_GetPlayerAttractionUsage = Logic.GetPlayerAttractionUsage;
    --- @diagnostic disable-next-line: duplicate-set-field
    Logic.GetPlayerAttractionUsage = function(_PlayerID)
        local Usage = Stronghold.Attraction.Orig_Logic_GetPlayerAttractionUsage(_PlayerID);
        if Stronghold.Attraction.Data[_PlayerID] then
            Usage = math.max(Usage - Stronghold.Attraction.Data[_PlayerID].VirtualSettlers, 0);
        end
        return Usage;
    end
end

-- -------------------------------------------------------------------------- --
-- Watchtowers

function Stronghold.Attraction:OnWatchtowerBuild(_EntityID, _PlayerID)
    local EntityType = Logic.GetEntityType(_EntityID);
    if EntityType == Entities.PB_DarkTower1 or EntityType == Entities.PB_Tower1
    or EntityType == Entities.PB_DarkTower4 or EntityType == Entities.PB_Tower4 then
        local x,y,z = Logic.EntityGetPos(_EntityID);
        local Position = GetCirclePosition(_EntityID, 200, -90);
        local ID = Logic.CreateEntity(Entities.PU_Watchman_Deco, Position.X, Position.Y, 0, _PlayerID);
        x,y,z = Logic.EntityGetPos(ID);
        MakeInvulnerable(ID);
        Logic.SetEntitySelectableFlag(ID, 0);
        -- BuildingID, WatchmanID, HomePosition, PursuedTargetID, State
        local Data = {_EntityID, ID, {X= x, Y= y}, 0, 0};
        self.Data[_PlayerID].Watchtowers[1] = self.Data[_PlayerID].Watchtowers[1] + 1;
        table.insert(self.Data[_PlayerID].Watchtowers, Data);
    end
end

function Stronghold.Attraction:OnWatchtowerUpgraded(_EntityIDOld, _EntityIDNew, _PlayerID)
    local EntityType = Logic.GetEntityType(_EntityIDNew);
    if IsPlayer(_PlayerID) then
        if EntityType == Entities.PB_DarkTower4 or EntityType == Entities.PB_Tower4 then
            for i= self.Data[_PlayerID].Watchtowers[1] +1, 2, -1 do
                if self.Data[_PlayerID].Watchtowers[i][1] == _EntityIDOld then
                    local Data = table.remove(self.Data[_PlayerID].Watchtowers, i);
                    Data[1] = _EntityIDNew;
                    table.insert(self.Data[_PlayerID].Watchtowers, i, Data);
                    break;
                end
            end
        end
    end
end

function Stronghold.Attraction:OnWatchtowerDestroyed(_EntityID)
    -- Hawk removal
    self:OnHawkHabitatDestroyed(_EntityID);
end

function Stronghold.Attraction:ManageWatchtowersOfPlayer(_PlayerID)
    for i= self.Data[_PlayerID].Watchtowers[1] +1, 2, -1 do
        local Data = self.Data[_PlayerID].Watchtowers[i];
        if not IsExisting(Data[1]) then
            self.Data[_PlayerID].Watchtowers[1] = self.Data[_PlayerID].Watchtowers[1] - 1;
            DestroyEntity(Data[2]);
            table.remove(self.Data[_PlayerID].Watchtowers, i);
        else
            local MaxDistance = Logic.GetEntityExplorationRange(Data[1]) * 100;
            -- Check watchman existing
            if not IsValidEntity(Data[2]) then
                local ID = Logic.CreateEntity(Entities.PU_Watchman_Deco, Data[3].X, Data[3].Y, 0, _PlayerID);
                MakeInvulnerable(ID);
                Logic.SetEntitySelectableFlag(ID, 0);
                self.Data[_PlayerID].Watchtowers[i][2] = ID;
            end
            -- Move watchman to tower
            if Data[5] == 0 then
                if GetDistance(Data[2], Data[1]) > 300 then
                    if Logic.IsEntityMoving(Data[2]) == false then
                        Logic.MoveSettler(Data[2], Data[3].X, Data[3].Y, 270);
                    end
                else
                    self.Data[_PlayerID].Watchtowers[i][5] = 1;
                    SVLib.SetInvisibility(Data[2], true);
                end
            -- Find criminal
            elseif Data[5] == 1 then
                local _, Criminal = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PU_Criminal_Deco, Data[3].X, Data[3].Y, MaxDistance, 1);
                self.Data[_PlayerID].Watchtowers[i][4] = Criminal or 0;
                self.Data[_PlayerID].Watchtowers[i][5] = 2;
                if Criminal then
                    SVLib.SetInvisibility(Data[2], false);
                end
            -- Catch criminal
            elseif Data[5] == 2 then
                if not IsValidEntity(Data[4]) then
                    self.Data[_PlayerID].Watchtowers[i][5] = 0;
                    local x,y,z = Logic.EntityGetPos(Data[2]);
                    Logic.MoveSettler(Data[2], x, y);
                else
                    local x1,y1,z1 = Logic.EntityGetPos(Data[4]);
                    Logic.MoveSettler(Data[2], x1, y1);
                    local x2,y2,z2 = Logic.EntityGetPos(Data[2]);
                    local _, Criminal = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PU_Criminal_Deco, x2, y2, 300, 1);
                    if Criminal then
                        DestroyEntity(Criminal);
                    end
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Hawks

function Stronghold.Attraction:InitalizeHawksForExistingTowers()
    for PlayerID = 1, GetMaxPlayers() do
        local Buildings = GetBuildingsOfType(PlayerID, 0, true);
        for i= 2, Buildings[1] +1 do
            self:OnHawkHabitatCreated(Buildings[i]);
        end
    end
end

function Stronghold.Attraction:OnHawkHabitatCreated(_EntityID)
    local EntityType = Logic.GetEntityType(_EntityID);
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if PlayerID ~= 0 then
        if EntityType == Entities.PB_DarkTower4 or EntityType == Entities.PB_Tower4 then
            local Positions = {};
            for Angle = 0, 288, 72 do
                local Position = GetCirclePosition(_EntityID, 500, Angle);
                table.insert(Positions, Position)
            end
            local ID = Logic.CreateEntity(Entities.PU_Hawk_Deco, Positions[1].X, Positions[1].Y, 0, PlayerID);
            Logic.SetTaskList(ID, TaskLists.TL_NPC_WALK);
            MakeInvulnerable(ID);
            self.Data.HawkHabitats[PlayerID][_EntityID] = {ID, 3, unpack(Positions)};
        end
    end
end

function Stronghold.Attraction:OnHawkHabitatDestroyed(_EntityID)
    for PlayerID,_ in pairs(self.Data.HawkHabitats) do
        if self.Data.HawkHabitats[PlayerID][_EntityID] then
            local ID = self.Data.HawkHabitats[PlayerID][_EntityID][1];
            DestroyEntity(ID);
            self.Data.HawkHabitats[PlayerID][_EntityID] = nil;
        end
    end
end

function Stronghold.Attraction:ManageHawksOfPlayer(_PlayerID)
    for EntityID, Data in pairs(self.Data.HawkHabitats[_PlayerID]) do
        local HawkID = Data[1];
        local Position = Data[Data[2]];
        if IsExisting(HawkID) then
            if GetDistance(HawkID, Position) <= 400 then
                Data[2] = (Data[2] + 1 > 7 and 3) or Data[2] + 1;
                self.Data.HawkHabitats[_PlayerID][EntityID][2] = Data[2];
            else
                Logic.MoveEntity(HawkID, Position.X, Position.Y);
            end
        else
            local ID = Logic.CreateEntity(Entities.PU_Hawk_Deco, Position.X, Position.Y, 0, _PlayerID);
            Logic.SetTaskList(ID, TaskLists.TL_NPC_WALK);
            MakeInvulnerable(ID);
            self.Data.HawkHabitats[_PlayerID][EntityID][1] = ID;
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Rats

function Stronghold.Attraction:DoRatsAppear(_PlayerID)
    return GetRank(_PlayerID) >= PlayerRank.Count;
end

function Stronghold.Attraction:GetPlayerRats(_PlayerID)
    if IsPlayer(_PlayerID) then
        local Rats = 0;
        for EntityID, Data in pairs(self.Data[_PlayerID].RatData) do
            Rats = Rats + Data[1];
        end
        return math.floor(Rats);
    end
    return 0;
end

function Stronghold.Attraction:GetBuildingsInfestableWithRats(_PlayerID)
    local Buildings = {};
    if IsPlayer(_PlayerID) then
        Buildings = GetWorkplacesOfType(_PlayerID, 0, true);
        for i= 2, Buildings[1] +1 do
            if not self.Data[_PlayerID].RatData[Buildings[i]] then
                self.Data[_PlayerID].RatData[Buildings[i]] = {0};
            end
        end
    end
    return Buildings;
end

function Stronghold.Attraction:OnRatPlagueOnPayday(_PlayerID)
    if IsPlayer(_PlayerID) then
        if self:GetPlayerRats(_PlayerID) >= 1 and GUI.GetPlayerID() == _PlayerID then
            Message(XGUIEng.GetStringTableText("sh_text/Player_RatsSpreadDisease"));
        end
    end
end

function Stronghold.Attraction:ManageRatsOfPlayer(_PlayerID)
    if IsPlayerInitalized(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local BaseRate = self.Config.CivilDuties.Rats.BaseDirtRate;
        local UpgradeRate = self.Config.CivilDuties.Rats.UpgradeDirtRade;
        local CleanRate = self.Config.CivilDuties.Rats.DisposalRate;

        if self:DoRatsAppear(_PlayerID) then
            local Buildings = self:GetBuildingsInfestableWithRats(_PlayerID);
            for i= 2, Buildings[1] +1 do
                local Data = self.Data[_PlayerID].RatData[Buildings[i]];
                local Level = Logic.GetUpgradeLevelForBuilding(Buildings[i]);
                local WorkerMax = Logic.GetBuildingWorkPlaceLimit(Buildings[i]);
                local Worker = Logic.GetBuildingWorkPlaceUsage(Buildings[i]);
                local Dirt = math.min(Data[1] + (Worker/WorkerMax) * (BaseRate + (Level * UpgradeRate)), 1);

                local HawkArea = self.Config.CivilDuties.Rats.HawkArea;
                local x,y,z = Logic.EntityGetPos(Buildings[i]);
                local Tower1 = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower4, x, y, HawkArea, 16);
                local Tower2 = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower4, x, y, HawkArea, 16);
                Dirt = math.max(Dirt - (CleanRate * (Tower1 + Tower2)), 0);

                self.Data[_PlayerID].RatData[Buildings[i]][1] = Dirt;
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Criminals

function Stronghold.Attraction:ResetThievesCycleCounter(_PlayerID)
    if IsPlayer(_PlayerID) then
        self.Data[_PlayerID].CriminalsCounter = 0;
    end
end

function Stronghold.Attraction:StealGoodsOnPayday(_PlayerID)
    local GuiPlayer = GUI.GetPlayerID();
    local TotalAmount = 0;
    local ResourcesToSub = {};
    local ResourcesToSteal = {"Gold", "Wood", "Clay", "Stone", "Iron", "Sulfur"};
    local Criminals = self:CountCriminals(_PlayerID);
    if Criminals > 0 then
        for i= 1, Criminals do
            local Type = ResourceType[ResourcesToSteal[math.random(1, 6)]];
            local Amount = math.random(
                self.Config.CivilDuties.Crime.TheftAmount.Min,
                self.Config.CivilDuties.Crime.TheftAmount.Max
            );
            ResourcesToSub[Type] = (ResourcesToSub[Type] or 0) + Amount;
            TotalAmount = TotalAmount + Amount;
        end
        if TotalAmount > 0 and GuiPlayer == _PlayerID and GuiPlayer ~= 17 then
            local Text = XGUIEng.GetStringTableText("sh_text/Player_CriminalsStoleResources");
            Message(string.format(Text, TotalAmount));
        end
        RemoveResourcesFromPlayer(_PlayerID, ResourcesToSub);
    end
end

function Stronghold.Attraction:GetCriminalDestinations(_PlayerID)
    local Buildings = {};
    if IsPlayer(_PlayerID) then
        Buildings = GetWorkplacesOfType(_PlayerID, 0, true);
        local CastleID = GetHeadquarterID(_PlayerID);
        if CastleID ~= 0 then
            table.insert(Buildings, CastleID);
            Buildings[1] = Buildings[1] + 1;
        end
    end
    return Buildings;
end

-- Replaces the worker with a criminal.
function Stronghold.Attraction:CreateCriminalFromWorker(_PlayerID, _BuildingID, _WorkerID)
    local ID = 0;
    if IsExisting(_BuildingID) then
        -- Create thief
        local x,y,z = Logic.EntityGetPos(_BuildingID);
        DestroyEntity(_WorkerID);
        ID = AI.Entity_CreateFormation(_PlayerID, Entities.PU_Criminal_Deco, nil, 0, x, y, 0, 0, 0, 0);
        x,y,z = Logic.EntityGetPos(ID);
        Logic.SetEntitySelectableFlag(ID, 0);
        Logic.MoveSettler(ID, x, y);
    end
    return ID;
end

-- Replaces the worker with a criminal and calls the callback.
function Stronghold.Attraction:ConvertToCriminal(_PlayerID, _BuildingID, _WorkerID)
    local GuiPlayer = GUI.GetPlayerID();
    local ID = 0;
    if self.Data[_PlayerID] and IsExisting(_BuildingID) then
        -- Create thief
        local x,y,z = Logic.EntityGetPos(_BuildingID);
        ID = self:CreateCriminalFromWorker(_PlayerID, _BuildingID, _WorkerID);
        x,y,z = Logic.EntityGetPos(ID);
        local Data = {ID, _BuildingID, {X= x, Y= y}, nil, 0};
        table.insert(self.Data[_PlayerID].Criminals, Data);
        self.Data[_PlayerID].Criminals[1] = self.Data[_PlayerID].Criminals[1] + 1;

        -- Show message
        if GuiPlayer == _PlayerID and GuiPlayer ~= 17 then
            Message(XGUIEng.GetStringTableText("sh_text/Player_ConvertedToCriminal"));
        end
        -- Trigger callback
        GameCallback_SH_Logic_CriminalAppeared(_PlayerID, ID, _BuildingID);
    end
    return ID;
end

-- Unregister the criminal and calls the callback.
function Stronghold.Attraction:UnregisterCriminal(_PlayerID, _EntityID)
    local GuiPlayer = GUI.GetPlayerID();
    if self.Data[_PlayerID] then
        for i= self.Data[_PlayerID].Criminals[1] +1, 2, -1 do
            local Data = self.Data[_PlayerID].Criminals[i];
            if Data[1] == _EntityID then
                -- Show message
                if GuiPlayer == _PlayerID and GuiPlayer ~= 17 then
                    Message(XGUIEng.GetStringTableText("sh_text/Player_CriminalResocialized"));
                end
                -- Invoke callback
                GameCallback_SH_Logic_CriminalCatched(_PlayerID, Data[1], Data[2]);
                -- Delete thief
                table.remove(self.Data[_PlayerID].Criminals, i);
                self.Data[_PlayerID].Criminals[1] = self.Data[_PlayerID].Criminals[1] - 1;
            end
        end
    end
end

function Stronghold.Attraction:DoCriminalsAppear(_PlayerID)
    return GetRank(_PlayerID) >= PlayerRank.Earl;
end

function Stronghold.Attraction:CalculateCrimeRate(_PlayerID)
    local CrimeRate = 0;
    if IsPlayerInitalized(_PlayerID) and not IsAIPlayer(_PlayerID) then
        CrimeRate = self.Config.CivilDuties.Crime.CrimeRate;
        local Places = GetBuildingsOfType(_PlayerID, Entities.PB_ExecutionerPlace1, true);
        if Places[1] > 0 then
            CrimeRate = CrimeRate * self.Config.CivilDuties.Crime.ExecutionerRate;
        end
        CrimeRate = GameCallback_SH_Calculate_CrimeRate(_PlayerID, CrimeRate);
    end
    return CrimeRate;
end

function Stronghold.Attraction:CountCriminals(_PlayerID)
    local CriminalCount = 0;
    if self.Data[_PlayerID] then
        CriminalCount = self.Data[_PlayerID].Criminals[1];
    end
    return CriminalCount;
end

function Stronghold.Attraction:GetReputationLossByCriminals(_PlayerID)
    local Loss = 0;
    if self.Data[_PlayerID] then
        local Criminals = self:CountCriminals(_PlayerID);
        local Damage = self.Config.CivilDuties.Crime.ReputationDamage;
        Loss = Loss + (Damage * Criminals);
    end
    return Loss;
end

function Stronghold.Attraction:GetCriminalsOfBuilding(_BuildingID)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Criminals = {0};
    if self.Data[PlayerID] then
        for i= self.Data[PlayerID].Criminals[1] +1, 2, -1 do
            if self.Data[PlayerID].Criminals[i][2] == _BuildingID then
                table.insert(Criminals, self.Data[PlayerID].Criminals[i][1]);
                Criminals[1] = Criminals[1] + 1;
            end
        end
    end
    return Criminals;
end

-- Returns a random position for a thief to walk to.
function Stronghold.Attraction:GetCriminalTarget(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local WorkplaceList = GetWorkplacesOfType(PlayerID, 0, true);
    local DoorPos = GetHeadquarterEntrance(PlayerID);
    local Target = WorkplaceList[math.random(2, WorkplaceList[1] +1)];
    return GetReachablePosition(_EntityID, Target, DoorPos);
end

-- Returns the amount of criminal energy.
function Stronghold.Attraction:GetCriminalEnergy(_PlayerID)
    local Motivation = GetReputation(_PlayerID) / 100;
    local Workers = Logic.GetNumberOfAttractedWorker(_PlayerID);
    local WorkerRate = self.Config.CivilDuties.Crime.WorkerRate;
    local CrimeRate = self:CalculateCrimeRate(_PlayerID);
    local Potential = (Workers * WorkerRate) * (1/Motivation) * CrimeRate;
    return math.min(math.floor(Potential), 100);
end

function Stronghold.Attraction:ManageCriminalsOfPlayer(_PlayerID)
    if IsPlayerInitalized(_PlayerID) then
        -- Converting workers to criminals
        -- Depending on the crime rate each x seconds a settler can become a
        -- criminal by a chance of y%.
        if self:DoCriminalsAppear(_PlayerID) then
            local Data = self.Data[_PlayerID];
            local TimeBetween = self.Config.CivilDuties.Crime.TimeBetween;
            if Data.CriminalsCounter < self.Config.CivilDuties.Crime.MaxPerCycle then
                if Data.LastAttempt + TimeBetween < Logic.GetTime() then
                    local CriminalEnergy = self:GetCriminalEnergy(_PlayerID);
                    if CriminalEnergy > 0 and math.random(1,100) <= CriminalEnergy then
                        local WorkerList = GetWorkersOfType(_PlayerID, 0);
                        local Selected = WorkerList[math.random(2, WorkerList[1] +1)];
                        local Building = Logic.GetSettlersWorkBuilding(Selected);
                        if self:ConvertToCriminal(_PlayerID, Building, Selected) ~= 0 then
                            self.Data[_PlayerID].CriminalsCounter = Data.CriminalsCounter +1;
                        end
                        self.Data[_PlayerID].LastAttempt = Logic.GetTime();
                    end
                end
            end
        end

        -- Control criminals
        -- Moves the criminals between the castle and their former workplace.
        -- They might get seen what will rise their exposition.
        for i= self.Data[_PlayerID].Criminals[1] +1, 2, -1 do
            local Data = self.Data[_PlayerID].Criminals[i];
            if IsValidEntity(Data[1]) then
                if Data[5] == 0 then
                    local RandomPosition = self:GetCriminalTarget(Data[1]);
                    self.Data[_PlayerID].Criminals[i][4] = RandomPosition;
                    self.Data[_PlayerID].Criminals[i][5] = 1;
                    Logic.MoveSettler(Data[1], Data[4].X, Data[4].Y);
                elseif Data[5] == 1 then
                    if Logic.IsEntityMoving(Data[1]) == false then
                        self.Data[_PlayerID].Criminals[i][5] = 2;
                    end
                    local x,y,z = Logic.EntityGetPos(Data[1])
                    local _, Criminal = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PU_Watchman_Deco, x, y, 300, 1);
                    if Criminal then
                        DestroyEntity(Data[1]);
                    end
                elseif Data[5] == 2 then
                    self.Data[_PlayerID].Criminals[i][4] = CopyTable(Data[3]);
                    self.Data[_PlayerID].Criminals[i][5] = 3;
                    Logic.MoveSettler(Data[1], Data[4].X, Data[4].Y);
                elseif Data[5] == 3 then
                    if Logic.IsEntityMoving(Data[1]) == false then
                        self.Data[_PlayerID].Criminals[i][5] = 0;
                    end
                end
            else
                self:UnregisterCriminal(_PlayerID, Data[1]);
            end
        end

        -- Control hero
        -- The hero can hunt down criminals everywhere
        local HeroID = GetNobleID(_PlayerID);
        if IsEntityValid(HeroID) then
            local x,y,z = Logic.EntityGetPos(HeroID);
            local Area = self.Config.CivilDuties.Crime.HeroVisionArea;
            local _, EntityID = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PU_Criminal_Deco, x, y, Area, 1);
            if EntityID then
                DestroyEntity(EntityID);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Workers

GameCallback_GetPlayerAttractionLimitForSpawningWorker = function(_PlayerID, _Amount)
    return Logic.GetPlayerAttractionLimit(_PlayerID);
end

GameCallback_GetPlayerAttractionUsageForSpawningWorker = function(_PlayerID, _Amount)
    return Logic.GetPlayerAttractionUsage(_PlayerID);
end

GameCallback_BuyEntityAttractionLimitCheck = function(_PlayerID, _CanSpawn)
    -- TODO: Let soldier costs be handeled by logic?
    local BuyEvent = CEntity.GetEventData(1);
    if BuyEvent.event == CEntity.Events.BUY_SOLDIER then
        local LeaderType = Logic.GetEntityType(BuyEvent.leaderID);
        local Places = GetMilitaryPlacesUsedByUnit(LeaderType, 1);
        if not HasPlayerSpaceForUnits(_PlayerID, Places) then
            local Costs = GetSoldierCostsByLeaderType(_PlayerID, LeaderType, 1);
            AddResourcesToPlayer(_PlayerID, Costs);
            return false;
        end
    end
    return true;
end

function Stronghold.Attraction:UpdateMotivationOfPlayersWorkers(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        -- Update Motivation of workers
        local WorkerList = GetWorkersOfType(_PlayerID, 0);
        for i= 2, WorkerList[1] +1 do
            local WorkplaceID = Logic.GetSettlersWorkBuilding(WorkerList[i]);
            if  (WorkplaceID ~= nil and WorkplaceID ~= 0)
            and Logic.IsOvertimeActiveAtBuilding(WorkplaceID) == 0
            and Logic.IsAlarmModeActive(WorkplaceID) ~= true then
                local OldMoti = Logic.GetSettlersMotivation(WorkerList[i]);
                local NewMoti = math.floor((OldMoti * 100) + 0.5) + _Amount;
                NewMoti = math.min(NewMoti, GetMaxReputation(_PlayerID));
                NewMoti = math.min(NewMoti, GetReputation(_PlayerID));
                NewMoti = math.max(NewMoti, 20);
                CEntity.SetMotivation(WorkerList[i], NewMoti / 100);
            end
        end
        -- Restore reputation when workers are all gone
        -- (Must be done so that they don't leave immedaitly when they return.)
        if GetReputation(_PlayerID) <= 25 and Logic.GetNumberOfAttractedWorker(_PlayerID) == 0 then
            Stronghold.Player:SetPlayerReputation(_PlayerID, 50);
            return;
        end
    end
end

function Stronghold.Attraction:GetVirtualPlayerAttractionLimit(_PlayerID)
    local Limit = 0;
    local RawLimit = 0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        -- Headquarters
        local HQ1 = GetBuildingsOfType(_PlayerID, Entities.PB_Headquarters1, true);
        RawLimit = RawLimit + (HQ1[1] * self.Config.Attraction.HQCivil[1]);
        local HQ2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Headquarters2);
        RawLimit = RawLimit + (HQ2 * self.Config.Attraction.HQCivil[2]);
        local HQ3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Headquarters3);
        RawLimit = RawLimit + (HQ3 * self.Config.Attraction.HQCivil[3]);
        if RawLimit == 0 and GetHeadquarterID(_PlayerID) == 0 then
            Limit = Limit + 35;
        end
        -- Village Centers
        local VC1 = GetBuildingsOfType(_PlayerID, Entities.PB_VillageCenter1, true);
        RawLimit = RawLimit + (VC1[1] * self.Config.Attraction.VCCivil[1]);
        local VC2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_VillageCenter2);
        RawLimit = RawLimit + (VC2 * self.Config.Attraction.VCCivil[2]);
        local VC3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_VillageCenter3);
        RawLimit = RawLimit + (VC3 * self.Config.Attraction.VCCivil[3]);
        -- External
        Limit = GameCallback_SH_Calculate_CivilAttrationLimit(_PlayerID, Limit + RawLimit);
        -- Virtual settlers
        Limit = Limit + self.Data[_PlayerID].VirtualSettlers;
    end
    return Limit, RawLimit;
end

function Stronghold.Attraction:GetBuildingDoorPosition(_BarracksID)
    local Position = {X= 0, Y= 0};
    local PlayerID = Logic.EntityGetPlayer(_BarracksID);
    if IsPlayer(PlayerID) then
        local BarracksType = Logic.GetEntityType(_BarracksID);
        if BarracksType == Entities.CB_Castle1
        or BarracksType == Entities.CB_Castle1
        or BarracksType == Entities.CB_CrafortCastle
        or BarracksType == Entities.PB_Headquarters1
        or BarracksType == Entities.PB_Headquarters2
        or BarracksType == Entities.PB_Headquarters3 then
            Position = GetCirclePosition(_BarracksID, 1300, 180);
        end
        if BarracksType == Entities.CB_CleycourtCastle then
            Position = GetCirclePosition(_BarracksID, 1400, 270);
        end
        if BarracksType == Entities.CB_DarkCastle
        or BarracksType == Entities.CB_KaloixCastle
        or BarracksType == Entities.CB_FolklungCastle then
            DoorPos = GetCirclePosition(_BarracksID, 1400, 180);
        end
        if BarracksType == Entities.CB_OldKingsCastle
        or BarracksType == Entities.CB_OldKingsCastleRuin then
            Position = GetCirclePosition(_BarracksID, 1500, 180);
        end
        if BarracksType == Entities.PB_VillageCenter1
        or BarracksType == Entities.PB_VillageCenter2
        or BarracksType == Entities.PB_VillageCenter3 then
            Position = GetCirclePosition(_BarracksID, 1100, 270);
        end
    end
    return Position
end

-- -------------------------------------------------------------------------- --
-- Serfs

function Stronghold.Attraction:GetPlayerSlaveAttractionLimit(_PlayerID)
    local Limit = 0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        if Stronghold.Player.Config.DefeatModes.LastManStanding
        or IsEntityValid(GetNobleID(_PlayerID)) then
            local RawLimit = self.Config.Attraction.SlaveLimit;
            -- Rank
            local Rank = GetRank(_PlayerID);
            if Rank > 0 then
                RawLimit = RawLimit + (Rank * self.Config.Attraction.RankSlaveBonus);
            end
            -- External
            Limit = GameCallback_SH_Calculate_SlaveAttrationLimit(_PlayerID, RawLimit);
        end
    end
    return math.floor(Limit + 0.5);
end

function Stronghold.Attraction:GetPlayerSlaveAttractionUsage(_PlayerID)
    local Usage = 0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local BattleSerfs = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_BattleSerf);
        local Serfs = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Serf);
        Usage = BattleSerfs + Serfs;
        -- External
        Usage = GameCallback_SH_Calculate_SlaveAttrationUsage(_PlayerID, Usage);
    end
    return math.floor(Usage + 0.5);
end

function Stronghold.Attraction:HasPlayerSpaceForSlave(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local SlaveLimit = self:GetPlayerSlaveAttractionLimit(_PlayerID);
        local SlaveUsage = self:GetPlayerSlaveAttractionUsage(_PlayerID);
        return SlaveLimit - SlaveUsage >= 1;
    end
    return true;
end

-- -------------------------------------------------------------------------- --
-- Military

function Stronghold.Attraction:GetPlayerMilitaryAttractionLimit(_PlayerID)
    local Limit = 0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        if Stronghold.Player.Config.DefeatModes.LastManStanding
        or IsEntityValid(GetNobleID(_PlayerID)) then
            -- Headquarters
            local HQ1 = GetBuildingsOfType(_PlayerID, Entities.PB_Headquarters1, true);
            Limit = Limit + (HQ1[1] * self.Config.Attraction.HQMilitary[1]);
            local HQ2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Headquarters2);
            Limit = Limit + (HQ2 * self.Config.Attraction.HQMilitary[2]);
            local HQ3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Headquarters3);
            Limit = Limit + (HQ3 * self.Config.Attraction.HQMilitary[3]);
            if Limit == 0 and GetHeadquarterID(_PlayerID) == 0 then
                Limit = Limit + (1 * self.Config.Attraction.HQMilitary[1]);
            end
            -- Outpost
            local OP1 = GetBuildingsOfType(_PlayerID, Entities.PB_Outpost1, true);
            Limit = Limit + (OP1[1] * self.Config.Attraction.OPMilitary[1]);
            local OP2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Outpost2);
            Limit = Limit + (OP2 * self.Config.Attraction.OPMilitary[2]);
            local OP3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Outpost3);
            Limit = Limit + (OP3 * self.Config.Attraction.OPMilitary[3]);
            -- External
            Limit = GameCallback_SH_Calculate_MilitaryAttrationLimit(_PlayerID, Limit);
        end
    end
    return math.floor(Limit);
end

function Stronghold.Attraction:GetRequiredSpaceForUnitType(_Type, _Amount)
    if self.Config.UsedSpace[_Type] then
        return self.Config.UsedSpace[_Type] * (_Amount or 1);
    end
    return 0;
end

function Stronghold.Attraction:GetPlayerMilitaryAttractionUsage(_PlayerID)
    local Usage = 0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        Usage = self:GetMillitarySize(_PlayerID);
        -- External
        Usage = GameCallback_SH_Calculate_MilitaryAttrationUsage(_PlayerID, Usage);
    end
    return math.floor(Usage + 0.5);
end

function Stronghold.Attraction:HasPlayerSpaceForUnits(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local MilitaryLimit = self:GetPlayerMilitaryAttractionLimit(_PlayerID);
        local MilitaryUsage = self:GetPlayerMilitaryAttractionUsage(_PlayerID);
        return MilitaryLimit - MilitaryUsage >= _Amount;
    end
    return true;
end

function Stronghold.Attraction:GetMillitarySize(_PlayerID)
    local Size = 0;
    for k,v in pairs(self.Config.UsedSpace) do
        local Config = Stronghold.Unit.Config:Get(k, _PlayerID);
        if not Config or Config.IsCivil ~= true then
            local UnitList = GetLeadersOfType(_PlayerID, k);
            for i= 2, UnitList[1] +1 do
                -- Get unit size
                local Usage = v;
                if Logic.IsLeader(UnitList[i]) == 1 then
                    local Soldiers = {Logic.GetSoldiersAttachedToLeader(UnitList[i])};
                    Usage = Usage + (Usage * Soldiers[1]);
                end
                -- External
                Usage = GameCallback_SH_Calculate_UnitPlaces(_PlayerID, UnitList[i], k, Usage);

                Size = Size + Usage;
            end
        end
    end
    return Size;
end

