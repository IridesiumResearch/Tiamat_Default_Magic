-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Every item this mod registers, from the tables in `config.lua` (brief §9).
-- Each has a texture of its own name; `tools/make_textures.py` draws the
-- placeholders. What is drunk or eaten is handed to Life, so Life's key
-- drinks it, Life's icons show its effects, and anyone can drink one — a
-- magic player makes, anyone drinks, and trade across the Fork needs no
-- code.

local C = tdm.config
local U = tdm.util

local I = {}

I.ids = {}          -- short id -> numeric material id

local function register(spec)
    I.ids[spec.id] = game.register_item{
        id = spec.id,
        name = spec.name,
        description = spec.description,
        texture = "textures/" .. spec.id .. ".png",
    }
end

-- Every item, in one list: the Bench's, tier 3's, a tincture for each
-- planet, and the elixirs drawn from them.
I.all = {}
local function add(list)
    for _, spec in ipairs(list) do I.all[#I.all + 1] = spec end
end
add(C.bench_items)
add(C.lab_items)
for _, planet in ipairs(C.planets) do
    local name = C.planet_names[planet]
    I.all[#I.all + 1] = { id = "tincture_" .. planet, name = "Tincture of " .. name,
        description = string.format("A herb ruled by %s, drawn out in spirit of wine.", name) }
end
add(C.elixirs)
add(C.familiar_items)
add(C.tier4_items)

for _, spec in ipairs(I.all) do
    register(spec)
end

-- Food, through Life. Life is a hard dependency, so this answers false only
-- for a spec Life refuses, which is a mistake in `config.lua` worth a line
-- in the log rather than a mod that will not load.
local life = U.exports("tiamat_default_life")
if life then
    for _, spec in ipairs(I.all) do
        if spec.food and not life.add_food(U.id(spec.id), spec.food) then
            game.log("tiamat_default_magic: Life refused the food " .. spec.id)
        end
    end
end

return I
