-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Essences of the beasts (brief §6.9): what a creature is, distilled.
--
-- For a player who knows the Essences, every `every`th creature of a kind
-- they kill (Life's on_kill), with a phial on them, gives its essence: a
-- `beast_essence` whose detail names the kind (`k=<kind>`), so no recipe
-- will melt it down. No chance in it: a counter, so it can be tested. Each
-- kind's first essence is a discovery.
--
-- Given to one of their own familiars, an essence is one of its traits —
-- three, the oldest giving way — and the familiar's body is made again with
-- it: a horse's is speed, a mammoth's is health, a bat's is a gnome that
-- sees ore further off. The rest are kept, and named, for later gifts.

local C = tdm.config
local U = tdm.util

local X = {}

local K = C.essences
local life = U.exports("tiamat_default_life")
local progress = U.exports("tiamat_default_progress")

local ESSENCE = U.material(U.id("beast_essence"))
local PHIAL = U.material(U.id("phial"))
local FAMILY = game.mod_id .. ".essence"

if progress then
    progress.register_discovery{ id = FAMILY .. ":*", insight = K.insight, label = "The essence of a %s",
        group = "essences" }
end

local function carries(uuid, material)
    for _, view in ipairs({ "player:hotbar", "player:main" }) do
        for _, stack in ipairs(game.inventory(uuid, view) or {}) do
            if stack.material == material and stack.detail == nil and stack.shape == nil then return true end
        end
    end
    return false
end

if life and life.on_kill then
    life.on_kill(function(uuid, kind)
        if not (progress and progress.has(uuid, K.node)) or type(kind) ~= "string" then return end
        local key = "kills:" .. uuid .. ":" .. kind
        local n = (game.storage.get(key) or 0) + 1
        game.storage.set(key, n)
        if n % K.every ~= 0 or not carries(uuid, PHIAL) then return end
        if game.take(uuid, { material = PHIAL, count = 1 }) < U.UNITS then return end
        game.give(uuid, { material = ESSENCE, count = 1, detail = "k=" .. kind })
        progress.discover(uuid, FAMILY .. ":" .. kind)
    end)
end

--- Whether a held stack is an essence.
function X.is_essence(held)
    return held.material == ESSENCE and type(held.detail) == "string" and string.match(held.detail, "^k=[%w_]+$") ~= nil
end

local function traits_key(uuid, familiar) return "traits:" .. uuid .. ":" .. familiar end

--- The kinds whose essences a player's familiar has taken, oldest first.
function X.taken(uuid, familiar)
    local list = {}
    for kind in string.gmatch(tostring(game.storage.get(traits_key(uuid, familiar)) or ""), "[%w_]+") do
        list[#list + 1] = kind
    end
    return list
end

--- What a player's familiar's traits come to: `{ speed, health, sense }`.
function X.traits(uuid, familiar)
    local out = {}
    for _, kind in ipairs(X.taken(uuid, familiar)) do
        for k, v in pairs(K.traits[kind] or {}) do
            if k == "sense" then out[k] = (out[k] or 0) + v else out[k] = (out[k] or 1) * v end
        end
    end
    return out
end

--- Gives a held essence to a player's familiar of `familiar`; answers what to say.
function X.give(uuid, familiar, held)
    local kind = string.match(held.detail, "^k=([%w_]+)$")
    if game.take(uuid, { material = ESSENCE, count = 1, detail = held.detail }) < U.UNITS then return "" end
    local list = X.taken(uuid, familiar)
    list[#list + 1] = kind
    while #list > K.slots do table.remove(list, 1) end
    game.storage.set(traits_key(uuid, familiar), table.concat(list, ","))
    tdm.familiars.renew(uuid, familiar)
    return string.format("Your %s takes the %s's essence.", familiar, (string.gsub(kind, "_", " ")))
end

return X
