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
tdm.items = load("items")               -- every item, from config's tables; food into Life
tdm.blocks = load("blocks")             -- the blocks the Art must have (one, so far)
tdm.apprentice = load("apprentice")     -- the Apothecary's Bench: shared nodes, recipes, flames
tdm.primer = load("primer")             -- the Mute Book
tdm.tree = load("tree")                 -- the magic tree, tiers 3 to 7, as data
tdm.path = load("path")                 -- the Emerald Tablet's path, and the tree, into Progress
load("commands")                        -- `magic`, in chat

tdm.hooks.install()

-- What other mods may call. One export per mod, built whole first.
game.export(load("exports"))

game.log(string.format("tiamat_default_magic ready: the Apothecary's Bench (%d nodes), the Emerald Tablet, %d path nodes",
    #tdm.config.bench_nodes, #tdm.tree))
