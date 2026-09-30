-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Works at the athanor: the Signs of the Seven (brief §6.5) and the
-- Ouroboros ring (§7.3). And who set every carved glyph of the Art.
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
-- most `budget` a pass, and only its neighbours are read. Who set a carved
-- glyph — a sigil, a seal, an ouroboros — is remembered when it is placed
-- (`carved:x,y,z`) and forgotten when it is dug. The engine's place event
-- names no domain, so a carving counts in the overworld.
--
-- Eight ouroboros blocks round a burning athanor, at its own height, shorten
-- its works by their setter's `magic.long_work_percent` (the Ouroboros: 20
-- per cent less time, which is a quarter more work a tick).

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
    return string.format("carved:%d,%d,%d", x, y, z)
end

--- Who set the carved glyph at `x, y, z`, or nil.
function S.setter(x, y, z)
    local who = game.storage.get(key(x, y, z))
    return type(who) == "string" and who or nil
end

-- Who set it: remembered when a glyph of the Art is placed, forgotten when dug.
tdm.on_place(function(e)
    if G.of(e.occupancy) then game.storage.set(key(e.x, e.y, e.z), e.player) end
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

local RING = { { 1, 0 }, { 1, 1 }, { 0, 1 }, { -1, 1 }, { -1, 0 }, { -1, -1 }, { 0, -1 }, { 1, -1 } }
local OUROBOROS = G.by_id.ouroboros

--- The per cent less time an athanor's works take for a whole Ouroboros
--- ring round it, by the knowledge of whoever set the ring's first block.
function S.ring_percent(pos)
    local setter = nil
    for _, d in ipairs(RING) do
        local x, z = pos.x + d[1], pos.z + d[2]
        local at = game.get_block{ x = x, y = pos.y, z = z, domain = pos.domain }
        local glyph = at and at.occupancy and G.of(at.occupancy)
        if glyph ~= OUROBOROS then return 0 end
        setter = setter or S.setter(x, pos.y, z)
    end
    if not (setter and progress) then return 0 end
    local less = -(progress.effects_of(setter, "magic.")["magic.long_work_percent"] or 0)
    return math.max(0, math.min(less, 90))
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
            local extra = C.sigils.every * S.percent(name, pos) // 100
            local less = S.ring_percent(pos)
            if less > 0 then extra = extra + C.sigils.every * less // (100 - less) end
            if extra > 0 then craft.add_progress(name, extra) end
        end
    end
end)

return S
