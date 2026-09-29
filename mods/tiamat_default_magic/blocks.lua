-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The blocks this mod registers (brief §8). There will be five, and each is
-- a block only because it must be one; everything else the Art makes is an
-- item, and everything it builds is carved from the world's own blocks. So
-- far there is the Bench's one: light needs a block, because the engine has
-- no light an item gives.

local C = tdm.config

local B = {}

local lamp = C.hermetic_lamp
B.hermetic_lamp = game.register_block{
    id = lamp.id,
    name = lamp.name,
    description = lamp.description,
    hardness = lamp.hardness,
    tags = lamp.tags,
    -- Glass: seen through, and light passes a whole block of it.
    transparent = true,
    light_emit = lamp.light,
    textures = { all = "textures/" .. lamp.id .. ".png" },
}

return B
