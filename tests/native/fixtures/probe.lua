-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- A mod loaded after Tiamat Default Magic that asks the siblings what they
-- see, the way any mod would: through their exports. `t ...` in chat.
--
--   t nodes              the Bench's nodes Progress knows, in its order
--   t has <node>         whether the speaker holds it
--   t award <n>          insight, as another mod's milestone
--   t learn <node>       Progress's unlock, paid in insight
--   t insight            the speaker's insight
--   t can <recipe>       Craft's `can`, by hand
--   t make <recipe>      Craft's `perform`, by hand
--   t burn <colour>      a flame powder put on a campfire, which burns it
--   t magic              this mod's export version

local p = game.exports("tiamat_default_progress")
local c = game.exports("tiamat_default_craft")
local m = game.exports("tiamat_default_magic")
assert(p and c and m, "the probe sees Progress, Craft and Magic")

local FIRE = "tiamat_default_craft:campfire:5,64,5"

game.register_on_chat(function(e)
    local word, rest = string.match(e.text, "^t (%S+)%s*(.*)$")
    if not word then return end
    local say
    if word == "nodes" then
        local ids = {}
        for _, n in ipairs(p.nodes()) do
            if string.match(n.id, "^shared%.") and (n.id == "shared.mutus_liber" or n.id == "shared.apothecary"
                or n.id == "shared.herb_lore" or n.id == "shared.foxfire" or n.id == "shared.stillroom") then
                ids[#ids + 1] = n.id .. "/" .. n.tier .. "/" .. n.cost
            end
        end
        say = table.concat(ids, " ")
    elseif word == "has" then
        say = tostring(p.has(e.player, rest))
    elseif word == "award" then
        say = tostring(p.award(e.player, math.tointeger(tonumber(rest)), "a probe"))
    elseif word == "learn" then
        local ok, why = p.unlock(e.player, rest)
        say = tostring(ok) .. (why and (" " .. why) or "")
    elseif word == "insight" then
        say = tostring(p.insight(e.player))
    elseif word == "can" then
        local ok, why = c.can(e.player, rest)
        say = tostring(ok) .. (why and (" " .. why) or "")
    elseif word == "make" then
        local ok, why = c.perform(e.player, rest)
        say = ok and "made" or ("not " .. tostring(why))
    elseif word == "burn" then
        game.make_container(FIRE, 4)
        local powder = "tiamat_default_magic:flame_powder_" .. rest
        game.container_give(FIRE, { material = powder, count = 1, slot = 1 })
        local ok, why = c.perform(e.player, "tiamat_default_magic:burn_" .. rest, FIRE)
        say = ok and "burnt" or ("not " .. tostring(why))
    elseif word == "magic" then
        say = tostring(m.version)
    end
    game.chat_to(e.player, say or "?")
    return false
end)
