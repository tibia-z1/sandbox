-- data/scripts/custom/z1_spells_command.lua
-- Compact vocation spellbook table. Filters out monster/internal spells.

print("[Z1 Spells] Loading compact vocation spellbook v8...")

local DIALOG_ITEM = 3059

local function clean(s) return tostring(s or ""):lower() end

local function getVocationName(player)
    local voc = player:getVocation()
    if not voc then return "unknown" end
    local name = voc:getName()
    if name and name ~= "" then return name end
    return "vocation " .. tostring(voc:getId())
end

local function isInternalSpell(spell)
    local words = clean(spell.words or spell.spellWords or spell.name)
    local name = clean(spell.name or spell.spellName or "")
    if words:find("###", 1, true) or name:find("###", 1, true) then return true end
    if words == "" then return true end
    if words:find("paralyze") or words:find("skill reducer") or words:find("summon") then return true end
    if name:find("paralyze") or name:find("skill reducer") or name:find("summon") then return true end
    return false
end

local function spellWords(spell)
    return spell.words or spell.spellWords or spell.name or "?"
end
local function spellName(spell)
    return spell.name or spell.spellName or spellWords(spell)
end
local function spellLevel(spell)
    return tonumber(spell.level or spell.lvl or spell.minLevel or 0) or 0
end
local function spellMana(spell)
    return tonumber(spell.mana or spell.manaCost or 0) or 0
end

local function categoryOf(spell)
    local words = clean(spellWords(spell))
    local name = clean(spellName(spell))
    if words:find("adori") or words:find("adevo") or words:find("adana") or words:find("adito") then return "Runes / Conjuring" end
    if words:find("exura") or name:find("healing") or name:find("heal") or words:find("utura") then return "Healing" end
    if words:find("utani") or words:find("utamo") or words:find("utito") or words:find("exana") or words:find("exiva") or words:find("exani") or words:find("utevo") then return "Support / Utility" end
    return "Attack"
end

local function getSpells(player)
    local ok, spells = pcall(function() return player:getInstantSpells() end)
    if not ok or type(spells) ~= "table" then return {} end
    local out = {}
    for _, s in ipairs(spells) do
        if type(s) == "table" and not isInternalSpell(s) then out[#out+1] = s end
    end
    table.sort(out, function(a,b)
        local ca, cb = categoryOf(a), categoryOf(b)
        if ca ~= cb then return ca < cb end
        local la, lb = spellLevel(a), spellLevel(b)
        if la ~= lb then return la < lb end
        return spellName(a) < spellName(b)
    end)
    return out
end

local function addTable(lines, category, spells)
    if #spells == 0 then return end
    lines[#lines+1] = ""
    lines[#lines+1] = category
    lines[#lines+1] = string.format("%-6s | %-24s | %-28s | %-5s", "Level", "Words", "Spell", "Mana")
    lines[#lines+1] = string.rep("-", 42)
    for _, s in ipairs(spells) do
        lines[#lines+1] = string.format("%-6d | %-24s | %-28s | %-5d", spellLevel(s), spellWords(s), spellName(s), spellMana(s))
    end
end

local cmd = TalkAction("!spells")
function cmd.onSay(player, words, param)
    local spells = getSpells(player)
    local byCat = { ["Attack"]={}, ["Healing"]={}, ["Support / Utility"]={}, ["Runes / Conjuring"]={} }
    for _, s in ipairs(spells) do byCat[categoryOf(s)][#byCat[categoryOf(s)] + 1] = s end

    local lines = {}
    lines[#lines+1] = "Spellbook - " .. getVocationName(player)
    lines[#lines+1] = "Level: " .. player:getLevel() .. " | Magic Level: " .. player:getMagicLevel()
    lines[#lines+1] = "Use the exact words shown below."
    addTable(lines, "Attack", byCat["Attack"])
    addTable(lines, "Healing", byCat["Healing"])
    addTable(lines, "Support / Utility", byCat["Support / Utility"])
    addTable(lines, "Runes / Conjuring", byCat["Runes / Conjuring"])
    if #spells == 0 then lines[#lines+1] = "No vocation spells were returned by the server API." end
    player:showTextDialog(DIALOG_ITEM, table.concat(lines, "\n"))
    return true
end
cmd:setDescription("shows your vocation spellbook grouped by attack, healing, support, and runes.")
cmd:groupType("normal")
cmd:register()

print("[Z1 Spells] v8 loaded.")
