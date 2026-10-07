-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Tier 6, the Red Work (brief §5.4).
--
-- The recipes are data (`config.lua`, `tier6_recipes`): Gate IX's Ferment;
-- the Rubedo, the traditional forty philosophical days in the Egg (one
-- hour, Craft's longest recipe to the tick); Gate X raising the Stone and
-- Gate XI multiplying it; the alkahest; the Panacea. This file adds what is
-- more than a recipe:
--
-- - the Red Stone projected on base metal makes gold, while the world
--   allows transmutation, and both Stones yield `magic.projection_percent`
--   more (Exaltation doubles them);
-- - the alkahest poured melts rock to prima materia, and coagula makes it
--   common stone again, unit for unit;
-- - the Panacea heals and cures everyone near its drinker (Life's heal and
--   cure, its answer to L-M2);
-- - the Phoenix: once in three sun-days, a death drops nothing (Life's
--   keep_inventory, its answer to L-M7);
-- - the Chymical Wedding: an athanor with Sol and Luna opposite and a
--   quintessence on top, which crowns whoever knows the Wedding.

local C = tdm.config
local U = tdm.util
local R = tdm.recipes
local Q = tdm.quintessence
local E = tdm.effects
local G = tdm.glyphs

local M = {}

local craft = U.exports("tiamat_default_craft")
local progress = U.exports("tiamat_default_progress")
local life = U.exports("tiamat_default_life")

R.register_all(C.tier6_recipes)
R.register_all(C.tier6_living_recipes)
if tdm.albedo.transmutation then
    R.register{ id = "spanish_gold", station = "hand", node = C.spanish_gold.node,
        inputs = C.spanish_gold.inputs, outputs = C.spanish_gold.outputs }
end
for _, study in ipairs(C.tier6_studies) do C.studies[#C.studies + 1] = study end

-- Projection, and Exaltation's yield ----------------------------------------------------------

local P = C.red_projection
local projections = {}      -- recipe id -> { makes (qualified), count }
if tdm.albedo.transmutation then
    R.group(P.base, P.base_members)
    R.register{
        id = "projection_red", station = "hand", node = P.node,
        inputs = { { "red_stone", count = 1 }, { P.base, count = P.count } },
        outputs = { { P.makes, count = P.count } },
    }
    projections[U.id("projection_red")] = { makes = U.id(P.makes), count = P.count }
    projections[U.id("projection_white")] = { makes = U.id(C.white_projection.makes), count = C.white_projection.count }
end
local MILESTONE = game.mod_id .. ".transmutation"

if craft and progress then
    craft.on_crafted(function(uuid, recipe_id)
        local p = projections[recipe_id]
        if not p then return end
        local percent = progress.effects_of(uuid, "magic.")["magic.projection_percent"] or 0
        local more = p.count * percent // 100
        if more > 0 then game.give(uuid, { material = p.makes, count = more }) end
        progress.discover(uuid, MILESTONE)
    end)
end

-- The alkahest, and coagula ------------------------------------------------------------------

local K = C.alkahest
local ALKAHEST = U.material(U.id(K.item))
local PRIMA = U.material(U.id(K.becomes))
local SOLUBLE = {}
for _, id in ipairs(C.gifts.gnome_delving.digs) do
    local m = U.material(U.id(id))
    if m then SOLUBLE[m] = true end
end

--- The blocks round `pos` the alkahest would melt for `uuid`.
local function soluble_round(pos, uuid)
    local out = {}
    local r = K.radius
    for dx = -r, r do
        for dy = -r, r do
            for dz = -r, r do
                local at = { x = pos.x + dx, y = pos.y + dy, z = pos.z + dz, domain = pos.domain }
                local b = game.get_block(at)
                local fluid = b and game.get_fluid(at)
                if b and SOLUBLE[b.material] and b.occupancy == game.OCCUPANCY_FULL and not (fluid and fluid.volume > 0)
                    and not (tdm.seal and tdm.seal.warding(at.x, at.y, at.z, uuid, at.domain)) then
                    out[#out + 1] = at
                end
            end
        end
    end
    return out
end

tdm.on_use(function(e)
    if not (e.x and e.held and e.held.material == ALKAHEST) then return nil end
    if not (progress and progress.has(e.player, K.node)) then return "You do not know the alkahest." end
    local melt = soluble_round(U.block_of(e), e.player)
    if #melt == 0 then return "The alkahest finds nothing here it can dissolve." end
    if Q.amount(e.player) < #melt * K.cost then return C.caduceus.dry end
    if game.take(e.player, { material = ALKAHEST, count = 1 }) < U.UNITS then return "" end
    Q.spend(e.player, #melt * K.cost)
    for _, at in ipairs(melt) do game.set_block(at, "engine:air") end
    game.give(e.player, { material = PRIMA, units = #melt * U.UNITS })
    return ""
end)

for _, id in ipairs(C.coagula.into) do
    local q = U.id(id)
    if U.material(q) then
        R.register{ id = "coagula_" .. string.match(q, ":(.+)$"), station = "hand", node = C.coagula.node, unlisted = true,
            inputs = { { K.becomes, count = 1 } }, outputs = { { q, units = U.UNITS } } }
    end
end
C.book_notes["magic.prima_materia"] = "prima materia  ->  any common stone, earth or sand, unit for unit, by hand"

-- The Panacea --------------------------------------------------------------------------------

local PANACEA = U.id("panacea")
if life and life.on_eat and life.heal then
    life.on_eat(function(uuid, material)
        if material ~= PANACEA then return end
        local body = game.player_entity(uuid)
        local me = body and game.entity(body)
        if not me then return end
        for _, id in ipairs(game.entities_in_radius(me.pos, C.panacea.radius)) do
            local e = game.entity(id)
            if e and e.owner and e.owner ~= uuid then
                life.heal(e.owner, C.panacea.heal)
                if life.cure then
                    for _, fx in ipairs(C.panacea.cures) do life.cure(e.owner, fx) end
                end
                game.chat_to(e.owner, "The Panacea's warmth reaches you.")
            end
        end
    end)
end

-- The Phoenix ----------------------------------------------------------------------------------

local PH = C.phoenix
local function armed_key(uuid) return "phoenix:" .. uuid end
local function ready_key(uuid) return "phoenix_ready:" .. uuid end

--- Arms the phoenix for a player who knows it and whose time has come.
local function arm(uuid)
    if not (life and life.keep_inventory and progress and progress.has(uuid, PH.node)) then return end
    if game.storage.get(armed_key(uuid)) == true then return end
    local ready = game.storage.get(ready_key(uuid)) or 0
    if E.now() < ready then return end
    life.keep_inventory(uuid)
    game.storage.set(armed_key(uuid), true)
end

tdm.on_join(function(event) arm(event.player) end)
if progress then progress.on_unlock(function(uuid, node) if node == PH.node then arm(uuid) end end) end
if life and life.on_death then
    life.on_death(function(uuid)
        if game.storage.get(armed_key(uuid)) ~= true then return end
        game.storage.set(armed_key(uuid), nil)
        game.storage.set(ready_key(uuid), E.now() + PH.every)
        game.chat_to(uuid, PH.rises)
    end)
end
local since = 0
tdm.on_tick(function(dt)
    since = since + (math.tointeger(dt) or 1)
    if since < 1200 then return end
    since = 0
    for uuid in pairs(tdm.online) do arm(uuid) end
end)

-- The Chymical Wedding ---------------------------------------------------------------------------

local W = C.wedding
local LIT_OR_NOT = { [U.material(U.id(C.athanor.block.id)) or -1] = true, [U.material(U.id(C.athanor.lit.id)) or -2] = true }
local STATION = U.id(C.athanor.station)
local PREFIX = "tiamat_default_craft:" .. STATION .. ":"
local CROWN = U.material(U.id(W.crown))
local WEDDING = game.mod_id .. ".chymical_wedding"
if progress then
    progress.register_discovery{ id = WEDDING, insight = W.discovery, label = "The Chymical Wedding", group = "opus" }
end

local function glyph_at(x, y, z, domain)
    local b = game.get_block{ x = x, y = y, z = z, domain = domain }
    local g = b and b.occupancy and G.of(b.occupancy)
    return g and g.id or nil
end

--- Whether the athanor at `pos` is wed: Sol and Luna on opposite sides,
--- a quintessence on top. Answers the top's position.
function M.wed(pos)
    if glyph_at(pos.x, pos.y + 1, pos.z, pos.domain) ~= "quintessence" then return nil end
    for _, d in ipairs({ { 1, 0 }, { 0, 1 } }) do
        local a = glyph_at(pos.x + d[1], pos.y, pos.z + d[2], pos.domain)
        local b = glyph_at(pos.x - d[1], pos.y, pos.z - d[2], pos.domain)
        if (a == "sol" and b == "luna") or (a == "luna" and b == "sol") then
            return { x = pos.x, y = pos.y + 1, z = pos.z, domain = pos.domain }
        end
    end
    return nil
end

local looked = 0
tdm.on_tick(function(dt)
    looked = looked + (math.tointeger(dt) or 1)
    if looked < 200 then return end
    looked = 0
    for _, name in ipairs(game.containers(PREFIX)) do
        if game.storage.get("wedded:" .. name) == nil then
            local pos = U.station_pos(name, STATION)
            local b = pos and game.get_block(pos)
            local top = b and LIT_OR_NOT[b.material] and M.wed(pos)
            local who = top and tdm.sigils.setter(top.x, top.y, top.z, top.domain)
            if who and progress and progress.has(who, W.node) then
                game.storage.set("wedded:" .. name, true)
                game.give(who, { material = CROWN, count = 1 })
                progress.discover(who, WEDDING)
                game.emit_particles{ pos = { x = pos.x + 0.5, y = pos.y + 2, z = pos.z + 0.5 }, count = 40,
                    colour = { r = 1.0, g = 0.4, b = 0.4 }, size = 0.15, lifetime = 2, spread = 1, collide = false }
            end
        end
    end
end)

return M
