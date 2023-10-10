local MapName = Framework.GetCurrentMapName();
local Path = "data\\maps\\user\\shs5mp_configs\\" ..MapName.. ".lua";
local ShPath = "data\\script\\stronghold\\sh.loader.lua";
Script.Load(ShPath);
if gvStrongholdLoaded then
    Script.Load(Path);
end
