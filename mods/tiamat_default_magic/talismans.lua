-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Planetary talismans (brief §6.6): a planet's sign struck in its metal.
--
-- A talisman is made on Craft's anvil from the metal, with a carved sigil
-- block as the die — named by its glyph, found and kept, never taken (Craft's
-- answer to C-M1). Worn in one of Life's four worn slots (Life's promise,
-- L-M4), it gives one passive, refreshed every `every` ticks while it is
-- worn and let lapse when it is not:
--
--   Sol       warmth: never cold                  Life's `warmth`
--   Luna      night-sight                         this mod's own effect
--   Venus     animals follow you                  Life's `follow`
--   Mars      a bare fist strikes harder          Life's `hurt`, on a punch
--   Jupiter   you tire slowly                     Life's `steady`
--   Saturn    ore nearby glints                   a layer of blocks read a look
--   Mercury   quick feet                          Life's composed abilities
--
-- How many count is `1 + magic.talisman_slots`, and each works at
-- `1 + magic.talisman_grade` (the Greater Talismans raise both). A player is
-- looked at once every `every` ticks, one player a tick, round the players
-- who are here.

local C = tdm.config
local U = tdm.util
local E = tdm.effects

local T = {}

local K = C.talismans
local life = U.exports("tiamat_default_life")
local progress = U.exports("tiamat_default_progress")

-- The dies' materials, and each talisman's item and recipe.
tdm.recipes.group(K.die, K.die_materials)
local by_material = {}      -- numeric material -> its kind
for _, kind in ipairs(K.kinds) do
    local id = "talisman_" .. kind.planet
    kind.id = id
    tdm.recipes.register{
        id = id, station = "anvil", node = K.node, strikes = K.strikes,
        inputs = { { kind.metal, count = 1 } },
        tools = { { "#hammer", wear = 1 }, { glyph = kind.planet, material = K.die, count = 1, wear = 0 } },
        outputs = { { id, count = 1 } },
    }
    local m = U.material(U.id(id))
    if m then by_material[m] = kind end
end

local ORES = {}
for _, id in ipairs(C.ores) do
    local m = U.material(U.id(id))
    if m then ORES[m] = true end
end

--- The talismans a player wears that count, as `{ planet = true }`, and the
--- grade they work at.
function T.worn(uuid)
    local fx = progress and progress.effects_of(uuid, "magic.") or {}
    local slots = 1 + (fx["magic.talisman_slots"] or 0)
    local grade = 1 + (fx["magic.talisman_grade"] or 0)
    local found, n = {}, 0
    for _, stack in ipairs(game.inventory(uuid, K.view) or {}) do
        local kind = by_material[stack.material]
        if kind and not found[kind.planet] and n < slots then
            found[kind.planet] = true
            n = n + 1
        end
    end
    return found, grade
end

-- The gifts ---------------------------------------------------------------------------

local MERCURY = game.mod_id .. ":talisman_mercury"
local quick = {}            -- uuid -> true while Mercury's speed is on them
local layer = {}            -- uuid -> the layer of Saturn's cube read next

local function body(uuid)
    local id = game.player_entity(uuid)
    local e = id and game.entity(id)
    return e and e.pos or nil
end

local function saturn(uuid, pos)
    local r = K.saturn_radius
    local l = layer[uuid] or -r
    layer[uuid] = l >= r and -r or l + 1
    local cx, cy, cz = math.floor(pos.x), math.floor(pos.y) + l, math.floor(pos.z)
    for dx = -r, r do
        for dz = -r, r do
            local at = game.get_block{ x = cx + dx, y = cy, z = cz + dz }
            if at and ORES[at.material] then
                game.emit_particles{ pos = { x = cx + dx + 0.5, y = cy + 0.5, z = cz + dz + 0.5 }, count = 3,
                    colour = { r = 0.9, g = 0.8, b = 0.4 }, size = 0.1, lifetime = 1.5, spread = 0.2,
                    collide = false, player = uuid }
            end
        end
    end
end

--- One look at a player: set what their talismans give, let lapse the rest.
function T.look(uuid)
    local worn, grade = T.worn(uuid)
    local lasts = K.lasts
    if life and life.add_effect then
        if worn.sol then life.add_effect(uuid, "warmth", lasts) end
        if worn.jupiter then life.add_effect(uuid, "steady", lasts) end
    end
    if worn.luna then E.start(uuid, "night_sight", lasts) end
    local pos = body(uuid)
    if worn.venus and pos and life and life.follow then
        for _, id in ipairs(game.entities_in_radius(pos, K.venus_radius * grade, "tiamat_default_life")) do
            life.follow(id, uuid, lasts)
        end
    end
    if worn.saturn and pos then saturn(uuid, pos) end
    if life and life.set_ability then
        if worn.mercury then
            life.set_ability(uuid, MERCURY, { speed_mul = 1 + K.mercury_speed * grade / 100 })
            quick[uuid] = true
        elseif quick[uuid] then
            life.set_ability(uuid, MERCURY, nil)
            quick[uuid] = nil
        end
    end
end

-- Mars: a bare fist strikes harder at a creature.
tdm.on_punch(function(e)
    if e.owner or not (life and life.hurt) then return nil end
    if game.held(e.attacker) ~= nil then return nil end
    local worn, grade = T.worn(e.attacker)
    if worn.mars then life.hurt(e.target, K.mars_extra * grade, "physical", e.attacker) end
    return nil
end)

-- One player a tick, each every `every` ticks at most.
local queue, since = {}, 0
tdm.on_tick(function(dt)
    since = since + (math.tointeger(dt) or 1)
    if #queue == 0 then
        if since < K.every then return end
        since = 0
        for _, uuid in ipairs(U.sorted_keys(tdm.online)) do queue[#queue + 1] = uuid end
    end
    local uuid = table.remove(queue, 1)
    if uuid and tdm.online[uuid] then T.look(uuid) end
end)

tdm.on_leave(function(event)
    quick[event.player], layer[event.player] = nil, nil
end)

return T
