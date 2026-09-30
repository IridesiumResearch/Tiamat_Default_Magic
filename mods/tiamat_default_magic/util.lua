-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Small helpers with no opinion about the Art.

local U = {}

--- Units in one item of loose material: an item is a block's worth.
U.UNITS = 27

local PREFIXES = {
    W = "tiamat_default_world",
    L = "tiamat_default_life",
    C = "tiamat_default_craft",
}

--- A qualified id from `config.lua`'s short forms: `"mortar"` is this mod's,
--- `"W:sulfur"` the world's, `"L:bone"` Life's, `"C:glass"` Craft's. A name
--- already qualified with a mod id, or a `#group`, is left alone.
function U.id(name)
    if string.sub(name, 1, 1) == "#" then return name end
    local prefix, rest = string.match(name, "^(%u):(.+)$")
    if prefix then return PREFIXES[prefix] .. ":" .. rest end
    if string.find(name, ":", 1, true) then return name end
    return game.mod_id .. ":" .. name
end

--- Whether `name` is a qualified id, `"mod:thing"`.
function U.qualified(name)
    return type(name) == "string" and #name <= 128 and string.match(name, "^[%a_][%w_]*:[%w_]+$") ~= nil
end

--- A numeric material id for a qualified id, or nil when nothing registered
--- it. `game.get_block_id` errors on an unknown id, which is right for a
--- typo in this mod's own names and wrong for another mod's block that may
--- or may not be there.
function U.material(id)
    if not U.qualified(id) then return nil end
    local ok, material = pcall(game.get_block_id, id)
    if ok then return material end
    return nil
end

--- Another mod's exports at version 1, or nil when it is not loaded.
function U.exports(id)
    local ok, exports = pcall(game.exports, id)
    if ok and type(exports) == "table" and exports.version == 1 then return exports end
    return nil
end

--- The block a use or dig event's cell is in.
function U.block_of(e)
    return { x = e.x // 3, y = e.y // 3, z = e.z // 3, domain = e.domain }
end

--- Where a Craft station's container stands, from its name:
--- `tiamat_default_craft:<station>:x,y,z`, with `<domain>@` before the
--- position off the overworld. `station` is the station's id, which may
--- itself hold a colon (the athanor's does). Nil for any other name.
function U.station_pos(name, station)
    if type(name) ~= "string" then return nil end
    local prefix = "tiamat_default_craft:" .. station .. ":"
    if string.sub(name, 1, #prefix) ~= prefix then return nil end
    local rest = string.sub(name, #prefix + 1)
    local domain, where = string.match(rest, "^(.*)@([^@]+)$")
    local x, y, z = string.match(where or rest, "^(%-?%d+),(%-?%d+),(%-?%d+)$")
    if not x then return nil end
    return { x = math.tointeger(tonumber(x)), y = math.tointeger(tonumber(y)), z = math.tointeger(tonumber(z)),
        domain = domain or "overworld" }
end

--- The middle of a block's top face, in world blocks: where a flame is seen.
function U.above(pos)
    return { x = pos.x + 0.5, y = pos.y + 0.9, z = pos.z + 0.5, domain = pos.domain }
end

--- A plain copy of data another mod handed over. What crosses an export is
--- a read-only VIEW, which Lua code reads like a table but the engine's own
--- calls do not — `game.show_dialog` sees a view's colour as no numbers at
--- all — so a widget built by the interface is copied before it is shown.
function U.plain(value)
    if type(value) ~= "table" and type(value) ~= "userdata" then return value end
    local out = {}
    for k, v in pairs(value) do out[k] = U.plain(v) end
    return out
end

--- A sorted copy of a table's keys.
function U.sorted_keys(t)
    local keys = {}
    for key in pairs(t) do keys[#keys + 1] = key end
    table.sort(keys)
    return keys
end

return U
