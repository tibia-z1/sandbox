-- data/scripts/custom/00_z1_rift_config.lua
-- Z1 central Rift/Prestige config v9. Load before other z1_* scripts.

print("[Z1 Config] Loading v10 central config...")

local function resolveItemId(name, fallback)
    local ok, itemType = pcall(ItemType, name)
    if ok and itemType then
        local id = itemType:getId()
        if id and id > 0 then return id end
    end
    return fallback
end

_G.Z1Rift = _G.Z1Rift or {}

Z1Rift.items = Z1Rift.items or {}
Z1Rift.items.goldIngot = resolveItemId("gold ingot", 9058)
Z1Rift.items.fieryTear = resolveItemId("fiery tear", 39040)
Z1Rift.items.z1Arrow = resolveItemId("z1 arrow", 763)
Z1Rift.items.z2Arrow = resolveItemId("z2 arrow", 761)
Z1Rift.items.z3Arrow = resolveItemId("z3 arrow", 762)

Z1Rift.storages = Z1Rift.storages or {}
Z1Rift.storages.prestigeRank = 590001
Z1Rift.storages.lastPrestige = 590003
Z1Rift.storages.morshabaalKills = 591001
Z1Rift.storages.claimedZ3Starter = 592001
Z1Rift.storages.claimedArmorZ3 = 593001
Z1Rift.storages.claimedArmorZ2 = 593002
Z1Rift.storages.claimedArmorZ1 = 593003

Z1Rift.debug = {
    -- Set true only while testing. False = one starter claim per character.
    allowMultipleZ3StarterClaims = false,
    -- Set true only while testing. False = one armor claim per character.
    allowMultipleArmorClaims = false,
}

Z1Rift.prestige = {
    requiredLevel = 10000,
    resetLevel = 1000,
    maxRank = 10,
    xpBonusPercentPerRank = 10,
    speedBonusPerRank = 10,
    rewardItemName = "fiery tear",
    rewardItemId = Z1Rift.items.fieryTear,
    rewardCountPerPrestige = 1,
}

-- Room 2 boundaries: 32267,32197,8 to 32275,32205,8.
-- Layout mirrors Room 1 logic: display item -> sign -> portal.
Z1Rift.room2 = {
    from = Position(32267, 32197, 8),
    to   = Position(32275, 32205, 8),

    -- Top row: Z weapon progression.
    z3Display = Position(32269, 32197, 8),
    z3Sign    = Position(32269, 32198, 8),
    portalZ3  = Position(32269, 32199, 8),

    z2Display = Position(32271, 32197, 8),
    z2Sign    = Position(32271, 32198, 8),
    portalZ2  = Position(32271, 32199, 8),

    z1Display = Position(32273, 32197, 8),
    z1Sign    = Position(32273, 32198, 8),
    portalZ1  = Position(32273, 32199, 8),

    forge     = Position(32271, 32201, 8),
    forgeSign = Position(32270, 32201, 8),

    -- Bottom row: Z Armor sets (portal faces center forge, display faces outer wall).
    armorZ3Portal  = Position(32269, 32203, 8),
    armorZ3Sign    = Position(32269, 32204, 8),
    armorZ3Display = Position(32269, 32205, 8),

    armorZ2Portal  = Position(32271, 32203, 8),
    armorZ2Sign    = Position(32271, 32204, 8),
    armorZ2Display = Position(32271, 32205, 8),

    armorZ1Portal  = Position(32273, 32203, 8),
    armorZ1Sign    = Position(32273, 32204, 8),
    armorZ1Display = Position(32273, 32205, 8),
}

Z1Rift.aids = {
    forge   = 11465,
    gateZ3  = 11466,
    gateZ2  = 11467,
    gateZ1  = 11468,
    armorZ3 = 11480,
    armorZ2 = 11481,
    armorZ1 = 11482,
    info    = 11554,
}

Z1Rift.forge = {
    morshabaalKillsRequired = 5,
    claimZ3CostIngots = 25,
    upgradeZ3ToZ2CostIngots = 75,
    upgradeZ3ToZ2CostRiftmarks = 1,
    upgradeZ2ToZ1CostIngots = 150,
    upgradeZ2ToZ1CostRiftmarks = 3,
    defaultStarterZ3Weapon = 26044,
}

Z1Rift.zWeapons = {
    z3 = {26044,26047,26050,26053,26056,26059,26062,26065,26068,26071},
    z2 = {25984,25987,25990,25993,25996,25999,26002,26005,26008,26011},
    z1 = {26016,26019,26022,26025,26028,26031,26034,26037,26040,26043},
}

Z1Rift.weaponTier = {}
Z1Rift.weaponIndex = {}
for i, id in ipairs(Z1Rift.zWeapons.z3) do Z1Rift.weaponTier[id] = 3; Z1Rift.weaponIndex[id] = i end
for i, id in ipairs(Z1Rift.zWeapons.z2) do Z1Rift.weaponTier[id] = 2; Z1Rift.weaponIndex[id] = i end
for i, id in ipairs(Z1Rift.zWeapons.z1) do Z1Rift.weaponTier[id] = 1; Z1Rift.weaponIndex[id] = i end

-- Vocation -> Z weapon slot index (mirrors z1_weapon_upgrade.lua VOC_Z3_INDEX).
-- Used by z1_room2.lua for the weapon display items (shows the player's voc weapon on entry).
-- Index: 1=Blade  2=Slayer  3=Axe  4=Chopper  5=Mace  6=Hammer
--        7=Bow    8=Crossbow  9=Wand  10=Rod
--
-- Vocation IDs (this server):
--   1=Sorcerer  2=Druid  3=Paladin  4=Knight
--   5=Master Sorcerer  6=Elder Druid  7=Royal Paladin  8=Elite Knight
-- 1=Sorc  2=Druid  3=Paladin  4=Knight  5=MSorc  6=EDruid  7=RPal  8=EKnight
Z1Rift.vocWeaponIndex = {
    [0] = 1,              -- no vocation      -> Blade
    [1] = 9,  [5] = 9,   -- Sorc / MSorc     -> Wand
    [2] = 10, [6] = 10,  -- Druid / EDruid   -> Rod
    [3] = 7,  [7] = 7,   -- Paladin / RPal   -> Bow  (display; modal chooses bow or crossbow)
    [4] = 1,  [8] = 1,   -- Knight / EKnight -> Blade (display; modal picks final type)
}

-- Armor set definitions.
-- !  ITEM IDs marked TODO must be filled in once the master-folder items.xml is accessible.
--    Everything else is already registered in z1_items.lua and works today.
Z1Rift.armorSets = {
    z3 = {
        label      = "Z3 Armor",
        tier       = 3,
        level      = 1000,
        costIngots = 30,
        storage    = 593001,
        displayId  = 26189,   -- Z3 Crown (helmet)
        items = {
            { id = 26189, count = 1 },  -- Z3 Crown
            -- TODO: add Z3 chestplate ID once master folder is connected
            -- TODO: add Z3 legs ID
            -- TODO: add Z3 boots ID
            -- TODO: add Z3 shield ID
        },
    },
    z2 = {
        label      = "Z2 Armor",
        tier       = 2,
        level      = 5000,
        costIngots = 80,
        storage    = 593002,
        displayId  = 13993,   -- Z2 Chestplate
        items = {
            { id = 26189, count = 1 },  -- Z3 Crown (helmet slot; replace with Z2 helmet TODO)
            { id = 13993, count = 1 },  -- Z2 Chestplate
            { id = 13999, count = 1 },  -- Z2 Legs
            { id = 14000, count = 1 },  -- Z2 Shield
            { id = 22195, count = 1 },  -- Onyx Pendant (Z2 amulet)
            -- TODO: add Z2 boots ID
        },
    },
    z1 = {
        label      = "Z1 Armor",
        tier       = 1,
        level      = 10000,
        costIngots = 200,
        storage    = 593003,
        displayId  = 26190,   -- Z1 Crown (helmet)
        items = {
            { id = 26190, count = 1 },  -- Z1 Crown
            { id = 23476, count = 1 },  -- Z1 Boots
            { id = 13993, count = 1 },  -- Z2 Chestplate (replace with Z1 chest TODO)
            { id = 13999, count = 1 },  -- Z2 Legs     (replace with Z1 legs TODO)
            { id = 14000, count = 1 },  -- Z2 Shield   (replace with Z1 shield TODO)
            { id = 22195, count = 1 },  -- Onyx Pendant
        },
    },
}

print(string.format("[Z1 Config] v10 loaded. gold ingot=%d, fiery tear=%d, Z3 repeat=%s.",
    Z1Rift.items.goldIngot, Z1Rift.items.fieryTear, tostring(Z1Rift.debug.allowMultipleZ3StarterClaims)))
