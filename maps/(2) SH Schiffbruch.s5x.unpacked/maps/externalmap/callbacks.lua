--- 
--- Community Server Callbacks
---
--- - OnMapStart
---   Loads the archive of the mod before the map is even started. Needed to
---   put the changed files on the stack.
--- 

local OnMapStart;

local print = function(...)
	if LuaDebugger and LuaDebugger.Log then
		if table.getn(arg) > 1 then
			LuaDebugger.Log(arg)
		else
			LuaDebugger.Log(unpack(arg))
		end;
	end;
end;

OnMapStart = function()
    CMod.PushArchive("stronghold_s5mp\\archive.bba");
    print("Stronghold mod loaded!");
end

local Callbacks = {
	OnMapStart = OnMapStart;
};
return Callbacks;

