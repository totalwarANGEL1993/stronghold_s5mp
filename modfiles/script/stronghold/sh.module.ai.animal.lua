---
--- Animal AI
---

Stronghold.AI.Data.Animals = {};
Stronghold.AI.Data.AnimalsBlacklist = {};

-- -------------------------------------------------------------------------- --

--- Creates an animal.
--- @param _PlayerID integer ID of owner
--- @param _Type integer Type of animal
--- @param _Position table Position of animal
--- @param _Orientation number Orientation
--- @return string ScriptName Name of created animal
function CreateAnimal(_PlayerID, _Type, _Position, _Orientation)
    local ScriptName;
    if Stronghold.AI.Config.MigratoryAnimal[_Type] then
        local ID = Logic.CreateEntity(
            _Type,
            _Position.X, _Position.Y,
            _Orientation or 0,
            _PlayerID
        );
        ScriptName = CreateNameForEntity(ID);
    end
    return ScriptName;
end

--- Creates an animal NPC that is controlled by the AI.
--- @param _Type integer Type of animal
--- @param _Position table Position of animal
--- @param _Orientation number Orientation
--- @return string ScriptName Name of created animal
function CreateAutonomousAnimal(_Type, _Position, _Orientation)
    local ScriptName;
    if Stronghold.AI.Config.MigratoryAnimal[_Type] then
        local ID = Logic.CreateEntity(
            _Type,
            _Position.X, _Position.Y,
            _Orientation or 0,
            GetNeutralPlayerID()
        );
        ScriptName = CreateNameForEntity(ID);
        StartControlAnimalAutonoumous(ScriptName);
    end
    return ScriptName;
end

--- Enables AI controlling for the animal NPC.
--- @param _ScriptName string Script name
function StartControlAnimalAutonoumous(_ScriptName)
    Stronghold.AI:RegisterMigratoryAnimal(GetID(_ScriptName));
end

--- Disables AI controlling for the animal NPC.
--- @param _ScriptName string Script name
function StopControlAnimalAutonoumous(_ScriptName)
    Stronghold.AI:RegisterMigratoryAnimal(GetID(_ScriptName));
end

function Stronghold.AI:InitAnimals()
    for Type,_ in pairs(self.Config.MigratoryAnimal) do
        local TypeFilter = CEntityIterator.OfTypeFilter(Type);
        for EntityID in CEntityIterator.Iterator(TypeFilter) do
            self:UnregisterMigratoryAnimal(EntityID);
            self:RegisterMigratoryAnimal(EntityID);
        end
    end
end

function Stronghold.AI:RegisterMigratoryAnimal(_Entity)
    local EntityID = (type(_Entity) ~= "number" and GetID(_Entity)) or _Entity;
    local Type = Logic.GetEntityType(EntityID);
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    if PlayerID ~= 0 and self.Config.MigratoryAnimal[Type] then
        local ScriptName = Logic.GetEntityName(EntityID);
        if not ScriptName or not self.Data.AnimalsBlacklist[ScriptName] then
            local ID = ChangePlayer(EntityID, GetNeutralPlayerID());
            ScriptName = CreateNameForEntity(ID);
            self.Data.Animals[ScriptName] = {
                HomePosition = GetPosition(ID),
                Chance = self.Config.MigratoryAnimal[Type][3],
                MinArea = self.Config.MigratoryAnimal[Type][1],
                MaxArea = self.Config.MigratoryAnimal[Type][2],
                Fleeing = 0,
            };
            return ID;
        end
    end
    return 0;
end

function Stronghold.AI:UnregisterMigratoryAnimal(_Entity)
    local ScriptName = _Entity;
    if type(ScriptName) ~= "string" then
        ScriptName = Logic.GetEntityName(_Entity);
    end
    if self.Data.Animals[ScriptName] then
        self.Data.Animals[ScriptName] = nil;
    end
end

function Stronghold.AI:GetAnimalScareMongerID(_EntityID)
    local AllPlayers = {1,2,3,4,5,6,7,8};
    for i= 9, GetMaxAmountOfPlayer() do
        table.insert(AllPlayers, i);
    end
    local Position = GetPosition(_EntityID);
    local RangeFilter = CEntityIterator.InRangeFilter(Position.X, Position.Y, 1000);
    local PlayerFilter = CEntityIterator.OfAnyPlayerFilter(unpack(AllPlayers));
    local OtherEntitiesNear = 0;
    for OtherID in CEntityIterator.Iterator(RangeFilter, PlayerFilter) do
        OtherEntitiesNear = OtherEntitiesNear + 1;
        if OtherEntitiesNear > 1 then
            return OtherID;
        end
    end
    return 0;
end

function Stronghold.AI:ControlMigratoryAnimal()
    for ScriptName, Data in pairs(self.Data.Animals) do
        local ID = GetID(ScriptName);
        if not IsExisting(ID) then
            self.Data.Animals[ScriptName] = nil;
        else
            if GetDistance(ID, Data.HomePosition) > Data.MaxArea then
                Logic.MoveSettler(ID, Data.HomePosition.X, Data.HomePosition.Y);
            else
                self.Data.Animals[ScriptName].Fleeing = math.max(Data.Fleeing - 1, 0);
                if Data.Fleeing == 0 and Logic.IsEntityMoving(ID) == false then
                    if math.random(1, 100) <= Data.Chance then
                        local Angle = math.random(1, 360);
                        local Distance = math.random(Data.MinArea, Data.MaxArea);
                        Position = GetCirclePosition(Data.HomePosition, Distance, Angle);
                        if IsValidPosition(Position) then
                            Logic.MoveSettler(ID, Position.X, Position.Y);
                        end
                    end
                else
                    if Data.Fleeing <= 0 then
                        local ScareMonger = self:GetAnimalScareMongerID(ID);
                        if ScareMonger ~= 0 then
                            local Angle = GetAngleBetween(ID, ScareMonger);
                            Position = GetCirclePosition(ScareMonger, Data.MinArea, Angle);
                            if IsValidPosition(Position) then
                                Logic.MoveSettler(ID, Position.X, Position.Y);
                            end
                            self.Data.Animals[ScriptName].Fleeing = 10;
                        end
                    end
                end
            end
        end
    end
end

