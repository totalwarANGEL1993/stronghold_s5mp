

Gender = {
    Male = 1,
    Female = 2
}

Rank = {
    Commoner = 0,
    Noble = 1,
    Mayor = 2,
    Earl = 3,
    Baron = 4,
    Count = 5,
    Margrave = 6,
    Duke = 7
};

Requirement = {
    Headquarters = 1,
    Cathedral = 2,
    Workers = 3,
    Soldiers = 4,
    SettlerType = 5,
    BuildingType = 6,
    Beautification = 7,
    Custom = 8,
}

OutlawAttackState = {
    -- The camp waits for troops to respawn.
    RecruitUnits = 1,
    -- The camp moves the troops to the attack target.
    AdvanceUnits = 2,
    -- The camp attacks all targets in the area.
    PillageArea = 3,
    -- The attackers return to the camp and vanish.
    RetreatHome = 4,
    -- The attackers regroup when to far appart
    StandGround = 5,
    -- Troops defend while recruiting
    DefendBase = 6,
};

ProvinceType = {
    -- Province produces honor
    Honor = 1,
    -- Province produces reputation
    Reputation = 2,
    -- Province grants additional military capacity
    Military = 3,
    -- Province produces resources
    Resource = 4,
    -- Province produces resources
    Custom = 5,
}

