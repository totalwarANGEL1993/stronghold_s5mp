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
    Stronghold.Attraction:AddCriminal(_PlayerID, _BuildingID, _WorkerID);
end

--- Removes a criminal from the map.
--- @param _PlayerID integer ID of player
--- @param _EntityID integer ID of criminal
function RehabilitateCriminal(_PlayerID, _EntityID)
    Stronghold.Attraction:RemoveCriminal(_PlayerID, _EntityID);
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
            Criminals = {},
            RatData = {},
        };
        -- For each player seperatly to better distribute the computing load
        self.Data.HawkHabitats[i] = {};
    end

    GetEntitiesOfDiplomacyStateInArea_BlacklistedTypes[Entities.PU_Bear_Deco] = true;
    GetEntitiesOfDiplomacyStateInArea_BlacklistedTypes[Entities.PU_Dog_Deco] = true;
    GetEntitiesOfDiplomacyStateInArea_BlacklistedTypes[Entities.XA_Hawk] = true;

    self:InitLogicOverride();
    self:InitalizeHawksForExistingTowers();
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
    -- Hawk creation
    self:OnHawkHabitatCreated(_EntityID);
end

function Stronghold.Attraction:OnEntityDestroyed(_EntityID)
    -- Hawk removal
    self:OnHawkHabitatDestroyed(_EntityID);
end

function Stronghold.Attraction:OncePerSecond(_PlayerID)
    -- Hawks
    self:ManageHawks(_PlayerID);
    -- Criminals
    self:ManageCriminalsOfPlayer(_PlayerID);
    -- Rats
    self:ManageRatsOfPlayer(_PlayerID);
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
-- Rats

function Stronghold.Attraction:InitalizeHawksForExistingTowers()
    for PlayerID = 1, GetMaxPlayers() do
        local Buildings = GetBuildingsOfType(PlayerID, 0, true);
        for i= 2, Buildings[1] +1 do
            self:OnHawkHabitatCreated(Buildings[i]);
        end
    end
end

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

function Stronghold.Attraction:ManageRatsOfPlayer(_PlayerID)
    if IsPlayerInitalized(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local BaseRate = self.Config.Rats.BaseDirtRate;
        local UpgradeRate = self.Config.Rats.UpgradeDirtRade;
        local CleanRate = self.Config.Rats.DisposalRate;

        if self:DoRatsAppear(_PlayerID) then
            local Buildings = self:GetBuildingsInfestableWithRats(_PlayerID);
            for i= 2, Buildings[1] do
                local Data = self.Data[_PlayerID].RatData[Buildings[i]];
                local Level = Logic.GetUpgradeLevelForBuilding(Buildings[i]);
                local WorkerMax = Logic.GetBuildingWorkPlaceLimit(Buildings[i]);
                local Worker = Logic.GetBuildingWorkPlaceUsage(Buildings[i]);
                local Dirt = math.min(Data[1] + (Worker/WorkerMax) * (BaseRate + (Level * UpgradeRate)), 1);

                local HawkArea = self.Config.Rats.HawkArea;
                local x,y,z = Logic.EntityGetPos(Buildings[i]);
                local Tower1 = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower4, x, y, HawkArea, 16);
                local Tower2 = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower4, x, y, HawkArea, 16);
                Dirt = math.max(Dirt - (CleanRate * (Tower1 + Tower2)), 0);

                self.Data[_PlayerID].RatData[Buildings[i]][1] = Dirt;
            end
        end
    end
end

function Stronghold.Attraction:GetBuildingsInfestableWithRats(_PlayerID)
    local Buildings = {};
    if IsPlayer(_PlayerID) then
        Buildings = GetWorkplacesOfType(_PlayerID, 0, true);
        for i= 2, Buildings[1] do
            if not self.Data[_PlayerID].RatData[Buildings[i]] then
                self.Data[_PlayerID].RatData[Buildings[i]] = {0};
            end
        end
    end
    return Buildings;
end

function Stronghold.Attraction:ManageHawks(_PlayerID)
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
        end
    end
end

function Stronghold.Attraction:OnRatPlagueOnPayday(_PlayerID)
    if IsPlayer(_PlayerID) then
        if self:GetPlayerRats(_PlayerID) >= 1 and GUI.GetPlayerID() == _PlayerID then
            Message(XGUIEng.GetStringTableText("sh_text/Player_RatsSpreadDisease"));
        end
    end
end

function Stronghold.Attraction:OnHawkHabitatCreated(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local EntityType = Logic.GetEntityType(_EntityID);
    if EntityType == Entities.PB_DarkTower4 or EntityType == Entities.PB_Tower4 then
        local Positions = {};
        for Angle = 0, 288, 72 do
            local Position = GetCirclePosition(_EntityID, 500, Angle);
            table.insert(Positions, Position)
        end
        local ID = Logic.CreateEntity(Entities.XA_Hawk, Positions[1].X, Positions[1].Y, 0, PlayerID);
        Logic.SetTaskList(ID, TaskLists.TL_NPC_WALK);
        MakeInvulnerable(ID);
        self.Data.HawkHabitats[PlayerID][_EntityID] = {ID, 3, unpack(Positions)};
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
                self.Config.Crime.Effects.TheftAmount.Min,
                self.Config.Crime.Effects.TheftAmount.Max
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

function Stronghold.Attraction:ManageCriminalsOfPlayer(_PlayerID)
    if IsPlayerInitalized(_PlayerID) then
        -- Converting workers to criminals
        -- Depending on the crime rate each x seconds a settler can become a
        -- criminal by a chance of y%.
        if self:DoCriminalsAppear(_PlayerID) then
            local Data = self.Data[_PlayerID];
            local TimeBetween = self.Config.Crime.Convert.TimeBetween;
            if Data.CriminalsCounter < self.Config.Crime.Convert.MaxPerCycle then
                if Data.LastAttempt + TimeBetween < Logic.GetTime() then
                    local WorkerList = self:GetPotentialCriminalSettlers(_PlayerID);
                    if WorkerList[1] > 0 then
                        local Selected = WorkerList[math.random(2, WorkerList[1] +1)];
                        self:AddCriminal(_PlayerID, Selected[2], Selected[1]);
                    end
                    self.Data[_PlayerID].CriminalsCounter = Data.CriminalsCounter +1;
                    self.Data[_PlayerID].LastAttempt = Logic.GetTime();
                end
            end
        end

        -- Catch criminals
        -- Criminals will be cathed if they are exposed long enough.
        for i= table.getn(self.Data[_PlayerID].Criminals), 1, -1 do
            local Data = self.Data[_PlayerID].Criminals[i];
            if not IsExisting(Data[1]) or not IsExisting(Data[2]) then
                self:RemoveCriminal(_PlayerID, Data[1]);
            else
                local MaxObfuscation = self.Config.Crime.Obfuscation.Points;
                local ExpositionValue = 0;
                local Exposition = self:GetSettlersExposition(_PlayerID, Data[1]);
                if Exposition == 0 then
                    ExpositionValue = math.min(Data[5] + 1, MaxObfuscation);
                else
                    ExpositionValue = math.max(Data[5] - Exposition, 0);
                end
                self.Data[_PlayerID].Criminals[i][5] = ExpositionValue
                if Data[5] <= 0 then
                    self:RemoveCriminal(_PlayerID, Data[1]);
                end
            end
        end

        -- Move criminals
        -- Moves the criminals between the castle and their former workplace.
        -- They might get seen what will rise their exposition.
        for i= table.getn(self.Data[_PlayerID].Criminals), 1, -1 do
            local Data = self.Data[_PlayerID].Criminals[i];
            self.Data[_PlayerID].Criminals[i][4] = Data[4] or GetHeadquarterEntrance(_PlayerID);
            if GetDistance(Data[1], Data[4]) <= 100 then
                self.Data[_PlayerID].Criminals[i][4] = nil;
                if GetDistance(Data[1], GetHeadquarterEntrance(_PlayerID)) <= 100 then
                    self.Data[_PlayerID].Criminals[i][4] = Data[3];
                end
            end
            local Task = Logic.GetCurrentTaskList(Data[1]);
            if  Data[4] and Logic.IsEntityMoving(Data[1]) == false
            and not IsFighting(Data[1]) then
                Logic.MoveSettler(Data[1], Data[4].X, Data[4].Y);
            end
        end
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

-- Replaces the worker with a criminal and calls the callback.
function Stronghold.Attraction:AddCriminal(_PlayerID, _BuildingID, _WorkerID)
    local GuiPlayer = GUI.GetPlayerID();
    local ID = 0;
    if self.Data[_PlayerID] then
        -- Create thief
        local x,y,z = Logic.EntityGetPos(_BuildingID);
        DestroyEntity(_WorkerID);
        ID = AI.Entity_CreateFormation(_PlayerID, Entities.CU_Thief, nil, 0, x, y, 0, 0, 0, 0);
        x,y,z = Logic.EntityGetPos(ID);
        Logic.SetEntitySelectableFlag(ID, 0);
        Logic.MoveSettler(ID, x, y);
        local Points = self.Config.Crime.Obfuscation.Points;
        table.insert(self.Data[_PlayerID].Criminals, {ID, _BuildingID, {X= x, Y= y}, nil, Points});

        -- Show message
        if GuiPlayer == _PlayerID and GuiPlayer ~= 17 then
            Message(XGUIEng.GetStringTableText("sh_text/Player_ConvertedToCriminal"));
        end
        -- Trigger callback
        GameCallback_SH_Logic_CriminalAppeared(_PlayerID, ID, _BuildingID);
    end
    return ID;
end

-- Destroys the criminal and calls the callback.
function Stronghold.Attraction:RemoveCriminal(_PlayerID, _EntityID)
    local GuiPlayer = GUI.GetPlayerID();
    if self.Data[_PlayerID] then
        for i= table.getn(self.Data[_PlayerID].Criminals), 1, -1 do
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
                DestroyEntity(_EntityID);
                break;
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
        CrimeRate = self.Config.Crime.Convert.Rate;
        local Places = GetBuildingsOfType(_PlayerID, Entities.PB_ExecutionerPlace1, true);
        if Places[1] > 0 then
            CrimeRate = CrimeRate * self.Config.Crime.Convert.Executioner;
        end
        CrimeRate = GameCallback_SH_Calculate_CrimeRate(_PlayerID, CrimeRate);
    end
    return CrimeRate;
end

-- Decides if a worker turns criminal.
-- Becoming criminal is chance based and directly tied to the individual
-- happyness of the settler. The presence or absence of "the law" also
-- influences the chance. The cance can never drop below 0.1% per second
-- and never rise about 10% per second.
function Stronghold.Attraction:DoesSettlerTurnCriminal(_PlayerID, _WorkerID)
    if IsPlayerInitalized(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Motivation = Logic.GetSettlersMotivation(_WorkerID);
        local CrimeRate = self:CalculateCrimeRate(_PlayerID);
        local Exposition = self:GetSettlersExposition(_PlayerID, _WorkerID);
        -- Oppurtunity makes the thief...
        if Exposition > 0 then
            CrimeRate = CrimeRate * (1/Exposition);
        end
        local Chance = (self.Config.Crime.Convert.Chance * CrimeRate) * (1/Motivation);
        return math.random(1, 1000) <= math.ceil(math.min(Chance, 10));
    end
    return false;
end

-- Returns all workers that can become criminal.
function Stronghold.Attraction:GetPotentialCriminalSettlers(_PlayerID)
    local ResultList = {0};
    local WorkplaceList = GetWorkplacesOfType(_PlayerID, 0, true);
    for j= 2, WorkplaceList[1] +1 do
        local Type = Logic.GetEntityType(WorkplaceList[j]);
        if Type ~= Entities.PB_Foundry1 and Type ~= Entities.PB_Foundry2 then
            local WorkerOfBuilding = {Logic.GetAttachedWorkersToBuilding(WorkplaceList[j])};
            for i= 2, WorkerOfBuilding[1] +1 do
                if self:DoesSettlerTurnCriminal(_PlayerID, WorkerOfBuilding[i]) then
                    table.insert(ResultList, {WorkerOfBuilding[i], WorkplaceList[j]});
                    ResultList[1] = ResultList[1] +1;
                end
            end
        end
    end
    return ResultList;
end

-- Returns how much a settler is watched by "the law".
-- Beeing watched lowers the chance to become criminal and also increases the
-- chance to catches those who already broke the law.
function Stronghold.Attraction:GetSettlersExposition(_PlayerID, _CriminalID)
    local Exposition = 0;
    if IsPlayerInitalized(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local x,y,z = Logic.EntityGetPos(_CriminalID);
        -- Check militia
        local _, MilitiaID = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PU_BattleSerf, x, y, self.Config.Crime.Obfuscation.SerfArea, 1);
        if MilitiaID then
            Exposition = Exposition + (1 * self.Config.Crime.Obfuscation.SerfRate);
        end
        -- Check watchtowers
        local _, DarkTower1ID = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower1, x, y, self.Config.Crime.Obfuscation.TowerArea, 1);
        local _, DarkTower4ID = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower4, x, y, self.Config.Crime.Obfuscation.TowerArea, 1);
        local _, Tower1ID = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower1, x, y, self.Config.Crime.Obfuscation.TowerArea, 1);
        local _, Tower4ID = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower4, x, y, self.Config.Crime.Obfuscation.TowerArea, 1);
        if (DarkTower1ID and Logic.IsConstructionComplete(DarkTower1ID) == 1)
        or (DarkTower4ID and Logic.IsConstructionComplete(DarkTower4ID) == 1)
        or (Tower1ID and Logic.IsConstructionComplete(Tower1ID) == 1)
        or (Tower4ID and Logic.IsConstructionComplete(Tower4ID) == 1) then
            Exposition = Exposition + (1 * self.Config.Crime.Obfuscation.TowerRate);
        end
        -- Check hero
        local HeroID = GetNobleID(_PlayerID);
        if Logic.CheckEntitiesDistance(_CriminalID, HeroID, self.Config.Crime.Obfuscation.HeroArea) == 1 then
            Exposition = Exposition + (1 * self.Config.Crime.Obfuscation.HeroRate);
        end
        -- Check town guard
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_ReportingOffice) == 1 then
            Exposition = Exposition * self.Config.Crime.Obfuscation.TownGuardFactor;
        end
    end
    return Exposition;
end

function Stronghold.Attraction:CountCriminals(_PlayerID)
    local CriminalCount = 0;
    if self.Data[_PlayerID] then
        CriminalCount = table.getn(self.Data[_PlayerID].Criminals);
    end
    return CriminalCount;
end

function Stronghold.Attraction:GetCriminals(_PlayerID)
    if self.Data[_PlayerID] then
        return self.Data[_PlayerID].Criminals;
    end
    return {};
end

function Stronghold.Attraction:GetReputationLossByCriminals(_PlayerID)
    local Loss = 0;
    if self.Data[_PlayerID] then
        local Criminals = self:CountCriminals(_PlayerID);
        local Damage = self.Config.Crime.Effects.ReputationDamage;
        Loss = Loss + (Damage * Criminals);
    end
    return Loss;
end

function Stronghold.Attraction:GetCriminalsOfBuilding(_BuildingID)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Criminals = {0};
    if self.Data[PlayerID] then
        for i= table.getn(self.Data[PlayerID].Criminals), 1, -1 do
            if self.Data[PlayerID].Criminals[i][2] == _BuildingID then
                table.insert(Criminals, self.Data[PlayerID].Criminals[i][1]);
                Criminals[1] = Criminals[1] + 1;
            end
        end
    end
    return Criminals;
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
        return MilitaryLimit - MilitaryUsage > _Amount;
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

