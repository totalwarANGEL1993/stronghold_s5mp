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

--- Activates/Deactivates marching for all units of the player.
--- 
--- When marching is activated, units will still run if they are acting
--- aggressivly (attacking target, attack move, ect).
--- 
--- @param _PlayerID integer ID of player
--- @param _Flag boolean Marching flag
function SetGlobalUnitMarchingFlag(_PlayerID, _Flag)
    Stronghold.Stamina:SetGlobalUnitMarchingFlag(_PlayerID, _Flag)
end

--- Activates/Deactivates marching for this unit.
--- 
--- Activating marching for single units will ignore the global setting for
--- the player if their units are not set to marching. This is supposed to
--- be used in events like cutscenes.
--- 
--- When marching is activated, units will still run if they are acting
--- aggressivly (attacking target, attack move, ect).
--- 
--- @param _Entity any ID or scriptname of entity
--- @param _Flag boolean Marching flag
function SetUnitMarchingFlag(_Entity, _Flag)
    local EntityID = GetID(_Entity);
    Stronghold.Stamina:SetUnitMarchingFlag(EntityID, _Flag)
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Stamina:Install()
    for PlayerID = 1, GetMaxAmountOfPlayer() do
        self.Data.Endurance[PlayerID] = {};
        self.Data.Marching[PlayerID] = {Global = false};
    end

    self:OverwriteArmyWalkingSpeed();
    self:OverwriteUI();
    self:InitDamageOverwrite();
    self:CreateNetworkHandlers();
end

function Stronghold.Stamina:OnSaveGameLoaded()
end

function Stronghold.Stamina:OnEntityCreated(_EntityID)
    self:SetUnitEnduranceOnCreate(_EntityID);
end

function Stronghold.Stamina:OnEntityDestroyed(_EntityID)
    self:SetUnitEnduranceOnDestroy(_EntityID);
end

function Stronghold.Stamina:OncePerSecond(_PlayerID)
    self:UpdateUnitEndurance(_PlayerID);
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

function Stronghold.Stamina:OnUnknownTaskForMilitaryUnit(_EntityID)
    -- Control running/walking (Leader)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Leader) == 1
    or Logic.IsEntityInCategory(_EntityID, EntityCategories.Hero) == 1
    or Logic.IsEntityInCategory(_EntityID, EntityCategories.Serf) == 1
    or Logic.GetEntityType(_EntityID) == Entities.PU_BattleSerf
    or Logic.GetEntityType(_EntityID) == Entities.PU_Thief then
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
                        if (Command == 0 or Command == 3 or Command == 5 or Command == 6 or Command == 8)
                        or Logic.GetEntityType(_EntityID) == Entities.PU_Serf then
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
            if LeaderID and LeaderID ~= 0 then
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
end

function Stronghold.Stamina:IsUnitSupposedToRun(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if PlayerID == 0 or PlayerID > 16 then
        return true;
    end
    local TaskList = Logic.GetCurrentTaskList(_EntityID);
    local Command = Logic.LeaderGetCurrentCommand(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);

    if self.Config.Movement.IgnoredTypes[Type] then
        return true;
    end

    -- Run always when performing these tasks
    if TaskList == "TL_START_BATTLE" or
       TaskList == "TL_SERF_BUILD" or
       TaskList == "TL_SERF_EXTRACT_RESOURCE" or
       TaskList == "TL_SERF_EXTRACT_WOOD" or
       TaskList == "TL_SERF_GO_TO_CONSTRUCTION_SITE" or
       TaskList == "TL_SERF_GO_TO_RESOURCE" or
       TaskList == "TL_SERF_GO_TO_TREE" or
       TaskList == "TL_SERF_TURN_INTO_BATTLE_SERF" then
        return true;
    end
    -- Check switches and commands
    if self.Data.Marching[PlayerID].Global
    or self.Data.Marching[PlayerID][_EntityID] then
        local IsInArmy = AiArmy.GetArmyOfTroop(_EntityID) ~= 0;
        local IsRefilling = AiArmyRefiller.GetRefillerOfTroop(_EntityID) ~= 0;
        return (Command == 0 or Command == 3) or
               (not IsInArmy and not IsRefilling and Command == 5) or
               IsFighting(_EntityID);
    end
    return (Command == 0 or Command == 3 or Command == 5 or Command == 6 or Command == 8) or
           Type == Entities.PU_Serf or
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

function Stronghold.Stamina:InitDamageOverwrite()
    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_BattleDamage", function(_AttackerID, _AttackedID, _Damage)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Stamina:ApplyEnduranceToDamage(_AttackerID, _AttackedID, _Damage);
        return CurrentAmount;
    end);
end

function Stronghold.Stamina:SetUnitEnduranceOnCreate(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if self.Data.Endurance[PlayerID] then
        if Type == Entities.PU_BattleSerf
        or Type == Entities.PU_Serf
        then
            self.Data.Endurance[PlayerID].LastTransformedID = _EntityID;
        end
        self.Data.Endurance[PlayerID][_EntityID] = 1.0;
    end
end

function Stronghold.Stamina:SetUnitEnduranceOnDestroy(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local TaskList = Logic.GetCurrentTaskList(_EntityID);
    if self.Data.Endurance[PlayerID] then
        local NewID = self.Data.Endurance[PlayerID].LastTransformedID;
        local Type = Logic.GetEntityType(NewID);
        local Stamina = self.Data.Endurance[PlayerID][_EntityID] or 0;
        if  TaskList == "TL_SERF_TURN_INTO_BATTLE_SERF" and Type == Entities.PU_BattleSerf then
            self.Data.Endurance[PlayerID][NewID] = Stamina;
        end
        if  TaskList == "TL_BATTLE_SERF_TURN_INTO_SERF" and Type == Entities.PU_Serf then
            self.Data.Endurance[PlayerID][NewID] = Stamina;
        end
        self.Data.Endurance[PlayerID].LastTransformedID = nil;
        self.Data.Endurance[PlayerID][_EntityID] = nil;
    end
end

function Stronghold.Stamina:UpdateUnitEndurance(_PlayerID)
    if self.Data.Endurance[_PlayerID] then
        for EntityID, Endurance in pairs(self.Data.Endurance[_PlayerID]) do
            if self:DoesUnitEnduranceChange(EntityID) then
                local Max = self.Config.Endurance.MaxStaminaThreshold;
                local Type = Logic.GetEntityType(EntityID);
                local TaskList = Logic.GetCurrentTaskList(EntityID) or "";
                local Config = Stronghold.Unit.Config.Troops:GetConfig(Type);
                local Tier = (Config == nil and 0) or Config.Tier;
                local Factor = 0;
                if self.Config.Endurance.RestingRecoveryTask[TaskList] then
                    Factor = self.Config.Endurance.RestingRecoveryRates[Tier] or 0;
                end
                if self.Config.Endurance.RunningDrainTasks[TaskList] then
                    Factor = self.Config.Endurance.RunningDrainRates[Tier] or 0;
                end
                if self.Config.Endurance.BattleDrainTasks[TaskList] then
                    Factor = self.Config.Endurance.BattleDrainRates[Tier] or 0;
                end
                Endurance = math.min(math.max(Endurance + Factor, 0), Max);
                self.Data.Endurance[_PlayerID][EntityID] = Endurance;
            end
        end
    end
end

function Stronghold.Stamina:ApplyEnduranceToDamage(_AttackerID, _AttackedID, _Damage)
    return self:GetUnitDamageByEndurance(_AttackerID, _Damage);
end

function Stronghold.Stamina:DoesUnitEnduranceChange(_EntityID)
    return Logic.GetEntityHealth(_EntityID) > 0 and
           Logic.IsEntityInCategory(_EntityID, EntityCategories.Cannon) == 0 and
           Logic.IsEntityInCategory(_EntityID, EntityCategories.Hero) == 0 and
           Logic.IsEntityInCategory(_EntityID, EntityCategories.Worker) == 0 and
           not self.Config.Endurance.IgnoredTypes[Logic.GetEntityType(_EntityID)] and
           AiArmy.GetArmyOfTroop(_EntityID) == 0 and
           AiArmyRefiller.GetRefillerOfTroop(_EntityID) == 0;
end

function Stronghold.Stamina:GetUnitEndurance(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if self.Data.Endurance[PlayerID] then
        return self.Data.Endurance[PlayerID][_EntityID] or 1;
    end
    return 1;
end

function Stronghold.Stamina:GetUnitDamageByEndurance(_AttackerID, _Damage)
    local LeaderID = _AttackerID;
    if Logic.IsEntityInCategory(LeaderID, EntityCategories.Soldier) == 1 then
        LeaderID = SVLib.GetLeaderOfSoldier(LeaderID);
    end
    local Endurance = self:GetUnitEndurance(LeaderID);
    local Factor = 1;
    if  Endurance <= self.Config.Endurance.MaxStaminaThreshold
    and Endurance > self.Config.Endurance.FineStaminaThreshold then
        Factor = self.Config.Endurance.FineDamageFactor;
    end
    if  Endurance <= self.Config.Endurance.FineStaminaThreshold
    and Endurance > self.Config.Endurance.GoodStaminaThreshold then
        Factor = self.Config.Endurance.GoodDamageFactor;
    end
    if  Endurance <= self.Config.Endurance.GoodStaminaThreshold
    and Endurance > self.Config.Endurance.BadStaminaThreshold then
        Factor = self.Config.Endurance.BadDamageFactor;
    end
    if  Endurance < self.Config.Endurance.BadStaminaThreshold then
        Factor = self.Config.Endurance.WorseDamageFactor;
    end
    return self:CalculateDamageReduction(_Damage, Factor, 16);
end

-- The following function is the core of the stamina system:
-- * Stamina factor > 1:
--   - Big damage is increased less by higher stamina
--   - Small damage is increased more by higher stamina
-- * Stamina factor < 1:
--   - Big damage is decreased more by lower stamina
--   - Small damage is decreased less by lower stamina
-- This will (hopefully) make the player conserve their elite more and also
-- make weak cannon fodder more atractive to use.
function Stronghold.Stamina:CalculateDamageReduction(_Damage, _Factor, _Base)
    if _Damage > 0 and _Base > 0 then
        local LogValue = math.log(_Damage) / math.log(_Base);
        if _Factor > 1 then
            return _Damage + 3;
        elseif _Factor < 1 then
            return _Damage * (_Factor ^ LogValue);
        end
    end
    return _Damage;
end

-- -------------------------------------------------------------------------- --
-- UI

function Stronghold.Stamina:OnSelectUnit(_EntityID)
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if GuiPlayer ~= 17 and GuiPlayer ~= PlayerID then
        return;
    end
    local VisibilityFlag = 0;
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Cannon) == 0 then
        if Logic.IsEntityInCategory(_EntityID, EntityCategories.Leader) == 1
        or Logic.IsEntityInCategory(_EntityID, EntityCategories.Hero) == 1
        or Logic.IsEntityInCategory(_EntityID, EntityCategories.Serf) == 1
        or Logic.GetEntityType(_EntityID) == Entities.PU_BattleSerf
        or Logic.GetEntityType(_EntityID) == Entities.PU_Thief then
            VisibilityFlag = 1;
        end
    end

    XGUIEng.ShowWidget("DetailsStatus", VisibilityFlag);
    XGUIEng.ShowWidget("DetailsStatus_Pace", 1);
    XGUIEng.ShowWidget("DetailsStatus_Stamina", 1);
end

function Stronghold.Stamina:GetUnitStaminaIcon(_Endurance)
    local EnduranceSource = "";
    if  _Endurance <= self.Config.Endurance.MaxStaminaThreshold
    and _Endurance > self.Config.Endurance.FineStaminaThreshold then
        EnduranceSource = "graphics/textures/gui/i_res_motiv_fine.png";
    end
    if  _Endurance <= self.Config.Endurance.FineStaminaThreshold
    and _Endurance > self.Config.Endurance.GoodStaminaThreshold then
        EnduranceSource = "graphics/textures/gui/i_res_motiv_good.png";
    end
    if  _Endurance <= self.Config.Endurance.GoodStaminaThreshold
    and _Endurance > self.Config.Endurance.BadStaminaThreshold then
        EnduranceSource = "graphics/textures/gui/i_res_motiv_bad.png";
    end
    if  _Endurance < self.Config.Endurance.BadStaminaThreshold then
        EnduranceSource = "graphics/textures/gui/i_res_motiv_worse.png";
    end
    return EnduranceSource;
end

function Stronghold.Stamina:GetUnitPaceIcon(_EntityID)
    local TaskList = Logic.GetCurrentTaskList(_EntityID);
    local PaceSource = "graphics/textures/gui/onscreen_status_recover.png";
    if Logic.IsEntityMoving(_EntityID) then
        PaceSource = "graphics/textures/gui/onscreen_status_leave.png";
    elseif IsFighting(_EntityID) then
        PaceSource = "graphics/textures/gui/onscreen_status_flee.png";
    elseif TaskList == "TL_START_BATTLE" or
           TaskList == "TL_SERF_BUILD" or
           TaskList == "TL_SERF_EXTRACT_RESOURCE" or
           TaskList == "TL_SERF_EXTRACT_WOOD" then
        PaceSource = "graphics/textures/gui/onscreen_status_work.png";
    end
    return PaceSource;
end

function Stronghold.Stamina:OverwriteUI()
    Overwrite.CreateOverwrite("GUIAction_Command", function(_Command)
        if _Command ~= 6 then
            Overwrite.CallOriginal();
            return;
        end
        Stronghold.Stamina:SendToggleRunAction();
    end);

    Overwrite.CreateOverwrite("GUIUpdate_CommandGroup", function()
        Overwrite.CallOriginal();
        Stronghold.Stamina:SendToggleRunUpdate();
    end);
end

function Stronghold.Stamina:SendToggleRunAction()
    local EntityID = GUI.GetSelectedEntity();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    if GuiPlayer == PlayerID then
        Syncer.InvokeEvent(
            self.NetworkCall,
            self.SyncEvents.SetGlobalPace,
            PlayerID,
            not self.Data.Marching[PlayerID].Global
        );
    end
end

function Stronghold.Stamina:SendToggleRunUpdate()
    local EntityID = GUI.GetSelectedEntity();
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    if GuiPlayer == PlayerID then
        local RunFlag = (self.Data.Marching[PlayerID].Global and 0) or 1;
        local WalkFlag = (self.Data.Marching[PlayerID].Global and 1) or 0;
        XGUIEng.ShowWidget("Command_Run", RunFlag);
        XGUIEng.ShowWidget("Command_Walk", WalkFlag);
    end
end

function GUIUpdate_DetailsStatus()
    local EntityID = GUI.GetSelectedEntity();
    local TaskList = Logic.GetCurrentTaskList(EntityID) or "";

    local PaceVisibilityFlag = 1;
    local StaminaVisibilityFlag = 1;
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Worker) == 1
    then
        PaceVisibilityFlag = 0;
        StaminaVisibilityFlag = 0;
    end
    if TaskList == "TL_SERF_WALK" then
        PaceVisibilityFlag = 0;
    end
    if  string.find(TaskList, "WALK_BATTLE") == nil
    and string.find(TaskList, "START_BATTLE") == nil
    and string.find(TaskList, "TL_BATTLE") == nil
    and string.find(TaskList, "_IDLE") == nil
    and string.find(TaskList, "TL_SERF") == nil
    then
        PaceVisibilityFlag = 0;
    end

    local PaceImage = Stronghold.Stamina:GetUnitPaceIcon(EntityID);
    XGUIEng.ShowWidget("DetailsStatus_Pace", PaceVisibilityFlag);
    XGUIEng.SetMaterialTexture("DetailsStatus_PaceIcon", 1, PaceImage);

    local Endurance = Stronghold.Stamina:GetUnitEndurance(EntityID);
    local EnduranceImage = Stronghold.Stamina:GetUnitStaminaIcon(Endurance);
    XGUIEng.ShowWidget("DetailsStatus_Stamina", StaminaVisibilityFlag);
    XGUIEng.SetMaterialTexture("DetailsStatus_StaminaIcon", 1, EnduranceImage);
end

