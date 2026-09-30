<!-- SPDX-FileCopyrightText: Iridesium -->
<!-- SPDX-License-Identifier: GPL-3.0-only -->

# Tiamat Default Magic — the brief

*Draft 2, 2026-09-29: the designer's build prompt (draft 1, 2026-09-28), with every engine and sibling fact re-checked against the stubs and the sibling repositories on 2026-09-29 and corrected in place; what changed and why is §2.1. It replaces draft 0 of this file. Draft 1 was: a brief for an AI coding assistant and the person supervising it. Design and plan only. Companion to `Tiamat_default_science-PROMPT.md` (its sibling on the other side of the Fork), to the shipped briefs of `tiamat_default_craft` and `tiamat_default_progress`, and to the long plan `schism_design.md`. Read, in this order: the engine's `api/AGENTS.md` and `api/stubs/game.lua`; the `docs/exports.md` of World, Life, UI, Craft, Progress and Weather; then this. Every engine and sibling fact below was checked against those files on 2026-09-28. **Where they disagree with this text, they win**, and the disagreement goes in `docs/engine-asks.md` or `docs/sibling-asks.md`.*

---

## 0. One paragraph

`tiamat_default_magic` is the Hermetic Art: the magic door of Progress's Fork, and everything behind it. It is **alchemy as it was actually practised**, not wand-waving: a furnace (the athanor), glassware that changes what the furnace does, reagents with their real names and their real recipes (vitriol from pyrite, *aqua fortis* from saltpeter and vitriol, *aqua regia* from that and sal ammoniac, quicksilver from cinnabar), and a spine that is George Ripley's **Twelve Gates** (1471) — Calcination to Projection — running through the colour stages of the Great Work (*nigredo*, the peacock's tail, *albedo*, *citrinitas*, *rubedo*) to the Philosophers' Stone. Around the spine hang Paracelsus' spagyric medicine and his four elementals, the homunculus, Theophilus' basilisk, the alkahest, and at the top the Hermetic creation itself: weaving a world out of prima materia. It adds **102 nodes** over tiers 1–7, is built to take **roughly sixty hours** to climb in full, gives a small child something delightful in its first half hour, and registers **five blocks**.

---

## 0.1 Where it sits

| Mod | What this mod takes from it |
|---|---|
| `tiamat_default_world` | Ores and rock (every planetary metal, pyrite, sulfur, salt, crystal, orichalcum, obsidian); ~32 plant blocks (~24 of them covers) for spagyrics; biomes and depth bands (`biome_under`, `depth_band`) for where elementals are found; `climate` |
| `tiamat_default_life` | `add_stat` for the Quintessence bar; `add_food` for every elixir; `on_eat`, `on_kill`, `on_death`, `on_sleep`; `set_alight`; `add_heat_source` / `add_contact_fire` for the athanor; `drop`; creatures' short ids for essences; the `worn` view for talismans; Life's `antidote`, `honey`, `egg`, `bone`, `wheat`, `apple`, `berries` |
| `tiamat_default_ui` (optional) | Tabs (`add_tab`) for the *Mutus Liber*, the familiar screen and the athanor's long-work dial; `widgets`, `theme`; the shape crafter, where every glyph is carved |
| `tiamat_default_craft` | The recipe registry, stations, fuels, groups, tool registration, `register_glyph` / `glyph_of`, `wear`, the firsts; its kiln, workbench and anvil; its ingots, glass, charcoal, `bone_needle`, `bark_strip`, leather, cloth |
| `tiamat_default_progress` | `register_path` (the door), `register_node` (the tree), `register_study`, `register_discovery`, `award`, `has`, `effects_of`, `on_fork` / `on_repath` |
| `tiamat_weather` (optional) | `falling_on` (pyrite weathering in rain), `weather_at` (sylphs in storms), `extinguish` (the undine), `on_lightning` (a bolt on an athanor is a sign) |
| `tiamat_default_science` | **Nothing.** Siblings, never dependants. Both are loaded in the same world so that a magic player and a science player can trade; neither names the other. |

**Division of labour, restated so nobody re-litigates it.** Craft owns recipes, stations, fire and tools. Progress owns insight, nodes and the lock. Life owns bodies, food, effects and creatures' AI. This mod owns *what alchemy is*: its reagents, its vessels, its operations, its creatures and its worlds — and it reaches every one of those owners only through their exports.

---

## 1. Repository shape and manifest

Same skeleton as the siblings: `mods/tiamat_default_magic/`, vendored `AGENTS.md` and `stubs/game.lua`, `tests/native`, `tools/make_textures.py`, `docs/exports.md`, `docs/engine-asks.md`, `docs/sibling-asks.md`, `docs/pacing.md`, `docs/lore.md` (the sources, §15).

```
mods/tiamat_default_magic/
  mod.toml
  init.lua            load order only
  config.lua          EVERY number: costs, ticks, yields, radii, caps, the herb table, the pacing targets
  util.lua            integer helpers, the LCG, qualified-id helpers
  hooks.lua           one engine registration per hook, fan-out to subscribers
  store.lua           per-player and per-place records in game.storage (scalars only), cached
  items.lua           every item, from a data table (§9)
  blocks.lua          the five blocks (§8)
  path.lua            register_path (the Emerald Tablet), on_choose, on_repath cleanup
  tree.lua            the node table (§5) → progress.register_node; the effects keys
  apprentice.lua      the shared Apothecary's Bench (§4) and its recipes
  athanor.lua         the station, the vessels, the four degrees of fire, long works
  gates/              one file per Gate of Ripley: calcination.lua … projection.lua
  menstrua.lua        solvents and salts (§6.4)
  spagyrics.lua       tinctures, the herb→planet table, elixirs (add_food + on_eat effects)
  effects.lua         the effects Life does not have (§6.7), each a timer in the player record
  glyphs.lua          masks, the 48 symmetries, register_glyph for every variant
  constructs.lua      the bounded pattern matcher and every construct (§7.3)
  talismans.lua       the worn-view poll, seven passives
  seal.lua            wards (dig/place refusal)
  familiars.lua       the four elementals, the homunculus, the basilisk, the phoenix (entities)
  arbor.lua           the Tree of Diana, grown cell by cell
  opus.lua            the Stones, cibation, projection, multiplication
  cosmos.lua          the microcosm, correspondence gates, woven worlds, sundering
  studies.lua         register_study / register_discovery / award calls
  primer.lua          the Mutus Liber (picture pages)
  screens.lua         tabs and dialogs
  commands.lua        `magic …` chat words, operator words
  exports.lua         what other mods may call (§12)
  hud.lua             none — the Quintessence bar is Life's; the one HUD channel this mod might want is §10.3
  textures/ sounds/ models/ pictures/
```

```toml
id = "tiamat_default_magic"
name = "Tiamat Default Magic"
version = "0.1.0"
description = "The Hermetic Art: the athanor, the Twelve Gates, spagyrics, elementals and the Philosophers' Stone."
license = "GPL-3.0-only"
# The four without which there is no Art, as hard dependencies; the interface and the
# weather optional (§2.1). Either edge makes `game.exports` answer from init.lua's first line.
depends = [
  "core >=0.1",
  "tiamat_default_world >=0.1",
  "tiamat_default_life >=0.1",
  "tiamat_default_craft >=0.4",
  "tiamat_default_progress >=0.1",
]
optional_depends = ["tiamat_default_ui", "tiamat_weather"]   # §2.1

[[world_option]]
id = "transmutation"
name = "Transmutation"
description = "May the Stones make silver and gold? Off: they still heal and still open the Great Arcanum, but projection makes nothing."
default = 1

[[world_option]]
id = "woven_worlds"
name = "Woven worlds per player"
description = "How many worlds each Adept may weave at once."
options = ["1", "2", "4"]
default = 1
```

No `[theme]` (the UI mod's is the world's). No `conflicts` — in particular **not** `tiamat_default_science`: a server with both is the intended game.

---

## 2. Engine and sibling facts this design rests on

Everything in Craft's and Progress's briefs §2 still applies (no floats that reach the world, registries freeze after `init.lua`, integer storage scalars, one callback per hook per mod, 50 ms tick, random tick ≈ once per block per 20 minutes). The ones that shape *this* mod:

| Need | Fact (source) | Consequence |
|---|---|---|
| A path and a door | Progress `register_path{ id, label, door, recipe, sentence, refusal, on_choose }`; door recipe adds the Keystone and requires `shared.keystone` (Progress exports) | Door = `tiamat_default_magic:emerald_tablet` (§3). |
| Path nodes before the Fork | `can_unlock` answers "lies beyond the Fork" for any path node while a player has no path; path nodes of tier ≥ 3 must reach `shared.fork` (Progress `nodes.lua`) | **Children cannot touch path nodes before the Fork** — and the Fork wants orichalcum from 2,000 blocks down. So the child's door is the **Apothecary's Bench**: five cheap `shared.*` nodes this mod registers (tiers 1–2), open to everyone (§4). |
| Node limits | tier 0..7; cost 0..100,000; ≤ 8 `requires`; ≤ 8 effects, integers; `id` ≤ 64 chars (Progress `config.lua`) | The tree in §5 obeys all four; `tools/check_tree.py` (§13) proves it. |
| Recipes, stations, heat | Craft `register`, `register_station{ slots, heat, fuels, block, lit_block, boost, auto, forge }`, `register_fuel`; heat tiers 1..9; every slot role takes a range `{ from, to }`; a heat station makes, while it burns, the **most particular** recipe its slots, tools and heat satisfy (most inputs and tools first, then by id); **no recipe may take more than 72,000 ticks** (Craft `config.lua` `max_ticks`) (Craft exports, `registry.lua`) | The athanor is a Craft heat station and runs itself. **Vessels are tools** in its tool slot(s): an alembic, a retort, a pelican, an aludel, an Egg — the historical glassware turns one furnace into every apparatus, and costs zero blocks. |
| Carved shapes | A carved stack is `{ material, shape = mask }`; Craft's `register_glyph(mask, id)` (one meaning a mask, while mods load), `glyph_of(stack or mask)`; **a stack with a shape or a detail is never a Craft ingredient — nor a Craft tool** (Craft exports; `registry.lua` tool lookup) | Glyphs work today. A carved part *as an ingredient or a tool* needs sibling ask **C-M1** (§14); until then relic and talisman recipes use the wrapper in §7.5. |
| Node effects on Craft's numbers | Craft reads `craft.*` keys through the function Progress hands it, summing **every** node a player holds (Progress `effects_of`); `craft.fuel_percent` is read **for the kiln only** (Craft `furnace.lua`) | Magic nodes may carry `craft.*` effects (the Salamander carries `craft.fuel_percent`, honestly a kiln bonus; ask **C-M8** extends it to every heat station). Magic's own numbers use `magic.*` keys, read here through `progress.effects_of(uuid, "magic.")`. |
| A bar for the player | Life `add_stat(id, { max, regen, name, colour, start })`, `stat`, `set_stat`, `spend_stat` — **one max for every player, drawn for every player** (Life exports) | Quintessence is a Life stat. Science players would see it: sibling ask **L-M1** (per-player max, hidden at 0). Fallback: `start = 0`, and a science player's bar is set to 0 on join and on every fork. |
| Shared reagents | Science also makes saltpeter, oil of vitriol and quicksilver; neither mod names the other | Each mod registers its own item **and adds it to a shared Craft group** — `#saltpeter`, `#oil_of_vitriol`, `#quicksilver` (Craft groups are additive; either mod may create one). Every recipe here names the group, so a science player's quicksilver works in a magic player's retort. |
| Drinks | Life `add_food(material, { food, saturation, heal, effects = {{id,ticks}}, cures, well_fed, temperature, sound = "drink" })`; effects only Life's own: `burning poison wither radiation regeneration resistance warmth cooling well_fed rested hearty steady` (Life exports) | Every elixir is an `add_food` item. Effects Life lacks (night-sight, swiftness, water-breathing, levitation) are this mod's own timers, started from Life's `on_eat` (§6.7). |
| Hurting and healing others | Life exports **no** damage, heal-other or apply-effect; it exports `set_alight(target, ticks)` (Life exports) | The salamander's attack is `set_alight`. Panacea-on-friends, sprayed elixirs and the basilisk's stare are sibling ask **L-M2**, each with a stated fallback. |
| Player movement | `set_player_abilities(uuid, { fly, speed, sprint, wind_sky })` — one table per player, **last writer wins**, client-predicted; `push_player(uuid, impulse)` — "added, not set", and **not** documented as predicted; `move_player` (stubs) | Life already writes abilities (cold, hunger). Swiftness and sylph flight need sibling ask **L-M3** (compose) — fallback §6.7, which must be tested for rubber-banding. |
| The sky | `set_sky_modifier(uuid, …)` is one modifier per player, last writer wins — and **Weather writes it for every exposed player whenever its value changes** (Weather `fx.lua`) | Night-sight, the Luna talisman and a woven world's sky need Weather ask **Wx-M1** (a layered overlay). Until then this mod never calls `set_sky_modifier`. |
| Entities | `register_model` (≤ 64 per server, all mods), `spawn_entity`, `set_entity`, `steer_entity`, `find_path` (8,000 expansions per tick shared by every search) (stubs) | Six models (§10.1), leaving the budget to Life's ~30. Familiars path only when more than 6 blocks from their master, at most one search per familiar per 20 ticks. |
| Worlds | `register_domain{ instanced = true, generator, position }`; `create_domain(template, key, { position })`; `destroy_domain` (instances only, refused while occupied); **the generator is told `{x, y, z, seed}` and not which instance it fills** (stubs) | Woven worlds use the *offset trick* (§6.10): every world is its own far-away slice of one infinite generator, and its parameters are read from *where* it is. Engine ask **E-M1** would make it cleaner. |
| Weather | `falling_on(player)` (a **player**, not a place), `weather_at(x,y,z)`, `ignite`, `extinguish`, `on_lightning(fn)`; no way to call rain (Weather exports) | Nothing here needs to *make* weather. Rain on a placed block = `weather_at` rain/storm there **and** `get_light(pos).sun == 15`. |
| Pictures | `register_picture` ≤ 512 per server, ≤ 2048 px an edge and ≤ 8 MiB decoded (stubs; engine `texture.rs`) | The *Mutus Liber* uses ≤ 120; art is optional (§11) — every page has a text form. |

### 2.1 Checked on 2026-09-29 — what changed from draft 1

Every claim in §2 and below was re-checked against `stubs/game.lua` and the sibling repositories. These did not hold, and the text has been corrected where they appear:

| Draft 1 said | What is so (source) | What changes |
|---|---|---|
| A lit station may advance while its chunk is unloaded (asked in C-M5) | **It does not**: "a furnace in a chunk that is not loaded is paused" (Craft `furnace.lua`) | The 40-day works are 13 h 20 min with a player nearby. C-M5 is no longer optional; §6.1 |
| The athanor makes the next step of a chain on its own | A heat station takes from its input slots and gives to its output slots; nothing moves an output back into an input (Craft `furnace.lua`, `registry.lua`) | Step chains need the player (or the homunculus) to move each step; §6.1 |
| Fuel is not counted | Coal burns 1,800 ticks a block, charcoal 1,200, wood 800 (Craft `config.lua`) | A Red Stone at Craft's rates is ~530 blocks of coal. Ask **C-M10**, an athanor's own slow burn; §6.1 |
| A philosophical day is 24,000 ticks | Day length is the sky mod's `register_sky{ day_length_ticks }`, not an engine constant; the core sky uses 24,000 | `config.lua` holds the length; nothing else assumes it |
| `copper_plate` (kerotakis) | Craft has no copper plate | Kerotakis: `iron_plate` + glass |
| "bark strips", "bone needle", "iron hammer" | `bark_strip`, `bone_needle`, `iron_hammer` (Craft exports) | Named so |
| Life's `fruit` | No such item: `apple`, `berries`; Craft's group `#fruit` holds both | Recipes name `#fruit` |
| World's `rose` block | `rose` is an item; the blocks are `rose_bush` and `rose_blooms` (World `blocks.lua`) | The Venus row reads so |
| ~45 plant covers, ~40 herb species | ~32 plant blocks, ~24 of them covers (World `blocks.lua`) | Herb insight ~150, not ~200 |
| ~22 creature kinds | 26 (Life exports) | Essence insight ~260 |
| Re-registering a glyph faults | It answers `nil, "that mask is already <id>"` and never raises (Craft `registry.lua`) | C-M7 is a convenience, not a fault |
| World owns pyrite's random tick | It does not; World ticks snow, ivy, rose bushes, grass, alpine surfaces and sulfur (World `hooks.lua`) | The rain route may use `register_random_tick` on pyrite (one handler a material, so agree it with World first: **W-M3**) |
| Weather writes the sky modifier continuously | Only when its value changes, and `nil` when there is no weather (Weather `fx.lua`) | Wx-M1 still stands (one modifier a player, last writer wins) |
| UI engine-ask 16, the black shape editor, is open | Landed 2026-09-28 (engine `0921437`) | Note removed |
| The *Mutus Liber* on J, familiars on K | `register_action` is "stored now, inert until Task 13" (stubs) | Both open by USING the item (`register_on_use{ anywhere = true }`) and by chat (`magic book`) until actions work |
| Lapis Infinitus "projection ×10" | Effects sum: Exaltation's 100 + Lapis's 900 = ×11 | Lapis carries 800, so the total is ×10 |
| Node `label` ≤ 32, text ≤ 90 | Progress keeps 48 and 200 (`nodes.lua`); ours are tighter by choice | Unchanged: ours |
| A flame powder is thrown on a fire by using the fire | Craft hears every use at a campfire first (a LISTED callback, and listed callbacks keep load order) and opens the fire's box | A powder is PUT ON a campfire, as food is, and burns there as a campfire recipe; at a lit kiln or bloomery (which Craft does not list) it is thrown. Ask **C-M9**; §4 |
| Discovery families named `tiamat_default_magic:herb:*` | Progress finds a family by splitting at the FIRST colon, so that id never resolves; its own families are `biome:*`, `kill:*` (`insight.lua`) | Every family here is `tiamat_default_magic.<name>:*`, and every discovery `tiamat_default_magic.<name>` |
| Groups named `#tiamat_default_magic:blast` | Craft's group names are `^#[%w_]+$`: no colon (`util.lua`) | This mod's groups are `#magic_<name>` (`#magic_blast`, `#magic_herb`, `#magic_tincture`, `#magic_calx`); the shared ones stay `#saltpeter`, `#oil_of_vitriol`, `#quicksilver` |
| Pictures ≤ 2048 px | ≤ 2048 px on an edge AND ≤ 8 MiB decoded (~1448² square) | Plates are drawn at 1024² |

**Long works and Quintessence (decided 2026-09-30).** See §6.1 (a philosophical day is 1,800 ticks, so the forty-day Red Stone is one hour and one recipe) and §6.8 (the bar waits for L-M1 or tier 5).

**Dependencies (decided 2026-09-29).** Draft 0 made every sibling optional; draft 1 made every sibling hard. The mod now takes a middle course: **hard** on `core`, World, Life, Craft and Progress, without any one of which there is no Art to practise (no plants, no fire, no recipes, no door); **optional** on the interface (without it the *Mutus Liber* is a dialog) and on Weather (without it pyrite weathers only in the bath, sylphs come only to peaks, and a bolt on an athanor is not heard). §16's "load with Weather absent" test asserts that the mod loads and degrades, not that the engine refuses.

---

## 3. The door: the Emerald Tablet

```lua
progress.register_path{
  id       = "magic",
  label    = "The Hermetic Art",
  door     = "tiamat_default_magic:emerald_tablet",
  recipe   = { inputs = {
    { "tiamat_default_world:crystal", units = 27 },       -- the tablet itself: green-lit crystal
    { "tiamat_default_craft:copper_ingot", count = 4 },   -- the verdigris of its letters
    { "tiamat_default_craft:silver_ingot", count = 2 },
  } },                                                      -- Progress adds the Keystone and `shared.keystone`
  sentence = "As above, so below. This binds you; the other door closes.",
  refusal  = "The letters on the Tablet will not hold still for you.",
  on_choose = function(uuid) path.on_choose(uuid) end,
}
```

The *Tabula Smaragdina* is the founding text of Hermetic alchemy (Arabic by the 9th century; Latin by the 12th). A placed Tablet is a plain block (hardness 2.6, light {2, 9, 4}, tags `crystal`, `glowing`) that Progress drives with `on_use`.

`path.on_choose(uuid)`: sets the Quintessence stat's player max to 10 (L-M1) or its value to 10 (fallback) — once the stat exists (§6.8); calls `progress.unlock(uuid, "magic.hermetic_oath")` (cost 0, so free the moment the Fork is taken); gives one `mutus_liber` if the player has none; plays the `hermetic` cue; one chat line: *"You have taken the Oath. Seek the Athanor."*

`progress.on_repath(fn(uuid, old, new))`, when `old == "magic"`: familiars despawned (records kept, marked dormant), Quintessence to 0, the player's woven worlds **sealed not destroyed** (entry refused, contents kept — a repath is reversible by repathing back, and destroying someone's world on a rules toggle is not acceptable), wards lifted. Nothing crafted is taken back: items are the world's, not the path's.

---

## 4. The children's door — the Apothecary's Bench (shared, tiers 1–2)

**This is the most important section for the stated goal.** A six-year-old will never reach the Fork. So the first taste of magic is five `shared.*` nodes this mod registers, costing 5 to 25 insight, open before the Fork to **every** player (magic, science and undecided alike — Progress keeps shared nodes through the Fork and through a repath, so nothing is ever taken from a child). A player with fire, clay, a campfire and Craft's first copper can finish three of the five; the lamp and the stillroom want Craft's glass (a heat-2 kiln recipe, Craft's second hour).

| Node | Cost | Requires | Branch | Unlocks |
|---|---|---|---|---|
| `shared.mutus_liber` **The Mute Book** ★ | 5 | `firecraft` | APPR | The *Mutus Liber* (1677), a picture-only primer: the magic recipe book a child can read. Recipe: 1 `leather`, 2 `bark_strip`, 1 `charcoal` (hand). |
| `shared.apothecary` **The Apothecary's Mortar** ★ | 10 | `mutus_liber` | APPR | Fired-clay mortar & pestle (tool). Grinds `#plant` into *simples*. Flame powders on any burning fire: sulfur (blue), copper filings (green), salt (yellow), ground bone (white sparks). Put on a campfire like food (it flares in a second); thrown at a lit kiln or bloomery. |
| `shared.herb_lore` **Herb Lore** ★ | 10 | `apothecary` | APPR | Campfire teas in the copper pot: chamomile (rested + warm), mint (cool), bramble-leaf (heal 1); a lady's-mantle poultice (heal 2). |

| Node | Cost | Requires | Branch | Unlocks |
|---|---|---|---|---|
| `shared.foxfire` **Foxfire** ★ | 20 | `apothecary` | APPR | Glow caps sealed in glass: the **Hermetic Lamp** block (green-white light 12, never burns out). Foxfire lit the *Turtle* submarine in 1775. |
| `shared.stillroom` **The Stillroom** ★ | 25 | `herb_lore` | APPR | A copper still (a tool in Craft's kiln tool slot, heat 1): rosewater (Avicenna's steam distillation; heal 2 + rested) and mint water. First distillation is a discovery. |

**Design rules for the bench (and for every ★ node in the tree):**

1. **Instantly visible.** Every one makes a colour, a light, a sound or a drink you can taste within ten seconds of learning it. No node whose payoff is "unlocks a later node".
2. **Three ingredients at most, one station, no timers over 60 seconds, no failure, nothing lost.** A flame powder is only taken by a fire that is burning; anywhere else it stays in your hand.
3. **Readable without reading.** The *Mutus Liber* (§11) was historically a book of alchemy told in pictures only; ours is too. Each page: input icons → station icon → output icon.
4. **One-click carving.** Every glyph a child meets is a preset button in the shape crafter (ask **U-M1**), so "carve the Sun" is a click, not twenty-seven.
5. **Toybox discoveries.** Small insight for play itself (§6.12): *"You made fire burn blue!"* (+3), *"A lamp that never goes out"* (+5).
6. **Creative worlds** (Life's `mode`): Progress already answers `true` for every shared node; the bench is simply open.

The Hermetic Lamp is the bench's one block, and it is the one block a child wants most: a light that never burns out, from mushrooms in a jar.

---

## 5. The tree (tiers 3–7)

Legend: ★ a child can enjoy it (rules in §4); ◆ on the **spine** — an ancestor of the capstone, so it must be learned to finish the tree. Branch codes: **GATE** the Twelve Gates (the spine of operations), **FIRE** vessels and heat, **MENS** menstrua (solvents and salts), **PLAN** the seven planetary metals, **SPAG** spagyrics and medicine, **ELEM** elementals and the living work, **SIGN** sigils, talismans, seals, **OPUS** the Stones and their colours, **COSM** worlds. A requirement written without a prefix is a `magic.` node.

Nodes with nothing after them (the tree's leaves, by design — each is a reward, not a toll): `shared.foxfire`, `shared.stillroom`, `magic.blue_vitriol`, `magic.spirit_of_salt`, `magic.arbor_dianae`, `magic.ouroboros`, `magic.phosphorus`, `magic.sal_alembroth`, `magic.caduceus`, `magic.undine_tides`, `magic.gnome_delving`, `magic.sylph_flight`, `magic.orichalcum_awakened`, `magic.greater_talismans`, `magic.atalanta_fugiens`, `magic.assay`, `magic.greater_seal`, `magic.basilisk`, `magic.phoenix`, `magic.rosarium`, `magic.wise_mind`, `magic.planetary_skies`, `magic.native_spirits`, `magic.planetary_veins`, `magic.worldgate`, `magic.hermes_trismegistus`.

### 5.1 Tier 3 — *Nigredo* I: the Laboratory

The first ring after the Fork is deliberately gentle: six ★ nodes (athanor, glass, bath, the metals, their sigils, verdigris) before anything asks for patience. The salamander is the tier's showpiece — a creature that appears in your own furnace.

| Node | Cost | Requires | Branch | Unlocks |
|---|---|---|---|---|
| `magic.hermetic_oath` **The Oath** ★ ◆ | 0 | `shared.fork` | GATE | Granted free on choosing the Emerald Tablet. The root. Gives the Adept's notebook page in the *Mutus Liber*. |
| `magic.athanor` **The Athanor** ★ ◆ | 100 | `hermetic_oath` | FIRE | The **Athanor** station (slow tower furnace; "the philosophers' oven") and the ash bath: the 2nd degree of fire. |
| `magic.glassblowing` **Glassblowing** ★ ◆ | 80 | `hermetic_oath` | FIRE | Blowpipe (iron) → phial, cucurbit, alembic head, receiver, from Craft glass in the kiln. |
| `magic.bain_marie` **Maria's Bath** ★ ◆ | 60 | `athanor` | FIRE | The **bain-marie** vessel (Maria the Jewess, 1st c.): the 1st degree, a heat that never scorches. |
| `magic.seven_metals` **The Seven Metals** ★ | 80 | `hermetic_oath` | PLAN | Sol-gold, Luna-silver, Venus-copper, Mars-iron, Jupiter-tin, Saturn-lead, Mercury-quicksilver. Unlocks the seven sigil glyphs and their shape-crafter presets. |
| `magic.degrees_of_fire` **The Four Degrees** ◆ | 100 | `athanor` | FIRE | Geber's scale: the sand bath (3rd degree, charcoal or coal) and naked fire blown by bellows (4th). |
| `magic.gate_calcination` **Gate I: Calcination** ◆ | 120 | `athanor`, `degrees_of_fire` | GATE | Calxes: litharge & minium (lead), putty (tin), *aes ustum* (copper), *crocus martis* (iron), bone ash. |
| `magic.cupellation` **The Cupel** ◆ | 120 | `gate_calcination` | PLAN | Bone-ash cupel. 9 lead ingots → 8 litharge + 1 silver grain (9 grains = 1 silver ingot): the historic silver-from-galena. |
| `magic.sigils` **Signs of the Seven** ★ | 100 | `seven_metals` | SIGN | A carved sigil block touching an athanor speeds its own metal's recipes 15 % (any stone), 30 % if carved from that metal's ore block. |
| `magic.vinegar_and_wine` **Wine and Vinegar** ◆ | 80 | `bain_marie` | MENS | Ferment `#fruit` or wheat in the bath (1 day) → *vinum*; leave it a day more → vinegar; distil → distilled vinegar. |
| `magic.verdigris` **Verdigris** ★ | 80 | `vinegar_and_wine` | MENS | Copper over vinegar → verdigris (green). A salve (cures burning) and a reagent. "It turns copper green!" |
| `magic.aqua_vitae` **Aqua Vitae** ◆ | 120 | `vinegar_and_wine`, `glassblowing` | MENS | "Burning water" distilled from *vinum*; rectified seven times in the receiver → spirit of wine (a reagent, never drunk). |
| `magic.spagyric_tincture` **Spagyric Tinctures** ★ ◆ | 140 | `aqua_vitae` | SPAG | Herb + spirit of wine, digested a day → one of seven planetary tinctures, by Culpeper's rulers (§6.3). Each species first distilled is a discovery. |
| `magic.simple_elixirs` **Simple Elixirs** ★ ◆ | 120 | `spagyric_tincture` | SPAG | Phial drinks: Vigour (regeneration), Fortitude (resistance), Warming, Cooling, Night-sight (Luna), Swiftness (Mercury). |
| `magic.green_vitriol` **Green Vitriol** ◆ | 120 | `bain_marie` | MENS | Pyrite weathered in the bath (or left in the rain) → green vitriol. Discovery: *V.I.T.R.I.O.L.* |
| `magic.retort` **The Retort** ◆ | 80 | `glassblowing` | FIRE | The retort vessel: dry distillation at the 2nd degree. |
| `magic.oil_of_vitriol` **Oil of Vitriol** | 150 | `green_vitriol`, `retort`, `degrees_of_fire` | MENS | Vitriol distilled dry → oil of vitriol (sulfuric acid) + *caput mortuum*, the "dead head". |
| `magic.blue_vitriol` **Vitriol of Venus** ★ | 100 | `oil_of_vitriol`, `verdigris` | PLAN | Copper + oil of vitriol → blue vitriol crystals (the prettiest thing in the lab). |
| `magic.salamander` **The Salamander** ★ ◆ | 160 | `athanor`, `gate_calcination` | ELEM | Cellini's salamander: an athanor kept burning one whole day draws one; feed it flowers of sulfur or sulfur to bind it. Knowing it, every kiln you light burns half again as long; bound, it follows you and leaves you an ember that burns hotter than bellows. |
| `magic.gate_solution` **Gate II: Solution** ◆ | 140 | `gate_calcination`, `vinegar_and_wine` | GATE | Calxes dissolved: salt of tartar (potash, from ash), *sal saturni*, salt of Venus. |
| `magic.gate_separation` **Gate III: Separation** ◆ | 150 | `gate_solution`, `aqua_vitae` | GATE | Paracelsus' *tria prima* out of any `#plant`: principle Mercury (spirit), principle Sulfur (oil), principle Salt (fixed ash). |

### 5.2 Tier 4 — *Nigredo* II: the Menstrua and the Black

Solvents in their historical order of discovery, the Egg, the first three elementals, and the *nigredo* itself.

| Node | Cost | Requires | Branch | Unlocks |
|---|---|---|---|---|
| `magic.aludel` **The Aludel** ◆ | 180 | `degrees_of_fire` | FIRE | Sublimation vessel: the volatile rises and is caught as "flowers". |
| `magic.pelican` **The Pelican** ◆ | 180 | `aqua_vitae`, `glassblowing` | FIRE | Circulation vessel: a spirit rises and returns, forever. Exalts tinctures; runs long works. |
| `magic.philosophers_egg` **The Philosophers' Egg** ◆ | 200 | `pelican` | FIRE | The hermetically sealed ovum: every long work of the Opus is cooked in it. |
| `magic.flowers_of_sulfur` **Flowers of Sulfur** ★ ◆ | 150 | `aludel` | MENS | Sulfur sublimed pure (yellow). Salamander food; the Sulfur of the metals. |
| `magic.quicksilver` **Quicksilver** ★ ◆ | 200 | `retort`, `degrees_of_fire` | PLAN | Cinnabar roasted in the retort → quicksilver (Theophrastus, 300 BC). The seventh metal. |
| `magic.vermilion` **Vermilion** | 180 | `quicksilver`, `flowers_of_sulfur` | PLAN | Quicksilver + sulfur sublimed → vermilion (Jabir). The Red that the Red Work imitates. |
| `magic.amalgams` **Amalgams** ◆ | 200 | `quicksilver` | PLAN | Gold, silver and tin amalgams; fire-gilding. Amalgams are the body of most later works. |
| `magic.saltpeter` **The Nitre Bed** ◆ | 200 | `gate_separation` | MENS | Rotting `#plant`, ash and earth kept warm three days → saltpeter. |
| `magic.aqua_fortis` **Aqua Fortis** ◆ | 250 | `saltpeter`, `green_vitriol`, `retort` | MENS | Saltpeter + vitriol distilled → "strong water". **Parting**: separates gold from silver. |
| `magic.spirit_of_salt` **Spirit of Salt** | 200 | `oil_of_vitriol` | MENS | Glauber (1648): salt + oil of vitriol → spirit of salt, and *sal mirabilis* as by-product. |
| `magic.sal_ammoniac` **Sal Ammoniac** ◆ | 200 | `aludel`, `gate_calcination` | MENS | Bone and salt sublimed → sal ammoniac. |
| `magic.aqua_regia` **Aqua Regia** ◆ | 300 | `aqua_fortis`, `sal_ammoniac` | MENS | Royal water: dissolves gold. Gold in it is **the Green Lion**, who devours the Sun. |
| `magic.arbor_dianae` **The Tree of Diana** ★ | 250 | `aqua_fortis`, `amalgams` | PLAN | Silver amalgam in *aqua fortis* grows a crystal silver tree: the **Arbor Dianae** block, one cell at a time. A slow silver farm. |
| `magic.gate_conjunction` **Gate IV: Conjunction** ◆ | 250 | `gate_separation`, `amalgams` | GATE | The Chemical Wedding: principle Sulfur (the King) and principle Mercury (the Queen), with Salt → Conjoined Matter. |
| `magic.gate_putrefaction` **Gate V: Putrefaction** ◆ | 300 | `gate_conjunction`, `philosophers_egg` | GATE | Conjoined Matter sealed three days in the Egg at the 1st degree → **Caput Corvi**, the Raven's Head. The *nigredo*. |
| `magic.cauda_pavonis` **The Peacock's Tail** ★ ◆ | 250 | `gate_putrefaction` | OPUS | Caput Corvi washed (ablution) → Peacock Matter: the Egg shimmers every colour while it works. |
| `magic.theriac` **Theriac** ◆ | 200 | `simple_elixirs`, `gate_separation` | SPAG | Galen's universal antidote: makes Life's `antidote` item. |
| `magic.exalted_tinctures` **Exalted Tinctures** ◆ | 220 | `pelican`, `spagyric_tincture` | SPAG | Circulated tinctures: every elixir lasts twice as long; Night-sight and Swiftness gain a second grade. |
| `magic.palingenesis` **Palingenesis** ★ | 250 | `gate_separation`, `philosophers_egg` | SPAG | The plant reborn from its ashes (Digby, Kircher): a plant's principle Salt in a warmed phial gives the living plant back. A flower copier. |
| `magic.undine` **The Undine** ★ ◆ | 280 | `salamander`, `bain_marie` | ELEM | Found in still water at night. Bound: carries up to 4 blocks of water, pours on command, douses fires. |
| `magic.gnome` **The Gnome** ★ ◆ | 280 | `salamander`, `cupellation` | ELEM | Found below the Gloam line. Bound: ore-sense — sparks over every ore within 8 blocks, every 5 s. |
| `magic.sylph` **The Sylph** ★ ◆ | 280 | `salamander`, `aludel` | ELEM | Found on peaks in wind or storm. Bound: a gust (one mid-air jump) and a soft landing. |
| `magic.talismans` **Planetary Talismans** | 220 | `sigils`, `amalgams` | SIGN | Seven talismans (sigil struck in its metal) worn in Life's worn slots, one passive each (§6.6). |
| `magic.hermetic_seal` **The Hermetic Seal** | 250 | `sigils`, `glassblowing` | SIGN | The seal glyph, placed: nobody but you (and whom you name) digs or places within 6 blocks. |
| `magic.ouroboros` **The Ouroboros** | 200 | `sigils`, `pelican` | SIGN | Eight ouroboros blocks ringing an athanor: its long works take 20 % less time. |
| `magic.phosphorus` **Phosphorus** ★ | 220 | `oil_of_vitriol`, `gate_calcination` | MENS | Scheele's route (1769): bone ash + vitriol + charcoal → phosphorus, "the light-bearer". Phosphorus spills light any fire without a striker. |

### 5.3 Tier 5 — *Albedo* and *Citrinitas*: the White Work

| Node | Cost | Requires | Branch | Unlocks |
|---|---|---|---|---|
| `magic.gate_congelation` **Gate VI: Congelation** ◆ | 400 | `gate_putrefaction`, `aludel` | GATE | Fixing the volatile: fixed mercury, fixed salts. |
| `magic.gate_cibation` **Gate VII: Cibation** ◆ | 450 | `gate_congelation` | GATE | Feeding the matter in stages: athanor works that take their inputs a portion at a time. Shortens every stone. |
| `magic.gate_sublimation` **Gate VIII: Sublimation** ◆ | 450 | `gate_congelation`, `flowers_of_sulfur` | GATE | "The Eagle flies": the matter raised and purified. |
| `magic.albedo` **Albedo: the White Stone** ★ ◆ | 600 | `gate_congelation`, `cauda_pavonis` | OPUS | Seven days in the Egg → the **White Stone**. Projected on quicksilver, tin or lead, it makes silver. |
| `magic.sal_alembroth` **Sal Alembroth** | 400 | `gate_sublimation`, `sal_ammoniac`, `quicksilver` | MENS | The "salt of wisdom": quicksilver and sal ammoniac sublimed together. |
| `magic.citrinitas` **Citrinitas** ◆ | 600 | `albedo`, `gate_sublimation` | OPUS | The yellowing: White Stone + Solar tincture → Solar Sulfur, the Yellow King. |
| `magic.aurum_potabile` **Aurum Potabile** ◆ | 550 | `aqua_regia`, `citrinitas` | SPAG | Drinkable gold: heals fully, cures all, long regeneration. |
| `magic.elixir_vitae` **Elixir of Life (lesser)** ◆ | 500 | `theriac`, `exalted_tinctures` | SPAG | Regeneration and resistance together, and quintessence refills faster for 10 min. |
| `magic.quintessence` **The Fifth Essence** ◆ | 450 | `exalted_tinctures`, `pelican` | SPAG | Rupescissa's quintessence, circulated a thousand times: the Quintessence bar grows (+20 max). |
| `magic.caduceus` **The Caduceus** ★ | 500 | `quintessence`, `talismans` | SIGN | Hermes' staff: Hermes' Stride (short blink, quintessence) and elixirs sprayed on friends nearby. |
| `magic.elemental_circle` **The Circle of Four** ★ ◆ | 500 | `undine`, `gnome`, `sylph` | ELEM | The four element glyphs round a centre: familiars persist across restarts; two may walk with you. |
| `magic.salamander_forge` **The Salamander's Forge** | 450 | `elemental_circle`, `degrees_of_fire` | ELEM | Your salamander's ember in an athanor's vessel slot holds the 4th degree with no bellows. |
| `magic.undine_tides` **The Undine's Gift** | 450 | `elemental_circle` | ELEM | With your undine near: water breathing, faster swimming. |
| `magic.gnome_delving` **The Gnome's Delving** | 450 | `elemental_circle` | ELEM | Your gnome tunnels 1×2 ahead of you, up to 16 blocks, as a tier-2 tool would. |
| `magic.sylph_flight` **The Sylph's Wings** ★ | 500 | `elemental_circle` | ELEM | Ten seconds of flight for 10 quintessence. |
| `magic.orichalcum_awakened` **Orichalcum Awakened** | 600 | `albedo`, `amalgams` | PLAN | The glimmer attuned: living orichalcum ingots → orichalcum pick, axe, spade, chisel (tier 4). |
| `magic.kerotakis` **Maria's Kerotakis** | 400 | `amalgams`, `degrees_of_fire` | FIRE | The reflux palette for tinting metals: electrum (gold + silver) and tinged alloys. |
| `magic.greater_talismans` **Greater Talismans** | 500 | `talismans`, `kerotakis` | SIGN | Talisman effects doubled; two worn talismans both count. |
| `magic.atalanta_fugiens` **Atalanta Fugiens** ★ | 350 | `cauda_pavonis` | OPUS | Maier's 1617 emblem book with fugues: each emblem earned is a discovery and a page; the athanor plays its fugue while it works. |
| `magic.assay` **The Assay** | 400 | `aqua_fortis`, `cupellation` | PLAN | The assayer's art: every study at the research table pays 25 % more insight. |
| `magic.greater_seal` **The Greater Seal** | 450 | `hermetic_seal`, `gate_congelation` | SIGN | Seal radius 12; a sealed door or trapdoor opens only for the named. |

### 5.4 Tier 6 — *Rubedo*: the Red Work

| Node | Cost | Requires | Branch | Unlocks |
|---|---|---|---|---|
| `magic.gate_fermentation` **Gate IX: Fermentation** ◆ | 800 | `gate_cibation`, `citrinitas` | GATE | The Stone leavened with gold: the Ferment. |
| `magic.rubedo` **Rubedo: the Philosophers' Stone** ★ ◆ | 1200 | `gate_fermentation`, `aurum_potabile` | OPUS | Forty philosophical days in the Egg (cibation and the Ouroboros shorten it) → the **Red Stone**. Projected on any base metal, it makes gold. |
| `magic.gate_exaltation` **Gate X: Exaltation** ◆ | 900 | `rubedo` | GATE | The Stone raised in virtue: every projection yields ×2. |
| `magic.gate_multiplication` **Gate XI: Multiplication** ◆ | 1000 | `gate_exaltation` | GATE | Stone + gold + quicksilver, seven days → two Stones. |
| `magic.alkahest` **The Alkahest** ◆ | 900 | `aqua_regia`, `gate_sublimation` | MENS | The universal solvent: a phial dissolves blocks (radius 1) to prima materia, units kept; digs hard rock. |
| `magic.prima_materia` **Prima Materia** ◆ | 800 | `alkahest` | MENS | *Coagula*: prima materia condensed into any common stone, earth or sand, unit for unit. |
| `magic.panacea` **The Panacea** ◆ | 1000 | `rubedo`, `elixir_vitae` | SPAG | Heals and cures you and everyone within 6 blocks. |
| `magic.homunculus` **The Homunculus** ★ ◆ | 1200 | `gate_putrefaction`, `elixir_vitae`, `elemental_circle` | ELEM | Paracelsus' little helper, forty days in the Egg: a 27-slot satchel; keeps your athanors fed from a chest within 8. |
| `magic.basilisk` **The Basilisk** ★ | 900 | `gate_putrefaction`, `vermilion` | ELEM | Theophilus (c. 1120): a hen's egg under toads hatches a basilisk. Its ash on copper is "Spanish gold". A guard whose stare freezes hostile creatures. |
| `magic.essentia_animalium` **Essences of the Beasts** ◆ | 800 | `homunculus` | ELEM | Distilled essences of Life's creatures (each kind a discovery). Fed to a familiar, one lends a trait. |
| `magic.microcosm` **The Microcosm** ★ ◆ | 1100 | `quintessence`, `philosophers_egg`, `prima_materia` | COSM | A world in the Egg: your own floating island, entered through your Philosophers' Egg. |
| `magic.as_above_so_below` **As Above, So Below** | 1000 | `microcosm`, `hermetic_seal` | COSM | Paired Emerald-glyph gates: step on one, arrive at its twin. |
| `magic.phoenix` **The Phoenix** ★ | 1000 | `rubedo`, `salamander_forge` | ELEM | The bird of the Red Work: once each three days, your dropped belongings return to you after death. |
| `magic.rosarium` **The Rose Garden** ★ | 900 | `palingenesis`, `essentia_animalium` | SPAG | The *Rosarium Philosophorum* built: wild plants bloom in the garden, and rose blooms regrow at once. |
| `magic.wise_mind` **The Stone of the Mind** | 800 | `quintessence`, `rubedo` | SPAG | Quintessence max +40; the bar refills twice as fast. |
| `magic.greater_elementals` **The Greater Elementals** ◆ | 1000 | `elemental_circle`, `essentia_animalium` | ELEM | Three familiars at once; the salamander sets hostile creatures alight, the undine heals, the gnome carries ore, the sylph scouts. |
| `magic.chymical_wedding` **The Chymical Wedding** ◆ | 900 | `gate_conjunction`, `rubedo`, `albedo` | OPUS | Rosenkreutz (1616): the Red King and the White Queen joined in a ceremony construct. |

### 5.5 Tier 7 — The Great Arcanum

| Node | Cost | Requires | Branch | Unlocks |
|---|---|---|---|---|
| `magic.gate_projection` **Gate XII: Projection** ◆ | 1500 | `gate_multiplication` | GATE | The Stone projected on the world: base ore blocks in radius 2 become gold ore; every creature near is healed. |
| `magic.rebis` **The Rebis** ◆ | 1800 | `chymical_wedding`, `gate_multiplication` | OPUS | The "two-thing", perfected union of opposites. The key of worlds. |
| `magic.elemental_quintessences` **Quintessences of the Four** ◆ | 1500 | `greater_elementals`, `quintessence` | ELEM | From each bound elemental, its element's quintessence. |
| `magic.opus_mundi` **Opus Mundi** ★ ◆ | 3000 | `rebis`, `elemental_quintessences`, `microcosm`, `prima_materia` | COSM | The Loom of the Four: weave a whole world, of Earth, Water, Air, Fire or Quintessence. |
| `magic.planetary_skies` **Planetary Skies** ★ | 1500 | `opus_mundi` | COSM | Choose a woven world's sky: leaden Saturn, golden Sol, silver Luna... |
| `magic.native_spirits` **Native Spirits** | 1500 | `opus_mundi`, `greater_elementals` | COSM | A woven world is born with wild elementals of its element. |
| `magic.planetary_veins` **Planetary Veins** | 1500 | `opus_mundi`, `gate_projection` | COSM | Choose which planetary metal runs rich in a woven world. |
| `magic.worldgate` **The World-Gate** | 2000 | `opus_mundi`, `as_above_so_below` | COSM | A standing gate from the overworld into a woven world, for anyone you allow. |
| `magic.solve_et_coagula` **Solve et Coagula** ◆ | 2500 | `opus_mundi` | COSM | Dissolve a woven world back into chaos; half its prima materia returns. |
| `magic.universal_medicine` **The Universal Medicine** ◆ | 2000 | `panacea`, `rebis` | SPAG | An aura: friends within 8 regenerate while you stand among them. |
| `magic.lapis_infinitus` **Lapis Infinitus** ◆ | 2500 | `gate_projection`, `gate_multiplication` | OPUS | Projection ×10; multiplication in one day. |
| `magic.hermes_trismegistus` **Thrice-Greatest** ★ ◆ | 4000 | `opus_mundi`, `lapis_infinitus`, `universal_medicine`, `solve_et_coagula` | COSM | The capstone. The Emerald Tablet speaks its whole text (Newton's translation); a golden aura; the title *Trismegistus*. |

### 5.6 Registration

`tree.lua` holds the table above as data (id, tier, cost, requires, branch, label, text, effects) and loops `progress.register_node`. `label` ≤ 32 characters; `text` is the node's first sentence (≤ 90 characters — what a child reads) and a second line for adults. Effects are integers under `magic.*` (read here) or `craft.*` (read by Craft). The ones the tree carries:

| Node | Effects |
|---|---|
| `salamander` | `craft.fuel_percent` +50 (Craft reads it for kilns you light; C-M8 would extend it to the athanor) |
| `sigils` | `magic.sigil_percent` 15 |
| `exalted_tinctures` | `magic.elixir_duration_percent` 100 |
| `quintessence` | `magic.quintessence_max` 20 |
| `wise_mind` | `magic.quintessence_max` 40, `magic.quintessence_regen_percent` 100 |
| `ouroboros` | `magic.long_work_percent` −20 |
| `gate_cibation` | `magic.long_work_percent` −15 |
| `assay` | `magic.study_bonus_percent` 25 |
| `gate_exaltation` | `magic.projection_percent` 100 |
| `lapis_infinitus` | `magic.projection_percent` 800 (with Exaltation's 100: ×10), `magic.multiplication_days` −6 |
| `greater_talismans` | `magic.talisman_grade` 1, `magic.talisman_slots` 1 |
| `elemental_circle` / `greater_elementals` | `magic.familiars` 1 / 1 |

(Progress's `effects_of` answers per player and is summed live; nothing about an effect is stored, so every number here is retunable in `config.lua` with no migration.)

---

## 6. The Art, system by system

### 6.1 The athanor and the vessels

The **athanor** ("the philosophers' furnace", from Arabic *al-tannūr*) is a tower furnace built to hold a low, even heat for weeks. One Craft station:

```lua
craft.register_station{
  id = "tiamat_default_magic:athanor",
  name = "Athanor",
  slots = { fuel = 1, input = { from = 2, to = 4 }, tool = { from = 5, to = 6 }, output = { from = 7, to = 9 } },
  heat = true,
  block = "tiamat_default_magic:athanor", lit_block = "tiamat_default_magic:athanor_lit",
  boost = { tool = "#magic_blast", heat = 4 },       -- the 4th degree: bellows, or a salamander's ember
  refuse_fuel = "The athanor wants a slow fire: wood, charcoal or coal.",
}
```

Recipe: 9 `brick`, 2 `iron_plate`, 1 `glass`, 9 `fired_clay` at the workbench, `requires = "magic.athanor"`. Life: `add_contact_fire("tiamat_default_magic:athanor_lit", { damage = 1, ticks = 20, after = 20 })`, `add_heat_source(..., 0.8)`.

Two vessel slots (5–6): Craft's slot roles all take ranges. The group `#magic_blast` holds Craft's `bellows` and this mod's `salamander_ember` (§6.9).

**The four degrees of fire** (the pseudo-Geber scale every later text repeats) are recipe requirements, not new machinery:

| Degree | Historical name | How the athanor makes it | Used for |
|---|---|---|---|
| 1st | *balneum Mariae*, the water bath ("horse-dung heat") | heat ≥ 1 **and** the `bain_marie` vessel (node `bain_marie`) | digestion, fermentation, putrefaction, the Stones' long works |
| 2nd | the ash bath | heat ≥ 1 and `ash_bath` (node `athanor`) | circulation, most distillations |
| 3rd | the sand bath | heat ≥ 2 (charcoal, coal) and `sand_bath` (node `degrees_of_fire`) | dry distillation, sublimation |
| 4th | naked fire | heat 4 (bellows or ember boost; node `degrees_of_fire`) | calcination of metals, cupellation, vitrification |

**The vessels** (all items; made at the kiln with the blowpipe unless noted):

| Vessel | Historical role | Made from |
|---|---|---|
| `phial` (consumable) | holds every drink | 1 glass → 4 |
| `cucurbit` + `alembic` + `receiver` | the still: gourd, head and catch | 3 glass |
| `retort` | dry distillation | 2 glass |
| `bain_marie` | Maria's water bath | a `copper_pot` + Life's `water_bucket` → `bain_marie` + Life's empty `bucket` (two outputs) |
| `ash_bath`, `sand_bath` | the middle degrees | fired clay + 9 units of `#ash` / `sand` |
| `pelican` | circulation (the vessel pictured feeding its young) | 4 glass |
| `aludel` | sublimation | 2 fired clay + 2 glass |
| `philosophers_egg` | the sealed ovum of every long work | 3 glass + 1 `flowers_of_sulfur` (the seal) |
| `kerotakis` | Maria's reflux palette, for tinting metals | `iron_plate` + glass (Craft has no copper plate) |
| `cupel` | the assay dish | 9 units bone ash |

**Long works (decided 2026-09-30, for play).** A *philosophical day* is **1,800 ticks — ninety seconds, and exactly the time one block of coal burns** (`config.lua`, `philosophical_day`). The historical counts are kept, so the Mute Book and the node texts say what the texts say: the *nigredo* 3 days (4½ min), the White Stone 7 days (10½ min), the Red Stone the traditional **forty days (one hour)**, the homunculus forty. Forty days is 72,000 ticks, which is Craft's `max_ticks` exactly: **every long work is one ordinary recipe** — no step chains, no intermediate items, nothing to move between slots, and nothing waiting on C-M5. Fuel is one block of coal a philosophical day at Craft's own rates (the Red Stone: forty coal), so C-M10 is no longer needed either. And the athanor is a `long` station (Craft's answer to C-M5): the ticks its chunk was unloaded are worked when it is next loaded, fuel permitting, so a Red Stone is started and left. Cibation, the Ouroboros ring and the salamander forge shorten them (effects above). "Takes a while" now comes from the chain of Gates and the materials each wants, not from a clock.

*Why not the in-game day:* at 24,000 ticks a philosophical day, the Red Stone is 13 h 20 min with a player standing by it (Craft pauses unloaded furnaces) and ~530 blocks of coal, and every long work is a chain of hour-long steps moved by hand. That is waiting, not playing.

The athanor's screen (Craft's) gains a tab from this mod: a dial of the long work, its stage colour, and the historical sentence for that stage (*"The Raven's head appears"*).

### 6.2 The Twelve Gates (the spine)

Ripley's *Compound of Alchymy* (1471) names twelve gates in this order, and the tree keeps it: **Calcination, Solution, Separation, Conjunction, Putrefaction, Congelation, Cibation, Sublimation, Fermentation, Exaltation, Multiplication, Projection.** Each gate is one node and one family of recipes; the first time a player completes one it is a discovery worth 25 × the gate's number (Gate XII: 300).

The matter moving through the gates — the "subject" of the Work — is named as the texts name it, so the *Mutus Liber* can show the right beast for each stage:

| Stage | Matter (item) | Emblem |
|---|---|---|
| Conjunction | `conjoined_matter` | the King and Queen |
| Putrefaction (*nigredo*) | `caput_corvi` | the black crow |
| Ablution | `peacock_matter` | the peacock's tail |
| Albedo | `white_stone` | the white swan |
| Citrinitas | `solar_sulfur` | the yellow king |
| Aqua regia + gold | `green_lion` | the green lion devouring the sun |
| Rubedo | `red_stone` | the pelican in her piety; the phoenix |
| Union | `rebis` | the crowned hermaphrodite |

### 6.3 Spagyrics — the herbal half

Paracelsus' *spagyria* ("separate and combine"): a plant's three principles separated, purified and rejoined. A tincture takes 1 unit-block of a plant (27 units of a World cover block, or 1 of a Life crop item) + 1 `spirit_of_wine`, one philosophical day at the 1st degree → the plant's **planetary tincture**, by its ruler in Nicholas Culpeper's *Complete Herbal* (1653). Culpeper-attested rulers are marked C; the rest are assigned by analogy and marked A (keep them in `config.lua`, so a better source is one edit):

| Planet | Tincture | World / Life plants |
|---|---|---|
| Sol | `tincture_sol` | `roman_chamomile` C, `peony` C, rice A |
| Luna | `tincture_luna` | `poppy` C, `water_iris` C, `blue_lunaria` A, `reeds` A, `glow_cap` A, turnip C, melon A |
| Venus | `tincture_venus` | `ladys_mantle`(+bloom) C, `wild_mint` C, `bramble` C, `rose_bush` / `rose_blooms` (and the `rose` item) C, `bluebell` A, wheat C, apple C, berries C |
| Mars | `tincture_mars` | `gorse` C, `allium` C, `cactus` A |
| Mercury | `tincture_mercury` | `fern` C, `maidenhair` C, `tall_grass` A |
| Jupiter | `tincture_jupiter` | `monstera` A, `pitcher_plant` A |
| Saturn | `tincture_saturn` | `climbing_ivy` C, `heather` A, `lichen` A, `moss` A, `dead_sagebrush` A, `mushroom_cap` A, mushroom A |

**Each species' first tincture is a discovery** (family `tiamat_default_magic.herb:*`, 5 insight each, about 30 species): the long-tail exploration reward of this path, and it sends a player through every biome. `exports.register_herb(material, planet)` lets later mods add plants.

### 6.4 The menstrua — solvents and salts, historically

The order below is the order they were discovered, and the tree respects it: nothing needs a reagent that had not yet been invented when its operation was.

| Reagent | Recipe (station, degree, vessel, time) | Historical note |
|---|---|---|
| `vinum` → `vinegar` → `distilled_vinegar` | `#fruit` or 3 wheat + water bucket, bath 1 day → vinum; 1 day more → vinegar; still → distilled | antiquity |
| `verdigris` | copper ingot over vinegar, bath 1 day | Pliny |
| `aqua_vitae` → `spirit_of_wine` | vinum, still, 2nd degree; spirit = aqua vitae through the receiver 7× (7 recipes, each 1 min) | Salerno, 12th c.; "quintessence" of Rupescissa, 14th c. |
| `green_vitriol` | 27 units `pyrite` + water, bath 3 days — **or** a placed pyrite block under open rain (`weather_at` says rain or storm there, and `get_light(pos).sun == 15`) for 3 days turns to a `green_vitriol` drop when dug (this mod's random-tick handler on `pyrite` is forbidden — World owns it — so the rain route uses this mod's own list of pyrite blocks a player has *placed*) | weathered pyrite: the mines' copperas |
| `oil_of_vitriol` + `caput_mortuum` | 2 vitriol, retort, 3rd degree, 2 min | Jabir / pseudo-Geber |
| `blue_vitriol` | copper ingot + oil of vitriol | "vitriol of Venus" |
| `salt_of_tartar` | 27 units `#ash` + water, bath, evaporate | potash |
| `saltpeter` | 27 units `#plant` + 9 `#ash` + 27 dirt, bath 3 days | the nitre bed |
| `aqua_fortis` | `#saltpeter` + green vitriol, retort, 3rd degree | pseudo-Geber, c. 1300 |
| `spirit_of_salt` + `sal_mirabilis` | 9 units salt + oil of vitriol, retort | Glauber, 1648 |
| `sal_ammoniac` | bone + 9 units salt, aludel, 3rd degree | medieval animal-matter route |
| `aqua_regia` | aqua fortis + sal ammoniac | "royal water": dissolves gold |
| `green_lion` | gold ingot + aqua regia, bath 1 day | the lion that devours the sun |
| `flowers_of_sulfur` | 27 units `sulfur`, aludel, 3rd degree → 9 | sublimation |
| `quicksilver` | 27 units `cinnabar`, retort, 3rd degree → 9 | Theophrastus |
| `vermilion` | quicksilver + flowers of sulfur, aludel | Jabir |
| `phosphorus` | 27 units bone ash + oil of vitriol + charcoal, retort, 4th degree → 3 | Scheele & Gahn, 1769–71 |
| `alkahest` | aqua regia + spirit of wine + sal alembroth, Egg, 1st degree, 7 days → 3 phials | Paracelsus named it; van Helmont claimed it |

**Cinnabar.** World has no mercury ore. Sibling ask **W-M1** (§14): a `cinnabar` block, crust round World's existing sulfur features in Volcanic Foothills and Geyser Basin, and seams in Mineral Vein Tunnels — which is where it really forms. **Fallback until it lands:** native quicksilver droplets from sulfur crust: 27 units `sulfur`, retort, 4th degree → 1 quicksilver (a ninth of the cinnabar yield, and marked in the recipe name as a stand-in so it is deleted when W-M1 ships).

### 6.5 The planetary metals and the sigils

The seven sigils are carved into the top face of a whole block (§7.1). A sigil block **touching** an athanor speeds that athanor's recipes whose output or main input is its metal by `magic.sigil_percent` (15 %), doubled when the sigil is carved from that metal's own ore block — `gold_ore` for Sol, `silver_ore` Luna, `copper_ore` Venus, `iron_ore` Mars, `tin_ore` Jupiter, `lead_ore` Saturn, `cinnabar` Mercury. Recipe-to-planet is a table in `config.lua`. The speed-up is applied by this mod, not Craft: when an athanor is lit (Craft `on_first`/`on_crafted` cannot say; so this mod keeps its own list of athanors from `on_place` and polls each one's neighbours every 200 ticks), it credits extra progress — **ask C-M6** (`craft.add_progress(container, ticks)`) makes that exact; without it, the sigil instead refunds one input in N (N from the percentage) through `on_crafted` — same economy, different feel.

**Cupellation** is the path's first real economy: silver extracted from lead, as nearly all medieval silver was.

### 6.6 Talismans

Seven talismans, each a sigil struck in its metal: a medal made at Craft's anvil from 1 ingot, struck on the carved sigil block as the die. Craft does not accept a carved block as a tool, so this is a wrapped recipe (§7.5): this mod checks the carved die is in the player's pack (not taken), then `craft.perform`s. C-M1 makes it an ordinary recipe. Worn in Life's `tiamat_default_life:worn` view (4 slots; confirm another mod may read it — **ask L-M4**). Polled every 40 ticks per online player (round-robin, one player per tick).

| Talisman | Passive | Mechanism | Needs |
|---|---|---|---|
| Sol | never cold | re-cure via Life | L-M2 (`add_effect warmth`); fallback: none, shows "you feel the sun" |
| Luna | night-sight | the sky brightened through Weather's overlay | Wx-M1 |
| Venus | tame animals follow you | Life creatures near are steered | L-M5; fallback: none |
| Mars | fists do 3 | Life `add_weapon` cannot key on a worn item | L-M2 |
| Jupiter | food lasts longer | Life `steady` effect | L-M2 |
| Saturn | ore-sense 4 blocks | as the gnome, smaller | engine only ✔ |
| Mercury | swiftness 1 | abilities | L-M3 |

Ship Saturn first: it needs nothing from anyone.

### 6.7 Elixirs and this mod's own effects

Every drink is registered with Life's `add_food` (`sound = "drink"`), so Life's X key drinks it, Life's effect icons show Life's effects, and **anyone can drink them** — magic players make, anyone drinks: trade across the Fork is automatic.

| Elixir | Life spec | Own effect (started from `on_eat`) |
|---|---|---|
| Vigour | `effects = {{"regeneration", 300}}` | — |
| Fortitude | `{{"resistance", 600}}` | — |
| Warming / Cooling draught | `temperature = "warm"/"cool"`, `{{"warmth"/"cooling", 1200}}` | — |
| Night-sight | — | sky brightened, 2,400 ticks (Wx-M1; until then `rested` and a faint glow of particles round the drinker) |
| Swiftness | — | speed ×1.3, 1,200 ticks (L-M3) |
| Rosewater, teas | small heal, `rested` | — |
| Theriac | makes Life's own `antidote` | — |
| Aurum potabile | `heal = 27`, `cures = {"poison","wither","radiation","burning"}`, `{{"regeneration",1200}}` | — |
| Elixir of Life | `{{"regeneration",2400},{"resistance",2400}}` | Quintessence regen ×2, 12,000 ticks |
| Panacea | full heal + cure all | same to everyone within 6 (L-M2) |
| Undine's gift | — | water-breathing (L-M6) |

Own effects live in the player record (`fx:<uuid>:<id>` = expiry tick), are ticked from one list, and are **multiplied** by `magic.elixir_duration_percent`. Durations above are base.

**Fallback for L-M3 (abilities).** Until Life composes abilities, this mod never calls `set_player_abilities` at all; swiftness and sylph flight are `push_player` impulses (a forward nudge per 10 ticks while moving; a small upward impulse per tick during flight). The engine does not document impulses as client-predicted, so this is tried in a real window before it ships; if it rubber-bands, both wait for L-M3.

### 6.8 Quintessence (the one bar)

**Held back (decided 2026-09-30, for play).** Nothing in tiers 3 or 4 spends Quintessence — its first uses are the Caduceus and the Sylph's Wings, at tier 5 — and a Life stat today is drawn for every player, so registering it now would put an empty bar on every child's and every science player's screen for nothing. The stat is registered when Life answers L-M1 or when tier 5 is built, whichever comes first; if tier 5 comes first, the fallback below applies.


`life.add_stat("tiamat_default_magic:quintessence", { max = 100, regen = 0, name = "Quintessence", colour = { 214, 190, 90 }, start = 0 })` — max is the ceiling for anyone; a player's own ceiling is `10 + magic.quintessence_max` (so 10 / 30 / 70), enforced by this mod clamping with `set_stat`. Regen is this mod's: 1 point per 200 ticks, ×(1 + regen percent), paused while the player is a ghost. Refilled by *spirit of wine* (+5), *quintessence* (+20), *aurum potabile* (full). Spent by the caduceus (Stride 5, spray 10), sylph flight (10 / 10 s), the alkahest pour (1 per block), projection on the world (20).

Quintessence is small on purpose: the Art is in substances, and the bar is the handful of things a substance cannot do by itself.

### 6.9 Familiars — the living work

Six creatures, each a model (§10.1) and an entity this mod owns; all behaviour in `familiars.lua` on `register_on_entity_step`. **Found, then bound**: each has a place and time it appears, a thing that binds it, and a use. At most `1 + magic.familiars` active (1 → 2 → 3); a familiar dismissed is a record, not a death.

| Familiar | Appears (per online Adept who holds the node, checked every 600 ticks) | Binding | Use (node that adds it) |
|---|---|---|---|
| **Salamander** (Paracelsus; Cellini saw one as a boy) | in an athanor the player lit that has burned 1 philosophical day at any degree (this mod counts the ticks its block is `athanor_lit`) | feed it 9 units `sulfur` or `flowers_of_sulfur` | follows you (the kiln bonus is the node's); binding gives a `salamander_ember`, which in an athanor's vessel slot is the 4th degree without bellows (`salamander_forge`); sets hostile creatures alight (`greater_elementals`, Life `set_alight`) |
| **Undine** | a brimming block of World `water` (`get_fluid` volume 27) at night within 8 of the player — or at any hour in the Gloam's `still_water` pools (Shadow Pool Chambers) | a phial of `rosewater` | carries up to 4 blocks of water (`set_fluid` from its own tally, which it fills from water it stands in: conserved), douses (`weather.extinguish`) and wets farmland (`undine`); water-breathing (`undine_tides`); heals 1 per 100 ticks (`greater_elementals`, L-M2) |
| **Gnome** (Paracelsus coined the word) | below World's `dark_caves` band (`depth_band`) | a `silver_grain` | ore-sense: particles over every `ore`-tagged block within 8 every 100 ticks — a bounded 17×17×17 read spread over 17 ticks (one slice each) (`gnome`); tunnels 1×2 ahead up to 16 as a tier-2 tool, drops to the player (`gnome_delving`); carries ore from its own digging (`greater_elementals`) |
| **Sylph** | peaks (`alpine_highlands`, `frozen_wastes`, `icefall`) or anywhere in `storm`/`blizzard` | a phial of `aqua_vitae` | one mid-air jump and a soft landing (`sylph`); flight (`sylph_flight`); scouts: names the biome 200 blocks ahead (`greater_elementals`) |
| **Homunculus** | made, not found: `conjoined_matter` + `elixir_vitae` + `caput_corvi`, 40 days in the Egg (Paracelsus, *De natura rerum*, 1537) | — | a 27-slot satchel (a container `tiamat_default_magic:satchel:<entity id>`); moves fuel and inputs from one chest into athanors within 8, at most one stack per 40 ticks |
| **Basilisk** (Theophilus Presbyter, *De diversis artibus* III, c. 1120) | made: a Life `egg` + `vermilion`, bath 7 days | — | guard: hostile creatures within 6 that it sees (`line_of_sight`) are frozen 5 s (`set_entity speed 0` on this mod's entities; Life's need L-M2); its shed `basilisk_ash` + copper ingot → gold ingot, once per day ("Spanish gold") |

The **phoenix** is not an entity: it is a node (`phoenix`) that, once per 3 philosophical days, collects the player's dropped stacks on death — **needs L-M7** (`on_death` answering the drop position and the dropped stack entities, or a keep-inventory flag); without it the node gives a *phoenix feather* on death that points back to where you died (a compass), which is honest and still useful.

**Essences of the beasts** (`essentia_animalium`): Life's `on_kill(uuid, kind)` gives a chance-free counter per kind; every third kill of a kind with a `phial` in inventory yields a `beast_essence` (detail `k=<kind>`, so no recipe consumes it — it is fed by use). Each kind first distilled is a discovery (family `essence:*`, 10 each, 26 kinds). Fed to a familiar, an essence sets one trait slot: *horse* speed ×1.5, *wolf* guards you, *goat* carries +9 slots, *bat* sees ores 2 further, *crow* flies (sylph only), *mammoth* health ×2, *fox* ignores hostiles. Three slots per familiar, overwritable.

**Budget.** Familiars are capped per player (3) and per server (config `familiars_per_server`, default 60). Each thinks every 10 ticks, paths at most once per 20 ticks with `budget = 400`, and never paths closer than 6 blocks to its master.

### 6.10 The Stones, projection and the economy

| Stone | Made (Egg, 1st degree) | Projection (`transmutation` world option on) |
|---|---|---|
| White Stone | `peacock_matter` + `fixed_mercury` + `tincture_luna`, 7 days | 1 stone + 9 quicksilver / tin / lead ingots → 9 silver ingots; ×(1 + projection %) |
| Red Stone | `solar_sulfur` + `ferment` + `aurum_potabile` + `white_stone`, 40 days (cibation: 4 stages of 10 days, each fed a `tincture_sol` — skip a feeding and the stage waits, nothing is lost) | 1 stone + 9 base ingots (copper, tin, lead, iron bar, silver) → 9 gold ingots; ×(1 + projection %) |
| Multiplication | stone + gold ingot + quicksilver, 7 days → 2 stones (1 day with Lapis Infinitus) | — |

Transmutation is the iconic goal and it is **deliberately late**: gold's only big pre-Fork use (the Keystone) is already spent, the White Stone is the 5th tier and the Red the 6th, and 40 real hours of work sit between the first *caput corvi* and the first projection. With the world option off, the Stones remain ingredients and medicines.

**Gate XII, projection on the world**: a Red Stone and 20 quintessence thrown at the ground turns base-metal ore blocks within radius 2 into `gold_ore`, one block per tick (`game.set_block`), and heals nearby creatures (L-M2).

### 6.11 Cosmos — worlds

**The microcosm** ("man is a little world", Paracelsus). One instanced domain template `tiamat_default_magic:microcosm`; each Adept's instance key is the first 16 hex of their UUID. Generator: a floating island 48 blocks across (a density ellipsoid, grass cap from World's `grass`/`dirt`, a spring of water, 3 random World plant covers from `rng_stream(pos, "micro")`), air all round. Entered by using your placed-or-held Philosophers' Egg with the node; left the same way (return position stored). A safe farm, a store, a place to run athanors undisturbed.

**Woven worlds** (`opus_mundi`). Five templates registered at load, one per archetype — `world_earth` (caverns and crystal, deep ores), `world_water` (archipelago on a planet-wide sea), `world_air` (floating islands over a void, sylph-haunted), `world_fire` (basalt and lava seas, obsidian), `world_quintessence` (glass, calcite and light, crystal spires) — each a compiled density field built once at load from World's own blocks.

The **offset trick** (because a generator is not told which instance it fills — **E-M1**): every instance is given, at weaving, a *region* of its template's infinite coordinate space — `x0 = (slot × 2 + 1) × 2^20` — and its players are placed there and only ever there. The generator is a pure function of position, so each world is a different slice of noise; and because it can compute `slot = x // 2^21`, it can also read **parameters from the slot number** without storage: `(slot % 8)` picks the planetary vein (`planetary_veins`), `(slot // 8) % 8` the sea level band, `(slot // 64) % 7` the sky (applied per player through Weather's overlay on arrival — Wx-M1 — since a domain sky is per template; `planetary_skies` waits on it). Weaving chooses the lowest free slot whose parameters match what the player chose. Clean, deterministic, no engine change; E-M1 would retire it.

**The Loom** is a construct (§7.3): a 5×5 floor. Use its centre with the Rebis in hand: a dialog (archetype, sky, veins, sea) → consumes the Rebis, the four elemental quintessences, 27 prima materia blocks' worth of units and 1 Red Stone → `create_domain` → the weaver is transferred in. `native_spirits` spawns up to 4 wild elementals of the world's element near arrivals. `worldgate` places a standing correspondence gate in the overworld for the world, usable by anyone on its allow-list. The per-player cap is the world option `woven_worlds`.

**Solve et coagula.** Using the Loom with no Rebis and your world selected: everyone inside is `transfer_entity`'d to their stored return point (or world spawn), then `destroy_domain` in the same callback (the engine orders it right); half the prima materia comes back. The slot is free again. Magic *creates and destroys*; science *travels and modifies* — the Schism asymmetry, kept.

**As above, so below** (correspondence gates): two Emerald-glyph constructs (§7.3) linked by using one then the other with a `quintessence`; stepping on either (`register_on_player_move`) moves you to the other (`move_player`, same domain; across domains only via a worldgate). 5 quintessence a trip; cap 8 pairs per player.

### 6.12 Insight: where this path's comes from

Progress's studies of gold and silver pay about 330 an hour at the end of the shared tree. That cannot pay for 102 nodes, so this path brings its own income, **rising with the tier**, all through Progress's exports so the pacing ledger (`progress sources`) sees every point:

| Source | How | Value |
|---|---|---|
| **Studies** (`register_study`, research table) | `study_calx` (any calx, 1) · `study_tincture` (1) · `study_vitriol` · `study_quicksilver` · `study_aqua_regia` · `study_caput_corvi` · `study_peacock` · `study_white_stone` · `study_solar_sulfur` · `study_aurum_potabile` · `study_prima_materia` · `study_red_stone` · `study_elemental_quintessence` | 15 · 20 · 30 · 40 · 60 · 120 · 150 · 300 · 350 · 250 · 200 · 1,500 · 400 (ticks: 600 → 12,000) |
| **Gates** (discoveries) | first completion of Gate *n* | 25 × *n* (1,950 total) |
| **Herbs** (family `herb:*`) | first tincture of each species | 5 (~150) |
| **Essences** (family `essence:*`) | first essence of each Life creature | 10 (~260) |
| **Emblems** (family `emblem:*`, `atalanta_fugiens`) | 50 of Maier's emblems, each tied to a first (Emblem I "the wind carried it in his belly" ↔ first sylph …; table in `config.lua`) | 10 (500) |
| **Familiars** (discoveries) | first of each found and bound | 30 each |
| **Toybox** (group `toybox`) | first blue flame, first lamp, first rosewater, first Tree of Diana grown, first peacock shimmer | 3–10 |
| **Milestones** (`award`) | first transmutation (200), first world woven (1,000), first microcosm visit (100) | — |
| **Assay** | +25 % on every study (`on_crafted` → `award` the bonus) | — |

The model income per tier (the "target income" column in §13) is these sources, played. It is a guess to be measured — see §13.

---

## 7. Glyphs, constructs and relics — the 3-D crafting

### 7.1 The glyph set

Every glyph is a 27-cell mask (index `x + 3y + 9z`, bit `index`) carved in the UI's shape crafter, which spends one unit of the block's material per remaining cell. **Rotation and mirror do not matter**: `glyphs.lua` computes all 48 symmetries of each shape at load and registers every distinct variant with `craft.register_glyph(mask, id)` (the "variants" column). `tools/glyphs.py` (§13) generates this table and proves that no variant of any magic glyph collides with a science glyph, with the UI's Slab / Stairs / Pillar presets, or with another magic glyph.

| Glyph | Cells | Canonical mask | Variants to register | Shape (top · middle · bottom layer; rows z=0..2, columns x=0..2) | Reading |
|---|---|---|---|---|---|
| `sol` | 19 | 16612927 | 6 | <code>...  ###  ###<br>.#.  ###  ###<br>...  ###  ###</code> | Sol · gold. Bonus ×2 when carved from `gold_ore`. |
| `luna` | 22 | 83853119 | 24 | <code>..#  ###  ###<br>.##  ###  ###<br>..#  ###  ###</code> | Luna · silver. ×2 from `silver_ore`. |
| `mars` | 24 | 117374719 | 12 | <code>##.  ###  ###<br>#.#  ###  ###<br>.##  ###  ###</code> | Mars · iron. ×2 from `iron_ore`. |
| `venus` | 22 | 100433791 | 6 | <code>#.#  ###  ###<br>...  ###  ###<br>#.#  ###  ###</code> | Venus · copper. ×2 from `copper_ore`. |
| `jupiter` | 22 | 100433855 | 48 | <code>.##  ###  ###<br>...  ###  ###<br>#.#  ###  ###</code> | Jupiter · tin. ×2 from `tin_ore`. |
| `saturn` | 22 | 50233279 | 48 | <code>.##  ###  ###<br>..#  ###  ###<br>.#.  ###  ###</code> | Saturn · lead. ×2 from `lead_ore`. |
| `mercury` | 23 | 100597439 | 24 | <code>.#.  ###  ###<br>#.#  ###  ###<br>#.#  ###  ###</code> | Mercury · quicksilver. ×2 from `cinnabar` (W-M1). |
| `fire` | 15 | 6127127 | 6 | <code>...  .#.  ###<br>.#.  ###  ###<br>...  .#.  ###</code> | Fire (the pyramid). Counts in the Circle only carved from `lava_rock` or `magma_crust`. |
| `water` | 25 | 134143999 | 6 | <code>###  ###  ###<br>#.#  #.#  ###<br>###  ###  ###</code> | Water (the cup). From `ice`, `clear_ice` or `calcite`. |
| `air` | 20 | 129928175 | 1 | <code>###  #.#  ###<br>#.#  ...  #.#<br>###  #.#  ###</code> | Air (the open frame). From `pumice`. |
| `earth` | 19 | 49020602 | 1 | <code>.#.  ###  .#.<br>###  ###  ###<br>.#.  ###  .#.</code> | Earth (the rounded stone). From `granite`. |
| `quintessence` | 7 | 4289552 | 1 | <code>...  .#.  ...<br>.#.  ###  .#.<br>...  .#.  ...</code> | The fifth, joining all six ways. From `crystal`. |
| `ouroboros` | 8 | 14700600 | 3 | <code>...  ###  ...<br>...  #.#  ...<br>...  ###  ...</code> | The serpent ring. Any stone. |
| `seal` | 25 | 134151167 | 3 | <code>###  ###  ###<br>#.#  ###  #.#<br>###  ###  ###</code> | The Hermetic Seal (a ward). Any stone; `black_marble` doubles its radius. |
| `emerald` | 23 | 50331327 | 6 | <code>.#.  ###  ###<br>###  ###  ###<br>.#.  ###  ###</code> | The Tablet: correspondence gates. From `crystal`. |

Intaglio sigils are a whole block with the pattern cut from one face, because the shape editor starts full and a left-click removes a cell — a child carves the Sun in eight clicks, or one with a preset (U-M1).

### 7.2 Reading a glyph in the world

A placed carved block is `get_block(pos) → { material, occupancy }`; `craft.glyph_of(occupancy)` names the glyph; the material is the block id. Constructs are **checked on use and on place only, never on the tick**: a check reads at most 5×5×5 = 125 blocks, and its result is cached in storage against the construct's anchor until any block in its box is dug or placed (`register_on_dig_complete` / `register_on_place` invalidate by a spatial key).

### 7.3 Constructs

| Construct | Pattern (anchor in **bold**) | Effect |
|---|---|---|
| Planetary athanor | **athanor** + a sigil block on any face | §6.5 |
| Ouroboros ring | **athanor** + 8 `ouroboros` blocks in the ring round it at its own height | long works −20 % |
| Circle of Four | 5×5 floor: **quintessence** centre; `fire`, `water`, `air`, `earth` at the four mid-edges, each carved from its element's material | binding more familiars; the elementals' second abilities; source of elemental quintessence (the elemental stands on its own glyph for 1 day) |
| Hermetic Seal | **seal** block | ward, radius 6 (12 with `greater_seal`, ×2 on `black_marble`); allow-list by chat `magic seal allow <name>` |
| Correspondence gate | 3×3 floor: **emerald** centre, `sol` and `luna` at alternate corners (as above, so below) | §6.11 |
| Chymical Wedding | **athanor** with `sol` on one side, `luna` opposite, `quintessence` on top | required to make the Rebis |
| Rose Garden | 7×7 of grass/dirt bordered by `venus` sigils, a Tree of Diana inside | wild plant covers bloom inside every 600 ticks (`set_block` of a random World flower from the palingenesis list onto empty grass); rose blooms regrow at once |
| The Loom | 5×5 floor: **quintessence** centre; the 7 sigils + `emerald` on the 8 cells round it; `fire`/`water`/`air`/`earth` at the outer mid-edges | weaving (§6.11) |

### 7.4 The Tree of Diana

One block, `tiamat_default_magic:arbor_dianae`, placed as a seed (1 cell) and grown by this mod, **cell by cell**, through `game.set_block(pos, id, mask)` — 27 stages from one block id, with an order table that grows a trunk then branches. One cell per 400 ticks while a phial of `aqua_fortis` has been poured on it in the last day (so 27 cells = 3 hours of tended growth). Dug, it drops `silver_ingot` units equal to its cells (27 = one ingot) — a small, visible, lovable silver farm (`drops = { ["tiamat_default_craft:silver_ingot"] = 27 }` per full block, scaled by the engine by occupancy). Growth is from this mod's list of placed trees (≤ 64 per player), never from a random tick.

### 7.5 Relics — shaped parts assembled

The Technic-style layer: late items are **assembled** from carved blocks plus reagents.

| Relic | Carved parts | Other inputs | Station |
|---|---|---|---|
| Caduceus | `mercury` (in `silver_ore`), `ouroboros` (in `gold_ore`) | a stick, 2 quicksilver, 1 quintessence | workbench |
| Philosophers' Egg (sealed) | — | (§6.1) | kiln |
| Talisman | the sigil block itself (checked, not taken) | ingot | anvil (wrapped) |
| The Loom's key | `quintessence` (crystal) | Rebis | used, not made |
| Rebis | `sol` (gold ore) + `luna` (silver ore) | red + white stones, green lion | athanor, Chymical Wedding construct present |
| Microcosm seed | `earth` + `water` (their materials) | prima materia 27 units, quintessence | athanor, Egg vessel |

**Mechanism.** With Craft ask **C-M1** landed, these are ordinary recipes whose inputs (or tools) name a glyph: `{ glyph = "tiamat_default_magic:sol", material = "tiamat_default_world:gold_ore", count = 1 }`. **Fallback (works today):** this mod registers the relic recipe with Craft with its non-carved inputs only, and wraps it: a relic's screen button calls this mod, which `game.take`s the exact carved stacks from the player (engine `take` matches shape exactly — take each registered variant until one answers), then `craft.perform`; if perform fails, the carved stacks are given back. One transaction, conserved.

---

## 8. Blocks — five

| Block | Why it must be a block | Notes |
|---|---|---|
| `emerald_tablet` | Progress's door must be a block | light {2,9,4}; hardness 2.6; tags `crystal`, `glowing` |
| `athanor` | a Craft station in the world | hardness 2.0; tags `stone`, `hard` |
| `athanor_lit` | Craft's `lit_block` | light {12,7,2}; contact fire |
| `hermetic_lamp` | light needs a block (the engine has no item light) | light {6,12,8}; hardness 0.5; transparent; the Apothecary's Bench's gift |
| `arbor_dianae` | grows in the world, cell by cell | transparent (cutout), light {3,3,4}; drops silver units |

Everything else — vessels, reagents, stones, talismans, familiars' food, relics — is an item; every in-world structure is carved from World's own blocks. The Loom, the Circle, the gates and the seals add **no** blocks.

---

## 9. Items

Registered from a table in `items.lua` (id, name, description; texture from `tools/make_textures.py` placeholders: a tinted phial, powder, crystal, ingot or medal silhouette per category). About 120:

- **Bench:** `mutus_liber`, `mortar`, `ground_herb`, `flame_powder_blue` (sulfur), `_green` (copper), `_yellow` (salt), `_white` (bone ash), `chamomile_tea`, `mint_tea`, `bramble_tea`, `poultice`, `copper_still`, `rosewater`, `mint_water`.
- **Vessels:** §6.1 table, plus `blowpipe`.
- **Calxes & salts:** `litharge`, `minium`, `putty`, `aes_ustum`, `crocus_martis`, `bone_ash`, `silver_grain`, `salt_of_tartar`, `sal_saturni`, `salt_of_venus`, `sal_mirabilis`, `sal_ammoniac`, `sal_alembroth`, `saltpeter`.
- **Menstrua:** §6.4 table.
- **Principles:** `principle_mercury`, `principle_sulfur`, `principle_salt`.
- **Tinctures & elixirs:** seven tinctures; `elixir_vigour`, `elixir_fortitude`, `draught_warming`, `draught_cooling`, `elixir_night_sight`, `elixir_swiftness`, `theriac` (→ Life's antidote), `aurum_potabile`, `elixir_vitae`, `panacea`, `quintessence`.
- **The Work:** `conjoined_matter`, `caput_corvi`, `peacock_matter`, `fixed_mercury`, `white_stone`, `solar_sulfur`, `ferment`, `red_stone`, `rebis`, `prima_materia`, `quintessence_fire`, `_water`, `_air`, `_earth`.
- **Metals & tools:** `amalgam_gold`, `amalgam_silver`, `amalgam_tin`, `electrum`, `living_orichalcum`, `orichalcum_pick`, `_axe`, `_spade`, `_chisel` (Craft `register_tool`, tier 4, 1,200 uses; engine tools `speed_multiplier` 9; anvil recipes with the iron hammer), seven `talisman_*`, `caduceus`, `phosphorus`, `phosphorus_spill`.
- **Living work:** `beast_essence` (detail), `basilisk_egg`, `basilisk_ash`, `phoenix_feather`, `homunculus_vial` (spawns the homunculus).

Groups registered with Craft: `#saltpeter`, `#oil_of_vitriol`, `#quicksilver` (shared with science, §2), `#tincture` (the seven), `#calx`, `#vitriol`, `#base_metal` (for projection: copper, tin, lead ingots, iron bar), `#stone_of_the_wise` (white, red).

---

## 10. Sounds, models, screens

### 10.1 Models (6 of the server's 64)

`salamander`, `undine`, `gnome`, `sylph`, `homunculus`, `basilisk`. Self-contained `.glb`, clips `idle`, `walk`, `swim` (undine), `run`. Friendly silhouettes — a child should want one, not fear one. The basilisk is a grumpy rooster-lizard, not a monster.

### 10.2 Sounds

`bubble` (athanor working), `hiss` (distillation), `chime` (a gate passed), `hermetic` (the Oath), and **one short fugue loop per colour stage** (Maier wrote a fugue for each emblem; public domain scores, played on a synthesised organ) — the athanor plays its stage's fugue via `play_loop` within radius 12 while a long work runs. Every sound bound to a cue of its name so sound packs can re-skin.

### 10.3 Screens

- **The *Mutus Liber*** (opened by using the book, or `magic book` in chat; action `mutus_liber`, default key **J**, once the engine's actions work — §2.1; a dialog `tiamat_default_magic:liber` in the interface's look, not a tab: the interface draws a tab for every player, and the book is only for whoever carries one): pages of pictures, one per node the player holds or can next learn — never the whole tree at once. Text line under each picture for readers.
- **Familiars** (a UI tab): each bound familiar, its traits, dismiss/summon buttons; action `familiar` (default key **K**, once actions work) summons the first.
- **Athanor dial** (a tab beside Craft's station screen): the long work's stage, colour, time left.
- **The Loom** (dialog).
- **No HUD script of its own.** Quintessence is Life's bar. Toasts use Progress's discovery flash and chat.

---

## 11. The picture primer (*Mutus Liber*)

The historical *Mutus Liber* (La Rochelle, 1677) is fifteen plates and no words: the perfect model for a child's recipe book. `primer.lua` generates, per recipe node, a page tree of UI images: inputs (item icons) → station/vessel/degree icon → output icon, plus the node's first sentence as a caption. Icons come from item textures (`register_picture` on the same PNGs). **Art budget ≤ 120 pictures**; where a picture is missing the page shows text. The fifteen historical plates (public domain) may be used as chapter frontispieces.

---

## 12. Exports

`game.exports("tiamat_default_magic")`, version 1, never raises, answers `nil, reason`:

| Field | What |
|---|---|
| `version` | `1` |
| `quintessence(uuid)`, `spend_quintessence(uuid, n)` | the bar, through Life |
| `register_herb(material, planet)` | another mod's plant gets a tincture (while mods load) |
| `glyphs` | read-only `{ id = { mask, variants } }` |
| `familiars(uuid)` | `{ { kind, entity } }` |
| `is_warded(pos, uuid)` | whether a seal forbids `uuid` there |
| `on_opus(fn(uuid, stage))` | a player completes a gate or a stone |

---

## 13. Pacing — the climb, and how it is measured

**Target: about sixty hours for the whole tree, about forty for the spine**, after the ~3 hours of the shared tree and the ~2 hours of deep mining the Keystone takes. Model (a guess, in `docs/pacing.md` and `config.lua`):

| Tier | Nodes | Whole tier (insight) | On the spine | ★ kid nodes | Target income / hour | Hours for the whole tier |
|---|---|---|---|---|---|---|
| 1 | 3 | 25 | 0 | 3 | — | — |
| 2 | 2 | 45 | 0 | 2 | — | — |
| 3 | 21 | 2,200 | 1,690 | 11 | 450 | 4.9 |
| 4 | 26 | 5,890 | 4,120 | 9 | 750 | 7.9 |
| 5 | 21 | 9,950 | 4,500 | 5 | 900 | 11.1 |
| 6 | 17 | 16,200 | 11,600 | 6 | 1100 | 14.7 |
| 7 | 12 | 25,300 | 18,800 | 3 | 1400 | 18.1 |
| **all** | **102** | **59,610** | **40,710** | | | **≈ 57 h** |

What a player waits on, per tier, besides insight — the gates that make it *take a while* without grinding a bar:

| Tier | Material gate | Time gate | Place gate |
|---|---|---|---|
| 3 | pyrite, bone, copper, lead, wheat/fruit | 1-day ferments | none (all near the surface) |
| 4 | cinnabar (volcanic/geyser biomes), sulfur, silver, saltpeter's plants | the *nigredo*: 3 days | dark caves (gnome), peaks (sylph), still water (undine) |
| 5 | gold, crystal, orichalcum (2,000 down) | the White Stone: 7 days | the Circle of Four's element stones (lava rock, ice, pumice, granite: four biomes) |
| 6 | gold in bulk, prima materia (the alkahest eats rock) | the Red Stone: 40 days; the homunculus: 40 days | — |
| 7 | orichalcum, diamond, four quintessences | multiplication | your own worlds |

**Measure, don't guess.** Progress logs every insight change by source (`progress sources`, and the server log's `pacing` lines). This mod names its sources through the discovery groups (`found_herbs`, `found_essences`, `found_gates`, `found_emblems`, `found_toybox`) and studies. After a real session the model table is replaced by the ledger, and only `config.lua` changes.

`tools/check_tree.py` (shipped with the repo, run by CI): loads the node table, proves no dangling requires, no cycles, no tier inversion, every tier-3+ node reaches `shared.fork`, ≤ 8 requires, costs in range; prints the table above. `tools/glyphs.py`: proves the glyph table (§7.1).

---

## 14. Asks

### `docs/sibling-asks.md`

**Craft**
- **C-M1, a glyph as an ingredient or a tool.** `inputs = { { glyph = "<id>", material = "<id or #group>", count = n } }` consumes carved stacks whose `glyph_of` is that id (any registered variant); the same form in `tools` finds one without consuming it. The rule "a carved stack is never an ingredient" stays the default; naming the glyph is the opt-in, because *the carving is the ingredient*. Fallback §7.5.
- **C-M5, long recipes.** Craft's `max_ticks` is 72,000. Ask: a station opting in with `long = true` accepts recipes up to 960,000 ticks (40 days); and say whether a lit station advances while its chunk is unloaded. Fallback: step chains (§6.1).
- **C-M6, `add_progress(container, ticks)`.** For the sigil bonus. Fallback: refunds.
- **C-M8, `craft.fuel_percent` on every heat station** a player lit, not only the kiln.
- **C-M9, a use at a fire for a held thing Craft does not want.** Craft's listed use callback at a campfire opens the fire's box whatever is held. Ask: answer `nil` when the held stack is neither fuel, cookable, nor a striker, so a later mod's listed callback hears it — or pass the container to `on_crafted` as a fourth argument (`fn(uuid, recipe_id, outputs, container)`), so a recipe's effect can be put where it was made. Fallback: flame powders are campfire recipes that make nothing, and the flare is shown where the player is looking.
- **C-M10, an athanor's slow fire.** A station field `burn_percent` (per cent of each fuel's ticks, default 100), so the athanor can burn a block of coal for a philosophical day, as a real athanor's self-feeding tower did. Without it a Red Stone costs ~530 blocks of coal. Fallback: the Stones' durations are cut in `config.lua`.
- **C-M7, idempotent glyphs.** Registering a mask again with the *same* id answers `true` (a mod re-registering its own variants must not fault).

**Life**
- **L-M1, per-player stat ceiling.** `set_stat_max(uuid, id, max)`; a bar at max 0 is not drawn. So a science player never sees Quintessence.
- **L-M2, effects and health on others.** `add_effect(target, id, ticks)`, `cure(target, id)`, `heal(target, n)`, `hurt(target, n, kind, source)` for players and Life's creatures. Unlocks: sprayed elixirs, panacea, the undine's healing, Sol/Mars/Jupiter talismans, the basilisk's stare on Life's creatures.
- **L-M3, composed abilities.** `set_ability(uuid, source, { speed_mul, fly })` combined by Life with its own. Fallback §6.7.
- **L-M4, reading the worn view.** Confirm `game.inventory(uuid, "tiamat_default_life:worn")` from another mod.
- **L-M5, steer a Life creature.** `follow(entity, uuid, ticks)` for the Venus talisman.
- **L-M6, air.** `set_air(uuid, n)` or a `water_breathing` effect.
- **L-M7, the phoenix.** `on_death(fn(uuid, pos, drops))` with the drop entities, or `keep_inventory(uuid)` once.

**World**
- **W-M1, cinnabar.** A `cinnabar` block (tags `ore`, `mineral`; hardness 1.8; drops itself) as crust round Volcanic Foothills fumaroles and Geyser Basin throats, and seams in Mineral Vein Tunnels. Science needs it too (barometer, daguerreotype). Fallback §6.4.
- **W-M3, pyrite's random tick.** The engine allows one random-tick handler a material, and World does not tick pyrite today. Ask: leave pyrite to this mod (weathering to vitriol under rain), or tick it in World and call an export of this mod. Fallback: the list of placed pyrite blocks in §6.4.
- **W-M2 (optional), the magical shells.** If World builds `hot_magical` / `cold_magical` / `slime_border`, this mod reads `hot_fiber_stone` as *salamander's wool* (asbestos was so called) and `caul` as the membrane of the world-egg — both would join the T6–T7 recipes. Nothing waits on it.

**UI**
- **U-M1, shape-crafter presets from siblings.** `add_preset{ id, label, mask, visible = fn(player) → bool }`: buttons beside Slab / Stairs / Pillar, shown when `visible` answers true (a node held). The biggest single thing for children.

**Progress**
- **P-M1, a branch label and a reveal rule.** A node field `branch = "Menstrua"` the Research tab groups by, and an option to show a path node only when all but one of its requirements are held. A hundred nodes shown at once overwhelms a child and an adult alike.

**Weather**
- **Wx-M1, a layered sky overlay.** Weather writes `set_sky_modifier` for every player continuously, and a second writer would fight it. Ask: `add_overlay(uuid, source, { intensity, sky, sky_mix, saturation, grade } | nil)`, blended by Weather into what it writes. For night-sight, the Luna talisman and woven worlds' skies. Shared with science (the Core's darkening, the atmosphere processor).

### `docs/engine-asks.md`

- **E-M1, the instance in the generator.** `pos.domain = "template/key"` in a generator's position. Retires the offset trick (§6.11).
- **E-M2, a sky per instance** set at runtime (a woven world's own sky without a per-player overlay).

---

## 15. Code rules

Craft's and Progress's code rules apply verbatim (fan-out, lazy id resolution, storage scalars, integer maths, exports never raise, degrade when a sibling function answers nil). Additions:

1. **Nothing ticks by scanning the world.** Athanors, trees, familiars, wards, gates and effects each live on a list; `on_tick` walks at most `config.tick_budget` entries (default 64) and resumes next tick.
2. **Every randomness is the LCG** seeded from `game.world_seed` and a named stream, or `game.rng_stream`. There is almost none: the design replaced chance with counters (every third kill, every Nth cupel) so it can be tested.
3. **Historical names in the data, plain words in the first sentence.** `crocus_martis` is the id; "Iron rust, roasted golden" is what a child reads.
4. **One source of truth for numbers:** `config.lua`. `tools/check_tree.py` reads the same table the mod does (`tree.lua` returns it).
5. **Sources in `docs/lore.md`:** Ripley 1471; pseudo-Geber *Summa Perfectionis* (c. 1300); Theophrastus *On Stones*; Theophilus *De diversis artibus*; Paracelsus *De natura rerum* (1537) and *Liber de nymphis…* (1566); Rupescissa *De consideratione quintae essentiae*; Glauber *Furni novi philosophici* (1646–50); Culpeper *Complete Herbal* (1653); *Mutus Liber* (1677); Maier *Atalanta Fugiens* (1617); *Rosarium Philosophorum* (1550); Andreae *Chymische Hochzeit* (1616); Newton's translation of the Emerald Tablet; Cellini's *Vita*. Every node text that claims history cites one of them there.

---

## 16. Tests (`tests/native`)

- Load with every sibling; load with the interface and Weather absent (both optional — the mod loads and degrades, §2.1).
- **Tree:** every node registers; Progress validates the graph with none disabled; `check_tree.py` agrees; apprentice nodes buyable before the Fork, path nodes refused before it.
- **Door:** Emerald Tablet recipe appears only with `shared.keystone`; choosing sets the path, grants `hermetic_oath`, gives the primer, sets Quintessence.
- **Glyphs:** every variant registered; no collision with science's table (import its table from a fixture); a carved Sol from `gold_ore` reads `sol` in every orientation.
- **Athanor:** each degree's recipes run only with their vessel and heat; no registered recipe exceeds Craft's `max_ticks` (step chains); a 40-day work completes after 960,000 simulated ticks of burning; sigil bonus measured.
- **Reagents:** each recipe of §6.4 conserves what it says it does (`conserve = true` where material→material).
- **Effects:** an elixir's own effect expires on time; duration scales with the node; no `set_player_abilities` call while L-M3 is absent; no `set_sky_modifier` call while Wx-M1 is absent.
- **Familiars:** appear under their conditions with a stubbed clock; binding; caps; path budget never exceeded (count calls).
- **Stones:** projection yields with the world option on/off; multiplication doubles.
- **Cosmos:** weave → instance exists, player inside at the slot offset, generator output differs between two slots; sunder with a player inside → player out, domain gone, prima materia half back.
- **Repath:** familiars dormant, Quintessence 0, worlds sealed not destroyed; repath back → all restored.
- **Determinism:** full suite twice → identical storage dump.

---

## 17. Build order

1. Scaffold, manifest, `config.lua`, `hooks.lua`, `store.lua`, items, blocks. **Tests: load.**
2. **Apothecary's Bench** (§4) end to end: the child's half hour. Tag `0.1.0` — shippable before the Fork has a door.
3. Door, `tree.lua` (all nodes registered, most unlocking nothing yet), `check_tree.py`. **Tests: tree, door.**
4. Athanor, vessels, degrees; Gates I–III; menstrua through oil of vitriol; spagyric tinctures and simple elixirs; own effects. **Tier 3 playable.** `0.2.0`.
5. Glyphs, sigils, constructs framework; salamander (first entity). `0.3.0`.
6. Tier 4: the Egg, Gates IV–V, the menstrua, Tree of Diana, three elementals, talismans, seal, ouroboros. `0.4.0`.
7. Tier 5: the White Work, Quintessence, caduceus, Circle, orichalcum tools, emblems. `0.5.0`.
8. Tier 6: the Red Stone, alkahest, homunculus, basilisk, microcosm, gates. `0.6.0`.
9. Tier 7: projection, Rebis, the Loom and woven worlds, sundering, capstone. `1.0.0`.
10. Pacing: a real session's ledger replaces §13's model; tune `config.lua` only.

---

## 18. Numbers a designer will turn (`config.lua`)

Every node cost; every recipe's inputs, ticks, degree and vessel; philosophical-day length (24,000); long-work durations (3 / 7 / 40); sigil percentages; ward radii; familiar spawn checks, caps, budgets and trait values; Quintessence base, regen, costs; elixir durations; study yields and ticks; discovery values; herb→planet table; emblem→first table; projection yields; world-slot bit layout; woven-world caps; tick budget.

---

## 19. Out of scope

Combat magic, curses and damage spells (Life owns damage; alchemy is not a battle art). Ceremonial magic, demons, Solomonic seals, astrology as fortune-telling. Drinkable alcohol (aqua vitae is a solvent). Poisons as weapons (sugar of lead exists as a reagent and nothing else). Any recipe that *consumes* a Life creature alive. PvP griefing tools: the seal defends, it never attacks. Science's content, in any form.
