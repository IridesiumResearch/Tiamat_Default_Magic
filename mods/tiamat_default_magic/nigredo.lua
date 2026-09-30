-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Tier 4, Nigredo II (brief §5.2): the menstrua and the black.
--
-- The recipes are data (`config.lua`, `tier4_recipes`): the aludel, the
-- pelican and the Philosophers' Egg; sublimation and quicksilver from the
-- world's cinnabar; the amalgams; the solvents in the order they were
-- discovered; theriac; and the spine of the Opus — Conjunction (Gate IV),
-- Putrefaction (Gate V, the nigredo) and the Peacock's Tail. This file adds
-- what is more than a recipe:
--
-- - quicksilver and saltpeter join science's groups, so either tree's
--   reagent works in the other's apparatus;
-- - palingenesis, a recipe for each of the world's plants;
-- - a phosphorus spill lights a laid fire or a fuelled furnace;
-- - an athanor washing the Raven's Head shimmers every colour;
-- - the Exalted Tinctures make Life's effects of this mod's drinks last
--   longer, through Life's `add_effect`.

local C = tdm.config
local U = tdm.util
local R = tdm.recipes

local N = {}

local craft = U.exports("tiamat_default_craft")
local progress = U.exports("tiamat_default_progress")
local life = U.exports("tiamat_default_life")

R.group("#quicksilver", { "quicksilver" })
R.group("#saltpeter", { "saltpeter" })
R.register_all(C.tier4_recipes)

-- Palingenesis: a sprig of a plant, its salt and a phial give it back.
for _, herb in ipairs(C.herbs) do
    local id = U.id(herb[1])
    if string.sub(herb[1], 1, 2) == "W:" and not herb.count and U.material(id) then
        local short = string.match(id, ":(.+)$")
        R.register{
            id = "palingenesis_" .. short, station = "athanor", node = C.palingenesis.node,
            degree = 1, days = C.palingenesis.days, unlisted = true,
            inputs = { { id, units = C.palingenesis.sprig_units }, { "principle_salt", count = 1 }, { "phial", count = 1 } },
            outputs = { { id, units = C.palingenesis.yield_units } },
        }
    end
end
C.book_notes["magic.palingenesis"] =
    "a sprig of a plant + principle salt + a phial  ->  the living plant again, in the athanor, in Maria's bath (1st degree), a day"

-- Phosphorus spills ------------------------------------------------------------------

local SPILL = U.material(U.id(C.spill.item))
local lights = {}
for i, id in ipairs(C.spill.lights) do lights[i] = U.id(id) end

tdm.on_use_at(lights, function(e)
    if not (SPILL and e.held and e.held.material == SPILL) or not craft then return nil end
    local pos = U.block_of(e)
    local ok, why = craft.ignite({ x = pos.x, y = pos.y, z = pos.z, domain = e.domain ~= "overworld" and e.domain or nil },
        e.player)
    if not ok then return why or "It will not catch." end
    game.take(e.player, { material = SPILL, count = 1 })
    return ""
end)

-- The Peacock's Tail ---------------------------------------------------------------------

local LIT = U.material(U.id(C.athanor.lit.id))
local STATION = U.id(C.athanor.station)
local PREFIX = "tiamat_default_craft:" .. STATION .. ":"
local EGG = U.material(U.id("philosophers_egg"))
local RAVEN = U.material(U.id("caput_corvi"))
local PEACOCK = game.mod_id .. ".peacock"

if progress then
    progress.register_discovery{ id = PEACOCK, insight = C.peacock.discovery,
        label = "The Egg shimmers like a peacock's tail", group = "toybox" }
end

--- Whether an athanor holds the Raven's Head in its inputs and the Egg in a vessel slot.
local function washing(name)
    local egg, raven = false, false
    for _, stack in ipairs(game.container(name)) do
        if stack.material == EGG and stack.slot >= C.athanor.slots.tool.from and stack.slot <= C.athanor.slots.tool.to then
            egg = true
        elseif stack.material == RAVEN and stack.slot >= C.athanor.slots.input.from and stack.slot <= C.athanor.slots.input.to then
            raven = true
        end
    end
    return egg and raven
end

local elapsed, turn = 0, 0
tdm.on_tick(function(dt)
    elapsed = elapsed + (math.tointeger(dt) or 1)
    if elapsed < C.peacock.every then return end
    elapsed = 0
    turn = turn % #C.peacock_colours + 1
    for _, name in ipairs(game.containers(PREFIX)) do
        local pos = U.station_pos(name, STATION)
        local at = pos and game.get_block(pos)
        if at and at.material == LIT and washing(name) then
            game.emit_particles{ pos = U.above(pos), count = C.peacock.particles, colour = C.peacock_colours[turn],
                size = 0.18, lifetime = 1.6, velocity = { y = 0.8 }, spread = 0.6, area = { x = 0.4, y = 0.1, z = 0.4 },
                gravity = -0.5, collide = false }
        end
    end
end)

local ABLUTION = U.id("ablution")
if craft and progress then
    craft.on_crafted(function(uuid, recipe_id)
        if recipe_id == ABLUTION then progress.discover(uuid, PEACOCK) end
    end)
end

-- Exalted tinctures: this mod's drinks' Life effects last longer --------------------------

local drinks = {}
for _, spec in ipairs(tdm.items.all) do
    if spec.food and spec.food.effects then drinks[U.id(spec.id)] = spec.food.effects end
end

if life and life.add_effect and progress then
    life.on_eat(function(uuid, material)
        local effects = drinks[material]
        if not effects then return end
        local bonus = progress.effects_of(uuid, "magic.")["magic.elixir_duration_percent"] or 0
        if bonus <= 0 then return end
        for _, fx in ipairs(effects) do
            life.add_effect(uuid, fx[1], fx[2] * (100 + bonus) // 100)
        end
    end)
end

return N
