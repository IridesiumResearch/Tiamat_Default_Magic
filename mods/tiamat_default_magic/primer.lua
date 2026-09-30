-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The Mute Book (brief §11): the historical *Mutus Liber* (La Rochelle,
-- 1677) is fifteen plates of alchemy and no words, which makes it the right
-- model for a child's recipe book. A page for each node the reader holds or
-- could learn next — never the whole tree at once — and on it, for each
-- thing that node makes, the picture of what comes out and one line of what
-- goes in and where.
--
-- A dialog, not a tab on the interface's screen: a tab is drawn for every
-- player, and the book is only for whoever has one. It opens when the book
-- is used, anywhere, and on `magic book` in chat: the engine's actions,
-- which would give it a key, are inert until its Task 13 (engine ask E-M3).

local C = tdm.config
local U = tdm.util
local A = tdm.apprentice

local P = {}

local FORM = "liber"
local BOOK = U.material(U.id("mutus_liber"))

local ui = U.exports("tiamat_default_ui")
local W = ui and ui.widgets

-- Pictures ride in the dialog's own tree, so they cost none of the
-- server's 512 registered pictures: a content hash is enough.
local pictures = {}
local names = {}            -- this mod's id -> the name a player reads
local function know(id, name)
    names[id] = name
    local ok, hash = pcall(game.content_hash, "textures/" .. id .. ".png")
    if ok then pictures[id] = hash end
end
for _, spec in ipairs(tdm.items.all) do know(spec.id, spec.name) end
know(C.hermetic_lamp.id, C.hermetic_lamp.name)
know(C.athanor.block.id, C.athanor.block.name)

local STATIONS = {
    hand = "by hand",
    workbench = "at a workbench",
    campfire = "on a campfire, in a copper pot",
    kiln = "in a burning kiln",
    athanor = "in the athanor",
    anvil = "struck on an anvil",
}

--- The name a player reads for a config id: this mod's item's own name, or
--- the other mod's id made readable ("W:roman_chamomile" -> "roman chamomile").
local function name_of(id)
    if names[id] then return names[id] end
    local short = string.match(id, "[:#]([^:#]+)$") or id
    return (string.gsub(short, "_", " "))
end

--- What a player reads for a recipe's entry: a carving by its glyph.
local function entry_name(entry)
    if entry.glyph then return "carved " .. name_of(entry.glyph) .. " sign" end
    return name_of(entry[1])
end

local function amount(entry)
    if entry.glyph then return "a " .. entry_name(entry) end
    if entry.count and entry.count > 1 then return entry.count .. " " .. name_of(entry[1]) end
    if entry.units then return "a handful of " .. name_of(entry[1]) end
    return name_of(entry[1])
end

--- One line: "2 fired clay + stick -> Mortar and pestle, by hand".
function P.line(r)
    local parts = {}
    for i, entry in ipairs(r.inputs) do parts[i] = amount(entry) end
    local out = r.outputs[1]
    local tools = {}
    for i, entry in ipairs(r.tools or {}) do tools[i] = entry_name(entry) end
    local with = #tools > 0 and (", with a " .. table.concat(tools, " and ")) or ""
    local where = STATIONS[r.station] or r.station
    if r.degree then where = where .. ", " .. C.degrees[r.degree].name end
    local time = ""
    if r.days then time = r.days == 1 and ", a day" or string.format(", %d days", r.days) end
    return string.format("%s  ->  %s, %s%s%s", table.concat(parts, " + "), amount(out), where, with, time)
end

-- Widgets: the interface's look when it is here, plain ones without it.
-- The interface's come back as read-only views, copied into plain tables
-- before a dialog can carry them (util.plain).
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
local function column(children, gap)
    return { type = "container", direction = "column", children = children, gap = gap or 6, align = "stretch" }
end
local function row(children, size)
    return { type = "container", direction = "row", children = children, gap = 8, size = size, align = "center" }
end

local function recipe_row(r)
    local out = r.outputs[1][1]
    local children = {}
    if pictures[out] then
        children[1] = { type = "image", hash = pictures[out], size = 40, cross_size = 40 }
    end
    children[#children + 1] = text(P.line(r))
    return row(children, 44)
end

--- Every node the book can have a page for: the Bench's, then the path's,
--- each `{ id, cost, requires = { ... }, label, text }`.
local book_nodes = {}
for _, node in ipairs(C.bench_nodes) do
    book_nodes[#book_nodes + 1] = { id = node.id, cost = node.cost, requires = { node.requires },
        label = node.label, text = node.text }
end
for _, node in ipairs(tdm.tree) do
    local requires = {}
    for i, ref in ipairs(node.requires) do
        requires[i] = string.find(ref, ".", 1, true) and ref or ("magic." .. ref)
    end
    book_nodes[#book_nodes + 1] = { id = "magic." .. node.id, cost = node.cost, requires = requires,
        label = node.label, text = node.text }
end

--- Whether the player could learn `node` next: everything it needs is held.
local function next_for(uuid, node)
    for _, ref in ipairs(node.requires) do
        if not A.has(uuid, ref) then return false end
    end
    return true
end

--- The book's pages for a player, as one dialog tree: a page for each node
--- they hold or could learn next, never the whole tree at once.
function P.build(uuid)
    local pages = { label("The Mute Book", 22) }
    local shown = 0
    for _, node in ipairs(book_nodes) do
        local held = A.has(uuid, node.id)
        if held or next_for(uuid, node) then
            shown = shown + 1
            local page = { label(node.label, 18), text(node.text) }
            if held then
                for _, r in ipairs(tdm.recipes.by_node[node.id] or {}) do
                    page[#page + 1] = recipe_row(r)
                end
                if C.book_notes[node.id] then page[#page + 1] = text(C.book_notes[node.id]) end
            else
                page[#page + 1] = hint(string.format("Learn it at the research table for %d insight.", node.cost))
            end
            pages[#pages + 1] = column(page, 4)
        end
    end
    if shown == 0 then
        pages[#pages + 1] = text("The pages are blank. Light your first fire, and they will fill.")
    end
    return column({ { type = "scroll", grow = 1, children = { column(pages, 14) } } }, 0)
end

local open = {}

--- Opens the book for a player.
function P.open(uuid)
    open[uuid] = true
    game.show_dialog{ player = uuid, form = FORM, tree = P.build(uuid) }
end

--- Whether a player carries a Mute Book.
function P.carries(uuid)
    if not BOOK then return false end
    for _, view in ipairs({ "player:hotbar", "player:main" }) do
        for _, stack in ipairs(game.inventory(uuid, view) or {}) do
            if stack.material == BOOK then return true end
        end
    end
    return false
end

-- Using the book, at a block or at nothing, opens it.
tdm.on_use(function(e)
    if not (e.held and e.held.material == BOOK) then return nil end
    P.open(e.player)
    return ""
end)

tdm.on_dialog(FORM, function(e)
    if e.kind == "closed" then open[e.player] = nil end
end)

tdm.on_leave(function(e)
    open[e.player] = nil
end)

return P
