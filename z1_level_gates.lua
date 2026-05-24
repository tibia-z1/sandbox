-- z1_level_gates.lua
-- Central level gate tables and helper for hunt, boss, quest, and hub portals.
-- This version is ACTIVE. No manual paste blocks. If hunt_room.lua/teleports.lua from this patch are installed, gates work.

_G.Z1 = _G.Z1 or {}
local Z1 = _G.Z1

_G.Z1HuntLevels = {
    [8701]=20,  [8702]=35,  [8703]=45,  [8704]=50,  [8705]=80,
    [8706]=110, [8707]=150, [8708]=220, [8709]=280,
    [8710]=330, [8711]=400, [8712]=500, [8713]=600, [8714]=700,
    [8715]=850, [8716]=950, [8717]=1000,[8718]=1050,
    [8719]=1100,[8720]=1250,[8721]=1450,[8722]=1700,
    [8723]=1850,[8724]=1900,[8725]=2000,[8726]=2400,
    [8727]=2800,[8728]=3200,[8729]=3400,[8730]=3800,
    [8731]=4200,[8732]=4500,[8733]=4700,
    [8734]=5000,[8735]=5200,[8736]=5400,[8737]=5600,
    [8738]=5800,[8739]=6000,[8740]=6200,[8741]=6600,
    [8742]=6800,[8743]=7200,[8744]=7400,[8745]=7600,
    [8746]=8000,[8747]=8400,[8748]=9000,[8749]=9800,
    [8750]=10200,[8751]=10600,[8752]=10800,[8753]=11000,
    [8754]=11200,[8755]=11400,
}

_G.Z1HubLevels = {
    [9001]=1, [9002]=1, [9003]=1, [9004]=1, [8001]=1,
    [9201]=200,  [9202]=500,  [9203]=800,
    [9204]=900,  [9205]=1000,
    [9301]=250,  [9302]=200,  [9303]=300, [9304]=250,
}

function Z1.checkLevelGate(player, aid, levelTable)
    local minLvl = levelTable and levelTable[aid]
    if not minLvl or minLvl <= 1 then return true, nil end

    local group = player:getGroup()
    if group and group:getAccess() then
        return true, nil -- gods/gms bypass level gates for testing/support
    end

    local lvl = player:getLevel()
    if lvl < minLvl then
        return false, string.format("You need level %d to enter here. Your level: %d.", minLvl, lvl)
    end
    return true, nil
end

print("[Z1 Level Gates] ACTIVE. Hunt + hub gates are enforced by patched hunt_room.lua and teleports.lua.")
