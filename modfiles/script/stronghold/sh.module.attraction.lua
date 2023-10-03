---
--- Attraction Script
---
--- This script manages the attraction of settlers for the players.
---
--- Attraction limit is split in two. The player has a civil and a military
--- limit. Civil units are all workers and military is the rest.
---
--- Defined game callbacks:
--- - <number> GameCallback_SH_Calculate_CivilAttrationLimit(_PlayerID, _Amount)
---   Allows to overwrite the max usage of civil places.
---
--- - <number> GameCallback_SH_Calculate_CivilAttrationUsage(_PlayerID, _Amount)
---   Allows to overwrite the current overall usage of civil places.
---
--- - <number> GameCallback_SH_Calculate_MilitaryAttrationLimit(_PlayerID, _Amount)
---   Allows to overwrite the max usage of military places.
---
--- - <number> GameCallback_SH_Calculate_MilitaryAttrationUsage(_PlayerID, _Amount)
---   Allows to overwrite the current overall usage of military places.
---
--- - <number> GameCallback_SH_Calculate_SlaveAttrationLimit(_PlayerID, _Amount)
---   Allows to overwrite the max usage of serf places.
---
--- - <number> GameCallback_SH_Calculate_SlaveAttrationUsage(_PlayerID, _Amount)
---   Allows to overwrite the current overall usage of serf places.
---
--- - <number> GameCallback_SH_Calculate_UnitPlaces(_PlayerID, _EntityID, _Type, _Places)
---   Allows to overwrite the places a unit is occupying.
--- 
--- - <number> GameCallback_SH_Calculate_CrimeRate(_PlayerID, _Rate)
---   Allows to overwrite the crime rate.
---
--- - <number> GameCallback_SH_Logic_CriminalAppeared(_PlayerID, _EntityID, _BuildingID)
---   Allows to overwrite the crime chance.
---
--- - <number> GameCallback_SH_Logic_CriminalCatched(_PlayerID, _OldEntityID, _BuildingID)
---   Allows to overwrite the crime chance.
---

Stronghold = Stronghold or {};

Stronghold.Attraction = {
    Data = {},
    Config = {},
    Text = {},
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

function GetSlaveAttractionLimit(_PlayerID)
    return Stronghold.Attraction:GetPlayerSlaveAttractionLimit(_PlayerID);
end

function GetSlaveAttractionUsage(_PlayerID)
    return Stronghold.Attraction:GetPlayerSlaveAttractionUsage(_PlayerID);
end

function GetMilitaryPlacesUsedByUnit(_Type, _Amount)
    return Stronghold.Attraction:GetRequiredSpaceForUnitType(_Type, _Amount);
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
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            LastAttempt = 0,
            VirtualSettlers = 0,
            Criminals = {},
        };
    end

    self:InitCriminalsEffects();
    self:InitLogicOverride();
end

function Stronghold.Attraction:OnSaveGameLoaded()
    self:InitLogicOverride();
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

function GameCallback_SH_Calculate_MilitaryAttrationLimit(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_CivilAttrationLimit(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_SlaveAttrationLimit(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_MilitaryAttrationUsage(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_CivilAttrationUsage(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_SlaveAttrationUsage(_PlayerID, _Amount)
    return _Amount;
end

function GameCallback_SH_Calculate_UnitPlaces(_PlayerID, _EntityID, _Type, _Usage)
    return _Usage;
end

function GameCallback_SH_Calculate_CrimeRate(_PlayerID, _Rate)
    return _Rate;
end

function GameCallback_SH_Logic_CriminalAppeared(_PlayerID, _EntityID, _BuildingID)
end

function GameCallback_SH_Logic_CriminalCatched(_PlayerID, _OldEntityID, _BuildingID)
end

-- -------------------------------------------------------------------------- --
-- Criminals

-- Criminals steal resources. The losses are discovered on payday (because I am
-- very lazy and do not want to programm an extra job for it). Each criminal
-- will also have effect on the reputation.
function Stronghold.Attraction:InitCriminalsEffects()
    -- Criminals steal goods at the payday.
    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_Payday", function(_PlayerID, _Amount)
        local Amount = Overwrite.CallOriginal();
        Stronghold.Attraction:StealGoodsOnPayday(_PlayerID);
        return Amount;
    end);
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
            local LastAttemptTime = self.Data[_PlayerID].LastAttempt;
            local TimeBetween = self.Config.Crime.Convert.TimeBetween;
            if LastAttemptTime + TimeBetween < Logic.GetTime() then
                local WorkerList = self:GetPotentialCriminalSettlers(_PlayerID);
                local WorkerCount = table.getn(WorkerList);
                if WorkerCount > 0 then
                    local Selected = WorkerList[math.random(1, WorkerCount)];
                    self:AddCriminal(_PlayerID, Selected[2], Selected[1]);
                end
                self.Data[_PlayerID].LastAttempt = Logic.GetTime();
            end
        end

        -- Catch criminals
        -- Criminals will be cathed if they are exposed long enough. If their
        -- camouflage is blown they will be caught.
        for i= table.getn(self.Data[_PlayerID].Criminals), 1, -1 do
            local Data = self.Data[_PlayerID].Criminals[i];
            if not IsExisting(Data[1]) or not IsExisting(Data[2]) then
                self:RemoveCriminal(_PlayerID, Data[1]);
            else
                local MaxVeil = self.Config.Crime.Unveil.Points;
                local Exposition = self:GetSettlersExposition(_PlayerID, Data[1]);
                if Exposition == 0 then
                    self.Data[_PlayerID].Criminals[i][5] = math.min(Data[5] + 1, MaxVeil);
                else
                    self.Data[_PlayerID].Criminals[i][5] = math.max(Data[5] - Exposition, 0);
                end
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
            self.Data[_PlayerID].Criminals[i][4] = Data[4] or Stronghold.Players[_PlayerID].DoorPos;
            if GetDistance(Data[1], Data[4]) <= 100 then
                self.Data[_PlayerID].Criminals[i][4] = nil;
                if GetDistance(Data[1], Stronghold.Players[_PlayerID].DoorPos) <= 100 then
                    self.Data[_PlayerID].Criminals[i][4] = Data[3];
                end
            end
            local Task = Logic.GetCurrentTaskList(Data[1]);
            if  Data[4] and Logic.IsEntityMoving(Data[1]) == false
            and not IsFighting(Data[1]) then
                Logic.GroupAttackMove(Data[1], Data[4].X, Data[4].Y);
            end
        end
    end
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
        local Points = self.Config.Crime.Unveil.Points;
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
                -- Delete thief
                table.remove(self.Data[_PlayerID].Criminals, i);
                DestroyEntity(_EntityID);
                -- Show message
                if GuiPlayer == _PlayerID and GuiPlayer ~= 17 then
                    Message(XGUIEng.GetStringTableText("sh_text/Player_CriminalResocialized"));
                end
                -- Invoke callback
                GameCallback_SH_Logic_CriminalCatched(_PlayerID, Data[1], Data[2]);
                break;
            end
        end
    end
end

function Stronghold.Attraction:DoCriminalsAppear(_PlayerID)
    return GetRank(_PlayerID) >= 3;
end

-- Decides if a worker turns criminal.
-- Becoming criminal is chance based and directly tied to the individual
-- happyness of the settler. The presence or absence of "the law" also
-- influences the chance. The cance can never drop below 0.1% per second
-- and never rise about 10% per second.
function Stronghold.Attraction:DoesSettlerTurnCriminal(_PlayerID, _WorkerID)
    if IsPlayerInitalized(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Motivation = Logic.GetSettlersMotivation(_WorkerID);
        local CrimeRate = GameCallback_SH_Calculate_CrimeRate(_PlayerID, self.Config.Crime.Convert.Rate);
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
    local WorkerList = {};
    for k, v in pairs(Stronghold:GetWorkplacesOfType(_PlayerID, 0, true)) do
        local Type = Logic.GetEntityType(v);
        if Type ~= Entities.PB_Foundry1 and Type ~= Entities.PB_Foundry2 then
            local WorkerOfBuilding = {Logic.GetAttachedWorkersToBuilding(v)};
            for i= 2, WorkerOfBuilding[1] +1 do
                if self:DoesSettlerTurnCriminal(_PlayerID, WorkerOfBuilding[i]) then
                    table.insert(WorkerList, {WorkerOfBuilding[i], v});
                end
            end
        end
    end
    return WorkerList;
end

-- Returns how much a settler is watched by "the law".
-- Beeing watched lowers the chance to become criminal and also increases the
-- chance to catches those who already broke the law.
function Stronghold.Attraction:GetSettlersExposition(_PlayerID, _CriminalID)
    local Exposition = 0;
    if IsPlayerInitalized(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local x,y,z = Logic.EntityGetPos(_CriminalID);
        -- Check militia
        local _, MilitiaID = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PU_BattleSerf, x, y, self.Config.Crime.Unveil.SerfArea, 1);
        if MilitiaID then
            Exposition = Exposition + (1 * self.Config.Crime.Unveil.SerfRate);
        end
        -- Check watchtowers
        local _, DarkTowerID = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_DarkTower1, x, y, self.Config.Crime.Unveil.TowerArea, 1);
        local _, TowerID = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.PB_Tower1, x, y, self.Config.Crime.Unveil.TowerArea, 1);
        if (DarkTowerID and Logic.IsConstructionComplete(DarkTowerID) == 1)
        or (TowerID and Logic.IsConstructionComplete(TowerID) == 1) then
            Exposition = Exposition + (1 * self.Config.Crime.Unveil.TowerRate);
        end
        -- Check town guard
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_ReportingOffice) == 1 then
            Exposition = Exposition * self.Config.Crime.Unveil.TownGuardFactor;
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

function Stronghold.Attraction:GetReputationLossByCriminals(_PlayerID)
    local Loss = 0;
    if self.Data[_PlayerID] then
        local Criminals = self:CountCriminals(_PlayerID);
        local Damage = self.Config.Crime.Effects.ReputationDamage;
        Loss = Loss + (Damage + GetRank(_PlayerID)) * Criminals;
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

function Stronghold.Attraction:UpdateMotivationOfPlayersWorkers(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        -- Update Motivation of workers
        for k,v in pairs(Stronghold:GetWorkersOfType(_PlayerID, 0)) do
            local WorkplaceID = Logic.GetSettlersWorkBuilding(v);
            if  (WorkplaceID ~= nil and WorkplaceID ~= 0)
            and Logic.IsOvertimeActiveAtBuilding(WorkplaceID) == 0
            and Logic.IsAlarmModeActive(WorkplaceID) ~= true then
                local OldMoti = Logic.GetSettlersMotivation(v);
                local NewMoti = math.floor((OldMoti * 100) + 0.5) + _Amount;
                NewMoti = math.min(NewMoti, GetMaxReputation(_PlayerID));
                NewMoti = math.min(NewMoti, GetReputation(_PlayerID));
                NewMoti = math.max(NewMoti, 20);
                CEntity.SetMotivation(v, NewMoti / 100);
            end
        end
        -- Restore reputation when workers are all gone
        -- (Must be done so that they don't leave immedaitly when they return.)
        if GetReputation(_PlayerID) <= 25 and Logic.GetNumberOfAttractedWorker(_PlayerID) == 0 then
            Stronghold:SetPlayerReputation(_PlayerID, 50);
            return;
        end
    end
end

function Stronghold.Attraction:UpdatePlayerCivilAttractionLimit(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Limit = 0;
        local RawLimit = 0;
        -- Village Centers
        local VC1 = table.getn(Stronghold:GetBuildingsOfType(_PlayerID, Entities.PB_VillageCenter1, true));
        RawLimit = RawLimit + (VC1 * self.Config.Attraction.VCCivil[1]);
        local VC2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_VillageCenter2);
        RawLimit = RawLimit + (VC2 * self.Config.Attraction.VCCivil[2]);
        local VC3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_VillageCenter3);
        RawLimit = RawLimit + (VC3 * self.Config.Attraction.VCCivil[3]);
        -- Headquarters
        local HQ1 = table.getn(Stronghold:GetBuildingsOfType(_PlayerID, Entities.PB_Headquarters1, true));
        RawLimit = RawLimit + (HQ1 * self.Config.Attraction.HQCivil[1]);
        local HQ2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Headquarters2);
        RawLimit = RawLimit + (HQ2 * self.Config.Attraction.HQCivil[2]);
        local HQ3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Headquarters3);
        RawLimit = RawLimit + (HQ3 * self.Config.Attraction.HQCivil[3]);
        -- External
        Limit = GameCallback_SH_Calculate_CivilAttrationLimit(_PlayerID, RawLimit);
        -- Virtual settlers
        Limit = Limit + self.Data[_PlayerID].VirtualSettlers;

        CLogic.SetAttractionLimitOffset(_PlayerID, math.max(math.ceil(Limit - RawLimit), 0));
    end
end

-- -------------------------------------------------------------------------- --
-- Serfs

function Stronghold.Attraction:GetPlayerSlaveAttractionLimit(_PlayerID)
    local Limit = 0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local RawLimit = self.Config.Attraction.SlaveLimit;
        -- Rank
        local Rank = GetRank(_PlayerID);
        if Rank > 0 then
            RawLimit = RawLimit + (Rank * self.Config.Attraction.RankSlaveBonus);
        end

        -- External
        Limit = GameCallback_SH_Calculate_SlaveAttrationLimit(_PlayerID, RawLimit);
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
        local Limit = self:GetPlayerSlaveAttractionLimit(_PlayerID);
        local Usage = self:GetPlayerSlaveAttractionUsage(_PlayerID);
        return Limit - Usage >= 1;
    end
    return true;
end

-- -------------------------------------------------------------------------- --
-- Virtual Settlers

function Stronghold.Attraction:UpdatePlayerCivilAttractionUsage(_PlayerID)
    if IsPlayerInitalized(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local RealUsage = Stronghold.Attraction.Orig_Logic_GetPlayerAttractionUsage(_PlayerID);
        local Usage = RealUsage;
        -- Technology effect
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_ForeignSpecialists) == 1 then
            Usage = Usage * self.Config.ForeignSpecialists.AttractionFactor;
        end
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
        local Limit = Stronghold.Attraction.Orig_Logic_GetPlayerAttractionLimit(_PlayerID);
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
-- Military

function Stronghold.Attraction:GetPlayerMilitaryAttractionLimit(_PlayerID)
    local Limit = 0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        if IsEntityValid(Stronghold:GetPlayerHero(_PlayerID)) then
            -- Headquarters
            local HQ1 = table.getn(Stronghold:GetBuildingsOfType(_PlayerID, Entities.PB_Headquarters1, true));
            Limit = Limit + (HQ1 * self.Config.Attraction.HQMilitary[1]);
            local HQ2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Headquarters2);
            Limit = Limit + (HQ2 * self.Config.Attraction.HQMilitary[2]);
            local HQ3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Headquarters3);
            Limit = Limit + (HQ3 * self.Config.Attraction.HQMilitary[3]);
            -- Barracks
            local BB1 = table.getn(Stronghold:GetBuildingsOfType(_PlayerID, Entities.PB_Barracks1, true));
            Limit = Limit + (BB1 * self.Config.Attraction.BBMilitary[1]);
            local BB2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Barracks2);
            Limit = Limit + (BB2 * self.Config.Attraction.BBMilitary[2]);
            -- Archery
            local AR1 = table.getn(Stronghold:GetBuildingsOfType(_PlayerID, Entities.PB_Archery1, true));
            Limit = Limit + (AR1 * self.Config.Attraction.BBMilitary[1]);
            local AR2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Archery2);
            Limit = Limit + (AR2 * self.Config.Attraction.BBMilitary[2]);
            -- Stables
            local ST1 = table.getn(Stronghold:GetBuildingsOfType(_PlayerID, Entities.PB_Stable1, true));
            Limit = Limit + (ST1 * self.Config.Attraction.BBMilitary[1]);
            local ST2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Stable2);
            Limit = Limit + (ST2 * self.Config.Attraction.BBMilitary[2]);

            -- External
            Limit = GameCallback_SH_Calculate_MilitaryAttrationLimit(_PlayerID, Limit);
        end
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
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        Usage = self:GetMillitarySize(_PlayerID);
        -- Technology effect
        if Logic.IsTechnologyResearched(_PlayerID, Technologies.T_ReserveForces) == 1 then
            Usage = Usage * self.Config.ReserveUnits.AttractionFactor;
        end
        -- External
        Usage = GameCallback_SH_Calculate_MilitaryAttrationUsage(_PlayerID, Usage);
    end
    return math.floor(Usage + 0.5);
end

function Stronghold.Attraction:HasPlayerSpaceForUnits(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Limit = self:GetPlayerMilitaryAttractionLimit(_PlayerID);
        local Usage = self:GetPlayerMilitaryAttractionUsage(_PlayerID);
        return Limit - Usage >= _Amount;
    end
    return true;
end

function Stronghold.Attraction:GetMillitarySize(_PlayerID)
    local Size = 0;
    for k,v in pairs(self.Config.UsedSpace) do
        local Config = Stronghold.Unit.Config:Get(k, _PlayerID);
        if not Config or Config.IsCivil ~= true then
            local UnitList = Stronghold:GetLeadersOfType(_PlayerID, k);
            for i= 1, table.getn(UnitList) do
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

