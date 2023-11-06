gvStrongholdLoaded = true;

-- -------------------------------------------------------------------------- --
-- CHECK COMMUNITY SERVER                                                     --
-- -------------------------------------------------------------------------- --

-- Check if the game is runnung on the community server. Singleplayer Extended
-- and Multiplayer are both fine.
-- (SP Ext may have some questionable hacks going on though...)
if not CMod then
    GUI.AddStaticNote("@color:255,0,0 ERROR: Community Server is required!");
    gvStrongholdLoaded = false;
    return false;
end

-- -------------------------------------------------------------------------- --
-- LOAD CERBERUS                                                              --
-- -------------------------------------------------------------------------- --

-- Try loading lib from the archive
gvCerberusPath = gvCerberusPath or "data\\script\\";
Script.Load(gvCerberusPath.. "cerberus\\loader.lua");
Lib.AddPath(gvCerberusPath);
-- Check lib has been loaded
gvStrongholdLoaded = Lib ~= nil;
assert(Lib ~= nil);

-- Load comforts
Lib.Require("comfort/AreEnemiesInArea");
Lib.Require("comfort/ArePositionsConnected");
Lib.Require("comfort/ConvertSecondsToString");
Lib.Require("comfort/CreateNameForEntity");
Lib.Require("comfort/CreateWoodPile");
Lib.Require("comfort/GetCirclePosition");
Lib.Require("comfort/GetDistance");
Lib.Require("comfort/GetEnemiesInArea");
Lib.Require("comfort/GetHealth");
Lib.Require("comfort/GetGeometricCenter");
Lib.Require("comfort/GetPlayerEntities");
Lib.Require("comfort/GetLanguage");
Lib.Require("comfort/GetResourceName");
Lib.Require("comfort/GetSeparatedTooltipText");
Lib.Require("comfort/GetUpgradedEntityType");
Lib.Require("comfort/IsBuildingBeingUpgraded");
Lib.Require("comfort/IsFighting");
Lib.Require("comfort/IsInTable");
Lib.Require("comfort/IsValidEntity");
Lib.Require("comfort/IsValidPosition");
Lib.Require("comfort/KeyOf");

-- Load modules
Lib.Require("module/ai/AiArmyManager");
Lib.Require("module/ai/AiArmyRefiller");
Lib.Require("module/archive/Archive");
Lib.Require("module/camera/FreeCam");
Lib.Require("module/entity/EntityTracker");
Lib.Require("module/entity/SVLib");
Lib.Require("module/entity/Treasure");
Lib.Require("module/lua/Extension");
Lib.Require("module/lua/Overwrite");
Lib.Require("module/mp/BuyHero");
Lib.Require("module/mp/Syncer");
Lib.Require("module/trigger/Job");
Lib.Require("module/ui/Placeholder");
Lib.Require("module/weather/WeatherMaker");

-- -------------------------------------------------------------------------- --
-- LOAD STRONGHOLD                                                            --
-- -------------------------------------------------------------------------- --

---@diagnostic disable-next-line: undefined-global
gvStrongholdPath = gvStrongholdPath or "data\\script\\stronghold\\";

-- Define check function
DetectStronghold = function()
    return false;
end
-- Load detecter script
-- (It redefines the function above to return true)
Script.Load(gvStrongholdPath.. "sh.detecter.lua");
-- Check if stronghold has been loaded
if not DetectStronghold() then
    GUI.AddStaticNote("@color:255,0,0 ERROR: Can not find Stronghold!");
    gvStrongholdLoaded = false;
    return false;
end

-- Finally load the mod.
-- (A nightmarish orgy of cross-dependencies...)

Script.Load(gvStrongholdPath.. "sh.main.lua");
Script.Load(gvStrongholdPath.. "sh.main.config.lua");
Script.Load(gvStrongholdPath.. "sh.utils.lua");
---
Script.Load(gvStrongholdPath.. "sh.module.rights.lua");
Script.Load(gvStrongholdPath.. "sh.module.rights.constants.lua");
Script.Load(gvStrongholdPath.. "sh.module.rights.config.lua");
---
Script.Load(gvStrongholdPath.. "sh.module.attraction.lua");
Script.Load(gvStrongholdPath.. "sh.module.attraction.config.lua");
Script.Load(gvStrongholdPath.. "sh.module.building.lua");
Script.Load(gvStrongholdPath.. "sh.module.building.config.lua");
Script.Load(gvStrongholdPath.. "sh.module.construction.lua");
Script.Load(gvStrongholdPath.. "sh.module.construction.config.lua");
Script.Load(gvStrongholdPath.. "sh.module.economy.lua");
Script.Load(gvStrongholdPath.. "sh.module.economy.config.lua");
Script.Load(gvStrongholdPath.. "sh.module.economy.text.lua");
Script.Load(gvStrongholdPath.. "sh.module.hero.lua");
Script.Load(gvStrongholdPath.. "sh.module.hero.config.lua");
Script.Load(gvStrongholdPath.. "sh.module.province.lua");
Script.Load(gvStrongholdPath.. "sh.module.province.constants.lua");
Script.Load(gvStrongholdPath.. "sh.module.province.config.lua");
Script.Load(gvStrongholdPath.. "sh.module.recruit.lua");
Script.Load(gvStrongholdPath.. "sh.module.recruit.config.lua");
Script.Load(gvStrongholdPath.. "sh.module.statistic.lua");
Script.Load(gvStrongholdPath.. "sh.module.unit.lua");
Script.Load(gvStrongholdPath.. "sh.module.unit.config.lua");
---
Script.Load(gvStrongholdPath.. "sh.module.multiplayer.lua");
Script.Load(gvStrongholdPath.. "sh.module.multiplayer.config.lua");
---
Script.Load(gvStrongholdPath.. "sh.module.ai.lua");

