-- data/scripts/custom/00_z1_reward_config.lua
-- Zero1 Labs SAFE CONFIG
-- This replaces a broken reward config that had a syntax error near "and".
-- Keep this file only if other scripts still reference _G.Z1Rewards.
-- It does NOT create room objects, prestige, weapons, or loot side effects.

_G.Z1Rewards = _G.Z1Rewards or {}

Z1Rewards.brand = "Zero1 Labs"
Z1Rewards.currencyName = "fiery tear"

local function resolveItemId(name, fallback)
    local ok, it = pcall(ItemType, name)
    if ok and it then
        local id = it:getId()
        if id and id > 0 then
            return id
        end
    end
    return fallback
end

Z1Rewards.fieryTearId = resolveItemId("fiery tear", 39040)
Z1Rewards.goldIngotId = resolveItemId("gold ingot", 9058)

print(string.format("[Z1 Rewards] Safe config loaded. fiery tear=%s, gold ingot=%s",
    tostring(Z1Rewards.fieryTearId),
    tostring(Z1Rewards.goldIngotId)
))
