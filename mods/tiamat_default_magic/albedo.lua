-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Tier 5, the White Work (brief §5.3).
--
-- The recipes are data (`config.lua`, `tier5_recipes`): Gates VI to VIII
-- (Congelation fixes quicksilver, Cibation feeds the Peacock matter until
-- it grows, Sublimation raises the Eagle); the Albedo, seven philosophical
-- days in the Egg, and its yellowing; aurum potabile, the lesser Elixir of
-- Life and the quintessence itself; Maria's kerotakis and electrum; and
-- orichalcum woken by it. This file adds what is more than a recipe:
--
-- - projection: the White Stone on base metal makes silver, while the world
--   allows transmutation (its world option; off, the Stone is only an
--   ingredient and a study);
-- - orichalcum tools, Craft's tier 4, engine tools that dig;
-- - the Assay: this mod's studies pay the assayer more;
-- - Atalanta Fugiens: an emblem for each first, once the book is known.

local C = tdm.config
local U = tdm.util
local R = tdm.recipes

local A = {}

local craft = U.exports("tiamat_default_craft")
local progress = U.exports("tiamat_default_progress")

R.register_all(C.tier5_recipes)
for _, study in ipairs(C.tier5_studies) do C.studies[#C.studies + 1] = study end

-- Projection --------------------------------------------------------------------------

local P = C.white_projection
local transmutation = game.world_option(C.transmutation_option)
A.transmutation = transmutation ~= false
local MILESTONE = game.mod_id .. ".transmutation"

if A.transmutation then
    R.group(P.base, P.base_members)
    R.register{
        id = "projection_white", station = "hand", node = P.node,
        inputs = { { "white_stone", count = 1 }, { P.base, count = P.count } },
        outputs = { { P.makes, count = P.count } },
    }
    if progress then
        progress.register_discovery{ id = MILESTONE, insight = P.milestone, label = "A first transmutation",
            group = "milestones" }
    end
end

-- Orichalcum tools ----------------------------------------------------------------------

local O = C.orichalcum
for _, tool in ipairs(C.orichalcum_tools) do
    game.register_item{ id = tool.id, name = tool.name, texture = "textures/" .. tool.id .. ".png",
        description = string.format("Tier %d, of living orichalcum. Wears after %d uses.", O.tier, O.uses) }
    game.register_tool{ id = tool.id, name = tool.name, brush = tool.brush or "block", speed_multiplier = tool.speed }
    if craft then
        local ok, why = craft.register_tool{ id = U.id(tool.id), type = tool.type, tier = O.tier, uses = O.uses,
            digs = true, name = tool.name }
        if not ok then game.log("tiamat_default_magic: Craft refused the tool " .. tool.id .. ": " .. tostring(why)) end
    end
    R.register{
        id = tool.id, station = "workbench", node = O.node,
        inputs = { { "living_orichalcum", count = tool.ingots }, tool.brush and { "C:stick", count = 1 } or { "C:haft", count = 1 } },
        outputs = { { tool.id, count = 1 } },
    }
end
local life = U.exports("tiamat_default_life")
if life and life.add_weapon then
    for _, tool in ipairs(C.orichalcum_tools) do life.add_weapon(U.id(tool.id), O.weapon) end
end

-- The Assay, and the first transmutation ----------------------------------------------------

local studies = nil         -- qualified recipe id -> insight, built on first use: every tier has added its own by then
local function study_insight(id)
    if not studies then
        studies = {}
        for _, study in ipairs(C.studies) do studies[U.id(study.id)] = study.insight end
    end
    return studies[id]
end
local PROJECTION = U.id("projection_white")

if craft and progress then
    craft.on_crafted(function(uuid, recipe_id)
        local insight = study_insight(recipe_id)
        if insight then
            local bonus = progress.effects_of(uuid, "magic.")["magic.study_bonus_percent"] or 0
            if bonus > 0 then progress.award(uuid, insight * bonus // 100, "the assay") end
        elseif recipe_id == PROJECTION then
            progress.discover(uuid, MILESTONE)
        end
    end)
end

-- Atalanta Fugiens: an emblem for a first ---------------------------------------------------------

local E = C.emblems
local EMBLEM = game.mod_id .. ".emblem"
local PREFIX = game.mod_id .. "."

if progress then
    local names, keys = {}, {}
    for key, title in pairs(E.by_discovery) do
        local short = string.gsub(key, "[^%w_]", "_")
        names[short] = "Emblem " .. title
        keys[PREFIX .. key] = short
    end
    progress.register_discovery{ id = EMBLEM .. ":*", insight = E.insight, label = "%s", group = "emblems", names = names }
    progress.on_discover(function(uuid, id)
        local short = keys[id]
        if short and progress.has(uuid, E.node) then progress.discover(uuid, EMBLEM .. ":" .. short) end
    end)
end

return A
