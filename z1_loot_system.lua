-- data/scripts/custom/z1_loot_system.lua
-- Consolidated loot file. Replaces z1_loot_command.lua and z1_riftmark_drops.lua.
--
-- CONTAINS:
--   1. !loot <name> -- bidirectional: monster->items and item->monsters
--   2. Corpse clearing -- removes default monster loot after death
--      so the server loot system has full control
--   3. Riftmark drops from elite monsters
--
-- +-------------------------------------------------------------+
-- | MANUAL STEP -- Riftmark item                                  |
-- |                                                             |
-- | Option A (recommended): add a custom item to items.xml:     |
-- |   <item id="XXXX" name="Riftmark" article="a">              |
-- |     <attribute key="weight" value="100"/>                   |
-- |     <attribute key="description" value="Prestige currency"/>|
-- |   </item>                                                   |
-- |   Then change RIFTMARK_ID below to XXXX.                    |
-- |                                                             |
-- | Option B (temporary): leave RIFTMARK_ID = 11115 to use      |
-- |   silver tokens as Riftmarks. Fully functional but cosmetic.|
-- +-------------------------------------------------------------+
--
-- login.lua: player:registerEvent("Z1LootKill")

print("[Z1 Loot System] Loading...")

-- =========================================================
-- CONFIG
-- =========================================================

local RIFTMARK_ID  = _G.Z1_RIFTMARK_ITEM_ID or 11115  -- change to your custom item ID
local CLEAR_CORPSE = false   -- set false to keep default loot while testing

-- =========================================================
-- SECTION 1: !loot -- BIDIRECTIONAL LOOKUP
-- =========================================================

local function norm(s) return (s or ""):lower():gsub("^%s+",""):gsub("%s+$","") end

local function pct(chance)
    if not chance then return "?" end
    local p = chance / 1000
    if p >= 100 then return "always"
    elseif p >= 10  then return string.format("%.1f%%", p)
    else                 return string.format("%.2f%%", p)
    end
end

local function count(n)
    return (n and n > 1) and (" x1-"..n) or ""
end

-- Monster -> loot (forward)
local function searchMonster(query)
    local idx = _G.Z1_MONSTER_LOOT_INDEX or {}
    local key = norm(query)
    if idx[key] then return idx[key], nil end
    local matches = {}
    for k, data in pairs(idx) do
        if k:find(key, 1, true) then
            matches[#matches+1] = data.name
            if #matches >= 20 then break end
        end
    end
    table.sort(matches)
    return nil, matches
end

-- Item -> monsters that drop it (reverse)
local function searchItem(query)
    local idx = _G.Z1_MONSTER_LOOT_INDEX or {}
    local key = norm(query)
    local results = {}
    for _, data in pairs(idx) do
        if data.items then
            for _, item in ipairs(data.items) do
                if norm(item.name):find(key, 1, true) then
                    results[#results+1] = {monster=data.name, item=item.name, chance=item.chance or 0, max=item.maxCount}
                end
            end
        end
    end
    table.sort(results, function(a,b) return a.chance > b.chance end)
    return results
end

local lootCmd = TalkAction("!loot")
function lootCmd.onSay(player, words, param)
    local q = norm(param)
    if q == "" then
        player:showTextDialog(639,
            "[ Loot Lookup ]\n\n" ..
            "By monster:  !loot demon\n" ..
            "By item:     !loot fire sword\n\n" ..
            "Partial names work in both modes.\n" ..
            "Results sorted by drop chance.")
        return true
    end

    -- Try monster first
    local mData, mMatches = searchMonster(q)
    if mData then
        local lines = {"[ " .. mData.name .. " ]", "Experience: " .. tostring(mData.exp or 0), ""}
        if not mData.items or #mData.items == 0 then
            lines[#lines+1] = "No loot registered."
        else
            local sorted = {}
            for _, it in ipairs(mData.items) do sorted[#sorted+1] = it end
            table.sort(sorted, function(a,b) return (a.chance or 0) > (b.chance or 0) end)
            for _, it in ipairs(sorted) do
                lines[#lines+1] = string.format("%-28s %s%s", it.name, pct(it.chance), count(it.maxCount))
            end
        end
        player:showTextDialog(639, table.concat(lines, "\n"))
        return true
    end

    -- Try item reverse search
    local iResults = searchItem(q)
    if #iResults > 0 then
        local bestName = iResults[1].item
        local lines = {"[ Dropped by: " .. bestName .. " ]", string.rep("-", 34)}
        local shown = math.min(#iResults, 30)
        for i = 1, shown do
            local r = iResults[i]
            lines[#lines+1] = string.format("%-28s %s%s", r.monster, pct(r.chance), count(r.max))
        end
        if #iResults > 30 then lines[#lines+1] = "... and " .. (#iResults-30) .. " more." end
        lines[#lines+1] = ""
        lines[#lines+1] = "Total sources: " .. #iResults .. " monster(s)"
        player:showTextDialog(639, table.concat(lines, "\n"))
        return true
    end

    -- Nothing found
    local text = "Nothing found for: \"" .. param .. "\"\n\n"
    if mMatches and #mMatches > 0 then
        text = text .. "Did you mean:\n"
        for _, name in ipairs(mMatches) do text = text .. "  " .. name .. "\n" end
    else
        text = text .. "Try: !loot demon  or  !loot fire sword"
    end
    player:showTextDialog(639, text)
    return true
end
lootCmd:setDescription("[Usage]: !loot <monster or item name>")
lootCmd:separator(" ")
lootCmd:groupType("normal")
lootCmd:register()

-- =========================================================
-- SECTION 2: KILL EVENT -- corpse clearing + Riftmark drops
-- =========================================================

-- Riftmark drop table by monster name (lowercase) -> tier
local RIFTMARK_TABLE = {
    -- Common (4%)
    wyrm="c", ["frost dragon"]="c", ["serpent spawn"]="c",
    behemoth="c", nightmare="c", hydra="c",
    -- Uncommon (8%)
    demon="u", ["dragon lord"]="u", medusa="u",
    hellhound="u", ["undead dragon"]="u", ["grim reaper"]="u", lich="u",
    -- Rare (15%)
    destroyer="r", ["dark torturer"]="r", plaguesmith="r",
    juggernaut="r", ["diabolic imp"]="r", ["demon outcast"]="r",
    -- Elite (25%)
    brachiodemon="e", ["draken elite"]="e", ["falcon paladin"]="e",
    ["cobra assassin"]="e", ["infernal phantom"]="e",
    -- Boss (60%)
    morshabaal="b", ["morshabaal's core"]="b", ferumbras="b",
    ghazbaran="b", ["magma bubble"]="b", ["duke krule"]="b",
    ["lord azaram"]="b", ["grand master oberon"]="b",
    ["the pale worm"]="b", ["the souldespoiler"]="b",
}

local RIFTMARK_TIERS = {
    c={chance=4,  min=1, max=1},
    u={chance=8,  min=1, max=2},
    r={chance=15, min=1, max=3},
    e={chance=25, min=2, max=5},
    b={chance=60, min=3, max=8},
}

local killEvent = CreatureEvent("Z1LootKill")
killEvent:type("kill")
killEvent:onKill(function(creature, target, lastHit)
    if not creature or not creature:isPlayer() then return true end
    if not target or not target:isMonster() then return true end

    local name = target:getName():lower()

    -- -- CORPSE CLEARING ------------------------------------
    -- Default monster loot drops when the monster dies (before onKill fires).
    -- We schedule a tiny delay so the corpse is fully placed, then clear it.
    if CLEAR_CORPSE then
        local pos = target:getPosition()
        local corpseId = target:getType():getCorpseId()
        if corpseId and corpseId > 0 and pos then
            addEvent(function()
                local tile = Tile(pos)
                if not tile then return end
                for _, item in ipairs(tile:getItems()) do
                    if item:getId() == corpseId and item:isContainer() then
                        for i = item:getSize() - 1, 0, -1 do
                            local lootItem = item:getItem(i)
                            if lootItem then lootItem:remove() end
                        end
                        break
                    end
                end
            end, 100)
        end
    end

    -- -- RIFTMARK DROPS -------------------------------------
    local tierKey = RIFTMARK_TABLE[name]
    if not tierKey then return true end
    local t = RIFTMARK_TIERS[tierKey]
    if not t then return true end
    if math.random(100) > t.chance then return true end
    local amount = math.random(t.min, t.max)
    local added = creature:addItem(RIFTMARK_ID, amount)
    if added then
        creature:sendTextMessage(MESSAGE_LOOT,
            string.format("You found %d Riftmark%s from %s.",
                amount, amount>1 and "s" or "", target:getName()))
    end

    return true
end)
killEvent:register()

_G.Z1_RIFTMARK_ITEM_ID = RIFTMARK_ID

print(string.format("[Z1 Loot System] Loaded. !loot active. Riftmark ID=%d. Corpse clearing=%s.",
    RIFTMARK_ID, tostring(CLEAR_CORPSE)))
print("[Z1 Loot System] ADD to login.lua: player:registerEvent('Z1LootKill')")
print("[Z1 Loot System] Set CLEAR_CORPSE=false to temporarily keep default loot while testing.")
