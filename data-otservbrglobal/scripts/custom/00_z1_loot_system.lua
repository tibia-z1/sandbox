-- Z1 Loot Core
-- Central helper for monster loot tables.
-- Use inside monster files with:
-- dofile('data/scripts/custom/00_z1_loot_core.lua')
-- monster.loot = Z1Loot.build('starter', monster.experience, { { name = 'special item', chance = 1000 } })

Z1Loot = Z1Loot or {}

Z1Loot.currency = {
    goldCoin = 'gold coin',
    platinumCoin = 'platinum coin',
    crystalCoin = 'crystal coin',
    goldIngot = 'gold ingot',
}

-- chance is 1 to 100000 in OTServBR/Canary monster loot convention.
-- 100000 = 100%, 50000 = 50%, 1000 = 1%.
Z1Loot.tables = {
    starter = {
        { name = 'gold coin', chance = 80000, maxCount = 100 },
        { name = 'platinum coin', chance = 8000, maxCount = 3 },
        { name = 'small diamond', chance = 1200, maxCount = 2 },
    },

    easy = {
        { name = 'gold coin', chance = 90000, maxCount = 100 },
        { name = 'platinum coin', chance = 20000, maxCount = 8 },
        { name = 'crystal coin', chance = 800, maxCount = 1 },
        { name = 'small emerald', chance = 1600, maxCount = 3 },
    },

    mid = {
        { name = 'platinum coin', chance = 65000, maxCount = 25 },
        { name = 'crystal coin', chance = 6000, maxCount = 3 },
        { name = 'gold ingot', chance = 300, maxCount = 1 },
        { name = 'small sapphire', chance = 2200, maxCount = 5 },
    },

    high = {
        { name = 'platinum coin', chance = 95000, maxCount = 100 },
        { name = 'crystal coin', chance = 25000, maxCount = 10 },
        { name = 'gold ingot', chance = 1200, maxCount = 2 },
        { name = 'giant shimmering pearl', chance = 1000, maxCount = 2 },
    },

    elite = {
        { name = 'crystal coin', chance = 70000, maxCount = 25 },
        { name = 'gold ingot', chance = 4500, maxCount = 4 },
        { name = 'blue gem', chance = 1800, maxCount = 2 },
        { name = 'green gem', chance = 1800, maxCount = 2 },
        { name = 'red gem', chance = 1800, maxCount = 2 },
    },

    expBoost = {
        { name = 'platinum coin', chance = 100000, maxCount = 50 },
        { name = 'crystal coin', chance = 35000, maxCount = 5 },
        { name = 'gold ingot', chance = 500, maxCount = 1 },
        { name = 'small ruby', chance = 2500, maxCount = 3 },
    },
}

function Z1Loot.copy(list)
    local result = {}
    if not list then
        return result
    end
    for _, item in ipairs(list) do
        local entry = {}
        for k, v in pairs(item) do
            entry[k] = v
        end
        table.insert(result, entry)
    end
    return result
end

function Z1Loot.merge(base, extra)
    local result = Z1Loot.copy(base)
    if extra then
        for _, item in ipairs(extra) do
            table.insert(result, item)
        end
    end
    return result
end

function Z1Loot.build(tier, monsterExperience, extra)
    local base = Z1Loot.tables[tier] or Z1Loot.tables.easy
    return Z1Loot.merge(base, extra)
end

print('[Z1 Loot Core] Loaded central loot helper.')
