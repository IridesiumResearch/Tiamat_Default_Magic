-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Quintessence (brief §6.8): the one bar.
--
-- A Life stat, drawn in Life's status tray and saved with the vitals; its
-- ceiling is set per player through Life's `set_stat_max` (Life's answer to
-- L-M1), and a ceiling of 0 is not drawn — so only a player on the magic
-- path sees it: `base` (10) from the Oath, and `magic.quintessence_max`
-- more as the Fifth Essence and the Stone of the Mind are learned.
--
-- It fills slowly on its own — `regen` a point every `every` ticks, times
-- (1 + `magic.quintessence_regen_percent`), doubled while the Elixir of
-- Life flows — and at once from a drink of quintessence or aurum potabile.
-- It is small on purpose: the Art is in substances, and the bar is the
-- handful of things a substance cannot do by itself.

local C = tdm.config
local U = tdm.util
local E = tdm.effects

local Q = {}

local K = C.quintessence
Q.ID = U.id(K.id)
local life = U.exports("tiamat_default_life")
local progress = U.exports("tiamat_default_progress")

local ok = life and life.add_stat and life.set_stat_max
    and life.add_stat(Q.ID, { max = K.ceiling, regen = 0, name = K.name, colour = K.colour, start = 0 })
Q.available = ok and true or false
if life and not ok then game.log("tiamat_default_magic: Life did not take the Quintessence bar") end

--- A player's ceiling: 0 off the path, so the bar is not drawn for them.
function Q.ceiling(uuid)
    if not (progress and progress.path(uuid) == C.path.id) then return 0 end
    return K.base + (progress.effects_of(uuid, "magic.")["magic.quintessence_max"] or 0)
end

--- Sets a player's ceiling from what they know now.
function Q.refresh(uuid)
    if Q.available then life.set_stat_max(uuid, Q.ID, Q.ceiling(uuid)) end
end

function Q.amount(uuid)
    if not Q.available then return 0 end
    return life.stat(uuid, Q.ID) or 0
end

--- Takes `n` if there is that much: true, or false and nothing taken.
function Q.spend(uuid, n)
    if not Q.available then return false end
    return life.spend_stat(uuid, Q.ID, n) == true
end

function Q.add(uuid, n)
    if not Q.available then return end
    life.set_stat(uuid, Q.ID, math.min(Q.amount(uuid) + n, Q.ceiling(uuid)))
end

-- The ceiling follows the path and the tree.
tdm.on_join(function(event) Q.refresh(event.player) end)
if progress then
    progress.on_unlock(function(uuid) Q.refresh(uuid) end)
    progress.on_fork(function(uuid) Q.refresh(uuid) end)
    progress.on_repath(function(uuid, old)
        Q.refresh(uuid)
        if old == C.path.id and Q.available then life.set_stat(uuid, Q.ID, 0) end
    end)
end

-- Drinks that fill it, and the Elixir of Life's flow.
local refills = {}
for id, n in pairs(K.refills) do refills[U.id(id)] = n end
local FLOW, FLOW_TICKS = K.flow[1], K.flow[2]
local VITAE = U.id("elixir_vitae")

if life and life.on_eat then
    life.on_eat(function(uuid, material)
        if refills[material] then Q.add(uuid, refills[material]) end
        if material == VITAE then E.start(uuid, FLOW, FLOW_TICKS) end
    end)
end

-- Filling on its own, every `every` ticks, for the players who are here.
local since = 0
tdm.on_tick(function(dt)
    since = since + (math.tointeger(dt) or 1)
    if since < K.every or not Q.available then return end
    since = 0
    for uuid in pairs(tdm.online) do
        local ceiling = Q.ceiling(uuid)
        if ceiling > 0 and Q.amount(uuid) < ceiling then
            local percent = 100 + (progress.effects_of(uuid, "magic.")["magic.quintessence_regen_percent"] or 0)
            if E.left(uuid, FLOW) > 0 then percent = percent * 2 end
            Q.add(uuid, math.max(1, K.regen * percent // 100))
        end
    end
end)

return Q
