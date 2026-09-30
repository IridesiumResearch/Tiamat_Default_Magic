-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The glyphs (brief §7.1): every shape in `glyph_table.lua`, in each of its
-- distinct rotations and mirrorings, registered with Craft's glyph registry
-- — the one both trees share, so a mask means one thing in the world — and
-- the seven sigils as one-click buttons in the interface's shape crafter,
-- shown to whoever knows the Seven Metals.

local C = tdm.config
local U = tdm.util

local G = {}

local craft = U.exports("tiamat_default_craft")
local progress = U.exports("tiamat_default_progress")
local ui = U.exports("tiamat_default_ui")

--- Every distinct image of `mask` under the 48 symmetries of the cube:
--- the six orders of the three axes, each axis kept or reversed.
function G.variants(mask)
    local cells = {}
    for i = 0, 26 do
        if (mask >> i) & 1 == 1 then cells[#cells + 1] = { i % 3, (i // 3) % 3, i // 9 } end
    end
    local seen, out = {}, {}
    local orders = { { 1, 2, 3 }, { 1, 3, 2 }, { 2, 1, 3 }, { 2, 3, 1 }, { 3, 1, 2 }, { 3, 2, 1 } }
    for _, order in ipairs(orders) do
        for flips = 0, 7 do
            local m = 0
            for _, c in ipairs(cells) do
                local v = { c[order[1]], c[order[2]], c[order[3]] }
                for axis = 1, 3 do
                    if (flips >> (axis - 1)) & 1 == 1 then v[axis] = 2 - v[axis] end
                end
                m = m | (1 << (v[1] + 3 * v[2] + 9 * v[3]))
            end
            if not seen[m] then
                seen[m] = true
                out[#out + 1] = m
            end
        end
    end
    table.sort(out)
    return out
end

G.table = tdm.glyph_table
G.by_id = {}                -- short id -> its entry, with `variants`
G.by_qualified = {}         -- qualified glyph id -> its entry

for _, glyph in ipairs(G.table) do
    glyph.variants = G.variants(glyph.mask)
    glyph.qualified = U.id(glyph.id)
    G.by_id[glyph.id] = glyph
    G.by_qualified[glyph.qualified] = glyph
    if craft then
        for _, mask in ipairs(glyph.variants) do
            local ok, why = craft.register_glyph(mask, glyph.qualified)
            if not ok then
                game.log(string.format("tiamat_default_magic: Craft refused glyph %s (mask %d): %s",
                    glyph.id, mask, tostring(why)))
            end
        end
    end
end

--- The glyph a carved mask reads as, this mod's entry, or nil.
function G.of(mask)
    if not craft or type(mask) ~= "number" then return nil end
    local id = craft.glyph_of(mask)
    return id and G.by_qualified[id] or nil
end

-- The sigils as one-click shapes, for whoever knows the Seven Metals.
if ui and ui.add_preset then
    for _, glyph in ipairs(G.table) do
        if glyph.label then
            local ok, why = ui.add_preset{
                id = U.id("preset_" .. glyph.id),
                label = glyph.label,
                mask = glyph.mask,
                visible = function(player)
                    return progress ~= nil and progress.has(player, C.sigils.node) == true
                end,
            }
            if not ok then game.log("tiamat_default_magic: the interface refused a preset: " .. tostring(why)) end
        end
    end
end

return G
