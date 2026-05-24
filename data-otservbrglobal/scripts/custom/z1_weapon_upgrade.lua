-- data/scripts/custom/z1_weapon_upgrade.lua
-- Z1 Rift Forge v12
-- Weapon selection by vocation.
--
--  Knight (4/8)  -> ModalWindow: Blade / Slayer / Axe / Chopper / Mace / Hammer (6 choices)
--  Paladin (3/7) -> ModalWindow: Bow / Crossbow (2 choices)
--  Sorcerer (1/5)-> Wand automatically (index 9)
--  Druid (2/6)   -> Rod automatically  (index 10)
--  No vocation   -> Blade (default, index 1)
--
-- Weapon type index (matches zWeapons tables in 00_z1_rift_config.lua):
--   1=Blade  2=Slayer  3=Axe  4=Chopper  5=Mace  6=Hammer
--   7=Bow    8=Crossbow  9=Wand  10=Rod
--
-- login.lua: player:registerEvent("Z1WeaponSelectModal")
-- (Z1PlayerLogin already handles this)
--
-- VOCATION IDs (this server):
--   1 = Knight        5 = Elite Knight
--   2 = Paladin       6 = Royal Paladin
--   3 = Sorcerer      7 = Master Sorcerer
--   4 = Druid         8 = Elder Druid

print("[Z1 Weapon Upgrade] Loading v13 (correct vocation IDs)...")

local BOOK_ID = 639
local function C()          return _G.Z1Rift or {} end
local function cfgItems()   return C().items    or {} end
local function cfgForge()   return C().forge    or {} end
local function cfgStorages()return C().storages or {} end
local function cfgDebug()   return C().debug    or {} end

local function msg(player, text)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[Rift Forge] " .. text)
end

local function safeStorage(player, key)
    if not player or not key then return 0 end
    local v = player:getStorageValue(key)
    return (v == nil or v < 0) and 0 or v
end

local function isStaff(player)
    local g = player and player:getGroup()
    return g and g:getId() >= 3
end

local function getVocId(player)
    local voc = player and player:getVocation()
    return voc and voc:getId() or 0
end

-- 1=Sorc  2=Druid  3=Paladin  4=Knight  5=MSorc  6=EDruid  7=RPal  8=EKnight
local function isKnight(player)  local v=getVocId(player) return v==4 or v==8 end
local function isPaladin(player) local v=getVocId(player) return v==3 or v==7 end
local function isSorc(player)    local v=getVocId(player) return v==1 or v==5 end
local function isDruid(player)   local v=getVocId(player) return v==2 or v==6 end

local function itemName(id)
    local ok, t = pcall(ItemType, id)
    if ok and t then local n=t:getName(); if n and n~="" then return n end end
    return "item " .. tostring(id or "?")
end

-- =========================================================
-- Z TIER WEAPON ID TABLES
-- Position (index) paired across tiers: Z1[i] <-> Z2[i] <-> Z3[i]
-- 1=Blade  2=Slayer  3=Axe  4=Chopper  5=Mace  6=Hammer
-- 7=Bow    8=Crossbow  9=Wand  10=Rod
-- =========================================================

local Z3 = {26044,26047,26050,26053,26056,26059,26062,26065,26068,26071}
local Z2 = {25984,25987,25990,25993,25996,25999,26002,26005,26008,26011}
local Z1 = {26016,26019,26022,26025,26028,26031,26034,26037,26040,26043}

-- Human-readable type label per index (for info messages)
local TYPE_LABEL = {
    "Blade", "Slayer", "Axe", "Chopper", "Mace", "Hammer",
    "Bow", "Crossbow", "Wand", "Rod"
}

-- Vocation default Z3 index (auto-assigned, no player choice for mages/default).
-- Knights and Paladins get nil here -- they go through a modal window.
-- 1=Sorc  2=Druid  3=Paladin  4=Knight  5=MSorc  6=EDruid  7=RPal  8=EKnight
local VOC_Z3_INDEX = {
    [0] = 1,              -- no vocation       -> Blade
    [4] = nil, [8] = nil, -- Knight / EKnight  -> modal (6 weapon types)
    [3] = nil, [7] = nil, -- Paladin / RPal    -> modal (Bow / Crossbow)
    [1] = 9,  [5] = 9,   -- Sorcerer / MSorc  -> Wand (auto)
    [2] = 10, [6] = 10,  -- Druid / EDruid    -> Rod  (auto)
}

-- -- KNIGHT MODAL: 6 weapon type choices -------------------
local KNIGHT_CHOICES = {
    [1] = { idx=1, label="Blade   (1H Sword)  -- balanced, shield-compatible" },
    [2] = { idx=2, label="Slayer  (2H Sword)  -- high damage, no shield"      },
    [3] = { idx=3, label="Axe     (1H Axe)    -- aggressive strikes"          },
    [4] = { idx=4, label="Chopper (2H Axe)    -- heavy offensive power"       },
    [5] = { idx=5, label="Mace    (1H Club)   -- solid, shield-compatible"    },
    [6] = { idx=6, label="Hammer  (2H Club)   -- slow but devastating"        },
}

-- -- PALADIN MODAL: 2 ranged weapon choices -----------------
local PALADIN_CHOICES = {
    [1] = { idx=7, label="Bow       -- faster attack speed, versatile"        },
    [2] = { idx=8, label="Crossbow  -- heavier bolts, powerful single shots"  },
}

local WEAPON_SELECT_WINDOW   = 59010  -- knight modal
local PALADIN_MODAL_WINDOW   = 59011  -- paladin modal
local STORAGE_PENDING_SELECT = 592010
local STORAGE_VOC_AT_CLAIM   = 592011  -- saves voc during modal

-- =========================================================
-- WEAPON SCAN
-- =========================================================

local function buildTierMap()
    local m, idxm = {}, {}
    for i,id in ipairs(Z3) do m[id]=3 idxm[id]=i end
    for i,id in ipairs(Z2) do m[id]=2 idxm[id]=i end
    for i,id in ipairs(Z1) do m[id]=1 idxm[id]=i end
    return m, idxm
end
local TIER_MAP, IDX_MAP = buildTierMap()

local function scanZWeapons(player)
    local found = {[1]={}, [2]={}, [3]={}}
    local function add(item)
        if not item then return end
        local id=item:getId(); local tier=TIER_MAP[id]; local idx=IDX_MAP[id]
        if tier and idx then found[tier][#found[tier]+1]={item=item,id=id,tier=tier,index=idx} end
    end
    add(player:getSlotItem(CONST_SLOT_RIGHT))
    add(player:getSlotItem(CONST_SLOT_LEFT))
    local bp = player:getSlotItem(CONST_SLOT_BACKPACK)
    if bp and bp:isContainer() then
        for i=0, math.min((bp:getSize() or 0)-1, 100) do
            local c=bp:getItem(i); add(c)
            if c and c:isContainer() then
                for j=0, math.min((c:getSize() or 0)-1, 100) do add(c:getItem(j)) end
            end
        end
    end
    return found
end

local function getBestTier(player)
    local f=scanZWeapons(player)
    if #f[1]>0 then return 1 end
    if #f[2]>0 then return 2 end
    if #f[3]>0 then return 3 end
    return 0
end

local function getFirstWeaponOfTier(player, tier)
    local f=scanZWeapons(player); return f[tier] and f[tier][1] or nil
end

local function playerHasAnyZWeapon(player)
    local f=scanZWeapons(player); return (#f[1]+#f[2]+#f[3]) > 0
end

-- =========================================================
-- PAYMENT
-- =========================================================

local function canPay(player, ingots, riftmarks)
    local items=cfgItems(); local ingotId=items.goldIngot or 9058; local riftId=items.fieryTear or 3958
    local hi=player:getItemCount(ingotId) or 0; local hr=player:getItemCount(riftId) or 0
    if hi<ingots then return false,"Need "..ingots.." gold ingots. Have "..hi.."." end
    if (riftmarks or 0)>0 and hr<riftmarks then return false,"Need "..riftmarks.." fiery tear(s). Have "..hr.."." end
    return true
end

local function takePayment(player, ingots, riftmarks)
    local items=cfgItems(); local ingotId=items.goldIngot or 9058; local riftId=items.fieryTear or 3958
    if (ingots or 0)>0 and not player:removeItem(ingotId,ingots) then return false end
    if (riftmarks or 0)>0 and not player:removeItem(riftId,riftmarks) then
        if (ingots or 0)>0 then player:addItem(ingotId,ingots) end
        return false
    end
    return true
end

-- =========================================================
-- GIVE Z3 -- called after choice is confirmed (modal or auto)
-- =========================================================

local function giveZ3ByIndex(player, z3Index)
    local cost    = cfgForge().claimZ3CostIngots or 25
    local storages = cfgStorages()
    local claimKey = storages.claimedZ3Starter or 592001
    local debug    = cfgDebug()

    if not takePayment(player, cost, 0) then
        msg(player, "Could not remove payment. Contact staff.") return
    end

    local weaponId = Z3[z3Index] or Z3[1]
    player:addItem(weaponId, 1)

    if not debug.allowMultipleZ3StarterClaims then
        player:setStorageValue(claimKey, 1)
    end

    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    msg(player, "Received Z3 " .. (TYPE_LABEL[z3Index] or "Weapon") .. ": " ..
        itemName(weaponId) .. ". " .. cost .. " ingots consumed.")
    Game.broadcastMessage(player:getName() .. " has claimed their first Z weapon from the Rift Forge!", MESSAGE_EVENT_ADVANCE)
end

-- =========================================================
-- SHOW MODALS
-- =========================================================

local function showKnightModal(player)
    if safeStorage(player, STORAGE_PENDING_SELECT) >= 1 then
        msg(player, "Weapon selection already open. Check your UI.") return
    end

    player:setStorageValue(STORAGE_VOC_AT_CLAIM, getVocId(player))
    player:setStorageValue(STORAGE_PENDING_SELECT, 1)

    local window = ModalWindow(
        WEAPON_SELECT_WINDOW,
        "Z3 Weapon -- Choose Your Style (Knight)",
        "You are a Knight. Choose the weapon type\n" ..
        "that best matches your fighting style.\n\n" ..
        "1H weapons allow you to equip a shield.\n" ..
        "2H weapons deal more raw damage but leave\n" ..
        "you without a shield slot.\n\n" ..
        "Your choice is permanent for this claim."
    )
    for i, ch in ipairs(KNIGHT_CHOICES) do
        window:addChoice(i, ch.label)
    end
    window:addButton(1, "Confirm")
    window:addButton(0, "Cancel")
    window:setDefaultEnterButton(1)
    window:setDefaultEscapeButton(0)
    window:sendToPlayer(player)
end

local function showPaladinModal(player)
    if safeStorage(player, STORAGE_PENDING_SELECT) >= 1 then
        msg(player, "Weapon selection already open. Check your UI.") return
    end

    player:setStorageValue(STORAGE_VOC_AT_CLAIM, getVocId(player))
    player:setStorageValue(STORAGE_PENDING_SELECT, 1)

    local window = ModalWindow(
        PALADIN_MODAL_WINDOW,
        "Z3 Weapon -- Choose Your Ranged Style (Paladin)",
        "You are a Paladin. Choose your ranged weapon.\n\n" ..
        "Both scale with your Distance Fighting skill.\n" ..
        "Bow fires faster.\n" ..
        "Crossbow hits harder per shot.\n\n" ..
        "Your choice is permanent for this claim."
    )
    for i, ch in ipairs(PALADIN_CHOICES) do
        window:addChoice(i, ch.label)
    end
    window:addButton(1, "Confirm")
    window:addButton(0, "Cancel")
    window:setDefaultEnterButton(1)
    window:setDefaultEscapeButton(0)
    window:sendToPlayer(player)
end

-- =========================================================
-- MODAL RESPONSE -- handles both Knight and Paladin windows
-- =========================================================

local modalEv = CreatureEvent("Z1WeaponSelectModal")
modalEv:type("modalwindow")
modalEv:onModalWindow(function(player, windowId, buttonId, choiceId)
    if windowId ~= WEAPON_SELECT_WINDOW and windowId ~= PALADIN_MODAL_WINDOW then
        return true
    end

    player:setStorageValue(STORAGE_PENDING_SELECT, 0)
    player:setStorageValue(STORAGE_VOC_AT_CLAIM, 0)

    if buttonId == 0 or not choiceId or choiceId == 0 then
        msg(player, "Weapon selection cancelled. Your kills are still counted -- return to claim anytime.")
        return true
    end

    if windowId == WEAPON_SELECT_WINDOW then
        local ch = KNIGHT_CHOICES[choiceId]
        if not ch then msg(player, "Invalid choice. Please try again.") return true end
        giveZ3ByIndex(player, ch.idx)

    elseif windowId == PALADIN_MODAL_WINDOW then
        local ch = PALADIN_CHOICES[choiceId]
        if not ch then msg(player, "Invalid choice. Please try again.") return true end
        giveZ3ByIndex(player, ch.idx)
    end

    return true
end)
modalEv:register()

-- =========================================================
-- CLAIM Z3 (entry point)
-- =========================================================

local function claimZ3(player)
    local forge    = cfgForge()
    local storages = cfgStorages()
    local debug    = cfgDebug()
    local claimKey = storages.claimedZ3Starter or 592001

    if not debug.allowMultipleZ3StarterClaims and safeStorage(player, claimKey) >= 1 then
        msg(player, "You already claimed your Z3 starter. Contact staff for issues.") return true
    end
    if not debug.allowMultipleZ3StarterClaims and playerHasAnyZWeapon(player) then
        msg(player, "You already carry Z-tier gear. Use the upgrade gates to improve it.") return true
    end

    local kills    = safeStorage(player, storages.morshabaalKills or 591001)
    local required = forge.morshabaalKillsRequired or 5
    if not isStaff(player) and kills < required then
        msg(player, "Need " .. required .. " Morshabaal kills. Current: " .. kills .. ".") return true
    end

    local cost = forge.claimZ3CostIngots or 25
    local ok, reason = canPay(player, cost, 0)
    if not ok then msg(player, reason) return true end

    local vocId = getVocId(player)

    -- Paladin: bow/crossbow modal
    if isPaladin(player) then
        msg(player, "Paladins choose their ranged weapon. A selection window is opening...")
        showPaladinModal(player)
        return true
    end

    -- Knight: 6-type weapon modal
    if isKnight(player) then
        msg(player, "Knights choose their weapon type. A selection window is opening...")
        showKnightModal(player)
        return true
    end

    -- Sorcerer / Druid / default: auto-assigned by vocation index
    local autoIndex = VOC_Z3_INDEX[vocId] or 1
    local vocLabel  = isSorc(player) and "Sorcerer" or isDruid(player) and "Druid" or "Adventurer"
    msg(player, vocLabel .. "s receive a " .. (TYPE_LABEL[autoIndex] or "Rift") .. " weapon automatically...")
    giveZ3ByIndex(player, autoIndex)
    return true
end

-- =========================================================
-- UPGRADE Z3->Z2 and Z2->Z1 (preserves weapon type/index)
-- =========================================================

local function upgradeExactTier(player, fromTier)
    if fromTier == 1 then msg(player, "Z1 is already the maximum tier.") return true end
    local found = getFirstWeaponOfTier(player, fromTier)
    if not found then msg(player, "No Z" .. fromTier .. " weapon found to upgrade.") return true end

    local nextList = fromTier == 3 and Z2 or Z1
    local newId    = nextList[found.index]
    if not newId then msg(player, "Matching upgrade item not found. Contact staff.") return true end

    local forge    = cfgForge()
    local ingots, riftmarks
    if fromTier == 3 then
        ingots    = forge.upgradeZ3ToZ2CostIngots    or 75
        riftmarks = forge.upgradeZ3ToZ2CostRiftmarks or 1
    else
        ingots    = forge.upgradeZ2ToZ1CostIngots    or 150
        riftmarks = forge.upgradeZ2ToZ1CostRiftmarks or 3
    end

    local ok, reason = canPay(player, ingots, riftmarks)
    if not ok then msg(player, reason) return true end
    if not takePayment(player, ingots, riftmarks) then msg(player, "Could not remove payment.") return true end

    local oldName = itemName(found.id)
    found.item:remove()
    player:addItem(newId, 1)
    msg(player, oldName .. " -> " .. itemName(newId) .. ". Payment consumed.")
    player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
    return true
end

-- =========================================================
-- AUTO-FORGE (anvil action)
-- =========================================================

local function autoForge(player)
    local best = getBestTier(player)
    if best == 0 then return claimZ3(player) end
    if best == 3 then return upgradeExactTier(player, 3) end
    if best == 2 then return upgradeExactTier(player, 2) end
    msg(player, "Z1 is already the maximum tier.")
    return true
end

local function infoText(player)
    local forge    = cfgForge()
    local storages = cfgStorages()
    local kills    = safeStorage(player, storages.morshabaalKills or 591001)
    local best     = getBestTier(player)
    local voc      = player:getVocation()
    local vocName  = (voc and voc:getName()) or "unknown"
    return table.concat({
        "[ Rift Forge ]", "",
        "Vocation        : " .. vocName,
        "Morshabaal kills: " .. kills .. " / " .. (forge.morshabaalKillsRequired or 5),
        "Best Z weapon   : " .. (best==0 and "none" or ("Z"..best)), "",
        "COSTS",
        "Z3 starter : " .. (forge.claimZ3CostIngots or 25) .. " gold ingots",
        "Z3 -> Z2    : " .. (forge.upgradeZ3ToZ2CostIngots or 75) ..
            " ingots + " .. (forge.upgradeZ3ToZ2CostRiftmarks or 1) .. " fiery tear",
        "Z2 -> Z1    : " .. (forge.upgradeZ2ToZ1CostIngots or 150) ..
            " ingots + " .. (forge.upgradeZ2ToZ1CostRiftmarks or 3) .. " fiery tears", "",
        "WEAPON ASSIGNMENT",
        "Knights  : Choose Blade / Slayer / Axe / Chopper / Mace / Hammer",
        "Paladins : Choose Bow or Crossbow",
        "Sorcerers: Wand (auto-assigned)",
        "Druids   : Rod  (auto-assigned)",
    }, "\n")
end

-- =========================================================
-- EVENTS
-- =========================================================

local forgeAction = Action()
function forgeAction.onUse(player, item, fromPos, target, toPos, isHotkey)
    return autoForge(player)
end
local a = C().aids or {}
forgeAction:aid(a.forge or 11465)
forgeAction:aid(77001)
forgeAction:register()

-- -- WEAPON CHEST ACTIONS --------------------------------------
-- Opening a weapon chest:
--   1. Refreshes the weapon display to match THIS player's vocation (immediate feedback).
--   2. Runs the claim/upgrade logic -- Knight & Paladin get a choice modal, Sorc/Druid auto.
-- No stepin teleport needed -- player opens the chest intentionally.

local function registerChest(aid, mode)
    local act = Action()
    function act.onUse(player, item, fromPos, target, toPos, isHotkey)
        -- Refresh weapon display for the player opening the chest.
        if _G.Z1UpdateWeaponDisplays then
            _G.Z1UpdateWeaponDisplays(player)
        end
        -- Run claim / upgrade.
        if mode == "z3" then
            claimZ3(player)
        elseif mode == "z2" then
            upgradeExactTier(player, 3)
        elseif mode == "z1" then
            upgradeExactTier(player, 2)
        end
        return true
    end
    act:aid(aid)
    act:register()
end

registerChest(a.gateZ3 or 11466, "z3")
registerChest(a.gateZ2 or 11467, "z2")
registerChest(a.gateZ1 or 11468, "z1")
registerChest(77002, "z3")
registerChest(77003, "z2")
registerChest(77004, "z1")

local forgeCmd = TalkAction("!forge")
function forgeCmd.onSay(player, words, param)
    player:showTextDialog(BOOK_ID, infoText(player))
    return true
end
forgeCmd:setDescription("Z forge progress, Morshabaal kills, costs.")
forgeCmd:groupType("normal")
forgeCmd:register()

print("[Z1 Weapon Upgrade] v13 loaded. Knight(4/8): 6-type modal. Paladin(3/7): Bow/Crossbow modal. Sorc(1/5)+Druid(2/6): auto-assigned.")
