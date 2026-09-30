-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The effects Life does not have (brief §6.7), each a timer.
--
-- Storage holds scalars, so an effect is one key: `fx:<uuid>:<id>` is the
-- clock tick it ends on. The clock is this mod's own, counted every tick and
-- written now and then, because the engine hands a mod no tick count and a
-- timer has to survive a restart. Only players who are here are ticked: a
-- player's timers are read when they join and dropped when they leave, and
-- keep running out while they are away, since the clock does.
--
-- Each effect is a look, repeated every `every` ticks while it lasts, to
-- that player alone. Night-sight is the one tier 3 needs: until Weather
-- blends a sky overlay (sibling ask Wx-M1) it brightens nothing, so it is a
-- faint glow of motes round the drinker, and Life's own rested sleep.

local C = tdm.config

local E = {}

local live = {}             -- uuid -> { effect id -> the tick it ends }

-- The clock -------------------------------------------------------------------------

local clock = nil
local unsaved = 0
local SAVE_EVERY = 200

--- Ticks the world has run, as this mod counts them.
function E.now()
    if clock == nil then
        local stored = game.storage.get("clock")
        clock = type(stored) == "number" and math.tointeger(stored) or 0
    end
    return clock
end

local function advance(dt)
    local step = math.tointeger(dt) or 1
    clock = E.now() + step
    unsaved = unsaved + step
    if unsaved >= SAVE_EVERY then
        unsaved = 0
        game.storage.set("clock", clock)
    end
end

-- Timers ------------------------------------------------------------------------------

local function key(uuid, id)
    return "fx:" .. uuid .. ":" .. id
end

local function load(uuid)
    local timers = {}
    local prefix = "fx:" .. uuid .. ":"
    for _, k in ipairs(game.storage.keys(prefix)) do
        local ends = game.storage.get(k)
        if type(ends) == "number" then timers[string.sub(k, #prefix + 1)] = math.tointeger(ends) end
    end
    live[uuid] = timers
    return timers
end

--- Starts (or lengthens to) `ticks` of effect `id` on a player, scaled by
--- their `magic.elixir_duration_percent`.
function E.start(uuid, id, ticks)
    if not C.own_effects[id] then return false end
    local progress = tdm.util.exports("tiamat_default_progress")
    local bonus = progress and progress.effects_of(uuid, "magic.")["magic.elixir_duration_percent"] or 0
    ticks = ticks * (100 + bonus) // 100
    local timers = live[uuid] or load(uuid)
    local ends = E.now() + ticks
    if (timers[id] or 0) < ends then
        timers[id] = ends
        game.storage.set(key(uuid, id), ends)
    end
    return true
end

--- Ticks of effect `id` a player has left, 0 when none.
function E.left(uuid, id)
    local timers = live[uuid] or load(uuid)
    local ends = timers[id]
    if not ends then return 0 end
    return math.max(0, ends - E.now())
end

-- Looks ---------------------------------------------------------------------------------

local LOOKS = {}

function LOOKS.night_sight(uuid, spec)
    local body = game.player_entity(uuid)
    local e = body and game.entity(body)
    if not e then return end
    game.emit_particles{ pos = { x = e.pos.x, y = e.pos.y + 1.2, z = e.pos.z }, count = spec.particles,
        colour = spec.colour, size = 0.12, lifetime = 2, area = { x = 1.2, y = 0.8, z = 1.2 },
        spread = 0.1, collide = false, player = uuid }
end

tdm.on_tick(function(dt)
    advance(dt)
    local now = clock
    for uuid, timers in pairs(live) do
        for id, ends in pairs(timers) do
            if ends <= now then
                timers[id] = nil
                game.storage.set(key(uuid, id), nil)
            else
                local spec = C.own_effects[id]
                if spec and now % spec.every == 0 and LOOKS[id] then LOOKS[id](uuid, spec) end
            end
        end
    end
end)

tdm.on_join(function(event) load(event.player) end)
tdm.on_leave(function(event) live[event.player] = nil end)

return E
