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

-- The athanor (brief §6.1) ---------------------------------------------------------
--
-- "The philosophers' oven": a tower furnace built to hold a low, even heat.
-- One Craft station that burns and works on its own; the vessels in its two
-- tool slots turn it into every apparatus, and cost no blocks.
C.athanor = {
    station = "athanor",                                -- qualified: tiamat_default_magic:athanor
    name = "Athanor",
    block = { id = "athanor", name = "Athanor", description = "The philosophers' furnace: a slow tower fire. Light it with a striker.",
        hardness = 2.0, tags = { "stone", "hard" } },
    lit = { id = "athanor_lit", name = "Athanor (burning)", description = "A slow fire, held even for days.",
        hardness = 2.0, tags = { "stone", "hard", "glowing" }, light = { r = 12, g = 7, b = 2 } },
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
    night_sight = { every = 40, particles = 6, colour = { r = 0.7, g = 0.9, b = 1.0, a = 0.35 } },
    -- Through Life's composed abilities (its answer to L-M3): a speed that
    -- multiplies in with Life's own cold and hunger, under this mod's name.
    swiftness = { speed_mul = 1.3 },
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

return C
