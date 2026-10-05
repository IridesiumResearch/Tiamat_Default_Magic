-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Tiamat Default Magic: the Hermetic Art (docs/brief.md). This file only
-- decides load order.
--
-- Every file below is loaded exactly once and hangs what it exports off the
-- `tdm` global, which the sandbox shares between a mod's own files. The
-- engine's `require` is confined to this directory and does not cache, so a
-- file required twice would run twice; nothing but this file calls it.
--
-- Order: numbers and helpers, then the hook fan-out every file subscribes
-- to, then what the Art registers — items and blocks before the recipes that
-- name them — then the book that shows them, and last the engine hooks and
-- the export, both of which must be whole before the registration window
-- closes.

tdm = {}

-- The host reports a failed load as "errored in init.lua" and nothing more,
-- so say which file and what the error was before letting it through.
local function load(name)
    local ok, result = pcall(require, name)
    if not ok then
        game.log(string.format("tiamat_default_magic: %s.lua failed: %s", name, tostring(result)))
        error(result, 0)
    end
    return result
end

tdm.config = load("config")
tdm.util = load("util")
tdm.hooks = load("hooks")               -- one engine registration per hook, many subscribers
tdm.recipes = load("recipes")           -- every recipe into Craft, the degrees of fire, the book's index
tdm.items = load("items")               -- every item, from config's tables; food into Life
tdm.blocks = load("blocks")             -- the door and the lamp
tdm.athanor = load("athanor")           -- the philosophers' furnace, and the laboratory's recipes
tdm.apprentice = load("apprentice")     -- the Apothecary's Bench: shared nodes, recipes, flames
tdm.effects = load("effects")           -- the effects Life does not have, as timers
tdm.spagyrics = load("spagyrics")       -- herbs, tinctures, elixirs
tdm.nigredo = load("nigredo")           -- tier 4: the strong waters, quicksilver, Gates IV and V
tdm.arbor = load("arbor")               -- the Tree of Diana, grown a cell at a time
tdm.albedo = load("albedo")             -- tier 5: Gates VI to VIII, the White Stone, orichalcum, emblems
tdm.quintessence = load("quintessence") -- the one bar, Life's, for magic players
tdm.glyph_table = load("glyph_table")   -- the glyphs, as data
tdm.glyphs = load("glyphs")             -- every glyph into Craft; the sigils' one-click presets
tdm.sigils = load("sigils")             -- a planet's sign at the athanor
tdm.weathering = load("weathering")     -- pyrite in the rain
tdm.familiars = load("familiars")       -- the living work: the salamander
tdm.talismans = load("talismans")       -- a planet's sign struck in its metal, worn
tdm.seal = load("seal")                 -- the Hermetic Seal: a ward
tdm.caduceus = load("caduceus")         -- Hermes' staff: the Stride, and elixirs shared
tdm.essences = load("essences")         -- essences of the beasts, and familiars' traits
tdm.cosmos = load("cosmos")             -- the microcosm, and the correspondence gates
tdm.rubedo = load("rubedo")             -- tier 6: the Red Stone, the alkahest, the Panacea, the Phoenix, the Wedding
tdm.arcanum = load("arcanum")           -- tier 7: Gate XII, the Rebis, the Four's quintessences, the Medicine, the capstone
tdm.worlds = load("worlds")             -- tier 7: the Loom, woven worlds, Solve et Coagula, the World-Gate
tdm.gates = load("gates")               -- Ripley's Gates as discoveries; every tier's studies (after the last tier)
tdm.tree = load("tree")                 -- the magic tree, tiers 3 to 7, as data
tdm.primer = load("primer")             -- the Mute Book
tdm.path = load("path")                 -- the Emerald Tablet's path, and the tree, into Progress
load("commands")                        -- `magic`, in chat

tdm.hooks.install()

-- What other mods may call. One export per mod, built whole first.
game.export(load("exports"))

game.log(string.format("tiamat_default_magic ready: the Apothecary's Bench (%d nodes), the Emerald Tablet, %d of %d path nodes (tiers 3 to %d)",
    #tdm.config.bench_nodes, #tdm.path.shipped, #tdm.tree, tdm.config.built_tier))
