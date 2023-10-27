SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 3,

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
        UseWeatherSet("DesertWeatherSet");
        AddPeriodicSummer(360);
        LocalMusic.UseSet = MEDITERANEANMUSIC;
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        ForbidTechnology(Technologies.B_Palisade, 1);
        ForbidTechnology(Technologies.B_Wall, 1);
        SetupProvinces();
        SetupCamps();
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
        SetHostile(1, 7);
        SetHostile(2, 7);
        SetHostile(3, 7);
        SetHostile(4, 7);
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
    end,
}

-- -------------------------------------------------------------------------- --

function SetupProvinces()
    local Peacetime = GetSelectedPeacetime();

    -- Province produces 30 + (10 * (Peacetime -1)) honor. Additionaly
    -- upgrading the villge center increases the amount by 50% each.
    CreateHonorProvince(
        "Oasis de Lune",
        "Province1Pos",
        math.floor((30 + (10 * (Peacetime -1))) + 0.5),
        0.5,
        "Province1Hut1",
        "Province1Hut2",
        "Province1Hut3",
        "Province1Hut4",
        "Province1Hut5",
        "Province1Hut6",
        "Province1Hut7",
        "Province1Hut8"
    );

    -- Province produces 30 + (10 * (Peacetime -1)) honor. Additionaly
    -- upgrading the villge center increases the amount by 50% each.
    CreateHonorProvince(
        "Oasis de Sene",
        "Province2Pos",
        math.floor((30 + (10 * (Peacetime -1))) + 0.5),
        0.5,
        "Province2Hut1",
        "Province2Hut2",
        "Province2Hut3",
        "Province2Hut4",
        "Province2Hut5",
        "Province2Hut6",
        "Province2Hut7",
        "Province2Hut8"
    );

    -- Central province produces 600 + (100 * (Peacetime -1)) wood. Additionaly
    -- upgrading the villge center increases the amount by 75% each.
    CreateResourceProvince(
        "la Source de Mystere",
        "Province3Pos",
        ResourceType.WoodRaw,
        math.floor((600 + (100 * (Peacetime -1))) + 0.5),
        0.75,
        "Province3Hut1",
        "Province3Hut2"
    )
end

-- -------------------------------------------------------------------------- --

function SetupCamps()
    local Peacetime = GetSelectedPeacetime();
    if Peacetime == 1 then
        SetupCampsWS0();
    elseif Peacetime == 2 then
        SetupCampsWS10();
    elseif Peacetime == 3 then
        SetupCampsWS20();
    elseif Peacetime == 4 then
        SetupCampsWS30();
    else
        SetupCampsWS40();
    end
end

function SetupCampsWS0()
    for j= 1, 2 do
        local CampID = DelinquentsCampCreate {
            HomePosition = "Province" ..j.. "Pos",
            RodeLength = 4500,
            Strength = 7,
        };

        DelinquentsCampAddSpawner(
            CampID, "Outpost" ..j, 120, 1,
            Entities.PU_LeaderSword2,
            Entities.PU_LeaderBow2,
            Entities.PU_LeaderBow2
        );
        for i= 1, 4 do
            DelinquentsCampAddSpawner(
                CampID, "OP" ..j.. "Tent" ..i, 120, 1,
                Entities.PU_LeaderPoleArm1,
                Entities.PU_LeaderPoleArm1,
                Entities.PU_LeaderBow1
            );
        end
    end
end

function SetupCampsWS10()
    for j= 1, 2 do
        local CampID = DelinquentsCampCreate {
            HomePosition = "Province" ..j.. "Pos",
            RodeLength = 4500,
            Strength = 7,
        };

        DelinquentsCampAddSpawner(
            CampID, "Outpost" ..j, 120, 2,
            Entities.PU_LeaderSword2,
            Entities.PU_LeaderBow2,
            Entities.PU_LeaderBow2
        );
        for i= 1, 4 do
            DelinquentsCampAddSpawner(
                CampID, "OP" ..j.. "Tent" ..i, 120, 2,
                Entities.PU_LeaderSword1,
                Entities.PU_LeaderPoleArm1,
                Entities.PU_LeaderBow1
            );
        end
    end
end

function SetupCampsWS20()
    for j= 1, 2 do
        local CampID = DelinquentsCampCreate {
            HomePosition = "Province" ..j.. "Pos",
            RodeLength = 4500,
            Strength = 7,
        };

        DelinquentsCampAddSpawner(
            CampID, "Outpost" ..j, 90, 2,
            Entities.PU_LeaderSword2,
            Entities.PU_LeaderBow2,
            Entities.PU_LeaderBow2
        );
        for i= 1, 4 do
            DelinquentsCampAddSpawner(
                CampID, "OP" ..j.. "Tent" ..i, 90, 2,
                Entities.PU_LeaderPoleArm2,
                Entities.PU_LeaderBow2
            );
        end
    end
end

function SetupCampsWS30()
    for j= 1, 2 do
        ReplaceEntity("OP" ..j.. "Tower1", Entities.PB_Tower2);
        ReplaceEntity("OP" ..j.. "Tower2", Entities.PB_Tower2);

        local CampID = DelinquentsCampCreate {
            HomePosition = "Province" ..j.. "Pos",
            RodeLength = 4500,
            Strength = 7,
        };

        DelinquentsCampAddSpawner(
            CampID, "Outpost" ..j, 90, 3,
            Entities.PU_LeaderSword3,
            Entities.PU_LeaderBow2,
            Entities.PU_LeaderBow2
        );
        for i= 1, 4 do
            DelinquentsCampAddSpawner(
                CampID, "OP" ..j.. "Tent" ..i, 90, 3,
                Entities.PU_LeaderPoleArm2,
                Entities.PU_LeaderBow3
            );
        end
    end
end

function SetupCampsWS40()
    for j= 1, 2 do
        ReplaceEntity("OP" ..j.. "Tower1", Entities.PB_Tower3);
        ReplaceEntity("OP" ..j.. "Tower2", Entities.PB_Tower3);

        local CampID = DelinquentsCampCreate {
            HomePosition = "Province" ..j.. "Pos",
            RodeLength = 4500,
            Strength = 7,
        };

        DelinquentsCampAddSpawner(
            CampID, "Outpost" ..j, 60, 3,
            Entities.PU_LeaderSword4,
            Entities.PU_LeaderRifle2,
            Entities.PU_LeaderRifle2,
            Entities.PV_Cannon3
        );
        for i= 1, 4 do
            DelinquentsCampAddSpawner(
                CampID, "OP" ..j.. "Tent" ..i, 60, 3,
                Entities.PU_LeaderPoleArm3,
                Entities.PU_LeaderPoleArm3,
                Entities.PU_LeaderBow3,
                Entities.PV_Cannon3
            );
        end
    end
end

