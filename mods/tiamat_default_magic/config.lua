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

-- The Mute Book's key, which a player may move in the settings screen.
C.book_key = "KeyJ"
-- The familiars' key: each press calls the next bound familiar to walk.
C.familiar_key = "KeyK"

-- The Bench's one block: light from mushrooms in a jar.
C.hermetic_lamp = {
    id = "hermetic_lamp", name = "Hermetic Lamp",
    description = "Glow caps sealed in glass. It never goes out.",
    hardness = 0.5, light = { r = 6, g = 12, b = 8 }, tags = { "glowing", "glass" },
    -- One piece: a jar is lifted whole, never chipped away a cell at a time,
    -- and nothing is carved into it. Still a glass cube, so no model: a
    -- model has no faces for glass to be.
    whole = true,
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

-- Time (brief §6.1) ----------------------------------------------------------------
--
-- A philosophical day is ninety seconds: exactly one block of coal's burn
-- (Craft's 1,800 ticks). The historical counts stand, and the forty-day Red
-- Stone is 72,000 ticks, Craft's `max_ticks` to the tick, so every long
-- work is one recipe. Nothing reads these yet; the athanor will.
C.philosophical_day = 1800
C.long_works = {                    -- in philosophical days
    nigredo = 3,                    -- Gate V, the Raven's Head
    white_stone = 7,
    red_stone = 40,
    homunculus = 40,
    multiplication = 7,
}

-- The door (brief §3) -------------------------------------------------------------
--
-- The Emerald Tablet, the founding text of Hermetic alchemy: green-lit
-- crystal, its letters in verdigris and silver. Progress adds the Keystone
-- to the recipe and requires `shared.keystone`.
-- The release gate: the highest tier whose Art is built. Nodes above it are
-- not registered with Progress, so nobody meets a node that does nothing;
-- raised a tier at a time as each lands (docs/brief.md §17).
C.built_tier = 7

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
    -- The Research tab groups each tier by branch under these names, and
    -- shows a node only once all but one of its requirements are held: the
    -- frontier and the step past it, not ninety-seven tiles (Progress's
    -- answer to P-M1).
    branches = {
        GATE = "The Twelve Gates", FIRE = "Vessels and Fire", MENS = "Menstrua", PLAN = "The Seven Metals",
        SPAG = "Spagyrics", ELEM = "Elementals", SIGN = "Sigils and Seals", OPUS = "The Stones", COSM = "Worlds",
    },
    reveal = "near",
}

C.emerald_tablet = {
    id = "emerald_tablet", name = "The Emerald Tablet",
    description = "As above, so below. Use it, holding the Keystone's knowledge, to take the Hermetic path.",
    hardness = 2.6, light = { r = 2, g = 9, b = 4 }, tags = { "crystal", "glowing" },
    -- Drawn as a standing tablet on its plinth, and so whole: it comes up in
    -- one piece. The world knows the plinth and the slab (a wall across the
    -- middle row), which is what a player walks against and aims at.
    model = { id = "emerald_tablet", file = "models/emerald_tablet.glb", texture = "models/emerald_tablet.png" },
    shape = { "### ### ###", "... ### ...", "... ### ..." },
}

-- Toybox discoveries (brief §6.12): insight for play itself.
C.toybox = {
    flame = 3,                      -- each colour of flame, the first time
    lamp = 5,                       -- the first Hermetic Lamp
    distillation = 5,               -- the first thing distilled
}

-- The athanor (brief §6.1) ---------------------------------------------------------
--
-- "The philosophers' oven": a tower furnace built to hold a low, even heat.
-- One Craft station that burns and works on its own; the vessels in its two
-- tool slots turn it into every apparatus, and cost no blocks.
C.athanor = {
    station = "athanor",                                -- qualified: tiamat_default_magic:athanor
    name = "Athanor",
    -- Both are drawn as the tower (its mouth dark, or burning) and so are
    -- whole: the furnace is lifted in one piece, and a chisel cannot take
    -- a corner off it. The world knows the tower and the dome over it.
    block = { id = "athanor", name = "Athanor", description = "The philosophers' furnace: a slow tower fire. Light it with a striker.",
        hardness = 2.0, tags = { "stone", "hard" },
        model = { id = "athanor", file = "models/athanor.glb", texture = "models/athanor.png" },
        shape = { "### ### ###", "### ### ###", ".#. ### .#." } },
    lit = { id = "athanor_lit", name = "Athanor (burning)", description = "A slow fire, held even for days.",
        hardness = 2.0, tags = { "stone", "hard", "glowing" }, light = { r = 12, g = 7, b = 2 },
        model = { id = "athanor_lit", file = "models/athanor_lit.glb", texture = "models/athanor_lit.png" },
        shape = { "### ### ###", "### ### ###", ".#. ### .#." } },
    slots = { fuel = 1, input = { from = 2, to = 4 }, tool = { from = 5, to = 6 }, output = { from = 7, to = 9 } },
    blast = "#magic_blast",                             -- what blows the 4th degree: Craft's bellows (and, one day, a salamander's ember)
    blast_members = { "C:bellows", "salamander_ember" },
    blast_heat = 4,
    refuse_fuel = "The athanor wants a slow fire: wood, charcoal or coal.",
    contact_fire = { damage = 1, ticks = 20, after = 20 },
    warmth = 0.8,
}

-- The four degrees of fire: a heat the athanor must burn at, and the bath
-- that must stand in a vessel slot. The 4th has no bath: it is heat 4,
-- which only a blast in a vessel slot reaches.
C.degrees = {
    { heat = 1, bath = "bain_marie", name = "in Maria's bath (1st degree)" },
    { heat = 1, bath = "ash_bath", name = "in the ash bath (2nd degree)" },
    { heat = 2, bath = "sand_bath", name = "in the sand bath, on coal or charcoal (3rd degree)" },
    { heat = 4, name = "at naked fire, bellows blowing (4th degree)" },
}

-- Tier 3's items (brief §9). `look` is the placeholder picture's kind, which
-- tools/make_textures.py draws.
C.lab_items = {
    -- Vessels, and the pipe that blows them.
    { id = "blowpipe", name = "Blowpipe", description = "An iron pipe. In a kiln's tool slot, it blows glass into vessels." },
    { id = "phial", name = "Phial", description = "A little glass bottle. Every elixir is drunk from one." },
    { id = "alembic", name = "Alembic", description = "The still: a cucurbit, its head and a receiver. Distils, in the athanor." },
    { id = "retort", name = "Retort", description = "A glass retort, for distilling what is dry." },
    { id = "bain_marie", name = "Maria's bath", description = "A copper pot of water: the 1st degree of fire, a heat that never scorches." },
    { id = "ash_bath", name = "Ash bath", description = "A clay dish of ash: the 2nd degree of fire." },
    { id = "sand_bath", name = "Sand bath", description = "A clay dish of sand: the 3rd degree of fire, on coal or charcoal." },
    { id = "cupel", name = "Cupel", description = "A little cup of bone ash. Lead melted in it leaves its silver behind." },
    -- Gate I: calxes, and what the cupel leaves.
    { id = "litharge", name = "Litharge", description = "Lead, roasted: a yellow calx." },
    { id = "minium", name = "Minium", description = "Litharge, roasted longer: red lead." },
    { id = "putty", name = "Putty of tin", description = "Tin, roasted: a white calx." },
    { id = "aes_ustum", name = "Aes ustum", description = "Burnt copper: a black calx." },
    { id = "crocus_martis", name = "Crocus martis", description = "Iron rust, roasted golden-red." },
    { id = "bone_ash", name = "Bone ash", description = "Bone, burnt white. Cupels are made of it." },
    { id = "silver_grain", name = "Silver grain", description = "A bead of silver from the cupel. Nine make an ingot." },
    -- Wine, vinegar, spirit.
    { id = "vinum", name = "Vinum", description = "Fruit, fermented in the bath. Not for drinking: for distilling." },
    { id = "vinegar", name = "Vinegar", description = "Vinum left another day. It turns copper green." },
    { id = "distilled_vinegar", name = "Distilled vinegar", description = "Vinegar, distilled clear. It dissolves calxes." },
    { id = "verdigris", name = "Verdigris", description = "Copper's green rust, grown over vinegar." },
    { id = "verdigris_salve", name = "Verdigris salve", description = "Verdigris in honey: the Egyptians' ointment. It soothes a burn.",
        food = { cures = { "burning" }, sound = "eat" } },
    { id = "aqua_vitae", name = "Aqua vitae", description = "Burning water, distilled from vinum. A solvent, never a drink." },
    { id = "spirit_of_wine", name = "Spirit of wine", description = "Aqua vitae, rectified: the spirit every tincture is drawn with." },
    -- Vitriol.
    { id = "green_vitriol", name = "Green vitriol", description = "Pyrite, weathered wet: a salt like green glass. V.I.T.R.I.O.L." },
    { id = "oil_of_vitriol", name = "Oil of vitriol", description = "Green vitriol, distilled dry: a strong, heavy oil." },
    { id = "caput_mortuum", name = "Caput mortuum", description = "The dead head: the red residue in the retort." },
    { id = "blue_vitriol", name = "Blue vitriol", description = "Vitriol of Venus: copper in oil of vitriol, grown into deep blue crystals." },
    -- Gate II: salts.
    { id = "salt_of_tartar", name = "Salt of tartar", description = "Ash, dissolved and dried: potash." },
    { id = "sal_saturni", name = "Sal saturni", description = "Saturn's salt: litharge dissolved in vinegar. Sweet, and poison." },
    { id = "salt_of_venus", name = "Salt of Venus", description = "Burnt copper dissolved in vinegar: a green-blue salt." },
    -- Gate III: the three principles.
    { id = "principle_mercury", name = "Principle Mercury", description = "A plant's spirit, parted from it." },
    { id = "principle_sulfur", name = "Principle Sulfur", description = "A plant's oil, parted from it." },
    { id = "principle_salt", name = "Principle Salt", description = "A plant's fixed ash, parted from it." },
}

-- Spagyrics (brief §6.3): a plant's planet, by Culpeper's rulers where he
-- names one (C) and by analogy where he does not (A). A better source is
-- one edit here. `units` is how much of the plant a tincture takes: a
-- handful of a cover, or one crop.
C.planets = { "sol", "luna", "venus", "mars", "mercury", "jupiter", "saturn" }
C.planet_names = { sol = "Sol", luna = "Luna", venus = "Venus", mars = "Mars", mercury = "Mercury", jupiter = "Jupiter", saturn = "Saturn" }
C.herbs = {
    { "W:roman_chamomile", "sol" },     -- C
    { "W:peony", "sol" },               -- C
    { "L:rice", "sol", count = 1 },     -- A
    { "W:poppy", "luna" },              -- C
    { "W:water_iris", "luna" },         -- C
    { "W:blue_lunaria", "luna" },       -- A
    { "W:reeds", "luna" },              -- A
    { "W:glow_cap", "luna" },           -- A
    { "L:turnip", "luna", count = 1 },  -- C
    { "W:ladys_mantle", "venus" },      -- C
    { "W:ladys_mantle_bloom", "venus" },-- C
    { "W:wild_mint", "venus" },         -- C
    { "W:bramble", "venus" },           -- C
    { "W:rose_blooms", "venus" },       -- C
    { "W:rose", "venus", count = 1 },   -- C
    { "W:bluebell", "venus" },          -- A
    { "L:wheat", "venus", count = 1 },  -- C
    { "L:apple", "venus", count = 1 },  -- C
    { "L:berries", "venus", count = 1 },-- C
    { "W:gorse", "mars" },              -- C
    { "W:allium", "mars" },             -- C
    { "W:cactus", "mars" },             -- A
    { "W:fern", "mercury" },            -- C
    { "W:maidenhair", "mercury" },      -- C
    { "W:tall_grass", "mercury" },      -- A
    { "W:monstera", "jupiter" },        -- A
    { "W:pitcher_plant", "jupiter" },   -- A
    { "W:climbing_ivy", "saturn" },     -- C
    { "W:heather", "saturn" },          -- A
    { "W:lichen", "saturn" },           -- A
    { "W:moss", "saturn" },             -- A
    { "W:dead_sagebrush", "saturn" },   -- A
    { "W:mushroom_cap", "saturn" },     -- A
    { "L:mushroom", "saturn", count = 1 }, -- A
}
C.herb_units = 9                    -- a cover's handful, per tincture
C.tincture_days = 1

-- The simple elixirs: a tincture in a phial, by hand. Life's own effects
-- where Life has one; `own` is this mod's (effects.lua). Night-sight
-- brightens nothing until Weather's overlay (Wx-M1): until then it is a
-- rested sleep and a faint glow round the drinker. Swiftness is quick
-- feet through Life's composed abilities, and Life's `steady` besides.
C.elixirs = {
    { id = "elixir_vigour", planet = "sol", name = "Elixir of vigour", description = "Sol's tincture: your wounds close.",
        food = { effects = { { "regeneration", 300 } }, sound = "drink" } },
    { id = "elixir_night_sight", planet = "luna", name = "Elixir of night-sight", description = "Luna's tincture: the dark is kinder.",
        food = { effects = { { "rested", 2400 } }, sound = "drink" }, own = { "night_sight", 2400 } },
    { id = "elixir_hearts_ease", planet = "venus", name = "Heart's ease", description = "Venus's tincture: it heals and calms.",
        food = { heal = 4, effects = { { "rested", 1200 } }, sound = "drink" } },
    { id = "elixir_fortitude", planet = "mars", name = "Elixir of fortitude", description = "Mars's tincture: blows land softer.",
        food = { effects = { { "resistance", 600 } }, sound = "drink" } },
    { id = "elixir_swiftness", planet = "mercury", name = "Elixir of swiftness", description = "Mercury's tincture: quick feet.",
        food = { effects = { { "steady", 1200 } }, sound = "drink" }, own = { "swiftness", 1200 } },
    { id = "draught_warming", planet = "jupiter", name = "Warming draught", description = "Jupiter's tincture: warm through.",
        food = { temperature = "warm", effects = { { "warmth", 1200 } }, sound = "drink" } },
    { id = "draught_cooling", planet = "saturn", name = "Cooling draught", description = "Saturn's tincture: cool as stone.",
        food = { temperature = "cool", effects = { { "cooling", 1200 } }, sound = "drink" } },
}

-- This mod's own effects (brief §6.7): what Life does not have, each a
-- timer in storage and a look every `every` ticks.
C.own_effects = {
    -- Night-sight: the frame never darker than `light_floor`, caves too,
    -- through Weather's overlay (its answer to Wx-M1); and a faint glow of
    -- motes round the drinker.
    night_sight = { every = 40, particles = 6, colour = { r = 0.7, g = 0.9, b = 1.0, a = 0.35 },
        overlay = { light_floor = 0.35, ease_ticks = 40 } },
    -- Through Life's composed abilities (its answer to L-M3): a speed that
    -- multiplies in with Life's own cold and hunger, under this mod's name.
    swiftness = { speed_mul = 1.3 },
    -- The Elixir of Life: quintessence fills twice as fast (quintessence.lua).
    quintessence_flow = {},
    -- The Sylph's Wings: flight, through Life's composed abilities.
    flight = { fly = true },
}

-- The recipes of tier 3. `degree` is a degree of fire (above); `days` is in
-- philosophical days; `gate` is the Gate of Ripley a recipe completes, the
-- first time (a discovery worth 25 x the gate's number).
C.lab_recipes = {
    -- The athanor itself, its baths and the glass.
    { id = "athanor", station = "workbench", node = "magic.athanor",
        inputs = { { "C:brick", count = 9 }, { "C:iron_plate", count = 2 }, { "C:glass", count = 1 }, { "C:fired_clay", count = 9 } },
        outputs = { { "athanor", count = 1 } } },
    { id = "ash_bath", station = "hand", node = "magic.athanor",
        inputs = { { "C:fired_clay", count = 1 }, { "#ash", units = 9 } }, outputs = { { "ash_bath", count = 1 } } },
    { id = "bain_marie", station = "hand", node = "magic.bain_marie",
        inputs = { { "C:copper_pot", count = 1 }, { "L:water_bucket", count = 1 } },
        outputs = { { "bain_marie", count = 1 }, { "L:bucket", count = 1 } } },
    { id = "sand_bath", station = "hand", node = "magic.degrees_of_fire",
        inputs = { { "C:fired_clay", count = 1 }, { "W:sand", units = 9 } }, outputs = { { "sand_bath", count = 1 } } },
    { id = "blowpipe", station = "workbench", node = "magic.glassblowing",
        inputs = { { "C:iron_bar", count = 1 } }, tools = { { "#hammer", wear = 1 } }, outputs = { { "blowpipe", count = 1 } } },
    { id = "phial", station = "kiln", node = "magic.glassblowing", heat = 2, ticks = 200,
        inputs = { { "C:glass", count = 1 } }, tools = { { "blowpipe", wear = 0 } }, outputs = { { "phial", count = 4 } } },
    { id = "alembic", station = "kiln", node = "magic.glassblowing", heat = 2, ticks = 600,
        inputs = { { "C:glass", count = 3 } }, tools = { { "blowpipe", wear = 0 } }, outputs = { { "alembic", count = 1 } } },
    { id = "retort", station = "kiln", node = "magic.retort", heat = 2, ticks = 400,
        inputs = { { "C:glass", count = 2 } }, tools = { { "blowpipe", wear = 0 } }, outputs = { { "retort", count = 1 } } },

    -- Gate I, Calcination: metals roasted at naked fire.
    { id = "calcine_lead", station = "athanor", node = "magic.gate_calcination", degree = 4, ticks = 600, gate = 1,
        inputs = { { "C:lead_ingot", count = 1 } }, outputs = { { "litharge", count = 1 } } },
    { id = "calcine_tin", station = "athanor", node = "magic.gate_calcination", degree = 4, ticks = 600, gate = 1,
        inputs = { { "C:tin_ingot", count = 1 } }, outputs = { { "putty", count = 1 } } },
    { id = "calcine_copper", station = "athanor", node = "magic.gate_calcination", degree = 4, ticks = 600, gate = 1,
        inputs = { { "C:copper_ingot", count = 1 } }, outputs = { { "aes_ustum", count = 1 } } },
    { id = "calcine_iron", station = "athanor", node = "magic.gate_calcination", degree = 4, ticks = 600, gate = 1,
        inputs = { { "C:iron_bar", count = 1 } }, outputs = { { "crocus_martis", count = 1 } } },
    { id = "calcine_bone", station = "athanor", node = "magic.gate_calcination", degree = 4, ticks = 400, gate = 1,
        inputs = { { "L:bone", count = 1 } }, outputs = { { "bone_ash", count = 1 } } },
    { id = "minium", station = "athanor", node = "magic.gate_calcination", degree = 2, days = 1,
        inputs = { { "litharge", count = 1 } }, outputs = { { "minium", count = 1 } } },

    -- The cupel: the historic silver-from-lead.
    { id = "cupel", station = "hand", node = "magic.cupellation",
        inputs = { { "bone_ash", count = 1 } }, outputs = { { "cupel", count = 1 } } },
    { id = "cupellation", station = "athanor", node = "magic.cupellation", degree = 4, ticks = 1200,
        inputs = { { "C:lead_ingot", count = 9 } }, tools = { { "cupel", wear = 0 } },
        outputs = { { "litharge", count = 8 }, { "silver_grain", count = 1 } } },
    { id = "silver_from_grains", station = "athanor", node = "magic.cupellation", heat = 2, ticks = 600,
        inputs = { { "silver_grain", count = 9 } }, outputs = { { "C:silver_ingot", count = 1 } } },

    -- Wine and vinegar, in Maria's bath.
    { id = "vinum", station = "athanor", node = "magic.vinegar_and_wine", degree = 1, days = 1,
        inputs = { { "#fruit", count = 3 }, { "L:water_bucket", count = 1 } },
        outputs = { { "vinum", count = 1 }, { "L:bucket", count = 1 } } },
    { id = "vinum_from_wheat", station = "athanor", node = "magic.vinegar_and_wine", degree = 1, days = 1,
        inputs = { { "L:wheat", count = 3 }, { "L:water_bucket", count = 1 } },
        outputs = { { "vinum", count = 1 }, { "L:bucket", count = 1 } } },
    { id = "vinegar", station = "athanor", node = "magic.vinegar_and_wine", degree = 1, days = 1,
        inputs = { { "vinum", count = 1 } }, outputs = { { "vinegar", count = 1 } } },
    { id = "distilled_vinegar", station = "athanor", node = "magic.vinegar_and_wine", degree = 2, ticks = 600,
        inputs = { { "vinegar", count = 1 } }, tools = { { "alembic", wear = 0 } }, outputs = { { "distilled_vinegar", count = 1 } } },

    -- Verdigris, and the Egyptians' ointment.
    { id = "verdigris", station = "athanor", node = "magic.verdigris", degree = 1, days = 1,
        inputs = { { "C:copper_ingot", count = 1 }, { "vinegar", count = 1 } }, outputs = { { "verdigris", count = 3 } } },
    { id = "verdigris_salve", station = "hand", node = "magic.verdigris",
        inputs = { { "verdigris", count = 1 }, { "L:honey", count = 1 } }, outputs = { { "verdigris_salve", count = 2 } } },

    -- Burning water, and its spirit.
    { id = "aqua_vitae", station = "athanor", node = "magic.aqua_vitae", degree = 2, ticks = 600,
        inputs = { { "vinum", count = 1 } }, tools = { { "alembic", wear = 0 } }, outputs = { { "aqua_vitae", count = 1 } } },
    { id = "spirit_of_wine", station = "athanor", node = "magic.aqua_vitae", degree = 2, days = 1,
        inputs = { { "aqua_vitae", count = 3 } }, tools = { { "alembic", wear = 0 } }, outputs = { { "spirit_of_wine", count = 1 } } },

    -- Vitriol: the bath's route (the rain's waits on sibling ask W-M3).
    { id = "green_vitriol", station = "athanor", node = "magic.green_vitriol", degree = 1, days = 3,
        inputs = { { "W:pyrite", units = 27 }, { "L:water_bucket", count = 1 } },
        outputs = { { "green_vitriol", count = 1 }, { "L:bucket", count = 1 } } },
    { id = "oil_of_vitriol", station = "athanor", node = "magic.oil_of_vitriol", degree = 3, days = 1,
        inputs = { { "green_vitriol", count = 2 } }, tools = { { "retort", wear = 0 } },
        outputs = { { "oil_of_vitriol", count = 1 }, { "caput_mortuum", count = 1 } } },
    { id = "blue_vitriol", station = "athanor", node = "magic.blue_vitriol", degree = 1, ticks = 600,
        inputs = { { "C:copper_ingot", count = 1 }, { "#oil_of_vitriol", count = 1 } }, outputs = { { "blue_vitriol", count = 3 } } },

    -- Gate II, Solution.
    { id = "salt_of_tartar", station = "athanor", node = "magic.gate_solution", degree = 1, days = 1, gate = 2,
        inputs = { { "#ash", units = 27 }, { "L:water_bucket", count = 1 } },
        outputs = { { "salt_of_tartar", count = 1 }, { "L:bucket", count = 1 } } },
    { id = "sal_saturni", station = "athanor", node = "magic.gate_solution", degree = 1, days = 1, gate = 2,
        inputs = { { "litharge", count = 1 }, { "distilled_vinegar", count = 1 } }, outputs = { { "sal_saturni", count = 1 } } },
    { id = "salt_of_venus", station = "athanor", node = "magic.gate_solution", degree = 1, days = 1, gate = 2,
        inputs = { { "aes_ustum", count = 1 }, { "distilled_vinegar", count = 1 } }, outputs = { { "salt_of_venus", count = 1 } } },

    -- Gate III, Separation: any herb into its three principles.
    { id = "separation", station = "athanor", node = "magic.gate_separation", degree = 2, days = 1, gate = 3,
        inputs = { { "#magic_herb", units = 27 } }, tools = { { "alembic", wear = 0 } },
        outputs = { { "principle_mercury", count = 1 }, { "principle_sulfur", count = 1 }, { "principle_salt", count = 1 } } },
}

-- Tier 4 (brief §5.2): the menstrua and the black ----------------------------------

C.tier4_items = {
    -- Vessels.
    { id = "aludel", name = "Aludel", description = "A pot of pots, stacked: what rises in it is caught as flowers." },
    { id = "pelican", name = "Pelican", description = "A glass vessel whose arms bend back into its belly: what rises returns, for ever." },
    { id = "philosophers_egg", name = "Philosophers' Egg", description = "The sealed glass ovum. Every long work of the Opus is cooked in it." },
    -- Sublimates, quicksilver and its works.
    { id = "flowers_of_sulfur", name = "Flowers of sulfur", description = "Sulfur, sublimed pure and yellow. A salamander's food." },
    { id = "quicksilver", name = "Quicksilver", description = "The seventh metal, liquid: roasted out of cinnabar." },
    { id = "vermilion", name = "Vermilion", description = "Quicksilver and sulfur, raised together: the red the Red Work imitates." },
    { id = "amalgam_gold", name = "Gold amalgam", description = "Gold swallowed by quicksilver: soft, and the body of later works." },
    { id = "amalgam_silver", name = "Silver amalgam", description = "Silver in quicksilver. In strong water it grows a tree." },
    { id = "amalgam_tin", name = "Tin amalgam", description = "Tin in quicksilver: the backing of mirrors." },
    -- Salts and the strong waters, in the order they were discovered.
    { id = "saltpeter", name = "Saltpeter", description = "The nitre bed's crust: rotting plants, ash and earth, kept warm." },
    { id = "aqua_fortis", name = "Aqua fortis", description = "Strong water: it eats silver and leaves gold alone." },
    { id = "spirit_of_salt", name = "Spirit of salt", description = "Glauber's biting vapour, from salt and oil of vitriol." },
    { id = "sal_mirabilis", name = "Sal mirabilis", description = "Glauber's wonderful salt, left in the retort." },
    { id = "sal_ammoniac", name = "Sal ammoniac", description = "Bone and salt, sublimed: a salt that rises." },
    { id = "aqua_regia", name = "Aqua regia", description = "Royal water: strong enough to dissolve even gold." },
    { id = "green_lion", name = "The Green Lion", description = "Gold dissolved in royal water: the lion that devours the Sun." },
    { id = "phosphorus", name = "Phosphorus", description = "The light-bearer, from bone ash. It glows by itself." },
    { id = "phosphorus_spill", name = "Phosphorus spill", description = "A stick tipped with phosphorus. It lights a laid fire, or a fuelled furnace." },
    -- The Opus: the matter of the Work, stage by stage.
    { id = "conjoined_matter", name = "Conjoined matter", description = "The Chemical Wedding: the King and Queen of a plant, with its salt." },
    { id = "caput_corvi", name = "Caput corvi", description = "The Raven's Head: the matter, rotted black in the Egg. The nigredo." },
    { id = "peacock_matter", name = "Peacock matter", description = "The black, washed: it shimmers every colour, like a peacock's tail." },
}

C.tier4_recipes = {
    -- Vessels, at the kiln with the blowpipe.
    { id = "aludel", station = "kiln", node = "magic.aludel", heat = 2, ticks = 600,
        inputs = { { "C:fired_clay", count = 2 }, { "C:glass", count = 2 } }, tools = { { "blowpipe", wear = 0 } },
        outputs = { { "aludel", count = 1 } } },
    { id = "pelican", station = "kiln", node = "magic.pelican", heat = 2, ticks = 800,
        inputs = { { "C:glass", count = 4 } }, tools = { { "blowpipe", wear = 0 } }, outputs = { { "pelican", count = 1 } } },
    { id = "philosophers_egg", station = "kiln", node = "magic.philosophers_egg", heat = 2, ticks = 800,
        inputs = { { "C:glass", count = 3 }, { "flowers_of_sulfur", count = 1 } }, tools = { { "blowpipe", wear = 0 } },
        outputs = { { "philosophers_egg", count = 1 } } },

    -- Sublimation, and quicksilver from its ore.
    { id = "flowers_of_sulfur", station = "athanor", node = "magic.flowers_of_sulfur", degree = 3, ticks = 600,
        inputs = { { "W:sulfur", units = 27 } }, tools = { { "aludel", wear = 0 } }, outputs = { { "flowers_of_sulfur", count = 9 } } },
    { id = "quicksilver", station = "athanor", node = "magic.quicksilver", degree = 3, ticks = 600,
        inputs = { { "W:cinnabar", units = 27 } }, tools = { { "retort", wear = 0 } }, outputs = { { "quicksilver", count = 9 } } },
    { id = "vermilion", station = "athanor", node = "magic.vermilion", degree = 3, ticks = 600,
        inputs = { { "#quicksilver", count = 1 }, { "flowers_of_sulfur", count = 1 } }, tools = { { "aludel", wear = 0 } },
        outputs = { { "vermilion", count = 1 } } },
    { id = "amalgam_gold", station = "hand", node = "magic.amalgams", tools = { { "mortar", wear = 0 } },
        inputs = { { "C:gold_ingot", count = 1 }, { "#quicksilver", count = 2 } }, outputs = { { "amalgam_gold", count = 1 } } },
    { id = "amalgam_silver", station = "hand", node = "magic.amalgams", tools = { { "mortar", wear = 0 } },
        inputs = { { "C:silver_ingot", count = 1 }, { "#quicksilver", count = 2 } }, outputs = { { "amalgam_silver", count = 1 } } },
    { id = "amalgam_tin", station = "hand", node = "magic.amalgams", tools = { { "mortar", wear = 0 } },
        inputs = { { "C:tin_ingot", count = 1 }, { "#quicksilver", count = 2 } }, outputs = { { "amalgam_tin", count = 1 } } },

    -- The nitre bed and the strong waters.
    { id = "saltpeter", station = "athanor", node = "magic.saltpeter", degree = 1, days = 3,
        inputs = { { "#magic_herb", units = 27 }, { "#ash", units = 9 }, { "W:dirt", units = 27 } },
        outputs = { { "saltpeter", count = 1 } } },
    { id = "aqua_fortis", station = "athanor", node = "magic.aqua_fortis", degree = 3, ticks = 600,
        inputs = { { "#saltpeter", count = 1 }, { "green_vitriol", count = 1 } }, tools = { { "retort", wear = 0 } },
        outputs = { { "aqua_fortis", count = 1 } } },
    { id = "spirit_of_salt", station = "athanor", node = "magic.spirit_of_salt", degree = 3, ticks = 600,
        inputs = { { "W:salt", units = 9 }, { "#oil_of_vitriol", count = 1 } }, tools = { { "retort", wear = 0 } },
        outputs = { { "spirit_of_salt", count = 1 }, { "sal_mirabilis", count = 1 } } },
    { id = "sal_ammoniac", station = "athanor", node = "magic.sal_ammoniac", degree = 3, ticks = 600,
        inputs = { { "L:bone", count = 1 }, { "W:salt", units = 9 } }, tools = { { "aludel", wear = 0 } },
        outputs = { { "sal_ammoniac", count = 1 } } },
    { id = "aqua_regia", station = "athanor", node = "magic.aqua_regia", degree = 1, ticks = 600,
        inputs = { { "aqua_fortis", count = 1 }, { "sal_ammoniac", count = 1 } }, outputs = { { "aqua_regia", count = 1 } } },
    { id = "green_lion", station = "athanor", node = "magic.aqua_regia", degree = 1, days = 1,
        inputs = { { "C:gold_ingot", count = 1 }, { "aqua_regia", count = 1 } }, outputs = { { "green_lion", count = 1 } } },
    { id = "phosphorus", station = "athanor", node = "magic.phosphorus", degree = 4, ticks = 1200,
        inputs = { { "bone_ash", count = 1 }, { "#oil_of_vitriol", count = 1 }, { "C:charcoal", count = 1 } },
        tools = { { "retort", wear = 0 } }, outputs = { { "phosphorus", count = 3 } } },
    { id = "phosphorus_spill", station = "hand", node = "magic.phosphorus",
        inputs = { { "phosphorus", count = 1 }, { "C:stick", count = 2 } }, outputs = { { "phosphorus_spill", count = 4 } } },

    -- Theriac: Galen's antidote, which is Life's own.
    { id = "theriac", station = "hand", node = "magic.theriac",
        inputs = { { "#magic_tincture", count = 1 }, { "L:honey", count = 1 }, { "principle_salt", count = 1 } },
        outputs = { { "L:antidote", count = 1 } } },

    -- Gates IV and V, and the Peacock's Tail.
    { id = "conjunction", station = "athanor", node = "magic.gate_conjunction", degree = 1, days = 1, gate = 4,
        inputs = { { "principle_sulfur", count = 1 }, { "principle_mercury", count = 1 }, { "principle_salt", count = 1 } },
        tools = { { "pelican", wear = 0 } }, outputs = { { "conjoined_matter", count = 1 } } },
    { id = "putrefaction", station = "athanor", node = "magic.gate_putrefaction", degree = 1, days = 3, gate = 5,
        inputs = { { "conjoined_matter", count = 1 } }, tools = { { "philosophers_egg", wear = 0 } },
        outputs = { { "caput_corvi", count = 1 } } },
    { id = "ablution", station = "athanor", node = "magic.cauda_pavonis", degree = 1, days = 1,
        inputs = { { "caput_corvi", count = 1 }, { "distilled_vinegar", count = 1 } }, tools = { { "philosophers_egg", wear = 0 } },
        outputs = { { "peacock_matter", count = 1 } } },
}

-- Palingenesis (Digby, Kircher): a plant's salt, warmed in a phial with a
-- sprig of it, gives the living plant back — the world's covers only.
C.palingenesis = { node = "magic.palingenesis", days = 1, sprig_units = 3, yield_units = 27 }

-- Phosphorus spills light what a striker would, without one: a laid
-- campfire, or a heat station with fuel in it.
C.spill = { item = "phosphorus_spill", lights = { "C:unlit_campfire", "C:kiln", "C:bloomery", "athanor" } }

-- The Peacock's Tail: an athanor washing the Raven's Head in the Egg
-- shimmers every colour while it works.
C.peacock = { every = 100, particles = 20, discovery = 10 }
C.peacock_colours = {
    { r = 0.1, g = 0.5, b = 1.0 }, { r = 0.1, g = 0.9, b = 0.5 }, { r = 0.9, g = 0.8, b = 0.1 },
    { r = 0.8, g = 0.2, b = 0.9 }, { r = 0.2, g = 0.8, b = 0.9 },
}

-- The Tree of Diana (brief §7.4): silver amalgam in strong water grows a
-- crystal silver tree, a cell at a time, while it has been watered with
-- aqua fortis within `fed_ticks`. Dug, it pays silver by its share of a
-- whole block: a full tree is an ingot. `order` is the growth, trunk first.
C.arbor = {
    node = "magic.arbor_dianae",
    block = { id = "arbor_dianae", name = "Tree of Diana",
        description = "A tree of silver crystal, grown in strong water. Water it with aqua fortis; dig it for silver.",
        hardness = 0.6, light = { r = 3, g = 3, b = 4 }, tags = { "crystal", "glowing" } },
    seed = { id = "arbor_seed", name = "Seed of Diana",
        description = "Silver amalgam wet with strong water. Plant it on the ground, and water it with aqua fortis." },
    water = "aqua_fortis",
    drops = { ["C:silver_ingot"] = 27 },
    every = 2000,                   -- ticks between one cell and the next
    fed_ticks = 24000,              -- how long a watering lasts: a sun-day
    budget = 64,                    -- trees grown a pass
    per_player = 64,
    order = { 10, 13, 16, 15, 17, 7, 25, 12, 14, 4, 22, 6, 8, 24, 26, 3, 5, 21, 23, 9, 11, 1, 19, 0, 2, 18, 20 },
    discovery = 10,
}
C.arbor_recipes = {
    { id = "arbor_seed", station = "hand", node = "magic.arbor_dianae",
        inputs = { { "amalgam_silver", count = 1 }, { "aqua_fortis", count = 1 } }, outputs = { { "arbor_seed", count = 3 } } },
}

-- Talismans (brief §6.6): a planet's sign struck in its metal, on the anvil,
-- with a carved sigil block as the die (found, not taken). Worn in Life's
-- worn slots, one passive each, refreshed every `every` ticks while worn;
-- `slots` of them count (1, and `magic.talisman_slots` more), each at
-- `1 + magic.talisman_grade`.
C.talismans = {
    node = "magic.talismans",
    view = "tiamat_default_life:worn",
    every = 40,
    lasts = 80,                     -- ticks an effect is set for, a little past the next look
    strikes = 4,
    die = "#magic_die",             -- what a die may be carved from: stone and the ores
    die_materials = { "W:stone", "W:granite", "W:slate", "W:calcite", "W:dark_basalt", "W:black_marble",
        "W:gold_ore", "W:silver_ore", "W:copper_ore", "W:iron_ore", "W:tin_ore", "W:lead_ore", "W:cinnabar" },
    kinds = {
        { planet = "sol", metal = "C:gold_ingot", name = "Talisman of Sol", gift = "never cold" },
        { planet = "luna", metal = "C:silver_ingot", name = "Talisman of Luna", gift = "the dark is kinder" },
        { planet = "venus", metal = "C:copper_ingot", name = "Talisman of Venus", gift = "animals follow you" },
        { planet = "mars", metal = "C:iron_bar", name = "Talisman of Mars", gift = "your fists strike harder" },
        { planet = "jupiter", metal = "C:tin_ingot", name = "Talisman of Jupiter", gift = "you tire slowly" },
        { planet = "saturn", metal = "C:lead_ingot", name = "Talisman of Saturn", gift = "you sense ore nearby" },
        { planet = "mercury", metal = "amalgam_tin", name = "Talisman of Mercury", gift = "quick feet" },
    },
    venus_radius = 6,
    mars_extra = 2,                 -- points a bare fist adds, a grade
    saturn_radius = 4,              -- blocks: one layer of the cube read a look
    mercury_speed = 10,             -- per cent quicker, a grade
}

-- What an ore-sense sees (Saturn's talisman now; the gnome's, later).
C.ores = { "W:gold_ore", "W:silver_ore", "W:copper_ore", "W:iron_ore", "W:tin_ore", "W:lead_ore", "W:cinnabar",
    "W:coal", "W:pyrite", "W:crystal", "W:orichalcum", "W:diamond", "W:chromium_ore", "W:pitchblende", "W:salt",
    "W:sulfur" }

-- The Hermetic Seal (brief §7.3): a seal glyph set by a player who knows it
-- wards the blocks within `radius` (Greater Seal: `greater_radius`), twice
-- that carved from black marble. Nobody but its setter, whoever they allow
-- and an operator may dig or build there. No ward may touch another
-- player's: a seal is refused where its ward would overlap theirs.
C.seal = {
    node = "magic.hermetic_seal",
    greater = "magic.greater_seal",
    radius = 6,
    greater_radius = 12,
    marble = "W:black_marble",
    marble_times = 2,
    refused = "A Hermetic Seal wards this place.",
    overlaps = "Another's seal already wards ground this close.",
}

-- The Ouroboros (brief §7.3): eight ouroboros blocks ringing a burning
-- athanor at its own height shorten its works by the setter's
-- `magic.long_work_percent` (the Ouroboros: 20 per cent less time).
C.ouroboros = { node = "magic.ouroboros" }

-- Tier 5 (brief §5.3): the White Work ------------------------------------------------

C.tier5_items = {
    { id = "fixed_mercury", name = "Fixed mercury", description = "Quicksilver made to sit still: Gate VI, Congelation." },
    { id = "eagle", name = "The Eagle", description = "The matter raised and purified in the aludel: Gate VIII, Sublimation." },
    { id = "sal_alembroth", name = "Sal alembroth", description = "The salt of wisdom: quicksilver and sal ammoniac, sublimed together." },
    { id = "white_stone", name = "The White Stone", description = "The Albedo: seven days in the Egg. Projected on base metal, it makes silver." },
    { id = "solar_sulfur", name = "Solar sulfur", description = "The White Stone yellowed: Citrinitas, the Yellow King." },
    { id = "aurum_potabile", name = "Aurum potabile", description = "Drinkable gold. It heals every hurt and cures every ill.",
        food = { heal = 27, cures = { "poison", "wither", "radiation", "burning" }, effects = { { "regeneration", 1200 } }, sound = "drink" } },
    { id = "elixir_vitae", name = "Elixir of life (lesser)", description = "Strength and healing together, and your quintessence flows.",
        food = { effects = { { "regeneration", 2400 }, { "resistance", 2400 } }, sound = "drink" } },
    { id = "quintessence", name = "Quintessence", description = "Spirit circulated a thousand times: the fifth essence. Drunk, it fills your well.",
        food = { sound = "drink" } },
    { id = "kerotakis", name = "Kerotakis", description = "Maria's reflux palette, for tinting metals in the athanor." },
    { id = "electrum", name = "Electrum", description = "Gold and silver, one metal: the ancients' pale gold." },
    { id = "living_orichalcum", name = "Living orichalcum", description = "The glimmer, attuned: orichalcum that answers the hand." },
}

C.tier5_recipes = {
    -- Gate VI, Congelation: quicksilver fixed with an alkali.
    { id = "congelation", station = "athanor", node = "magic.gate_congelation", degree = 3, ticks = 1200, gate = 6,
        inputs = { { "#quicksilver", count = 1 }, { "salt_of_tartar", count = 1 } }, tools = { { "aludel", wear = 0 } },
        outputs = { { "fixed_mercury", count = 1 } } },
    -- Gate VII, Cibation: the matter fed, a portion at a time, grows.
    { id = "cibation", station = "athanor", node = "magic.gate_cibation", degree = 1, days = 2, gate = 7,
        inputs = { { "peacock_matter", count = 1 }, { "spirit_of_wine", count = 3 } }, tools = { { "philosophers_egg", wear = 0 } },
        outputs = { { "peacock_matter", count = 2 } } },
    -- Gate VIII, Sublimation: the Eagle flies.
    { id = "sublimation", station = "athanor", node = "magic.gate_sublimation", degree = 3, ticks = 1200, gate = 8,
        inputs = { { "fixed_mercury", count = 1 }, { "flowers_of_sulfur", count = 1 } }, tools = { { "aludel", wear = 0 } },
        outputs = { { "eagle", count = 1 } } },
    { id = "sal_alembroth", station = "athanor", node = "magic.sal_alembroth", degree = 3, ticks = 1200,
        inputs = { { "#quicksilver", count = 1 }, { "sal_ammoniac", count = 1 } }, tools = { { "aludel", wear = 0 } },
        outputs = { { "sal_alembroth", count = 1 } } },
    -- The Albedo, and the yellowing.
    { id = "albedo", station = "athanor", node = "magic.albedo", degree = 1, days = 7,
        inputs = { { "peacock_matter", count = 1 }, { "fixed_mercury", count = 1 }, { "tincture_luna", count = 1 } },
        tools = { { "philosophers_egg", wear = 0 } }, outputs = { { "white_stone", count = 1 } } },
    { id = "citrinitas", station = "athanor", node = "magic.citrinitas", degree = 1, days = 3,
        inputs = { { "white_stone", count = 1 }, { "tincture_sol", count = 1 }, { "eagle", count = 1 } },
        tools = { { "philosophers_egg", wear = 0 } }, outputs = { { "solar_sulfur", count = 1 } } },
    -- The medicines.
    { id = "aurum_potabile", station = "athanor", node = "magic.aurum_potabile", degree = 2, days = 1,
        inputs = { { "green_lion", count = 1 }, { "solar_sulfur", count = 1 }, { "spirit_of_wine", count = 1 } },
        tools = { { "pelican", wear = 0 } }, outputs = { { "aurum_potabile", count = 3 } } },
    { id = "elixir_vitae", station = "athanor", node = "magic.elixir_vitae", degree = 1, days = 1,
        inputs = { { "L:antidote", count = 1 }, { "tincture_sol", count = 1 }, { "tincture_luna", count = 1 } },
        tools = { { "pelican", wear = 0 } }, outputs = { { "elixir_vitae", count = 2 } } },
    { id = "quintessence", station = "athanor", node = "magic.quintessence", degree = 2, days = 3,
        inputs = { { "spirit_of_wine", count = 3 } }, tools = { { "pelican", wear = 0 } },
        outputs = { { "quintessence", count = 1 } } },
    -- Maria's kerotakis, and what it tints.
    { id = "kerotakis", station = "kiln", node = "magic.kerotakis", heat = 2, ticks = 600,
        inputs = { { "C:iron_plate", count = 1 }, { "C:glass", count = 1 } }, tools = { { "blowpipe", wear = 0 } },
        outputs = { { "kerotakis", count = 1 } } },
    { id = "electrum", station = "athanor", node = "magic.kerotakis", degree = 4, ticks = 1200,
        inputs = { { "C:gold_ingot", count = 1 }, { "C:silver_ingot", count = 1 } }, tools = { { "kerotakis", wear = 0 } },
        outputs = { { "electrum", count = 2 } } },
    -- Orichalcum, awakened, and its tools.
    { id = "living_orichalcum", station = "athanor", node = "magic.orichalcum_awakened", degree = 4, ticks = 2400,
        inputs = { { "W:orichalcum", units = 27 }, { "amalgam_silver", count = 1 } }, tools = { { "kerotakis", wear = 0 } },
        outputs = { { "living_orichalcum", count = 1 } } },
}

-- Projection of the White Stone (brief §6.10), while the world allows
-- transmutation: one stone and nine base ingots make nine of silver.
C.white_projection = {
    node = "magic.albedo",
    base = "#magic_white_base", base_members = { "C:tin_ingot", "C:lead_ingot", "quicksilver" },
    makes = "C:silver_ingot", count = 9,
    milestone = 200,                -- the first transmutation, once
}
C.transmutation_option = "tiamat_default_magic:transmutation"

-- Orichalcum tools: Craft's tier 4, engine tools that dig.
C.orichalcum_tools = {
    { id = "orichalcum_pick", name = "Orichalcum pick", type = "pick", speed = 4.2, ingots = 3 },
    { id = "orichalcum_axe", name = "Orichalcum axe", type = "axe", speed = 4.6, ingots = 3 },
    { id = "orichalcum_spade", name = "Orichalcum spade", type = "spade", speed = 4.6, ingots = 3 },
    { id = "orichalcum_chisel", name = "Orichalcum chisel", type = "chisel", speed = 1.4, ingots = 1, brush = "subnode" },
}
C.orichalcum = { node = "magic.orichalcum_awakened", tier = 4, uses = 1200, weapon = 8 }

-- Quintessence (brief §6.8): one bar, Life's, drawn only for magic players
-- (Life's per-player ceiling, its answer to L-M1). Ceiling `base` plus
-- `magic.quintessence_max`; `regen` points every `every` ticks, times
-- (1 + `magic.quintessence_regen_percent`), doubled while the Elixir of
-- Life flows.
C.quintessence = {
    id = "quintessence",            -- qualified: tiamat_default_magic:quintessence
    name = "Quintessence", colour = { 214, 190, 90 },
    ceiling = 100,                  -- the stat's own, above anyone's
    base = 10,
    every = 200, regen = 1,
    refills = { quintessence = 20, aurum_potabile = 1000 },
    flow = { "quintessence_flow", 12000 }, -- the own effect the Elixir of Life starts, and its ticks
}

-- The Assay: every study at the research table pays its node's
-- `progress.study_percent` more, which Progress reads when it pays (P-M2).
C.assay = { node = "magic.assay" }

-- Atalanta Fugiens (Maier, 1617): an emblem for a first, once the book is
-- known. Fifty emblems in all; these are the firsts the Art has so far.
C.emblems = {
    node = "magic.atalanta_fugiens", insight = 10,
    by_discovery = {
        ["gate_1"] = "I: the wind carried it in his belly",
        ["gate_2"] = "II: the earth is its nurse",
        ["gate_3"] = "III: go to the woman who washes the sheets",
        ["gate_4"] = "IV: join the brother to the sister",
        ["gate_5"] = "V: put a toad to the woman's breast",
        ["gate_6"] = "VI: sow your gold in white earth",
        ["gate_7"] = "VII: the young bird falls from the nest",
        ["gate_8"] = "VIII: take the egg and smite it with fire",
        ["peacock"] = "IX: enclose the old man in the house of dew",
        ["familiar_salamander"] = "XXIX: as the salamander lives in fire",
        ["familiar_undine"] = "XXV: the dragon dies not unless slain",
        ["familiar_gnome"] = "XXVI: the fruit of human wisdom",
        ["familiar_sylph"] = "XLVI: two eagles come together",
        ["tree_of_diana"] = "XIV: this is the dragon that devours its tail",
        ["transmutation"] = "XXI: make a circle of man and woman",
    },
}

C.tier5_studies = {
    { id = "study_white_stone", name = "Study the White Stone", inputs = { { "white_stone", count = 1 } }, ticks = 9000, insight = 300 },
    { id = "study_solar_sulfur", name = "Study solar sulfur", inputs = { { "solar_sulfur", count = 1 } }, ticks = 9000, insight = 350 },
    { id = "study_aurum_potabile", name = "Study aurum potabile", inputs = { { "aurum_potabile", count = 1 } }, ticks = 6000, insight = 250 },
}

-- The Caduceus (brief §5.3): Hermes' staff, assembled from two carvings.
-- Used, it is Hermes' Stride, a step of `stride` blocks the way its holder
-- faces for `stride_cost` quintessence; an elixir used on another player
-- with it known is given to them, for `spray_cost`.
C.caduceus = {
    node = "magic.caduceus",
    item = { id = "caduceus", name = "Caduceus", description = "Hermes' staff. Use it to stride; with it, an elixir used on a friend is theirs." },
    stride = 8, stride_cost = 5, spray_cost = 10,
    dry = "Your well of quintessence is dry.",
}
C.caduceus_recipe = {
    id = "caduceus", station = "workbench", node = "magic.caduceus",
    inputs = {
        { glyph = "mercury", material = "W:silver_ore", count = 1 },
        { glyph = "ouroboros", material = "W:gold_ore", count = 1 },
        { "C:stick", count = 1 }, { "#quicksilver", count = 2 }, { "quintessence", count = 1 },
    },
    outputs = { { "caduceus", count = 1 } },
}

-- The elementals' second gifts (brief §5.3), each a node.
C.gifts = {
    undine_tides = { node = "magic.undine_tides", effect = "water_breathing", ticks = 80 },
    gnome_delving = { node = "magic.gnome_delving", reach = 16, height = 2,
        -- What a gnome may tunnel: the world's own ground and ore, nothing
        -- anybody built, so a tunnel never opens a chest or a station.
        digs = { "W:stone", "W:granite", "W:slate", "W:calcite", "W:dark_basalt", "W:basalt", "W:dirt", "W:sand",
            "W:gravel", "W:white_sand", "W:dry_clay", "W:wet_clay", "W:cobble", "W:coal", "W:copper_ore", "W:tin_ore",
            "W:iron_ore", "W:lead_ore", "W:silver_ore", "W:gold_ore", "W:cinnabar", "W:pyrite", "W:salt", "W:sulfur" } },
    sylph_flight = { node = "magic.sylph_flight", cost = 10, ticks = 200 },
}

-- Tier 6 (brief §5.4): the Red Work -------------------------------------------------

C.tier6_items = {
    { id = "ferment", name = "The Ferment", description = "The Stone leavened with gold: Gate IX, Fermentation." },
    { id = "red_stone", name = "The Red Stone", description = "The Philosophers' Stone: forty days in the Egg. Projected on base metal, it makes gold." },
    { id = "alkahest", name = "Alkahest", description = "The universal solvent. Poured on rock, it melts it back into first matter." },
    { id = "prima_materia", name = "Prima materia", description = "First matter: what every common stone is made of, before it is any of them." },
    { id = "panacea", name = "The Panacea", description = "The cure for all ills, for you and everyone near you.",
        food = { heal = 27, cures = { "poison", "wither", "radiation", "burning" }, sound = "drink" } },
    { id = "wedding_crown", name = "The Wedding Crown", description = "Given when the Red King and the White Queen are joined at an athanor. The Rebis needs it." },
}

C.tier6_recipes = {
    -- Gate IX, Fermentation; the Rubedo; Gates X and XI.
    { id = "fermentation", station = "athanor", node = "magic.gate_fermentation", degree = 1, days = 3, gate = 9,
        inputs = { { "solar_sulfur", count = 1 }, { "C:gold_ingot", count = 1 }, { "vinum", count = 1 } },
        tools = { { "philosophers_egg", wear = 0 } }, outputs = { { "ferment", count = 1 } } },
    { id = "rubedo", station = "athanor", node = "magic.rubedo", degree = 1, days = 40,
        inputs = { { "solar_sulfur", count = 1 }, { "ferment", count = 1 }, { "white_stone", count = 1 } },
        tools = { { "philosophers_egg", wear = 0 } }, outputs = { { "red_stone", count = 1 } } },
    { id = "exaltation", station = "athanor", node = "magic.gate_exaltation", degree = 1, days = 1, gate = 10,
        inputs = { { "red_stone", count = 1 }, { "quintessence", count = 1 } }, tools = { { "philosophers_egg", wear = 0 } },
        outputs = { { "red_stone", count = 1 } } },
    { id = "multiplication", station = "athanor", node = "magic.gate_multiplication", degree = 1, days = 7, gate = 11,
        inputs = { { "red_stone", count = 1 }, { "C:gold_ingot", count = 1 }, { "#quicksilver", count = 1 } },
        tools = { { "philosophers_egg", wear = 0 } }, outputs = { { "red_stone", count = 2 } } },
    -- The universal solvent, and first matter made into common stone.
    { id = "alkahest", station = "athanor", node = "magic.alkahest", degree = 1, days = 7,
        inputs = { { "aqua_regia", count = 1 }, { "spirit_of_wine", count = 1 }, { "sal_alembroth", count = 1 } },
        tools = { { "philosophers_egg", wear = 0 } }, outputs = { { "alkahest", count = 3 } } },
    -- The Panacea.
    { id = "panacea", station = "athanor", node = "magic.panacea", degree = 1, days = 1,
        inputs = { { "aurum_potabile", count = 1 }, { "elixir_vitae", count = 1 }, { "quintessence", count = 1 } },
        tools = { { "pelican", wear = 0 } }, outputs = { { "panacea", count = 3 } } },
}

-- Projection of the Red Stone, while the world allows transmutation; both
-- Stones' projections yield `magic.projection_percent` more (Exaltation).
C.red_projection = {
    node = "magic.rubedo",
    base = "#magic_red_base",
    base_members = { "C:copper_ingot", "C:tin_ingot", "C:lead_ingot", "C:iron_bar", "C:silver_ingot" },
    makes = "C:gold_ingot", count = 9,
}

-- The alkahest poured (brief §5.4): the blocks round the one it is poured
-- on melt into prima materia, unit for unit, a quintessence each; only the
-- world's own rock and earth (the gnome's list), never anything built.
C.alkahest = { node = "magic.alkahest", radius = 1, cost = 1, item = "alkahest", becomes = "prima_materia" }
-- Coagula: prima materia, unit for unit, into any common stone, earth or sand.
C.coagula = { node = "magic.prima_materia", into = { "W:stone", "W:granite", "W:slate", "W:calcite", "W:dark_basalt",
    "W:dirt", "W:sand", "W:white_sand", "W:gravel" } }

-- The Panacea heals and cures everyone within `radius` of its drinker.
C.panacea = { radius = 6, heal = 27, cures = { "poison", "wither", "radiation", "burning" } }

-- The Phoenix (brief §6.9): once in `every` ticks (three sun-days), a
-- death drops nothing (Life's keep_inventory, its answer to L-M7).
C.phoenix = { node = "magic.phoenix", every = 72000, rises = "The phoenix rises: you keep what you carried." }

-- The Chymical Wedding (brief §7.3): an athanor with a Sol sigil on one
-- side, Luna's opposite and a quintessence glyph on top; a player who
-- knows the Wedding and completes it is given the Wedding Crown.
C.wedding = { node = "magic.chymical_wedding", crown = "wedding_crown", discovery = 50 }

-- The living works of tier 6 (brief §6.9): two familiars made, not found.
C.homunculus = {
    node = "magic.homunculus", made = true,
    model = { id = "homunculus", file = "models/homunculus.glb", texture = "models/homunculus.png" },
    name = "Homunculus", collider = { width = 0.8, height = 1.4 }, health = 12, speed = 1.0,
    vial = "homunculus_vial", food = {}, food_units = 0, discovery = 50,
    satchel = 27,                   -- slots in the satchel it carries
    reach = 8,                      -- blocks: the chests and athanors it tends
    every = 40,                     -- ticks between one block of fuel and the next
    keep = 27 * 9,                  -- units of fuel it keeps in an athanor
    fuels = { "W:coal", "C:charcoal" },
}
C.basilisk = {
    node = "magic.basilisk", made = true,
    model = { id = "basilisk", file = "models/basilisk.glb", texture = "models/basilisk.png" },
    name = "Basilisk", collider = { width = 1.0, height = 1.2 }, health = 14, speed = 0.9,
    egg = "basilisk_egg", food = {}, food_units = 0, discovery = 50,
    stare = 6,                      -- blocks: hostile creatures it sees are frozen
    freeze = 100,                   -- ticks they stay frozen
    every = 100,
    ash_every = 24000,              -- a sun-day: it sheds an ash
    ash = "basilisk_ash",
}
-- Life's creatures a guard turns on: the ones that turn on players.
C.hostile = { "spider", "cave_troll", "swamp_hag", "scurrier", "cave_rat", "ghost" }

C.tier6_living_items = {
    { id = "homunculus_vial", name = "Homunculus", description = "Paracelsus' little helper, in its vial. Use it to let it out." },
    { id = "basilisk_egg", name = "Basilisk egg", description = "A hen's egg kept under vermilion. Use it to hatch it." },
    { id = "basilisk_ash", name = "Basilisk ash", description = "What a basilisk sheds. On copper, it is Spanish gold." },
    { id = "beast_essence", name = "Beast essence", description = "A creature's essence, distilled. Give it to a familiar." },
}
C.tier6_living_recipes = {
    { id = "homunculus_vial", station = "athanor", node = "magic.homunculus", degree = 1, days = 40,
        inputs = { { "conjoined_matter", count = 1 }, { "elixir_vitae", count = 1 }, { "caput_corvi", count = 1 } },
        tools = { { "philosophers_egg", wear = 0 } }, outputs = { { "homunculus_vial", count = 1 } } },
    { id = "basilisk_egg", station = "athanor", node = "magic.basilisk", degree = 1, days = 7,
        inputs = { { "L:egg", count = 1 }, { "vermilion", count = 1 } }, outputs = { { "basilisk_egg", count = 1 } } },
}
-- Theophilus' Spanish gold, while the world allows transmutation.
C.spanish_gold = { node = "magic.basilisk", inputs = { { "basilisk_ash", count = 1 }, { "C:copper_ingot", count = 1 } },
    outputs = { { "C:gold_ingot", count = 1 } } }

-- Essences of the beasts: every `every`th creature of a kind a player kills,
-- with a phial on them, gives its essence; fed to a familiar it is a trait
-- (three, the oldest given way). A kind's first essence is a discovery.
C.essences = {
    node = "magic.essentia_animalium", every = 3, insight = 10, slots = 3,
    traits = { horse = { speed = 1.5 }, mammoth = { health = 2 }, bat = { sense = 2 } },
}

-- The Greater Elementals: each familiar's third gift.
C.greater = { node = "magic.greater_elementals", every = 100, alight = 60, heal = 1, scout = 200 }

-- The Microcosm (brief §6.11): a world in the Egg — each adept's own
-- floating island, an instance of one template keyed by the first 16 hex
-- of their UUID, entered and left by using the Philosophers' Egg in hand.
C.microcosm = {
    node = "magic.microcosm",
    template = "microcosm",         -- qualified: tiamat_default_magic:microcosm
    egg = "philosophers_egg",
    radius = 24, depth = 12, top = 64, -- blocks: the island's half-width, its depth, and where its turf lies
    arrive = { x = 0.5, y = 66, z = 0.5 },
    ground = { grass = "W:grass", dirt = "W:dirt", stone = "W:stone" },
    flowers = { "W:roman_chamomile", "W:poppy", "W:bluebell" },
    discovery = 100,
}

-- As Above, So Below (brief §6.11): a correspondence gate is an emerald
-- glyph with Sol and Luna sigils on the alternate corners of the 3x3 round
-- it. Two are linked by using each in turn with a quintessence in hand;
-- stepping onto one sets its walker on the other, for quintessence.
C.correspondence = { node = "magic.as_above_so_below", cost = 5, link_with = "quintessence", per_player = 8,
    rest = 40 }                     -- ticks before a traveller can be carried again

-- The Rose Garden (brief §7.3): a Tree of Diana grown whole, with a Venus
-- sigil three blocks off on each of its four sides, set by an adept who
-- knows the Rosarium: wild flowers bloom on the grass round it.
C.rosarium = { node = "magic.rosarium", reach = 3, every = 600,
    flowers = { "W:roman_chamomile", "W:poppy", "W:bluebell", "W:peony", "W:allium" }, cells = { 10, 13 } }

C.tier6_studies = {
    { id = "study_prima_materia", name = "Study prima materia", inputs = { { "prima_materia", count = 1 } }, ticks = 6000, insight = 200 },
    { id = "study_red_stone", name = "Study the Red Stone", inputs = { { "red_stone", count = 1 } }, ticks = 12000, insight = 1500 },
}

-- Ripley's Twelve Gates, as discoveries: the first time a player completes
-- each, 25 x its number (brief §6.2).
C.gates = { "Calcination", "Solution", "Separation", "Conjunction", "Putrefaction", "Congelation",
    "Cibation", "Sublimation", "Fermentation", "Exaltation", "Multiplication", "Projection" }
C.gate_insight = 25

-- Other discoveries of tier 3.
C.discoveries = {
    vitriol = { insight = 10, label = "V.I.T.R.I.O.L.: visit the interior of the earth" },
    herb = 5,                       -- each species' first tincture
}

-- Studies at Progress's research table (brief §6.12).
C.studies = {
    { id = "study_calx", name = "Study a calx", inputs = { { "#magic_calx", count = 1 } }, ticks = 600, insight = 15 },
    { id = "study_tincture", name = "Study a tincture", inputs = { { "#magic_tincture", count = 1 } }, ticks = 1200, insight = 20 },
    { id = "study_vitriol", name = "Study vitriol", inputs = { { "green_vitriol", count = 1 } }, ticks = 1800, insight = 30 },
    { id = "study_quicksilver", name = "Study quicksilver", inputs = { { "#quicksilver", count = 1 } }, ticks = 2400, insight = 40 },
    { id = "study_aqua_regia", name = "Study aqua regia", inputs = { { "aqua_regia", count = 1 } }, ticks = 3600, insight = 60 },
    { id = "study_caput_corvi", name = "Study the Raven's Head", inputs = { { "caput_corvi", count = 1 } }, ticks = 6000, insight = 120 },
    { id = "study_peacock", name = "Study the Peacock's Tail", inputs = { { "peacock_matter", count = 1 } }, ticks = 6000, insight = 150 },
}

-- Sigils (brief §6.5): a carved planet's sign touching a burning athanor
-- speeds its own metal's work by the setter's `magic.sigil_percent` (the
-- Signs of the Seven: 15), twice that carved from the metal's own ore.
-- Craft's `add_progress` gives the ticks. Every `every` ticks an athanor is
-- looked at, at most `budget` of them a pass.
C.sigils = {
    node = "magic.seven_metals",        -- who sees the one-click presets
    every = 200,
    budget = 64,
    ore_times = 2,
    -- What counts as a planet's metal in an athanor's inputs.
    metals = {
        sol = { "C:gold_ingot" },
        luna = { "C:silver_ingot", "silver_grain" },
        venus = { "C:copper_ingot", "aes_ustum", "verdigris", "salt_of_venus", "blue_vitriol" },
        mars = { "C:iron_bar", "crocus_martis" },
        jupiter = { "C:tin_ingot", "putty" },
        saturn = { "C:lead_ingot", "litharge", "minium", "sal_saturni" },
        mercury = { "W:cinnabar" },
    },
}

-- Familiars (brief §6.9): found, then bound. The salamander first.
C.familiars = {
    think_every = 10,               -- a bound familiar looks for its master
    near = 3,                       -- blocks: close enough, it stops
    lost = 32,                      -- blocks: further, it is set down beside them
    orphans = 64,                   -- blocks: an untracked familiar this near a joining player is cleared
    per_server = 60,                -- familiars, wild and bound, in the whole world
    base = 1,                       -- bound at once, before `magic.familiars`
}
C.salamander = {
    node = "magic.salamander",
    model = { id = "salamander", file = "models/salamander.glb", texture = "models/salamander.png" },
    name = "Salamander",
    collider = { width = 1.2, height = 1.0 },
    health = 10,
    speed = 1.3,
    check_every = 600,              -- ticks between looks into the athanors
    burn_days = 1,                  -- an athanor burning this long draws one
    reach = 16,                     -- blocks: an adept this near the athanor is the one it came for
    food = { "W:sulfur", "flowers_of_sulfur" },
    food_units = 9,
    ember = "salamander_ember",
    forge = "magic.salamander_forge", -- whose ember it leaves: the Salamander's Forge
    appears = "Something stirs in the athanor's fire.",
    bound = "The salamander curls round your ankle. It is yours.",
    discovery = 30,
}
-- The three that are found in the world (brief §6.9). Each is looked for
-- round the adepts who know it, one adept a tick, every `find_every` ticks.
C.find_every = 600
C.undine = {
    node = "magic.undine",
    model = { id = "undine", file = "models/undine.glb", texture = "models/undine.png" },
    name = "Undine", collider = { width = 1.0, height = 1.6 }, health = 10, speed = 1.0,
    food = { "rosewater" }, food_units = 27,
    appears = "Something moves in the still water.",
    bound = "The undine rises from the water. It is yours.",
    hungry = "It ripples, wanting rosewater.",
    discovery = 30,
    look = 6,                       -- blocks: the columns looked into for still water, this far out
    night = { from = 0.75, to = 0.25 }, -- time of day: it comes after dusk and before dawn
    carry = 4,                      -- blocks of water it carries, filled where it stands in water
    douse = 6,                      -- blocks: fires this near it are put out
}
C.gnome = {
    node = "magic.gnome",
    model = { id = "gnome", file = "models/gnome.glb", texture = "models/gnome.png" },
    name = "Gnome", collider = { width = 0.9, height = 1.5 }, health = 10, speed = 1.1,
    food = { "silver_grain" }, food_units = 27,
    appears = "A small figure watches you from the dark.",
    bound = "The gnome doffs its cap. It is yours.",
    hungry = "It holds out its hand for silver.",
    discovery = 30,
    bands = { dark_caves = true },  -- World's depth bands it lives in: the Gloam and below
    sense = 8,                      -- blocks: ore within this glints, a layer a thought
}
C.sylph = {
    node = "magic.sylph",
    model = { id = "sylph", file = "models/sylph.glb", texture = "models/sylph.png" },
    name = "Sylph", collider = { width = 0.9, height = 1.8 }, health = 8, speed = 1.4,
    food = { "aqua_vitae" }, food_units = 27,
    appears = "The wind turns, and something rides it.",
    bound = "The sylph settles on your shoulder. It is yours.",
    hungry = "It swirls, wanting aqua vitae.",
    discovery = 30,
    biomes = { alpine_highlands = true, frozen_wastes = true, icefall = true },
    weathers = { storm = true, blizzard = true },
    safe = 3,                       -- blocks a body falls unhurt (Life's own rule)
    mercy = 2,                      -- health healed a block fallen past that: a soft landing
}

C.familiar_items = {
    { id = "salamander_ember", name = "Salamander's ember",
        description = "It never cools. In an athanor's vessel slot it blows the 4th degree, like bellows." },
}

-- Pyrite in the rain (weathering.lua): a random tick under open sky while
-- one of these falls weathers it, and dug it gives green vitriol.
C.weathering = {
    block = "W:pyrite",
    becomes = "green_vitriol",
    wet = { rain = true, storm = true },
}

-- The Mute Book's line for a node whose recipes are too many to list one
-- by one.
C.book_notes = {
    ["magic.spagyric_tincture"] = "a handful of any herb + spirit of wine  ->  its planet's tincture, in the athanor, in Maria's bath (1st degree), a day",
    ["magic.simple_elixirs"] = "a tincture + a phial  ->  that planet's elixir, by hand",
}

-- Tier 7 (brief §5.5): the Great Arcanum ----------------------------------------------

C.tier7_items = {
    { id = "rebis", name = "The Rebis", description = "The two-thing: the Red King and the White Queen made one. The key of worlds." },
    { id = "quintessence_fire", name = "Quintessence of Fire", description = "The pure essence of fire, drawn from a salamander in the Circle." },
    { id = "quintessence_water", name = "Quintessence of Water", description = "The pure essence of water, drawn from an undine in the Circle." },
    { id = "quintessence_air", name = "Quintessence of Air", description = "The pure essence of air, drawn from a sylph in the Circle." },
    { id = "quintessence_earth", name = "Quintessence of Earth", description = "The pure essence of earth, drawn from a gnome in the Circle." },
}

C.tier7_recipes = {
    -- The Rebis (brief §7.5): the two Stones and the green lion, Sol carved
    -- in gold ore and Luna in silver, joined in the Egg; the Wedding Crown
    -- stands for the Wedding the athanor has seen, and is kept.
    { id = "rebis", station = "athanor", node = "magic.rebis", degree = 1, days = 7,
        inputs = { { "red_stone", count = 1 }, { "white_stone", count = 1 }, { "green_lion", count = 1 },
            { glyph = "sol", material = "W:gold_ore", count = 1 }, { glyph = "luna", material = "W:silver_ore", count = 1 } },
        tools = { { "philosophers_egg", wear = 0 }, { "wedding_crown", wear = 0 } }, outputs = { { "rebis", count = 1 } } },
}

-- Lapis Infinitus (brief §5.5): the Stone multiplies in one day, fed a
-- quintessence in place of Gate XI's quicksilver.
C.lapis = { node = "magic.lapis_infinitus", days = 1 }

-- Gate XII, projection on the world (brief §6.10): a Red Stone and `cost`
-- quintessence used on the ground turn base-metal ore within `radius` to
-- gold ore, `per_tick` blocks a tick, and heal every creature and player
-- within `heal_radius`. With transmutation off, it only heals.
C.world_projection = {
    node = "magic.gate_projection", stone = "red_stone", cost = 20, radius = 2, per_tick = 1,
    ores = { "W:copper_ore", "W:tin_ore", "W:lead_ore", "W:iron_ore" }, becomes = "W:gold_ore",
    heal = 10, heal_radius = 8, gate = 12,
}

-- Quintessences of the Four (brief §5.5): an elemental walking with an
-- adept who stands on the Circle of Four's centre gives its element's
-- quintessence for every `days` philosophical days spent there.
C.elemental_quintessences = {
    node = "magic.elemental_quintessences", days = 1, every = 100, reach = 8,
    kinds = { salamander = "fire", undine = "water", sylph = "air", gnome = "earth" },
}

-- The Universal Medicine: every `every` ticks, other players within
-- `radius` of an adept who knows it heal `heal`.
C.universal_medicine = { node = "magic.universal_medicine", radius = 8, every = 100, heal = 1 }

-- Thrice-Greatest: the Tablet speaks its whole text (Newton's translation,
-- c. 1680) to whoever has it; a golden aura about them; the title on
-- their tongue in chat.
C.trismegistus = {
    node = "magic.hermes_trismegistus", title = "Trismegistus", aura_every = 40,
    tablet = {
        "Tis true without lying, certain & most true.",
        "That which is below is like that which is above & that which is above is like that which is below to do the miracles of one only thing.",
        "And as all things have been & arose from one by the mediation of one: so all things have their birth from this one thing by adaptation.",
        "The Sun is its father, the moon its mother, the wind hath carried it in its belly, the earth its nurse.",
        "The father of all perfection in the whole world is here.",
        "Its force or power is entire if it be converted into earth.",
        "Separate thou the earth from the fire, the subtle from the gross sweetly with great industry.",
        "It ascends from the earth to the heaven & again it descends to the earth and receives the force of things superior & inferior.",
        "By this means you shall have the glory of the whole world & thereby all obscurity shall fly from you.",
        "Its force is above all force. For it vanquishes every subtle thing & penetrates every solid thing.",
        "So was the world created.",
        "From this are & do come admirable adaptations whereof the means is here in this.",
        "Hence I am called Hermes Trismegist, having the three parts of the philosophy of the whole world.",
        "That which I have said of the operation of the Sun is accomplished & ended.",
    },
}

C.tier7_studies = {
    { id = "study_elemental_quintessence", name = "Study an elemental quintessence",
        inputs = { { "#magic_elemental_quintessence", count = 1 } }, ticks = 9000, insight = 400 },
}

-- Woven worlds (brief §6.11) ---------------------------------------------------------
--
-- Five templates, one an archetype; each world an instance whose KEY holds
-- its parameters: `<weaver's first 16 hex>_<n>_<vein>_<sea>` (letters,
-- digits and `_`, the engine's rule). The generator reads them back from
-- `pos.domain`, so nothing is stored for it and every worker agrees.
C.worlds = {
    node = "magic.opus_mundi",
    skies_node = "magic.planetary_skies",
    veins_node = "magic.planetary_veins",
    spirits_node = "magic.native_spirits",
    gate_node = "magic.worldgate",
    solve_node = "magic.solve_et_coagula",
    discovery = 1000,               -- the first world woven (brief §6.12)
    -- What a weaving consumes (brief §6.11).
    costs = { { "rebis", count = 1 }, { "quintessence_fire", count = 1 }, { "quintessence_water", count = 1 },
        { "quintessence_air", count = 1 }, { "quintessence_earth", count = 1 }, { "prima_materia", units = 27 * 27 },
        { "red_stone", count = 1 } },
    returned = 27 * 27 // 2,        -- prima materia units Solve et Coagula gives back
    arrive = { x = 0.5, y = 68, z = 0.5 },
    landing = { radius = 7, top = 66, depth = 5 },  -- the ground every world has under its arrival
    seas = { low = 56, mid = 62, high = 68 },
    archetypes = {
        { id = "earth", name = "Earth", spirit = "gnome", blurb = "Caverns and crystal, and the ores lie deep." },
        { id = "water", name = "Water", spirit = "undine", blurb = "An archipelago on a world-wide sea." },
        { id = "air", name = "Air", spirit = "sylph", blurb = "Floating islands over nothing at all." },
        { id = "fire", name = "Fire", spirit = "salamander", blurb = "Basalt and ash on a sea of lava." },
        { id = "quintessence", name = "Quintessence", blurb = "Calcite and crystal, and light." },
    },
    veins = {                       -- planet -> the ore that runs rich (planetary_veins)
        sol = "W:gold_ore", luna = "W:silver_ore", venus = "W:copper_ore", mars = "W:iron_ore",
        jupiter = "W:tin_ore", saturn = "W:lead_ore", mercury = "W:cinnabar",
    },
    common_ores = { "W:copper_ore", "W:iron_ore", "W:coal", "W:tin_ore" },
    ores_per_chunk = 6, rich_per_chunk = 18,
    -- Skies, by name: the archetypes' own, and the seven planets'
    -- (planetary_skies). `day` and `night` are the sky, `sun` the light.
    skies = {
        earth = { day = { 0.55, 0.62, 0.55 }, night = { 0.03, 0.04, 0.03 }, sun = { 1.0, 0.92, 0.8 } },
        water = { day = { 0.45, 0.65, 0.85 }, night = { 0.02, 0.03, 0.07 }, sun = { 0.95, 0.98, 1.0 } },
        air = { day = { 0.7, 0.82, 0.95 }, night = { 0.05, 0.06, 0.12 }, sun = { 1.0, 1.0, 1.0 } },
        fire = { day = { 0.6, 0.3, 0.15 }, night = { 0.15, 0.04, 0.02 }, sun = { 1.0, 0.6, 0.35 } },
        quintessence = { day = { 0.85, 0.85, 0.75 }, night = { 0.08, 0.07, 0.1 }, sun = { 1.0, 0.98, 0.9 } },
        saturn = { day = { 0.42, 0.42, 0.45 }, night = { 0.03, 0.03, 0.04 }, sun = { 0.75, 0.75, 0.78 } },
        sol = { day = { 0.9, 0.75, 0.35 }, night = { 0.08, 0.05, 0.02 }, sun = { 1.0, 0.85, 0.5 } },
        luna = { day = { 0.75, 0.78, 0.85 }, night = { 0.06, 0.07, 0.12 }, sun = { 0.85, 0.9, 1.0 } },
        venus = { day = { 0.85, 0.6, 0.65 }, night = { 0.08, 0.03, 0.06 }, sun = { 1.0, 0.8, 0.8 } },
        mars = { day = { 0.75, 0.35, 0.25 }, night = { 0.1, 0.02, 0.02 }, sun = { 1.0, 0.65, 0.5 } },
        jupiter = { day = { 0.45, 0.5, 0.85 }, night = { 0.03, 0.03, 0.1 }, sun = { 0.9, 0.9, 1.0 } },
        mercury = { day = { 0.55, 0.78, 0.75 }, night = { 0.03, 0.07, 0.07 }, sun = { 0.9, 1.0, 0.95 } },
    },
    spirits = 4,                    -- wild elementals a world keeps near an arrival (native_spirits)
    spirit_every = 400,             -- ticks between one spirit's birth and the next
    spirit_reach = 32,              -- blocks: the wild ones near an arrival that count towards those
    gate_rest = 40,                 -- ticks before a World-Gate carries the same traveller again
}

-- The Mute Book's lines for tier 7's works that are not recipes.
C.book_notes["magic.gate_projection"] = "a Red Stone + 20 quintessence, used on the ground  ->  copper, tin, lead and iron ore near it become gold ore, and all near are healed"
C.book_notes["magic.elemental_quintessences"] = "stand at the centre of a Circle of Four with an elemental walking with you: a day there, and it gives its element's quintessence"
C.book_notes["magic.opus_mundi"] = "the Loom: a quintessence glyph in crystal, the seven sigils and the emerald round it, fire, water, air and earth at the edges. Use it with the Rebis to weave; with anything else, to enter your worlds. The Egg, used inside, brings you back"
C.book_notes["magic.planetary_skies"] = "at the Loom, choose the sky your world wears"
C.book_notes["magic.planetary_veins"] = "at the Loom, choose the metal that runs rich in your world"
C.book_notes["magic.native_spirits"] = "your worlds keep wild spirits of their element near whoever walks in them"
C.book_notes["magic.worldgate"] = "use a correspondence gate's emerald with the Egg: it opens on your newest world. magic world allow <name> lets a friend through"
C.book_notes["magic.solve_et_coagula"] = "at the Loom, dissolve a world: everyone in it comes home, and half its prima materia returns"
C.book_notes["magic.universal_medicine"] = "friends within eight blocks of you slowly heal"
C.book_notes["magic.hermes_trismegistus"] = "magic tablet: the Emerald Tablet's whole text"

return C
