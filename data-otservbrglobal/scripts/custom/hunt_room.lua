print("Zero1 Hunt Room PRIORITY FIX loaded - level gates + subtle one-word labels + real visual lookTypes")

local PORTAL_ITEM_IDS = {
    fire = 25053,
    energy = 25051,
}

local ROOM = {
    fromX = 32243,
    toX = 32268,
    fromY = 32167,
    toY = 32191,
    z = 8,
}

local CLEAN_ROOM_ON_STARTUP = true
local CREATE_RETURN_PORTALS = true
local LEVEL_GATE_ENABLED = false  -- set false to open all portals to everyone

-- Destination source: generated from otservbr-monster.xml spawn coordinates.
-- Corrected layout: 5 mob columns x 11 rows = 55 teleports, organized through 3 shared walking aisles.
-- Removed Orshabaal/Ferumbras/Endgame placeholders because they were not in the uploaded spawn XML.
-- New monsters were filtered to generic/high-XP hunting creatures and only included when found in the uploaded XML.

local VERTICAL_WALL_ID = 1356
local HORIZONTAL_WALL_ID = 1357

local HUNT_ROOM_RETURN_POS = Position(32256, 32193, 8)
local RETURN_AID = 8799  -- was 9799, changed to avoid AID conflicts

_G.Z1 = _G.Z1 or {}
local Z1 = _G.Z1


-- Label color tuning. Random colors looked flashy but readability was bad.
-- TEXTCOLOR_WHITE is preferred when available; 215 is a safe white-ish fallback in most Canary/TFS builds.
local HUNT_LABEL_COLOR = TEXTCOLOR_LIGHTBLUE or TEXTCOLOR_LIGHTGREY or 35
local HUNT_LABEL_EFFECT = nil

local function showLabel(text, pos, effect)
    if Game.sendAnimatedText then
        Game.sendAnimatedText(text, pos, HUNT_LABEL_COLOR)
    else
        local spectators = Game.getSpectators(pos, false, true, 7, 7, 5, 5)
        for i = 1, #spectators do
            spectators[i]:say(text, TALKTYPE_MONSTER_SAY, false, spectators[i], pos)
        end
    end

    if effect and effect ~= CONST_ME_NONE then
        pos:sendMagicEffect(effect)
    end
end

local function registerVisualMonster(name, lookType)
    local mType = Game.createMonsterType(name)
    local monster = {}

    monster.description = name:lower()
    monster.experience = 0
    monster.outfit = { lookType = lookType }

    monster.health = 999999999
    monster.maxHealth = 999999999
    monster.race = "blood"
    monster.corpse = 0
    monster.speed = 0
    monster.manaCost = 0

    monster.changeTarget = { interval = 4000, chance = 0 }
    monster.strategiesTarget = { nearest = 100 }

    monster.flags = {
        summonable = false,
        attackable = false,
        hostile = false,
        convinceable = false,
        pushable = false,
        rewardBoss = false,
        illusionable = false,
        canPushItems = false,
        canPushCreatures = false,
        staticAttackChance = 0,
        targetDistance = 1,
        runHealth = 0,
        healthHidden = true,
        isBlockable = true,
        canWalkOnEnergy = true,
        canWalkOnFire = true,
        canWalkOnPoison = true,
    }

    monster.light = { level = 0, color = 0 }
    monster.voices = { interval = 5000, chance = 0 }
    monster.loot = {}
    monster.attacks = {}
    monster.defenses = { defense = 999, armor = 999, mitigation = 100 }

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
end

-- Visual monster appearance registry.
-- NOTE: TibiaWiki Creature IDs are useful references, but some IDs are not valid client lookTypes in Canary.
-- I kept known safe classic lookTypes where your server already had working visuals,
-- fixed Lion to a safe lion lookType, and replaced the generic extra placeholders with the uploaded Creature ID values.
local VISUAL_MONSTER_LOOKTYPES = {
    ["Z1 Aisle Rotworm"] = { lookType = 26, source = "Rotworm" },
    ["Z1 Aisle Minotaur"] = { lookType = 25, source = "Minotaur" },
    ["Z1 Aisle Dwarf"] = { lookType = 69, source = "Dwarf" },
    ["Z1 Aisle Cyclops"] = { lookType = 22, source = "Cyclops" },
    ["Z1 Aisle Pirate"] = { lookType = 98, source = "Pirate Corsair" },
    ["Z1 Aisle Vampire"] = { lookType = 68, source = "Vampire" },
    ["Z1 Aisle Dragon"] = { lookType = 34, source = "Dragon" },
    ["Z1 Aisle Dragon Lord"] = { lookType = 39, source = "Dragon Lord" },
    ["Z1 Aisle Giant Spider"] = { lookType = 38, source = "Giant Spider" },
    ["Z1 Aisle Hero"] = { lookType = 73, source = "Hero" },
    ["Z1 Aisle Wyrm"] = { lookType = 291, source = "Wyrm" },
    ["Z1 Aisle Frost Dragon"] = { lookType = 248, source = "Frost Dragon" },
    ["Z1 Aisle Warlock"] = { lookType = 130, source = "Warlock" },
    ["Z1 Aisle Hydra"] = { lookType = 121, source = "Hydra" },
    ["Z1 Aisle Behemoth"] = { lookType = 55, source = "Behemoth" },
    ["Z1 Aisle Hellhound"] = { lookType = 240, source = "Hellhound" },
    ["Z1 Aisle Nightmare"] = { lookType = 245, source = "Nightmare" },
    ["Z1 Aisle Grim Reaper"] = { lookType = 300, source = "Grim Reaper" },
    ["Z1 Aisle Serpent Spawn"] = { lookType = 220, source = "Serpent Spawn" },
    ["Z1 Aisle Medusa"] = { lookType = 330, source = "Medusa" },
    ["Z1 Aisle Demon"] = { lookType = 35, source = "Demon" },
    ["Z1 Aisle Draken"] = { lookType = 362, source = "Draken Elite" },
    ["Z1 Aisle Undead Dragon"] = { lookType = 231, source = "Undead Dragon" },
    ["Z1 Aisle Destroyer"] = { lookType = 236, source = "Destroyer" },
    ["Z1 Aisle Asura"] = { lookType = 150, source = "Frost Flower Asura" },
    ["Z1 Aisle Falcon"] = { lookType = 1071, source = "Falcon Paladin" },
    ["Z1 Aisle Cobra"] = { lookType = 1217, source = "Cobra Assassin" },
    ["Z1 Aisle Lion Knight"] = { lookType = 1317, source = "Lion Knight" },
    ["Z1 Aisle Dark Torturer"] = { lookType = 234, source = "Dark Torturer" },
    ["Z1 Aisle Juggernaut"] = { lookType = 244, source = "Juggernaut" },
    ["Z1 Aisle Plaguesmith"] = { lookType = 247, source = "Plaguesmith" },
    ["Z1 Aisle Fury"] = { lookType = 149, source = "Fury" },
    ["Z1 Aisle Hellfire Fighter"] = { lookType = 243, source = "Hellfire Fighter" },
    ["Z1 Aisle Bony Sea Devil"] = { lookType = 1294, source = "Bony Sea Devil" },
    ["Z1 Aisle Brachiodemon"] = { lookType = 1299, source = "Brachiodemon" },
    ["Z1 Aisle Branchy Crawler"] = { lookType = 1297, source = "Branchy Crawler" },
    ["Z1 Aisle Capricious Phantom"] = { lookType = 1298, source = "Capricious Phantom" },
    ["Z1 Aisle Cloak Of Terror"] = { lookType = 1295, source = "Cloak of Terror" },
    ["Z1 Aisle Courage Leech"] = { lookType = 1315, source = "Courage Leech" },
    ["Z1 Aisle Distorted Phantom"] = { lookType = 1298, source = "Distorted Phantom" },
    ["Z1 Aisle Gore Horn"] = { lookType = 1548, source = "Gore Horn" },
    ["Z1 Aisle Gorerilla"] = { lookType = 1559, source = "Gorerilla" },
    ["Z1 Aisle Hulking Prehemoth"] = { lookType = 1553, source = "Hulking Prehemoth" },
    ["Z1 Aisle Infernal Demon"] = { lookType = 1313, source = "Infernal Demon" },
    ["Z1 Aisle Infernal Phantom"] = { lookType = 1298, source = "Infernal Phantom" },
    ["Z1 Aisle Many Faces"] = { lookType = 1296, source = "Many Faces" },
    ["Z1 Aisle Mould Phantom"] = { lookType = 1298, source = "Mould Phantom" },
    ["Z1 Aisle Rotten Golem"] = { lookType = 1312, source = "Rotten Golem" },
    ["Z1 Aisle Sulphider"] = { lookType = 1546, source = "Sulphider" },
    ["Z1 Aisle Turbulent Elemental"] = { lookType = 1314, source = "Turbulent Elemental" },
    ["Z1 Aisle Vibrant Phantom"] = { lookType = 1298, source = "Vibrant Phantom" },
    ["Z1 Aisle Brain Squid"] = { lookType = 1059, source = "Brain Squid" },
    ["Z1 Aisle Burning Book"] = { lookType = 1061, source = "Burning Book" },
    ["Z1 Aisle Icecold Book"] = { lookType = 1061, source = "Icecold Book" },
    ["Z1 Aisle Energetic Book"] = { lookType = 1061, source = "Energetic Book" },
}

for visualName, data in pairs(VISUAL_MONSTER_LOOKTYPES) do
    registerVisualMonster(visualName, data.lookType)
end

-- Corrected room layout: 5 mob columns, but only 3 shared walking aisles.
-- Important: portal must touch the walking aisle. Monster goes behind the portal.
--
-- X distribution:
-- 32243-32246 = left walking aisle, using the 4 free spaces you pointed out
-- 32247-32249 = column 1, faces left aisle
-- 32250-32252 = column 2, faces middle aisle
-- 32253-32255 = middle shared aisle
-- 32256-32258 = column 3, faces middle aisle
-- 32259-32261 = column 4, faces right shared aisle
-- 32262-32264 = right shared aisle
-- 32265-32267 = column 5, faces right shared aisle
-- 32268       = right buffer / wall-side free tile
local lanes = {
    -- Column 1: opened from the left aisle.
    -- From aisle to room: portal, monster, wall.
    { side = "left",  portalX = 32247, monsterX = 32248, wallX = 32249 },

    -- Column 2: opened from the middle aisle on its right side.
    -- From left to right: wall, monster, portal, then shared aisle.
    { side = "right", wallX = 32250, monsterX = 32251, portalX = 32252 },

    -- Column 3: opened from the same middle aisle on its left side.
    -- From shared aisle to room: portal, monster, wall.
    { side = "left",  portalX = 32256, monsterX = 32257, wallX = 32258 },

    -- Column 4: opened from the right shared aisle on its right side.
    { side = "right", wallX = 32259, monsterX = 32260, portalX = 32261 },

    -- Column 5: opened from the same right shared aisle on its left side.
    { side = "left",  portalX = 32265, monsterX = 32266, wallX = 32267 },
}

local startY = 32168
local rowStep = 2
local rowsPerLane = 11
local z = 8

-- NOTE: AIDs use 87XX range (not 97XX) to avoid conflict with
-- Canary built-in scripts: teleport_ab_dendriel.lua (9701-9705)
-- and fury_gates.lua (9710, 9715).
local hunts = {
    { aid = 8701, label = "ROTWORMS",       level = "LVL 20+",   visualMonster = "Z1 Aisle Rotworm",        destination = Position(32797, 31560, 7) },
    { aid = 8702, label = "MINOTAURS",      level = "LVL 35+",   visualMonster = "Z1 Aisle Minotaur",       destination = Position(32463, 31948, 3) },
    { aid = 8703, label = "DWARVES",        level = "LVL 45+",   visualMonster = "Z1 Aisle Dwarf",          destination = Position(32570, 31453, 8) },
    { aid = 8704, label = "CYCLOPS",        level = "LVL 50+",   visualMonster = "Z1 Aisle Cyclops",        destination = Position(32609, 31404, 2) },
    { aid = 8705, label = "PIRATES",        level = "LVL 80+",   visualMonster = "Z1 Aisle Pirate",         destination = Position(31982, 32826, 2) },
    { aid = 8706, label = "VAMPIRES",       level = "LVL 110+",  visualMonster = "Z1 Aisle Vampire",        destination = Position(32953, 31435, 2) },
    { aid = 8707, label = "DRAGONS",        level = "LVL 150+",  visualMonster = "Z1 Aisle Dragon",         destination = Position(33103, 32590, 6) },
    { aid = 8708, label = "DRAGON LORDS",   level = "LVL 220+",  visualMonster = "Z1 Aisle Dragon Lord",    destination = Position(32615, 31336, 15) },
    { aid = 8709, label = "GIANT SPIDERS",  level = "LVL 280+",  visualMonster = "Z1 Aisle Giant Spider",   destination = Position(32768, 31098, 2) },

    { aid = 8710, label = "HEROES",         level = "LVL 330+",  visualMonster = "Z1 Aisle Hero",           destination = Position(33298, 31597, 9) },
    { aid = 8711, label = "WYRMS",          level = "LVL 400+",  visualMonster = "Z1 Aisle Wyrm",           destination = Position(32405, 32729, 2) },
    { aid = 8712, label = "FROST DRAGONS",  level = "LVL 500+",  visualMonster = "Z1 Aisle Frost Dragon",   destination = Position(32250, 31404, 5) },
    { aid = 8713, label = "WARLOCKS",       level = "LVL 600+",  visualMonster = "Z1 Aisle Warlock",        destination = Position(33167, 31772, 15) },
    { aid = 8714, label = "HYDRAS",         level = "LVL 700+",  visualMonster = "Z1 Aisle Hydra",          destination = Position(33012, 32639, 4) },
    { aid = 8715, label = "BEHEMOTHS",      level = "LVL 850+",  visualMonster = "Z1 Aisle Behemoth",       destination = Position(32404, 32747, 1) },
    { aid = 8716, label = "HELLHOUNDS",     level = "LVL 950+",  visualMonster = "Z1 Aisle Hellhound",      destination = Position(33414, 31719, 8) },
    { aid = 8717, label = "NIGHTMARES",     level = "LVL 1000+", visualMonster = "Z1 Aisle Nightmare",      destination = Position(32939, 31460, 3) },
    { aid = 8718, label = "GRIM REAPERS",   level = "LVL 1050+", visualMonster = "Z1 Aisle Grim Reaper",    destination = Position(32784, 31025, 8) },

    { aid = 8719, label = "SERPENTS",       level = "LVL 1100+", visualMonster = "Z1 Aisle Serpent Spawn",  destination = Position(32753, 32514, 11) },
    { aid = 8720, label = "MEDUSA",         level = "LVL 1250+", visualMonster = "Z1 Aisle Medusa",         destination = Position(32868, 32826, 2) },
    { aid = 8721, label = "DEMONS",         level = "LVL 1450+", visualMonster = "Z1 Aisle Demon",          destination = Position(32117, 32679, 5) },
    { aid = 8722, label = "DRAKENS",        level = "LVL 1700+", visualMonster = "Z1 Aisle Draken",         destination = Position(33107, 31077, 2) },
    { aid = 8723, label = "UNDEAD DRAGONS", level = "LVL 1850+", visualMonster = "Z1 Aisle Undead Dragon",  destination = Position(33631, 31825, 8) },
    { aid = 8724, label = "DESTROYERS",     level = "LVL 1900+", visualMonster = "Z1 Aisle Destroyer",      destination = Position(32852, 32274, 12) },
    { aid = 8725, label = "ASURAS",         level = "LVL 2000+", visualMonster = "Z1 Aisle Asura",          destination = Position(32949, 32690, 7) },
    { aid = 8726, label = "FALCONS",        level = "LVL 2400+", visualMonster = "Z1 Aisle Falcon",         destination = Position(33366, 31322, 2) },
    { aid = 8727, label = "COBRAS",         level = "LVL 2800+", visualMonster = "Z1 Aisle Cobra",          destination = Position(33388, 32680, 5) },

    { aid = 8728, label = "LION KNIGHTS",          level = "LVL 3200+", visualMonster = "Z1 Aisle Lion Knight",           destination = Position(32364, 32476, 5) },
    { aid = 8729, label = "DARK TORTURERS", level = "LVL 3400+", visualMonster = "Z1 Aisle Dark Torturer",  destination = Position(33472, 31728, 8) },
    { aid = 8730, label = "JUGGERNAUTS",    level = "LVL 3800+", visualMonster = "Z1 Aisle Juggernaut",     destination = Position(33429, 32454, 13) },
    { aid = 8731, label = "PLAGUESMITHS",   level = "LVL 4200+", visualMonster = "Z1 Aisle Plaguesmith",    destination = Position(33238, 31437, 13) },
    { aid = 8732, label = "FURIES",         level = "LVL 4500+", visualMonster = "Z1 Aisle Fury",           destination = Position(33298, 31835, 15) },
    { aid = 8733, label = "HELLFIRE",       level = "LVL 4700+", visualMonster = "Z1 Aisle Hellfire Fighter", destination = Position(33615, 32634, 13) },

    -- Expanded high-XP generic hunts from the uploaded creature list and verified in otservbr-monster.xml.
    { aid = 8734, label = "BONY SEA DEVIL",       level = "LVL 5000+", visualMonster = "Z1 Aisle Bony Sea Devil",       destination = Position(33938, 31017, 8) },
    { aid = 8735, label = "BRACHIODEMON",         level = "LVL 5200+", visualMonster = "Z1 Aisle Brachiodemon",         destination = Position(34040, 31063, 11) },
    { aid = 8736, label = "BRANCHY CRAWLER",      level = "LVL 5400+", visualMonster = "Z1 Aisle Branchy Crawler",      destination = Position(33933, 31084, 11) },
    { aid = 8737, label = "CAPRICIOUS PHANTOM",   level = "LVL 5600+", visualMonster = "Z1 Aisle Capricious Phantom",   destination = Position(33941, 31032, 9) },
    { aid = 8738, label = "CLOAK OF TERROR",      level = "LVL 5800+", visualMonster = "Z1 Aisle Cloak Of Terror",      destination = Position(33884, 31861, 4) },
    { aid = 8739, label = "COURAGE LEECH",        level = "LVL 6000+", visualMonster = "Z1 Aisle Courage Leech",        destination = Position(33839, 31835, 3) },
    { aid = 8740, label = "DISTORTED PHANTOM",    level = "LVL 6200+", visualMonster = "Z1 Aisle Distorted Phantom",    destination = Position(33931, 31218, 12) },
    { aid = 8741, label = "GORE HORNS",           level = "LVL 6600+", visualMonster = "Z1 Aisle Gore Horn",            destination = Position(33562, 32863, 14) },
    { aid = 8742, label = "GORERILLAS",           level = "LVL 6800+", visualMonster = "Z1 Aisle Gorerilla",            destination = Position(33588, 32979, 14) },

    { aid = 8743, label = "HULKING PREHEMOTH",    level = "LVL 7200+", visualMonster = "Z1 Aisle Hulking Prehemoth",    destination = Position(33640, 32911, 14) },
    { aid = 8744, label = "INFERNAL DEMONS",      level = "LVL 7400+", visualMonster = "Z1 Aisle Infernal Demon",       destination = Position(33990, 31037, 9) },
    { aid = 8745, label = "INFERNAL PHANTOMS",    level = "LVL 7600+", visualMonster = "Z1 Aisle Infernal Phantom",     destination = Position(33999, 31065, 9) },
    { aid = 8746, label = "MANY FACES",           level = "LVL 8000+", visualMonster = "Z1 Aisle Many Faces",           destination = Position(33918, 31205, 9) },
    { aid = 8747, label = "MOULD PHANTOMS",       level = "LVL 8400+", visualMonster = "Z1 Aisle Mould Phantom",        destination = Position(33950, 31036, 12) },
    { aid = 8748, label = "ROTTEN GOLEMS",        level = "LVL 9000+", visualMonster = "Z1 Aisle Rotten Golem",         destination = Position(33937, 31087, 13) },

    { aid = 8749, label = "SULPHIDERS",           level = "LVL 9800+", visualMonster = "Z1 Aisle Sulphider",            destination = Position(33652, 32821, 14) },
    { aid = 8750, label = "TURBULENT ELEMENTALS", level = "LVL 10200+", visualMonster = "Z1 Aisle Turbulent Elemental", destination = Position(33940, 31093, 9) },
    { aid = 8751, label = "VIBRANT PHANTOMS",     level = "LVL 10600+", visualMonster = "Z1 Aisle Vibrant Phantom",     destination = Position(33843, 31901, 3) },
    { aid = 8752, label = "BRAIN SQUIDS",         level = "LVL 10800+", visualMonster = "Z1 Aisle Brain Squid",         destination = Position(32479, 32805, 12) },
    { aid = 8753, label = "BURNING BOOKS",        level = "LVL 11000+", visualMonster = "Z1 Aisle Burning Book",        destination = Position(32584, 32718, 12) },
    { aid = 8754, label = "ICECOLD BOOKS",        level = "LVL 11200+", visualMonster = "Z1 Aisle Icecold Book",        destination = Position(32467, 32593, 14) },
    { aid = 8755, label = "ENERGETIC BOOKS",      level = "LVL 11400+", visualMonster = "Z1 Aisle Energetic Book",      destination = Position(32515, 32539, 12) },
}

local portalConfig = {}
local visualMonsters = {}
local walls = {}
local destinations = {}

local function addWall(pos, itemId)
    table.insert(walls, { pos = pos, itemId = itemId })
end

local function buildLayout()
    for index, hunt in ipairs(hunts) do
        local laneIndex = math.floor((index - 1) / rowsPerLane) + 1
        local rowIndex = (index - 1) % rowsPerLane
        local lane = lanes[laneIndex]
        if not lane then
            print("[Z1 Hunt Aisle] Too many hunts configured. Increase lanes or rowsPerLane. Skipping: " .. hunt.label)
            return
        end

        local y = startY + (rowIndex * rowStep)

        local portalPos = Position(lane.portalX, y, z)
        local visualPos = Position(lane.monsterX, y, z)

        table.insert(portalConfig, {
            pos = portalPos,
            itemId = PORTAL_ITEM_IDS.fire,
            aid = hunt.aid,
            label = hunt.label .. " - " .. hunt.level,
        })

        table.insert(visualMonsters, {
            pos = visualPos,
            name = hunt.visualMonster,
            label = hunt.label,
        })

        destinations[hunt.aid] = hunt.destination

        -- Room-style dividers.
        -- Each monster gets a side wall plus horizontal separators.
        if rowIndex > 0 then
            addWall(Position(lane.wallX, y - 1, z), HORIZONTAL_WALL_ID)
            addWall(Position(lane.monsterX, y - 1, z), HORIZONTAL_WALL_ID)
            addWall(Position(lane.portalX, y - 1, z), HORIZONTAL_WALL_ID)
        end

        -- Side wall next to monster, creating the small-room look.
        addWall(Position(lane.wallX, y, z), VERTICAL_WALL_ID)
        addWall(Position(lane.wallX, y - 1, z), VERTICAL_WALL_ID)

        -- Bottom separator only on final row.
        if rowIndex == rowsPerLane - 1 then
            addWall(Position(lane.wallX, y + 1, z), HORIZONTAL_WALL_ID)
            addWall(Position(lane.monsterX, y + 1, z), HORIZONTAL_WALL_ID)
            addWall(Position(lane.portalX, y + 1, z), HORIZONTAL_WALL_ID)
        end

        if CREATE_RETURN_PORTALS then
            local returnPos = Position(hunt.destination.x - 1, hunt.destination.y, hunt.destination.z)

            table.insert(portalConfig, {
                pos = returnPos,
                itemId = PORTAL_ITEM_IDS.energy,
                aid = RETURN_AID,
                label = "BACK TO HUNTS",
            })

            destinations[RETURN_AID] = HUNT_ROOM_RETURN_POS
        end
    end
end

buildLayout()

local function cleanRoom()
    if not CLEAN_ROOM_ON_STARTUP then
        return
    end

    for x = ROOM.fromX, ROOM.toX do
        for y = ROOM.fromY, ROOM.toY do
            local pos = Position(x, y, ROOM.z)
            local tile = Tile(pos)

            if tile then
                local firePortal = tile:getItemById(PORTAL_ITEM_IDS.fire)
                if firePortal then firePortal:remove() end

                local energyPortal = tile:getItemById(PORTAL_ITEM_IDS.energy)
                if energyPortal then energyPortal:remove() end

                local vWall = tile:getItemById(VERTICAL_WALL_ID)
                if vWall then vWall:remove() end

                local hWall = tile:getItemById(HORIZONTAL_WALL_ID)
                if hWall then hWall:remove() end

                local creatures = tile:getCreatures()
                if creatures then
                    for _, creature in ipairs(creatures) do
                        local name = creature:getName():lower()
                        if name:find("z1 aisle") or name:find("z1 grid") or name:find("z1 test") then
                            creature:remove()
                        end
                    end
                end
            end
        end
    end
end

local function setupWalls()
    for _, wall in ipairs(walls) do
        local tile = Tile(wall.pos)

        if tile and not tile:getItemById(wall.itemId) then
            Game.createItem(wall.itemId, 1, wall.pos)
        end
    end
end

local function setupPortal(portal)
    local tile = Tile(portal.pos)
    if not tile then
        print("[Z1 Hunt Aisle] Missing portal tile at: " .. portal.pos.x .. "," .. portal.pos.y .. "," .. portal.pos.z)
        return
    end

    local item = tile:getItemById(portal.itemId)
    if not item then
        item = Game.createItem(portal.itemId, 1, portal.pos)
    end

    if item then
        item:setActionId(portal.aid)
        item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, portal.label)
    end
end

local function spawnVisualMonster(data)
    local tile = Tile(data.pos)
    if not tile then
        print("[Z1 Hunt Aisle] Missing visual tile at: " .. data.pos.x .. "," .. data.pos.y .. "," .. data.pos.z)
        return
    end

    local creatures = tile:getCreatures()
    if creatures then
        for _, creature in ipairs(creatures) do
            if creature:getName():lower() == data.name:lower() then
                return
            end
        end
    end

    local monster = Game.createMonster(data.name, data.pos, false, true)
    if monster then
        monster:setDropLoot(false)
    end
end

local startup = GlobalEvent("Zero1HuntAisleStartup")

function startup.onStartup()
    cleanRoom()
    setupWalls()

    for _, portal in ipairs(portalConfig) do
        setupPortal(portal)
    end

    for _, visual in ipairs(visualMonsters) do
        spawnVisualMonster(visual)
    end

    return true
end

startup:register()

local visualRespawn = GlobalEvent("Zero1HuntAisleVisualRespawn")

function visualRespawn.onThink(interval)
    for _, visual in ipairs(visualMonsters) do
        spawnVisualMonster(visual)
    end
    return true
end

visualRespawn:interval(10000)
visualRespawn:register()

local teleport = MoveEvent()

function teleport.onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()
    if not player then return true end

    local aid = item:getActionId()
    if aid == 0 then aid = item.actionid end

    local destination = destinations[aid]
    if not destination then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "This hunt teleport is not configured yet.")
        return true
    end

	if LEVEL_GATE_ENABLED and aid ~= RETURN_AID then
		local hunt = nil
		for _, h in ipairs(hunts) do
			if h.aid == aid then hunt = h break end
		end
		if hunt and hunt.level and player:getLevel() < hunt.level then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
				string.format("You need level %d to enter %s.", hunt.level, hunt.label))
			player:teleportTo(fromPosition, true)
			fromPosition:sendMagicEffect(CONST_ME_POFF)
			return true
		end
	end

    player:teleportTo(destination)
    position:sendMagicEffect(CONST_ME_TELEPORT)
    destination:sendMagicEffect(CONST_ME_TELEPORT)
    return true
end

teleport:type("stepin")

for aid in pairs(destinations) do
    teleport:aid(aid)
end

teleport:register()

local labelEvent = GlobalEvent("Zero1HuntAisleLabels")

function labelEvent.onThink(interval)
    for _, visual in ipairs(visualMonsters) do
        local spectators = Game.getSpectators(visual.pos, false, true, 7, 7, 5, 5)

        if #spectators > 0 then
            showLabel(visual.label, visual.pos, HUNT_LABEL_EFFECT)
        end
    end

    return true
end

labelEvent:interval(4000)
labelEvent:register()
