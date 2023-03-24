--- 
--- Constants for outlaw
--- 

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

