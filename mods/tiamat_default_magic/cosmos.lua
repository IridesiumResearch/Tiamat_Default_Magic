-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Cosmos, tier 6 (brief §6.11): the microcosm and the correspondence gates.
--
-- **The microcosm** — "man is a little world", Paracelsus. One instanced
-- domain template; each adept's instance is keyed by the first 16 hex of
-- their UUID, so it is theirs and only theirs, and the engine keeps it
-- across restarts. Its generator is a floating island: a flattened sphere
-- of stone under dirt under turf, air all round — a density field compiled
-- once at load, read in every generation worker, and a pure function of
-- position (the generator never needs to know whose island it fills: they
-- are all the same island, and each is its owner's own copy). Using the
-- Philosophers' Egg in hand takes its owner there, from wherever they
-- stood, and back again.
--
-- **As above, so below** — a correspondence gate is an emerald glyph with
-- Sol and Luna sigils on the alternate corners round it. Two gates are
-- linked by using each in turn with a quintessence in hand; stepping onto
-- one sets the walker down on the other, for quintessence. Same domain
-- only: crossing between worlds is the World-Gate's (tier 7, worlds.lua),
-- and a gate bound to a world is a World-Gate and carries nobody here.

local C = tdm.config
local U = tdm.util
local G = tdm.glyphs
local Q = tdm.quintessence

local W = {}

local progress = U.exports("tiamat_default_progress")

-- The microcosm -----------------------------------------------------------------------------

local M = C.microcosm
local TEMPLATE = U.id(M.template)
local GRASS, DIRT, STONE = U.material(U.id(M.ground.grass)), U.material(U.id(M.ground.dirt)), U.material(U.id(M.ground.stone))

--- The island: positive inside a flattened sphere centred under the turf,
--- cut flat at the top, and the value there is how deep below the turf.
local function const(v) return { op = "const", value = v } end
local function sub(a, b) return { op = "sub", a = a, b = b } end
local function mul(a, b) return { op = "mul", a = a, b = b } end
local function add(a, b) return { op = "add", a = a, b = b } end
local function square_over(a, scale)
    local q = { op = "div", a = a, b = const(scale) }
    return mul(q, q)
end
local below_top = sub(const(M.top + 0.5), { op = "y" })
local centred_y = sub({ op = "y" }, const(M.top - M.depth / 2))
local sphere = sub(const(1), add(add(square_over({ op = "x" }, M.radius), square_over({ op = "z" }, M.radius)),
    square_over(centred_y, M.depth)))
local ISLAND = game.density{ op = "min", a = below_top, b = mul(const(M.depth), sphere) }

if GRASS and DIRT and STONE then
    game.register_domain{
        id = M.template,
        instanced = true,
        generator = function(buf, pos)
            if ISLAND:bounds(pos).all_empty then return end
            buf:fill_palette(ISLAND, {
                { above = 0.0, material = GRASS },
                { above = 1.0, material = DIRT },
                { above = 4.0, material = STONE },
            })
        end,
    }
end

local VISIT = game.mod_id .. ".microcosm"
if progress then
    progress.register_discovery{ id = VISIT, insight = M.discovery, label = "A world in the Egg", group = "milestones" }
end

local EGG = U.material(U.id(M.egg))

local function return_key(uuid) return "microreturn:" .. uuid end

--- Takes a player into their microcosm, or back out of it.
local function travel(uuid, domain)
    local body = game.player_entity(uuid)
    local me = body and game.entity(body)
    if not me then return "" end
    local mine = TEMPLATE .. "/" .. string.sub(uuid, 1, 16)
    if domain == mine then
        local back = tostring(game.storage.get(return_key(uuid)) or "")
        local x, y, z, from = string.match(back, "^(%-?[%d.]+),(%-?[%d.]+),(%-?[%d.]+),(.+)$")
        if not x then return "The Egg will not open the way back." end
        if not game.transfer_entity(body, from, { x = tonumber(x), y = tonumber(y), z = tonumber(z) }) then
            return "The Egg will not open the way back."
        end
        return ""
    end
    local id = game.create_domain(TEMPLATE, string.sub(uuid, 1, 16))
    if not id then return "The Egg is cold." end
    game.storage.set(return_key(uuid), string.format("%.2f,%.2f,%.2f,%s", me.pos.x, me.pos.y, me.pos.z, domain or "overworld"))
    if not game.transfer_entity(body, id, M.arrive) then return "The Egg is cold." end
    if progress then progress.discover(uuid, VISIT) end
    return ""
end

tdm.on_use(function(e)
    if not (e.held and e.held.material == EGG) then return nil end
    local out = tdm.worlds and tdm.worlds.egg_use(e)    -- inside a woven world, the Egg goes back
    if out then return out end
    if not (progress and progress.has(e.player, M.node)) then return nil end   -- an egg is a vessel to everybody else
    return travel(e.player, e.domain)
end)

-- Correspondence gates ------------------------------------------------------------------------

local K = C.correspondence
local LINK = U.material(U.id(K.link_with))

local function glyph_at(x, y, z)
    local b = game.get_block{ x = x, y = y, z = z }
    local g = b and b.occupancy and G.of(b.occupancy)
    return g and g.id or nil
end

--- Whether an emerald at `x, y, z` is a gate: Sol on one diagonal, Luna on the other.
function W.gate(x, y, z)
    if glyph_at(x, y, z) ~= "emerald" then return false end
    local a, b = glyph_at(x + 1, y, z + 1), glyph_at(x - 1, y, z - 1)
    local c, d = glyph_at(x + 1, y, z - 1), glyph_at(x - 1, y, z + 1)
    return (a == "sol" and b == "sol" and c == "luna" and d == "luna")
        or (a == "luna" and b == "luna" and c == "sol" and d == "sol")
end

local function pair_key(x, y, z) return string.format("gatepair:%d,%d,%d", x, y, z) end
local pending = {}          -- uuid -> the gate they used first
local carried = {}          -- uuid -> clock tick before which they are not carried again

local function pairs_of(uuid)
    local n = 0
    for _, k in ipairs(game.storage.keys("gateowner:")) do
        if game.storage.get(k) == uuid then n = n + 1 end
    end
    return n // 2
end

-- Heard at crystal, where a gate's emerald is carved, before any mod's
-- handler for what is held: a quintessence is a drink to Life.
tdm.on_use_at({ "tiamat_default_world:crystal" }, function(e)
    if not (e.x and e.held and e.held.material == LINK) then return nil end
    local at = U.block_of(e)
    if not W.gate(at.x, at.y, at.z) then return nil end
    if not (progress and progress.has(e.player, K.node)) then return "You do not know the correspondence." end
    local first = pending[e.player]
    if not first or (first.x == at.x and first.y == at.y and first.z == at.z) then
        pending[e.player] = at
        return "The emerald hums. Use its twin."
    end
    if pairs_of(e.player) >= K.per_player then return "You hold as many gates as you can." end
    if game.take(e.player, { material = LINK, count = 1 }) < U.UNITS then return "" end
    pending[e.player] = nil
    game.storage.set(pair_key(first.x, first.y, first.z), string.format("%d,%d,%d", at.x, at.y, at.z))
    game.storage.set(pair_key(at.x, at.y, at.z), string.format("%d,%d,%d", first.x, first.y, first.z))
    game.storage.set(string.format("gateowner:%d,%d,%d", first.x, first.y, first.z), e.player)
    game.storage.set(string.format("gateowner:%d,%d,%d", at.x, at.y, at.z), e.player)
    return "As above, so below: the gates are one."
end)

tdm.on_move(function(e)
    if e.domain ~= "overworld" then return end
    local x, y, z = e.x, e.y - 1, e.z
    if tdm.worlds and tdm.worlds.gate_of(x, y, z) then return end   -- a World-Gate's, now
    local twin = game.storage.get(pair_key(x, y, z))
    if type(twin) ~= "string" then return end
    if (carried[e.player] or 0) > tdm.effects.now() then return end
    local tx, ty, tz = string.match(twin, "^(%-?%d+),(%-?%d+),(%-?%d+)$")
    tx, ty, tz = math.tointeger(tonumber(tx)), math.tointeger(tonumber(ty)), math.tointeger(tonumber(tz))
    if not (W.gate(x, y, z) and W.gate(tx, ty, tz)) then return end
    if not Q.spend(e.player, K.cost) then return end
    carried[e.player] = tdm.effects.now() + K.rest
    game.move_player(e.player, { x = tx + 0.5, y = ty + 1, z = tz + 0.5 })
end)

tdm.on_leave(function(e) pending[e.player], carried[e.player] = nil, nil end)

return W
