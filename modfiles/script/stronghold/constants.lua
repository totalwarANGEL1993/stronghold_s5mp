

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

