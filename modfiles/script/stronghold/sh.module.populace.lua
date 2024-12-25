---
--- Attraction Script
---
--- This script manages the attraction of settlers for the players.
---
--- Attraction limit is split in two. The player has a civil and a military
--- limit. Civil units are all workers and military is the rest.
---

Stronghold = Stronghold or {};

Stronghold.Populace = {
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
    return Stronghold.Populace:CalculateCrimeRate(_PlayerID);
end

--- Returns the amount of criminals the player has.
--- @param _PlayerID integer ID of player
--- @return integer Amount Amount of criminals
function CountCriminals(_PlayerID)
    return Stronghold.Populace:CountCriminals(_PlayerID);
end

--- Converts a worker to a criminal.
--- @param _PlayerID integer ID of player
--- @param _BuildingID integer Workplace of worker
--- @param _WorkerID integer ID of worker
function ConvertToCriminal(_PlayerID, _BuildingID, _WorkerID)
    Stronghold.Populace:ConvertToCriminal(_PlayerID, _BuildingID, _WorkerID);
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
    return Stronghold.Populace:GetCriminalsOfBuilding(_BuildingID);
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

--- Calculates the crime rate of the player.
--- @param _PlayerID integer ID of player
--- @param _Rate number Current crime rate
--- @return number Altered Altered crime rate
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

--- Calculates the filth rate of the player.
--- @param _PlayerID integer ID of player
--- @param _Rate number Current filth rate
--- @return number Altered Altered filth rate
function GameCallback_SH_Calculate_FilthRate(_PlayerID, _Rate)
    return _Rate;
end

--- Triggers after a building has spawned a rat.
--- @param _PlayerID integer ID of player
--- @param _EntityID integer ID of rat
--- @param _BuildingID integer ID of building
function GameCallback_SH_Logic_RatAppeared(_PlayerID, _EntityID, _BuildingID)
end

--- Triggers before a rat is deleted because it has been killed.
--- @param _PlayerID integer ID of player
--- @param _EntityID integer ID of rat
--- @param _BuildingID integer ID of building
function GameCallback_SH_Logic_RatExterminated(_PlayerID, _EntityID, _BuildingID)
end

-- -------------------------------------------------------------------------- --
-- Main

function Stronghold.Populace:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            Watchtowers = {0},
            LastCrimeAttempt = 0,
            CriminalsCounter = 0,
            Criminals = {0},
            LastRatAttempt = 0,
            RatsCounter = 0,
            Rats = {0},
        };
        -- For each player seperatly to better distribute the computing load
        self.Data.HawkHabitats[i] = {};
    end

    self:InitalizeHawksForExistingTowers();
    self:InitalizeGuardsForExistingBuildings();
    self:OverwriteHeroFindButtonUpdate();
    self:OnPayday();
end

function Stronghold.Populace:OnSaveGameLoaded()
    self:OverwriteHeroFindButtonUpdate();
end

function Stronghold.Populace:OnEntityCreated(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    -- Set stamina
    if Logic.IsWorker(_EntityID) == 1 then
        local MaxStamina = CEntity.GetMaxStamina(_EntityID);
        SetEntityStamina(_EntityID, MaxStamina * 0.1);
    end
    -- Watchtowers
    self:OnWatchtowerBuild(_EntityID, PlayerID);
end

function Stronghold.Populace:OnEntityDestroyed(_EntityID)
    -- Hawks
    self:OnHawkHabitatDestroyed(_EntityID);
end

function Stronghold.Populace:OncePerSecond(_PlayerID)
    -- Watchtowers
    self:ManageWatchtowersOfPlayer(_PlayerID);
    -- Criminals
    self:ManageCriminalsOfPlayer(_PlayerID);
    -- Rats
    self:ManageRatsOfPlayer(_PlayerID);
    -- Control hawk
    self:ManageHawksOfPlayer(_PlayerID);
end

function Stronghold.Populace:OnConstructionComplete(_EntityID, _PlayerID)
    -- Watchtowers
    self:OnWatchtowerBuild(_EntityID, _PlayerID);
    -- Hawks
    self:OnHawkHabitatCreated(_EntityID);
end

function Stronghold.Populace:OnUpgradeComplete(_EntityIDOld, _EntityIDNew)
end

function Stronghold.Populace:OnPayday()
    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_Payday", function(_PlayerID, _Amount)
        local Amount = Overwrite.CallOriginal();
        Stronghold.Populace:OnRatPlagueOnPayday(_PlayerID);
        Stronghold.Populace:StealGoodsOnPayday(_PlayerID);
        Stronghold.Populace:ResetThievesCycleCounter(_PlayerID);
        Stronghold.Populace:ResetRatsCycleCounter(_PlayerID);
        return Amount;
    end);
end

-- -------------------------------------------------------------------------- --
-- Hero Update

function Stronghold.Populace:OverwriteHeroFindButtonUpdate()
    GUIUpdate_HeroFindButtons = function()
        local PlayerID = GUI.GetPlayerID();

        local Hero = {};
        Logic.GetHeroes(PlayerID, Hero);
        for i= table.getn(Hero), 1, -1 do
            local Type = Logic.GetEntityType(Hero[i]);
            if self.Config.FakeHeroTypes[Type] then
                table.remove(Hero, i);
            end
        end

        for j= 1, 6 do
            if  Hero[j] ~= nil then
                XGUIEng.ShowWidget(gvGUI_WidgetID.HeroFindButtons[j], 1);
                XGUIEng.ShowWidget(gvGUI_WidgetID.HeroBGIcon[j], 1);
                XGUIEng.SetBaseWidgetUserVariable(gvGUI_WidgetID.HeroFindButtons[j], 0,Hero[j]);
                if Logic.GetEntityHealth(Hero[j]) == 0 then
                    XGUIEng.ShowWidget(gvGUI_WidgetID.HeroDeadIcon[j], 1);
                else
                    XGUIEng.ShowWidget(gvGUI_WidgetID.HeroDeadIcon[j], 0);
                end
            else
                XGUIEng.ShowWidget(gvGUI_WidgetID.HeroFindButtons[j], 0);
                XGUIEng.ShowWidget(gvGUI_WidgetID.HeroBGIcon[j], 0);
                XGUIEng.ShowWidget(gvGUI_WidgetID.HeroDeadIcon[j], 0);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Watchtowers

function Stronghold.Populace:InitalizeGuardsForExistingBuildings()
    for PlayerID = 1, GetMaxPlayers() do
        local Buildings = GetPlayerEntities(PlayerID, 0);
        for i= 1, table.getn(Buildings) do
            self:OnWatchtowerBuild(Buildings[i], PlayerID);
        end
    end
end

function Stronghold.Populace:OnWatchtowerBuild(_EntityID, _PlayerID)
    local EntityType = Logic.GetEntityType(_EntityID);
    if EntityType == Entities.PB_DarkTower1 or EntityType == Entities.PB_Tower1
    or EntityType == Entities.PB_DarkTower4 or EntityType == Entities.PB_Tower4 then
        if Logic.IsConstructionComplete(_EntityID) == 1 then
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
end

function Stronghold.Populace:OnWatchtowerUpgraded(_EntityIDOld, _EntityIDNew, _PlayerID)
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

function Stronghold.Populace:OnWatchtowerDestroyed(_EntityID)
    -- Hawk removal
    self:OnHawkHabitatDestroyed(_EntityID);
end

function Stronghold.Populace:ManageWatchtowersOfPlayer(_PlayerID)
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
                    Logic.SetEntitySelectableFlag(Data[2], 0);
                    Logic.SetEntityScriptingValue(Data[2], 72, 4);
                end
            -- Catch criminal
            elseif Data[5] == 2 then
                if not IsValidEntity(Data[4])
                or Logic.CheckEntitiesDistance(Data[1], Data[2], MaxDistance) == 0 then
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

function Stronghold.Populace:InitalizeHawksForExistingTowers()
    for PlayerID = 1, GetMaxPlayers() do
        local Buildings = GetPlayerEntities(PlayerID, 0);
        for i= 1, table.getn(Buildings) do
            self:OnHawkHabitatCreated(Buildings[i]);
        end
    end
end

function Stronghold.Populace:OnHawkHabitatCreated(_EntityID)
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
            self:OnHawkHabitatDestroyed(_EntityID);
            self.Data.HawkHabitats[PlayerID][_EntityID] = {ID, 3, unpack(Positions)};
        end
    end
end

function Stronghold.Populace:OnHawkHabitatDestroyed(_EntityID)
    for PlayerID,_ in pairs(self.Data.HawkHabitats) do
        if self.Data.HawkHabitats[PlayerID][_EntityID] then
            local ID = self.Data.HawkHabitats[PlayerID][_EntityID][1];
            DestroyEntity(ID);
            self.Data.HawkHabitats[PlayerID][_EntityID] = nil;
        end
    end
end

function Stronghold.Populace:ManageHawksOfPlayer(_PlayerID)
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

function Stronghold.Populace:ResetRatsCycleCounter(_PlayerID)
    if IsPlayer(_PlayerID) then
        self.Data[_PlayerID].RatsCounter = 0;
    end
end

function Stronghold.Populace:DoRatsAppear(_PlayerID)
    return GetRank(_PlayerID) >= PlayerRank.Count;
end

function Stronghold.Populace:GetRatDestinations(_PlayerID)
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

function Stronghold.Populace:CreateRatAtBuilding(_PlayerID, _BuildingID)
    local ID = 0;
    if IsExisting(_BuildingID) then
        -- Create rat
        local x,y,z = Logic.EntityGetPos(_BuildingID);
        ID = AI.Entity_CreateFormation(_PlayerID, Entities.PU_Rat_Deco, nil, 0, x, y, 0, 0, 0, 0);
        SVLib.SetEntitySize(ID, 0.5);
        x,y,z = Logic.EntityGetPos(ID);
        Logic.SetEntitySelectableFlag(ID, 0);
        Logic.MoveSettler(ID, x, y);
    end
    return ID;
end

function Stronghold.Populace:RegisterRat(_PlayerID, _BuildingID)
    local ID = 0;
    if self.Data[_PlayerID] and IsExisting(_BuildingID) then
        -- Create thief
        local x,y,z = Logic.EntityGetPos(_BuildingID);
        ID = self:CreateRatAtBuilding(_PlayerID, _BuildingID);
        x,y,z = Logic.EntityGetPos(ID);
        local Data = {ID, _BuildingID, {X= x, Y= y}, nil, 0};
        table.insert(self.Data[_PlayerID].Rats, Data);
        self.Data[_PlayerID].Rats[1] = self.Data[_PlayerID].Rats[1] + 1;
        -- Trigger callback
        GameCallback_SH_Logic_RatAppeared(_PlayerID, ID, _BuildingID);
    end
    return ID;
end

function Stronghold.Populace:UnregisterRat(_PlayerID, _EntityID)
    if self.Data[_PlayerID] then
        for i= self.Data[_PlayerID].Rats[1] +1, 2, -1 do
            local Data = self.Data[_PlayerID].Rats[i];
            if Data[1] == _EntityID then
                -- Invoke callback
                GameCallback_SH_Logic_RatExterminated(_PlayerID, Data[1], Data[2]);
                -- Delete thief
                table.remove(self.Data[_PlayerID].Rats, i);
                self.Data[_PlayerID].Rats[1] = self.Data[_PlayerID].Rats[1] - 1;
            end
        end
    end
end

function Stronghold.Populace:CalculateFilthRate(_PlayerID)
    local FilthRate = 0;
    if IsPlayerInitalized(_PlayerID) and not IsAIPlayer(_PlayerID) then
        FilthRate = self.Config.CivilDuties.Rats.FilthRate;
        -- TODO: Create special building?
        FilthRate = GameCallback_SH_Calculate_FilthRate(_PlayerID, FilthRate);
    end
    return FilthRate;
end

function Stronghold.Populace:CountRats(_PlayerID)
    local RatCount = 0;
    if self.Data[_PlayerID] then
        RatCount = self.Data[_PlayerID].Rats[1];
    end
    return RatCount;
end

function Stronghold.Populace:GetReputationLossByRats(_PlayerID)
    local Loss = 0;
    if self.Data[_PlayerID] then
        local Morale = GetPlayerMorale(_PlayerID);
        local Rats = self:CountRats(_PlayerID);
        local Damage = self.Config.CivilDuties.Rats.ReputationDamage;
        Loss = Loss + (Damage * Rats);
        Loss = math.max(math.floor((Loss / Morale) + 0.5), 0);
    end
    return Loss;
end

function Stronghold.Populace:GetRatsOfBuilding(_BuildingID)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Rats = {0};
    if self.Data[PlayerID] then
        for i= self.Data[PlayerID].Rats[1] +1, 2, -1 do
            if self.Data[PlayerID].Rats[i][2] == _BuildingID then
                table.insert(Rats, self.Data[PlayerID].Rats[i][1]);
                Rats[1] = Rats[1] + 1;
            end
        end
    end
    return Rats;
end

-- Returns a random position for a thief to walk to.
function Stronghold.Populace:GetRatTarget(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local WorkplaceList = GetWorkplacesOfType(PlayerID, 0, true);
    local DoorPos = GetHeadquarterEntrance(PlayerID);
    local Target = WorkplaceList[math.random(2, WorkplaceList[1] +1)];
    return GetReachablePosition(_EntityID, Target, DoorPos);
end

-- Returns the amount of filthiness.
function Stronghold.Populace:GetPlayerFilthiness(_PlayerID)
    local Motivation = GetReputation(_PlayerID) / 100;
    local Workers = Logic.GetNumberOfAttractedWorker(_PlayerID);
    local WorkerRate = self.Config.CivilDuties.Rats.WorkerRate;
    local FilthRate = self:CalculateFilthRate(_PlayerID);
    local Potential = (Workers * WorkerRate) * (1/Motivation) * FilthRate;
    return math.min(math.floor(Potential), 100);
end

function Stronghold.Populace:GetHawkTowersInArea(_PlayerID, _X, _Y, _Area)
    local _, HawkTower1 = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower4, _X, _Y, _Area, 1);
    local _, HawkTower2 = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower4, _X, _Y, _Area, 1);
    if HawkTower1 or HawkTower2 then
        return true;
    end
    return false;
end

function Stronghold.Populace:OnRatPlagueOnPayday(_PlayerID)
    if IsPlayer(_PlayerID) then
        if self:GetReputationLossByRats(_PlayerID) > 0 and GUI.GetPlayerID() == _PlayerID then
            Message(XGUIEng.GetStringTableText("sh_text/Player_RatsSpreadDisease"));
        end
    end
end

function Stronghold.Populace:ManageRatsOfPlayer(_PlayerID)
    if IsPlayerInitalized(_PlayerID) then
        -- Create rats at workplaces
        -- Depending on the filth rate each x seconds a rat is spawned by
        -- a chance of y%.
        if self:DoRatsAppear(_PlayerID) then
            local Data = self.Data[_PlayerID];
            local TimeBetween = self.Config.CivilDuties.Rats.TimeBetween;
            if Data.RatsCounter < self.Config.CivilDuties.Rats.MaxPerCycle then
                if Data.LastRatAttempt + TimeBetween < Logic.GetTime() then
                    local Filth = self:GetPlayerFilthiness(_PlayerID);
                    if Filth > 0 and math.random(1,100) <= Filth then
                        local BuildingList = GetWorkplacesOfType(_PlayerID, 0, true);
                        local Selected = BuildingList[math.random(2, BuildingList[1] +1)];
                        if self:RegisterRat(_PlayerID, Selected) ~= 0 then
                            self.Data[_PlayerID].RatsCounter = Data.RatsCounter +1;
                        end
                        self.Data[_PlayerID].LastRatAttempt = Logic.GetTime();
                    end
                end
            end
        end

        -- Control rats
        -- Moves the rats between random workplaces.
        for i= self.Data[_PlayerID].Rats[1] +1, 2, -1 do
            local Data = self.Data[_PlayerID].Rats[i];
            if IsValidEntity(Data[1]) then
                if Data[5] == 0 then
                    local RandomPosition = self:GetRatTarget(Data[1]);
                    self.Data[_PlayerID].Rats[i][4] = RandomPosition;
                    self.Data[_PlayerID].Rats[i][5] = 1;
                    Logic.MoveSettler(Data[1], Data[4].X, Data[4].Y);
                    Logic.SetEntityScriptingValue(Data[1], 72, 4);
                elseif Data[5] == 1 then
                    if Logic.IsEntityMoving(Data[1]) == false then
                        self.Data[_PlayerID].Rats[i][5] = 2;
                        return;
                    end
                    Logic.SetEntityScriptingValue(Data[1], 72, 4);
                    local x,y,z = Logic.EntityGetPos(Data[1])
                    local Area = self.Config.CivilDuties.Rats.TowerVisionArea;
                    if self:GetHawkTowersInArea(_PlayerID, x, y, Area) then
                        local Chance = self.Config.CivilDuties.Rats.CatchChance;
                        if math.random(1, 100) <= Chance then
                            DestroyEntity(Data[1]);
                        end
                    end
                elseif Data[5] == 2 then
                    self.Data[_PlayerID].Rats[i][4] = CopyTable(Data[3]);
                    self.Data[_PlayerID].Rats[i][5] = 3;
                    Logic.MoveSettler(Data[1], Data[4].X, Data[4].Y);
                    Logic.SetEntityScriptingValue(Data[1], 72, 4);
                elseif Data[5] == 3 then
                    if Logic.IsEntityMoving(Data[1]) == false then
                        self.Data[_PlayerID].Rats[i][5] = 0;
                        return;
                    end
                    local x,y,z = Logic.EntityGetPos(Data[1])
                    local Area = self.Config.CivilDuties.Rats.TowerVisionArea;
                    Logic.SetEntityScriptingValue(Data[1], 72, 4);
                    if self:GetHawkTowersInArea(_PlayerID, x, y, Area) then
                        local Chance = self.Config.CivilDuties.Rats.CatchChance;
                        if math.random(1, 100) <= Chance then
                            DestroyEntity(Data[1]);
                        end
                    end
                end
            else
                self:UnregisterRat(_PlayerID, Data[1]);
            end
        end

        -- Control hero
        -- The hero can hunt down rats everywhere
        local HeroID = GetNobleID(_PlayerID);
        if IsEntityValid(HeroID) then
            local x,y,z = Logic.EntityGetPos(HeroID);
            local Area = self.Config.CivilDuties.Rats.HeroVisionArea;
            local _, EntityID = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PU_Rat_Deco, x, y, Area, 1);
            if EntityID then
                DestroyEntity(EntityID);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Criminals

function Stronghold.Populace:ResetThievesCycleCounter(_PlayerID)
    if IsPlayer(_PlayerID) then
        self.Data[_PlayerID].CriminalsCounter = 0;
    end
end

function Stronghold.Populace:StealGoodsOnPayday(_PlayerID)
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

function Stronghold.Populace:GetCriminalDestinations(_PlayerID)
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
function Stronghold.Populace:CreateCriminalFromWorker(_PlayerID, _BuildingID, _WorkerID)
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
function Stronghold.Populace:ConvertToCriminal(_PlayerID, _BuildingID, _WorkerID)
    local ID = 0;
    if self.Data[_PlayerID] and IsExisting(_BuildingID) and IsExisting(_WorkerID) then
        -- Create thief
        local x,y,z = Logic.EntityGetPos(_BuildingID);
        ID = self:CreateCriminalFromWorker(_PlayerID, _BuildingID, _WorkerID);
        x,y,z = Logic.EntityGetPos(ID);
        local Data = {ID, _BuildingID, {X= x, Y= y}, nil, 0};
        table.insert(self.Data[_PlayerID].Criminals, Data);
        self.Data[_PlayerID].Criminals[1] = self.Data[_PlayerID].Criminals[1] + 1;
        -- Trigger callback
        GameCallback_SH_Logic_CriminalAppeared(_PlayerID, ID, _BuildingID);
    end
    return ID;
end

-- Unregister the criminal and calls the callback.
function Stronghold.Populace:UnregisterCriminal(_PlayerID, _EntityID)
    if self.Data[_PlayerID] then
        for i= self.Data[_PlayerID].Criminals[1] +1, 2, -1 do
            local Data = self.Data[_PlayerID].Criminals[i];
            if Data[1] == _EntityID then
                -- Invoke callback
                GameCallback_SH_Logic_CriminalCatched(_PlayerID, Data[1], Data[2]);
                -- Delete thief
                table.remove(self.Data[_PlayerID].Criminals, i);
                self.Data[_PlayerID].Criminals[1] = self.Data[_PlayerID].Criminals[1] - 1;
            end
        end
    end
end

function Stronghold.Populace:DoCriminalsAppear(_PlayerID)
    return GetRank(_PlayerID) >= PlayerRank.Earl;
end

function Stronghold.Populace:CalculateCrimeRate(_PlayerID)
    local CrimeRate = 0;
    if IsPlayerInitalized(_PlayerID) and not IsAIPlayer(_PlayerID) then
        CrimeRate = self.Config.CivilDuties.Crime.CrimeRate;
        local ChopChop = GetPlayerEntities(_PlayerID, Entities.PB_ExecutionerPlace1);
        if ChopChop[1] and Logic.IsConstructionComplete(ChopChop[1]) == 1 then
            CrimeRate = CrimeRate * self.Config.CivilDuties.Crime.ExecutionerRate;
        end
        CrimeRate = GameCallback_SH_Calculate_CrimeRate(_PlayerID, CrimeRate);
    end
    return CrimeRate;
end

function Stronghold.Populace:CountCriminals(_PlayerID)
    local CriminalCount = 0;
    if self.Data[_PlayerID] then
        CriminalCount = self.Data[_PlayerID].Criminals[1];
    end
    return CriminalCount;
end

function Stronghold.Populace:GetReputationLossByCriminals(_PlayerID)
    local Loss = 0;
    if self.Data[_PlayerID] then
        local Morale = GetPlayerMorale(_PlayerID);
        local Criminals = self:CountCriminals(_PlayerID);
        local Damage = self.Config.CivilDuties.Crime.ReputationDamage;
        Loss = Loss + (Damage * Criminals);
        Loss = math.max(math.floor((Loss / Morale) + 0.5), 0);
    end
    return Loss;
end

function Stronghold.Populace:GetCriminalsOfBuilding(_BuildingID)
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
function Stronghold.Populace:GetCriminalTarget(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local WorkplaceList = GetWorkplacesOfType(PlayerID, 0, true);
    if WorkplaceList[1] > 0 then
        local DoorPos = GetHeadquarterEntrance(PlayerID);
        local Target = WorkplaceList[math.random(2, WorkplaceList[1] +1)];
        return GetReachablePosition(_EntityID, Target, DoorPos);
    end
end

-- Returns the amount of criminal energy.
function Stronghold.Populace:GetCriminalEnergy(_PlayerID)
    local Motivation = GetReputation(_PlayerID) / 100;
    local Workers = Logic.GetNumberOfAttractedWorker(_PlayerID);
    if Workers > 0 then
        local WorkerRate = self.Config.CivilDuties.Crime.WorkerRate;
        local CrimeRate = self:CalculateCrimeRate(_PlayerID);
        local Potential = (Workers * WorkerRate) * (1/Motivation) * CrimeRate;
        return math.min(math.floor(Potential), 100);
    end
    return 0;
end

function Stronghold.Populace:ManageCriminalsOfPlayer(_PlayerID)
    if IsPlayerInitalized(_PlayerID) then
        -- Converting workers to criminals
        -- Depending on the crime rate each x seconds a settler can become a
        -- criminal by a chance of y%.
        if self:DoCriminalsAppear(_PlayerID) then
            local Data = self.Data[_PlayerID];
            local TimeBetween = self.Config.CivilDuties.Crime.TimeBetween;
            if Data.CriminalsCounter < self.Config.CivilDuties.Crime.MaxPerCycle then
                if Data.LastCrimeAttempt + TimeBetween < Logic.GetTime() then
                    local CriminalEnergy = self:GetCriminalEnergy(_PlayerID);
                    if CriminalEnergy > 0 and math.random(1,100) <= CriminalEnergy then
                        local Selected = 0;
                        local WorkerList = GetWorkersOfType(_PlayerID, 0);
                        if WorkerList[1] > 0 then
                            Selected = WorkerList[math.random(2, WorkerList[1] +1)];
                        end
                        local Building = Logic.GetSettlersWorkBuilding(Selected);
                        if self:ConvertToCriminal(_PlayerID, Building, Selected) ~= 0 then
                            self.Data[_PlayerID].CriminalsCounter = Data.CriminalsCounter +1;
                        end
                        self.Data[_PlayerID].LastCrimeAttempt = Logic.GetTime();
                    end
                end
            end
        end

        -- Control criminals
        -- Moves the criminals between the castle and their former workplace.
        for i= self.Data[_PlayerID].Criminals[1] +1, 2, -1 do
            local Data = self.Data[_PlayerID].Criminals[i];
            if IsValidEntity(Data[1]) then
                if Data[5] == 0 then
                    local RandomPosition = self:GetCriminalTarget(Data[1]);
                    if RandomPosition then
                        self.Data[_PlayerID].Criminals[i][4] = RandomPosition;
                        self.Data[_PlayerID].Criminals[i][5] = 1;
                        Logic.SetEntityScriptingValue(Data[1], 72, 4);
                        Logic.MoveSettler(Data[1], Data[4].X, Data[4].Y);
                    end
                elseif Data[5] == 1 then
                    if Logic.IsEntityMoving(Data[1]) == false then
                        self.Data[_PlayerID].Criminals[i][5] = 2;
                    end
                    Logic.SetEntityScriptingValue(Data[1], 72, 4);
                    local x,y,z = Logic.EntityGetPos(Data[1])
                    local _, Criminal = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PU_Watchman_Deco, x, y, 300, 1);
                    if Criminal then
                        DestroyEntity(Data[1]);
                    end
                elseif Data[5] == 2 then
                    self.Data[_PlayerID].Criminals[i][4] = CopyTable(Data[3]);
                    self.Data[_PlayerID].Criminals[i][5] = 3;
                    Logic.MoveSettler(Data[1], Data[4].X, Data[4].Y);
                    Logic.SetEntityScriptingValue(Data[1], 72, 4);
                elseif Data[5] == 3 then
                    if Logic.IsEntityMoving(Data[1]) == false then
                        self.Data[_PlayerID].Criminals[i][5] = 0;
                    end
                    Logic.SetEntityScriptingValue(Data[1], 72, 4);
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

