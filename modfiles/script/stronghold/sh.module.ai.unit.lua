---
--- Unit AI
---

-- -------------------------------------------------------------------------- --

function Stronghold.AI:OnUnknownTaskForMilitaryUnit(_EntityID)
    -- The army system uses command 5 to move troops which means, leaders
    -- attached to an army would always run anyway. So we do not meddle
    -- with their anims and tasks.
    if AiArmy.GetArmyOfTroop(_EntityID) ~= 0 then
        return;
    end
    -- Control running/walking (Leader)
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Leader) == 1
    or Logic.IsEntityInCategory(_EntityID, EntityCategories.Hero) == 1
    or Logic.IsEntityInCategory(_EntityID, EntityCategories.Serf) == 1 then
        if IsValidEntity(_EntityID) then
            local TaskList = Logic.GetCurrentTaskList(_EntityID);
            local Command = Logic.LeaderGetCurrentCommand(_EntityID);
            local Factor = self.Config.Movement.RegularSpeedFactor;

            -- Change speed
            if self:ShouldUnitRun(_EntityID) then
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
            if string.find(TaskList, "WALK") then
                local RunTask = self.Config.Movement.WalkToRun[TaskList] or TaskList;
                local WalkTask = self.Config.Movement.RunToWalk[TaskList] or TaskList;
                if RunTask or WalkTask then
                    if TaskList == WalkTask and Command == 5 then
                        Logic.SetTaskList(_EntityID, TaskLists[RunTask]);
                        return TaskAdvancementType.NextTick;
                    end
                    if TaskList == RunTask and Command ~= 5 then
                        Logic.SetTaskList(_EntityID, TaskLists[WalkTask]);
                        return TaskAdvancementType.NextTick;
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
            local Command = Logic.LeaderGetCurrentCommand(LeaderID);
            if TaskList == "TL_FORMATION" then
                if Command == 0 or Command == 5 or IsFighting(LeaderID) then
                    Logic.SetTaskList(_EntityID, TaskLists.TL_FORMATION_BATTLE);
                    return TaskAdvancementType.NextTick;
                end
                return TaskAdvancementType.Immediately;
            elseif TaskList == "TL_FORMATION_BATTLE" then
                if Command ~= 0 and Command ~= 5 and not IsFighting(LeaderID) then
                    Logic.SetTaskList(_EntityID, TaskLists.TL_FORMATION);
                    return TaskAdvancementType.NextTick;
                end
                return TaskAdvancementType.Immediately;
            end
        end
    end
end

function Stronghold.AI:ShouldUnitRun(_EntityID)
    local TaskList = Logic.GetCurrentTaskList(_EntityID);
    local Command = Logic.LeaderGetCurrentCommand(_EntityID);
    return Command == 5 or
           TaskList == "TL_SERF_GO_TO_CONSTRUCTION_SITE" or
           TaskList == "TL_SERF_GO_TO_RESOURCE" or
           TaskList == "TL_SERF_GO_TO_TREE" or
           IsFighting(_EntityID);
end

-- -------------------------------------------------------------------------- --

Stronghold.AI.Data.MigratoryAnimals = {0};

function Stronghold.AI:InitMigratoryAnimals()
    for Type,_ in pairs(self.Config.MigratoryAnimal) do
        local TypeFilter = CEntityIterator.OfTypeFilter(Type);
        for EntityID in CEntityIterator.Iterator(TypeFilter) do
            self.Data.MigratoryAnimals[EntityID] = nil;
            self:RegisterMigratoryAnimal(EntityID);
        end
    end
end

function Stronghold.AI:RegisterMigratoryAnimal(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if PlayerID == 0 and self.Config.MigratoryAnimal[Type] then
        self.Data.MigratoryAnimals[1] = self.Data.MigratoryAnimals[1] + 1;
        table.insert(self.Data.MigratoryAnimals, _EntityID);
    end
end

function Stronghold.AI:IsMigratoryAnimalFleeing(_EntityID)
    local TaskList = Logic.GetEntityScriptingValue(_EntityID, -22);
    if TaskList == TaskLists.TL_ANIMAL_FLEE then
        return true;
    end
    return false;
end

function Stronghold.AI:ControlMigratoryAnimal()
    local CurrentTurn = Logic.GetCurrentTurn();
    if CurrentTurn > 50 then
        local TurnMod = math.mod(CurrentTurn, 10);
        for i= (self.Data.MigratoryAnimals[1] +1) - TurnMod, 2, -10 do
            if not IsExisting(self.Data.MigratoryAnimals[i]) then
                self.Data.MigratoryAnimals[1] = self.Data.MigratoryAnimals[1] - 1;
                table.remove(self.Data.MigratoryAnimals, i);
            else
                if self:IsMigratoryAnimalFleeing(self.Data.MigratoryAnimals[i]) then
                    local Factor = self.Config.MigratoryAnimal.FleeingSpeedFactor;
                    Logic.SetSpeedFactor(self.Data.MigratoryAnimals[i], Factor);
                else
                    local Factor = self.Config.MigratoryAnimal.RegularSpeedFactor;
                    Logic.SetSpeedFactor(self.Data.MigratoryAnimals[i], Factor);
                end
            end
        end
    end
end

