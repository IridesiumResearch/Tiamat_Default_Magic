<!-- SPDX-FileCopyrightText: Iridesium -->
<!-- SPDX-License-Identifier: GPL-3.0-only -->

# Exports

What Tiamat Default Magic (`tiamat_default_magic`) deliberately offers other mods. This is the document
`LICENSE.EXCEPTION` names as "the Exports": a mod that reaches this one only
through what is listed here, the engine's scripting API or the network
protocol is an independent work. A mod that copies or adapts this mod's code
or assets is not, and stays under the GPL.

An interface this mod offers in fact is an export whether or not it is listed
here, so this file changes in the same commit as any change to one.

## The exported table

`game.exports("tiamat_default_magic")` answers it to a mod that lists this
one in `depends` or `optional_depends`. Source:
`mods/tiamat_default_magic/exports.lua`.

| Field | Shape | What it does |
|---|---|---|
| `version` | integer, `1` | Bumped only when a change would break a reader. |
| `glyphs` | `{ [id] = { mask, variants } }` | Every glyph of the Art by its short id (`"sol"`): the canonical 27-bit mask and every orientation Craft knows it by. Read-only data. |
| `is_warded(pos, uuid)` | `{ x, y, z }` in whole blocks (the overworld); a UUID | Whether a Hermetic Seal forbids that player to dig or build there. `nil` and why for a malformed question. |
| `familiars(uuid)` | a player's UUID in hex | Their familiars whose bodies are in the world, as `{ { kind, entity } }`; `nil` and why for a malformed UUID. |

The brief's other fields (§12: the Quintessence bar, herbs, wards, the
Opus's subscribers) are added as the parts of the Art they read are built.

## Identifiers it registers

All are namespaced `tiamat_default_magic:` by the engine.

- **Blocks:** `emerald_tablet` (the door; light 2, 9, 4), `hermetic_lamp`
  (light 6, 12, 8; transparent; never goes out), `athanor` and `athanor_lit`
  (light 12, 7, 2; Life's contact fire and heat source), `arbor_dianae`
  (the Tree of Diana: cutout, light 3, 3, 4; dug, it pays a silver ingot's
  units by the share of the block it fills).
- **Models and entities:** the familiars `salamander`, `undine`, `gnome`
  and `sylph`, each drawn from `models/<kind>.glb` with the picture beside
  it, spawned by this mod and named for their kind.
- **Items:** `mutus_liber`, `mortar`, `copper_still`; the simples
  `simple_chamomile`, `simple_mint`, `simple_bramble`, `simple_mantle`; the
  flame powders `flame_powder_blue`, `_green`, `_yellow`, `_white`; and,
  food through Life's `add_food`, `chamomile_tea`, `mint_tea`,
  `bramble_tea`, `poultice`, `rosewater`, `mint_water`; tier 3's vessels
  (`blowpipe`, `phial`, `alembic`, `retort`, `bain_marie`, `ash_bath`,
  `sand_bath`, `cupel`), calxes and salts (`litharge`, `minium`, `putty`,
  `aes_ustum`, `crocus_martis`, `bone_ash`, `silver_grain`, `caput_mortuum`,
  `salt_of_tartar`, `sal_saturni`, `salt_of_venus`), liquids (`vinum`,
  `vinegar`, `distilled_vinegar`, `aqua_vitae`, `spirit_of_wine`,
  `oil_of_vitriol`), `verdigris`, `verdigris_salve` (food: cures burning),
  `green_vitriol`, `blue_vitriol`, the three principles
  (`principle_mercury`, `_sulfur`, `_salt`), seven tinctures
  (`tincture_<planet>`: sol, luna, venus, mars, mercury, jupiter, saturn)
  and seven elixirs, all food (`elixir_vigour`, `elixir_night_sight`,
  `elixir_hearts_ease`, `elixir_fortitude`, `elixir_swiftness`,
  `draught_warming`, `draught_cooling`); `salamander_ember`, in
  `#magic_blast`; and tier 4's `aludel`, `pelican`, `philosophers_egg`,
  `flowers_of_sulfur`, `quicksilver`, `vermilion`, `amalgam_gold`,
  `amalgam_silver`, `amalgam_tin`, `saltpeter`, `aqua_fortis`,
  `spirit_of_salt`, `sal_mirabilis`, `sal_ammoniac`, `aqua_regia`,
  `green_lion`, `phosphorus`, `phosphorus_spill` (used at a laid campfire
  or a fuelled kiln, bloomery or athanor, it lights it through Craft's
  `ignite`), `conjoined_matter`, `caput_corvi`, `peacock_matter`, and `arbor_seed`
  (planted by using it on the ground; watered with aqua fortis); and the
  seven talismans `talisman_<planet>`, worn in Life's worn slots.
- **Into Progress:** the path `magic`, "The Hermetic Art", whose door is
  `emerald_tablet` (Progress registers its recipe as
  `tiamat_default_progress:door_magic`: the Keystone, 27 units of crystal,
  four copper ingots, two silver); the 97 path nodes of `tree.lua`,
  `magic.hermetic_oath` to `magic.hermes_trismegistus`, carrying the effect
  keys `craft.fuel_percent` and `magic.sigil_percent`,
  `elixir_duration_percent`, `quintessence_max`,
  `quintessence_regen_percent`, `long_work_percent`, `study_bonus_percent`,
  `projection_percent`, `multiplication_days`, `talisman_grade`,
  `talisman_slots` and `familiars`; the shared nodes `shared.mutus_liber`,
  `shared.apothecary`, `shared.herb_lore` (tier 1) and `shared.foxfire`,
  `shared.stillroom` (tier 2); the discoveries `tiamat_default_magic.lamp`,
  `tiamat_default_magic.distillation` and the family
  `tiamat_default_magic.flame:*` (`blue`, `green`, `yellow`, `white`), all
  in the group `toybox`; the Twelve Gates `tiamat_default_magic.gate_1` …
  `gate_12` (25 insight times the number, group `gates`),
  `tiamat_default_magic.vitriol`, and the family
  `tiamat_default_magic.herb:*` (a species' first tincture, group
  `herbs`); `tiamat_default_magic.familiar_<kind>` for each of the four (group
  `familiars`); `tiamat_default_magic.peacock` and `tiamat_default_magic.tree_of_diana`
  (toybox); the studies
  `study_calx`, `study_tincture`, `study_vitriol`, `study_quicksilver`,
  `study_aqua_regia`, `study_caput_corvi`, `study_peacock`.
- **Into Craft:** the recipes `mutus_liber`, `mortar`, `grind_chamomile`,
  `grind_mint`, `grind_bramble`, `grind_mantle`, `flame_powder_blue`,
  `_green`, `_yellow`, `_white`, `poultice`, `hermetic_lamp` (by hand);
  `copper_still` (workbench); `chamomile_tea`, `mint_tea`, `bramble_tea`
  and `burn_blue`, `burn_green`, `burn_yellow`, `burn_white` (campfire; the
  last four make nothing, and are a powder flaring); `rosewater`,
  `mint_water` (kiln, heat 1, the still in the tool slot); the station
  `tiamat_default_magic:athanor` (fuel 1, inputs 2–4, vessels 5–6, outputs
  7–9; it burns; `#magic_blast` in a vessel slot makes heat 4) and tier 3's
  recipes there, at the workbench, the kiln and by hand (`config.lua`,
  `lab_recipes`, and a `tincture_<plant>` for each herb); the groups
  `#magic_blast` (Craft's bellows), `#magic_herb`, `#magic_tincture`,
  `#magic_calx`, and this mod's oil, quicksilver and saltpeter in
  science's `#oil_of_vitriol`, `#quicksilver` and `#saltpeter`; tier 4's
  recipes (`config.lua`, `tier4_recipes`, and a `palingenesis_<plant>`
  for each of the world's plants); the talismans at the anvil
  (`talisman_<planet>`: the planet's metal, a hammer, and a sigil carved
  from any of `#magic_die` as the die, four blows); and the
  glyphs of `glyph_table.lua` in every distinct orientation (`sol`,
  `luna`, `venus`, `mars`, `jupiter`, `saturn`, `mercury`, `fire`, `water`,
  `air`, `earth`, `quintessence`, `ouroboros`, `seal`, `emerald`, each
  `tiamat_default_magic:<name>`). The athanor is `long`. Each is
  qualified `tiamat_default_magic:<id>`.
- **Into the interface:** the shape crafter's presets
  `tiamat_default_magic:preset_<planet>`, the seven sigils, shown to a
  player who holds `magic.seven_metals`.
- **Into Life:** the ability sources `tiamat_default_magic:swiftness`
  (`speed_mul` 1.3, while the elixir lasts) and
  `tiamat_default_magic:talisman_mercury` (a tenth quicker a grade, while
  it is worn).
- **Random tick:** the world's `pyrite`, which weathers in the rain.
- **Dialog:** `liber`, the Mute Book.

## Commands it accepts

Chat words, said by a player and swallowed. For anyone: `magic` (how far
along the Apothecary's Bench the speaker is), `magic book` (opens the Mute
Book for a player who carries one), and `magic seal allow <name>` and
`magic seal deny <name>` (who, of the players here, may build within the
speaker's seals), and `magic familiar [kind]` (which familiars walk and
rest, or call one to walk). A sentence that only begins with the word is chat.

## Data it stores or sends

`game.storage`, private to this mod: `clock` (ticks the world has run, as
this mod counts them) and `fx:<uuid>:<effect>` (the tick a player's own
effect ends: `night_sight`, `swiftness`), `carved:x,y,z` (who set a
carving of the Art there; it replaced `sigil:x,y,z`),
`seal:x,y,z` (a Hermetic Seal: its setter and radius),
`sealallow:<setter>:<uuid>` (who a setter lets build in their wards),
`tree:x,y,z` (a Tree of Diana: its cells and who planted
it) with `treefed:x,y,z` (the tick its watering ends), `weathered:x,y,z` (pyrite the rain has weathered),
`familiar:<uuid>:<kind>` (`true` while it walks, `"resting"`, or
`"dormant"` after a repath away), `undine_water:<uuid>` (blocks of water
an undine carries), and per athanor `burned:<container>` (ticks it has burned
without going out) and `called:<container>` (a salamander came). Who
chose the path, and which nodes they
hold, is Progress's; an athanor's fire and work are Craft's.

## What it reads from other mods

Not exports, listed so the direction is clear: Progress's `register_path`,
`register_node`, `unlock`, `register_discovery`, `discover` and `has`; Craft's `register`,
`on_crafted` and `on_first`, and its blocks `kiln_lit`, `bloomery_lit` and
`campfire_lit`, `register_station`, `register_group` and its stations'
slots; Life's `add_food`, `on_eat`, `add_contact_fire`,
`add_heat_source`, `set_ability`, and its `campfire` block; Craft's
`register_glyph`, `glyph_of`, `add_progress` and `on_crafted`'s
container; the interface's `add_preset`; Weather's `weather_at`; the interface's
`widgets`, for the book's look; Weather's `fire` block. It names the
world's `roman_chamomile`, `wild_mint`, `bramble`, `ladys_mantle`,
`glow_cap`, `sulfur`, `salt` and `rose` in its recipes.
