-- data/scripts/custom/z1_doors.lua
-- Suppresses the "You are not allowed to enter." / "You are an unwanted intruder!"
-- message from custom locked door items in your hub and dungeons.
--
-- HOW IT WORKS:
--   We register an Action for each door item ID used in custom areas.
--   When a player clicks or bumps into a door they cannot open, our handler
--   fires first and either silently blocks or shows a custom message.
--   Returning true from an Action suppresses the engine's default behaviour
--   including the intruder message.
--
-- STANDARD TIBIA LOCKED DOOR IDs (horizontal/vertical variants):
--   1543, 1541, 5011, 5013, 1575, 1577, 9265, 9267, 35418, 35420
--
-- ADD YOUR CUSTOM DOOR IDs in the CUSTOM_DOOR_IDS table below.
-- If you do not know which IDs your doors use, stand next to one and use:
--   /look (admin command to inspect an item)
-- or check the "door" item entries in your items.xml.

print("[Z1 Doors] Loading door message suppressor...")

-- =========================================================
-- CONFIG
-- =========================================================

-- Set to "" to silently block (no message at all)
-- Set to a string to show a custom message instead
local BLOCK_MESSAGE = ""   -- empty = silent block

-- Add the item IDs of every locked door in your custom areas.
-- Common Tibia door IDs included by default. Add yours as needed.
local CUSTOM_DOOR_IDS = {
    -- Standard Tibia locked doors (horizontal)
    1541, 1543,
    -- Standard Tibia locked doors (vertical)
    5011, 5013, 5113, 
    -- Other common locked door variants
    1575, 1577, 9265, 9267,
    -- Newer Tibia locked doors
    35418, 35420, 35416, 35414,
    -- TODO: Add your hub/dungeon-specific door IDs here:
	2772, 
    -- 1234,
    -- 5678,
}

-- =========================================================
-- ACTION HANDLER -- fires when player uses (clicks) a door
-- Returning true suppresses all engine default behaviour
-- =========================================================

local doorAction = Action()

function doorAction.onUse(player, item, fromPos, target, toPos, isHotkey)
    -- Check if door is actually locked (can't open)
    -- In Canary, a locked door transforms to an open state when usable.
    -- If we're here, the player cannot open it -- suppress the message.

    if BLOCK_MESSAGE ~= "" then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, BLOCK_MESSAGE)
    end

    -- Return true to block default "unwanted intruder" message
    return true
end

-- Register for all door IDs
for _, id in ipairs(CUSTOM_DOOR_IDS) do
    doorAction:id(id)
end
doorAction:register()

-- =========================================================
-- MOVE EVENT -- fires when player steps on a door tile (stepin)
-- Some servers block movement by having doors without open state.
-- =========================================================

-- This suppresses the "intruder" broadcast that some door scripts trigger
-- by intercepting the stepin event on door tiles with specific AIDs.
-- Uncomment and configure if you have door tiles with Action IDs:
--[[
local doorMoveEvent = MoveEvent()
doorMoveEvent:type("stepin")
function doorMoveEvent.onStepIn(creature, item, position, fromPosition)
    local player = Player(creature)
    if not player then return true end
    -- Silent bounce back
    if fromPosition then
        player:teleportTo(fromPosition, true)
    end
    return true
end
-- Add AID of door tiles you want silently blocked:
-- doorMoveEvent:aid(YOUR_DOOR_AID)
-- doorMoveEvent:register()
--]]

print("[Z1 Doors] Loaded. " .. #CUSTOM_DOOR_IDS .. " door IDs suppressed.")
print("[Z1 Doors] Add your custom door item IDs to CUSTOM_DOOR_IDS table.")
