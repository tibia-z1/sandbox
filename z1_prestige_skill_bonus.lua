-- data/scripts/custom/z1_prestige_skill_bonus.lua
-- Prestige Skill Bonus -- REPLACES the per-kill addSkillTries() injection.
--
-- PROBLEM WITH THE OLD SYSTEM:
--   The old code added tries to ALL combat skills on each kill.
--   This meant casting a fire ball increased Club fighting skill.
--   Killing a monster increased shielding even if you stood still.
--   Completely wrong and immersion-breaking.
--
-- NEW SYSTEM (this file):
--   Uses CreatureEvent type "advance" -- fires ONLY when a skill naturally
--   advances through legitimate use. Bonus tries are added to THAT skill only.
--   A mage advancing magic level gets magic bonus. A knight advancing sword
--   skill gets sword bonus. Cross-skill contamination is impossible.
--
-- SETUP:
--   1. Drop this file in data/scripts/custom/
--   2. In z1_prestige.lua, find the Z1PrestigeXP kill event and REMOVE
--      these lines (the skill injection block):
--
--        local skillBonus = rank * SKILL_TRIES_PER_RANK
--        if skillBonus > 0 then
--            for _, skillId in ipairs(BONUS_SKILLS) do
--                pcall(function() creature:addSkillTries(skillId, skillBonus) end)
--            end
--            pcall(function() creature:addManaSpent(rank * 20) end)
--        end
--
--   3. Add to login.lua (or to Z1PrestigeLogin):
--      player:registerEvent("Z1PrestigeSkillBonus")
--
-- NOTE: Magic level boost uses addManaSpent() when the magic level advances.
-- The amount of mana "spent" is set to 10% of the next level's requirement x rank.

print("[Z1 Prestige Skill] Loading advance-based skill bonus...")

local RANK_STORAGE = _G.Z1_PRESTIGE_RANK_STORAGE or 590001

local function getRank(player)
    local v = player:getStorageValue(RANK_STORAGE)
    return math.max(0, v or 0)
end

-- Bonus tries = rank x 10% of newLevel (scales with progression)
-- At rank 2, advancing to sword skill 100 adds 2x10 = 20 bonus tries toward 101.
-- At rank 10, same advance adds 100 tries -- meaningful late-game acceleration.
local BONUS_PERCENT = 1 -- 100% per rank

local skillBonus = CreatureEvent("Z1PrestigeSkillBonus")
skillBonus:type("advance")
skillBonus:onAdvance(function(player, skill, oldLevel, newLevel)
    if not player then return true end

    -- Skip level-up events (SKILL_LEVEL = player level)
    if skill == SKILL_LEVEL then return true end

    local rank = getRank(player)
    if rank <= 0 then return true end

    local bonus = math.floor(newLevel * rank * BONUS_PERCENT)
    if bonus <= 0 then return true end

    if skill == SKILL_MAGLEVEL then
        -- Magic level: add mana spent (each try = 1 mana unit in the formula)
        pcall(function() player:addManaSpent(bonus) end)
    else
        -- All combat skills: sword, axe, club, distance, shielding, fist
        pcall(function() player:addSkillTries(skill, bonus) end)
    end

    return true
end)
skillBonus:register()

-- Register on login so existing players get it without relog
local loginPatch = CreatureEvent("Z1PrestigeSkillBonusLogin")
loginPatch:type("login")
loginPatch:onLogin(function(player)
    if not player then return true end
    player:registerEvent("Z1PrestigeSkillBonus")
    return true
end)
loginPatch:register()

print("[Z1 Prestige Skill] onAdvance bonus loaded. Sword trains sword. Magic trains magic.")
print("[Z1 Prestige Skill] REMOVE the old per-kill skill injection from z1_prestige.lua!")
