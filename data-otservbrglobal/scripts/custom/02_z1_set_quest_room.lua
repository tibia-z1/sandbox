-- 02_z1_set_quest_room.lua
-- SETROOM FIX: two-row visual reward-only equipment room. No trial teleport.
-- Put in: data/scripts/custom/
-- Requires: 00_z1_core.lua

local Z1 = _G.Z1
if not Z1 then
    print("[Z1 Set Room] ERROR: 00_z1_core.lua was not loaded before this file.")
    return
end

local function msg(player, text)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, text)
end

-- Visual floor/label polish for the set room.
-- White marble under display items makes the set pieces readable against the dark room.
local DISPLAY_FLOOR_ID = 409 -- white marble floor
local SET_LABEL_COLOR = TEXTCOLOR_LIGHTBLUE or TEXTCOLOR_LIGHTGREY or 35
local SET_LABEL_EFFECT = nil

local function ensureGround(pos, itemId)
    local tile = Tile(pos)
    if not tile then
        Game.createTile(pos, true)
        tile = Tile(pos)
    end
    if not tile then
        return false
    end

    local ground = tile:getGround()
    if ground then
        if ground:getId() ~= itemId then
            ground:transform(itemId)
        end
    else
        Game.createItem(itemId, 1, pos)
    end
    return true
end

local function sendCleanLabel(text, pos, effect)
    if Game.sendAnimatedText then
        Game.sendAnimatedText(text, pos, SET_LABEL_COLOR)
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

local function validItemId(id)
    if not id or id <= 0 then
        return false
    end
    local itemType = ItemType(id)
    return itemType and itemType:getId() and itemType:getId() > 0
end

local function resolveItemId(entry)
    if not entry then
        return nil
    end

    if entry.id and validItemId(entry.id) then
        return entry.id
    end

    if entry.ids then
        for _, candidate in ipairs(entry.ids) do
            if validItemId(candidate) then
                return candidate
            end
        end
    end

    if entry.names then
        for _, name in ipairs(entry.names) do
            local id = ItemType(name):getId()
            if id and id > 0 then
                return id
            end
        end
    end

    if entry.name then
        local id = ItemType(entry.name):getId()
        if id and id > 0 then
            return id
        end
    end

    return nil
end

local function resolveVisualItemId(trial)
    if trial.visualItemIds then
        for _, candidate in ipairs(trial.visualItemIds) do
            if validItemId(candidate) then
                return candidate
            end
        end
    end

    if trial.visualNames then
        for _, name in ipairs(trial.visualNames) do
            local id = ItemType(name):getId()
            if id and id > 0 then
                return id
            end
        end
    end

    if trial.rewards then
        for _, reward in ipairs(trial.rewards) do
            local id = resolveItemId(reward)
            if id then
                return id
            end
        end
    end

    local fallback = ItemType("brass helmet"):getId()
    return (fallback and fallback > 0) and fallback or 3354
end

local function findTrialByPortalAid(aid)
    for _, trial in ipairs(Z1.SET_TRIALS) do
        if trial.portalAid == aid then
            return trial
        end
    end
    return nil
end

local function getCostText(trial)
    local cost = trial.currencyCost or 0
    if cost <= 0 then
        return "free"
    end
    return cost .. " " .. (Z1.SET_CURRENCY_NAME or "gold ingot") .. (cost == 1 and "" or "s")
end

local function makeImmovable(item, uid)
    -- Items with a unique id cannot normally be moved/taken by players in Canary/TFS.
    -- This is cleaner than trying to use real quest rewards as floor decorations.
    if not item or not uid then
        return
    end

    if item.setAttribute then
        item:setAttribute(ITEM_ATTRIBUTE_UNIQUEID, uid)
    end
end

local function isZ1SetRoomAid(aid)
    if not aid or aid <= 0 then
        return false
    end

    if aid == Z1.SET_RETURN_AID then
        return true
    end

    if aid >= 8800 and aid <= 8899 then
        return true
    end

    if aid >= (Z1.SET_DISPLAY_AID_BASE or 9120) and aid <= ((Z1.SET_DISPLAY_AID_BASE or 9120) + 100) then
        return true
    end

    if aid >= (Z1.SET_SIGN_AID_BASE or 9140) and aid <= ((Z1.SET_SIGN_AID_BASE or 9140) + 100) then
        return true
    end

    for _, trial in ipairs(Z1.SET_TRIALS) do
        if aid == trial.portalAid then
            return true
        end
    end

    return false
end

local function shouldClearShowcaseItem(it)
    if not it then
        return false
    end

    local aid = it:getActionId()
    if isZ1SetRoomAid(aid) then
        return true
    end

    local id = it:getId()
    -- Remove old wrong portal/stair visual and the new portal visual if already present.
    if id == 1387 or id == 25051 or id == 25053 or id == 1947 then
        return true
    end

    return false
end

local function removeZ1ItemsAt(pos)
    local tile = Tile(pos)
    if not tile then
        return
    end

    local items = tile:getItems()
    if not items then
        return
    end

    for _, it in ipairs(items) do
        if shouldClearShowcaseItem(it) then
            it:remove()
        end
    end
end

local function isOldVerticalSetRoomItem(it)
    if not it then
        return false
    end

    local id = it:getId()
    if id == (Z1.SET_TRIAL_PORTAL_ITEMID or 1387) then
        return true
    end
    if id == (Z1.RETURN_PORTAL_ITEMID or 1387) then
        return true
    end
    if id == (Z1.SET_SIGN_ITEMID or 1947) then
        return true
    end

    local aid = it:getActionId()
    return isZ1SetRoomAid(aid)
end

local function clearOldVerticalSetRoomAt(pos)
    local tile = Tile(pos)
    if not tile then
        return
    end
    local items = tile:getItems()
    if not items then
        return
    end
    for _, it in ipairs(items) do
        if isOldVerticalSetRoomItem(it) then
            it:remove()
        end
    end
end

local function clearSetRoomArea()
    -- Clears only Z1-created items by action id in the new showcase room. It does not wipe your floor/walls.
    for x = Z1.SET_ROOM_TOP_LEFT.x, Z1.SET_ROOM_BOTTOM_RIGHT.x do
        for y = Z1.SET_ROOM_TOP_LEFT.y, Z1.SET_ROOM_BOTTOM_RIGHT.y do
            removeZ1ItemsAt(Position(x, y, Z1.SET_ROOM_TOP_LEFT.z))
        end
    end

    -- Aggressively clear older vertical test positions at x=32242, y=32170..32190.
    -- This removes old Z1 portals/signs but should not remove map floors.
    for y = 32170, 32190 do
        clearOldVerticalSetRoomAt(Position(32242, y, 8))
    end
end

local function createLabelSign(trial, index)
    if not trial.signPos then
        return
    end

    local sign = Game.createItem(Z1.SET_SIGN_ITEMID or 1947, 1, trial.signPos)
    if not sign then
        print("[Z1 Set Room] WARNING: could not create sign for " .. trial.name)
        return
    end

    sign:setActionId((Z1.SET_SIGN_AID_BASE or 9140) + index)
    makeImmovable(sign, (Z1.SET_SIGN_UID_BASE or 61100) + index)

    -- -- Build a rich description ----------------------------------
    local lines = {}
    local function add(s) lines[#lines+1] = s end

    add("[ " .. trial.name .. " ]")
    add("")
    add("Level required : " .. (trial.level or 0))
    add("Cost           : " .. getCostText(trial))
    add("")
    add("HOW TO CLAIM:")
    add("  Step on the portal in front of this sign.")
    add("  You must meet the level and cost requirements.")
    add("  Items are delivered instantly on claim.")
    add("")
    add("REWARDS:")
    local rewardCount = 0
    for _, reward in ipairs(trial.rewards or {}) do
        -- Resolve the item name for display.
        local displayName = nil
        if reward.name then
            displayName = reward.name
        elseif reward.names then
            displayName = reward.names[1]
        elseif reward.id and reward.id > 0 then
            local ok, t = pcall(ItemType, reward.id)
            if ok and t then
                local n = t:getName()
                displayName = (n and n ~= "") and n or ("item #" .. reward.id)
            end
        elseif reward.ids then
            local ok, t = pcall(ItemType, reward.ids[1])
            if ok and t then
                local n = t:getName()
                displayName = (n and n ~= "") and n or ("item #" .. reward.ids[1])
            end
        end
        if displayName then
            local countStr = (reward.count and reward.count > 1) and (" x" .. reward.count) or ""
            add("  * " .. displayName .. countStr)
            rewardCount = rewardCount + 1
        end
    end
    if rewardCount == 0 then
        add("  (see staff for details)")
    end

    local text = table.concat(lines, "\n")

    if sign.setAttribute then
        sign:setAttribute(ITEM_ATTRIBUTE_TEXT, text)
    end
end

local function createDisplayItem(trial, index)
    if not trial.displayPos then
        return
    end

    -- Paint only the ground under the equipment display. This preserves the rest of the black room/number floor.
    ensureGround(trial.displayPos, DISPLAY_FLOOR_ID)

    local displayId = resolveVisualItemId(trial)
    local display = Game.createItem(displayId, 1, trial.displayPos)
    if not display then
        print(string.format("[Z1 Set Room] WARNING: could not create display item %d for %s", displayId, trial.name))
        return
    end

    display:setActionId((Z1.SET_DISPLAY_AID_BASE or 9120) + index)
    makeImmovable(display, (Z1.SET_DISPLAY_UID_BASE or 61000) + index)

    local text = trial.name .. " display item. This is only a visual marker for the quest set. It cannot be taken."
    if display.setAttribute then
        display:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, text)
    end
end

local function createPortal(trial)
    local portal = Game.createItem(Z1.SET_TRIAL_PORTAL_ITEMID or 1387, 1, trial.portalPos)
    if not portal then
        print(string.format("[Z1 Set Room] ERROR: could not create portal for %s at %d,%d,%d",
            trial.name, trial.portalPos.x, trial.portalPos.y, trial.portalPos.z))
        return
    end

    portal:setActionId(trial.portalAid)
    makeImmovable(portal, (Z1.SET_PORTAL_UID_BASE or 61200) + (trial.portalAid - (Z1.SET_PORTAL_AID_BASE or 9100)))
    if portal.setAttribute then
        portal:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, trial.name .. " portal. Level " .. trial.level .. ". Cost: " .. getCostText(trial) .. ".")
    end
end

local function giveSet(player, trial)
    local given = 0

    for _, reward in ipairs(trial.rewards or {}) do
        local itemId = resolveItemId(reward)
        if itemId then
            player:addItem(itemId, reward.count or 1)
            given = given + 1
        else
            print("[Z1 Set Room] WARNING: no valid item found for reward in " .. trial.name .. " / " .. (reward.name or "unknown"))
        end
    end

    player:setStorageValue(trial.storage, 1)
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    msg(player, "You received the " .. trial.name .. " (" .. given .. " items).")
end

local function canClaim(player, trial)
    if player:getLevel() < trial.level then
        msg(player, "You need level " .. trial.level .. " to claim the " .. trial.name .. ".")
        return false
    end

    if player:getStorageValue(trial.storage) == 1 and Z1.ALLOW_SET_RECLAIM_TESTING == false then
        msg(player, "You already claimed the " .. trial.name .. ".")
        return false
    end

    local cost = trial.currencyCost or 0
    if cost > 0 and player:getItemCount(Z1.SET_CURRENCY_ID) < cost then
        msg(player, "You need " .. getCostText(trial) .. " to claim the " .. trial.name .. ".")
        return false
    end

    return true
end

local function payCost(player, trial)
    local cost = trial.currencyCost or 0
    if cost <= 0 then
        return true
    end
    return player:removeItem(Z1.SET_CURRENCY_ID, cost)
end

local setup = GlobalEvent("Z1TwoRowVisualSetRoomSetup")
function setup.onStartup()
    clearSetRoomArea()

    for index, trial in ipairs(Z1.SET_TRIALS) do
        createDisplayItem(trial, index)
        createLabelSign(trial, index)
        createPortal(trial)

        print(string.format("[Z1 Set Room] %s | display %d,%d,%d | sign %d,%d,%d | portal AID %d at %d,%d,%d | level %d | cost %s",
            trial.name,
            trial.displayPos.x, trial.displayPos.y, trial.displayPos.z,
            trial.signPos.x, trial.signPos.y, trial.signPos.z,
            trial.portalAid, trial.portalPos.x, trial.portalPos.y, trial.portalPos.z,
            trial.level, getCostText(trial)))
    end

    if Z1.CREATE_SET_RETURN_PORTALS then
        local ret = Game.createItem(Z1.RETURN_PORTAL_ITEMID or 1387, 1, Z1.SET_ROOM_RETURN_POS)
        if ret then
            ret:setActionId(Z1.SET_RETURN_AID)
            makeImmovable(ret, Z1.SET_RETURN_UID or 61299)
            if ret.setAttribute then
                ret:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Return to the main hub.")
            end
            print(string.format("[Z1 Set Room] Return portal AID %d at %d,%d,%d",
                Z1.SET_RETURN_AID, Z1.SET_ROOM_RETURN_POS.x, Z1.SET_ROOM_RETURN_POS.y, Z1.SET_ROOM_RETURN_POS.z))
        end
    end

    return true
end
setup:register()

local Z1_SET_MODAL_ID = 59100
local playerPendingSetClaim = {}

local function openSetClaimModal(player, trial)
	local modal = ModalWindow({
		title = trial.name,
		message =
			"Claim this equipment set?\n\n" ..
			"Required level: " .. trial.level .. "\n" ..
			"Cost: " .. getCostText(trial) .. "\n\n" ..
			"Rewards will be delivered instantly."
	})

	modal:addButton("Claim", function(button, choice)
		local guid = player:getGuid()
		local pendingAid = playerPendingSetClaim[guid]
		playerPendingSetClaim[guid] = nil

		if not pendingAid then
			return true
		end

		local pendingTrial = findTrialByPortalAid(pendingAid)
		if not pendingTrial then
			msg(player, "Set claim expired. Step on the portal again.")
			return true
		end

		if not canClaim(player, pendingTrial) then
			return true
		end

		if not payCost(player, pendingTrial) then
			msg(player, "Could not remove payment. Try again.")
			return true
		end

		giveSet(player, pendingTrial)
		return true
	end)

	modal:addButton("Cancel", function(button, choice)
		playerPendingSetClaim[player:getGuid()] = nil
		msg(player, "Set claim cancelled.")
		return true
	end)

	modal:setDefaultEnterButton("Claim")
	modal:setDefaultEscapeButton("Cancel")
	modal:sendToPlayer(player)
end

local portalMove = MoveEvent()

function portalMove.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if not item then
		return true
	end

	local aid = item:getActionId()

	if aid == Z1.SET_RETURN_AID then
		player:teleportTo(Z1.HUB_POS)
		Z1.HUB_POS:sendMagicEffect(CONST_ME_TELEPORT)
		return true
	end

	local trial = findTrialByPortalAid(aid)
	if not trial then
		msg(player, "This set portal is not configured.")
		player:teleportTo(fromPosition, true)
		return true
	end

	if not canClaim(player, trial) then
		player:teleportTo(fromPosition, true)
		return true
	end

	playerPendingSetClaim[player:getGuid()] = aid
	openSetClaimModal(player, trial)

	return true
end

portalMove:type("stepin")

for _, trial in ipairs(Z1.SET_TRIALS) do
	portalMove:position(trial.portalPos)
end

if Z1.CREATE_SET_RETURN_PORTALS then
	portalMove:position(Z1.SET_ROOM_RETURN_POS)
end

portalMove:register()

print("[Z1 Set Room] Two-row visual reward-only room loaded.")