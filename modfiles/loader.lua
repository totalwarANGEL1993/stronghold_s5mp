if not CMod then
    GUI.AddStaticNote("@color:255,0,0 ERROR: Community Server is required!");
    return false;
end

Script.Load("cerberus\\loader.lua");
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

Script.Load("data\\maps\\user\\stronghold_s5mp\\script\\detecter.lua");
if not DetectStronghold() then
    GUI.AddStaticNote("@color:255,0,0 ERROR: Can not find Stronghold!");
    return false;
end

-- ---------- --

---@diagnostic disable-next-line: undefined-global
local ModPath = gvTestPath or "data\\script\\stronghold\\";

Script.Load(ModPath.. "sh.main.lua");
Script.Load(ModPath.. "sh.main.config.lua");
Script.Load(ModPath.. "sh.main.text.lua");

Script.Load(ModPath.. "sh.utils.lua");

Script.Load(ModPath.. "sh.module.attraction.lua");
Script.Load(ModPath.. "sh.module.attraction.config.lua");
Script.Load(ModPath.. "sh.module.attraction.text.lua");

Script.Load(ModPath.. "sh.module.rights.lua");
Script.Load(ModPath.. "sh.module.rights.constants.lua");
Script.Load(ModPath.. "sh.module.rights.config.lua");
Script.Load(ModPath.. "sh.module.rights.text.lua");

Script.Load(ModPath.. "sh.module.unit.lua");
Script.Load(ModPath.. "sh.module.unit.config.lua");
Script.Load(ModPath.. "sh.module.unit.text.lua");

Script.Load(ModPath.. "sh.module.hero.lua");
Script.Load(ModPath.. "sh.module.hero.config.lua");
Script.Load(ModPath.. "sh.module.hero.text.lua");

Script.Load(ModPath.. "sh.module.economy.lua");
Script.Load(ModPath.. "sh.module.economy.config.lua");
Script.Load(ModPath.. "sh.module.economy.text.lua");

Script.Load(ModPath.. "sh.module.recruitment.lua");
Script.Load(ModPath.. "sh.module.recruitment.config.lua");
Script.Load(ModPath.. "sh.module.recruitment.text.lua");

Script.Load(ModPath.. "sh.module.province.lua");
Script.Load(ModPath.. "sh.module.province.constants.lua");
Script.Load(ModPath.. "sh.module.province.config.lua");
Script.Load(ModPath.. "sh.module.province.text.lua");

Script.Load(ModPath.. "sh.module.construction.lua");
Script.Load(ModPath.. "sh.module.construction.config.lua");

Script.Load(ModPath.. "sh.module.building.lua");
Script.Load(ModPath.. "sh.module.building.config.lua");
Script.Load(ModPath.. "sh.module.building.text.lua");

Script.Load(ModPath.. "sh.module.spawner.lua");
Script.Load(ModPath.. "sh.module.outlaw.lua");
Script.Load(ModPath.. "sh.module.outlaw.constants.lua");

