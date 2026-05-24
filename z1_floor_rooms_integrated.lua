-- z1_floor_rooms_integrated.lua
-- Integrated floor cleanup for:
-- 1) Main teleport room floor conversion/cleanup
-- 2) Set/quest rooms #1 and #2 black marble + number floors
-- Put in: data/scripts/custom/

print("[Z1 Floor Rooms] Loading integrated floor cleanup...")

local FLOOR = {
    BLACK_MARBLE = 410,
    STONY = 6388,
    MARBLE = 10986,
}

local config = {
    enabled = true,
    debug = true,

    -- Main teleport room. This can convert old planks and remove blocking top-items.
    teleportRoom = {
        enabled = true,
        fromPos = Position(32242, 32167, 8),
        toPos   = Position(32269, 32192, 8),
        groundId = FLOOR.BLACK_MARBLE,
        clearTopItems = true,
    },

    -- Set/quest display rooms. These must remove straw/cobwebs/etc. but preserve portals, signs, displays.
    numberRooms = {
        enabled = true,
        clearTopItems = true,
        rooms = {
            one = {
                fromPos = Position(32236, 32197, 8),
                toPos   = Position(32244, 32205, 8),
                backgroundId = FLOOR.BLACK_MARBLE,
            },
            two = {
                fromPos = Position(32267, 32197, 8),
                toPos   = Position(32275, 32205, 8),
                backgroundId = FLOOR.BLACK_MARBLE,
            }
        }
    },

    -- Items that should NEVER be removed as top items.
    -- Add your visual set item IDs here if needed, but UID/action checks below already protect most Z1 objects.
    protectedItemIds = {
        [25051] = true, -- energy portal visual used by set room
        [25053] = true, -- common teleport/fire portal fallback
        [1387] = true,  -- older portal fallback, if still used anywhere
        [1947] = true,  -- sign fallback
        [1948] = true,  -- sign fallback / readable sign variants
    },

    -- These action/unique ranges protect Z1 room objects regardless of item ID.
    protectedActionIdMin = 9000,
    protectedActionIdMax = 9300,
    protectedUniqueIdMin = 61000,
    protectedUniqueIdMax = 63000,
}

local function normalizeArea(fromPos, toPos)
    return {
        minX = math.min(fromPos.x, toPos.x),
        maxX = math.max(fromPos.x, toPos.x),
        minY = math.min(fromPos.y, toPos.y),
        maxY = math.max(fromPos.y, toPos.y),
        z = fromPos.z,
    }
end

local function ensureTile(pos)
    local tile = Tile(pos)
    if not tile then
        Game.createTile(pos, true)
        tile = Tile(pos)
    end
    return tile
end

local function setGround(pos, itemId)
    local tile = ensureTile(pos)
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

local function isProtectedTopItem(item)
    if not item then
        return true
    end

    local itemId = item:getId()
    if config.protectedItemIds[itemId] then
        return true
    end

    local aid = item:getActionId()
    if aid and aid >= config.protectedActionIdMin and aid <= config.protectedActionIdMax then
        return true
    end

    local uid = item:getUniqueId()
    if uid and uid >= config.protectedUniqueIdMin and uid <= config.protectedUniqueIdMax then
        return true
    end

    return false
end

local function clearTileTopItems(pos)
    local tile = Tile(pos)
    if not tile then
        return 0
    end

    local items = tile:getItems()
    if not items then
        return 0
    end

    local ground = tile:getGround()
    local removed = 0

    for i = #items, 1, -1 do
        local item = items[i]
        if item then
            -- Never remove the ground item.
            if not ground or item.uid ~= ground.uid then
                if not isProtectedTopItem(item) then
                    item:remove()
                    removed = removed + 1
                end
            end
        end
    end

    return removed
end

local function fillRect(fromPos, toPos, itemId, clearTopItems)
    local area = normalizeArea(fromPos, toPos)
    local painted = 0
    local removed = 0

    for x = area.minX, area.maxX do
        for y = area.minY, area.maxY do
            local pos = Position(x, y, area.z)
            if setGround(pos, itemId) then
                painted = painted + 1
            end
            if clearTopItems then
                removed = removed + clearTileTopItems(pos)
            end
        end
    end

    return painted, removed
end

local function paintNumberOne()
    local room = config.numberRooms.rooms.one
    local painted, removed = fillRect(room.fromPos, room.toPos, room.backgroundId, config.numberRooms.clearTopItems)

    -- Number 1: vertical line at x=32240 from y=32197 to 32205,
    -- plus side tile at x=32239,y=32199.
    for y = 32199, 32203 do
        setGround(Position(32240, y, 8), FLOOR.MARBLE)
    end
    setGround(Position(32239, 32199, 8), FLOOR.MARBLE)

    return painted, removed
end

local function paintNumberTwo()
    local room = config.numberRooms.rooms.two
    local painted, removed = fillRect(room.fromPos, room.toPos, room.backgroundId, config.numberRooms.clearTopItems)

    -- Number 2 seven-segment style using marble floor.
    local coords = {
        -- top
        {32270,32199}, {32271,32199}, {32272,32199},
        -- upper right
        {32272,32200}, {32272,32201},
        -- middle
        {32270,32201}, {32271,32201}, {32272,32201},
        -- lower left
        {32270,32202}, {32270,32203},
        -- bottom
        {32271,32203}, {32272,32203},
    }

    for _, c in ipairs(coords) do
        setGround(Position(c[1], c[2], 8), FLOOR.MARBLE)
    end

    return painted, removed
end

local function cleanTeleportRoom()
    local room = config.teleportRoom
    return fillRect(room.fromPos, room.toPos, room.groundId, room.clearTopItems)
end

local ge = GlobalEvent("Z1FloorRoomsIntegrated")
function ge.onStartup()
    if not config.enabled then
        print("[Z1 Floor Rooms] Disabled.")
        return true
    end

    local totalPainted = 0
    local totalRemoved = 0

    if config.teleportRoom.enabled then
        local painted, removed = cleanTeleportRoom()
        totalPainted = totalPainted + painted
        totalRemoved = totalRemoved + removed
        if config.debug then
            print("[Z1 Floor Rooms] Teleport room cleaned. Painted=" .. painted .. ", removed top-items=" .. removed)
        end
    end

    if config.numberRooms.enabled then
        local p1, r1 = paintNumberOne()
        local p2, r2 = paintNumberTwo()
        totalPainted = totalPainted + p1 + p2
        totalRemoved = totalRemoved + r1 + r2
        if config.debug then
            print("[Z1 Floor Rooms] Room #1 painted. Painted=" .. p1 .. ", removed top-items=" .. r1)
            print("[Z1 Floor Rooms] Room #2 painted. Painted=" .. p2 .. ", removed top-items=" .. r2)
        end
    end

    if config.debug then
        print("[Z1 Floor Rooms] Integrated cleanup done. Total painted=" .. totalPainted .. ", total removed top-items=" .. totalRemoved)
    end

    return true
end

ge:register()
