-- Z1 Custom Monster: Exp Bug
-- Purpose: controlled boosted XP creature for leveling/testing/progression events.
-- Put this file in: data/monster/custom/exp_bug.lua
-- If your server does not auto-load monster folders, add it to monsters.xml.

-- Do NOT dofile here. Monster files can load from a different root folder in Canary.
-- The loot core is already loaded by data/scripts/custom/00_z1_loot_core.lua.
-- If it is missing, this monster falls back to a simple loot table.

local mType = Game.createMonsterType('Exp Bug')
local monster = {}

monster.description = 'an exp bug'
monster.experience = 500000
monster.outfit = {
    lookType = 45,
    lookHead = 0,
    lookBody = 0,
    lookLegs = 0,
    lookFeet = 0,
    lookAddons = 0,
    lookMount = 0,
}

monster.health = 3500
monster.maxHealth = 3500
monster.race = 'venom'
monster.corpse = 5961
monster.speed = 180
monster.manaCost = 0

monster.changeTarget = {
    interval = 4000,
    chance = 8,
}

monster.strategiesTarget = {
    nearest = 80,
    health = 10,
    damage = 10,
    random = 0,
}

monster.flags = {
    summonable = false,
    attackable = true,
    hostile = true,
    convinceable = false,
    pushable = false,
    rewardBoss = false,
    illusionable = false,
    canPushItems = false,
    canPushCreatures = false,
    staticAttackChance = 90,
    targetDistance = 1,
    runHealth = 0,
    healthHidden = false,
    isBlockable = false,
    canWalkOnEnergy = true,
    canWalkOnFire = false,
    canWalkOnPoison = true,
}

monster.light = {
    level = 0,
    color = 0,
}

monster.voices = {
    interval = 5000,
    chance = 10,
    { text = 'bzzzt... experience detected', yell = false },
    { text = 'debugging reality...', yell = false },
}

if Z1Loot and Z1Loot.build then
    monster.loot = Z1Loot.build('expBoost', monster.experience, {
        { name = 'gold ingot', chance = 1000, maxCount = 1 },
    })
else
    print('[Z1 Exp Bug] WARNING: Z1Loot not loaded. Using fallback loot table.')
    monster.loot = {
        { name = 'platinum coin', chance = 80000, maxCount = 100 },
        { name = 'crystal coin', chance = 20000, maxCount = 5 },
        { name = 'gold ingot', chance = 1000, maxCount = 1 },
    }
end

monster.attacks = {
    { name = 'melee', interval = 2000, chance = 100, minDamage = 0, maxDamage = -180 },
    { name = 'combat', interval = 2500, chance = 20, type = COMBAT_ENERGYDAMAGE, minDamage = -80, maxDamage = -220, range = 5, shootEffect = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYHIT, target = true },
}

monster.defenses = {
    defense = 30,
    armor = 35,
    mitigation = 0.85,
    { name = 'combat', interval = 3000, chance = 12, type = COMBAT_HEALING, minDamage = 80, maxDamage = 180, effect = CONST_ME_MAGIC_BLUE, target = false },
}

monster.elements = {
    { type = COMBAT_PHYSICALDAMAGE, percent = 0 },
    { type = COMBAT_ENERGYDAMAGE, percent = 30 },
    { type = COMBAT_EARTHDAMAGE, percent = 100 },
    { type = COMBAT_FIREDAMAGE, percent = -10 },
    { type = COMBAT_LIFEDRAIN, percent = 0 },
    { type = COMBAT_MANADRAIN, percent = 0 },
    { type = COMBAT_DROWNDAMAGE, percent = 0 },
    { type = COMBAT_ICEDAMAGE, percent = 10 },
    { type = COMBAT_HOLYDAMAGE, percent = 0 },
    { type = COMBAT_DEATHDAMAGE, percent = 0 },
}

monster.immunities = {
    { type = 'paralyze', condition = false },
    { type = 'outfit', condition = false },
    { type = 'invisible', condition = true },
    { type = 'bleed', condition = false },
}

mType:register(monster)
