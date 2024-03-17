--- 
--- Hero Script
---
--- This script implements all processes around the hero.
--- 

Stronghold = Stronghold or {};

Stronghold.Hero = {
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
--- This is supposed to be used when the player has no choice or starts without
--- a headquarter!
--- @param _PlayerID integer ID of player
--- @param _Type integer Hero type or 0 to take any existing
--- @param _Position any Spawn position
function PlayerCreateNoble(_PlayerID, _Type, _Position)
    Stronghold.Hero:BuyHeroCreateNoble(_PlayerID, _Type, _Position);
end

function PlayerSetupNoble(_PlayerID, _HeroID, _Type)
    Stronghold.Hero:BuyHeroSetupNoble(_PlayerID, _HeroID, _Type, true);
end

--- Activates the hero selection for the player.
--- @param _PlayerID integer ID of player
function PlayerActivateNobleSelection(_PlayerID)
    Stronghold.Hero:SetHeroSelectionForPlayerEnabled(_PlayerID, true);
end

--- Deactivates the hero selection for the player.
--- @param _PlayerID integer ID of player
function PlayerDeactivateNobleSelection(_PlayerID)
    Stronghold.Hero:SetHeroSelectionForPlayerEnabled(_PlayerID, false);
end

--- Returns if the Noble of the player is of the type.
---
--- If the hero is downed then this function returns false.
---
--- @param _PlayerID integer ID of player
--- @param _Type integer|string Entity type or name
--- @return boolean HasHero Player has hero of type
function PlayerHasLordOfType(_PlayerID, _Type)
    return Stronghold.Hero:HasValidLordOfType(_PlayerID, _Type);
end

--- Changes the name of the hero in the selection screen.
--- @param _Type integer Entity type
--- @param _Text any New name (string or table)
function SetHeroSelectionName(_Type, _Text)
    Stronghold.Hero:SetHeroName(_Type, _Text)
end

--- Changes the biography of the hero in the selection screen.
--- @param _Type integer Entity type
--- @param _Text any New biography (string or table)
function SetHeroSelectionBiography(_Type, _Text)
    Stronghold.Hero:SetHeroBiography(_Type, _Text)
end

--- Changes the effect description of the hero in the selection screen.
--- @param _Type integer Entity type
--- @param _Text any New effect description (string or table)
function SetHeroSelectionDescription(_Type, _Text)
    Stronghold.Hero:SetHeroDescription(_Type, _Text)
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Hero:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            Hero6 = {
                ConvertAllowed = 1,
                ConversionTime = 0,
            },
            Hero11 = {
                ShurikenAllowed = 1,
                ShurikenTime = 0,
            },
        };
        -- NEVER EVER CHANGE THIS!!!
        BuyHero.SetNumberOfBuyableHeroes(i, 1);
    end

    self:ConfigureBuyHero();
    self:OverrideCalculationCallbacks();
    self:OverrideHero5AbilityArrowRain();
    self:OverrideHero7AbilityMadness();
    self:OverrideHero8AbilityMoralDamage();
    self:OverrideDetailsPayAndSlots();
    self:OverrideGuiPlaceBuilding();
    self:OverwriteAttackMemoryRegister();
end

function Stronghold.Hero:OnSaveGameLoaded()
    for i= 1, GetMaxPlayers() do
        local Wolves = GetLeadersOfType(i, Entities.CU_Barbarian_Hero_wolf);
        for j= 2, Wolves[1] +1 do
            self:ConfigureSummonedEntities(Wolves[j]);
        end
    end
end

function Stronghold.Hero:SetEntityConvertable(_EntityID, _Flag)
    self.Data.ConvertBlacklist[_EntityID] = _Flag == true;
end

function Stronghold.Hero:SetHeroName(_Type, _Text)
    -- TODO: Use string key overwrite
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

function Stronghold.Hero:OnEntityCreated(_EntityID)
    -- Configure summons
    if Logic.IsSettler(_EntityID) == 1 then
        self:ConfigureSummonedEntities(_EntityID);
    end
end

function Stronghold.Hero:OncePerSecond(_PlayerID)
    -- Configure summons
    self:VargWolvesController(_PlayerID);
    -- Helias conversion
    self:HeliasConvertController(_PlayerID);
    -- Yukis Shuriken
    self:YukiShurikenConterController(_PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Hero Selection

function Stronghold.Hero:OnSelectLeader(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if not IsPlayer(PlayerID) or Logic.IsLeader(_EntityID) == 0 then
        return;
    end

    XGUIEng.SetWidgetPosition("Command_Attack", 4, 4);
    XGUIEng.SetWidgetPosition("Command_Stand", 38, 4);
    XGUIEng.SetWidgetPosition("Command_Defend", 72, 4);
    XGUIEng.SetWidgetPosition("Command_Patrol", 106, 4);
    XGUIEng.SetWidgetPosition("Command_Guard", 140, 4);

    XGUIEng.ShowWidget("Formation01", 0);
    XGUIEng.ShowWidget("Formation02", 0);
    XGUIEng.ShowWidget("Formation03", 0);
    XGUIEng.ShowWidget("Formation04", 0);

    XGUIEng.ShowWidget("Selection_MilitaryUnit", 1);
    XGUIEng.ShowWidget("Selection_Leader", 1);
    XGUIEng.ShowWidget("Commands_Leader", 0);
    XGUIEng.ShowWidget("Buy_Soldier", 1);
end

function Stronghold.Hero:OnSelectHero(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if not IsPlayer(PlayerID) or Logic.IsHero(_EntityID) == 0 then
        return;
    end

    XGUIEng.SetWidgetPosition("Command_Attack", 4, 4);
    XGUIEng.SetWidgetPosition("Command_Stand", 38, 4);
    XGUIEng.SetWidgetPosition("Command_Defend", 72, 4);
    XGUIEng.SetWidgetPosition("Command_Patrol", 106, 4);
    XGUIEng.SetWidgetPosition("Command_Guard", 140, 4);
    XGUIEng.ShowWidget("Buy_Soldier", 0);

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
        XGUIEng.SetWidgetPosition("Hero2_RechargeBuildCannon", 4, 38);
        XGUIEng.SetWidgetPosition("Hero2_BuildCannon", 4, 38);
        XGUIEng.ShowWidget("Hero2_RechargePlaceBomb", 0);
        XGUIEng.ShowWidget("Hero2_PlaceBomb", 0);
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
    if IsPlayer(PlayerID) then
		if EntityID == GetNobleID(PlayerID) then
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
    GameCallback_GUI_BuyHero_CountHeroes = function(_PlayerID)
        local Hero = {};
        Logic.GetHeroes(_PlayerID, Hero);
        for i= table.getn(Hero), 1, -1 do
            local Type = Logic.GetEntityType(Hero[i]);
            if Stronghold.Populace.Config.FakeHeroTypes[Type] then
                table.remove(Hero, i);
            end
        end
        return table.getn(Hero);
    end

    Overwrite.CreateOverwrite("GameCallback_Logic_BuyHero_OnHeroSelected", function(_PlayerID, _ID, _Type)
        if IsPlayer(_PlayerID) then
            Stronghold.Construction:InitBarracksBuildingLimits(_PlayerID);
            Stronghold.Hero:BuyHeroSetupNoble(_PlayerID, _ID, _Type);
            Stronghold.Hero:PlayFunnyComment(_PlayerID);
            Stronghold.Hero:InitSpecialUnits(_PlayerID, _Type);
            return;
        end
        return Overwrite.CallOriginal();
    end);

    Overwrite.CreateOverwrite("GameCallback_GUI_BuyHero_GetHeadline", function(_PlayerID)
        if IsPlayer(_PlayerID) then
            local SelectionText = XGUIEng.GetStringTableText("sh_text/Player_ChooseNobleMsg")
            local SelectionTextDone = XGUIEng.GetStringTableText("sh_text/Player_ChooseNobleDone")
            local LordID = GetNobleID(_PlayerID);
            return (LordID ~= 0 and SelectionTextDone) or SelectionText;
        end
        return Overwrite.CallOriginal();
    end);

    Overwrite.CreateOverwrite("GameCallback_GUI_BuyHero_GetMessage", function(_PlayerID, _Type)
        if IsPlayer(_PlayerID) then
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
    if IsPlayer(_PlayerID) then
        local ID = 0;
        local HeroList = self:GetHeroes(_PlayerID);
        if _Type == 0 and table.getn(HeroList) > 0 then
            ID = HeroList[1];
        else
            local Position = _Position;
            if type(Position) ~= "table" then
                Position = GetPosition(Position);
            end
            ID = Logic.CreateEntity(_Type, Position.X, Position.Y, 0, _PlayerID);
        end
        self:BuyHeroSetupNoble(_PlayerID, ID, _Type, true);
        self:InitSpecialUnits(_PlayerID, _Type);
    end
end

function Stronghold.Hero:BuyHeroSetupNoble(_PlayerID, _ID, _Type, _Silent)
    if IsPlayer(_PlayerID) then
        -- Get motivation cap
        local ExpectedSoftCap = 2;
        local CurrentSoftCap = CUtil.GetPlayersMotivationSoftcap(_PlayerID);
        -- Set name of lord
        Logic.SetEntityName(_ID, GetNobleScriptname(_PlayerID));
        -- Display info message
        if not _Silent and XNetwork.Manager_DoesExist() == 1 then
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
            Stronghold.Player:AddPlayerReputation(_PlayerID, RepuBonus);
        end
        if _Type == Entities.CU_BlackKnight then
            -- Update motivation soft cap
            ExpectedSoftCap = Stronghold.Hero.Config.Hero7.ReputationCap / 100;
            -- Create guard for Kerberos
            Tools.CreateSoldiersForLeader(_ID, 3);
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
function Stronghold.Hero:ConfigureSummonedEntities(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_Hero13_Summon then
        Logic.SetSpeedFactor(_EntityID, 0.9);
        SVLib.SetEntitySize(_EntityID, 0.9);
    end
    if Type == Entities.CU_Barbarian_Hero_wolf then
        if self:HasValidLordOfType(PlayerID, Entities.CU_Barbarian_Hero) then
            local CurrentRank = GetRank(PlayerID);
            local Armor = 3 + math.floor(CurrentRank * 0.5);
            local Damage = 14 + math.floor(CurrentRank * 2);
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
    local LordID = GetNobleID(_PlayerID);
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
    Stronghold.Recruit:InitDefaultRoster(_PlayerID);

    local ThiefRecruiter = {Entities.PB_Tavern2};
    if string.find(Logic.GetEntityTypeName(_Type), "^PU_Hero1[abc]+$")
    or _Type == Entities.CU_Hero13 then
        Stronghold.Recruit.Data[_PlayerID].Roster.Melee[5] = UpgradeCategories.LeaderPoleArm4;
        Stronghold.Recruit.Data[_PlayerID].Roster.Melee[6] = UpgradeCategories.LeaderSword4;
    elseif _Type == Entities.PU_Hero2 then
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[4] = UpgradeCategories.LeaderBow2;
        Stronghold.Recruit.Data[_PlayerID].Roster.Melee[5] = UpgradeCategories.LeaderAxe2;
        Stronghold.Recruit.Data[_PlayerID].Roster.Melee[6] = UpgradeCategories.LeaderAxe1;
    elseif _Type == Entities.PU_Hero3 then
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[4] = UpgradeCategories.LeaderBow2;
        Stronghold.Recruit.Data[_PlayerID].Roster.Cannon[5] = UpgradeCategories.Cannon5;
        Stronghold.Recruit.Data[_PlayerID].Roster.Cannon[6] = UpgradeCategories.Cannon6;
    elseif _Type == Entities.PU_Hero4 then
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[4] = UpgradeCategories.LeaderBow2;
        Stronghold.Recruit.Data[_PlayerID].Roster.Cavalry[3] = UpgradeCategories.LeaderCavalry2;
        Stronghold.Recruit.Data[_PlayerID].Roster.Cavalry[4] = UpgradeCategories.LeaderHeavyCavalry2;
    elseif _Type == Entities.PU_Hero5 then
        Stronghold.Recruit.Data[_PlayerID].Roster.Melee[5] = UpgradeCategories.BanditLeaderSword1;
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[4] = UpgradeCategories.BanditLeaderBow1;
        Stronghold.Recruit.Data[_PlayerID].Roster.Cavalry[3] = UpgradeCategories.BanditLeaderCavalry1;
    elseif _Type == Entities.PU_Hero6 then
        Stronghold.Recruit.Data[_PlayerID].Roster.Melee[5] = UpgradeCategories.TemplarLeaderPoleArm1;
        Stronghold.Recruit.Data[_PlayerID].Roster.Cavalry[3] = UpgradeCategories.TemplarLeaderCavalry1;
        Stronghold.Recruit.Data[_PlayerID].Roster.Cavalry[4] = UpgradeCategories.TemplarLeaderHeavyCavalry1;
    elseif _Type == Entities.PU_Hero10 then
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[2] = UpgradeCategories.LeaderBow2;
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[3] = UpgradeCategories.LeaderBow3;
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[4] = UpgradeCategories.LeaderRifle1;
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[5] = UpgradeCategories.LeaderRifle2;
    elseif _Type == Entities.PU_Hero11 then
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[2] = UpgradeCategories.LeaderBow2;
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[3] = UpgradeCategories.LeaderBow3;
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[4] = UpgradeCategories.LeaderRifle1;
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[5] = UpgradeCategories.LeaderRifle2;
    elseif _Type == Entities.CU_BlackKnight then
        Stronghold.Recruit.Data[_PlayerID].Roster.Melee[5] = UpgradeCategories.BlackKnightLeader2;
        Stronghold.Recruit.Data[_PlayerID].Roster.Melee[6] = UpgradeCategories.BlackKnightLeader1;
    elseif _Type == Entities.CU_Mary_de_Mortfichet then
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[4] = UpgradeCategories.LeaderBow4;
        ResearchTechnology(Technologies.T_ThiefSabotage, _PlayerID);
        local RankScout = GetRankRequired(_PlayerID, PlayerRight.Scout);
        local RightsAndDuties = Stronghold.Rights.Data[_PlayerID].Titles;
        table.insert(RightsAndDuties[RankScout].Rights, PlayerRight.Thief);
        SetRightsAndDuties(_PlayerID, RightsAndDuties);
        ThiefRecruiter = {Entities.PB_Tavern1, Entities.PB_Tavern2};
    elseif _Type == Entities.CU_Barbarian_Hero then
        Stronghold.Recruit.Data[_PlayerID].Roster.Melee[5] = UpgradeCategories.BarbarianLeader2;
        Stronghold.Recruit.Data[_PlayerID].Roster.Melee[6] = UpgradeCategories.BarbarianLeader1;
    elseif _Type == Entities.CU_Evil_Queen then
        Stronghold.Recruit.Data[_PlayerID].Roster.Melee[5] = UpgradeCategories.BearmanLeader1;
        Stronghold.Recruit.Data[_PlayerID].Roster.Ranged[4] = UpgradeCategories.SkirmisherLeader1;
    end
    Stronghold.Recruit.Data[_PlayerID].Config[Entities.PU_Thief].RecruiterBuilding = ThiefRecruiter;
end

-- -------------------------------------------------------------------------- --
-- Passive battle effects

function Stronghold.Hero:OverwriteAttackMemoryRegister()
    Overwrite.CreateOverwrite("GameCallback_SH_Logic_OnAttackRegisterIteration", function(_PlayerID, _AttackedID, _AttackerID, _TimeRemaining)
        Overwrite.CallOriginal();
        Stronghold.Hero:HeroTeleportController(_PlayerID, _AttackedID);
        Stronghold.Hero:HeliasConvertController(_PlayerID, _AttackedID, _AttackerID);
        Stronghold.Hero:YukiShurikenConterController(_PlayerID, _AttackedID, _AttackerID);
    end);
end

function Stronghold.Hero:HeroTeleportController(_PlayerID, _EntityID)
    if Logic.IsHero(_EntityID) == 1 and Logic.GetEntityHealth(_EntityID) == 0 then
        local EntityType = Logic.GetEntityType(_EntityID);
        if Stronghold.Populace.Config.FakeHeroTypes[EntityType] then
            DestroyEntity(_EntityID);
        else
            local CastleID = GetHeadquarterID(_PlayerID);
            if CastleID ~= 0 and Logic.IsBuilding(CastleID) == 1 then
                Stronghold.Player:InvalidateAttackRegister(_PlayerID, _EntityID);
                local Text = XGUIEng.GetStringTableText("sh_text/Player_NobleDefeated");
                Message(Text);
                local x,y,z = Logic.EntityGetPos(_EntityID);
                Logic.CreateEffect(GGL_Effects.FXDieHero, x, y, _PlayerID);
                local ID = SetPosition(_EntityID, GetHeadquarterEntrance(_PlayerID));
                if Logic.GetEntityType(ID) == Entities.CU_BlackKnight then
                    Logic.LeaderChangeFormationType(ID, 1);
                end
                Logic.HurtEntity(ID, Logic.GetEntityHealth(ID));
            end
        end
    end
end

function Stronghold.Hero:HeliasConvertController(_PlayerID, _AttackedID, _AttackerID)
    if Logic.GetEntityType(_AttackedID) == Entities.PU_Hero6 then
        if Logic.GetEntityHealth(_AttackedID) > 0 then
            -- Reset limit
            local CurrentTurn = Logic.GetCurrentTurn();
            local UsedLast = self.Data[_PlayerID].Hero6.ConversionTime;
            local UsageFrequency = self.Config.Hero6.ConversionFrequency;
            if CurrentTurn - UsedLast >= UsageFrequency then
                self.Data[_PlayerID].Hero6.ConvertAllowed = 1;
            end
            -- Convert 1 enemy
            if self.Data[_PlayerID].Hero6.ConvertAllowed == 1 then
                local HeliasPlayerID = Logic.EntityGetPlayer(_AttackedID);
                local AttackerID = _AttackerID;
                if Logic.IsEntityInCategory(AttackerID, EntityCategories.Soldier) == 1 then
                    AttackerID = SVLib.GetLeaderOfSoldier(AttackerID);
                end
                if not self.Data.ConvertBlacklist[AttackerID] then
                    local UnitType = Logic.GetEntityType(AttackerID);
                    local Config = Stronghold.Unit.Config.Troops:GetConfig(UnitType, _PlayerID);
                    if Config then
                        local RankRequired = GetRankRequired(UnitType, Config.Right);
                        if  (RankRequired ~= -1 and GetRank(_PlayerID) >= RankRequired)
                        and Logic.GetEntityHealth(AttackerID) > 0
                        and Logic.IsSettler(AttackerID) == 1
                        and Logic.IsHero(AttackerID) == 0 then
                            if GetDistance(AttackerID, _AttackedID) <= self.Config.Hero6.ConversionArea then
                                local ID = ChangePlayer(AttackerID, HeliasPlayerID);
                                if GUI.GetPlayerID() == HeliasPlayerID then
                                    Sound.PlayFeedbackSound(Sounds.VoicesHero6_HERO6_ConvertSettler_rnd_01, 100);
                                end
                                self.Data[_PlayerID].Hero6.ConversionTime = CurrentTurn;
                                self.Data[_PlayerID].Hero6.ConvertAllowed = 0;
                            end
                        end
                    end
                end
            end
        end
    end
end

function Stronghold.Hero:YukiShurikenConterController(_PlayerID, _AttackedID, _AttackerID)
    if Logic.GetEntityType(_AttackedID) == Entities.PU_Hero11 then
        if Logic.GetEntityHealth(_AttackedID) > 0 then
            -- Reset limit
            local CurrentTurn = Logic.GetCurrentTurn();
            local UsedLast = self.Data[_PlayerID].Hero11.ShurikenTime;
            local UsageFrequency = self.Config.Hero11.ShurikenFrequency;
            if CurrentTurn - UsedLast >= UsageFrequency then
                self.Data[_PlayerID].Hero11.ShurikenAllowed = 1;
            end
            -- Throw shuriken
            if self.Data[_PlayerID].Hero11.ShurikenAllowed == 1 then
                local Task = Logic.GetCurrentTaskList(_AttackedID);
                local IsFighting = Task and string.find(Task, "_BATTLE") ~= nil;
                local IsSpecial = Task and string.find(Task, "_SPECIAL") ~= nil;
                local IsWalking = Task and string.find(Task, "_WALK") ~= nil;
                if IsFighting and not IsSpecial and not IsWalking then
                    local YukiPlayerID = Logic.EntityGetPlayer(_AttackedID);
                    local AttackerID = _AttackerID;
                    if Logic.IsEntityInCategory(AttackerID, EntityCategories.Soldier) == 1 then
                        AttackerID = SVLib.GetLeaderOfSoldier(AttackerID);
                    end
                    if Logic.IsSettler(AttackerID) == 1
                    and Logic.IsBuilding(AttackerID) == 0
                    and Logic.IsHero(AttackerID) == 0
                    and Logic.GetEntityHealth(AttackerID) > 0
                    and IsNear(_AttackedID, AttackerID, 3000) then
                        SendEvent.HeroShuriken(_AttackedID, AttackerID);
                        if GUI.GetPlayerID() == YukiPlayerID then
                            Sound.PlayFeedbackSound(Sounds.AOVoicesHero11_HERO11_Shuriken_rnd_01, 100);
                        end
                        self.Data[_PlayerID].Hero11.ShurikenTime = CurrentTurn;
                        self.Data[_PlayerID].Hero11.ShurikenAllowed = 0;
                    end
                end
            end
        end
    end
end

function Stronghold.Hero:VargWolvesController(_PlayerID)
    if IsPlayer(_PlayerID) then
        local WolvesBatteling = 0;
        local SummonWolves = GetLeadersOfType(_PlayerID, Entities.CU_Barbarian_Hero_wolf);
        for i= 2, SummonWolves[1] +1 do
            if IsFighting(SummonWolves[i]) then
                WolvesBatteling = WolvesBatteling +1;
            end
        end
        local Honor = self.Config.Hero9.WolfHonorRate * WolvesBatteling;
        Stronghold.Economy:AddOneTimeHonor(_PlayerID, Honor);
    end
end

-- -------------------------------------------------------------------------- --
-- Tower

function Stronghold.Hero:OverrideGuiPlaceBuilding()
    Overwrite.CreateOverwrite("GUIAction_PlaceBuilding", function(_UpgradeCategory)
        local PlayerID = GUI.GetPlayerID();
        -- Evil building replacer
        local Replacement = Stronghold.Hero.Config.DarkBuildingReplacements[_UpgradeCategory];
        if PlayerID ~= 17 and Replacement then
            if Stronghold.Hero:HasValidLordOfType(PlayerID, Entities.CU_BlackKnight)
            or Stronghold.Hero:HasValidLordOfType(PlayerID, Entities.CU_Evil_Queen) then
                GUIAction_PlaceBuilding(Replacement);
                return;
            end
        end
        Overwrite.CallOriginal();
    end);
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

function Stronghold.Hero:OverrideHero7AbilityMadness()
    GUIAction_Hero7Madness = function()
        local HeroID = HeroSelection_GetCurrentSelectedHeroID();
        GUI.SettlerInflictFear(HeroID);
        GUI.SettlerAffectUnitsInArea(HeroID);
    end
    Overwrite.CreateOverwrite("GUITooltip_NormalButton", function(_TextKey, _ShortCut)
        Overwrite.CallOriginal();
        if _TextKey == "MenuHero7/command_madness" then
            local Text = XGUIEng.GetStringTableText("sh_text/Skill_1_CU_BlackKnight");
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

function Stronghold.Hero:OverrideDetailsPayAndSlots()
    GUIUpdate_SelectionGeneric = function()
        XGUIEng.ShowAllSubWidgets("Details_Generic", 0);

        local EntityID = GUI.GetSelectedEntity();
        if EntityID == nil then
            return
        end

        local CurrentHealth = Logic.GetEntityHealth(EntityID);
        if CurrentHealth ~= nil then
            XGUIEng.ShowWidget("DetailsHealth", 1);
        end

        local Armor = Logic.GetEntityArmor(EntityID);
        if Armor ~= nil then
            XGUIEng.ShowWidget("DetailsArmor", 1);
        end

        local Damage = Logic.GetEntityDamage(EntityID);
        if Damage ~= nil and Damage ~= 0 then
            XGUIEng.ShowWidget("DetailsDamage", 1);
        end

        if  Logic.IsLeader(EntityID) == 1
        and Logic.IsEntityInCategory(EntityID, EntityCategories.Cannon) == 0
        and Logic.IsHero(EntityID) == 0 then
            if 	Logic.GetEntityType(EntityID) ~= Entities.CU_Barbarian_Hero_wolf
		    and	Logic.GetEntityType(EntityID) ~= Entities.PU_Hero5_Outlaw then
                XGUIEng.ShowWidget("DetailsExperience", 1);
            end
        end

        XGUIEng.ShowWidget("DetailsPayAndSlots", 1);
        XGUIEng.ShowWidget("DetailsSoldiers", 1);
    end

    GUIUpdate_DetailsSoldiers = function()
        local ID = GUI.GetSelectedEntity();
        local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(ID);
        local Soldiers = Logic.LeaderGetNumberOfSoldiers(ID);
        if Logic.IsLeader(ID) == 1 and MaxSoldiers > 0 then
            XGUIEng.ShowWidget("DetailsSoldiers", 1);
            local Text = "@ra " ..Soldiers.. "/" ..MaxSoldiers;
            XGUIEng.SetText("DetailsSoldiers_Amount", Text);
        else
            XGUIEng.ShowWidget("DetailsSoldiers", 0);
        end
    end

    GUIUpdate_DetailsSlots = function()
        local ID = GUI.GetSelectedEntity();
        local Type = Logic.GetEntityType(ID);
        if Logic.IsLeader(ID) == 1 and Type ~= Entities.CU_BlackKnight then
            local Upkeep = Logic.LeaderGetUpkeepCost(ID);
            XGUIEng.SetText("DetailsPayAndSlots_SlotAmount", "@ra " ..Upkeep);
            XGUIEng.ShowWidget("DetailsPayAndSlots", 1);
        else
            XGUIEng.ShowWidget("DetailsPayAndSlots", 0);
        end
    end

    GUIUpdate_GroupStrength = function()
        XGUIEng.ShowWidget("DetailsGroupStrength", 0);
    end
end

-- -------------------------------------------------------------------------- --
-- Passive Abilities

function Stronghold.Hero:OverrideCalculationCallbacks()
    -- Generic --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ResourceMined", function(_PlayerID, _BuildingID, _SourceID, _ResourceType, _Amount, _Remaining)
        local CurrentAmount, RemainingAmount = Overwrite.CallOriginal();
        CurrentAmount, ResourceRemaining = Stronghold.Hero:ResourceProductionBonus(_PlayerID, _BuildingID, _SourceID, _ResourceType, CurrentAmount, RemainingAmount);
        return CurrentAmount, ResourceRemaining;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_SerfExtraction", function(_PlayerID, _SerfID, _SourceID, _ResourceType, _Amount, _Remaining)
        local CurrentAmount, RemainingAmount = Overwrite.CallOriginal();
        CurrentAmount, ResourceRemaining = Stronghold.Hero:SerfExtractionBonus(_PlayerID, _SerfID, _SourceID, _ResourceType, CurrentAmount, RemainingAmount);
        return CurrentAmount, ResourceRemaining;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ResourceRefined", function(_PlayerID, _BuildingID, _ResourceType, Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ResourceRefiningBonus(_PlayerID, _BuildingID, _ResourceType, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_KnowledgeIncrease", function(_PlayerID, _Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyKnowledgePassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_GoodsTraded", function(_PlayerID, _BuildingID, _BuyType, _BuyAmount, _SellType, _SellAmount)
        Overwrite.CallOriginal();
        Stronghold.Hero:ApplyTradePassiveAbility(_PlayerID, _BuildingID, _BuyType, _BuyAmount, _SellType, _SellAmount);
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MinimalConstructionDistance", function(_PlayerID, _UpgradeCategory, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyTowerDistancePassiveAbility(_PlayerID, _UpgradeCategory, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_BattleDamage", function(_AttackerID, _AttackedID, _Damage)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyCalculateBattleDamage(_AttackerID, _AttackedID, _Damage);
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

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_DynamicReputationIncrease", function(_PlayerID, _Type, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyDynamicReputationBonusPassiveAbility(_PlayerID, _Type, CurrentAmount);
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

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_DynamicHonorIncrease", function(_PlayerID, _Type, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyDynamicHonorBonusPassiveAbility(_PlayerID, _Type, CurrentAmount);
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

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_SlaveAttrationLimit", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMaxSlaveAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_SlaveAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplySlaveAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    -- Social --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_InfluenceIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyInfluencePointsPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_CrimeRate", function(_PlayerID, _Rate)
        local CrimeRate = Overwrite.CallOriginal();
        CrimeRate = Stronghold.Hero:ApplyCrimeRatePassiveAbility(_PlayerID, CrimeRate);
        return CrimeRate;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_HonorFromSermon", function(_PlayerID, _BlessCategory, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyHonorSermonPassiveAbility(_PlayerID, _BlessCategory, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ReputationFromSermon", function(_PlayerID, _BlessCategory, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyReputationSermonPassiveAbility(_PlayerID, _BlessCategory, CurrentAmount);
        return CurrentAmount;
    end);
end

function Stronghold.Hero:HasValidLordOfType(_PlayerID, _Type)
    if IsPlayer(_PlayerID) then
        local LordID = GetNobleID(_PlayerID);
        if self:IsValidHero(LordID, _Type) then
            return true;
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
    for i= table.getn(HeroList), 1, -1 do
        local Type = Logic.GetEntityType(HeroList[i]);
        if Stronghold.Populace.Config.FakeHeroTypes[Type] then
            table.remove(HeroList, i);
        end
    end
    return HeroList;
end

-- Passive Ability: Resource production bonus
function Stronghold.Hero:ResourceProductionBonus(_PlayerID, _BuildingID, _SourceID, _Type, _Amount, _Remaining)
    local ResourceRemaining = _Remaining
    local Amount = _Amount;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero2) then
        if _Type == ResourceType.ClayRaw
        or _Type == ResourceType.IronRaw
        or _Type == ResourceType.StoneRaw
        or _Type == ResourceType.SulfurRaw
        then
            Amount = Amount + self.Config.Hero2.MinerExtractionBonus;
        end
    end
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero5) then
        if math.random(1,100) <= self.Config.Hero5.MinerMineralChance then
            ResourceRemaining = ResourceRemaining + math.max(Amount -1, 1);
        end
    end
    return Amount, ResourceRemaining;
end

-- Passive Ability: Serf extraction bonus
function Stronghold.Hero:SerfExtractionBonus(_PlayerID, _SerfID, _SourceID, _Type, _Amount, _Remaining)
    local ResourceRemaining = _Remaining
    local Amount = _Amount;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero5) then
        if _Type ~= ResourceType.WoodRaw then
            if math.random(1,100) <= self.Config.Hero5.SerfMineralChance then
                ResourceRemaining = ResourceRemaining + math.max(Amount -1, 1);
            end
        else
            -- This has the same effect as the previous implementation were as
            -- long as the tree was half full the amount of wood was restored
            -- without the downside of trees blocking building places longer.
            Logic.AddToPlayersGlobalResource(_PlayerID, _Type, self.Config.Hero5.SerfWoodBonus);
        end
    end
    return Amount, ResourceRemaining;
end

-- Passive Ability: Resource refining bonus
function Stronghold.Hero:ResourceRefiningBonus(_PlayerID, _BuildingID, _Type, _Amount)
    local Amount = _Amount;
    local BuildingType = Logic.GetEntityType(_BuildingID);
    local TypeName = Logic.GetEntityTypeName(BuildingType);
    if  self:HasValidLordOfType(_PlayerID, Entities.PU_Hero10)
    and string.find(TypeName, "PB_GunsmithWorkshop") then
        if _Type == ResourceType.Sulfur then
            Amount = Amount + Stronghold.Hero.Config.Hero10.RefiningBonus;
        end
    end
    return Amount;
end

-- Passive Ability: soldier costs
function Stronghold.Hero:ApplySoldierCostPassiveAbility(_PlayerID, _LeaderType, _Costs)
    local Costs = _Costs;
    -- Do nothing
    return Costs;
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
        Value = Value * self.Config.Hero12.PopulationFactor;
    end
    return Value;
end

-- Passive Ability: Increase of max serf attraction
function Stronghold.Hero:ApplyMaxSlaveAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidLordOfType(_PlayerID, Entities.CU_Mary_de_Mortfichet) then
        Value = Value + (self.Config.Hero8.BonusSlaves * GetRank(_PlayerID));
    end
    return Value;
end

-- Passive Ability: Change serf places usage
function Stronghold.Hero:ApplySlaveAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    -- Do nothing
    return Value;
end

-- Passive Ability: Change used space of specific unit type
function Stronghold.Hero:ApplyUnitAttractionPassiveAbility(_PlayerID, _Type, _Value)
    local Value = _Value;
    -- Cavalry malus (Salim, Ari)
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero3)
    or self:HasValidLordOfType(_PlayerID, Entities.PU_Hero5) then
        if _Type == Entities.CU_TemplarLeaderHeavyCavalry1
        or _Type == Entities.PU_LeaderHeavyCavalry1
        or _Type == Entities.PU_LeaderHeavyCavalry2 then
            Value = Value + 1;
        end
    end
    -- Sharpshooter malus (Erec, Helias, Varg, Kala)
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero4)
    or self:HasValidLordOfType(_PlayerID, Entities.PU_Hero6)
    or self:HasValidLordOfType(_PlayerID, Entities.CU_Barbarian_Hero)
    or self:HasValidLordOfType(_PlayerID, Entities.CU_Evil_Queen) then
        -- Triple honor costs of riflemen
        if _Type == Entities.PU_LeaderRifle1
        or _Type == Entities.PU_LeaderRifle2 then
            Value = Value + 1;
        end
    end
    -- Cannon bonus (Salim)
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero3) then
        if _Type == Entities.CV_Cannon1
        or _Type == Entities.CV_Cannon2
        or _Type == Entities.PV_Cannon1
        or _Type == Entities.PV_Cannon2
        or _Type == Entities.PV_Cannon3
        or _Type == Entities.PV_Cannon4
        or _Type == Entities.PV_Cannon7
        or _Type == Entities.PV_Cannon8 then
            Value = Value - self.Config.Hero3.CannonPlaceReduction;
        end
    end
    return Value;
end

-- Passive Ability: Increase of max military attraction
function Stronghold.Hero:ApplyMaxMilitaryAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidLordOfType(_PlayerID, "^PU_Hero1[abc]+$") then
        Value = Value * self.Config.Hero1.MilitaryFactor;
    end
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
function Stronghold.Hero:ApplyDynamicReputationBonusPassiveAbility(_PlayerID, _Type, _Amount)
    local Value = _Amount;
    if self:HasValidLordOfType(_PlayerID, Entities.CU_Barbarian_Hero) then
        if _Type == Entities.PB_Tavern1 or _Type == Entities.PB_Tavern2 then
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
function Stronghold.Hero:ApplyDynamicHonorBonusPassiveAbility(_PlayerID, _Type, _Amount)
    local Value = _Amount;
    if self:HasValidLordOfType(_PlayerID, Entities.CU_Barbarian_Hero) then
        if _Type == Entities.PB_Tavern1 or _Type == Entities.PB_Tavern2 then
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
        if _Type == Entities.PU_Scout or _Type == Entities.PU_Thief then
            Upkeep = Upkeep * self.Config.Hero8.UpkeepFactor;
        end
    end
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero10) then
        if _Type == Entities.PU_LeaderRifle1 or _Type == Entities.PU_LeaderRifle2 then
            Upkeep = Upkeep * self.Config.Hero10.UpkeepFactor;
        end
    end
    return Upkeep;
end

-- Passive Ability: Generating influence points
function Stronghold.Hero:ApplyInfluencePointsPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidLordOfType(_PlayerID, "^PU_Hero1[abc]+$") then
        Value = Value * self.Config.Hero1.InfluenceFactor;
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

-- Passive Ability: Generating knowledge points
function Stronghold.Hero:ApplyKnowledgePassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero3) then
        Value = Value * self.Config.Hero3.KnowledgeFactor;
    end
    return Value;
end

-- Passive Ability: Bonus resources on trade
function Stronghold.Hero:ApplyTradePassiveAbility(_PlayerID, _BuildingID, _BuyType, _BuyAmount, _SellType, _SellAmount)
    local GuiPlayer = GUI.GetPlayerID();
    local Bonus = 0;
    local ResourceName = GetResourceName(_BuyType);
    local Text = XGUIEng.GetStringTableText("SH_Text/GUI_TradeBonus");
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero11) then
        Bonus = math.ceil(_BuyAmount * self.Config.Hero11.TradeBonusFactor);
    end
    if Bonus > 0 then
        Logic.AddToPlayersGlobalResource(_PlayerID, _BuyType, Bonus);
        if GuiPlayer == _PlayerID then
            Message(string.format(Text, Bonus, ResourceName));
        end
    end
end

-- Passive Ability: Bonus honor for sermons
function Stronghold.Hero:ApplyHonorSermonPassiveAbility(_PlayerID, _BlessCategory, _Amount)
    local Amount = _Amount;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero6) then
        Amount = Amount + self.Config.Hero6.SermonHonorBonus;
    end
    return Amount;
end

-- Passive Ability: Bonus reputation for sermons
function Stronghold.Hero:ApplyReputationSermonPassiveAbility(_PlayerID, _BlessCategory, _Amount)
    local Amount = _Amount;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero6) then
        Amount = Amount + self.Config.Hero6.SermonReputationBonus;
    end
    return Amount;
end

-- Passive Ability: Soft tower limit
function Stronghold.Hero:ApplyTowerDistancePassiveAbility(_PlayerID, _UpgradeCategory, _Amount)
    local Amount = _Amount;
    if self.Config.TowerPlacementDistanceCheck[_UpgradeCategory] then
        if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero2) then
            Amount = self.Config.Hero2.TowerDistance;
        end
    end
    return Amount;
end

-- Passive Ability: Battle damage
function Stronghold.Hero:ApplyCalculateBattleDamage(_AttackerID, _AttackedID, _Damage)
    local PlayerID = Logic.EntityGetPlayer(_AttackerID);
    local Amount = _Damage;
    -- Nothing to do
    return Amount;
end

function Stronghold.Hero:ApplyExperiencePassiveAbility(_PlayerID, _EntityID, _Amount)
    local Amount = 0;
    if self:HasValidLordOfType(_PlayerID, Entities.PU_Hero4) then
        if  Logic.IsEntityInCategory(_EntityID, EntityCategories.Cannon) == 0
        and Logic.IsEntityInCategory(_EntityID, EntityCategories.Scout) == 0
        and Logic.IsEntityInCategory(_EntityID, EntityCategories.Thief) == 0 then
            Amount = self.Config.Hero4.TrainExperience;
        end
    end
    return Amount;
end

