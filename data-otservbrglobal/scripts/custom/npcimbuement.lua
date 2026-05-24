-- data/scripts/custom/npcimbuement.lua
-- Zero1 Imbuement Supplies NPC
-- Converted to Canary Game.createNpcType API (same as z1_merchant.lua).
-- Old NpcSystem/NpcHandler/ShopModule API is NOT available in Canary scripts/.
--
-- Sells all imbuement material items by clientId.
-- Place the NPC in-world via the map editor or a startup script.

local internalNpcName = "Equality Imbuement"
local npcType   = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name        = internalNpcName
npcConfig.description = "Imbuement Supplies"

npcConfig.health    = 500
npcConfig.maxHealth = 500
npcConfig.walkInterval = 0
npcConfig.walkRadius   = 0

npcConfig.outfit = {
    lookType   = 130,   -- shopkeeper female; change to taste
    lookHead   = 78,
    lookBody   = 52,
    lookLegs   = 95,
    lookFeet   = 114,
    lookAddons = 0,
}

npcConfig.flags = {
    floorchange = false,
}

npcConfig.voices = {
    interval = 20000,
    chance   = 40,
    { text = "I carry everything you need for imbuements!" },
    { text = "Quality imbuement materials, fair prices." },
    { text = "Ask me for a trade!" },
}

local keywordHandler = KeywordHandler:new()
local npcHandler     = NpcHandler:new(keywordHandler)

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

npcHandler:setMessage(MESSAGE_GREET,     "Welcome, |PLAYERNAME|! I carry imbuement materials. Say {trade} to browse my stock.")
npcHandler:setMessage(MESSAGE_WALKAWAY,  "Come back when you need supplies!")
npcHandler:setMessage(MESSAGE_SENDTRADE, "Here are my imbuement materials:")

npcHandler:setCallback(CALLBACK_SET_INTERACTION,    onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT,    creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- ============================================================
-- SHOP: all imbuement materials
-- sell = price player pays to BUY from NPC
-- Items are listed by clientId (server item ID) to avoid name-lookup failures.
-- ============================================================
npcConfig.shop = {

    -- -- BASIC / PROTECTION ------------------------------------
    { itemName = "protective charm",        clientId = 12448, buy = 5000 },
    { itemName = "sabretooth",              clientId = 11228, buy = 4000 },
    { itemName = "vexclaw talon",           clientId = 12440, buy = 6000 },

    -- -- VAMPIRISM ---------------------------------------------
    { itemName = "vampire teeth",           clientId = 10602, buy = 2000 },
    { itemName = "bloody pincers",          clientId = 10550, buy = 4000 },
    { itemName = "piece of dead brain",     clientId = 10577, buy = 7000 },

    -- -- VOID --------------------------------------------------
    { itemName = "rope belt",               clientId = 10557, buy = 2000 },
    { itemName = "silencer claws",          clientId = 12400, buy = 4000 },
    { itemName = "some grimeleech wings",   clientId = 12403, buy = 7000 },

    -- -- ELEMENTAL: FIRE ---------------------------------------
    { itemName = "fiery heart",             clientId = 9636,  buy = 3000 },
    { itemName = "green dragon leather",    clientId = 5877,  buy = 2000 },
    { itemName = "blazing bone",            clientId = 16131, buy = 7000 },

    -- -- ELEMENTAL: ICE ----------------------------------------
    { itemName = "ice cube",                clientId = 7441,  buy = 3000 },
    { itemName = "winter wolf fur",         clientId = 10295, buy = 5000 },
    { itemName = "thick fur",               clientId = 11224, buy = 7000 },

    -- -- ELEMENTAL: EARTH --------------------------------------
    { itemName = "earth heart",             clientId = 9596,  buy = 3000 },
    { itemName = "green dragon scale",      clientId = 5920,  buy = 4000 },
    { itemName = "swampling moss",          clientId = 17823, buy = 7000 },

    -- -- ELEMENTAL: ENERGY -------------------------------------
    { itemName = "energy vein",             clientId = 23508, buy = 5000 },
    { itemName = "spark sphere",            clientId = 23505, buy = 7000 },
    { itemName = "ring of blue plasma",     clientId = 23529, buy = 10000 },

    -- -- SHIELDING ---------------------------------------------
    { itemName = "hardened bone",           clientId = 5925,  buy = 3000 },
    { itemName = "turtle shell",            clientId = 5899,  buy = 5000 },
    { itemName = "horror skull",            clientId = 12443, buy = 7000 },

    -- -- SPEED -------------------------------------------------
    { itemName = "elk hoof",               clientId = 11236, buy = 3000 },
    { itemName = "wereboar hoof",          clientId = 13247, buy = 5000 },
    { itemName = "grimace",                clientId = 12445, buy = 7000 },

    -- -- SWORD SKILL -------------------------------------------
    { itemName = "lion's mane",            clientId = 10608, buy = 3000 },
    { itemName = "mooh'tah shell",         clientId = 12422, buy = 5000 },
    { itemName = "war crystal",            clientId = 16112, buy = 7000 },

    -- -- MAGIC LEVEL -------------------------------------------
    { itemName = "cultish mask",           clientId = 9638,  buy = 3000 },
    { itemName = "cloth piece",            clientId = 5912,  buy = 7000 },

    -- -- CAPACITY ----------------------------------------------
    { itemName = "fairy wings",            clientId = 5891,  buy = 3000 },
    { itemName = "little bowl of myrrh",   clientId = 16113, buy = 5000 },
    { itemName = "broken shamanic staff",  clientId = 12407, buy = 7000 },

    -- -- MOVEMENT SPEED (imbuement) ----------------------------
    { itemName = "damselfly eye",          clientId = 17463, buy = 3000 },
    { itemName = "compound eye",           clientId = 14083, buy = 5000 },
    { itemName = "iron ore",               clientId = 5880,  buy = 7000 },

    -- -- AXE SKILL ---------------------------------------------
    { itemName = "orc tooth",              clientId = 11113, buy = 2000 },
    { itemName = "battle stone",           clientId = 11222, buy = 5000 },
    { itemName = "walker's steel",         clientId = 23573, buy = 7000 },

    -- -- CLUB SKILL --------------------------------------------
    { itemName = "cyclops toe",            clientId = 10574, buy = 2000 },
    { itemName = "ogre nose ring",         clientId = 12418, buy = 5000 },
    { itemName = "war horn",               clientId = 12419, buy = 7000 },

    -- -- DISTANCE SKILL ----------------------------------------
    { itemName = "piece of swampling wood",clientId = 17828, buy = 3000 },
    { itemName = "metal spike",            clientId = 16130, buy = 5000 },
    { itemName = "elite draken mail",      clientId = 12607, buy = 7000 },

    -- -- SHIELD SKILL ------------------------------------------
    { itemName = "scarab shell",           clientId = 10556, buy = 3000 },
    { itemName = "brimstone shell",        clientId = 12417, buy = 5000 },
    { itemName = "frazzle skin",           clientId = 20199, buy = 7000 },

    -- -- MAGIC LEVEL (high) ------------------------------------
    { itemName = "mystical hourglass",     clientId = 9660,  buy = 5000 },
    { itemName = "burning heart",          clientId = 9633,  buy = 7000 },
    { itemName = "royal star",             clientId = 11427, buy = 10000 },
}

-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
