-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Two screens of the adept's own (brief §10.3).
--
-- **Familiars**: each bound familiar, whether it walks or rests, the
-- essences it has taken, and what it carries; a button sends one to rest
-- or calls it to walk, and the homunculus's opens its satchel. On its key
-- (L, unless the player moved it) and on `magic familiars` in chat. A
-- dialog, not a tab on the interface's screen, for the Mute Book's reason:
-- a tab is drawn for every player, and this is only for an adept.
--
-- **The athanor's dial**: the colour stage of the work an athanor holds,
-- and what the texts say of it, on `magic athanor` while looking at one.
-- The brief wants it as a tab beside Craft's station screen, and the time
-- the work has left; Craft has no tab for another mod there and keeps a
-- furnace's job to itself (C-M11). So the work is told here by what the
-- athanor holds, as Craft would choose it — the most particular recipe the
-- player knows whose inputs and vessels are all in place — and the time is
-- the work's whole length, not what is left of it.

local C = tdm.config
local U = tdm.util
local F = tdm.familiars

local S = {}

local ui = U.exports("tiamat_default_ui")
local craft = U.exports("tiamat_default_craft")
local progress = U.exports("tiamat_default_progress")
local W = ui and ui.widgets

-- Widgets: the interface's look when it is here, plain ones without it.
local function label(text, size)
    if W then return U.plain(W.label(text, size)) end
    return { type = "label", text = text, style = { text_size = size or 17 } }
end
local function text(t)
    if W then return U.plain(W.text(t)) end
    return { type = "label", text = t, style = { text_size = 15 } }
end
local function hint(t)
    if W then return U.plain(W.hint(t)) end
    return { type = "label", text = t, style = { text_size = 13 } }
end
local function button(name, t)
    if W then return U.plain(W.button(name, t, true)) end
    return { type = "button", name = name, text = t }
end
local function column(children, gap)
    return { type = "container", direction = "column", children = children, gap = gap or 6, align = "stretch" }
end
local function row(children, size)
    return { type = "container", direction = "row", children = children, gap = 8, size = size, align = "center" }
end

local names = {}            -- this mod's item id -> the name a player reads
for _, spec in ipairs(tdm.items.all) do names[spec.id] = spec.name end

--- The name a player reads for a config id.
local function name_of(id)
    if names[id] then return names[id] end
    local short = string.match(id, "[:#]([^:#]+)$") or id
    return (string.gsub(short, "_", " "))
end

-- Familiars ------------------------------------------------------------------------------------

local FAMILIARS = "familiars"

--- One familiar's lines and buttons.
local function familiar_rows(uuid, f)
    local K = F.KINDS[f.kind]
    local state = f.walking and "walks with you" or "rests"
    if f.walking and not F.seen() then state = state .. ", seen only as a shadow by day" end
    local body = f.entity and game.entity(f.entity)
    if body and body.health then state = state .. string.format("; health %d", math.tointeger(body.health) or 0) end
    local buttons = { label(K.name, 18) }
    if f.walking then
        buttons[#buttons + 1] = button("rest:" .. f.kind, "Rest")
    else
        buttons[#buttons + 1] = button("walk:" .. f.kind, "Walk")
    end
    if f.kind == "homunculus" then buttons[#buttons + 1] = button("satchel", "Satchel") end
    local lines = { row(buttons, 36), text("It " .. state .. ".") }
    local taken = tdm.essences and tdm.essences.taken(uuid, f.kind) or {}
    if #taken > 0 then
        local kinds = {}
        for i, kind in ipairs(taken) do kinds[i] = (string.gsub(kind, "_", " ")) end
        lines[#lines + 1] = hint(string.format("Essences: %s (%d of %d).", table.concat(kinds, ", "), #taken,
            C.essences.slots))
    end
    if f.kind == "undine" then
        lines[#lines + 1] = hint(string.format("It carries %d of %d blocks of water.", F.carried(uuid), C.undine.carry))
    end
    return column(lines, 2)
end

--- The Familiars screen for a player, as one dialog tree.
function S.familiars(uuid)
    local list = F.list(uuid)
    local walking = 0
    for _, f in ipairs(list) do
        if f.walking then walking = walking + 1 end
    end
    local rows = { label("Familiars", 22) }
    if #list == 0 then
        rows[#rows + 1] = text("You have no familiar. The Mute Book says where each is found, and what binds it.")
    else
        rows[#rows + 1] = text(string.format("%d may walk with you at once; %d %s now.", F.cap(uuid), walking,
            walking == 1 and "walks" or "walk"))
        for _, f in ipairs(list) do rows[#rows + 1] = familiar_rows(uuid, f) end
    end
    return column({ { type = "scroll", grow = 1, children = { column(rows, 12) } } }, 0)
end

--- Opens the Familiars screen for a player.
function S.open_familiars(uuid)
    game.show_dialog{ player = uuid, form = FAMILIARS, tree = S.familiars(uuid) }
end

game.register_action{ id = "familiars", default_key = C.familiars_screen_key, description = "Your familiars" }

tdm.on_action(game.mod_id .. ":familiars", function(e)
    if e.pressed and U.adept(e.player) then S.open_familiars(e.player) end
end)

tdm.on_dialog(FAMILIARS, function(e)
    if e.kind ~= "pressed" or not e.name then return end
    local uuid = e.player
    local verb, kind = string.match(e.name, "^(%a+):?(.*)$")
    local bound = false
    for _, f in ipairs(F.list(uuid)) do
        if f.kind == kind then bound = true end
    end
    if verb == "walk" and bound then
        F.walk(uuid, kind)
    elseif verb == "rest" and bound then
        F.rest(uuid, kind)
    elseif verb == "satchel" then
        game.close_dialog{ player = uuid, form = FAMILIARS }
        local said = F.satchel(uuid)
        if said ~= "" then game.chat_to(uuid, said) end
        return
    else
        return
    end
    game.update_dialog{ player = uuid, form = FAMILIARS, tree = S.familiars(uuid) }
end)

-- The athanor's dial -----------------------------------------------------------------------------

local DIAL = "athanor"
local D = C.dial
local A = C.athanor
local STATION = U.id(A.station)
local COLD = U.material(U.id(A.block.id))
local LIT = U.material(U.id(A.lit.id))

--- Every work of the athanor, as `{ id, r, inputs, tools, weight }`: what
--- must stand in its input and vessel slots, qualified, a bath for its
--- degree among the vessels — as recipes.lua gives it to Craft.
local works = nil
local function all_works()
    if works then return works end
    works = {}
    for id, r in pairs(tdm.recipes.by_id) do
        if r.station == "athanor" then
            local inputs, tools, carved = {}, {}, false
            for _, entry in ipairs(r.inputs or {}) do
                if entry.glyph then carved = true break end
                inputs[#inputs + 1] = { id = U.id(entry[1]), units = entry.units or (entry.count or 1) * U.UNITS }
            end
            for _, entry in ipairs(r.tools or {}) do
                if entry.glyph then carved = true break end
                tools[#tools + 1] = U.id(entry[1])
            end
            local degree = r.degree and C.degrees[r.degree]
            if degree and degree.bath then tools[#tools + 1] = U.id(degree.bath) end
            -- A carving is told by its shape, which a slot's stack does not
            -- say plainly: those few works are left to Craft's own screen.
            if not carved then
                works[#works + 1] = { id = id, r = r, inputs = inputs, tools = tools, weight = #inputs + #tools }
            end
        end
    end
    table.sort(works, function(a, b)
        if a.weight ~= b.weight then return a.weight > b.weight end
        return a.id < b.id
    end)
    return works
end

--- Whether a stack's material is `id`: itself, or a member of the group `id` names.
local function is(material, id)
    local name = game.block_of(material)
    if not name then return false end
    if string.sub(id, 1, 1) == "#" then return craft ~= nil and craft.in_group(id, name) == true end
    return name == id
end

--- What an athanor's container holds, as `{ input = { stacks }, tool = { stacks }, fuel = units }`.
local function contents(name)
    local ok, stacks = pcall(game.container, name)
    local held = { input = {}, tool = {}, fuel = 0 }
    for _, stack in ipairs(ok and stacks or {}) do
        if stack.slot == A.slots.fuel then held.fuel = stack.units
        elseif stack.slot >= A.slots.input.from and stack.slot <= A.slots.input.to then held.input[#held.input + 1] = stack
        elseif stack.slot >= A.slots.tool.from and stack.slot <= A.slots.tool.to then held.tool[#held.tool + 1] = stack end
    end
    return held
end

local function enough(stacks, id, units)
    local have = 0
    for _, stack in ipairs(stacks) do
        if stack.shape == nil and is(stack.material, id) then have = have + stack.units end
    end
    return have >= units
end

--- The work an athanor holds for a player: the most particular they know
--- whose inputs and vessels are all in place, or nil.
function S.work_in(uuid, name)
    local held = contents(name)
    for _, w in ipairs(all_works()) do
        local known = w.r.node == nil or (progress ~= nil and progress.has(uuid, w.r.node) == true)
        local ready = known
        for _, need in ipairs(w.inputs) do
            ready = ready and enough(held.input, need.id, need.units)
        end
        for _, tool in ipairs(w.tools) do
            ready = ready and enough(held.tool, tool, 1)
        end
        if ready then return w, held end
    end
    return nil, held
end

--- "3 philosophical days (4½ minutes)".
local function length(days)
    local halves = days * C.philosophical_day * 2 // 1200
    local minutes = halves // 2 .. (halves % 2 == 1 and "½" or "")
    if days == 1 then return string.format("a philosophical day (%s minutes)", minutes) end
    return string.format("%d philosophical days (%s minutes)", days, minutes)
end

--- The colour swatch of a stage.
local function swatch(colour)
    return { type = "container", direction = "row", size = 56, cross_size = 28, children = {},
        style = { background = colour, border = { 0, 0, 0 } } }
end

--- The dial of the athanor whose container is `name`, as one dialog tree.
function S.dial(uuid, name, pos)
    local at = game.get_block(pos)
    local burning = at ~= nil and at.material == LIT
    local w, held = S.work_in(uuid, name)
    local rows = { label("The Athanor", 22) }
    local fuel = held.fuel // U.UNITS
    rows[#rows + 1] = text((burning and "Its fire burns" or "It is cold") ..
        (fuel > 0 and string.format(", with %d %s of fuel by it.", fuel, fuel == 1 and "block" or "blocks") or ", and nothing to burn."))
    if not w then
        rows[#rows + 1] = text(D.idle)
    else
        local short = string.match(w.id, ":(.+)$") or w.id
        local stage = D.stages[D.by_recipe[short] or ""]
        local by_degree = w.r.degree and D.degrees[w.r.degree]
        local colour = (stage and stage.colour) or (by_degree and by_degree.colour) or { 150, 110, 70 }
        local heading = stage and stage.name or name_of(w.r.outputs[1][1])
        rows[#rows + 1] = row({ swatch(colour), label(heading, 18) }, 36)
        rows[#rows + 1] = text(D.said[short] or (stage and stage.said) or (by_degree and by_degree.said) or "")
        local made = name_of(w.r.outputs[1][1])
        local time = w.r.days and length(w.r.days) or nil
        rows[#rows + 1] = hint(string.format("The work: %s%s.", w.r.name or made, time and (", " .. time) or ""))
        if not burning then rows[#rows + 1] = hint("Light it, and the work begins.") end
    end
    rows[#rows + 1] = row({ button("again", "Look again") }, 36)
    return column(rows, 8)
end

local dials = {}            -- uuid -> { name, pos } of the athanor they are reading

--- `magic athanor`: the dial of the athanor a player is looking at.
function S.athanor_command(uuid)
    local at = game.looking_at(uuid)
    if not (at and at.material and (at.material == COLD or at.material == LIT)) then
        return "Look at an athanor, and say it again."
    end
    local pos = { x = at.x // 3, y = at.y // 3, z = at.z // 3, domain = at.domain }
    local where = string.format("%d,%d,%d", pos.x, pos.y, pos.z)
    if pos.domain and pos.domain ~= "overworld" then where = pos.domain .. "@" .. where end
    local name = "tiamat_default_craft:" .. STATION .. ":" .. where
    dials[uuid] = { name = name, pos = pos }
    game.show_dialog{ player = uuid, form = DIAL, tree = S.dial(uuid, name, pos) }
    return nil
end

tdm.on_dialog(DIAL, function(e)
    if e.kind == "closed" then dials[e.player] = nil return end
    local d = dials[e.player]
    if e.kind ~= "pressed" or e.name ~= "again" or not d then return end
    game.update_dialog{ player = e.player, form = DIAL, tree = S.dial(e.player, d.name, d.pos) }
end)

tdm.on_leave(function(e)
    dials[e.player] = nil
end)

return S
