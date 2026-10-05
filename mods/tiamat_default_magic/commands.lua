-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- `magic`, in chat. For anyone: `magic` says how far along the Bench the
-- speaker is; `magic book` opens the Mute Book for a player who carries one;
-- `magic seal allow <name>` and `magic seal deny <name>` say who may build
-- within the speaker's seals; `magic world allow <name>` and `deny` who may
-- walk in their woven worlds; `magic leave` goes back out of one; `magic
-- tablet` shows the Thrice-Greatest the Emerald Tablet's whole text.
-- A sentence that only begins with the word is chat.

local C = tdm.config
local A = tdm.apprentice
local P = tdm.primer

tdm.on_chat("magic", function(player, rest)
    local word = string.lower(rest)
    if word == "" then
        local held = 0
        for _, node in ipairs(C.bench_nodes) do
            if A.has(player, node.id) then held = held + 1 end
        end
        return string.format("The Apothecary's Bench: %d of %d learned.", held, #C.bench_nodes)
    elseif string.sub(word, 1, 9) == "familiar " or word == "familiar" then
        return tdm.familiars.command(player, string.sub(rest, 10))
    elseif string.sub(word, 1, 5) == "seal " or word == "seal" then
        return tdm.seal.command(player, string.sub(rest, 6))
    elseif string.sub(word, 1, 6) == "world " or word == "world" then
        return tdm.worlds.command(player, string.sub(rest, 7))
    elseif word == "leave" then
        return tdm.worlds.leave_command(player)
    elseif word == "tablet" then
        if not tdm.arcanum.trismegistus(player) then return "The Tablet keeps its whole text for the Thrice-Greatest." end
        tdm.arcanum.tablet(player)
        return nil
    elseif word == "book" then
        if not P.carries(player) then return "You have no Mute Book. Make one by hand: leather, two bark strips, charcoal." end
        P.open(player)
        return nil
    end
    return false
end)

return {}
