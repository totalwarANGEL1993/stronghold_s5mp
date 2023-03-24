--- 
--- Promotion System
--- 
--- 
--- 

Stronghold = Stronghold or {};

Stronghold.Promotion = {
    Data = {},
    Config = {
        Gender = {
            [Entities.PU_Hero1]              = Gender.Male,
            [Entities.PU_Hero1a]             = Gender.Male,
            [Entities.PU_Hero1b]             = Gender.Male,
            [Entities.PU_Hero1c]             = Gender.Male,
            [Entities.PU_Hero2]              = Gender.Male,
            [Entities.PU_Hero3]              = Gender.Male,
            [Entities.PU_Hero4]              = Gender.Male,
            [Entities.PU_Hero5]              = Gender.Female,
            [Entities.PU_Hero6]              = Gender.Male,
            [Entities.CU_BlackKnight]        = Gender.Male,
            [Entities.CU_Mary_de_Mortfichet] = Gender.Female,
            [Entities.CU_Barbarian_Hero]     = Gender.Male,
            [Entities.PU_Hero10]             = Gender.Male,
            [Entities.PU_Hero11]             = Gender.Female,
            [Entities.CU_Evil_Queen]         = Gender.Female,
        },

        Titles = {
            [Rank.Noble]    = {
                Costs       = {0, 0, 0, 0, 0, 0, 0},
                Conditions  = {},
            },
            [Rank.Mayor]    = {
                Costs       = {10, 0, 0, 0, 0, 0, 0},
                Conditions  = {},
            },
            [Rank.Earl]     = {
                Costs       = {25, 0, 0, 0, 0, 0, 0},
                Conditions  = {},
            },
            [Rank.Baron]    = {
                Costs       = {50, 0, 0, 0, 0, 0, 0},
                Conditions  = {},
            },
            [Rank.Count]    = {
                Costs       = {100, 0, 0, 0, 0, 0, 0},
                Conditions  = {},
            },
            [Rank.Margrave] = {
                Costs       = {200, 0, 0, 0, 0, 0, 0},
                Conditions  = {},
            },
            [Rank.Duke]     = {
                Costs       = {300, 0, 0, 0, 0, 0, 0},
                Conditions  = {},
            },
        }
    },
};

-- -------------------------------------------------------------------------- --
-- API

--- Returns the gender of the entity type.
function GetGender(_Type)
    return Stronghold.Promotion:GetHeroGender(_Type);
end

--- Returns the rank of the player.
function GetRank(_PlayerID)
    return Stronghold.Promotion:GetPlayerRank(_PlayerID);
end

--- Sets the rank of the player.
function SetRank(_PlayerID, _Rank)
    return Stronghold.Promotion:SetPlayerRank(_PlayerID, _Rank);
end

--- Returns the name of the rank invoking the gender of the players hero.
function GetRankName(_Rank, _PlayerID)
    return Stronghold.Promotion:GetPlayerRankName(_Rank, _PlayerID)
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Promotion:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {
            MaxRank = Stronghold.Config.Base.MaxRank,
            LockRank = Stronghold.Config.Base.MaxRank,
            Rank = Stronghold.Config.Base.InitialRank,
        };
    end
    self:CreateButtonHandlers();
end

function Stronghold.Promotion:OnSaveGameLoaded()
end

function Stronghold.Promotion:CreateButtonHandlers()
    self.SyncEvents = {
        RankUp = 1,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Promotion.SyncEvents.RankUp then
                Stronghold:PromotePlayer(_PlayerID);
                Stronghold.Promotion:OnlineHelpUpdate("OnlineHelpButton", Technologies.T_OnlineHelp);
            end
        end
    );
end

function Stronghold.Promotion:GetPlayerRank(_PlayerID)
    if self:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Rank;
    end
    return 1;
end

function Stronghold.Promotion:SetPlayerRank(_PlayerID, _Rank)
    if self:IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Rank = _Rank;
    end
end

function Stronghold.Promotion:GetHeroGender(_Type)
    if self.Config.Gender[_Type] then
        return self.Config.Gender[_Type];
    end
    return Gender.Male;
end

function Stronghold.Promotion:GetPlayerRankName(_Rank, _PlayerID)
    _PlayerID = _PlayerID or 0;
    local Language = GetLanguage();
    local Gender = Gender.Male;
    local CurrentRank = Rank.Commoner;

    if _PlayerID ~= 17 then
        CurrentRank = _Rank;
        if Stronghold:IsPlayer(_PlayerID) then
            local LordID = Stronghold:GetPlayerHero(_PlayerID);
            if LordID ~= 0 then
                Gender = GetGender(Logic.GetEntityType(LordID)) or 1;
            end
        end
    end
    return Stronghold.Text.Promotion.Title[CurrentRank][Gender][Language];
end

-- -------------------------------------------------------------------------- --
-- Requirement functions

function Stronghold.Promotion:ArePromotionRequirementsFulfilled(_PlayerID, _Rank)
    local Fulfilled = true;
    for i= 1, table.getn(self.Config.Titles[_Rank].Conditions) do
        local Condition = self.Config.Titles[_Rank].Conditions[i];
        if Condition[1] == Requirement.Headquarters then
            Fulfilled = Fulfilled and self:DoesHeadquarterOfUpgradeLevelExist(_PlayerID, Condition[2]);
        elseif Condition[1] == Requirement.Cathedral then
            Fulfilled = Fulfilled and self:DoesCathedralOfUpgradeLevelExist(_PlayerID, Condition[2]);
        elseif Condition[1] == Requirement.Workers then
            Fulfilled = Fulfilled and self:DoesWorkerAmountInSettlementExist(_PlayerID, Condition[2]);
        elseif Condition[1] == Requirement.Soldiers then
            Fulfilled = Fulfilled and self:DoesSoldierAmountInSettlementExist(_PlayerID, Condition[2]);
        elseif Condition[1] == Requirement.SettlerType then
            Fulfilled = Fulfilled and self:DoSettlersOfTypeInSettlementExist(_PlayerID, Condition[2], Condition[3]);
        elseif Condition[1] == Requirement.BuildingType then
            Fulfilled = Fulfilled and self:DoBuildingsOfTypeInSettlementExist(_PlayerID, Condition[2], Condition[3]);
        elseif Condition[1] == Requirement.Beautification then
            if Condition[2] == 1 then
                Fulfilled = Fulfilled and self:DoesBeautificationAmountInSettlementExist(_PlayerID, Condition[3]);
            else
                Fulfilled = Fulfilled and self:DoAllBeautificationsInSettlementExist(_PlayerID);
            end
        elseif Condition[1] == Requirement.Custom then
            Fulfilled = Fulfilled and self:DoCustomConditionSucceed(i, _PlayerID, Condition[2]);
        end
    end
    return Fulfilled;
end

function Stronghold.Promotion:DoesHeadquarterOfUpgradeLevelExist(_PlayerID, _Level)
    local ID = GetHeadquarterID(_PlayerID);
    if ID ~= 0 then
        return Logic.GetUpgradeLevelForBuilding(ID) >= _Level;
    end
    return false;
end

function Stronghold.Promotion:DoesCathedralOfUpgradeLevelExist(_PlayerID, _Level)
    local Cathedral1 = GetValidEntitiesOfType(_PlayerID, Entities.PB_Monastery1);
    local Cathedral2 = GetValidEntitiesOfType(_PlayerID, Entities.PB_Monastery2);
    local Cathedral3 = GetValidEntitiesOfType(_PlayerID, Entities.PB_Monastery3);
    local ID = Cathedral3[1] or Cathedral2[1] or Cathedral1[1] or 0;
    if ID ~= 0 then
        return Logic.GetUpgradeLevelForBuilding(ID) >= _Level;
    end
    return false;
end

function Stronghold.Promotion:DoesWorkerAmountInSettlementExist(_PlayerID, _Amount)
    return Logic.GetNumberOfAttractedWorker(_PlayerID) >= _Amount;
end

function Stronghold.Promotion:DoesSoldierAmountInSettlementExist(_PlayerID, _Amount)
    return Logic.GetNumberOfAttractedSoldiers(_PlayerID) >= _Amount;
end

function Stronghold.Promotion:DoSettlersOfTypeInSettlementExist(_PlayerID, _Type, _Amount)
    return Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, _Type) >= _Amount;
end

function Stronghold.Promotion:DoBuildingsOfTypeInSettlementExist(_PlayerID, _Type, _Amount)
    return table.getn(GetValidEntitiesOfType(_PlayerID, _Type)) >= _Amount;
end

function Stronghold.Promotion:DoesBeautificationAmountInSettlementExist(_PlayerID, _Amount)
    local Amount = 0;
    for i= 1, 12 do
        local Type = "PB_Beautification" .. ((i < 10 and "0"..i) or i);
        Amount = Amount + table.getn(GetValidEntitiesOfType(_PlayerID, Entities[Type]));
    end
    return Amount >= _Amount;
end

function Stronghold.Promotion:DoAllBeautificationsInSettlementExist(_PlayerID)
    for i= 1, 12 do
        local Type = "PB_Beautification" .. ((i < 10 and "0"..i) or i);
        if table.getn(GetValidEntitiesOfType(_PlayerID, Entities[Type])) < 1 then
            return false;
        end
    end
    return true;
end

function Stronghold.Promotion:DoCustomConditionSucceed(_i, _PlayerID, _Function)
    return _Function(_PlayerID, _i);
end

-- -------------------------------------------------------------------------- --
-- Rank Up Button

function Stronghold.Promotion:OnlineHelpAction()
    local PlayerID = GUI.GetPlayerID();
    if not Stronghold:IsPlayerInitalized(PlayerID) then
        return false;
    end
    local CurrentRank = GetRank(PlayerID);
    local NextRank = self.Config.Titles[CurrentRank+1];
    if NextRank then
        local Costs = Stronghold:CreateCostTable(unpack(NextRank.Costs));
        if not HasPlayerEnoughResourcesFeedback(Costs) then
            return true;
        end
    end
    if Stronghold:CanPlayerBePromoted(PlayerID) then
        Syncer.InvokeEvent(
            Stronghold.Promotion.NetworkCall,
            Stronghold.Promotion.SyncEvents.RankUp
        );
    end
    return true;
end

function Stronghold.Promotion:OnlineHelpTooltip(_Key)
    if _Key == "MenuMap/OnlineHelp" then
        local Language = GetLanguage();
        local CostText = "";
        local Text = "";

        local PlayerID = Stronghold:GetLocalPlayerID();
        local NextRank = GetRank(PlayerID) +1;
        if  PlayerID ~= 17 and self.Config.Titles[NextRank]
        and NextRank <= self.Data[PlayerID].MaxRank
        and NextRank < self.Data[PlayerID].LockRank then
            local Config = self.Config.Titles[NextRank];
            local Costs = Stronghold:CreateCostTable(unpack(Config.Costs));
            Text = string.format(
                Stronghold.Text.Promotion.NewRank[1][Language],
                GetRankName(NextRank, PlayerID),
                (Config.Description and Config.Description[Language]) or ""
            );
            CostText = Stronghold:FormatCostString(PlayerID, Costs);
        else
            Text = Stronghold.Text.Promotion.NewRank[2][Language];
        end

        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostText);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return true;
    end
    return false;
end

function Stronghold.Promotion:OnlineHelpUpdate(_PlayerID, _Button, _Technology)
    if _Button == "OnlineHelpButton" then
        local Texture = "graphics/textures/gui/b_rank_f2.png";
        if GUI.GetPlayerID() == _PlayerID then
            local Disabled = 1;
            if Stronghold:IsPlayerInitalized(_PlayerID) then
                local CurrentRank = GetRank(_PlayerID);
                Texture = "graphics/textures/gui/b_rank_" ..CurrentRank.. ".png";
                if CurrentRank >= Stronghold.Config.Base.MaxRank then
                    Texture = "graphics/textures/gui/b_rank_f1.png";
                end
                if Stronghold:CanPlayerBePromoted(_PlayerID) then
                    Disabled = 0;
                end
            end
            for i= 0, 6 do
                XGUIEng.SetMaterialTexture(_Button, i, Texture);
            end
            XGUIEng.DisableButton(_Button, Disabled);
            return true;
        end
    end
    return false;
end

