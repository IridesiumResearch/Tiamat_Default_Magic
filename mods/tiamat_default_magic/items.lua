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

for _, spec in ipairs(C.bench_items) do
    register(spec)
end

-- Food, through Life. Life is a hard dependency, so this answers false only
-- for a spec Life refuses, which is a mistake in `config.lua` worth a line
-- in the log rather than a mod that will not load.
local life = U.exports("tiamat_default_life")
if life then
    for _, spec in ipairs(C.bench_items) do
        if spec.food and not life.add_food(U.id(spec.id), spec.food) then
            game.log("tiamat_default_magic: Life refused the food " .. spec.id)
        end
    end
end

return I
