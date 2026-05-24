print("Zero1Labs Daily Chest System loaded")

local DAILY_CHEST_UID = 9701
local DAILY_CHEST_AID = 9701
local DAILY_CHEST_POS = Position(1063, 1027, 7)
local DAILY_COOLDOWN_SECONDS = 300 -- 5 minutes for testing

local function setupDailyChest()
    local tile = Tile(DAILY_CHEST_POS)
    if not tile then
        print("[Zero1Labs Daily Chest] Missing tile at " .. DAILY_CHEST_POS.x .. "," .. DAILY_CHEST_POS.y .. "," .. DAILY_CHEST_POS.z)
        return
    end

    local chest = tile:getTopDownItem()
    if chest then
        chest:setAttribute(ITEM_ATTRIBUTE_UNIQUEID, DAILY_CHEST_UID)
        chest:setActionId(DAILY_CHEST_AID)
        chest:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Daily reward chest")
    else
        print("[Zero1Labs Daily Chest] No chest found at daily chest position.")
    end
end

local startup = GlobalEvent("Zero1LabsDailyChestStartup")

function startup.onStartup()
    setupDailyChest()
    return true
end

startup:register()

local function giveRewardItem(player, itemId, count)
    local item = player:addItem(itemId, count)

    if not item then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Reward error: item ID " .. itemId .. " could not be added.")
        return false
    end

    return true
end

local dailyChest = Action()

function dailyChest.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local storage = 970100
    local now = os.time()
    local nextClaim = player:getStorageValue(storage)

    if nextClaim > now then
        local remaining = nextClaim - now
        local minutes = math.floor(remaining / 60)
        local seconds = remaining % 60
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You can claim again in " .. minutes .. "m " .. seconds .. "s.")
        return true
    end

    -- OR logic: player gets ONLY ONE random reward.
    local rewards = {
        { text = "50 crystal coins", id = 3043, count = 50 },
        { text = "2 gold ingots", id = 9058, count = 2 },		
        { text = "15 Tibia Coins", id = 22118, count = 15 },
        { text = "Lasting Exercise Sword", id = 35285, count = 14400 },
        { text = "Lasting Exercise Bow", id = 35288, count = 14400 },
        { text = "Lasting Exercise Wand", id = 35290, count = 14400 },
		{ text = "Lasting Exercise Rod", id = 35289, count = 14400 },
        { text = "Lasting Exercise Shield", id = 44067, count = 14400 },
		{ text = "Primal Bag", id = 39546, count = 1 },
		{ text = "Bag you Desire", id = 34109, count = 1 },
    }

    local reward = rewards[math.random(#rewards)]

    if not giveRewardItem(player, reward.id, reward.count) then
        return true
    end

    player:setStorageValue(storage, now + DAILY_COOLDOWN_SECONDS)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Daily reward claimed: " .. reward.text .. ".")
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    return true
end

dailyChest:uid(DAILY_CHEST_UID)
dailyChest:register()