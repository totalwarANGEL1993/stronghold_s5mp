---
--- Unit AI
---

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

