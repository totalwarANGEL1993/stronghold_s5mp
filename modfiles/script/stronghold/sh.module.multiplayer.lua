--- 
--- Multiplayer Script
---
--- Implements a rudimentary rule system to configure a multiplayer match.
---
--- Defined game callbacks:
--- - GameCallback_SH_Logic_OnGameStart()
---   Called when the map is loaded.
---   
--- - GameCallback_SH_Logic_OnConfigurated()
---   Called when configuration is confirmed by the host.
---   
--- - GameCallback_SH_Logic_OnPeaceTimeOver()
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
--- @param _Config? table Overwrite configuration
function SetupStrongholdMultiplayerConfig(_Config)
    if _Config then
        Stronghold.Multiplayer:ConfigureChangeDefault(_Config);
    end
    Stronghold.Multiplayer:ConfigureReset();
    Stronghold.Multiplayer:Configure();
end

--- Displays the configuration window for the host.
--- @param _Config? table Overwrite default configuration
function ShowStrongholdConfiguration(_Config)
    if not Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        Stronghold.Multiplayer:ConfigureChangeDefault(_Config);
        Stronghold.Multiplayer:ConfigureReset();
        Stronghold.Multiplayer:SuspendPlayers();
    end
    Stronghold.Multiplayer:ShowRuleSelection();
end

-- -------------------------------------------------------------------------- --

function GameCallback_SH_Logic_OnGameStart()
end

function GameCallback_SH_Logic_OnConfigurated()
end

function GameCallback_SH_Logic_OnPeaceTimeOver()
end

-- -------------------------------------------------------------------------- --

function GUIAction_SHMP_Config_SetHeroAllowed(_Type)
    local PlayerID = GUI.GetPlayerID();
    -- Only host can trigger action
    if (PlayerID ~= 17 and PlayerID ~= Syncer.GetHostPlayerID())
    -- AND only if not already confirmed
    or Stronghold.Multiplayer:HaveRulesBeenConfigured() then
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
    local PlayerID = GUI.GetPlayerID();
    -- Only host can trigger action
    if (PlayerID ~= 17 and PlayerID ~= Syncer.GetHostPlayerID())
    -- AND only if not already confirmed
    or Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.ChangeResource,
        _Amount
    );
end

function GUIAction_SHMP_Config_SetInitialRank(_Rank)
    local PlayerID = GUI.GetPlayerID();
    -- Only host can trigger action
    if (PlayerID ~= 17 and PlayerID ~= Syncer.GetHostPlayerID())
    -- AND only if not already confirmed
    or Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.ChangeStartRank,
        _Rank
    );
end

function GUIAction_SHMP_Config_SetFinalRank(_Rank)
    local PlayerID = GUI.GetPlayerID();
    -- Only host can trigger action
    if (PlayerID ~= 17 and PlayerID ~= Syncer.GetHostPlayerID())
    -- AND only if not already confirmed
    or Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.ChangeFinalRank,
        _Rank
    );
end

function GUIAction_SHMP_Config_SetPeaceTime(_Time)
    local PlayerID = GUI.GetPlayerID();
    -- Only host can trigger action
    if (PlayerID ~= 17 and PlayerID ~= Syncer.GetHostPlayerID())
    -- AND only if not already confirmed
    or Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.ChangePeacetime,
        _Time
    );
end

function GUIAction_SHMP_Config_Reset()
    local PlayerID = GUI.GetPlayerID();
    -- Only host can trigger action
    if (PlayerID ~= 17 and PlayerID ~= Syncer.GetHostPlayerID())
    -- AND only if not already confirmed
    or Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.Reset
    );
end

function GUIAction_SHMP_Config_Confirm()
    local PlayerID = GUI.GetPlayerID();
    -- Only host can trigger action
    if PlayerID ~= 17 and not Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        if (PlayerID == Syncer.GetHostPlayerID()) then
            Syncer.InvokeEvent(
                Stronghold.Multiplayer.NetworkCall,
                Stronghold.Multiplayer.SyncEvents.Confirm
            );
        end
        return;
    end
    if PlayerID == 17 or Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        Stronghold.Multiplayer:HideRuleSelection();
    end
end

function GUIAction_SHMP_ShowRules()
    ShowStrongholdConfiguration();
end

-- -------------------------------------------------------------------------- --

function GUITooltip_SHMP_Config_SetHeroAllowed(_Type)
    local TypeName = Logic.GetEntityTypeName(_Type);
    local Text = XGUIEng.GetStringTableText("sh_shs5mp/hero_" ..TypeName);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

function GUITooltip_SHMP_Config_SetResource(_TextKey)
    local Text = XGUIEng.GetStringTableText(_TextKey);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

function GUITooltip_SHMP_Config_SetPeacetime(_TextKey)
    local Text = XGUIEng.GetStringTableText(_TextKey);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

function GUITooltip_SHMP_Config_SetInitialRank(_TextKey)
    local Text = XGUIEng.GetStringTableText(_TextKey);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

function GUITooltip_SHMP_Config_SetFinalRank(_TextKey)
    local Text = XGUIEng.GetStringTableText(_TextKey);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

function GUITooltip_SHMP_ShowRules(_TextKey)
    local Text = XGUIEng.GetStringTableText(_TextKey);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

-- -------------------------------------------------------------------------- --

function GUIUpdate_SHMP_Config_SetHeroAllowed(_Widget, _Type)
    local Flag = (Stronghold.Multiplayer.Data.Config.AllowedHeroes[_Type] and 0) or 1;
    XGUIEng.HighLightButton(_Widget, Flag);
end

function GUIUpdate_SHMP_Config_SetResource(_Widget)
    local Selected = Stronghold.Multiplayer.Data.Config.ResourceSelected or 1;
    local Flag = (string.find(_Widget, "Resource" ..Selected) ~= nil and 1) or 0;
    XGUIEng.HighLightButton(_Widget, Flag);
end

function GUIUpdate_SHMP_Config_SetPeacetime(_Widget)
    local Selected = Stronghold.Multiplayer.Data.Config.PeacetimeSelected or 1;
    local Flag = (string.find(_Widget, "Peacetime" ..Selected) ~= nil and 1) or 0;
    XGUIEng.HighLightButton(_Widget, Flag);
end

function GUIUpdate_SHMP_Config_SetInitialRank(_Widget)
    local Rank = Stronghold.Multiplayer.Data.Config.Rank.Initial;
    local Flag = (string.find(_Widget, "InitialRank_Rank" ..Rank) ~= nil and 1) or 0;
    XGUIEng.HighLightButton(_Widget, Flag);
end

function GUIUpdate_SHMP_Config_SetFinalRank(_Widget)
    local Rank = Stronghold.Multiplayer.Data.Config.Rank.Final;
    local Flag = (string.find(_Widget, "FinalRank_Rank" ..Rank) ~= nil and 1) or 0;
    XGUIEng.HighLightButton(_Widget, Flag);
end

function GUIUpdate_SHMP_Config_Reset(_Widget)
    -- Only show for host and if not already configured
    if GUI.GetPlayerID() ~= Syncer.GetHostPlayerID()
    or Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        XGUIEng.ShowWidget(_Widget, 0);
    end
end

function GUIUpdate_SHMP_Config_Confirm(_Widget)
    -- Only show for host and if not already configured
    if  GUI.GetPlayerID() ~= Syncer.GetHostPlayerID()
    and not Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        XGUIEng.ShowWidget(_Widget, 0);
    else
        XGUIEng.ShowWidget(_Widget, 1);
    end
end

function GUIUpdate_SHMP_TimerText()
    local TimerBase = math.floor(Stronghold.Multiplayer.Data.StartGameTimer or 0);
    local ConfirmTime = math.floor(Stronghold.Multiplayer.Data.RulesConfirmedTime or 0);

    local Timer = TimerBase - (math.floor(Logic.GetTime()) - ConfirmTime);
    if Timer < 0 then
        XGUIEng.ShowWidget("SHS5MP_Counter", 0);
        return;
    end

    local Text = "@center --- " ..Timer.. " ---";
    local Red, Green, Blue = 66, 245, 69;
    if Timer < 7 then
        Red, Green, Blue = 209, 183, 52;
    end
    if Timer < 4 then
        Red, Green, Blue = 209, 52, 52;
    end
    XGUIEng.SetTextColor("SHS5MP_CounterText", Red, Green, Blue);
    XGUIEng.SetText("SHS5MP_CounterText", Text);
end

function GUIUpdate_SHMP_ShowRules(_Widget)
    local Visible = Stronghold.Multiplayer:HaveRulesBeenConfigured();
    XGUIEng.ShowWidget(_Widget, (Visible and 1) or 0);
end

-- -------------------------------------------------------------------------- --

function Stronghold.Multiplayer:ConfigureResource(_Amount)
    if _Amount == 1 then
        self.Data.Config.Resources = {0, 600, 1200, 1500, 550, 0, 0};
    elseif _Amount == 2 then
        self.Data.Config.Resources = {50, 2500, 3000, 3500, 2000, 500, 500};
    elseif _Amount == 3 then
        self.Data.Config.Resources = {300, 7500, 6000, 7000, 5000, 3000, 3000};
    end
    self.Data.Config.ResourceSelected = _Amount;
end

function Stronghold.Multiplayer:ConfigureHeroAllowed(_Type, _Allowed)
    self.Data.Config.AllowedHeroes[_Type] = _Allowed == true;
end

function Stronghold.Multiplayer:ConfigureInitialRank(_Rank)
    self.Data.Config.Rank.Initial = _Rank;
    -- Update final rank as well
    local FinalRank = self.Data.Config.Rank.Final;
    self.Data.Config.Rank.Final = math.max(FinalRank, _Rank);
end

function Stronghold.Multiplayer:ConfigureFinalRank(_Rank)
    self.Data.Config.Rank.Final = _Rank;
    -- Update initial rank as well
    local StartingRank = self.Data.Config.Rank.Initial;
    self.Data.Config.Rank.Initial = math.min(StartingRank, _Rank);
end

function Stronghold.Multiplayer:ConfigurePeaceTime(_Time)
    self.Data.Config.PeacetimeSelected = _Time;
    self.Data.Config.PeaceTime = (_Time -1) * 10;
end

function Stronghold.Multiplayer:ConfigureChangeDefault(_Config)
    if _Config then
        local Default = self.Config.DefaultSettings;
        if _Config.DisableDefaultWinCondition then
            self.Config.DisableDefaultWinCondition = _Config.DisableDefaultWinCondition == true;
        end
        if _Config.PeaceTimeOpenGates ~= nil then
            self.Config.PeaceTimeOpenGates = _Config.PeaceTimeOpenGates == true;
        end
        self.Config.DefaultSettings.PeaceTime = _Config.PeaceTime or Default.PeaceTime;
        self.Config.DefaultSettings.Rank.Initial = _Config.Rank.Initial or Default.Rank.Initial;
        self.Config.DefaultSettings.Rank.Final = _Config.Rank.Initial or Default.Rank.Final;
        self.Config.DefaultSettings.Resources = _Config.Rank.Initial or Default.Resources;
        for k,v in pairs(Default.AllowedHeroes) do
            self.Config.DefaultSettings.AllowedHeroes[k] = _Config.AllowedHeroes[k] or v;
        end
    end
end

function Stronghold.Multiplayer:ConfigureReset()
    self.Data.Config = self.Config.DefaultSettings;

    self.Data.Config.ResourceSelected = 1;
    self.Data.Config.PeacetimeSelected = 1;
    self.Data.Config.Rank.Initial = 0;
    self.Data.Config.Rank.Final = 7;
    if self.Data.Config.AllowedHeroes then
        for k,v in pairs(self.Data.Config.AllowedHeroes) do
            self.Data.Config.AllowedHeroes[k] = true;
        end
    end
end

function Stronghold.Multiplayer:Configure()
    -- Setup ranks
    if self.Data.Config.Rank then
        if XNetwork.Manager_DoesExist() == 1 then
            local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer();
            for PlayerID= 1, HumenPlayer, 1 do
                SetRank(PlayerID, self.Data.Config.Rank.Initial or 0);
                Stronghold.Rights:SetPlayerMaxRank(PlayerID, self.Data.Config.Rank.Final or 7);
            end
        else
            SetRank(1, self.Data.Config.Rank.Initial or 0);
            Stronghold.Rights:SetPlayerMaxRank(1, self.Data.Config.Rank.Final or 7);
        end
    end

    -- Setup resources
    if self.Data.Config.Resources then
        if XNetwork.Manager_DoesExist() == 1 then
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
        else
            AddHonor(1, self.Data.Config.Resources[1] or 0);
            Tools.GiveResouces(
                1,
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
    self:HideRuleSelection();
    if not self:HaveRulesBeenConfigured() then
        local Timer = 10;
        local Turns = Timer * 10;
        self.Data.StartGameTimer = Timer;
        self.Data.RulesConfirmedTime = Logic.GetTime();
        self:ShowRuleTimer();

        -- Start the delay
        Stronghold:AddDelayedAction(Turns, function()
            Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
            Message(XGUIEng.GetStringTableText("sh_shs5mp/rulesset"));
            Stronghold.Multiplayer:HideRuleTimer();
            Stronghold.Multiplayer:ResumePlayers();
            Stronghold.Multiplayer:OnGameModeSet();
        end);
    end
    self.Data.RulesHaveBeenConfirmed = true;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Multiplayer:HaveRulesBeenConfigured()
    return self.Data.RulesHaveBeenConfirmed;
end

function Stronghold.Multiplayer:SuspendPlayers()
    -- Register rule selection active
    self.Data.IsRuleConfigurationActive = true;
    -- Suspend players
    if XNetwork.Manager_DoesExist() == 1 then
        local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer();
        for PlayerID= 1, HumenPlayer do
            self:SuspendPlayer(PlayerID);
        end
    else
        self:SuspendPlayer(GUI.GetPlayerID());
    end
end

function Stronghold.Multiplayer:ResumePlayers()
    -- Register rule selection inactive
    self.Data.IsRuleConfigurationActive = false;
    -- Resume players
    if XNetwork.Manager_DoesExist() == 1 then
        local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer();
        for PlayerID= 1, HumenPlayer do
            self:ResumePlayer(PlayerID);
        end
    else
        self:ResumePlayer(GUI.GetPlayerID());
    end
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
            if Soldiers[1] then
                for i= 1, Soldiers[1] +1 do
                    DestroyEntity(Soldiers[i]);
                end
            end
            local Type = Logic.GetEntityType(v);
            local ID = ReplaceEntity(v, Entities.XD_ScriptEntity);
            table.insert(self.Data[_PlayerID].ReplacedEntities, {ID, Type, Soldiers[1] or 0});
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

function Stronghold.Multiplayer:ShowRuleSelection()
    GUI.ClearSelection();
    XGUIEng.SetWidgetPosition("Windows", 64, 148);
    XGUIEng.ShowWidget("GCWindow", 0);
    XGUIEng.ShowWidget("BackGround_Top", 0);
    XGUIEng.ShowWidget("Top", 0);
    XGUIEng.ShowWidget("BackGroundBottomContainer", 0);
    XGUIEng.ShowWidget("ResourceView", 0);
    XGUIEng.ShowWidget("SelectionView", 0);
    XGUIEng.ShowWidget("MiniMap", 0);
    XGUIEng.ShowWidget("MiniMapOverlay", 0);
    XGUIEng.ShowWidget("MinimapButtons", 0);
    XGUIEng.ShowWidget("Movie", 1);
    XGUIEng.ShowWidget("MovieBarTop", 1);
    XGUIEng.ShowWidget("MovieBarBottom", 1);
    XGUIEng.ShowWidget("MovieInvisibleClickCatcher", 1);
    XGUIEng.ShowWidget("CreditsWindow", 0);
    XGUIEng.ShowWidget("SHS5MP", 1);
    XGUIEng.ShowWidget("SHS5MP_ShowRules", 0);
end

function Stronghold.Multiplayer:HideRuleSelection()
    XGUIEng.SetWidgetPosition("Windows", 64, 94);
    XGUIEng.ShowWidget("GCWindow", 1);
    XGUIEng.ShowWidget("BackGround_Top", 1);
    XGUIEng.ShowWidget("Top", 1);
    XGUIEng.ShowWidget("BackGroundBottomContainer", 1);
    XGUIEng.ShowWidget("ResourceView", 1);
    XGUIEng.ShowWidget("SelectionView", 1);
    XGUIEng.ShowWidget("MiniMap", 1);
    XGUIEng.ShowWidget("MiniMapOverlay", 1);
    XGUIEng.ShowWidget("MinimapButtons", 1);
    XGUIEng.ShowWidget("Movie", 0);
    XGUIEng.ShowWidget("MovieBarTop", 0);
    XGUIEng.ShowWidget("MovieBarBottom", 0);
    XGUIEng.ShowWidget("CreditsWindow", 1);
    XGUIEng.ShowWidget("SHS5MP", 0);
    XGUIEng.ShowWidget("SHS5MP_ShowRules", 1);
end

function Stronghold.Multiplayer:ShowRuleTimer()
    GUI.ClearSelection();
    XGUIEng.SetWidgetPosition("Windows", 64, 148);
    XGUIEng.ShowWidget("GCWindow", 0);
    XGUIEng.ShowWidget("BackGround_Top", 0);
    XGUIEng.ShowWidget("Top", 0);
    XGUIEng.ShowWidget("BackGroundBottomContainer", 0);
    XGUIEng.ShowWidget("ResourceView", 0);
    XGUIEng.ShowWidget("SelectionView", 0);
    XGUIEng.ShowWidget("MiniMap", 0);
    XGUIEng.ShowWidget("MiniMapOverlay", 0);
    XGUIEng.ShowWidget("MinimapButtons", 0);
    XGUIEng.ShowWidget("Movie", 1);
    XGUIEng.ShowWidget("MovieBarTop", 0);
    XGUIEng.ShowWidget("MovieBarBottom", 0);
    XGUIEng.ShowWidget("MovieInvisibleClickCatcher", 1);
    XGUIEng.ShowWidget("CreditsWindow", 0);
    XGUIEng.ShowWidget("SHS5MP", 1);
    XGUIEng.ShowWidget("SHS5MP_Configure", 0);
    XGUIEng.ShowWidget("SHS5MP_Counter", 1);
    XGUIEng.ShowWidget("SHS5MP_ShowRules", 0);
end

function Stronghold.Multiplayer:HideRuleTimer()
    XGUIEng.SetWidgetPosition("Windows", 64, 94);
    XGUIEng.ShowWidget("GCWindow", 1);
    XGUIEng.ShowWidget("BackGround_Top", 1);
    XGUIEng.ShowWidget("Top", 1);
    XGUIEng.ShowWidget("BackGroundBottomContainer", 1);
    XGUIEng.ShowWidget("ResourceView", 1);
    XGUIEng.ShowWidget("SelectionView", 1);
    XGUIEng.ShowWidget("MiniMap", 1);
    XGUIEng.ShowWidget("MiniMapOverlay", 1);
    XGUIEng.ShowWidget("MinimapButtons", 1);
    XGUIEng.ShowWidget("Movie", 0);
    XGUIEng.ShowWidget("MovieBarTop", 0);
    XGUIEng.ShowWidget("MovieBarBottom", 0);
    XGUIEng.ShowWidget("MovieInvisibleClickCatcher", 0);
    XGUIEng.ShowWidget("CreditsWindow", 1);
    XGUIEng.ShowWidget("SHS5MP", 0);
    XGUIEng.ShowWidget("SHS5MP_Configure", 1);
    XGUIEng.ShowWidget("SHS5MP_Counter", 0);
    XGUIEng.ShowWidget("SHS5MP_ShowRules", 1);
end

-- -------------------------------------------------------------------------- --

function Stronghold.Multiplayer:OnGameStart()
    -- Do it delayed by 1 turn just to be sure all went trought.
    Stronghold:AddDelayedAction(1, function()
        GameCallback_SH_Logic_OnGameStart();
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
    GameCallback_SH_Logic_OnPeaceTimeOver();
end

function Stronghold.Multiplayer:OnGameModeSet()
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
        GameCallback_SH_Logic_OnConfigurated();
    else
        GameCallback_SH_Logic_OnConfigurated();
        self:OnPeaceTimeOver();
    end
end

function Stronghold.Multiplayer:OverrideFunctions()
    Overwrite.CreateOverwrite("GameCallback_GUI_SelectionChanged", function()
        Overwrite.CallOriginal();
        Stronghold.Multiplayer:DeselectAll();
    end);

    Overwrite.CreateOverwrite("GameCallback_Logic_BriefingStarted", function(_PlayerID, _Briefing)
        Overwrite.CallOriginal();
        if Stronghold.Multiplayer:HaveRulesBeenConfigured() then
            Stronghold.Multiplayer:HideRuleSelection();
            XGUIEng.ShowWidget("SHS5MP_ShowRules", 0);
        end
    end);

    Overwrite.CreateOverwrite("GameCallback_Logic_BriefingFinished", function(_PlayerID, _Briefing)
        Overwrite.CallOriginal();
        if Stronghold.Multiplayer:HaveRulesBeenConfigured() then
            XGUIEng.ShowWidget("SHS5MP_ShowRules", 1);
        end
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

