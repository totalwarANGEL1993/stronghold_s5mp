--- 
--- Province Script
---
--- Provinces are special locations a player can claim to get their benefits.
---
--- Defined game callbacks:
--- - GameCallback_Logic_OnProvinceClaimed(_PlayerID, _ProvinceID, _BuildingID)
---   A player claimed a province.
--- 
--- - GameCallback_Logic_OnProvinceUpgraded(_PlayerID, _ProvinceID, _BuildingID)
---   A player has upgraded a province.
--- 
--- - GameCallback_Logic_OnProvincePayday(_PlayerID, _ProvinceID, _BuildingID)
---   A player controlled a province at their payday.
--- 
--- - GameCallback_Logic_OnProvinceLost(_PlayerID, _ProvinceID)
---   A player lost a ptovince.
--- 

Stronghold = Stronghold or {};

Stronghold.Province = {
    Data = {
        ProvinceIdSequence = 0,
        Provinces = {},
    },
    Config = {},
    Text = {},
}

function Stronghold.Province:Install()
    self:StartTriggers();
end

function Stronghold.Province:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --

-- Creates a province that is granting honor when claimed.
function CreateHonorProvince(_Name, _Position, _AmountOfHonor, _UpgradeFactor, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Honor,
        DisplayName = (type(_Name) == "table" and _Name[GetLanguage()]) or _Name,
        Position    = GetPosition(_Position),
        Amount      = _AmountOfHonor,
        Upgrade     = _UpgradeFactor,
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

-- Creates a province that is granting reputation when claimed.
function CreateReputationProvince(_Name, _Position, _AmountOfReputation, _UpgradeFactor, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Reputation,
        DisplayName = (type(_Name) == "table" and _Name[GetLanguage()]) or _Name,
        Position    = GetPosition(_Position),
        Amount      = _AmountOfReputation,
        Upgrade     = _UpgradeFactor,
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

-- Creates a province that is granting additional military space when claimed.
function CreateMilitaryProvince(_Name, _Position, _AmountOfUnits, _UpgradeFactor, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Military,
        DisplayName = (type(_Name) == "table" and _Name[GetLanguage()]) or _Name,
        Position    = GetPosition(_Position),
        Amount      = _AmountOfUnits,
        Upgrade     = _UpgradeFactor,
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

-- Creates a province that is producing resources when claimed.
function CreateResourceProvince(_Name, _Position, _ResourceType, _Amount, _UpgradeFactor, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Resource,
        DisplayName = (type(_Name) == "table" and _Name[GetLanguage()]) or _Name,
        Position    = GetPosition(_Position),
        Resource    = _ResourceType,
        Amount      = _Amount,
        Upgrade     = _UpgradeFactor,
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

-- Creates a province that is doing nothing.
function CreateCustomProvince(_Name, _Position, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Custom,
        DisplayName = (type(_Name) == "table" and _Name[GetLanguage()]) or _Name,
        Position    = GetPosition(_Position),
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

-- Changes the neutral player.
function SetProvincesNeutralPlayerID(_PlayerID)
    Stronghold.Province:SetNeutralPlayerID(_PlayerID);
end

-- -------------------------------------------------------------------------- --

function GameCallback_Logic_OnProvinceClaimed(_PlayerID, _ProvinceID, _BuildingID)
end

function GameCallback_Logic_OnProvinceUpgraded(_PlayerID, _ProvinceID, _BuildingID)
end

function GameCallback_Logic_OnProvincePayday(_PlayerID, _ProvinceID, _BuildingID)
end

function GameCallback_Logic_OnProvinceLost(_PlayerID, _ProvinceID)
end

-- -------------------------------------------------------------------------- --

function Stronghold.Province:StartTriggers()
    Overwrite.CreateOverwrite("GameCallback_Logic_Payday", function(_PlayerID)
        Overwrite.CallOriginal();
        Stronghold.Province:OnPayday(_PlayerID);
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_HonorIncreaseSpecial", function(_PlayerID)
        local Amount = Overwrite.CallOriginal();
        Amount = Amount + Stronghold.Province:GetSumOfProvincesRevenue(ProvinceType.Honor, _PlayerID);
        return Amount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_ReputationIncreaseExternal", function(_PlayerID)
        local Amount = Overwrite.CallOriginal();
        Amount = Amount + Stronghold.Province:GetSumOfProvincesRevenue(ProvinceType.Reputation, _PlayerID);
        return Amount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_MilitaryAttrationLimit", function(_PlayerID, _Amount)
        local Amount = Overwrite.CallOriginal();
        Amount = Amount + Stronghold.Province:GetSumOfProvincesRevenue(ProvinceType.Military, _PlayerID);
        return Amount;
    end);
end

-- -------------------------------------------------------------------------- --

function Stronghold.Province:CreateProvince(_Data)
    self.Data.ProvinceIdSequence = self.Data.ProvinceIdSequence +1;
    local ID = self.Data.ProvinceIdSequence;

    _Data.ID = ID;
    _Data.Owner = self.Config.NeutralPlayerID;
    _Data.DisplayName = _Data.DisplayName or ("Province " ..ID);
    _Data.Explorers = {Entities = {}};

    self.Data.Provinces[ID] = _Data;
    return ID;
end

function Stronghold.Province:AddExplorerEntity(_ID, _Entity)
    if self.Data.Provinces[_ID] then
        table.insert(self.Data.Provinces[_ID].Explorers, _Entity);
    end
end

function Stronghold.Province:SetNeutralPlayerID(_PlayerID)
    self.Config.NeutralPlayerID = _PlayerID;
end

function Stronghold.Province:ClaimProvince(_ID, _PlayerID, _BuildingID)
    if self.Data.Provinces[_ID] then
        -- Save owner
        self.Data.Provinces[_ID].Owner = _PlayerID;
        self.Data.Provinces[_ID].Village = CreateNameForEntity(_BuildingID);
        -- Create exploration entities
        for i= table.getn(self.Data.Provinces[_ID].Explorers), 1, -1 do
            local Explorer = self.Data.Provinces[_ID].Explorers[i];
            local ExploreRange = Logic.GetEntityExplorationRange(GetID(Explorer));
            local Location = GetPosition(Explorer);
            local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, Location.X, Location.Y, 0, _PlayerID);
            Logic.SetEntityExplorationRange(ID, ExploreRange);
            table.insert(self.Data.Provinces[_ID].Explorers.Entities, ID);
        end
        -- Print message
        local Lang = GetLanguage();
        local PlayerName = UserTool_GetPlayerName(_PlayerID);
        local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
        Message(string.format(
            self.Text.Msg.Claimed[Lang],
            PlayerColor.. " " ..PlayerName,
            self.Data.Provinces[_ID].DisplayName
        ));

        -- Print effect info
        if GUI.GetPlayerID() == _PlayerID then
            local Msg = self:CreateProvinceEffectMessage(_ID, _PlayerID, _BuildingID);
            if Msg then
                Message(Msg);
            end
        end
        -- Extern effects
        GameCallback_Logic_OnProvinceClaimed(_PlayerID, _ID, _BuildingID);
    end
end

function Stronghold.Province:UpgradeProvince(_ID, _PlayerID, _BuildingID)
    if self.Data.Provinces[_ID] then
        -- Print message
        local Lang = GetLanguage();
        local PlayerName = UserTool_GetPlayerName(_PlayerID);
        local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
        Message(string.format(
            self.Text.Msg.Upgraded[Lang],
            PlayerColor.. " " ..PlayerName,
            self.Data.Provinces[_ID].DisplayName
        ));
        -- Print effect info
        if GUI.GetPlayerID() == _PlayerID then
            local Msg = self:CreateProvinceEffectMessage(_ID, _PlayerID, _BuildingID);
            if Msg then
                Message(Msg);
            end
        end
        -- Extern effects
        GameCallback_Logic_OnProvinceUpgraded(_PlayerID, _ID, _BuildingID);
    end
end

function Stronghold.Province:LooseProvince(_ID, _PlayerID)
    if self.Data.Provinces[_ID] then
        -- Delete owner
        self.Data.Provinces[_ID].Owner = self.Config.NeutralPlayerID;
        self.Data.Provinces[_ID].Village = nil;
        -- Delete exploration Entities
        for i= table.getn(self.Data.Provinces[_ID].Explorers.Entities), 1, -1 do
            DestroyEntity(self.Data.Provinces[_ID].Explorers.Entities[i]);
        end
        self.Data.Provinces[_ID].Entities = {};
        -- Print message
        local Lang = GetLanguage();
        Message(string.format(
            self.Text.Msg.Lost[Lang],
            self.Data.Provinces[_ID].DisplayName
        ));
        -- Extern effects
        GameCallback_Logic_OnProvinceLost(_PlayerID, _ID);
    end
end

function Stronghold.Province:GetSumOfProvincesRevenue(_Type, _PlayerID)
    local Revenue = 0;
    if _Type ~= ProvinceType.Resource and _Type ~= ProvinceType.Custom then
        for k,v in pairs(self.Data.Provinces) do
            if v.Type == _Type and v.Owner == _PlayerID and IsExisting(v.Village) then
                local VillageID = GetID(v.Village);
                local Level = Logic.GetUpgradeLevelForBuilding(VillageID);
                Revenue = Revenue + v.Amount;
                for i= 1, Level do
                    Revenue = Revenue + math.floor((v.Amount * v.Upgrade) + 0.5);
                end
            end
        end
    end
    return Revenue;
end

function Stronghold.Province:GetProvinceRevenue(_ID, _PlayerID)
    local Revenue = 0;
    if self.Data.Provinces[_ID] then
        local Data = self.Data.Provinces[_ID];
        if Data.Owner == _PlayerID and IsExisting(Data.Village) then
            local VillageID = GetID(Data.Village);
            local Level = Logic.GetUpgradeLevelForBuilding(VillageID);
            Revenue = Data.Amount;
            for i= 1, Level do
                Revenue = Revenue + math.floor((Data.Amount * Data.Upgrade) + 0.5);
            end
        end
    end
    return Revenue;
end

function Stronghold.Province:CreateProvinceEffectMessage(_ID, _PlayerID, _BuildingID)
    local Msg;
    if self.Data.Provinces[_ID] then
        local Lang = GetLanguage();
        local Text = "[Text]";
        local Template;

        if self.Data.Provinces[_ID].Type == ProvinceType.Honor then
            Template = self.Text.Msg.Revenue[3];
            local ResourceName = Stronghold.Config.UI.Honor[Lang];
            Text = self:GetProvinceRevenue(_ID, _PlayerID).. " " ..ResourceName;
        elseif self.Data.Provinces[_ID].Type == ProvinceType.Reputation then
            Template = self.Text.Msg.Revenue[3];
            local ResourceName = Stronghold.Config.UI.Reputation[Lang];
            Text = self:GetProvinceRevenue(_ID, _PlayerID).. " " ..ResourceName;
        elseif self.Data.Provinces[_ID].Type == ProvinceType.Military then
            Template = self.Text.Msg.Revenue[2];
            Text = "" ..self:GetProvinceRevenue(_ID, _PlayerID);
        elseif self.Data.Provinces[_ID].Type == ProvinceType.Resource then
            Template = self.Text.Msg.Revenue[1];
            local ResourceName = GetResourceName(self.Data.Provinces[_ID].Resource);
            Text = self:GetProvinceRevenue(_ID, _PlayerID).. " " ..ResourceName;
        end
        if Template then
            Msg = string.format(Template[Lang], Text);
        end
    end
    return Msg;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Province:ControlProvince()
    for k,v in pairs(self.Data.Provinces) do
        if v.Owner ~= self.Config.NeutralPlayerID and v.Village ~= nil then
            if Stronghold:IsPlayer(v.Owner) then
                if not IsExisting(v.Village) then
                    self:LooseProvince(k, v.Owner);
                end
            end
        end
    end
end

function Stronghold.Province:OnPayday(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        for k,v in pairs(self.Data.Provinces) do
            if v and v.Owner == _PlayerID then
                if v.Type == ProvinceType.Resource then
                    local Amount = Stronghold.Province:GetProvinceRevenue(k, v.Owner);
                    Logic.AddToPlayersGlobalResource(v.Owner, v.Resource, Amount);
                end
                GameCallback_Logic_OnProvincePayday(v.Owner, k, GetID(v.Village));
            end
        end
    end
end

function Stronghold.Province:OnBuildingCreated(_BuildingID, _PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        if Logic.IsEntityInCategory(_BuildingID, EntityCategories.VillageCenter) == 1 then
            if Logic.IsConstructionComplete(_BuildingID) == 0 then
                local VillagePosition = GetPosition(_BuildingID);
                for k,v in pairs(self.Data.Provinces) do
                    if v.Owner == self.Config.NeutralPlayerID then
                        if GetDistance(VillagePosition, v.Position) <= 4000 then
                            if AreEnemiesInArea(_PlayerID, v.Position, 7000) then
                                if _PlayerID == GUI.GetPlayerID() then
                                    Message(self.Text.Msg.Denyed[GetLanguage()]);
                                end
                                SetHealth(_BuildingID, 0);
                            end
                        end
                    end
                end
            end
        end
    end
end

function Stronghold.Province:OnBuildingConstructed(_BuildingID, _PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        if Logic.IsEntityInCategory(_BuildingID, EntityCategories.VillageCenter) == 1 then
            local Position = GetPosition(_BuildingID);
            for k,v in pairs(self.Data.Provinces) do
                if v.Owner == self.Config.NeutralPlayerID then
                    if GetDistance(Position, v.Position) <= 4000 then
                        self:ClaimProvince(k, _PlayerID, _BuildingID);
                    end
                end
            end
        end
    end
end

function Stronghold.Province:OnBuildingUpgraded(_BuildingID, _PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        if Logic.IsEntityInCategory(_BuildingID, EntityCategories.VillageCenter) == 1 then
            local ScriptName = CreateNameForEntity(_BuildingID);
            for k,v in pairs(self.Data.Provinces) do
                if v.Owner ~= self.Config.NeutralPlayerID and v.Village == ScriptName then
                    self:UpgradeProvince(k, _PlayerID, _BuildingID);
                end
            end
        end
    end
end
