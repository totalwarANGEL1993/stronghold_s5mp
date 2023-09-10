local MapName = Framework.GetCurrentMapName();
local Path = "data\\maps\\user\\shs5mp_configs\\" ..MapName.. ".lua";
local ShPath = "data\\maps\\user\\stronghold_s5mp\\sh.loader.lua";
Script.Load(ShPath);
if gvStrongholdLoaded then
    Script.Load(Path);
end

