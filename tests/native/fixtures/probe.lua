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
--   t path               the speaker's path, or nil
--   t count              how many magic nodes Progress validated
--   t effects <prefix>   the speaker's summed effects, "key=value" sorted
--   t glyph <mask>       Craft's glyph_of a mask
--   t fluid <x> <y> <z>  a block's fluid, its volume, and the world's water's id
--   t band <x> <y> <z>   the world's depth band there
--   t time               the time of day
--   t surface <x> <z>    a column's top from y 72: its y, fluid and volume

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
    elseif word == "glyph" then
        say = tostring(c.glyph_of(math.tointeger(tonumber(rest))))
    elseif word == "fluid" then
        local x, y, z = string.match(rest, "^(%-?%d+) (%-?%d+) (%-?%d+)$")
        local f = game.get_fluid{ x = math.tointeger(tonumber(x)), y = math.tointeger(tonumber(y)), z = math.tointeger(tonumber(z)) }
        say = string.format("%s %s %s", tostring(f and f.fluid), tostring(f and f.volume),
            tostring(game.fluid_id and game.fluid_id("tiamat_default_world:water")))
    elseif word == "band" then
        local w = game.exports("tiamat_default_world")
        local x, y, z = string.match(rest, "^(%-?%d+) (%-?%d+) (%-?%d+)$")
        say = tostring(w and w.depth_band(tonumber(x), tonumber(y), tonumber(z)))
    elseif word == "time" then
        say = tostring(game.time_of_day())
    elseif word == "surface" then
        local x, z = string.match(rest, "^(%-?%d+) (%-?%d+)$")
        local top = game.surface_at{ x = math.tointeger(tonumber(x)), z = math.tointeger(tonumber(z)), from = 72, depth = 24 }
        say = top and string.format("%d %s %s", top.y, tostring(top.fluid), tostring(top.volume)) or "nil"
    elseif word == "path" then
        say = tostring(p.path(e.player))
    elseif word == "count" then
        local n = 0
        for _, node in ipairs(p.nodes()) do
            if node.path == "magic" then n = n + 1 end
        end
        say = tostring(n)
    elseif word == "effects" then
        local fx = p.effects_of(e.player, rest ~= "" and rest or nil)
        local keys = {}
        for k in pairs(fx) do keys[#keys + 1] = k end
        table.sort(keys)
        for i, k in ipairs(keys) do keys[i] = k .. "=" .. fx[k] end
        say = table.concat(keys, " ")
    end
    game.chat_to(e.player, say or "?")
    return false
end)
