---
--- Animal AI
---

Stronghold.AI.Data.Animals = {};

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
        self.Data.Animals[_EntityID] = true;
    end
end

function Stronghold.AI:ControlMigratoryAnimal()
    for EntityID, Data in pairs(self.Data.Animals) do
        if not IsExisting(EntityID) then
            self.Data.Animals[EntityID] = nil;
        else
            local TaskList = Logic.GetCurrentTaskList(EntityID);
            if TaskList == "TL_ANIMAL_FLEE" then
                Logic.SetSpeedFactor(EntityID, 2.0);
            else
                Logic.SetSpeedFactor(EntityID, 1.0);
            end
        end
    end
end

