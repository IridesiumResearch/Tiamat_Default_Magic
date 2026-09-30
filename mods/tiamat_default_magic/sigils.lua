-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The Signs of the Seven at the athanor (brief §6.5).
--
-- A sigil is a whole block with a planet's sign cut into it (glyphs.lua).
-- Set against a burning athanor, it speeds the work of its own metal: by
-- the setter's `magic.sigil_percent`, and by twice that when it is carved
-- from the metal's own ore — gold ore for Sol, cinnabar for Mercury. The
-- knowledge is the setter's: a sigil set by somebody who never learned the
-- Signs is a carved stone and nothing more.
--
-- Nothing ticks by scanning the world. The athanors are Craft's containers,
-- which the engine lists by name; each is looked at every `every` ticks, at
-- most `budget` a pass, and only its six neighbours are read. Who set a
-- sigil is remembered when it is placed (`sigil:x,y,z`) and forgotten when
-- it is dug. The engine's place event names no domain, so a sigil counts in
-- the overworld, where athanors are built.

local C = tdm.config
local U = tdm.util
local G = tdm.glyphs

local S = {}

local craft = U.exports("tiamat_default_craft")
local progress = U.exports("tiamat_default_progress")

local LIT = U.material(U.id(C.athanor.lit.id))
local STATION = U.id(C.athanor.station)
local PREFIX = "tiamat_default_craft:" .. STATION .. ":"

-- Which planet a material in an athanor belongs to, and each planet's ore.
local planet_of = {}
for planet, list in pairs(C.sigils.metals) do
    for _, id in ipairs(list) do
        local m = U.material(U.id(id))
        if m then planet_of[m] = planet end
    end
end
local ore_of = {}
for _, glyph in ipairs(G.table) do
    if glyph.planet and glyph.ore then ore_of[glyph.planet] = U.material(U.id(glyph.ore)) end
end

local function key(x, y, z)
    return string.format("sigil:%d,%d,%d", x, y, z)
end

-- Who set it: remembered when a sigil is placed, forgotten when dug.
tdm.on_place(function(e)
    local glyph = G.of(e.occupancy)
    if glyph and glyph.planet then game.storage.set(key(e.x, e.y, e.z), e.player) end
    return nil
end)

tdm.on_dig(function(e)
    local k = key(e.x // 3, e.y // 3, e.z // 3)
    if game.storage.get(k) ~= nil then game.storage.set(k, nil) end
end)

--- The planets whose metal is in an athanor's inputs.
local function planets_in(name)
    local found = {}
    for _, stack in ipairs(game.container(name)) do
        local slot = stack.slot
        if slot >= C.athanor.slots.input.from and slot <= C.athanor.slots.input.to then
            local planet = planet_of[stack.material]
            if planet then found[planet] = true end
        end
    end
    return found
end

local SIDES = { { 1, 0, 0 }, { -1, 0, 0 }, { 0, 1, 0 }, { 0, -1, 0 }, { 0, 0, 1 }, { 0, 0, -1 } }

--- The speed-up a burning athanor has from the sigils touching it, in per
--- cent: the best sigil of a metal it is working, by its setter's knowledge.
function S.percent(name, pos)
    local wanted = planets_in(name)
    if next(wanted) == nil then return 0 end
    local best = 0
    for _, d in ipairs(SIDES) do
        local x, y, z = pos.x + d[1], pos.y + d[2], pos.z + d[3]
        local at = game.get_block{ x = x, y = y, z = z, domain = pos.domain }
        local glyph = at and at.occupancy and G.of(at.occupancy)
        if glyph and glyph.planet and wanted[glyph.planet] then
            local setter = game.storage.get(key(x, y, z))
            local known = 0
            if type(setter) == "string" and progress then
                known = progress.effects_of(setter, "magic.")["magic.sigil_percent"] or 0
            end
            if at.material == ore_of[glyph.planet] then known = known * C.sigils.ore_times end
            if known > best then best = known end
        end
    end
    return best
end

local elapsed = 0
local cursor = 0
tdm.on_tick(function(dt)
    elapsed = elapsed + (math.tointeger(dt) or 1)
    if elapsed < C.sigils.every then return end
    elapsed = 0
    if not craft then return end
    local names = game.containers(PREFIX)
    local count = #names
    if count == 0 then return end
    for i = 1, math.min(count, C.sigils.budget) do
        cursor = cursor % count + 1
        local name = names[cursor]
        local pos = U.station_pos(name, STATION)
        local at = pos and game.get_block(pos)
        if at and at.material == LIT then
            local percent = S.percent(name, pos)
            if percent > 0 then craft.add_progress(name, C.sigils.every * percent // 100) end
        end
    end
end)

return S
