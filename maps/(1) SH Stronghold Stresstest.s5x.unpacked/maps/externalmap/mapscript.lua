local MapName = Framework.GetCurrentMapName();
local ShPath = "data\\script\\stronghold\\sh.loader.debug.lua";
local Path = "data\\maps\\user\\shs5mp_configs\\" ..MapName.. ".lua";
Script.Load(ShPath);
if gvStronghold_Loaded then
    Script.Load(Path);
end

-- Load test stuff
Script.Load("E:\\Siedler\\Projekte\\stronghold_s5mp\\maps\\(1) SH Stronghold Stresstest.s5x.unpacked\\maps\\externalmap\\main.lua");
if not gvTestmapMainLoaded then
    Script.Load("data\\maps\\externalmap\\main.lua");
end

