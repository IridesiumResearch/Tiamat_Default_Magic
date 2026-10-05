-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Woven worlds, tier 7 (brief §6.11): the Loom, the five archetypes, Solve
-- et Coagula, the World-Gate and the native spirits.
--
-- **A world is an instance.** One template an archetype — Earth, Water,
-- Air, Fire, Quintessence — and each woven world an instance of it whose
-- key carries its parameters: `<weaver's first 16 hex>_<n>_<vein>_<sea>`.
-- The generator reads them back from `pos.domain`, so nothing is stored for
-- it and every generation worker agrees. Each world's field is compiled the
-- first time a worker fills one of its chunks, its noise streams named for
-- the key, so two worlds of one archetype are two worlds; a world's sky is
-- set on the instance when it is woven (engine `create_domain`'s `sky`).
--
-- **The Loom** is a construct: a quintessence glyph carved in crystal, the
-- seven sigils and the emerald round it, and fire, water, air and earth at
-- the outer mid-edges (brief §7.3). Used with the Rebis in hand it asks
-- what to weave; used with anything else, it lists the weaver's worlds, to
-- enter or to dissolve. Weaving takes the Rebis, the four quintessences, a
-- block of prima materia and a Red Stone; dissolving (Solve et Coagula)
-- carries everyone inside back out, ends the world and gives half the prima
-- materia back. A world's door stays shut while its weaver has left the
-- Art (a repath seals it; it is never destroyed for that).
--
-- **Leaving** is the Philosophers' Egg, used inside, or `magic leave` for a
-- guest who carries none; either goes back to where the traveller stood.
-- A **World-Gate** is a correspondence gate bound to a world with the Egg:
-- stepping on it carries its weaver, and anyone they allow (`magic world
-- allow <name>`), inside.

local C = tdm.config
local U = tdm.util

local W = {}

local K = C.worlds
local progress = U.exports("tiamat_default_progress")

local function has(uuid, node) return progress ~= nil and progress.has(uuid, node) == true end

-- The archetypes: their fields, built once per world ---------------------------------------------

local function const(v) return { op = "const", value = v } end
local function sub(a, b) return { op = "sub", a = a, b = b } end
local function add(a, b) return { op = "add", a = a, b = b } end
local function mul(a, b) return { op = "mul", a = a, b = b } end
local function max(a, b) return { op = "max", a = a, b = b } end
local function min(a, b) return { op = "min", a = a, b = b } end
local function abs(a) return { op = "abs", a = a } end
local Y = { op = "y" }
local function noise2(stream, frequency, amplitude, octaves)
    return { op = "noise2", stream = stream, frequency = frequency, amplitude = amplitude, octaves = octaves or 3 }
end
local function noise(stream, frequency, octaves, stretch)
    return { op = "noise", stream = stream, frequency = frequency, octaves = octaves or 3, stretch = stretch }
end
local function square_over(a, scale)
    local q = { op = "div", a = a, b = const(scale) }
    return mul(q, q)
end

--- The ground every world has under its arrival: a little island, so a
--- traveller never lands in a sea, in lava or on nothing.
local L = K.landing
local LANDING = min(sub(const(L.top + 0.5), Y),
    mul(const(L.depth), sub(const(1), add(add(square_over({ op = "x" }, L.radius), square_over({ op = "z" }, L.radius)),
        square_over(sub(Y, const(L.top - L.depth / 2)), L.depth)))))

-- Each archetype: its field (a function of the world's key), its strata,
-- and its sea (a fluid, or none).
local ARCH = {}

ARCH.earth = {
    field = function(s)
        local surface = sub(add(const(66), noise2("earth_hills_" .. s, 0.01, 10)), Y)
        -- Caverns below y = 50: solid wherever the cave noise is far from zero.
        local caves = max(mul(sub(abs(noise("earth_caves_" .. s, 0.04)), const(0.22)), const(80)), sub(Y, const(50)))
        return min(surface, caves)
    end,
    bands = { { 0, "W:grass" }, { 1, "W:dirt" }, { 4, "W:stone" }, { 30, "W:granite" } },
    ores = { "W:crystal" },
}
ARCH.water = {
    field = function(s) return sub(add(const(58), noise2("water_isles_" .. s, 0.008, 16)), Y) end,
    bands = { { 0, "W:white_sand" }, { 2, "W:sand" }, { 5, "W:stone" } },
    sea = "W:water",
}
ARCH.air = {
    field = function(s)
        local cloud = mul(noise("air_isles_" .. s, 0.02, 3, { y = 2 }), const(24))
        return sub(sub(cloud, mul(abs(sub(Y, const(64))), const(0.8))), const(4))
    end,
    bands = { { 0, "W:grass" }, { 1, "W:dirt" }, { 4, "W:stone" } },
}
ARCH.fire = {
    field = function(s) return sub(add(const(60), noise2("fire_crags_" .. s, 0.012, 14)), Y) end,
    bands = { { 0, "W:volcanic_ash" }, { 1, "W:dark_basalt" }, { 6, "W:lava_rock" }, { 20, "W:obsidian" } },
    sea = "W:lava",
}
ARCH.quintessence = {
    field = function(s)
        local ground = sub(add(const(62), noise2("q_plain_" .. s, 0.01, 4)), Y)
        local spires = sub(add(mul(sub(noise2("q_spires_" .. s, 0.07, 1, 2), const(0.55)), const(120)), const(80)), Y)
        return max(ground, spires)
    end,
    bands = { { 0, "W:calcite" }, { 3, "W:stone" } },
    sea = "W:water",
    ores = { "W:crystal" },
}

W.ARCHETYPES = {}
for _, a in ipairs(K.archetypes) do
    W.ARCHETYPES[a.id] = a
    local arch = ARCH[a.id]
    arch.palette = {}
    for _, band in ipairs(arch.bands) do
        local m = U.material(U.id(band[2]))
        if m then arch.palette[#arch.palette + 1] = { above = band[1] + 0.0, material = m } end
    end
    arch.fluid = arch.sea and (U.id(arch.sea)) or nil
    arch.ore_ids = {}
    for _, id in ipairs(K.common_ores) do arch.ore_ids[#arch.ore_ids + 1] = U.material(U.id(id)) end
    for _, id in ipairs(arch.ores or {}) do arch.ore_ids[#arch.ore_ids + 1] = U.material(U.id(id)) end
end
local VEIN = {}
for planet, id in pairs(K.veins) do VEIN[planet] = U.material(U.id(id)) end

--- A world's key, made and read: the weaver, their world's number, the vein
--- (a planet, or `none`) and the sea (`low`, `mid` or `high`).
function W.key(uuid, n, vein, sea) return string.format("%s_%d_%s_%s", string.sub(uuid, 1, 16), n, vein, sea) end
function W.parse(domain)
    local arch, key = string.match(domain or "", "^" .. game.mod_id .. ":world_(%a+)/(.+)$")
    if not arch then return nil end
    local owner, n, vein, sea = string.match(key, "^(%x+)_(%d+)_(%a+)_(%a+)$")
    if not owner then return nil end
    return { archetype = arch, key = key, owner16 = owner, n = math.tointeger(tonumber(n)), vein = vein, sea = sea }
end
function W.is_woven(domain) return W.parse(domain) ~= nil end

local fields = {}           -- key -> the compiled field (per VM: each worker compiles its own once)
local function field_of(w)
    local f = fields[w.key]
    if not f then
        f = game.density(max(ARCH[w.archetype].field(w.key), LANDING))
        fields[w.key] = f
    end
    return f
end

local function generate(buf, pos)
    local w = W.parse(pos.domain)
    if not w then return end
    local arch = ARCH[w.archetype]
    local field = field_of(w)
    local sea = arch.fluid and K.seas[w.sea] or nil
    local bounds = field:bounds(pos)
    if bounds.all_empty and not (sea and pos.y * 16 < sea) then return end
    if not bounds.all_empty then buf:fill_palette(field, arch.palette) end
    if sea then buf:fill_fluid_below(sea, arch.fluid) end
    if bounds.all_empty then return end
    -- Ore: a few common seams a chunk, and a planet's metal rich where the
    -- weaver chose one. O(ores), each set only deep inside the rock.
    local rng = game.rng_stream(pos, "veins_" .. w.key)
    local rich = VEIN[w.vein]
    local tries = K.ores_per_chunk + (rich and K.rich_per_chunk or 0)
    for i = 1, tries do
        local x, y, z = rng:below(16), rng:below(16), rng:below(16)
        local ore = (rich and i > K.ores_per_chunk) and rich or arch.ore_ids[rng:below(#arch.ore_ids) + 1]
        if ore and field:at(pos.x * 16 + x, pos.y * 16 + y, pos.z * 16 + z, pos.seed) > 3 then
            buf:set_block(x, y, z, ore)
        end
    end
end

for _, a in ipairs(K.archetypes) do
    game.register_domain{ id = "world_" .. a.id, instanced = true, generator = generate }
end

-- Skies --------------------------------------------------------------------------------------------

local function blend(a, b, t) return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t } end
local function dim(c, t) return { c[1] * t, c[2] * t, c[3] * t } end

--- A sky named in `config.lua`, as the engine's keyframes.
function W.sky(name)
    local s = K.skies[name]
    if not s then return nil end
    local dusk = blend(s.night, s.day, 0.5)
    return {
        keyframes = {
            { time = 0.0, sky = s.night, sun = dim(s.sun, 0.25), intensity = 0.15, stars = 1 },
            { time = 0.25, sky = dusk, sun = s.sun, intensity = 0.6, stars = 0.3 },
            { time = 0.5, sky = s.day, sun = s.sun, intensity = 1.0, stars = 0 },
            { time = 0.75, sky = dusk, sun = s.sun, intensity = 0.6, stars = 0.3 },
            { time = 0.999, sky = s.night, sun = dim(s.sun, 0.25), intensity = 0.15, stars = 1 },
        },
        cave_fog = s.night,
    }
end

-- Records ---------------------------------------------------------------------------------------

-- A world's record: `woven:<key>` = "archetype|owner|sky|x,y,z|domain",
-- the Loom it was woven at standing in for a return point nobody kept.
local function record_key(key) return "woven:" .. key end
local function encode(r)
    return table.concat({ r.archetype, r.owner, r.sky, string.format("%d,%d,%d", r.loom.x, r.loom.y, r.loom.z), r.loom.domain or "overworld" }, "|")
end
local function decode(v)
    if type(v) ~= "string" then return nil end
    local arch, owner, sky, x, y, z, domain = string.match(v, "^(%a+)|(%x+)|(%a+)|(%-?%d+),(%-?%d+),(%-?%d+)|(.+)$")
    if not arch then return nil end
    return { archetype = arch, owner = owner, sky = sky,
        loom = { x = math.tointeger(tonumber(x)), y = math.tointeger(tonumber(y)), z = math.tointeger(tonumber(z)), domain = domain } }
end
function W.record(key) return decode(game.storage.get(record_key(key))) end

--- A player's worlds: `{ { key, id, record } }`, oldest first.
function W.worlds_of(uuid)
    local out = {}
    for _, k in ipairs(game.storage.keys("woven:" .. string.sub(uuid, 1, 16) .. "_")) do
        local key = string.sub(k, #"woven:" + 1)
        local r = decode(game.storage.get(k))
        if r and r.owner == uuid then
            out[#out + 1] = { key = key, id = U.id("world_" .. r.archetype) .. "/" .. key, record = r }
        end
    end
    table.sort(out, function(a, b) return a.key < b.key end)
    return out
end

local CAP = math.tointeger(tonumber(game.world_option(game.mod_id .. ":woven_worlds") or "1")) or 1

-- Where everyone is, and travel ----------------------------------------------------------------

W.where = {}                -- uuid -> the domain they are in, as last heard

tdm.on_move(function(e) W.where[e.player] = e.domain end)
tdm.on_domain_enter(function(e)
    for uuid in pairs(tdm.online) do
        if game.player_entity(uuid) == e.entity then W.where[uuid] = e.to end
    end
end)
tdm.on_leave(function(e) W.where[e.player] = nil end)

local function return_key(uuid) return "wovenreturn:" .. uuid end

--- Carries a player into a woven world, keeping where they stood.
local function enter(uuid, id, from)
    local body = game.player_entity(uuid)
    if not body then return false end
    game.storage.set(return_key(uuid), string.format("%.2f,%.2f,%.2f,%s", from.x, from.y, from.z, from.domain or "overworld"))
    return game.transfer_entity(body, id, K.arrive)
end

--- Carries a player out of a woven world, to where they stood before it
--- (or the Loom of the world they are in, for anyone who kept nothing).
function W.leave(uuid, domain)
    local body = game.player_entity(uuid)
    if not body then return false end
    local back = tostring(game.storage.get(return_key(uuid)) or "")
    local x, y, z, to = string.match(back, "^(%-?[%d.]+),(%-?[%d.]+),(%-?[%d.]+),(.+)$")
    if x and to ~= domain then
        game.storage.set(return_key(uuid), nil)
        return game.transfer_entity(body, to, { x = tonumber(x), y = tonumber(y), z = tonumber(z) })
    end
    local w = W.parse(domain)
    local r = w and W.record(w.key)
    if not r then return false end
    return game.transfer_entity(body, r.loom.domain, { x = r.loom.x + 0.5, y = r.loom.y + 1, z = r.loom.z + 3.5 })
end

local function allow_key(owner, uuid) return "worldallow:" .. owner .. ":" .. uuid end

--- Whether `uuid` may go into a world: its weaver (while they walk the
--- Art), or someone they allow.
local function may_enter(uuid, r)
    if progress and progress.path(r.owner) ~= C.path.id then return false, "That world is sealed: its weaver has left the Art." end
    if uuid == r.owner or game.storage.get(allow_key(r.owner, uuid)) == true then return true end
    return false, "That world is not open to you."
end

-- The Egg, used inside a woven world, goes back. Heard before the
-- microcosm's own use of it (cosmos.lua asks this file first).
local EGG = U.material(U.id(C.microcosm.egg))
function W.egg_use(e)
    if not (e.held and e.held.material == EGG and W.is_woven(e.domain)) then return nil end
    if not W.leave(e.player, e.domain) then return "The Egg will not open the way back." end
    return ""
end

-- The Loom ----------------------------------------------------------------------------------

local SIGILS = { sol = true, luna = true, venus = true, mars = true, jupiter = true, saturn = true, mercury = true, emerald = true }
local RING = { { 1, 0 }, { 1, 1 }, { 0, 1 }, { -1, 1 }, { -1, 0 }, { -1, -1 }, { 0, -1 }, { 1, -1 } }
local EDGES = { { 2, 0 }, { -2, 0 }, { 0, 2 }, { 0, -2 } }

--- Whether a Loom lies round `x, y, z` (its centre).
function W.loom(x, y, z, domain)
    local glyph_at = tdm.arcanum.glyph_at
    if glyph_at(x, y, z, domain) ~= "quintessence" then return false end
    local seen = {}
    for _, d in ipairs(RING) do
        local g = glyph_at(x + d[1], y, z + d[2], domain)
        if not (g and SIGILS[g]) or seen[g] then return false end
        seen[g] = true
    end
    local four = {}
    for _, d in ipairs(EDGES) do
        local g = glyph_at(x + d[1], y, z + d[2], domain)
        if not g or four[g] then return false end
        four[g] = true
    end
    return (four.fire and four.water and four.air and four.earth) == true
end

local FORM = "loom"
local REBIS = U.material(U.id("rebis"))
local weaving = {}          -- uuid -> the choices of a weaving in hand, and the Loom
local listing = {}          -- uuid -> the Loom whose worlds they are looking at

local function button(name, text, chosen)
    return { type = "button", name = name, text = chosen and ("[" .. text .. "]") or text }
end
local function label(text, size) return { type = "label", text = text, style = { text_size = size or 15 } } end
local function row(children) return { type = "container", direction = "row", gap = 6, children = children } end
local function column(children) return { type = "container", direction = "column", gap = 8, align = "stretch", children = children } end

local function weave_tree(uuid)
    local s = weaving[uuid]
    local rows = { label("The Loom of the Four", 22), label("Weave a world of:") }
    local archs = {}
    for _, a in ipairs(K.archetypes) do archs[#archs + 1] = button("arch:" .. a.id, a.name, s.archetype == a.id) end
    rows[#rows + 1] = row(archs)
    rows[#rows + 1] = label(W.ARCHETYPES[s.archetype].blurb, 13)
    if has(uuid, K.skies_node) then
        rows[#rows + 1] = label("Under the sky of:")
        local skies = { button("sky:" .. s.archetype, "its own", s.sky == s.archetype) }
        for _, planet in ipairs(C.planets) do skies[#skies + 1] = button("sky:" .. planet, C.planet_names[planet], s.sky == planet) end
        rows[#rows + 1] = row(skies)
    end
    if has(uuid, K.veins_node) then
        rows[#rows + 1] = label("With rich veins of:")
        local veins = { button("vein:none", "nothing", s.vein == "none") }
        for _, planet in ipairs(C.planets) do veins[#veins + 1] = button("vein:" .. planet, C.planet_names[planet], s.vein == planet) end
        rows[#rows + 1] = row(veins)
    end
    rows[#rows + 1] = label("Its sea:")
    rows[#rows + 1] = row({ button("sea:low", "low", s.sea == "low"), button("sea:mid", "middling", s.sea == "mid"),
        button("sea:high", "high", s.sea == "high") })
    rows[#rows + 1] = label("It takes the Rebis, the four quintessences, a block of prima materia and a Red Stone.", 13)
    rows[#rows + 1] = row({ button("weave", "Weave") })
    return column(rows)
end

local function list_tree(uuid)
    local rows = { label("The Loom of the Four", 22) }
    local worlds = W.worlds_of(uuid)
    if #worlds == 0 then
        rows[#rows + 1] = label("You have woven no world. Use the Loom with the Rebis in hand.")
    end
    for i, w in ipairs(worlds) do
        local a = W.ARCHETYPES[w.record.archetype]
        local parts = { label(string.format("%d. A world of %s", i, a and a.name or w.record.archetype)), button("enter:" .. w.key, "Enter") }
        if has(uuid, K.solve_node) then parts[#parts + 1] = button("solve:" .. w.key, "Solve et coagula") end
        rows[#rows + 1] = row(parts)
    end
    rows[#rows + 1] = label(string.format("You may hold %d at once.", CAP), 13)
    return column(rows)
end

local function show(uuid, tree) game.show_dialog{ player = uuid, form = FORM, tree = tree } end

--- Takes every cost of a weaving, or nothing.
local function take_costs(uuid)
    local taken = {}
    for _, cost in ipairs(K.costs) do
        local id = U.id(cost[1])
        local want = cost.units or cost.count * U.UNITS
        local got = game.take(uuid, { material = id, units = want })
        taken[#taken + 1] = { material = id, units = got }
        if got < want then
            for _, t in ipairs(taken) do
                if t.units > 0 then game.give(uuid, { material = t.material, units = t.units }) end
            end
            return false
        end
    end
    return true
end

local WOVEN = game.mod_id .. ".woven"
if progress then
    progress.register_discovery{ id = WOVEN, insight = K.discovery, label = "A world woven", group = "milestones" }
end

local function weave(uuid)
    local s = weaving[uuid]
    if #W.worlds_of(uuid) >= CAP then return "You hold as many worlds as you may. Dissolve one first." end
    if not take_costs(uuid) then return "The Loom wants the Rebis, the four quintessences, a block of prima materia and a Red Stone." end
    local n = (math.tointeger(tonumber(game.storage.get("wovencount:" .. uuid))) or 0) + 1
    game.storage.set("wovencount:" .. uuid, n)
    local key = W.key(uuid, n, s.vein, s.sea)
    local id = game.create_domain(U.id("world_" .. s.archetype), key, { sky = W.sky(s.sky) })
    if not id then return "The Loom will not take the thread." end
    game.storage.set(record_key(key), encode{ archetype = s.archetype, owner = uuid, sky = s.sky, loom = s.loom })
    weaving[uuid] = nil
    game.close_dialog{ player = uuid, form = FORM }
    if progress then progress.discover(uuid, WOVEN) end
    enter(uuid, id, { x = s.loom.x + 0.5, y = s.loom.y + 1, z = s.loom.z + 3.5, domain = s.loom.domain })
    return "The Loom sings. A world is woven, and you step into it."
end

--- Ends a world: everyone inside carried out, the instance destroyed, half
--- the prima materia back. Answers what to tell the weaver.
local function solve(uuid, key)
    local r = W.record(key)
    if not (r and r.owner == uuid) then return "That is not your world." end
    local id = U.id("world_" .. r.archetype) .. "/" .. key
    for other in pairs(tdm.online) do
        if W.where[other] == id then W.leave(other, id) end
    end
    W.release_spirits(id)
    if not game.destroy_domain(id) then return "Something still stirs inside; the world will not come apart yet." end
    game.storage.set(record_key(key), nil)
    for _, k in ipairs(game.storage.keys("worldgate:")) do
        if game.storage.get(k) == key then game.storage.set(k, nil) end
    end
    game.give(uuid, { material = U.id("prima_materia"), units = K.returned })
    return "Solve et coagula: the world comes apart, and half its first matter returns to you."
end

tdm.on_use_at({ "tiamat_default_world:crystal" }, function(e)
    if not e.x then return nil end
    local at = U.block_of(e)
    if not W.loom(at.x, at.y, at.z, e.domain) then return nil end
    if not has(e.player, K.node) then return "The Loom is still. You do not know the Opus Mundi." end
    local loom = { x = at.x, y = at.y, z = at.z, domain = e.domain or "overworld" }
    if e.held and e.held.material == REBIS then
        weaving[e.player] = { archetype = "earth", sky = "earth", vein = "none", sea = "mid", loom = loom }
        show(e.player, weave_tree(e.player))
    else
        listing[e.player] = loom
        show(e.player, list_tree(e.player))
    end
    return ""
end)

tdm.on_dialog(FORM, function(e)
    if e.kind == "closed" then weaving[e.player], listing[e.player] = nil, nil return end
    if e.kind ~= "pressed" or not e.name then return end
    local uuid = e.player
    local verb, arg = string.match(e.name, "^(%a+):?(.*)$")
    local s = weaving[uuid]
    if s and verb == "arch" and W.ARCHETYPES[arg] then
        if s.sky == s.archetype then s.sky = arg end
        s.archetype = arg
    elseif s and verb == "sky" and K.skies[arg] and has(uuid, K.skies_node) then
        s.sky = arg
    elseif s and verb == "vein" and (arg == "none" or VEIN[arg]) and has(uuid, K.veins_node) then
        s.vein = arg
    elseif s and verb == "sea" and K.seas[arg] then
        s.sea = arg
    elseif s and verb == "weave" then
        game.chat_to(uuid, weave(uuid))
        return
    elseif verb == "enter" and listing[uuid] then
        local r = W.record(arg)
        if not r then return end
        local ok, why = may_enter(uuid, r)
        if not ok then game.chat_to(uuid, why) return end
        local loom = listing[uuid]
        game.close_dialog{ player = uuid, form = FORM }
        listing[uuid] = nil
        enter(uuid, U.id("world_" .. r.archetype) .. "/" .. arg, { x = loom.x + 0.5, y = loom.y + 1, z = loom.z + 3.5, domain = loom.domain })
        return
    elseif verb == "solve" and listing[uuid] and has(uuid, K.solve_node) then
        game.chat_to(uuid, solve(uuid, arg))
        show(uuid, list_tree(uuid))
        return
    else
        return
    end
    show(uuid, weave_tree(uuid))
end)

tdm.on_leave(function(e) weaving[e.player], listing[e.player] = nil, nil end)

-- The World-Gate ---------------------------------------------------------------------------------

local function gate_key(x, y, z) return string.format("worldgate:%d,%d,%d", x, y, z) end

--- The world a World-Gate at `x, y, z` opens on, if it is one.
function W.gate_of(x, y, z)
    local key = game.storage.get(gate_key(x, y, z))
    return type(key) == "string" and key or nil
end

-- Bound with the Egg, at a correspondence gate's emerald: to the weaver's
-- newest world.
tdm.on_use_at({ "tiamat_default_world:crystal" }, function(e)
    if not (e.x and e.held and e.held.material == EGG) then return nil end
    local at = U.block_of(e)
    if not tdm.cosmos.gate(at.x, at.y, at.z) then return nil end
    if (e.domain or "overworld") ~= "overworld" then return nil end
    if not has(e.player, K.gate_node) then return "You do not know the World-Gate." end
    local worlds = W.worlds_of(e.player)
    if #worlds == 0 then return "You have woven no world for it to open on." end
    game.storage.set(gate_key(at.x, at.y, at.z), worlds[#worlds].key)
    return "The emerald clouds over: the gate opens on your world."
end)

local carried = {}          -- uuid -> the clock tick before which a gate will not carry them again
tdm.on_move(function(e)
    if (e.domain or "overworld") ~= "overworld" then return end
    local key = W.gate_of(e.x, e.y - 1, e.z)
    if not key then return end
    if (carried[e.player] or 0) > tdm.effects.now() then return end
    if not tdm.cosmos.gate(e.x, e.y - 1, e.z) then return end
    local r = W.record(key)
    if not r then return end
    local ok, why = may_enter(e.player, r)
    carried[e.player] = tdm.effects.now() + K.gate_rest
    if not ok then game.chat_to(e.player, why) return end
    enter(e.player, U.id("world_" .. r.archetype) .. "/" .. key, { x = e.x + 0.5, y = e.y, z = e.z + 2.5, domain = "overworld" })
end)

tdm.on_leave(function(e) carried[e.player] = nil end)

--- `magic world allow <name>` / `deny <name>`; `magic leave`.
function W.command(uuid, rest)
    local verb, name = string.match(rest or "", "^(%a+)%s+(.+)$")
    if verb ~= "allow" and verb ~= "deny" then return "magic world allow <name>, or magic world deny <name>" end
    for other, joined in pairs(tdm.online) do
        if joined == name and other ~= uuid then
            game.storage.set(allow_key(uuid, other), verb == "allow" or nil)
            return verb == "allow" and (name .. " may walk in your worlds.") or (name .. " may not.")
        end
    end
    return "Nobody here is called " .. name .. "."
end
function W.leave_command(uuid)
    local domain = W.where[uuid]
    if not W.is_woven(domain) then return "You are not in a woven world." end
    if not W.leave(uuid, domain) then return "The way back will not open." end
    return nil
end

-- Native spirits ---------------------------------------------------------------------------------

local spirits = {}          -- domain -> { [entity] = true }
W.spirit = {}               -- entity -> its domain: the wild spirits of woven worlds

function W.release_spirits(domain)
    for id in pairs(spirits[domain] or {}) do
        game.despawn_entity(id)
        W.spirit[id] = nil
    end
    spirits[domain] = nil
end

local KINDS4 = { "salamander", "undine", "gnome", "sylph" }
local since_spirits = 0
tdm.on_tick(function(dt)
    since_spirits = since_spirits + (math.tointeger(dt) or 1)
    if since_spirits < K.spirit_every then return end
    since_spirits = 0
    for uuid in pairs(tdm.online) do
        local domain = W.where[uuid]
        local w = W.parse(domain)
        local r = w and W.record(w.key)
        if r and has(r.owner, K.spirits_node) then
            local list = spirits[domain] or {}
            spirits[domain] = list
            local body = game.player_entity(uuid)
            local me = body and game.entity(body)
            -- The wild ones already near, adopted: a restart forgets the list,
            -- and the world must not fill up again on every one.
            if me then
                for _, id in ipairs(game.entities_in_radius(me.pos, K.spirit_reach, game.mod_id)) do
                    local e = game.entity(id)
                    if e and not list[id] and type(e.nametag) == "string" and string.sub(e.nametag, 1, 5) == "Wild " then
                        list[id], W.spirit[id] = true, domain
                    end
                end
            end
            local n = 0
            for id in pairs(list) do
                if game.entity(id) then n = n + 1 else list[id], W.spirit[id] = nil, nil end
            end
            if me and n < K.spirits then
                local a = W.ARCHETYPES[r.archetype]
                local kind = a.spirit or KINDS4[(n % #KINDS4) + 1]
                local F = tdm.familiars.KINDS[kind]
                local rng = (n * 7 + 3) % 9 - 4
                local pos = { x = me.pos.x + rng, y = me.pos.y + 1, z = me.pos.z + 4 - rng }
                local id = game.spawn_entity{ pos = pos, model = U.id(F.model.id), health = F.health, speed = F.speed,
                    nametag = "Wild " .. string.lower(F.name), collider = F.collider }
                if id then
                    game.transfer_entity(id, domain, pos)
                    list[id] = true
                    W.spirit[id] = domain
                end
            end
        end
    end
end)

return W
