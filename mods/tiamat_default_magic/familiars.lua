-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Familiars (brief §6.9): the living work. Found, then bound.
--
-- Paracelsus' four elementals, each with a place it is found, a thing it is
-- fed to bind it, and a gift:
--
--   Salamander   in an athanor burning a whole       sulfur          its ember blows the 4th
--                philosophical day                                   degree; kilns burn longer
--   Undine       still water, at night               rosewater       carries water, douses fire
--   Gnome        the deep caves (the Gloam)          a silver grain  ore glints round you
--   Sylph        the peaks, or any storm             aqua vitae      a soft landing
--
-- A familiar is a RECORD, `familiar:<uuid>:<kind>`: `true` while it walks
-- with its master, `"resting"` when it does not (only `1 + magic.familiars`
-- walk at once; the newest bound, or the one called with `magic familiar
-- <kind>` or the K key, walks), and `"dormant"` after its master repaths
-- away. Its body
-- is made when its master is here — spawned on join, despawned on leave —
-- because the engine keeps an entity across a save but not its id. A body
-- of this mod's nobody is keeping, near a joining player, is a crash's
-- leftover and is cleared.
--
-- Nothing scans the world. The salamander's athanors are Craft's
-- containers, listed by the engine; the others are looked for round the
-- adepts who know them, one adept a tick, a few columns or one block each.

local C = tdm.config
local U = tdm.util

local F = {}

local craft = U.exports("tiamat_default_craft")
local progress = U.exports("tiamat_default_progress")
local life = U.exports("tiamat_default_life")
local world = U.exports("tiamat_default_world")
local weather = U.exports("tiamat_weather")

F.KINDS = { salamander = C.salamander, undine = C.undine, gnome = C.gnome, sylph = C.sylph,
    homunculus = C.homunculus, basilisk = C.basilisk }
F.ORDER = { "salamander", "undine", "gnome", "sylph", "homunculus", "basilisk" }

local MODELS = {}           -- qualified model id -> kind
local FOOD = {}             -- kind -> { numeric material = true }

for _, kind in ipairs(F.ORDER) do
    local K = F.KINDS[kind]
    local ok, why = pcall(game.register_model, { id = K.model.id, file = K.model.file, texture = K.model.texture })
    if not ok then game.log("tiamat_default_magic: the " .. kind .. "'s model was refused: " .. tostring(why)) end
    MODELS[U.id(K.model.id)] = kind
    FOOD[kind] = {}
    for _, id in ipairs(K.food) do
        local m = U.material(U.id(id))
        if m then FOOD[kind][m] = true end
    end
    if progress then
        progress.register_discovery{ id = game.mod_id .. ".familiar_" .. kind, insight = K.discovery,
            label = "A " .. string.lower(K.name) .. (K.made and ", made" or ", bound"), group = "familiars" }
    end
end

local EMBER = U.id(C.salamander.ember)
local WATER = "tiamat_default_world:water"
local WATER_ID = nil        -- the world's water's fluid number, asked once the world is open
local BUCKET = U.material("tiamat_default_life:bucket")
local WATER_BUCKET = U.id("tiamat_default_life:water_bucket")

-- The elementals' second gifts (tier 5), each a node of its own.
local GIFTS = C.gifts
local function gifted(uuid, gift)
    return progress ~= nil and progress.has(uuid, GIFTS[gift].node) == true
end

local wild = {}             -- entity -> { kind, adept, container? }
local bodies = {}           -- uuid -> { kind -> entity }
local owner_of = {}         -- entity -> { uuid, kind }

-- Records ------------------------------------------------------------------------------------

local function record_key(uuid, kind) return "familiar:" .. uuid .. ":" .. kind end
local function record(uuid, kind) return game.storage.get(record_key(uuid, kind)) end
local function set_record(uuid, kind, value) game.storage.set(record_key(uuid, kind), value) end

--- How many familiars may walk with a player at once.
function F.cap(uuid)
    local more = progress and progress.effects_of(uuid, "magic.")["magic.familiars"] or 0
    return C.familiars.base + more
end

local function count()
    local n = 0
    for _ in pairs(wild) do n = n + 1 end
    for _, kinds in pairs(bodies) do
        for _ in pairs(kinds) do n = n + 1 end
    end
    return n
end

local function where(uuid)
    local id = game.player_entity(uuid)
    local e = id and game.entity(id)
    return e and e.pos or nil, e
end

local function spawn(kind, pos, uuid)
    if count() >= C.familiars.per_server then return nil end
    local K = F.KINDS[kind]
    -- A familiar's traits, from the essences it was given (essences.lua).
    local speed, health = K.speed, K.health
    if uuid and tdm.essences then
        local t = tdm.essences.traits(uuid, kind)
        speed = speed * (t.speed or 1)
        health = math.tointeger(health * (t.health or 1)) or health
    end
    return game.spawn_entity{ pos = pos, model = U.id(K.model.id), health = health, speed = speed,
        nametag = K.name, collider = K.collider }
end


local function body_of(uuid, kind)
    return bodies[uuid] and bodies[uuid][kind] or nil
end

--- Puts a player's familiar of `kind` beside them, if it walks and is not here.
local function come(uuid, kind)
    if body_of(uuid, kind) or record(uuid, kind) ~= true then return end
    local pos = where(uuid)
    if not pos then return end
    local id = spawn(kind, { x = pos.x + 1, y = pos.y, z = pos.z + 1 }, uuid)
    if not id then return end
    bodies[uuid] = bodies[uuid] or {}
    bodies[uuid][kind] = id
    owner_of[id] = { uuid = uuid, kind = kind }
end

--- Lets a player's familiar's body be made again, with what it is now:
--- after it is given a trait.
function F.renew(uuid, kind)
    local id = bodies[uuid] and bodies[uuid][kind]
    if not id then return end
    game.despawn_entity(id)
    bodies[uuid][kind], owner_of[id] = nil, nil
    come(uuid, kind)
end

local function go(uuid, kind)
    local id = body_of(uuid, kind)
    if not id then return end
    game.despawn_entity(id)
    bodies[uuid][kind] = nil
    owner_of[id] = nil
end

--- Makes `kind` walk with a player, resting others beyond their number.
function F.walk(uuid, kind)
    set_record(uuid, kind, true)
    local walking = { kind }
    for _, other in ipairs(F.ORDER) do
        if other ~= kind and record(uuid, other) == true then walking[#walking + 1] = other end
    end
    for i = F.cap(uuid) + 1, #walking do
        set_record(uuid, walking[i], "resting")
        go(uuid, walking[i])
    end
    come(uuid, kind)
end

--- Every familiar a player has bound, walking or resting, as `{ { kind, entity } }`
--- (entity nil for one not here).
function F.list(uuid)
    local out = {}
    for _, kind in ipairs(F.ORDER) do
        local r = record(uuid, kind)
        if r == true or r == "resting" then out[#out + 1] = { kind = kind, entity = body_of(uuid, kind) } end
    end
    return out
end

local function has_node(uuid, kind)
    return progress ~= nil and progress.has(uuid, F.KINDS[kind].node) == true
end

local function looked_for(uuid, kind)
    for _, w in pairs(wild) do
        if w.adept == uuid and w.kind == kind then return true end
    end
    return false
end

local function appear(kind, adept, pos, extra)
    local id = spawn(kind, pos)
    if not id then return nil end
    wild[id] = { kind = kind, adept = adept, container = extra }
    game.chat_to(adept, F.KINDS[kind].appears)
    game.emit_particles{ pos = pos, count = 24, colour = { r = 0.8, g = 0.9, b = 1.0 }, size = 0.15,
        velocity = { y = 1 }, spread = 1, lifetime = 1, collide = false }
    return id
end

-- Finding: the salamander, in a long-burning athanor --------------------------------------------

local S = C.salamander
local LIT = U.material(U.id(C.athanor.lit.id))
local STATION = U.id(C.athanor.station)
local PREFIX = "tiamat_default_craft:" .. STATION .. ":"

local function adept_near(pos)
    if not progress then return nil end
    local best, best_d = nil, nil
    for _, id in ipairs(game.entities_in_radius(pos, S.reach)) do
        local e = game.entity(id)
        local uuid = e and e.owner
        if uuid and has_node(uuid, "salamander") and record(uuid, "salamander") == nil
            and not looked_for(uuid, "salamander") then
            local dx, dy, dz = e.pos.x - pos.x, e.pos.y - pos.y, e.pos.z - pos.z
            local d = dx * dx + dy * dy + dz * dz
            if not best_d or d < best_d then best, best_d = uuid, d end
        end
    end
    return best
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
                if adept and appear("salamander", adept, above, name) then
                    game.storage.set("called:" .. name, true)
                end
            end
        elseif game.storage.get(burned_key) ~= nil then
            -- Gone out: the day starts again, and it may call another.
            game.storage.set(burned_key, nil)
            game.storage.set("called:" .. name, nil)
        end
    end
end)

-- Finding: the others, round the adepts who know them ------------------------------------------

local function night()
    local t = game.time_of_day and game.time_of_day() or 0.5
    local n = C.undine.night
    return t >= n.from or t < n.to
end

--- Still water near `pos`: a column's top that is a whole block of fluid.
local function still_water(pos)
    local r = C.undine.look
    local x0, z0, y0 = math.floor(pos.x), math.floor(pos.z), math.floor(pos.y)
    for _, d in ipairs({ { 0, 0 }, { r, 0 }, { -r, 0 }, { 0, r }, { 0, -r } }) do
        local top = game.surface_at{ x = x0 + d[1], z = z0 + d[2], from = y0 + 8, depth = 24 }
        if top and top.fluid and top.volume == 27 then
            return { x = x0 + d[1] + 0.5, y = top.y + 1, z = z0 + d[2] + 0.5 }
        end
    end
    return nil
end

local FIND = {}

function FIND.undine(uuid, pos)
    if not night() then return nil end
    return still_water(pos)
end

function FIND.gnome(uuid, pos)
    if not (world and world.depth_band) then return nil end
    local band = world.depth_band(math.floor(pos.x), math.floor(pos.y), math.floor(pos.z))
    if band and C.gnome.bands[band] then return { x = pos.x + 2, y = pos.y, z = pos.z } end
    return nil
end

function FIND.sylph(uuid, pos)
    local x, y, z = math.floor(pos.x), math.floor(pos.y), math.floor(pos.z)
    local biome = world and world.biome_under and world.biome_under(x, y, z)
    local kind = weather and weather.weather_at and weather.weather_at(x, y, z)
    if (biome and C.sylph.biomes[biome]) or (kind and C.sylph.weathers[kind]) then
        return { x = pos.x + 2, y = pos.y + 1, z = pos.z }
    end
    return nil
end

local queue, since = {}, 0
tdm.on_tick(function(dt)
    since = since + (math.tointeger(dt) or 1)
    if #queue == 0 then
        if since < C.find_every then return end
        since = 0
        for _, uuid in ipairs(U.sorted_keys(tdm.online)) do queue[#queue + 1] = uuid end
    end
    local uuid = table.remove(queue, 1)
    if not (uuid and tdm.online[uuid]) then return end
    local pos = where(uuid)
    if not pos then return end
    for kind, find in pairs(FIND) do
        if has_node(uuid, kind) and record(uuid, kind) == nil and not looked_for(uuid, kind) then
            local at = find(uuid, pos)
            if at then appear(kind, uuid, at) end
        end
    end
end)

-- Binding, and using one ------------------------------------------------------------------------

local function water_key(uuid) return "undine_water:" .. uuid end

tdm.on_use_entity(function(e)
    local w = wild[e.target]
    if w then
        local K = F.KINDS[w.kind]
        local held = e.held
        if not (held and FOOD[w.kind][held.material] and held.shape == nil and held.detail == nil) then
            return K.hungry or "It flickers, hungry. It wants sulfur."
        end
        if not has_node(e.player, w.kind) then
            return "It will not come to you. You do not know the " .. K.name .. "."
        end
        if record(e.player, w.kind) ~= nil then return "You have a " .. string.lower(K.name) .. " already." end
        if game.take(e.player, { material = held.material, units = K.food_units }) < K.food_units then
            return "It wants more than that."
        end
        wild[e.target] = nil
        bodies[e.player] = bodies[e.player] or {}
        bodies[e.player][w.kind] = e.target
        owner_of[e.target] = { uuid = e.player, kind = w.kind }
        F.walk(e.player, w.kind)
        if w.kind == "salamander" and progress and progress.has(e.player, S.forge) then
            game.give(e.player, { material = EMBER, count = 1 })
        end
        game.chat_to(e.player, K.bound)
        if progress then progress.discover(e.player, game.mod_id .. ".familiar_" .. w.kind) end
        return ""
    end
    local mine = owner_of[e.target]
    -- Your own gnome, empty-handed, tunnels; your own sylph lends you wings.
    if mine and mine.uuid == e.player and e.held == nil then
        if mine.kind == "gnome" and gifted(e.player, "gnome_delving") then return F.delve(e.player) end
        if mine.kind == "sylph" and gifted(e.player, "sylph_flight") then
            if not tdm.quintessence.spend(e.player, GIFTS.sylph_flight.cost) then return C.caduceus.dry end
            tdm.effects.start(e.player, "flight", GIFTS.sylph_flight.ticks)
            local scouted = F.scout(e.player)
            return "The sylph lifts you." .. (scouted and (" Far ahead: " .. scouted .. ".") or "")
        end
        if mine.kind == "homunculus" then return F.satchel(e.player) end
    end
    -- An essence given to your own familiar is one of its traits.
    if mine and mine.uuid == e.player and e.held and tdm.essences and tdm.essences.is_essence(e.held) then
        return tdm.essences.give(e.player, mine.kind, e.held)
    end
    -- Your own undine gives you a bucket of the water it carries.
    if mine and mine.uuid == e.player and mine.kind == "undine" and e.held and e.held.material == BUCKET then
        local carried = game.storage.get(water_key(e.player)) or 0
        if carried <= 0 then return "It has no water to give." end
        if game.take(e.player, { material = BUCKET, count = 1 }) < U.UNITS then return "" end
        game.give(e.player, { material = WATER_BUCKET, count = 1 })
        game.storage.set(water_key(e.player), carried - 1)
        return ""
    end
    return nil
end)

-- Following, and each one's work --------------------------------------------------------------

local ORES = {}
for _, id in ipairs(C.ores) do
    local m = U.material(U.id(id))
    if m then ORES[m] = true end
end
local layer = {}            -- uuid -> the layer of the gnome's cube read next

local WORK = {}

function WORK.undine(uuid, id, me)
    -- The Undine's Gift: its master breathes water while it walks with them.
    if gifted(uuid, "undine_tides") and life and life.add_effect then
        life.add_effect(uuid, GIFTS.undine_tides.effect, GIFTS.undine_tides.ticks)
    end
    -- It fills itself, a whole block at a time, from the water it stands in:
    -- the water is taken from the world, so none is made.
    local carried = game.storage.get(water_key(uuid)) or 0
    local at = { x = math.floor(me.pos.x), y = math.floor(me.pos.y), z = math.floor(me.pos.z) }
    if carried < C.undine.carry then
        if WATER_ID == nil and game.fluid_id then WATER_ID = game.fluid_id(WATER) or false end
        local fluid = game.get_fluid(at)
        if fluid and fluid.volume == 27 and WATER_ID and fluid.fluid == WATER_ID
            and game.set_fluid(at, { fluid = WATER, volume = 0 }) then
            game.storage.set(water_key(uuid), carried + 1)
        end
    end
    if weather and weather.fires_near and weather.extinguish then
        for i, fire in ipairs(weather.fires_near(at.x, at.y, at.z, C.undine.douse) or {}) do
            if i > 4 then break end
            weather.extinguish(fire.x, fire.y, fire.z)
        end
    end
end

function WORK.gnome(uuid, id, me)
    local pos = where(uuid)
    if not pos then return end
    local r = C.gnome.sense + (tdm.essences and tdm.essences.traits(uuid, "gnome").sense or 0)
    local l = layer[uuid] or -r
    layer[uuid] = l >= r and -r or l + 1
    local cx, cy, cz = math.floor(pos.x), math.floor(pos.y) + l, math.floor(pos.z)
    for dx = -r, r do
        for dz = -r, r do
            local b = game.get_block{ x = cx + dx, y = cy, z = cz + dz }
            if b and ORES[b.material] then
                game.emit_particles{ pos = { x = cx + dx + 0.5, y = cy + 0.5, z = cz + dz + 0.5 }, count = 3,
                    colour = { r = 1.0, g = 0.75, b = 0.3 }, size = 0.12, lifetime = 2, spread = 0.2,
                    collide = false, player = uuid }
            end
        end
    end
end

-- The Gnome's Delving: a tunnel two high, up to `reach` ahead, through the
-- world's own ground only; each block dug is its master's.
local DIGS = {}
for _, id in ipairs(C.gifts.gnome_delving.digs) do
    local m = U.material(U.id(id))
    if m then DIGS[m] = true end
end

function F.delve(uuid)
    local body = game.player_entity(uuid)
    local me = body and game.entity(body)
    if not me then return "" end
    local G = GIFTS.gnome_delving
    -- The way the player faces, to the nearest of the four: a choice of
    -- direction, not a quantity the world keeps.
    local dx, dz = 0, 0
    if math.abs(me.facing.x) >= math.abs(me.facing.z) then dx = me.facing.x >= 0 and 1 or -1
    else dz = me.facing.z >= 0 and 1 or -1 end
    local x, y, z = math.floor(me.pos.x), math.floor(me.pos.y), math.floor(me.pos.z)
    local dug = 0
    for step = 1, G.reach do
        local bx, bz = x + dx * step, z + dz * step
        for h = 0, G.height - 1 do
            local at = { x = bx, y = y + h, z = bz }
            local b = game.get_block(at)
            if b and b.occupancy ~= 0 then
                local fluid = game.get_fluid(at)
                if not DIGS[b.material] or b.occupancy ~= game.OCCUPANCY_FULL or (fluid and fluid.volume > 0)
                    or (tdm.seal and tdm.seal.warding(at.x, at.y, at.z, uuid)) then
                    return dug > 0 and string.format("The gnome digs %d blocks, and stops.", dug) or "The gnome will not dig that."
                end
                game.set_block(at, "engine:air")
                game.give(uuid, { material = b.material, units = U.UNITS })
                dug = dug + 1
            end
        end
    end
    return string.format("The gnome digs %d blocks.", dug)
end

local thought = 0
tdm.on_tick(function(dt)
    thought = thought + (math.tointeger(dt) or 1)
    if thought < C.familiars.think_every then return end
    thought = 0
    for uuid, kinds in pairs(bodies) do
        local master = where(uuid)
        for kind, id in pairs(kinds) do
            local me = game.entity(id)
            if not me then
                kinds[kind], owner_of[id] = nil, nil     -- killed, or gone: it comes back on the next join
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
                if WORK[kind] then WORK[kind](uuid, id, me) end
            end
        end
    end
end)

-- The sylph's soft landing, on the one tick its master lands.
tdm.on_tick(function()
    if not (life and life.heal) then return end
    for uuid, kinds in pairs(bodies) do
        if kinds.sylph then
            local _, e = where(uuid)
            local fell = e and e.fell or 0
            if fell > C.sylph.safe then
                life.heal(uuid, math.min(1000, math.floor((fell - C.sylph.safe) * C.sylph.mercy + 0.5)))
            end
        end
    end
end)

-- The made ones: a homunculus from its vial, a basilisk from its egg ----------------------------

local MADE = {}             -- numeric material of a vial or egg -> kind
for _, kind in ipairs({ "homunculus", "basilisk" }) do
    local K = F.KINDS[kind]
    local m = U.material(U.id(K.vial or K.egg))
    if m then MADE[m] = kind end
end

tdm.on_use(function(e)
    local kind = e.held and MADE[e.held.material]
    if not kind then return nil end
    local K = F.KINDS[kind]
    if not has_node(e.player, kind) then return "You do not know how to wake it." end
    if record(e.player, kind) ~= nil then return "You have a " .. string.lower(K.name) .. " already." end
    if game.take(e.player, { material = e.held.material, count = 1 }) < U.UNITS then return "" end
    F.walk(e.player, kind)
    if progress then progress.discover(e.player, game.mod_id .. ".familiar_" .. kind) end
    game.chat_to(e.player, "The " .. string.lower(K.name) .. " stirs, and is yours.")
    return ""
end)

-- The homunculus: a satchel, and athanors kept in fuel from a chest.
local H = C.homunculus
local FUELS = {}
for _, id in ipairs(H.fuels) do
    local m = U.material(U.id(id))
    if m then FUELS[#FUELS + 1] = { id = U.id(id), material = m } end
end
local CHESTS = "tiamat_default_craft:chest:"
local ATHANORS = "tiamat_default_craft:" .. U.id(C.athanor.station) .. ":"

function F.satchel(uuid)
    local name = game.mod_id .. ":satchel:" .. uuid
    game.make_container(name, H.satchel)
    if not game.open_container(name, uuid) then return "Somebody is in the satchel." end
    return ""
end

local function near(name, station, pos)
    local at = U.station_pos(name, station)
    if not at then return nil end
    local dx, dy, dz = at.x + 0.5 - pos.x, at.y + 0.5 - pos.y, at.z + 0.5 - pos.z
    return dx * dx + dy * dy + dz * dz <= H.reach * H.reach
end

local tended = {}           -- uuid -> ticks since its last block of fuel
function WORK.homunculus(uuid, id, me)
    tended[uuid] = (tended[uuid] or 0) + C.familiars.think_every
    if tended[uuid] < H.every then return end
    tended[uuid] = 0
    local chests = {}
    for _, name in ipairs(game.containers(CHESTS)) do
        if near(name, "chest", me.pos) then chests[#chests + 1] = name end
    end
    if #chests == 0 then return end
    for _, name in ipairs(game.containers(ATHANORS)) do
        if near(name, U.id(C.athanor.station), me.pos) then
            local held = 0
            for _, stack in ipairs(game.container(name)) do
                if stack.slot == C.athanor.slots.fuel then held = stack.units end
            end
            if held < H.keep then
                for _, chest in ipairs(chests) do
                    for _, fuel in ipairs(FUELS) do
                        local got = game.container_take(chest, { material = fuel.id, units = U.UNITS })
                        if got > 0 then
                            local put = game.container_give(name, { material = fuel.id, units = got, slot = C.athanor.slots.fuel })
                            if put < got then game.container_give(chest, { material = fuel.id, units = got - put }) end
                            return                     -- a block a turn
                        end
                    end
                end
            end
        end
    end
end

-- The basilisk: a guard whose stare freezes hostile creatures, and an ash.
local B = C.basilisk
local HOSTILE = {}
for _, kind in ipairs(C.hostile) do HOSTILE["tiamat_default_life:" .. kind] = true end
local stared = {}
function WORK.basilisk(uuid, id, me)
    stared[uuid] = (stared[uuid] or 0) + C.familiars.think_every
    if stared[uuid] >= B.every and life and life.freeze then
        stared[uuid] = 0
        local eye = { x = me.pos.x, y = me.pos.y + 1, z = me.pos.z }
        for _, other in ipairs(game.entities_in_radius(me.pos, B.stare, "tiamat_default_life")) do
            local e = game.entity(other)
            if e and e.model and HOSTILE[e.model] then
                local sees = not game.line_of_sight or game.line_of_sight(eye, { x = e.pos.x, y = e.pos.y + 1, z = e.pos.z }) ~= false
                if sees then life.freeze(other, B.freeze) end
            end
        end
    end
    local key = "basilisk_ash:" .. uuid
    local next_ash = game.storage.get(key)
    if type(next_ash) ~= "number" then
        game.storage.set(key, tdm.effects.now() + B.ash_every)
    elseif tdm.effects.now() >= next_ash then
        game.give(uuid, { material = U.id(B.ash), count = 1 })
        game.storage.set(key, tdm.effects.now() + B.ash_every)
    end
end

-- The Greater Elementals: each one's third gift.
local GR = C.greater
local function greater(uuid) return progress ~= nil and progress.has(uuid, GR.node) == true end
local spent = {}            -- uuid -> ticks since the last greater gift
local plain_salamander, plain_undine = WORK.salamander, WORK.undine

function WORK.salamander(uuid, id, me)
    if plain_salamander then plain_salamander(uuid, id, me) end
    if not (greater(uuid) and life and life.set_alight) then return end
    spent[uuid] = (spent[uuid] or 0) + C.familiars.think_every
    if spent[uuid] < GR.every then return end
    spent[uuid] = 0
    for _, other in ipairs(game.entities_in_radius(me.pos, B.stare, "tiamat_default_life")) do
        local e = game.entity(other)
        if e and e.model and HOSTILE[e.model] then life.set_alight(other, GR.alight) end
    end
end

function WORK.undine(uuid, id, me)
    plain_undine(uuid, id, me)
    if not (greater(uuid) and life and life.heal) then return end
    spent[uuid] = (spent[uuid] or 0) + C.familiars.think_every
    if spent[uuid] < GR.every then return end
    spent[uuid] = 0
    life.heal(uuid, GR.heal)
end

--- The sylph scouts, for a master who knows the Greater Elementals: the
--- biome `scout` blocks ahead, or nil.
function F.scout(uuid)
    if not (greater(uuid) and world and world.biome_under) then return nil end
    local _, me = where(uuid)
    if not me then return nil end
    -- The way the player faces, as far as the scout flies: a place to name.
    local x = math.floor(me.pos.x + me.facing.x * GR.scout)
    local z = math.floor(me.pos.z + me.facing.z * GR.scout)
    local biome = world.biome_under(x, math.floor(me.pos.y), z)
    return biome and (string.gsub(biome, "_", " ")) or nil
end

-- Coming and going -------------------------------------------------------------------------------

--- Clears familiars near `pos` that nobody is keeping: a crash's leftovers.
local function clear_orphans(pos)
    for _, id in ipairs(game.entities_in_radius(pos, C.familiars.orphans, game.mod_id)) do
        local e = game.entity(id)
        if e and e.model and MODELS[e.model] and not wild[id] and not owner_of[id]
            and not (tdm.worlds and tdm.worlds.spirit[id]) then game.despawn_entity(id) end
    end
end

tdm.on_join(function(event)
    local pos = where(event.player)
    if pos then clear_orphans(pos) end
    for _, kind in ipairs(F.ORDER) do come(event.player, kind) end
end)

tdm.on_leave(function(event)
    for _, kind in ipairs(F.ORDER) do go(event.player, kind) end
    bodies[event.player] = nil
    layer[event.player] = nil
end)

-- The Salamander's Forge: the ember is the Forge's gift, given when it is
-- learned with a salamander bound, or at the binding if it is known.
if progress then
    progress.on_unlock(function(uuid, node)
        local r = node == S.forge and record(uuid, "salamander")
        if r == true or r == "resting" then game.give(uuid, { material = EMBER, count = 1 }) end
    end)
end

-- The path: repathing away sends every familiar to sleep, and back wakes them.
if progress then
    progress.on_repath(function(uuid, old, new)
        for _, kind in ipairs(F.ORDER) do
            local r = record(uuid, kind)
            if old == C.path.id and (r == true or r == "resting") then
                go(uuid, kind)
                set_record(uuid, kind, "dormant")
            elseif new == C.path.id and r == "dormant" then
                set_record(uuid, kind, "resting")
            end
        end
    end)
end

--- Calls the next bound familiar after the first that walks, in the order
--- of the four, to walk; answers what to tell the player.
function F.next(uuid)
    local bound, walking = {}, nil
    for _, kind in ipairs(F.ORDER) do
        local r = record(uuid, kind)
        if r == true or r == "resting" then
            bound[#bound + 1] = kind
            if r == true and not walking then walking = #bound end
        end
    end
    if #bound == 0 then return "You have no familiar." end
    local kind = bound[(walking or 0) % #bound + 1]
    F.walk(uuid, kind)
    return "Your " .. kind .. " walks with you."
end

game.register_action{ id = "familiar", default_key = C.familiar_key, description = "Call your next familiar" }

tdm.on_action(game.mod_id .. ":familiar", function(e)
    if e.pressed then game.chat_to(e.player, F.next(e.player)) end
end)

--- `magic familiar [kind]`: which walk and rest, or call one to walk.
function F.command(uuid, rest)
    local kind = string.lower(rest or "")
    if kind == "" then
        local parts = {}
        for _, f in ipairs(F.list(uuid)) do
            parts[#parts + 1] = f.kind .. (record(uuid, f.kind) == true and " (walking)" or " (resting)")
        end
        if #parts == 0 then return "You have no familiar." end
        return "Your familiars: " .. table.concat(parts, ", ") .. "."
    end
    local r = F.KINDS[kind] and record(uuid, kind)
    if r ~= true and r ~= "resting" then return "You have no " .. kind .. "." end
    F.walk(uuid, kind)
    return "Your " .. kind .. " walks with you."
end

return F
