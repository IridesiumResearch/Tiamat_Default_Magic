-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- What other mods may call (brief §12; docs/exports.md is the list). Built
-- whole here, because the engine takes one export per mod. The brief's
-- other fields — the Quintessence bar, herbs, wards, the Opus's
-- subscribers — are added as the parts of the Art they read are built:
-- an export that answers nothing yet is a promise nobody can test.
--
-- Nothing here raises: a malformed question answers nil and a reason.

local U = tdm.util

local E = {}

E.version = 1

--- Every glyph of the Art: `{ [id] = { mask, variants = { ... } } }`, the
--- short id (`"sol"`) to its canonical mask and every orientation Craft
--- knows it by. Plain data, built once.
E.glyphs = {}
for _, glyph in ipairs(tdm.glyphs.table) do
    E.glyphs[glyph.id] = { mask = glyph.mask, variants = U.plain(glyph.variants) }
end

--- A player's familiars whose bodies are in the world: `{ { kind, entity } }`.
function E.familiars(uuid)
    if type(uuid) ~= "string" or not string.match(uuid, "^%x+$") then return nil, "familiars takes a player's UUID" end
    return tdm.familiars.list(uuid)
end

return E
