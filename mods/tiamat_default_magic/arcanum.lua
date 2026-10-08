-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Tier 7, the Great Arcanum (brief §5.5), all but the worlds (worlds.lua).
--
-- - Gate XII, projection on the world: a Red Stone and quintessence used on
--   the ground turn the base-metal ore round it into gold ore, a block a
--   tick, and heal every creature and player near — or only heal, where
--   the world forbids transmutation;
-- - the Rebis, made in the Egg from the two Stones and the green lion,
--   Sol and Luna carved in their ores, the Wedding Crown standing by;
-- - Quintessences of the Four: an elemental walking with an adept who
--   stands at the centre of a Circle of Four gives its element's essence,
--   one for each philosophical day spent there;
-- - Lapis Infinitus: the Stone multiplies in a day, fed a quintessence
--   in place of the quicksilver (its projections are ten-fold through the
--   tree's effects, rubedo.lua);
-- - the Universal Medicine: friends near an adept who knows it heal;
-- - Thrice-Greatest: the Tablet's whole text, a golden aura and a crown
--   over the head.

local C = tdm.config
local U = tdm.util
local R = tdm.recipes
local Q = tdm.quintessence
local E = tdm.effects
local G = tdm.glyphs

local A = {}

local progress = U.exports("tiamat_default_progress")
local life = U.exports("tiamat_default_life")

R.register_all(C.tier7_recipes)
R.group("#magic_elemental_quintessence",
    { "quintessence_fire", "quintessence_water", "quintessence_air", "quintessence_earth" })
for _, study in ipairs(C.tier7_studies) do C.studies[#C.studies + 1] = study end

-- Salamander's wool (W-M2): teased from the hot shell's fibre, and a
-- blast in an athanor's vessel slot, beside bellows and the ember.
R.register(C.shells.wool_recipe)
R.group(C.athanor.blast, { C.shells.wool.id })

-- Lapis Infinitus: Gate XI in a day, a quintessence for the quicksilver.
R.register{ id = "multiplication_lapis", station = "athanor", node = C.lapis.node, degree = 1, days = C.lapis.days, gate = 11,
    inputs = { { "red_stone", count = 1 }, { "C:gold_ingot", count = 1 }, { "quintessence", count = 1 } },
    tools = { { "philosophers_egg", wear = 0 } }, outputs = { { "red_stone", count = 2 } } }

local function has(uuid, node) return progress ~= nil and progress.has(uuid, node) == true end

local function body_pos(uuid)
    local body = game.player_entity(uuid)
    local me = body and game.entity(body)
    return me and me.pos or nil, body
end

--- A glyph's short id at a block, counted only when carved from one of its
--- own materials (where it names any).
local MATERIALS = {}
for _, glyph in ipairs(tdm.glyph_table) do
    if glyph.materials then
        MATERIALS[glyph.id] = {}
        for _, id in ipairs(glyph.materials) do
            local m = U.material(U.id(id))
            if m then MATERIALS[glyph.id][m] = true end
        end
    end
end
function A.glyph_at(x, y, z, domain)
    local b = game.get_block{ x = x, y = y, z = z, domain = domain }
    local g = b and b.occupancy and G.of(b.occupancy)
    if not g then return nil end
    if MATERIALS[g.id] and not MATERIALS[g.id][b.material] then return nil end
    return g.id
end

-- Gate XII: projection on the world ---------------------------------------------------------

local P = C.world_projection
local STONE = U.material(U.id(P.stone))
local GOLD_ORE = U.id(P.becomes)
local BASE = {}
for _, id in ipairs(P.ores) do
    local m = U.material(U.id(id))
    if m then BASE[m] = true end
end
local queue = {}            -- blocks waiting to turn, in order: { x, y, z, domain }

tdm.on_use(function(e)
    if not (e.x and e.held and e.held.material == STONE) then return nil end
    if not has(e.player, P.node) then return nil end           -- a Stone is a Stone to everybody else
    if Q.amount(e.player) < P.cost then return C.caduceus.dry end
    if game.take(e.player, { material = STONE, count = 1 }) < U.UNITS then return "" end
    Q.spend(e.player, P.cost)
    local at = U.block_of(e)
    local turned = 0
    if tdm.albedo.transmutation then
        local r = P.radius
        for dx = -r, r do
            for dy = -r, r do
                for dz = -r, r do
                    local x, y, z = at.x + dx, at.y + dy, at.z + dz
                    local b = game.get_block{ x = x, y = y, z = z, domain = e.domain }
                    if b and BASE[b.material] and not (tdm.seal and tdm.seal.warding(x, y, z, e.player, e.domain)) then
                        queue[#queue + 1] = { x = x, y = y, z = z, domain = e.domain }
                        turned = turned + 1
                    end
                end
            end
        end
    end
    -- Every creature and player near is healed.
    local centre = { x = at.x + 0.5, y = at.y + 1, z = at.z + 0.5 }
    if life and life.heal then
        for _, id in ipairs(game.entities_in_radius(centre, P.heal_radius)) do
            local other = game.entity(id)
            if other and other.owner then life.heal(other.owner, P.heal)
            elseif other and other.source == "tiamat_default_life" then life.heal(id, P.heal) end
        end
    end
    game.emit_particles{ pos = centre, count = 60, colour = { r = 1.0, g = 0.75, b = 0.2 }, size = 0.15,
        lifetime = 2, spread = P.radius, collide = false }
    if progress and tdm.gates then progress.discover(e.player, tdm.gates.id(P.gate)) end
    if turned > 0 then return "The Stone falls on the earth, and the earth answers in gold." end
    return "The Stone falls on the earth, and all near it are healed."
end)

-- The queue, a few blocks a tick: what was base ore when the Stone fell
-- and is base ore still.
tdm.on_tick(function()
    for _ = 1, P.per_tick do
        local at = table.remove(queue, 1)
        if not at then return end
        local b = game.get_block(at)
        if b and BASE[b.material] then game.set_block(at, GOLD_ORE) end
    end
end)

-- The Four's quintessences ------------------------------------------------------------------

local EQ = C.elemental_quintessences
local NEED = EQ.days * C.philosophical_day
local EDGES = { { 2, 0 }, { -2, 0 }, { 0, 2 }, { 0, -2 } }

--- Whether a Circle of Four lies round `x, y, z`: its quintessence centre
--- there, and fire, water, air and earth at the four mid-edges.
function A.circle(x, y, z, domain)
    if A.glyph_at(x, y, z, domain) ~= "quintessence" then return false end
    local seen = {}
    for _, d in ipairs(EDGES) do
        local g = A.glyph_at(x + d[1], y, z + d[2], domain)
        if not g or seen[g] then return false end
        seen[g] = true
    end
    return seen.fire and seen.water and seen.air and seen.earth or false
end

--- The Circle a player stands on, if any: its centre under their feet.
local function standing_on_circle(pos)
    local x, z = math.floor(pos.x), math.floor(pos.z)
    for _, y in ipairs({ math.floor(pos.y), math.floor(pos.y) - 1 }) do
        if A.circle(x, y, z) then return true end
    end
    return false
end

local function drawn_key(uuid, kind) return "eqdrawn:" .. uuid .. ":" .. kind end

local since_circle = 0
tdm.on_tick(function(dt)
    since_circle = since_circle + (math.tointeger(dt) or 1)
    if since_circle < EQ.every then return end
    local step = since_circle
    since_circle = 0
    for uuid in pairs(tdm.online) do
        if has(uuid, EQ.node) then
            local pos = body_pos(uuid)
            if pos and standing_on_circle(pos) then
                for _, f in ipairs(tdm.familiars.list(uuid)) do
                    local element = EQ.kinds[f.kind]
                    local fe = f.entity and game.entity(f.entity)
                    if element and fe and math.abs(fe.pos.x - pos.x) <= EQ.reach and math.abs(fe.pos.z - pos.z) <= EQ.reach then
                        local drawn = (tonumber(game.storage.get(drawn_key(uuid, f.kind))) or 0) + step
                        if drawn >= NEED then
                            drawn = drawn - NEED
                            game.give(uuid, { material = U.id("quintessence_" .. element), count = 1 })
                            game.chat_to(uuid, string.format("Your %s gives up the quintessence of %s.", f.kind, element))
                        end
                        game.storage.set(drawn_key(uuid, f.kind), math.tointeger(drawn))
                    end
                end
            end
        end
    end
end)

-- The Universal Medicine ------------------------------------------------------------------

local UM = C.universal_medicine
local since_medicine = 0
tdm.on_tick(function(dt)
    since_medicine = since_medicine + (math.tointeger(dt) or 1)
    if since_medicine < UM.every then return end
    since_medicine = 0
    if not (life and life.heal) then return end
    for uuid in pairs(tdm.online) do
        if has(uuid, UM.node) then
            local pos = body_pos(uuid)
            if pos then
                for _, id in ipairs(game.entities_in_radius(pos, UM.radius)) do
                    local other = game.entity(id)
                    if other and other.owner and other.owner ~= uuid and tdm.online[other.owner]
                        and game.player_entity(other.owner) == id then
                        life.heal(other.owner, UM.heal)
                    end
                end
            end
        end
    end
end)

-- Thrice-Greatest --------------------------------------------------------------------------------

local T = C.trismegistus
local TABLET_FORM = "tablet"
local CROWN = game.register_picture{ file = "textures/wedding_crown.png" }

--- Shows the Emerald Tablet's whole text to a player.
function A.tablet(uuid)
    local lines = { { type = "label", text = "The Emerald Tablet", style = { text_size = 22 } } }
    for _, line in ipairs(T.tablet) do
        lines[#lines + 1] = { type = "label", text = line, style = { text_size = 15 } }
    end
    lines[#lines + 1] = { type = "label", text = "- Isaac Newton's translation", style = { text_size = 13 } }
    game.show_dialog{ player = uuid, form = TABLET_FORM, tree = {
        type = "container", direction = "column", gap = 6, align = "stretch",
        children = { { type = "scroll", grow = 1, children = {
            { type = "container", direction = "column", gap = 8, align = "stretch", children = lines } } } },
    } }
end
tdm.on_dialog(TABLET_FORM, function() end)

--- Whether a player is Thrice-Greatest.
function A.trismegistus(uuid) return has(uuid, T.node) end

if progress then
    progress.on_unlock(function(uuid, node)
        if node ~= T.node then return end
        A.tablet(uuid)
        local name = tdm.online[uuid] or "An adept"
        for other in pairs(tdm.online) do
            game.chat_to(other, name .. " is " .. T.title .. ": Thrice-Greatest.")
        end
    end)
end

local since_aura = 0
tdm.on_tick(function(dt)
    since_aura = since_aura + (math.tointeger(dt) or 1)
    if since_aura < T.aura_every then return end
    since_aura = 0
    for uuid in pairs(tdm.online) do
        if has(uuid, T.node) then
            local pos, body = body_pos(uuid)
            if pos then
                game.emit_particles{ pos = { x = pos.x, y = pos.y + 1, z = pos.z }, count = 8,
                    colour = { r = 1.0, g = 0.85, b = 0.3 }, size = 0.08, lifetime = 2, spread = 0.6, collide = false }
                game.show_over(body, { picture = CROWN, seconds = 4, size = 0.5, colour = { r = 1, g = 0.9, b = 0.5 } })
            end
        end
    end
end)

return A
