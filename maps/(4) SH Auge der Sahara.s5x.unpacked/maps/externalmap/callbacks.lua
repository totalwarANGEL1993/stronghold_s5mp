--- 
--- Community Server Callbacks
---
--- - OnMapStart
---   Loads the archive of the mod before the map is even started. Needed to
---   put the changed files on the stack.
--- 

local Callbacks = {
	OnMapStart = function()
        CMod.PushArchive("stronghold_s5mp\\archive.bba");
    end;
};
return Callbacks;

