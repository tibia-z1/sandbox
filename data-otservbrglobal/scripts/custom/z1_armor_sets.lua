-- data/scripts/custom/z1_armor_sets.lua
-- Z1 Armor Set Claim Chests v2
--
-- Players open a chest -> confirmation dialog appears showing:
--   * Set name, cost in gold ingots, items included.
--   * Confirm -> items delivered.   Cancel -> nothing happens.
--
-- Requires Z1ArmorConfirmModal registered on player at login.
-- z1_player_commands.lua (Z1PlayerLogin) handles this automatically.
--
-- Configuration lives in 00_z1_rift_config.lua -> Z1Rift.armorSets.
-- Level gate has been removed -- only ingot cost and tier prerequisites remain.
-- godz1 check

print("[Z1 Armor Sets] Loading v2 (chest + confirmation modal)...")

local function C()         return _G.Z1Rift or {} end
local function cfgItems()  return C().items    or {} end
local function cfgDebug()  return C().debug    or {} end
local function cfgSets()   return C().armorSets or {} end
local function cfgAids()   return C().aids     or {} end

local function msg(player, text)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[Armor Forge] " .. text)
end

local function safeStorage(player, key)
    if not key then return 0 end
    local v = player:getStorageValue(key)
    return (v == nil or v < 0) and 0 or v
end

-- Window IDs for the three armor confirmation modals.
local ARMOR_WINDOW = {
    z3 = 59020,
    z2 = 59021,
    z1 = 59022,
}
local WINDOW_TO_KEY = {}
for k, id in pairs(ARMOR_WINDOW) do WINDOW_TO_KEY[id] = k end

-- Storage key used to remember which set a player is about to confirm (per-session).
local STORAGE_PENDING_ARMOR = 592020

-- ---------------------------------------------
-- CLAIM LOGIC (runs after modal confirmation)
-- ---------------------------------------------

local function claimArmorSet(player, setKey)
    local sets      = cfgSets()
    local set       = sets[setKey]
    if not set then
        msg(player, "Armor set '" .. tostring(setKey) .. "' not configured. Contact staff.")
        return true
    end

    local debug       = cfgDebug()
    local allowRepeat = debug.allowMultipleArmorClaims == true
    local ingotId     = cfgItems().goldIngot or 9058

    -- Already claimed check.
    if not allowRepeat and safeStorage(player, set.storage) >= 1 then
        msg(player, "You already claimed the " .. set.label .. ". Contact staff if there is an issue.")
        return true
    end

    -- Prerequisite tier check (Z2 needs Z3 claimed, Z1 needs Z2 claimed).
    if setKey == "z2" then
        local z3 = sets.z3
        if z3 and not allowRepeat and safeStorage(player, z3.storage) < 1 then
            msg(player, "You must claim the Z3 Armor set first.")
            return true
        end
    elseif setKey == "z1" then
        local z2 = sets.z2
        if z2 and not allowRepeat and safeStorage(player, z2.storage) < 1 then
            msg(player, "You must claim the Z2 Armor set first.")
            return true
        end
    end

    -- Cost check.
    local cost = set.costIngots or 0
    if cost > 0 then
        local has = player:getItemCount(ingotId) or 0
        if has < cost then
            msg(player, "You need " .. cost .. " gold ingots. You have " .. has .. ".")
            return true
        end
    end

    -- Take payment.
    if cost > 0 and not player:removeItem(ingotId, cost) then
        msg(player, "Could not remove gold ingots. Contact staff.")
        return true
    end

    -- Give items.
    local given = 0
    for _, entry in ipairs(set.items or {}) do
        if entry.id and entry.id > 0 then
            player:addItem(entry.id, entry.count or 1)
            given = given + 1
        end
    end

    -- Mark as claimed.
    if not allowRepeat then
        player:setStorageValue(set.storage, 1)
    end

    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    msg(player, "You received the " .. set.label .. " (" .. given .. " piece(s)). " ..
        (cost > 0 and cost .. " gold ingots consumed." or ""))
    Game.broadcastMessage(
        player:getName() .. " has claimed the " .. set.label .. " from the Armor Forge!",
        MESSAGE_EVENT_ADVANCE)
    return true
end

-- ---------------------------------------------
-- CONFIRMATION MODAL
-- ---------------------------------------------

local function showArmorConfirmModal(player, setKey)
    local sets  = cfgSets()
    local set   = sets[setKey]
    if not set then
        msg(player, "Armor set not configured. Contact staff.")
        return
    end

    local debug       = cfgDebug()
    local allowRepeat = debug.allowMultipleArmorClaims == true
    local ingotId     = cfgItems().goldIngot or 9058

    -- Pre-checks before even showing the modal.
    if not allowRepeat and safeStorage(player, set.storage) >= 1 then
        msg(player, "You already claimed the " .. set.label .. ".")
        return
    end
    if setKey == "z2" then
        local z3 = sets.z3
        if z3 and not allowRepeat and safeStorage(player, z3.storage) < 1 then
            msg(player, "You must claim the Z3 Armor set first.")
            return
        end
    elseif setKey == "z1" then
        local z2 = sets.z2
        if z2 and not allowRepeat and safeStorage(player, z2.storage) < 1 then
            msg(player, "You must claim the Z2 Armor set first.")
            return
        end
    end

    local cost = set.costIngots or 0
    local has  = player:getItemCount(ingotId) or 0

    -- Build item list text.
    local itemLines = {}
    for _, entry in ipairs(set.items or {}) do
        if entry.id and entry.id > 0 then
            local ok, t = pcall(ItemType, entry.id)
            local name = (ok and t and t:getName() ~= "") and t:getName() or ("item " .. entry.id)
            itemLines[#itemLines+1] = "  * " .. name .. (entry.count and entry.count > 1 and " x" .. entry.count or "")
        end
    end

    local body = set.label .. "\n\n" ..
        "Items you will receive:\n" ..
        table.concat(itemLines, "\n") .. "\n\n" ..
        "Cost: " .. cost .. " gold ingots\n" ..
        "You have: " .. has .. " gold ingots\n\n" ..
        (has < cost and "Not enough gold ingots!" or "Ready to claim -- press Confirm.")

    -- Save pending set so the modal response knows which set to claim.
    player:setStorageValue(STORAGE_PENDING_ARMOR, ARMOR_WINDOW[setKey] or 0)

    local window = ModalWindow(
        ARMOR_WINDOW[setKey],
        set.label .. " -- Confirm Claim",
        body
    )
    window:addButton(1, "Confirm")
    window:addButton(0, "Cancel")
    window:setDefaultEnterButton(1)
    window:setDefaultEscapeButton(0)
    window:sendToPlayer(player)
end

-- ---------------------------------------------
-- MODAL RESPONSE EVENT
-- ---------------------------------------------

local armorModalEv = CreatureEvent("Z1ArmorConfirmModal")
armorModalEv:type("modalwindow")
armorModalEv:onModalWindow(function(player, windowId, buttonId, choiceId)
    local setKey = WINDOW_TO_KEY[windowId]
    if not setKey then return true end  -- not our window

    player:setStorageValue(STORAGE_PENDING_ARMOR, 0)

    if buttonId == 0 then
        msg(player, "Armor claim cancelled.")
        return true
    end

    claimArmorSet(player, setKey)
    return true
end)
armorModalEv:register()

-- ---------------------------------------------
-- CHEST ACTION REGISTRATION
-- ---------------------------------------------

local function registerArmorChest(aid, setKey)
    local act = Action()
    function act.onUse(player, item, fromPos, target, toPos, isHotkey)
        showArmorConfirmModal(player, setKey)
        return true
    end
    act:aid(aid)
    act:register()
end

local aids = (_G.Z1Rift or {}).aids or {}
registerArmorChest(aids.armorZ3 or 11480, "z3")
registerArmorChest(aids.armorZ2 or 11481, "z2")
registerArmorChest(aids.armorZ1 or 11482, "z1")


print("[Z1 Armor Sets] v2 loaded. Chests: armorZ3=" .. (aids.armorZ3 or 11480) ..
    " armorZ2=" .. (aids.armorZ2 or 11481) .. " armorZ1=" .. (aids.armorZ1 or 11482) ..
    ". Modal IDs: z3=" .. ARMOR_WINDOW.z3 .. " z2=" .. ARMOR_WINDOW.z2 .. " z1=" .. ARMOR_WINDOW.z1 .. ".")
