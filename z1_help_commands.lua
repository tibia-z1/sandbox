-- data/scripts/custom/z1_help_commands.lua
-- Clean table-format command reference.
-- IMPORTANT: only registers !commands here.
-- !loot is in z1_loot_system.lua
-- !forge is in z1_weapon_upgrade.lua
-- !online, !inspect are in z1_player_commands.lua
-- !prestige is in z1_prestige.lua
-- !spells is in z1_spells_command.lua
-- !daychest, !donate are in z1_thais_events.lua
-- !promotion is in z1_promote.lua

print("[Z1 Help] Loading table-format command manual...")

local BOOK_ID = 639

local function canAdmin(player)
    local g = player and player:getGroup()
    return g and g:getId() >= 3
end

local function buildHelp(player)
    local t = {}
    local function add(s) t[#t+1] = s end
    local W = 42  -- total width

    local function row(cmd, desc)
        local gap = W - #cmd - #desc - 2
        add("  " .. cmd .. string.rep(" ", math.max(1, gap)) .. desc)
    end

    local function section(name)
        add("")
        add("  " .. name)
        add("  " .. string.rep("-", W - 2))
    end

    add("  " .. string.rep("=", W - 2))
    add("     ZERO1 LABS  -- Player Commands")
    add("  " .. string.rep("=", W - 2))

    section("NAVIGATION")
    row("!online",         "Online players + prestige ranks")
    row("!inspect <name>", "Inspect any online player")

    section("PROGRESSION")
    row("!promotion",      "Promote vocation (2 gold ingots)")
    row("!prestige",       "Ascension unlock (level 10,000)")
    row("!forge",          "Z weapon upgrade status + costs")

    section("LOOKUP")
    row("!loot <name>",    "Monster drops or who drops an item")
    row("!spells",         "Your vocation spellbook")

    section("EVENTS")
    row("!daychest",       "Daily chest status & upgrade")
    row("!donate <n>",     "Donate ingots to prosperity fund")

    add("")
    add("  " .. string.rep("-", W - 2))
    add("  Tip: !loot fire sword finds who drops it.")
    add("       !loot demon shows Demon's full loot.")
    add("  " .. string.rep("=", W - 2))

    if canAdmin(player) then
        add("")
        add("  ADMIN ONLY")
        add("  " .. string.rep("-", W - 2))
        row("/z1marketseed", "Rebuild depot market seller")
        row("/z1stock",      "Give test items to yourself")
        row("/z1look <id>",  "Test monster outfit lookType")
        row("/z1huntlooks",  "Debug hunt room appearances")
        row("!resetclaim",   "Reset player claim storage")
        add("  " .. string.rep("-", W - 2))
    end

    return table.concat(t, "\n")
end

local helpCmd = TalkAction("!commands")
function helpCmd.onSay(player, words, param)
    player:showTextDialog(BOOK_ID, buildHelp(player))
    return false
end
helpCmd:separator(" ")
helpCmd:groupType("normal")
helpCmd:register()

print("[Z1 Help] Table-format command manual loaded.")
