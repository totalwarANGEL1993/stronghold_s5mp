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
            [Rank.Noble]    = {},
            [Rank.Mayor]    = {},
            [Rank.Earl]     = {},
            [Rank.Baron]    = {},
            [Rank.Count]    = {},
            [Rank.Margrave] = {},
            [Rank.Duke]     = {},
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
end

function Stronghold.Promotion:OnSaveGameLoaded()
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

