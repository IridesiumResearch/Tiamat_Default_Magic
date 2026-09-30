<!-- SPDX-FileCopyrightText: Iridesium -->
<!-- SPDX-License-Identifier: GPL-3.0-only -->

# Asks of the sibling mods

What this mod needs from the OTHER default mods (Progress, Craft, Life, the
world, the interface and the weather), as `docs/engine-asks.md` holds what
it needs from the engine. Each says what was wanted, what stood in for it,
and what came of it. The design reasons are in `docs/brief.md` §14.

## Where they stand, 2026-09-30

| Ask | Of | State | In this mod |
|---|---|---|---|
| C-M1 glyph as ingredient or tool | Craft | answered (0.5.0) | for the talismans and relics (tiers 4–7) |
| C-M5 time while unloaded | Craft | answered (0.5.0), as narrowed | **adopted**: the athanor is `long` |
| C-M6 `add_progress` | Craft | answered (0.5.0) | **adopted**: sigils |
| C-M7 idempotent glyphs | Craft | answered (0.5.0) | nothing to change |
| C-M8 `fuel_percent` at every heat station | Craft | answered (0.5.0) | the Salamander's node now helps its athanor too |
| C-M9 which fire burnt a powder | Craft | answered (0.5.0), option (b) | **adopted**: the flare is over its own campfire |
| C-M10 an athanor's slow fire | Craft | withdrawn | a philosophical day is 1,800 ticks instead |
| L-M1 per-player stat ceiling | Life | answered (uncommitted in Life, 2026-09-30) | Quintessence, with tier 5 |
| L-M2 effects and health on others | Life | answered (uncommitted) | sprayed elixirs, the panacea, talismans (tiers 4–7) |
| L-M3 composed abilities | Life | answered (uncommitted) | **adopted**: the elixir of swiftness |
| L-M4 the worn view | Life | answered (uncommitted) | talismans (tier 4) |
| L-M5 steer a creature | Life | answered (uncommitted) | the Venus talisman (tier 4) |
| L-M6 air | Life | answered (uncommitted) | the undine's gift (tier 5) |
| L-M7 the phoenix | Life | answered (uncommitted) | the phoenix (tier 6) |
| W-M1 cinnabar | World | answered (1d50d64) | quicksilver (tier 4) |
| W-M2 the magical shells | World | not built; optional | nothing waits on it |
| W-M3 pyrite's random tick | World | answered: it is ours | **adopted**: pyrite weathers in the rain |
| U-M1 shape-crafter presets | Interface | answered (ae8954a) | **adopted**: the seven sigils |
| U-M2 widgets are views | Interface | answered (ae8954a) | the book copies them |
| P-M1 a branch label and a reveal rule | Progress | **open** | the Research tab shows the path flat |
| Wx-M1 a layered sky overlay | Weather | **open** | night-sight glows instead of brightening |

Life's answers are in its working tree, not yet committed, as of this
date; this mod calls each only when Life's exports have it, so a Life
without them loses that effect and nothing else.

## The asks, as they were made

### Tiamat Default Craft

**C-M10, an athanor's slow fire** — *withdrawn 2026-09-30.* A station field
`burn_percent`. With a philosophical day of 1,800 ticks (brief §6.1) a Red
Stone burns forty coal at Craft's own rates, which is a fair price.

**C-M9, a fire that lets a held thing through.** Either the campfire's
listed use callback answers `nil` for what it cannot use, or `on_crafted`
passes the container. *Answered:* the container, as a fourth argument.

**C-M8, `craft.fuel_percent` on every heat station a player lit**, not
only the kiln. *Answered.*

**C-M7, idempotent glyphs.** The same mask with the same id again answers
`true`. *Answered.*

**C-M6, `add_progress(container, ticks)`**, for a sigil's speed-up at an
athanor. *Answered*, at a heat station or a running one.

**C-M5, long recipes, and time while unloaded.** Narrowed on 2026-09-30 to
the second half: a lit station working, when next loaded, the ticks that
passed while its chunk was not. *Answered:* `long = true`.

**C-M1, a glyph as an ingredient or a tool.**
`{ glyph = "<id>", material = "<id or #group>", count = n }` in `inputs` or
`tools`. Shared with science's C-S3. *Answered.*

### Tiamat Default Life

**L-M1, a per-player stat ceiling.** `set_stat_max(uuid, id, max)`; a bar
at max 0 is not drawn. *Answered.*

**L-M2, effects and health on others.** `add_effect`, `cure`, `heal`,
`hurt`, for players and Life's creatures. *Answered.*

**L-M3, composed abilities.** `set_ability(uuid, source, { speed_mul, fly })`,
combined with Life's own cold and hunger. *Answered.*

**L-M4, reading the worn view** as a promise. *Answered.*

**L-M5, steer a creature.** `follow(entity, uuid, ticks)`. *Answered.*

**L-M6, air.** `set_air(uuid, n)` and a `water_breathing` effect. *Answered.*

**L-M7, the phoenix.** `on_death(fn(uuid, pos, drops))` and
`keep_inventory(uuid)`. *Answered.*

### Tiamat Default World

**W-M3, pyrite's random tick.** One handler a material. *Answered without
a change:* the world does not tick pyrite, so this mod takes the handler.

**W-M2 (optional), the magical shells.** If World builds `hot_magical` /
`cold_magical`, this mod reads `hot_fiber_stone` as salamander's wool and
`caul` as the world-egg's membrane. *Not built;* nothing waits on it.

**W-M1, cinnabar**, round Volcanic Foothills fumaroles and Geyser Basin
throats, and in Mineral Vein Tunnels seams. *Answered.*

### Tiamat Default UI

**U-M2, say that `widgets` answer views.** A widget from the exported
builders reaches another mod as a read-only view, which `game.show_dialog`
cannot read. *Answered:* its exports say so. Keep `util.plain`.

**U-M1, shape-crafter presets from siblings.**
`add_preset{ id, label, mask, visible? }`. *Answered:* four to a row after
Block, Slab, Stairs and Pillar; at most eight added presets show at once.

### Tiamat Default Progress

**P-M1, a branch label and a reveal rule** — *open.* A node field
`branch = "Menstrua"` the Research tab groups by, and an option to show a
path node only when all but one of its requirements are held. This path has
97 nodes; the Research tab shows them flat. `tree.lua` already carries each
node's `branch`, ready.

### Tiamat Weather

**Wx-M1, a layered sky overlay** — *open.*
`add_overlay(uuid, source, { intensity, sky, sky_mix, saturation } | nil)`,
blended by Weather into what it writes, since `set_sky_modifier` is one
modifier a player and the last writer wins. For night-sight, the Luna
talisman and woven worlds' skies. Shared with science (Wx-S2). Until then
this mod never calls `set_sky_modifier`.
