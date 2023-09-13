---
--- Mod Loader for version 0.0.1.
---

function OnMapStart()
	CMod.PushArchive("stronghold_s5mp\\legacy\\archive-0-0-1.bba");
end;

local Callbacks = {
	OnMapStart = OnMapStart;
};
return Callbacks;

