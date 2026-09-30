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

That is all, for now. The brief's fields (§12: the Quintessence bar, herbs,
glyphs, familiars, wards, the Opus's subscribers) are added as the parts of
the Art they read are built.

## Identifiers it registers

All are namespaced `tiamat_default_magic:` by the engine.

- **Blocks:** `emerald_tablet` (the door; light 2, 9, 4) and `hermetic_lamp`
  (light 6, 12, 8; transparent; never goes out).
- **Items:** `mutus_liber`, `mortar`, `copper_still`; the simples
  `simple_chamomile`, `simple_mint`, `simple_bramble`, `simple_mantle`; the
  flame powders `flame_powder_blue`, `_green`, `_yellow`, `_white`; and,
  food through Life's `add_food`, `chamomile_tea`, `mint_tea`,
  `bramble_tea`, `poultice`, `rosewater`, `mint_water`.
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
  in the group `toybox`.
- **Into Craft:** the recipes `mutus_liber`, `mortar`, `grind_chamomile`,
  `grind_mint`, `grind_bramble`, `grind_mantle`, `flame_powder_blue`,
  `_green`, `_yellow`, `_white`, `poultice`, `hermetic_lamp` (by hand);
  `copper_still` (workbench); `chamomile_tea`, `mint_tea`, `bramble_tea`
  and `burn_blue`, `burn_green`, `burn_yellow`, `burn_white` (campfire; the
  last four make nothing, and are a powder flaring); `rosewater`,
  `mint_water` (kiln, heat 1, the still in the tool slot). Each is
  qualified `tiamat_default_magic:<id>`.
- **Dialog:** `liber`, the Mute Book.

## Commands it accepts

Chat words, said by a player and swallowed. For anyone: `magic` (how far
along the Apothecary's Bench the speaker is) and `magic book` (opens the
Mute Book for a player who carries one). A sentence that only begins with
the word is chat.

## Data it stores or sends

Nothing yet: the Bench and the door keep no state of their own. Who chose
the path, and which nodes they hold, is Progress's.

## What it reads from other mods

Not exports, listed so the direction is clear: Progress's `register_path`,
`register_node`, `unlock`, `register_discovery`, `discover` and `has`; Craft's `register`,
`on_crafted` and `on_first`, and its blocks `kiln_lit`, `bloomery_lit` and
`campfire_lit`; Life's `add_food` and its `campfire` block; the interface's
`widgets`, for the book's look; Weather's `fire` block. It names the
world's `roman_chamomile`, `wild_mint`, `bramble`, `ladys_mantle`,
`glow_cap`, `sulfur`, `salt` and `rose` in its recipes.
