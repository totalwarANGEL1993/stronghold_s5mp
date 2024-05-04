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

function AddAuthority(_PlayerID, _Amount)
    Stronghold.Hero.Perk:AddPlayerAuthority(_PlayerID, _Amount);
end

function GetAuthority(_PlayerID)
    return Stronghold.Hero.Perk:GetPlayerAuthority(_PlayerID);
end

function GetAuthorityForRank(_PlayerID, _Rank)
    return Stronghold.Hero.Perk:GetGrantedAuthorityForRank(_PlayerID, _Rank);
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
            Authority = 0,
        };
    end
    self:OverwriteGameCallbacks();
    self:OwerwriteAdditionalGameCallbacks();
end

function Stronghold.Hero.Perk:OnSaveGameLoaded()
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
            self.Data[PlayerID].ScoutBombs[_EntityID] = {Logic.GetCurrentTurn(), x, y};
        end
    end
    -- Pit amount
    local Amount = Logic.GetResourceDoodadGoodAmount(_EntityID);
    if Amount > 0 then
        Amount = self:ApplyMineAmountPassiveAbility(_EntityID, Amount);
        Logic.SetResourceDoodadGoodAmount(_EntityID, math.ceil(Amount));
    end
end

function Stronghold.Hero.Perk:OncePerSecond(_PlayerID)
end

-- -------------------------------------------------------------------------- --

function Stronghold.Hero.Perk:SetupPerksForPlayerHero(_PlayerID, _Type)
    if IsPlayer(_PlayerID) then
        -- Authority
        for Rank = 1, GetRank(_PlayerID) do
            local Authority = self.Data[_PlayerID].Authority;
            local Gain = self.Config.Skill.GainedPoints[Rank];
            self.Data[_PlayerID].Authority = Authority + Gain;
        end

        -- Perks
        self.Data[_PlayerID].UnlockedPerks = {};
        if PlayerHasLordOfType(_PlayerID, "^PU_Hero1[abc]+$") then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero1_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Kingsguard);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero1_Mobilization);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero1_SocialCare);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero1_SolemnAuthority);
        end
        if _Type == Entities.PU_Hero2 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero2_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Lancer);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Axemen);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero2_FortressMaster);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero2_ExtractResources);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero2_Demolitionist);
        end
        if _Type == Entities.PU_Hero3 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero3_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Lancer);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Cannons);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero3_AtileryExperte);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero3_MasterOfArts);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero3_MercenaryCost);
        end
        if _Type == Entities.PU_Hero4 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero4_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteLongbow);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteCavalry);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero4_GrandMaster);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero4_ExperiencedInstructor);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero4_Marschall);
        end
        if _Type == Entities.PU_Hero5 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero5_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Bandits);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero5_ChildOfNature);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero5_TaxBonus);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero5_HubertusBlessing);
        end
        if _Type == Entities.PU_Hero6 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero6_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Templars);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero6_Confessor);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero6_ConvertSettler);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero6_Preacher);
        end
        if _Type == Entities.CU_BlackKnight then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero7_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero7_Paranoid);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_BlackKnights);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero7_Moloch);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero7_ArmyOfDarkness);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero7_Tyrant);
        end
        if _Type == Entities.CU_Mary_de_Mortfichet then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero8_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero8_Underhanded);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteCavalry);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Assassins);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero8_AgentMaster);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero8_AssassinMaster);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero8_SlaveMaster);
        end
        if _Type == Entities.CU_Barbarian_Hero then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero9_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Barbarians);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero9_BerserkerRage);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero9_CriticalDrinker);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero9_Mobilization);
        end
        if _Type == Entities.PU_Hero10 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero10_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Lancer);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteRifle);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero10_SlaveMaster);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero10_GunManufacturer);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero10_MusketeersOath);
        end
        if _Type == Entities.PU_Hero11 then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero11_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteLongbow);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteRifle);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero11_TradeMaster);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero11_LandOfTheSmile);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero11_UseShuriken);
        end
        if _Type == Entities.CU_Evil_Queen then
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero12_Ability);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_EliteLongbow);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Unit_Evil);
            -- Remove this after skilltree implementation:
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero12_FertilityIcon);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero12_Moloch);
            self:UnlockPerkForPlayer(_PlayerID, HeroPerks.Hero12_MothersComfort);
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
            if Config.Chance and Config.Chance < 100 then
                return RandomNumber(HeroID) <= Config.Chance;
            end
            return true;
        end
    end
    return false;
end

function Stronghold.Hero.Perk:RollDiceForPerk(_Perk, _EntityID)
    return false;
end

function Stronghold.Hero.Perk:HasPlayerUnlockedPerk(_PlayerID, _Perk)
    if IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].UnlockedPerks[_Perk] == true;
    end
    return false;
end

function Stronghold.Hero.Perk:UnlockPerkForPlayer(_PlayerID, _Perk)
    if IsPlayer(_PlayerID) then
        if not self.Data[_PlayerID].UnlockedPerks[_Perk] then
            self.Data[_PlayerID].UnlockedPerks[_Perk] = true;
            self:OnPerkUnlockedSpecialAction(_PlayerID, _Perk);
            GameCallback_SH_Logic_OnPerkUnlocked(_PlayerID, _Perk);
        end
    end
end

function Stronghold.Hero.Perk:GetPlayerAuthority(_PlayerID)
    if IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Authority;
    end
    return 0;
end

function Stronghold.Hero.Perk:GetGrantedAuthorityForRank(_PlayerID, _Rank)
    if IsPlayer(_PlayerID) then
        -- TODO: Add perks that increase points?
        return self.Config.Skill.GainedPoints[_Rank] or 0;
    end
    return 0;
end

function Stronghold.Hero.Perk:AddPlayerAuthority(_PlayerID, _Amount)
    if IsPlayer(_PlayerID) then
        local CurrentAmount = self.Data[_PlayerID].Authority;
        self.Data[_PlayerID].Authority = CurrentAmount + _Amount;
    end
end

-- -------------------------------------------------------------------------- --

function Stronghold.Hero.Perk:OwerwriteAdditionalGameCallbacks()
    Overwrite.CreateOverwrite("GameCallback_SH_Logic_OnAttackRegisterIteration", function(_PlayerID, _AttackedID, _AttackerID, _TimeRemaining)
        Overwrite.CallOriginal();
        Stronghold.Hero.Perk:HeliasConvertController(_PlayerID, _AttackedID, _AttackerID);
        Stronghold.Hero.Perk:YukiShurikenConterController(_PlayerID, _AttackedID, _AttackerID);
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Logic_PlayerPromoted", function(_PlayerID, _OldRank, _NewRank)
        Overwrite.CallOriginal();
        Stronghold.Hero.Perk:OnPlayerPromoted(_PlayerID, _OldRank, _NewRank);
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

function Stronghold.Hero.Perk:OnPlayerPromoted(_PlayerID, _OldRank, _NewRank)
    if IsPlayer(_PlayerID) and GetNobleID(_PlayerID) ~= 0 then
        AddAuthority(_PlayerID, GetAuthorityForRank(_PlayerID, _NewRank));
    end
end

-- -------------------------------------------------------------------------- --

function Stronghold.Hero.Perk:OverwriteGameCallbacks()
    -- Generic --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ResourceMined", function(_PlayerID, _BuildingID, _SourceID, _ResourceType, _Amount, _Remaining)
        local CurrentAmount, RemainingAmount = Overwrite.CallOriginal();
        CurrentAmount, ResourceRemaining = Stronghold.Hero.Perk:ResourceProductionBonus(_PlayerID, _BuildingID, _SourceID, _ResourceType, CurrentAmount, RemainingAmount);
        return CurrentAmount, ResourceRemaining;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_SerfExtraction", function(_PlayerID, _SerfID, _SourceID, _ResourceType, _Amount, _Remaining)
        local CurrentAmount, RemainingAmount = Overwrite.CallOriginal();
        CurrentAmount, ResourceRemaining = Stronghold.Hero.Perk:SerfExtractionBonus(_PlayerID, _SerfID, _SourceID, _ResourceType, CurrentAmount, RemainingAmount);
        return CurrentAmount, ResourceRemaining;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ResourceRefined", function(_PlayerID, _BuildingID, _ResourceType, Amount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ResourceRefiningBonus(_PlayerID, _BuildingID, _ResourceType, CurrentAmount);
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
        CurrentAmount = Stronghold.Hero.Perk:ApplyCalculateBattleDamage(_AttackerID, _AttackedID, _Damage);
        return CurrentAmount;
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

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_DynamicReputationIncrease", function(_PlayerID, _Type, _CurrentAmount)
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

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_DynamicHonorIncrease", function(_PlayerID, _Type, _CurrentAmount)
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

    -- Money --

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_TotalPaydayIncome", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyIncomeBonusPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_TotalPaydayUpkeep", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyUpkeepDiscountPassiveAbility(_PlayerID, _CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_PaydayUpkeep", function(_PlayerID, _UnitType, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyUnitUpkeepDiscountPassiveAbility(_PlayerID, _UnitType, CurrentAmount)
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

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_HonorFromSermon", function(_PlayerID, _BlessCategory, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyHonorSermonPassiveAbility(_PlayerID, _BlessCategory, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ReputationFromSermon", function(_PlayerID, _BlessCategory, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero.Perk:ApplyReputationSermonPassiveAbility(_PlayerID, _BlessCategory, CurrentAmount);
        return CurrentAmount;
    end);
end

-- -------------------------------------------------------------------------- --

function Stronghold.Hero.Perk:ResourceProductionBonus(_PlayerID, _BuildingID, _SourceID, _ResourceType, _CurrentAmount, _RemainingAmount)
    local CurrentAmount, RemainingAmount = _CurrentAmount, _RemainingAmount;
    -- Hero 2: Extract Resources
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero2_ExtractResources) then
        if _ResourceType ~= ResourceType.WoodRaw then
            local Data = self.Config.Perks[HeroPerks.Hero2_ExtractResources].Data;
            CurrentAmount = CurrentAmount + Data.Amount;
        end
    end
end

function Stronghold.Hero.Perk:SerfExtractionBonus(_PlayerID, _SerfID, _SourceID, _ResourceType, _CurrentAmount, _RemainingAmount)
    local CurrentAmount, RemainingAmount = _CurrentAmount, _RemainingAmount;
    -- Hero 5: Wood Chopping
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero5_ChildOfNature) then
        local Data = self.Config.Perks[HeroPerks.Hero5_ChildOfNature].Data;
        if _ResourceType == ResourceType.WoodRaw then
            Logic.AddToPlayersGlobalResource(_PlayerID, ResourceType.Wood, Data.WoodBonus);
        elseif RandomNumber(_SerfID) <= Data.PreservationChance then
            RemainingAmount = RemainingAmount + Data.SerfPreservation;
        end
    end
    return CurrentAmount, RemainingAmount;
end

function Stronghold.Hero.Perk:ResourceRefiningBonus(_PlayerID, _BuildingID, _ResourceType, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
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

function Stronghold.Hero.Perk:ApplyCalculateBattleDamage(_AttackerID, _AttackedID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    local AttackerPlayerID = Logic.EntityGetPlayer(_AttackerID);
    local AttackerType = Logic.GetEntityType(_AttackerID);
    local AttackedPlayerID = Logic.EntityGetPlayer(_AttackedID);
    local AttackedType = Logic.GetEntityType(_AttackedID);

    -- Damage delt --

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

    -- Hero 4: Marschall
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero4_Marschall) then
        local Data = self.Config.Perks[HeroPerks.Hero4_Marschall].Data;
        if Data.EntityTypes[AttackedType] then
            local DamageClass = CInterface.Logic.GetEntityTypeDamageClass(AttackerType);
            if Data.DamageClasses[DamageClass] then
                CurrentAmount = CurrentAmount * Data.Factor;
            end
        end
    end
    -- Hero 4: Hubertus Blessing
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero5_HubertusBlessing) then
        local Data = self.Config.Perks[HeroPerks.Hero5_HubertusBlessing].Data;
        if Data.EntityTypes[AttackedType] then
            CurrentAmount = CurrentAmount * Data.Factor;
        end
    end
    -- Hero 9: Berserker Rage
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero9_BerserkerRage) then
        local Data = self.Config.Perks[HeroPerks.Hero9_BerserkerRage].Data;
        if Data.EntityTypes[AttackedType] then
            CurrentAmount = CurrentAmount * Data.DamageTakenFactor;
        end
    end
    -- Hero 12: Mothers Comfort
    if self:IsPerkTriggered(AttackedPlayerID, HeroPerks.Hero12_MothersComfort) then
        local Data = self.Config.Perks[HeroPerks.Hero12_MothersComfort].Data;
        if Data.EntityTypes[AttackedType] then
            local DamageClass = CInterface.Logic.GetEntityTypeDamageClass(AttackerType);
            if Data.DamageClasses[DamageClass] then
                CurrentAmount = CurrentAmount * Data.DamageTakenFactor;
            end
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
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyReputationDecreasePassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 7: Tyrant
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero7_Tyrant) then
        if self.Data[_PlayerID].UnlockedPerks[HeroPerks.Hero7_Tyrant] then
            local Data = self.Config.Perks[HeroPerks.Hero7_Tyrant].Data;
            CurrentAmount = CurrentAmount * Data.Factor;
        end
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyHonorBonusPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 1: Social Care
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero1_SocialCare) then
        local Data = self.Config.Perks[HeroPerks.Hero1_SocialCare].Data;
        CurrentAmount = CurrentAmount * Data.HonorFactor;
    end
    return CurrentAmount;
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
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMercenaryCostPassiveAbility(_PlayerID, _Type, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 3: Mercenary Cost
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero3_MercenaryCost) then
        local Data = self.Config.Perks[HeroPerks.Hero3_MercenaryCost].Data;
        CurrentAmount = Data.FactorOverwrite;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMercenaryExperiencePassiveAbility(_PlayerID, _Type, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 3: Mercenary Cost
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero3_MercenaryCost) then
        local Data = self.Config.Perks[HeroPerks.Hero3_MercenaryCost].Data;
        CurrentAmount = Data.ExperienceOverwrite;
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

function Stronghold.Hero.Perk:ApplyIncomeBonusPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
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
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyUpkeepDiscountPassiveAbility(_PlayerID, _CurrentAmount)
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
    -- Hero 12: Fertility Icon
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero12_FertilityIcon) then
        local Data = self.Config.Perks[HeroPerks.Hero12_FertilityIcon].Data;
        CurrentAmount = CurrentAmount * Data.Factor;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyCivilAttractionPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyMaxMilitaryAttractionPassiveAbility(_PlayerID, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 1: Mobilization
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero1_Mobilization) then
        local Data = self.Config.Perks[HeroPerks.Hero1_Mobilization].Data;
        CurrentAmount = CurrentAmount * Data.Factor;
    end
    -- Hero 9: Mobilization
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero9_Mobilization) then
        local Data = self.Config.Perks[HeroPerks.Hero9_Mobilization].Data;
        CurrentAmount = CurrentAmount * Data.Factor;
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
        -- Knights Malus
        if self.Data[_PlayerID].UnlockedPerks[HeroPerks.Unit_Bandits]
        or self.Data[_PlayerID].UnlockedPerks[HeroPerks.Unit_Cannons]
        then
            if _Type == Entities.CU_TemplarLeaderHeavyCavalry1
            or _Type == Entities.PU_LeaderHeavyCavalry1
            or _Type == Entities.PU_LeaderHeavyCavalry2 then
                CurrentAmount = CurrentAmount + 1;
            end
        end
        -- Sharpshooters Malus
        if self.Data[_PlayerID].UnlockedPerks[HeroPerks.Unit_EliteCavalry]
        or self.Data[_PlayerID].UnlockedPerks[HeroPerks.Unit_Templars]
        or self.Data[_PlayerID].UnlockedPerks[HeroPerks.Unit_Barbarians]
        or self.Data[_PlayerID].UnlockedPerks[HeroPerks.Unit_Evil]
        then
            if _Type == Entities.PU_LeaderRifle1
            or _Type == Entities.PU_LeaderRifle2 then
                CurrentAmount = CurrentAmount + 1;
            end
        end
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

function Stronghold.Hero.Perk:ApplyHonorSermonPassiveAbility(_PlayerID, _BlessCategory, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
    -- Hero 6: Preacher
    if self:IsPerkTriggered(_PlayerID, HeroPerks.Hero6_Preacher) then
        local Data = self.Config.Perks[HeroPerks.Hero6_Preacher].Data;
        CurrentAmount = CurrentAmount + Data.Bonus;
    end
    return CurrentAmount;
end

function Stronghold.Hero.Perk:ApplyReputationSermonPassiveAbility(_PlayerID, _BlessCategory, _CurrentAmount)
    local CurrentAmount = _CurrentAmount;
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
                for BombID, BombData in pairs(self.Data[PlayerID].ScoutBombs) do
                    if GetDistance({X= x1, Y= y1}, {X= BombData[2], Y= BombData[3]}) < 1000 then
                        if self:IsPerkTriggered(PlayerID, HeroPerks.Hero2_Demolitionist) then
                            local Data = self.Config.Perks[HeroPerks.Hero2_Demolitionist];
                            local Percent = RandomNumber(_EntityID, Data.MinResource, Data.MaxResource);
                            Amount = Amount * (Percent/100);
                        end
                        self.Data[PlayerID].ScoutBombs[BombID] = nil;
                        break;
                    end
                end
            end
        end
    end
    return Amount;
end

