local mType = Game.createMonsterType("Training Monk")
local monster = {}

monster.description = "a training monk"
monster.experience = 500000

monster.outfit = {
    lookType = 57,
    lookHead = 0,
    lookBody = 0,
    lookLegs = 0,
    lookFeet = 0,
    lookAddons = 0,
    lookMount = 0,
}

monster.raceId = 57
monster.health = 10000000
monster.maxHealth = 10000000
monster.race = "blood"
monster.corpse = 18090
monster.speed = 0
monster.manaCost = 0

monster.changeTarget = {
    interval = 4000,
    chance = 0,
}

monster.strategiesTarget = {
    nearest = 100,
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
    staticAttackChance = 100,
    targetDistance = 1,
    runHealth = 0,
    healthHidden = false,
    isBlockable = true,
    canWalkOnEnergy = false,
    canWalkOnFire = false,
    canWalkOnPoison = false,
}

monster.light = {
    level = 0,
    color = 0,
}

monster.voices = {
    interval = 10000,
    chance = 5,
    { text = "Train harder.", yell = false },
    { text = "Discipline creates power.", yell = false },
}

monster.loot = {}

monster.attacks = {
    { name = "melee", interval = 2000, chance = 100, minDamage = 0, maxDamage = -5 },
}

monster.defenses = {
    defense = 100,
    armor = 10,
    mitigation = 10,
    { name = "combat", interval = 1000, chance = 100, type = COMBAT_HEALING, minDamage = 50000, maxDamage = 100000, effect = CONST_ME_MAGIC_BLUE, target = false },
}

monster.elements = {
    { type = COMBAT_PHYSICALDAMAGE, percent = 0 },
    { type = COMBAT_ENERGYDAMAGE, percent = 0 },
    { type = COMBAT_EARTHDAMAGE, percent = 0 },
    { type = COMBAT_FIREDAMAGE, percent = 0 },
    { type = COMBAT_LIFEDRAIN, percent = 0 },
    { type = COMBAT_MANADRAIN, percent = 0 },
    { type = COMBAT_DROWNDAMAGE, percent = 0 },
    { type = COMBAT_ICEDAMAGE, percent = 0 },
    { type = COMBAT_HOLYDAMAGE, percent = 0 },
    { type = COMBAT_DEATHDAMAGE, percent = 0 },
}

monster.immunities = {
    { type = "paralyze", condition = true },
    { type = "outfit", condition = true },
    { type = "invisible", condition = true },
    { type = "bleed", condition = true },
    { type = "fire", condition = true },
    { type = "energy", condition = true },
    { type = "poison", condition = true },
}

mType:register(monster)