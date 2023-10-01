---
--- Mod Loader for version 0.0.1.
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
	CMod.PushArchive("stronghold_s5mp\\legacy\\textureslow-0-0-1.bba");
	CMod.PushArchive("stronghold_s5mp\\legacy\\texturesmed-0-0-1.bba");
	CMod.PushArchive("stronghold_s5mp\\legacy\\textures-0-0-1.bba");
	CMod.PushArchive("stronghold_s5mp\\legacy\\system-0-0-1.bba");
    print("Stronghold mod loaded!");
end;

local Callbacks = {
	OnMapStart = OnMapStart;
};
return Callbacks;

