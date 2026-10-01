-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The Tree of Diana (brief §7.4): the Arbor Dianae of the old laboratories,
-- a tree of silver crystals grown from silver amalgam in aqua fortis. A
-- small, visible, lovable silver farm.
--
-- A seed is planted by using it on the ground: one cell of the block above,
-- at the bottom of its middle. Watered with aqua fortis it grows, a cell
-- every `every` ticks for as long as the watering lasts, trunk first and
-- then branches (`order`), until the block is whole. It is one block, and
-- the engine pays its silver when it is dug, by the share of the block it
-- fills: a full tree is an ingot.
--
-- Nothing scans the world: each tree is a key, `tree:x,y,z` (its cells,
-- and who planted it) with `treefed:x,y,z` (the tick its watering ends),
-- read once into a list; each pass grows at most `budget` of them. A tree
-- dug, or found no longer to be a tree, is forgotten. Trees are the
-- overworld's: the engine's use and dig events name the block, and this
-- mod plants where they say.

local C = tdm.config
local U = tdm.util
local E = tdm.effects

local T = {}

local A = C.arbor
local progress = U.exports("tiamat_default_progress")

local drops = {}
for id, units in pairs(A.drops) do drops[U.id(id)] = units end

T.block = game.register_block{
    id = A.block.id,
    name = A.block.name,
    description = A.block.description,
    hardness = A.block.hardness,
    tags = A.block.tags,
    light_emit = A.block.light,
    cutout = true,
    drops = drops,
    textures = { all = "textures/" .. A.block.id .. ".png" },
}

local TREE = U.id(A.block.id)
local SEED = U.material(U.id(A.seed.id))
local WATER = U.material(U.id(A.water))
local GROWN = game.mod_id .. ".tree_of_diana"

tdm.recipes.register_all(C.arbor_recipes)
if progress then
    progress.register_discovery{ id = GROWN, insight = A.discovery, label = "A Tree of Diana, grown", group = "toybox" }
end

--- The mask of a tree of `cells` cells.
function T.mask(cells)
    local m = 0
    for i = 1, cells do m = m | (1 << A.order[i]) end
    return m
end

local function key(x, y, z) return string.format("tree:%d,%d,%d", x, y, z) end
local function fed_key(x, y, z) return string.format("treefed:%d,%d,%d", x, y, z) end

-- The trees, read once from storage, kept in step after.
local trees = nil           -- key -> { x, y, z, cells, by }
local order = {}            -- keys, in the order found or planted

local function decode(v)
    local cells, by = string.match(v or "", "^(%d+);(%x*)$")
    return tonumber(cells), by
end

local function all()
    if trees then return trees end
    trees = {}
    for _, k in ipairs(game.storage.keys("tree:")) do
        local x, y, z = string.match(k, "^tree:(%-?%d+),(%-?%d+),(%-?%d+)$")
        local cells, by = decode(game.storage.get(k))
        if x and cells then
            trees[k] = { x = math.tointeger(tonumber(x)), y = math.tointeger(tonumber(y)), z = math.tointeger(tonumber(z)),
                cells = math.tointeger(cells), by = by }
            order[#order + 1] = k
        end
    end
    table.sort(order)
    return trees
end

local function save(t)
    game.storage.set(key(t.x, t.y, t.z), string.format("%d;%s", t.cells, t.by or ""))
end

local function forget(k)
    local t = all()[k]
    if not t then return end
    trees[k] = nil
    game.storage.set(k, nil)
    game.storage.set(fed_key(t.x, t.y, t.z), nil)
    for i, other in ipairs(order) do
        if other == k then table.remove(order, i) break end
    end
end

local function planted_by(uuid)
    local n = 0
    for _, t in pairs(all()) do
        if t.by == uuid then n = n + 1 end
    end
    return n
end

local function sparkle(t, count)
    game.emit_particles{ pos = { x = t.x + 0.5, y = t.y + 0.5, z = t.z + 0.5 }, count = count,
        colour = { r = 0.85, g = 0.9, b = 1.0 }, size = 0.08, lifetime = 1, spread = 0.6,
        area = { x = 0.4, y = 0.4, z = 0.4 }, collide = false }
end

-- Planting and watering -------------------------------------------------------------------

tdm.on_use(function(e)
    if not (e.x and e.held) then return nil end
    local held = e.held.material
    if held == SEED then
        if not (progress and progress.has(e.player, A.node)) then return "You do not know how to grow the Tree of Diana." end
        local below = U.block_of(e)
        local at = { x = below.x, y = below.y + 1, z = below.z }
        local there = game.get_block(at)
        if there and there.occupancy ~= 0 then return "There is no room above that for a tree." end
        if planted_by(e.player) >= A.per_player then return "You have as many trees as you can tend." end
        if game.take(e.player, { material = SEED, count = 1 }) < U.UNITS then return "" end
        game.set_block(at, TREE, T.mask(1))
        local t = { x = at.x, y = at.y, z = at.z, cells = 1, by = e.player }
        all()[key(at.x, at.y, at.z)] = t
        order[#order + 1] = key(at.x, at.y, at.z)
        save(t)
        sparkle(t, 8)
        return ""
    elseif held == WATER then
        local pos = U.block_of(e)
        local t = all()[key(pos.x, pos.y, pos.z)]
        if not t then return nil end
        if game.take(e.player, { material = WATER, count = 1 }) < U.UNITS then return "" end
        game.storage.set(fed_key(t.x, t.y, t.z), E.now() + A.fed_ticks)
        sparkle(t, 16)
        return ""
    end
    return nil
end)

tdm.on_dig(function(e)
    local k = key(e.x // 3, e.y // 3, e.z // 3)
    if all()[k] then forget(k) end
    return nil
end)

-- The Rose Garden ------------------------------------------------------------------------------
--
-- A tree grown whole, with a Venus sigil `reach` blocks off on each of its
-- four sides, set by an adept who knows the Rosarium: every `every` ticks a
-- wild flower blooms on an empty patch of grass round it (brief §7.3).

local RS = C.rosarium
local GRASS = U.material(U.id("W:grass"))
local FLOWERS = {}
for _, id in ipairs(RS.flowers) do
    if U.material(U.id(id)) then FLOWERS[#FLOWERS + 1] = U.id(id) end
end
local BLOOM = 0
for _, cell in ipairs(RS.cells) do BLOOM = BLOOM | (1 << cell) end

local function venus_at(x, y, z)
    local b = game.get_block{ x = x, y = y, z = z }
    local g = b and b.occupancy and tdm.glyphs.of(b.occupancy)
    return g and g.id == "venus", b
end

--- Whether the grown tree `t` stands in a Rose Garden: answers its gardener.
local function garden(t)
    local r = RS.reach
    local gardener = nil
    for _, d in ipairs({ { r, 0 }, { -r, 0 }, { 0, r }, { 0, -r } }) do
        local x, z = t.x + d[1], t.z + d[2]
        if not venus_at(x, t.y, z) then return nil end
        gardener = gardener or tdm.sigils.setter(x, t.y, z)
    end
    if gardener and progress and progress.has(gardener, RS.node) then return gardener end
    return nil
end

local bloomed = 0
local function bloom(t, now)
    if #FLOWERS == 0 or not GRASS or not garden(t) then return end
    local rng = game.rng_stream({ x = t.x, y = t.y, z = t.z, seed = game.world_seed or 0 }, "rosarium" .. now)
    local r = RS.reach - 1
    for _ = 1, 4 do
        local x, z = t.x - r + rng:below(2 * r + 1), t.z - r + rng:below(2 * r + 1)
        local ground = game.get_block{ x = x, y = t.y - 1, z = z }
        local above = game.get_block{ x = x, y = t.y, z = z }
        if ground and ground.material == GRASS and above and above.occupancy == 0 then
            game.set_block({ x = x, y = t.y, z = z }, FLOWERS[rng:below(#FLOWERS) + 1], BLOOM)
            return
        end
    end
end

tdm.on_tick(function(dt)
    bloomed = bloomed + (math.tointeger(dt) or 1)
    if bloomed < RS.every then return end
    bloomed = 0
    local now = E.now()
    all()
    for _, k in ipairs(order) do
        local t = trees[k]
        if t and t.cells == #A.order then bloom(t, now) end
    end
end)

-- Growing ---------------------------------------------------------------------------------------

local MATERIAL = U.material(TREE)
local elapsed, cursor = 0, 0
tdm.on_tick(function(dt)
    elapsed = elapsed + (math.tointeger(dt) or 1)
    if elapsed < A.every then return end
    elapsed = 0
    all()
    local count = #order
    if count == 0 then return end
    local now = E.now()
    for _ = 1, math.min(count, A.budget) do
        cursor = cursor % #order + 1
        local k = order[cursor]
        local t = k and trees[k]
        if t then
            local at = game.get_block{ x = t.x, y = t.y, z = t.z }
            if at and at.material ~= MATERIAL and at.occupancy ~= 0 then
                forget(k)                                   -- something else is there now
            elseif at and at.material == MATERIAL and t.cells < #A.order then
                local fed = game.storage.get(fed_key(t.x, t.y, t.z))
                if type(fed) == "number" and fed > now then
                    t.cells = t.cells + 1
                    game.set_block({ x = t.x, y = t.y, z = t.z }, TREE, T.mask(t.cells))
                    save(t)
                    sparkle(t, 6)
                    if t.cells == #A.order and progress and t.by and t.by ~= "" then
                        progress.discover(t.by, GROWN)
                    end
                end
            end
        end
    end
end)

return T
