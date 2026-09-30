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

local words = {}
local uses = {}
local listed = {}
local listed_materials = {}
local dialogs = {}
local leaves = {}
local joins = {}
local ticks = {}

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

    game.register_on_dialog_event(function(event)
        local fn = dialogs[event.form]
        if fn then fn(event) end
    end)

    game.register_on_player_leave(function(event)
        for _, fn in ipairs(leaves) do fn(event) end
    end)

    game.register_on_player_join(function(event)
        for _, fn in ipairs(joins) do fn(event) end
    end)

    if #ticks > 0 then
        game.register_on_tick(function(dt)
            for _, fn in ipairs(ticks) do fn(dt) end
        end)
    end
end

return H
