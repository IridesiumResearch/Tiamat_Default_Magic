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

--- A player's quintessence, and its ceiling (0 off the magic path).
function E.quintessence(uuid)
    if type(uuid) ~= "string" then return nil, "quintessence takes a player's UUID" end
    return tdm.quintessence.amount(uuid), tdm.quintessence.ceiling(uuid)
end

--- Takes `n` of a player's quintessence if they have it: true, else false.
function E.spend_quintessence(uuid, n)
    if type(uuid) ~= "string" or math.type(n) ~= "integer" or n < 0 then return nil, "spend_quintessence(uuid, n)" end
    return tdm.quintessence.spend(uuid, n)
end

--- Whether a Hermetic Seal forbids `uuid` to dig or build at `pos`
--- (`{ x, y, z, domain? }`, whole blocks; the overworld when no domain).
function E.is_warded(pos, uuid)
    if type(pos) ~= "table" or type(uuid) ~= "string" then return nil, "is_warded takes a position and a UUID" end
    local x, y, z = math.tointeger(pos.x), math.tointeger(pos.y), math.tointeger(pos.z)
    if not (x and y and z) then return nil, "a position is whole blocks" end
    return tdm.seal.warding(x, y, z, uuid, pos.domain) ~= nil
end

--- A player's bound familiars: `{ { kind, entity } }`, entity nil for one
--- resting or not here.
function E.familiars(uuid)
    if type(uuid) ~= "string" or not string.match(uuid, "^%x+$") then return nil, "familiars takes a player's UUID" end
    return tdm.familiars.list(uuid)
end

return E
