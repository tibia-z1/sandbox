-- data/scripts/custom/z1_player_commands.lua
-- !online, !inspect -- utility commands + prestige description on login
-- NOTE: !forge lives in z1_weapon_upgrade.lua
-- NOTE: !promotion lives in z1_promote.lua

print("[Z1 Player Commands] Loading...")

local RANK_STORAGE = _G.Z1_PRESTIGE_RANK_STORAGE or 590001

local RANK_TITLES = {
    [1]="Rift Touched",  [2]="Rift Walker",    [3]="Rift Seeker",
    [4]="Rift Breaker",  [5]="Rift Strider",   [6]="Rift Warden",
    [7]="Rift Champion", [8]="Rift Sovereign",  [9]="Rift Ascendant",
    [10]="Rift Lord",
}

local function getRank(player)
    local v = player:getStorageValue(RANK_STORAGE)
    return math.max(0, v or 0)
end

-- =========================================================
-- PRESTIGE DESCRIPTION  -- right-click look window
-- Badge format: [P2] Rift Walker
-- =========================================================

local function updateDescription(player)
    local rank = getRank(player)
    if rank <= 0 then
        pcall(function() player:setDescription("") end)
        return
    end
    local title = RANK_TITLES[rank] or ("Prestige Rank " .. rank)
    pcall(function() player:setDescription(string.format("[P%d] %s", rank, title)) end)
end

-- =========================================================
-- !online
-- =========================================================

local onlineCmd = TalkAction("!online")
function onlineCmd.onSay(player, words, param)
    local players = Game.getPlayers()
    if not players or #players == 0 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "No players online.")
        return true
    end

    table.sort(players, function(a, b)
        local ra, rb = getRank(a), getRank(b)
        if ra ~= rb then return ra > rb end
        return (a:getLevel() or 0) > (b:getLevel() or 0)
    end)

    local W = 44
    local t = {}
    local function add(s) t[#t+1] = s end

    add(string.format("  Online Players: %d", #players))
    add("  " .. string.rep("-", W-2))
    add(string.format("  %-18s %-8s %s", "Name", "Level", "Prestige"))
    add("  " .. string.rep("-", W-2))

    for _, p in ipairs(players) do
        local rank    = getRank(p)
        local rankStr = rank > 0
            and string.format("[P%d] %s", rank, RANK_TITLES[rank] or "")
            or  "-"
        add(string.format("  %-18s %-8d %s", p:getName(), p:getLevel() or 0, rankStr))
    end

    add("  " .. string.rep("-", W-2))
    player:showTextDialog(639, table.concat(t, "\n"))
    return true
end
onlineCmd:setDescription("Lists all online players with level and prestige rank.")
onlineCmd:groupType("normal")
onlineCmd:register()

-- =========================================================
-- !inspect <name>
-- =========================================================

local inspectCmd = TalkAction("!inspect")
function inspectCmd.onSay(player, words, param)
    if not param or param == "" then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Usage: !inspect <player name>")
        return true
    end
    local target = Player(param)
    if not target then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "'" .. param .. "' is not online.")
        return true
    end
    local rank  = getRank(target)
    local voc   = target:getVocation()
    local W = 34
    local t = {
        "  " .. string.rep("-", W),
        string.format("  Inspecting: %s", target:getName()),
        "  " .. string.rep("-", W),
        string.format("  Level    : %d", target:getLevel() or 0),
        string.format("  Vocation : %s", (voc and voc:getName()) or "unknown"),
        string.format("  Prestige : %s",
            rank > 0 and string.format("[P%d] %s", rank, RANK_TITLES[rank] or "")
                      or "Not ascended"),
        "  " .. string.rep("-", W),
    }
    player:showTextDialog(639, table.concat(t, "\n"))
    return true
end
inspectCmd:setDescription("[Usage]: !inspect <name>")
inspectCmd:separator(" ")
inspectCmd:groupType("normal")
inspectCmd:register()

-- =========================================================
-- !resetclaim <name>  -- GM command: resets all claim storage
-- =========================================================

local resetCmd = TalkAction("!resetclaim")
function resetCmd.onSay(player, words, param)
    local group = player:getGroup()
    if not group or group:getId() < 3 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Access denied.")
        return false
    end

    local targetName = param and param:match("^%s*(.-)%s*$") or ""
    local target = targetName ~= "" and Player(targetName) or player
    if not target then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Player '" .. targetName .. "' is not online.")
        return false
    end

    local r   = _G.Z1Rift or {}
    local z1  = _G.Z1    or {}
    local keys = {}
    -- Armor set storages
    local sets = r.armorSets or {}
    for _, s in pairs(sets) do
        if s.storage then keys[#keys+1] = s.storage end
    end
    -- Weapon tier claim storages
    local wStores = r.claimStorages or {}
    for _, s in pairs(wStores) do keys[#keys+1] = s end
    -- Equipment set storages
    for _, trial in ipairs(z1.SET_TRIALS or {}) do
        if trial.storage then keys[#keys+1] = trial.storage end
    end
    -- Prestige rank storage
    keys[#keys+1] = _G.Z1_PRESTIGE_RANK_STORAGE or 590001

    local count = 0
    for _, k in ipairs(keys) do
        target:setStorageValue(k, -1)
        count = count + 1
    end

    local msg = string.format("[GM] Reset %d claim storage keys for %s.", count, target:getName())
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, msg)
    target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[GM] Your claim progress was reset by staff.")
    print(msg)
    return false
end
resetCmd:separator(" ")
resetCmd:setDescription("[GM] Resets all armor/weapon/set claim storage. Usage: !resetclaim <name>")
resetCmd:groupType("gamemaster")
resetCmd:register()

-- =========================================================
-- LOGIN
-- =========================================================

local loginEv = CreatureEvent("Z1PlayerLogin")
loginEv:type("login")
loginEv:onLogin(function(player)
    if not player then return true end
    updateDescription(player)
    player:registerEvent("Z1LootKill")
    player:registerEvent("Z1WeaponThink")
    player:registerEvent("Z1WeaponSelectModal")  -- weapon choice modal for Z3 claim
    player:registerEvent("Z1ArmorConfirmModal")  -- armor set confirmation modal
    player:registerEvent("Z1ProsperityXP")       -- 2x XP when prosperity fund is full
    return true
end)
loginEv:register()

print("[Z1 Player Commands] !online, !inspect, !resetclaim loaded.")
print("[Z1 Player Commands] Login event: Z1PlayerLogin registered.")
