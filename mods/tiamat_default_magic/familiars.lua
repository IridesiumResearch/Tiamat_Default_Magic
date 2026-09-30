-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Familiars (brief §6.9): the living work. Found, then bound.
--
-- The salamander first, as Benvenuto Cellini saw one as a boy, in the fire.
-- An athanor kept burning a whole philosophical day draws one, for an adept
-- who knows the Salamander and stands near it; fed a handful of sulfur, it
-- is theirs. Bound, it follows them, and leaves them its ember, which in an
-- athanor's vessel slot blows the 4th degree as bellows do.
--
-- An entity is kept by the engine across a save, but its id is not, so a
-- familiar is a RECORD and its body is made when its master is here:
-- `familiar:<uuid>:<kind>` in storage, `true` while they walk the path and
-- `"dormant"` after they repath away. The body is spawned on join and
-- despawned on leave. A salamander this mod is not keeping — a wild one left
-- by a restart, a body a crash did not despawn — is cleared when a player
-- joins near it.
--
-- Nothing scans the world: the athanors are Craft's containers, listed by
-- the engine; each is looked into every `check_every` ticks.

local C = tdm.config
local U = tdm.util

local F = {}

local craft = U.exports("tiamat_default_craft")
local progress = U.exports("tiamat_default_progress")
local S = C.salamander

local MODEL = U.id(S.model.id)
local LIT = U.material(U.id(C.athanor.lit.id))
local STATION = U.id(C.athanor.station)
local PREFIX = "tiamat_default_craft:" .. STATION .. ":"
local EMBER = U.id(S.ember)
local DISCOVERY = game.mod_id .. ".familiar_salamander"

local ok, why = pcall(game.register_model, { id = S.model.id, file = S.model.file, texture = S.model.texture })
if not ok then game.log("tiamat_default_magic: the salamander's model was refused: " .. tostring(why)) end

if progress then
    progress.register_discovery{ id = DISCOVERY, insight = S.discovery, label = "A salamander, bound", group = "familiars" }
end

local food = {}
for _, id in ipairs(S.food) do
    local m = U.material(U.id(id))
    if m then food[m] = true end
end

local wild = {}             -- entity -> { adept = uuid, container }
local bound = {}            -- uuid -> entity
local owner_of = {}         -- entity -> uuid

local function count()
    local n = 0
    for _ in pairs(wild) do n = n + 1 end
    for _ in pairs(bound) do n = n + 1 end
    return n
end

local function record_key(uuid)
    return "familiar:" .. uuid .. ":salamander"
end

--- Where a player's body is, or nil.
local function where(uuid)
    local body = game.player_entity(uuid)
    local e = body and game.entity(body)
    return e and e.pos or nil
end

local function spawn(pos)
    if count() >= C.familiars.per_server then return nil end
    return game.spawn_entity{ pos = pos, model = MODEL, health = S.health, speed = S.speed,
        nametag = S.name, collider = S.collider }
end

--- The salamander that is a player's, if its body is in the world.
function F.of(uuid)
    return bound[uuid]
end

--- Every familiar a player has, as `{ { kind, entity } }` (the export).
function F.list(uuid)
    local out = {}
    if bound[uuid] then out[1] = { kind = "salamander", entity = bound[uuid] } end
    return out
end

-- Calling one --------------------------------------------------------------------------

--- The adept near `pos` a salamander would come for: holds the node, is on
--- the path, has no salamander, and is nearest.
local function adept_near(pos)
    if not progress then return nil end
    local best, best_d = nil, nil
    for _, id in ipairs(game.entities_in_radius(pos, S.reach)) do
        local e = game.entity(id)
        local uuid = e and e.owner
        if uuid and progress.has(uuid, S.node) and not bound[uuid]
            and game.storage.get(record_key(uuid)) == nil then
            local dx, dy, dz = e.pos.x - pos.x, e.pos.y - pos.y, e.pos.z - pos.z
            local d = dx * dx + dy * dy + dz * dz
            if not best_d or d < best_d then best, best_d = uuid, d end
        end
    end
    return best
end

local function looked_for(uuid)
    for _, w in pairs(wild) do
        if w.adept == uuid then return true end
    end
    return false
end

local elapsed = 0
tdm.on_tick(function(dt)
    elapsed = elapsed + (math.tointeger(dt) or 1)
    if elapsed < S.check_every then return end
    local step = elapsed
    elapsed = 0
    if not craft then return end
    for _, name in ipairs(game.containers(PREFIX)) do
        local pos = U.station_pos(name, STATION)
        local at = pos and game.get_block(pos)
        local burned_key = "burned:" .. name
        if at and at.material == LIT then
            local burned = (game.storage.get(burned_key) or 0) + step
            game.storage.set(burned_key, burned)
            if burned >= S.burn_days * C.philosophical_day and game.storage.get("called:" .. name) == nil then
                local above = { x = pos.x + 0.5, y = pos.y + 1, z = pos.z + 0.5, domain = pos.domain }
                local adept = adept_near(above)
                if adept and not looked_for(adept) then
                    local id = spawn(above)
                    if id then
                        wild[id] = { adept = adept, container = name }
                        game.storage.set("called:" .. name, true)
                        game.chat_to(adept, S.appears)
                        game.emit_particles{ pos = above, count = 24, colour = { r = 1, g = 0.6, b = 0.2 },
                            size = 0.15, velocity = { y = 1 }, spread = 1, lifetime = 1, collide = false }
                    end
                end
            end
        elseif game.storage.get(burned_key) ~= nil then
            -- Gone out: the day starts again, and it may call another.
            game.storage.set(burned_key, nil)
            game.storage.set("called:" .. name, nil)
        end
    end
end)

-- Binding one ----------------------------------------------------------------------------

tdm.on_use_entity(function(e)
    local w = wild[e.target]
    if not w then return nil end
    local held = e.held
    if not (held and food[held.material] and held.shape == nil and held.detail == nil) then
        return "It flickers, hungry. It wants sulfur."
    end
    if not (progress and progress.has(e.player, S.node)) then
        return "It will not come to you. You do not know the Salamander."
    end
    if bound[e.player] then return "You have a salamander already." end
    if game.take(e.player, { material = held.material, units = S.food_units }) < S.food_units then
        return "It wants a handful of sulfur."
    end
    wild[e.target] = nil
    bound[e.player] = e.target
    owner_of[e.target] = e.player
    game.storage.set(record_key(e.player), true)
    game.give(e.player, { material = EMBER, count = 1 })
    game.chat_to(e.player, S.bound)
    if progress then progress.discover(e.player, DISCOVERY) end
    return ""
end)

-- Following ---------------------------------------------------------------------------------

local thought = 0
tdm.on_tick(function(dt)
    thought = thought + (math.tointeger(dt) or 1)
    if thought < C.familiars.think_every then return end
    thought = 0
    for uuid, id in pairs(bound) do
        local master = where(uuid)
        local me = game.entity(id)
        if not me then
            bound[uuid], owner_of[id] = nil, nil       -- killed, or gone: it comes back on the next join
        elseif master then
            -- How far, across the ground: a steering choice, not a quantity
            -- the world keeps, so the positions' own numbers are enough.
            local dx, dz = master.x - me.pos.x, master.z - me.pos.z
            local d2 = dx * dx + dz * dz
            local near, lost = C.familiars.near, C.familiars.lost
            if d2 > lost * lost then
                game.set_entity(id, { pos = { x = master.x + 1, y = master.y, z = master.z + 1 } })
            elseif d2 > near * near then
                game.steer_entity(id, master)
            end
        end
    end
end)

-- Coming and going ----------------------------------------------------------------------------

--- Clears salamanders near `pos` that nobody is keeping: a crash's leftovers.
local function clear_orphans(pos)
    for _, id in ipairs(game.entities_in_radius(pos, C.familiars.orphans, game.mod_id)) do
        local e = game.entity(id)
        if e and e.model == MODEL and not wild[id] and not owner_of[id] then game.despawn_entity(id) end
    end
end

local function come(uuid)
    if bound[uuid] or game.storage.get(record_key(uuid)) ~= true then return end
    local pos = where(uuid)
    if not pos then return end
    local id = spawn({ x = pos.x + 1, y = pos.y, z = pos.z + 1 })
    if id then
        bound[uuid] = id
        owner_of[id] = uuid
    end
end

local function go(uuid)
    local id = bound[uuid]
    if not id then return end
    game.despawn_entity(id)
    bound[uuid], owner_of[id] = nil, nil
end

tdm.on_join(function(event)
    local pos = where(event.player)
    if pos then clear_orphans(pos) end
    come(event.player)
end)

tdm.on_leave(function(event) go(event.player) end)

-- The path: repathing away sends a familiar to sleep, and back wakes it.
if progress then
    progress.on_repath(function(uuid, old, new)
        if old == C.path.id and game.storage.get(record_key(uuid)) == true then
            go(uuid)
            game.storage.set(record_key(uuid), "dormant")
        elseif new == C.path.id and game.storage.get(record_key(uuid)) == "dormant" then
            game.storage.set(record_key(uuid), true)
            come(uuid)
        end
    end)
end

return F
