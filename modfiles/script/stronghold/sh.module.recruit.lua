--- 
--- Recruitment Script
--- 

Stronghold = Stronghold or {};

Stronghold.Recruit = Stronghold.Recruit or {
    SyncEvents = {},
    Data = {},
    Config = {},
};

function Stronghold.Recruit:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            Config = CopyTable(Stronghold.Unit.Config),
            Roster = {},
        };
        self:InitDefaultRoster(i);
    end
end

function Stronghold.Recruit:OnSaveGameLoaded()
end

function Stronghold.Recruit:CreateBuildingButtonHandlers()
    self.SyncEvents = {
        BuyCannon = 1,
        BuyUnit = 2,
    };
    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Recruit.SyncEvents.BuyCannon then
                Stronghold.Unit:PayUnit(_PlayerID, arg[1], 0);
                self:RegisterCannonOrder(_PlayerID, arg[2], arg[1]);
            elseif _Action == Stronghold.Recruit.SyncEvents.BuyUnit then
                Stronghold.Unit:PayUnit(_PlayerID, arg[1], 0);
            end
        end
    );
end

-- -------------------------------------------------------------------------- --

function Stronghold.Recruit:InitDefaultRoster(_PlayerID)
    if self.Data[_PlayerID] then
        self.Data[_PlayerID].Roster = {
            Melee   = {},
            Ranged  = {},
            Cavalry = {},
            Cannon  = {},
            Tavern  = {},
        }
    end
end

function Stronghold.Recruit:IsUnitAllowed(_BuildingID, _Type)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local Config = Stronghold.Unit.Config:Get(_Type, PlayerID);
    if Config then
        return Stronghold.Rights:GetRankRequiredForRight(PlayerID, Config.Right) > 0;
    end
    return false;
end

function Stronghold.Recruit:BuyUnitAction(_WidgetID, _PlayerID, _EntityID, _UpgradeCategory, _EntityType)

    if string.find(Logic.GetEntityTypeName(Logic.GetEntityType(_EntityID)), "PB_Foundry") then
        GUIAction_BuyCannon(_UpgradeCategory);
    else
        GUIAction_BuyMillitaryUnit(_UpgradeCategory);
    end
end

function Stronghold.Recruit:BuyUnitTooltip(_WidgetID, _PlayerID, _EntityID, _EntityType)
    local Text = "";
    local CostsText = "";
    if not self:IsUnitAllowed(_EntityID, _EntityType) then
        Text = XGUIEng.GetStringTableText("MenuGeneric/UnitNotAvailable");
    else
        local Soldiers = (Logic.IsAutoFillActive(_EntityID) == 1 and Config.Soldiers) or 0;
        local Costs = Stronghold.Recruitment:GetLeaderCosts(_PlayerID, _EntityType, Soldiers);
        CostsText = FormatCostString(_PlayerID, Costs);
        local Name = " @color:180,180,180,255 " ..XGUIEng.GetStringTableText("names/".. TypeName);
        Text = Name.. " @cr " ..XGUIEng.GetStringTableText("sh_description/Unit_" ..TypeName.. "_normal");
        if XGUIEng.IsButtonDisabled(_WidgetID) == 1 then
            local DisabledText = XGUIEng.GetStringTableText("sh_description/Unit_" ..TypeName.. "_disabled");
            local Rank = Stronghold.Rights:GetRankRequiredForRight(_PlayerID, Config.Right);
            local RankName = GetRankName(Rank, _PlayerID);
            DisabledText = string.gsub(DisabledText, "#Rank#", RankName);
            Text = Text.. " @cr " ..DisabledText;
        end
    end

    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180,255 " ..Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostsText);
end

function Stronghold.Recruit:BuyUnitUpdate(_WidgetID, _PlayerID, _EntityID, _EntityType)

end

-- -------------------------------------------------------------------------- --

function GUIAction_BuySerf()
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if GuiPlayer == 17 or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuySerfAction(PlayerID, EntityID);
end

function GUITooltip_BuySerf()
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuySerfTooltip(PlayerID, EntityID);
end

function GUIUpdate_BuySerf()
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuySerfUpdate(PlayerID, EntityID);
end

function Stronghold.Recruit:BuySerfAction(_PlayerID, _EntityID)
    local WidgetID = "Buy_Serf";
end

function Stronghold.Recruit:BuySerfTooltip(_PlayerID, _EntityID)
    local WidgetID = "Buy_Serf";
end

function Stronghold.Recruit:BuySerfUpdate(_PlayerID, _EntityID)
    local WidgetID = "Buy_Serf";
end

-- -------------------------------------------------------------------------- --

function GUIAction_BuyMeleeUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if GuiPlayer == 17 or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyMeleeUnitAction(PlayerID, EntityID, _Index);
end

function GUITooltip_BuyMeleeUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyMeleeUnitTooltip(PlayerID, EntityID, _Index);
end

function GUIUpdate_BuyMeleeUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyMeleeUnitUpdate(PlayerID, EntityID, _Index);
end

function Stronghold.Recruit:OnBarracksSelected(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Barracks1 and Type ~= Entities.PB_Barracks2 then
        return;
    end
    for i= 1, 8 do
        local Visble = (self.Data[_PlayerID].Roster.Melee[i] and 1) or 0;
        XGUIEng.ShowWidget("Buy_MeleeUnit" ..i, Visble);
        GUIUpdate_BuyMeleeUnit(i);
    end
    XGUIEng.ShowWidget("RallyPoint", 1);
    XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Recruit:BuyMeleeUnitAction(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_MeleeUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Melee[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitAction(WidgetID, _PlayerID, _EntityID, UpgradeCategory, EntityType);
end

function Stronghold.Recruit:BuyMeleeUnitTooltip(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_MeleeUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Melee[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitTooltip(WidgetID, _PlayerID, _EntityID, EntityType);
end

function Stronghold.Recruit:BuyMeleeUnitUpdate(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_MeleeUnit" .._Index;
    if not self.Data[_PlayerID].Roster.Melee[_Index] then
        XGUIEng.ShowWidget(WidgetID, 0);
        return;
    end
    local UpgradeCategory = self.Data[_PlayerID].Roster.Melee[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitUpdate(WidgetID, _PlayerID, _EntityID, EntityType);
end

-- -------------------------------------------------------------------------- --

function GUIAction_BuyRangedUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if GuiPlayer == 17 or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyRangedUnitAction(PlayerID, EntityID, _Index);
end

function GUITooltip_BuyRangedUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyRangedUnitTooltip(PlayerID, EntityID, _Index);
end

function GUIUpdate_BuyRangedUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyRangedUnitUpdate(PlayerID, EntityID, _Index);
end

function Stronghold.Recruit:OnArcherySelected(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Archery1 and Type ~= Entities.PB_Archery2 then
        return;
    end
    for i= 1, 8 do
        local Visble = (self.Data[_PlayerID].Roster.Ranged[i] and 1) or 0;
        XGUIEng.ShowWidget("Buy_RangedUnit" ..i, Visble);
        GUIUpdate_BuyRangedUnit(i);
    end
    XGUIEng.ShowWidget("RallyPoint", 1);
    XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Recruit:BuyRangedUnitAction(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_RangedUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Ranged[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitAction(WidgetID, _PlayerID, _EntityID, UpgradeCategory, EntityType);
end

function Stronghold.Recruit:BuyRangedUnitTooltip(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_RangedUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Ranged[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitTooltip(WidgetID, _PlayerID, _EntityID, EntityType);
end

function Stronghold.Recruit:BuyRangedUnitUpdate(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_RangedUnit" .._Index;
    if not self.Data[_PlayerID].Roster.Ranged[_Index] then
        XGUIEng.ShowWidget(WidgetID, 0);
        return;
    end
    local UpgradeCategory = self.Data[_PlayerID].Roster.Ranged[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitUpdate(WidgetID, _PlayerID, _EntityID, EntityType);
end

-- -------------------------------------------------------------------------- --

function GUIAction_BuyCavalryUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if GuiPlayer == 17 or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCavalryUnitAction(PlayerID, EntityID, _Index);
end

function GUITooltip_BuyCavalryUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCavalryUnitTooltip(PlayerID, EntityID, _Index);
end

function GUIUpdate_BuyCavalryUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCavalryUnitUpdate(PlayerID, EntityID, _Index);
end

function Stronghold.Recruit:OnStableSelected(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Stable1 and Type ~= Entities.PB_Stable2 then
        return;
    end
    for i= 1, 8 do
        local Visble = (self.Data[_PlayerID].Roster.Cavalry[i] and 1) or 0;
        XGUIEng.ShowWidget("Buy_CavalryUnit" ..i, Visble);
        GUIUpdate_BuyCavalryUnit(i);
    end
    XGUIEng.ShowWidget("RallyPoint", 1);
    XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Recruit:BuyCavalryUnitAction(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CavalryUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cavalry[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitAction(WidgetID, _PlayerID, _EntityID, UpgradeCategory, EntityType);
end

function Stronghold.Recruit:BuyCavalryUnitTooltip(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CavalryUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cavalry[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitTooltip(WidgetID, _PlayerID, _EntityID, EntityType);
end

function Stronghold.Recruit:BuyCavalryUnitUpdate(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CavalryUnit" .._Index;
    if not self.Data[_PlayerID].Roster.Cavalry[_Index] then
        XGUIEng.ShowWidget(WidgetID, 0);
        return;
    end
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cavalry[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitUpdate(WidgetID, _PlayerID, _EntityID, EntityType);
end

-- -------------------------------------------------------------------------- --

function GUIAction_BuyCannonUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if GuiPlayer == 17 or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCannonUnitAction(PlayerID, EntityID, _Index);
end

function GUITooltip_BuyCannonUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCannonUnitTooltip(PlayerID, EntityID, _Index);
end

function GUIUpdate_BuyCannonUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyCannonUnitUpdate(PlayerID, EntityID, _Index);
end

function Stronghold.Recruit:OnFoundrySelected(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Foundry1 and Type ~= Entities.PB_Foundry2 then
        return;
    end
    for i= 1, 8 do
        local Visble = (self.Data[_PlayerID].Roster.Cannon[i] and 1) or 0;
        XGUIEng.ShowWidget("Buy_CannonUnit" ..i, Visble);
        GUIUpdate_BuyCannonUnit(i);
    end
    XGUIEng.ShowWidget("RallyPoint", 1);
    XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Recruit:BuyCannonUnitAction(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CannonUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cannon[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitAction(WidgetID, _PlayerID, _EntityID, UpgradeCategory, EntityType);
end

function Stronghold.Recruit:BuyCannonUnitTooltip(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CannonUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cannon[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitTooltip(WidgetID, _PlayerID, _EntityID, EntityType);
end

function Stronghold.Recruit:BuyCannonUnitUpdate(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_CannonUnit" .._Index;
    if not self.Data[_PlayerID].Roster.Cannon[_Index] then
        XGUIEng.ShowWidget(WidgetID, 0);
        return;
    end
    local UpgradeCategory = self.Data[_PlayerID].Roster.Cannon[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitUpdate(WidgetID, _PlayerID, _EntityID, EntityType);
end

-- -------------------------------------------------------------------------- --

function GUIAction_BuyTavernUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local GuiPlayer = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if GuiPlayer == 17 or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyTavernUnitAction(PlayerID, EntityID, _Index);
end

function GUITooltip_BuyTavernUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyTavernUnitTooltip(PlayerID, EntityID, _Index);
end

function GUIUpdate_BuyTavernUnit(_Index)
    local PlayerID = GetLocalPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    if not IsPlayer(PlayerID) or not IsExisting(EntityID) then
        return;
    end
    Stronghold.Recruit:BuyTavernUnitUpdate(PlayerID, EntityID, _Index);
end

function Stronghold.Recruit:OnTavernSelected(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type ~= Entities.PB_Tavern1 and Type ~= Entities.PB_Tavern2 then
        return;
    end
    for i= 1, 2 do
        local Visble = (self.Data[_PlayerID].Roster.Tavern[i] and 1) or 0;
        XGUIEng.ShowWidget("Buy_TavernUnit" ..i, Visble);
        GUIUpdate_BuyTavernUnit(i);
    end
    XGUIEng.ShowWidget("RallyPoint", 1);
    XGUIEng.ShowWidget("ActivateSetRallyPoint", 1);
    GUIUpdate_PlaceRallyPoint();
end

function Stronghold.Recruit:BuyTavernUnitAction(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_TavernUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Tavern[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitAction(WidgetID, _PlayerID, _EntityID, UpgradeCategory, EntityType);
end

function Stronghold.Recruit:BuyTavernUnitTooltip(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_TavernUnit" .._Index;
    local UpgradeCategory = self.Data[_PlayerID].Roster.Tavern[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitTooltip(WidgetID, _PlayerID, _EntityID, EntityType);
end

function Stronghold.Recruit:BuyTavernUnitUpdate(_PlayerID, _EntityID, _Index)
    local WidgetID = "Buy_TavernUnit" .._Index;
    if not self.Data[_PlayerID].Roster.Tavern[_Index] then
        XGUIEng.ShowWidget(WidgetID, 0);
        return;
    end
    local UpgradeCategory = self.Data[_PlayerID].Roster.Tavern[_Index];
    local Amount, EntityType = Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategory);
    Stronghold.Recruit:BuyUnitUpdate(WidgetID, _PlayerID, _EntityID, EntityType);
end

-- -------------------------------------------------------------------------- --

