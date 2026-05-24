-- data/scripts/custom/z1_prestige.lua
-- Z1 Prestige / Ascension v5
--
-- Changes from v4:
--   - Speed bonus: now +10% of base speed per rank (not flat +10)
--   - Vocation: resets to unpromoted version (Master Sorcerer -> Sorcerer, etc.)
--   - Skills: each kill adds bonus skill tries proportional to rank
--   - Morshabaal kill event registered on login for the Z forge
--
-- !prestige       -> ModalWindow confirmation dialog
-- !prestigeinfo   -> shows rank, bonuses, vocation note

print("[Z1 Prestige] Loading v5 -- % speed, vocation reset, skill gain...")

-- =========================================================
-- CONFIG
-- =========================================================

local REQUIRED_LEVEL    = 10000
local RESET_LEVEL       = 1000
local MAX_RANK          = 10
local RIFTMARK_ITEM_ID  = 39040
local RIFTMARK_REWARD   = 1

local XP_BONUS_PER_RANK    = 10   -- % extra XP per rank per kill
local SPEED_PCT_PER_RANK   = 10   -- % of base speed added per rank
local SKILL_TRIES_PER_RANK = 8    -- bonus skill tries added per kill per rank

local STORAGE_RANK          = 590001
local STORAGE_SPEED_APPLIED = 590002
local STORAGE_LAST_PRESTIGE = 590003
local STORAGE_PENDING       = 590004

local PRESTIGE_WINDOW_ID = 59001

_G.Z1_PRESTIGE_RANK_STORAGE = STORAGE_RANK

-- =========================================================
-- VOCATION RESET MAP
-- Promoted voc -> base (unpromoted) voc
-- Player must pay for promotion again after prestige.
-- =========================================================

local VOCATION_BASE = {
    [5] = 1,  -- Master Sorcerer  -> Sorcerer
    [6] = 2,  -- Elder Druid      -> Druid
    [7] = 3,  -- Royal Paladin    -> Paladin
    [8] = 4,  -- Elite Knight     -> Knight
    -- Already base vocs -- keep as-is
    [1] = 1, [2] = 2, [3] = 3, [4] = 4,
}

local VOC_NAME = {
    [1]="Sorcerer", [2]="Druid", [3]="Paladin", [4]="Knight",
    [5]="Master Sorcerer", [6]="Elder Druid", [7]="Royal Paladin", [8]="Elite Knight",
}

-- Skills that receive bonus tries on kill
local BONUS_SKILLS = {
    SKILL_SWORD, SKILL_AXE, SKILL_CLUB,
    SKILL_DISTANCE, SKILL_SHIELDING, SKILL_FIST,
}

-- =========================================================
-- HELPERS
-- =========================================================

local function getRank(player)
    return math.max(0, player:getStorageValue(STORAGE_RANK))
end

local function expForLevel(level)
    return math.floor(((50 * level * level * level) - (150 * level * level) + (400 * level)) / 3)
end

local function send(player, text)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, text)
end

-- Base speed formula: 220 + (2 x level) -- mirrors vanilla Tibia
local function baseSpeed(level)
    return 220 + (2 * level)
end

local function applyPrestigeSpeed(player)
    local prev = player:getStorageValue(STORAGE_SPEED_APPLIED)
    if prev and prev > 0 then player:changeSpeed(-prev) end

    local rank = getRank(player)
    if rank <= 0 then
        player:setStorageValue(STORAGE_SPEED_APPLIED, 0)
        return
    end

    -- +10% of base speed per rank (calculated at current level)
    local pct   = rank * SPEED_PCT_PER_RANK / 100
    local bonus = math.floor(baseSpeed(player:getLevel()) * pct)

    if bonus > 0 then
        player:changeSpeed(bonus)
        player:setStorageValue(STORAGE_SPEED_APPLIED, bonus)
    else
        player:setStorageValue(STORAGE_SPEED_APPLIED, 0)
    end
end

local function resetVocation(player)
    local vocId   = player:getVocation():getId()
    local baseVoc = VOCATION_BASE[vocId] or vocId
    -- Set via DB so it persists correctly after logout/level-reset
    db.query(string.format(
        "UPDATE `players` SET `vocation` = %d WHERE `id` = %d",
        baseVoc, player:getGuid()))
    return VOC_NAME[baseVoc] or ("vocation " .. baseVoc)
end

local function resetPlayerLevelAfterLogout(guid)
    local exp = expForLevel(RESET_LEVEL)
    db.query(string.format(
        "UPDATE `players` SET `level` = %d, `experience` = %d WHERE `id` = %d",
        RESET_LEVEL, exp, guid))
    print(string.format("[Z1 Prestige] guid %d reset -> level %d / exp %d.", guid, RESET_LEVEL, exp))
end

-- =========================================================
-- EXECUTE PRESTIGE
-- =========================================================

local function executePrestige(player)
    local rank = getRank(player)
    if rank >= MAX_RANK then
        send(player, "[Prestige] Maximum rank already reached.")
        return
    end
    if player:getLevel() < REQUIRED_LEVEL then
        send(player, string.format("[Prestige] Need level %d to ascend.", REQUIRED_LEVEL))
        return
    end

    local newRank  = rank + 1
    local guid     = player:getGuid()
    local pid      = player:getId()

    player:setStorageValue(STORAGE_RANK, newRank)
    player:setStorageValue(STORAGE_LAST_PRESTIGE, os.time())
    player:setStorageValue(STORAGE_PENDING, 0)

    -- Reward Riftmarks
    if RIFTMARK_ITEM_ID and RIFTMARK_ITEM_ID > 0 then
        player:addItem(RIFTMARK_ITEM_ID, RIFTMARK_REWARD)
    end

    -- Reset vocation to base (unpromoted) -- persisted via DB
    local baseVocName = resetVocation(player)

    -- Speed bonus re-calculated at level 1000 after reset
    local newSpeedBonus = math.floor(baseSpeed(RESET_LEVEL) * (newRank * SPEED_PCT_PER_RANK / 100))

    Game.broadcastMessage(string.format(
        "[Ascension] %s has transcended mortality -- Prestige Rank %d. The Rift bends to their will.",
        player:getName(), newRank), MESSAGE_EVENT_ADVANCE)

    send(player, string.format(
        "[Ascension] Rank %d achieved.\n" ..
        "Level resets to %d. Vocation resets to %s (pay for promotion again).\n" ..
        "Z weapons stay equipped at any level.\n\n" ..
        "+%d%% XP per kill  |  +%d%% speed (%d flat at lv%d)  |  +%d Riftmarks\n" ..
        "Skills gain %d extra tries per kill.\n\n" ..
        "The Rift awaits your return.",
        newRank, RESET_LEVEL, baseVocName,
        newRank * XP_BONUS_PER_RANK,
        newRank * SPEED_PCT_PER_RANK, newSpeedBonus, RESET_LEVEL,
        RIFTMARK_REWARD,
        newRank * SKILL_TRIES_PER_RANK))

    player:save()
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

    addEvent(function()
        local p = Player(pid)
        if p then p:remove() end
    end, 800)

    addEvent(function()
        resetPlayerLevelAfterLogout(guid)
    end, 2500)
end

-- =========================================================
-- !prestige -- ModalWindow
-- =========================================================

local prestigeCmd = TalkAction("!prestige")

function prestigeCmd.onSay(player, words, param)
    local rank = getRank(player)

    if rank >= MAX_RANK then
        send(player, "[Prestige] Maximum rank " .. MAX_RANK .. " achieved. You are already a legend.")
        return true
    end
    if player:getLevel() < REQUIRED_LEVEL then
        send(player, string.format("[Prestige] Need level %d. Your level: %d.", REQUIRED_LEVEL, player:getLevel()))
        return true
    end
    local last = player:getStorageValue(STORAGE_LAST_PRESTIGE)
    if last > 0 and os.time() - last < 10 then
        send(player, "[Prestige] The Rift is still settling. Wait a moment.")
        return true
    end
    if player:getStorageValue(STORAGE_PENDING) == 1 then
        send(player, "[Prestige] Close the current window first.")
        return true
    end

    local newRank    = rank + 1
    local xpBonus    = newRank * XP_BONUS_PER_RANK
    local spdBonus   = math.floor(baseSpeed(RESET_LEVEL) * (newRank * SPEED_PCT_PER_RANK / 100))
    local vocId      = player:getVocation():getId()
    local baseVocName = VOC_NAME[VOCATION_BASE[vocId] or vocId] or "base vocation"

    local msg = string.format(
        "You stand at the threshold of Ascension.\n" ..
        "Transcending to Prestige Rank %d of %d.\n\n" ..
        "Your level resets to %d.\n" ..
        "Vocation resets to %s -- pay for promotion again.\n" ..
        "Z weapons stay equipped at any level.\n\n" ..
        "YOU KEEP:\n" ..
        "  All items, Z gear, backpacks\n" ..
        "  Skills, magic level, offline training\n" ..
        "  Quests, storages and house\n\n" ..
        "YOU GAIN PERMANENTLY:\n" ..
        "  +%d%% experience per kill (cumulative)\n" ..
        "  +%d%% speed (+%d at lv%d, cumulative)\n" ..
        "  +%d skill tries per kill (all skills)\n" ..
        "  %d Riftmarks (prestige currency)\n\n" ..
        "Vocation resets so you relive the journey.\n" ..
        "This cannot be undone. Will you ascend?",
        newRank, MAX_RANK,
        RESET_LEVEL,
        baseVocName,
        xpBonus,
        newRank * SPEED_PCT_PER_RANK, spdBonus, RESET_LEVEL,
        newRank * SKILL_TRIES_PER_RANK,
        RIFTMARK_REWARD
    )

    local window = ModalWindow(PRESTIGE_WINDOW_ID, "Ascension -- Prestige Rank " .. newRank, msg)
    window:addButton(1, "Ascend")
    window:addButton(0, "Cancel")
    window:setDefaultEnterButton(1)
    window:setDefaultEscapeButton(0)
    window:sendToPlayer(player)

    player:setStorageValue(STORAGE_PENDING, 1)
    return true
end

prestigeCmd:setDescription("at level 10000, opens the Ascension window to prestige to the next rank.")
prestigeCmd:separator(" ")
prestigeCmd:groupType("normal")
prestigeCmd:register()

-- =========================================================
-- MODAL RESPONSE
-- =========================================================

local modalEvent = CreatureEvent("Z1PrestigeModal")
modalEvent:type("modalwindow")
modalEvent:onModalWindow(function(player, modalWindowId, buttonId, choiceId)
    if modalWindowId ~= PRESTIGE_WINDOW_ID then return true end
    player:setStorageValue(STORAGE_PENDING, 0)
    if buttonId == 1 then
        executePrestige(player)
    else
        send(player, "[Prestige] Ascension cancelled. The Rift endures.")
    end
    return true
end)
modalEvent:register()

-- =========================================================
-- !prestigeinfo
-- =========================================================

local prestigeInfo = TalkAction("!prestigeinfo")

function prestigeInfo.onSay(player, words, param)
    local rank  = getRank(player)
    local lines = {}
    local function add(s) lines[#lines + 1] = s end
    local vocId     = player:getVocation():getId()
    local vocName   = VOC_NAME[vocId] or "unknown"

    add("[ Prestige -- Ascension System ]")
    add(string.rep("-", 36))
    add(string.format("Your rank      :  %d / %d", rank, MAX_RANK))
    add(string.format("Required level :  %d", REQUIRED_LEVEL))
    add(string.format("Reset level    :  %d  (Z3 minimum floor)", RESET_LEVEL))
    add(string.format("Vocation reset :  %s  (back to base, re-promote)", vocName))
    add("")
    if rank > 0 then
        local spdBonus = math.floor(baseSpeed(player:getLevel()) * (rank * SPEED_PCT_PER_RANK / 100))
        add(string.format("XP bonus       :  +%d%% per kill", rank * XP_BONUS_PER_RANK))
        add(string.format("Speed bonus    :  +%d%% (~%d at current level)", rank * SPEED_PCT_PER_RANK, spdBonus))
        add(string.format("Skill tries    :  +%d per kill (all skills)", rank * SKILL_TRIES_PER_RANK))
    else
        add("XP bonus       :  none yet -- prestige to unlock")
        add("Speed bonus    :  none yet")
        add("Skill tries    :  none yet")
    end
    if rank < MAX_RANK then
        add("")
        add("Next rank gains:")
        local nr = rank + 1
        local nsb = math.floor(baseSpeed(player:getLevel()) * (nr * SPEED_PCT_PER_RANK / 100))
        add(string.format("  +%d%% XP  |  +%d%% speed (~%d)  |  +%d skill tries  |  %d Riftmarks",
            nr * XP_BONUS_PER_RANK, nr * SPEED_PCT_PER_RANK, nsb,
            nr * SKILL_TRIES_PER_RANK, RIFTMARK_REWARD))
    else
        add("")
        add("MAXIMUM RANK REACHED. No further ascension.")
    end
    add("")
    add(string.rep("-", 36))
    add("KEPT ON RESET: items, Z gear, skills, quests, house")
    add("RESET: level, vocation promotion (re-promote to unlock spells)")
    add("")
    add("!prestige at level " .. REQUIRED_LEVEL .. " to open the Ascension window.")
    add("!tiers -- weapon/armor stats.  !morshkills -- Z forge progress.")

    player:showTextDialog(639, table.concat(lines, "\n"))
    return true
end

prestigeInfo:setDescription("shows your prestige rank, bonuses, and reset rules.")
prestigeInfo:groupType("normal")
prestigeInfo:register()

-- =========================================================
-- LOGIN -- register all events, reapply speed, clear stale flags
-- =========================================================

local loginEvent = CreatureEvent("Z1PrestigeLogin")
loginEvent:type("login")
loginEvent:onLogin(function(player)
    applyPrestigeSpeed(player)
    player:setStorageValue(STORAGE_PENDING, 0)
    player:registerEvent("Z1PrestigeModal")
    player:registerEvent("Z1PrestigeXP")
    player:registerEvent("Z1PrestigeInspect")
    player:registerEvent("Z1PrestigeGlow")    -- aura effect by rank
    player:registerEvent("Z1MorshabaalKill")  -- for Z forge kill counter
    player:registerEvent("Z1FieryTearDrop")   -- elite monster Riftmark drops
    player:registerEvent("Z1ArrowStrike")     -- Z arrows for paladins
    return true
end)
loginEvent:register()

-- =========================================================
-- KILL -- XP bonus + skill bonus per rank
-- =========================================================

local xpEvent = CreatureEvent("Z1PrestigeXP")
xpEvent:type("kill")
xpEvent:onKill(function(creature, target, lastHit)
    if not creature or not creature:isPlayer() then return true end
    if not target or not target:isMonster() then return true end
    local rank = getRank(creature)
    if rank <= 0 then return true end

    local mType = target:getType()
    if not mType then return true end
    local baseXp = mType:getExperience()

    -- XP bonus
    if baseXp and baseXp > 0 then
        local bonus = math.floor(baseXp * ((rank * XP_BONUS_PER_RANK) / 100))
        if bonus > 0 then creature:addExperience(bonus, true) end
    end

    -- Skill gain bonus -- add extra tries to all combat skills
    -- This bypasses whatever skill cap is in config by directly crediting tries
    local skillBonus = rank * SKILL_TRIES_PER_RANK
    if skillBonus > 0 then
        for _, skillId in ipairs(BONUS_SKILLS) do
            pcall(function() creature:addSkillTries(skillId, skillBonus) end)
        end
        -- Magic level tries too (expressed as mana spent)
        pcall(function() creature:addManaSpent(rank * 20) end)
    end

    return true
end)
xpEvent:register()

print("[Z1 Prestige] v5 loaded. % speed, vocation reset, skill gains per kill.")
print("[Z1 Prestige] !prestige -> ModalWindow | !prestigeinfo -> stats | !morshkills -> forge progress")
