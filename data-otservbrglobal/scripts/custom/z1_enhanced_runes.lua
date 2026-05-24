print("[Z1 Runes] Loading simplified Z1/Z2 rune system...")

local allowedMages = {
	[1] = true, -- Sorcerer
	[2] = true, -- Druid
	[5] = true, -- Master Sorcerer
	[6] = true, -- Elder Druid
}

local function isMage(player)
	return allowedMages[player:getVocation():getId()] == true
end

local function getTargetPlayer(creature, variant)
	local target = nil

	if variant and variant.getNumber then
		target = Player(variant:getNumber())
	end

	if target then
		return target
	end

	return creature:getPlayer()
end

local function restoreMana(target, amount)
	if not target then
		return false
	end

	local currentMana = target:getMana()
	local maxMana = target:getMaxMana()

	if currentMana >= maxMana then
		target:sendCancelMessage("You already have full mana.")
		target:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local restoreAmount = math.min(amount, maxMana - currentMana)
	target:addMana(restoreAmount)
	target:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	target:sendTextMessage(MESSAGE_HEALED, "You recovered " .. restoreAmount .. " mana.")
	return true
end

local function restoreHealth(target, amount)
	if not target then
		return false
	end

	local currentHealth = target:getHealth()
	local maxHealth = target:getMaxHealth()

	if currentHealth >= maxHealth then
		target:sendCancelMessage("You already have full health.")
		target:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local restoreAmount = math.min(amount, maxHealth - currentHealth)
	target:addHealth(restoreAmount)
	target:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	target:sendTextMessage(MESSAGE_HEALED, "You healed " .. restoreAmount .. " health.")
	return true
end

local function registerManaRune(name, runeId, amount)
	local spell = Spell("rune")
	spell:name(name)
	spell:runeId(runeId)
	spell:charges(2)
	spell:allowFarUse(true)
	spell:blockWalls(false)

	function spell.onCastSpell(creature, variant, isHotkey)
		local caster = creature:getPlayer()
		if not caster then
			return false
		end

		local target = getTargetPlayer(creature, variant)
		return restoreMana(target, amount)
	end

	spell:register()
end

local function registerHealingRune(name, runeId, amount)
	local spell = Spell("rune")
	spell:name(name)
	spell:runeId(runeId)
	spell:charges(1)
	spell:allowFarUse(true)
	spell:blockWalls(false)

	function spell.onCastSpell(creature, variant, isHotkey)
		local caster = creature:getPlayer()
		if not caster then
			return false
		end

		local target = getTargetPlayer(creature, variant)
		return restoreHealth(target, amount)
	end

	spell:register()
end

local function registerSDRune(name, runeId, minDamage, maxDamage)
	local combat = Combat()
	combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
	combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)
	combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_SUDDENDEATH)

	function onGetFormulaValues(player, level, magicLevel)
		if not isMage(player) then
			return 0, 0
		end

		return -minDamage, -maxDamage
	end

	combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

	local spell = Spell("rune")
	spell:name(name)
	spell:runeId(runeId)
	spell:charges(1)
	spell:allowFarUse(true)
	spell:blockWalls(true)

	function spell.onCastSpell(creature, variant, isHotkey)
		local player = creature:getPlayer()
		if not player then
			return false
		end

		if not isMage(player) then
			player:sendCancelMessage("Only sorcerers and druids can use this rune.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		return combat:execute(creature, variant)
	end

	spell:register()
end

registerHealingRune("Z2 Healing Rune", 11603, 2500)
registerHealingRune("Z1 Healing Rune", 11604, 7500)

registerSDRune("Z2 SD Rune", 11609, 1800, 3200)
registerSDRune("Z1 SD Rune", 11610, 4000, 7000)

registerManaRune("Z2 Mana Rune", 11629, 5000)
registerManaRune("Z1 Mana Rune", 11630, 15000)

print("[Z1 Runes] Loaded: Z1/Z2 SD, Mana, Healing.")