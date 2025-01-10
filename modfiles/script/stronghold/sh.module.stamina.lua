---
--- Stamina
---

Stronghold = Stronghold or {};

Stronghold.Stamina = {
    Data = {
        Endurance = {},
        Marching = {},
    },
    Config = {},
};

-- -------------------------------------------------------------------------- --
-- API



-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Stamina:Install()
    for PlayerID = 1, GetMaxAmountOfPlayer() do
        self.Data.Endurance[PlayerID] = {};
        self.Data.Marching[PlayerID] = {Global = false};
    end

    self:OverwriteArmyWalkingSpeed();
    self:CreateNetworkHandlers();
end

function Stronghold.Stamina:OnSaveGameLoaded()
end

function Stronghold.Stamina:OnEntityCreated(_EntityID)
    self:SetUnitStaminaOnCreate(_EntityID);
end

function Stronghold.Stamina:OnEntityDestroyed(_EntityID)
    self:SetUnitStaminaOnDestroy(_EntityID);
end

function Stronghold.Stamina:OncePerSecond(_PlayerID)
    self:UpdateUnitStamina(_PlayerID);
end

function Stronghold.Stamina:OnUnknownTask(_EntityID)
    local AdvanceType;
    AdvanceType = self:OnUnknownTaskForMilitaryUnit(_EntityID);
    if AdvanceType ~= nil then
        return AdvanceType;
    end
end

function Stronghold.Stamina:CreateNetworkHandlers()
    self.SyncEvents = {
        SetGlobalPace = 1,
        SetPace = 2,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Stamina.SyncEvents.SetGlobalPace then
                self:SetGlobalUnitMarchingFlag(arg[1], arg[2]);
            end
            if _Action == Stronghold.Stamina.SyncEvents.SetPace then
                self:SetUnitMarchingFlag(arg[1], arg[2]);
            end
        end
    );
end

-- -------------------------------------------------------------------------- --
-- Walking Pace

function Stronghold.Stamina:OnUnknownTaskForMilitaryUnit(_EntityID)
    -- Control running/walking (Leader)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Leader) == 1
    or Logic.IsEntityInCategory(_EntityID, EntityCategories.Hero) == 1
    or Logic.IsEntityInCategory(_EntityID, EntityCategories.Serf) == 1 then
        if IsValidEntity(_EntityID) then
            local TaskList = Logic.GetCurrentTaskList(_EntityID);
            local Command = Logic.LeaderGetCurrentCommand(_EntityID);
            local Factor = self.Config.Movement.RegularSpeedFactor;
            local ShouldRun = self:IsUnitSupposedToRun(_EntityID);

            -- Change speed
            if ShouldRun then
                Factor = self.Config.Movement.AttackSpeedFactor;
            end
            if Logic.IsLeader(_EntityID) == 1 then
                local Soldiers = {Logic.GetSoldiersAttachedToLeader(_EntityID)};
                for i= 2, Soldiers[1] +1 do
                    if IsValidEntity(Soldiers[i]) then
                        Logic.SetSpeedFactor(Soldiers[i], Factor);
                    end
                end
            end
            Logic.SetSpeedFactor(_EntityID, Factor);

            -- Change tasklists
            if ShouldRun then
                if string.find(TaskList, "WALK") or string.find(TaskList, "START_BATTLE") then
                    local RunTask = self.Config.Movement.WalkToRun[TaskList] or TaskList;
                    local WalkTask = self.Config.Movement.RunToWalk[TaskList] or TaskList;
                    if RunTask or WalkTask then
                        if Command == 0 or Command == 3 or Command == 5 or Command == 6 or Command == 8 then
                            if TaskList == WalkTask then
                                Logic.SetTaskList(_EntityID, TaskLists[RunTask]);
                                return TaskAdvancementType.NextTick;
                            end
                            if TaskList == RunTask then
                                Logic.SetTaskList(_EntityID, TaskLists[WalkTask]);
                                return TaskAdvancementType.NextTick;
                            end
                        end
                    end
                end
            end
            return TaskAdvancementType.Immediately;
        end
    end
    -- Control running/walking (Soldier)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Soldier) == 1 then
        if IsValidEntity(_EntityID) then
            local TaskList = Logic.GetCurrentTaskList(_EntityID);
            local LeaderID = SVLib.GetLeaderOfSoldier(_EntityID);
            local ShouldRun = self:IsUnitSupposedToRun(LeaderID);
            if TaskList == "TL_FORMATION" then
                if ShouldRun then
                    Logic.SetTaskList(_EntityID, TaskLists.TL_FORMATION_BATTLE);
                    return TaskAdvancementType.NextTick;
                end
                return TaskAdvancementType.Immediately;
            elseif TaskList == "TL_FORMATION_BATTLE" then
                if ShouldRun then
                    Logic.SetTaskList(_EntityID, TaskLists.TL_FORMATION);
                    return TaskAdvancementType.NextTick;
                end
                return TaskAdvancementType.Immediately;
            end
        end
    end
end

function Stronghold.Stamina:SetGlobalUnitMarchingFlag(_PlayerID, _Flag)
    if _PlayerID == 17 then
        return;
    end
    self.Data.Marching[_PlayerID].Global = _Flag == true;
end

function Stronghold.Stamina:SetUnitMarchingFlag(_EntityID, _Flag)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if PlayerID == 0 or PlayerID == 17 then
        return;
    end
    self.Data.Marching[PlayerID][_EntityID] = _Flag == true;
end

function Stronghold.Stamina:IsUnitSupposedToRun(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if PlayerID == 0 or PlayerID > 16 then
        return true;
    end
    local TaskList = Logic.GetCurrentTaskList(_EntityID);
    local Command = Logic.LeaderGetCurrentCommand(_EntityID);

    -- Run always when performing these tasks
    if TaskList == "TL_START_BATTLE" or
       TaskList == "TL_SERF_GO_TO_CONSTRUCTION_SITE" or
       TaskList == "TL_SERF_GO_TO_RESOURCE" or
       TaskList == "TL_SERF_GO_TO_TREE" then
        return true;
    end
    -- Check switches and commands
    if self.Data.Marching[PlayerID].Global
    or self.Data.Marching[PlayerID][_EntityID] then
        return (Command == 0 or Command == 3 or Command == 5) or
               IsFighting(_EntityID);
    end
    return (Command == 0 or Command == 3 or Command == 5 or
            Command == 6 or Command == 8) or
           IsFighting(_EntityID);
end

function Stronghold.Stamina:OverwriteArmyWalkingSpeed()
    if AiArmy then
        self.Orig_GetNormalizedSpeedFactors = AiArmy.Internal.Army.GetNormalizedSpeedFactors;
        --- @diagnostic disable-next-line: duplicate-set-field
        AiArmy.Internal.Army.GetNormalizedSpeedFactors = function(this)
            local Factors = Stronghold.Stamina.Orig_GetNormalizedSpeedFactors(this);
            for EntityID, Factor in pairs(Factors) do
                local AdjustmentFactor = self.Config.Movement.RegularSpeedFactor;
                if Stronghold.Stamina:IsUnitSupposedToRun(EntityID) then
                    AdjustmentFactor = self.Config.Movement.AttackSpeedFactor;
                end
                Factors[EntityID] = Factor * AdjustmentFactor;
            end
            return Factors;
        end

        self.Orig_GetResetSpeedFactors = AiArmy.Internal.Army.GetResetSpeedFactors;
        --- @diagnostic disable-next-line: duplicate-set-field
        AiArmy.Internal.Army.GetResetSpeedFactors = function(this)
            local Factors = Stronghold.Stamina.Orig_GetResetSpeedFactors(this);
            for EntityID, Factor in pairs(Factors) do
                local AdjustmentFactor = self.Config.Movement.RegularSpeedFactor;
                if Stronghold.Stamina:IsUnitSupposedToRun(EntityID) then
                    AdjustmentFactor = self.Config.Movement.AttackSpeedFactor;
                end
                Factors[EntityID] = Factor * AdjustmentFactor;
            end
            return Factors;
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Unit Endurance

function Stronghold.Stamina:SetUnitStaminaOnCreate(_EntityID)

end

function Stronghold.Stamina:SetUnitStaminaOnDestroy(_EntityID)

end

function Stronghold.Stamina:UpdateUnitStamina(_PlayerID)

end

