--- 
--- Hero Script
---
--- This script implements all processes around the hero.
---
--- Managed by the script:
--- - Stats of hero
--- - Stats of summons
--- - Selection of hero
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
function PlayerCreateNoble(_PlayerID, _Type, _Position)
    Stronghold.Hero:BuyHeroCreateNoble(_PlayerID, _Type, _Position);
end

--- Returns if the player has the type as hero.
function PlayerHasHeroOfType(_PlayerID, _Type)
    return Stronghold.Hero:HasValidHeroOfType(_PlayerID, _Type);
end

-- -------------------------------------------------------------------------- --

function Stronghold.Hero:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {};
    end

    self:ConfigureBuyHero();
    self:OverrideCalculationCallbacks();
    self:OverrideHero5AbilityArrowRain();
    self:OverrideHero8AbilityMoralDamage();
end

function Stronghold.Hero:OnSaveGameLoaded()
    for i= 1, table.getn(Score.Player) do
        local Wolves = {Logic.GetPlayerEntities(i, Entities.CU_Barbarian_Hero_wolf, 48)};
        for j=2, Wolves[1] +1 do
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
    self.Text.Hero.Name[_Type] = Text;
end

function Stronghold.Hero:SetHeroBiography(_Type, _Text)
    local Text = _Text;
    if type(Text) ~= "table" then
        Text = {de = _Text, en = _Text};
    end
    self.Text.Hero.Biography[_Type] = Text;
end

function Stronghold.Hero:SetHeroDescription(_Type, _Text)
    local Text = _Text;
    if type(Text) ~= "table" then
        Text = {de = _Text, en = _Text};
    end
    self.Text.Hero.Description[_Type] = Text;
end

-- -------------------------------------------------------------------------- --
-- Hero Selection

function Stronghold.Hero:OnSelectLeader(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if not Stronghold:IsPlayer(PlayerID) or Logic.IsLeader(_EntityID) == 0 then
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
    if not Stronghold:IsPlayer(PlayerID) or Logic.IsHero(_EntityID) == 0 then
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
    if Stronghold:IsPlayer(PlayerID) then
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
        if Stronghold:IsPlayer(_PlayerID) then
            Stronghold.Hero:BuyHeroSetupNoble(_PlayerID, _ID, _Type);
            Stronghold.Hero:PlayFunnyComment(_PlayerID);
            Stronghold.Hero:InitSpecialUnits(_PlayerID, _Type);
            return;
        end
        return Overwrite.CallOriginal();
    end);

    Overwrite.CreateOverwrite("GameCallback_GUI_BuyHero_GetHeadline", function(_PlayerID)
        if Stronghold:IsPlayer(_PlayerID) then
            local LordID = GetID(Stronghold.Players[_PlayerID].LordScriptName);
            local Caption = (LordID ~= 0 and "Alea Iacta Est!") or "Wählt Euren Adligen!";
            return Caption;
        end
        return Overwrite.CallOriginal();
    end);

    Overwrite.CreateOverwrite("GameCallback_GUI_BuyHero_GetMessage", function(_PlayerID, _Type)
        if Stronghold:IsPlayer(_PlayerID) then
            local Lang = GetLanguage();
            local DisplayName = Stronghold.Hero.Text.Hero.Names[_Type][Lang];
            local Biography = Stronghold.Hero.Text.Hero.Biography[_Type][Lang];
            local Description = Stronghold.Hero.Text.Hero.Description[_Type][Lang];
            return string.format(
                "%s @cr @cr @color:180,180,180 %s @cr @cr %s",
                DisplayName,
                Biography,
                Description
            );
        end
        return Overwrite.CallOriginal();
    end);
end

function Stronghold.Hero:BuyHeroCreateNoble(_PlayerID, _Type, _Position)
    if Stronghold:IsPlayer(_PlayerID) then
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
    if Stronghold:IsPlayer(_PlayerID) then
        -- Get motivation cap
        local ExpectedSoftCap = 2;
        local CurrentSoftCap = CUtil.GetPlayersMotivationSoftcap(_PlayerID);
        -- Set name of lord
        Logic.SetEntityName(_ID, Stronghold.Players[_PlayerID].LordScriptName);
        -- Display info message
        if not _Silent then
            local Language = GetLanguage();
            local PlayerName = UserTool_GetPlayerName(_PlayerID);
            local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
            Message(string.format(self.Text.Player[1][Language], PlayerColor, PlayerName));
        end

        if _Type == Entities.PU_Hero11 then
            -- Update motivation soft cap
            ExpectedSoftCap = 3;
            -- Give motivation for Yuki
            Stronghold:UpdateMotivationOfPlayersWorkers(_PlayerID, 50);
            Stronghold:AddPlayerReputation(_PlayerID, 100);
        end
        if _Type == Entities.CU_BlackKnight then
            -- Update motivation soft cap
            ExpectedSoftCap = 1.75;
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
function Stronghold.Hero:ConfigurePlayersHeroPet(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_Barbarian_Hero_wolf then
        if self:HasValidHeroOfType(PlayerID, Entities.CU_Barbarian_Hero) then
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
-- (Yes, it is intended that every player hears them.)
function Stronghold.Hero:PlayFunnyComment(_PlayerID)
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
    Sound.PlayQueuedFeedbackSound(FunnyComment, 127);
end

function Stronghold.Hero:InitSpecialUnits(_PlayerID, _Type)
    Stronghold.Recruitment:InitDefaultRoster(_PlayerID);

    local ThiefRecruiter = {Entities.PB_Tavern2};
    if string.find(Logic.GetEntityTypeName(_Type), "PU_Hero1") then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword2"] = Entities.PU_LeaderPoleArm4;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.PU_LeaderSword4;
    elseif _Type == Entities.PU_Hero2 then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow2"] = Entities.PU_LeaderBow2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow3"] = Entities.PU_LeaderBow3;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeRifle1"] = Entities.PU_LeaderRifle1;
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
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword2"] = Entities.CU_BlackKnight_LeaderMace2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.CU_BlackKnight_LeaderMace1;
    elseif _Type == Entities.CU_Mary_de_Mortfichet then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow3"] = Entities.PU_LeaderBow4;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeRifle1"] = Entities.PU_LeaderRifle1;
        ResearchTechnology(Technologies.T_ThiefSabotage, _PlayerID);
        ThiefRecruiter = {Entities.PB_Tavern1, Entities.PB_Tavern2};
    elseif _Type == Entities.CU_Barbarian_Hero then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword2"] = Entities.CU_Barbarian_LeaderClub2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.CU_Barbarian_LeaderClub1;
    elseif _Type == Entities.CU_Evil_Queen then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword1"] = Entities.PU_LeaderPoleArm1;
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
    if Stronghold:IsPlayer(_PlayerID) then
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
                    local Language = GetLanguage();
                    local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(k));
                    local Name = XGUIEng.GetStringTableText("Names/" ..TypeName);
                    Message(string.format(self.Text.Player[2][Language], PlayerColor, Name));
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
    if Stronghold:IsPlayer(_PlayerID) then
        for k,v in pairs(Stronghold.Players[_PlayerID].AttackMemory) do
            if Logic.GetEntityType(k) == Entities.PU_Hero6 then
                local HeliasPlayerID = Logic.EntityGetPlayer(k);
                local AttackerID = v[2];
                if Logic.IsEntityInCategory(AttackerID, EntityCategories.Soldier) == 1 then
                    AttackerID = SVLib.GetLeaderOfSoldier(AttackerID);
                end
                if not self.Data.ConvertBlacklist[AttackerID] then
                    if Logic.GetEntityHealth(AttackerID) > 0 and Logic.IsHero(AttackerID) == 0 then
                        if math.random(1, 1000) <= 3 and GetDistance(AttackerID, k) <= 1000 then
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

function Stronghold.Hero:VargWolvesController(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        local WolvesBatteling = 0;
        for k,v in pairs(GetPlayerEntities(_PlayerID, Entities.CU_Barbarian_Hero_wolf)) do
            local Task = Logic.GetCurrentTaskList(v);
            if Task and string.find(Task, "BATTLE") then
                WolvesBatteling = WolvesBatteling +1;
            end
        end
        Stronghold.Economy:AddOneTimeHonor(_PlayerID, 0.05 * WolvesBatteling);
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
            local Language = GetLanguage();
            local Text = Stronghold.Hero.Text.Hero.Skill[Entities.PU_Hero5][Language];
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
            local Language = GetLanguage();
            local Text = Stronghold.Hero.Text.Hero.Skill[Entities.CU_Mary_de_Mortfichet][Language];
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
    Overwrite.CreateOverwrite("GameCallback_GainedResources", function(_PlayerID, _ResourceType, _Amount)
        Overwrite.CallOriginal();
        if Stronghold:IsPlayer(_PlayerID) then
            Stronghold.Hero:ResourceProductionBonus(_PlayerID, _ResourceType, _Amount);
        end
    end);

    -- Noble --

    Overwrite.CreateOverwrite("GameCallback_Calculate_ReputationMax", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMaxReputationPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_ReputationIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyReputationIncreasePassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_DynamicReputationIncrease", function(_PlayerID, _BuildingID, _WorkerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyDynamicReputationBonusPassiveAbility(_PlayerID, _BuildingID, _WorkerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_ReputationDecrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyReputationDecreasePassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_HonorIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyHonorBonusPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_DynamicHonorIncrease", function(_PlayerID, _BuildingID, _WorkerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyDynamicHonorBonusPassiveAbility(_PlayerID, _BuildingID, _WorkerID, CurrentAmount);
        return CurrentAmount;
    end);

    -- Money --

    Overwrite.CreateOverwrite("GameCallback_Calculate_TotalPaydayIncome", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyIncomeBonusPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_TotalPaydayUpkeep", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyUpkeepDiscountPassiveAbility(_PlayerID, _CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_PaydayUpkeep", function(_PlayerID, _UnitType, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyUnitUpkeepDiscountPassiveAbility(_PlayerID, _UnitType, CurrentAmount)
        return CurrentAmount;
    end);

    -- Attraction --

    Overwrite.CreateOverwrite("GameCallback_Calculate_CivilAttrationLimit", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMaxCivilAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_CivilAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyCivilAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_MilitaryAttrationLimit", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMaxMilitaryAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_MilitaryAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMilitaryAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    -- Social --

    Overwrite.CreateOverwrite("GameCallback_Calculate_MeasureIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMeasurePointsPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_CrimeRate", function(_PlayerID, _Rate)
        local CrimeRate = Overwrite.CallOriginal();
        CrimeRate = Stronghold.Hero:ApplyCrimeRatePassiveAbility(_PlayerID, CrimeRate);
        return CrimeRate;
    end);
end

function Stronghold.Hero:HasValidHeroOfType(_PlayerID, _Type)
    if Stronghold:IsPlayer(_PlayerID) then
        local LordID = GetID(Stronghold.Players[_PlayerID].LordScriptName);
        if IsEntityValid(LordID) then
            local HeroType = Logic.GetEntityType(LordID);
            local TypeName = Logic.GetEntityTypeName(HeroType);
            if type(_Type) == "string" and TypeName and string.find(TypeName, _Type) then
                return true;
            elseif type(_Type) == "number" and HeroType == _Type then
                return true;
            end
        end
    end
    return false;
end

-- Passive Ability: Resource production bonus
-- (Callback is only called for main resource types)
-- TODO: Replace this with server functions?
function Stronghold.Hero:ResourceProductionBonus(_PlayerID, _Type, _Amount)
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero2) then
        if _Amount >= 4 then
            if _Type == ResourceType.SulfurRaw
            or _Type == ResourceType.ClayRaw
            or _Type == ResourceType.StoneRaw
            or _Type == ResourceType.IronRaw then
                -- TODO: Maybe use the non-raw here?
                Logic.AddToPlayersGlobalResource(_PlayerID, _Type, math.max(_Amount-3, 1));
            end
        end
    end
end

-- Passive Ability: leader costs
function Stronghold.Hero:ApplyLeaderCostPassiveAbility(_PlayerID, _Type, _Costs)
    local Costs = _Costs;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero4) then
        local IsCannon = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Cannon) == 1
        local IsScout = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Scout) == 1
        local IsThief = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Thief) == 1
        if not IsCannon and not IsScout and not IsThief then
            if Costs[ResourceType.Gold] then
                Costs[ResourceType.Gold] = math.ceil(Costs[ResourceType.Gold] * 1.5);
            end
            if Costs[ResourceType.Clay] then
                Costs[ResourceType.Clay] = math.ceil(Costs[ResourceType.Clay] * 1.5);
            end
            if Costs[ResourceType.Wood] then
                Costs[ResourceType.Wood] = math.ceil(Costs[ResourceType.Wood] * 1.5);
            end
            if Costs[ResourceType.Stone] then
                Costs[ResourceType.Stone] = math.ceil(Costs[ResourceType.Stone] * 1.5);
            end
            if Costs[ResourceType.Iron] then
                Costs[ResourceType.Iron] = math.ceil(Costs[ResourceType.Iron] * 1.5);
            end
            if Costs[ResourceType.Sulfur] then
                Costs[ResourceType.Sulfur] = math.ceil(Costs[ResourceType.Sulfur] * 1.5);
            end
        end
    end
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero3) then
        if Logic.IsEntityTypeInCategory(_Type, EntityCategories.Cannon) == 1 then
            Costs[ResourceType.Honor] = nil;
            Costs[ResourceType.Gold] = math.ceil(Costs[ResourceType.Gold] * 0.9);
            Costs[ResourceType.Wood] = math.ceil(Costs[ResourceType.Wood] * 0.9);
            Costs[ResourceType.Iron] = math.ceil(Costs[ResourceType.Iron] * 0.9);
            Costs[ResourceType.Sulfur] = math.ceil(Costs[ResourceType.Sulfur] * 0.9);
        end
    end
    return Costs;
end

-- Passive Ability: soldier costs
function Stronghold.Hero:ApplySoldierCostPassiveAbility(_PlayerID, _LeaderType, _Costs)
    local Costs = _Costs;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero11) then
        if Costs[ResourceType.Gold] then
            Costs[ResourceType.Gold] = math.ceil(Costs[ResourceType.Gold] * 0.9);
        end
        if Costs[ResourceType.Clay] then
            Costs[ResourceType.Clay] = math.ceil(Costs[ResourceType.Clay] * 0.9);
        end
        if Costs[ResourceType.Wood] then
            Costs[ResourceType.Wood] = math.ceil(Costs[ResourceType.Wood] * 0.9);
        end
        if Costs[ResourceType.Stone] then
            Costs[ResourceType.Stone] = math.ceil(Costs[ResourceType.Stone] * 0.9);
        end
        if Costs[ResourceType.Iron] then
            Costs[ResourceType.Iron] = math.ceil(Costs[ResourceType.Iron] * 0.9);
        end
        if Costs[ResourceType.Sulfur] then
            Costs[ResourceType.Sulfur] = math.ceil(Costs[ResourceType.Sulfur] * 0.9);
        end
    end
    return Costs;
end

function Stronghold.Hero:ApplyRecruitTimePassiveAbility(_PlayerID, _LeaderType, _Value)
    local Value = _Value;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero10) then
        if Logic.IsEntityTypeInCategory(_LeaderType, EntityCategories.Rifle) == 1 then
            Value = Value * 0.5;
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
    if self:HasValidHeroOfType(_PlayerID, Entities.CU_Evil_Queen) then
        Value = Value * 1.25;
    end
    return Value;
end

-- Passive Ability: Change millitary places usage
function Stronghold.Hero:ApplyMilitaryAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if Stronghold.Hero:HasValidHeroOfType(_PlayerID, Entities.CU_Mary_de_Mortfichet) then
        local ThiefCount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Thief);
        Value = Value - (ThiefCount * 3);
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
    if self:HasValidHeroOfType(_PlayerID, Entities.CU_BlackKnight) then
        Value = 175;
    elseif self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero11) then
        Value = 300;
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
    if self:HasValidHeroOfType(_PlayerID, Entities.CU_BlackKnight) then
        Decrease = Decrease * 0.6;
    end
    return Decrease;
end

-- Passive Ability: Improve dynamic reputation generation
function Stronghold.Hero:ApplyDynamicReputationBonusPassiveAbility(_PlayerID, _BuildingID, _WorkerID, _Amount)
    local Value = _Amount;
    if self:HasValidHeroOfType(_PlayerID, Entities.CU_Barbarian_Hero) then
        local Type = Logic.GetEntityType(_BuildingID);
        if Type == Entities.PB_Tavern1 or Type == Entities.PB_Tavern2 then
            Value = Value * 2;
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
    if self:HasValidHeroOfType(_PlayerID, Entities.CU_Barbarian_Hero) then
        local Type = Logic.GetEntityType(_BuildingID);
        if Type == Entities.PB_Tavern1 or Type == Entities.PB_Tavern2 then
            Value = Value * 2;
        end
    end
    return Value;
end

-- Passive Ability: Tax income bonus
function Stronghold.Hero:ApplyIncomeBonusPassiveAbility(_PlayerID, _Income)
    local Income = _Income;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero5) then
        Income = Income * 1.3;
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
    -- if self:HasValidHeroOfType(_PlayerID, Entities.CU_Mary_de_Mortfichet) then
    --     if _Type == Entities.PU_Scout or _Type == Entities.PU_Thief then
    --         Upkeep = 0;
    --     end
    -- end
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero10) then
        if _Type == Entities.PU_LeaderRifle1 or _Type == Entities.PU_LeaderRifle2 then
            Upkeep = Upkeep * 0.7;
        end
    end
    return Upkeep;
end

-- Passive Ability: Generating measure points
function Stronghold.Hero:ApplyMeasurePointsPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidHeroOfType(_PlayerID, "^PU_Hero1[abc]+$") then
        Value = Value * 2.0;
    end
    return Value;
end

-- Passive Ability: Change factor of becoming a criminal
function Stronghold.Hero:ApplyCrimeRatePassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero6) then
        Value = Value * 0.25;
    end
    return Value;
end

-- Passive Ability: Chance the chance of becoming a criminal
function Stronghold.Hero:ApplyCrimeChancePassiveAbility(_PlayerID, _Chance)
    local Value = _Chance;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero6) then
        Value = Value * 0.75;
    end
    return Value;
end

