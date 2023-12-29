function Test_MoveShip()
    local PathSize = CalculateOptimalNumPoints(GetPosition("LineStart"), GetPosition("LineEnd"), 20);
    local Path = GetPositionsBetween(GetPosition("LineStart"), GetPosition("LineEnd"), PathSize);
    table.insert(Path, 1, GetPosition("LineStart"));
    table.insert(Path, GetPosition("LineEnd"));

    gvShipTest = {};
    gvShipTest.ScriptName = "TestCog";
    gvShipTest.Path = Path;
    gvShipTest.PathSize = PathSize + 2;
    gvShipTest.Index = 1;

    StartSimpleHiResJob("Test_ShipMovementController");
end

function Test_MoveShipReverse()
    local PathSize = CalculateOptimalNumPoints(GetPosition("LineEnd"), GetPosition("LineStart"), 20);
    local Path = GetPositionsBetween(GetPosition("LineEnd"), GetPosition("LineStart"), PathSize);
    table.insert(Path, 1, GetPosition("LineEnd"));
    table.insert(Path, GetPosition("LineStart"));

    gvShipTest = {};
    gvShipTest.ScriptName = "TestCog";
    gvShipTest.Path = Path;
    gvShipTest.PathSize = PathSize + 2;
    gvShipTest.Index = 1;

    StartSimpleHiResJob("Test_ShipMovementController");
end

function Test_ShipMovementController()
    if gvShipTest.Index >= gvShipTest.PathSize then
        return true;
    end

    local EntityID = GetID(gvShipTest.ScriptName);
    local Type = Logic.GetEntityType(EntityID);
    local Position = gvShipTest.Path[gvShipTest.Index];
    local Angle = GetAngleBetween(EntityID, Position);
    DestroyEntity(EntityID);
    EntityID = Logic.CreateEntity(Type, Position.X, Position.Y, Angle, 0);
    Logic.SetEntityName(EntityID, gvShipTest.ScriptName);

    gvShipTest.Index = gvShipTest.Index + 1;
end

