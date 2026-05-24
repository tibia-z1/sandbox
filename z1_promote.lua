-- z1_promote.lua
-- Simple gold-ingot promotion command.
-- Put in: data/scripts/custom/

local CONFIG = {
    cost = 2,
    currencyName = "gold ingot",
    currencyFallbackId = 9058,
    freeForGod = true,
    dialogItemId = 3059,
}

local PROMOTIONS = {
    [1] = { id = 5, name = "Master Sorcerer" },
    [2] = { id = 6, name = "Elder Druid" },
    [3] = { id = 7, name = "Royal Paladin" },
    [4] = { id = 8, name = "Elite Knight" },
}

local function getCurrencyId()
    local id = 0
    local ok, result = pcall(function()
        return ItemType(CONFIG.currencyName):getId()
    end)
    if ok and result and result > 0 then
        id = result
    else
        id = CONFIG.currencyFallbackId
    end
    return id
end

local function isGod(player)
    local group = player:getGroup()
    if not group then return false end
    return group:getId() >= 4
end

local promote = TalkAction("!promotion")
function promote.onSay(player, words, param)
    local vocation = player:getVocation()
    local vocationId = vocation:getId()
    local promo = PROMOTIONS[vocationId]

    if not promo then
        player:sendCancelMessage("You are already promoted or your vocation cannot be promoted with this command.")
        return true
    end

    local currencyId = getCurrencyId()
    local free = CONFIG.freeForGod and isGod(player)

    if not free then
        if player:getItemCount(currencyId) < CONFIG.cost then
            player:sendCancelMessage("You need " .. CONFIG.cost .. " gold ingots to become a " .. promo.name .. ".")
            return true
        end
        player:removeItem(currencyId, CONFIG.cost)
    end

    local newVocation = Vocation(promo.id)
    if not newVocation then
        player:sendCancelMessage("Promotion vocation ID " .. promo.id .. " was not found. Check vocations.xml.")
        return true
    end

    player:setVocation(newVocation)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are now a " .. promo.name .. "." .. (free and " No gold ingots were consumed because you are staff." or " Cost: " .. CONFIG.cost .. " gold ingots."))
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    player:save()
    return true
end

promote:setDescription("promotes your vocation by consuming gold ingots. Example: !promotion")
promote:groupType("normal")
promote:register()

print("[Z1 Promote] Gold ingot promotion command loaded.")
