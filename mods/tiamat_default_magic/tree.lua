-- SPDX-FileCopyrightText: Iridesium
-- SPDX-License-Identifier: GPL-3.0-only
--
-- The tree: every node of the magic path, tiers 3 to 7 (brief §5), as DATA
-- and nothing else. `path.lua` registers it with Progress; `tools/check_tree.py`
-- reads this very file to prove the graph sound, so it stays a plain table
-- literal — one node a line, no code, no locals.
--
-- A node is `id` (the part after `magic.`), `tier`, `cost` in insight,
-- `requires` (ids written without a prefix are `magic.` nodes), `branch`
-- (the brief's code: GATE, FIRE, MENS, PLAN, SPAG, ELEM, SIGN, OPUS, COSM;
-- Progress does not group by it yet, sibling ask P-M1), `star` when a
-- child can enjoy it, `label`, `text` (the first sentence a child reads,
-- 90 characters at most) and `effects` (integers under `magic.*`, read here,
-- or `craft.*`, read by Craft; Progress sums them per player, live).
--
-- Most nodes unlock nothing yet: the Art behind them is built tier by tier
-- (brief §17). Learning one early is harmless; it is only knowledge.

return {
    -- Tier 3 — Nigredo I: the Laboratory
    { id = "hermetic_oath", tier = 3, cost = 0, requires = { "shared.fork" }, branch = "GATE", star = true, label = "The Oath", text = "You swore the Hermetic Oath. Your journey into the Art begins here." },
    { id = "athanor", tier = 3, cost = 100, requires = { "hermetic_oath" }, branch = "FIRE", star = true, label = "The Athanor", text = "Build the Athanor, the alchemist's slow tower furnace." },
    { id = "glassblowing", tier = 3, cost = 80, requires = { "hermetic_oath" }, branch = "FIRE", star = true, label = "Glassblowing", text = "Blow glass into phials and stills with an iron blowpipe." },
    { id = "bain_marie", tier = 3, cost = 60, requires = { "athanor" }, branch = "FIRE", star = true, label = "Maria's Bath", text = "Maria's water bath: a gentle heat that never burns what it warms." },
    { id = "seven_metals", tier = 3, cost = 80, requires = { "hermetic_oath" }, branch = "PLAN", star = true, label = "The Seven Metals", text = "Seven metals, seven planets: gold is the Sun, silver the Moon." },
    { id = "degrees_of_fire", tier = 3, cost = 100, requires = { "athanor" }, branch = "FIRE", label = "The Four Degrees", text = "Four heats, from warm to white-hot: sand baths and bellows." },
    { id = "gate_calcination", tier = 3, cost = 120, requires = { "athanor", "degrees_of_fire" }, branch = "GATE", label = "Gate I: Calcination", text = "The First Gate: roast metals into coloured ashes called calxes." },
    { id = "cupellation", tier = 3, cost = 120, requires = { "gate_calcination" }, branch = "PLAN", label = "The Cupel", text = "Melt lead in a bone-ash cup, and a bead of silver is left behind." },
    { id = "sigils", tier = 3, cost = 100, requires = { "seven_metals" }, branch = "SIGN", star = true, label = "Signs of the Seven", text = "Carve a planet's sign and set it by the athanor to speed its metal.", effects = { { "magic.sigil_percent", 15 } } },
    { id = "vinegar_and_wine", tier = 3, cost = 80, requires = { "bain_marie" }, branch = "MENS", label = "Wine and Vinegar", text = "Leave fruit to ferment in the bath: first wine, then vinegar." },
    { id = "verdigris", tier = 3, cost = 80, requires = { "vinegar_and_wine" }, branch = "MENS", star = true, label = "Verdigris", text = "Copper over vinegar turns bright green. It soothes burns, too." },
    { id = "aqua_vitae", tier = 3, cost = 120, requires = { "vinegar_and_wine", "glassblowing" }, branch = "MENS", label = "Aqua Vitae", text = "Distil wine into burning water, then again and again into spirit." },
    { id = "spagyric_tincture", tier = 3, cost = 140, requires = { "aqua_vitae" }, branch = "SPAG", star = true, label = "Spagyric Tinctures", text = "Soak a herb in spirit for a day to draw out its planet's tincture." },
    { id = "simple_elixirs", tier = 3, cost = 120, requires = { "spagyric_tincture" }, branch = "SPAG", star = true, label = "Simple Elixirs", text = "Drinks in phials: for strength, warmth, cool, night eyes and speed." },
    { id = "green_vitriol", tier = 3, cost = 120, requires = { "bain_marie" }, branch = "MENS", label = "Green Vitriol", text = "Pyrite left wet turns to green vitriol, a salt like green glass." },
    { id = "retort", tier = 3, cost = 80, requires = { "glassblowing" }, branch = "FIRE", label = "The Retort", text = "A glass retort, for distilling things that are dry." },
    { id = "oil_of_vitriol", tier = 3, cost = 150, requires = { "green_vitriol", "retort", "degrees_of_fire" }, branch = "MENS", label = "Oil of Vitriol", text = "Heat green vitriol hard and a strong oil drips out: oil of vitriol." },
    { id = "blue_vitriol", tier = 3, cost = 100, requires = { "oil_of_vitriol", "verdigris" }, branch = "PLAN", star = true, label = "Vitriol of Venus", text = "Copper in oil of vitriol grows deep blue crystals." },
    { id = "salamander", tier = 3, cost = 160, requires = { "athanor", "gate_calcination" }, branch = "ELEM", star = true, label = "The Salamander", text = "Keep an athanor burning a whole day and a fire lizard may come.", effects = { { "craft.fuel_percent", 50 } } },
    { id = "gate_solution", tier = 3, cost = 140, requires = { "gate_calcination", "vinegar_and_wine" }, branch = "GATE", label = "Gate II: Solution", text = "The Second Gate: dissolve the ashes into salts." },
    { id = "gate_separation", tier = 3, cost = 150, requires = { "gate_solution", "aqua_vitae" }, branch = "GATE", label = "Gate III: Separation", text = "The Third Gate: split any plant into its spirit, oil and salt." },

    -- Tier 4 — Nigredo II: the Menstrua and the Black
    { id = "aludel", tier = 4, cost = 180, requires = { "degrees_of_fire" }, branch = "FIRE", label = "The Aludel", text = "The aludel: a pot where vapours rise and settle as fine flowers." },
    { id = "pelican", tier = 4, cost = 180, requires = { "aqua_vitae", "glassblowing" }, branch = "FIRE", label = "The Pelican", text = "A glass pelican: what rises inside it flows back down, for ever." },
    { id = "philosophers_egg", tier = 4, cost = 200, requires = { "pelican" }, branch = "FIRE", label = "The Philosophers' Egg", text = "A sealed glass egg, where every long work of the Art is cooked." },
    { id = "flowers_of_sulfur", tier = 4, cost = 150, requires = { "aludel" }, branch = "MENS", star = true, label = "Flowers of Sulfur", text = "Sulfur rises in the aludel and settles as pure yellow flowers." },
    { id = "quicksilver", tier = 4, cost = 200, requires = { "retort", "degrees_of_fire" }, branch = "PLAN", star = true, label = "Quicksilver", text = "Roast red cinnabar and a silver liquid metal runs out: quicksilver." },
    { id = "vermilion", tier = 4, cost = 180, requires = { "quicksilver", "flowers_of_sulfur" }, branch = "PLAN", label = "Vermilion", text = "Quicksilver and sulfur, raised together, make bright red vermilion." },
    { id = "amalgams", tier = 4, cost = 200, requires = { "quicksilver" }, branch = "PLAN", label = "Amalgams", text = "Quicksilver swallows gold, silver and tin into soft amalgams." },
    { id = "saltpeter", tier = 4, cost = 200, requires = { "gate_separation" }, branch = "MENS", label = "The Nitre Bed", text = "A heap of rotting plants and ash, kept warm, grows saltpeter." },
    { id = "aqua_fortis", tier = 4, cost = 250, requires = { "saltpeter", "green_vitriol", "retort" }, branch = "MENS", label = "Aqua Fortis", text = "Strong water: it eats silver but leaves gold alone." },
    { id = "spirit_of_salt", tier = 4, cost = 200, requires = { "oil_of_vitriol" }, branch = "MENS", label = "Spirit of Salt", text = "Salt and oil of vitriol give spirit of salt, a biting vapour." },
    { id = "sal_ammoniac", tier = 4, cost = 200, requires = { "aludel", "gate_calcination" }, branch = "MENS", label = "Sal Ammoniac", text = "Bone and salt, heated in the aludel, give a salt that rises." },
    { id = "aqua_regia", tier = 4, cost = 300, requires = { "aqua_fortis", "sal_ammoniac" }, branch = "MENS", label = "Aqua Regia", text = "Royal water, strong enough to dissolve even gold." },
    { id = "arbor_dianae", tier = 4, cost = 250, requires = { "aqua_fortis", "amalgams" }, branch = "PLAN", star = true, label = "The Tree of Diana", text = "Silver amalgam in strong water grows a sparkling silver tree." },
    { id = "gate_conjunction", tier = 4, cost = 250, requires = { "gate_separation", "amalgams" }, branch = "GATE", label = "Gate IV: Conjunction", text = "The Fourth Gate: the King and Queen of the matter are wed." },
    { id = "gate_putrefaction", tier = 4, cost = 300, requires = { "gate_conjunction", "philosophers_egg" }, branch = "GATE", label = "Gate V: Putrefaction", text = "The Fifth Gate: the sealed matter turns black as a raven's head." },
    { id = "cauda_pavonis", tier = 4, cost = 250, requires = { "gate_putrefaction" }, branch = "OPUS", star = true, label = "The Peacock's Tail", text = "Washed, the black matter shimmers every colour, like a peacock's tail." },
    { id = "theriac", tier = 4, cost = 200, requires = { "simple_elixirs", "gate_separation" }, branch = "SPAG", label = "Theriac", text = "Galen's great antidote, good against every poison." },
    { id = "exalted_tinctures", tier = 4, cost = 220, requires = { "pelican", "spagyric_tincture" }, branch = "SPAG", label = "Exalted Tinctures", text = "Circulate tinctures in the pelican: every elixir lasts twice as long.", effects = { { "magic.elixir_duration_percent", 100 } } },
    { id = "palingenesis", tier = 4, cost = 250, requires = { "gate_separation", "philosophers_egg" }, branch = "SPAG", star = true, label = "Palingenesis", text = "Warm a plant's ash in a phial and the living plant comes back." },
    { id = "undine", tier = 4, cost = 280, requires = { "salamander", "bain_marie" }, branch = "ELEM", star = true, label = "The Undine", text = "A water spirit, found in still water at night. It carries water for you." },
    { id = "gnome", tier = 4, cost = 280, requires = { "salamander", "cupellation" }, branch = "ELEM", star = true, label = "The Gnome", text = "An earth spirit of the deep caves. It shows you where ore is hidden." },
    { id = "sylph", tier = 4, cost = 280, requires = { "salamander", "aludel" }, branch = "ELEM", star = true, label = "The Sylph", text = "An air spirit of stormy peaks. It gives you a jump in mid-air." },
    { id = "talismans", tier = 4, cost = 220, requires = { "sigils", "amalgams" }, branch = "SIGN", label = "Planetary Talismans", text = "Strike a planet's sign in its metal and wear it for a gift." },
    { id = "hermetic_seal", tier = 4, cost = 250, requires = { "sigils", "glassblowing" }, branch = "SIGN", label = "The Hermetic Seal", text = "Carve the Seal: nobody but you and your friends may build near it." },
    { id = "ouroboros", tier = 4, cost = 200, requires = { "sigils", "pelican" }, branch = "SIGN", label = "The Ouroboros", text = "Ring your athanor with the serpent that eats its tail: works go faster.", effects = { { "magic.long_work_percent", -20 } } },
    { id = "phosphorus", tier = 4, cost = 220, requires = { "oil_of_vitriol", "gate_calcination" }, branch = "MENS", star = true, label = "Phosphorus", text = "From bones comes phosphorus, the light-bearer, which glows by itself." },

    -- Tier 5 — Albedo and Citrinitas: the White Work
    { id = "gate_congelation", tier = 5, cost = 400, requires = { "gate_putrefaction", "aludel" }, branch = "GATE", label = "Gate VI: Congelation", text = "The Sixth Gate: make the restless spirits sit still." },
    { id = "gate_cibation", tier = 5, cost = 450, requires = { "gate_congelation" }, branch = "GATE", label = "Gate VII: Cibation", text = "The Seventh Gate: feed the matter little by little, and it works faster.", effects = { { "magic.long_work_percent", -15 } } },
    { id = "gate_sublimation", tier = 5, cost = 450, requires = { "gate_congelation", "flowers_of_sulfur" }, branch = "GATE", label = "Gate VIII: Sublimation", text = "The Eighth Gate: the eagle flies, and the matter rises pure." },
    { id = "albedo", tier = 5, cost = 600, requires = { "gate_congelation", "cauda_pavonis" }, branch = "OPUS", star = true, label = "Albedo: the White Stone", text = "Seven days in the Egg make the White Stone, which turns lead to silver." },
    { id = "sal_alembroth", tier = 5, cost = 400, requires = { "gate_sublimation", "sal_ammoniac", "quicksilver" }, branch = "MENS", label = "Sal Alembroth", text = "Quicksilver and sal ammoniac raised together: the salt of wisdom." },
    { id = "citrinitas", tier = 5, cost = 600, requires = { "albedo", "gate_sublimation" }, branch = "OPUS", label = "Citrinitas", text = "The White Stone yellows into Solar Sulfur, the Yellow King." },
    { id = "aurum_potabile", tier = 5, cost = 550, requires = { "aqua_regia", "citrinitas" }, branch = "SPAG", label = "Aurum Potabile", text = "Gold you can drink. It heals every hurt and cures every ill." },
    { id = "elixir_vitae", tier = 5, cost = 500, requires = { "theriac", "exalted_tinctures" }, branch = "SPAG", label = "Elixir of Life (lesser)", text = "The lesser Elixir of Life: strength and healing for a long while." },
    { id = "quintessence", tier = 5, cost = 450, requires = { "exalted_tinctures", "pelican" }, branch = "SPAG", label = "The Fifth Essence", text = "Spirit circulated a thousand times: the fifth essence. Your well grows.", effects = { { "magic.quintessence_max", 20 } } },
    { id = "caduceus", tier = 5, cost = 500, requires = { "quintessence", "talismans" }, branch = "SIGN", star = true, label = "The Caduceus", text = "Hermes' staff: step through space, and share your elixirs with friends." },
    { id = "elemental_circle", tier = 5, cost = 500, requires = { "undine", "gnome", "sylph" }, branch = "ELEM", star = true, label = "The Circle of Four", text = "Carve the four elements in a circle, and two spirits may walk with you.", effects = { { "magic.familiars", 1 } } },
    { id = "salamander_forge", tier = 5, cost = 450, requires = { "elemental_circle", "degrees_of_fire" }, branch = "ELEM", label = "The Salamander's Forge", text = "Your salamander's ember keeps the athanor white-hot without bellows." },
    { id = "undine_tides", tier = 5, cost = 450, requires = { "elemental_circle" }, branch = "ELEM", label = "The Undine's Gift", text = "With your undine near, you breathe water and swim swift." },
    { id = "gnome_delving", tier = 5, cost = 450, requires = { "elemental_circle" }, branch = "ELEM", label = "The Gnome's Delving", text = "Your gnome digs a tunnel ahead of you." },
    { id = "sylph_flight", tier = 5, cost = 500, requires = { "elemental_circle" }, branch = "ELEM", star = true, label = "The Sylph's Wings", text = "Your sylph lends you wings for ten seconds." },
    { id = "orichalcum_awakened", tier = 5, cost = 600, requires = { "albedo", "amalgams" }, branch = "PLAN", label = "Orichalcum Awakened", text = "Wake sleeping orichalcum, and make tools of the living metal." },
    { id = "kerotakis", tier = 5, cost = 400, requires = { "amalgams", "degrees_of_fire" }, branch = "FIRE", label = "Maria's Kerotakis", text = "Maria's palette tints metals: gold and silver make electrum." },
    { id = "greater_talismans", tier = 5, cost = 500, requires = { "talismans", "kerotakis" }, branch = "SIGN", label = "Greater Talismans", text = "Talismans grow stronger, and two worn together both work.", effects = { { "magic.talisman_grade", 1 }, { "magic.talisman_slots", 1 } } },
    { id = "atalanta_fugiens", tier = 5, cost = 350, requires = { "cauda_pavonis" }, branch = "OPUS", star = true, label = "Atalanta Fugiens", text = "Maier's book of fifty emblems, each with music. Collect them all." },
    { id = "assay", tier = 5, cost = 400, requires = { "aqua_fortis", "cupellation" }, branch = "PLAN", label = "The Assay", text = "The assayer's art: every study at the research table teaches more.", effects = { { "magic.study_bonus_percent", 25 } } },
    { id = "greater_seal", tier = 5, cost = 450, requires = { "hermetic_seal", "gate_congelation" }, branch = "SIGN", label = "The Greater Seal", text = "A wider Seal, and doors that open only for your friends." },

    -- Tier 6 — Rubedo: the Red Work
    { id = "gate_fermentation", tier = 6, cost = 800, requires = { "gate_cibation", "citrinitas" }, branch = "GATE", label = "Gate IX: Fermentation", text = "The Ninth Gate: the Stone is leavened with gold." },
    { id = "rubedo", tier = 6, cost = 1200, requires = { "gate_fermentation", "aurum_potabile" }, branch = "OPUS", star = true, label = "Rubedo: the Philosophers' Stone", text = "Forty days in the Egg make the Red Stone, which turns metal to gold." },
    { id = "gate_exaltation", tier = 6, cost = 900, requires = { "rubedo" }, branch = "GATE", label = "Gate X: Exaltation", text = "The Tenth Gate: the Stone's power is doubled.", effects = { { "magic.projection_percent", 100 } } },
    { id = "gate_multiplication", tier = 6, cost = 1000, requires = { "gate_exaltation" }, branch = "GATE", label = "Gate XI: Multiplication", text = "The Eleventh Gate: one Stone, fed gold, becomes two." },
    { id = "alkahest", tier = 6, cost = 900, requires = { "aqua_regia", "gate_sublimation" }, branch = "MENS", label = "The Alkahest", text = "The universal solvent. It melts stone back into first matter." },
    { id = "prima_materia", tier = 6, cost = 800, requires = { "alkahest" }, branch = "MENS", label = "Prima Materia", text = "First matter can become any common stone, earth or sand." },
    { id = "panacea", tier = 6, cost = 1000, requires = { "rubedo", "elixir_vitae" }, branch = "SPAG", label = "The Panacea", text = "The cure for all ills, for you and everyone near you." },
    { id = "homunculus", tier = 6, cost = 1200, requires = { "gate_putrefaction", "elixir_vitae", "elemental_circle" }, branch = "ELEM", star = true, label = "The Homunculus", text = "A little helper made in the Egg. It carries things and feeds your fires." },
    { id = "basilisk", tier = 6, cost = 900, requires = { "gate_putrefaction", "vermilion" }, branch = "ELEM", star = true, label = "The Basilisk", text = "A grumpy rooster-lizard hatched from an egg. Its stare freezes foes." },
    { id = "essentia_animalium", tier = 6, cost = 800, requires = { "homunculus" }, branch = "ELEM", label = "Essences of the Beasts", text = "Distil the essence of each animal and give its gift to a spirit." },
    { id = "microcosm", tier = 6, cost = 1100, requires = { "quintessence", "philosophers_egg", "prima_materia" }, branch = "COSM", star = true, label = "The Microcosm", text = "A little world in the Egg: your own floating island to visit." },
    { id = "as_above_so_below", tier = 6, cost = 1000, requires = { "microcosm", "hermetic_seal" }, branch = "COSM", label = "As Above, So Below", text = "Two linked gates: step on one and arrive at the other." },
    { id = "phoenix", tier = 6, cost = 1000, requires = { "rubedo", "salamander_forge" }, branch = "ELEM", star = true, label = "The Phoenix", text = "The phoenix brings your lost things back to you after you die." },
    { id = "rosarium", tier = 6, cost = 900, requires = { "palingenesis", "essentia_animalium" }, branch = "SPAG", star = true, label = "The Rose Garden", text = "The Rose Garden: flowers bloom wild inside it, and roses grow back." },
    { id = "wise_mind", tier = 6, cost = 800, requires = { "quintessence", "rubedo" }, branch = "SPAG", label = "The Stone of the Mind", text = "The Stone of the Mind: your well of quintessence grows deep and quick.", effects = { { "magic.quintessence_max", 40 }, { "magic.quintessence_regen_percent", 100 } } },
    { id = "greater_elementals", tier = 6, cost = 1000, requires = { "elemental_circle", "essentia_animalium" }, branch = "ELEM", label = "The Greater Elementals", text = "Three spirits walk with you, and each learns a new gift.", effects = { { "magic.familiars", 1 } } },
    { id = "chymical_wedding", tier = 6, cost = 900, requires = { "gate_conjunction", "rubedo", "albedo" }, branch = "OPUS", label = "The Chymical Wedding", text = "The Red King and the White Queen are joined in a great ceremony." },

    -- Tier 7 — The Great Arcanum
    { id = "gate_projection", tier = 7, cost = 1500, requires = { "gate_multiplication" }, branch = "GATE", label = "Gate XII: Projection", text = "The Twelfth Gate: cast the Stone upon the earth, and ore turns to gold." },
    { id = "rebis", tier = 7, cost = 1800, requires = { "chymical_wedding", "gate_multiplication" }, branch = "OPUS", label = "The Rebis", text = "The Rebis: two things made one, the key to making worlds." },
    { id = "elemental_quintessences", tier = 7, cost = 1500, requires = { "greater_elementals", "quintessence" }, branch = "ELEM", label = "Quintessences of the Four", text = "Draw from each spirit the pure essence of its element." },
    { id = "opus_mundi", tier = 7, cost = 3000, requires = { "rebis", "elemental_quintessences", "microcosm", "prima_materia" }, branch = "COSM", star = true, label = "Opus Mundi", text = "The Loom of the Four: weave a whole new world of your own." },
    { id = "planetary_skies", tier = 7, cost = 1500, requires = { "opus_mundi" }, branch = "COSM", star = true, label = "Planetary Skies", text = "Choose the sky your woven world wears." },
    { id = "native_spirits", tier = 7, cost = 1500, requires = { "opus_mundi", "greater_elementals" }, branch = "COSM", label = "Native Spirits", text = "Your woven world is born with wild spirits of its element." },
    { id = "planetary_veins", tier = 7, cost = 1500, requires = { "opus_mundi", "gate_projection" }, branch = "COSM", label = "Planetary Veins", text = "Choose which metal runs rich in your woven world." },
    { id = "worldgate", tier = 7, cost = 2000, requires = { "opus_mundi", "as_above_so_below" }, branch = "COSM", label = "The World-Gate", text = "A standing gate into your woven world, for friends you allow." },
    { id = "solve_et_coagula", tier = 7, cost = 2500, requires = { "opus_mundi" }, branch = "COSM", label = "Solve et Coagula", text = "Dissolve a woven world back into chaos, and keep half its matter." },
    { id = "universal_medicine", tier = 7, cost = 2000, requires = { "panacea", "rebis" }, branch = "SPAG", label = "The Universal Medicine", text = "Friends near you slowly heal while you stand among them." },
    { id = "lapis_infinitus", tier = 7, cost = 2500, requires = { "gate_projection", "gate_multiplication" }, branch = "OPUS", label = "Lapis Infinitus", text = "The endless Stone: ten times the gold, and it multiplies in a day.", effects = { { "magic.projection_percent", 800 }, { "magic.multiplication_days", -6 } } },
    { id = "hermes_trismegistus", tier = 7, cost = 4000, requires = { "opus_mundi", "lapis_infinitus", "universal_medicine", "solve_et_coagula" }, branch = "COSM", star = true, label = "Thrice-Greatest", text = "Thrice-Greatest: the Emerald Tablet speaks, and you are a master." },
}
