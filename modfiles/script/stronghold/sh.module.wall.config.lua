--- 
--- Configuration for the walls
--- 

-- Dictionary for mapping corners to wally
Stronghold.Wall.Config.CornerForSegment = {
    [Entities.PB_DarkWallStraightGate_Closed]   = Entities.PB_DarkWallCorner,
    [Entities.PB_DarkWallStraightGate]          = Entities.PB_DarkWallCorner,
    [Entities.PB_DarkWallDistorted]             = Entities.PB_DarkWallCorner,
    [Entities.PB_DarkWallStraight]              = Entities.PB_DarkWallCorner,
    [Entities.PB_PalisadeStraightGate_Closed]   = Entities.PB_PalisadeCorner,
    [Entities.PB_PalisadeStraightGate]          = Entities.PB_PalisadeCorner,
    [Entities.PB_PalisadeDistorted]             = Entities.PB_PalisadeCorner,
    [Entities.PB_PalisadeStraight]              = Entities.PB_PalisadeCorner,
    [Entities.PB_WallStraightGate_Closed]       = Entities.PB_WallCorner,
    [Entities.PB_WallStraightGate]              = Entities.PB_WallCorner,
    [Entities.PB_WallDistorted]                 = Entities.PB_WallCorner,
    [Entities.PB_WallStraight]                  = Entities.PB_WallCorner,
}

-- Dictionary to map open gates to closed gates
Stronghold.Wall.Config.OpenToClosedGate = {
    [Entities.PB_DarkWallStraightGate]          = Entities.PB_DarkWallStraightGate_Closed,
    [Entities.PB_PalisadeStraightGate]          = Entities.PB_PalisadeStraightGate_Closed,
    [Entities.PB_WallStraightGate]              = Entities.PB_WallStraightGate_Closed,
}

-- Dictionary to map closed gates to open gates
Stronghold.Wall.Config.ClosedToOpenGate = {
    [Entities.PB_DarkWallStraightGate_Closed]   = Entities.PB_DarkWallStraightGate,
    [Entities.PB_PalisadeStraightGate_Closed]   = Entities.PB_PalisadeStraightGate,
    [Entities.PB_WallStraightGate_Closed]       = Entities.PB_WallStraightGate,
}

-- Dictionary to map gate types to wall types
Stronghold.Wall.Config.GateToWall = {
    [Entities.PB_DarkWallStraightGate_Closed]   = Entities.PB_DarkWallDistorted,
    [Entities.PB_PalisadeStraightGate_Closed]   = Entities.PB_PalisadeDistorted,
    [Entities.PB_WallStraightGate_Closed]       = Entities.PB_WallDistorted,
    [Entities.PB_DarkWallStraightGate]          = Entities.PB_DarkWallDistorted,
    [Entities.PB_PalisadeStraightGate]          = Entities.PB_PalisadeDistorted,
    [Entities.PB_WallStraightGate]              = Entities.PB_WallDistorted,
}

-- Dictionary to map wall types to gate types
Stronghold.Wall.Config.WallToGate = {
    [Entities.PB_DarkWallDistorted]             = Entities.PB_DarkWallStraightGate_Closed,
    [Entities.PB_PalisadeDistorted]             = Entities.PB_PalisadeStraightGate_Closed,
    [Entities.PB_WallDistorted]                 = Entities.PB_WallStraightGate_Closed,
}

-- Dictionary to map wall types to dark counterparts
Stronghold.Wall.Config.WallToDarkWall = {
    [Entities.PB_WallStraightGate_Closed]       = Entities.PB_DarkWallStraightGate_Closed,
    [Entities.PB_WallStraightGate]              = Entities.PB_DarkWallStraightGate,
    [Entities.PB_WallDistorted]                 = Entities.PB_DarkWallDistorted,
    [Entities.PB_WallStraight]                  = Entities.PB_DarkWallStraight,
}

-- Dictionary of types considered a wall
Stronghold.Wall.Config.LegalWallType = {
    [Entities.PB_DarkWallStraightGate_Closed]   = true,
    [Entities.PB_DarkWallStraightGate]          = true,
    [Entities.PB_DarkWallDistorted]             = true,
    [Entities.PB_DarkWallStraight]              = true,
    [Entities.PB_PalisadeStraightGate_Closed]   = true,
    [Entities.PB_PalisadeStraightGate]          = true,
    [Entities.PB_PalisadeDistorted]             = true,
    [Entities.PB_PalisadeStraight]              = true,
    [Entities.PB_WallStraightGate_Closed]       = true,
    [Entities.PB_WallStraightGate]              = true,
    [Entities.PB_WallDistorted]                 = true,
    [Entities.PB_WallStraight]                  = true,
}

-- Dictionary of opened gate types
Stronghold.Wall.Config.OpenGateType = {
    [Entities.PB_DarkWallStraightGate]          = true,
    [Entities.PB_PalisadeStraightGate]          = true,
    [Entities.PB_WallStraightGate]              = true,
}

-- Dictionary of closed gate types
Stronghold.Wall.Config.ClosedGateType = {
    [Entities.PB_DarkWallStraightGate_Closed]   = true,
    [Entities.PB_PalisadeStraightGate_Closed]   = true,
    [Entities.PB_WallStraightGate_Closed]       = true,
}

-- Dictionary of wall segment types
Stronghold.Wall.Config.WallSegmentType = {
    [Entities.PB_DarkWallDistorted]             = true,
    [Entities.PB_PalisadeDistorted]             = true,
    [Entities.PB_WallDistorted]                 = true,
}

-- Dictionary of wodden wall types
Stronghold.Wall.Config.WoddenWallTypes = {
    [Entities.PB_PalisadeStraightGate_Closed]   = true,
    [Entities.PB_PalisadeStraightGate]          = true,
    [Entities.PB_PalisadeDistorted]             = true,
    [Entities.PB_PalisadeStraight]              = true,
}

-- Dictionary of stone wall types
Stronghold.Wall.Config.StoneWallTypes = {
    [Entities.PB_DarkWallStraightGate_Closed]   = true,
    [Entities.PB_DarkWallStraightGate]          = true,
    [Entities.PB_DarkWallDistorted]             = true,
    [Entities.PB_DarkWallStraight]              = true,
    [Entities.PB_WallStraightGate_Closed]       = true,
    [Entities.PB_WallStraightGate]              = true,
    [Entities.PB_WallDistorted]                 = true,
    [Entities.PB_WallStraight]                  = true,
}

-- Dictionary of neutral wall types
Stronghold.Wall.Config.NeutralWallType = {
    [Entities.XD_DarkWallCorner]                = true,
    [Entities.XD_DarkWallStraightGate_Closed]   = true,
    [Entities.XD_DarkWallStraightGate]          = true,
    [Entities.XD_DarkWallDistorted]             = true,
    [Entities.XD_DarkWallStraight]              = true,
    [Entities.XD_PalisadeCorner]                = true,
    [Entities.XD_PalisadeStraightGate_Closed]   = true,
    [Entities.XD_PalisadeStraightGate]          = true,
    [Entities.XD_PalisadeDistorted]             = true,
    [Entities.XD_PalisadeStraight]              = true,
    [Entities.XD_WallCorner]                    = true,
    [Entities.XD_WallStraightGate_Closed]       = true,
    [Entities.XD_WallStraightGate]              = true,
    [Entities.XD_WallDistorted]                 = true,
    [Entities.XD_WallStraight]                  = true,
}

