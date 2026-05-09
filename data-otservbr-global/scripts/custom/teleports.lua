print("Zero1 Teleport System loaded")

local PORTAL_ITEM_IDS = {
    fire = 25053,
    ice = 25057,
    holy = 25055,
    energy = 25051,
    death = 25047,
    earth = 25049,
}

local portalConfig = {
    -- THAIS DEPOT ENTRANCE PORTALS
    { pos = Position(32349, 32222, 7), itemId = PORTAL_ITEM_IDS.fire, aid = 9001, label = "HUNTS" },
    { pos = Position(32349, 32223, 7), itemId = PORTAL_ITEM_IDS.death, aid = 9002, label = "BOSSES" },
    { pos = Position(32349, 32224, 7), itemId = PORTAL_ITEM_IDS.ice, aid = 9003, label = "QUESTS" },
	{ pos = Position(32342, 32220, 7), itemId = PORTAL_ITEM_IDS.holy, aid = 8001, label = "TRAINING" },
	
	-- TEST TRAININGS
	{ pos = Position(32365, 32236, 7), aid = 8001, label = "TRAINING" },
    { pos = Position(1116, 1092, 7), aid = 8001, label = "TRAINING" },
    { pos = Position(1058, 1005, 7), aid = 8001, label = "TRAINING" },
    { pos = Position(1055, 1009, 7), aid = 8002, label = "NPCs" },

    -- HUNTS HUB
    { pos = Position(32163, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9101, label = "DRAGONS" },
    { pos = Position(32165, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9102, label = "DRAGON LORDS" },
    { pos = Position(32167, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9103, label = "FROST DRAGONS" },
    { pos = Position(32169, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9104, label = "GIANT SPIDERS" },
    { pos = Position(32171, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9105, label = "BEHEMOTHS" },
    { pos = Position(32173, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9106, label = "WYRMS" },
    { pos = Position(32175, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9107, label = "MEDUSA" },
    { pos = Position(32177, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9108, label = "SERPENTS" },
    { pos = Position(32179, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9109, label = "ASURAS" },
    { pos = Position(32181, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9110, label = "COBRAS" },
    { pos = Position(32183, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9111, label = "DRAKENS" },
    { pos = Position(32185, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9112, label = "FALCONS" },
    { pos = Position(32187, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9113, label = "WARLOCKS" },
    { pos = Position(32189, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9114, label = "HEROES" },
    { pos = Position(32191, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9115, label = "VAMPIRES" },
    { pos = Position(32193, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9116, label = "DJINNS BLUE" },
    { pos = Position(32195, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9117, label = "DJINNS GREEN" },
    { pos = Position(32197, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9118, label = "LIONS" },
    { pos = Position(32199, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9119, label = "CYCLOPS" },
    { pos = Position(32201, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9120, label = "PIRATES" },
    { pos = Position(32203, 31107, 6), itemId = PORTAL_ITEM_IDS.fire, aid = 9121, label = "ENERGY ELEMS" },

    -- BOSSES HUB
    { pos = Position(32163, 31092, 6), itemId = PORTAL_ITEM_IDS.death, aid = 9201, label = "ANNIHILATOR" },
    { pos = Position(32165, 31092, 6), itemId = PORTAL_ITEM_IDS.death, aid = 9202, label = "DEMONS" },
    { pos = Position(32167, 31092, 6), itemId = PORTAL_ITEM_IDS.death, aid = 9203, label = "WARZONE 7" },
    { pos = Position(32169, 31092, 6), itemId = PORTAL_ITEM_IDS.death, aid = 9204, label = "WARZONE 8" },
    { pos = Position(32171, 31092, 6), itemId = PORTAL_ITEM_IDS.death, aid = 9205, label = "WARZONE 9" },

    -- QUESTS HUB
    { pos = Position(32173, 31077, 6), itemId = PORTAL_ITEM_IDS.ice, aid = 9301, label = "POI" },
    { pos = Position(32175, 31077, 6), itemId = PORTAL_ITEM_IDS.ice, aid = 9302, label = "ANNIHILATOR" },
    { pos = Position(32177, 31077, 6), itemId = PORTAL_ITEM_IDS.ice, aid = 9303, label = "DEMON OAK" },
    { pos = Position(32179, 31077, 6), itemId = PORTAL_ITEM_IDS.ice, aid = 9304, label = "INFERNO PITS" },

    -- RETURN PORTALS
    { pos = Position(32163, 31104, 6), itemId = PORTAL_ITEM_IDS.energy, aid = 9999, label = "BACK TO THAIS" },
    { pos = Position(32163, 31090, 6), itemId = PORTAL_ITEM_IDS.energy, aid = 9999, label = "BACK TO THAIS" },
    { pos = Position(32170, 31079, 6), itemId = PORTAL_ITEM_IDS.energy, aid = 9999, label = "BACK TO THAIS" },
	    -- RETURN PORTALS AT HUNT DESTINATIONS
    { pos = Position(33177, 31196, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(33140, 31306, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32769, 31099, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32405, 32748, 1), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32406, 32730, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32869, 32827, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32876, 32834, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32946, 32680, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(33401, 32680, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(33108, 31078, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(33367, 31323, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32936, 31111, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32905, 31076, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32954, 31436, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(33097, 32529, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(33037, 32624, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32371, 32472, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32610, 31405, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(31983, 32827, 2), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
    { pos = Position(32942, 31556, 1), itemId = PORTAL_ITEM_IDS.energy, aid = 9910, label = "BACK TO HUNTS" },
}

local destinations = {
    -- DEPOT → HUBS
    [9001] = Position(32163, 31105, 6),
    [9002] = Position(32163, 31091, 6),
    [9003] = Position(32173, 31079, 6),
	[8001] = Position(1116, 1092, 7),

    -- HUNTS
    [9101] = Position(33176, 31195, 2),
    [9102] = Position(33176, 31195, 2),
    [9103] = Position(33139, 31305, 2),
    [9104] = Position(32768, 31098, 2),
    [9105] = Position(32404, 32747, 1),
    [9106] = Position(32405, 32729, 2),
    [9107] = Position(32868, 32826, 2),
    [9108] = Position(32875, 32833, 2),
    [9109] = Position(32945, 32679, 2),
    [9110] = Position(33400, 32679, 2),
    [9111] = Position(33107, 31077, 2),
    [9112] = Position(33366, 31322, 2),
    [9113] = Position(32935, 31110, 2),
    [9114] = Position(32904, 31075, 2),
    [9115] = Position(32953, 31435, 2),
    [9116] = Position(33096, 32528, 2),
    [9117] = Position(33036, 32623, 2),
    [9118] = Position(32370, 32471, 2),
    [9119] = Position(32609, 31404, 2),
    [9120] = Position(31982, 32826, 2),
    [9121] = Position(32941, 31555, 1),

    -- BOSSES
    [9201] = Position(33218, 31670, 13),
    [9202] = Position(33219, 31657, 13),
    [9203] = Position(32654, 31815, 10),
    [9204] = Position(32650, 31822, 10),
    [9205] = Position(32663, 31818, 10),

    -- QUESTS
    [9301] = Position(32787, 32327, 6),
    [9302] = Position(33218, 31670, 13),
    [9303] = Position(32798, 32327, 10),
    [9304] = Position(32787, 32327, 6),

    -- RETURNS
    [9999] = Position(32347, 32223, 7),
    [9910] = Position(32163, 31105, 6),
    [9920] = Position(32163, 31091, 6),
    [9930] = Position(32173, 31079, 6),
}

local startup = GlobalEvent("Zero1TeleportStartup")

function startup.onStartup()
    for _, portal in ipairs(portalConfig) do
        local tile = Tile(portal.pos)

        if tile then
            local item = tile:getItemById(portal.itemId)

            if not item then
                item = Game.createItem(portal.itemId, 1, portal.pos)
            end

            if item then
                item:setActionId(portal.aid)
                item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, portal.label)
            end
        else
            print("[Zero1TeleportStartup] Missing tile at: " .. portal.pos.x .. "," .. portal.pos.y .. "," .. portal.pos.z)
        end
    end

    return true
end

startup:register()

local teleport = MoveEvent()

function teleport.onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()
    if not player then
        return true
    end

    local destination = destinations[item.actionid]
    if not destination then
        return true
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

-- FLOATING LABELS FROM PORTAL CONFIG
local textcolors = {5, 30, 35, 95, 108, 129, 143, 155, 180, 198, 210, 215}

local function showLabel(text, pos, effect)
    if Game.sendAnimatedText then
        Game.sendAnimatedText(text, pos, textcolors[math.random(#textcolors)])
    else
        local spectators = Game.getSpectators(pos, false, true, 7, 7, 5, 5)
        for i = 1, #spectators do
            spectators[i]:say(text, TALKTYPE_MONSTER_SAY, false, spectators[i], pos)
        end
    end

    pos:sendMagicEffect(effect or CONST_ME_TELEPORT)
end

local labelEvent = GlobalEvent("Zero1TeleportLabels")

function labelEvent.onThink(interval)
    for _, portal in ipairs(portalConfig) do
        local spectators = Game.getSpectators(portal.pos, false, true, 7, 7, 5, 5)

        if #spectators > 0 then
            showLabel(portal.label, portal.pos, CONST_ME_TELEPORT)
        end
    end

    return true
end

labelEvent:interval(4000)
labelEvent:register()

-- ACTION ID LABELS
-- Any item with ActionID 4225 will show TEMPLE.
local aidLabels = {
{ aid = 4225, label = "TEMPLE" },
{ aid = 9701, label = "DAILY REWARD" },
}

local function checkTileForIdLabel(pos)
    local tile = Tile(pos)
    if not tile then
        return
    end

    local items = tile:getItems()
    if not items then
        return
    end

    for _, item in ipairs(items) do
        local aidText = aidLabels[item:getActionId()]
        if aidText then
            showLabel(aidText, pos, CONST_ME_MAGIC_BLUE)
            return
        end

        local uidText = uidLabels[item:getUniqueId()]
        if uidText then
            showLabel(uidText, pos, CONST_ME_MAGIC_BLUE)
            return
        end
    end
end

local actionIdLabelEvent = GlobalEvent("Zero1ActionIdLabels")

function actionIdLabelEvent.onThink(interval)
    local players = Game.getPlayers()

    for _, player in ipairs(players) do
        local p = player:getPosition()

        for x = p.x - 7, p.x + 7 do
            for y = p.y - 5, p.y + 5 do
                checkTileForIdLabel(Position(x, y, p.z))
            end
        end
    end

    return true
end

actionIdLabelEvent:interval(5000)
actionIdLabelEvent:register()