--- 
--- Hero Script
---
--- This script implements all processes around the hero.
---
--- Managed by the script:
--- - Selection of hero
--- - Special units
--- - Summons
--- - Activated abilities
--- - Passive abilities
--- - Selection menus
--- 

Stronghold = Stronghold or {};

Stronghold.Hero = {
    SyncEvents = {},
    Data = {
        ConvertBlacklist = {},
    },
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- API

--- Creates an hero for the player.
--- 
--- This is supposed to be used when the player has no choice which hero
--- they have to use.
--- @param _PlayerID number ID of player
--- @param _Type number Entity type
--- @param _Position any Spawn position
function PlayerCreateNoble(_PlayerID, _Type, _Position)
    Stronghold.Hero:BuyHeroCreateNoble(_PlayerID, _Type, _Position);
end

--- Activates the hero selection for the player.
--- @param _PlayerID number ID of player
function PlayerActivateNobleSelection(_PlayerID)
    Stronghold.Hero:SetHeroSelectionForPlayerEnabled(_PlayerID, true);
end

--- Deactivates the hero selection for the player.
--- @param _PlayerID number ID of player
function PlayerDeactivateNobleSelection(_PlayerID)
    Stronghold.Hero:SetHeroSelectionForPlayerEnabled(_PlayerID, false);
end

--- Returns if the Noble of the player is of the type.
---
--- If the hero is downed then this function returns false.
---
--- @param _PlayerID number ID of player
--- @param _Type number Entity type
--- @return boolean HasHero Player has hero of type
function PlayerHasLordOfType(_PlayerID, _Type)
    return Stronghold.Hero:HasValidLordOfType(_PlayerID, _Type);
end

--- Returns if the player has a hero of the type.
---
--- He hero doesn't need to be the Noble.
--- If the hero is downed then this function returns false.
---
--- @param _PlayerID number ID of player
--- @param _Type number Entity type
--- @return boolean HasHero Player has hero of type
function PlayerHasHeroOfType(_PlayerID, _Type)
    return Stronghold.Hero:HasValidHeroOfType(_PlayerID, _Type);
end

--- Changes the name of the hero in the selection screen.
--- @param _Type number Entity type
--- @param _Text any New name (string or table)
function SetHeroSelectionName(_Type, _Text)
    Stronghold.Hero:SetHeroName(_Type, _Text)
end

--- Changes the biography of the hero in the selection screen.
--- @param _Type number Entity type
--- @param _Text any New biography (string or table)
function SetHeroSelectionBiography(_Type, _Text)
    Stronghold.Hero:SetHeroBiography(_Type, _Text)
end

--- Changes the effect description of the hero in the selection screen.
--- @param _Type number Entity type
--- @param _Text any New effect description (string or table)
function SetHeroSelectionDescription(_Type, _Text)
    Stronghold.Hero:SetHeroDescription(_Type, _Text)
end

-- -------------------------------------------------------------------------- --

function Stronghold.Hero:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {};
        -- NEVER EVER CHANGE THIS!!!
        BuyHero.SetNumberOfBuyableHeroes(i, 1);
    end

    self:ConfigureBuyHero();
    self:OverrideCalculationCallbacks();
    self:OverrideHero5AbilityArrowRain();
    self:OverrideHero8AbilityMoralDamage();
end

function Stronghold.Hero:OnSaveGameLoaded()
    for i= 1, table.getn(Score.Player) do
        local Wolves = Stronghold:GetLeadersOfType(i, Entities.CU_Barbarian_Hero_wolf);
        for j=1, table.getn(Wolves) do
            self:ConfigurePlayersHeroPet(Wolves[j]);
        end
    end
end

function Stronghold.Hero:SetEntityConvertable(_EntityID, _Flag)
    self.Data.ConvertBlacklist[_EntityID] = _Flag == true;
end

function Stronghold.Hero:SetHeroName(_Type, _Text)
    local Text = _Text;
    if type(Text) ~= "table" then
        Text = {de = _Text, en = _Text};
    end
    self.Config.Hero.Name[_Type] = Text;
end

function Stronghold.Hero:SetHeroBiography(_Type, _Text)
    local Text = _Text;
    if type(Text) ~= "table" then
        Text = {de = _Text, en = _Text};
    end
    self.Config.Hero.Biography[_Type] = Text;
end

function Stronghold.Hero:SetHeroDescription(_Type, _Text)
    local Text = _Text;
    if type(Text) ~= "table" then
        Text = {de = _Text, en = _Text};
    end
    self.Config.Hero.Description[_Type] = Text;
end

function Stronghold.Hero:SetHeroSelectionForPlayerEnabled(_PlayerID, _Flag)
    -- Deactivates both the selection and the buy hero window.
    BuyHero.SetNumberOfBuyableHeroes(_PlayerID, (_Flag and 1) or 0);
end

-- -------------------------------------------------------------------------- --
-- Hero Selection

function Stronghold.Hero:OnSelectLeader(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if not IsHumanPlayer(PlayerID) or Logic.IsLeader(_EntityID) == 0 then
        return;
    end

    XGUIEng.SetWidgetPosition("Command_Attack", 4, 4);
    XGUIEng.SetWidgetPosition("Command_Stand", 38, 4);
    XGUIEng.SetWidgetPosition("Command_Defend", 72, 4);
    XGUIEng.SetWidgetPosition("Command_Patrol", 106, 4);
    XGUIEng.SetWidgetPosition("Command_Guard", 140, 4);
    XGUIEng.SetWidgetPosition("Formation01", 4, 38);
    XGUIEng.ShowWidget("Selection_MilitaryUnit", 1);

    XGUIEng.TransferMaterials("Research_Gilds", "Formation01");
    XGUIEng.ShowWidget("Selection_Leader", 1);

    local ShowFormations = 0;
    XGUIEng.ShowWidget("Commands_Leader", ShowFormations);
    for i= 1, 4 do
        XGUIEng.ShowWidget("Formation0" ..i, 1);
        if XGUIEng.IsButtonDisabled("Formation0" ..i) == 1 then
            if Logic.IsTechnologyResearched(PlayerID, Technologies.GT_StandingArmy) == 1 then
                XGUIEng.DisableButton("Formation0" ..i, 0);
            end
        end
    end
end

function Stronghold.Hero:OnSelectHero(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if not IsHumanPlayer(PlayerID) or Logic.IsHero(_EntityID) == 0 then
        return;
    end

    XGUIEng.SetWidgetPosition("Command_Attack", 4, 4);
    XGUIEng.SetWidgetPosition("Command_Stand", 38, 4);
    XGUIEng.SetWidgetPosition("Command_Defend", 72, 4);
    XGUIEng.SetWidgetPosition("Command_Patrol", 106, 4);
    XGUIEng.SetWidgetPosition("Command_Guard", 140, 4);
    XGUIEng.SetWidgetPosition("Formation01", 404, 4);
    XGUIEng.ShowWidget("Formation01", 0);
    XGUIEng.ShowWidget("Formation02", 0);
    XGUIEng.ShowWidget("Formation03", 0);
    XGUIEng.ShowWidget("Formation04", 0);

    self:OnSelectHero1(_EntityID);
    self:OnSelectHero2(_EntityID);
    self:OnSelectHero3(_EntityID);
    self:OnSelectHero4(_EntityID);
    self:OnSelectHero5(_EntityID);
    self:OnSelectHero6(_EntityID);
    self:OnSelectHero7(_EntityID);
    self:OnSelectHero8(_EntityID);
    self:OnSelectHero9(_EntityID);
    self:OnSelectHero10(_EntityID);
    self:OnSelectHero11(_EntityID);
    self:OnSelectHero12(_EntityID);
end

function Stronghold.Hero:OnSelectHero1(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    local TypeName = Logic.GetEntityTypeName(Type);
    if string.find(TypeName, "^PU_Hero1[abc]+$") then
        XGUIEng.SetWidgetPosition("Hero1_RechargeProtectUnits", 4, 38);
        XGUIEng.SetWidgetPosition("Hero1_ProtectUnits", 4, 38);
        XGUIEng.ShowWidget("Hero1_RechargeSendHawk", 0);
        XGUIEng.ShowWidget("Hero1_SendHawk", 0);
        XGUIEng.ShowWidget("Hero1_LookAtHawk", 0);
    end
end

function Stronghold.Hero:OnSelectHero2(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero2 then
        XGUIEng.SetWidgetPosition("Hero2_RechargePlaceBomb", 4, 38);
        XGUIEng.SetWidgetPosition("Hero2_PlaceBomb", 4, 38);
        XGUIEng.ShowWidget("Hero2_RechargeBuildCannon", 0);
        XGUIEng.ShowWidget("Hero2_BuildCannon", 0);
    end
end

function Stronghold.Hero:OnSelectHero3(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero3 then
        XGUIEng.SetWidgetPosition("Hero3_RechargeBuildTrap", 4, 38);
        XGUIEng.SetWidgetPosition("Hero3_BuildTrap", 4, 38);
        XGUIEng.ShowWidget("Hero3_RechargeHeal", 0);
        XGUIEng.ShowWidget("Hero3_Heal", 0);
    end
end

function Stronghold.Hero:OnSelectHero4(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero4 then
        XGUIEng.SetWidgetPosition("Hero4_RechargeCircularAttack", 4, 38);
        XGUIEng.SetWidgetPosition("Hero4_CircularAttack", 4, 38);
        XGUIEng.ShowWidget("Hero4_RechargeAuraOfWar", 0);
        XGUIEng.ShowWidget("Hero4_AuraOfWar", 0);
    end
end

function Stronghold.Hero:OnSelectHero5(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero5 then
        XGUIEng.SetWidgetPosition("Hero5_RechargeSummon", 4, 38);
        XGUIEng.SetWidgetPosition("Hero5_Summon", 4, 38);
        XGUIEng.SetWidgetPosition("Hero5_RechargeArrowRain", 4, 38);
        XGUIEng.SetWidgetPosition("Hero5_ArrowRain", 4, 38);
        XGUIEng.ShowWidget("Hero5_RechargeCamouflage", 0);
        XGUIEng.ShowWidget("Hero5_Camouflage", 0);
        XGUIEng.ShowWidget("Hero5_RechargeSummon", 0);
        XGUIEng.ShowWidget("Hero5_Summon", 0);
    end
end

function Stronghold.Hero:OnSelectHero6(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero6 then
        XGUIEng.SetWidgetPosition("Hero6_RechargeBless", 4, 38);
        XGUIEng.SetWidgetPosition("Hero6_Bless", 4, 38);
        XGUIEng.ShowWidget("Hero6_RechargeConvertSettler", 0);
        XGUIEng.ShowWidget("Hero6_ConvertSettler", 0);
    end
end

function Stronghold.Hero:OnSelectHero7(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_BlackKnight then
        XGUIEng.SetWidgetPosition("Hero7_RechargeMadness", 4, 38);
        XGUIEng.SetWidgetPosition("Hero7_Madness", 4, 38);
        XGUIEng.ShowWidget("Hero7_RechargeInflictFear", 0);
        XGUIEng.ShowWidget("Hero7_InflictFear", 0);
        XGUIEng.ShowWidget("Buy_Soldier", 1);
        XGUIEng.ShowWidget("Buy_Soldier_Button", 1);
    end
end

function Stronghold.Hero:OnSelectHero8(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_Mary_de_Mortfichet then
        XGUIEng.SetWidgetPosition("Hero8_RechargeMoraleDamage", 4, 38);
        XGUIEng.SetWidgetPosition("Hero8_MoraleDamage", 4, 38);
        XGUIEng.ShowWidget("Hero8_RechargePoison", 0);
        XGUIEng.ShowWidget("Hero8_Poison", 0);
    end
end

function Stronghold.Hero:OnSelectHero9(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_Barbarian_Hero then
        XGUIEng.SetWidgetPosition("Hero9_RechargeCallWolfs", 4, 38);
        XGUIEng.SetWidgetPosition("Hero9_CallWolfs", 4, 38);
        XGUIEng.ShowWidget("Hero9_RechargeBerserk", 0);
        XGUIEng.ShowWidget("Hero9_Berserk", 0);
    end
end

function Stronghold.Hero:OnSelectHero10(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero10 then
        XGUIEng.SetWidgetPosition("Hero10_RechargeLongRangeAura", 4, 38);
        XGUIEng.SetWidgetPosition("Hero10_LongRangeAura", 4, 38);
        XGUIEng.ShowWidget("Hero10_RechargeSniperAttack", 0);
        XGUIEng.ShowWidget("Hero10_SniperAttack", 0);
    end
end

function Stronghold.Hero:OnSelectHero11(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero11 then
        XGUIEng.SetWidgetPosition("Hero11_RechargeFireworksFear", 4, 38);
        XGUIEng.SetWidgetPosition("Hero11_FireworksFear", 4, 38);
        XGUIEng.ShowWidget("Hero11_RechargeShuriken", 0);
        XGUIEng.ShowWidget("Hero11_RechargeFireworksMotivate", 0);
        XGUIEng.ShowWidget("Hero11_Shuriken", 0);
        XGUIEng.ShowWidget("Hero11_FireworksMotivate", 0);
    end
end

function Stronghold.Hero:OnSelectHero12(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_Evil_Queen then
        XGUIEng.SetWidgetPosition("Hero12_RechargePoisonRange", 4, 38);
        XGUIEng.SetWidgetPosition("Hero12_PoisonRange", 4, 38);
        XGUIEng.ShowWidget("Hero12_RechargePoisonArrows", 0);
        XGUIEng.ShowWidget("Hero12_PoisonArrows", 0);
    end
end

function Stronghold.Hero:PrintSelectionName()
    local EntityID = GUI.GetSelectedEntity();
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    if IsHumanPlayer(PlayerID) then
		if EntityID == GetID(Stronghold.Players[PlayerID].LordScriptName) then
            local Type = Logic.GetEntityType(EntityID);
            local TypeName = Logic.GetEntityTypeName(Type);
            local Name = XGUIEng.GetStringTableText("Names/" ..TypeName);
            local CurrentRank = GetRank(PlayerID);
            local Text = GetRankName(CurrentRank, PlayerID);
            XGUIEng.SetText("Selection_Name", Text.. " " ..Name);
		end
    end
end

-- -------------------------------------------------------------------------- --
-- Buy Hero

function Stronghold.Hero:ConfigureBuyHero()
    Overwrite.CreateOverwrite("GameCallback_Logic_BuyHero_OnHeroSelected", function(_PlayerID, _ID, _Type)
        if IsHumanPlayer(_PlayerID) then
            Stronghold.Hero:BuyHeroSetupNoble(_PlayerID, _ID, _Type);
            Stronghold.Hero:PlayFunnyComment(_PlayerID);
            Stronghold.Hero:InitSpecialUnits(_PlayerID, _Type);
            return;
        end
        return Overwrite.CallOriginal();
    end);

    Overwrite.CreateOverwrite("GameCallback_GUI_BuyHero_GetHeadline", function(_PlayerID)
        if IsHumanPlayer(_PlayerID) then
            local LordID = GetID(Stronghold.Players[_PlayerID].LordScriptName);
            local Caption = (LordID ~= 0 and "Alea Iacta Est!") or "Wählt Euren Adligen!";
            return Caption;
        end
        return Overwrite.CallOriginal();
    end);

    Overwrite.CreateOverwrite("GameCallback_GUI_BuyHero_GetMessage", function(_PlayerID, _Type)
        if IsHumanPlayer(_PlayerID) then
            local Lang = GetLanguage();
            local TypeName = Logic.GetEntityTypeName(_Type);

            -- Displayed name
            local DisplayName = XGUIEng.GetStringTableText("sh_names/Name_" ..TypeName);
            if Stronghold.Hero.Config.Hero.Name[_Type] then
                if type(Stronghold.Hero.Config.Hero.Name[_Type]) == "table" then
                    DisplayName = Stronghold.Hero.Config.Hero.Name[_Type][Lang];
                else
                    DisplayName = Stronghold.Hero.Config.Hero.Name[_Type];
                end
            end
            -- Displayed biography
            local Biography = XGUIEng.GetStringTableText("sh_text/Biography_" ..TypeName);
            if Stronghold.Hero.Config.Hero.Biography[_Type] then
                if type(Stronghold.Hero.Config.Hero.Biography[_Type]) == "table" then
                    Biography = Stronghold.Hero.Config.Hero.Biography[_Type][Lang];
                else
                    Biography = Stronghold.Hero.Config.Hero.Biography[_Type];
                end
            end
            -- Displayed skills
            local Description = XGUIEng.GetStringTableText("sh_text/Effects_" ..TypeName);
            -- Line breaks in string tables are NOT ignored!
            Description = string.gsub(Description, "\r\n", "");
            Description = string.gsub(Description, "\n", "");
            if Stronghold.Hero.Config.Hero.Description[_Type] then
                if type(Stronghold.Hero.Config.Hero.Description[_Type]) == "table" then
                    Description = Stronghold.Hero.Config.Hero.Description[_Type][Lang];
                else
                    Description = Stronghold.Hero.Config.Hero.Description[_Type];
                end
            end

            return Placeholder.Replace(string.format(
                "%s{cr}{cr}{grey}%s{cr}{cr}{white}%s",
                DisplayName,
                Biography,
                Description
            ));
        end
        return Overwrite.CallOriginal();
    end);
end

function Stronghold.Hero:BuyHeroCreateNoble(_PlayerID, _Type, _Position)
    if IsHumanPlayer(_PlayerID) then
        local Position = _Position;
        if type(Position) ~= "table" then
            Position = GetPosition(Position);
        end
        local ID = Logic.CreateEntity(_Type, Position.X, Position.Y, 0, _PlayerID);
        self:BuyHeroSetupNoble(_PlayerID, ID, _Type, true);
        self:InitSpecialUnits(_PlayerID, _Type);
    end
end

function Stronghold.Hero:BuyHeroSetupNoble(_PlayerID, _ID, _Type, _Silent)
    if IsHumanPlayer(_PlayerID) then
        -- Get motivation cap
        local ExpectedSoftCap = 2;
        local CurrentSoftCap = CUtil.GetPlayersMotivationSoftcap(_PlayerID);
        -- Set name of lord
        Logic.SetEntityName(_ID, Stronghold.Players[_PlayerID].LordScriptName);
        -- Display info message
        if not _Silent then
            local PlayerName = UserTool_GetPlayerName(_PlayerID);
            local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
            local Text = XGUIEng.GetStringTableText("sh_text/Player_NobleChosen");
            Message(string.format(Text, PlayerColor, PlayerName));
        end

        if _Type == Entities.PU_Hero11 then
            -- Update motivation soft cap
            ExpectedSoftCap = Stronghold.Hero.Config.Hero11.ReputationCap / 100;
            -- Give motivation for Yuki
            local RepuBonus = Stronghold.Hero.Config.Hero11.InitialReputation;
            Stronghold.Attraction:UpdateMotivationOfPlayersWorkers(_PlayerID, RepuBonus);
            Stronghold:AddPlayerReputation(_PlayerID, RepuBonus);
        end
        if _Type == Entities.CU_BlackKnight then
            -- Update motivation soft cap
            ExpectedSoftCap = Stronghold.Hero.Config.Hero7.ReputationCap / 100;
            -- Create guard for Kerberos
            -- Tools.CreateSoldiersForLeader(_ID, 3);
            Logic.LeaderChangeFormationType(_ID, 1);
        end

        -- Call hero selected callbacks
        CUtil.AddToPlayersMotivationSoftcap(_PlayerID, ExpectedSoftCap - CurrentSoftCap);
        if _PlayerID == GUI.GetPlayerID() or GUI.GetPlayerID() == 17 then
            Stronghold.Building:OnHeadquarterSelected(GUI.GetSelectedEntity());
        end
    end
end

-- The wolves of Varg becoming stronger when he gets higher titles.
function Stronghold.Hero:ConfigurePlayersHeroPet(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_Barbarian_Hero_wolf then
        if self:HasValidLordOfType(PlayerID, Entities.CU_Barbarian_Hero) then
            local CurrentRank = GetRank(PlayerID);
            local Armor = 2 + math.floor(CurrentRank * 0.5);
            local Damage = 13 + math.floor(CurrentRank * 3);
            Logic.SetSpeedFactor(_EntityID, 1.1 + ((CurrentRank -1) * 0.04));
            SVLib.SetEntitySize(_EntityID, 1.1 + ((CurrentRank -1) * 0.04));
            CEntity.SetArmor(_EntityID, Armor);
            CEntity.SetDamage(_EntityID, Damage);
        end
    end
end

-- Play a funny comment when the hero is selected.
function Stronghold.Hero:PlayFunnyComment(_PlayerID)
    -- It's not intended anymore that other players hear the funny comment.
    if GetLocalPlayerID() ~= _PlayerID then
        return;
    end

    local FunnyComment = Sounds.VoicesHero1_HERO1_FunnyComment_rnd_01;
    local LordID = GetID(Stronghold.Players[_PlayerID].LordScriptName);
    local Type = Logic.GetEntityType(LordID);
    if Type == Entities.PU_Hero2 then
        FunnyComment = Sounds.VoicesHero2_HERO2_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero3 then
        FunnyComment = Sounds.VoicesHero3_HERO3_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero4 then
        FunnyComment = Sounds.VoicesHero4_HERO4_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero5 then
        FunnyComment = Sounds.VoicesHero5_HERO5_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero6 then
        FunnyComment = Sounds.VoicesHero6_HERO6_FunnyComment_rnd_01;
    elseif Type == Entities.CU_BlackKnight then
        FunnyComment = Sounds.VoicesHero7_HERO7_FunnyComment_rnd_01;
    elseif Type == Entities.CU_Mary_de_Mortfichet then
        FunnyComment = Sounds.VoicesHero8_HERO8_FunnyComment_rnd_01;
    elseif Type == Entities.CU_Barbarian_Hero then
        FunnyComment = Sounds.VoicesHero9_HERO9_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero10 then
        FunnyComment = Sounds.AOVoicesHero10_HERO10_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero11 then
        FunnyComment = Sounds.AOVoicesHero11_HERO11_FunnyComment_rnd_01;
    elseif Type == Entities.CU_Evil_Queen then
        FunnyComment = Sounds.AOVoicesHero12_HERO12_FunnyComment_rnd_01;
    end
    Sound.PlayQueuedFeedbackSound(FunnyComment, 100);
end

function Stronghold.Hero:InitSpecialUnits(_PlayerID, _Type)
    Stronghold.Recruitment:InitDefaultRoster(_PlayerID);

    local ThiefRecruiter = {Entities.PB_Tavern2};
    if string.find(Logic.GetEntityTypeName(_Type), "^PU_Hero1[abc]+$") then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword2"] = Entities.PU_LeaderPoleArm4;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.PU_LeaderSword4;
    elseif _Type == Entities.PU_Hero4 then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow2"] = Entities.PU_LeaderBow2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow3"] = Entities.PU_LeaderBow3;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeRifle1"] = Entities.PU_LeaderRifle1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeCavalryHeavy1"] = Entities.PU_LeaderHeavyCavalry2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeCavalryLight1"] = Entities.PU_LeaderCavalry2;
    elseif _Type == Entities.PU_Hero5 then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword3"] = Entities.CU_BanditLeaderSword2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.CU_BanditLeaderSword1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow1"] = Entities.CU_BanditLeaderBow1;
    elseif _Type == Entities.CU_BlackKnight then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword2"] = Entities.PU_LeaderPoleArm2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword3"] = Entities.CU_BlackKnight_LeaderMace2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.CU_BlackKnight_LeaderMace1;
    elseif _Type == Entities.CU_Mary_de_Mortfichet then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow3"] = Entities.PU_LeaderBow4;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeRifle1"] = Entities.PU_LeaderRifle1;
        ResearchTechnology(Technologies.T_ThiefSabotage, _PlayerID);
        ThiefRecruiter = {Entities.PB_Tavern1, Entities.PB_Tavern2};
    elseif _Type == Entities.CU_Barbarian_Hero then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword2"] = Entities.PU_LeaderSword1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword3"] = Entities.CU_Barbarian_LeaderClub2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.CU_Barbarian_LeaderClub1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow1"] = Entities.PU_LeaderBow1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow2"] = Entities.PU_LeaderBow2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow3"] = Entities.PU_LeaderBow3;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeRifle1"] = Entities.PU_LeaderRifle1;
    elseif _Type == Entities.CU_Evil_Queen then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword2"] = Entities.PU_LeaderPoleArm2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword3"] = Entities.CU_Evil_LeaderBearman1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.PU_LeaderSword3;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow2"] = Entities.PU_LeaderBow2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow3"] = Entities.CU_Evil_LeaderSkirmisher1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeRifle1"] = Entities.PU_LeaderBow3;
    end
    Stronghold.Recruitment.Data[_PlayerID].Config[Entities.PU_Thief].RecruiterBuilding = ThiefRecruiter;
end

-- -------------------------------------------------------------------------- --
-- Trigger

function Stronghold.Hero:EntityAttackedController(_PlayerID)
    if IsHumanPlayer(_PlayerID) then
        for k,v in pairs(Stronghold.Players[_PlayerID].AttackMemory) do
            -- Count down and remove
            Stronghold.Players[_PlayerID].AttackMemory[k][1] = v[1] -1;
            if Stronghold.Players[_PlayerID].AttackMemory[k][1] <= 0 then
                Stronghold.Players[_PlayerID].AttackMemory[k] = nil;
            end

            -- Teleport to HQ
            if Logic.IsHero(k) == 1 then
                if Logic.GetEntityHealth(k) == 0 then
                    Stronghold.Players[_PlayerID].AttackMemory[k] = nil;
                    local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
                    local x,y,z = Logic.EntityGetPos(k);

                    -- Send message
                    local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(k));
                    local Name = XGUIEng.GetStringTableText("Names/" ..TypeName);
                    local Text = XGUIEng.GetStringTableText("sh_text/Player_NobleDefeated");
                    Message(string.format(Text, PlayerColor, Name));
                    -- Place hero
                    Logic.CreateEffect(GGL_Effects.FXDieHero, x, y, _PlayerID);
                    local ID = SetPosition(k, Stronghold.Players[_PlayerID].DoorPos);
                    if Logic.GetEntityType(ID) == Entities.CU_BlackKnight then
                        Logic.LeaderChangeFormationType(ID, 1);
                    end
                    Logic.HurtEntity(ID, Logic.GetEntityHealth(ID));
                end
            end

            if not IsExisting(k) then
                Stronghold.Players[_PlayerID].AttackMemory[k] = nil;
            end
        end
    end
end

function Stronghold.Hero:HeliasConvertController(_PlayerID)
    if IsHumanPlayer(_PlayerID) then
        for k,v in pairs(Stronghold.Players[_PlayerID].AttackMemory) do
            if Logic.GetEntityType(k) == Entities.PU_Hero6 then
                if Logic.GetEntityHealth(k) > 0 then
                    if math.random(1, self.Config.Hero6.ConversionMax) <= self.Config.Hero6.ConversionChance then
                        local HeliasPlayerID = Logic.EntityGetPlayer(k);
                        local AttackerID = v[2];
                        if Logic.IsEntityInCategory(AttackerID, EntityCategories.Soldier) == 1 then
                            AttackerID = SVLib.GetLeaderOfSoldier(AttackerID);
                        end
                        if not self.Data.ConvertBlacklist[AttackerID] then
                            local UnitType = Logic.GetEntityType(AttackerID);
                            local Config = Stronghold.Unit.Config:Get(UnitType, _PlayerID);
                            if Config then
                                local RankRequired = GetRankRequired(UnitType, Config.Right);
                                if  (RankRequired ~= -1 and GetRank(_PlayerID) >= RankRequired)
                                and Logic.GetEntityHealth(AttackerID) > 0
                                and Logic.IsSettler(AttackerID) == 1
                                and Logic.IsHero(AttackerID) == 0 then
                                    if GetDistance(AttackerID, k) <= self.Config.Hero6.ConversionArea then
                                        ChangePlayer(AttackerID, HeliasPlayerID);
                                        if GUI.GetPlayerID() == HeliasPlayerID then
                                            Sound.PlayFeedbackSound(Sounds.VoicesHero6_HERO6_ConvertSettler_rnd_01, 0);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function Stronghold.Hero:VargWolvesController(_PlayerID)
    if IsHumanPlayer(_PlayerID) then
        local WolvesBatteling = 0;
        for k,v in pairs(Stronghold:GetLeadersOfType(_PlayerID, Entities.CU_Barbarian_Hero_wolf)) do
            local Task = Logic.GetCurrentTaskList(v);
            if Task and string.find(Task, "BATTLE") then
                WolvesBatteling = WolvesBatteling +1;
            end
        end
        local Honor = self.Config.Hero9.WolfHonorRate * WolvesBatteling;
        Stronghold.Economy:AddOneTimeHonor(_PlayerID, Honor);
    end
end

function Stronghold.Hero:YukiShurikenConterController(_PlayerID)
    if CMod and IsHumanPlayer(_PlayerID) then
        for k,v in pairs(Stronghold.Players[_PlayerID].AttackMemory) do
            if Logic.GetEntityType(k) == Entities.PU_Hero11 then
                if Logic.GetEntityHealth(k) > 0 then
                    local RechargeTime = Logic.HeroGetAbilityRechargeTime(k, Abilities.AbilityShuriken);
                    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(k, Abilities.AbilityShuriken);
                    if TimeLeft == RechargeTime then
                        if math.random(1, self.Config.Hero11.ShurikenMax) <= self.Config.Hero11.ShurikenChance then
                            local YukiPlayerID = Logic.EntityGetPlayer(k);
                            local AttackerID = v[2];
                            if Logic.IsEntityInCategory(AttackerID, EntityCategories.Soldier) == 1 then
                                AttackerID = SVLib.GetLeaderOfSoldier(AttackerID);
                            end
                            if Logic.IsSettler(AttackerID) == 1
                            and Logic.IsHero(AttackerID) == 0
                            and Logic.GetEntityHealth(AttackerID) > 0
                            and IsNear(k, AttackerID, 3000) then
                                SendEvent.HeroShuriken(k, AttackerID);
                                if GUI.GetPlayerID() == YukiPlayerID then
                                    Sound.PlayFeedbackSound(Sounds.AOVoicesHero11_HERO11_Shuriken_rnd_01, 0);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Activated Abilities

function Stronghold.Hero:OverrideHero5AbilityArrowRain()
    function GUIAction_Hero5ArrowRain()
        GUI.ActivateShurikenCommandState();
	    GUI.State_SetExclusiveMessageRecipient(HeroSelection_GetCurrentSelectedHeroID());
    end
    Overwrite.CreateOverwrite("GUITooltip_NormalButton", function(_TextKey, _ShortCut)
        Overwrite.CallOriginal();
        if _TextKey == "AOMenuHero5/command_poisonarrows" then
            local Text = XGUIEng.GetStringTableText("sh_text/Skill_1_PU_Hero5");
            ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name")..
                ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]";

            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Placeholder.Replace(Text));
            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
        end
    end);
end

function Stronghold.Hero:OverrideHero8AbilityMoralDamage()
    function GUIAction_Hero8MoraleDamage()
        local HeroID = HeroSelection_GetCurrentSelectedHeroID();
        GUI.SettlerCircularAttack(HeroID);
        GUI.SettlerAffectUnitsInArea(HeroID);
    end
    Overwrite.CreateOverwrite("GUITooltip_NormalButton", function(_TextKey, _ShortCut)
        Overwrite.CallOriginal();
        if _TextKey == "MenuHero8/command_moraledamage" then
            local Text = XGUIEng.GetStringTableText("sh_text/Skill_1_CU_Mary_de_Mortfichet");
            ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name")..
                ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]";

            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Placeholder.Replace(Text));
            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
        end
    end);
end

-- -------------------------------------------------------------------------- --
-- Passive Abilities

function Stronghold.Hero:OverrideCalculationCallbacks()
    -- Generic --
    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ResourceMined", function(_PlayerID, _BuildingID, _ResourceType, _Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ResourceProductionBonus(_PlayerID, _BuildingID, _ResourceType, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ResourceRefined", function(_PlayerID, _BuildingID, _ResourceType, Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ResourceRefiningBonus(_PlayerID, _BuildingID, _ResourceType, CurrentAmount);
        return CurrentAmount;
    end);

    -- Noble --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ReputationMax", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMaxReputationPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ReputationIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyReputationIncreasePassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_DynamicReputationIncrease", function(_PlayerID, _BuildingID, _WorkerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyDynamicReputationBonusPassiveAbility(_PlayerID, _BuildingID, _WorkerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ReputationDecrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyReputationDecreasePassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_HonorIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyHonorBonusPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_DynamicHonorIncrease", function(_PlayerID, _BuildingID, _WorkerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyDynamicHonorBonusPassiveAbility(_PlayerID, _BuildingID, _WorkerID, CurrentAmount);
        return CurrentAmount;
    end);

    -- Money --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_TotalPaydayIncome", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyIncomeBonusPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_TotalPaydayUpkeep", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyUpkeepDiscountPassiveAbility(_PlayerID, _CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_PaydayUpkeep", function(_PlayerID, _UnitType, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyUnitUpkeepDiscountPassiveAbility(_PlayerID, _UnitType, CurrentAmount)
        return CurrentAmount;
    end);

    -- Attraction --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_CivilAttrationLimit", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMaxCivilAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_CivilAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyCivilAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MilitaryAttrationLimit", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMaxMilitaryAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MilitaryAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMilitaryAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    -- Social --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MeasureIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMeasurePointsPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_CrimeRate", function(_PlayerID, _Rate)
        local CrimeRate = Overwrite.CallOriginal();
        CrimeRate = Stronghold.Hero:ApplyCrimeRatePassiveAbility(_PlayerID, CrimeRate);
        return CrimeRate;
    end);
end

function Stronghold.Hero:HasValidLordOfType(_PlayerID, _Type)
    if IsHumanPlayer(_PlayerID) then
        local LordID = GetID(Stronghold.Players[_PlayerID].LordScriptName);
        if self:IsValidHero(LordID, _Type) then
            return true;
        end
    end
    return false;
end

function Stronghold.Hero:HasValidHeroOfType(_PlayerID, _Type)
    if IsHumanPlayer(_PlayerID) then
        for k, HeroID in pairs(self:GetHeroes(_PlayerID)) do
            if self:IsValidHero(HeroID, _Type) then
                return true;
            end
        end
    end
    return false;
end

function Stronghold.Hero:IsValidHero(_HeroID, _Type)
    local HeroType = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(HeroType);
    if IsEntityValid(_HeroID) then
        if type(_Type) == "string" and TypeName and string.find(TypeName, _Type) then
            return true;
        elseif type(_Type) == "number" and HeroType == _Type then
            return true;
        end
    end
    return false;
end

function Stronghold.Hero:GetHeroes(_PlayerID)
    local HeroList = {};
    Logic.GetHeroes(_PlayerID, HeroList);
    return HeroList;
end

-- Passive Ability: Resource production bonus
function Stronghold.Hero:ResourceProductionBonus(_PlayerID, _BuildingID, _Type, _Amount)
    local Amount = _Amount;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero2) then
        if _Type == ResourceType.ClayRaw
        or _Type == ResourceType.IronRaw
        or _Type == ResourceType.StoneRaw
        or _Type == ResourceType.SulfurRaw
        then
            Amount = Amount + (1 + Logic.GetUpgradeLevelForBuilding(_BuildingID));
        end
    end
    return Amount;
end

-- Passive Ability: Resource refining bonus
function Stronghold.Hero:ResourceRefiningBonus(_PlayerID, _BuildingID, _Type, _Amount)
    local Amount = _Amount;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero5) then
        if _Type == ResourceType.Wood then
            Amount = Amount + 1;
        end
    end
    return Amount;
end

-- Passive Ability: leader costs
function Stronghold.Hero:ApplyLeaderCostPassiveAbility(_PlayerID, _Type, _Costs)
    local Costs = _Costs;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero4) then
        local Factor = self.Config.Hero4.UnitCostFactor;
        local IsCannon = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Cannon) == 1
        local IsScout = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Scout) == 1
        local IsThief = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Thief) == 1
        if not IsCannon and not IsScout and not IsThief then
            if Costs[ResourceType.Gold] then
                Costs[ResourceType.Gold] = math.ceil(Costs[ResourceType.Gold] * Factor);
            end
            if Costs[ResourceType.Clay] then
                Costs[ResourceType.Clay] = math.ceil(Costs[ResourceType.Clay] * Factor);
            end
            if Costs[ResourceType.Wood] then
                Costs[ResourceType.Wood] = math.ceil(Costs[ResourceType.Wood] * Factor);
            end
            if Costs[ResourceType.Stone] then
                Costs[ResourceType.Stone] = math.ceil(Costs[ResourceType.Stone] * Factor);
            end
            if Costs[ResourceType.Iron] then
                Costs[ResourceType.Iron] = math.ceil(Costs[ResourceType.Iron] * Factor);
            end
            if Costs[ResourceType.Sulfur] then
                Costs[ResourceType.Sulfur] = math.ceil(Costs[ResourceType.Sulfur] * Factor);
            end
        end
    end
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero3) then
        local Factor = self.Config.Hero3.UnitCostFactor;
        if Logic.IsEntityTypeInCategory(_Type, EntityCategories.Cannon) == 1 then
            Costs[ResourceType.Gold] = math.ceil(Costs[ResourceType.Gold] * Factor);
            Costs[ResourceType.Wood] = math.ceil(Costs[ResourceType.Wood] * Factor);
            Costs[ResourceType.Iron] = math.ceil(Costs[ResourceType.Iron] * Factor);
            Costs[ResourceType.Sulfur] = math.ceil(Costs[ResourceType.Sulfur] * Factor);
        end
    end
    return Costs;
end

-- Passive Ability: soldier costs
function Stronghold.Hero:ApplySoldierCostPassiveAbility(_PlayerID, _LeaderType, _Costs)
    local Costs = _Costs;
    -- Do nothing
    return Costs;
end

function Stronghold.Hero:ApplyRecruitTimePassiveAbility(_PlayerID, _LeaderType, _Value)
    local Value = _Value;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero10) then
        if Logic.IsEntityTypeInCategory(_LeaderType, EntityCategories.Rifle) == 1 then
            Value = Value * self.Config.Hero10.TrainTimeFactor;
        end
    end
    return Value;
end

-- Passive Ability: Change civil places usage
function Stronghold.Hero:ApplyCivilAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    -- Do nothing
    return Value;
end

-- Passive Ability: Increase of max civil attraction
function Stronghold.Hero:ApplyMaxCivilAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidLordOfType(_PlayerID, Entities.CU_Evil_Queen) then
        Value = Value * self.Config.Hero12.PupulationFactor;
    end
    return Value;
end

-- Passive Ability: Change millitary places usage
function Stronghold.Hero:ApplyMilitaryAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidLordOfType(_PlayerID, Entities.CU_Mary_de_Mortfichet) then
        local ThiefCount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Thief);
        Value = Value - (ThiefCount * 3);
    elseif self:HasValidLordOfType(_PlayerID, Entities.PU_Hero3) then
        local Cannon1 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PV_Cannon1);
        Cannon1 = math.floor(((Cannon1 * 10) * self.Config.Hero3.UnitPlaceFactor) + 0.5);
        local Cannon2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PV_Cannon2);
        Cannon2 = math.floor(((Cannon2 * 10) * self.Config.Hero3.UnitPlaceFactor) + 0.5);
        local Cannon3 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PV_Cannon3);
        Cannon3 = math.floor(((Cannon3 * 10) * self.Config.Hero3.UnitPlaceFactor) + 0.5);
        local Cannon4 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PV_Cannon4);
        Cannon4 = math.floor(((Cannon4 * 10) * self.Config.Hero3.UnitPlaceFactor) + 0.5);
        Value = Value - (Cannon1 + Cannon2 + Cannon3 + Cannon4);
    end
    return Value;
end

-- Passive Ability: Increase of max military attraction
function Stronghold.Hero:ApplyMaxMilitaryAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    -- Do nothing
    return Value;
end

-- Passive Ability: Increase of reputation
function Stronghold.Hero:ApplyMaxReputationPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidLordOfType(_PlayerID, Entities.CU_BlackKnight) then
        Value = self.Config.Hero7.ReputationCap;
    elseif self:HasValidLordOfType(_PlayerID, Entities.PU_Hero11) then
        Value = self.Config.Hero11.ReputationCap;
    end
    return Value;
end

-- Passive Ability: Increase of reputation
function Stronghold.Hero:ApplyReputationIncreasePassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    -- Do nothing
    return Value;
end

-- Passive Ability: Decrease of reputation
function Stronghold.Hero:ApplyReputationDecreasePassiveAbility(_PlayerID, _Decrease)
    local Decrease = _Decrease;
    if self:HasValidLordOfType(_PlayerID, Entities.CU_BlackKnight) then
        Decrease = Decrease * self.Config.Hero7.ReputationLossFactor;
    end
    return Decrease;
end

-- Passive Ability: Improve dynamic reputation generation
function Stronghold.Hero:ApplyDynamicReputationBonusPassiveAbility(_PlayerID, _BuildingID, _WorkerID, _Amount)
    local Value = _Amount;
    if self:HasValidLordOfType(_PlayerID, Entities.CU_Barbarian_Hero) then
        local Type = Logic.GetEntityType(_BuildingID);
        if Type == Entities.PB_Tavern1 or Type == Entities.PB_Tavern2 then
            Value = Value * self.Config.Hero9.TavernEfficiency;
        end
    end
    return Value;
end

-- Passive Ability: Honor increase bonus
function Stronghold.Hero:ApplyHonorBonusPassiveAbility(_PlayerID, _Income)
    local Income = _Income;
    -- do nothing
    return Income;
end

-- Passive Ability: Improve dynamic honor generation
function Stronghold.Hero:ApplyDynamicHonorBonusPassiveAbility(_PlayerID, _BuildingID, _WorkerID, _Amount)
    local Value = _Amount;
    if self:HasValidLordOfType(_PlayerID, Entities.CU_Barbarian_Hero) then
        local Type = Logic.GetEntityType(_BuildingID);
        if Type == Entities.PB_Tavern1 or Type == Entities.PB_Tavern2 then
            Value = Value * self.Config.Hero9.TavernEfficiency;
        end
    end
    return Value;
end

-- Passive Ability: Tax income bonus
function Stronghold.Hero:ApplyIncomeBonusPassiveAbility(_PlayerID, _Income)
    local Income = _Income;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero5) then
        Income = Income * self.Config.Hero5.TaxIncomeFactor;
    end
    return Income;
end

-- Passive Ability: Upkeep discount
function Stronghold.Hero:ApplyUpkeepDiscountPassiveAbility(_PlayerID, _Upkeep)
    local Upkeep = _Upkeep;
    -- do nothing
    return Upkeep;
end

-- Passive Ability: Upkeep discount
-- This function is called for each unit type individually.
function Stronghold.Hero:ApplyUnitUpkeepDiscountPassiveAbility(_PlayerID, _Type, _Upkeep)
    local Upkeep = _Upkeep;
    if self:HasValidLordOfType(_PlayerID, Entities.CU_Mary_de_Mortfichet) then
        if _Type == Entities.PU_Thief then
            Upkeep = self.Config.Hero8.UpkeepFactor;
        end
    end
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero10) then
        if _Type == Entities.PU_LeaderRifle1 or _Type == Entities.PU_LeaderRifle2 then
            Upkeep = Upkeep * self.Config.Hero10.UpkeepFactor;
        end
    end
    return Upkeep;
end

-- Passive Ability: Generating measure points
function Stronghold.Hero:ApplyMeasurePointsPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidLordOfType(_PlayerID, "^PU_Hero1[abc]+$") then
        Value = Value * self.Config.Hero1.MeasureFactor;
    end
    return Value;
end

-- Passive Ability: Change factor of becoming a criminal
function Stronghold.Hero:ApplyCrimeRatePassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero6) then
        Value = Value * self.Config.Hero6.CrimeRateFactor;
    end
    return Value;
end

-- Passive Ability: Chance the chance of becoming a criminal
function Stronghold.Hero:ApplyCrimeChancePassiveAbility(_PlayerID, _Chance)
    local Value = _Chance;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero6) then
        Value = Value * self.Config.Hero9.WolfHonorRate;
    end
    return Value;
end

