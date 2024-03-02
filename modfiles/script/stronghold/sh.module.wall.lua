--- 
--- Wall Script
---
--- This script implements special properties of walls.
--- 

Stronghold = Stronghold or {};

Stronghold.Wall = Stronghold.Wall or {
    SyncEvents = {},
    Data = {},
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Wall:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            Measure = {},
            RallyPoint = {},
            UnitMover = {},
            Corners = {},
        };
    end

    self:CreateWallsButtonHandlers();
    self:MakeNeutralWallsInvincible();
end

function Stronghold.Wall:OnSaveGameLoaded()
end

function Stronghold.Wall:CreateWallsButtonHandlers()
    self.SyncEvents = {
        OpenGate = 1,
        CloseGate = 2,
        TurnToGate = 3,
        TurnToWall = 4,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Wall.SyncEvents.OpenGate then
                Stronghold.Wall:OnGateOpenedCallback(_PlayerID, arg[1], arg[2]);
            end
            if _Action == Stronghold.Wall.SyncEvents.CloseGate then
                Stronghold.Wall:OnGateClosedCallback(_PlayerID, arg[1], arg[2]);
            end
            if _Action == Stronghold.Wall.SyncEvents.TurnToGate then
                Stronghold.Wall:OnWallTurnedToGateCallback(_PlayerID, arg[1], arg[2]);
            end
            if _Action == Stronghold.Wall.SyncEvents.TurnToWall then
                Stronghold.Wall:OnGateTurnedToWallCallback(_PlayerID, arg[1], arg[2]);
            end
        end
    );
end

function Stronghold.Wall:OnEntityCreated(_EntityID)
    -- Wall placed
    self:OnWallOrPalisadeCreated(_EntityID);
end

function Stronghold.Wall:OnEntityDestroyed(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    -- Wall destroyed
    self:OnWallOrPalisadeDestroyed(_EntityID);
end

function Stronghold.Wall:OnPlacementCheck(_PlayerID, _Type, _X, _Y, _Rotation, _IsBuildOn)
    if self.Config.LegalWallType[_Type] then
        if AreEnemiesInArea(_PlayerID, {X= _X, Y= _Y}, 2000) then
            return false;
        end
    end
    return true;
end

-- -------------------------------------------------------------------------- --
-- Wall GUI

GUIAction_OpenGate = function()
    local PlayerID = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local Type = Logic.GetEntityType(EntityID);
    if PlayerID == 17 or Stronghold.Wall.Config.OpenGateType[Type] then
        return;
    end
    GUI.ClearSelection();
    Syncer.InvokeEvent(
        Stronghold.Wall.NetworkCall,
        Stronghold.Wall.SyncEvents.OpenGate,
        EntityID,
        Type
    );
end

GUIAction_CloseGate = function()
    local PlayerID = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local Type = Logic.GetEntityType(EntityID);
    if PlayerID == 17 or Stronghold.Wall.Config.ClosedGateType[Type] then
        return;
    end
    GUI.ClearSelection();
    Syncer.InvokeEvent(
        Stronghold.Wall.NetworkCall,
        Stronghold.Wall.SyncEvents.CloseGate,
        EntityID,
        Type
    );
end

GUIAction_TurnToGate = function()
    local PlayerID = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local Type = Logic.GetEntityType(EntityID);
    if PlayerID == 17 then
        return;
    end
    GUI.ClearSelection();
    Syncer.InvokeEvent(
        Stronghold.Wall.NetworkCall,
        Stronghold.Wall.SyncEvents.TurnToGate,
        EntityID,
        Type
    );
end

GUIAction_TurnToWall = function()
    local PlayerID = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local Type = Logic.GetEntityType(EntityID);
    if PlayerID == 17 then
        return;
    end
    GUI.ClearSelection();
    Syncer.InvokeEvent(
        Stronghold.Wall.NetworkCall,
        Stronghold.Wall.SyncEvents.TurnToWall,
        EntityID,
        Type
    );
end

GUITooltip_OpenGate = function(_TextKey, _ShortCut)
    local TextToolTip = XGUIEng.GetStringTableText(_TextKey.. "_normal");
    if XGUIEng.IsButtonDisabled(XGUIEng.GetCurrentWidgetID()) == 1 then
        TextToolTip = XGUIEng.GetStringTableText(_TextKey.. "_disabled");
    end
    local ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") ..
                            ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]";
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, TextToolTip);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
end

GUITooltip_CloseGate = function(_TextKey, _ShortCut)
    local TextToolTip = XGUIEng.GetStringTableText(_TextKey.. "_normal");
    if XGUIEng.IsButtonDisabled(XGUIEng.GetCurrentWidgetID()) == 1 then
        TextToolTip = XGUIEng.GetStringTableText(_TextKey.. "_disabled");
    end
    local ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") ..
                            ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]";
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, TextToolTip);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
end

GUITooltip_TurnToGate = function(_TextKey, _ShortCut)
    local TextToolTip = XGUIEng.GetStringTableText(_TextKey.. "_normal");
    if XGUIEng.IsButtonDisabled(XGUIEng.GetCurrentWidgetID()) == 1 then
        TextToolTip = XGUIEng.GetStringTableText(_TextKey.. "_disabled");
    end
    local ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") ..
                            ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]";
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, TextToolTip);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
end

GUITooltip_TurnToWall = function(_TextKey, _ShortCut)
    local TextToolTip = XGUIEng.GetStringTableText(_TextKey.. "_normal");
    if XGUIEng.IsButtonDisabled(XGUIEng.GetCurrentWidgetID()) == 1 then
        TextToolTip = XGUIEng.GetStringTableText(_TextKey.. "_disabled");
    end
    local ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") ..
                            ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]";
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, TextToolTip);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
end

GUIUpdate_OpenGate = function()
    local EntityID = GUI.GetSelectedEntity();
    local Type = Logic.GetEntityType(EntityID);
    local Highlight = (Stronghold.Wall.Config.OpenGateType[Type] and 1) or 0;
    XGUIEng.HighLightButton("OpenPalisadeGate", Highlight);
    XGUIEng.HighLightButton("OpenWallGate", Highlight);
end

GUIUpdate_CloseGate = function()
    local EntityID = GUI.GetSelectedEntity();
    local Type = Logic.GetEntityType(EntityID);
    local Highlight = (Stronghold.Wall.Config.ClosedGateType[Type] and 1) or 0;
    XGUIEng.HighLightButton("ClosePalisadeGate", Highlight);
    XGUIEng.HighLightButton("CloseWallGate", Highlight);
end

GUIUpdate_TurnToGate = function()
end

GUIUpdate_TurnToWall = function()
end

function Stronghold.Wall:OnWallSelected(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    local TypeName = Logic.GetEntityTypeName(Type);
    if string.find(TypeName, "Palisade") then
        GUIUpdate_UpgradeButtons("Upgrade_Palisade", Technologies.UP1_Palisade);
    end
    GUIUpdate_OpenGate();
    GUIUpdate_CloseGate();

    XGUIEng.ShowWidget("Wall", 0);
    XGUIEng.ShowWidget("Commands_Wall", 0);
    XGUIEng.ShowWidget("Upgrade_Palisade", 0);
    XGUIEng.ShowWidget("OpenPalisadeGate", 0);
    XGUIEng.ShowWidget("ClosePalisadeGate", 0);
    XGUIEng.ShowWidget("OpenWallGate", 0);
    XGUIEng.ShowWidget("CloseWallGate", 0);
    XGUIEng.ShowWidget("TurnToPalisadeGate", 0);
    XGUIEng.ShowWidget("TurnToGate", 0);
    XGUIEng.ShowWidget("TurnToWall", 0);

    if Logic.IsConstructionComplete(_EntityID) == 1 then
        if self.Config.LegalWallType[Type] then
            XGUIEng.ShowWidget("Wall", 1);
            XGUIEng.ShowWidget("Commands_Wall", 1);
        end
        if self.Config.WoddenWallTypes[Type] then
            XGUIEng.ShowWidget("Upgrade_Palisade", 1);
            if self.Config.ClosedGateType[Type] then
                XGUIEng.ShowWidget("OpenPalisadeGate", 1);
                XGUIEng.ShowWidget("ClosePalisadeGate", 1);
                XGUIEng.ShowWidget("TurnToWall", 0);
            end
            if self.Config.OpenGateType[Type] then
                XGUIEng.ShowWidget("OpenPalisadeGate", 1);
                XGUIEng.ShowWidget("ClosePalisadeGate", 1);
                XGUIEng.ShowWidget("TurnToWall", 0);
            end
            if self.Config.WallSegmentType[Type] then
                XGUIEng.ShowWidget("ConvertToGate", 1);
                XGUIEng.ShowWidget("TurnToPalisadeGate", 1);
            end
        end
        if self.Config.StoneWallTypes[Type] then
            if self.Config.ClosedGateType[Type] then
                XGUIEng.ShowWidget("OpenWallGate", 1);
                XGUIEng.ShowWidget("CloseWallGate", 1);
                XGUIEng.ShowWidget("TurnToWall", 0);
            end
            if self.Config.OpenGateType[Type] then
                XGUIEng.ShowWidget("OpenWallGate", 1);
                XGUIEng.ShowWidget("CloseWallGate", 1);
                XGUIEng.ShowWidget("TurnToWall", 0);
            end
            if self.Config.WallSegmentType[Type] then
                XGUIEng.ShowWidget("ConvertToGate", 1);
                XGUIEng.ShowWidget("TurnToGate", 1);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Wall Logic

function Stronghold.Wall:OnWallOrPalisadeCreated(_EntityID)
    local SegmentType = Logic.GetEntityType(_EntityID);
    if self.Config.NeutralWallType[SegmentType] then
        self:MakeNeutralWallInvincible(_EntityID);
    end
    if self.Config.LegalWallType[SegmentType] then
        self:CreateWallCornerForSegment(_EntityID);
    end
end

function Stronghold.Wall:MakeNeutralWallsInvincible()
    for Type,_ in pairs(self.Config.NeutralWallType) do
        local OfPlayer = CEntityIterator.OfPlayerFilter(0);
        local OfType = CEntityIterator.OfTypeFilter(Type);
        for EntityID in CEntityIterator.Iterator(OfPlayer, OfType) do
            self:MakeNeutralWallInvincible(EntityID);
        end
    end
end

function Stronghold.Wall:MakeNeutralWallInvincible(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local EntityType = Logic.GetEntityType(_EntityID);
    if PlayerID == 0 or self.Config.NeutralWallType[EntityType] then
        MakeInvulnerable(_EntityID);
    end
end

function Stronghold.Wall:OnWallOrPalisadeUpgraded(_EntityID)
    -- Kerberos and Kala are building dark walls
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if IsPlayer(PlayerID) then
        if PlayerHasLordOfType(PlayerID, Entities.CU_BlackKnight)
        or PlayerHasLordOfType(PlayerID, Entities.CU_Evil_Queen) then
            local SegmentType = Logic.GetEntityType(_EntityID);
            SegmentType = Stronghold.Wall.Config.WallToDarkWall[SegmentType] or SegmentType;
            ReplaceEntity(_EntityID, SegmentType);
        end
    end
end

function Stronghold.Wall:OnWallOrPalisadeDestroyed(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local SegmentType = Logic.GetEntityType(_EntityID);
    if IsPlayer(PlayerID) then
        if self.Config.LegalWallType[SegmentType] then
            if self.Data[PlayerID].Corners[_EntityID] then
                DestroyEntity(self.Data[PlayerID].Corners[_EntityID][1]);
                DestroyEntity(self.Data[PlayerID].Corners[_EntityID][2]);
                self.Data[PlayerID].Corners[_EntityID] = nil;
            end
        end
    end
end

function Stronghold.Wall:OnGateOpenedCallback(_PlayerID, _EntityID, _Type)
    if Logic.EntityGetPlayer(_EntityID) ~= _PlayerID then
        return;
    end
    if not IsPlayer(_PlayerID) or not IsExisting(_EntityID) then
        return;
    end
    if Stronghold.Wall.Config.ClosedToOpenGate[_Type] then
        local Health = GetHealth(_EntityID);
        local ID = ReplaceEntity(_EntityID, Stronghold.Wall.Config.ClosedToOpenGate[_Type]);
        SetHealth(ID, Health);
        if _PlayerID == GUI.GetPlayerID() then
            GUI.SelectEntity(ID);
        end
    end
end

function Stronghold.Wall:OnGateClosedCallback(_PlayerID, _EntityID, _Type)
    if Logic.EntityGetPlayer(_EntityID) ~= _PlayerID then
        return;
    end
    if not IsPlayer(_PlayerID) or not IsExisting(_EntityID) then
        return;
    end
    if Stronghold.Wall.Config.OpenToClosedGate[_Type] then
        local Health = GetHealth(_EntityID);
        local ID = ReplaceEntity(_EntityID, Stronghold.Wall.Config.OpenToClosedGate[_Type]);
        SetHealth(ID, Health);
        if _PlayerID == GUI.GetPlayerID() then
            GUI.SelectEntity(ID);
        end
    end
end

function Stronghold.Wall:OnGateTurnedToWallCallback(_PlayerID, _EntityID, _Type)
    if Logic.EntityGetPlayer(_EntityID) ~= _PlayerID then
        return;
    end
    if not IsPlayer(_PlayerID) or not IsExisting(_EntityID) then
        return;
    end
    if Stronghold.Wall.Config.GateToWall[_Type] then
        local Position = GetPosition(_EntityID);
        local Orientation = Logic.GetEntityOrientation(_EntityID) - 45;
        local EntityType = Stronghold.Wall.Config.GateToWall[_Type];
        local ScriptName = Logic.GetEntityName(_EntityID);
        local Health = GetHealth(_EntityID);
        DestroyEntity(_EntityID);
        local ID = Logic.CreateEntity(EntityType, Position.X, Position.Y, Orientation, _PlayerID);
        Logic.SetEntityName(ID, ScriptName);
        SetHealth(ID, Health);
        if _PlayerID == GUI.GetPlayerID() then
            GUI.SelectEntity(ID);
        end
    end
end

function Stronghold.Wall:OnWallTurnedToGateCallback(_PlayerID, _EntityID, _Type)
    if Logic.EntityGetPlayer(_EntityID) ~= _PlayerID then
        return;
    end
    if not IsPlayer(_PlayerID) or not IsExisting(_EntityID) then
        return;
    end
    if Stronghold.Wall.Config.WallToGate[_Type] then
        local Position = GetPosition(_EntityID);
        local Orientation = Logic.GetEntityOrientation(_EntityID) + 45;
        local EntityType = Stronghold.Wall.Config.WallToGate[_Type];
        local ScriptName = Logic.GetEntityName(_EntityID);
        local Health = GetHealth(_EntityID);
        DestroyEntity(_EntityID);
        local ID = Logic.CreateEntity(EntityType, Position.X, Position.Y, Orientation, _PlayerID);
        Logic.SetEntityName(ID, ScriptName);
        SetHealth(ID, Health);
        if _PlayerID == GUI.GetPlayerID() then
            GUI.SelectEntity(ID);
        end
    end
end

function Stronghold.Wall:CreateWallCornerForSegment(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if IsPlayer(PlayerID) and IsExisting(_EntityID) then
        local IsGate = false;
        local SegmentType = Logic.GetEntityType(_EntityID);
        if self.Config.OpenGateType[SegmentType] or self.Config.ClosedGateType[SegmentType] then
            IsGate = true;
        end

        local Distance1 = 283.1;
        local Orientation = Logic.GetEntityOrientation(_EntityID);
        if Orientation == 45 or Orientation == 135 or Orientation == 225 or Orientation == 315 then
            Distance1 = (not IsGate and 300.1) or 300.1;
        else
            Distance1 = (not IsGate and 300.1) or 300.1;
        end

        local Angle1 = (IsGate and 90) or 135;
        local Angle2 = (IsGate and 270) or 315;
        local Position1 = GetCirclePosition(_EntityID, Distance1, Angle1);
        local Position2 = GetCirclePosition(_EntityID, Distance1, Angle2);
        local CornerType = self.Config.CornerForSegment[SegmentType];
        if not CornerType then
            return;
        end

        self.Data[PlayerID].Corners[_EntityID] = {};
        if not self:IsGroundToSteep(Position1.X, Position1.Y, 250) then
            local _, OtherID = Logic.GetEntitiesInArea(CornerType, Position1.X, Position1.Y, 200, 1);
            if OtherID then
                Position1 = GetCirclePosition(OtherID, 0.1, Angle1);
            end
            local ID = Logic.CreateEntity(CornerType, Position1.X, Position1.Y, 0, 1);
            table.insert(self.Data[PlayerID].Corners[_EntityID], ID);
        end
        if not self:IsGroundToSteep(Position2.X, Position2.Y, 250) then
            local _, OtherID = Logic.GetEntitiesInArea(CornerType, Position2.X, Position2.Y, 200, 1);
            if OtherID then
                Position2 = GetCirclePosition(OtherID, 0.1, Angle1);
            end
            local ID = Logic.CreateEntity(CornerType, Position2.X, Position2.Y, 0, 1);
            table.insert(self.Data[PlayerID].Corners[_EntityID], ID);
        end
    end
end

function Stronghold.Wall:IsGroundToSteep(_X, _Y, _Height)
    local Heights = {};
    for x = -200, 200, 200 do
        for y = -200, 200, 200 do
            local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, _X+x, _Y+y, 0, 0);
            if IsExisting(ID) then
                local _,_,z = Logic.EntityGetPos(ID);
                table.insert(Heights, z);
                DestroyEntity(ID);
            end
        end
    end

    local Highest = math.max(unpack(Heights));
    local Lowest  = math.min(unpack(Heights));
    if math.abs(Highest-Lowest) <= _Height then
        return false
    end
    return true;
end

