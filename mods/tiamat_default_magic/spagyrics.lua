-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Spagyrics (brief §6.3): Paracelsus' "separate and combine", the herbal
-- half of the Art. A handful of a plant and a spirit of wine, digested a
-- philosophical day in Maria's bath, give that plant's PLANETARY tincture,
-- by its ruler in Culpeper's Complete Herbal (1653) where he names one. A
-- tincture in a phial is an elixir, and the elixirs are Life's food, so
-- anyone may drink what a magic player makes.
--
-- Each species' first tincture is a discovery: the long-tail reward of the
-- path, and what sends a player through every biome looking for plants.

local C = tdm.config
local U = tdm.util
local R = tdm.recipes

local S = {}

local progress = U.exports("tiamat_default_progress")
local craft = U.exports("tiamat_default_craft")
local life = U.exports("tiamat_default_life")

-- Only the plants that are here: a sibling that dropped one leaves a gap,
-- not a refused recipe.
S.herbs = {}                -- tincture recipe id -> { material, planet, short }
local herb_members = {}
for _, herb in ipairs(C.herbs) do
    local id = U.id(herb[1])
    if U.material(id) then
        local short = string.match(id, ":(.+)$")
        herb_members[#herb_members + 1] = id
        local recipe = {
            id = "tincture_" .. short, station = "athanor", node = "magic.spagyric_tincture",
            degree = 1, days = C.tincture_days, unlisted = true,
            inputs = { herb.count and { id, count = herb.count } or { id, units = C.herb_units },
                { "spirit_of_wine", count = 1 } },
            outputs = { { "tincture_" .. herb[2], count = 1 } },
        }
        if R.register(recipe) then
            S.herbs[U.id(recipe.id)] = { material = id, planet = herb[2], short = short }
        end
    end
end

-- The groups the Art reads: every herb (Gate III takes any of them), every
-- tincture, every calx (the study takes any), and oil of vitriol, shared
-- with science so a science player's acid works in a magic player's retort.
R.group("#magic_herb", herb_members)
local tinctures = {}
for i, planet in ipairs(C.planets) do tinctures[i] = "tincture_" .. planet end
R.group("#magic_tincture", tinctures)
R.group("#magic_calx", { "litharge", "minium", "putty", "aes_ustum", "crocus_martis" })
R.group("#oil_of_vitriol", { "oil_of_vitriol" })

-- Elixirs: a tincture in a phial, by hand.
for _, elixir in ipairs(C.elixirs) do
    R.register{
        id = elixir.id, station = "hand", node = "magic.simple_elixirs", unlisted = true,
        inputs = { { "tincture_" .. elixir.planet, count = 1 }, { "phial", count = 1 } },
        outputs = { { elixir.id, count = 1 } },
    }
end

-- Discoveries: each species, the first time.
local HERB = game.mod_id .. ".herb"
if progress then
    local names = {}
    for _, herb in pairs(S.herbs) do
        names[herb.short] = "A tincture of " .. string.gsub(herb.short, "_", " ")
    end
    progress.register_discovery{ id = HERB .. ":*", insight = C.discoveries.herb, label = "%s",
        group = "herbs", names = names }
end

if craft then
    craft.on_crafted(function(uuid, recipe_id)
        local herb = S.herbs[recipe_id]
        if herb and progress then progress.discover(uuid, HERB .. ":" .. herb.short) end
    end)
end

-- Own effects, started when an elixir is drunk.
local own = {}
for _, elixir in ipairs(C.elixirs) do
    if elixir.own then own[U.id(elixir.id)] = elixir.own end
end
if life then
    life.on_eat(function(uuid, material)
        local effect = own[material]
        if effect then tdm.effects.start(uuid, effect[1], effect[2]) end
    end)
end

return S
