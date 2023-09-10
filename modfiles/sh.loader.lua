gvStrongholdLoaded = true;
gvStrongholdVersion = 1;

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
-- (Using the path that is supposed to be used for bba files)
Script.Load("data\\script\\cerberus\\loader.lua");
-- Check lib has been loaded
gvStrongholdLoaded = Lib ~= nil;
assert(Lib ~= nil);

-- Load comforts
Lib.Require("comfort/AreEnemiesInArea");
Lib.Require("comfort/ArePositionsConnected");
Lib.Require("comfort/ConvertSecondsToString");
Lib.Require("comfort/CreateNameForEntity");
Lib.Require("comfort/CreateWoodPile");
Lib.Require("comfort/GetDistance");
Lib.Require("comfort/GetEnemiesInArea");
Lib.Require("comfort/GetGeometricCenter");
Lib.Require("comfort/GetPlayerEntities");
Lib.Require("comfort/GetLanguage");
Lib.Require("comfort/GetResourceName");
Lib.Require("comfort/GetSeparatedTooltipText");
Lib.Require("comfort/IsBuildingBeingUpgraded");
Lib.Require("comfort/IsInTable");
Lib.Require("comfort/IsValidEntity");
Lib.Require("comfort/KeyOf");

-- Load modules
Lib.Require("module/archive/Archive");
Lib.Require("module/camera/FreeCam");
Lib.Require("module/entity/EntityTracker");
Lib.Require("module/entity/SVLib");
Lib.Require("module/entity/Treasure");
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
local ModPath = gvTestPath or "data\\script\\stronghold\\";

-- Define check function
DetectStronghold = function()
    return false;
end
-- Load detecter script
-- (It redefines the function above to return true)
Script.Load(ModPath.. "sh.detecter.lua");
-- Check if stronghold has been loaded
if not DetectStronghold() then
    GUI.AddStaticNote("@color:255,0,0 ERROR: Can not find Stronghold!");
    gvStrongholdLoaded = false;
    return false;
end

-- Finally load the mod.
-- (A nightmarish orgy of cross-dependencies...)

Script.Load(ModPath.. "sh.main.lua");
Script.Load(ModPath.. "sh.main.config.lua");
Script.Load(ModPath.. "sh.utils.lua");
---
Script.Load(ModPath.. "sh.module.rights.lua");
Script.Load(ModPath.. "sh.module.rights.constants.lua");
Script.Load(ModPath.. "sh.module.rights.config.lua");
---
Script.Load(ModPath.. "sh.module.attraction.lua");
Script.Load(ModPath.. "sh.module.attraction.config.lua");
Script.Load(ModPath.. "sh.module.building.lua");
Script.Load(ModPath.. "sh.module.building.config.lua");
Script.Load(ModPath.. "sh.module.construction.lua");
Script.Load(ModPath.. "sh.module.construction.config.lua");
Script.Load(ModPath.. "sh.module.economy.lua");
Script.Load(ModPath.. "sh.module.economy.config.lua");
Script.Load(ModPath.. "sh.module.economy.text.lua");
Script.Load(ModPath.. "sh.module.hero.lua");
Script.Load(ModPath.. "sh.module.hero.config.lua");
Script.Load(ModPath.. "sh.module.province.lua");
Script.Load(ModPath.. "sh.module.province.constants.lua");
Script.Load(ModPath.. "sh.module.province.config.lua");
Script.Load(ModPath.. "sh.module.recruitment.lua");
Script.Load(ModPath.. "sh.module.recruitment.config.lua");
Script.Load(ModPath.. "sh.module.statistic.lua");
Script.Load(ModPath.. "sh.module.unit.lua");
Script.Load(ModPath.. "sh.module.unit.config.lua");
---
Script.Load(ModPath.. "sh.module.spawner.lua");
Script.Load(ModPath.. "sh.module.spawner.config.lua");
Script.Load(ModPath.. "sh.module.outlaw.lua");
Script.Load(ModPath.. "sh.module.outlaw.constants.lua");
---
Script.Load(ModPath.. "sh.module.multiplayer.lua");
Script.Load(ModPath.. "sh.module.multiplayer.config.lua");

