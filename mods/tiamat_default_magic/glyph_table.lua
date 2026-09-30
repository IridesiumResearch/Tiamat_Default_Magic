-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The glyphs of the Art (brief §7.1), as DATA and nothing else: `glyphs.lua`
-- registers them with Craft, `tools/glyphs.py` reads this very file to
-- prove them sound, so it stays a plain table literal.
--
-- A glyph is a 27-cell mask, cell `x + 3*y + 9*z` is bit `x + 3*y + 9*z`,
-- carved in the interface's shape crafter from a whole block: the editor
-- starts full and a click removes a cell, so the seven sigils are INTAGLIO,
-- a block with the sign cut into its top face. Rotation and mirror do not
-- matter; every distinct one of the 48 symmetries is registered.
--
-- `planet` makes a sigil (brief §6.5): it speeds its own metal's work at an
-- athanor it touches, twice as much carved from `ore`. `element` makes one
-- of the Circle's four (§7.3), which counts only carved from one of
-- `materials`. `label` is the shape crafter's one-click button (8 bytes).

return {
    { id = "sol", mask = 16612927, planet = "sol", ore = "W:gold_ore", label = "Sol" },
    { id = "luna", mask = 83853119, planet = "luna", ore = "W:silver_ore", label = "Luna" },
    { id = "venus", mask = 100433791, planet = "venus", ore = "W:copper_ore", label = "Venus" },
    { id = "mars", mask = 117374719, planet = "mars", ore = "W:iron_ore", label = "Mars" },
    { id = "jupiter", mask = 100433855, planet = "jupiter", ore = "W:tin_ore", label = "Jupiter" },
    { id = "saturn", mask = 50233279, planet = "saturn", ore = "W:lead_ore", label = "Saturn" },
    { id = "mercury", mask = 100597439, planet = "mercury", ore = "W:cinnabar", label = "Mercury" },
    { id = "fire", mask = 6127127, element = "fire", materials = { "W:lava_rock", "W:magma_crust" } },
    { id = "water", mask = 134143999, element = "water", materials = { "W:ice", "W:clear_ice", "W:calcite" } },
    { id = "air", mask = 129928175, element = "air", materials = { "W:pumice" } },
    { id = "earth", mask = 49020602, element = "earth", materials = { "W:granite" } },
    { id = "quintessence", mask = 4289552, materials = { "W:crystal" } },
    { id = "ouroboros", mask = 14700600 },
    { id = "seal", mask = 134151167 },
    { id = "emerald", mask = 50331327, materials = { "W:crystal" } },
}
