-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- One of each engine hook for the whole mod, with subscribers.
--
-- The engine keeps ONE callback per hook per mod — two for `on_use`, one
-- listed and one not — and refuses a second. So every file that wants a
-- chat word or a use subscribes here, and this file holds the engine's
-- registrations. They are made at the end of init.lua (`tdm.hooks.install`),
-- once every file has said which blocks it wants to hear used first.

local H = {}

--- Who is here: UUID -> the name they joined with (for a person to type,
--- never to key anything on). The engine has no list of players to ask.
tdm.online = {}

local words = {}
local uses = {}
local listed = {}
local listed_materials = {}
local dialogs = {}
local leaves = {}
local joins = {}
local ticks = {}
local places = {}
local digs = {}
local entity_uses = {}
local dig_starts = {}
local punches = {}
local actions = {}
local moves = {}
local enters = {}

--- Runs `fn(player, rest)` when a player says `word` (case-insensitive),
--- alone or followed by more words. A string `fn` answers is its reply, said
--- to the speaker alone; `false` lets the line through to chat; anything
--- else swallows it.
function tdm.on_chat(word, fn)
    assert(not words[word], "chat word registered twice: " .. word)
    words[word] = fn
end

--- Runs `fn(event)` when a player uses a block, or uses at nothing (`e.x`
--- nil). Answer a string (`""` for silence) to handle it; the first to
--- answer stops the rest.
function tdm.on_use(fn)
    uses[#uses + 1] = fn
end

--- Runs `fn(event)` for a use at one of `materials` (qualified ids), asked
--- BEFORE any mod's unlisted handler: what a block is for comes before what
--- a hand holds. Materials nobody registered are skipped.
function tdm.on_use_at(materials, fn)
    for _, id in ipairs(materials) do
        if tdm.util.material(id) then listed_materials[#listed_materials + 1] = id end
    end
    listed[#listed + 1] = fn
end

--- Runs `fn(event)` when a player presses or releases the qualified action `id`.
function tdm.on_action(id, fn)
    actions[id] = actions[id] or {}
    table.insert(actions[id], fn)
end

--- Runs `fn(event)` when a player's feet cross into another block:
--- `{ player, x, y, z, domain, from? }`.
function tdm.on_move(fn)
    moves[#moves + 1] = fn
end

--- Runs `fn(event)` before a body enters a simulation space:
--- `{ entity, from, to }`. To watch, not to refuse: the answer is ignored.
function tdm.on_domain_enter(fn)
    enters[#enters + 1] = fn
end

--- Runs `fn(event)` for events from the dialog this mod showed as `form`.
function tdm.on_dialog(form, fn)
    dialogs[game.mod_id .. ":" .. form] = fn
end

function tdm.on_leave(fn)
    leaves[#leaves + 1] = fn
end

function tdm.on_join(fn)
    joins[#joins + 1] = fn
end

--- Runs `fn(event)` when a player uses an entity. The first answer that is
--- not nil handles it; nil lets the next mod (and at last the block behind)
--- have it.
function tdm.on_use_entity(fn)
    entity_uses[#entity_uses + 1] = fn
end

--- Runs `fn(event)` when a dig begins: a refusal here reaches the player
--- before they wait out the dig. The first answer that is not nil decides.
function tdm.on_dig_start(fn)
    dig_starts[#dig_starts + 1] = fn
end

--- Runs `fn(event)` when a player punches an entity. The first answer
--- that is not nil decides.
function tdm.on_punch(fn)
    punches[#punches + 1] = fn
end

--- Runs `fn(event)` before a placement. The first answer that is not nil
--- decides (a refusal); nil lets it through to the next.
function tdm.on_place(fn)
    places[#places + 1] = fn
end

--- Runs `fn(event)` when a dig is about to complete. The first answer that
--- is not nil decides: a refusal, or `{ drops = ... }` for what it yields.
--- `first` puts it ahead of the rest: a ward's refusal comes before any
--- say about what the dig yields.
function tdm.on_dig(fn, first)
    if first then table.insert(digs, 1, fn) else digs[#digs + 1] = fn end
end

--- Runs `fn(dt_ticks)` every tick, after everything subscribed before it.
function tdm.on_tick(fn)
    ticks[#ticks + 1] = fn
end

local function first_verdict(list, event)
    for _, fn in ipairs(list) do
        local verdict = fn(event)
        if verdict ~= nil then return verdict end
    end
    return nil
end

--- Makes the engine registrations. Called once, last thing in init.lua.
function H.install()
    game.register_on_chat(function(event)
        local first, rest = string.match(event.text, "^%s*(%S+)%s*(.*)$")
        if first == nil then return end
        local fn = words[string.lower(first)]
        if fn == nil then return end
        local verdict = fn(event.player, rest)
        if verdict == false then return end
        if type(verdict) == "string" and verdict ~= "" then return verdict end
        return false
    end)

    -- `anywhere`: the Mute Book is read wherever its reader looks.
    game.register_on_use(function(event) return first_verdict(uses, event) end, { anywhere = true })
    if #listed_materials > 0 then
        game.register_on_use(function(event) return first_verdict(listed, event) end,
            { materials = listed_materials })
    end

    game.register_on_action(function(event)
        for _, fn in ipairs(actions[event.id] or {}) do fn(event) end
    end)

    if #moves > 0 then
        game.register_on_player_move(function(event)
            for _, fn in ipairs(moves) do fn(event) end
        end)
    end

    if #enters > 0 then
        game.register_on_domain_enter(function(event)
            for _, fn in ipairs(enters) do fn(event) end
        end)
    end

    game.register_on_dialog_event(function(event)
        local fn = dialogs[event.form]
        if fn then fn(event) end
    end)

    game.register_on_player_leave(function(event)
        for _, fn in ipairs(leaves) do fn(event) end
        tdm.online[event.player] = nil
    end)

    game.register_on_player_join(function(event)
        tdm.online[event.player] = event.name or ""
        for _, fn in ipairs(joins) do fn(event) end
    end)

    if #entity_uses > 0 then
        game.register_on_use_entity(function(event) return first_verdict(entity_uses, event) end)
    end

    if #dig_starts > 0 then
        game.register_on_dig_start(function(event) return first_verdict(dig_starts, event) end)
    end
    if #punches > 0 then
        game.register_on_punch(function(event) return first_verdict(punches, event) end)
    end

    if #places > 0 then
        game.register_on_place(function(event) return first_verdict(places, event) end)
    end
    if #digs > 0 then
        game.register_on_dig_complete(function(event) return first_verdict(digs, event) end)
    end

    if #ticks > 0 then
        game.register_on_tick(function(dt)
            for _, fn in ipairs(ticks) do fn(dt) end
        end)
    end
end

return H
