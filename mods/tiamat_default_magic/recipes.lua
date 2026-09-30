-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Every recipe this mod gives Craft goes through here, from `config.lua`'s
-- short forms, and is indexed by the node that opens it for the Mute Book.
--
-- A recipe at the athanor may name a DEGREE of fire instead of a heat and
-- a vessel (brief §6.1): the pseudo-Geber scale every later text repeats.
-- The degree is a requirement, not machinery — a heat the athanor must
-- burn at and the bath that must stand in one of its two vessel slots:
--
--   1st  Maria's water bath      heat 1 and the `bain_marie`
--   2nd  the ash bath            heat 1 and the `ash_bath`
--   3rd  the sand bath           heat 2 (charcoal or coal) and the `sand_bath`
--   4th  naked fire              heat 4: bellows in a vessel slot
--
-- Time is in philosophical days where the texts count it (`days`), turned
-- into ticks here, and in ticks where they do not.

local C = tdm.config
local U = tdm.util

local R = {}

local craft = U.exports("tiamat_default_craft")

R.by_node = {}       -- node id -> its recipes, in registration order: the book's pages
R.by_id = {}         -- qualified recipe id -> its config entry

--- The station a config entry names, as Craft knows it: Craft's own are
--- bare words, the athanor is this mod's.
local function station_of(name)
    if name == "athanor" then return U.id(C.athanor.station) end
    return name
end

local function qualify_list(list)
    local out = {}
    for i, entry in ipairs(list or {}) do
        if entry.glyph then
            -- A carving, named by its glyph (Craft's answer to C-M1).
            out[i] = { glyph = U.id(entry.glyph), material = U.id(entry.material), count = entry.count or 1,
                wear = entry.wear }
        else
            out[i] = { U.id(entry[1]), count = entry.count, units = entry.units, wear = entry.wear }
        end
    end
    return out
end

--- Registers one recipe from its config entry. Answers whether Craft took it.
function R.register(r)
    if not craft then return false end
    local tools = qualify_list(r.tools)
    local heat = r.heat
    if r.degree then
        local degree = C.degrees[r.degree]
        heat = degree.heat
        if degree.bath then tools[#tools + 1] = { U.id(degree.bath), wear = 0 } end
    end
    local ticks = r.ticks
    if r.days then ticks = r.days * C.philosophical_day end
    local id = U.id(r.id)
    local ok, why = craft.register{
        id = id,
        name = r.name,
        station = station_of(r.station),
        inputs = qualify_list(r.inputs),
        outputs = qualify_list(r.outputs),
        tools = #tools > 0 and tools or nil,
        heat = heat,
        ticks = ticks,
        strikes = r.strikes,
        requires = r.node,
    }
    if not ok then
        game.log("tiamat_default_magic: Craft refused the recipe " .. r.id .. ": " .. tostring(why))
        return false
    end
    R.by_id[id] = r
    if r.node and not r.unlisted then
        R.by_node[r.node] = R.by_node[r.node] or {}
        table.insert(R.by_node[r.node], r)
    end
    return true
end

--- Registers a list of recipes.
function R.register_all(list)
    for _, r in ipairs(list) do R.register(r) end
end

--- Adds members to a Craft group (`#name`, no colon: Craft's rule).
function R.group(name, members)
    if not craft then return end
    local qualified = {}
    for _, m in ipairs(members) do
        local id = U.id(m)
        if U.material(id) then qualified[#qualified + 1] = id end   -- another mod's that is not here: left out
    end
    if #qualified == 0 then return end
    local ok, why = craft.register_group(name, qualified)
    if not ok then game.log("tiamat_default_magic: Craft refused the group " .. name .. ": " .. tostring(why)) end
end

return R
