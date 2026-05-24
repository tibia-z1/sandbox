print("Zero1Labs Training Monks System loaded")

-- Training room generator
-- Pattern:
-- Columns: 1018, 1030, 1042, 1054, 1066, 1078
-- Vertical step: 12
-- First Y: 1112
-- Test up to Y: 1232
-- Monks spawn at x-1,y-1,z and x+1,y-1,z

local trainingRooms = {}

local trainingColumns = {1018, 1030, 1042, 1054, 1066, 1078}
local startY = 1112
local roomsPerColumn = 11 -- 1112 to 1232 with step 12
local yStep = 12
local z = 7

for _, x in ipairs(trainingColumns) do
    for i = 0, roomsPerColumn - 1 do
        local y = startY + (i * yStep)

        table.insert(trainingRooms, {
            playerTile = Position(x, y, z),
            monkPositions = {
                Position(x - 1, y - 1, z),
                Position(x + 1, y - 1, z),
            },
        })
    end
end

local function spawnTrainingMonk(pos)
    local tile = Tile(pos)
    if not tile then
        print("[Zero1Labs Training] Missing monk tile at " .. pos.x .. "," .. pos.y .. "," .. pos.z)
        return
    end

    local creatures = tile:getCreatures()
    if creatures then
        for _, creature in ipairs(creatures) do
            if creature:getName():lower() == "training monk" then
                return
            end
        end
    end

    local monk = Game.createMonster("Training Monk", pos, false, true)
    if monk then
        monk:setDropLoot(false)
    else
        print("[Zero1Labs Training] Could not spawn Training Monk at " .. pos.x .. "," .. pos.y .. "," .. pos.z)
    end
end

local function ensureTrainingMonks()
    for _, room in ipairs(trainingRooms) do
        for _, monkPos in ipairs(room.monkPositions) do
            spawnTrainingMonk(monkPos)
        end
    end
end

local startup = GlobalEvent("Zero1LabsTrainingMonksStartup")

function startup.onStartup()
    ensureTrainingMonks()
    return true
end

startup:register()

local respawnEvent = GlobalEvent("Zero1LabsTrainingMonksRespawn")

function respawnEvent.onThink(interval)
    ensureTrainingMonks()
    return true
end

respawnEvent:interval(10000)
respawnEvent:register()