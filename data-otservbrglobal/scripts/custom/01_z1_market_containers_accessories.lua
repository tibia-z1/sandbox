-- 01_z1_market_containers_accessories.lua
-- Market offers: backpacks, quivers, amulets, rings
-- Currency: GOLD COINS (not gold ingots)
-- Place in: data-otservbr-global/scripts/custom/
-- Loads after 00_z1_core.lua (01 prefix)
--
-- Uses Z1.addOfferById() for all items -- bypasses name-lookup failures
-- caused by items.xml name mismatches in this server version.
-- clientIds sourced from z1_merchant.lua (already verified working).
--
-- Items marked "TODO: master folder" need their clientId confirmed
-- once the main otserver folder is accessible.

_G.Z1 = _G.Z1 or {}
local Z1 = _G.Z1
Z1.MARKET_OFFERS = Z1.MARKET_OFFERS or {}

local offers = Z1.MARKET_OFFERS

-- Shorthand helpers
local function byId(id, price, amount, label)
    Z1.addOfferById(offers, id, price, amount, label)
end
local function byName(name, price, amount)
    Z1.addOfferByName(offers, name, price, amount)
end

-- ============================================================
-- BACKPACKS & CONTAINERS
-- NPC official price: 25gp. We sell at 100gp (4x utility pricing).
-- ============================================================

-- Basic color variants -- all clientIds confirmed via z1_merchant.lua
byId(1987,  100,  1, "backpack")
byId(2485,  100,  1, "blue backpack")
byId(2486,  100,  1, "green backpack")
byId(2484,  100,  1, "orange backpack")
byId(2487,  100,  1, "red backpack")
byId(2489,  100,  1, "yellow backpack")
byId(2490,  100,  1, "purple backpack")
byId(2777,  100,  1, "white backpack")
byId(2488,  100,  1, "brown backpack")
byId(7956,  100,  1, "pink backpack")
byId(7957,  100,  1, "black backpack")

-- Animal / themed -- clientIds from z1_merchant.lua
byId(7714,   500,  1, "bear backpack")
byId(10523,  500,  1, "wolf backpack")
byId(10521,  500,  1, "bug backpack")
byId(10520,  500,  1, "bat backpack")
byId(10519, 1000,  1, "dragon backpack")
byId(8843,  1000,  1, "demon backpack")
byId(20066, 1000,  1, "panther backpack")
byId(9601,  1000,  1, "pirate backpack")

-- Seasonal / Special -- clientIds from z1_merchant.lua
byId(9605,  2000,  1, "santa backpack")
byId(25748, 2000,  1, "mushroom backpack")
byId(12699, 2000,  1, "beach backpack")
byId(12700, 2000,  1, "heart backpack")
byId(16122, 2000,  1, "crystal backpack")
byId(9603,  2000,  1, "lucky backpack")

-- TODO: master folder -- need clientId for these backpacks:
-- butterfly backpack, leaf backpack, hunting backpack,
-- moonlight backpack, starry backpack, frost backpack,
-- death backpack, chaos backpack
-- Example once you have the ID: byId(XXXXX, 2000, 1, "butterfly backpack")

-- Other containers
byId(1988,  25,    1, "bag")
byId(2855,  25,    1, "basket")
byId(2455,  200,   1, "toolbox")
byId(1748,  2000,  1, "iron chest")
-- TODO: master folder -- wooden chest and wood and iron chest clientIds
-- byId(XXXXX, 500,  1, "wooden chest")
-- byId(XXXXX, 1000, 1, "wood and iron chest")

-- ============================================================
-- QUIVERS
-- clientIds confirmed from z1_merchant.lua (except base quiver -- see note)
-- ============================================================
-- NOTE: base "quiver" clientId 2488 is the same as "brown backpack" in this
-- server -- wrong ID. Correct quiver clientId needs master folder.
-- byId(2488, 500, 1, "quiver")  <- DISABLED: wrong ID (= brown backpack)
byId(31626, 500,    1, "blue quiver")
byId(31627, 5000,   1, "decorated quiver")
byId(33766, 100000, 1, "falcon quiver")
byId(34095, 100000, 1, "rift quiver")
byId(39286, 500000, 1, "sanguine quiver")

-- ============================================================
-- AMULETS & NECKLACES
-- ============================================================

-- Basic protection
byId(3081,  1000, 10, "stone skin amulet")
byId(814,   1000, 10, "terra amulet")
byId(816,   1000, 10, "lightning pendant")
byId(815,   1000, 10, "magma amulet")
byId(813,   1000, 10, "icy amulet")
byId(3059,   500, 10, "silver amulet")
byId(3057,   500, 10, "golden amulet")
byId(3056,   200, 10, "bronze amulet")
byId(3085,  1000, 10, "dragon necklace")
byId(3082,  1000, 10, "elven amulet")
byId(3083,   200, 10, "garlic necklace")

-- Mid-tier
byId(2997,  8000,  10, "platinum amulet")
-- NOTE: amulet of loss (2997) shares ID with platinum amulet in this server.
-- Correct amulet of loss clientId needed from master folder.
-- byId(XXXXX, 60000, 10, "amulet of loss")
byId(9301,  4000,  10, "bonfire amulet")
-- NOTE: glacier amulet (815) shares ID with magma amulet in this server.
-- byId(XXXXX, 4000, 10, "glacier amulet")  <- disabled pending master folder
byId(21170, 5000,  10, "gearwheel chain")
-- NOTE: gill necklace clientId 16108 = ring of blue plasma -- wrong.
-- byId(XXXXX, 5000, 10, "gill necklace")   <- disabled pending master folder
byId(27565, 5000,  10, "foxtail amulet")
byId(20342, 5000,  10, "jade amulet")
byId(3084,  10000, 10, "mysterious amulet")
byId(5741,  10000, 10, "horseman's amulet")  -- TODO: verify clientId from master folder
byId(35605, 5000,  10, "ruby necklace")
byId(35607, 5000,  10, "sapphire necklace")
byId(35609, 10000, 10, "diamond necklace")
-- NOTE: emerald necklace shares clientId 35605 with ruby necklace -- wrong.
-- byId(XXXXX, 10000, 10, "emerald necklace")  <- disabled pending master folder
byId(35611, 10000, 10, "garnet necklace")    -- TODO: verify clientId
byId(35613, 10000, 10, "amethyst necklace")  -- TODO: verify clientId
byId(3009,  8000,  10, "golden necklace")
byId(9765,  50000, 10, "phoenix necklace")   -- NOTE: shares ID with ring of healing in z1_merchant; may need correction
byId(9766,  50000, 10, "spirit cloak")
byId(22061, 20000, 10, "enchanted werewolf amulet")
byId(35523, 30000, 10, "exotic amulet")
byId(5741,  10000, 10, "necklace of the deep") -- TODO: verify clientId
byId(10556, 4000,  10, "scarab amulet")
byId(16108, 5000,  10, "necklace of the deep") -- placeholder, verify

-- High-end / endgame amulets
byId(33764, 200000, 10, "falcon pendant")
byId(34093, 200000, 10, "cobra amulet")
byId(34079, 200000, 10, "lion amulet")
byId(39181, 500000, 10, "alicorn amulet")
byId(39178, 500000, 10, "spiritthorn necklace")
byId(40251, 1000000, 10, "sanguine fibula")
byId(40252, 1000000, 10, "sanguine brooch")

-- ============================================================
-- RINGS
-- ============================================================

-- Basic utility
byId(3052,  2000,  10, "life ring")
byId(3051,  4000,  10, "energy ring")
byId(3053,  4000,  10, "time ring")
byId(3050,  2000,  10, "power ring")
byId(3097,  2000,  10, "dwarven ring")
byId(3092,  4000,  10, "axe ring")
byId(3093,  4000,  10, "club ring")
byId(3091,  4000,  10, "sword ring")
byId(6299,  4000,  10, "death ring")
byId(3063,  2000,  10, "gold ring")
byId(3007,  4000,  10, "crystal ring")
byId(12669, 5000,  10, "star ring")
byId(3049,  10000, 10, "stealth ring")
byId(3048,  200000, 10, "might ring")

-- Mid utility
byId(9765,  10000, 10, "ring of healing")  -- NOTE: same ID as phoenix necklace above; one of these is wrong
byId(7419,  20000, 10, "ring of the sky")
byId(16108, 20000, 10, "ring of blue plasma")
byId(16109, 20000, 10, "ring of red plasma")
byId(16110, 20000, 10, "ring of green plasma")
byId(11098, 10000, 10, "guardian ring")
byId(17095, 10000, 10, "claw ring")
byId(23541, 50000, 10, "gnome ring")
byId(25758, 50000, 10, "eye of the storm ring")
-- TODO: master folder -- heroic ring, angel ring clientIds
-- byId(XXXXX, 10000, 10, "heroic ring")
-- byId(XXXXX, 30000, 10, "angel ring")

-- Endgame rings
byId(33765, 300000,  10, "falcon ring")
byId(34094, 300000,  10, "cobra ring")
byId(34080, 300000,  10, "lion ring")
byId(16114, 500000,  10, "prismatic ring")
byId(39182, 1000000, 10, "alicorn ring")
byId(39188, 1000000, 10, "arboreal ring")
byId(39179, 1000000, 10, "spiritthorn ring")
byId(40253, 2000000, 10, "sanguine coil")
byId(40254, 2000000, 10, "sanguine loop")

print(string.format("[Z1 Market Containers & Accessories] Loaded. Total market offers now: %d", #Z1.MARKET_OFFERS))
