--- 
--- Multiplayer Script
---
--- Implements a rudimentary rule system to configure a multiplayer game.
---
--- Defined game callbacks:
--- - GameCallback_Logic_OnGameStart()
---   Called when the map is loaded.
---   
--- - GameCallback_Logic_OnConfigurated()
---   Called when configuration is confirmed by the host.
---   
--- - GameCallback_Logic_OnPeaceTimeOver()
---   Called when peacetime is over.
--- 

Stronghold = Stronghold or {};

Stronghold.Multiplayer = {
    SyncEvents = {},
    Data = {},
    Config = {},
    Text = {},
}

function Stronghold.Multiplayer:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {
            ReplacedEntities = {};
        };
    end
    self.Data.IsRuleConfigurationActive = false;
    self.Data.Config = {};

    self:ConfigureReset();
    self:CreateMultiplayerButtonHandlers();
    self:OverrideFunctions();
    self:OnGameStart();
end

function Stronghold.Multiplayer:OnSaveGameLoaded()
end

function Stronghold.Multiplayer:CreateMultiplayerButtonHandlers()
    self.SyncEvents = {
        ChangeResource = 1,
        ChangeHero = 2,
        ChangeStartRank = 3,
        ChangeFinalRank = 4,
        ChangePeacetime = 5,
        Reset = 6,
        Confirm = 7,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Multiplayer.SyncEvents.ChangeResource then
                Stronghold.Multiplayer:ConfigureResource(arg[1]);
            elseif _Action == Stronghold.Multiplayer.SyncEvents.ChangeHero then
                Stronghold.Multiplayer:ConfigureHeroAllowed(arg[1], arg[2]);
            elseif _Action == Stronghold.Multiplayer.SyncEvents.ChangeStartRank then
                Stronghold.Multiplayer:ConfigureInitialRank(arg[1]);
            elseif _Action == Stronghold.Multiplayer.SyncEvents.ChangeFinalRank then
                Stronghold.Multiplayer:ConfigureFinalRank(arg[1]);
            elseif _Action == Stronghold.Multiplayer.SyncEvents.ChangePeacetime then
                Stronghold.Multiplayer:ConfigurePeaceTime(arg[1]);
            elseif _Action == Stronghold.Multiplayer.SyncEvents.Reset then
                Stronghold.Multiplayer:ConfigureReset();
            elseif _Action == Stronghold.Multiplayer.SyncEvents.Confirm then
                Stronghold.Multiplayer:Configure();
            end
        end
    );
end

-- -------------------------------------------------------------------------- --

--- Takes a configuration and immediately confirms it.
--- @param _Config table Configuration
function SetupStrongholdMultiplayerConfig(_Config)
    if not _Config then
        _Config = Stronghold.Multiplayer.Config.DefaultSettings;
    end
    Stronghold.Multiplayer.Data.Config = _Config;
    Stronghold.Multiplayer:Configure();
end

--- Displays the configuration window for the host.
function ShowStrongholdConfiguration()
    Stronghold.Multiplayer:ConfigureReset();
    Stronghold.Multiplayer:ShowRuleSelection();
    -- TODO !!!
end

-- -------------------------------------------------------------------------- --

function GameCallback_Logic_OnGameStart()
end

function GameCallback_Logic_OnConfigurated()
end

function GameCallback_Logic_OnPeaceTimeOver()
end

-- -------------------------------------------------------------------------- --

function GUIAction_SHMP_Config_SetHeroAllowed(_Type)
    -- Only host can trigger action
    if GUI.GetPlayerID() ~= Syncer.GetHostPlayerID() then
        return;
    end
    local Flag = not Stronghold.Multiplayer.Data.Config.AllowedHeroes[_Type];
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.ChangeHero,
        _Type, Flag
    );
end

function GUIAction_SHMP_Config_SetResource(_Amount)
    -- Only host can trigger action
    if GUI.GetPlayerID() ~= Syncer.GetHostPlayerID() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.ChangeResource,
        _Amount
    );
end

function GUIAction_SHMP_Config_SetInitialRank(_Rank)
    -- Only host can trigger action
    if GUI.GetPlayerID() ~= Syncer.GetHostPlayerID() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.ChangeStartRank,
        _Rank
    );
end

function GUIAction_SHMP_Config_SetFinalRank(_Rank)
    -- Only host can trigger action
    if GUI.GetPlayerID() ~= Syncer.GetHostPlayerID() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.ChangeFinalRank,
        _Rank
    );
end

function GUIAction_SHMP_Config_SetPeaceTime(_Time)
    -- Only host can trigger action
    if GUI.GetPlayerID() ~= Syncer.GetHostPlayerID() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.ChangePeacetime,
        _Time
    );
end

function GUIAction_SHMP_Config_Reset()
    -- Only host can trigger action
    if GUI.GetPlayerID() ~= Syncer.GetHostPlayerID() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.Reset
    );
end

function GUIAction_SHMP_Config_Confirm()
    -- Only host can trigger action
    if GUI.GetPlayerID() ~= Syncer.GetHostPlayerID() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.Confirm
    );
end

-- -------------------------------------------------------------------------- --

function GUITooltip_SHMP_Config_SetHeroAllowed(_Type, _TextKey)
    local TypeName = Logic.GetEntityTypeName(_Type);
    local Name = XGUIEng.GetStringTableText("names/" ..TypeName);
    local Text = string.format(XGUIEng.GetStringTableText(_TextKey), Name);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

function GUITooltip_SHMP_Config_SetResource(_Amount, _TextKey)
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, _TextKey .. _Amount);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

function GUITooltip_SHMP_Config_SetInitialRank(_Rank, _TextKey)
    local Name = GetRankName(_Rank, GUI.GetPlayerID());
    local Text = string.format(XGUIEng.GetStringTableText(_TextKey), Name);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

function GUITooltip_SHMP_Config_SetFinalRank(_Rank, _TextKey)
    local Name = GetRankName(_Rank, GUI.GetPlayerID());
    local Text = string.format(XGUIEng.GetStringTableText(_TextKey), Name);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

function GUITooltip_SHMP_Config_Reset(_TextKey)
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, _TextKey);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

function GUITooltip_SHMP_Config_Confirm(_TextKey)
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, _TextKey);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

-- -------------------------------------------------------------------------- --

function GUIUpdate_SHMP_Config_SetHeroAllowed(_Widget, _Type)
    local Flag = (Stronghold.Multiplayer.Data.Config.AllowedHeroes[_Type] and 0) or 1;
    XGUIEng.HighlightButton(_Widget, Flag);
end

function GUIUpdate_SHMP_Config_SetResource(_Widget, _Type)
    local Selected = Stronghold.Multiplayer.Data.Config.ResourceSelected or 0;
    local Flag = (string.find(_Widget, "ResourceAmount" ..Selected) ~= nil and 1) or 0;
    XGUIEng.HighlightButton(_Widget, Flag);
end

function GUIUpdate_SHMP_Config_SetInitialRank(_Widget)
    local Rank = Stronghold.Multiplayer.Data.Config.Rank.Initial;
    local Flag = (string.find(_Widget, "InitialRank" ..Rank) ~= nil and 1) or 0;
    XGUIEng.HighlightButton(_Widget, Flag);
end

function GUIUpdate_SHMP_Config_SetFinalRank(_Widget)
    local Rank = Stronghold.Multiplayer.Data.Config.Rank.Final;
    local Flag = (string.find(_Widget, "FinalRank" ..Rank) ~= nil and 1) or 0;
    XGUIEng.HighlightButton(_Widget, Flag);
end

function GUIUpdate_SHMP_Config_Reset(_Widget)
    -- Only show for host
    if GUI.GetPlayerID() ~= Syncer.GetHostPlayerID() then
        XGUIEng.ShowWidget(_Widget, 0);
    end
end

function GUIUpdate_SHMP_Config_Confirm(_Widget)
    -- Only show for host
    if GUI.GetPlayerID() ~= Syncer.GetHostPlayerID() then
        XGUIEng.ShowWidget(_Widget, 0);
    end
end

-- -------------------------------------------------------------------------- --

function Stronghold.Multiplayer:ConfigureResource(_Amount)
    if _Amount == 0 then
        self.Data.Config.Resources = {0, 600, 1200, 1500, 550, 0, 0};
    elseif _Amount == 1 then
        self.Data.Config.Resources = {50, 2500, 3000, 3500, 2000, 800, 800};
    elseif _Amount == 2 then
        self.Data.Config.Resources = {300, 5000, 6000, 8000, 4500, 3000, 3000};
    end
    self.Data.Config.ResourceSelected = _Amount;
    -- TODO: Update UI
end

function Stronghold.Multiplayer:ConfigureHeroAllowed(_Type, _Allowed)
    self.Data.Config.AllowedHeroes[_Type] = _Allowed == true;
    -- TODO: Update UI
end

function Stronghold.Multiplayer:ConfigureInitialRank(_Rank)
    self.Data.Config.Rank.Initial = _Rank;
    -- Update final rank as well
    local FinalRank = self.Data.Config.Rank.Final;
    self.Data.Config.Rank.Final = math.max(FinalRank, _Rank);
    -- TODO: Update UI
end

function Stronghold.Multiplayer:ConfigureFinalRank(_Rank)
    self.Data.Config.Rank.Final = _Rank;
    -- Update initial rank as well
    local StartingRank = self.Data.Config.Rank.Initial;
    self.Data.Config.Rank.Initial = math.min(StartingRank, _Rank);
    -- TODO: Update UI
end

function Stronghold.Multiplayer:ConfigurePeaceTime(_Time)
    self.Data.Config.PeaceTime = _Time * 10;
    -- TODO: Update UI
end

function Stronghold.Multiplayer:ConfigureReset()
    self.Data.Config = self.Config.DefaultSettings;
    -- TODO: Update UI (if visible)
end

function Stronghold.Multiplayer:Configure()
    self:HideRuleSelection();

    -- Setup ranks
    if self.Data.Config.Rank then
        local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer();
        for PlayerID= 1, HumenPlayer, 1 do
            SetRank(PlayerID, self.Data.Config.Rank.Initial or 0);
            Stronghold.Rights:SetPlayerMaxRank(PlayerID, self.Data.Config.Rank.Final or 7);
        end
    end

    -- Setup resources
    if self.Data.Config.Resources then
        local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer();
        for PlayerID= 1, HumenPlayer, 1 do
            AddHonor(PlayerID, self.Data.Config.Resources[1] or 0);
            Tools.GiveResouces(
                PlayerID,
                self.Data.Config.Resources[2] or 0,
                self.Data.Config.Resources[3] or 0,
                self.Data.Config.Resources[4] or 0,
                self.Data.Config.Resources[5] or 0,
                self.Data.Config.Resources[6] or 0,
                self.Data.Config.Resources[7] or 0
            );
        end
    end

    -- Setup heroes
    if self.Data.Config.AllowedHeroes then
        for k,v in pairs(self.Data.Config.AllowedHeroes) do
            BuyHero.AllowHero(k, v == true);
        end
    end

    -- Finally setup game
    self:OnGameModeSet();
end

-- -------------------------------------------------------------------------- --

function Stronghold.Multiplayer:ShowRuleSelection()
    -- Register rule selection active
    self.Data.IsRuleConfigurationActive = true;
    -- Suspend players
    local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer();
    for PlayerID= 1, HumenPlayer do
        self:SuspendPlayer(PlayerID);
    end
    -- TODO: Show window
end

function Stronghold.Multiplayer:HideRuleSelection()
    -- Register rule selection inactive
    self.Data.IsRuleConfigurationActive = false;
    -- Resume players
    local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer();
    for PlayerID= 1, HumenPlayer do
        self:ResumePlayer(PlayerID);
    end
    -- TODO: Hide window
end

function Stronghold.Multiplayer:SuspendPlayer(_PlayerID)
    self:ResumePlayer(_PlayerID);
    for k,v in pairs(GetPlayerEntities(_PlayerID, 0)) do
        if Logic.IsBuilding(v) == 1 then
            local Type = Logic.GetEntityType(v);
            local TypeName = Logic.GetEntityTypeName(Type);
            if not string.find(TypeName, "Headquarter") then
                local ID = ReplaceEntity(v, Entities.XD_ScriptEntity);
                table.insert(self.Data[_PlayerID].ReplacedEntities, {ID, Type, 0});
            end
        elseif Logic.IsSettler(v) == 1 then
            local Soldiers = {Logic.GetSoldiersAttachedToLeader(v)};
            for i= 1, Soldiers[1] +1 do
                DestroyEntity(Soldiers[i]);
            end
            local Type = Logic.GetEntityType(v);
            local ID = ReplaceEntity(v, Entities.XD_ScriptEntity);
            table.insert(self.Data[_PlayerID].ReplacedEntities, {ID, Type, Soldiers[1]});
        end
    end
end

function Stronghold.Multiplayer:ResumePlayer(_PlayerID)
    for i= 1, table.getn(self.Data[_PlayerID].ReplacedEntities) do
        local ID = self.Data[_PlayerID].ReplacedEntities[i][1];
        local Type = self.Data[_PlayerID].ReplacedEntities[i][2];
        local Soldiers = 0;
        if Logic.IsEntityTypeInCategory(Type, EntityCategories.Soldier) == 1 then
            Soldiers = self.Data[_PlayerID].ReplacedEntities[i][3];
        end
        ID = ReplaceEntity(ID, Type);
        if Soldiers > 0 then
            Tools.CreateSoldiersForLeader(ID, Soldiers);
        end
    end
    self.Data[_PlayerID].ReplacedEntities = {};
end

function Stronghold.Multiplayer:DeselectAll()
    local Selection = {GUI.GetSelectedEntities()};
    if Selection[1] and self.Data.IsRuleConfigurationActive then
        GUI.ClearSelection();
    end
end

-- -------------------------------------------------------------------------- --

function Stronghold.Multiplayer:OnGameStart()
    -- Do it delayed by 1 turn just to be sure all went trought.
    Stronghold:AddDelayedAction(1, function()
        GameCallback_Logic_OnGameStart();
    end);
end

function Stronghold.Multiplayer:OnPeaceTimeOver()
    -- Open named gates
    if self.Data.Config.PeaceTimeOpenGates then
        local Index = 0;
        while true do
            Index = Index +1;
            if not IsExisting("PTGate" ..Index) then
                break;
            end

            local ID = GetID("PTGate" ..Index);
            local Type = Logic.GetEntityType(ID);
            if Type == Entities.XD_PalisadeGate1 then
                -- FIXME: Was that the opened one?
                ReplaceEntity(ID, Entities.XD_PalisadeGate2);
            end
            if Type == Entities.XD_DarkWallStraightGate_Closed then
                ReplaceEntity(ID, Entities.XD_DarkWallStraightGate);
            end
            if Type == Entities.XD_WallStraightGate_Closed then
                ReplaceEntity(ID, Entities.XD_WallStraightGate);
            end
        end
    end

    -- Setup diplomacy
    MultiplayerTools.SetUpDiplomacyOnMPGameConfig();

    -- Peacetime callback
    GameCallback_Logic_OnPeaceTimeOver();
end

function Stronghold.Multiplayer:OnGameModeSet()
    if XNetwork ~= nil then
        Script.Load("Data\\Script\\MapTools\\MultiPlayer\\VC_Deathmatch.lua");
        Script.Load("Data\\Script\\MapTools\\MultiPlayer\\PeaceTime.lua");

        Action_PeaceTime = function()
            GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/Note_PeaceTimeOver"));
	        GUIAction_ToggleStopWatch(0, 0);
	        Sound.PlayGUISound(Sounds.OnKlick_Select_kerberos, 127);
            Stronghold.Multiplayer:OnPeaceTimeOver();
        end

        -- Start default victory condition?
        if not self.Data.Config.DisableDefaultWinCondition then
		    Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "VC_Deathmatch", 1);
        end

        -- Start peacetime?
        local PeaceTime = self.Data.Config.PeaceTime or 0;
        if PeaceTime > 0 then
            MultiplayerTools.PeaceTime = math.ceil(PeaceTime) * 60;
            GUIAction_ToggleStopWatch(MultiplayerTools.PeaceTime, 1);
            Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "Condition_PeaceTime", "Action_PeaceTime", 1);
            GameCallback_Logic_OnConfigurated();
        else
            GameCallback_Logic_OnConfigurated();
            self:OnPeaceTimeOver();
        end
    end
end

function Stronghold.Multiplayer:OverrideFunctions()
    Overwrite.CreateOverwrite("GameCallback_GUI_SelectionChanged", function()
        Overwrite.CallOriginal();
        Stronghold.Multiplayer:DeselectAll();
    end);

    if MultiplayerTools then
        self.Orig_MultiplayerTools_SetUpGameLogicOnMPGameConfig = MultiplayerTools.SetUpGameLogicOnMPGameConfig;
        MultiplayerTools.SetUpGameLogicOnMPGameConfig = function()
            Stronghold.Multiplayer.Orig_MultiplayerTools_SetUpGameLogicOnMPGameConfig();
            Stronghold.Multiplayer:OnGameStart();
        end

        MultiplayerTools.SetMPGameMode = function()
        end
    else
        Stronghold.Multiplayer:OnGameStart();
    end
end

