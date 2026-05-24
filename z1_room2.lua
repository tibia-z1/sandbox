-- data/scripts/custom/z1_room2.lua
-- Z1 Room 2 v12: Chest-based weapon & armor claim with choice dialogs.
--
-- Top row    (display→sign→chest): Z3 / Z2 / Z1 weapon claim.
--   • Display items transform to the using player's vocation weapon on CHEST OPEN.
--     Sorcerer → Wand | Druid → Rod | Paladin → Bow | Knight → Blade (display only)
--   • Opening a weapon chest updates the display THEN opens the choice dialog:
--       Knight  → modal: Blade/Slayer/Axe/Chopper/Mace/Hammer (1H and 2H)
--       Paladin → modal: Bow or Crossbow
--       Sorc/Druid → auto-assigned (Wand/Rod), no choice needed
-- Center     : Rift Forge (anvil) — fallback path.
-- Bottom row (chest→sign→display): Z3 / Z2 / Z1 armor set claim.
--   • Opening an armor chest shows a confirmation dialog with cost before claiming.
--
-- Vocation IDs: 1=Sorc  2=Druid  3=Paladin  4=Knight  (+4 promotions)
--
-- Export: _G.Z1UpdateWeaponDisplays(player) — call from any script to refresh displays.

print("[Z1 Room2] Loading v12 (chest-based claim + voc display)...")

local function C()  return _G.Z1Rift or {} end
local function itemId(name, fallback)
    local ok, t = pcall(ItemType, name)
    if ok and t then local id = t:getId(); if id and id > 0 then return id end end
    return fallback
end

local BLACK_FLOOR    = 410
local WHITE_FLOOR    = 409
local MARBLE_FLOOR   = 10986
local CHEST_WEAPON   = 19250   -- reward chest (container=32) for weapon claim chests
local CHEST_ARMOR    = 29433   -- chest (container=15) for armor claim chests
local ANVIL          = 35185
local SIGN           = 2017

-- ---------------------------------------------
-- HELPERS
-- ---------------------------------------------

local function msg(player, text)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[Rift Room] " .. text)
end

local function ensureTile(pos)
    if not pos then return nil end
    if not Tile(pos) then Game.createTile(pos, true) end
    return Tile(pos)
end

local function setGround(pos, id)
    local tile = ensureTile(pos)
    if not tile then return end
    local ground = tile:getGround()
    if ground then
        if ground:getId() ~= id then ground:transform(id) end
    else
        Game.createItem(id, 1, pos)
    end
end

local function cleanTopItems(pos)
    local tile = Tile(pos)
    if not tile then return end
    local items = tile:getItems()
    if not items then return end
    for i = #items, 1, -1 do
        local it = items[i]
        if it then
            local aid = it:getActionId()
            local id  = it:getId()
            if (aid and aid >= 11460 and aid <= 11600) or
               (aid and aid >= 77001 and aid <= 77100) or
               id == CHEST_WEAPON or id == CHEST_ARMOR or
               id == 25051 or  -- old portal, clean up if still present
               id == ANVIL or id == SIGN or id == 1947 or id == 35185 then
                it:remove()
            end
        end
    end
end

local function fillRoom()
    local p = C().room2 or {}
    if not p.from or not p.to then return end
    for x = math.min(p.from.x, p.to.x), math.max(p.from.x, p.to.x) do
        for y = math.min(p.from.y, p.to.y), math.max(p.from.y, p.to.y) do
            local pos = Position(x, y, p.from.z)
            setGround(pos, BLACK_FLOOR)
            cleanTopItems(pos)
        end
    end
    -- Marble "2" floor accent underneath the room.
    local coords = {
        {32270,32199}, {32271,32199}, {32272,32199},
        {32272,32200}, {32272,32201},
        {32270,32201}, {32271,32201}, {32272,32201},
        {32270,32202}, {32270,32203},
        {32271,32203}, {32272,32203},
    }
    for _, c in ipairs(coords) do setGround(Position(c[1], c[2], 8), MARBLE_FLOOR) end
end

local function setUnique(it, uid)
    if not it or not uid then return end
    pcall(function() it:setAttribute(ITEM_ATTRIBUTE_UNIQUEID, uid) end)
end

local function place(id, pos, aid, desc, uid)
    if not pos then return nil end
    ensureTile(pos)
    local it = Game.createItem(id, 1, pos)
    if not it then return nil end
    if aid  then it:setAttribute(ITEM_ATTRIBUTE_ACTIONID, aid) end
    if desc then
        it:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, desc)
        if id == SIGN then it:setAttribute(ITEM_ATTRIBUTE_TEXT, desc) end
    end
    setUnique(it, uid)
    return it
end

local function placeDisplay(id, pos, desc, uid)
    if not pos then return nil end
    setGround(pos, WHITE_FLOOR)
    return place(id, pos, nil, desc, uid)
end

-- ---------------------------------------------
-- VOCATION-AWARE WEAPON DISPLAY
-- ---------------------------------------------

-- Returns (z3Id, z2Id, z1Id) — the display weapon for each tier matching this vocation.
-- Paladin shows Bow (index 7). Knight shows Blade (index 1). Sorc→Wand(9). Druid→Rod(10).
-- Indices are set in 00_z1_rift_config.lua vocWeaponIndex.
local function getVocWeaponIds(player)
    local r    = C()
    local zw   = r.zWeapons or {}
    local z3w  = zw.z3 or {}
    local z2w  = zw.z2 or {}
    local z1w  = zw.z1 or {}
    local vocId = player:getVocation():getId()

    local idx = (r.vocWeaponIndex or {})[vocId] or 1
    return z3w[idx] or z3w[1],
           z2w[idx] or z2w[1],
           z1w[idx] or z1w[1]
end

-- Finds the first item with no AID at a position and transforms it to newId.
-- (Display items are the only non-ground items placed without an AID.)
local function transformDisplay(pos, newId)
    if not pos or not newId or newId == 0 then return end
    local tile = Tile(pos)
    if not tile then return end
    local items = tile:getItems()
    if not items then return end
    for _, item in ipairs(items) do
        local aid = item:getActionId()
        if not aid or aid == 0 then
            if item:getId() ~= newId then item:transform(newId) end
            return
        end
    end
end

local function updateWeaponDisplays(player)
    local p = C().room2 or {}
    local id3, id2, id1 = getVocWeaponIds(player)
    transformDisplay(p.z3Display, id3)
    transformDisplay(p.z2Display, id2)
    transformDisplay(p.z1Display, id1)
end

-- Export for use by weapon upgrade and armor set scripts.
_G.Z1UpdateWeaponDisplays = updateWeaponDisplays

-- ---------------------------------------------
-- STARTUP BUILDER
-- ---------------------------------------------

local startup = GlobalEvent("Z1Room2V10Builder")
startup:type("startup")
function startup.onStartup()
    local p    = C().room2 or {}
    local aids = C().aids  or {}
    local z    = C().zWeapons or {}
    local sets = C().armorSets or {}

    fillRoom()

    -- -- TOP ROW: Z Weapon chests --
    -- Display items start with the generic [1] weapon; they update to the player's vocation
    -- when the player OPENS the chest (not just on room entry).
    placeDisplay(z.z3 and z.z3[1] or 26044, p.z3Display,
        "Z3 weapon display. Open the chest below to see your vocation's weapon and claim.", 62101)
    place(SIGN, p.z3Sign, 11531,
        "Z3 Starter\nOpen the chest to choose\n25 gold ingots\nRequires Morshabaal kills", 62111)
    setGround(p.portalZ3, WHITE_FLOOR)
    place(CHEST_WEAPON, p.portalZ3, aids.gateZ3 or 11466,
        "Z3 Weapon Chest. Open to claim your vocation's Z3 starter weapon.", 62002)

    placeDisplay(z.z2 and z.z2[1] or 25984, p.z2Display,
        "Z2 weapon display. Open the chest below to upgrade.", 62102)
    place(SIGN, p.z2Sign, 11532,
        "Z2 Upgrade\nOpen the chest to upgrade your Z3\n75 ingots + 1 fiery tear", 62112)
    setGround(p.portalZ2, WHITE_FLOOR)
    place(CHEST_WEAPON, p.portalZ2, aids.gateZ2 or 11467,
        "Z2 Weapon Chest. Open with a Z3 weapon in your inventory to upgrade.", 62003)

    placeDisplay(z.z1 and z.z1[1] or 26016, p.z1Display,
        "Z1 weapon display. Open the chest below to upgrade.", 62103)
    place(SIGN, p.z1Sign, 11533,
        "Z1 Endgame\nOpen the chest to upgrade your Z2\n150 ingots + 3 fiery tears", 62113)
    setGround(p.portalZ1, WHITE_FLOOR)
    place(CHEST_WEAPON, p.portalZ1, aids.gateZ1 or 11468,
        "Z1 Weapon Chest. Open with a Z2 weapon in your inventory to upgrade.", 62004)

    -- -- CENTER: Rift Forge --
    setGround(p.forge, WHITE_FLOOR)
    place(ANVIL, p.forge, aids.forge or 11465,
        "Rift Forge. Auto-detects your Z weapon and guides you through claim or upgrade.", 62001)
    if p.forgeSign then
        place(SIGN, p.forgeSign, 11534, "Forge\nAuto path\nIngots + fiery tears", 62114)
    end

    -- -- BOTTOM ROW: Z Armor set portals --
    -- Order: portal (facing forge) → sign → display (outer wall)
    local function buildArmorSlot(set, portalPos, signPos, displayPos, aid, pUid, sUid, dUid)
        if not set or not portalPos then return end
        local costTxt  = (set.costIngots or 0) .. " gold ingots"
        placeDisplay(set.displayId or 26189, displayPos,
            set.label .. " armor display.", dUid)
        place(SIGN, signPos, nil,
            set.label .. "\nOpen chest to claim\n" .. costTxt, sUid)
        setGround(portalPos, WHITE_FLOOR)
        place(CHEST_ARMOR, portalPos, aid,
            set.label .. " Armor Chest. Open to confirm and claim. Cost: " .. costTxt, pUid)
        print(string.format("[Z1 Room2] %s armor chest AID %d at %d,%d,%d | cost %s",
            set.label, aid, portalPos.x, portalPos.y, portalPos.z, costTxt))
    end

    buildArmorSlot(sets.z3, p.armorZ3Portal, p.armorZ3Sign, p.armorZ3Display,
        aids.armorZ3 or 11480, 62031, 62131, 62141)
    buildArmorSlot(sets.z2, p.armorZ2Portal, p.armorZ2Sign, p.armorZ2Display,
        aids.armorZ2 or 11481, 62032, 62132, 62142)
    buildArmorSlot(sets.z1, p.armorZ1Portal, p.armorZ1Sign, p.armorZ1Display,
        aids.armorZ1 or 11482, 62033, 62133, 62143)

    print("[Z1 Room2] v12 built: weapon chests + voc display + armor chests.")
    return true
end
startup:register()

-- ---------------------------------------------
-- STEPIN: Update weapon display to player's vocation
-- ---------------------------------------------
-- Fires when a player steps into ANY tile of Room 2.
-- Only updates displays when entering from OUTSIDE the room (not every step inside).

local roomStepin = MoveEvent()
roomStepin:type("stepin")
function roomStepin.onStepIn(creature, item, position, fromPosition)
    local player = Player(creature)
    if not player then return true end

    local p = C().room2 or {}
    if not p.from or not p.to then return true end

    local minX = math.min(p.from.x, p.to.x); local maxX = math.max(p.from.x, p.to.x)
    local minY = math.min(p.from.y, p.to.y); local maxY = math.max(p.from.y, p.to.y)

    -- Only update when crossing the room boundary (entering from outside).
    local wasInside = fromPosition.x >= minX and fromPosition.x <= maxX
                   and fromPosition.y >= minY and fromPosition.y <= maxY
    if not wasInside then
        updateWeaponDisplays(player)
    end
    return true
end

-- Register the stepin on every tile inside Room 2.
do
    local p = (_G.Z1Rift or {}).room2 or {}
    if p.from and p.to then
        for x = math.min(p.from.x, p.to.x), math.max(p.from.x, p.to.x) do
            for y = math.min(p.from.y, p.to.y), math.max(p.from.y, p.to.y) do
                roomStepin:position(Position(x, y, p.from.z))
            end
        end
        print(string.format("[Z1 Room2] Voc-display stepin registered for %d tiles.",
            (math.max(p.from.x, p.to.x) - math.min(p.from.x, p.to.x) + 1) *
            (math.max(p.from.y, p.to.y) - math.min(p.from.y, p.to.y) + 1)))
    end
end
roomStepin:register()

print("[Z1 Room2] v12 loaded. Voc-aware display (on entry + chest open) + chest claim events.")