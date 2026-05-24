-- data/scripts/custom/z1_set_tiers.lua
-- Game set tiers, protection tables, and simple overall protection preview.

print("[Z1 Set Tiers] Loading...")

_G.Z1Sets = _G.Z1Sets or {}
Z1Sets.elements = {"Physical", "Fire", "Poison", "Ice", "Energy", "Holy", "Death"}

-- Design model for your server progression. These are target protection identities, not every exact item attribute.
Z1Sets.tiers = {
    [1] = {
        name = "Tier 1", theme = "Starter / Quest Sets",
        sets = {
            { name = "Crown",     protection = {Physical=5, Fire=0, Poison=0, Ice=0, Energy=0, Holy=0, Death=0} },
            { name = "Dragon",    protection = {Physical=7, Fire=15, Poison=0, Ice=-5, Energy=0, Holy=0, Death=0} },
            { name = "Demon",     protection = {Physical=8, Fire=8, Poison=0, Ice=0, Energy=0, Holy=0, Death=8} },
        }
    },
    [2] = {
        name = "Tier 2", theme = "Advanced / Forge Sets",
        sets = {
            { name = "Golden",    protection = {Physical=10, Fire=3, Poison=0, Ice=0, Energy=3, Holy=0, Death=0} },
            { name = "Prismatic", protection = {Physical=15, Fire=0, Poison=0, Ice=0, Energy=10, Holy=0, Death=3} },
            { name = "Cobra",     protection = {Physical=12, Fire=-5, Poison=8, Ice=0, Energy=0, Holy=0, Death=8} },
            { name = "Falcon",    protection = {Physical=20, Fire=15, Poison=0, Ice=7, Energy=0, Holy=0, Death=0} },
        }
    },
    [3] = {
        name = "Tier 3", theme = "Endgame / Prestige Sets",
        sets = {
            { name = "Soul",      protection = {Physical=18, Fire=5, Poison=0, Ice=12, Energy=0, Holy=7, Death=12} },
            { name = "Sanguine",  protection = {Physical=20, Fire=8, Poison=0, Ice=8, Energy=9, Holy=0, Death=7} },
            { name = "Z1",        protection = {Physical=25, Fire=15, Poison=15, Ice=15, Energy=15, Holy=10, Death=15} },
        }
    }
}

local BOOK_ID = 639
local function pad(s, n) s = tostring(s or ""); if #s >= n then return s end; return s .. string.rep(" ", n - #s) end

local tiersCmd = TalkAction("!sets")
function tiersCmd.onSay(player, words, param)
    local lines = {"Z1 Game Sets", "", "Elements: Physical, Fire, Poison, Ice, Energy, Holy, Death", ""}
    for tierNo = 1, 3 do
        local tier = Z1Sets.tiers[tierNo]
        lines[#lines+1] = tier.name .. " - " .. tier.theme
        lines[#lines+1] = pad("Set", 11) .. " Phy Fire Pois Ice  Enr Holy Death"
        for _, set in ipairs(tier.sets) do
            local p = set.protection
            lines[#lines+1] = pad(set.name, 11) .. string.format(" %3s %4s %4s %3s %4s %4s %5s",
                p.Physical or 0, p.Fire or 0, p.Poison or 0, p.Ice or 0, p.Energy or 0, p.Holy or 0, p.Death or 0)
        end
        lines[#lines+1] = ""
    end
    player:showTextDialog(BOOK_ID, table.concat(lines, "\n"))
    return true
end
tiersCmd:setDescription("shows server set tiers and elemental protection roles.")
tiersCmd:groupType("normal")
tiersCmd:register()

-- Alias: !tiers should point to this same set-table concept if no other file owns it.
local tiersAlias = TalkAction("!tiers")
function tiersAlias.onSay(player, words, param) return tiersCmd.onSay(player, words, param) end
tiersAlias:setDescription("shows server set tiers and elemental protection roles.")
tiersAlias:groupType("normal")
tiersAlias:register()

local protectionCmd = TalkAction("!protection")
function protectionCmd.onSay(player, words, param)
    local lines = {"Overall Protection", "", "This command currently shows the set-design reference.", "Exact equipped-item calculation will be connected after final item IDs are locked.", "", "Use !sets to view all tier tables."}
    player:showTextDialog(BOOK_ID, table.concat(lines, "\n"))
    return true
end
protectionCmd:setDescription("shows your overall protection summary or the current protection model.")
protectionCmd:groupType("normal")
protectionCmd:register()

print("[Z1 Set Tiers] Loaded commands: !sets, !tiers, !protection")
