-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The blocks this mod registers (brief §8). There will be five, and each is
-- a block only because it must be one; everything else the Art makes is an
-- item, and everything it builds is carved from the world's own blocks. So
-- far there are two: the Bench's lamp (light needs a block, because the
-- engine has no light an item gives) and the door (Progress's door must be
-- a block a player uses).

local C = tdm.config

local B = {}

local tablet = C.emerald_tablet
B.emerald_tablet = game.register_block{
    id = tablet.id,
    name = tablet.name,
    description = tablet.description,
    hardness = tablet.hardness,
    tags = tablet.tags,
    light_emit = tablet.light,
    textures = { all = "textures/" .. tablet.id .. ".png" },
}

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
