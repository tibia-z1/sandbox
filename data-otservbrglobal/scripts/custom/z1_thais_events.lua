-- z1_thais_events.lua
-- All live content centered on Thais:
--   1. City raids (escalating waves, server announcement, boss reward chest)
--   2. Scaling daily chest (base reward + bonus tiers bought with gold ingots)
--   3. Server Prosperity Fund (communal donation -> server-wide XP boost)
--   4. Weekly World Boss at Thais depot
-- Put in: data/scripts/custom/
-- Requires: 00_z1_core.lua loaded first.

print("[Z1 Thais Events] Loading...")

local Z1 = _G.Z1
if not Z1 then
    print("[Z1 Thais Events] ERROR: 00_z1_core.lua must load first.")
    return
end

-- =========================================================
-- SHARED POSITIONS -- Thais landmarks
-- ALL spawn positions are OUTSIDE the city walls / PZ.
-- The temple and depot area are PZ -- monsters spawned there
-- cannot move or attack. Use positions on open roads/fields.
--
-- Scatter offsets: each spawn in a wave is nudged slightly so
-- monsters don't all land on the same tile.
--
-- HOW TO VERIFY: log in as GM, use !raid, watch the console
-- for "[Z1 Raid] SPAWNED ... at x,y,z". Go to those coords
-- and check if the tile is walkable and outside PZ.
-- =========================================================
local POS = {
    -- North road outside the city walls (~32366, 32202, 7)
    northGate  = {
        Position(32366, 32202, 7),
        Position(32368, 32200, 7),
        Position(32364, 32200, 7),
        Position(32370, 32203, 7),
    },
    -- South road outside the south gate (~32373, 32288, 7)
    southGate  = {
        Position(32373, 32288, 7),
        Position(32371, 32290, 7),
        Position(32375, 32291, 7),
        Position(32369, 32292, 7),
    },
    -- East open field outside the east wall (~32398, 32250, 7)
    eastField  = {
        Position(32398, 32250, 7),
        Position(32400, 32253, 7),
        Position(32402, 32248, 7),
        Position(32396, 32255, 7),
    },
    -- West docks / beach area, outside city (~32334, 32257, 7)
    docks      = {
        Position(32334, 32257, 7),
        Position(32332, 32260, 7),
        Position(32336, 32254, 7),
    },
    -- Boss arena: large open field east of Thais
    bossArena  = Position(32408, 32257, 7),
    -- World boss: same open field, slightly different tile
    worldBossSpawn = Position(32410, 32260, 7),
    -- Prosperity NPC / daily chest: near the temple entrance
    -- (INSIDE the PZ is fine for NPCs and chests -- only spawns need to be outside)
    prosperityNPC = Position(32365, 32237, 7),
    dailyChestPos = Position(32369, 32238, 7),
}

-- =========================================================
-- SECTION 1: CITY RAIDS
-- =========================================================

local RAID_COOLDOWN_STORAGE = 599901  -- global (not per-player): fake using first player trick
local RAID_COOLDOWN_SECONDS = 7200    -- 2 hours minimum between raids
local RAID_ACTIVE = false

-- Wave definitions: each wave spawns after the previous boss dies or after a timer.
local RAID_WAVES = {
    {
        label = "Scout Wave",
        delay = 0,
        spawns = {
            { name = "Demon",     pos = POS.northGate[1] },
            { name = "Demon",     pos = POS.northGate[2] },
            { name = "Demon",     pos = POS.southGate[1] },
            { name = "Demon",     pos = POS.southGate[2] },
            { name = "Demon",     pos = POS.docks[1] },
            { name = "Behemoth",  pos = POS.eastField[1] },
            { name = "Behemoth",  pos = POS.eastField[2] },
            { name = "Behemoth",  pos = POS.northGate[3] },
        }
    },
    {
        label = "Elite Wave",
        delay = 180,
        spawns = {
            { name = "Juggernaut",    pos = POS.northGate[1] },
            { name = "Juggernaut",    pos = POS.northGate[4] },
            { name = "Juggernaut",    pos = POS.southGate[3] },
            { name = "Dark Torturer", pos = POS.docks[2] },
            { name = "Dark Torturer", pos = POS.eastField[3] },
            { name = "Plaguesmith",   pos = POS.southGate[4] },
        }
    },
    {
        label = "Rift Lord (BOSS)",
        delay = 360,
        spawns = {
            { name = "Ghazbaran", pos = POS.bossArena },
        },
        isBoss = true,
    },
}

-- Damage tracking for the boss reward
local _bossDamage = {}  -- [creatureId] = totalDamage

local function broadcastRaid(text)
    Game.broadcastMessage("[THAIS UNDER ATTACK] " .. text, MESSAGE_EVENT_ADVANCE)
end

local function spawnWave(wave)
    broadcastRaid(wave.label .. " has arrived!")
    print(string.format("[Z1 Raid] === Wave: %s ===", wave.label))
    for _, spawn in ipairs(wave.spawns) do
        local p = spawn.pos
        local m = Game.createMonster(spawn.name, p, true, true)
        if m then
            print(string.format("[Z1 Raid] SPAWNED  %-24s  at %d,%d,%d  (id=%d)",
                spawn.name, p.x, p.y, p.z, m:getId()))
            -- Send a visible effect at spawn tile so you can see it in-game
            p:sendMagicEffect(CONST_ME_TELEPORT)
            if wave.isBoss then
                _bossDamage = {}
                print(string.format("[Z1 Raid] BOSS spawned at %d,%d,%d -- watching for death.", p.x, p.y, p.z))
            end
        else
            print(string.format("[Z1 Raid] FAILED to spawn %-24s  at %d,%d,%d  (check map tile/walkable)",
                spawn.name, p.x, p.y, p.z))
        end
    end
end

local function giveRaidReward(pos)
    -- Spawn a reward chest at the boss arena
    local chest = Game.createItem(1987, 1, pos)  -- 1987 = typical chest item
    if chest then
        chest:setActionId(8899)
    end
    broadcastRaid("The Rift Lord has been defeated! A reward chest appeared at the battlefield.")
end

-- Raid reward chest action
local raidChestEvent = Action()
function raidChestEvent.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Give top-tier loot proportional to participation.
    -- Simplified: anyone who opens it during the window gets the same reward.
    local rewards = {
        { id = Z1.SET_CURRENCY_ID, count = 20 },  -- 20 gold ingots
        { id = 3043, count = 50 },                  -- 50 crystal coins
    }
    for _, r in ipairs(rewards) do
        player:addItem(r.id, r.count)
    end
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[Thais Raid] You claimed your raid reward!")
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

    -- Optionally remove the chest so it can only be looted once per server.
    -- Comment this out if you want everyone to be able to claim.
    -- item:remove()
    return true
end
raidChestEvent:aid(8899)
raidChestEvent:register()

-- Main raid ticker
local raidTick = GlobalEvent("Z1ThaisRaidTick")
local _raidStartTime = 0
local _wavesFired = {}

function raidTick.onThink(interval)
    -- Only run raid logic if a raid is active
    if not RAID_ACTIVE then return true end

    local elapsed = os.time() - _raidStartTime

    for i, wave in ipairs(RAID_WAVES) do
        if not _wavesFired[i] and elapsed >= wave.delay then
            spawnWave(wave)
            _wavesFired[i] = true

            if wave.isBoss then
                -- Poll for boss death -- check in 30 seconds
                addEvent(function()
                    local bossAlive = false
                    local specs = Game.getSpectators(POS.bossArena, false, false, 15, 15, 15, 15)
                    for _, c in ipairs(specs) do
                        -- Ghazbaran or your boss name
                        if not c:isPlayer() and (c:getName() == "Ghazbaran") then
                            bossAlive = true
                            break
                        end
                    end
                    if not bossAlive then
                        RAID_ACTIVE = false
                        giveRaidReward(POS.bossArena)
                    end
                end, 30 * 1000)
            end
        end
    end

    -- Raid auto-ends after 20 minutes regardless
    if elapsed >= 1200 then
        RAID_ACTIVE = false
        broadcastRaid("The invasion has been repelled (or you weren't fast enough).")
    end

    return true
end
raidTick:interval(5000)
raidTick:register()

-- Raid scheduler: fires every 5 minutes, randomly starts a raid based on cooldown
local raidScheduler = GlobalEvent("Z1ThaisRaidScheduler")
local _lastRaidTime = 0

function raidScheduler.onThink(interval)
    if RAID_ACTIVE then return true end

    local now = os.time()
    if (now - _lastRaidTime) < RAID_COOLDOWN_SECONDS then return true end

    -- Random chance: ~20% per check (checks every 10 min = ~2 hour average gap)
    if math.random(100) > 20 then return true end

    local playerCount = #Game.getPlayers()
    if playerCount < 1 then return true end  -- don't raid an empty server

    -- Start raid
    RAID_ACTIVE = true
    RAID_ACTIVE = true
    _raidStartTime = now
    _lastRaidTime = now
    _wavesFired = {}

    broadcastRaid("A Rift has opened near Thais! Monsters are invading! Head to the city to defend it!")
    -- 5-minute warning effect
    POS.northGate:sendMagicEffect(CONST_ME_TELEPORT)
    POS.southGate:sendMagicEffect(CONST_ME_TELEPORT)

    return true
end
raidScheduler:interval(600000)  -- check every 10 minutes
raidScheduler:register()

-- Admin command: trigger a raid immediately
local forceRaidCmd = TalkAction("/z1raid")
function forceRaidCmd.onSay(player, words, param)
    local group = player:getGroup()
    if not group or not group:getAccess() then
        player:sendCancelMessage("Access denied.")
        return false
    end
    if RAID_ACTIVE then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "A raid is already active.")
        return false
    end
    RAID_ACTIVE = true
    _raidStartTime = os.time()
    _lastRaidTime = os.time()
    _wavesFired = {}
    broadcastRaid("A Rift has opened near Thais! Monsters are invading!")
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[Z1] Raid started on Thais.")
    return false
end
forceRaidCmd:separator(" ")
forceRaidCmd:groupType("god")
forceRaidCmd:register()

-- =========================================================
-- SECTION 2: SCALING DAILY CHEST
-- Gold ingot donations increase the reward tier permanently
-- per account until the next day's reset.
-- =========================================================

local DAILY_CHEST_AID        = 9702   -- different from existing 9701
local DAILY_CHEST_UID        = 9702
local DAILY_STORAGE_COOLDOWN = 599801  -- per-player
local DAILY_STORAGE_TIER     = 599802  -- per-player daily tier upgrades
local DAILY_RESET_HOUR       = 6       -- resets at 06:00 server time
local DAILY_COOLDOWN_SECS    = 86400   -- 24 hours

-- Tiers: index = tier level (0 = free base, 1-4 = paid upgrades)
local DAILY_TIERS = {
    [0] = {
        label = "Basic",
        cost  = 0,
        rewards = {
            { id = 3043, count = 50,  label = "50 crystal coins" },
            { id = 22118, count = 25, label = "25 Zero1 Coins" },
        }
    },
    [1] = {
        label = "Silver",
        cost  = 5,  -- 5 gold ingots to upgrade to this tier today
        rewards = {
            { id = 3043, count = 200,  label = "200 crystal coins" },
            { id = Z1 and Z1.SET_CURRENCY_ID or 9058, count = 5, label = "5 gold ingots" },
            { id = 22118, count = 100, label = "100 Zero1 Coins" },
        }
    },
    [2] = {
        label = "Gold",
        cost  = 15,  -- 15 gold ingots cumulative
        rewards = {
            { id = 3043, count = 500, label = "500 crystal coins" },
            { id = Z1 and Z1.SET_CURRENCY_ID or 9058, count = 15, label = "15 gold ingots" },
            { id = 22118, count = 300, label = "300 Zero1 Coins" },
            { id = 28540, count = 1,   label = "training sword" },
        }
    },
    [3] = {
        label = "Rift",
        cost  = 40,  -- 40 gold ingots cumulative
        rewards = {
            { id = 3043, count = 1200, label = "1200 crystal coins" },
            { id = Z1 and Z1.SET_CURRENCY_ID or 9058, count = 40, label = "40 gold ingots" },
            { id = 22118, count = 750, label = "750 Zero1 Coins" },
            -- Rare item from a pool
        }
    },
}

-- Upgrade chest: NPC or chest next to the daily chest that accepts gold ingots
-- Player uses !daychest upgrade to upgrade their tier for today.
local upgradeCmd = TalkAction("!daychest")
function upgradeCmd.onSay(player, words, param)
    if param:lower() == "info" then
        local lines = {"=== Daily Chest Tiers ==="}
        for i = 0, 3 do
            local t = DAILY_TIERS[i]
            if t then
                local items = {}
                for _, r in ipairs(t.rewards) do table.insert(items, r.label) end
                table.insert(lines, string.format(
                    "Tier %d (%s) | Cost: %d gold ingots | Rewards: %s",
                    i, t.label, t.cost, table.concat(items, ", ")
                ))
            end
        end
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, table.concat(lines, "\n"))
        return false
    end

    if param:lower() == "upgrade" then
        local currentTier = player:getStorageValue(DAILY_STORAGE_TIER)
        if currentTier < 0 then currentTier = 0 end
        local nextTier = currentTier + 1
        local nextData = DAILY_TIERS[nextTier]

        if not nextData then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[Daily Chest] Already at max tier.")
            return false
        end

        local cost = nextData.cost - (DAILY_TIERS[currentTier] and DAILY_TIERS[currentTier].cost or 0)
        local ingotId = Z1 and Z1.SET_CURRENCY_ID or 9058
        if player:getItemCount(ingotId) < cost then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
                string.format("[Daily Chest] You need %d more gold ingots to upgrade to %s tier.",
                    cost, nextData.label))
            return false
        end

        player:removeItem(ingotId, cost)
        player:setStorageValue(DAILY_STORAGE_TIER, nextTier)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
            string.format("[Daily Chest] Upgraded to %s tier for today! Open your daily chest to claim rewards.",
                nextData.label))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
        return false
    end

    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        "[Daily Chest] Commands: !daychest info | !daychest upgrade")
    return false
end
upgradeCmd:separator(" ")
upgradeCmd:groupType("normal")
upgradeCmd:register()

-- Daily chest Action event
local dailyScalingChest = Action()
function dailyScalingChest.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local now = os.time()
    local nextClaim = player:getStorageValue(DAILY_STORAGE_COOLDOWN)

    if nextClaim > now then
        local rem = nextClaim - now
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
            string.format("[Daily Chest] Next claim in %dh %dm.",
                math.floor(rem/3600), math.floor((rem%3600)/60)))
        return true
    end

    local tier = math.max(0, player:getStorageValue(DAILY_STORAGE_TIER))
    local tierData = DAILY_TIERS[tier] or DAILY_TIERS[0]

    local rewardLines = {}
    for _, reward in ipairs(tierData.rewards) do
        local added = player:addItem(reward.id, reward.count)
        if added then table.insert(rewardLines, reward.label) end
    end

    -- Reset tier for tomorrow and set cooldown
    player:setStorageValue(DAILY_STORAGE_COOLDOWN, now + DAILY_COOLDOWN_SECS)
    player:setStorageValue(DAILY_STORAGE_TIER, 0)  -- tier resets daily

    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        string.format("[Daily Chest - %s Tier] You received: %s.",
            tierData.label, table.concat(rewardLines, ", ")))
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    return true
end
dailyScalingChest:uid(DAILY_CHEST_UID)
dailyScalingChest:register()

-- Place the scaling chest on startup
local dailyChestSetup = GlobalEvent("Z1ThaisScalingChestSetup")
function dailyChestSetup.onStartup()
    local tile = Tile(POS.dailyChestPos)
    if tile then
        local chest = tile:getTopDownItem()
        if chest then
            chest:setAttribute(ITEM_ATTRIBUTE_UNIQUEID, DAILY_CHEST_UID)
            chest:setActionId(DAILY_CHEST_AID)
            chest:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION,
                "Daily Reward Chest -- upgradeable with gold ingots. Type !daychest info.")
        else
            print("[Z1 Thais Events] No chest item found at daily chest position " ..
                POS.dailyChestPos.x .. "," .. POS.dailyChestPos.y)
        end
    end
    return true
end
dailyChestSetup:register()

-- =========================================================
-- SECTION 3: PROSPERITY FUND
-- Players donate gold ingots to a shared fund.
-- When the fund fills, server-wide XP boost for 2 hours.
-- =========================================================

local PROSPERITY_STORAGE = 599901   -- global sum stored on player id 1 (server storage trick)
local PROSPERITY_GOAL    = 1000     -- gold ingots needed to trigger boost
local PROSPERITY_BOOST_STORAGE = 599902  -- timestamp when boost ends (check on XP gain)
local PROSPERITY_BOOST_DURATION = 7200  -- 2 hours

-- We use a text file workaround since GlobalStorage isn't available in all Canary versions.
-- Store the fund total as a db query.
local function getProsperityFund()
    if not db.storeQuery then return 0 end
    local r = db.storeQuery("SELECT `value` FROM `server_config` WHERE `config` = 'z1_prosperity_fund'")
    if not r then return 0 end
    local val = tonumber(Result.getDataString(r, "value")) or 0
    Result.free(r)
    return val
end

local function setProsperityFund(val)
    db.query(string.format(
        "INSERT INTO `server_config` (`config`, `value`) VALUES ('z1_prosperity_fund', '%d') " ..
        "ON DUPLICATE KEY UPDATE `value` = '%d'",
        val, val
    ))
end

local function getProsperityBoostEnd()
    if not db.storeQuery then return 0 end
    local r = db.storeQuery("SELECT `value` FROM `server_config` WHERE `config` = 'z1_prosperity_boost_end'")
    if not r then return 0 end
    local val = tonumber(Result.getDataString(r, "value")) or 0
    Result.free(r)
    return val
end

local function setProsperityBoostEnd(ts)
    db.query(string.format(
        "INSERT INTO `server_config` (`config`, `value`) VALUES ('z1_prosperity_boost_end', '%d') " ..
        "ON DUPLICATE KEY UPDATE `value` = '%d'",
        ts, ts
    ))
end

local function isProsperityActive()
    return os.time() < getProsperityBoostEnd()
end

local donateCmd = TalkAction("!donate")
function donateCmd.onSay(player, words, param)
    local amount = tonumber(param)
    if not amount or amount < 1 then
        local fund = getProsperityFund()
        local boostActive = isProsperityActive()
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format(
            "[Prosperity Fund] Current: %d/%d gold ingots donated.\n" ..
            "Boost active: %s\n" ..
            "When full, all players get 2x XP for 2 hours!\n" ..
            "Type !donate [amount] to contribute.",
            fund, PROSPERITY_GOAL,
            boostActive and "YES (2x XP active!)" or "No"
        ))
        return false
    end

    local ingotId = Z1 and Z1.SET_CURRENCY_ID or 9058
    if player:getItemCount(ingotId) < amount then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You don't have that many gold ingots.")
        return false
    end

    player:removeItem(ingotId, amount)
    local fund = getProsperityFund() + amount
    setProsperityFund(fund)

    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        string.format("[Prosperity Fund] You donated %d gold ingots. Fund: %d/%d.",
            amount, fund, PROSPERITY_GOAL))

    if fund >= PROSPERITY_GOAL then
        setProsperityFund(0)  -- reset fund
        local boostEnd = os.time() + PROSPERITY_BOOST_DURATION
        setProsperityBoostEnd(boostEnd)
        Game.broadcastMessage(
            "[PROSPERITY] The city treasury is full! ALL players receive 2x XP for 2 hours! " ..
            "Thank the donors!",
            MESSAGE_EVENT_ADVANCE
        )
    end

    return false
end
donateCmd:separator(" ")
donateCmd:groupType("normal")
donateCmd:register()

-- XP bonus when prosperity boost is active.
-- Canary 3.x does not support gainexperience CreatureEvent.
-- Use onKill: add 1x baseXP on top (engine already gave 1x) = 2x total.
-- ADD TO login.lua: player:registerEvent("Z1ProsperityXP")
local prosXP = CreatureEvent("Z1ProsperityXP")
prosXP:type("kill")
prosXP:onKill(function(creature, target, lastHit)
    if not creature:isPlayer() then return true end
    if not target or not target:isMonster() then return true end
    if not isProsperityActive() then return true end
    local mType = target:getType()
    if not mType then return true end
    local baseXp = mType:getExperience()
    if not baseXp or baseXp <= 0 then return true end
    creature:addExperience(baseXp, true)  -- +1x on top of base = 2x total
    return true
end)
prosXP:register()

-- =========================================================
-- SECTION 4: WEEKLY WORLD BOSS
-- Spawns every 7 days at Thais bossArena.
-- All participants who deal damage get a fragment item.
-- =========================================================

local WORLD_BOSS_STORAGE  = 599910  -- timestamp of last world boss
local WORLD_BOSS_INTERVAL = 604800  -- 7 days
local WORLD_BOSS_NAME     = "Ghazbaran"  -- replace with your custom boss
local WORLD_BOSS_FRAGMENT_ID = Z1 and Z1.SET_CURRENCY_ID or 9058  -- give gold ingots as reward

local _worldBossActive = false
local _worldBossParticipants = {}  -- [playerId] = damage

local worldBossScheduler = GlobalEvent("Z1WorldBossScheduler")
local _lastWorldBoss = 0

function worldBossScheduler.onThink(interval)
    if _worldBossActive then return true end

    local now = os.time()
    if (now - _lastWorldBoss) < WORLD_BOSS_INTERVAL then return true end

    -- Announce 10 minutes before
    _lastWorldBoss = now
    Game.broadcastMessage(
        "[WORLD BOSS] A powerful Rift Lord will manifest at Thais in 10 minutes! Gather your strength!",
        MESSAGE_EVENT_ADVANCE
    )

    addEvent(function()
        _worldBossActive = true
        _worldBossParticipants = {}
        local boss = Game.createMonster(WORLD_BOSS_NAME, POS.worldBossSpawn, true, true)
        if boss then
            print(string.format("[Z1 World Boss] Spawned %s at %d,%d,%d",
                WORLD_BOSS_NAME, POS.worldBossSpawn.x, POS.worldBossSpawn.y, POS.worldBossSpawn.z))
            Game.broadcastMessage(
                "[WORLD BOSS] The Rift Lord has appeared at Thais! Defeat it for rare rewards!",
                MESSAGE_EVENT_ADVANCE
            )
        else
            _worldBossActive = false
            print("[Z1 World Boss] Failed to spawn " .. WORLD_BOSS_NAME)
        end
    end, 10 * 60 * 1000)

    return true
end
worldBossScheduler:interval(3600000)  -- check hourly
worldBossScheduler:register()

-- Track world boss death
local worldBossDeath = CreatureEvent("Z1WorldBossDeath")
worldBossDeath:type("death")
worldBossDeath:onDeath(function(creature, corpse, killer, mostDamage, lastHit, justify)
    if not _worldBossActive then return true end
    if creature:getName() ~= WORLD_BOSS_NAME then return true end

    _worldBossActive = false
    Game.broadcastMessage(
        "[WORLD BOSS] The Rift Lord has been defeated! Rewards are being distributed!",
        MESSAGE_EVENT_ADVANCE
    )

    -- Give rewards to all online players who are near (simplified: all online players)
    for _, player in ipairs(Game.getPlayers()) do
        local dist = player:getPosition():getDistance(POS.worldBossSpawn)
        if dist <= 50 then  -- within 50 tiles of the arena
            player:addItem(WORLD_BOSS_FRAGMENT_ID, 30)  -- 30 gold ingots
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
                "[World Boss] You helped defeat the Rift Lord and earned 30 gold ingots!")
        end
    end
    return true
end)
worldBossDeath:register()

print("[Z1 Thais Events] All systems loaded: raids, scaling daily chest, prosperity fund, world boss.")
