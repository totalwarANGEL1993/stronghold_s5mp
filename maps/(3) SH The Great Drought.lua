SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 1,

    -- ###################################################################### --
    -- #                             CONFIG                                 # --
    -- ###################################################################### --

    -- Disable standard victory condition?
    -- (Game is not lost when the HQ falls)
    DisableDefaultWinCondition = false,
    -- Disable rule configuration?
    DisableRuleConfiguration = false;

    -- Open up named gates on the map.
    -- (PTGate1, PTGate2, ...)
    PeaceTimeOpenGates = true,

    -- Fill resource piles with resources
    -- (value of resources or 0 to not change)
    MapStartFillClay = 2000,
    MapStartFillStone = 2000,
    MapStartFillIron = 1000,
    MapStartFillSulfur = 1000,
    MapStartFillWood = 8000,

    -- Rank
    Rank = {
        Initial = 0,
        Final = 7,
    },

    -- Setup heroes allowed
    AllowedHeroes = {
        -- Dario
        [Entities.PU_Hero1c]             = true,
        -- Pilgrim
        [Entities.PU_Hero2]              = true,
        -- Salim
        [Entities.PU_Hero3]              = true,
        -- Erec
        [Entities.PU_Hero4]              = true,
        -- Ari
        [Entities.PU_Hero5]              = true,
        -- Helias
        [Entities.PU_Hero6]              = true,
        -- Kerberos
        [Entities.CU_BlackKnight]        = true,
        -- Mary
        [Entities.CU_Mary_de_Mortfichet] = true,
        -- Varg
        [Entities.CU_Barbarian_Hero]     = true,
        -- Drake
        [Entities.PU_Hero10]             = true,
        -- Yuki
        [Entities.PU_Hero11]             = true,
        -- Kala
        [Entities.CU_Evil_Queen]         = true,
    },

    -- ###################################################################### --
    -- #                            CALLBACKS                               # --
    -- ###################################################################### --

    -- Called when map is loaded
    OnMapStart = function()
        UseWeatherSet("DesertWeatherSet");
        AddPeriodicSummer(10);
        LocalMusic.UseSet = MEDITERANEANMUSIC;
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        ForbidTechnology(Technologies.B_PowerPlant, 1);
        ForbidTechnology(Technologies.B_PowerPlant, 2);
        ForbidTechnology(Technologies.B_PowerPlant, 3);

        SetHostile(1, 7);
        SetHostile(2, 7);
        SetHostile(3, 7);
        CreateSulfurRobbers();

        Drought_Start();
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
        UseWeatherSet("DesertWeatherSet");
    end,
}

-- -------------------------------------------------------------------------- --
-- Robbers

function CreateSulfurRobbers()
    for _, Index in pairs{1, 2, 3} do
        local CampID = DelinquentsCampCreate {
            HomePosition = "RobbersCampPos" ..Index,
            RodeLength = 2700,
            Strength = 9,
        };
        _G["gvBanditCamp" ..Index] = CampID;

        DelinquentsCampAddSpawner(
            CampID, "RobbersTower" ..Index, 60, 3,
            unpack(GetSulfurRobbersTroopTypes())
        );
    end
end

function GetSulfurRobbersTroopTypes()
    local PeaceTimeSelected = GetSelectedPeacetime();
    if PeaceTimeSelected == 1 or PeaceTimeSelected == 6 then
        return {
            Entities.PU_LeaderSword1,
            Entities.PU_LeaderPoleArm1,
            Entities.PU_LeaderBow1,
            Entities.PU_LeaderPoleArm1,
            Entities.PU_LeaderBow1
        };
    end
    if PeaceTimeSelected == 2 or PeaceTimeSelected == 7 then
        return {
            Entities.PU_LeaderSword1,
            Entities.PU_LeaderPoleArm2,
            Entities.PU_LeaderBow2,
            Entities.PU_LeaderPoleArm2,
            Entities.PU_LeaderBow2
        };
    end
    if PeaceTimeSelected == 3 or PeaceTimeSelected == 8 then
        return {
            Entities.PU_LeaderSword2,
            Entities.PV_Cannon1,
            Entities.PU_LeaderBow3,
            Entities.PU_LeaderPoleArm3,
            Entities.PU_LeaderBow3,
            Entities.PU_LeaderPoleArm2
        };
    end
    if PeaceTimeSelected == 4 or PeaceTimeSelected == 9 then
        return {
            Entities.PU_LeaderSword3,
            Entities.PU_LeaderRifle1,
            Entities.PV_Cannon1,
            Entities.PU_LeaderBow3,
            Entities.PU_LeaderPoleArm3,
            Entities.PV_Cannon1
        };
    end
    return {
        Entities.PU_LeaderSword4,
        Entities.PU_LeaderRifle2,
        Entities.PV_Cannon3,
        Entities.PU_LeaderPoleArm4,
        Entities.PU_LeaderRifle2,
        Entities.PV_Cannon3
    };
end

-- -------------------------------------------------------------------------- --
-- Drought mechanic

gvDrought = {
    WaterHeight = 1486,
    MaxWaterHeight = 1486,
    MinWaterHeight = 1075,
    AreaCoords = {1000, 1000, 43800, 43800},
    DrySteps = 0,
    DryTime = 45*60*10,
}

function Drought_Start()
    if gvDrought.JobID then
        EndJob(gvDrought.JobID);
        gvDrought.JobID = nil;
    end

    local PeacetimeTurns = GetPeacetimeInSeconds() * 10;
    gvDrought.DryTime = PeacetimeTurns;
    local WaterDelta = gvDrought.MaxWaterHeight - gvDrought.MinWaterHeight;
    if PeacetimeTurns > 0 then
        gvDrought.DrySteps = WaterDelta / PeacetimeTurns;
    end
    local InitialWaterHeight = gvDrought.MaxWaterHeight;
    if PeacetimeTurns == 0 then
        InitialWaterHeight = gvDrought.MinWaterHeight;
    end

    Drought_SetWaterHeight(InitialWaterHeight);
    Drought_UpdateBlocking();

    if PeacetimeTurns > 0 then
        gvDrought.JobID = StartSimpleHiResJob("Drought_Control");
    end
end

function Drought_SetWaterHeight(_Height)
    local Pos1 = {X= gvDrought.AreaCoords[1], Y= gvDrought.AreaCoords[2]};
    local Pos2 = {X= gvDrought.AreaCoords[3], Y= gvDrought.AreaCoords[4]};
    local Height = math.ceil(_Height);
    Logic.WaterSetAbsoluteHeight(Pos1.X / 100, Pos1.Y / 100, Pos2.X / 100, Pos2.Y / 100, Height);
end

function Drought_UpdateBlocking()
    -- Does (hopefully) not crash
    CUtil.UpdateBlockingWholeMapNoHeight();
    GUI.RebuildMinimapTerrain();
end


function Drought_Control()
    gvDrought.WaterHeight = gvDrought.WaterHeight - gvDrought.DrySteps;
    if gvDrought.WaterHeight < gvDrought.MinWaterHeight then
        gvDrought.WaterHeight = gvDrought.MinWaterHeight;
    end

    Drought_SetWaterHeight(gvDrought.WaterHeight);
    --- @diagnostic disable-next-line: undefined-field
    if math.mod(Logic.GetCurrentTurn(), 50) == 0 then
        Drought_UpdateBlocking();
    end

    gvDrought.DryTime = gvDrought.DryTime - 1;
    if gvDrought.DryTime <= 0 then
        Drought_UpdateBlocking();
        return true;
    end
end

