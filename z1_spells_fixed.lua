print("[Z1 Spells] Loading vocation-based Z1 spell system...")

local Z1_MIN_LEVEL = 1000

-- Level-focused formulas because skill/magic caps are currently annoying little gremlins.

function z1SorcererEnergyFormula(player, level, maglevel)
    local min = (level * 2.2) + (maglevel * 8)
    local max = (level * 3.4) + (maglevel * 12)
    return -min, -max
end

function z1SorcererFireFormula(player, level, maglevel)
    local min = (level * 2.4) + (maglevel * 8)
    local max = (level * 3.6) + (maglevel * 12)
    return -min, -max
end

function z1DruidIceFormula(player, level, maglevel)
    local min = (level * 2.2) + (maglevel * 8)
    local max = (level * 3.4) + (maglevel * 12)
    return -min, -max
end

function z1DruidEarthFormula(player, level, maglevel)
    local min = (level * 2.3) + (maglevel * 8)
    local max = (level * 3.5) + (maglevel * 12)
    return -min, -max
end

function z1PaladinHolyFormula(player, level, maglevel)
    local min = (level * 2.8) + (maglevel * 4)
    local max = (level * 4.0) + (maglevel * 6)
    return -min, -max
end

function z1KnightPhysicalFormula(player, level, maglevel)
    local min = (level * 3.0) + (maglevel * 2)
    local max = (level * 4.4) + (maglevel * 4)
    return -min, -max
end

function z1HealFormula(player, level, maglevel)
    local min = (level * 1.4) + (maglevel * 30)
    local max = (level * 2.1) + (maglevel * 50)
    return min, max
end

function z1MaxHealFormula(player, level, maglevel)
    local min = (level * 2.2) + (maglevel * 50)
    local max = (level * 3.4) + (maglevel * 80)
    return min, max
end

-- =========================================================
-- SORCERER: ENERGY
-- =========================================================

local combatSorcererEnergy = Combat()
combatSorcererEnergy:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combatSorcererEnergy:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_BIGCLOUDS)
combatSorcererEnergy:setArea(createCombatArea(AREA_CIRCLE6X6))
combatSorcererEnergy:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "z1SorcererEnergyFormula")

local spellSorcererEnergy = Spell("instant")

function spellSorcererEnergy.onCastSpell(creature, variant)
    return combatSorcererEnergy:execute(creature, variant)
end

spellSorcererEnergy:group("attack", "focus")
spellSorcererEnergy:id(50101)
spellSorcererEnergy:name("Z1 Rage of the Skies")
spellSorcererEnergy:words("z1 gran mas vis")
spellSorcererEnergy:level(Z1_MIN_LEVEL)
spellSorcererEnergy:mana(12000)
spellSorcererEnergy:isSelfTarget(true)
spellSorcererEnergy:isPremium(false)
spellSorcererEnergy:isAggressive(true)
spellSorcererEnergy:blockWalls(true)
spellSorcererEnergy:cooldown(4 * 1000)
spellSorcererEnergy:groupCooldown(2 * 1000, 2 * 1000)
spellSorcererEnergy:needLearn(false)
spellSorcererEnergy:vocation("sorcerer;true", "master sorcerer;true")
spellSorcererEnergy:register()

-- =========================================================
-- SORCERER: FIRE
-- =========================================================

local combatSorcererFire = Combat()
combatSorcererFire:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combatSorcererFire:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)
combatSorcererFire:setArea(createCombatArea(AREA_CIRCLE6X6))
combatSorcererFire:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "z1SorcererFireFormula")

local spellSorcererFire = Spell("instant")

function spellSorcererFire.onCastSpell(creature, variant)
    return combatSorcererFire:execute(creature, variant)
end

spellSorcererFire:group("attack", "focus")
spellSorcererFire:id(50102)
spellSorcererFire:name("Z1 Hell Core")
spellSorcererFire:words("z1 gran mas flam")
spellSorcererFire:level(Z1_MIN_LEVEL)
spellSorcererFire:mana(14000)
spellSorcererFire:isSelfTarget(true)
spellSorcererFire:isPremium(false)
spellSorcererFire:isAggressive(true)
spellSorcererFire:blockWalls(true)
spellSorcererFire:cooldown(4 * 1000)
spellSorcererFire:groupCooldown(2 * 1000, 2 * 1000)
spellSorcererFire:needLearn(false)
spellSorcererFire:vocation("sorcerer;true", "master sorcerer;true")
spellSorcererFire:register()

-- =========================================================
-- DRUID: ICE
-- =========================================================

local combatDruidIce = Combat()
combatDruidIce:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combatDruidIce:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICEAREA)
combatDruidIce:setArea(createCombatArea(AREA_CIRCLE6X6))
combatDruidIce:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "z1DruidIceFormula")

local spellDruidIce = Spell("instant")

function spellDruidIce.onCastSpell(creature, variant)
    return combatDruidIce:execute(creature, variant)
end

spellDruidIce:group("attack", "focus")
spellDruidIce:id(50103)
spellDruidIce:name("Z1 Frozen Sky")
spellDruidIce:words("z1 gran mas frigo")
spellDruidIce:level(Z1_MIN_LEVEL)
spellDruidIce:mana(13000)
spellDruidIce:isSelfTarget(true)
spellDruidIce:isPremium(false)
spellDruidIce:isAggressive(true)
spellDruidIce:blockWalls(true)
spellDruidIce:cooldown(4 * 1000)
spellDruidIce:groupCooldown(2 * 1000, 2 * 1000)
spellDruidIce:needLearn(false)
spellDruidIce:vocation("druid;true", "elder druid;true")
spellDruidIce:register()

-- =========================================================
-- DRUID: EARTH
-- =========================================================

local combatDruidEarth = Combat()
combatDruidEarth:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combatDruidEarth:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_CARNIPHILA)
combatDruidEarth:setArea(createCombatArea(AREA_CIRCLE6X6))
combatDruidEarth:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "z1DruidEarthFormula")

local spellDruidEarth = Spell("instant")

function spellDruidEarth.onCastSpell(creature, variant)
    return combatDruidEarth:execute(creature, variant)
end

spellDruidEarth:group("attack", "focus")
spellDruidEarth:id(50104)
spellDruidEarth:name("Z1 Terra Collapse")
spellDruidEarth:words("z1 gran mas tera")
spellDruidEarth:level(Z1_MIN_LEVEL)
spellDruidEarth:mana(13000)
spellDruidEarth:isSelfTarget(true)
spellDruidEarth:isPremium(false)
spellDruidEarth:isAggressive(true)
spellDruidEarth:blockWalls(true)
spellDruidEarth:cooldown(4 * 1000)
spellDruidEarth:groupCooldown(2 * 1000, 2 * 1000)
spellDruidEarth:needLearn(false)
spellDruidEarth:vocation("druid;true", "elder druid;true")
spellDruidEarth:register()

-- =========================================================
-- PALADIN: HOLY
-- =========================================================

local combatPaladinHoly = Combat()
combatPaladinHoly:setParameter(COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
combatPaladinHoly:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HOLYAREA)
combatPaladinHoly:setArea(createCombatArea(AREA_CIRCLE6X6))
combatPaladinHoly:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "z1PaladinHolyFormula")

local spellPaladinHoly = Spell("instant")

function spellPaladinHoly.onCastSpell(creature, variant)
    return combatPaladinHoly:execute(creature, variant)
end

spellPaladinHoly:group("attack", "focus")
spellPaladinHoly:id(50105)
spellPaladinHoly:name("Z1 Divine Collapse")
spellPaladinHoly:words("z1 gran mas san")
spellPaladinHoly:level(Z1_MIN_LEVEL)
spellPaladinHoly:mana(10000)
spellPaladinHoly:isSelfTarget(true)
spellPaladinHoly:isPremium(false)
spellPaladinHoly:isAggressive(true)
spellPaladinHoly:blockWalls(true)
spellPaladinHoly:cooldown(4 * 1000)
spellPaladinHoly:groupCooldown(2 * 1000, 2 * 1000)
spellPaladinHoly:needLearn(false)
spellPaladinHoly:vocation("paladin;true", "royal paladin;true")
spellPaladinHoly:register()

-- =========================================================
-- KNIGHT: PHYSICAL
-- =========================================================

local combatKnightPhysical = Combat()
combatKnightPhysical:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combatKnightPhysical:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_EXPLOSIONAREA)
combatKnightPhysical:setArea(createCombatArea(AREA_CIRCLE6X6))
combatKnightPhysical:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "z1KnightPhysicalFormula")

local spellKnightPhysical = Spell("instant")

function spellKnightPhysical.onCastSpell(creature, variant)
    return combatKnightPhysical:execute(creature, variant)
end

spellKnightPhysical:group("attack", "focus")
spellKnightPhysical:id(50106)
spellKnightPhysical:name("Z1 Titan Break")
spellKnightPhysical:words("z1 gran mas ico")
spellKnightPhysical:level(Z1_MIN_LEVEL)
spellKnightPhysical:mana(8000)
spellKnightPhysical:isSelfTarget(true)
spellKnightPhysical:isPremium(false)
spellKnightPhysical:isAggressive(true)
spellKnightPhysical:blockWalls(true)
spellKnightPhysical:cooldown(4 * 1000)
spellKnightPhysical:groupCooldown(2 * 1000, 2 * 1000)
spellKnightPhysical:needLearn(false)
spellKnightPhysical:vocation("knight;true", "elite knight;true")
spellKnightPhysical:register()

-- =========================================================
-- UNIVERSAL HEAL
-- =========================================================

local combatZ1Heal = Combat()
combatZ1Heal:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combatZ1Heal:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combatZ1Heal:setParameter(COMBAT_PARAM_AGGRESSIVE, false)
combatZ1Heal:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "z1HealFormula")

local spellZ1Heal = Spell("instant")

function spellZ1Heal.onCastSpell(creature, variant)
    return combatZ1Heal:execute(creature, variant)
end

spellZ1Heal:group("healing")
spellZ1Heal:id(50107)
spellZ1Heal:name("Z1 Grand Healing")
spellZ1Heal:words("exura gran z1")
spellZ1Heal:level(Z1_MIN_LEVEL)
spellZ1Heal:mana(8000)
spellZ1Heal:isSelfTarget(true)
spellZ1Heal:isPremium(false)
spellZ1Heal:isAggressive(false)
spellZ1Heal:cooldown(2 * 1000)
spellZ1Heal:groupCooldown(1 * 1000)
spellZ1Heal:needLearn(false)
spellZ1Heal:register()

-- =========================================================
-- UNIVERSAL MAX HEAL
-- =========================================================

local combatZ1MaxHeal = Combat()
combatZ1MaxHeal:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combatZ1MaxHeal:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_GREEN)
combatZ1MaxHeal:setParameter(COMBAT_PARAM_AGGRESSIVE, false)
combatZ1MaxHeal:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "z1MaxHealFormula")

local spellZ1MaxHeal = Spell("instant")

function spellZ1MaxHeal.onCastSpell(creature, variant)
    return combatZ1MaxHeal:execute(creature, variant)
end

spellZ1MaxHeal:group("healing")
spellZ1MaxHeal:id(50108)
spellZ1MaxHeal:name("Z1 Supreme Healing")
spellZ1MaxHeal:words("exura max z1")
spellZ1MaxHeal:level(Z1_MIN_LEVEL)
spellZ1MaxHeal:mana(16000)
spellZ1MaxHeal:isSelfTarget(true)
spellZ1MaxHeal:isPremium(false)
spellZ1MaxHeal:isAggressive(false)
spellZ1MaxHeal:cooldown(6 * 1000)
spellZ1MaxHeal:groupCooldown(1 * 1000)
spellZ1MaxHeal:needLearn(false)
spellZ1MaxHeal:register()

print("[Z1 Spells] Vocation-based Z1 spell system loaded.")