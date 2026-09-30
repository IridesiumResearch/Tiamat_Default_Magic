-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The magic path: the door (brief §3) and the tree (§5), into Progress.
--
-- Progress owns the graph, the insight and the lock: this file registers
-- into it and keeps no second copy of who chose what. A path node is `false`
-- to every player of the other path, and "lies beyond the Fork" to a player
-- with none, whatever this mod does.
--
-- Choosing the Emerald Tablet gives the Oath, free, and the Mute Book to a
-- player who has none. `on_choose` also runs when a player repaths INTO
-- magic, which is right: the Oath went with the old path and comes back.
-- Repathing away needs nothing from this mod yet — Progress takes the path's
-- nodes itself, and nothing the Art has built so far belongs to a player.
-- The Quintessence bar is set here once there is one (brief §6.8, waiting
-- on the decision about sibling ask L-M1).

local C = tdm.config
local U = tdm.util
local P = tdm.primer

local T = {}

local progress = U.exports("tiamat_default_progress")

T.nodes = tdm.tree               -- the data; tools/check_tree.py reads the same file

-- The nodes that ship: every one up to the tier whose Art is built. The
-- rest of the tree is held back, not shown with nothing behind it.
T.shipped = {}
for _, node in ipairs(T.nodes) do
    if node.tier <= C.built_tier then T.shipped[#T.shipped + 1] = node end
end

--- A node reference from tree.lua, qualified: bare names are `magic.` nodes.
local function node_id(ref)
    return string.find(ref, ".", 1, true) and ref or ("magic." .. ref)
end

local BOOK = U.id("mutus_liber")

--- A player has just taken the Hermetic path.
function T.on_choose(uuid)
    local ok, why = progress.unlock(uuid, C.path.oath)
    if not ok and not progress.has(uuid, C.path.oath) then
        game.log("tiamat_default_magic: the Oath was refused: " .. tostring(why))
    end
    if not P.carries(uuid) then
        game.give(uuid, { material = BOOK, count = 1 })
    end
    game.chat_to(uuid, C.path.welcome)
end

if progress then
    local inputs = {}
    for i, entry in ipairs(C.path.inputs) do
        inputs[i] = { U.id(entry[1]), count = entry.count, units = entry.units }
    end
    local ok, why = progress.register_path{
        id = C.path.id,
        label = C.path.label,
        door = U.id(C.emerald_tablet.id),
        recipe = { inputs = inputs },
        sentence = C.path.sentence,
        refusal = C.path.refusal,
        on_choose = function(uuid) T.on_choose(uuid) end,
    }
    if not ok then game.log("tiamat_default_magic: Progress refused the path: " .. tostring(why)) end

    for _, node in ipairs(T.shipped) do
        local requires = {}
        for i, ref in ipairs(node.requires) do requires[i] = node_id(ref) end
        local effects = nil
        if node.effects then
            effects = {}
            for i, fx in ipairs(node.effects) do effects[i] = { fx[1], fx[2] } end
        end
        local added, refused = progress.register_node{
            id = node_id(node.id), tier = node.tier, cost = node.cost, requires = requires,
            label = node.label, text = node.text, effects = effects,
        }
        if not added then
            game.log("tiamat_default_magic: Progress refused " .. node.id .. ": " .. tostring(refused))
        end
    end
end

return T
