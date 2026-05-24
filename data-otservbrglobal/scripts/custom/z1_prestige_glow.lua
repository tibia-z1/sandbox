-- data/scripts/custom/z1_prestige_glow.lua
-- Prestige Aura -- visible glow effect that fires every ~10 seconds
-- around prestiged players. Scales visually with rank so rank 10
-- looks clearly more powerful than rank 1.
-- Registered via Z1PrestigeLogin (z1_prestige.lua).
--
-- ADD TO login.lua (if not using Z1PrestigeLogin):
--   player:registerEvent("Z1PrestigeGlow")

print("[Z1 Prestige Glow] Loading prestige aura system...")

local RANK_STORAGE = _G.Z1_PRESTIGE_RANK_STORAGE or 590001

-- How many think ticks between glow pulses.
-- Think interval is typically ~300ms. 33 ticks ~ 10 seconds.
local GLOW_EVERY = 33

-- Effects per rank tier.
-- Each entry: { primary effect, optional secondary effect or nil }
-- Secondary fires 1 tick after primary for a layered look.
local RANK_EFFECTS = {
    [1]  = { CONST_ME_MAGIC_GREEN,  nil                  },  -- subtle green
    [2]  = { CONST_ME_MAGIC_GREEN,  CONST_ME_MAGIC_BLUE  },  -- green + blue
    [3]  = { CONST_ME_MAGIC_BLUE,   nil                  },  -- pure blue
    [4]  = { CONST_ME_MAGIC_BLUE,   CONST_ME_ENERGYAREA  },  -- blue + energy
    [5]  = { CONST_ME_ENERGYAREA,   nil                  },  -- electric
    [6]  = { CONST_ME_ENERGYAREA,   CONST_ME_FIREAREA    },  -- electric + fire
    [7]  = { CONST_ME_FIREAREA,     nil                  },  -- fire
    [8]  = { CONST_ME_FIREAREA,     CONST_ME_HOLYAREA    },  -- fire + holy gold
    [9]  = { CONST_ME_HOLYAREA,     CONST_ME_MORTAREA    },  -- holy + death
    [10] = { CONST_ME_MAGIC_RED,    CONST_ME_HOLYAREA    },  -- blood red + holy -- max rank
}

local glowCounters = {}
local secondaryQueue = {}  -- { [pid] = { effect, tick } }

local glowEvent = CreatureEvent("Z1PrestigeGlow")
glowEvent:type("think")
glowEvent:onThink(function(player, interval)
    if not player:isPlayer() then return true end

    local rank = math.max(0, player:getStorageValue(RANK_STORAGE))
    if rank <= 0 then return true end

    local pid = player:getId()
    glowCounters[pid] = (glowCounters[pid] or 0) + 1

    -- Fire queued secondary effect one tick after primary
    local sec = secondaryQueue[pid]
    if sec then
        secondaryQueue[pid] = nil
        pcall(function()
            player:getPosition():sendMagicEffect(sec)
        end)
    end

    if glowCounters[pid] < GLOW_EVERY then
        return true
    end
    glowCounters[pid] = 0

    local fx = RANK_EFFECTS[rank]
    if not fx then return true end

    local pos = player:getPosition()
    if not pos then return true end

    -- Primary effect
    pcall(function() pos:sendMagicEffect(fx[1]) end)

    -- Queue secondary for next tick (layered look without same-tick flicker)
    if fx[2] then
        secondaryQueue[pid] = fx[2]
    end

    return true
end)
glowEvent:register()

print("[Z1 Prestige Glow] Loaded. Rank 1=green, Rank 5=electric, Rank 10=blood+holy aura.")
