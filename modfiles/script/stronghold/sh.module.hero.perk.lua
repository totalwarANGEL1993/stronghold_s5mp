--- 
--- Hero Script
---
--- This script implements all processes around the hero.
--- 

Stronghold = Stronghold or {};
Stronghold.Hero = Stronghold.Hero or {};

Stronghold.Hero.Perk = {
    Data = {
        ConvertBlacklist = {},
        ScoutBombs = {},
    },
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- API

function HasPlayerUnlockedPerk(_PlayerID, _Perk)
    return Stronghold.Hero.Perk:HasPlayerUnlockedPerk(_PlayerID, _Perk);
end

function UnlockPerkForPlayer(_PlayerID, _Perk)
    Stronghold.Hero.Perk:UnlockPerkForPlayer(_PlayerID, _Perk)
end

-- -------------------------------------------------------------------------- --
-- Game Callback

function GameCallback_SH_Logic_OnPerkUnlocked(_PlayerID, _Perk)
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Hero.Perk:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            UnlockedPerks = {},
            LastTaxLevel = 4,
            NobleKillerEntityID = 0,
            BuyPerkLock = false,
            -- GUI
            PerkAssignmentList = {},
            PerkOpenList = {},
            PerkClosedLookup = {},
        };
    end
    self:CreateBuildingButtonHandlers();
    self:OverwriteGameCallbacks();
    self:OwerwriteAdditionalGameCallbacks();
end

function Stronghold.Hero.Perk:OnSaveGameLoaded()
end

function Stronghold.Hero.Perk:CreateBuildingButtonHandlers()
    self.SyncEvents = {
        SelectPerk = 1,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Hero.Perk.SyncEvents.SelectPerk then
                Stronghold.Hero.Perk:OnPerkSelected(_PlayerID, arg[1], arg[2]);
            end
        end
    );
end

function Stronghold.Hero.Perk:OnEntityCreated(_EntityID)
    -- Experience
    if Logic.IsSettler(_EntityID) == 1 then
        local Amount = CEntity.GetLeaderExperience(_EntityID) or 0;
        local PlayerID = Logic.EntityGetPlayer(_EntityID);
        Amount = self:ApplyExperiencePassiveAbility(PlayerID, _EntityID, Amount);
        CEntity.SetLeaderExperience(_EntityID, Amount);
    end
    -- Track Scout bombs
    if Logic.GetEntityType(_EntityID) == Entities.XD_Bomb1 then
        local PlayerID = Logic.EntityGetPlayer(_EntityID);
        if IsPlayer(PlayerID) then
            local x, y, z = Logic.EntityGetPos(_EntityID);
            self.Data.ScoutBombs[_EntityID] = {Logic.GetCurrentTurn(), x, y};
        end
    end
    -- Pit amount
    local Amount = Logic.GetResourceDoodadGoodAmount(_EntityID);
    if Amount > 0 then
        Amount = self:ApplyMineAmountPassiveAbility(_EntityID, Amount);
        Logic.SetResourceDoodadGoodAmount(_EntityID, math.ceil(Amount));
    end
end

function Stronghold.Hero.Perk:OnEntityDestroyed(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    self:ApplyRefundUnitPassiveAbility(PlayerID, _EntityID);
end

function Stronghold.Hero.Perk:OncePerSecond(_PlayerID)
    -- Endurance regeneration
    self:ApplyEnduranceRegenerationPassiveAbility(_PlayerID);
end

-- -------------------------------------------------------------------------- --
-- GUI

function Stronghold.Hero.Perk:PerkWindowOnShow()
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = GetLocalPlayerID();
    if GuiPlayer == 17
    or GuiPlayer ~= PlayerID
    or not IsPlayer(PlayerID) then
        return;
    end
    XGUIEng.ShowWidget("HeroPerkWindow", 1);
    XGUIEng.ShowAllSubWidgets("HeroPerkInitialPerksRow", 1);
    XGUIEng.ShowAllSubWidgets("HeroPerkTier1PerksRow", 1);
    XGUIEng.ShowAllSubWidgets("HeroPerkTier2PerksRow", 1);
    XGUIEng.ShowAllSubWidgets("HeroPerkTier3PerksRow", 1);
end

function Stronghold.Hero.Perk:PerkWindowUnlockPerkAction(_RowID, _ColumnID)
    local GuiPlayer = GUI.GetPlayerID();
    local PlayerID = GetLocalPlayerID();
    if _RowID == 1
    or GuiPlayer == 17
    or GuiPlayer ~= PlayerID
    or not IsPlayer(PlayerID) then
        return;
    end

    local PerkID = self.Data[PlayerID].PerkAssignmentList[_RowID][_ColumnID];
    if PerkID then
        local PerkConfig = self.Config:GetPerkConfig(PerkID);
        assert(PerkConfig ~= nil);
        if  not self:HasPlayerUnlockedPerk(PlayerID, PerkID)
        and not self.Data[PlayerID].PerkClosedLookup[PerkID]
        and PerkConfig.Data.RequiredRank <= GetRank(PlayerID) then
            -- Send event
            Syncer.InvokeEvent(
                Stronghold.Hero.Perk.NetworkCall,
                Stronghold.Hero.Perk.SyncEvents.SelectPerk,
                _RowID,
                PerkID
            );
            -- Lock selection for 1 second in Multiplayer
            if XNetwork.Manager_DoesExist() == 1 then
                self.Data[PlayerID].BuyPerkLock = true;
                Job.Turn(function(_PlayerID, _StartTurn)
                    if _StartTurn + 10 < Logic.GetCurrentTurn() then
                        Stronghold.Hero.Perk.Data[_PlayerID].BuyPerkLock = false;
                        return true;
                    end
                end, PlayerID, Logic.GetCurrentTurn());
            end
        end
    end
end

function Stronghold.Hero.Perk:PerkWindowUnlockPerkTooltip(_RowID, _ColumnID)
    local PlayerID = GetLocalPlayerID();
    local WidgetID = XGUIEng.GetCurrentWidgetID();
    if not IsPlayer(PlayerID) then
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "");
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return;
    end

    local PerkID = self.Data[PlayerID].PerkAssignmentList[_RowID][_ColumnID];
    local TooltipText = "";
    if PerkID then
        local PerkConfig = self.Config:GetPerkConfig(PerkID);
        assert(PerkConfig ~= nil);
        TooltipText = XGUIEng.GetStringTableText(PerkConfig.Text);
        if PerkConfig.Data.RequiredRank > GetRank(PlayerID) then
            TooltipText = XGUIEng.GetStringTableText("sh_windowperks/unknown");
        end
    end
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Placeholder.Replace(TooltipText));
    XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
end

function Stronghold.Hero.Perk:PerkWindowUnlockPerkUpdate(_RowID, _ColumnID)
    local PlayerID = GetLocalPlayerID();
    local WidgetID = XGUIEng.GetCurrentWidgetID();
    if not IsPlayer(PlayerID) then
        XGUIEng.TransferMaterials("HeroPerkMiscButtonSource1", WidgetID);
        XGUIEng.DisableButton(WidgetID, 0);
        XGUIEng.HighLightButton(WidgetID, 0);
        return;
    end

    local ButtonDisabled = 0;
    local ButtonHighlighted = 0;
    local ButtonVisible = 1;
    local IconTexture = "HeroPerkMiscButtonSource1";
    local PerkID = self.Data[PlayerID].PerkAssignmentList[_RowID][_ColumnID];
    if PerkID then
        if _RowID > 1 then
            local PerkConfig = self.Config:GetPerkConfig(PerkID);
            assert(PerkConfig ~= nil);
            if PerkConfig.Data.RequiredRank > GetRank(PlayerID) then
                IconTexture = "HeroPerkMiscButtonSource2";
                ButtonDisabled = 1;
            elseif self.Data[PlayerID].PerkClosedLookup[PerkID] then
                IconTexture = PerkConfig.Icon;
                ButtonDisabled = 1;
            elseif self:HasPlayerUnlockedPerk(PlayerID, PerkID) then
                IconTexture = PerkConfig.Icon;
                ButtonHighlighted = 1;
            else
                IconTexture = PerkConfig.Icon;
            end
            if self.Data[PlayerID].BuyPerkLock then
                ButtonDisabled = 1;
                ButtonHighlighted = 0;
            end
        else
            local Width = 370;
            local ButtonWith = 32 + 6;
            local Size = math.min(table.getn(self.Data[PlayerID].PerkAssignmentList[_RowID]), 10);
            local XHalf = math.max((Width / 2) - ((ButtonWith * Size) / 2), 0);
            XGUIEng.SetWidgetPosition(WidgetID, XHalf + ((_ColumnID -1) * ButtonWith), 0);
            local PerkConfig = self.Config:GetPerkConfig(PerkID);
            assert(PerkConfig ~= nil);
            IconTexture = PerkConfig.Icon;
        end
    else
        ButtonVisible = 0;
    end
    XGUIEng.TransferMaterials(IconTexture, WidgetID);
    XGUIEng.ShowWidget(WidgetID, ButtonVisible);
    XGUIEng.DisableButton(WidgetID, ButtonDisabled);
    XGUIEng.HighLightButton(WidgetID, ButtonHighlighted);
end

function Stronghold.Hero.Perk:PerkWindowUpdateHeadline()
    local PlayerID = GetLocalPlayerID();
    if PlayerID == 17 then
        -- HACK: Selfclose for spectator player
        XGUIEng.ShowWidget("HeroPerkWindow", 0);
        return;
    end
    local WidgetID = XGUIEng.GetCurrentWidgetID();
    local Text = "Names/PU_Hero1";
    if IsPlayer(PlayerID) then
        local HeroID = GetNobleID(PlayerID);
        local HeroType = Logic.GetEntityType(HeroID);
        local TypeName = Logic.GetEntityTypeName(HeroType);
        Text = XGUIEng.GetStringTableText("Names/" ..TypeName) or "";
    end
    XGUIEng.SetText(WidgetID, Placeholder.Replace("@center " ..Text));
end

function Stronghold.Hero.Perk:PerkWindowUpdateFlavorText()
    local PlayerID = GetLocalPlayerID();
    if PlayerID == 17 then
        return;
    end
    local WidgetID = XGUIEng.GetCurrentWidgetID();
    local Text = self.Config.UI.FlavorText[Entities.PU_Hero1];
    if IsPlayer(PlayerID) then
        local HeroID = GetNobleID(PlayerID);
        local HeroType = Logic.GetEntityType(HeroID);
        Text = XGUIEng.GetStringTableText(self.Config.UI.FlavorText[HeroType]) or "";
    end
    XGUIEng.SetText(WidgetID, Placeholder.Replace("{grey}" ..Text));
end

function Stronghold.Hero.Perk:PerkWindowUpdatePortrait()
    local PlayerID = GetLocalPlayerID();
    if PlayerID == 17 then
        return;
    end
    local WidgetID = XGUIEng.GetCurrentWidgetID();
    local Image = self.Config.UI.Portraits[Entities.PU_Hero1];
    if IsPlayer(PlayerID) then
        local HeroID = GetNobleID(PlayerID);
        local HeroType = Logic.GetEntityType(HeroID);
        Image = self.Config.UI.Portraits[HeroType] or "";
    end
    XGUIEng.SetMaterialTexture(WidgetID, 0, Image);
end

function GUIAction_HeroPerkUnlockPerk(_RowID, _ColumnID)
    Stronghold.Hero.Perk:PerkWindowUnlockPerkAction(_RowID, _ColumnID);
end

function GUITooltip_HeroPerkUnlockPerk(_RowID, _ColumnID)
    Stronghold.Hero.Perk:PerkWindowUnlockPerkTooltip(_RowID, _ColumnID);
end

function GUIUpdate_HeroPerkUnlockPerk(_RowID, _ColumnID)
    Stronghold.Hero.Perk:PerkWindowUnlockPerkUpdate(_RowID, _ColumnID);
end

function GUIUpdate_HeroPerkUpdateHeadline()
    Stronghold.Hero.Perk:PerkWindowUpdateHeadline();
end

function GUIUpdate_HeroPerkUpdateFlavorText()
    Stronghold.Hero.Perk:PerkWindowUpdateFlavorText();
end

function GUIUpdate_HeroPerkUpdatePortrait()
    Stronghold.Hero.Perk:PerkWindowUpdatePortrait();
end

-- -------------------------------------------------------------------------- --
-- Logic

function Stronghold.Hero.Perk:ResetPerksForPlayer(_PlayerID)
    if IsPlayer(_PlayerID) then
        self.Data[_PlayerID].PerkAssignmentList = {[1] = {}, [2] = {}, [3] = {}, [4] = {}};
        self.Data[_PlayerID].PerkOpenList = {[1] = {}, [2] = {}, [3] = {}, [4] = {}};
        self.Data[_PlayerID].PerkClosedLookup = {};
    end
end

function Stronghold.Hero.Perk:SetupPerksForPlayerHero(_PlayerID, _Type)
    if IsPlayer(_PlayerID) then
        -- Perks
        self.Data[_PlayerID].UnlockedPerks = {};
        if PlayerHasLordOfType(_PlayerID, "^PU_Hero1[abc]+$") then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero1_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteSpear);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteSword);
        end
        if _Type == Entities.PU_Hero2 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero2_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Axemen);
        end
        if _Type == Entities.PU_Hero3 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero3_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Cannons);
        end
        if _Type == Entities.PU_Hero4 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero4_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteCavalry);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteKnight);
        end
        if _Type == Entities.PU_Hero5 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero5_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Bandits);
        end
        if _Type == Entities.PU_Hero6 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero6_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Templars);
        end
        if _Type == Entities.CU_BlackKnight then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero7_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero7_Paranoid);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_BlackKnights);
        end
        if _Type == Entities.CU_Mary_de_Mortfichet then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero8_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero8_Underhanded);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteCrossbow);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Assassins);
        end
        if _Type == Entities.CU_Barbarian_Hero then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero9_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Barbarians);
        end
        if _Type == Entities.PU_Hero10 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero10_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteRifle);
        end
        if _Type == Entities.PU_Hero11 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero11_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero11_TraditionalMedicine);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteRifle);
        end
        if _Type == Entities.CU_Evil_Queen then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero12_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Evil);
        end
    end
end

function Stronghold.Hero.Perk:SetupUnlockablePerksForPlayerHero(_PlayerID, _Type)
    if IsPlayer(_PlayerID) then
        -- Fill generic perks
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_MineSupervisor);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_TightBelt);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Educated);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_HouseTax);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_FarmTax);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_AlarmBoost);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_InspiringPresence);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_MoodCannon);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Pyrotechnican);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_MiddleClassLover);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_ConstructionIndustry);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_PhilosophersStone);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Bureaucrat);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Benefactor);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_BeastMaster);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Convocation);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_ForeignLegion);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_ManFlayer);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_HonorTheFallen);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_EfficiencyStrategist);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_BelieverInScience);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_WarScars);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Haggler);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_ExperienceValue);
        self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Shielded);

        -- Fill personal perks
        if PlayerHasLordOfType(_PlayerID, "^PU_Hero1[abc]+$") then
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Benefactor);
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Convocation);

            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero1_Mobilization);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero1_SocialCare);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero1_SolemnAuthority);
        end
        if _Type == Entities.PU_Hero2 then
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_MineSupervisor);
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Pyrotechnican);

            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero2_Demolitionist);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero2_ExtractResources);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero2_FortressMaster);
        end
        if _Type == Entities.PU_Hero3 then
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Haggler);
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Educated);
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Shielded);

            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero3_AtileryExperte);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero3_MasterOfArts);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero3_MercenaryBoost);
        end
        if _Type == Entities.PU_Hero4 then
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_ExperienceValue);
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_InspiringPresence);

            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero4_ExperiencedInstructor);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero4_GrandMaster);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero4_Marschall);
        end
        if _Type == Entities.PU_Hero5 then
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_HouseTax);
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_FarmTax);
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_Bureaucrat);

            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero5_ChildOfNature);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero5_HubertusBlessing);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero5_TaxBonus);
        end
        if _Type == Entities.PU_Hero6 then
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero6_Confessor);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero6_ConvertSettler);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero6_Preacher);
        end
        if _Type == Entities.CU_BlackKnight then
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_TightBelt);

            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero7_ArmyOfDarkness);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero7_Moloch);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero7_Tyrant);
        end
        if _Type == Entities.CU_Mary_de_Mortfichet then
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_HonorTheFallen);

            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero8_AgentMaster);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero8_AssassinMaster);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero8_SlaveMaster);
        end
        if _Type == Entities.CU_Barbarian_Hero then
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero9_BerserkerRage);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero9_CriticalDrinker);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero9_Mobilization);
        end
        if _Type == Entities.PU_Hero10 then
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_PhilosophersStone);

            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero10_GunManufacturer);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero10_MusketeersOath);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero10_SlaveMaster);
        end
        if _Type == Entities.PU_Hero11 then
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_MoodCannon);
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_QuantityDiscount);
            self:ClosePerkForPlayerInSelection(_PlayerID, HeroPerks.Generic_ManFlayer);

            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero11_LandOfTheSmile);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero11_TradeMaster);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero11_UseShuriken);
        end
        if _Type == Entities.CU_Evil_Queen then
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero12_FertilityIcon);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero12_Moloch);
            self:AllowPerkForPlayerInSelection(_PlayerID, HeroPerks.Hero12_MothersComfort);
        end
    end
end

function Stronghold.Hero.Perk:RandomizeChoosablePerks(_PlayerID)
    if IsPlayer(_PlayerID) then
        -- Personal perks
        local ClosedLookup = {};
        local PerkID1 = self.Data[_PlayerID].PerkOpenList[2][1];
        table.insert(self.Data[_PlayerID].PerkAssignmentList[2], PerkID1);
        ClosedLookup[PerkID1] = true;
        local PerkID2 = self.Data[_PlayerID].PerkOpenList[3][1];
        table.insert(self.Data[_PlayerID].PerkAssignmentList[3], PerkID2);
        ClosedLookup[PerkID2] = true;
        local PerkID3 = self.Data[_PlayerID].PerkOpenList[4][1];
        table.insert(self.Data[_PlayerID].PerkAssignmentList[4], PerkID3);
        ClosedLookup[PerkID3] = true;

        -- Generic perks
        for i= 2, 4 do
            local NotEnough = true;
            while (NotEnough) do
                local MaxSize = table.getn(self.Data[_PlayerID].PerkOpenList[i]);
                local Random = math.random(1, MaxSize);
                local PerkID = self.Data[_PlayerID].PerkOpenList[i][Random];
                if  not self.Data[_PlayerID].PerkClosedLookup[PerkID]
                and not ClosedLookup[PerkID] then
                    local PerkConfig = self.Config:GetPerkConfig(PerkID);
                    assert(PerkConfig ~= nil);
                    local Row = self.Config.UI.RankToRow[PerkConfig.Data.RequiredRank];
                    if table.getn(self.Data[_PlayerID].PerkAssignmentList[Row]) < 3 then
                        table.insert(self.Data[_PlayerID].PerkAssignmentList[Row], PerkID);
                        ClosedLookup[PerkID] = true;
                    end
                end
                if  table.getn(self.Data[_PlayerID].PerkAssignmentList[i]) >= 3 then
                    NotEnough = false;
                end
            end
        end
    end
end

function Stronghold.Hero.Perk:SortAssignmentPerksList(_PlayerID)
    if IsPlayer(_PlayerID) then
        local GetPerkValue = function(_Name)
            if string.find(_Name, "/command_") 
            or string.find(_Name, "/Skill_") then
                return 1;
            elseif string.find(_Name, "/Hero") then
                return 2;
            elseif string.find(_Name, "/Unit_") then
                return 3;
            end
            return 4;
        end

        local Comperator = function(a, b)
            local Perk1Config = self.Config:GetPerkConfig(a);
            local Perk2Config = self.Config:GetPerkConfig(b);
            if Perk1Config and Perk2Config then
                local Value1 = GetPerkValue(Perk1Config.Text);
                local Value2 = GetPerkValue(Perk2Config.Text);
                return Value1 < Value2;
            end
            return false;
        end

        for i = 1, 4 do
            table.sort(self.Data[_PlayerID].PerkAssignmentList[i], Comperator);
        end
    end
end

function Stronghold.Hero.Perk:OnPerkUnlockedSpecialAction(_PlayerID, _Perk)
    if IsPlayer(_PlayerID) then
        -- Hero 7: Give soldiers
        if _Perk == HeroPerks.Hero7_Paranoid then
            local NobleID = GetNobleID(_PlayerID);
            Tools.CreateSoldiersForLeader(NobleID, 3);
            Logic.LeaderChangeFormationType(NobleID, 1);
        end
        -- Hero 7: Update soft cap
        if _Perk == HeroPerks.Hero7_Tyrant then
            local ExpectedSoftCap = 2;
            local CurrentSoftCap = CUtil.GetPlayersMotivationSoftcap(_PlayerID);
            ExpectedSoftCap = self.Config.Perks[_Perk].Data.MaxReputation / 100;
            CUtil.AddToPlayersMotivationSoftcap(_PlayerID, ExpectedSoftCap - CurrentSoftCap);
        end
        -- Hero 11: Update soft cap
        if _Perk == HeroPerks.Hero11_LandOfTheSmile then
            local RepuBonus = self.Config.Perks[_Perk].Data.Reputation;
            local ExpectedSoftCap = 2;
            local CurrentSoftCap = CUtil.GetPlayersMotivationSoftcap(_PlayerID);
            ExpectedSoftCap = self.Config.Perks[_Perk].Data.MaxReputation / 100;
            CUtil.AddToPlayersMotivationSoftcap(_PlayerID, ExpectedSoftCap - CurrentSoftCap);
            Stronghold.Attraction:UpdateMotivationOfPlayersWorkers(_PlayerID, RepuBonus);
            Stronghold.Player:AddPlayerReputation(_PlayerID, RepuBonus);
        end
    end
end

function Stronghold.Hero.Perk:IsPerkTriggered(_PlayerID, _Perk)
    if IsPlayer(_PlayerID) then
        local Config = self.Config:GetPerkConfig(_Perk);
        local HeroID = GetNobleID(_PlayerID);
        if Config and IsValidEntity(HeroID) and self:HasPlayerUnlockedPerk(_PlayerID, _Perk) then
            if Config.Data.Chance and Config.Data.Chance < 100 then
                return math.random(1, 100) <= Config.Data.Chance;
            end
            return true;
        end
    end
    return false;
end

function Stronghold.Hero.Perk:HasPlayerUnlockedPerk(_PlayerID, _PerkID)
    if IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].UnlockedPerks[_PerkID] == true;
    end
    return false;
end

function Stronghold.Hero.Perk:UnlockPerkForPlayer(_PlayerID, _PerkID)
    if IsPlayer(_PlayerID) then
        if not self.Data[_PlayerID].UnlockedPerks[_PerkID] then
            self.Data[_PlayerID].UnlockedPerks[_PerkID] = true;
            table.insert(self.Data[_PlayerID].PerkAssignmentList[1], _PerkID);
            self:OnPerkUnlockedSpecialAction(_PlayerID, _PerkID);
            GameCallback_SH_Logic_OnPerkUnlocked(_PlayerID, _PerkID);
        end
    end
end

function Stronghold.Hero.Perk:AllowPerkForPlayerInSelection(_PlayerID, _PerkID)
    if IsPlayer(_PlayerID) then
        local PerkConfig = self.Config:GetPerkConfig(_PerkID);
        assert(PerkConfig ~= nil);
        local Row = self.Config.UI.RankToRow[PerkConfig.Data.RequiredRank];
        table.insert(self.Data[_PlayerID].PerkOpenList[Row], _PerkID);
        table.sort(self.Data[_PlayerID].PerkOpenList[Row]);
    end
end

function Stronghold.Hero.Perk:ClosePerkForPlayerInSelection(_PlayerID, _PerkID)
    if IsPlayer(_PlayerID) then
        self.Data[_PlayerID].PerkClosedLookup[_PerkID] = true;
    end
end

function Stronghold.Hero.Perk:OnPerkSelected(_PlayerID, _RowID, _PerkID)
    if IsPlayer(_PlayerID) then
        for _, Perk in pairs(self.Data[_PlayerID].PerkAssignmentList[_RowID]) do
            if _PerkID ~= Perk then
                self:ClosePerkForPlayerInSelection(_PlayerID, Perk);
            end
        end
        self:UnlockPerkForPlayer(_PlayerID, _PerkID);
        self:SortAssignmentPerksList(_PlayerID);
        self:PerkWindowOnShow();
    end
end

-- -------------------------------------------------------------------------- --

function Stronghold.Hero.Perk:OwerwriteAdditionalGameCallbacks()
    Overwrite.CreateOverwrite("GameCallback_SH_Logic_OnAttackRegisterIteration", function(_PlayerID, _AttackedID, _AttackerID, _TimeRemaining)
        Overwrite.CallOriginal();
        Stronghold.Hero.Perk:HeliasConvertController(_PlayerID, _AttackedID, _AttackerID);
        Stronghold.Hero.Perk:YukiShurikenConterController(_PlayerID, _AttackedID, _AttackerID);
    end);
end

function Stronghold.Hero.Perk:HeliasConvertController(_PlayerID, _AttackedID, _AttackerID)
    if IsPlayer(_PlayerID) then
        if Logic.GetEntityType(_AttackedID) == Entities.PU_Hero6 then
            if Logic.GetEntityHealth(_AttackedID) > 0 then
                if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero6_ConvertSettler) then
                    local HeliasPlayerID = Logic.EntityGetPlayer(_AttackedID);
                    local AttackerID = _AttackerID;
                    if Logic.IsEntityInCategory(AttackerID, EntityCategories.Soldier) == 1 then
                        AttackerID = SVLib.GetLeaderOfSoldier(AttackerID);
                    end
                    if not self.Data.ConvertBlacklist[AttackerID] then
                        local UnitType = Logic.GetEntityType(AttackerID);
                        local UnitConfig = Stronghold.Unit.Config.Troops:GetConfig(UnitType, _PlayerID);
                        if UnitConfig then
                            local RankRequired = GetRankRequired(UnitType, UnitConfig.Right);
                            if  (RankRequired ~= -1 and GetRank(_PlayerID) >= RankRequired)
                            and Logic.GetEntityHealth(AttackerID) > 0
                            and Logic.IsSettler(AttackerID) == 1
                            and Logic.IsHero(AttackerID) == 0 then
                                local PerkConfig = self.Config.Perks[HeroPerks.Hero6_ConvertSettler].Data;
                                if GetDistance(AttackerID, _AttackedID) <= PerkConfig.Area then
                                    local ID = ChangePlayer(AttackerID, HeliasPlayerID);
                                    SetMercenaryUnit(AttackerID, nil);
                                    SetMercenaryUnit(ID, true);
                                    if GUI.GetPlayerID() == HeliasPlayerID then
                                        Sound.PlayFeedbackSound(Sounds.VoicesHero6_HERO6_ConvertSettler_rnd_01, 100);
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

function Stronghold.Hero.Perk:YukiShurikenConterController(_PlayerID, _AttackedID, _AttackerID)
    if IsPlayer(_PlayerID) then
        if Logic.GetEntityType(_AttackedID) == Entities.PU_Hero11 then
            if Logic.GetEntityHealth(_AttackedID) > 0 then
                if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero11_UseShuriken) then
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
                        and Logic.IsHero(AttackerID) == 0
                        and Logic.GetEntityHealth(AttackerID) > 0
                        and IsNear(_AttackedID, AttackerID, 3000) then
                            SendEvent.HeroShuriken(_AttackedID, AttackerID);
                            if GUI.GetPlayerID() == YukiPlayerID then
                                Sound.PlayFeedbackSound(Sounds.AOVoicesHero11_HERO11_Shuriken_rnd_01, 100);
                            end
                        end
                    end
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

function Stronghold.Hero.Perk:OnPlayerPayday(_PlayerID, _CurrentAmount)
    if IsPlayer(_PlayerID) then
        -- Save last tax level
        self.Data[_PlayerID].LastTaxLevel = GetTaxHeight(_PlayerID) -1;
    end
end

function Stronghold.Hero.Perk:OnNobleDefeated(_PlayerID, _NobleID, _AttackerID)
    if IsPlayer(_PlayerID) then
        -- Save entity that defeated the Noble
        self.Data[_PlayerID].NobleKillerEntityID = _AttackerID;
    end
end

-- -------------------------------------------------------------------------- --

function Stronghold.Hero.Perk:OverwriteGameCallbacks()
    -- Generic --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ResourceMined", function(_PlayerID, _BuildingID, _SourceID, _ResourceType, _Amount, _Remaining)
        local CurrentAmount, RemainingAmount = Overwrite.CallOriginal();
        CurrentAmount, ResourceRemaining = Stronghold.Hero.Perk:ApplyResourceProductionBonusAbility(_PlayerID, _BuildingID, _SourceID, _ResourceType, CurrentAmount, RemainingAmount);
        return CurrentAmount, ResourceRemaining;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_SerfExtraction", function(_PlayerID, _SerfID, _SourceID, _ResourceType, _Amount, _Remaining)
        local CurrentAmount, RemainingAmount = Overwrite.CallOriginal();
        CurrentAmount, ResourceRemaining = Stronghold.Hero.Perk:ApplySerfExtractionBonusAbility(_PlayerID, _SerfID, _SourceID, _ResourceType, CurrentAmount, RemainingAmount);
        return CurrentAmount, ResourceRemaining;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ResourceRefined", function(_PlayerID, _BuildingID, _ResourceType, Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyResourceRefiningBonusAbility(_PlayerID, _BuildingID, _ResourceType, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_KnowledgeIncrease", function(_PlayerID, _Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyKnowledgePassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_GoodsTraded", function(_PlayerID, _BuildingID, _BuyType, _BuyAmount, _SellType, _SellAmount)
        Overwrite.CallOriginal();
        Stronghold.Hero.Perk:ApplyTradePassiveAbility(_PlayerID, _BuildingID, _BuyType, _BuyAmount, _SellType, _SellAmount);
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MinimalConstructionDistance", function(_PlayerID, _UpgradeCategory, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyTowerDistancePassiveAbility(_PlayerID, _UpgradeCategory, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_BattleDamage", function(_AttackerID, _AttackedID, _Damage)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyBattleDamagePassiveAbility(_AttackerID, _AttackedID, _Damage);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Logic_OnNobleDefeated", function(_PlayerID, _NobleID, _AttackerID)
        Stronghold.Hero.Perk:OnNobleDefeated(_PlayerID, _NobleID, _AttackerID);
    end);

    -- Noble --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ReputationMax", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyMaxReputationPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ReputationIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyReputationIncreasePassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ServiceReputationIncrease", function(_PlayerID, _Type, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyDynamicReputationBonusPassiveAbility(_PlayerID, _Type, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ReputationDecrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyReputationDecreasePassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_HonorIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyHonorBonusPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ServiceHonorIncrease", function(_PlayerID, _Type, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyDynamicHonorBonusPassiveAbility(_PlayerID, _Type, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MercenaryCostFactor", function(_PlayerID, _Type, _Factor)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyMercenaryCostPassiveAbility(_PlayerID, _Type, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MercenaryExperience", function(_PlayerID, _Type, _Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyMercenaryExperiencePassiveAbility(_PlayerID, _Type, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MercenaryCapacityFactor", function(_PlayerID, _Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyMercenaryCapacityPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MercenaryRechargeTimer", function(_PlayerID, _Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyMercenaryRechargePassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_HungerPenalty", function(_PlayerID, _Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyReputationHungerPenaltyPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_SleepPenalty", function(_PlayerID, _Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyReputationSleepPenaltyPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    -- Money --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_TotalPaydayIncome", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyPaydayIncomeBonusPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_TotalPaydayUpkeep", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyPaydayUpkeepDiscountPassiveAbility(_PlayerID, _CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_PaydayUpkeep", function(_PlayerID, _UnitType, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyUnitUpkeepDiscountPassiveAbility(_PlayerID, _UnitType, CurrentAmount)
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_CalculateFestivalCosts", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        Stronghold.Hero.Perk:ApplyFestivalCostsDiscountPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_CalculateSermonCosts", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        Stronghold.Hero.Perk:ApplySermonCostsDiscountPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_Payday", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        Stronghold.Hero.Perk:OnPlayerPayday(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    -- Attraction --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_CivilAttrationLimit", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyMaxCivilAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_CivilAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyCivilAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MilitaryAttrationLimit", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyMaxMilitaryAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MilitaryAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyMilitaryAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_SingleUnitPlaces", function(_PlayerID, _EntityID, _Type, _Usage)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyUnitTypeAttractionPassiveAbility(_PlayerID, _Type, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_SlaveAttrationLimit", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyMaxSlaveAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_SlaveAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplySlaveAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    -- Social --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_InfluenceIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyInfluencePointsPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_CrimeRate", function(_PlayerID, _Rate)
        local CrimeRate = Overwrite.CallOriginal();
        CrimeRate = Stronghold.Hero.Perk:ApplyCrimeRatePassiveAbility(_PlayerID, CrimeRate);
        return CrimeRate;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_FilthRate", function(_PlayerID, _Rate)
        local FilthRate = Overwrite.CallOriginal();
        FilthRate = Stronghold.Hero.Perk:ApplyFilthRatePassiveAbility(_PlayerID, FilthRate);
        return FilthRate;
    end);
end

-- -------------------------------------------------------------------------- --

function Stronghold.Hero.Perk:ApplyResourceProductionBonusAbility(_PlayerID, _BuildingID, _SourceID, _ResourceType, _CurrentAmount, _RemainingAmount)
    local CurrentAmount, RemainingAmount = _CurrentAmount, _RemainingAmount;
    -- Generic T1: Mine Supervisor
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_MineSupervisor) then
        if _ResourceType ~= ResourceType.WoodRaw then
            local Data = self.Config.Perks[HeroPerks.Generic_MineSupervisor].Data;
            CurrentAmount = CurrentAmount + Data.Amount;
        end
    end
    -- Hero 2: Extract Resources
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero2_ExtractResources) then
        if _ResourceType ~= ResourceType.WoodRaw then
            local Data = self.Config.Perks[HeroPerks.Hero2_ExtractResources].Data;
            CurrentAmount = CurrentAmount + Data.Amount;
        end
    end
    -- Hero 5: Child of Nature
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero5_ChildOfNature) then
        local Data = self.Config.Perks[HeroPerks.Hero5_ChildOfNature].Data;
        if  math.random(1, 100) <= Data.PreservationChance
        and _ResourceType ~= ResourceType.WoodRaw then
            RemainingAmount = RemainingAmount + Data.MinerPreservation;
        end
        if _ResourceType == ResourceType.SilverRaw then
            Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.WoodRaw, Data.RawWoodBonus);
        end
    end
    return CurrentAmount, RemainingAmount;
end

function Stronghold.Hero.Perk:ApplySerfExtractionBonusAbility(_PlayerID, _SerfID, _SourceID, _ResourceType, _CurrentAmount, _RemainingAmount)
    local CurrentAmount, RemainingAmount = _CurrentAmount, _RemainingAmount;
    -- Hero 5: Child of Nature
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero5_ChildOfNature) then
        local Data = self.Config.Perks[HeroPerks.Hero5_ChildOfNature].Data;
        if _ResourceType == ResourceType.WoodRaw then
            Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.WoodRaw, Data.RawWoodBonus);
        elseif _ResourceType == ResourceType.SilverRaw then
            Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.WoodRaw, Data.RawWoodBonus);
        elseif math.random(1, 100) <= Data.PreservationChance then
            RemainingAmount = RemainingAmount + Data.SerfPreservation;
        end
    end
    return CurrentAmount, RemainingAmount;
end

function Stronghold.Hero.Perk:ApplyResourceRefiningBonusAbility(_PlayerID, _BuildingID, _ResourceType, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Generic T2: Middleclass Lover
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_MiddleClassLover) then
        local Data = self.Config.Perks[HeroPerks.Generic_MiddleClassLover].Data;
        if Logic.GetUpgradeLevelForBuilding(_BuildingID) == 0 then
            CurrentAmount = CurrentAmount + Data.Bonus;
        end
    end
    -- Generic T2: Construction Insustry
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_ConstructionIndustry) then
        local Data = self.Config.Perks[HeroPerks.Generic_ConstructionIndustry].Data;
        if Data.ResourceTypes[_ResourceType] then
            CurrentAmount = CurrentAmount + Data.Bonus;
        end
    end
    -- Generic T2: Philosophers Stone
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_PhilosophersStone) then
        local Data = self.Config.Perks[HeroPerks.Generic_PhilosophersStone].Data;
        if Data.ResourceTypes[_ResourceType] then
            CurrentAmount = CurrentAmount + Data.Bonus;
        end
    end
    -- Generic T3: Man Flayer
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_ManFlayer) then
        local Data = self.Config.Perks[HeroPerks.Generic_ManFlayer].Data;
        if Logic.IsOvertimeActiveAtBuilding(_BuildingID) == 0 then
            CurrentAmount = math.floor(CurrentAmount + Data.BonusFactor);
        else
            CurrentAmount = math.ceil(CurrentAmount + Data.MalusFactor);
        end
    end
    -- Generic T3: Number Juggler
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_NumberJuggler) then
        local Data = self.Config.Perks[HeroPerks.Generic_NumberJuggler].Data;
        if Data.ResourceTypes[_ResourceType] then
            local TaxHeight = self.Data[_PlayerID].LastTaxLevel;
            CurrentAmount = CurrentAmount + (Data.Gross - TaxHeight);
        end
    end
    -- Generic T3: Efficiency Strategist
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_EfficiencyStrategist) then
        local Data = self.Config.Perks[HeroPerks.Generic_EfficiencyStrategist].Data;
        Logic.AddToPlayersGlobalResource(_PlayerID, _ResourceType +1, Data.Resource);
        CurrentAmount = math.max(CurrentAmount + Data.Refine, 1);
    end
    -- Hero 5: Child of Nature
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero5_ChildOfNature) then
        local Data = self.Config.Perks[HeroPerks.Hero5_ChildOfNature].Data;
        if _ResourceType == ResourceType.Wood then
            CurrentAmount = CurrentAmount + Data.RefinedWoodBonus;
        end
    end
    -- Hero 10: Gun Manufacturer
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero10_GunManufacturer) then
        local Data = self.Config.Perks[HeroPerks.Hero10_GunManufacturer].Data;
        local BuildingType = Logic.GetEntityType(_BuildingID);
        if Data.EntityTypes[BuildingType] and Data.ResourceTypes[_ResourceType] then
            CurrentAmount = CurrentAmount + Data.Bonus;
        end
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyKnowledgePassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Generic T1: Educated
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_Educated) then
        local Data = self.Config.Perks[HeroPerks.Generic_Educated].Data;
        CurrentAmount = CurrentAmount * Data.Factor;
    end
    -- Generic T3: Believer in Science
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_BelieverInScience) then
        local Data = self.Config.Perks[HeroPerks.Generic_BelieverInScience].Data;
        Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.Faith, Data.Faith);
        CurrentAmount = math.max(CurrentAmount - Data.Faith, 1);
    end
    -- Hero 3: Knowledge Boost
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero3_MasterOfArts) then
        local Data = self.Config.Perks[HeroPerks.Hero3_MasterOfArts].Data;
        CurrentAmount = CurrentAmount * Data.Factor;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyTradePassiveAbility(_PlayerID, _BuildingID, _BuyType, _BuyAmount, _SellType, _SellAmount)
    local GuiPlayer = GUI.GetPlayerID();
    local Bonus = 0;
    local ResourceName = GetResourceName(_BuyType);
    local Text = XGUIEng.GetStringTableText("SH_Text/GUI_TradeBonus");

    -- Generic T2: Quantity Discount
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_QuantityDiscount) then
        local Data = self.Config.Perks[HeroPerks.Generic_QuantityDiscount].Data;
        Bonus = math.ceil(_BuyAmount * Data.Factor);
    end
    -- Hero 11: Trade Master
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero11_TradeMaster) then
        local Data = self.Config.Perks[HeroPerks.Hero11_TradeMaster].Data;
        local Factor = 1.0 + (Data.FactorBonus * (_BuyAmount / Data.FactorDiv));
        Bonus = math.ceil(_BuyAmount * Factor);
    end

    if Bonus > 0 then
        Logic.AddToPlayersGlobalResource(_PlayerID, _BuyType, Bonus);
        if GuiPlayer == _PlayerID then
            Message(string.format(Text, Bonus, ResourceName));
        end
    end
end

function Stronghold.Hero.Perk:ApplyTowerDistancePassiveAbility(_PlayerID, _UpgradeCategory, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 2: Defence Master
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero2_FortressMaster) then
        local Data = self.Config.Perks[HeroPerks.Hero2_FortressMaster].Data;
        CurrentAmount = CurrentAmount * Data.Factor;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyBattleDamagePassiveAbility(_AttackerID, _AttackedID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    local AttackerPlayerID = Logic.EntityGetPlayer(_AttackerID);
    local AttackerType = Logic.GetEntityType(_AttackerID);
    local AttackedPlayerID = Logic.EntityGetPlayer(_AttackedID);
    local AttackedType = Logic.GetEntityType(_AttackedID);

    -- Damage delt --

    -- Generic T1: Alarm Boost
    if self:IsPerkTriggered(AttackerPlayerID, HeroPerks.Generic_AlarmBoost) then
        local Data = self.Config.Perks[HeroPerks.Generic_AlarmBoost].Data;
        if IsAttackerAlarmDefender(_AttackerID) then
            CurrentAmount = CurrentAmount * Data.DamageFactor;
        end
    end
    -- Generic T1: Inspiring Presence
    if self:IsPerkTriggered(AttackerPlayerID, HeroPerks.Generic_InspiringPresence) then
        local Data = self.Config.Perks[HeroPerks.Generic_InspiringPresence].Data;
        if IsAttackerAlarmDefender(_AttackerID) then
            CurrentAmount = CurrentAmount * Data.DamageFactor;
        end
    end
    -- Generic T2: Beast Master
    if self:IsPerkTriggered(AttackerPlayerID, HeroPerks.Generic_BeastMaster) then
        local Data = self.Config.Perks[HeroPerks.Generic_BeastMaster].Data;
        if Data.EntityTypes[AttackerType] then
            CurrentAmount = CurrentAmount * Data.DamageDeltFactor;
        end
    end
    -- Hero 8: Assassin Master
    if self:IsPerkTriggered(AttackerPlayerID, HeroPerks.Hero8_AssassinMaster) then
        local Data = self.Config.Perks[HeroPerks.Hero8_AssassinMaster].Data;
        if Data.EntityTypes[AttackerType] then
            CurrentAmount = CurrentAmount * Data.DamageDeltFactor;
        end
    end
    -- Hero 9: Berserker Rage
    if self:IsPerkTriggered(AttackerPlayerID, HeroPerks.Hero9_BerserkerRage) then
        local Data = self.Config.Perks[HeroPerks.Hero9_BerserkerRage].Data;
        if Data.EntityTypes[AttackedType] then
            CurrentAmount = CurrentAmount * Data.DamageDeltFactor;
        end
    end

    -- Damage taken --

    -- Generic T2: Beast Master
    if self:IsPerkTriggered(AttackerPlayerID, HeroPerks.Generic_BeastMaster) then
        local Data = self.Config.Perks[HeroPerks.Generic_BeastMaster].Data;
        if Data.EntityTypes[AttackedType] then
            CurrentAmount = CurrentAmount * Data.DamageTakenFactor;
        end
    end
    -- Generic T3: War Scars
    if self:IsPerkTriggered(AttackerPlayerID, HeroPerks.Generic_WarScars) then
        local Data = self.Config.Perks[HeroPerks.Generic_WarScars].Data;
        if IsMercenaryUnit(_AttackedID) then
            CurrentAmount = CurrentAmount * Data.Factor;
        end
    end
    -- Generic T3: Values Experience
    if self:IsPerkTriggered(AttackerPlayerID, HeroPerks.Generic_ExperienceValue) then
        local Data = self.Config.Perks[HeroPerks.Generic_ExperienceValue].Data;
        local LeaderID = _AttackedID;
        if Logic.IsEntityInCategory(_AttackedID, EntityCategories.Soldier) == 1 then
            LeaderID = SVLib.GetLeaderOfSoldier(LeaderID);
        end
        local Level = math.floor((CEntity.GetLeaderExperience(LeaderID) or 0) / 200);
        local Factor = math.max(1 - (Level * Data.GrossFactor), 0.1);
        CurrentAmount = CurrentAmount * Factor;
    end
    -- Generic T3: Shielded
    if self:IsPerkTriggered(AttackerPlayerID, HeroPerks.Generic_Shielded) then
        local Data = self.Config.Perks[HeroPerks.Generic_Shielded].Data;
        local DamageClass = GetEntityDamageClass(_AttackedID);
        if Data.DamageClasses[DamageClass] then
            CurrentAmount = CurrentAmount * Data.DamageFactor;
        end
    end
    -- Hero 4: Marschall
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero4_Marschall) then
        local Data = self.Config.Perks[HeroPerks.Hero4_Marschall].Data;
        if Data.EntityTypes[AttackedType] then
            local DamageClass = GetEntityDamageClass(_AttackedID);
            if Data.DamageClasses[DamageClass] then
                CurrentAmount = CurrentAmount * Data.Factor;
            end
        end
    end
    -- Hero 4: Hubertus Blessing
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero5_HubertusBlessing) then
        local Data = self.Config.Perks[HeroPerks.Hero5_HubertusBlessing].Data;
        if Data.EntityTypes[AttackedType] then
            CurrentAmount = CurrentAmount * Data.DamageFactor;
        end
    end
    -- Hero 7: Moloch
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero7_Moloch) then
        local Data = self.Config.Perks[HeroPerks.Hero7_Moloch].Data;
        if Data.EntityTypes[AttackedType] then
            CurrentAmount = CurrentAmount * Data.DamageTakenFactor;
        end
    end
    -- Hero 9: Berserker Rage
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero9_BerserkerRage) then
        local Data = self.Config.Perks[HeroPerks.Hero9_BerserkerRage].Data;
        if Data.EntityTypes[AttackedType] then
            CurrentAmount = CurrentAmount * Data.DamageTakenFactor;
        end
    end
    -- Hero 9: Mobilization
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero9_Mobilization) then
        local Data = self.Config.Perks[HeroPerks.Hero9_Mobilization].Data;
        CurrentAmount = CurrentAmount * Data.DamageTakenFactor;
    end
    -- Hero 11: Traditional Medicine
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero11_TraditionalMedicine) then
        if AttackedType == Entities.PU_Hero11 then
            local Health = Logic.GetEntityHealth(_AttackedID);
            local MaxHealth = Logic.GetEntityMaxHealth(_AttackedID);
            if IsPlayer(AttackedPlayerID) and Health - CurrentAmount <= 0 then
                if self.Data[AttackedPlayerID].NobleKillerEntityID then
                    self.Data[AttackedPlayerID].NobleKillerEntityID = nil;
                    CurrentAmount = 0;
                    local x,y,z = Logic.EntityGetPos(_AttackedID);
                    Logic.CreateEffect(GGL_Effects.FXSalimHeal, x, y, 0);
                    Logic.HealEntity(_AttackedID, MaxHealth - Health);
                end
            end
        end
    end
    -- Hero 12: Mothers Comfort
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero12_MothersComfort) then
        local Data = self.Config.Perks[HeroPerks.Hero12_MothersComfort].Data;
        if Data.EntityTypes[AttackedType] then
            local DamageClass = GetEntityDamageClass(_AttackedID);
            if Data.DamageClasses[DamageClass] then
                CurrentAmount = CurrentAmount * Data.DamageTakenFactor;
            end
        end
    end
    -- Hero 12: Moloch
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero12_Moloch) then
        local Data = self.Config.Perks[HeroPerks.Hero12_Moloch].Data;
        if Data.EntityTypes[AttackedType] then
            CurrentAmount = CurrentAmount * Data.DamageTakenFactor;
        end
    end

    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMaxReputationPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 7: Tyrant
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero7_Tyrant) then
        local Data = self.Config.Perks[HeroPerks.Hero7_Tyrant].Data;
        CurrentAmount = Data.MaxReputation;
    end
    -- Hero 11: Land of the Smile
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero11_LandOfTheSmile) then
        local Data = self.Config.Perks[HeroPerks.Hero11_LandOfTheSmile].Data;
        CurrentAmount = Data.MaxReputation;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyReputationIncreasePassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyDynamicReputationBonusPassiveAbility(_PlayerID, _Type, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 9: Critical Drinker
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero9_CriticalDrinker) then
        local Data = self.Config.Perks[HeroPerks.Hero9_CriticalDrinker].Data;
        if _Type == Entities.PB_Tavern1 or _Type == Entities.PB_Tavern2 then
            CurrentAmount = CurrentAmount * Data.ReputationFactor;
        end
    end
    return math.floor(CurrentAmount + 0.5);
end

function Stronghold.Hero.Perk:ApplyReputationDecreasePassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Generic T2: Bureaucrat
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_Bureaucrat) then
        local Data = self.Config.Perks[HeroPerks.Generic_Bureaucrat].Data;
        CurrentAmount = CurrentAmount * Data.ReputationFactor;
    end
    -- Hero 7: Tyrant
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero7_Tyrant) then
        if self.Data[_PlayerID].UnlockedPerks[HeroPerks.Hero7_Tyrant] then
            local Data = self.Config.Perks[HeroPerks.Hero7_Tyrant].Data;
            CurrentAmount = CurrentAmount * Data.Factor;
        end
    end
    return math.floor(CurrentAmount + 0.5);
end

function Stronghold.Hero.Perk:ApplyHonorBonusPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Generic T2: Benefactor
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_Benefactor) then
        local Data = self.Config.Perks[HeroPerks.Generic_Benefactor].Data;
        CurrentAmount = CurrentAmount * Data.HonorFactor;
    end
    -- Hero 1: Social Care
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero1_SocialCare) then
        local Data = self.Config.Perks[HeroPerks.Hero1_SocialCare].Data;
        CurrentAmount = CurrentAmount * Data.HonorFactor;
    end
    return math.floor(CurrentAmount + 0.5);
end

function Stronghold.Hero.Perk:ApplyDynamicHonorBonusPassiveAbility(_PlayerID, _Type, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 9: Critical Drinker
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero9_CriticalDrinker) then
        local Data = self.Config.Perks[HeroPerks.Hero9_CriticalDrinker].Data;
        if _Type == Entities.PB_Tavern1 or _Type == Entities.PB_Tavern2 then
            CurrentAmount = CurrentAmount * Data.HonorFactor;
        end
    end
    return math.floor(CurrentAmount + 0.5);
end

function Stronghold.Hero.Perk:ApplyMercenaryCostPassiveAbility(_PlayerID, _Type, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Generic T2: Foreign Legion
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_ForeignLegion) then
        local Data = self.Config.Perks[HeroPerks.Generic_ForeignLegion].Data;
        CurrentAmount = Data.CostFactor;
    end
    -- Generic T3: Haggler
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_Haggler) then
        local Data = self.Config.Perks[HeroPerks.Generic_Haggler].Data;
        CurrentAmount = Data.Factor;
    end
    -- Hero 3: Mercenary Boost
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero3_MercenaryBoost) then
        local Data = self.Config.Perks[HeroPerks.Hero3_MercenaryBoost].Data;
        CurrentAmount = Data.FactorOverwrite;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMercenaryExperiencePassiveAbility(_PlayerID, _Type, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 3: Mercenary Boost
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero3_MercenaryBoost) then
        local Data = self.Config.Perks[HeroPerks.Hero3_MercenaryBoost].Data;
        CurrentAmount = Data.ExperienceOverwrite;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMercenaryRechargePassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Generic T2: Foreign Legion
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_ForeignLegion) then
        local Data = self.Config.Perks[HeroPerks.Generic_ForeignLegion].Data;
        CurrentAmount = Data.RechargeFactor;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMercenaryCapacityPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 3: Mercenary Boost
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero3_MercenaryBoost) then
        local Data = self.Config.Perks[HeroPerks.Hero3_MercenaryBoost].Data;
        CurrentAmount = Data.CapactyFactor;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyExperiencePassiveAbility(_PlayerID, _EntityID, _Amount)
    local Amount = _Amount;
    local Type = Logic.GetEntityType(_EntityID);
    -- Hero 4: Experienced Instructor
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero4_ExperiencedInstructor) then
        local Data = self.Config.Perks[HeroPerks.Hero4_ExperiencedInstructor].Data;
        if Data.EntityTypes[Type] then
            CurrentAmount = CurrentAmount + Data.Amount;
        end
    end
    -- Hero 4: Grand Master
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero4_GrandMaster) then
        local Data = self.Config.Perks[HeroPerks.Hero4_GrandMaster].Data;
        if Data.EntityTypes[Type] then
            CurrentAmount = CurrentAmount + Data.Amount;
        end
    end
    return Amount;
end

function Stronghold.Hero.Perk:ApplyPaydayIncomeBonusPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Generic T1: House Tax
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_HouseTax) then
        local Data = self.Config.Perks[HeroPerks.Generic_HouseTax].Data;
        local Bonus = 0;
        local HouseList = Stronghold:GetHousesOfType(_PlayerID, 0, true);
        for i= 2, HouseList[1] do
            local Level = Logic.GetUpgradeLevelForBuilding(HouseList[i]);
            for j= 1, Logic.GetBuildingSleepPlaceUsage(HouseList[i]) do
                Bonus = Bonus + (Data.Bonus * Level);
            end
        end
        CurrentAmount = CurrentAmount + Bonus;
    end
    -- Generic T1: Farm Tax
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_FarmTax) then
        local Data = self.Config.Perks[HeroPerks.Generic_FarmTax].Data;
        local Bonus = 0;
        local FarmList = Stronghold:GetFarmsOfType(_PlayerID, 0, true);
        for i= 2, FarmList[1] do
            local Level = Logic.GetUpgradeLevelForBuilding(FarmList[i]);
            for j= 1, Logic.GetBuildingFarmPlaceUsage(FarmList[i]) do
                Bonus = Bonus + (Data.Bonus * Level);
            end
        end
        CurrentAmount = CurrentAmount + Bonus;
    end
    -- Generic T2: Bureaucrat
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_Bureaucrat) then
        local Data = self.Config.Perks[HeroPerks.Generic_Bureaucrat].Data;
        CurrentAmount = CurrentAmount * Data.TaxFactor;
    end
    -- Generic T2: Benefactor
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_Benefactor) then
        local Data = self.Config.Perks[HeroPerks.Generic_Benefactor].Data;
        CurrentAmount = CurrentAmount * Data.TaxFactor;
    end
    -- Hero 1: Social Care
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero1_SocialCare) then
        local Data = self.Config.Perks[HeroPerks.Hero1_SocialCare].Data;
        CurrentAmount = CurrentAmount * Data.TaxFactor;
    end
    -- Hero 5: Tax Bonus
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero5_TaxBonus) then
        local Data = self.Config.Perks[HeroPerks.Hero5_TaxBonus].Data;
        CurrentAmount = CurrentAmount * Data.Bonus;
    end
    -- Hero 12: Fertility Icon
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero12_FertilityIcon) then
        local Data = self.Config.Perks[HeroPerks.Hero12_FertilityIcon].Data;
        CurrentAmount = CurrentAmount * Data.TaxFactor;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyPaydayUpkeepDiscountPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyUnitUpkeepDiscountPassiveAbility(_PlayerID, _UnitType, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 7: Army of Darkness
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero7_ArmyOfDarkness) then
        local Data = self.Config.Perks[HeroPerks.Hero7_ArmyOfDarkness].Data;
        if Data.EntityTypes[_UnitType] then
            CurrentAmount = CurrentAmount * Data.Factor;
        end
    end
    -- Hero 8: Agent Master
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero8_AgentMaster) then
        local Data = self.Config.Perks[HeroPerks.Hero8_AgentMaster].Data;
        if Data.EntityTypes[_UnitType] then
            CurrentAmount = CurrentAmount * Data.Factor;
        end
    end
    -- Hero 10: Musketeers Oath
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero10_MusketeersOath) then
        local Data = self.Config.Perks[HeroPerks.Hero10_MusketeersOath].Data;
        if _UnitType == Entities.PU_LeaderRifle1
        or _UnitType == Entities.PU_LeaderRifle2
        then
            CurrentAmount = CurrentAmount * Data.Factor;
        end
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMaxCivilAttractionPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Generic T2: Convocation
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_Convocation) then
        local Data = self.Config.Perks[HeroPerks.Generic_Convocation].Data;
        CurrentAmount = CurrentAmount * Data.PopulationFactor;
    end
    -- Hero 1: Mobilization
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero1_Mobilization) then
        local Data = self.Config.Perks[HeroPerks.Hero1_Mobilization].Data;
        CurrentAmount = CurrentAmount * Data.PopulationFactor;
    end
    -- Hero 12: Fertility Icon
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero12_FertilityIcon) then
        local Data = self.Config.Perks[HeroPerks.Hero12_FertilityIcon].Data;
        CurrentAmount = CurrentAmount * Data.PopulationFactor;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyCivilAttractionPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMaxMilitaryAttractionPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Generic T2: Convocation
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_Convocation) then
        local Data = self.Config.Perks[HeroPerks.Generic_Convocation].Data;
        CurrentAmount = CurrentAmount * Data.MilitaryFactor;
    end
    -- Hero 1: Mobilization
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero1_Mobilization) then
        local Data = self.Config.Perks[HeroPerks.Hero1_Mobilization].Data;
        CurrentAmount = CurrentAmount * Data.MilitaryFactor;
    end
    -- Hero 9: Mobilization
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero9_Mobilization) then
        local Data = self.Config.Perks[HeroPerks.Hero9_Mobilization].Data;
        CurrentAmount = CurrentAmount * Data.MilitaryFactor;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMilitaryAttractionPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyUnitTypeAttractionPassiveAbility(_PlayerID, _Type, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    if IsPlayer(_PlayerID) then
        -- Hero 3: Forge Master
        if self.Data[_PlayerID].UnlockedPerks[HeroPerks.Hero3_AtileryExperte] then
            if _Type == Entities.CV_Cannon1 or _Type == Entities.CV_Cannon2
            or _Type == Entities.PV_Cannon1 or _Type == Entities.PV_Cannon2
            or _Type == Entities.PV_Cannon3 or _Type == Entities.PV_Cannon4
            or _Type == Entities.PV_Cannon7 or _Type == Entities.PV_Cannon8
            then
                local Data = self.Config.Perks[HeroPerks.Hero3_AtileryExperte].Data;
                CurrentAmount = math.max(CurrentAmount - Data.Places, 1);
            end
        end
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMaxSlaveAttractionPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 8: Slave Master
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero8_SlaveMaster) then
        local Data = self.Config.Perks[HeroPerks.Hero8_SlaveMaster].Data;
        CurrentAmount = CurrentAmount + (Data.Amount * GetRank(_PlayerID));
    end
    -- Hero 10: Slave Master
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero10_SlaveMaster) then
        local Data = self.Config.Perks[HeroPerks.Hero10_SlaveMaster].Data;
        CurrentAmount = CurrentAmount + (Data.Amount * GetRank(_PlayerID));
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplySlaveAttractionPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyInfluencePointsPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 1: Solemn Authority
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero1_SolemnAuthority) then
        local Data = self.Config.Perks[HeroPerks.Hero1_SolemnAuthority].Data;
        CurrentAmount = CurrentAmount * Data.Factor;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyCrimeRatePassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 6: Confessor
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero6_Confessor) then
        local Data = self.Config.Perks[HeroPerks.Hero6_Confessor].Data;
        CurrentAmount = CurrentAmount + Data.CrimeFactor;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyFilthRatePassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 6: Confessor
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero6_Confessor) then
        local Data = self.Config.Perks[HeroPerks.Hero6_Confessor].Data;
        CurrentAmount = CurrentAmount + Data.FilthFactor;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMineAmountPassiveAbility(_EntityID, _Amount)
    local Amount = _Amount or 0;
    local ResourceType = Logic.GetResourceDoodadGoodType(_EntityID);
    local ResourceAmount = Logic.GetResourceDoodadGoodAmount(_EntityID);
    local x1,y1,z1 = Logic.EntityGetPos(_EntityID);
    if ResourceAmount > 0 then
        for PlayerID = 1, GetMaxPlayers() do
            if IsPlayer(PlayerID) then
                for BombID, BombData in pairs(self.Data.ScoutBombs) do
                    if GetDistance({X= x1, Y= y1}, {X= BombData[2], Y= BombData[3]}) < 1000 then
                        -- Generic T1: Pyrotechnican
                        if self:IsPerkTriggered(PlayerID, HeroPerks.Generic_Pyrotechnican) then
                            local Data = self.Config.Perks[HeroPerks.Generic_Pyrotechnican];
                            local Percent = math.random(Data.MinResource, Data.MaxResource);
                            Amount = Amount * (Percent/100);
                        end
                        -- Hero 2: Demolitionist
                        if self:IsPerkTriggered(PlayerID, HeroPerks.Hero2_Demolitionist) then
                            local Data = self.Config.Perks[HeroPerks.Hero2_Demolitionist];
                            local Percent = math.random(Data.MinResource, Data.MaxResource);
                            Amount = Amount * (Percent/100);
                        end
                        self.Data.ScoutBombs[BombID] = nil;
                        break;
                    end
                end
            end
        end
    end
    return Amount;
end

function Stronghold.Hero.Perk:ApplyReputationHungerPenaltyPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Generic T1: Tight Belt
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_TightBelt) then
        if self.Data[_PlayerID].UnlockedPerks[HeroPerks.Generic_TightBelt] then
            local Data = self.Config.Perks[HeroPerks.Generic_TightBelt].Data;
            CurrentAmount = CurrentAmount * Data.Factor;
        end
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyReputationSleepPenaltyPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Generic T1: Tight Belt
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_TightBelt) then
        if self.Data[_PlayerID].UnlockedPerks[HeroPerks.Generic_TightBelt] then
            local Data = self.Config.Perks[HeroPerks.Generic_TightBelt].Data;
            CurrentAmount = CurrentAmount * Data.Factor;
        end
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyEnduranceRegenerationPassiveAbility(_PlayerID)
    -- Generic T1: Mood Cannon
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_MoodCannon) then
        local Data = self.Config.Perks[HeroPerks.Generic_MoodCannon].Data;
        local NobleID = GetNobleID(_PlayerID);
        local x,y,z = Logic.EntityGetPos(NobleID);
        local BuildingList = {Logic.GetPlayerEntitiesInArea(_PlayerID, 0, x, y, Data.AreaSize, 16, 8)};
        for i= 2, BuildingList[1] +1 do
            if Logic.IsConstructionComplete(BuildingList[i]) == 1 then
                local WorkerList = {Logic.GetAttachedWorkersToBuilding(BuildingList[i])};
                for j= 2, WorkerList[1] +1 do
                    if Logic.IsSettlerAtWork(WorkerList[j]) == 1 then
                        local Stamina = CEntity.GetCurrentStamina(WorkerList[j]);
                        local MaxStamina = CEntity.GetMaxStamina(WorkerList[j]);
                        if Stamina / MaxStamina >= 0.05 then
                            Stamina = math.min(Stamina + (MaxStamina * Data.Factor), MaxStamina);
                            SetEntityStamina(WorkerList[j], math.ceil(Stamina));
                        end
                    end
                end
            end
        end
    end
end

function Stronghold.Hero.Perk:ApplyRefundUnitPassiveAbility(_PlayerID, _EntityID)
    -- Generic T3: Honor the Fallen
    if Logic.IsLeader(_EntityID) == 1 then
        if self:IsPerkTriggered(_PlayerID, HeroPerks.Generic_HonorTheFallen) then
            if self.Data[_PlayerID].UnlockedPerks[HeroPerks.Generic_HonorTheFallen] then
                local Data = self.Config.Perks[HeroPerks.Generic_HonorTheFallen].Data;
                local Costs = {};
                Logic.FillLeaderCostsTable(_PlayerID, UpgradeCategory, Costs);
                AddHonor(_PlayerID, math.ceil((Costs[ResourceType.Silver] or 0) * Data.Factor));
            end
        end
    end
end

function Stronghold.Hero.Perk:ApplyFestivalCostsDiscountPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- ...
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplySermonCostsDiscountPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 6: Preacher
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero6_Preacher) then
        local Data = self.Config.Perks[HeroPerks.Hero6_Preacher].Data;
        CurrentAmount = math.ceil(CurrentAmount * Data.CostFactor);
    end
    return CurrentAmount;
end

