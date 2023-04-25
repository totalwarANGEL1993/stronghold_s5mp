--- 
--- Util functions
---
--- This script contains comforts specific to Stronghold.
--- 

Stronghold = Stronghold or {};

Stronghold.Utils = {};

-- -------------------------------------------------------------------------- --
-- Find trees
-- (Limited to 16 per type but Vanilla compatible)

gvTreeTypeTable = {};

function GetTreeAtPosition(_X, _Y, _Range, _Amount, _Type)
    FillTreeTable();
    if CEntityIterator then
        return GetTreeAtPositionWithIterator(_X, _Y, _Range, _Amount);
    end

    _Amount = math.max(_Amount or 1, 1);
    _Type = _Type or 0;

    local List = {};
    local Statics = {Logic.GetEntitiesInArea(_Type, _X, _Y, _Range, 16, 32)};
    if Statics[1] <= 16 then
        for i= 2, Statics[1]+1 do
            if table.getn(List) >= _Amount then
                break;
            end
            if IsTree(Statics[i]) then
                table.insert(List, Statics[i]);
            end
        end
    end
    for k,v in pairs(gvTreeTypeTable) do
        if table.getn(List) >= _Amount then
            break;
        end
        for _, Tree in (GetTreeAtPosition(_X, _Y, _Range, Entities[k])) do
            if table.getn(List) >= _Amount then
                break;
            end
            table.insert(List, Tree);
        end
    end
    return List;
end

function GetTreeAtPositionWithIterator(_X, _Y, _Range, _Amount)
    local List = {};
    for ID in CEntityIterator.Iterator(CEntityIterator.InRangeFilter(_X, _Y, _Range)) do
        if table.getn(List) >= _Amount then
            break;
        end
        if IsTree(ID) then
            table.insert(List, ID);
        end
    end
    return List;
end

function IsTree(_Entity)
    if _Entity and IsExisting(_Entity) then
        local ID = GetID(_Entity);
        local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(ID));
        return gvTreeTypeTable[TypeName] == true;
    end
    return false;
end

function FillTreeTable()
    gvTreeTypeTable = gvTreeTypeTable or {};
    for k,v in pairs(Entities) do
        if v ~= Entities.XD_TreeStump1 then
            for _, TypePart in pairs{"Tree", "Pine", "Fir", "Cypress", "Willow"} do
                if (string.find(k, TypePart)) then
                    gvTreeTypeTable[k] = true;
                    break;
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- UI Tools

function Stronghold.Utils:OverwriteInterfaceTools()
    InterfaceTool_HasPlayerEnoughResources_Feedback = function(_Costs)
        local PlayerID = GetLocalPlayerID();
        return HasPlayerEnoughResourcesFeedback(PlayerID, _Costs);
    end

    InterfaceTool_CreateCostString = function(_Costs)
        local PlayerID = GUI.GetPlayerID();
        return FormatCostString(PlayerID, _Costs);
    end
end

function HasPlayerEnoughResourcesFeedback(_PlayerID, _Costs)
    local MsgString = ""

    local Honor     = GetHonor(_PlayerID);
    local Knowledge = GetKnowledge(_PlayerID);
    local GoldRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.GoldRaw);
	local Gold      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Gold);
    local ClayRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.ClayRaw);
    local Clay      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Clay);
	local WoodRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.WoodRaw);
	local Wood      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Wood);
	local IronRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.IronRaw);
	local Iron      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Iron);
	local StoneRaw  = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.StoneRaw);
	local Stone     = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Stone);
    local SulfurRaw = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.SulfurRaw);
    local Sulfur    = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Sulfur);

    if _Costs[ResourceType.Honor] ~= nil
	and _Costs[ResourceType.Honor] ~= 0
    and _Costs[ResourceType.Honor] - Honor > 0 then
        MsgString = string.format(
            XGUIEng.GetStringTableText("InGameMsgStrings/GUI_NotEnoughHonor"),
            _Costs[ResourceType.Honor] - Honor
        );
		GUI.AddNote(MsgString);
        Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_INFO_NotEnough, 100);
    end

    if _Costs[ResourceType.Knowledge] ~= nil
	and _Costs[ResourceType.Knowledge] ~= 0
    and _Costs[ResourceType.Knowledge] - Knowledge > 0 then
        MsgString = string.format(
            XGUIEng.GetStringTableText("InGameMsgStrings/GUI_NotEnoughKnowledge"),
            _Costs[ResourceType.Knowledge] - Knowledge
        );
		GUI.AddNote(MsgString);
        Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_INFO_NotEnough, 100);
    end

	if 	_Costs[ResourceType.Sulfur] ~= nil
	and _Costs[ResourceType.Sulfur] ~= 0
    and (Sulfur+SulfurRaw) < _Costs[ResourceType.Sulfur] then
		MsgString = string.format(
            XGUIEng.GetStringTableText("InGameMsgStrings/GUI_NotEnoughSulfur"),
            _Costs[ResourceType.Sulfur] - (Sulfur+SulfurRaw)
        );
		GUI.AddNote(MsgString);
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Sulfur, _Costs[ResourceType.Sulfur] - (Sulfur+SulfurRaw));
	end

	if _Costs[ResourceType.Iron] ~= nil
	and _Costs[ResourceType.Iron] ~= 0
    and (Iron+IronRaw) < _Costs[ResourceType.Iron] then
		MsgString = string.format(
            XGUIEng.GetStringTableText("InGameMsgStrings/GUI_NotEnoughIron"),
            _Costs[ResourceType.Iron] - (Iron+IronRaw)
        );
		GUI.AddNote(MsgString);
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Iron, _Costs[ResourceType.Iron] - (Iron+IronRaw));
	end

	if _Costs[ResourceType.Stone] ~= nil
	and _Costs[ResourceType.Stone] ~= 0
    and (Stone+StoneRaw) < _Costs[ResourceType.Stone] then
		MsgString = string.format(
            XGUIEng.GetStringTableText("InGameMsgStrings/GUI_NotEnoughStone"),
            _Costs[ResourceType.Stone] - (Stone+StoneRaw)
        );
		GUI.AddNote(MsgString);
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Stone, _Costs[ResourceType.Stone] - (Stone+StoneRaw));
	end

	if _Costs[ResourceType.Clay] ~= nil
	and _Costs[ResourceType.Clay] ~= 0
    and (Clay+ClayRaw) < _Costs[ResourceType.Clay]  then
		MsgString = string.format(
            XGUIEng.GetStringTableText("InGameMsgStrings/GUI_NotEnoughClay"),
            _Costs[ResourceType.Clay] - (Clay+ClayRaw)
        );
		GUI.AddNote(MsgString);
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Clay, _Costs[ResourceType.Clay] - (Clay+ClayRaw));
	end

	if _Costs[ResourceType.Wood] ~= nil
	and _Costs[ResourceType.Wood] ~= 0
    and (Wood+WoodRaw) < _Costs[ResourceType.Wood]  then
		MsgString = string.format(
            XGUIEng.GetStringTableText("InGameMsgStrings/GUI_NotEnoughWood"),
            _Costs[ResourceType.Wood] - (Wood+WoodRaw)
        );
		GUI.AddNote(MsgString);
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Wood, _Costs[ResourceType.Wood] - (Wood+WoodRaw));
	end

	if _Costs[ResourceType.Gold] ~= nil
	and _Costs[ResourceType.Gold] ~= 0
    and (Gold+GoldRaw) < _Costs[ResourceType.Gold] then
		MsgString = string.format(
            XGUIEng.GetStringTableText("InGameMsgStrings/GUI_NotEnoughMoney"),
            _Costs[ResourceType.Gold] - (Gold+GoldRaw)
        );
		GUI.AddNote(MsgString);
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Gold, _Costs[ResourceType.Gold] - (Gold+GoldRaw));
	end

    return (MsgString ~= "" and 0) or 1;
end

function FormatCostString(_PlayerID, _Costs)
    local CostString = "";

	local Honor     = GetHonor(_PlayerID);
	local Knowledge = GetKnowledge(_PlayerID);
	local GoldRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.GoldRaw);
	local Gold      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Gold);
    local ClayRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.ClayRaw);
    local Clay      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Clay);
	local WoodRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.WoodRaw);
	local Wood      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Wood);
	local IronRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.IronRaw);
	local Iron      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Iron);
	local StoneRaw  = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.StoneRaw);
	local Stone     = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Stone);
    local SulfurRaw = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.SulfurRaw);
    local Sulfur    = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Sulfur);

	if _Costs[ResourceType.Honor] ~= nil
    and _Costs[ResourceType.Honor] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("sh_names/Honor") .. ": ";
		if Honor >= _Costs[ResourceType.Honor] then
			CostString = CostString .. " @color:255,255,255,255 ";
		else
			CostString = CostString .. " @color:220,64,16,255 ";
		end
		CostString = CostString .. _Costs[ResourceType.Honor] .. " @color:255,255,255,255 @cr ";
	end

	if  _Costs[ResourceType.Knowledge] ~= nil
    and _Costs[ResourceType.Knowledge] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("sh_names/Knowledge") .. ": ";
		if Knowledge >= _Costs[ResourceType.Knowledge] then
			CostString = CostString .. " @color:255,255,255,255 ";
		else
			CostString = CostString .. " @color:220,64,16,255 ";
		end
		CostString = CostString .. _Costs[ResourceType.Knowledge] .. " @color:255,255,255,255 @cr ";
	end

    if  _Costs[ResourceType.Gold] ~= nil
    and _Costs[ResourceType.Gold] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameMoney") .. ": ";
		if GoldRaw + Gold >= _Costs[ResourceType.Gold] then
			CostString = CostString .. " @color:255,255,255,255 ";
		else
			CostString = CostString .. " @color:220,64,16,255 ";
		end
		CostString = CostString .. _Costs[ResourceType.Gold] .. " @color:255,255,255,255 @cr ";
	end

	if  _Costs[ResourceType.Wood] ~= nil
    and _Costs[ResourceType.Wood] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameWood") .. ": ";
		if WoodRaw + Wood >= _Costs[ResourceType.Wood] then
			CostString = CostString .. " @color:255,255,255,255 ";
		else
			CostString = CostString .. " @color:220,64,16,255 ";
		end
		CostString = CostString .. _Costs[ResourceType.Wood] .. " @color:255,255,255,255 @cr ";
	end

	if  _Costs[ResourceType.Clay] ~= nil
    and _Costs[ResourceType.Clay] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameClay") .. ": ";
		if ClayRaw + Clay >= _Costs[ResourceType.Clay] then
			CostString = CostString .. " @color:255,255,255,255 ";
		else
			CostString = CostString .. " @color:220,64,16,255 ";
		end
		CostString = CostString .. _Costs[ResourceType.Clay] .. " @color:255,255,255,255 @cr ";
	end

	if  _Costs[ResourceType.Stone] ~= nil
    and _Costs[ResourceType.Stone] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameStone") .. ": ";
		if StoneRaw + Stone >= _Costs[ResourceType.Stone] then
			CostString = CostString .. " @color:255,255,255,255 ";
		else
			CostString = CostString .. " @color:220,64,16,255 ";
		end
		CostString = CostString .. _Costs[ResourceType.Stone] .. " @color:255,255,255,255 @cr ";
	end

	if  _Costs[ResourceType.Iron] ~= nil
    and _Costs[ResourceType.Iron] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameIron") .. ": ";
		if IronRaw + Iron >= _Costs[ResourceType.Iron] then
			CostString = CostString .. " @color:255,255,255,255 ";
		else
			CostString = CostString .. " @color:220,64,16,255 ";
		end
		CostString = CostString .. _Costs[ResourceType.Iron] .. " @color:255,255,255,255 @cr ";
	end

	if  _Costs[ResourceType.Sulfur] ~= nil
    and _Costs[ResourceType.Sulfur] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameSulfur") .. ": ";
		if SulfurRaw + Sulfur >= _Costs[ResourceType.Sulfur] then
			CostString = CostString .. " @color:255,255,255,255 ";
		else
			CostString = CostString .. " @color:220,64,16,255 ";
		end
		CostString = CostString .. _Costs[ResourceType.Sulfur] .. " @color:255,255,255,255 @cr ";
	end

    return CostString;
end

-- -------------------------------------------------------------------------- --
-- Resources

function MergeCostTable(_Costs1, _Costs2)
    local Costs = {};
    Costs[ResourceType.Honor] = _Costs1[ResourceType.Honor];
    if _Costs2[ResourceType.Honor] ~= nil and _Costs2[ResourceType.Honor] > 0 then
        Costs[ResourceType.Honor] = (_Costs1[ResourceType.Honor] or 0) + _Costs2[ResourceType.Honor];
    end
    Costs[ResourceType.Knowledge] = _Costs1[ResourceType.Knowledge];
    if _Costs2[ResourceType.Knowledge] ~= nil and _Costs2[ResourceType.Knowledge] > 0 then
        Costs[ResourceType.Knowledge] = (_Costs1[ResourceType.Knowledge] or 0) + _Costs2[ResourceType.Knowledge];
    end
    Costs[ResourceType.Gold] = _Costs1[ResourceType.Gold];
    if _Costs2[ResourceType.Gold] ~= nil and _Costs2[ResourceType.Gold] > 0 then
        Costs[ResourceType.Gold] = (_Costs1[ResourceType.Gold] or 0) + _Costs2[ResourceType.Gold];
    end
    Costs[ResourceType.Clay] = _Costs1[ResourceType.Clay];
    if _Costs2[ResourceType.Clay] ~= nil and _Costs2[ResourceType.Clay] > 0 then
        Costs[ResourceType.Clay] = (_Costs1[ResourceType.Clay] or 0) + _Costs2[ResourceType.Clay];
    end
    Costs[ResourceType.Wood] = _Costs1[ResourceType.Wood];
    if _Costs2[ResourceType.Wood] ~= nil and _Costs2[ResourceType.Wood] > 0 then
        Costs[ResourceType.Wood] = (_Costs1[ResourceType.Wood] or 0) + _Costs2[ResourceType.Wood];
    end
    Costs[ResourceType.Stone] = _Costs1[ResourceType.Stone];
    if _Costs2[ResourceType.Stone] ~= nil and _Costs2[ResourceType.Stone] > 0 then
        Costs[ResourceType.Stone] = (_Costs1[ResourceType.Stone] or 0) + _Costs2[ResourceType.Stone];
    end
    Costs[ResourceType.Iron] = _Costs1[ResourceType.Iron];
    if _Costs2[ResourceType.Iron] ~= nil and _Costs2[ResourceType.Iron] > 0 then
        Costs[ResourceType.Iron] = (_Costs1[ResourceType.Iron] or 0) + _Costs2[ResourceType.Iron];
    end
    Costs[ResourceType.Sulfur] = _Costs1[ResourceType.Sulfur];
    if _Costs2[ResourceType.Sulfur] ~= nil and _Costs2[ResourceType.Sulfur] > 0 then
        Costs[ResourceType.Sulfur] = (_Costs1[ResourceType.Sulfur] or 0) + _Costs2[ResourceType.Sulfur];
    end
    return Costs
end

function CreateCostTable(_Honor, _Gold, _Clay, _Wood, _Stone, _Iron, _Sulfur, _Knowledge)
    local Costs = {};
    if _Honor ~= nil and _Honor > 0 then
        Costs[ResourceType.Honor] = _Honor;
    end
    if _Knowledge ~= nil and _Knowledge > 0 then
        Costs[ResourceType.Knowledge] = _Knowledge;
    end
    if _Gold ~= nil and _Gold > 0 then
        Costs[ResourceType.Gold] = _Gold;
    end
    if _Clay ~= nil and _Clay > 0 then
        Costs[ResourceType.Clay] = _Clay;
    end
    if _Wood ~= nil and _Wood > 0 then
        Costs[ResourceType.Wood] = _Wood;
    end
    if _Stone ~= nil and _Stone > 0 then
        Costs[ResourceType.Stone] = _Stone;
    end
    if _Iron ~= nil and _Iron > 0 then
        Costs[ResourceType.Iron] = _Iron;
    end
    if _Sulfur ~= nil and _Sulfur > 0 then
        Costs[ResourceType.Sulfur] = _Sulfur;
    end
    return Costs
end

function HasEnoughResources(_PlayerID, _Costs)
    if Stronghold:GetPlayer(_PlayerID) then
        local Honor     = GetHonor(_PlayerID);
        local Knowledge = GetKnowledge(_PlayerID);
        local GoldRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.GoldRaw);
        local Gold      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Gold);
        local ClayRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.ClayRaw);
        local Clay      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Clay);
        local WoodRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.WoodRaw);
        local Wood      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Wood);
        local IronRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.IronRaw);
        local Iron      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Iron);
        local StoneRaw  = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.StoneRaw);
        local Stone     = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Stone);
        local SulfurRaw = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.SulfurRaw);
        local Sulfur    = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Sulfur);

        if _Costs[ResourceType.Honor] ~= nil and Honor < _Costs[ResourceType.Honor] then
            return false;
        end
        if _Costs[ResourceType.Knowledge] ~= nil and Knowledge < _Costs[ResourceType.Knowledge] then
            return false;
        end
        if _Costs[ResourceType.Gold] ~= nil and Gold+GoldRaw < _Costs[ResourceType.Gold] then
            return false;
        end
        if _Costs[ResourceType.Clay] ~= nil and Clay+ClayRaw < _Costs[ResourceType.Clay]  then
            return false;
        end
        if _Costs[ResourceType.Wood] ~= nil and Wood+WoodRaw < _Costs[ResourceType.Wood]  then
            return false;
        end
        if _Costs[ResourceType.Iron] ~= nil and Iron+IronRaw < _Costs[ResourceType.Iron] then
            return false;
        end
        if _Costs[ResourceType.Stone] ~= nil and Stone+StoneRaw < _Costs[ResourceType.Stone] then
            return false;
        end
        if _Costs[ResourceType.Sulfur] ~= nil and Sulfur+SulfurRaw < _Costs[ResourceType.Sulfur] then
            return false;
        end
    end
    return true;
end

function AddResourcesToPlayer(_PlayerID, _Resources)
    if Stronghold:GetPlayer(_PlayerID) then
        if _Resources[ResourceType.Honor] ~= nil then
            AddHonor(_PlayerID, _Resources[ResourceType.Honor]);
        end
        if _Resources[ResourceType.Knowledge] ~= nil then
            AddKnowledge(_PlayerID, _Resources[ResourceType.Knowledge]);
        end
        if _Resources[ResourceType.Gold] ~= nil then
            AddGold(_PlayerID, _Resources[ResourceType.Gold] or _Resources[ResourceType.GoldRaw]);
        end
        if _Resources[ResourceType.Clay] ~= nil then
            AddClay(_PlayerID, _Resources[ResourceType.Clay] or _Resources[ResourceType.ClayRaw]);
        end
        if _Resources[ResourceType.Wood] ~= nil then
            AddWood(_PlayerID, _Resources[ResourceType.Wood] or _Resources[ResourceType.WoodRaw]);
        end
        if _Resources[ResourceType.Iron] ~= nil then
            AddIron(_PlayerID, _Resources[ResourceType.Iron] or _Resources[ResourceType.IronRaw]);
        end
        if _Resources[ResourceType.Stone] ~= nil then
            AddStone(_PlayerID, _Resources[ResourceType.Stone] or _Resources[ResourceType.StoneRaw]);
        end
        if _Resources[ResourceType.Sulfur] ~= nil then
            AddSulfur(_PlayerID, _Resources[ResourceType.Sulfur] or _Resources[ResourceType.SulfurRaw]);
        end
    end
end

function RemoveResourcesFromPlayer(_PlayerID, _Costs)
    if Stronghold:GetPlayer(_PlayerID) then
        local Honor     = GetHonor(_PlayerID);
        local Knowledge = GetKnowledge(_PlayerID);
        local GoldRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.GoldRaw);
        local Gold      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Gold);
        local ClayRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.ClayRaw);
        local Clay      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Clay);
        local WoodRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.WoodRaw);
        local Wood      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Wood);
        local IronRaw   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.IronRaw);
        local Iron      = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Iron);
        local StoneRaw  = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.StoneRaw);
        local Stone     = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Stone);
        local SulfurRaw = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.SulfurRaw);
        local Sulfur    = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Sulfur);

        -- Honor cost
        if  _Costs[ResourceType.Honor] ~= nil and _Costs[ResourceType.Honor] > 0
        and Honor >= _Costs[ResourceType.Honor] then
            AddHonor(_PlayerID, _Costs[ResourceType.Honor] * (-1));
        end
        -- Knowledge cost
        if  _Costs[ResourceType.Knowledge] ~= nil and _Costs[ResourceType.Knowledge] > 0
        and Knowledge >= _Costs[ResourceType.Knowledge] then
            AddKnowledge(_PlayerID, _Costs[ResourceType.Knowledge] * (-1));
        end
        -- Gold cost
        if  _Costs[ResourceType.Gold] ~= nil and _Costs[ResourceType.Gold] > 0
        and Gold+GoldRaw >= _Costs[ResourceType.Gold] then
            AddGold(_PlayerID, _Costs[ResourceType.Gold] * (-1));
        end
        -- Clay cost
        if  _Costs[ResourceType.Clay] ~= nil and _Costs[ResourceType.Clay] > 0
        and Clay+ClayRaw >= _Costs[ResourceType.Clay]  then
            AddClay(_PlayerID, _Costs[ResourceType.Clay] * (-1));
        end
        -- Wood cost
        if  _Costs[ResourceType.Wood] ~= nil and _Costs[ResourceType.Wood] > 0
        and Wood+WoodRaw >= _Costs[ResourceType.Wood]  then
            AddWood(_PlayerID, _Costs[ResourceType.Wood] * (-1));
        end
        -- Iron cost
        if  _Costs[ResourceType.Iron] ~= nil and _Costs[ResourceType.Iron] > 0
        and Iron+IronRaw >= _Costs[ResourceType.Iron] then
            AddIron(_PlayerID, _Costs[ResourceType.Iron] * (-1));
        end
        -- Stone cost
        if  _Costs[ResourceType.Stone] ~= nil and _Costs[ResourceType.Stone] > 0
        and Stone+StoneRaw >= _Costs[ResourceType.Stone] then
            AddStone(_PlayerID, _Costs[ResourceType.Stone] * (-1));
        end
        -- Sulfur cost
        if  _Costs[ResourceType.Sulfur] ~= nil and _Costs[ResourceType.Sulfur] > 0
        and Sulfur+SulfurRaw >= _Costs[ResourceType.Sulfur] then
            AddSulfur(_PlayerID, _Costs[ResourceType.Sulfur] * (-1));
        end
    end
end

