-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Pyrite in the rain (brief §6.4): the mines' copperas. Pyrite left wet
-- under open sky weathers, and dug, it gives green vitriol instead of
-- itself — the second way to vitriol, beside three days in Maria's bath.
--
-- The world does not tick pyrite, and leaves the one handler the engine
-- allows a material to this mod (the world's answer to W-M3). A block comes
-- up about every twenty minutes; when it does and rain or a storm is
-- falling on it from open sky, it is weathered, and remembered so
-- (`weathered:x,y,z`) until it is dug. Nothing here scans: the engine picks
-- the blocks. Without Weather there is no rain to weather anything, and the
-- bath is the only way.
--
-- The random tick names no domain, so this is the overworld's pyrite.

local C = tdm.config
local U = tdm.util

local W = {}

local weather = U.exports("tiamat_weather")
local PYRITE = U.material(U.id(C.weathering.block))
local VITRIOL = U.id(C.weathering.becomes)

local function key(x, y, z)
    return string.format("weathered:%d,%d,%d", x, y, z)
end

--- Whether rain falls on the block at `x, y, z` from open sky.
function W.rained_on(x, y, z)
    if not weather then return false end
    local kind = weather.weather_at(x, y, z)
    if not C.weathering.wet[kind] then return false end
    local light = game.get_light{ x = x, y = y + 1, z = z }
    return light ~= nil and light.sun == 15
end

if PYRITE and weather then
    game.register_random_tick(PYRITE, function(e)
        if W.rained_on(e.x, e.y, e.z) then game.storage.set(key(e.x, e.y, e.z), true) end
    end)
end

tdm.on_dig(function(e)
    if e.material ~= PYRITE then return nil end
    local k = key(e.x // 3, e.y // 3, e.z // 3)
    if game.storage.get(k) ~= true then return nil end
    game.storage.set(k, nil)
    return { drops = { [VITRIOL] = U.UNITS } }
end)

return W
