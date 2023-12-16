--- 
--- Province Script
---
--- Provinces are special locations a player can claim to get their benefits.
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

-- -------------------------------------------------------------------------- --
-- API

-- Creates a province that is granting honor when claimed.
--- @param _Name string|table Name of province
--- @param _Position string Position of center
--- @param _AmountOfHonor integer Amount of honor
--- @param _UpgradeFactor number Upgrade bonus factor
--- @param ... integer|string Buildings of povince
--- @return integer ID ID of province
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

--- Creates a province that is granting reputation when claimed.
--- @param _Name string|table Name of province
--- @param _Position string Position of center
--- @param _AmountOfReputation integer Amount of reputation
--- @param _UpgradeFactor number Upgrade bonus factor
--- @param ... integer|string Buildings of povince
--- @return integer ID ID of province
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

--- Creates a province that is granting additional military space when claimed.
--- @param _Name string|table Name of province
--- @param _Position string Position of center
--- @param _AmountOfUnits integer Amount of bonus units
--- @param _UpgradeFactor number Upgrade bonus factor
--- @param ... integer|string Buildings of povince
--- @return integer ID ID of province
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

--- Creates a province that is producing resources when claimed.
--- @param _Name string|table Name of province
--- @param _Position string Position of center
--- @param _ResourceType integer Type of resource
--- @param _Amount integer Amount of resource
--- @param _UpgradeFactor number Upgrade bonus factor
--- @param ... integer|string Buildings of povince
--- @return integer ID ID of province
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

--- Creates a province that is doing nothing.
--- @param _Name string|table Name of province
--- @param _Position string Position of center
--- @param _Parameters table List of Parameters
--- @param ... integer|string Buildings of povince
--- @return integer ID ID of province
function CreateCustomProvince(_Name, _Position, _Parameters, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Custom,
        DisplayName = (type(_Name) == "table" and _Name[GetLanguage()]) or _Name,
        Position    = GetPosition(_Position),
        Arguments   = CopyTable(_Parameters),
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

--- Changes the neutral player.
--- @param _PlayerID integer ID of player
function SetProvincesNeutralPlayerID(_PlayerID)
    Stronghold.Province:SetNeutralPlayerID(_PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Game Callbacks

--- Triggered after a province is claimed.
--- @param _PlayerID integer ID of player
--- @param _ProvinceID integer ID of province
--- @param _BuildingID integer ID of outpost
function GameCallback_SH_Logic_OnProvinceClaimed(_PlayerID, _ProvinceID, _BuildingID)
end

--- Triggered after the province output has benn upgraded.
--- @param _PlayerID integer ID of player
--- @param _ProvinceID integer ID of province
--- @param _BuildingID integer ID of outpost
function GameCallback_SH_Logic_OnProvinceUpgraded(_PlayerID, _ProvinceID, _BuildingID)
end

--- Triggered on the province owners payday.
--- @param _PlayerID integer ID of player
--- @param _ProvinceID integer ID of province
function GameCallback_SH_Logic_OnProvincePayday(_PlayerID, _ProvinceID)
end

--- Triggered after a player lost a province.
--- @param _PlayerID integer ID of player
--- @param _ProvinceID integer ID of province
function GameCallback_SH_Logic_OnProvinceLost(_PlayerID, _ProvinceID)
end

-- -------------------------------------------------------------------------- --
-- Internal

function Stronghold.Province:Install()
    self:OerwriteGameCallbacks();
end

function Stronghold.Province:OnSaveGameLoaded()
end

function Stronghold.Province:OnEverySecond()
    -- Controls provinces
    self:ControlProvince();
end

function Stronghold.Province:OerwriteGameCallbacks()
    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_Payday", function(_PlayerID, _Amount)
        local Amount = Overwrite.CallOriginal();
        Amount = Stronghold.Province:OnPayday(_PlayerID, Amount);
        return Amount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_HonorIncreaseExternal", function(_PlayerID)
        local Amount = Overwrite.CallOriginal();
        Amount = Amount + Stronghold.Province:GetSumOfProvincesRevenue(ProvinceType.Honor, _PlayerID);
        return Amount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_ReputationIncreaseExternal", function(_PlayerID)
        local Amount = Overwrite.CallOriginal();
        Amount = Amount + Stronghold.Province:GetSumOfProvincesRevenue(ProvinceType.Reputation, _PlayerID);
        return Amount;
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_MilitaryAttrationLimit", function(_PlayerID, _Amount)
        local Amount = Overwrite.CallOriginal();
        Amount = Amount + Stronghold.Province:GetSumOfProvincesRevenue(ProvinceType.Military, _PlayerID);
        return Amount;
    end);

    Overwrite.CreateOverwrite("GameCallback_PlaceBuildingAdditionalCheck", function(_Type, _x, _y, _rotation, _isBuildOn)
        local Allowed = Overwrite.CallOriginal();
        Allowed = Allowed and Stronghold.Province:CheckVillageCenterAllowed(_Type, _x, _y, _rotation, _isBuildOn);
        return Allowed;
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
            WriteEntityCreatedToLog(_PlayerID, ID, Logic.GetEntityType(ID));
            Logic.SetEntityExplorationRange(ID, ExploreRange);
            table.insert(self.Data.Provinces[_ID].Explorers.Entities, ID);
        end
        -- Print message
        local PlayerName = UserTool_GetPlayerName(_PlayerID);
        local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
        Message(string.format(
            XGUIEng.GetStringTableText("sh_text/Province_Claimed"),
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
        GameCallback_SH_Logic_OnProvinceClaimed(_PlayerID, _ID, _BuildingID);
    end
end

function Stronghold.Province:UpgradeProvince(_ID, _PlayerID, _BuildingID)
    if self.Data.Provinces[_ID] then
        -- Print message
        local Lang = GetLanguage();
        local PlayerName = UserTool_GetPlayerName(_PlayerID);
        local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
        Message(string.format(
            XGUIEng.GetStringTableText("sh_text/Province_Upgraded"),
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
        GameCallback_SH_Logic_OnProvinceUpgraded(_PlayerID, _ID, _BuildingID);
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
        Message(string.format(
            XGUIEng.GetStringTableText("sh_text/Province_Lost"),
            self.Data.Provinces[_ID].DisplayName
        ));
        -- Extern effects
        GameCallback_SH_Logic_OnProvinceLost(_PlayerID, _ID);
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
        local Text = "";
        local Template;

        if self.Data.Provinces[_ID].Type == ProvinceType.Honor then
            Template = XGUIEng.GetStringTableText("sh_text/Province_Revenue_Bonus");
            local ResourceName = XGUIEng.GetStringTableText("sh_names/Honor");
            Text = self:GetProvinceRevenue(_ID, _PlayerID).. " " ..ResourceName;
        elseif self.Data.Provinces[_ID].Type == ProvinceType.Reputation then
            Template = XGUIEng.GetStringTableText("sh_text/Province_Revenue_Bonus");
            local ResourceName = XGUIEng.GetStringTableText("sh_names/Reputation");
            Text = self:GetProvinceRevenue(_ID, _PlayerID).. " " ..ResourceName;
        elseif self.Data.Provinces[_ID].Type == ProvinceType.Military then
            Template = XGUIEng.GetStringTableText("sh_text/Province_Revenue_Military");
            Text = "" ..self:GetProvinceRevenue(_ID, _PlayerID);
        elseif self.Data.Provinces[_ID].Type == ProvinceType.Resource then
            Template = XGUIEng.GetStringTableText("sh_text/Province_Revenue_Resource");
            local ResourceName = GetResourceName(self.Data.Provinces[_ID].Resource);
            Text = self:GetProvinceRevenue(_ID, _PlayerID).. " " ..ResourceName;
        end
        if Template then
            Msg = string.format(Template, Text);
        end
    end
    return Msg;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Province:ControlProvince()
    for k,v in pairs(self.Data.Provinces) do
        if v.Owner ~= self.Config.NeutralPlayerID and v.Village ~= nil then
            if IsPlayer(v.Owner) then
                if not IsExisting(v.Village) then
                    self:LooseProvince(k, v.Owner);
                end
            end
        end
    end
end

function Stronghold.Province:OnPayday(_PlayerID, _Amount)
    local TaxAmount = _Amount;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        for k,v in pairs(self.Data.Provinces) do
            if v and v.Owner == _PlayerID then
                if v.Type == ProvinceType.Resource then
                    local Amount = Stronghold.Province:GetProvinceRevenue(k, v.Owner);
                    Logic.AddToPlayersGlobalResource(v.Owner, v.Resource, Amount);
                    WriteResourcesGainedToLog(v.Owner, v.Resource, Amount);
                end
                GameCallback_SH_Logic_OnProvincePayday(v.Owner, k);
            end
        end
    end
    return TaxAmount;
end

function Stronghold.Province:CheckVillageCenterAllowed(_Type, _x, _y, _rotation, _isBuildOn)
    local PlayerID = GUI.GetPlayerID()
    if IsPlayer(PlayerID) then
        if Logic.IsEntityTypeInCategory(_Type, EntityCategories.VillageCenter) == 1 then
            return not AreEnemiesInArea(PlayerID, {X= _x, Y= _y}, 5000);
        end
    end
    return true;
end

function Stronghold.Province:OnBuildingConstructed(_BuildingID, _PlayerID)
    if IsPlayer(_PlayerID) then
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
    if IsPlayer(_PlayerID) then
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

