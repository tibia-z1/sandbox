-- data/scripts/custom/z1_weapons.lua
-- Zero1 Labs SAFE SHIM
-- Purpose:
--   Disable the older consolidated Z1WeaponThink system without breaking login registrations.
--   Keep z1_weapon_aoe.lua as the active Z-weapon effect system.
--
-- Why:
--   The old z1_weapons.lua used CreatureEvent("Z1WeaponThink") with scripted hits,
--   Combat:execute(), market cleanup, and arrow overrides. It can interfere with
--   normal auto-attacks and overlaps with z1_weapon_aoe.lua.
--
-- Result:
--   If login.lua or z1_player_commands.lua still calls player:registerEvent("Z1WeaponThink"),
--   this no-op event safely exists and returns true.
--
-- Keep:
--   data/scripts/custom/z1_weapon_aoe.lua
-- Remove/avoid:
--   duplicate consolidated Z weapon scripts that also register Z1WeaponThink.

print("[Z1 Weapons] SAFE SHIM loaded. Z1WeaponThink disabled; z1_weapon_aoe.lua remains responsible for Z weapon effects.")

local ev = CreatureEvent("Z1WeaponThink")
ev:type("think")
ev:onThink(function(player, interval)
    return true
end)
ev:register()
