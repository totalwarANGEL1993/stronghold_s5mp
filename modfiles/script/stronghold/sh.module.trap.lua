--- 
--- Trap Script
---
--- This script implements special properties of traps.
--- 

Stronghold = Stronghold or {};

Stronghold.Trap = Stronghold.Trap or {
    SyncEvents = {},
    Data = {
        Trap = {},
        TrapDecoIDToTrapID = {},
        TrapRemains = {},
    },
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- Callbacks

--- Triggered when a unit spawning trap is triggered.
--- @param _PlayerID integer Owner of trap
--- @param _Type integer Type of trap
--- @param _X number X coordinate of trap
--- @param _Y number Y coordinate of trap
--- @param ... integer Spawned entities
function GameCallback_SH_Logic_OnSpawnTrapTriggered(_PlayerID, _Type, _X, _Y, ...)
end

--- Triggered when a AoE damage trap is triggered.
--- @param _PlayerID integer Owner of trap
--- @param _Type integer Type of trap
--- @param _X number X coordinate of trap
--- @param _Y number Y coordinate of trap
function GameCallback_SH_Logic_OnAoETrapTriggered(_PlayerID, _Type, _X, _Y)
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Trap:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            ExposedTraps = {},
        };
    end

    self:CreateTrapButtonHandlers();
    self:InitalizeTrapsCurrentlyExisting();
end

function Stronghold.Trap:OnSaveGameLoaded()
end

function Stronghold.Trap:CreateTrapButtonHandlers()
    self.SyncEvents = {
        TriggerTrap = 1,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Trap.SyncEvents.TriggerTrap then
                Stronghold.Trap:OnTrapTriggered(_PlayerID, arg[1]);
            end
        end
    );
end

function Stronghold.Trap:OncePerSecond(_PlayerID)
end

function Stronghold.Trap:OnEverySecond()
    self:TrapController();
end

function Stronghold.Trap:OnConstructionComplete(_EntityID, _PlayerID)
    self:OnTrapConstructed(_EntityID, _PlayerID)
end

function Stronghold.Trap:OnDiplomacyChanged(_PlayerID1, _PlayerID2, _DiplomacyState)
    self:UpdateTrapVisibilityOnDiplomacyChange(_PlayerID1, _PlayerID2, _DiplomacyState);
end

function Stronghold.Trap:OnPlacementCheck(_PlayerID, _Type, _X, _Y, _Rotation, _IsBuildOn)
    if self.Config.TrapTypeConfig[_Type] then
        local NoEnemyDistance = self.Config.TrapTypeConfig[_Type].NoEnemyDistance;
        if AreEnemiesInArea(_PlayerID, {X= _X, Y= _Y}, NoEnemyDistance) then
            return false;
        end
    end
    return true;
end

-- -------------------------------------------------------------------------- --
-- Traps Logic

function Stronghold.Trap:InitalizeTrapsCurrentlyExisting()
    for PlayerID = 1, GetMaxPlayers() do
        local Buildings = GetPlayerEntities(PlayerID, 0);
        for i= 1, table.getn(Buildings) do
            self:OnTrapConstructed(Buildings[i], PlayerID);
        end
    end
end

function Stronghold.Trap:OnTrapTriggered(_PlayerID, _TrapID)
    local PlayerID = Logic.EntityGetPlayer(_TrapID);
    if PlayerID ~= _PlayerID then
        return;
    end
    local EntityType = Logic.GetEntityType(_TrapID);
    if EntityType == Entities.PB_BearCage1 then
        self:OnBearCageTriggered(_PlayerID, _TrapID);
    elseif EntityType == Entities.PB_DogCage1 then
        self:OnDogCageTriggered(_PlayerID, _TrapID);
    elseif EntityType == Entities.PB_Traphole1 then
        self:OnTrapholeTriggered(_PlayerID, _TrapID);
    elseif EntityType == Entities.PB_PitchPit1 then
        self:OnPitchpitTriggered(_PlayerID, _TrapID);
    end
end

function Stronghold.Trap:OnTrapConstructed(_TrapID, _PlayerID)
    local GuiPlayer = GUI.GetPlayerID();
    local EntityType = Logic.GetEntityType(_TrapID);
    local Config = self.Config.TrapTypeConfig[EntityType];
    if not Config then
        return;
    end

    if GuiPlayer ~= 17 and GuiPlayer ~= _PlayerID then
        if Logic.GetDiplomacyState(_PlayerID, GuiPlayer) ~= Diplomacy.Friendly then
            SVLib.SetInvisibility(_TrapID, true);
        end
    end

    local Attachment = {0};
    -- Create deco bear
    if EntityType == Entities.PB_BearCage1 then
        local x,y,z = Logic.EntityGetPos(_TrapID);
        local Rotation = Logic.GetEntityOrientation(_TrapID) - 90;
        local AnimalID = Logic.CreateEntity(Entities.PU_Bear_Deco, x, y, Rotation, _PlayerID);
        Logic.SetTaskList(AnimalID, TaskLists.TL_NPC_IDLE);
        MakeInvulnerable(AnimalID);
        SVLib.SetEntitySize(AnimalID, 0.85);
        Attachment = {1, AnimalID};
    -- Create deco dog
    elseif EntityType == Entities.PB_DogCage1 then
        local x,y,z = Logic.EntityGetPos(_TrapID);
        local Rotation = Logic.GetEntityOrientation(_TrapID) - 90;
        local AnimalID = Logic.CreateEntity(Entities.PU_Dog_Deco, x, y, Rotation, _PlayerID);
        Logic.SetTaskList(AnimalID, TaskLists.TL_NPC_IDLE);
        MakeInvulnerable(AnimalID);
        Attachment = {1, AnimalID};
    end
    if Attachment[1] ~= 0 and GuiPlayer ~= 17 and GuiPlayer ~= _PlayerID then
        for i= 2, Attachment[1] +1 do
            if Logic.GetDiplomacyState(_PlayerID, GuiPlayer) ~= Diplomacy.Friendly then
                SVLib.SetInvisibility(Attachment[i], true);
            end
        end
    end

    self.Data.Trap[_TrapID] = {_PlayerID, EntityType, Attachment};
end

function Stronghold.Trap:OnBearCageTriggered(_PlayerID, _TrapID)
    if IsExisting(_TrapID) then
        local x,y,z = Logic.EntityGetPos(_TrapID);
        for i= 2, self.Data.Trap[_TrapID][3][1] +1 do
            DestroyEntity(self.Data.Trap[_TrapID][3][i]);
        end
        SetHealth(_TrapID, 0);
        local ID = AI.Entity_CreateFormation(_PlayerID, Entities.PU_Bear_Cage, nil, 0, x, y, 0, 0, 0, 0);
        Logic.SetEntitySelectableFlag(ID, 0);
        GameCallback_SH_Logic_OnSpawnTrapTriggered(_PlayerID, Entities.PB_BearCage1, x, y, ID);
        Job.Second(function(_AnimalID, _X, _Y)
            return Stronghold.Trap:TrapAggressiveAnimalController(_AnimalID, _X, _Y);
        end, ID, x, y);
    end
end

function Stronghold.Trap:OnDogCageTriggered(_PlayerID, _TrapID)
    if IsExisting(_TrapID) then
        local x,y,z = Logic.EntityGetPos(_TrapID);
        for i= 2, self.Data.Trap[_TrapID][3][1] +1 do
            DestroyEntity(self.Data.Trap[_TrapID][3][i]);
        end
        SetHealth(_TrapID, 0);

        local AnimalsCreated = {};
        for i= 1, 3 do
            local ID = AI.Entity_CreateFormation(_PlayerID, Entities.PU_Dog_Cage, nil, 0, x, y, 0, 0, 0, 0);
            Logic.SetEntitySelectableFlag(ID, 0);
            table.insert(AnimalsCreated, ID);
            Job.Second(function(_AnimalID, _X, _Y)
                return Stronghold.Trap:TrapAggressiveAnimalController(_AnimalID, _X, _Y);
            end, ID, x, y);
        end
        GameCallback_SH_Logic_OnSpawnTrapTriggered(_PlayerID, Entities.PB_DogCage1, x, y, unpack(AnimalsCreated));
    end
end

function Stronghold.Trap:OnTrapholeTriggered(_PlayerID, _TrapID)
    if IsExisting(_TrapID) then
        local x,y,z = Logic.EntityGetPos(_TrapID);
        for Angle = 45, 360, 45 do
            local Position = GetCirclePosition(_TrapID, 230, Angle);
            local DecoID = Logic.CreateEntity(Entities.XD_Traphole_Activated, Position.X, Position.Y, 0, 0);
            self.Data.TrapRemains[DecoID] = {5};
        end
        Sound.Play2DSound(Sounds.Military_SO_Bearman_rnd_1, 0, 127);
        local DamageDealerID = Logic.CreateEntity(Entities.XD_Traphole_Activated, x, y, 0, _PlayerID);
        self.Data.TrapRemains[DamageDealerID] = {5};
        SetHealth(_TrapID, 0);
        GameCallback_SH_Logic_OnAoETrapTriggered(_PlayerID, Entities.PB_Traphole1, x, y);
        -- Does crash for some reason...
        -- CEntity.DealDamageInArea(DamageDealerID, x, y, EffectArea, Damage);
        -- Workaround:
        Logic.CreateEntity(Entities.XD_Bomb_Traphole, x, y, 0, _PlayerID);
    end
end

function Stronghold.Trap:OnPitchpitTriggered(_PlayerID, _TrapID)
    if IsExisting(_TrapID) then
        local Duration = 30;
        local x, y, z = Logic.EntityGetPos(_TrapID);
        local DamageDealerID = Logic.CreateEntity(Entities.XD_ScriptEntity, x, y, 0, _PlayerID);
        Logic.SetModelAndAnimSet(DamageDealerID, Models.Effects_XF_HouseFire);
        SVLib.SetEntitySize(DamageDealerID, 0.5);
        SVLib.SetInvisibility(DamageDealerID, false);
        Sound.Play2DSound(Sounds.AmbientSounds_campfire_rnd_1, 0, 127);
        SetHealth(_TrapID, 0);
        self.Data.TrapRemains[DamageDealerID] = {Duration};

        for Angle = 90, 360, 90 do
            local Position = GetCirclePosition({X= x, Y= y}, 100, Angle);
            local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, Position.X, Position.Y, 0, _PlayerID);
            Logic.SetModelAndAnimSet(ID, Models.Effects_XF_HouseFireLo);
            Logic.SetEntityExplorationRange(ID, 10);
            SVLib.SetEntitySize(ID, 0.5);
            SVLib.SetInvisibility(ID, false);
            self.Data.TrapRemains[ID] = {Duration};
        end
        for Angle = 45, 315, 90 do
            local Position = GetCirclePosition({X= x, Y= y}, 200, Angle);
            local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, Position.X, Position.Y, 0, _PlayerID);
            Logic.SetModelAndAnimSet(ID, Models.Effects_XF_HouseFireMedium);
            SVLib.SetEntitySize(ID, 0.5);
            SVLib.SetInvisibility(ID, false);
            self.Data.TrapRemains[ID] = {Duration};
        end
        for Angle = 90, 360, 90 do
            local Position = GetCirclePosition({X= x, Y= y}, 300, Angle);
            local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, Position.X, Position.Y, 0, _PlayerID);
            Logic.SetModelAndAnimSet(ID, Models.Effects_XF_HouseFireSmall);
            SVLib.SetEntitySize(ID, 0.5);
            SVLib.SetInvisibility(ID, false);
            self.Data.TrapRemains[ID] = {Duration};
        end

        GameCallback_SH_Logic_OnAoETrapTriggered(_PlayerID, Entities.PB_PitchPit1, x, y);

        Job.Second(function(_Time, _X, _Y, _EntityID)
            -- Stop after delay
            if not IsExisting(_EntityID) or _Time + Duration < Logic.GetTime() then
                return true;
            end

            local PlayerID = Logic.EntityGetPlayer(_EntityID);

            -- Deal damage
            -- Does crash for some reason...
            -- CEntity.DealDamageInArea(_EntityID, _X, _Y, 300, 25);
            -- Workaround:
            Logic.CreateEntity(Entities.XD_Bomb_PitchPit, _X, _Y, 0, _PlayerID);

            -- Ignite closeby
            local _, NearPitchID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_PitchPit1, _X, _Y, 800, 1);
            if NearPitchID and Logic.IsConstructionComplete(NearPitchID) == 1 then
                self:OnPitchpitTriggered(_PlayerID, NearPitchID);
            end
        end, Logic.GetTime(), x, y, DamageDealerID);
    end
end

-- Controls the traps.
-- Some traps have attached entities. If any is destroyed, the trap will be
-- destroyed. If the trap is destroyed, the attachment is destroyed.
function Stronghold.Trap:TrapController()
    -- Traps
    for TrapID, Data in pairs(self.Data.Trap) do
        if not IsExisting(TrapID) then
            for i= 2, Data[3][1] +1 do
                self.Data.TrapDecoIDToTrapID[Data[3][i]] = nil;
                DestroyEntity(Data[3][i]);
            end
            self.Data.Trap[TrapID] = nil;
        else
            local PlayerID = Logic.EntityGetPlayer(TrapID);
            local Type = Logic.GetEntityType(TrapID);
            local Config = self.Config.TrapTypeConfig[Type];
            local AutoTrigger = (IsAIPlayer(PlayerID) or Config.AutoTrigger) == true;
            if Config then
                if Config.AutoTrigger or AutoTrigger then
                    local Position = GetPosition(TrapID);
                    local Area = Config.AutoTriggerDistance;
                    if AreEnemiesInArea(PlayerID, Position, Area) then
                        self:OnTrapTriggered(PlayerID, TrapID);
                    end
                end
                if Config.UnveilByThief then
                    self:UpdateTrapVisibilityOnDiscovery(PlayerID, TrapID);
                end
            end
        end
    end
    -- Remains
    for RemainID, Data in pairs(self.Data.TrapRemains) do
        if IsExisting(RemainID) then
            self.Data.TrapRemains[RemainID][1] = math.max(Data[1] - 1, 0);
            if Data[1] <= 0 then
                self.Data.TrapDecoIDToTrapID[RemainID] = nil;
                DestroyEntity(RemainID);
            end
        end
    end
end

-- Controls spawned animals.
-- Animals will attack close enemies. If they stray to far from the spawn
-- position, they will return to it.
function Stronghold.Trap:TrapAggressiveAnimalController(_EntityID, _X, _Y)
    if not IsValidEntity(_EntityID) then
        return true;
    end

    local MaxDistance = 5000;
    if GetDistance(_EntityID, {X= _X, Y= _Y}) > MaxDistance then
        Logic.MoveSettler(_EntityID, _X, _Y);
        return false;
    end

    if not IsFighting(_EntityID) and not Logic.IsEntityMoving(_EntityID) then
        local PlayerID = Logic.EntityGetPlayer(_EntityID);
        local Enemies = GetEnemiesInArea(PlayerID, {X= _X, Y= _Y}, MaxDistance);
        if Enemies[1] then
            local x,y,z = Logic.EntityGetPos(Enemies[1]);
            Logic.GroupAttackMove(_EntityID, x, y);
        end
    end
    return false;
end

-- Controls trap invisibility.
-- Traps can be pernamently exposed by a thief. This is only possible, if the
-- owner of the thief and the owner of the trap are hostile to each other. If
-- a thief comes to close to a trap of the enemy, it becomes visible for the 
-- owner and their allies.
function Stronghold.Trap:UpdateTrapVisibilityOnDiscovery(_PlayerID, _TrapID)
    if SVLib.GetInvisibility(_TrapID) then
        local x,y,z = Logic.EntityGetPos(_TrapID);
        local Type = Logic.GetEntityType(_TrapID);
        local Area = self.Config.TrapTypeConfig[Type].ThiefUnveilDistance;

        local OwnerOfThief = 0;
        for PlayerID = 1, GetMaxPlayers(), 1 do
            if _PlayerID ~= PlayerID and Logic.GetDiplomacyState(PlayerID, _PlayerID) == Diplomacy.Hostile then
                local _, ThiefID = Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PU_Thief, x, y, Area, 1);
                if ThiefID then
                    OwnerOfThief = PlayerID;
                    break;
                end
            end
        end
        if OwnerOfThief ~= 0 then
            for PlayerID = 1, GetMaxPlayers(), 1 do
                if Logic.GetDiplomacyState(PlayerID, OwnerOfThief) == Diplomacy.Friendly
                or PlayerID == OwnerOfThief then
                    local TrapData = self.Data.Trap[_TrapID];
                    SVLib.SetInvisibility(_TrapID, false);
                    for i= 2, TrapData[3][1] +1 do
                        SVLib.SetInvisibility(TrapData[3][i], false);
                    end
                    self.Data[PlayerID].ExposedTraps[_TrapID] = true;
                end
            end
        end
    end
end

-- Controls trap invisibility on diplomacy change.
-- Each time diplomacy changes, the visiblity of traps changes. When a player
-- becomes friendly to another they will see all placed traps but they are not
-- registered as exposed. When a player becomes hostile or neutral, all traps
-- not exposed by a thief are hidden again.
function Stronghold.Trap:UpdateTrapVisibilityOnDiplomacyChange(_PlayerID1, _PlayerID2, _DiplomacyState)
    if IsPlayer(_PlayerID1) then
        for TrapID, TrapData in pairs(self.Data.Trap) do
            if IsEntityValid(TrapID) then
                local TrapPlayerID = Logic.EntityGetPlayer(TrapID);
                -- Make traps invisible for hostile or neutral players
                if _DiplomacyState == Diplomacy.Hostile
                or _DiplomacyState == Diplomacy.Neutral then
                    if GUI.GetPlayerID() == _PlayerID1 and TrapPlayerID == _PlayerID2 then
                        if not self.Data[_PlayerID1].ExposedTraps[TrapID] then
                            SVLib.SetInvisibility(TrapID, true);
                            for i= 2, TrapData[3][1] +1 do
                                SVLib.SetInvisibility(TrapData[3][i], true);
                            end
                        end
                    end
                end
                -- Make traps visible for allied players
                if _DiplomacyState == Diplomacy.Friendly then
                    if GUI.GetPlayerID() == _PlayerID1 and TrapPlayerID == _PlayerID2 then
                        if not self.Data[_PlayerID1].ExposedTraps[TrapID] then
                            SVLib.SetInvisibility(TrapID, false);
                            for i= 2, TrapData[3][1] +1 do
                                SVLib.SetInvisibility(TrapData[3][i], false);
                            end
                        end
                    end
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Traps GUI

function Stronghold.Trap:OnTrapSelected(_EntityID)
    -- Workaround for selection because I am unable to change the model.
    if self.Data.TrapDecoIDToTrapID[_EntityID] then
        GUI.ClearSelection();
        GUI.SelectEntity(self.Data.TrapDecoIDToTrapID[_EntityID]);
        return;
    end
    if Logic.IsConstructionComplete(_EntityID) == 0 then
        XGUIEng.ShowWidget("Trap", 0);
        return;
    end

    -- Trigger button not needed anymore
    XGUIEng.ShowWidget("TriggerTrap", 0);

    local TrapType = Logic.GetEntityType(_EntityID);
    if TrapType == Entities.PB_BearCage1 then
        XGUIEng.ShowWidget("Trap", 1);
        XGUIEng.ShowWidget("Commands_Trap", 1);
        XGUIEng.ShowAllSubWidgets("Commands_Trap", 0);
        -- XGUIEng.ShowWidget("Research_BearTraining", 1);
        XGUIEng.ShowWidget("TriggerTrap", 1);
    elseif TrapType == Entities.PB_DogCage1 then
        XGUIEng.ShowWidget("Trap", 1);
        XGUIEng.ShowWidget("Commands_Trap", 1);
        XGUIEng.ShowAllSubWidgets("Commands_Trap", 0);
        -- XGUIEng.ShowWidget("Research_DogTraining", 1);
        XGUIEng.ShowWidget("TriggerTrap", 1);
    elseif TrapType == Entities.PB_Traphole1 then
        XGUIEng.ShowWidget("Trap", 1);
        XGUIEng.ShowWidget("Commands_Trap", 1);
        XGUIEng.ShowAllSubWidgets("Commands_Trap", 0);
    elseif TrapType == Entities.PB_PitchPit1 then
        XGUIEng.ShowWidget("Trap", 1);
        XGUIEng.ShowWidget("Commands_Trap", 1);
        XGUIEng.ShowAllSubWidgets("Commands_Trap", 0);
        XGUIEng.ShowWidget("TriggerTrap", 1);
    else
        XGUIEng.ShowWidget("Trap", 0);
    end
end

function GUIAction_TriggerTrap()
    local EntityID = GUI.GetSelectedEntity();
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    if PlayerID ~= GUI.GetPlayerID() then
        return;
    end
    GUI.ClearSelection();
    Syncer.InvokeEvent(
        Stronghold.Trap.NetworkCall,
        Stronghold.Trap.SyncEvents.TriggerTrap,
        EntityID
    );
end

function GUITooltip_TriggerTrap()
    local ShortCut = XGUIEng.GetStringTableText("keybindings/ReserachTechnologies4");
    local ShortCutDesc = XGUIEng.GetStringTableText("MenuGeneric/Key_name");
    local ShortCutToolTip = ShortCutDesc .. ": [" .. ShortCut .. "]";
    local Text = XGUIEng.GetStringTableText("sh_menutrap/triggertrap_normal");
    if XGUIEng.IsButtonDisabled("TriggerTrap") == 1 then
        Text = XGUIEng.GetStringTableText("sh_menutrap/triggertrap_disabled");
    end
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
end

function GUIUpdate_TriggerTrap()
end

