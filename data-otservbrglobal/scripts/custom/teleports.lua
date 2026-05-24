print("Zero1 Teleport System PRIORITY FIX loaded - level gates + stable labels")
_G.Z1 = _G.Z1 or {}
local Z1 = _G.Z1

local PORTAL_ITEM_IDS = {
    fire = 25053,
    ice = 25057,
    holy = 25055,
    energy = 25051,
    death = 25047,
    earth = 25049,
}

local LABEL_COLOR = TEXTCOLOR_LIGHTBLUE or TEXTCOLOR_LIGHTGREY or 35

local function showLabel(text, pos, effect)
    if Game.sendAnimatedText then
        Game.sendAnimatedText(text, pos, LABEL_COLOR)
    else
        local spectators = Game.getSpectators(pos, false, true, 7, 7, 5, 5)
        for i = 1, #spectators do
            spectators[i]:say(text, TALKTYPE_MONSTER_SAY, false, spectators[i], pos)
        end
    end

    pos:sendMagicEffect(effect or CONST_ME_TELEPORT)
end

-- =========================================================
-- PORTAL CONFIG
-- Hub entrance portals, bosses, quests, return portals.
-- Hunt portals are now handled by hunt_room.lua.
-- =========================================================

local portalConfig = {
    -- THAIS TEMPLE ENTRANCE PORTALS
    { pos = Position(32365, 32242, 7), itemId = PORTAL_ITEM_IDS.fire,  aid = 9001, label = "HUNTS" },
    { pos = Position(32373, 32242, 7), itemId = PORTAL_ITEM_IDS.death, aid = 9002, label = "BOSSES" },
    { pos = Position(32373, 32239, 7), itemId = PORTAL_ITEM_IDS.ice,   aid = 9003, label = "QUESTS" },
    { pos = Position(32365, 32236, 7), itemId = PORTAL_ITEM_IDS.holy,  aid = 8001, label = "TRAINING" },
	{ pos = Position(32373, 32236, 7), itemId = PORTAL_ITEM_IDS.energy,  aid = 9004, label = "DAILY CHEST" },

    -- TRAINING / NPC MARKERS
    { pos = Position(32365, 32236, 7), aid = 8001, label = "TRAINING" },
    { pos = Position(1116, 1092, 7),   aid = 8001, label = "TRAINING" },
    { pos = Position(1058, 1005, 7),   aid = 8001, label = "TRAINING" },
    { pos = Position(1055, 1009, 7),   aid = 8002, label = "NPCs" },

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

    -- RETURN PORTALS INSIDE HUBS
    { pos = Position(32163, 31104, 6), itemId = PORTAL_ITEM_IDS.energy, aid = 9999, label = "BACK TO TEMPLE" },
	{ pos = Position(32241, 32179, 8), itemId = PORTAL_ITEM_IDS.energy, aid = 9999, label = "BACK TO TEMPLE" },
    { pos = Position(32163, 31090, 6), itemId = PORTAL_ITEM_IDS.energy, aid = 9999, label = "BACK TO TEMPLE" },
    { pos = Position(32170, 31079, 6), itemId = PORTAL_ITEM_IDS.energy, aid = 9999, label = "BACK TO TEMPLE" },
}

local destinations = {
    [9001] = Position(32255, 32192, 8),
    [9002] = Position(32265, 32201, 8),
    [9003] = Position(32246, 32201, 8),
    [8001] = Position(1116, 1092, 7),
	[9004] = Position(1063, 1028, 7),

    [9201] = Position(33218, 31670, 13),
    [9202] = Position(33219, 31657, 13),
    [9203] = Position(32654, 31815, 10),
    [9204] = Position(32650, 31822, 10),
    [9205] = Position(32663, 31818, 10),

    [9301] = Position(32787, 32327, 6),
    [9302] = Position(33218, 31670, 13),
    [9303] = Position(32798, 32327, 10),
    [9304] = Position(32787, 32327, 6),

    [9999] = Position(32369, 32241, 7),
    [9910] = Position(32163, 31105, 6),
    [9920] = Position(32163, 31091, 6),
    [9930] = Position(32173, 31079, 6),
}

local function setupPortal(portal)
    local tile = Tile(portal.pos)
    if not tile then
        print("[Zero1TeleportStartup] Missing tile at: " .. portal.pos.x .. "," .. portal.pos.y .. "," .. portal.pos.z)
        return
    end

    local item = nil

    if portal.itemId then
        item = tile:getItemById(portal.itemId)
        if not item then
            item = Game.createItem(portal.itemId, 1, portal.pos)
        end
    else
        item = tile:getTopDownItem()
    end

    if item then
        item:setActionId(portal.aid)
        item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, portal.label)
    end
end

local startup = GlobalEvent("Zero1TeleportStartup")

function startup.onStartup()
    for _, portal in ipairs(portalConfig) do
        setupPortal(portal)
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

    local aid = item:getActionId()
    if aid == 0 then aid = item.actionid end

    local destination = destinations[aid]
    if not destination then
        return true
    end

    if aid ~= 9999 then
        local ok, reason = true, nil
        if Z1 and Z1.checkLevelGate and _G.Z1HubLevels then
            ok, reason = Z1.checkLevelGate(player, aid, _G.Z1HubLevels)
        elseif _G.Z1HubLevels and _G.Z1HubLevels[aid] and player:getLevel() < _G.Z1HubLevels[aid] then
            ok = false
            reason = "You need level " .. _G.Z1HubLevels[aid] .. " to use this portal."
        end
        if not ok then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, reason or "Your level is too low for this portal.")
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

local aidLabels = {
    [4225] = "TEMPLE",
}

local uidLabels = {}

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
