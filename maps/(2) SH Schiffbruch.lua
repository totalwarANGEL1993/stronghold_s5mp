SHS5MP_RulesDefinition = {
    -- Config version (Always an integer)
    Version = 2,

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

    -- Resources
    -- {Honor, Gold, Clay, Wood, Stone, Iron, Sulfur}
    Resources = {0, 1000, 1200, 1500, 550, 0, 0},

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
        AddPeriodicSummer(360);
        AddPeriodicRain(90);
        LocalMusic.UseSet = HIGHLANDMUSIC;
    end,

    -- Called after game start timer is over
    OnGameStart = function()
        SetHostile(1, 7);
        SetHostile(2, 7);
        CreatePassiveBanditCamps();
        CreateAggressiveBanditCamps();
        OverwriteOutlawCallbacks();
    end,

    -- Called after peacetime is over
    OnPeaceTimeOver = function()
    end,

    -- Called after game has been loaded (singleplayer)
    OnSaveLoaded = function()
    end,
}

-- -------------------------------------------------------------------------- --

function CreatePassiveBanditCamps()
    for k,v in pairs{1, 3} do
        Treasure.RandomChest("VCCamp" ..v.. "Chest1", 1000, 2000);
        for j= 1, 3 do
            CreateTroopSpawner(
                7, "VCCamp" ..v.. "Tent" ..j, nil, 1, 60, 3000,
                Entities.CU_BanditLeaderSword2,
                Entities.PU_LeaderBow1,
                Entities.CU_BanditLeaderBow1,
                Entities.PV_Cannon1,
                Entities.PU_LeaderPoleArm1
            );
        end
    end
end

function CreateAggressiveBanditCamps()
    local CampID = {2, 4};
    for i= 1, table.getn(CampID) do
        local v = CampID[i];
        Treasure.RandomChest("VCCamp" ..v.. "Chest1", 2000, 4000);

        -- Initalize spawner
        _G["VCCamp"] = {};
        _G["VCCamp" ..v.. "Attacks"] = 0;
        _G["VCCamp" ..v.. "Spawners"] = {};
        for j= 1, 5 do
            local ID = CreateTroopSpawner(
                7, "VCCamp" ..v.. "Tent" ..j, nil, 2, 60, 3000,
                Entities.PU_LeaderPoleArm1,
                Entities.CU_BanditLeaderSword2,
                Entities.PU_LeaderBow1,
                Entities.PV_Cannon1,
                Entities.CU_BanditLeaderBow1,
                Entities.PU_LeaderBow1
            );
            table.insert(_G["VCCamp" ..v.. "Spawners"], ID);
        end

        -- Initalize camps
        local TargetIndex = math.random(1,3);
        local ID = CreateOutlawCamp(
            7,
            "VCCamp" ..v.. "Center",
            "VCCamp" ..v.. "Pos" ..TargetIndex,
            2500,
            3,
            5 * 60,
            unpack(_G["VCCamp" ..v.. "Spawners"])
        );
        table.insert(_G["VCCamp"], ID);

        -- Allow attacks after 10 minutes
        AllowAttackForOutlawCamp(7, ID, false);
        Stronghold:AddDelayedAction((5 * 60) * 10, function(_ID)
            AllowAttackForOutlawCamp(7, _ID, true);
        end, ID);
    end
end

function OverwriteOutlawCallbacks()
    -- Outlaws choose next attack target by random
    GameCallback_SH_Logic_OutlawAttackFinished = function(_PlayerID, _CampID, _AttackResult)
        local Index = 2;
        if _G["VCCamp"][2] == _CampID then
            Index = 4;
        end
        -- Attack target
        local Target = "VCCamp" ..Index.. "Pos" ..math.random(1,3);
        SetAttackTargetOfOutlawCamp(_PlayerID, _CampID, Target);
        -- Attack strength
        _G["VCCamp" ..Index.. "Attacks"] = _G["VCCamp" ..Index.. "Attacks"] +1;
        if _G["VCCamp" ..Index.. "Attacks"] == 10 then
            SetAttackStrengthOfOutlawCamp(_PlayerID, _CampID, 4);
        end
        if _G["VCCamp" ..Index.. "Attacks"] == 15 then
            SetAttackStrengthOfOutlawCamp(_PlayerID, _CampID, 6);
        end
        if _G["VCCamp" ..Index.. "Attacks"] == 20 then
            SetAttackStrengthOfOutlawCamp(_PlayerID, _CampID, 8);
        end
    end
end

