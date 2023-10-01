---
--- Mod Loader for current version.
---

local print = function(...)
	if LuaDebugger and LuaDebugger.Log then
		if table.getn(arg) > 1 then
			LuaDebugger.Log(arg)
		else
			LuaDebugger.Log(unpack(arg))
		end;
	end;
end;

function OnMapStart()
	CMod.PushArchive("stronghold_s5mp\\textureslow.bba");
	CMod.PushArchive("stronghold_s5mp\\texturesmed.bba");
	CMod.PushArchive("stronghold_s5mp\\textures.bba");
	CMod.PushArchive("stronghold_s5mp\\system.bba");
    print("Stronghold mod loaded!");
end;

local Callbacks = {
	OnMapStart = OnMapStart;
};
return Callbacks;

