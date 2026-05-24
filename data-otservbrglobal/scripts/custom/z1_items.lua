--[[
    Z1 Custom Items
    File: data/scripts/custom/z1_items.lua

    FIX: Weapons no longer registered in MoveEvent here.
    items.xml already registers moveevent for weapons (level/voc check).
    We only register MoveEvent for ARMOR items (no XML moveevent conflict).

    Weapon speed bonus is now handled by Z1WeaponAoe CreatureEvent think
    (z1_weapon_aoe.lua) -- simpler and no conflicts.

    ADD TO login.lua:
        player:registerEvent("Z1SoulRegen")
        player:registerEvent("Z1WeaponAoe")
--]]

local TIERS = {
    [1] = { name = "Z1", armorSpeed = 100, minLevel = 10000 },
    [2] = { name = "Z2", armorSpeed = 40,  minLevel = 5000  },
    [3] = { name = "Z3", armorSpeed = 15,  minLevel = 1000  },
}

local function scaleByLevel(player, base)
    local lvl = player:getLevel()
    return math.floor(base * (1 + lvl / 5000) ^ 0.6)
end

local function notify(player, msg)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, msg)
end

-- ARMOR ONLY -- weapons excluded to avoid duplicate MoveEvent warnings.
-- items.xml handles weapon equip restrictions (level/voc) via moveevent;weapon.
local ARMOR_ITEMS = {
    [13993] = { tier = 2, type = "chest",   storage = 91001 }, -- Z2 chestplate
    [13999] = { tier = 2, type = "legs",    storage = 91002 }, -- Z2 legs
    [14000] = { tier = 2, type = "shield",  storage = 91003 }, -- Z2 shield
    [23476] = { tier = 1, type = "boots",   storage = 91004 }, -- Z1 boots
    [26189] = { tier = 3, type = "helmet",  storage = 91005 }, -- Z3 crown
    [26190] = { tier = 1, type = "helmet",  storage = 91005 }, -- Z1 crown
    [22195] = { tier = 2, type = "amulet",  storage = 91006 }, -- onyx pendant
}

local effects = {}

effects["chest"] = {
    onEquip = function(player, info)
        local t   = TIERS[info.tier]
        local spd = scaleByLevel(player, t.armorSpeed)
        player:changeSpeed(spd)
        player:setStorageValue(info.storage, spd)
        notify(player, string.format("[%s Chestplate] Speed +%d (level-scaled).", t.name, spd))
    end,
    onDequip = function(player, info)
        local spd = math.max(0, player:getStorageValue(info.storage))
        if spd > 0 then player:changeSpeed(-spd) end
        player:setStorageValue(info.storage, 0)
    end,
}

effects["legs"] = {
    onEquip = function(player, info)
        local t   = TIERS[info.tier]
        local spd = scaleByLevel(player, math.floor(t.armorSpeed * 0.6))
        player:changeSpeed(spd)
        player:setStorageValue(info.storage, spd)
        notify(player, string.format("[%s Legs] Speed +%d (level-scaled).", t.name, spd))
    end,
    onDequip = function(player, info)
        local spd = math.max(0, player:getStorageValue(info.storage))
        if spd > 0 then player:changeSpeed(-spd) end
        player:setStorageValue(info.storage, 0)
    end,
}

effects["shield"] = {
    onEquip = function(player, info)
        local t   = TIERS[info.tier]
        local spd = scaleByLevel(player, math.floor(t.armorSpeed * 0.4))
        player:changeSpeed(spd)
        player:setStorageValue(info.storage, spd)
        notify(player, string.format("[%s Shield] Speed +%d | Shielding active.", t.name, spd))
    end,
    onDequip = function(player, info)
        local spd = math.max(0, player:getStorageValue(info.storage))
        if spd > 0 then player:changeSpeed(-spd) end
        player:setStorageValue(info.storage, 0)
    end,
}

effects["boots"] = {
    onEquip = function(player, info)
        local t   = TIERS[info.tier]
        local spd = scaleByLevel(player, t.armorSpeed)
        player:changeSpeed(spd)
        player:setStorageValue(info.storage, spd)
        notify(player, string.format("[%s Boots] Speed +%d (level bonus on top of XML).", t.name, spd))
    end,
    onDequip = function(player, info)
        local spd = math.max(0, player:getStorageValue(info.storage))
        if spd > 0 then player:changeSpeed(-spd) end
        player:setStorageValue(info.storage, 0)
    end,
}

effects["helmet"] = {
    onEquip = function(player, info)
        local t   = TIERS[info.tier]
        local spd = scaleByLevel(player, math.floor(t.armorSpeed * 0.5))
        player:changeSpeed(spd)
        player:setStorageValue(info.storage, spd)
        notify(player, string.format("[%s Crown] Speed +%d active.", t.name, spd))
    end,
    onDequip = function(player, info)
        local spd = math.max(0, player:getStorageValue(info.storage))
        if spd > 0 then player:changeSpeed(-spd) end
        player:setStorageValue(info.storage, 0)
    end,
}

effects["amulet"] = {
    onEquip = function(player, info)
        player:setStorageValue(info.storage, info.tier)
        notify(player, string.format("[%s Pendant] Soul Regen active.", TIERS[info.tier].name))
    end,
    onDequip = function(player, info)
        player:setStorageValue(info.storage, 0)
    end,
}

local function handleMove(player, item, isEquip)
    local info = ARMOR_ITEMS[item:getId()]
    if not info then return true end
    local fx = effects[info.type]
    if not fx then return true end
    if isEquip then fx.onEquip(player, info) else fx.onDequip(player, info) end
    return true
end

local equipEvent  = MoveEvent()
local dequipEvent = MoveEvent()
equipEvent:type("equip")
dequipEvent:type("deequip")
equipEvent:onEquip(function(player, item, slot) return handleMove(player, item, true) end)
dequipEvent:onDeEquip(function(player, item, slot) return handleMove(player, item, false) end)

for itemId in pairs(ARMOR_ITEMS) do
    equipEvent:id(itemId)
    dequipEvent:id(itemId)
end

equipEvent:register()
dequipEvent:register()

------------------------------------------------------------------------
-- SOUL REGEN
-- Requires: player:registerEvent("Z1SoulRegen") in login.lua
------------------------------------------------------------------------
local soulRegen = CreatureEvent("Z1SoulRegen")
soulRegen:type("think")
soulRegen:onThink(function(creature, interval)
    if not creature:isPlayer() then return true end
    local tier = creature:getStorageValue(91006)
    if tier <= 0 then return true end
    local tmul = ({ [1]=8.0, [2]=3.0, [3]=1.0 })[tier] or 1.0
    local tick  = math.floor((10 + creature:getMagicLevel() * 0.5 + creature:getLevel() * 0.05) * tmul)
    local hp    = creature:getHealth()
    local maxHp = creature:getMaxHealth()
    local mp    = creature:getMana()
    local maxMp = creature:getMaxMana()
    if hp < maxHp then creature:addHealth(math.min(tick,   maxHp - hp)) end
    if mp < maxMp then creature:addMana(math.min(tick * 2, maxMp - mp)) end
    return true
end)
soulRegen:register()

print("[Z1 Items] Custom armor & weapon scripts loaded.")
