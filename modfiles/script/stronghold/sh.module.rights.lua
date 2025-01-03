--- 
--- Rights System
---
--- This script implements a promotion system with duties and rights much like
--- in Settlers 6. Some conditions must be fulfilled to climb up the ladder to
--- a higher rank.
--- 

Stronghold = Stronghold or {};

Stronghold.Rights = {
    SyncEvents = {},
    Config = {},
    Data = {},
    Text = {},
};

-- -------------------------------------------------------------------------- --
-- API

--- Returns the rank of the player.
--- @param _PlayerID integer ID of player
--- @return integer Rank Current rank
function GetRank(_PlayerID)
    return Stronghold.Rights:GetPlayerRank(_PlayerID);
end

--- Locks an rank and all ranks after it.
--- @param _PlayerID integer ID of player
--- @param _Rank integer Rank to lock
function LockRank(_PlayerID, _Rank)
    Stronghold.Rights:LockPlayerRank(_PlayerID, _Rank);
end

--- Sets the rank of the player.
--- @param _PlayerID integer ID of player
--- @param _Rank integer Rank to set
function SetRank(_PlayerID, _Rank)
    local CurrentRank = GetRank(_PlayerID);
    for i= 1, _Rank - CurrentRank do
        Stronghold.Rights:PromotePlayer(_PlayerID, true, false);
    end
end

--- Promotes the player to the next rank. The requirements must be fulfulled
--- and costs will be subtracted.
--- @param _PlayerID integer ID of player
--- @param _NoFeedback boolean Do not informplayer
function PromotePlayer(_PlayerID, _NoFeedback)
    Stronghold.Rights:PromotePlayer(_PlayerID, false, not _NoFeedback);
end

--- Enforces the players promotion to the next rank. The requirements are
--- ignored and costs will not be substracted.
--- @param _PlayerID integer ID of player
--- @param _NoFeedback boolean Do not informplayer
function ForcePromotePlayer(_PlayerID, _NoFeedback)
    Stronghold.Rights:PromotePlayer(_PlayerID, true, not _NoFeedback);
end

--- Returns the name of the rank invoking the gender of the players hero.
--- @param _Rank integer ID of Rank
--- @param _PlayerID integer ID of player
--- @return string Name Name of rank
function GetRankName(_Rank, _PlayerID)
    return Stronghold.Rights:GetPlayerRankName(_Rank, _PlayerID)
end

--- Returns the rank required for the right.
--- @param _PlayerID integer ID of player
--- @param _Right integer ID of right
--- @return integer Rank Rank required
function GetRankRequired(_PlayerID, _Right)
    return Stronghold.Rights:GetRankRequiredForRight(_PlayerID, _Right);
end

--- Changes rights and duties for the player.
--- @param _PlayerID integer ID of player
--- @param _Data table Rights and duties
function SetRightsAndDuties(_PlayerID, _Data)
    Stronghold.Rights:ChangeRightsAndDutiesForPlayer(_PlayerID, _Data);
end

--- Checks if a player has a right unlocked.
--- @param _PlayerID integer ID of player
--- @param _Right integer ID of right
--- @return boolean Unlocked Right is unlocked
function HasRight(_PlayerID, _Right)
    return Stronghold.Rights:HasPlayerRight(_PlayerID, _Right);
end

--- Checks if the right is unlockable by the player.
--- @param _PlayerID integer ID of player
--- @param _Right integer ID of right
--- @return boolean Unlockable Right can be unlocked
function IsRightUnlockable(_PlayerID, _Right)
    return Stronghold.Rights:IsRightUnlockable(_PlayerID, _Right);
end

--- Locks a right for the player so that they can not obtain it.
--- @param _PlayerID integer ID of player
--- @param _Right integer ID of right
function LockPlayerRight(_PlayerID, _Right)
    Stronghold.Rights:LockPlayerRight(_PlayerID, _Right);
end

--- Unlocks a right for the player so that they can use it.
--- @param _PlayerID integer ID of player
--- @param _Right integer ID of right
function UnlockPlayerRight(_PlayerID, _Right)
    Stronghold.Rights:UnlockPlayerRight(_PlayerID, _Right);
end

--- Checks if a right is locked for the player
--- @param _PlayerID integer ID of player
--- @param _Right integer ID of right
--- @return boolean IsLocked Right is locked
function IsRightLockedForPlayer(_PlayerID, _Right)
    return Stronghold.Rights:IsRightLockedForPlayer(_PlayerID, _Right);
end

--- Returns the gender of the entity type.
--- @param _Type integer Type of entity
--- @return integer Gender Gender of entity
function GetGender(_Type)
    return Stronghold.Rights:GetHeroGender(_Type);
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

--- Triggered after a player has been promoted.
--- @param _PlayerID integer ID of player
--- @param _OldRank integer Previous rank
--- @param _NewRank integer New rank
function GameCallback_SH_Logic_PlayerPromoted(_PlayerID, _OldRank, _NewRank)
end

--- Triggered after a player reached the highest rank.
--- @param _PlayerID integer ID of player
--- @param _Rank integer Rank
function GameCallback_SH_Logic_PlayerReachedHighestRank(_PlayerID, _Rank)
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Rights:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            MaxRank = Stronghold.Player.Config.Base.MaxRank,
            LockRank = Stronghold.Player.Config.Base.MaxRank +1,
            Rank = Stronghold.Player.Config.Base.InitialRank,

            Titles = CopyTable(self.Config.Titles);
            Rights = {},
        };
        self:InitDutiesAndRights(i, self.Config.Titles);
    end
    self:CreateButtonHandlers();
end

function Stronghold.Rights:OnSaveGameLoaded()
end

function Stronghold.Rights:CreateButtonHandlers()
    self.SyncEvents = {
        RankUp = 1,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Rights.SyncEvents.RankUp then
                Stronghold.Rights:PromotePlayer(_PlayerID, false, true);
                if _PlayerID == GUI.GetPlayerID() or GUI.GetPlayerID() == 17 then
                    Stronghold.Rights:OnlineHelpUpdate(_PlayerID, "OnlineHelpButton", Technologies.T_OnlineHelp);
                    GameCallback_GUI_SelectionChanged();
                end
            end
        end
    );
end

function Stronghold.Rights:OnEveryTurn(_PlayerID)
    -- Update promote button
    Stronghold.Rights:OnlineHelpUpdate(_PlayerID, "OnlineHelpButton", Technologies.T_OnlineHelp);
end

-- -------------------------------------------------------------------------- --
-- Attributes

function Stronghold.Rights:GetPlayerRank(_PlayerID)
    if IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Rank;
    end
    return 1;
end

function Stronghold.Rights:GetPlayerMaxRank(_PlayerID)
    return math.min(self.Data[_PlayerID].MaxRank, self.Data[_PlayerID].LockRank);
end

function Stronghold.Rights:SetPlayerRank(_PlayerID, _Rank)
    if IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Rank = _Rank;
        self:GrantPlayerRights(_PlayerID, _Rank);
    end
end

function Stronghold.Rights:SetPlayerMaxRank(_PlayerID, _Rank)
    if IsPlayer(_PlayerID) then
        self.Data[_PlayerID].LockRank = _Rank;
    end
end

function Stronghold.Rights:GetHeroGender(_Type)
    if self.Config.Gender[_Type] then
        return self.Config.Gender[_Type];
    end
    return Gender.Male;
end

function Stronghold.Rights:GetPlayerRankName(_Rank, _PlayerID)
    _PlayerID = _PlayerID or 0;
    local Language = GetLanguage();
    local Gender = Gender.Male;
    local CurrentRank = PlayerRank.Commoner;

    if _PlayerID ~= 17 then
        CurrentRank = _Rank;
        if IsPlayer(_PlayerID) then
            local LordID = GetNobleID(_PlayerID);
            if LordID ~= 0 then
                Gender = GetGender(Logic.GetEntityType(LordID)) or 1;
            end
        end
    end
    if CurrentRank == -1 then
        return "-";
    end
    local Key = "Rank" ..CurrentRank.. "_" ..((Gender == 1 and "Male") or "Female");
    return XGUIEng.GetStringTableText("sh_menurights/" ..Key);
end

-- -------------------------------------------------------------------------- --
-- Rights

function Stronghold.Rights:InitDutiesAndRights(_PlayerID, _RightsAndDuties)
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        local RightsAndDuties = CopyTable(_RightsAndDuties or self.Config.Titles);
        self.Data[_PlayerID].Titles = RightsAndDuties;
        self.Data[_PlayerID].Rights = {};
        for k,v in pairs(RightsAndDuties) do
            for _, RightToUnlock in pairs(RightsAndDuties[k].Rights) do
                self.Data[_PlayerID].Rights[RightToUnlock] = 0;
            end
        end
    end
end

function Stronghold.Rights:ChangeRightsAndDutiesForPlayer(_PlayerID, _Data)
    if IsPlayer(_PlayerID) then
        -- Change player rights and duties
        for k,v in pairs(_Data) do
            local RankKey = KeyOf(k, PlayerRank);
            assert(_Data[k] ~= nil, "PlayerRanks." ..RankKey.. " is missing from data table!");
            self.Data[_PlayerID].Titles[k].Duties = CopyTable(_Data[k].Duties or {});
            self.Data[_PlayerID].Titles[k].Rights = CopyTable(_Data[k].Rights or {});
        end
        -- Update unlocked rights
        self.Data[_PlayerID].Rights = {};
        for i= 1, GetRank(_PlayerID) do
            self:GrantPlayerRights(_PlayerID, i);
        end
    end
end

function Stronghold.Rights:LockPlayerRank(_PlayerID, _Rank)
    if IsPlayer(_PlayerID) then
        self.Data[_PlayerID].LockRank = _Rank;
    end
end

function Stronghold.Rights:LockPlayerRight(_PlayerID, _RightToLock)
    if IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Rights[_RightToLock] = -1;
        if GUI.GetPlayerID() == _PlayerID then
            Stronghold:OnSelectionMenuChanged(GUI.GetSelectedEntity());
        end
    end
end

function Stronghold.Rights:UnlockPlayerRight(_PlayerID, _RightToLock)
    if IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Rights[_RightToLock] = 0;
        for i= 0, GetRank(_PlayerID) do
            self:GrantPlayerRights(_PlayerID, i);
        end
        if GUI.GetPlayerID() == _PlayerID then
            Stronghold:OnSelectionMenuChanged(GUI.GetSelectedEntity());
        end
    end
end

function Stronghold.Rights:IsRightLockedForPlayer(_PlayerID, _RightToLock)
    if IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Rights[_RightToLock] == -1;
    end
    return false;
end

function Stronghold.Rights:GrantPlayerRights(_PlayerID, _Rank)
    if IsPlayer(_PlayerID) then
        for i= 1, table.getn(self.Data[_PlayerID].Titles[_Rank].Rights) do
            local RightToGrant = self.Data[_PlayerID].Titles[_Rank].Rights[i];
            if self.Data[_PlayerID].Rights[RightToGrant] ~= -1 then
                self.Data[_PlayerID].Rights[RightToGrant] = 1;
            end
        end
    end
end

function Stronghold.Rights:HasPlayerRight(_PlayerID, _Right)
    if IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Rights[_Right] == 1;
    end
end

function Stronghold.Rights:IsRightUnlockable(_PlayerID, _Right)
    if IsPlayer(_PlayerID) then
        for Title,_ in pairs(self.Data[_PlayerID].Titles) do
            for k,v in pairs(self.Data[_PlayerID].Titles[Title].Rights) do
                if v == _Right then
                    return true;
                end
            end
        end
    end
    return false;
end

function Stronghold.Rights:GetRankRequiredForRight(_PlayerID, _Right)
    if IsPlayer(_PlayerID) then
        for t,_ in pairs(self.Data[_PlayerID].Titles) do
            for j= 1, table.getn(self.Data[_PlayerID].Titles[t].Rights) do
                if self.Data[_PlayerID].Titles[t].Rights[j] == _Right then
                    return t;
                end
            end
        end
        return -1;
    end
    return 0;
end

-- -------------------------------------------------------------------------- --
-- Duties

function Stronghold.Rights:GetDutyDescription(_PlayerID, _Index, _Type, ...)
    local Lang = GetLanguage();
    local Text = "";
    if _Type == PlayerDuty.Headquarters then
        Text = XGUIEng.GetStringTableText("sh_menurights/Require_Headquarters" ..(arg[1] +1));
    elseif _Type == PlayerDuty.Cathedral then
        Text = XGUIEng.GetStringTableText("sh_menurights/Require_Monastery" ..(arg[1] +1));
    elseif _Type == PlayerDuty.Settlers then
        if arg[1] == 1 then
            local TypeName = Logic.GetEntityTypeName(arg[2]);
            local Amount = self:GetSettlersOfTypeInSettlement(_PlayerID, arg[2]);
            local Name = XGUIEng.GetStringTableText("Names/" ..TypeName);
            Text = string.format("%d/%d %s", Amount, arg[3], Name);
        else
            local Amount = self:GetWorkerAmountInSettlement(_PlayerID);
            Text = XGUIEng.GetStringTableText("sh_menurights/Require_Worker");
            Text = string.format("%d/%d %s", Amount, arg[2], Text);
        end
    elseif _Type == PlayerDuty.Beautification then
        if arg[1] == 1 then
            local Amount = self:GetBeautificationAmountInSettlement(_PlayerID);
            Text = XGUIEng.GetStringTableText("sh_menurights/Require_Beautification");
            Text = string.format("%d/%d %s", Amount, arg[2], Text);
        else
            Text = XGUIEng.GetStringTableText("sh_menurights/Require_Beautifications");
        end
    elseif _Type == PlayerDuty.Soldiers then
        local Amount = self:GetSoldierAmountInSettlement(_PlayerID);
        Text = XGUIEng.GetStringTableText("sh_menurights/Require_Soldiers");
        Text = string.format("%d/%d %s", Amount, arg[1], Text);
    elseif _Type == PlayerDuty.Workplaces then
        local Amount = self:GetWorkplaceAmountInSettlement(_PlayerID);
        Text = XGUIEng.GetStringTableText("sh_menurights/Require_Workplaces");
        Text = string.format("%d/%d %s", Amount, arg[1], Text);
    elseif _Type == PlayerDuty.Technology then
        local TechnologyKey = KeyOf(arg[1], Technologies);
        Text = XGUIEng.GetStringTableText("Names/" ..TechnologyKey);
    elseif _Type == PlayerDuty.Custom then
        local Fulfilled, Amount, Required = self:DoCustomConditionSucceed(_Index, _PlayerID, Condition[3]);
        Text = (type(arg[1]) == "table" and arg[1][Lang]) or arg[1];
        if Amount and Required then
            Text = Amount.. "/" ..Required.. " " ..Text;
        end
    elseif _Type == PlayerDuty.Noble then
        Text = XGUIEng.GetStringTableText("sh_menurights/Require_Noble");
    end
    return Text;
end

function Stronghold.Rights:GetDutiesDescription(_PlayerID, _Rank)
    local Duties = self.Config.Titles[_Rank].Duties;
    if IsPlayer(_PlayerID) then
        Duties = self.Data[_PlayerID].Titles[_Rank].Duties;
    end

    local Text = "";
    for i= 1, table.getn(Duties) do
        Text = Text .. ((i > 1 and ", ") or "");
        Text = Text .. self:GetDutyDescription(_PlayerID, i, unpack(Duties[i]));
    end
    return Text;
end

function Stronghold.Rights:ArePromotionRequirementsFulfilled(_PlayerID, _Rank)
    local Fulfilled = true;
    for i= 1, table.getn(self.Config.Titles[_Rank].Duties) do
        local Condition = self.Config.Titles[_Rank].Duties[i];
        if Condition[1] == PlayerDuty.Headquarters then
            Fulfilled = Fulfilled and self:DoesHeadquarterOfUpgradeLevelExist(_PlayerID, Condition[2]);
        elseif Condition[1] == PlayerDuty.Cathedral then
            Fulfilled = Fulfilled and self:DoesCathedralOfUpgradeLevelExist(_PlayerID, Condition[2]);
        elseif Condition[1] == PlayerDuty.Settlers then
            if Condition[2] == 1 then
                Fulfilled = Fulfilled and self:DoSettlersOfTypeInSettlementExist(_PlayerID, Condition[3], Condition[4]);
            else
                Fulfilled = Fulfilled and self:DoesWorkerAmountInSettlementExist(_PlayerID, Condition[3]);
            end
        elseif Condition[1] == PlayerDuty.Beautification then
            if Condition[2] == 1 then
                Fulfilled = Fulfilled and self:DoesBeautificationAmountInSettlementExist(_PlayerID, Condition[3]);
            else
                Fulfilled = Fulfilled and self:DoAllBeautificationsInSettlementExist(_PlayerID);
            end
        elseif Condition[1] == PlayerDuty.Workplaces then
            Fulfilled = Fulfilled and self:DoesWorkplaceAmountInSettlementExist(_PlayerID, Condition[2]);
        elseif Condition[1] == PlayerDuty.Soldiers then
            Fulfilled = Fulfilled and self:DoesSoldierAmountInSettlementExist(_PlayerID, Condition[2]);
        elseif Condition[1] == PlayerDuty.Technology then
            Fulfilled = Fulfilled and self:IsTechnologyResearched(_PlayerID, Condition[2]);
        elseif Condition[1] == PlayerDuty.Custom then
            Fulfilled = Fulfilled and self:DoCustomConditionSucceed(i, _PlayerID, Condition[3]);
        end
    end
    return Fulfilled;
end

function Stronghold.Rights:IsTechnologyResearched(_PlayerID, _Technology)
    return Logic.IsTechnologyResearched(_PlayerID, _Technology) == 1;
end

function Stronghold.Rights:GetWorkerAmountInSettlement(_PlayerID)
    return Logic.GetNumberOfAttractedWorker(_PlayerID);
end

function Stronghold.Rights:GetSoldierAmountInSettlement(_PlayerID)
    local MaxPlayers = GetMaxAmountOfPlayer();
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= MaxPlayers);
    local Amount = Logic.GetNumberOfAttractedSoldiers(_PlayerID);
    -- Deco entities must be explicitly excluded
    Amount = Amount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Bear_Deco);
    Amount = Amount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Criminal_Deco);
    Amount = Amount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Dog_Deco);
    Amount = Amount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Hawk_Deco);
    Amount = Amount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Rat_Deco);
    Amount = Amount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Watchman_Deco);
    -- Cage animals must be explicitly excluded
    Amount = Amount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Bear_Cage);
    Amount = Amount - Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Dog_Cage);
    return math.max(Amount, 0);
end

function Stronghold.Rights:GetSettlersOfTypeInSettlement(_PlayerID, _Type)
    local CurrentAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, _Type);
    return CurrentAmount;
end

function Stronghold.Rights:GetWorkplaceAmountInSettlement(_PlayerID)
    local WorkplaceAmount = GetWorkplacesOfType(_PlayerID, 0, true);
    return WorkplaceAmount[1];
end

function Stronghold.Rights:GetBuildingsOfTypeInSettlement(_PlayerID, _Type)
    if GetUpgradeLevelByEntityType(_Type) == 0 then
        local BuildingsOfType = GetBuildingsOfType(_PlayerID, _Type, true);
        return BuildingsOfType[1] or 0;
    end
    return Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, _Type);
end

function Stronghold.Rights:GetBeautificationAmountInSettlement(_PlayerID)
    local Amount = 0;
    for i= 1, 12 do
        local Type = "PB_Beautification" .. ((i < 10 and "0"..i) or i);
        local BuildingList = GetBuildingsOfType(_PlayerID, Entities[Type], true);
        Amount = Amount + BuildingList[1];
    end
    return Amount;
end

function Stronghold.Rights:GetAllBeautificationsInSettlement(_PlayerID)
    local Amount = 0;
    for i= 1, 12 do
        local Type = "PB_Beautification" .. ((i < 10 and "0"..i) or i);
        local Beautification = GetBuildingsOfType(_PlayerID, Entities[Type], true);
        if Beautification[1] > 0 then
            Amount = Amount +1;
        end
    end
    return Amount;
end

function Stronghold.Rights:DoesHeadquarterOfUpgradeLevelExist(_PlayerID, _Level)
    local ID = GetHeadquarterID(_PlayerID);
    if ID ~= 0 then
        return Logic.GetUpgradeLevelForBuilding(ID) >= _Level;
    end
    return false;
end

function Stronghold.Rights:DoesCathedralOfUpgradeLevelExist(_PlayerID, _Level)
    if _Level == 0 then
        local Cathedral = GetCathedralsOfType(_PlayerID, Entities.PB_Monastery1, true);
        return Cathedral[1] > 0;
    end
    if _Level == 1 then
        return Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Monastery2) > 0;
    end
    if _Level == 2 then
        return Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PB_Monastery3) > 0;
    end
    return false;
end

function Stronghold.Rights:DoesWorkerAmountInSettlementExist(_PlayerID, _Amount)
    return self:GetWorkerAmountInSettlement(_PlayerID) >= _Amount;
end

function Stronghold.Rights:DoesSoldierAmountInSettlementExist(_PlayerID, _Amount)
    return self:GetSoldierAmountInSettlement(_PlayerID) >= _Amount;
end

function Stronghold.Rights:DoSettlersOfTypeInSettlementExist(_PlayerID, _Type, _Amount)
    return self:GetSettlersOfTypeInSettlement(_PlayerID, _Type) >= _Amount;
end

function Stronghold.Rights:DoesWorkplaceAmountInSettlementExist(_PlayerID, _Amount)
    return self:GetWorkplaceAmountInSettlement(_PlayerID) >= _Amount;
end

function Stronghold.Rights:DoBuildingsOfTypeInSettlementExist(_PlayerID, _Type, _Amount)
    return self:GetBuildingsOfTypeInSettlement(_PlayerID, _Type) >= _Amount;
end

function Stronghold.Rights:DoesBeautificationAmountInSettlementExist(_PlayerID, _Amount)
    return self:GetBeautificationAmountInSettlement(_PlayerID) >= _Amount;
end

function Stronghold.Rights:DoAllBeautificationsInSettlementExist(_PlayerID)
    return self:GetAllBeautificationsInSettlement(_PlayerID) == 12;
end

function Stronghold.Rights:DoCustomConditionSucceed(_i, _PlayerID, _Function)
    local Fulfulled, Current, Required = _Function(_PlayerID, _i);
    return Fulfulled, Current, Required;
end

-- -------------------------------------------------------------------------- --
-- Rank Up Button

function Stronghold.Rights:OnlineHelpAction()
    local PlayerID = GetLocalPlayerID();
    local WidgetID = XGUIEng.GetCurrentWidgetID();
    if not IsPlayerInitalized(PlayerID) then
        return false;
    end
    local CurrentRank = GetRank(PlayerID);
    local NextRank = self.Config.Titles[CurrentRank+1];
    if NextRank then
        local Costs = CreateCostTable(unpack(NextRank.Costs));
        if InterfaceTool_HasPlayerEnoughResources_Feedback(Costs) == 0 then
            return true;
        end
    end
    if self:CanPlayerBePromoted(PlayerID) then
        Syncer.InvokeEvent(
            Stronghold.Rights.NetworkCall,
            Stronghold.Rights.SyncEvents.RankUp
        );
    else
        if GUI.GetPlayerID() == PlayerID then
            Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_COMMENT_BadPlay_rnd_01, 100);
            if not IsExisting(GetNobleID(PlayerID)) then
                Message(XGUIEng.GetStringTableText("sh_menurights/PromoteHero"));
            else
                Message(XGUIEng.GetStringTableText("sh_menurights/PromoteLocked"));
            end
        end
    end
    return true;
end

function Stronghold.Rights:OnlineHelpTooltip(_Key)
    if _Key == "MenuMap/OnlineHelp" then
        local CostText = "";
        local Text = "";

        local PlayerID = GetLocalPlayerID();
        local NextRank = GetRank(PlayerID) +1;
        if  PlayerID ~= 17 and self.Config.Titles[NextRank]
        and NextRank <= self.Data[PlayerID].MaxRank
        and NextRank <= self.Data[PlayerID].LockRank then
            local Config = self.Config.Titles[NextRank];
            local Costs = CreateCostTable(unpack(Config.Costs));
            Text = string.format(
                XGUIEng.GetStringTableText("sh_menurights/NewRank"),
                GetRankName(NextRank, PlayerID),
                self:GetDutiesDescription(PlayerID, NextRank)
            );
            CostText = FormatCostString(PlayerID, Costs);
        else
            Text = XGUIEng.GetStringTableText("sh_menurights/FinalRank");
        end

        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostText);
        XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "");
        return true;
    end
    return false;
end

function Stronghold.Rights:OnlineHelpUpdate(_PlayerID, _Button, _Technology)
    if _Button == "OnlineHelpButton" then
        local Texture = "graphics/textures/gui/b_rank_f2.png";
        if _PlayerID == GUI.GetPlayerID() or GUI.GetPlayerID() == 17 then
            if IsPlayerInitalized(_PlayerID) then
                local CurrentRank = GetRank(_PlayerID);
                Texture = "graphics/textures/gui/b_rank_" ..CurrentRank.. ".png";
                if CurrentRank >= self.Data[_PlayerID].LockRank
                or CurrentRank >= self.Data[_PlayerID].MaxRank then
                    Texture = "graphics/textures/gui/b_rank_f1.png";
                end
            end
            for i= 0, 6 do
                XGUIEng.SetMaterialTexture(_Button, i, Texture);
            end
        end
        return true;
    end
    return false;
end

function Stronghold.Rights:PromotePlayer(_PlayerID, _IgnoreDuties, _Verbose)
    if self:CanPlayerBePromoted(_PlayerID, _IgnoreDuties) then
        local CurrentRank = GetRank(_PlayerID);
        self:SetPlayerRank(_PlayerID, CurrentRank +1);
        for i= 0, 7 do
            if i >= CurrentRank +1 then
                AllowTechnology(self.Config.RankToTechnology[i], _PlayerID);
            else
                ForbidTechnology(self.Config.RankToTechnology[i], _PlayerID);
            end
        end

        -- Pay costs
        if not _IgnoreDuties then
            local Costs = CreateCostTable(unpack(self.Data[_PlayerID].Titles[CurrentRank +1].Costs));
            RemoveResourcesFromPlayer(_PlayerID, Costs);
        end
        -- Info message
        if _Verbose then
            local MsgText = string.format(
                XGUIEng.GetStringTableText("sh_menurights/PromoteSelf"),
                GetRankName(CurrentRank +1, _PlayerID)
            );
            if GUI.GetPlayerID() == _PlayerID then
                Sound.PlayGUISound(Sounds.OnKlick_Select_dario, 100);
            else
                MsgText = XGUIEng.GetStringTableText("sh_menurights/PromoteOther");
            end
            Message(MsgText);
        end
        -- Callbacks
        GameCallback_SH_Logic_PlayerPromoted(_PlayerID, CurrentRank, CurrentRank +1);
        if CurrentRank + 1 >= self:GetPlayerMaxRank(_PlayerID) then
            GameCallback_SH_Logic_PlayerReachedHighestRank(_PlayerID, CurrentRank +1);
        end
    end
end

function Stronghold.Rights:CanPlayerBePromoted(_PlayerID, _IgnoreDuties)
    if IsPlayer(_PlayerID) then
        if _IgnoreDuties or IsExisting(GetNobleID(_PlayerID)) then
            local CurrentRank = GetRank(_PlayerID);
            if CurrentRank < self.Data[_PlayerID].MaxRank and CurrentRank < self.Data[_PlayerID].LockRank then
                return _IgnoreDuties or self:ArePromotionRequirementsFulfilled(_PlayerID, CurrentRank +1);
            end
        end
    end
    return false;
end

-- -------------------------------------------------------------------------- --
-- Free Camera Buttons

gvToggleFreeCamera = 0;

GUIAction_FreeCameraButton = function (_Button)
    local PlayerID = GUI.GetPlayerID();
    if _Button == "FreeCamButton" then
        if not Syncer.IsMultiplayer() or PlayerID == 17 then
            if Logic.GetTechnologyState(PlayerID, Technologies.T_FreeCamera) ~= 0 then
                FreeCam.Toggle();
                XGUIEng.ShowWidget("FreeCamControls", 1);
            end
        end
    elseif _Button == "FreeCamCancelButton" then
        FreeCam.Toggle();
        XGUIEng.ShowWidget("FreeCamControls", 0);
    elseif _Button == "FreeCamHelpButton" then
        gvToggleFreeCamera = 1 - gvToggleFreeCamera;
        XGUIEng.ShowWidget("FreeCameraHelp", gvToggleFreeCamera);
    end
end

GUIUpdate_FreeCameraButton = function(_Button)
    if _Button == "FreeCamButton" then
        local PlayerID = GUI.GetPlayerID();
        local DisabledFlag = 0;
        if (Syncer.IsMultiplayer() and GUI.GetPlayerID() ~= 17)
        or Logic.GetTechnologyState(PlayerID, Technologies.T_FreeCamera) == 0 then
            DisabledFlag = 1;
        end
        XGUIEng.DisableButton(_Button, DisabledFlag);
    elseif _Button == "FreeCamCancelButton" then
    elseif _Button == "FreeCamHelpButton" then
    end
end

