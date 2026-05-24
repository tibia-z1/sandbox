-- z1_merchant.lua
-- Zero1 General Supply Merchant
-- Sells: backpacks, containers, quivers, rings, amulets/necklaces
-- Currency: gold coins
--
-- INSTALL:
--   1. Drop this file in data-otservbr-global/npc/
--   2. Place NPC in-world via RME or script (lookType 128 = shopkeeper male)
--   3. Verify clientIds match your items.otb if anything doesn't appear
--
-- HOW TO VERIFY A clientId:
--   In-game as GM: /i <itemname> -> check the ID shown
--   Or open data/items/items.otb with OTItemEditor and search by name.
--
-- SHOP FORMAT:
--   sell = price player pays to BUY from NPC
--   buy  = price NPC pays when player SELLS to it
--   (omit buy if NPC doesn't buy that item back)

local internalNpcName = "Z1 Merchant"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = "Z1 Merchant"

npcConfig.health = 500
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 0

npcConfig.outfit = {
    lookType = 128,   -- shopkeeper male; change to taste
    lookHead = 78,
    lookBody = 52,
    lookLegs = 95,
    lookFeet = 114,
    lookAddons = 0,
}

npcConfig.flags = {
    floorchange = false,
}

npcConfig.voices = {
    interval = 20000,
    chance = 40,
    { text = "Quality goods, fair prices!" },
    { text = "Looking for a backpack? I have them all." },
    { text = "Rings, amulets, containers -- you name it." },
    { text = "Ask me for a trade!" },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
    npcHandler:onThink(npc, interval)
end
npcType.onAppear = function(npc, creature)
    npcHandler:onAppear(npc, creature)
end
npcType.onDisappear = function(npc, creature)
    npcHandler:onDisappear(npc, creature)
end
npcType.onMove = function(npc, creature, fromPosition, toPosition)
    npcHandler:onMove(npc, creature, fromPosition, toPosition)
end
npcType.onSay = function(npc, creature, type, message)
    npcHandler:onSay(npc, creature, type, message)
end
npcType.onCloseChannel = function(npc, creature)
    npcHandler:onCloseChannel(npc, creature)
end

npcHandler:setMessage(MESSAGE_GREET, "Welcome, |PLAYERNAME|! I carry backpacks, containers, quivers, rings, and amulets. Say {trade} to browse.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Come back anytime!")
npcHandler:setMessage(MESSAGE_SENDTRADE, "Here is what I have in stock:")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- ============================================================
-- SHOP INVENTORY
-- sell = player buys from NPC (NPC sells)
-- buy  = player sells to NPC (NPC buys)
-- Prices in gold coins.
-- ============================================================
npcConfig.shop = {

    -- -- BACKPACKS (basic color variants) ---------------------
    -- NPC official price: 25gp. We sell at 100gp (utility pricing).
    -- buy back at 10gp -- players can offload them.
    { itemName = "backpack",            clientId = 1987,  buy =100,   sell=10 },
    { itemName = "blue backpack",       clientId = 2485,  buy =100,   sell=10 },
    { itemName = "green backpack",      clientId = 2486,  buy =100,   sell=10 },
    { itemName = "orange backpack",     clientId = 2484,  buy =100,   sell=10 },
    { itemName = "red backpack",        clientId = 2487,  buy =100,   sell=10 },
    { itemName = "yellow backpack",     clientId = 2489,  buy =100,   sell=10 },
    { itemName = "purple backpack",     clientId = 2490,  buy =100,   sell=10 },
    { itemName = "white backpack",      clientId = 2777,  buy =100,   sell=10 },
    { itemName = "brown backpack",      clientId = 2488,  buy =100,   sell=10 },
    { itemName = "pink backpack",       clientId = 7956,  buy =100,   sell=10 },
    { itemName = "black backpack",      clientId = 7957,  buy =100,   sell=10 },

    -- -- BACKPACKS (animal / themed) ---------------------------
    { itemName = "bear backpack",       clientId = 7714,  buy  = 500 },
    { itemName = "wolf backpack",       clientId = 10523, buy  = 500 },
    { itemName = "bug backpack",        clientId = 10521, buy  = 500 },
    { itemName = "bat backpack",        clientId = 10520, buy  = 500 },
    { itemName = "dragon backpack",     clientId = 10519, buy  = 1000 },
    { itemName = "demon backpack",      clientId = 8843,  buy  = 1000 },
    { itemName = "panther backpack",    clientId = 20066, buy  = 1000 },
    { itemName = "pirate backpack",     clientId = 9601,  buy  = 1000 },

    -- -- BACKPACKS (seasonal / special) -----------------------
    { itemName = "santa backpack",      clientId = 9605,  buy  = 2000 },
    { itemName = "mushroom backpack",   clientId = 25748, buy  = 2000 },
    { itemName = "beach backpack",      clientId = 12699, buy  = 2000 },
    { itemName = "heart backpack",      clientId = 12700, buy  = 2000 },
    { itemName = "crystal backpack",    clientId = 16122, buy  = 2000 },
    { itemName = "lucky backpack",      clientId = 9603,  buy  = 2000 },

    -- -- OTHER CONTAINERS --------------------------------------
    { itemName = "bag",                 clientId = 1988,  buy =25,    sell=5  },
    { itemName = "basket",              clientId = 2855,  buy =25,    sell=5  },
    { itemName = "toolbox",             clientId = 2455,  buy =200,   sell=20 },
    -- wooden chest: not found in items.xml -- omitted.
    -- iron chest: not found in items.xml -- omitted.

    -- -- QUIVERS -----------------------------------------------
    -- Paladin essentials. Basic = cheap. Endgame = very expensive.
    { itemName = "quiver",               clientId = 35562, buy =500,   sell=100 },
    { itemName = "blue quiver",         clientId = 31626, buy =500,   sell=100 },
    { itemName = "decorated quiver",    clientId = 31627, buy  = 5000 },
    { itemName = "falcon quiver",       clientId = 33766, buy  = 100000 },
    { itemName = "rift quiver",         clientId = 34095, buy  = 100000 },
    { itemName = "sanguine quiver",     clientId = 39286, buy  = 500000 },

    -- -- RINGS (utility) ---------------------------------------
    -- NPC sell prices used as base, x2 markup for our shop.
    -- NPC also buys most rings back at ~half NPC sell price.
    { itemName = "life ring",           clientId = 3052,  buy =2000,   sell=450  },
    { itemName = "energy ring",         clientId = 3051,  buy =4000,   sell=1000 },
    { itemName = "time ring",           clientId = 3053,  buy =4000,   sell=1000 },
    { itemName = "power ring",          clientId = 3050,  buy =2000,   sell=500  },
    { itemName = "dwarven ring",        clientId = 3097,  buy =2000,   sell=500  },
    { itemName = "axe ring",            clientId = 3092,  buy =4000,   sell=800  },
    { itemName = "club ring",           clientId = 3093,  buy =4000,   sell=800  },
    { itemName = "sword ring",          clientId = 3091,  buy =4000,   sell=800  },
    { itemName = "death ring",          clientId = 6299,  buy =4000,   sell=800  },
    { itemName = "gold ring",           clientId = 3063,  buy =2000,   sell=500  },
    { itemName = "crystal ring",        clientId = 3007,  buy =4000,   sell=800  },
    { itemName = "star ring",           clientId = 12669, buy =5000,   sell=1000 },
    { itemName = "stealth ring",        clientId = 3049,  buy =10000,  sell=2500 },
    { itemName = "might ring",          clientId = 3048,  buy =200000, sell=50000 },

    -- -- RINGS (mid / high) ------------------------------------
    { itemName = "ring of healing",     clientId = 3098,  buy  = 10000 },
    { itemName = "ring of the sky",     clientId = 7419,  buy  = 20000 },
    { itemName = "ring of blue plasma", clientId = 23529, buy =20000,  sell=5000 },
    { itemName = "ring of red plasma",  clientId = 23533, buy =20000,  sell=5000 },
    { itemName = "ring of green plasma",clientId = 23531, buy =20000,  sell=5000 },
    { itemName = "guardian ring",       clientId = 11098, buy  = 10000 },
    { itemName = "claw ring",           clientId = 17095, buy  = 10000 },
    { itemName = "gnome ring",          clientId = 23541, buy  = 50000 },
    { itemName = "eye of the storm ring", clientId = 25758, buy  = 50000 },

    -- -- RINGS (endgame) ---------------------------------------
    -- Priced high -- hunting is always more efficient.
    { itemName = "falcon ring",         clientId = 33765, buy  = 300000 },
    { itemName = "cobra ring",          clientId = 34094, buy  = 300000 },
    { itemName = "lion ring",           clientId = 34080, buy  = 300000 },
    { itemName = "prismatic ring",      clientId = 16114, buy  = 500000 },
    { itemName = "alicorn ring",        clientId = 39182, buy  = 1000000 },
    { itemName = "arboreal ring",       clientId = 39188, buy  = 1000000 },
    { itemName = "spiritthorn ring",    clientId = 39179, buy  = 1000000 },
    { itemName = "sanguine coil",       clientId = 40253, buy  = 2000000 },
    { itemName = "sanguine loop",       clientId = 40254, buy  = 2000000 },

    -- -- AMULETS (basic protection) ----------------------------
    -- Official NPC prices used as reference.
    { itemName = "stone skin amulet",   clientId = 3081,  buy =1000,   sell=250  },
    { itemName = "terra amulet",        clientId = 814,   buy =1000,   sell=250  },
    { itemName = "lightning pendant",   clientId = 816,   buy =1000,   sell=250  },
    { itemName = "magma amulet",        clientId = 817,   buy =1000,   sell=250  },
    { itemName = "glacier amulet",      clientId = 815,   buy =1000,   sell=250  },
    { itemName = "icy amulet",          clientId = 813,   buy =1000,   sell=250  },
    { itemName = "silver amulet",       clientId = 3059,  buy =500,    sell=100  },
    { itemName = "golden amulet",       clientId = 3013,  buy =500,    sell=100  },
    { itemName = "bronze amulet",       clientId = 3056,  buy =200,    sell=50   },
    { itemName = "dragon necklace",     clientId = 3085,  buy =1000,   sell=200  },
    { itemName = "elven amulet",        clientId = 3082,  buy =1000,   sell=200  },
    { itemName = "garlic necklace",     clientId = 3083,  buy =200,    sell=50   },

    -- -- AMULETS (mid-tier) ------------------------------------
    { itemName = "platinum amulet",     clientId = 3055,  buy =8000,   sell=2000 },
    { itemName = "amulet of loss",      clientId = 3057,  buy =60000,  sell=15000 },
    { itemName = "bonfire amulet",      clientId = 9301,  buy  = 4000 },
    { itemName = "gearwheel chain",     clientId = 21170, buy  = 5000 },
    { itemName = "gill necklace",       clientId = 16108, buy  = 5000 },
    { itemName = "foxtail amulet",      clientId = 27565, buy  = 5000 },
    { itemName = "jade amulet",         clientId = 20342, buy  = 5000 },
    { itemName = "mysterious amulet",   clientId = 3084,  buy  = 10000 },
    { itemName = "ruby necklace",       clientId = 3016,  buy =5000,   sell=1000 },
    { itemName = "sapphire necklace",   clientId = 35604, buy =5000,   sell=1000 },
    { itemName = "diamond necklace",    clientId = 35607, buy =10000,  sell=2500 },
    { itemName = "emerald necklace",    clientId = 35605, buy =10000,  sell=2500 },
    { itemName = "golden necklace",     clientId = 3009,  buy =8000,   sell=2000 },

    -- -- AMULETS (endgame) -------------------------------------
    -- phoenix necklace: ID not confirmed in items.xml -- omitted until verified.
    { itemName = "spirit cloak",            clientId = 8042,  buy  = 50000 },
    { itemName = "exotic amulet",           clientId = 35523, buy  = 30000 },
    { itemName = "enchanted werewolf amulet", clientId = 22061, buy  = 20000 },
    { itemName = "falcon pendant",          clientId = 33764, buy  = 200000 },
    { itemName = "cobra amulet",            clientId = 34093, buy  = 200000 },
    { itemName = "lion amulet",             clientId = 34079, buy  = 200000 },
    { itemName = "alicorn amulet",          clientId = 39181, buy  = 500000 },
    { itemName = "spiritthorn necklace",    clientId = 39178, buy  = 500000 },
    { itemName = "sanguine fibula",         clientId = 40251, buy  = 1000000 },
    { itemName = "sanguine brooch",         clientId = 40252, buy  = 1000000 },
}

-- On buy: NPC sells item to player
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
    npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end

-- On sell: player sells item to NPC
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
    player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end

-- On look/check item
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
