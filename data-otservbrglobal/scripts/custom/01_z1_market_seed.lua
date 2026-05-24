-- 01_z1_market_seed.lua
-- Seeds the real Tibia market_offers table for zero market/player_id 15.
-- Put in: data/scripts/custom/

local Z1 = _G.Z1
if not Z1 then
    print("[Z1 Market] ERROR: Z1 core did not load first.")
    return
end

local function safeQuery(sql)
    if not db or not db.query then
        print("[Z1 Market] ERROR: db.query is not available.")
        return false
    end
    local ok = db.query(sql)
    if not ok then
        print("[Z1 Market] SQL failed: " .. sql)
    end
    return ok
end

local function sellerExists()
    if not db.storeQuery then
        return true
    end
    local sellerId = tonumber(Z1.MARKET_SELLER_PLAYER_ID)
    local resultId = db.storeQuery("SELECT `id`, `name` FROM `players` WHERE `id` = " .. sellerId .. " LIMIT 1")
    if not resultId then
        print("[Z1 Market] ERROR: No player found with id=" .. sellerId .. ". Check players.id, not account_id.")
        return false
    end
    if Result and Result.free then
        Result.free(resultId)
    end
    return true
end

local function resolveOfferItemId(offer)
    if not offer then return 0 end
    if offer.itemId then
        local id = tonumber(offer.itemId)
        if id and id > 0 and ItemType(id):getId() > 0 then
            return id
        end
    end
    if offer.name then
        local id = ItemType(offer.name):getId()
        if id and id > 0 then return id end
    end
    if offer.names then
        for _, name in ipairs(offer.names) do
            local id = ItemType(name):getId()
            if id and id > 0 then return id end
        end
    end
    return 0
end

function Z1.seedMarketOffers()
    local sellerId = tonumber(Z1.MARKET_SELLER_PLAYER_ID or 0)
    if sellerId <= 0 then
        print("[Z1 Market] ERROR: invalid seller player id.")
        return false
    end

    if not sellerExists() then
        return false
    end

    if Z1.MARKET_CLEAR_SELLER_OFFERS_FIRST then
        safeQuery(string.format("DELETE FROM `market_offers` WHERE `player_id` = %d AND `sale` = 1", sellerId))
    end

    local created = os.time()
    local anonymous = tonumber(Z1.MARKET_ANONYMOUS or 0)
    local inserted = 0
    local skipped = 0

    for _, offer in ipairs(Z1.MARKET_OFFERS or {}) do
        local itemId = resolveOfferItemId(offer)
        local amount = tonumber(offer.amount or 1)
        local price = tonumber(offer.price or 1)
        if itemId > 0 and amount and amount > 0 and price and price > 0 then
            local sql = string.format(
                "INSERT INTO `market_offers` (`player_id`, `sale`, `itemtype`, `amount`, `created`, `anonymous`, `price`) VALUES (%d, 1, %d, %d, %d, %d, %d)",
                sellerId, itemId, amount, created, anonymous, price
            )
            if safeQuery(sql) then
                inserted = inserted + 1
            else
                print(string.format("[Z1 Market] Failed itemId=%s label=%s", tostring(itemId), tostring(offer.label)))
            end
        else
            skipped = skipped + 1
            print(string.format("[Z1 Market] Skipped invalid/missing offer label=%s", tostring(offer.label or offer.name)))
        end
    end

    print(string.format("[Z1 Market] Seed complete: inserted %d sell offers, skipped %d, seller player_id=%d.", inserted, skipped, sellerId))
    return true
end

local marketStartup = GlobalEvent("Z1FullMarketSeedStartup")
function marketStartup.onStartup()
    if Z1.MARKET_AUTO_SEED then
        Z1.seedMarketOffers()
    else
        print("[Z1 Market] Auto seed disabled.")
    end
    return true
end
marketStartup:register()
