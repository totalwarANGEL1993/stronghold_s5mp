--- 
--- Multiplayer Script
---
--- Implements a rudimentary rule system to configure a multiplayer match.
--- 

Stronghold = Stronghold or {};

Stronghold.Multiplayer = {
    SyncEvents = {},
    Data = {},
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- API

--- Takes a configuration and immediately confirms it.
--- @param _Config? table Overwrite configuration
function SetupStrongholdMultiplayerConfig(_Config)
    if _Config ~= nil then
        Stronghold.Multiplayer:ConfigureChangeDefault(_Config);
    end
    Stronghold.Multiplayer:ConfigureReset();
    Stronghold.Multiplayer:Configure();
end

--- Displays the configuration window for the host.
--- @param _Config? table Overwrite default configuration
function ShowStrongholdConfiguration(_Config)
    if not Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        if _Config ~= nil then
            Stronghold.Multiplayer:ConfigureChangeDefault(_Config);
        end
        Stronghold.Multiplayer:ConfigureReset();
        Stronghold.Multiplayer:SuspendPlayers();
    end
    Stronghold.Multiplayer:ShowRuleSelection();
end

--- Returns the mode selected.
---
--- Possible values:
--- * 1: Kingsmaker
--- * 2: Sudden Death
--- * 3: Last Man Standing
--- @return number Selected Selected mode
function GetSelectedMode()
    return Stronghold.Multiplayer.Data.Config.ModeSelected;
end

--- Returns the selected peacetime.
---
--- Possible values:
--- * 1: no peacetime
--- * 2: 15 minutes
--- * 3: 30 minutes
--- * 4: 45 minutes
--- * 5: 60 minutes
--- @return integer Selected Selected peacetime
function GetSelectedPeacetime()
    return Stronghold.Multiplayer.Data.Config.PeacetimeSelected;
end

--- Returns the peacetime in seconds.
--- @return integer Peacetime Peacetime
function GetPeacetimeInSeconds()
    local TimeMap = {0, 10, 20, 30, 40, 0, 15, 30, 45, 60};
    local Selected = TimeMap[Stronghold.Multiplayer.Data.Config.PeacetimeSelected];
    return Selected * 60;
end

--- Returns the resources selected.
---
--- Possible values:
--- * 1: normal
--- * 2: more
--- * 3: many
--- @return number Selected Selected resources
function GetSelectedResource()
    return Stronghold.Multiplayer.Data.Config.ResourceSelected;
end

--- Returns the rank all players start with.
---
--- Possible ranks:
--- * 0: Commoner
--- * 1: Nobleman/Noblewoman
--- * 2: Bailiff
--- * 3: Lord/Lady
--- * 4: Baron/Baroness
--- * 5: Count/Countess
--- * 6: Margrave/Margravine
--- * 7: Duke/Duchess
--- @return number Rank Initial rank
function GetSelectedStartingRank()
    return Stronghold.Multiplayer.Data.Config.Rank.Initial;
end

--- Returns the highest rank possible.
---
--- Possible ranks:
--- * 0: Commoner
--- * 1: Nobleman/Noblewoman
--- * 2: Bailiff
--- * 3: Lord/Lady
--- * 4: Baron/Baroness
--- * 5: Count/Countess
--- * 6: Margrave/Margravine
--- * 7: Duke/Duchess
--- @return number Rank Final rank
function GetSelectedFinalRank()
    return Stronghold.Multiplayer.Data.Config.Rank.Final;
end

--- Returns if a hero is allowed to be chosen as Noble.
--- @param _Type number Type of hero
--- @return boolean Allowed Hero is allowed
function IsHeroAllowedAsNoble(_Type)
    if Stronghold.Multiplayer.Data.Config.AllowedHeroes then
        return Stronghold.Multiplayer.Data.Config.AllowedHeroes[_Type] == true;
    end
    return false;
end

function IsDefaultVictoryConditionActive()
    return not Stronghold.Multiplayer.Data.Config.DisableDefaultWinCondition;
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

--- Triggered when the map is loaded
function GameCallback_SH_Logic_OnMapStart()
end

--- Triggered after the game started.
function GameCallback_SH_Logic_OnGameStart()
end

--- Triggered after the peacetime ends.
function GameCallback_SH_Logic_OnPeaceTimeOver()
end

--- Triggerd when a save has been loaded.
function GameCallback_SH_Logic_SaveLoaded()
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Multiplayer:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            ReplacedEntities = {};
            Versions = {
                Main = 0,
                Map = 0,
            },
        };
    end
    self.Data.IsRuleConfigurationActive = false;
    self.Data.Config = {};

    self:ConfigureReset();
    self:CreateMultiplayerButtonHandlers();
    self:OverrideFunctions();
    self:OnGameStart();
    self:InitEmsFeatureReplicaKeybindings();
    self:InitEmsFeatureReplicaFunctions();
end

function Stronghold.Multiplayer:OnSaveGameLoaded()
    self:InitEmsFeatureReplicaKeybindings();
    Delay.Turn(0, GameCallback_SH_Logic_SaveLoaded);
end

function Stronghold.Multiplayer:CreateMultiplayerButtonHandlers()
    self.SyncEvents = {
        ChangeMode = 1,
        ChangeResource = 2,
        ChangeHero = 3,
        ChangeStartRank = 4,
        ChangeFinalRank = 5,
        ChangePeacetime = 6,
        Reset = 7,
        Confirm = 8,
        BroadcastMainVersion = 9,
        BroadcastMapVersion = 10,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Multiplayer.SyncEvents.ChangeMode then
                Stronghold.Multiplayer:ConfigureMode(arg[1]);
            elseif _Action == Stronghold.Multiplayer.SyncEvents.ChangeResource then
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
            elseif _Action == Stronghold.Multiplayer.SyncEvents.BroadcastMainVersion then
                Stronghold.Multiplayer:ReceiveMainVersion(arg[1], arg[2]);
            elseif _Action == Stronghold.Multiplayer.SyncEvents.BroadcastMapVersion then
                Stronghold.Multiplayer:ReceiveMapVersion(arg[1], arg[2]);
            end
        end
    );
end

-- -------------------------------------------------------------------------- --

function Stronghold.Multiplayer:ConfigureMode(_Mode)
    self.Data.Config.ModeSelected = _Mode;
end

function Stronghold.Multiplayer:ConfigureResource(_Amount)
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
    local TimeMap = {0, 10, 20, 30, 40, 0, 15, 30, 45, 60};
    self.Data.Config.PeaceTime = TimeMap[_Time];
end

function Stronghold.Multiplayer:ConfigureChangeDefault(_Config)
    if _Config then
        local Default = self.Config.DefaultSettings;

        if _Config.MapStartFillClay then
            self.Config.DefaultSettings.MapStartFillClay = _Config.MapStartFillClay;
        end
        if _Config.MapStartFillIron then
            self.Config.DefaultSettings.MapStartFillIron = _Config.MapStartFillIron;
        end
        if _Config.MapStartFillStone then
            self.Config.DefaultSettings.MapStartFillStone = _Config.MapStartFillStone;
        end
        if _Config.MapStartFillSulfur then
            self.Config.DefaultSettings.MapStartFillSulfur = _Config.MapStartFillSulfur;
        end
        if _Config.MapStartFillWood then
            self.Config.DefaultSettings.MapStartFillWood = _Config.MapStartFillWood;
        end

        if _Config.Version then
            self.Config.DefaultSettings.Version = _Config.Version;
        end
        if _Config.DisableRuleConfiguration ~= nil then
            self.Config.DefaultSettings.DisableRuleConfiguration = _Config.DisableRuleConfiguration == true;
        end
        if _Config.DisableDefaultWinCondition ~= nil then
            self.Config.DefaultSettings.DisableDefaultWinCondition = _Config.DisableDefaultWinCondition == true;
        end
        if _Config.PeaceTimeOpenGates ~= nil then
            self.Config.DefaultSettings.PeaceTimeOpenGates = _Config.PeaceTimeOpenGates == true;
        end

        self.Config.DefaultSettings.PeaceTime = _Config.PeaceTime;
        self.Config.DefaultSettings.Rank.Initial = _Config.Rank.Initial or Default.Rank.Initial;
        self.Config.DefaultSettings.Rank.Final = _Config.Rank.Final or Default.Rank.Final;
        self.Config.DefaultSettings.Resources = _Config.Resources or Default.Resources;
        self.Config.DefaultSettings.Knowledge = _Config.Knowledge or Default.Knowledge;
        for k,v in pairs(Default.AllowedHeroes) do
            self.Config.DefaultSettings.AllowedHeroes[k] = _Config.AllowedHeroes[k] or v;
        end

        if _Config.OnMapStart then
            GameCallback_SH_Logic_OnMapStart = _Config.OnMapStart;
        end
        if _Config.OnGameStart then
            GameCallback_SH_Logic_OnGameStart = _Config.OnGameStart;
        end
        if _Config.OnPeaceTimeOver then
            GameCallback_SH_Logic_OnPeaceTimeOver = _Config.OnPeaceTimeOver;
        end
        if _Config.OnSaveLoaded then
            GameCallback_SH_Logic_SaveLoaded = _Config.OnSaveLoaded;
        end

        if _Config.Titles then
            local Players = Syncer.GetActivePlayers();
            for i= 1, table.getn(Players) do
                Stronghold.Rights:InitDutiesAndRights(Players[i], _Config.Titles);
            end
        end
    end
end

function Stronghold.Multiplayer:ConfigureReset()
    self.Data.Config = CopyTable(self.Config.DefaultSettings);

    self.Data.Config.ModeSelected = 2;
    self.Data.Config.ResourceSelected = 1;
    self.Data.Config.PeacetimeSelected = 8;
    self.Data.Config.Rank.Initial = 0;
    self.Data.Config.Rank.Final = 7;
    if self.Data.Config.AllowedHeroes then
        for k,v in pairs(self.Data.Config.AllowedHeroes) do
            self.Data.Config.AllowedHeroes[k] = true;
        end
    end
end

function Stronghold.Multiplayer:Configure()
    -- Setup mode
    if self.Data.Config.Mode then
        local Selected = self.Data.Config.ModeSelected;
        if Selected == 1 then
            Stronghold.Player:ActivateGameModeKingsmaker();
            if XNetwork.Manager_DoesExist() == 1 then
                local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer();
                for PlayerID = 1, HumenPlayer, 1 do
                    ForbidTechnology(Technologies.B_Headquarter, PlayerID);
                end
            else
                ForbidTechnology(Technologies.B_Headquarter, GUI.GetPlayerID());
            end
        end
        if Selected == 2 then
            Stronghold.Player:ActivateGameModeSuddenDeath();
        end
        if Selected == 3 then
            Stronghold.Player:ActivateGameModeAnnihilation();
        end
    end

    -- Setup ranks
    if self.Data.Config.Rank then
        local InitialRank = self.Data.Config.Rank.Initial or 0;
        local FinalRank = self.Data.Config.Rank.Final or 7;
        if XNetwork.Manager_DoesExist() == 1 then
            local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer();
            for PlayerID= 1, HumenPlayer, 1 do
                SetRank(PlayerID, InitialRank);
                AddKnowledge(PlayerID, 5 * InitialRank);
                Stronghold.Rights:SetPlayerMaxRank(PlayerID, FinalRank);
            end
        else
            SetRank(GUI.GetPlayerID(), InitialRank);
            AddKnowledge(GUI.GetPlayerID(), 5 * InitialRank);
            Stronghold.Rights:SetPlayerMaxRank(GUI.GetPlayerID(), FinalRank);
        end
    end

    -- Setup resources
    if self.Data.Config.Resources then
        local Selected = self.Data.Config.ResourceSelected;
        local Resources = self.Data.Config.Resources[Selected];
        if XNetwork.Manager_DoesExist() == 1 then
            local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer();
            for PlayerID= 1, HumenPlayer, 1 do
                AddHonor(PlayerID, Resources[1] or 0);
                Tools.GiveResouces(
                    PlayerID,
                    Resources[2] or 0,
                    Resources[3] or 0,
                    Resources[4] or 0,
                    Resources[5] or 0,
                    Resources[6] or 0,
                    Resources[7] or 0
                );
            end
        else
            AddHonor(GUI.GetPlayerID(), Resources[1] or 0);
            Tools.GiveResouces(
                GUI.GetPlayerID(),
                Resources[2] or 0,
                Resources[3] or 0,
                Resources[4] or 0,
                Resources[5] or 0,
                Resources[6] or 0,
                Resources[7] or 0
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
        if self.Data.Config.DisableRuleConfiguration then
            -- Start the delay
            Delay.Turn(1, function()
                local Check = Stronghold.Multiplayer:CheckVersions();
                if Check == 0 then
                    Stronghold.Multiplayer:ResumePlayers();
                    Stronghold.Multiplayer:OnGameModeSet();
                else
                    Stronghold.Multiplayer:OnVersionsDiffer();
                end
            end);
        else
            local Timer = 10;
            local Turns = Timer * 10;
            self.Data.StartGameTimer = Timer;
            self.Data.RulesConfirmedTime = Logic.GetTime();
            self:ShowRuleTimer();
            -- Start the delay
            Delay.Turn(Turns, function()
                local Check = Stronghold.Multiplayer:CheckVersions();
                if Check == 0 then
                    Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 70);
                    Message(XGUIEng.GetStringTableText("sh_shs5mp/rulesset"));
                    Stronghold.Multiplayer:HideRuleTimer();
                    Stronghold.Multiplayer:ResumePlayers();
                    Stronghold.Multiplayer:OnGameModeSet();
                else
                    Stronghold.Multiplayer:OnVersionsDiffer();
                end
            end);
        end
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
    if GUI.GetPlayerID() == _PlayerID then
        Camera.ScrollSetBorderFlag(0);
        Camera.ScrollSetSpeed(0);
    end
    local LeaderList = GetLeadersOfType(_PlayerID, 0);
    for i= 2, LeaderList[1] +1 do
        if Logic.IsBuilding(LeaderList[i]) == 1 then
            local Type = Logic.GetEntityType(LeaderList[i]);
            local TypeName = Logic.GetEntityTypeName(Type);
            if not string.find(TypeName, "Headquarter") then
                local ID = ReplaceEntity(LeaderList[i], Entities.XD_ScriptEntity);
                table.insert(self.Data[_PlayerID].ReplacedEntities, {ID, Type, 0});
            end
        elseif Logic.IsSettler(LeaderList[i]) == 1 then
            local Soldiers = {Logic.GetSoldiersAttachedToLeader(LeaderList[i])};
            if Soldiers[1] then
                for i= 1, Soldiers[1] +1 do
                    DestroyEntity(Soldiers[i]);
                end
            end
            local Type = Logic.GetEntityType(LeaderList[i]);
            local ID = ReplaceEntity(LeaderList[i], Entities.XD_ScriptEntity);
            table.insert(self.Data[_PlayerID].ReplacedEntities, {ID, Type, Soldiers[1] or 0});
        end
    end
end

function Stronghold.Multiplayer:ResumePlayer(_PlayerID)
    if GUI.GetPlayerID() == _PlayerID then
        Camera.ScrollSetBorderFlag(1);
        Camera.ScrollSetSpeed(2500);
    end
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
    local PlayerID = GUI.GetPlayerID();
    if PlayerID == 17 or self:HaveRulesBeenConfigured() then
        local Text = XGUIEng.GetStringTableText("sh_shs5mp/button_close");
        XGUIEng.SetText("SHS5MP_ControlsConfirm", Text);
    end
    XGUIEng.SetWidgetPosition("Windows", 64, 148);
    XGUIEng.ShowWidget("SocialResourceView", 0);
    XGUIEng.ShowWidget("BackGround_Top", 0);
    XGUIEng.ShowWidget("Top", 0);
    XGUIEng.ShowWidget("BackGroundBottomContainer", 0);
    XGUIEng.ShowWidget("ResourceView", 0);
    XGUIEng.ShowWidget("SelectionView", 0);
    XGUIEng.ShowWidget("MiniMap", 0);
    XGUIEng.ShowWidget("MiniMapOverlay", 0);
    XGUIEng.ShowWidget("MinimapButtons", 0);
    XGUIEng.ShowWidget("NotesWindow", 0);
    XGUIEng.ShowWidget("ShortMessagesListWindow", 0);
    XGUIEng.ShowWidget("Movie", 1);
    XGUIEng.ShowWidget("MovieBarTop", 0);
    XGUIEng.ShowWidget("MovieBarBottom", 0);
    XGUIEng.ShowWidget("MovieInvisibleClickCatcher", 1);
    XGUIEng.ShowWidget("CreditsWindow", 0);
    XGUIEng.ShowWidget("GameClock", 0);
    XGUIEng.ShowWidget("SHS5MP", 1);
    XGUIEng.ShowWidget("SHS5MP_ControlsRow", 1);
    XGUIEng.ShowWidget("SHS5MP_ControlsConfirm", 1);
    XGUIEng.ShowWidget("SHS5MP_ShowRules", 0);
    for i= 1, 5 do
        XGUIEng.ShowWidget("SHS5MP_Peacetime" ..(i+5), 1);
        XGUIEng.ShowWidget("SHS5MP_Peacetime" ..i, 0);
    end
end

function Stronghold.Multiplayer:HideRuleSelection()
    XGUIEng.SetWidgetPosition("Windows", 64, 94);
    XGUIEng.ShowWidget("SocialResourceView", 1);
    XGUIEng.ShowWidget("BackGround_Top", 1);
    XGUIEng.ShowWidget("Top", 1);
    XGUIEng.ShowWidget("BackGroundBottomContainer", 1);
    XGUIEng.ShowWidget("ResourceView", 1);
    XGUIEng.ShowWidget("SelectionView", 1);
    XGUIEng.ShowWidget("MiniMap", 1);
    XGUIEng.ShowWidget("MiniMapOverlay", 1);
    XGUIEng.ShowWidget("MinimapButtons", 1);
    XGUIEng.ShowWidget("NotesWindow", 1);
    XGUIEng.ShowWidget("ShortMessagesListWindow", 1);
    XGUIEng.ShowWidget("Movie", 0);
    XGUIEng.ShowWidget("MovieBarTop", 0);
    XGUIEng.ShowWidget("MovieBarBottom", 0);
    XGUIEng.ShowWidget("CreditsWindow", 1);
    XGUIEng.ShowWidget("SHS5MP", 0);
    XGUIEng.ShowWidget("SHS5MP_ShowRules", 1);
    if gvKeyBindings_GameClockFlag == 0 then
        XGUIEng.ShowWidget("GameClock", 1);
    end
end

function Stronghold.Multiplayer:ShowRuleTimer()
    GUI.ClearSelection();
    XGUIEng.SetWidgetPosition("Windows", 64, 148);
    XGUIEng.ShowWidget("SocialResourceView", 0);
    XGUIEng.ShowWidget("BackGround_Top", 0);
    XGUIEng.ShowWidget("Top", 0);
    XGUIEng.ShowWidget("BackGroundBottomContainer", 0);
    XGUIEng.ShowWidget("ResourceView", 0);
    XGUIEng.ShowWidget("SelectionView", 0);
    XGUIEng.ShowWidget("MiniMap", 0);
    XGUIEng.ShowWidget("MiniMapOverlay", 0);
    XGUIEng.ShowWidget("MinimapButtons", 0);
    XGUIEng.ShowWidget("NotesWindow", 0);
    XGUIEng.ShowWidget("ShortMessagesListWindow", 0);
    XGUIEng.ShowWidget("Movie", 1);
    XGUIEng.ShowWidget("MovieBarTop", 0);
    XGUIEng.ShowWidget("MovieBarBottom", 0);
    XGUIEng.ShowWidget("MovieInvisibleClickCatcher", 1);
    XGUIEng.ShowWidget("CreditsWindow", 0);
    XGUIEng.ShowWidget("SHS5MP", 1);
    XGUIEng.ShowWidget("SHS5MP_Configure", 0);
    XGUIEng.ShowWidget("SHS5MP_Counter", 1);
    XGUIEng.ShowWidget("SHS5MP_Counter_BG", 0);
    XGUIEng.ShowWidget("SHS5MP_ShowRules", 0);
    XGUIEng.ShowWidget("GameClock", 0);
    for i= 1, 5 do
        XGUIEng.ShowWidget("SHS5MP_Peacetime" ..(i+5), 1);
        XGUIEng.ShowWidget("SHS5MP_Peacetime" ..i, 0);
    end
end

function Stronghold.Multiplayer:HideRuleTimer()
    XGUIEng.SetWidgetPosition("Windows", 64, 94);
    XGUIEng.ShowWidget("SocialResourceView", 1);
    XGUIEng.ShowWidget("BackGround_Top", 1);
    XGUIEng.ShowWidget("Top", 1);
    XGUIEng.ShowWidget("BackGroundBottomContainer", 1);
    XGUIEng.ShowWidget("ResourceView", 1);
    XGUIEng.ShowWidget("SelectionView", 1);
    XGUIEng.ShowWidget("MiniMap", 1);
    XGUIEng.ShowWidget("MiniMapOverlay", 1);
    XGUIEng.ShowWidget("MinimapButtons", 1);
    XGUIEng.ShowWidget("NotesWindow", 1);
    XGUIEng.ShowWidget("ShortMessagesListWindow", 1);
    XGUIEng.ShowWidget("Movie", 0);
    XGUIEng.ShowWidget("MovieBarTop", 0);
    XGUIEng.ShowWidget("MovieBarBottom", 0);
    XGUIEng.ShowWidget("MovieInvisibleClickCatcher", 0);
    XGUIEng.ShowWidget("CreditsWindow", 1);
    XGUIEng.ShowWidget("SHS5MP", 0);
    XGUIEng.ShowWidget("SHS5MP_Configure", 1);
    XGUIEng.ShowWidget("SHS5MP_Counter", 0);
    XGUIEng.ShowWidget("SHS5MP_ShowRules", 1);
    if gvKeyBindings_GameClockFlag == 0 then
        XGUIEng.ShowWidget("GameClock", 1);
    end
end

-- -------------------------------------------------------------------------- --

function Stronghold.Multiplayer:OnVersionsDiffer()
    XGUIEng.ShowWidget("SHS5MP_Configure", 0);
    XGUIEng.ShowWidget("SHS5MP_Version", 1);

    local Players = Syncer.GetActivePlayers();
    -- Set main version text
    local MainText = "";
    for i= 1, table.getn(Players) do
        local Version = self.Data[Players[i]].Versions.Main;
        local Name = self:GetPlayerOnlineName();
        local Color = " @color:0,180,0,255 ";
        if self:CompareVersion(Version, Stronghold.Version) ~= 0 then
            Color = " @color:190,0,0,255 ";
        end
        MainText = MainText ..Name.. " " ..Color.. " (Version: " ..Version.. ") @color:255,255,255,255 @cr ";
    end
    XGUIEng.SetText("SHS5MP_Version_Main_Players", MainText);
    -- Set map version text
    local MapText = "";
    for i= 1, table.getn(Players) do
        local Version = self.Data[Players[i]].Versions.Map;
        local Name = self:GetPlayerOnlineName();
        local Color = " @color:0,180,0,255 ";
        if Version ~= self.Data.Config.Version then
            Color = " @color:190,0,0,255 ";
        end
        MapText = MapText ..Name.. " " ..Color.. " (Version: " ..Version.. ") @color:255,255,255,255 @cr ";
    end
    XGUIEng.SetText("SHS5MP_Version_Map_Players", MapText);
end

function Stronghold.Multiplayer:CheckVersions()
    local Players = Syncer.GetActivePlayers();
    if XNetwork.Manager_DoesExist() == 1 then
        -- Check main version
        local LastMainVersion = -1;
        for i= 1, table.getn(Players) do
            local Version = self.Data[Players[i]].Main;
            if LastMainVersion ~= -1 and self:CompareVersion(Version, LastMainVersion) ~= 0 then
                return 1;
            end
        end
        -- Check map version
        local LastMapVersion = -1;
        for i= 1, table.getn(Players) do
            local Version = self.Data[Players[i]].Map;
            if LastMapVersion ~= -1 and self:CompareVersion(Version, LastMainVersion) ~= 0 then
                return 2;
            end
        end
    end
    return 0;
end

function Stronghold.Multiplayer:BroadcastStrongholdVersion()
    if XNetwork.Manager_DoesExist() == 1 then
        local PlayerID = GUI.GetPlayerID();
        if Logic.GetCurrentTurn() < 31 and PlayerID ~= 17 then
            -- Send main version
            Syncer.InvokeEvent(
                Stronghold.Multiplayer.NetworkCall,
                Stronghold.Multiplayer.SyncEvents.BroadcastMainVersion,
                PlayerID,
                Stronghold.Version
            );
            -- Send map version
            Syncer.InvokeEvent(
                Stronghold.Multiplayer.NetworkCall,
                Stronghold.Multiplayer.SyncEvents.BroadcastMapVersion,
                PlayerID,
                self.Data.Config.Version
            );
        end
    end
end

function Stronghold.Multiplayer:GetPlayerOnlineName()
    if CNetwork then
        return XNetwork.UserInSession_GetUserNameByNetworkAddress(XNetwork.Manager_GetLocalMachineNetworkAddress());
    else
        return UserTool_GetPlayerName(1);
    end
end

function Stronghold.Multiplayer:CompareVersion(_Version1, _Version2)
    local Version1Parts = string.slice(_Version1, "%.");
    local Version2Parts = string.slice(_Version2, "%.");
    for i= 1, table.getn(Version1Parts) do
        if not Version2Parts[i] then
            return 1;
        end
        if tonumber(Version1Parts[i]) == nil then
            return -1;
        elseif tonumber(Version2Parts[i]) == nil then
            return 1;
        elseif tonumber(Version1Parts[i]) > tonumber(Version2Parts[i]) then
            return 1;
        elseif tonumber(Version2Parts[i]) > tonumber(Version1Parts[i]) then
            return -1;
        end
    end
    return 0;
end

function Stronghold.Multiplayer:ReceiveMainVersion(_Player, _Version)
    if self.Data[_Player] then
        self.Data[_Player].Versions.Main = _Version;
    end
end

function Stronghold.Multiplayer:ReceiveMapVersion(_Player, _Version)
    if self.Data[_Player] then
        self.Data[_Player].Versions.Map = _Version;
    end
end

-- -------------------------------------------------------------------------- --

function Stronghold.Multiplayer:OnGameStart()
    -- Do it delayed by 1 turn just to be sure all went trought.
    Delay.Turn(1, function()
        GameCallback_SH_Logic_OnMapStart();
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
            local PlayerID = Logic.EntityGetPlayer(ID);
            local Type = Logic.GetEntityType(ID);
            if Type == Entities.XD_PalisadeGate1 then
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
        local Text = XGUIEng.GetStringTableText("InGameMessages/Note_PeaceTimeOver");
        GUI.AddNote("@color:209,52,52,255 " ..Text);
        GUIAction_ToggleStopWatch(0, 0);
        Sound.PlayGUISound(Sounds.OnKlick_Select_kerberos, 127);
        Stronghold.Multiplayer:OnPeaceTimeOver();
        return true;
    end

    -- Start peacetime?
    local PeaceTime = 0;
    if self.Data.Config.PeaceTime then
        PeaceTime = self.Data.Config.PeaceTime;
    else
        local TimeMap = {0, 10, 20, 30, 40, 0, 15, 30, 45, 60};
        PeaceTime = TimeMap[self.Data.Config.PeacetimeSelected];
    end
    if PeaceTime > 0 then
        MultiplayerTools.PeaceTime = math.ceil(PeaceTime) * 60;
        GUIAction_ToggleStopWatch(MultiplayerTools.PeaceTime, 1);
        Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "Condition_PeaceTime", "Action_PeaceTime", 1);
        GameCallback_SH_Logic_OnGameStart();
    else
        GameCallback_SH_Logic_OnGameStart();
        self:OnPeaceTimeOver();
    end

    -- Fill clay
    if self.Data.Config.MapStartFillClay and self.Data.Config.MapStartFillClay > 0 then
        for EntityID in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.XD_Clay1)) do
            Logic.SetResourceDoodadGoodAmount(EntityID, self.Data.Config.MapStartFillClay);
        end
    end
    -- Fill stone
    if self.Data.Config.MapStartFillStone and self.Data.Config.MapStartFillStone > 0 then
        for EntityID in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.XD_Stone1)) do
            Logic.SetResourceDoodadGoodAmount(EntityID, self.Data.Config.MapStartFillStone);
        end
        for EntityID in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.XD_Stone2)) do
            Logic.SetResourceDoodadGoodAmount(EntityID, self.Data.Config.MapStartFillStone);
        end
    end
    -- Fill iron
    if self.Data.Config.MapStartFillIron and self.Data.Config.MapStartFillIron > 0 then
        for EntityID in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.XD_Iron1)) do
            Logic.SetResourceDoodadGoodAmount(EntityID, self.Data.Config.MapStartFillIron);
        end
    end
    -- Fill sulfur
    if self.Data.Config.MapStartFillSulfur and self.Data.Config.MapStartFillSulfur > 0 then
        for EntityID in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.XD_Sulfur1)) do
            Logic.SetResourceDoodadGoodAmount(EntityID, self.Data.Config.MapStartFillSulfur);
        end
    end

    -- Replace wood piles
    if self.Data.Config.MapStartFillWood then
        for EntityID in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.XD_SingnalFireOff)) do
            CreateWoodPile(CreateNameForEntity(EntityID), self.Data.Config.MapStartFillWood);
        end
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

-- -------------------------------------------------------------------------- --
-- EMS Stuff

function Stronghold.Multiplayer:InitEmsFeatureReplicaKeybindings()
    Input.KeyBindDown(Keys.Back, "Stronghold_KeyBindings_FastDemolish(GUI.GetPlayerID(), GUI.GetSelectedEntity())", 2);
end

function Stronghold.Multiplayer:InitEmsFeatureReplicaFunctions()
    self.Orig_GUIAction_ExpelSettler = GUIAction_ExpelSettler;
    GUIAction_ExpelSettler = function()
        if XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1 then
            local SelectedEntities = {GUI.GetSelectedEntities()};
            for i= 1, table.getn(SelectedEntities) do
                if Logic.IsHero(SelectedEntities[i]) == 0 then
                    if Logic.IsLeader(SelectedEntities[i]) == 1 then
                        local SoldierAmount = Logic.GetSoldiersAttachedToLeader(SelectedEntities[i]);
                        for j= 1, SoldierAmount do
                            GUI.ExpelSettler(SelectedEntities[i]);
                        end
                    end
                    GUI.ExpelSettler(SelectedEntities[i]);
                    GUI.DeselectEntity(SelectedEntities[i]);
                end
            end
        else
            Stronghold.Multiplayer.Orig_GUIAction_ExpelSettler();
        end
    end
end

function Stronghold_KeyBindings_FastDemolish(_PlayerID, _EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if _PlayerID ~= 17 and PlayerID == _PlayerID then
        if  Logic.IsEntityInCategory(_EntityID, EntityCategories.Headquarters) == 0
        and Logic.IsBuilding(_EntityID) == 1 then
            GUI.SellBuilding(_EntityID);
        end
    end
end

-- -------------------------------------------------------------------------- --
-- GUI Action

function GUIAction_SHMP_Config_SetMode(_Mode)
    local PlayerID = GUI.GetPlayerID();
    -- Only host can trigger action
    if (PlayerID ~= 17 and PlayerID ~= Syncer.GetHostPlayerID())
    -- AND only if not already confirmed
    or Stronghold.Multiplayer:HaveRulesBeenConfigured() then
        return;
    end
    Syncer.InvokeEvent(
        Stronghold.Multiplayer.NetworkCall,
        Stronghold.Multiplayer.SyncEvents.ChangeMode,
        _Mode
    );
end

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

function GUIAction_SHMP_Version_Close()
    Framework.CloseGame();
end

function GUIAction_SHMP_ShowRules()
    ShowStrongholdConfiguration();
end

-- -------------------------------------------------------------------------- --
-- GUI Tooltip

function GUITooltip_SHMP_Config_SetMode(_TextKey)
    local Text = XGUIEng.GetStringTableText(_TextKey);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

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
-- GUI Uptate

function GUIUpdate_SHMP_Config_SetMode(_Widget)
    local Selected = Stronghold.Multiplayer.Data.Config.ModeSelected or 1;
    local Flag = (string.find(_Widget, "Mode" ..Selected) ~= nil and 1) or 0;
    XGUIEng.HighLightButton(_Widget, Flag);
end

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
    local Selected = Stronghold.Multiplayer.Data.Config.PeacetimeSelected or 6;
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
    if  not Stronghold.Multiplayer:HaveRulesBeenConfigured()
    and GUI.GetPlayerID() ~= Syncer.GetHostPlayerID()
    and GUI.GetPlayerID() ~= 17 then
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
    local Visible = 0;
    if  Stronghold.Multiplayer:HaveRulesBeenConfigured()
    and XNetwork.Manager_DoesExist() == 1 then
        Visible = 1;
    end
    XGUIEng.ShowWidget(_Widget, Visible);
end

