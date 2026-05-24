-- data/scripts/custom/01_z1_restricted_arrows_cleanup.lua
-- Removes Z-arrow items from depot market offers so players cannot buy progression arrows.
-- This is needed because we are using existing Tibia arrows as Z tiers:
-- Z1 = flaming arrow, Z2 = flash arrow, Z3 = shiver arrow.

print("[Z1 Restricted Arrows] Loading market cleanup...")

local ge = GlobalEvent("Z1RestrictedArrowsCleanup")
ge:type("startup")

function ge.onStartup()
    local cfg = _G.Z1Rift or {}
    local items = cfg.items or {}

    local ids = {
        items.z1Arrow,
        items.z2Arrow,
        items.z3Arrow,
    }

    local cleaned = 0
    for _, id in ipairs(ids) do
        if id and id > 0 then
            local ok = pcall(function()
                -- Remove all market offers for these arrows, not only Zero Market.
                -- These are now progression-only arrows. Cruel, but economy needs laws.
                db.query("DELETE FROM `market_offers` WHERE `itemtype` = " .. id)
                db.query("DELETE FROM `player_depotitems` WHERE `itemtype` = " .. id)
            end)
            if ok then
                cleaned = cleaned + 1
            else
                print("[Z1 Restricted Arrows] WARNING: DB cleanup failed for item id " .. id)
            end
        end
    end

    print("[Z1 Restricted Arrows] Cleaned restricted arrow types: " .. cleaned)
    return true
end

ge:register()
