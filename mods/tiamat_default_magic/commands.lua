-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- `magic`, in chat. For anyone: `magic` says how far along the Bench the
-- speaker is; `magic book` opens the Mute Book for a player who carries one.
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
    elseif word == "book" then
        if not P.carries(player) then return "You have no Mute Book. Make one by hand: leather, two bark strips, charcoal." end
        P.open(player)
        return nil
    end
    return false
end)

return {}
