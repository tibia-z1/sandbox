-- data/scripts/custom/z1_prestige_bypass.lua
-- Prestige Weapon Bypass
-- If a player has prestige rank >= 1 (storage 590001 > 0), they can equip
-- any Z weapon (Z1/Z2/Z3) regardless of their current level.
--
-- HOW IT WORKS:
--   items.xml sets minimumLevel on Z weapons (1000/5000/10000).
--   The engine enforces that check. To bypass it in Lua, we register a
--   MoveEvent:equip for every Z weapon ID. When the event fires we verify
--   prestige rank > 0 and return true (allow). The engine's own level check
--   still fires but our event wins when registered correctly via Lua.
--
-- IMPORTANT -- items.xml setup:
--   For this bypass to work, the Z weapon entries in items.xml must NOT
--   have a <attribute key="minimumLevel"> tag. Move the level gate entirely
--   into this Lua file so there is only one enforcement point.
--   If items.xml keeps minimumLevel, the engine blocks equip before Lua fires.
--
-- MUST LOAD AFTER z1_prestige.lua (filename 06_ prefix recommended).

print("[Z1 Prestige Bypass] Loading Z weapon prestige bypass...")

-- =========================================================
-- PRESTIGE STORAGE KEY
-- Shared with z1_prestige.lua via _G.
-- =========================================================

local PRESTIGE_RANK_STORAGE = _G.Z1_PRESTIGE_RANK_STORAGE or 590001

-- =========================================================
-- Z WEAPON REGISTRY
-- All Z1, Z2, Z3 weapon IDs with their tier and minimum level.
-- These must match items.xml IDs exactly.
-- =========================================================

local Z_WEAPONS = {
    -- Z1  (minimum level 10,000 without prestige)
    [26016] = { tier = 1, minLevel = 1000 },
    [26019] = { tier = 1, minLevel = 1000 },
    [26022] = { tier = 1, minLevel = 1000 },
    [26025] = { tier = 1, minLevel = 1000 },
    [26028] = { tier = 1, minLevel = 1000 },
    [26031] = { tier = 1, minLevel = 1000 },
    [26034] = { tier = 1, minLevel = 1000 },
    [26037] = { tier = 1, minLevel = 1000 },
    [26040] = { tier = 1, minLevel = 1000 },
    [26043] = { tier = 1, minLevel = 1000 },

    -- Z2  (minimum level 5,000 without prestige)
    [25984] = { tier = 2, minLevel = 1000 },
    [25987] = { tier = 2, minLevel = 1000 },
    [25990] = { tier = 2, minLevel = 1000 },
    [25993] = { tier = 2, minLevel = 1000 },
    [25996] = { tier = 2, minLevel = 1000 },
    [25999] = { tier = 2, minLevel = 1000 },
    [26002] = { tier = 2, minLevel = 1000 },
    [26005] = { tier = 2, minLevel = 1000 },
    [26008] = { tier = 2, minLevel = 1000 },
    [26011] = { tier = 2, minLevel = 1000 },

    -- Z3  (minimum level 1,000 without prestige)
    [26044] = { tier = 3, minLevel = 1000 },
    [26047] = { tier = 3, minLevel = 1000 },
    [26050] = { tier = 3, minLevel = 1000 },
    [26053] = { tier = 3, minLevel = 1000 },
    [26056] = { tier = 3, minLevel = 1000 },
    [26059] = { tier = 3, minLevel = 1000 },
    [26062] = { tier = 3, minLevel = 1000 },
    [26065] = { tier = 3, minLevel = 1000 },
    [26068] = { tier = 3, minLevel = 1000 },
    [26071] = { tier = 3, minLevel = 1000 },
}

local TIER_NAME = { [1] = "Z1", [2] = "Z2", [3] = "Z3" }

-- =========================================================
-- EQUIP CHECK
-- =========================================================

local equipEvent  = MoveEvent()
local dequipEvent = MoveEvent()

equipEvent:type("equip")
dequipEvent:type("deequip")

equipEvent:onEquip(function(player, item, slot)
    local info = Z_WEAPONS[item:getId()]
    if not info then return true end

    local level = player:getLevel()
    local rank  = math.max(0, player:getStorageValue(PRESTIGE_RANK_STORAGE))

    -- Allow if level meets requirement normally
    if level >= info.minLevel then
        return true
    end

    -- Allow if player has any prestige rank (earned the right to wear all Z gear)
    if rank >= 1 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
            string.format("[%s Weapon] Equipped via Prestige Rank %d. True damage active.",
                TIER_NAME[info.tier], rank))
        return true
    end

    -- Block and explain
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        string.format("[%s Weapon] Requires level %d or Prestige Rank 1+. Your level: %d.",
            TIER_NAME[info.tier], info.minLevel, level))
    return false
end)

dequipEvent:onDeEquip(function(player, item, slot)
    -- Nothing special on dequip -- return true always
    return true
end)

-- Register for every Z weapon ID
for itemId in pairs(Z_WEAPONS) do
    equipEvent:id(itemId)
    dequipEvent:id(itemId)
end

equipEvent:register()
dequipEvent:register()

print(string.format("[Z1 Prestige Bypass] Registered %d Z weapons. Prestige rank 1+ bypasses level gate.", (function()
    local n = 0
    for _ in pairs(Z_WEAPONS) do n = n + 1 end
    return n
end)()))
