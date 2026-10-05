-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The athanor (brief §6.1): "the philosophers' oven", from the Arabic
-- al-tannur, a tower furnace built to hold a low, even heat for weeks.
--
-- It is a Craft station and nothing more: Craft places its container, opens
-- its screen, lights it with the fire striker, burns its fuel and makes, on
-- its own, the most particular recipe its slots, vessels and heat allow.
-- This file registers the station, its two blocks (each a model of the
-- tower, whole: lifted in one piece, and Craft's lighting swaps one for the
-- other with a plain write, which a whole block takes), and what Life should
-- know of a lit one (it burns to stand in, and warms to stand beside).
--
-- The vessels in its two tool slots are what make one furnace every
-- apparatus: a bath sets the degree of fire, an alembic or a retort the
-- operation, bellows the 4th degree (recipes.lua).

local C = tdm.config
local U = tdm.util

local T = {}

local A = C.athanor
local craft = U.exports("tiamat_default_craft")
local life = U.exports("tiamat_default_life")

local function block(spec)
    local whole, model, shape = U.block_look(spec)
    return game.register_block{
        id = spec.id,
        name = spec.name,
        description = spec.description,
        hardness = spec.hardness,
        tags = spec.tags,
        light_emit = spec.light,
        whole = whole, model = model, shape = shape,
        textures = { all = "textures/" .. spec.id .. ".png" },
    }
end

T.block = block(A.block)
T.lit = block(A.lit)

if craft then
    tdm.recipes.group(A.blast, A.blast_members)
    local ok, why = craft.register_station{
        id = U.id(A.station),
        name = A.name,
        slots = A.slots,
        heat = true,
        block = U.id(A.block.id),
        lit_block = U.id(A.lit.id),
        boost = { tool = A.blast, heat = A.blast_heat },
        refuse_fuel = A.refuse_fuel,
        -- Time passes for it while nobody is near: the ticks its chunk was
        -- unloaded are worked when it is next loaded, fuel permitting
        -- (Craft's answer to C-M5). A Red Stone is started, and left.
        long = true,
    }
    if not ok then game.log("tiamat_default_magic: Craft refused the athanor: " .. tostring(why)) end
end

if life then
    life.add_contact_fire(U.id(A.lit.id), A.contact_fire)
    life.add_heat_source(U.id(A.lit.id), A.warmth)
end

-- The laboratory's recipes: the athanor, its baths and glass, and tier 3's
-- operations (config.lua). The tinctures and elixirs are spagyrics.lua's.
tdm.recipes.register_all(C.lab_recipes)

return T
