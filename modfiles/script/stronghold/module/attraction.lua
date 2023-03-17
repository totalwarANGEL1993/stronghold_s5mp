---
--- Attraction Script
---
--- This script manages the attraction of settlers for the players.
---
--- Defined game callbacks:
--- - <number> GameCallback_Calculate_CivilAttrationLimit(_PlayerID, _Amount)
---   Allows to overwrite the max worker attraction.
---
--- - <number> GameCallback_Calculate_CivilAttrationUsage(_PlayerID, _Amount)
---   Allows to overwrite the used worker attraction.
---
--- - <number> GameCallback_Calculate_MilitaryAttrationUsage(_PlayerID, _Amount)
---   Allows to overwrite the current overall usage of military places.
---
--- - <number> GameCallback_Calculate_MilitaryAttrationLimit(_PlayerID, _Amount)
---   Allows to overwrite the max usage of military places.
---
--- - <number> GameCallback_Calculate_UnitPlaces(_PlayerID, _EntityID, _Type, _Places)
---   Allows to overwrite the places a unit is occupying.
--- 
--- - <number> GameCallback_Calculate_CrimeRate(_PlayerID, _Rate)
---   Allows to overwrite the crime rate.
--- 
--- - <number> GameCallback_Calculate_CrimeChance(_PlayerID, _Chance)
---   Allows to overwrite the crime chance.
---
--- - <number> GameCallback_Logic_CriminalAppeared(_PlayerID, _EntityID, _BuildingID)
---   Allows to overwrite the crime chance.
---
--- - <number> GameCallback_Logic_CriminalCatched(_PlayerID, _OldEntityID, _BuildingID)
---   Allows to overwrite the crime chance.
---

Stronghold = Stronghold or {};

Stronghold.Attraction = {
    Data = {},
    Config = {
        HQMilitaryAttraction = {
            [1] = 75,
            [2] = 100,
            [3] = 125
        },
        HQCivilAttraction = {
            [1] = 76,
            [2] = 76,
            [3] = 76
        },
        VCCivilAttraction = {
            [1] = 54,
            [2] = 72,
            [3] = 90
        },

        Criminals = {
            Steal      = {Min = 25, Max = 75},
            Convert    = {Rate = 1.0, Chance = 850, Time = 2*60},
            Catch      = {Chance = 4, Area = 4000},
            Reputation = 3,
        },

        UsedSpace = {
            [Entities.CU_BanditLeaderSword1] = 1,
            [Entities.CU_BanditLeaderSword2] = 1,
            [Entities.CU_Barbarian_LeaderClub1] = 1,
            [Entities.CU_Barbarian_LeaderClub2] = 1,
            [Entities.CU_BlackKnight_LeaderMace1] = 1,
            [Entities.CU_BlackKnight_LeaderMace2] = 1,
            [Entities.CU_Evil_LeaderBearman1] = 1,
            [Entities.PU_LeaderPoleArm1] = 1,
            [Entities.PU_LeaderPoleArm2] = 1,
            [Entities.PU_LeaderPoleArm3] = 1,
            [Entities.PU_LeaderPoleArm4] = 1,
            [Entities.PU_LeaderSword1] = 1,
            [Entities.PU_LeaderSword2] = 1,
            [Entities.PU_LeaderSword3] = 1,
            [Entities.PU_LeaderSword4] = 1,
            ---
            [Entities.CU_BanditLeaderBow1] = 1,
            [Entities.CU_Evil_LeaderSkirmisher1] = 1,
            [Entities.PU_LeaderBow1] = 1,
            [Entities.PU_LeaderBow2] = 1,
            [Entities.PU_LeaderBow3] = 1,
            [Entities.PU_LeaderBow4] = 1,
            [Entities.PU_LeaderRifle1] = 2,
            [Entities.PU_LeaderRifle2] = 2,
            ---
            [Entities.PU_LeaderCavalry1] = 1,
            [Entities.PU_LeaderCavalry2] = 1,
            [Entities.PU_LeaderHeavyCavalry1] = 3,
            [Entities.PU_LeaderHeavyCavalry2] = 3,
            ---
            [Entities.PV_Cannon1] = 10,
            [Entities.PV_Cannon2] = 10,
            [Entities.PV_Cannon3] = 20,
            [Entities.PV_Cannon4] = 20,
            ---
            [Entities.PU_Scout] = 0,
            [Entities.PU_Thief] = 0,
            ---
            [Entities.PU_Serf] = 0,
        },

        UI = {
            Msg = {
                ConvertedToCriminal = {
                    de = "Ein Arbeiter hat das Gesetz gebrochen!",
                    en = "A worker has become a criminal!",
                },
                CriminalsStoleResources = {
                    de = "Verbrecher haben %d Rohstoffe aus Euren Vorräten gestohlen!",
                    en = "Criminals have stolen %d resources from your stockpile!",
                },
                CriminalResocialized = {
                    de = "Ein Verbrecher hat seine gerechte Strafe erhalten!",
                    en = "A criminal has received their just punishment!",
                },
            }
        }
    },
};

-- -------------------------------------------------------------------------- --
-- API

function GetCrimeRate(_PlayerID)
    return Stronghold.Attraction:CalculateCrimeRate(_PlayerID);
end

function CountCriminals(_PlayerID)
    return Stronghold.Attraction:CountCriminals(_PlayerID);
end

function ConvertToCriminal(_PlayerID, _BuildingID, _WorkerID)
    Stronghold.Attraction:AddCriminal(_PlayerID, _BuildingID, _WorkerID);
end

function RehabilitateCriminal(_PlayerID, _EntityID)
    Stronghold.Attraction:RemoveCriminal(_PlayerID, _EntityID);
end

function GetCriminalsOfBuilding(_BuildingID)
    return Stronghold.Attraction:GetCriminalsOfBuilding(_BuildingID);
end

function GetMilitaryAttractionLimit(_PlayerID)
    return Stronghold.Attraction:GetPlayerMilitaryAttractionLimit(_PlayerID);
end

function GetMilitaryAttractionUsage(_PlayerID)
    return Stronghold.Attraction:GetPlayerMilitaryAttractionUsage(_PlayerID);
end

function GetCivilAttractionLimit(_PlayerID)
    return Logic.GetPlayerAttractionLimit(_PlayerID);
end

function GetCivilAttractionUsage(_PlayerID)
    return Logic.GetPlayerAttractionUsage(_PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Attraction:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {
            LastCriminal = 0,
            Criminals = {},
        };
    end

    self:OverrideAttraction();
    self:InitCriminalsEffects();
end

function Stronghold.Attraction:OnSaveGameLoaded()
    self:OverrideAttraction();
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

function GameCallback_Calculate_MilitaryAttrationLimit(_PlayerID, _Amount)
    return _Amount
end

function GameCallback_Calculate_CivilAttrationLimit(_PlayerID, _Amount)
    return _Amount
end

function GameCallback_Calculate_CivilAttrationUsage(_PlayerID, _Amount)
    return _Amount
end

function GameCallback_Calculate_MilitaryAttrationUsage(_PlayerID, _Amount)
    return _Amount
end

function GameCallback_Calculate_UnitPlaces(_PlayerID, _EntityID, _Type, _Usage)
    return _Usage;
end

function GameCallback_Calculate_CrimeRate(_PlayerID, _Rate)
    return _Rate;
end

function GameCallback_Calculate_CrimeChance(_PlayerID, _Chance)
    return _Chance;
end

function GameCallback_Logic_CriminalAppeared(_PlayerID, _EntityID, _BuildingID)
end

function GameCallback_Logic_CriminalCatched(_PlayerID, _OldEntityID, _BuildingID)
end

-- -------------------------------------------------------------------------- --
-- Criminals

function Stronghold.Attraction:ManageCriminalsOfPlayer(_PlayerID)
    if self.Data[_PlayerID] then
        -- Converting workers to criminals
        -- Depending on the crime rate each x seconds a settler can become a
        -- criminal by a chance of y%.
        -- Then they are deleted and their space inside the building is blocked
        -- until the criminal is punished.
        if self:DoCriminalsAppear(_PlayerID) then
            local CrimeRate = self:CalculateCrimeRate(_PlayerID);
            local CrimeChance = self.Config.Criminals.Convert.Chance;
            local CrimeTime = self.Config.Criminals.Convert.Time;
            if self.Data[_PlayerID].LastCriminal + (CrimeRate * CrimeTime) < Logic.GetTime() then
                CrimeChance = GameCallback_Calculate_CrimeChance(_PlayerID, CrimeChance);
                if math.random(1, 1000) <= CrimeChance then
                    local WorkerList = {};
                    for k, v in pairs(GetAllWorkplaces(_PlayerID)) do
                        if Logic.GetEntityType(v) ~= Entities.PB_Foundry1 and Logic.GetEntityType(v) ~= Entities.PB_Foundry2 then
                            local WorkerOfBuilding = {Logic.GetAttachedWorkersToBuilding(v)};
                            for i= 2, WorkerOfBuilding[1] +1 do
                                table.insert(WorkerList, {WorkerOfBuilding[i], v});
                            end
                        end
                    end
                    local WorkerCount = table.getn(WorkerList);
                    if WorkerCount > 0 then
                        local Selected = WorkerList[math.random(1, WorkerCount)];
                        local ID = self:AddCriminal(_PlayerID, Selected[2], Selected[1]);
                        if ID ~= 0 then
                            if GUI.GetPlayerID() == _PlayerID then
                                local Language = GetLanguage();
                                Message(self.Config.UI.Msg.ConvertedToCriminal[Language]);
                            end
                            GameCallback_Logic_CriminalAppeared(_PlayerID, ID, Selected[2]);
                        end
                    end
                end
                self.Data[_PlayerID].LastCriminal = Logic.GetTime();
            end
        end

        -- Catch criminals
        -- Criminals can be catched if close to their base of opperation any
        -- millitary unit is present. When townguard is researched criminals
        -- are found more efficiently.
        for i= table.getn(self.Data[_PlayerID].Criminals), 1, -1 do
            local Data = self.Data[_PlayerID].Criminals[i];
            if not IsExisting(Data[2]) then
                self:RemoveCriminal(_PlayerID, Data[1]);
            else
                local x,y,z = Logic.EntityGetPos(Data[1]);
                if Logic.IsPlayerEntityOfCategoryInArea(_PlayerID, x, y, self.Config.Criminals.Catch.Area, "Military", "MilitaryBuilding") == 1 then
                    local Chance = self:CalculateCriminalCatchChance(_PlayerID, Data[1]);
                    -- Decide if a criminal is catched
                    if math.random(1, 1000) <= Chance then
                        if GUI.GetPlayerID() == _PlayerID then
                            local Language = GetLanguage();
                            Message(self.Config.UI.Msg.CriminalResocialized[Language]);
                        end
                        self:RemoveCriminal(_PlayerID, Data[1]);
                        GameCallback_Logic_CriminalCatched(_PlayerID, Data[1], Data[2]);
                    end
                end
            end
        end

        -- Criminal activity
        -- Moves the criminals between the castle and their workplace
        for i= table.getn(self.Data[_PlayerID].Criminals), 1, -1 do
            local Data = self.Data[_PlayerID].Criminals[i];
            if Data[4] == nil then
                self.Data[_PlayerID].Criminals[i][4] = Stronghold.Players[_PlayerID].DoorPos;
            end
            if GetDistance(Data[1], Data[4]) <= 100 then
                if GetDistance(Data[1], Stronghold.Players[_PlayerID].DoorPos) <= 100 then
                    self.Data[_PlayerID].Criminals[i][4] = Data[3];
                else
                    self.Data[_PlayerID].Criminals[i][4] = nil;
                end
            end
            if Data[4] and Logic.IsEntityMoving(Data[1]) == false then
                local Task = Logic.GetCurrentTaskList(Data[1]);
                if not Task or not string.find(Task, "BATTLE") then
                    Logic.GroupAttackMove(Data[1], Data[4].X, Data[4].Y);
                end
            end
        end
    end
end

function Stronghold.Attraction:AddCriminal(_PlayerID, _BuildingID, _WorkerID)
    local ID = 0;
    if self.Data[_PlayerID] then
        local x,y,z = Logic.EntityGetPos(_BuildingID);
        DestroyEntity(_WorkerID);
        ID = AI.Entity_CreateFormation(_PlayerID, Entities.CU_Thief, nil, 0, x, y, 0, 0, 0, 0);
        x,y,z = Logic.EntityGetPos(ID);
        Logic.SetEntitySelectableFlag(ID, 0);
        Logic.MoveSettler(ID, x, y);
        table.insert(self.Data[_PlayerID].Criminals, {ID, _BuildingID, {X= x, Y= y}, nil});
    end
    return ID;
end

function Stronghold.Attraction:RemoveCriminal(_PlayerID, _EntityID)
    if self.Data[_PlayerID] then
        for i= table.getn(self.Data[_PlayerID].Criminals), 1, -1 do
            if self.Data[_PlayerID].Criminals[i][1] == _EntityID then
                table.remove(self.Data[_PlayerID].Criminals, i);
                DestroyEntity(_EntityID);
                break;
            end
        end
    end
end

function Stronghold.Attraction:DoCriminalsAppear(_PlayerID)
    if self.Data[_PlayerID] then
        return GetRank(_PlayerID) >= 3;
    end
    return false;
end

function Stronghold.Attraction:CalculateCrimeRate(_PlayerID)
    local CrimeRate = 0;
    if self.Data[_PlayerID] then
        local ReputationFactor = GetReputation(_PlayerID) / 100;
        local RankFactor = 1 - ((GetRank(_PlayerID) -1) / 15);
        CrimeRate = self.Config.Criminals.Convert.Rate * ReputationFactor * RankFactor;
        CrimeRate = GameCallback_Calculate_CrimeRate(_PlayerID, CrimeRate);
    end
    return CrimeRate;
end

function Stronghold.Attraction:CalculateCriminalCatchChance(_PlayerID, _ThiefID)
    local Chance = self.Config.Criminals.Catch.Chance;
    local Position = GetPosition(_ThiefID);
    -- The Noble can do it much better
    if self.Data[_PlayerID] then
        if IsNear(_ThiefID, Stronghold.Players[_PlayerID].LordScriptName, self.Config.Criminals.Catch.Area) then
            Chance = Chance +4;
        end
    end
    -- Buildings do it more efficient than just pepole
    if AreEntitiesInArea(_PlayerID, Entities.PB_DarkTower1, Position, self.Config.Criminals.Catch.Area, 1)
    or AreEntitiesInArea(_PlayerID, Entities.PB_Barracks1, Position, self.Config.Criminals.Catch.Area, 1)
    or AreEntitiesInArea(_PlayerID, Entities.PB_Barracks2, Position, self.Config.Criminals.Catch.Area, 1)
    or AreEntitiesInArea(_PlayerID, Entities.PB_Archery1, Position, self.Config.Criminals.Catch.Area, 1)
    or AreEntitiesInArea(_PlayerID, Entities.PB_Archery2, Position, self.Config.Criminals.Catch.Area, 1)
    or AreEntitiesInArea(_PlayerID, Entities.PB_Stable1, Position, self.Config.Criminals.Catch.Area, 1)
    or AreEntitiesInArea(_PlayerID, Entities.PB_Stable2, Position, self.Config.Criminals.Catch.Area, 1)
    or AreEntitiesInArea(_PlayerID, Entities.PB_Tower1, Position, self.Config.Criminals.Catch.Area, 1) then
        Chance = Chance +4;
    end
    -- A organized townguard increases efficiency futher
    if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_TownGuard) == 1 then
        Chance = Chance +4;
    end
    return Chance;
end

function Stronghold.Attraction:CountCriminals(_PlayerID)
    local CriminalCount = 0;
    if self.Data[_PlayerID] then
        CriminalCount = table.getn(self.Data[_PlayerID].Criminals);
    end
    return CriminalCount;
end

function Stronghold.Attraction:GetReputationLossByCriminals(_PlayerID)
    local Loss = 0;
    if self.Data[_PlayerID] then
        local Criminals = self:CountCriminals(_PlayerID);
        Loss = Loss + self.Config.Criminals.Reputation * Criminals;
    end
    return Loss;
end

function Stronghold.Attraction:GetCriminalsOfBuilding(_BuildingID)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Criminals = {};
    if self.Data[PlayerID] then
        for i= table.getn(self.Data[PlayerID].Criminals), 1, -1 do
            if self.Data[PlayerID].Criminals[i][2] == _BuildingID then
                table.insert(Criminals, self.Data[PlayerID].Criminals[i][1]);
            end
        end
    end
    return Criminals;
end

-- -------------------------------------------------------------------------- --
-- Workers

-- Worker Spawner
-- Workers spawn for each building. The workers inside a building can become
-- criminals. Their workplace stays occupied until they brought to justice.
function Stronghold.Attraction:CreateWorkersForPlayer(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        if not Stronghold.Players[_PlayerID].CivilAttractionLocked then
            if Logic.GetPlayerAttractionUsage(_PlayerID) < Logic.GetPlayerAttractionLimit(_PlayerID) then
                -- Get buildings that need workers
                local Buildings = GetAllWorkplaces(_PlayerID);
                for i= table.getn(Buildings), 1, -1 do
                    local Used, Limit = self:GetBuildingCurrentAndMaxWorkerAmount(Buildings[i]);
                    if Logic.IsOvertimeActiveAtBuilding(Buildings[i]) == 1
                    or IsBuildingBeingUpgraded(Buildings[i])
                    or Used == Limit then
                        table.remove(Buildings, i);
                    end
                end
                -- Create 1 worker
                local Index = self.Data[_PlayerID].LastBuildingWorkerCreatedIndex or 1;
                if Buildings[Index] then
                    local Type = Logic.GetWorkerTypeByBuilding(Buildings[Index]);
                    local Used, Limit = self:GetBuildingCurrentAndMaxWorkerAmount(Buildings[Index]);
                    local Criminals = self:GetCriminalsOfBuilding(Buildings[Index]);
                    local Current = math.min(Used +1, Limit - table.getn(Criminals));
                    local AttractionBuilding = self:GetClostestAttractionBuilding(Buildings[Index]);
                    local Position = Stronghold.Unit:GetBarracksDoorPosition(AttractionBuilding);
                    self:SetBuildingCurrentWorkerAmount(Buildings[Index], Current);
                    if Used < Current then
                        Stronghold:AddDelayedAction(1, function(_Type, _X, _Y, _PlayerID)
                            local ID = Logic.CreateEntity(_Type, _X, _Y, 0, _PlayerID);
                            local Reputation = Stronghold:GetPlayerReputation(_PlayerID);
                            CEntity.SetMotivation(ID, Reputation / 100);
                        end, Type, Position.X, Position.Y, _PlayerID);
                    end
                    self.Data[_PlayerID].LastBuildingWorkerCreatedIndex = Index +1;
                else
                    self.Data[_PlayerID].LastBuildingWorkerCreatedIndex = nil;
                end
            end
        end
    end
end

function Stronghold.Attraction:GetClostestAttractionBuilding(_BuildingID)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local BuildingID = 0;
    if Stronghold:IsPlayer(PlayerID) then
        local LastDistance = Logic.WorldGetSize();
        for k, v in pairs(self:GetAttractionBuildings(PlayerID)) do
            local Distance = GetDistance(v, _BuildingID);
            if LastDistance > Distance then
                LastDistance = Distance;
                BuildingID = v;
            end
        end
    end
    return BuildingID;
end

function Stronghold.Attraction:GetAttractionBuildings(_PlayerID)
    local AttractionBuildings = {};
    if Stronghold:IsPlayer(_PlayerID) then
        for k, v in pairs(GetValidEntitiesOfType(_PlayerID, Entities.PB_VillageCenter1)) do
            table.insert(AttractionBuildings, v);
        end
        for k, v in pairs(GetValidEntitiesOfType(_PlayerID, Entities.PB_VillageCenter2)) do
            table.insert(AttractionBuildings, v);
        end
        for k, v in pairs(GetValidEntitiesOfType(_PlayerID, Entities.PB_VillageCenter3)) do
            table.insert(AttractionBuildings, v);
        end
        table.insert(AttractionBuildings, GetID(Stronghold.Players[_PlayerID].HQScriptName));
    end
    return AttractionBuildings;
end

-- Set the current amount of workplaces in the building.
-- (Spread workers evenly over all buildings)
function Stronghold.Attraction:SetBuildingCurrentWorkerAmount(_EntityID, _Max)
    local WorkerMax = Logic.GetMaxNumWorkersInBuilding(_EntityID);
    local WorkerAmount = math.min(WorkerMax, _Max);
    if CNetwork then
        SendEvent.SetCurrentMaxNumWorkersInBuilding(_EntityID, WorkerAmount);
    else
        GUI.SetCurrentMaxNumWorkersInBuilding(_EntityID, WorkerAmount);
    end
end

-- Returns the current worker amount and the current max amount
function Stronghold.Attraction:GetBuildingCurrentAndMaxWorkerAmount(_EntityID)
    local PlacesLimit = 0;
    local PlacesUsed = 0;
    if Logic.IsBuilding(_EntityID) == 1 then
        local Workers = {Logic.GetAttachedWorkersToBuilding(_EntityID)};
        PlacesLimit = Logic.GetBuildingWorkPlaceLimit(_EntityID);
        PlacesUsed = math.max(Logic.GetBuildingWorkPlaceUsage(_EntityID), Workers[1]);
    end
    return PlacesUsed, PlacesLimit;
end

-- -------------------------------------------------------------------------- --
-- Military

function Stronghold.Attraction:GetPlayerMilitaryAttractionLimit(_PlayerID)
    local Limit = 0;
    if Stronghold:IsPlayer(_PlayerID) then
        local HeadquarterID = GetID(Stronghold.Players[_PlayerID].HQScriptName);
        local Rank = GetRank(_PlayerID);

        -- Attraction limit
        Limit = self.Config.HQMilitaryAttraction[1];
        if Logic.GetEntityType(HeadquarterID) == Entities.PB_Headquarters2 then
            Limit = self.Config.HQMilitaryAttraction[2];
        end
        if Logic.GetEntityType(HeadquarterID) == Entities.PB_Headquarters3 then
            Limit = self.Config.HQMilitaryAttraction[3];
        end
        Limit = Limit + (Limit * (Rank * 0.2));
        -- External
        Limit = GameCallback_Calculate_MilitaryAttrationLimit(_PlayerID, Limit);
    end
    return math.ceil(Limit);
end

function Stronghold.Attraction:GetRequiredSpaceForUnitType(_Type, _Amount)
    if self.Config.UsedSpace[_Type] then
        return self.Config.UsedSpace[_Type] * (_Amount or 1);
    end
    return 0;
end

function Stronghold.Attraction:GetPlayerMilitaryAttractionUsage(_PlayerID)
    local Usage = 0;
    if Stronghold:IsPlayer(_PlayerID) then
        Usage = self:GetMillitarySize(_PlayerID);
        -- External
        Usage = GameCallback_Calculate_MilitaryAttrationUsage(_PlayerID, Usage);
    end
    return Usage;
end

function Stronghold.Attraction:HasPlayerSpaceForUnits(_PlayerID, _Amount)
    if Stronghold:IsPlayer(_PlayerID) then
        local Limit = self:GetPlayerMilitaryAttractionLimit(_PlayerID);
        local Usage = self:GetPlayerMilitaryAttractionUsage(_PlayerID);
        return Limit - Usage >= _Amount;
    end
    return false;
end

function Stronghold.Attraction:GetMillitarySize(_PlayerID)
    local Size = 0;
    for k,v in pairs(self.Config.UsedSpace) do
        local UnitList = GetPlayerEntities(_PlayerID, k);
        for i= 1, table.getn(UnitList) do
            -- Get unit size
            local Usage = v;
            if Logic.IsLeader(UnitList[i]) == 1 then
                local Soldiers = {Logic.GetSoldiersAttachedToLeader(UnitList[i])};
                Usage = Usage + (Usage * Soldiers[1]);
            end
            -- External
            Usage = GameCallback_Calculate_UnitPlaces(_PlayerID, UnitList[i], k, Usage);

            Size = Size + Usage;
        end
    end
    return Size;
end

-- -------------------------------------------------------------------------- --
-- Criminal activity

-- Criminals steal resources. The losses are discovered on payday (because I am
-- very lazy and do not want to programm an extra job for it). Each criminal
-- will also have effect on the reputation.
function Stronghold.Attraction:InitCriminalsEffects()
    -- Criminals steal goods at the payday.
    Overwrite.CreateOverwrite("GameCallback_Logic_Payday", function(_PlayerID)
        Overwrite.CallOriginal();
        Stronghold.Attraction:StealGoodsOnPayday(_PlayerID);
    end);

    -- Criminals will have a negative effect on the reputation.
    Overwrite.CreateOverwrite("GameCallback_Calculate_ReputationDecreaseExternal", function(_PlayerID)
        local Amount = Overwrite.CallOriginal();
        local Criminals = Stronghold.Attraction:GetReputationLossByCriminals(_PlayerID);
        return Amount + Criminals;
    end);
end

function Stronghold.Attraction:StealGoodsOnPayday(_PlayerID)
    local TotalAmount = 0;
    local ResourcesToSub = {};
    local ResourcesToSteal = {"Gold", "Wood", "Clay", "Stone", "Iron", "Sulfur"};
    local Criminals = self:CountCriminals(_PlayerID);

    if Criminals > 0 then
        for i= 1, Criminals do
            local Type = ResourceType[ResourcesToSteal[math.random(1, 6)]];
            local Amount = math.random(self.Config.Criminals.Steal.Min, self.Config.Criminals.Steal.Max);
            ResourcesToSub[Type] = (ResourcesToSub[Type] or 0) + Amount;
            TotalAmount = TotalAmount + Amount;
        end
        if TotalAmount > 0 and GUI.GetPlayerID() == _PlayerID then
            local Language = GetLanguage();
            local Text = self.Config.UI.Msg.CriminalsStoleResources[Language];
            Message(string.format(Text, TotalAmount));
        end
        RemoveResourcesFromPlayer(_PlayerID, ResourcesToSub);
    end
end

-- -------------------------------------------------------------------------- --
-- Attraction

-- Overwrite attraction
-- The attraction limit is based on the headquarters. To make my life easier
-- I just overwrite the logics.
function Stronghold.Attraction:OverrideAttraction()
    self.Orig_GetPlayerAttractionLimit = Logic.GetPlayerAttractionLimit;
	Logic.GetPlayerAttractionLimit = function(_PlayerID)
		local Limit = 0;
        if not Stronghold:IsPlayer(_PlayerID) then
            return Stronghold.Attraction.Orig_GetPlayerAttractionLimit(_PlayerID);
        end

        -- HQ limit
        local HeadquarterID = GetID(Stronghold.Players[_PlayerID].HQScriptName);
        local HQLimit = Stronghold.Attraction.Config.HQCivilAttraction[1];
        if Logic.GetEntityType(HeadquarterID) == Entities.PB_Headquarters2 then
            HQLimit = Stronghold.Attraction.Config.HQCivilAttraction[2];
        end
        if Logic.GetEntityType(HeadquarterID) == Entities.PB_Headquarters3 then
            HQLimit = Stronghold.Attraction.Config.HQCivilAttraction[3];
        end
        Limit = Limit + HQLimit;
        -- VC limit
        local VCLimit = 0;
        local VCLevel1 = GetValidEntitiesOfType(_PlayerID, Entities.PB_VillageCenter1);
        VCLimit = VCLimit + (table.getn(VCLevel1) * Stronghold.Attraction.Config.VCCivilAttraction[1]);
        local VCLevel2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_VillageCenter2);
        VCLimit = VCLimit + (VCLevel2 * Stronghold.Attraction.Config.VCCivilAttraction[2]);
        local VCLevel3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_VillageCenter3);
        VCLimit = VCLimit + (VCLevel3 * Stronghold.Attraction.Config.VCCivilAttraction[3]);
        Limit = Limit + VCLimit;
        -- External
        Limit = GameCallback_Calculate_CivilAttrationLimit(_PlayerID, Limit);

        return math.floor(Limit + 0.5);
	end

	self.Orig_GetPlayerAttractionUsage = Logic.GetPlayerAttractionUsage;
	Logic.GetPlayerAttractionUsage = function(_PlayerID)
        local Usage = 0;
		if not Stronghold:IsPlayer(_PlayerID) then
            return Stronghold.Attraction.Orig_GetPlayerAttractionUsage(_PlayerID);
        end
        local WorkerCount = Logic.GetNumberOfAttractedWorker(_PlayerID);
        local SerfCount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Serf);
        local BattleSerfCount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_BattleSerf);
        local ScoutCount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Scout);
        local ThiefCount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Thief);
        local Criminals = Stronghold.Attraction:CountCriminals(_PlayerID);
        Usage = WorkerCount + Criminals +
                (BattleSerfCount * Stronghold.UnitConfig:GetConfig(Entities.PU_Serf, _PlayerID).Places) +
                (SerfCount * Stronghold.UnitConfig:GetConfig(Entities.PU_Serf, _PlayerID).Places) +
                (ScoutCount * Stronghold.UnitConfig:GetConfig(Entities.PU_Scout, _PlayerID).Places) +
                (ThiefCount * Stronghold.UnitConfig:GetConfig(Entities.PU_Thief, _PlayerID).Places);

        -- External
        Usage = GameCallback_Calculate_CivilAttrationUsage(_PlayerID, Usage);

        return math.floor(Usage + 0.5);
	end
end

