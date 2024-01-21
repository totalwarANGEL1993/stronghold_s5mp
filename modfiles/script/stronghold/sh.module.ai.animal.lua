---
--- Animal AI
---

Stronghold.AI.Data.Animals = {0};

-- -------------------------------------------------------------------------- --

function Stronghold.AI:InitMigratoryAnimals()
    for Type,_ in pairs(self.Config.MigratoryAnimal) do
        local TypeFilter = CEntityIterator.OfTypeFilter(Type);
        for EntityID in CEntityIterator.Iterator(TypeFilter) do
            self.Data.Animals[EntityID] = nil;
            self:RegisterMigratoryAnimal(EntityID);
        end
    end
end

function Stronghold.AI:RegisterMigratoryAnimal(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if PlayerID == 0 and self.Config.MigratoryAnimal[Type] then
        self.Data.Animals[1] = self.Data.Animals[1] + 1;
        table.insert(self.Data.Animals, _EntityID);
    end
end

function Stronghold.AI:ControlMigratoryAnimal()
    local CurrentTurn = Logic.GetCurrentTurn();
    if CurrentTurn > 50 then
        local TurnMod = math.mod(CurrentTurn, 10);
        for i= (self.Data.Animals[1] +1) - TurnMod, 2, -10 do
            if not IsExisting(self.Data.Animals[i]) then
                self.Data.Animals[1] = self.Data.Animals[1] - 1;
                table.remove(self.Data.Animals, i);
            end
            local TaskList = Logic.GetEntityScriptingValue(self.Data.Animals[i], -22);
            if TaskList == TaskLists.TL_ANIMAL_FLEE then
                local Factor = self.Config.MigratoryAnimal.FleeingSpeedFactor;
                Logic.SetSpeedFactor(self.Data.Animals[i], Factor);
            else
                local Factor = self.Config.MigratoryAnimal.RegularSpeedFactor;
                Logic.SetSpeedFactor(self.Data.Animals[i], Factor);
            end
        end
    end
end

