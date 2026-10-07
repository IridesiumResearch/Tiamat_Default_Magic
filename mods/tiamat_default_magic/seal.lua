-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The Hermetic Seal (brief §7.3): a ward. It defends; it never attacks.
--
-- A seal glyph set by a player who knows the Hermetic Seal wards the blocks
-- within its radius — 6, or 12 with the Greater Seal, and twice that carved
-- from black marble. There, nobody but its setter, the players they allow
-- (`magic seal allow <name>`), and an operator may dig or build. A dig is
-- refused as it begins, so nobody waits out a dig that will not happen.
--
-- A seal cannot be used to shut somebody out of their own ground: one is
-- refused where its ward would overlap another player's ward. A seal set by
-- somebody who has since left the path wards nothing.
--
-- The seals are keys (`seal:x,y,z`, holding the setter and the radius),
-- read once into a list, and every dig and build is checked against the
-- list — a few seals a player, not a world scan. A seal wards the domain it
-- was set in (the place and dig events name it); off the overworld its key
-- is `seal:<domain>@x,y,z`.

local C = tdm.config
local U = tdm.util
local G = tdm.glyphs

local W = {}

local S = C.seal
local progress = U.exports("tiamat_default_progress")
local SEAL = G.by_id.seal
local MARBLE = U.material(U.id(S.marble))

local seals = nil           -- key -> { x, y, z, by, radius }

local function key(x, y, z, domain) return U.place_key("seal", x, y, z, domain) end

local function all()
    if seals then return seals end
    seals = {}
    for _, k in ipairs(game.storage.keys("seal:")) do
        local rest = string.sub(k, 6)
        local domain, where = string.match(rest, "^(.*)@([^@]+)$")
        local x, y, z = string.match(where or rest, "^(%-?%d+),(%-?%d+),(%-?%d+)$")
        local by, radius = string.match(tostring(game.storage.get(k)), "^(%x+);(%d+)$")
        if x and by then
            seals[k] = { x = math.tointeger(tonumber(x)), y = math.tointeger(tonumber(y)),
                z = math.tointeger(tonumber(z)), by = by, radius = math.tointeger(tonumber(radius)),
                domain = domain or "overworld" }
        end
    end
    return seals
end

local function allow_key(owner, uuid) return "sealallow:" .. owner .. ":" .. uuid end

--- Whether `uuid` may touch ground a seal of `owner` wards.
local function allowed(owner, uuid)
    if uuid == owner then return true end
    if game.is_operator and game.is_operator(uuid) then return true end
    return game.storage.get(allow_key(owner, uuid)) == true
end

--- Whether a seal still wards: its setter is on the path and knows the Seal.
local function active(seal)
    return progress ~= nil and progress.has(seal.by, S.node) == true
end

--- Whether a seal forbids `uuid` the block at `x, y, z` in `domain` (the
--- overworld when nil): the seal, or nil.
function W.warding(x, y, z, uuid, domain)
    domain = domain or "overworld"
    for _, seal in pairs(all()) do
        local r = seal.radius
        if seal.domain == domain and math.abs(x - seal.x) <= r and math.abs(y - seal.y) <= r and math.abs(z - seal.z) <= r
            and not allowed(seal.by, uuid) and active(seal) then
            return seal
        end
    end
    return nil
end

--- The radius a seal set now by `uuid`, carved from `material`, would ward.
local function radius_for(uuid, material)
    local r = S.radius
    if progress and progress.has(uuid, S.greater) then r = S.greater_radius end
    if material == MARBLE then r = r * S.marble_times end
    return r
end

-- Setting one, and building or digging under one ------------------------------------------

tdm.on_place(function(e)
    if W.warding(e.x, e.y, e.z, e.player, e.domain) then return S.refused end
    if G.of(e.occupancy) ~= SEAL or not (progress and progress.has(e.player, S.node)) then return nil end
    local r = radius_for(e.player, e.material)
    for _, seal in pairs(all()) do
        local reach = r + seal.radius
        if seal.by ~= e.player and seal.domain == (e.domain or "overworld") and math.abs(e.x - seal.x) <= reach and math.abs(e.y - seal.y) <= reach
            and math.abs(e.z - seal.z) <= reach then
            return S.overlaps
        end
    end
    local k = key(e.x, e.y, e.z, e.domain)
    all()[k] = { x = e.x, y = e.y, z = e.z, by = e.player, radius = r, domain = e.domain or "overworld" }
    game.storage.set(k, string.format("%s;%d", e.player, r))
    return nil
end)

local function refuse_dig(e)
    local x, y, z = e.x // 3, e.y // 3, e.z // 3
    if W.warding(x, y, z, e.player, e.domain) then return S.refused end
    return nil
end

tdm.on_dig_start(refuse_dig)

tdm.on_dig(function(e)
    local refused = refuse_dig(e)
    if refused then return refused end
    local k = key(e.x // 3, e.y // 3, e.z // 3, e.domain)
    if all()[k] then
        seals[k] = nil
        game.storage.set(k, nil)
    end
    return nil
end, true)

-- `magic seal allow <name>` / `magic seal deny <name>`, of a player who is here.

--- Handles `seal ...` from the `magic` word; answers what to say.
function W.command(uuid, rest)
    local verb, name = string.match(rest, "^(%a+)%s+(.+)$")
    if verb ~= "allow" and verb ~= "deny" then return "magic seal allow <name>, or magic seal deny <name>" end
    for other, joined in pairs(tdm.online) do
        if joined == name then
            game.storage.set(allow_key(uuid, other), verb == "allow" or nil)
            return verb == "allow" and (name .. " may build within your seals.") or (name .. " may not.")
        end
    end
    return "Nobody here is called " .. name .. "."
end

return W
