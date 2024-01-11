---
--- Hero AI
---

Stronghold.AI.Data.Heroes = {};

-- -------------------------------------------------------------------------- --

function Stronghold.AI:ControlAiPlayerHeroes()
    for PlayerID = 1, GetMaxPlayers() do
        if IsAIPlayer(PlayerID) then
            if not self.Data.Heroes[PlayerID] then
                self.Data.Heroes[PlayerID] = {State = 1}
            end

            local HeroID = GetNobleID(PlayerID);
            local Type = Logic.GetEntityType(HeroID);
            if IsEntityValid(HeroID) then
                local DoorPos = GetHeadquarterEntrance(PlayerID);
                local OuterMaxDistance = 6000;
                local InnerMaxDistance = 4000;
                local PeaceDistance = 500;

                -- Find enemies
                if self.Data.Heroes[PlayerID].State == 1 then
                    if AreEnemiesInArea(PlayerID, DoorPos, InnerMaxDistance) then
                        self.Data.Heroes[PlayerID].State = 2;
                    else
                        if GetDistance(HeroID, DoorPos) > PeaceDistance then
                            self.Data.Heroes[PlayerID].State = 3;
                            --- @diagnostic disable-next-line: need-check-nil
                            Logic.MoveSettler(HeroID, DoorPos.X, DoorPos.Y);
                            for k,v in pairs(GetPlayerEntities(PlayerID, Entities.CU_Hero13_Summon)) do
                                Move(v, "DoorP" ..PlayerID);
                            end
                        end
                    end
                -- Battle enemies
                elseif self.Data.Heroes[PlayerID].State == 2 then
                    local MaxDistance = InnerMaxDistance;
                    if IsFighting(HeroID) then
                        MaxDistance = OuterMaxDistance;
                    end
                    if Type == Entities.PU_Hero5 or Type == Entities.PU_Her10 then
                        MaxDistance = MaxDistance - 1500;
                    end
                    if not AreEnemiesInArea(PlayerID, DoorPos, InnerMaxDistance) then
                        self.Data.Heroes[PlayerID].State = 3;
                        --- @diagnostic disable-next-line: need-check-nil
                        Logic.MoveSettler(HeroID, DoorPos.X, DoorPos.Y);
                        for k,v in pairs(GetPlayerEntities(PlayerID, Entities.CU_Hero13_Summon)) do
                            Move(v, "DoorP" ..PlayerID);
                        end
                    else
                        self:ControlAiPlayerHero(PlayerID, HeroID);
                    end
                -- Return home
                elseif self.Data.Heroes[PlayerID].State == 3 then
                    if Logic.IsEntityMoving(HeroID) == false then
                        --- @diagnostic disable-next-line: need-check-nil
                        Logic.MoveSettler(HeroID, DoorPos.X, DoorPos.Y);
                    end
                    if GetDistance(HeroID, DoorPos) <= PeaceDistance then
                        self.Data.Heroes[PlayerID].State = 1;
                    end
                end
            else
                self.Data.Heroes[PlayerID].State = 1;
            end
        end
    end
end

function Stronghold.AI:ControlAiPlayerHero(_PlayerID, _HeroID)
    local Type = Logic.GetEntityType(_HeroID);
    local TypeName = Logic.GetEntityTypeName(Type);

    if string.find(TypeName, "^PU_Hero1[abc]+$") then
        self:ControlHero1DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero2 then
        self:ControlHero2DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero3 then
        self:ControlHero3DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero4 then
        self:ControlHero4DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero5 then
        self:ControlHero5DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero6 then
        self:ControlHero6DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.CU_BlackKnight then
        self:ControlHero7DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.CU_Mary_de_Mortfichet then
        self:ControlHero8DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.CU_Barbarian_Hero then
        self:ControlHero9DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero10 then
        self:ControlHero10DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.PU_Hero11 then
        self:ControlHero11DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.CU_Evil_Queen then
        self:ControlHero12DefendCastle(_PlayerID, _HeroID);
    elseif Type == Entities.CU_Hero13 then
        self:ControlHero13DefendCastle(_PlayerID, _HeroID);
    end
end

-- Hero 1

function Stronghold.AI:ControlHero1DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Scare enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityInflictFear(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 2

function Stronghold.AI:ControlHero2DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Place bomb unter hero
        --- @diagnostic disable-next-line: undefined-field
        if math.mod(math.floor(Logic.GetTime()), 90) == 0 then
            local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
            if table.getn(CloseEnemies) >= 5 then
                local x,y,z = Logic.EntityGetPos(_HeroID);
                local ID = Logic.CreateEntity(Entities.XD_Bomb_Hero2, x, y, 0, _PlayerID);
                WriteEntityCreatedToLog(_PlayerID, ID, Logic.GetEntityType(ID));
            end
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 3

function Stronghold.AI:ControlHero3DefendCastle(_PlayerID, _HeroID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilityBuildCannon);
    local CurrentCharge = Logic.HeroGetAbilityChargeSeconds(_HeroID, Abilities.AbilityBuildCannon);
    if CurrentCharge >= RechargeTime then
        local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
        if table.getn(FarEnemyList) > 0 then
            -- Place "trap" near random enemy
            --- @diagnostic disable-next-line: undefined-field
            if math.mod(math.floor(Logic.GetTime()), 90) == 0 then
                local Selected = math.random(1, table.getn(FarEnemyList));
                local EnemyID = FarEnemyList[Selected];
                local x,y,z = Logic.EntityGetPos(EnemyID);
                local ID = Logic.CreateEntity(Entities.XD_Bomb_Hero2, x, y, 0, _PlayerID);
                WriteEntityCreatedToLog(_PlayerID, ID, Logic.GetEntityType(ID));
                Logic.HeroSetAbilityChargeSeconds(_HeroID, Abilities.AbilityBuildCannon, 0);
                SVLib.SetInvisibility(ID, true);
            end
            -- Attack enemies
            if not IsFighting(_HeroID) then
                local EnemyPos = GetPosition(FarEnemyList[1]);
                Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
            end
        end
    end
end

-- Hero 4

function Stronghold.AI:ControlHero4DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Hurt enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityCircularAttack(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 5

function Stronghold.AI:ControlHero5DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Hurt enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1800);
        local Selected = math.random(1, table.getn(CloseEnemies));
        local EnemyID = CloseEnemies[Selected];
        if Logic.IsSettler(EnemyID) == 1 then
            if Logic.IsEntityInCategory(EnemyID, EntityCategories.Soldier) == 1 then
                EnemyID = SVLib.GetLeaderOfSoldier(EnemyID);
            end
            self:HeroTriggerAbilityShuriken(_HeroID, EnemyID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 6

function Stronghold.AI:ControlHero6DefendCastle(_PlayerID, _HeroID)
    local HeroPos = GetPosition(_HeroID);
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Buff allies
        local AllyAmount = Logic.GetPlayerEntitiesInArea(_PlayerID, 0, HeroPos.X, HeroPos.Y, 1500, 16);
        if AllyAmount > 5 then
            self:HeroTriggerAbilityAffectUnits(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 7

function Stronghold.AI:ControlHero7DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Debuff enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityAffectUnits(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 8

function Stronghold.AI:ControlHero8DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Hurt enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityCircularAttack(_HeroID);
            self:HeroTriggerAbilityAffectUnits(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 9

function Stronghold.AI:ControlHero9DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Summon wolves
        if Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.CU_Barbarian_Hero_wolf) == 0 then
            local EnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 2000);
            if table.getn(EnemyList) > 0 then
                self:HeroTriggerAbilitySummon(_HeroID);
                return;
            end
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);

            local WolfList = GetPlayerEntities(_PlayerID, Entities.CU_Barbarian_Hero_wolf);
            for i= 1, table.getn(WolfList) do
                if not IsFighting(WolfList[i]) then
                    Logic.GroupAttackMove(WolfList[i], EnemyPos.X, EnemyPos.Y);
                end
            end
        end
    end
end

-- Hero 10

function Stronghold.AI:ControlHero10DefendCastle(_PlayerID, _HeroID)
    local HeroPos = GetPosition(_HeroID);
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Buff allies
        local AllyAmount = Logic.GetPlayerEntitiesInArea(_PlayerID, 0, HeroPos.X, HeroPos.Y, 1500, 16);
        if AllyAmount > 5 then
            self:HeroTriggerAbilityAffectUnits(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 11

function Stronghold.AI:ControlHero11DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Scare enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityInflictFear(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 12

function Stronghold.AI:ControlHero12DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    if table.getn(FarEnemyList) > 0 then
        -- Hurt enemies
        local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 1000);
        if table.getn(CloseEnemies) >= 5 then
            self:HeroTriggerAbilityCircularAttack(_HeroID);
        end
        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);
        end
    end
end

-- Hero 13

function Stronghold.AI:ControlHero13DefendCastle(_PlayerID, _HeroID)
    local FarEnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 3500);
    local HeroPos = GetPosition(_HeroID);
    if table.getn(FarEnemyList) > 0 then
        -- Summon Doppelganger if needed
        if Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.CU_Hero13_Summon) == 0 then
            local EnemyList = GetEnemiesInArea(_PlayerID, GetPosition(_HeroID), 2000);
            if table.getn(EnemyList) > 0 then
                self:HeroTriggerAbilitySummon(_HeroID);
                return;
            end
        end

        -- Attack enemies
        if not IsFighting(_HeroID) then
            local EnemyPos = GetPosition(FarEnemyList[1]);
            Logic.GroupAttackMove(_HeroID, EnemyPos.X, EnemyPos.Y);

            local Doppelganger = GetPlayerEntities(_PlayerID, Entities.CU_Hero13_Summon);
            for i= 1, table.getn(Doppelganger) do
                if not IsFighting(Doppelganger[i]) then
                    Logic.GroupAttackMove(Doppelganger[i], EnemyPos.X, EnemyPos.Y);
                end
            end
        end

        -- Buff allies
        local AllyAmount = Logic.GetPlayerEntitiesInArea(_PlayerID, 0, HeroPos.X, HeroPos.Y, 1500, 16);
        if AllyAmount > 5 then
            self:HeroTriggerAbilityAffectUnits(_HeroID);
        end

        -- Circula attack
        local Doppelganger = GetPlayerEntities(_PlayerID, Entities.CU_Hero13_Summon);
        for i= 1, table.getn(Doppelganger) do
            local CloseEnemies = GetEnemiesInArea(_PlayerID, GetPosition(Doppelganger[i]), 300);
            if table.getn(CloseEnemies) >= 1 then
                self:HeroTriggerAbilityCircularAttack(Doppelganger[i]);
            end
        end
    end
end

-- Helper

function Stronghold.AI:HeroTriggerAbilityInflictFear(_HeroID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilityInflictFear);
    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(_HeroID, Abilities.AbilityInflictFear);
    if TimeLeft ~= RechargeTime then
        return;
    end
    if XNetwork.Manager_DoesExist() == 1 and SendEvent then
        SendEvent.SettlerInflictFear(_HeroID);
        return;
    end
    GUI.SettlerInflictFear(_HeroID);
end

function Stronghold.AI:HeroTriggerAbilityAffectUnits(_HeroID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilityRangedEffect);
    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(_HeroID, Abilities.AbilityRangedEffect);
    if TimeLeft ~= RechargeTime then
        return;
    end
    if XNetwork.Manager_DoesExist() == 1 and SendEvent then
        SendEvent.SettlerAffectUnitsInArea(_HeroID);
        return;
    end
    GUI.SettlerAffectUnitsInArea(_HeroID);
end

function Stronghold.AI:HeroTriggerAbilityCircularAttack(_HeroID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilityCircularAttack);
    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(_HeroID, Abilities.AbilityCircularAttack);
    if TimeLeft ~= RechargeTime then
        return;
    end
    if XNetwork.Manager_DoesExist() == 1 and SendEvent then
        SendEvent.SettlerCircularAttack(_HeroID);
        return;
    end
    GUI.SettlerCircularAttack(_HeroID);
end

function Stronghold.AI:HeroTriggerAbilitySummon(_HeroID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilitySummon);
    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(_HeroID, Abilities.AbilitySummon);
    if TimeLeft ~= RechargeTime then
        return;
    end
    if XNetwork.Manager_DoesExist() == 1 and SendEvent then
        SendEvent.SettlerSummon(_HeroID);
        return;
    end
    GUI.SettlerSummon(_HeroID);
end

function Stronghold.AI:HeroTriggerAbilityShuriken(_HeroID, _TargetID)
    local RechargeTime = Logic.HeroGetAbilityRechargeTime(_HeroID, Abilities.AbilityShuriken);
    local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(_HeroID, Abilities.AbilityShuriken);
    if TimeLeft ~= RechargeTime then
        return;
    end
    if XNetwork.Manager_DoesExist() == 1 and SendEvent then
        SendEvent.HeroShuriken(_HeroID, _TargetID);
        return;
    end
    GUI.SettlerSummon(_HeroID, _TargetID);
end

