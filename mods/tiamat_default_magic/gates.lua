-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Ripley's Twelve Gates (brief §6.2), as the path's spine of discoveries,
-- and the studies the Art brings to Progress's research table (§6.12).
--
-- George Ripley's Compound of Alchymy (1471) names twelve gates in this
-- order: Calcination, Solution, Separation, Conjunction, Putrefaction,
-- Congelation, Cibation, Sublimation, Fermentation, Exaltation,
-- Multiplication, Projection. A recipe that completes a gate says so in
-- `config.lua` (`gate = n`); the first time a player makes one, the gate is
-- theirs, worth 25 x its number — Gate I 25 insight, Gate XII 300. All
-- twelve are registered now, so a later tier only has to name its gate.

local C = tdm.config
local U = tdm.util

local G = {}

local progress = U.exports("tiamat_default_progress")
local craft = U.exports("tiamat_default_craft")

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII" }

--- A gate's discovery id.
function G.id(n)
    return game.mod_id .. ".gate_" .. n
end

local VITRIOL = game.mod_id .. ".vitriol"

if progress then
    for n, name in ipairs(C.gates) do
        progress.register_discovery{ id = G.id(n), insight = C.gate_insight * n,
            label = string.format("Gate %s: %s", ROMAN[n], name), group = "gates" }
    end
    progress.register_discovery{ id = VITRIOL, insight = C.discoveries.vitriol.insight,
        label = C.discoveries.vitriol.label, group = "gates" }

    for _, study in ipairs(C.studies) do
        local inputs = {}
        for i, entry in ipairs(study.inputs) do inputs[i] = { U.id(entry[1]), count = entry.count } end
        local ok, why = progress.register_study{ id = U.id(study.id), name = study.name, inputs = inputs,
            ticks = study.ticks, insight = study.insight }
        if not ok then game.log("tiamat_default_magic: Progress refused the study " .. study.id .. ": " .. tostring(why)) end
    end
end

-- Which recipe opens which gate: read from the recipe as registered, when it
-- is made, so a tier loaded after this file is heard too.
local GREEN_VITRIOL = U.id("green_vitriol")

if craft and progress then
    craft.on_crafted(function(uuid, recipe_id)
        local r = tdm.recipes.by_id[recipe_id]
        local n = r and r.gate
        if n then progress.discover(uuid, G.id(n)) end
        if recipe_id == GREEN_VITRIOL then progress.discover(uuid, VITRIOL) end
    end)
end

return G
