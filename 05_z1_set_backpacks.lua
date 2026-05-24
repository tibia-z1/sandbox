-- 05_z1_set_backpacks.lua
-- Adds a themed backpack to every Z1 set reward.
-- Must run AFTER 00_z1_core.lua (filename 05_ guarantees this).
--
-- SELECTION CRITERIA:
--   1. Theme match with the set name/aesthetic
--   2. Volume efficiency (weight/slot ratio) scales with set tier
--
-- BACKPACK STATS (lower ratio = better):
--   Ghost Backpack      26 slots  5.00 wt  0.19  <- best in game
--   Backpack of Holding 24 slots 15.00 wt  0.63
--   Winged Backpack     24 slots 15.00 wt  0.63
--   Jewelled Backpack   22 slots 17.00 wt  0.77
--   Crown Backpack      20 slots 17.00 wt  0.85
--   Dragon Backpack     20 slots 17.00 wt  0.85
--   Dem/Crystal/etc.    20 slots 18.00 wt  0.90
--   Golden Backpack     20 slots 18.00 wt  0.90  <- SKIPPED: too plain for lv800
--
-- ASSIGNMENTS (theme + volume):
--   chain      lv1     Old and Used Backpack   20 / 0.90  starter feel
--   crown      lv80    Crown Backpack          20 / 0.85  exact match
--   dragon     lv180   Dragon Backpack         20 / 0.85  exact match
--   demon      lv400   Demon Backpack          20 / 0.90  exact match
--   golden     lv800   Jewelled Backpack       22 / 0.77  precious > plain golden
--   prismatic  lv1400  Crystal Backpack        20 / 0.90  crystal = prismatic
--   cobra      lv2800  Camouflage Backpack     20 / 0.90  snake/jungle camo
--   falcon     lv4500  Winged Backpack         24 / 0.63  wings + great volume
--   soul       lv7000  Backpack of Holding     24 / 0.63  holds souls + great volume
--   sanguine   lv10000 Ghost Backpack          26 / 0.19  ethereal + best bag in game

local Z1 = _G.Z1
if not Z1 or not Z1.SET_TRIALS then
    print("[Z1 Set Backpacks] ERROR: 00_z1_core.lua must load first.")
    return
end

local SET_BACKPACKS = {
    chain     = "old and used backpack",
    crown     = "crown backpack",
    dragon    = "dragon backpack",
    demon     = "demon backpack",
    golden    = "jewelled backpack",
    prismatic = "crystal backpack",
    cobra     = "camouflage backpack",
    falcon    = "winged backpack",
    soul      = "backpack of holding",
    sanguine  = "ghost backpack",
}

local function resolveId(name)
    local id = ItemType(name):getId()
    return (id and id > 0) and id or nil
end

local injected = 0
local missing  = {}

for _, trial in ipairs(Z1.SET_TRIALS) do
    local bpName = SET_BACKPACKS[trial.key]
    if bpName then
        local id = resolveId(bpName)
        if id then
            table.insert(trial.rewards, 1, Z1.makeReward({bpName}))
            injected = injected + 1
            print(string.format("[Z1 Set Backpacks] %s -> %s (id=%d)", trial.key, bpName, id))
        else
            table.insert(missing, string.format("  %-12s -> '%s' (not in items.xml)", trial.key, bpName))
        end
    end
end

if #missing > 0 then
    print("[Z1 Set Backpacks] WARNING - could not resolve:")
    for _, m in ipairs(missing) do print(m) end
end

print(string.format("[Z1 Set Backpacks] Injected %d/%d set backpacks.", injected, #Z1.SET_TRIALS))
