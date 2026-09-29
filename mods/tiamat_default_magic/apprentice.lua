-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The Apothecary's Bench (brief §4): the child's door into the Art.
--
-- A six-year-old will never reach the Fork, so the first taste of magic is
-- five SHARED nodes, open before it to every player, magic, science and
-- undecided alike; Progress keeps shared nodes through the Fork and a
-- repath, so nothing here is ever taken away. Every one makes a colour, a
-- light or a drink within seconds of being learned, takes three ingredients
-- at most at one station, and never fails or loses anything.
--
-- The flame powders are the one mechanism of the Bench's own. A powder on a
-- burning fire flares its colour. At a campfire it is PUT ON the fire, as
-- food is — Craft hears a use at a campfire before any later mod and puts
-- what it can cook into the fire's box, so each powder is a campfire recipe
-- that makes nothing, and flares when Craft says it was made. At a lit kiln
-- or bloomery, which Craft does not hear first, it is thrown (sibling ask
-- C-M9 would make both the same).

local C = tdm.config
local U = tdm.util

local A = {}

local progress = U.exports("tiamat_default_progress")
local craft = U.exports("tiamat_default_craft")

local function qualify_list(list)
    if not list then return nil end
    local out = {}
    for i, entry in ipairs(list) do
        local copy = { U.id(entry[1]), count = entry.count, units = entry.units, wear = entry.wear }
        out[i] = copy
    end
    return out
end

-- The nodes -----------------------------------------------------------------------

A.nodes = {}        -- node id -> its config entry, for the book
for _, node in ipairs(C.bench_nodes) do
    A.nodes[node.id] = node
    if progress then
        local ok, why = progress.register_node{
            id = node.id, tier = node.tier, cost = node.cost, requires = node.requires,
            label = node.label, text = node.text,
        }
        if not ok then game.log("tiamat_default_magic: Progress refused " .. node.id .. ": " .. tostring(why)) end
    end
end

-- The recipes ---------------------------------------------------------------------

A.recipes = {}      -- node id -> list of its recipes, in config order, for the book

local function register_recipe(r)
    local spec = {
        id = U.id(r.id),
        station = r.station,
        inputs = qualify_list(r.inputs),
        outputs = qualify_list(r.outputs),
        tools = qualify_list(r.tools),
        heat = r.heat,
        ticks = r.ticks,
        requires = r.node,
    }
    local ok, why = craft.register(spec)
    if not ok then
        game.log("tiamat_default_magic: Craft refused the recipe " .. r.id .. ": " .. tostring(why))
        return
    end
    if r.node then
        A.recipes[r.node] = A.recipes[r.node] or {}
        table.insert(A.recipes[r.node], r)
    end
end

if craft then
    for _, r in ipairs(C.bench_recipes) do
        register_recipe(r)
    end
    -- A powder on a campfire: a recipe that makes nothing, heard below.
    for _, colour in ipairs(U.sorted_keys(C.flames)) do
        local flame = C.flames[colour]
        register_recipe{
            id = "burn_" .. colour, station = "campfire", ticks = C.flame_ticks,
            inputs = { { flame.powder, count = 1 } }, outputs = {},
        }
    end
end

-- Discoveries: play itself pays a little ---------------------------------------------

-- Progress splits a discovery id at its FIRST colon to find a family, so a
-- family's prefix may hold dots but no colon: `tiamat_default_magic.flame:*`.
local FLAME = game.mod_id .. ".flame"
local LAMP = game.mod_id .. ".lamp"
local DISTIL = game.mod_id .. ".distillation"

if progress then
    local names = {}
    for colour, flame in pairs(C.flames) do names[colour] = flame.said end
    -- A family's label is a format for the member's name: "%s" is the name alone.
    progress.register_discovery{ id = FLAME .. ":*", insight = C.toybox.flame, label = "%s",
        group = "toybox", names = names }
    progress.register_discovery{ id = LAMP, insight = C.toybox.lamp, label = "A lamp that never goes out",
        group = "toybox" }
    progress.register_discovery{ id = DISTIL, insight = C.toybox.distillation, label = "A first distillation",
        group = "toybox" }
end

local function discover(uuid, id)
    if progress then progress.discover(uuid, id) end
end

-- Flames ---------------------------------------------------------------------------

local powders = {}          -- numeric material of a powder -> its colour
for colour, flame in pairs(C.flames) do
    local material = U.material(U.id(flame.powder))
    if material then powders[material] = colour end
end

--- A flame of `colour` over the fire at `pos` (whole blocks).
local function flare(pos, colour)
    local flame = C.flames[colour]
    local at = U.above(pos)
    if flame.sparks then
        game.emit_particles{ pos = at, count = C.flame_particles, colour = flame.colour, size = 0.08,
            lifetime = 0.9, velocity = { y = 4 }, spread = 3, gravity = 8, collide = true,
            radius = C.flame_radius }
    else
        game.emit_particles{ pos = at, count = C.flame_particles, colour = flame.colour, size = 0.2,
            lifetime = 1.4, velocity = { y = 1.2 }, spread = 0.5, area = { x = 0.3, y = 0.1, z = 0.3 },
            gravity = -1.5, collide = false, radius = C.flame_radius }
    end
    pcall(game.play_sound, { sound = "tiamat_default_craft:sizzle", pos = at, radius = 16 })
end

local function flared(uuid, pos, colour)
    if pos then flare(pos, colour) end
    game.chat_to(uuid, C.flames[colour].said)
    discover(uuid, FLAME .. ":" .. colour)
end

-- Thrown: at a lit kiln, a bloomery, a wildfire.
local thrown_at = {}
for i, id in ipairs(C.thrown_at) do thrown_at[i] = U.id(id) end
tdm.on_use_at(thrown_at, function(e)
    local held = e.held
    local colour = held and powders[held.material]
    if not colour or held.shape ~= nil or held.detail ~= nil then return nil end
    if game.take(e.player, { material = held.material, units = U.UNITS }) < U.UNITS then return nil end
    flared(e.player, U.block_of(e), colour)
    return ""
end)

-- Put on: the campfire's box burnt it. Craft does not say which fire, so
-- the flare is shown at the fire the player is looking at, if they are
-- looking at one; the recipe is made as the player who lit the fire.
local put_on = {}
for _, id in ipairs(C.put_on) do
    local material = U.material(U.id(id))
    if material then put_on[material] = true end
end

local function fire_in_view(uuid)
    local at = game.looking_at(uuid)
    if at and at.material and put_on[at.material] then
        return { x = at.x // 3, y = at.y // 3, z = at.z // 3, domain = at.domain }
    end
    return nil
end

local burnt = {}            -- recipe id -> colour
for colour in pairs(C.flames) do burnt[U.id("burn_" .. colour)] = colour end

local distilled = { [U.id("rosewater")] = true, [U.id("mint_water")] = true }

if craft then
    craft.on_crafted(function(uuid, recipe_id)
        local colour = burnt[recipe_id]
        if colour then
            flared(uuid, fire_in_view(uuid), colour)
        elseif distilled[recipe_id] then
            discover(uuid, DISTIL)
        end
    end)
    craft.on_first(function(uuid, event)
        if event == "craft:" .. U.id("hermetic_lamp") then discover(uuid, LAMP) end
    end)
end

--- Whether a player holds the Bench's node `id` (a Creative world holds all).
function A.has(uuid, id)
    return progress ~= nil and progress.has(uuid, id) == true
end

return A
