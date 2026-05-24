-- 00_z1_core.lua
-- Zero1 progression + full market config.
-- Put in: data/scripts/custom/
-- Keep filename with 00 so it loads before the other Z1 files.

_G.Z1 = _G.Z1 or {}
local Z1 = _G.Z1

-- Positions
Z1.HUB_POS = Position(32256, 32193, 8)
Z1.TRAINING_POS = Position(32256, 32193, 8)
Z1.SET_ROOM_RETURN_POS = Position(32253, 32167, 8)

-- Currency: your visible item says "gold ingot" and Client ID 9058.
Z1.SET_CURRENCY_NAME = "gold ingot"
Z1.SET_CURRENCY_ID = ItemType(Z1.SET_CURRENCY_NAME):getId()
if not Z1.SET_CURRENCY_ID or Z1.SET_CURRENCY_ID == 0 then
    Z1.SET_CURRENCY_ID = 9058
    print("[Z1 Core] WARNING: gold ingot name lookup failed. Falling back to id 9058.")
end
print("[Z1 Core] Gold ingot server id detected as: " .. Z1.SET_CURRENCY_ID)

-- Market seller
Z1.MARKET_SELLER_PLAYER_ID = 15 -- zero market
Z1.MARKET_SELLER_NAME = "zero market"
Z1.MARKET_AUTO_SEED = true
Z1.MARKET_CLEAR_SELLER_OFFERS_FIRST = true
Z1.MARKET_DELETE_OLD_Z1_OFFERS = true
Z1.MARKET_ANONYMOUS = 0

-- Storages
Z1.STORAGE_SET_BASE = 510000

-- Set showcase room: Position(32236,32197,8) to Position(32244,32205,8)
Z1.SET_ROOM_TOP_LEFT = Position(32236, 32197, 8)
Z1.SET_ROOM_BOTTOM_RIGHT = Position(32244, 32205, 8)
Z1.SET_TRIAL_PORTAL_ITEMID = 25051 -- energy portal visual; 1387 looked like stairs/walls in this client
Z1.RETURN_PORTAL_ITEMID = 25051
Z1.SET_SIGN_ITEMID = 2017 -- readable sign visual in this client
Z1.SET_DISPLAY_AID_BASE = 8920
Z1.SET_SIGN_AID_BASE = 8940
Z1.SET_RETURN_AID = 8999
Z1.SET_ROOM_MODE = "reward"
Z1.CREATE_SET_RETURN_PORTALS = true
Z1.ALLOW_SET_RECLAIM_TESTING = true -- keep true while testing; set false for launch

-- Helpers
function Z1.getItemIdByName(name)
    if not name or name == "" then
        return 0
    end
    local id = ItemType(name):getId()
    if id and id > 0 then
        return id
    end
    return 0
end

function Z1.addOfferByName(list, name, price, amount)
    local id = Z1.getItemIdByName(name)
    if id > 0 then
        table.insert(list, { itemId = id, amount = amount or 25, price = price, label = name })
    else
        print("[Z1 Market Core] Skipping missing market item by name: " .. name)
    end
end

-- ID-based alternative -- bypasses name lookup for items whose XML name differs.
-- Use this when ItemType(name):getId() fails but you know the server's clientId.
-- label is optional (shown in market listings); defaults to "item_<id>".
function Z1.addOfferById(list, id, price, amount, label)
    if not id or id <= 0 then
        print("[Z1 Market Core] Skipping offer -- invalid id: " .. tostring(id))
        return
    end
    table.insert(list, { itemId = id, amount = amount or 1, price = price, label = label or ("item_" .. id) })
end

function Z1.makeReward(names, count)
    return { names = names, count = count or 1, name = names[1] }
end

-- Chosen set progression: complete sets, no repeated fake armor spam.
-- Each slot uses name fallbacks. The script gives the first existing item name in your datapack.
Z1.SET_TRIALS = {
    {
        key = "plate", name = "Plate Set", shortLabel = "Plate", level = 1,
        portalAid = 8801, storage = Z1.STORAGE_SET_BASE + 1,
        portalPos = Position(32236, 32199, 8), displayPos = Position(32236, 32197, 8), signPos = Position(32236, 32198, 8), trialPos = Position(32240, 32201, 8),
        currencyCost = 0,
        visualNames = {"plate helmet", "brass helmet", "steel helmet"},
        rewards = {
            Z1.makeReward({"plate helmet", "brass helmet", "steel helmet"}),
            Z1.makeReward({"plate armor"}),
            Z1.makeReward({"plate legs"}),
            Z1.makeReward({"leather boots"}),
            Z1.makeReward({"plate shield"}),
            Z1.makeReward({"spike sword", "serpent sword"}),
        }
    },
    {
        key = "crown", name = "Crown Set", shortLabel = "Crown", level = 80,
        portalAid = 8802, storage = Z1.STORAGE_SET_BASE + 2,
        portalPos = Position(32238, 32199, 8), displayPos = Position(32238, 32197, 8), signPos = Position(32238, 32198, 8), trialPos = Position(32240, 32201, 8),
        currencyCost = 1,
        visualNames = {"crown helmet"},
        rewards = {
            Z1.makeReward({"crown helmet"}),
            Z1.makeReward({"crown armor"}),
            Z1.makeReward({"crown legs"}),
            Z1.makeReward({"steel boots", "boots of haste"}),
            Z1.makeReward({"crown shield"}),
            Z1.makeReward({"giant sword", "bright sword"}),
        }
    },
    {
        key = "dragon", name = "Dragon Set", shortLabel = "Dragon", level = 150,
        portalAid = 8803, storage = Z1.STORAGE_SET_BASE + 3,
        portalPos = Position(32240, 32199, 8), displayPos = Position(32240, 32197, 8), signPos = Position(32240, 32198, 8), trialPos = Position(32240, 32201, 8),
        currencyCost = 3,
        visualNames = {"dragon scale helmet", "dragon scale mail"},
        rewards = {
            Z1.makeReward({"dragon scale helmet", "royal helmet"}),
            Z1.makeReward({"dragon scale mail"}),
            Z1.makeReward({"dragon scale legs", "golden legs"}),
            Z1.makeReward({"boots of haste", "steel boots"}),
            Z1.makeReward({"demon shield", "dragon shield"}),
            Z1.makeReward({"fire sword", "dragon lance"}),
        }
    },
    {
        key = "demon", name = "Demon Set", shortLabel = "Demon", level = 350,
        portalAid = 8804, storage = Z1.STORAGE_SET_BASE + 4,
        portalPos = Position(32242, 32199, 8), displayPos = Position(32242, 32197, 8), signPos = Position(32242, 32198, 8), trialPos = Position(32240, 32201, 8),
        currencyCost = 7,
        visualNames = {"demon helmet"},
        rewards = {
            Z1.makeReward({"demon helmet"}),
            Z1.makeReward({"demon armor", "magic plate armor"}),
            Z1.makeReward({"demon legs", "golden legs"}),
            Z1.makeReward({"boots of haste", "steel boots"}),
            Z1.makeReward({"demon shield"}),
            Z1.makeReward({"demonrage sword", "nightmare blade", "magic sword"}),
        }
    },
    {
        key = "golden", name = "Golden Set", shortLabel = "Golden", level = 700,
        portalAid = 8805, storage = Z1.STORAGE_SET_BASE + 5,
        portalPos = Position(32244, 32199, 8), displayPos = Position(32244, 32197, 8), signPos = Position(32244, 32198, 8), trialPos = Position(32240, 32201, 8),
        currencyCost = 15,
        visualNames = {"golden helmet"},
        rewards = {
            Z1.makeReward({"golden helmet", "royal helmet"}),
            Z1.makeReward({"magic plate armor", "golden armor"}),
            Z1.makeReward({"golden legs"}),
            Z1.makeReward({"boots of haste", "steel boots"}),
            Z1.makeReward({"mastermind shield", "great shield"}),
            Z1.makeReward({"magic sword", "giant sword"}),
        }
    },
    {
        key = "prismatic", name = "Prismatic Set", shortLabel = "Prismatic", level = 1200,
        portalAid = 8806, storage = Z1.STORAGE_SET_BASE + 6,
        portalPos = Position(32236, 32203, 8), displayPos = Position(32236, 32205, 8), signPos = Position(32236, 32204, 8), trialPos = Position(32240, 32201, 8),
        currencyCost = 25,
        visualNames = {"prismatic helmet", "prismatic armor"},
        rewards = {
            Z1.makeReward({"prismatic helmet", "zaoan helmet", "royal helmet"}),
            Z1.makeReward({"prismatic armor", "ornate chestplate", "magic plate armor"}),
            Z1.makeReward({"prismatic legs", "ornate legs", "golden legs"}),
            Z1.makeReward({"prismatic boots", "boots of haste"}),
            Z1.makeReward({"prismatic shield", "ornate shield", "mastermind shield"}),
            Z1.makeReward({"prismatic sword", "magic sword"}),
        }
    },
    {
        key = "cobra", name = "Cobra Set", shortLabel = "Cobra", level = 2500,
        portalAid = 8807, storage = Z1.STORAGE_SET_BASE + 7,
        portalPos = Position(32238, 32203, 8), displayPos = Position(32238, 32205, 8), signPos = Position(32238, 32204, 8), trialPos = Position(32240, 32201, 8),
        currencyCost = 45,
        visualNames = {"cobra hood", "cobra crown"},
        rewards = {
            Z1.makeReward({"cobra hood", "cobra crown", "falcon coif", "royal helmet"}),
            Z1.makeReward({"cobra robe", "cobra armor", "falcon plate", "magic plate armor"}),
            Z1.makeReward({"cobra legs", "falcon greaves", "golden legs"}),
            Z1.makeReward({"cobra boots", "boots of haste"}),
            Z1.makeReward({"cobra shield", "falcon shield", "great shield"}),
            Z1.makeReward({"cobra sword", "cobra axe", "cobra club", "magic sword"}),
        }
    },
    {
        key = "falcon", name = "Falcon Set", shortLabel = "Falcon", level = 4000,
        portalAid = 8808, storage = Z1.STORAGE_SET_BASE + 8,
        portalPos = Position(32240, 32203, 8), displayPos = Position(32240, 32205, 8), signPos = Position(32240, 32204, 8), trialPos = Position(32240, 32201, 8),
        currencyCost = 70,
        visualNames = {"falcon coif"},
        rewards = {
            Z1.makeReward({"falcon coif", "falcon circlet", "royal helmet"}),
            Z1.makeReward({"falcon plate", "falcon robe", "magic plate armor"}),
            Z1.makeReward({"falcon greaves", "golden legs"}),
            Z1.makeReward({"falcon boots", "boots of haste"}),
            Z1.makeReward({"falcon shield", "great shield"}),
            Z1.makeReward({"falcon longsword", "falcon battleaxe", "falcon mace", "magic sword"}),
        }
    },
    {
        key = "soul", name = "Soul Set", shortLabel = "Soul", level = 7000,
        portalAid = 8809, storage = Z1.STORAGE_SET_BASE + 9,
        portalPos = Position(32242, 32203, 8), displayPos = Position(32242, 32205, 8), signPos = Position(32242, 32204, 8), trialPos = Position(32240, 32201, 8),
        currencyCost = 110,
        visualNames = {"soulbastion", "soulmantle"},
        rewards = {
            Z1.makeReward({"soulbastion", "soulmantle", "soulshroud", "falcon coif", "royal helmet"}),
            Z1.makeReward({"soulshell", "soulmantle", "soulshroud", "falcon plate", "magic plate armor"}),
            Z1.makeReward({"soulstrider", "falcon greaves", "golden legs"}),
            Z1.makeReward({"soulwalkers", "falcon boots", "boots of haste"}),
            Z1.makeReward({"soulbastion", "falcon shield", "great shield"}),
            Z1.makeReward({"soulshredder", "soulcutter", "soulmaimer", "soulbleeder", "magic sword"}),
        }
    },
    {
        key = "endgame", name = "Sanguine Endgame Set", shortLabel = "Sanguine", level = 10000,
        portalAid = 8810, storage = Z1.STORAGE_SET_BASE + 10,
        portalPos = Position(32244, 32203, 8), displayPos = Position(32244, 32205, 8), signPos = Position(32244, 32204, 8), trialPos = Position(32240, 32201, 8),
        currencyCost = 160,
        visualNames = {"sanguine blade", "sanguine armor"},
        rewards = {
            Z1.makeReward({"sanguine hat", "sanguine helmet", "soulbastion", "falcon coif", "royal helmet"}),
            Z1.makeReward({"sanguine armor", "sanguine robe", "soulshell", "falcon plate", "magic plate armor"}),
            Z1.makeReward({"sanguine legs", "soulstrider", "falcon greaves", "golden legs"}),
            Z1.makeReward({"sanguine boots", "soulwalkers", "falcon boots", "boots of haste"}),
            Z1.makeReward({"sanguine shield", "soulbastion", "falcon shield", "great shield"}),
            Z1.makeReward({"sanguine blade", "sanguine battleaxe", "sanguine cudgel", "sanguine bow", "sanguine rod", "sanguine wand", "soulshredder", "magic sword"}),
        }
    },
}

-- Full market offers. Uses names, then resolves IDs on startup. Missing datapack items are skipped safely.
Z1.MARKET_OFFER_NAMES = {
    -- Basic complete-set pieces
    {"leather helmet", 150, 100}, {"leather armor", 250, 100}, {"leather legs", 200, 100}, {"leather boots", 100, 100}, {"wooden shield", 150, 100},
    {"studded helmet", 500, 100}, {"studded armor", 700, 100}, {"studded legs", 600, 100}, {"studded shield", 500, 100},
    {"chain helmet", 900, 100}, {"chain armor", 1200, 100}, {"chain legs", 1000, 100}, {"brass helmet", 1200, 100}, {"brass armor", 2000, 100}, {"brass legs", 1800, 100}, {"brass shield", 1500, 100},
    {"iron helmet", 2500, 100}, {"plate helmet", 3000, 100}, {"plate armor", 4000, 100}, {"plate legs", 3500, 100}, {"plate shield", 3000, 100},
    {"steel helmet", 8000, 75}, {"steel shield", 8000, 75}, {"steel boots", 30000, 75},
    {"dark helmet", 10000, 50}, {"dark armor", 12000, 50}, {"dark shield", 12000, 50},

    -- Classic set pieces
    {"crown helmet", 25000, 50}, {"crown armor", 45000, 50}, {"crown legs", 60000, 50}, {"crown shield", 30000, 50},
    {"dragon scale helmet", 150000, 30}, {"dragon scale mail", 250000, 30}, {"dragon scale legs", 350000, 30}, {"dragon shield", 50000, 50},
    {"demon helmet", 500000, 25}, {"demon armor", 700000, 25}, {"demon legs", 900000, 25}, {"demon shield", 300000, 25},
    {"golden helmet", 1500000, 20}, {"golden armor", 800000, 20}, {"golden legs", 1500000, 20}, {"magic plate armor", 2000000, 20}, {"mastermind shield", 900000, 20}, {"great shield", 2500000, 20},

    -- Elemental sets
    {"lightning headband", 90000, 30}, {"lightning robe", 120000, 30}, {"lightning legs", 120000, 30}, {"lightning boots", 80000, 30},
    {"magma monocle", 90000, 30}, {"magma coat", 120000, 30}, {"magma legs", 120000, 30}, {"magma boots", 80000, 30},
    {"glacier mask", 90000, 30}, {"glacier robe", 120000, 30}, {"glacier kilt", 120000, 30}, {"glacier shoes", 80000, 30},
    {"terra hood", 90000, 30}, {"terra mantle", 120000, 30}, {"terra legs", 120000, 30}, {"terra boots", 80000, 30},

    -- Strong and modern sets, skipped if not in datapack
    {"zaoan helmet", 250000, 25}, {"zaoan armor", 300000, 25}, {"zaoan legs", 350000, 25}, {"zaoan shoes", 180000, 25},
    {"yalahari mask", 300000, 25}, {"yalahari armor", 350000, 25}, {"yalahari leg piece", 350000, 25},
    {"depth galea", 750000, 20}, {"depth lorica", 900000, 20}, {"depth ocrea", 900000, 20}, {"depth calcei", 450000, 20},
    {"prismatic helmet", 800000, 20}, {"prismatic armor", 1200000, 20}, {"prismatic legs", 1500000, 20}, {"prismatic boots", 900000, 20}, {"prismatic shield", 1200000, 20},
    {"ornate chestplate", 2000000, 15}, {"ornate legs", 2200000, 15}, {"ornate shield", 1500000, 15},
    {"gnome helmet", 3000000, 15}, {"gnome armor", 3500000, 15}, {"gnome legs", 3500000, 15}, {"gnome shield", 2500000, 15},
    {"cobra hood", 6000000, 10}, {"cobra robe", 7000000, 10}, {"cobra boots", 5000000, 10}, {"cobra sword", 8000000, 10}, {"cobra axe", 8000000, 10}, {"cobra club", 8000000, 10}, {"cobra rod", 8000000, 10}, {"cobra wand", 8000000, 10},
    {"lion spangenhelm", 6000000, 10}, {"lion plate", 7000000, 10}, {"lion shield", 5000000, 10}, {"lion longsword", 8000000, 10}, {"lion axe", 8000000, 10}, {"lion hammer", 8000000, 10},
    {"falcon coif", 25000000, 8}, {"falcon circlet", 25000000, 8}, {"falcon plate", 35000000, 8}, {"falcon robe", 35000000, 8}, {"falcon greaves", 45000000, 8}, {"falcon shield", 30000000, 8}, {"falcon longsword", 40000000, 8}, {"falcon battleaxe", 40000000, 8}, {"falcon mace", 40000000, 8}, {"falcon bow", 40000000, 8}, {"falcon rod", 40000000, 8}, {"falcon wand", 40000000, 8},
    {"naga helmet", 20000000, 8}, {"naga armor", 25000000, 8}, {"naga legs", 25000000, 8}, {"naga boots", 18000000, 8}, {"naga sword", 30000000, 8}, {"naga axe", 30000000, 8}, {"naga club", 30000000, 8},
    {"eldritch hood", 35000000, 6}, {"eldritch cuirass", 45000000, 6}, {"eldritch breeches", 45000000, 6}, {"eldritch shield", 40000000, 6},
    {"soulbastion", 90000000, 5}, {"soulmantle", 90000000, 5}, {"soulshroud", 90000000, 5}, {"soulshell", 100000000, 5}, {"soulstrider", 120000000, 5}, {"soulwalkers", 100000000, 5}, {"soulshredder", 150000000, 5}, {"soulcutter", 150000000, 5}, {"soulmaimer", 150000000, 5}, {"soulbleeder", 150000000, 5}, {"soulhexer", 150000000, 5}, {"soultainter", 150000000, 5},
    {"spiritthorn helmet", 160000000, 4}, {"spiritthorn armor", 200000000, 4}, {"spiritthorn ring", 100000000, 4},
    {"arboreal crown", 120000000, 4}, {"arboreal tome", 100000000, 4}, {"arboreal ring", 80000000, 4},
    {"sanguine blade", 300000000, 3}, {"sanguine battleaxe", 300000000, 3}, {"sanguine cudgel", 300000000, 3}, {"sanguine bow", 300000000, 3}, {"sanguine rod", 300000000, 3}, {"sanguine wand", 300000000, 3}, {"sanguine armor", 250000000, 3}, {"sanguine legs", 250000000, 3}, {"sanguine boots", 200000000, 3}, {"sanguine shield", 200000000, 3},

    -- Useful weapons / classics
    {"serpent sword", 5000, 75}, {"spike sword", 8000, 75}, {"fire sword", 40000, 50}, {"ice rapier", 25000, 50}, {"bright sword", 50000, 50}, {"giant sword", 90000, 50}, {"magic sword", 3000000, 20}, {"stonecutter axe", 3000000, 20}, {"thunder hammer", 3000000, 20}, {"nightmare blade", 1500000, 20}, {"royal axe", 1500000, 20}, {"wand of voodoo", 300000, 30}, {"underworld rod", 300000, 30},

    -- Currency/testing
    {"crystal coin", 10000, 1000}, {"gold ingot", 1000000, 100},
}

-- Build MARKET_OFFERS once at startup. This keeps seed scripts compatible.
Z1.MARKET_OFFERS = {}
for _, entry in ipairs(Z1.MARKET_OFFER_NAMES) do
    Z1.addOfferByName(Z1.MARKET_OFFERS, entry[1], entry[2], entry[3])
end

print(string.format("[Z1] Core loaded: %d market items, %d set quests, seller player_id=%d", #Z1.MARKET_OFFERS, #Z1.SET_TRIALS, Z1.MARKET_SELLER_PLAYER_ID))
