SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 5,

    -- ###################################################################### --
    -- #                             CONFIG                                 # --
    -- ###################################################################### --

    -- Disable standard victory condition?
    -- (Game is not lost when the HQ falls)
    DisableDefaultWinCondition = false,
    -- Disable rule configuration?
    DisableRuleConfiguration = false;
    -- Disable game start timer?
    -- (Requires rule config to be disabled!)
    DisableGameStartTimer = false;

    -- Peacetime in minutes
    PeaceTime = 0,
    -- Open up named gates on the map.
    -- (PTGate1, PTGate2, ...)
    PeaceTimeOpenGates = true,

    -- Fill resource piles with resources
    -- (value of resources or 0 to not change)
    MapStartFillClay = 4000,
    MapStartFillStone = 4000,
    MapStartFillIron = 4000,
    MapStartFillSulfur = 4000,
    MapStartFillWood = 4000,

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
        UseWeatherSet("HighlandsWeatherSet");
        Logic.AddWeatherElement(1, 20, 1, 1, 5, 10);
        LocalMusic.UseSet = HIGHLANDMUSIC;

        for i= 1, 8 do
            CreateWoodPile("WoodPile" ..i, 7500);
        end
        for i= 1, 8 do
            MakeInvulnerable("DrawBridge" ..i);
        end
        for i= 1, 12 do
            SVLib.SetInvisibility("PT_Barrier" ..i, true);
        end
        for i= 1, 4 do
            ForbidTechnology(Technologies.B_PowerPlant, i);
        end
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        SetHostile(1, 7);
        SetHostile(2, 7);
        SetHostile(3, 7);
        SetHostile(4, 7);

        EntityTracker.SetLimitOfType(Entities.PB_DarkTower2, 12);
        EntityTracker.SetLimitOfType(Entities.PB_DarkTower3, 12);
        EntityTracker.SetLimitOfType(Entities.PB_Tower2, 12);
        EntityTracker.SetLimitOfType(Entities.PB_Tower3, 12);

        CreateProvinces();
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
        -- Rain (normal)
        Logic.AddWeatherElement(2, 1*60, 1, 2, 5, 10);
        -- Rain (with snow)
        Logic.AddWeatherElement(2, 1*60, 1, 4, 5, 10);
        -- Winter (normal)
        Logic.AddWeatherElement(3, 2*60, 1, 3, 5, 10);
        -- Winter (without snow)
        Logic.AddWeatherElement(3, 4*60, 1, 7, 5, 10);
        -- Winter (normal)
        Logic.AddWeatherElement(3, 2*60, 1, 3, 5, 10);
        -- Winter (with rain)
        Logic.AddWeatherElement(3, 2*60, 1, 8, 5, 10);
        -- Rain (normal)
        Logic.AddWeatherElement(2, 1*60, 1, 2, 5, 10);
        -- Summer (normal)
        Logic.AddWeatherElement(1, 480, 1, 1, 5, 10);

        for i= 1, 12 do
            DestroyEntity("PT_Barrier" ..i);
        end
        for i= 1, 4 do
            AllowTechnology(Technologies.B_PowerPlant, i);
        end
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
    end,
}

-- ###################################################################### --
-- #                            CALLBACKS                               # --
-- ###################################################################### --

function CreateProvinces()
    local ProvinceNames = {
        "Drakonien",
        "Elmswald",
        "Runentale",
        "Sonnengrat",
    }

    local Troops = {
        {Entities.PU_LeaderPoleArm1, 0},
        {Entities.PU_LeaderBow2, 0},
        {Entities.PU_LeaderPoleArm1, 0},
        {Entities.PU_LeaderBow2, 0},
    }

    local PeaceTimeSelected = GetSelectedPeacetime();
    if PeaceTimeSelected == 2 or PeaceTimeSelected == 7 then
        Troops = {
            {Entities.PU_LeaderPoleArm1, 1},
            {Entities.PU_LeaderSword1, 2},
            {Entities.PU_LeaderBow2, 1},
            {Entities.PU_LeaderPoleArm2, 1},
            {Entities.PU_LeaderBow2, 1},
            {Entities.PU_LeaderBow2, 1},
        }
    elseif PeaceTimeSelected == 3 or PeaceTimeSelected == 8 then
        Troops = {
            {Entities.PU_LeaderPoleArm2, 2},
            {Entities.PU_LeaderSword2, 2},
            {Entities.PU_LeaderPoleArm2, 2},
            {Entities.PU_LeaderSword2, 2},
            {Entities.PU_LeaderBow2, 2},
            {Entities.PU_LeaderRifle1, 2},
            {Entities.PU_LeaderPoleArm2, 2},
            {Entities.PU_LeaderRifle1, 2},
        }
    elseif PeaceTimeSelected == 4 or PeaceTimeSelected == 9 then
        Troops = {
            {Entities.PU_LeaderPoleArm3, 3},
            {Entities.PU_LeaderSword3, 2},
            {Entities.PV_Cannon1, 0},
            {Entities.PU_LeaderBow3, 2},
            {Entities.PU_LeaderSword3, 2},
            {Entities.PU_LeaderBow3, 2},
            {Entities.PV_Cannon1, 0},
            {Entities.PU_LeaderPoleArm3, 3},
            {Entities.PU_LeaderBow3, 2},
            {Entities.PV_Cannon1, 0},
        }
    elseif PeaceTimeSelected == 5 or PeaceTimeSelected == 10 then
        Troops = {
            {Entities.PU_LeaderPoleArm4, 3},
            {Entities.PU_LeaderSword4, 3},
            {Entities.PU_LeaderPoleArm4, 3},
            {Entities.PV_Cannon3, 0},
            {Entities.PU_LeaderRifle2, 3},
            {Entities.PU_LeaderPoleArm4, 3},
            {Entities.PU_LeaderBow4, 3},
            {Entities.PV_Cannon3, 0},
            {Entities.PU_LeaderBow4, 3},
            {Entities.PU_LeaderRifle2, 3},
            {Entities.PU_LeaderSword4, 3},
            {Entities.PU_LeaderRifle2, 3},
        }
    end

    for i= 1, 4 do
        CreateHonorProvince(
            ProvinceNames[i], "PV"..i.."_Pos", 30, 0.5,
            "PV"..i.."_Hut1",
            "PV"..i.."_Hut2",
            "PV"..i.."_Hut3",
            "PV"..i.."_Hut4"
        );

        local ID = AiArmy.New(7, table.getn(Troops), GetPosition("PV"..i.."_ArmyPos"), 3000);
        AiArmy.SetFormationController(ID, CustomTroopFomrationController);
        for j= 1, table.getn(Troops) do
            AiArmy.SpawnTroop(ID, Troops[j][1], "PV"..i.."_ArmyPos", Troops[j][2]);
        end
        _G["PV"..i.."_Army"] = ID;
    end
end

-- Overwrite formation selection
function CustomTroopFomrationController(_ID)
    Stronghold.Unit:SetFormationOnCreate(_ID);
end

