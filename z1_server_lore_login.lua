-- data/scripts/custom/z1_server_lore_login.lua
-- Compact login lore/basics message. Register in login.lua: player:registerEvent("Z1ServerLoreLogin")

local ev = CreatureEvent("Z1ServerLoreLogin")
ev:type("login")
function ev.onLogin(player)
    if not player then return true end
    addEvent(function(pid)
        local p = Player(pid)
        if not p then return end
        p:sendTextMessage(MESSAGE_EVENT_ADVANCE,
            "Welcome to Zero1 Labs. Progress through hunts, quests, prestige, and the Rift Forge. Use !commands, !spells, !sets, !loot monster, and !moboutfits. Fiery tears are Riftmarks used for prestige and forge ultimate rewards.")
    end, 1500, player:getId())
    return true
end
ev:register()
