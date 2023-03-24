Script.Load("maps\\user\\cerberus\\loader.lua");
if Lib == nil then
    Script.Load("maps\\externalmap\\cerberus\\loader.lua");
end
assert(Lib ~= nil);

Lib.Require("comfort/AreEnemiesInArea");
Lib.Require("comfort/ArePositionsConnected");
Lib.Require("comfort/CreateNameForEntity");
Lib.Require("comfort/GetAllCannons");
Lib.Require("comfort/GetAllLeader");
Lib.Require("comfort/GetAllWorker");
Lib.Require("comfort/GetAllWorkplaces");
Lib.Require("comfort/GetDistance");
Lib.Require("comfort/GetEnemiesInArea");
Lib.Require("comfort/GetGeometricCenter");
Lib.Require("comfort/GetPlayerEntities");
Lib.Require("comfort/GetLanguage");
Lib.Require("comfort/GetResourceName");
Lib.Require("comfort/GetSeparatedTooltipText");
Lib.Require("comfort/GetValidEntitiesOfType");
Lib.Require("comfort/IsBuildingBeingUpgraded");
Lib.Require("comfort/IsInTable");
Lib.Require("comfort/IsValidEntity");
Lib.Require("comfort/KeyOf");

Lib.Require("module/archive/Archive");
Lib.Require("module/entity/EntityTracker");
Lib.Require("module/entity/SVLib");
Lib.Require("module/entity/Treasure");
Lib.Require("module/lua/Overwrite");
Lib.Require("module/mp/Syncer");
Lib.Require("module/trigger/Job");
Lib.Require("module/ui/BuyHero");
Lib.Require("module/ui/Placeholder");
Lib.Require("module/weather/WeatherMaker");

-- ---------- --

DetectStronghold = function()
    return false;
end

gvBasePath = gvBasePath or "script/stronghold/";
Script.Load(gvBasePath.. "detecter.lua");
if not DetectStronghold() then
    GUI.AddStaticNote("@color:255,0,0 ERROR: Can not find Stronghold!");
    return false;
end

-- ---------- --

Script.Load(gvBasePath.. "sh.main.lua");
Script.Load(gvBasePath.. "sh.utils.lua");

Script.Load(gvBasePath.. "sh.module.attraction.lua");
Script.Load(gvBasePath.. "sh.module.attraction.config.lua");
Script.Load(gvBasePath.. "sh.module.attraction.text.lua");

Script.Load(gvBasePath.. "sh.module.rights.lua");
Script.Load(gvBasePath.. "sh.module.rights.constants.lua");
Script.Load(gvBasePath.. "sh.module.rights.config.lua");
Script.Load(gvBasePath.. "sh.module.rights.text.lua");

Script.Load(gvBasePath.. "sh.module.unit.lua");
Script.Load(gvBasePath.. "sh.module.unit.config.lua");
Script.Load(gvBasePath.. "sh.module.unit.text.lua");

Script.Load(gvBasePath.. "sh.module.province.lua");
Script.Load(gvBasePath.. "sh.module.province.constants.lua");
Script.Load(gvBasePath.. "sh.module.province.config.lua");
Script.Load(gvBasePath.. "sh.module.province.text.lua");

Script.Load(gvBasePath.. "sh.module.construction.lua");
Script.Load(gvBasePath.. "sh.module.construction.config.lua");

Script.Load(gvBasePath.. "sh.module.spawner.lua");
Script.Load(gvBasePath.. "sh.module.outlaw.lua");
Script.Load(gvBasePath.. "sh.module.outlaw.constants.lua");

Script.Load(gvBasePath.. "module/economy.lua");
Script.Load(gvBasePath.. "module/building.lua");
Script.Load(gvBasePath.. "module/recruitment.lua");
Script.Load(gvBasePath.. "module/hero.lua");

