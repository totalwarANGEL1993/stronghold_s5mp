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
    Data = {},
    Config = {},
    Text = {},
};

-- -------------------------------------------------------------------------- --
-- API

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
--- @param _PlayerID integer ID of player
--- @param _Type integer Type of unit
--- @param _Amount integer amount of units
--- @return integer Amount Places used
function GetMilitaryPlacesUsedByUnit(_PlayerID, _Type, _Amount)
    return Stronghold.Attraction:GetRequiredSpaceForUnitType(_PlayerID, _Type, _Amount);
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
function GameCallback_SH_Calculate_SingleUnitPlaces(_PlayerID, _EntityID, _Type, _Usage)
    return _Usage;
end

-- -------------------------------------------------------------------------- --
-- Main

function Stronghold.Attraction:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            VirtualSettlers = 0,
        };
    end

    self:InitLogicOverride();
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

function Stronghold.Attraction:OnEveryTurn(_PlayerID)
    -- Update attraction
    self:UpdatePlayerAttractionUsage(_PlayerID);
    -- Worker limit
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local Limit, RawLimit = self:GetVirtualPlayerAttractionLimit(_PlayerID);
        CLogic.SetAttractionLimitOffset(_PlayerID, math.max(math.ceil(Limit - RawLimit), 0));
    end
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
        return math.ceil(Limit);
    end

    self.Orig_Logic_GetPlayerAttractionUsage = Logic.GetPlayerAttractionUsage;
    --- @diagnostic disable-next-line: duplicate-set-field
    Logic.GetPlayerAttractionUsage = function(_PlayerID)
        local Usage = Stronghold.Attraction.Orig_Logic_GetPlayerAttractionUsage(_PlayerID);
        if Stronghold.Attraction.Data[_PlayerID] then
            Usage = math.max(Usage - Stronghold.Attraction.Data[_PlayerID].VirtualSettlers, 0);
        end
        return math.floor(Usage);
    end
end

-- -------------------------------------------------------------------------- --
-- Workers

GameCallback_GetPlayerAttractionLimitForSpawningWorker = function(_PlayerID, _Amount)
    return Logic.GetPlayerAttractionLimit(_PlayerID);
end

GameCallback_GetPlayerAttractionUsageForSpawningWorker = function(_PlayerID, _Amount)
    if GetReputation(_PlayerID) > 30 then
        return Logic.GetPlayerAttractionUsage(_PlayerID);
    end
    return 0;
end

GameCallback_BuyEntityAttractionLimitCheck = function(_PlayerID, _CanSpawn)
    local BuyEvent = CEntity.GetEventData(1);
    if BuyEvent.event == CEntity.Events.BUY_SERF then
        if not HasPlayerSpaceForSlave(_PlayerID) then
            return false;
        end
    end
    if BuyEvent.event == CEntity.Events.BUY_LEADER then
        local _, EntityType = Logic.GetSettlerTypesInUpgradeCategory(BuyEvent.upgradeCategory);
        local Places = GetMilitaryPlacesUsedByUnit(_PlayerID, EntityType, 1);
        if not HasPlayerSpaceForUnits(_PlayerID, Places) then
            return false;
        end
    end
    if BuyEvent.event == CEntity.Events.BUY_SOLDIER then
        local LeaderType = Logic.GetEntityType(BuyEvent.leaderID);
        local Places = GetMilitaryPlacesUsedByUnit(_PlayerID, LeaderType, 1);
        if not HasPlayerSpaceForUnits(_PlayerID, Places) then
            -- local Costs = GetSoldierCostsByLeaderType(_PlayerID, LeaderType, 1);
            -- AddResourcesToPlayer(_PlayerID, Costs);
            return false;
        end
    end
    return true;
end

function Stronghold.Attraction:UpdateMotivationOfPlayersWorkers(_PlayerID, _Amount, _Silent)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        -- Update Motivation of workers
        local WorkerList = GetWorkersOfType(_PlayerID, 0);
        local WorkerLeaves = false;
        for i= 2, WorkerList[1] +1 do
            local WorkplaceID = Logic.GetSettlersWorkBuilding(WorkerList[i]);
            if  (WorkplaceID ~= nil and WorkplaceID ~= 0)
            and Logic.IsOvertimeActiveAtBuilding(WorkplaceID) == 0
            and Logic.IsAlarmModeActive(WorkplaceID) ~= true then
                local OldMoti = Logic.GetSettlersMotivation(WorkerList[i]);
                local NewMoti = math.floor((OldMoti * 100) + 0.5) + (_Amount or 0);
                NewMoti = math.min(NewMoti, GetMaxReputation(_PlayerID));
                NewMoti = math.min(NewMoti, GetReputation(_PlayerID));
                NewMoti = math.max(NewMoti, 0);
                if NewMoti <= 25 then
                    WorkerLeaves = true;
                end
                CEntity.SetMotivation(WorkerList[i], NewMoti / 100);
            end
        end
        -- Print worker leave message
        if WorkerLeaves and not _Silent then
            Message(XGUIEng.GetStringTableText("sh_text/UI_WorkerLeave"));
            Sound.PlayFeedbackSound(Sounds.VoicesMentor_LEAVE_Settler, 127);
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
        if Stronghold.Player.Config.DefeatModes.Annihilation
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
    return math.ceil(Limit);
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
    return math.floor(Usage);
end

function Stronghold.Attraction:HasPlayerSpaceForSlave(_PlayerID)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local CivilLimit = Logic.GetPlayerAttractionLimit(_PlayerID)
        local CivilUsage = Logic.GetPlayerAttractionUsage(_PlayerID)
        local SlaveLimit = self:GetPlayerSlaveAttractionLimit(_PlayerID);
        local SlaveUsage = self:GetPlayerSlaveAttractionUsage(_PlayerID);
        return CivilLimit - CivilUsage >= 1 and SlaveLimit - SlaveUsage >= 1;
    end
    return true;
end

-- -------------------------------------------------------------------------- --
-- Military

function Stronghold.Attraction:GetPlayerMilitaryAttractionLimit(_PlayerID)
    local Limit = 0;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        if not Stronghold.Player.Config.DefeatModes.Conservative
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
    return math.ceil(Limit);
end

function Stronghold.Attraction:GetRequiredSpaceForUnitType(_PlayerID, _Type, _Amount)
    if self.Config.UsedSpace[_Type] then
        local SpaceUsed = self.Config.UsedSpace[_Type];
        -- Apply unit places hero ability
        SpaceUsed = Stronghold.Hero.Perk:ApplyUnitTypeAttractionPassiveAbility(_PlayerID, _Type, SpaceUsed);
        return math.ceil(SpaceUsed * (_Amount or 1));
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
    return math.floor(Usage);
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
    for Type, Places in pairs(self.Config.UsedSpace) do
        local Config = Stronghold.Unit.Config.Troops:GetConfig(Type, _PlayerID);
        if not Config or Config.IsCivil ~= true then
            Places = self.Config.UsedSpace[Type] or 0;
            local UnitList = GetLeadersOfType(_PlayerID, Type);
            for i= 2, UnitList[1] +1 do
                local Usage = Places;
                if Logic.IsLeader(UnitList[i]) == 1 then
                    local Soldiers = {Logic.GetSoldiersAttachedToLeader(UnitList[i])};
                    Usage = Usage + (Places * Soldiers[1]);
                end
                Usage = GameCallback_SH_Calculate_SingleUnitPlaces(_PlayerID, UnitList[i], Type, Usage);
                Size = Size + Usage;
            end
        end
    end
    return Size;
end

