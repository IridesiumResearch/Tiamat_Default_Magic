-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The Caduceus (brief §5.3): Hermes' staff, a relic assembled from two
-- carvings — Mercury's sign in silver ore and the ouroboros in gold ore —
-- with quicksilver and a quintessence (the carvings named by their glyphs,
-- Craft's answer to C-M1).
--
-- Used, wherever its holder looks, it is Hermes' Stride: a step of `stride`
-- blocks along the ground the way they face, landing on the first two clear
-- blocks back from there, for quintessence. And with the Caduceus known, an
-- elixir used on another player is theirs: its effects are given to them
-- through Life's `add_effect`, for quintessence. Medicine, never a weapon.

local C = tdm.config
local U = tdm.util
local Q = tdm.quintessence

local K = C.caduceus
local progress = U.exports("tiamat_default_progress")
local life = U.exports("tiamat_default_life")

tdm.recipes.register(C.caduceus_recipe)

local CADUCEUS = U.material(U.id(K.item.id))

local function knows(uuid)
    return progress ~= nil and progress.has(uuid, K.node) == true
end

local function clear(x, y, z)
    local b = game.get_block{ x = x, y = y, z = z }
    return b ~= nil and b.occupancy == 0
end

-- Hermes' Stride.
tdm.on_use(function(e)
    if not (e.held and e.held.material == CADUCEUS) or not knows(e.player) then return nil end
    local body = game.player_entity(e.player)
    local me = body and game.entity(body)
    if not me then return "" end
    local fx, fz = me.facing.x, me.facing.z
    local x0, y, z0 = math.floor(me.pos.x), math.floor(me.pos.y), math.floor(me.pos.z)
    -- The facing's own components, rounded to a block's step: where the
    -- player is pointing, not a number the world keeps.
    for n = K.stride, 1, -1 do
        local x, z = math.floor(me.pos.x + fx * n), math.floor(me.pos.z + fz * n)
        if (x ~= x0 or z ~= z0) and clear(x, y, z) and clear(x, y + 1, z) then
            if not Q.spend(e.player, K.stride_cost) then return K.dry end
            game.move_player(e.player, { x = x + 0.5, y = y, z = z + 0.5 })
            game.emit_particles{ pos = { x = me.pos.x, y = me.pos.y + 1, z = me.pos.z }, count = 16,
                colour = { r = 0.9, g = 0.8, b = 0.4 }, size = 0.12, lifetime = 0.8, spread = 1, collide = false }
            return ""
        end
    end
    return "There is no room to stride that way."
end)

-- An elixir given to a friend.
local gifts = {}            -- numeric material -> its Life effects
for _, spec in ipairs(tdm.items.all) do
    if spec.food and spec.food.effects then
        local m = U.material(U.id(spec.id))
        if m then gifts[m] = spec.food.effects end
    end
end

tdm.on_use_entity(function(e)
    if not (e.owner and e.held and gifts[e.held.material]) or e.owner == e.player then return nil end
    if not (knows(e.player) and life and life.add_effect) then return nil end
    if not Q.spend(e.player, K.spray_cost) then return K.dry end
    if game.take(e.player, { material = e.held.material, count = 1 }) < U.UNITS then return "" end
    for _, fx in ipairs(gifts[e.held.material]) do life.add_effect(e.owner, fx[1], fx[2]) end
    game.chat_to(e.owner, "Somebody shares an elixir with you.")
    return ""
end)

return {}
