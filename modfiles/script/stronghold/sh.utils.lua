--- 
--- Util functions
---
--- This script contains comforts specific to Stronghold.
--- 

Stronghold = Stronghold or {};

Stronghold.Utils = {};

-- -------------------------------------------------------------------------- --
-- Behavior hacks

function GetEntityBehavior(_EntityID, _Behavior)
    if Logic.IsEntityAlive(_EntityID) then
        local entityadress = CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_EntityID));
        local startadress = entityadress[31];
        local endadress = entityadress[32];
        local lastindex = (endadress:GetInt() - startadress:GetInt()) / 4 - 1;
        for i = 0, lastindex do
            local behavioraddress = startadress[i];
            if behavioraddress:GetInt() ~= 0 and behavioraddress[0]:GetInt() == _Behavior then
                return behavioraddress;
            end
        end
    end
end

function SetEntityStamina(_EntityID, _Stamina)
    local workerbehavior = GetEntityBehavior(_EntityID, 7809840);
    if workerbehavior then
        workerbehavior[4]:SetInt(_Stamina);
    end
end

--- Returns the ID of the attack target entity of the entity.
--- @param _EntityID integer ID of attacking entity
--- @return integer target ID of attacked entity
function GetEntityCurrentTarget(_EntityID)
    if IsValidEntity(_EntityID) then
        local Attachments = CEntity.GetReversedAttachedEntities(_EntityID);
        if next(Attachments) then
            return (Attachments[32] and Attachments[32][1]) or
                   (Attachments[35] and Attachments[35][1]) or
                   (Attachments[51] and Attachments[51][1]);
        end
    end
    return 0;
end

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
    local LowestDistance = Logic.WorldGetSize();
    for ID in CEntityIterator.Iterator(CEntityIterator.InRangeFilter(_X, _Y, _Range)) do
        if table.getn(List) >= _Amount then
            break;
        end
        if IsTree(ID) then
            local CurrentDistance = GetDistance(ID, {X= _X, Y= _Y});
            if CurrentDistance < LowestDistance then
                LowestDistance = CurrentDistance;
                table.insert(List, 1, ID);
            else
                table.insert(List, ID);
            end
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
            for _, TypePart in pairs{"Tree", "Palm", "Pine", "Fir", "Cypress", "Umbrella", "Willow"} do
                if (string.find(k, TypePart)) then
                    gvTreeTypeTable[k] = true;
                    break;
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Entity Tools

function Stronghold.Utils:OverwriteLogicTools()
    SetPosition = SetSettlerPosition;
end

--- Places a copy of a settler at a position
--- @param _Entity any
--- @param _Position any
--- @return unknown
function SetSettlerPosition(_Entity, _Position)
    local OldID = GetID(_Entity)
    assert(OldID ~= 0);

    local PlayerID       = Logic.EntityGetPlayer(OldID);
    local ScriptName     = Logic.GetEntityName(OldID);
    local EntityType     = Logic.GetEntityType(OldID);
    local RelativeHealth = GetHealth(OldID);

    local SoldierAmount = 0;
    if Logic.IsLeader(OldID) == 1 or EntityType == Entities.CU_BlackKnight then
        SoldierAmount = Logic.GetSoldiersAttachedToLeader(OldID);
    end

    local WasSelected = IsEntitySelected(OldID);
    if WasSelected then
        GUI.DeselectEntity(OldID);
    end

    DestroyEntity(OldID);
    local NewID = AI.Entity_CreateFormation(PlayerID, Entities.PU_Watchman_Deco, nil, 0, _Position.X, _Position.Y, 0, 0, 0, 0);
    NewID = ReplaceEntity(NewID, EntityType);
    if SoldierAmount > 0 then
        Tools.CreateSoldiersForLeader(NewID, SoldierAmount);
    end
    Logic.SetEntityName(NewID, ScriptName);
    if WasSelected then
        GUI.SelectEntity(NewID);
    end
    SetHealth(NewID, RelativeHealth);
    GroupSelection_EntityIDChanged(OldID, NewID);
    return NewID;
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

    GetResourceName = function(_ResourceType)
        local GoodName = XGUIEng.GetStringTableText("InGameMessages/GUI_NameMoney");
        if _ResourceType == ResourceType.Silver then
            GoodName = XGUIEng.GetStringTableText("sh_names/Silver");
        elseif _ResourceType == ResourceType.Clay or _ResourceType == ResourceType.ClayRaw then
            GoodName = XGUIEng.GetStringTableText("InGameMessages/GUI_NameClay");
        elseif _ResourceType == ResourceType.Wood or _ResourceType == ResourceType.WoodRaw then
            GoodName = XGUIEng.GetStringTableText("InGameMessages/GUI_NameWood");
        elseif _ResourceType == ResourceType.Stone or _ResourceType == ResourceType.StoneRaw then
            GoodName = XGUIEng.GetStringTableText("InGameMessages/GUI_NameStone");
        elseif _ResourceType == ResourceType.Iron or _ResourceType == ResourceType.IronRaw then
            GoodName = XGUIEng.GetStringTableText("InGameMessages/GUI_NameIron");
        elseif _ResourceType == ResourceType.Sulfur or _ResourceType == ResourceType.SulfurRaw then
            GoodName = XGUIEng.GetStringTableText("InGameMessages/GUI_NameSulfur");
        end
        return GoodName;
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

    if _Costs[ResourceType.Silver] ~= nil
	and _Costs[ResourceType.Silver] ~= 0
    and _Costs[ResourceType.Silver] - Honor > 0 then
        MsgString = string.format(
            XGUIEng.GetStringTableText("sh_text/GUI_NotEnoughHonor"),
            _Costs[ResourceType.Silver] - Honor
        );
		GUI.AddNote(MsgString);
        Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_INFO_NotEnough, 100);
    end

    if _Costs[ResourceType.Knowledge] ~= nil
	and _Costs[ResourceType.Knowledge] ~= 0
    and _Costs[ResourceType.Knowledge] - Knowledge > 0 then
        MsgString = string.format(
            XGUIEng.GetStringTableText("sh_text/GUI_NotEnoughKnowledge"),
            _Costs[ResourceType.Knowledge] - Knowledge
        );
		GUI.AddNote(MsgString);
        Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_INFO_NotEnough, 100);
    end

	if 	_Costs[ResourceType.Sulfur] ~= nil
	and _Costs[ResourceType.Sulfur] ~= 0
    and (Sulfur+SulfurRaw) < _Costs[ResourceType.Sulfur] then
		MsgString = string.format(
            XGUIEng.GetStringTableText("sh_text/GUI_NotEnoughSulfur"),
            _Costs[ResourceType.Sulfur] - (Sulfur+SulfurRaw)
        );
		GUI.AddNote(MsgString);
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Sulfur, _Costs[ResourceType.Sulfur] - (Sulfur+SulfurRaw));
	end

	if _Costs[ResourceType.Iron] ~= nil
	and _Costs[ResourceType.Iron] ~= 0
    and (Iron+IronRaw) < _Costs[ResourceType.Iron] then
		MsgString = string.format(
            XGUIEng.GetStringTableText("sh_text/GUI_NotEnoughIron"),
            _Costs[ResourceType.Iron] - (Iron+IronRaw)
        );
		GUI.AddNote(MsgString);
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Iron, _Costs[ResourceType.Iron] - (Iron+IronRaw));
	end

	if _Costs[ResourceType.Stone] ~= nil
	and _Costs[ResourceType.Stone] ~= 0
    and (Stone+StoneRaw) < _Costs[ResourceType.Stone] then
		MsgString = string.format(
            XGUIEng.GetStringTableText("sh_text/GUI_NotEnoughStone"),
            _Costs[ResourceType.Stone] - (Stone+StoneRaw)
        );
		GUI.AddNote(MsgString);
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Stone, _Costs[ResourceType.Stone] - (Stone+StoneRaw));
	end

	if _Costs[ResourceType.Clay] ~= nil
	and _Costs[ResourceType.Clay] ~= 0
    and (Clay+ClayRaw) < _Costs[ResourceType.Clay]  then
		MsgString = string.format(
            XGUIEng.GetStringTableText("sh_text/GUI_NotEnoughClay"),
            _Costs[ResourceType.Clay] - (Clay+ClayRaw)
        );
		GUI.AddNote(MsgString);
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Clay, _Costs[ResourceType.Clay] - (Clay+ClayRaw));
	end

	if _Costs[ResourceType.Wood] ~= nil
	and _Costs[ResourceType.Wood] ~= 0
    and (Wood+WoodRaw) < _Costs[ResourceType.Wood]  then
		MsgString = string.format(
            XGUIEng.GetStringTableText("sh_text/GUI_NotEnoughWood"),
            _Costs[ResourceType.Wood] - (Wood+WoodRaw)
        );
		GUI.AddNote(MsgString);
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Wood, _Costs[ResourceType.Wood] - (Wood+WoodRaw));
	end

	if _Costs[ResourceType.Gold] ~= nil
	and _Costs[ResourceType.Gold] ~= 0
    and (Gold+GoldRaw) < _Costs[ResourceType.Gold] then
		MsgString = string.format(
            XGUIEng.GetStringTableText("sh_text/GUI_NotEnoughMoney"),
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

	if _Costs[ResourceType.Silver] ~= nil
    and _Costs[ResourceType.Silver] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("sh_names/Silver") .. ": ";
		if Honor >= _Costs[ResourceType.Silver] then
			CostString = CostString .. " @color:255,255,255,255 ";
		else
			CostString = CostString .. " @color:220,64,16,255 ";
		end
		CostString = CostString .. _Costs[ResourceType.Silver] .. " @color:255,255,255,255 @cr ";
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
    Costs[ResourceType.Silver] = _Costs1[ResourceType.Silver];
    if _Costs2[ResourceType.Silver] ~= nil and _Costs2[ResourceType.Silver] > 0 then
        Costs[ResourceType.Silver] = (_Costs1[ResourceType.Silver] or 0) + _Costs2[ResourceType.Silver];
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
        Costs[ResourceType.Silver] = _Honor;
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
    if IsPlayer(_PlayerID) then
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

        if _Costs[ResourceType.Silver] ~= nil and Honor < _Costs[ResourceType.Silver] then
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
    if IsPlayer(_PlayerID) then
        -- Add honor (silver)
        if _Resources[ResourceType.Silver] ~= nil then
            local Amount = _Resources[ResourceType.Silver];
            AddHonor(_PlayerID, Amount);
        end
        -- Add knowledge
        if _Resources[ResourceType.Knowledge] ~= nil then
            local Amount = _Resources[ResourceType.Knowledge];
            AddKnowledge(_PlayerID, Amount);
        end
        -- Add gold
        if _Resources[ResourceType.Gold] then
            local Amount = _Resources[ResourceType.Gold];
            AddGold(_PlayerID, Amount);
        end
        if _Resources[ResourceType.GoldRaw] then
            local Amount = _Resources[ResourceType.GoldRaw];
            Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.GoldRaw, Amount);
        end
        -- Add clay
        if _Resources[ResourceType.Clay] then
            local Amount = _Resources[ResourceType.Clay];
            AddClay(_PlayerID, Amount);
        end
        if _Resources[ResourceType.ClayRaw] then
            local Amount = _Resources[ResourceType.ClayRaw];
            Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.ClayRaw, Amount);
        end
        -- Add wood
        if _Resources[ResourceType.Wood] then
            local Amount = _Resources[ResourceType.Wood];
            AddWood(_PlayerID, Amount);
        end
        if _Resources[ResourceType.WoodRaw] then
            local Amount = _Resources[ResourceType.WoodRaw];
            Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.WoodRaw, Amount);
        end
        -- Add iron
        if _Resources[ResourceType.Iron] then
            local Amount = _Resources[ResourceType.Iron];
            AddIron(_PlayerID, Amount);
        end
        if _Resources[ResourceType.IronRaw] then
            local Amount = _Resources[ResourceType.IronRaw];
            Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.IronRaw, Amount);
        end
        -- Add stone
        if _Resources[ResourceType.Stone] then
            local Amount = _Resources[ResourceType.Stone];
            AddStone(_PlayerID, Amount);
        end
        if _Resources[ResourceType.StoneRaw] then
            local Amount = _Resources[ResourceType.StoneRaw];
            Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.StoneRaw, Amount);
        end
        -- Add sulfur
        if _Resources[ResourceType.Sulfur] then
            local Amount = _Resources[ResourceType.Sulfur];
            AddSulfur(_PlayerID, Amount);
        end
        if _Resources[ResourceType.SulfurRaw] then
            local Amount = _Resources[ResourceType.SulfurRaw];
            Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.SulfurRaw, Amount);
        end
    end
end

function RemoveResourcesFromPlayer(_PlayerID, _Costs)
    if IsPlayer(_PlayerID) then
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

        -- Honor (silver) cost
        if  _Costs[ResourceType.Silver] ~= nil and _Costs[ResourceType.Silver] > 0
        and Honor >= _Costs[ResourceType.Silver] then
            local Amount = _Costs[ResourceType.Silver] * (-1);
            AddHonor(_PlayerID, Amount);
        end
        -- Knowledge cost
        if  _Costs[ResourceType.Knowledge] ~= nil and _Costs[ResourceType.Knowledge] > 0
        and Knowledge >= _Costs[ResourceType.Knowledge] then
            local Amount = _Costs[ResourceType.Knowledge] * (-1);
            AddKnowledge(_PlayerID, Amount);
        end
        -- Gold cost
        if  _Costs[ResourceType.Gold] ~= nil and _Costs[ResourceType.Gold] > 0
        and Gold+GoldRaw >= _Costs[ResourceType.Gold] then
            local Amount = _Costs[ResourceType.Gold] * (-1);
            AddGold(_PlayerID, Amount);
        end
        -- Clay cost
        if  _Costs[ResourceType.Clay] ~= nil and _Costs[ResourceType.Clay] > 0
        and Clay+ClayRaw >= _Costs[ResourceType.Clay]  then
            local Amount = _Costs[ResourceType.Clay] * (-1);
            AddClay(_PlayerID, Amount);
        end
        -- Wood cost
        if  _Costs[ResourceType.Wood] ~= nil and _Costs[ResourceType.Wood] > 0
        and Wood+WoodRaw >= _Costs[ResourceType.Wood]  then
            local Amount = _Costs[ResourceType.Wood] * (-1);
            AddWood(_PlayerID, Amount);
        end
        -- Iron cost
        if  _Costs[ResourceType.Iron] ~= nil and _Costs[ResourceType.Iron] > 0
        and Iron+IronRaw >= _Costs[ResourceType.Iron] then
            local Amount = _Costs[ResourceType.Iron] * (-1);
            AddIron(_PlayerID, Amount);
        end
        -- Stone cost
        if  _Costs[ResourceType.Stone] ~= nil and _Costs[ResourceType.Stone] > 0
        and Stone+StoneRaw >= _Costs[ResourceType.Stone] then
            local Amount = _Costs[ResourceType.Stone] * (-1);
            AddStone(_PlayerID, Amount);
        end
        -- Sulfur cost
        if  _Costs[ResourceType.Sulfur] ~= nil and _Costs[ResourceType.Sulfur] > 0
        and Sulfur+SulfurRaw >= _Costs[ResourceType.Sulfur] then
            local Amount = _Costs[ResourceType.Sulfur] * (-1);
            AddSulfur(_PlayerID, Amount);
        end
    end
end

