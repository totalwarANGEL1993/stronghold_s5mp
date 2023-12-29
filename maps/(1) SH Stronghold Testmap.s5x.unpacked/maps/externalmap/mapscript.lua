local MapName = Framework.GetCurrentMapName();
local Path = "data\\maps\\user\\shs5mp_configs\\" ..MapName.. ".lua";
local ShPath = "data\\script\\stronghold\\sh.loader.lua";
Script.Load(ShPath);
if gvStronghold_Loaded then
    Script.Load(Path);
end

Script.Load("E:/Siedler/Projekte/stronghold_s5mp/maps/(1) SH Stronghold Testmap.s5x.unpacked/maps/externalmap/main.lua");

