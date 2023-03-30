--- 
--- 
--- 

function OnMapStart()
	CMod.PushArchive("stronghold_s5mp\\archive.bba");
end;

local Callbacks = {
	OnMapStart = OnMapStart;
};
return Callbacks;

