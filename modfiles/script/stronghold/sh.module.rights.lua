--- 
--- Promotion System
---
--- Defined game callbacks:
--- - GameCallback_Logic_PlayerPromoted(_PlayerID, _OldRank, _NewRank)
---   Called after a player has been promoted.
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

--- Returns the gender of the entity type.
function GetGender(_Type)
    return Stronghold.Rights:GetHeroGender(_Type);
end

--- Returns the rank of the player.
function GetRank(_PlayerID)
    return Stronghold.Rights:GetPlayerRank(_PlayerID);
end

--- Sets the rank of the player.
function SetRank(_PlayerID, _Rank)
    return Stronghold.Rights:SetPlayerRank(_PlayerID, _Rank);
end

--- Returns the name of the rank invoking the gender of the players hero.
function GetRankName(_Rank, _PlayerID)
    return Stronghold.Rights:GetPlayerRankName(_Rank, _PlayerID)
end

function GetRankRequired(_PlayerID, _Right)
    return Stronghold.Rights:GetRankRequiredForRight(_PlayerID, _Right);
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

function GameCallback_Logic_PlayerPromoted(_PlayerID, _OldRank, _NewRank)
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Rights:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {
            MaxRank = Stronghold.Config.Base.MaxRank,
            LockRank = Stronghold.Config.Base.MaxRank,
            Rank = Stronghold.Config.Base.InitialRank,

            Titles = CopyTable(Stronghold.Rights.Config.Titles);
            Rights = {},
        };
        self:InitDutiesAndRights(i);
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
                Stronghold.Rights:PromotePlayer(_PlayerID);
                Stronghold.Rights:OnlineHelpUpdate("OnlineHelpButton", Technologies.T_OnlineHelp);
            end
        end
    );
end

-- -------------------------------------------------------------------------- --

function Stronghold.Rights:GetPlayerRank(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Rank;
    end
    return 1;
end

function Stronghold.Rights:SetPlayerRank(_PlayerID, _Rank)
    if Stronghold:IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Rank = _Rank;
        self:GrantPlayerRights(_PlayerID, _Rank);
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
        if Stronghold:IsPlayer(_PlayerID) then
            local LordID = Stronghold:GetPlayerHero(_PlayerID);
            if LordID ~= 0 then
                Gender = GetGender(Logic.GetEntityType(LordID)) or 1;
            end
        end
    end
    return Stronghold.Rights.Text.Title[CurrentRank][Gender][Language];
end

-- -------------------------------------------------------------------------- --
-- Rights

function Stronghold.Rights:InitDutiesAndRights(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        for k,v in pairs(self.Config.Titles) do
            for _, RightToUnlock in pairs(self.Config.Titles[k].Rights) do
                self.Data[_PlayerID].Rights[RightToUnlock] = 0;
            end
        end
    end
end

function Stronghold.Rights:LockPlayerRight(_PlayerID, _RightToLock)
    if Stronghold:IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Rights[_RightToLock] = -1;
    end
end

function Stronghold.Rights:UnlockPlayerRight(_PlayerID, _RightToLock)
    if Stronghold:IsPlayer(_PlayerID) then
        self.Data[_PlayerID].Rights[_RightToLock] = 0;
        for i= 1, GetRank(_PlayerID) do
            self:GrantPlayerRights(_PlayerID, i);
        end
    end
end

function Stronghold.Rights:GrantPlayerRights(_PlayerID, _Rank)
    if Stronghold:IsPlayer(_PlayerID) then
        for i= 1, table.getn(self.Data[_PlayerID].Titles[_Rank].Rights) do
            local RightToGrant = self.Data[_PlayerID].Titles[_Rank].Rights[i];
            if self.Data[_PlayerID].Rights[RightToGrant] ~= -1 then
                self.Data[_PlayerID].Rights[RightToGrant] = 1;
            end
        end
    end
end

function Stronghold.Rights:HasPlayerRight(_PlayerID, _Right)
    if Stronghold:IsPlayer(_PlayerID) then
        return self.Data[_PlayerID].Rights[_Right] == 1;
    end
end

function Stronghold.Rights:GetRankRequiredForRight(_PlayerID, _Right)
    if Stronghold:IsPlayer(_PlayerID) then
        for i= 1, table.getn(self.Config.Titles) do
            for j= 1, table.getn(self.Config.Titles[i].Rights) do
                if self.Config.Titles[i].Rights[j] == _Right then
                    return i;
                end
            end
        end
    end
    return 0;
end

-- -------------------------------------------------------------------------- --
-- Duties

function Stronghold.Rights:GetDutyDescription(_PlayerID, _Type, ...)
    local Lang = GetLanguage();
    local Text = "";
    if _Type == PlayerDuty.Headquarters then
        Text = self.Text.RequireCastle[arg[1] +1][Lang];
    elseif _Type == PlayerDuty.Cathedral then
        Text = self.Text.RequireCathedral[arg[1] +1][Lang];
    elseif _Type == PlayerDuty.Settlers then
        if arg[1] == 1 then
            local TypeName = Logic.GetEntityTypeName(arg[2]);
            local Name = XGUIEng.GetStringTableText("Names/" ..TypeName);
            Text = string.format("%d %s", arg[4], Name);
        else
            Text = arg[3].. " ".. self.Text.RequireSettler[Lang];
        end
    elseif _Type == PlayerDuty.Buildings then
        if arg[1] == 1 then
            local TypeName = Logic.GetEntityTypeName(arg[2]);
            local Name = XGUIEng.GetStringTableText("Names/" ..TypeName);
            Text = string.format("%d %s", arg[4], Name);
        else
            Text = arg[3].. " ".. self.Text.RequireBuildings[Lang];
        end
    elseif _Type == PlayerDuty.Beautification then
        if arg[1] == 1 then
            Text = arg[2].. " ".. self.Text.RequireBeautification[1][Lang];
        else
            Text = self.Text.RequireBeautification[2][Lang];
        end
    elseif _Type == PlayerDuty.Soldiers then
        Text = arg[2].. " ".. self.Text.RequireSoldiers[Lang];
    elseif _Type == PlayerDuty.Technology then
        local TechnologyKey = KeyOf(arg[1], Technologies);
        Text = XGUIEng.GetStringTableText("Names/" ..TechnologyKey);
    elseif _Type == PlayerDuty.Custom then
        Text = (type(arg[2]) == "table" and arg[2][Lang]) or arg[2];
    end
    return Text;
end

function Stronghold.Rights:GetDutiesDescription(_PlayerID, _Rank)
    local Duties = self.Config.Titles[_Rank].Duties;
    if Stronghold:IsPlayer(_PlayerID) then
        Duties = self.Data[_PlayerID].Titles[_Rank].Duties;
    end

    local Text = "";
    for i= 1, table.getn(Duties) do
        Text = Text .. ((i > 1 and ", ") or "");
        Text = Text .. self:GetDutyDescription(_PlayerID, unpack(Duties[i]));
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
        elseif Condition[1] == PlayerDuty.Buildings then
            if Condition[2] == 1 then
                Fulfilled = Fulfilled and self:DoBuildingsOfTypeInSettlementExist(_PlayerID, Condition[3], Condition[4]);
            else
                Fulfilled = Fulfilled and self:DooesBuildingAmountInSettlementExist(_PlayerID, Condition[3]);
            end
        elseif Condition[1] == PlayerDuty.Beautification then
            if Condition[2] == 1 then
                Fulfilled = Fulfilled and self:DoesBeautificationAmountInSettlementExist(_PlayerID, Condition[3]);
            else
                Fulfilled = Fulfilled and self:DoAllBeautificationsInSettlementExist(_PlayerID);
            end
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

function Stronghold.Rights:DoesHeadquarterOfUpgradeLevelExist(_PlayerID, _Level)
    local ID = GetHeadquarterID(_PlayerID);
    if ID ~= 0 then
        return Logic.GetUpgradeLevelForBuilding(ID) >= _Level;
    end
    return false;
end

function Stronghold.Rights:DoesCathedralOfUpgradeLevelExist(_PlayerID, _Level)
    local Cathedral1 = GetValidEntitiesOfType(_PlayerID, Entities.PB_Monastery1);
    local Cathedral2 = GetValidEntitiesOfType(_PlayerID, Entities.PB_Monastery2);
    local Cathedral3 = GetValidEntitiesOfType(_PlayerID, Entities.PB_Monastery3);
    local ID = Cathedral3[1] or Cathedral2[1] or Cathedral1[1] or 0;
    if ID ~= 0 then
        return Logic.GetUpgradeLevelForBuilding(ID) >= _Level;
    end
    return false;
end

function Stronghold.Rights:IsTechnologyResearched(_PlayerID, _Technology)
    return Logic.IsTechnologyResearched(_PlayerID, _Technology) == 1;
end

function Stronghold.Rights:DoesWorkerAmountInSettlementExist(_PlayerID, _Amount)
    return Logic.GetNumberOfAttractedWorker(_PlayerID) >= _Amount;
end

function Stronghold.Rights:DoesSoldierAmountInSettlementExist(_PlayerID, _Amount)
    return Logic.GetNumberOfAttractedSoldiers(_PlayerID) >= _Amount;
end

function Stronghold.Rights:DoSettlersOfTypeInSettlementExist(_PlayerID, _Type, _Amount)
    return Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, _Type) >= _Amount;
end

function Stronghold.Rights:DoBuildingsOfTypeInSettlementExist(_PlayerID, _Type, _Amount)
    return table.getn(GetValidEntitiesOfType(_PlayerID, _Type)) >= _Amount;
end

function Stronghold.Rights:DoesBeautificationAmountInSettlementExist(_PlayerID, _Amount)
    local Amount = 0;
    for i= 1, 12 do
        local Type = "PB_Beautification" .. ((i < 10 and "0"..i) or i);
        Amount = Amount + table.getn(GetValidEntitiesOfType(_PlayerID, Entities[Type]));
    end
    return Amount >= _Amount;
end

function Stronghold.Rights:DoAllBeautificationsInSettlementExist(_PlayerID)
    for i= 1, 12 do
        local Type = "PB_Beautification" .. ((i < 10 and "0"..i) or i);
        if table.getn(GetValidEntitiesOfType(_PlayerID, Entities[Type])) < 1 then
            return false;
        end
    end
    return true;
end

function Stronghold.Rights:DoCustomConditionSucceed(_i, _PlayerID, _Function)
    return _Function(_PlayerID, _i);
end

-- -------------------------------------------------------------------------- --
-- Rank Up Button

function Stronghold.Rights:OnlineHelpAction()
    local PlayerID = GUI.GetPlayerID();
    if not Stronghold:IsPlayerInitalized(PlayerID) then
        return false;
    end
    local CurrentRank = GetRank(PlayerID);
    local NextRank = self.Config.Titles[CurrentRank+1];
    if NextRank then
        local Costs = CreateCostTable(unpack(NextRank.Costs));
        if not HasPlayerEnoughResourcesFeedback(Costs) then
            return true;
        end
    end
    if self:CanPlayerBePromoted(PlayerID) then
        Syncer.InvokeEvent(
            Stronghold.Rights.NetworkCall,
            Stronghold.Rights.SyncEvents.RankUp
        );
    end
    return true;
end

function Stronghold.Rights:OnlineHelpTooltip(_Key)
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
            local Costs = CreateCostTable(unpack(Config.Costs));
            Text = string.format(
                Stronghold.Rights.Text.NewRank[Language],
                GetRankName(NextRank, PlayerID),
                self:GetDutiesDescription(PlayerID, NextRank)
            );
            CostText = FormatCostString(PlayerID, Costs);
        else
            Text = Stronghold.Rights.Text.FinalRank[Language];
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
        if GUI.GetPlayerID() == _PlayerID then
            local Disabled = 1;
            if Stronghold:IsPlayerInitalized(_PlayerID) then
                local CurrentRank = GetRank(_PlayerID);
                Texture = "graphics/textures/gui/b_rank_" ..CurrentRank.. ".png";
                if CurrentRank >= self.Data[_PlayerID].LockRank
                or CurrentRank >= self.Data[_PlayerID].MaxRank then
                    Texture = "graphics/textures/gui/b_rank_f1.png";
                end
                if self:CanPlayerBePromoted(_PlayerID) then
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

function Stronghold.Rights:PromotePlayer(_PlayerID)
    local Language = GetLanguage();
    if self:CanPlayerBePromoted(_PlayerID) then
        local CurrentRank = GetRank(_PlayerID);
        local Costs = CreateCostTable(unpack(self.Data[_PlayerID].Titles[CurrentRank +1].Costs));
        SetRank(_PlayerID, CurrentRank +1);
        RemoveResourcesFromPlayer(_PlayerID, Costs);
        local MsgText = string.format(
            self.Text.PromoteSelf[Language],
            GetRankName(CurrentRank +1, _PlayerID)
        );
        if GUI.GetPlayerID() == _PlayerID then
            Sound.PlayGUISound(Sounds.OnKlick_Select_pilgrim, 100);
        else
            MsgText = string.format(
                self.Text.PromoteOther[Language],
                UserTool_GetPlayerName(_PlayerID),
                "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ","),
                GetRankName(CurrentRank +1, _PlayerID)
            );
        end
        Message(MsgText);
        GameCallback_Logic_PlayerPromoted(_PlayerID, CurrentRank, CurrentRank +1);
    end
end

function Stronghold.Rights:CanPlayerBePromoted(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        if IsExisting(Stronghold.Players[_PlayerID].LordScriptName) then
            local CurrentRank = GetRank(_PlayerID);
            if CurrentRank < self.Data[_PlayerID].MaxRank and CurrentRank < self.Data[_PlayerID].LockRank then
                return self:ArePromotionRequirementsFulfilled(_PlayerID, CurrentRank +1);
            end
        end
    end
    return false;
end

