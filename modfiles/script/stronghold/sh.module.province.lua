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

--- Creates a province that increases damage of all units.
--- @param _Name string|table Name of province
--- @param _Position string Position of center
--- @param _Amount number Damage bonus factor
--- @param _UpgradeFactor number Upgrade bonus factor
--- @param ... integer|string Buildings of povince
--- @return integer ID ID of province
function CreateEncouragingProvince(_Name, _Position, _Amount, _UpgradeFactor, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Encourage,
        DisplayName = (type(_Name) == "table" and _Name[GetLanguage()]) or _Name,
        Position    = GetPosition(_Position),
        Amount      = _Amount,
        Upgrade     = _UpgradeFactor,
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

--- Creates a province that decreases damage taken from attacks.
--- @param _Name string|table Name of province
--- @param _Position string Position of center
--- @param _Amount number Damage reduction factor
--- @param _UpgradeFactor number Upgrade bonus factor
--- @param ... integer|string Buildings of povince
--- @return integer ID ID of province
function CreateProtectingProvince(_Name, _Position, _Amount, _UpgradeFactor, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Protective,
        DisplayName = (type(_Name) == "table" and _Name[GetLanguage()]) or _Name,
        Position    = GetPosition(_Position),
        Amount      = _Amount,
        Upgrade     = _UpgradeFactor,
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

--- Creates a province that increases the slave limit.
--- @param _Name string|table Name of province
--- @param _Position string Position of center
--- @param _Amount number Amount of serfs
--- @param _UpgradeFactor number Upgrade bonus factor
--- @param ... integer|string Buildings of povince
--- @return integer ID ID of province
function CreateSlaveProvince(_Name, _Position, _Amount, _UpgradeFactor, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Slave,
        DisplayName = (type(_Name) == "table" and _Name[GetLanguage()]) or _Name,
        Position    = GetPosition(_Position),
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
        Parameters  = CopyTable(_Parameters),
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

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_BattleDamage", function(_AttackerID, _AttackedID, _Damage)
        local Damage = Overwrite.CallOriginal();
        Damage = Stronghold.Province:OnDamageInflicted(_AttackerID, _AttackedID, Damage);
        return math.max(math.floor(Damage), 1);
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Calculate_SlaveAttrationLimit", function(_PlayerID, _Amount)
        local Amount = Overwrite.CallOriginal();
        Amount = Amount + Stronghold.Province:GetSumOfProvincesRevenue(ProvinceType.Slave, _PlayerID);
        return math.max(math.floor(Amount), 1);
    end);

    Overwrite.CreateOverwrite("GameCallback_PlaceBuildingAdditionalCheck", function(_Type, _x, _y, _rotation, _isBuildOn)
        local Allowed = Overwrite.CallOriginal();
        Allowed = Allowed and Stronghold.Province:CheckFortificationAllowed(_Type, _x, _y, _rotation, _isBuildOn);
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
        self.Data.Provinces[_ID].Outpost = CreateNameForEntity(_BuildingID);
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
        self.Data.Provinces[_ID].Outpost = nil;
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
            if v.Type == _Type and v.Owner == _PlayerID and IsExisting(v.Outpost) then
                local OutpostID = GetID(v.Outpost);
                local Level = Logic.GetUpgradeLevelForBuilding(OutpostID);
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
        if Data.Owner == _PlayerID and IsExisting(Data.Outpost) then
            local OutpostID = GetID(Data.Outpost);
            local Level = Logic.GetUpgradeLevelForBuilding(OutpostID);
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
            local ResourceName = XGUIEng.GetStringTableText("sh_names/Silver");
            Text = self:GetProvinceRevenue(_ID, _PlayerID).. " " ..ResourceName;
        elseif self.Data.Provinces[_ID].Type == ProvinceType.Reputation then
            Template = XGUIEng.GetStringTableText("sh_text/Province_Revenue_Bonus");
            local ResourceName = XGUIEng.GetStringTableText("sh_names/Reputation");
            Text = self:GetProvinceRevenue(_ID, _PlayerID).. " " ..ResourceName;
        elseif self.Data.Provinces[_ID].Type == ProvinceType.Resource then
            Template = XGUIEng.GetStringTableText("sh_text/Province_Revenue_Resource");
            local ResourceName = GetResourceName(self.Data.Provinces[_ID].Resource);
            Text = self:GetProvinceRevenue(_ID, _PlayerID).. " " ..ResourceName;
        elseif self.Data.Provinces[_ID].Type == ProvinceType.Encourage then
            Template = XGUIEng.GetStringTableText("sh_text/Province_Revenue_Encourage");
            Text = "" ..math.floor(self:GetProvinceRevenue(_ID, _PlayerID) * 100);
        elseif self.Data.Provinces[_ID].Type == ProvinceType.Protective then
            Template = XGUIEng.GetStringTableText("sh_text/Province_Revenue_Protective");
            Text = "" ..math.floor(self:GetProvinceRevenue(_ID, _PlayerID) * 100);
        elseif self.Data.Provinces[_ID].Type == ProvinceType.Slave then
            Template = XGUIEng.GetStringTableText("sh_text/Province_Revenue_Slave");
            Text = "" ..self:GetProvinceRevenue(_ID, _PlayerID);
        end
        if Template then
            Msg = string.format(Template, Text);
        end
    end
    return Msg;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Province:ControlProvince()
    for ID, Data in pairs(self.Data.Provinces) do
        if Data.Owner ~= self.Config.NeutralPlayerID and Data.Outpost ~= nil then
            if IsPlayer(Data.Owner) then
                if not IsExisting(Data.Outpost) then
                    self:LooseProvince(ID, Data.Owner);
                end
            end
        end
    end
end

function Stronghold.Province:OnPayday(_PlayerID, _Amount)
    local TaxAmount = _Amount;
    if IsPlayer(_PlayerID) and not IsAIPlayer(_PlayerID) then
        for ID, Data in pairs(self.Data.Provinces) do
            if Data and Data.Owner == _PlayerID then
                if Data.Type == ProvinceType.Resource then
                    local Amount = Stronghold.Province:GetProvinceRevenue(ID, Data.Owner);
                    Logic.AddToPlayersGlobalResource(Data.Owner, Data.Resource, Amount);
                end
                GameCallback_SH_Logic_OnProvincePayday(Data.Owner, ID);
            end
        end
    end
    return TaxAmount;
end

function Stronghold.Province:OnDamageInflicted(_AttackerID, _AttackedID, _Damage)
    local AttackerPlayerID = Logic.EntityGetPlayer(_AttackerID);
    local AttackedPlayerID = Logic.EntityGetPlayer(_AttackedID);
    local Damage = _Damage;

    -- Increase damage
    local DamageBonus = self:GetSumOfProvincesRevenue(ProvinceType.Encourage, AttackerPlayerID);
    Damage = Damage * math.min(1 + DamageBonus, 3);
    -- Decrease damage
    local DamageMalus = self:GetSumOfProvincesRevenue(ProvinceType.Protective, AttackedPlayerID);
    Damage = Damage * (1 - DamageMalus);

    return Damage;
end

function Stronghold.Province:CheckFortificationAllowed(_Type, _x, _y, _rotation, _isBuildOn)
    local PlayerID = GUI.GetPlayerID()
    if IsPlayer(PlayerID) and _isBuildOn then
        if Logic.IsEntityInCategory(_Type, EntityCategories.VillageCenter)
        or Logic.IsEntityInCategory(_Type, EntityCategories.Headquarters) == 1 then
            local Position = {X= _x or 0, Y= _y or 0};
            if IsValidPosition(Position) then
                for _, Data in pairs(self.Data.Provinces) do
                    if GetDistance(Position, Data.Position) <= 100 then
                        return not AreEnemiesInArea(PlayerID, {X= _x, Y= _y}, 5000);
                    end
                end
            end
        end
    end
    return true;
end

function Stronghold.Province:OnBuildingConstructed(_BuildingID, _PlayerID)
    if IsPlayer(_PlayerID) then
        if Logic.IsEntityInCategory(_BuildingID, EntityCategories.VillageCenter)
        or Logic.IsEntityInCategory(_BuildingID, EntityCategories.Headquarters) == 1 then
            local Position = GetPosition(_BuildingID);
            local EntityType = Logic.GetEntityType(_BuildingID);
            local TypeName = Logic.GetEntityTypeName(EntityType);
            if string.find(TypeName, "PB_Outpost")
            or string.find(TypeName, "PB_VillageCenter") then
                for ID, Data in pairs(self.Data.Provinces) do
                    if Data.Owner == self.Config.NeutralPlayerID then
                        if GetDistance(Position, Data.Position) <= 100 then
                            self:ClaimProvince(ID, _PlayerID, _BuildingID);
                        end
                    end
                end
            end
        end
    end
end

function Stronghold.Province:OnBuildingUpgraded(_BuildingID, _PlayerID)
    if IsPlayer(_PlayerID) then
        if Logic.IsEntityInCategory(_BuildingID, EntityCategories.VillageCenter)
        or Logic.IsEntityInCategory(_BuildingID, EntityCategories.Headquarters) == 1 then
            local ScriptName = CreateNameForEntity(_BuildingID);
            local EntityType = Logic.GetEntityType(_BuildingID);
            local TypeName = Logic.GetEntityTypeName(EntityType);
            if string.find(TypeName, "PB_Outpost")
            or string.find(TypeName, "PB_VillageCenter") then
                for ID, Data in pairs(self.Data.Provinces) do
                    if Data.Owner ~= self.Config.NeutralPlayerID and Data.Outpost == ScriptName then
                        self:UpgradeProvince(ID, _PlayerID, _BuildingID);
                    end
                end
            end
        end
    end
end

