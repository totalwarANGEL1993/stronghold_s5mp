--- 
--- Province Script
---
--- Provinces are special locations a player can claim to get their benefits.
---
--- Defined game callbacks:
--- - GameCallback_Logic_OnProvinceClaimed(_PlayerID, _ProvinceID, _BuildingID)
---   A player claimed a province.
--- 
--- - GameCallback_Logic_OnProvinceLost(_PlayerID, _ProvinceID, _BuildingID)
---   A player lost a ptovince.
--- 

Stronghold = Stronghold or {};

ProvinceType = {
    -- Province produces honor
    Honor = 1,
    -- Province produces reputation
    Reputation = 2,
    -- Province grants additional military capacity
    Military = 3,
    -- Province produces resources
    Resource = 4,
}

Stronghold.Province = {
    ProvinceIdSequence = 0,
    Data = {
        Provinces = {},
    },
    Config = {
        NeutralPlayerID = 8,
        UI = {
            Msg = {
                Claimed = {
                    de = "%s{grey}hat die Provinz %s{grey}beansprucht.",
                    en = "%s{grey}has put %s{grey}under their control.",
                },
                Denyed = {
                    de = "Feinde verhindern den Bau des Dorfzentrums!",
                    en = "Enemies prevent the construction of the village center!",
                },
                Lost = {
                    de = "{grey}Die Provinz %s{grey}ist nun unabhängig.",
                    en = "{grey}The province %s{grey}has become independed.",
                },
            }
        }
    },
}

function Stronghold.Province:Install()
    self:StartTriggers();
end

function Stronghold.Province:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --

-- Creates a province that is granting honor when claimed.
function CreateHonorProvince(_Name, _Position, _AmountOfHonor, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Honor,
        DisplayName = _Name,
        Position    = GetPosition(_Position),
        Amount      = _AmountOfHonor,
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

-- Creates a province that is granting reputation when claimed.
function CreateReputationProvince(_Name, _Position, _AmountOfReputation, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Reputation,
        DisplayName = _Name,
        Position    = GetPosition(_Position),
        Amount      = _AmountOfReputation,
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

-- Creates a province that is granting additional military space when claimed.
function CreateMilitaryProvince(_Name, _Position, _AmountOfUnits, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Military,
        DisplayName = _Name,
        Position    = GetPosition(_Position),
        Amount      = _AmountOfUnits,
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

-- Creates a province that is producing resources when claimed.
function CreateResourceProvince(_Name, _Position, _UpdateTime, _Gold, _Clay, _Wood, _Stone, _Iron, _Sulfur, ...)
    local ID = Stronghold.Province:CreateProvince {
        Type        = ProvinceType.Resource,
        DisplayName = _Name,
        Position    = GetPosition(_Position),
        Resources   = {_Gold, _Clay, _Wood, _Stone, _Iron, _Sulfur},
        UpdateTime  = _UpdateTime * 10;
    };
    for i= 1, table.getn(arg) do
        Stronghold.Province:AddExplorerEntity(ID, arg[i]);
    end
    return ID;
end

-- -------------------------------------------------------------------------- --

function GameCallback_Logic_OnProvinceClaimed(_PlayerID, _ProvinceID, _BuildingID)
end

function GameCallback_Logic_OnProvinceLost(_PlayerID, _ProvinceID, _BuildingID)
end

-- -------------------------------------------------------------------------- --

function Stronghold.Province:CreateProvince(_Data)
    self.ProvinceIdSequence = self.ProvinceIdSequence +1;
    local ID = self.ProvinceIdSequence;

    _Data.ID = ID;
    _Data.Owner = self.Config.NeutralPlayerID;
    _Data.DisplayName = _Data.DisplayName or ("Province" ..ID);
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
            self.Config.UI.Msg.Claimed[Lang],
            PlayerColor.. " " ..PlayerName,
            self.Data.Provinces[_ID].DisplayName
        ));
        -- TODO: Sound

        GameCallback_Logic_OnProvinceClaimed(_PlayerID, _ID, _BuildingID);
    end
end

function Stronghold.Province:LooseProvince(_ID, _PlayerID, _BuildingID)
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
            self.Config.UI.Msg.Lost[Lang],
            self.Data.Provinces[_ID].DisplayName
        ));
        -- TODO: Sound

        GameCallback_Logic_OnProvinceLost(_PlayerID, _ID, _BuildingID);
    end
end

function Stronghold.Province:GetProvinceHonorForPlayer(_PlayerID)
    local Amount = 0;
    for k,v in pairs(self.Data.Provinces) do
        if v.Owner == _PlayerID and v.Type == ProvinceType.Honor then
            Amount = Amount + v.Amount;
        end
    end
    return Amount;
end

function Stronghold.Province:GetProvinceReputationForPlayer(_PlayerID)
    local Amount = 0;
    for k,v in pairs(self.Data.Provinces) do
        if v.Owner == _PlayerID and v.Type == ProvinceType.Reputation then
            Amount = Amount + v.Amount;
        end
    end
    return Amount;
end

function Stronghold.Province:GetProvinceMilitaryAttractionForPlayer(_PlayerID)
    local Amount = 0;
    for k,v in pairs(self.Data.Provinces) do
        if v.Owner == _PlayerID and v.Type == ProvinceType.Military then
            Amount = Amount + v.Amount;
        end
    end
    return Amount;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Province:StartTriggers()
    Overwrite.CreateOverwrite("GameCallback_Calculate_HonorIncreaseSpecial", function(_PlayerID)
        local Amount = Overwrite.CallOriginal();
        Amount = Amount + Stronghold.Province:GetProvinceHonorForPlayer(_PlayerID);
        return Amount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_ReputationIncreaseExternal", function(_PlayerID)
        local Amount = Overwrite.CallOriginal();
        Amount = Amount + Stronghold.Province:GetProvinceReputationForPlayer(_PlayerID);
        return Amount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_MilitaryAttrationLimit", function(_PlayerID, _Amount)
        local Amount = Overwrite.CallOriginal();
        Amount = Amount + Stronghold.Province:GetProvinceMilitaryAttractionForPlayer(_PlayerID);
        return Amount;
    end);

    Overwrite.CreateOverwrite("GameCallback_OnBuildingConstructionComplete", function(_BuildingID, _PlayerID)
        Overwrite.CallOriginal();
        Stronghold.Province:OnBuildingConstructed(_BuildingID, _PlayerID);
    end);

    Job.Destroy(function()
        local BuildingID = Event.GetEntityID();
        local PlayerID = Event.GetPlayerID();
        Stronghold.Province:OnBuildingDestroyed(BuildingID, PlayerID);
    end);

    Job.Create(function()
        local BuildingID = Event.GetEntityID();
        local PlayerID = Event.GetPlayerID();
        Stronghold.Province:OnBuildingCreated(BuildingID, PlayerID);
    end);

    Job.Turn(function()
        Stronghold.Province:ControlProvince();
    end);
end

function Stronghold.Province:ControlProvince()
    for k,v in pairs(self.Data.Provinces) do
        if v and v.Owner ~= self.Config.NeutralPlayerID then
            if v.Type == ProvinceType.Resource then
                if (v.LastUpdate or 0) + v.UpdateTime < Logic.GetCurrentTurn() then
                    local Res = v.Resources or {0,0,0,0,0,0};
                    Tools.GiveResouces(v.Owner, Res[1] or 0, Res[2] or 0, Res[3] or 0, Res[4] or 0, Res[5] or 0, Res[6] or 0);
                    self.Data.Provinces[k].LastUpdate = Logic.GetCurrentTurn();
                end
            end
        end
    end
end

function Stronghold.Province:OnBuildingCreated(_BuildingID, _PlayerID)
    if Logic.IsEntityInCategory(_BuildingID, EntityCategories.VillageCenter) == 1 then
        if Logic.IsConstructionComplete(_BuildingID) == 0 then
            local VillagePosition = GetPosition(_BuildingID);
            for k,v in pairs(self.Data.Provinces) do
                if v.Owner == self.Config.NeutralPlayerID then
                    if GetDistance(VillagePosition, v.Position) <= 4000 then
                        if AreEnemiesInArea(_PlayerID, v.Position, 7000) then
                            Message(self.Config.UI.Msg.Lost[GetLanguage()]);
                            SetHealth(_BuildingID, 0);
                        end
                    end
                end
            end
        end
    end
end

function Stronghold.Province:OnBuildingDestroyed(_BuildingID, _PlayerID)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    if Logic.IsEntityInCategory(_BuildingID, EntityCategories.VillageCenter) == 1 then
        local VillageName = CreateNameForEntity(_BuildingID);
        for k,v in pairs(self.Data.Provinces) do
            if v.Owner ~= self.Config.NeutralPlayerID and VillageName == v.Village then
                self:LooseProvince(k, PlayerID, _BuildingID);
            end
        end
    end
end

function Stronghold.Province:OnBuildingConstructed(_BuildingID, _PlayerID)
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

