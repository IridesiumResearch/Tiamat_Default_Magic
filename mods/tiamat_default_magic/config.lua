-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- Every number and every table of names this mod turns (brief §18). Nothing
-- else in the mod holds a cost, a count or a duration: retuning is an edit
-- here and nothing else.
--
-- Ids are written short where they are this mod's own (`mortar`), and with
-- a prefix where they are a sibling's: `W:` the world, `L:` Life, `C:`
-- Craft. `util.lua` qualifies both kinds.

local C = {}

-- The Apothecary's Bench (brief §4) ------------------------------------------------
--
-- Five shared nodes, open before the Fork to every player. Their `text` is
-- the first sentence a child reads: under 90 characters, plain words.

C.bench_nodes = {
    {
        id = "shared.mutus_liber", tier = 1, cost = 5, requires = "shared.firecraft",
        label = "The Mute Book",
        text = "A book of pictures that shows you how to make magic things.",
    },
    {
        id = "shared.apothecary", tier = 1, cost = 10, requires = "shared.mutus_liber",
        label = "The Apothecary's Mortar",
        text = "Grind herbs into simples, and make powders that turn fire blue, green and gold.",
    },
    {
        id = "shared.herb_lore", tier = 1, cost = 10, requires = "shared.apothecary",
        label = "Herb Lore",
        text = "Brew herb teas over a campfire in a copper pot, and wrap a healing poultice.",
    },
    {
        id = "shared.foxfire", tier = 2, cost = 20, requires = "shared.apothecary",
        label = "Foxfire",
        text = "Glowing mushrooms sealed in glass make a lamp that never goes out.",
    },
    {
        id = "shared.stillroom", tier = 2, cost = 25, requires = "shared.herb_lore",
        label = "The Stillroom",
        text = "A copper still in the kiln turns roses into rosewater.",
    },
}

-- The Bench's items. `food` is Life's `add_food` spec, for what is drunk or
-- eaten; the rest are tools and ingredients.
C.bench_items = {
    { id = "mutus_liber", name = "The Mute Book", description = "Mutus Liber: a book of alchemy told in pictures. Use it to read." },
    { id = "mortar", name = "Mortar and pestle", description = "Fired clay. Grinds herbs into simples." },
    { id = "simple_chamomile", name = "Ground chamomile", description = "A simple: chamomile flowers, ground." },
    { id = "simple_mint", name = "Ground mint", description = "A simple: mint leaves, ground." },
    { id = "simple_bramble", name = "Ground bramble leaf", description = "A simple: bramble leaves, ground." },
    { id = "simple_mantle", name = "Ground lady's mantle", description = "A simple: lady's mantle, ground. It stops bleeding." },
    { id = "flame_powder_blue", name = "Blue flame powder", description = "Sulfur, ground fine. Put it on a fire." },
    { id = "flame_powder_green", name = "Green flame powder", description = "Copper filings. Put them on a fire." },
    { id = "flame_powder_yellow", name = "Yellow flame powder", description = "Salt, ground fine. Put it on a fire." },
    { id = "flame_powder_white", name = "Spark powder", description = "Bone, ground fine. Put it on a fire." },
    { id = "chamomile_tea", name = "Chamomile tea", description = "Warm and sleepy.",
        food = { food = 1, temperature = "warm", effects = { { "warmth", 1200 }, { "rested", 1200 } }, sound = "drink" } },
    { id = "mint_tea", name = "Mint tea", description = "Cool on a hot day.",
        food = { food = 1, temperature = "cool", effects = { { "cooling", 1200 } }, sound = "drink" } },
    { id = "bramble_tea", name = "Bramble-leaf tea", description = "A little healing.",
        food = { food = 1, heal = 1, sound = "drink" } },
    { id = "poultice", name = "Lady's mantle poultice", description = "Wrap it on a cut.",
        food = { heal = 2, sound = "eat" } },
    { id = "copper_still", name = "Copper still", description = "Put it in a kiln's tool slot to distil." },
    { id = "rosewater", name = "Rosewater", description = "Roses, distilled, as Avicenna did. It heals and soothes.",
        food = { heal = 2, effects = { { "rested", 1200 } }, sound = "drink" } },
    { id = "mint_water", name = "Mint water", description = "Mint, distilled. Cool for a long while.",
        food = { temperature = "cool", effects = { { "cooling", 2400 } }, sound = "drink" } },
}

-- The Bench's one block: light from mushrooms in a jar.
C.hermetic_lamp = {
    id = "hermetic_lamp", name = "Hermetic Lamp",
    description = "Glow caps sealed in glass. It never goes out.",
    hardness = 0.5, light = { r = 6, g = 12, b = 8 }, tags = { "glowing", "glass" },
}

-- The Bench's recipes, into Craft. `node` is the shared node that opens
-- each. A tool with `wear = 0` is used and never worn: nothing a child
-- makes at the Bench breaks.
C.bench_recipes = {
    -- The book, by hand.
    { id = "mutus_liber", station = "hand", node = "shared.mutus_liber",
        inputs = { { "C:leather", count = 1 }, { "C:bark_strip", count = 2 }, { "C:charcoal", count = 1 } },
        outputs = { { "mutus_liber", count = 1 } } },

    -- The mortar, and what it grinds. A tuft of a plant is a few cells of
    -- it, so three units is a handful.
    { id = "mortar", station = "hand", node = "shared.apothecary",
        inputs = { { "C:fired_clay", count = 2 }, { "C:stick", count = 1 } },
        outputs = { { "mortar", count = 1 } } },
    { id = "grind_chamomile", station = "hand", node = "shared.apothecary", tools = { { "mortar", wear = 0 } },
        inputs = { { "W:roman_chamomile", units = 3 } }, outputs = { { "simple_chamomile", count = 1 } } },
    { id = "grind_mint", station = "hand", node = "shared.apothecary", tools = { { "mortar", wear = 0 } },
        inputs = { { "W:wild_mint", units = 3 } }, outputs = { { "simple_mint", count = 1 } } },
    { id = "grind_bramble", station = "hand", node = "shared.apothecary", tools = { { "mortar", wear = 0 } },
        inputs = { { "W:bramble", units = 3 } }, outputs = { { "simple_bramble", count = 1 } } },
    { id = "grind_mantle", station = "hand", node = "shared.apothecary", tools = { { "mortar", wear = 0 } },
        inputs = { { "W:ladys_mantle", units = 3 } }, outputs = { { "simple_mantle", count = 1 } } },

    -- Flame powders.
    { id = "flame_powder_blue", station = "hand", node = "shared.apothecary", tools = { { "mortar", wear = 0 } },
        inputs = { { "W:sulfur", units = 9 } }, outputs = { { "flame_powder_blue", count = 1 } } },
    { id = "flame_powder_green", station = "hand", node = "shared.apothecary", tools = { { "mortar", wear = 0 } },
        inputs = { { "C:copper_ingot", count = 1 } }, outputs = { { "flame_powder_green", count = 3 } } },
    { id = "flame_powder_yellow", station = "hand", node = "shared.apothecary", tools = { { "mortar", wear = 0 } },
        inputs = { { "W:salt", units = 9 } }, outputs = { { "flame_powder_yellow", count = 1 } } },
    { id = "flame_powder_white", station = "hand", node = "shared.apothecary", tools = { { "mortar", wear = 0 } },
        inputs = { { "L:bone", count = 1 } }, outputs = { { "flame_powder_white", count = 2 } } },

    -- Teas, over a campfire in Craft's copper pot (the pot's slot), and a
    -- poultice by hand.
    { id = "chamomile_tea", station = "campfire", node = "shared.herb_lore", ticks = 200,
        tools = { { "C:copper_pot", wear = 0 } },
        inputs = { { "simple_chamomile", count = 1 } }, outputs = { { "chamomile_tea", count = 1 } } },
    { id = "mint_tea", station = "campfire", node = "shared.herb_lore", ticks = 200,
        tools = { { "C:copper_pot", wear = 0 } },
        inputs = { { "simple_mint", count = 1 } }, outputs = { { "mint_tea", count = 1 } } },
    { id = "bramble_tea", station = "campfire", node = "shared.herb_lore", ticks = 200,
        tools = { { "C:copper_pot", wear = 0 } },
        inputs = { { "simple_bramble", count = 1 } }, outputs = { { "bramble_tea", count = 1 } } },
    { id = "poultice", station = "hand", node = "shared.herb_lore",
        inputs = { { "simple_mantle", count = 1 }, { "C:bark_strip", count = 1 } },
        outputs = { { "poultice", count = 1 } } },

    -- The lamp, by hand: a glass and a handful of glow caps.
    { id = "hermetic_lamp", station = "hand", node = "shared.foxfire",
        inputs = { { "C:glass", count = 1 }, { "W:glow_cap", units = 9 } },
        outputs = { { "hermetic_lamp", count = 1 } } },

    -- The still, at the workbench; what it distils, in a kiln burning wood.
    { id = "copper_still", station = "workbench", node = "shared.stillroom",
        inputs = { { "C:copper_pot", count = 1 }, { "C:glass", count = 1 }, { "C:copper_ingot", count = 1 } },
        outputs = { { "copper_still", count = 1 } } },
    { id = "rosewater", station = "kiln", node = "shared.stillroom", heat = 1, ticks = 400,
        tools = { { "copper_still", wear = 0 } },
        inputs = { { "W:rose", count = 1 } }, outputs = { { "rosewater", count = 2 } } },
    { id = "mint_water", station = "kiln", node = "shared.stillroom", heat = 1, ticks = 400,
        tools = { { "copper_still", wear = 0 } },
        inputs = { { "simple_mint", count = 1 } }, outputs = { { "mint_water", count = 2 } } },
}

-- Flame powders on a fire (brief §4). `recipe` is the campfire recipe that
-- burns one: a powder is PUT ON a campfire, as food is, because Craft hears
-- a use at a campfire before any later mod (sibling ask C-M9). At a lit
-- kiln or bloomery, which Craft does not list, it is thrown.
C.flames = {
    blue = { powder = "flame_powder_blue", colour = { r = 0.35, g = 0.55, b = 1.0 }, said = "The fire burns blue!" },
    green = { powder = "flame_powder_green", colour = { r = 0.3, g = 1.0, b = 0.45 }, said = "The fire burns green!" },
    yellow = { powder = "flame_powder_yellow", colour = { r = 1.0, g = 0.85, b = 0.2 }, said = "The fire burns gold!" },
    white = { powder = "flame_powder_white", colour = { r = 1.0, g = 1.0, b = 0.95 }, said = "The fire throws white sparks!", sparks = true },
}
C.flame_ticks = 20                  -- a powder on a campfire flares a second after it goes on
C.flame_particles = 48
C.flame_radius = 32                 -- how far a flare is seen

-- Fires a powder may be thrown at: blocks that are fire while they exist.
C.thrown_at = { "C:kiln_lit", "C:bloomery_lit", "tiamat_weather:fire" }
-- Fires a powder is put on, as food is.
C.put_on = { "C:campfire_lit", "L:campfire" }

-- The door (brief §3) -------------------------------------------------------------
--
-- The Emerald Tablet, the founding text of Hermetic alchemy: green-lit
-- crystal, its letters in verdigris and silver. Progress adds the Keystone
-- to the recipe and requires `shared.keystone`.
C.path = {
    id = "magic",
    label = "The Hermetic Art",
    sentence = "As above, so below. This binds you; the other door closes.",
    refusal = "The letters on the Tablet will not hold still for you.",
    inputs = {
        { "W:crystal", units = 27 },
        { "C:copper_ingot", count = 4 },
        { "C:silver_ingot", count = 2 },
    },
    oath = "magic.hermetic_oath",       -- cost 0, given the moment the door is chosen
    welcome = "You have taken the Oath. Seek the Athanor.",
}

C.emerald_tablet = {
    id = "emerald_tablet", name = "The Emerald Tablet",
    description = "As above, so below. Use it, holding the Keystone's knowledge, to take the Hermetic path.",
    hardness = 2.6, light = { r = 2, g = 9, b = 4 }, tags = { "crystal", "glowing" },
}

-- Toybox discoveries (brief §6.12): insight for play itself.
C.toybox = {
    flame = 3,                      -- each colour of flame, the first time
    lamp = 5,                       -- the first Hermetic Lamp
    distillation = 5,               -- the first thing distilled
}

return C
