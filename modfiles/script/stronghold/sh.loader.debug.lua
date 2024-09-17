gvStronghold_Loaded = true;

-- -------------------------------------------------------------------------- --
-- CHECK COMMUNITY SERVER                                                     --
-- -------------------------------------------------------------------------- --

-- Check if the game is runnung on the community server. Singleplayer Extended
-- and Multiplayer are both fine.
-- (SP Ext may have some questionable hacks going on though...)
if not CMod then
    GUI.AddStaticNote("@color:255,0,0 ERROR: Community Server is required!");
    gvStronghold_Loaded = false;
    return false;
end

-- -------------------------------------------------------------------------- --
-- LOAD CERBERUS                                                              --
-- -------------------------------------------------------------------------- --

-- Try loading lib from the archive
gvCerberusPath = gvCerberusPath or "E:\\Siedler\\Projekte\\stronghold_s5mp\\";
Script.Load(gvCerberusPath.. "cerberus\\loader.lua");
if Lib == nil then
    gvCerberusPath = "data\\script\\";
    Script.Load(gvCerberusPath.. "cerberus\\loader.lua");
end
Lib.AddPath(gvCerberusPath);
-- Check lib has been loaded
gvStronghold_Loaded = Lib ~= nil;
assert(Lib ~= nil);

-- Load comforts
Lib.Require("comfort/AreEnemiesInArea");
Lib.Require("comfort/ArePositionsConnected");
Lib.Require("comfort/ConvertSecondsToString");
Lib.Require("comfort/CreateNameForEntity");
Lib.Require("comfort/GetReachablePosition");
Lib.Require("comfort/CreateWoodPile");
Lib.Require("comfort/GetAlliesInArea");
Lib.Require("comfort/GetAngleBetween");
Lib.Require("comfort/GetCirclePosition");
Lib.Require("comfort/GetDistance");
Lib.Require("comfort/GetEnemiesInArea");
Lib.Require("comfort/GetHealth");
Lib.Require("comfort/GetMaxAmountOfPlayer");
Lib.Require("comfort/GetGeometricCenter");
Lib.Require("comfort/GetPlayerEntities");
Lib.Require("comfort/GetPositionsBetween");
Lib.Require("comfort/GetLanguage");
Lib.Require("comfort/GetResourceName");
Lib.Require("comfort/GetSeparatedTooltipText");
Lib.Require("comfort/GetUpgradedEntityType");
Lib.Require("comfort/IsBuildingBeingUpgraded");
Lib.Require("comfort/IsFighting");
Lib.Require("comfort/IsTraining");
Lib.Require("comfort/IsInTable");
Lib.Require("comfort/IsValidEntity");
Lib.Require("comfort/IsValidPosition");
Lib.Require("comfort/KeyOf");
Lib.Require("comfort/ShuffleTable");

-- Load modules
Lib.Require("module/ai/AiArmy");
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
Lib.Require("module/io/NonPlayerMerchant");
Lib.Require("module/trigger/Job");
Lib.Require("module/trigger/Delay");
Lib.Require("module/ui/Placeholder");
Lib.Require("module/weather/WeatherMaker");

-- -------------------------------------------------------------------------- --
-- LOAD STRONGHOLD                                                            --
-- -------------------------------------------------------------------------- --

---@diagnostic disable-next-line: undefined-global
gvStronghold_Path = gvStronghold_Path or "E:\\Siedler\\Projekte\\stronghold_s5mp\\modfiles\\script\\stronghold\\";

-- Define check function
DetectStronghold = function()
    return false;
end
-- Load detecter script
-- (It redefines the function above to return true)
Script.Load(gvStronghold_Path.. "sh.detecter.lua");
if not DetectStronghold() then
    gvStronghold_Path = "data\\script\\stronghold\\";
    Script.Load(gvStronghold_Path.. "sh.detecter.lua");
end
-- Check if stronghold has been loaded
if not DetectStronghold() then
    GUI.AddStaticNote("@color:255,0,0 ERROR: Can not find Stronghold!");
    gvStronghold_Loaded = false;
    return false;
end

-- Finally load the mod.
-- (A nightmarish orgy of cross-dependencies...)

Script.Load(gvStronghold_Path.. "sh.main.lua");
Script.Load(gvStronghold_Path.. "sh.main.constants.lua");
Script.Load(gvStronghold_Path.. "sh.main.config.lua");
Script.Load(gvStronghold_Path.. "sh.utils.lua");
---
Script.Load(gvStronghold_Path.. "sh.module.rights.lua");
Script.Load(gvStronghold_Path.. "sh.module.rights.constants.lua");
Script.Load(gvStronghold_Path.. "sh.module.rights.config.lua");
---
Script.Load(gvStronghold_Path.. "sh.module.player.lua");
Script.Load(gvStronghold_Path.. "sh.module.player.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.attraction.lua");
Script.Load(gvStronghold_Path.. "sh.module.attraction.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.populace.lua");
Script.Load(gvStronghold_Path.. "sh.module.populace.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.building.lua");
Script.Load(gvStronghold_Path.. "sh.module.building.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.construction.lua");
Script.Load(gvStronghold_Path.. "sh.module.construction.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.economy.lua");
Script.Load(gvStronghold_Path.. "sh.module.economy.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.economy.text.lua");
Script.Load(gvStronghold_Path.. "sh.module.trade.lua");
Script.Load(gvStronghold_Path.. "sh.module.trade.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.hero.lua");
Script.Load(gvStronghold_Path.. "sh.module.hero.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.hero.perk.lua");
Script.Load(gvStronghold_Path.. "sh.module.hero.perk.constants.lua");
Script.Load(gvStronghold_Path.. "sh.module.hero.perk.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.province.lua");
Script.Load(gvStronghold_Path.. "sh.module.province.constants.lua");
Script.Load(gvStronghold_Path.. "sh.module.province.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.recruit.lua");
Script.Load(gvStronghold_Path.. "sh.module.recruit.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.statistic.lua");
Script.Load(gvStronghold_Path.. "sh.module.unit.lua");
Script.Load(gvStronghold_Path.. "sh.module.unit.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.mercenary.lua");
Script.Load(gvStronghold_Path.. "sh.module.mercenary.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.trap.lua");
Script.Load(gvStronghold_Path.. "sh.module.trap.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.wall.lua");
Script.Load(gvStronghold_Path.. "sh.module.wall.config.lua");
---
Script.Load(gvStronghold_Path.. "sh.module.multiplayer.lua");
Script.Load(gvStronghold_Path.. "sh.module.multiplayer.config.lua");
---
Script.Load(gvStronghold_Path.. "sh.module.ai.lua");
Script.Load(gvStronghold_Path.. "sh.module.ai.config.lua");
Script.Load(gvStronghold_Path.. "sh.module.ai.animal.lua");
Script.Load(gvStronghold_Path.. "sh.module.ai.hero.lua");

