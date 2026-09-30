<!-- SPDX-FileCopyrightText: Iridesium -->
<!-- SPDX-License-Identifier: GPL-3.0-only -->

# Asks of the sibling mods

What this mod needs from the OTHER default mods (Progress, Craft, Life, the
world and the interface), as `docs/engine-asks.md` holds what it needs from
the engine. Each says what was wanted, what stands in for it today, and the
smallest change that would answer it. Newest first within each mod. The
design reasons are in `docs/brief.md` §14; where science wants the same
thing, its ask is named beside ours so the two are answered once.

Every ask below is **open** as of 2026-09-29.

## Tiamat Default Craft

**C-M10, an athanor's slow fire.** *Wanted:* a station field
`burn_percent` (per cent of each fuel's ticks; default 100, so nothing else
changes), set to about 5 on the athanor. *Why:* the athanor's point, in
every text, is a low heat held for weeks on little fuel; at Craft's rates
(coal 1,800 ticks a block) a forty-day Red Stone burns ~530 blocks of coal.
`craft.fuel_percent` is read for the kiln only and is a player's, not a
station's. *Stands in:* the Stones' durations are cut in `config.lua`.

**C-M9, a fire that lets a held thing through.** *Wanted, either of:*
(a) the listed use callback at a campfire answers `nil` when the held stack
is not fuel, not cookable and not a striker, instead of opening the box; or
(b) `on_crafted` passes the container a recipe was made in as a fourth
argument. *Why:* a flame powder is thrown on a burning fire, and at a
campfire Craft's listed callback hears the use first (listed callbacks keep
load order) and opens the box. *Stands in:* each powder is a campfire recipe
that makes nothing; put on the fire like food, it flares in a second, where
the player is looking. At a lit kiln or bloomery, which Craft does not list,
it is thrown.

**C-M8, `craft.fuel_percent` on every heat station a player lit**, not
only the kiln (`furnace.lua` reads it for `station.id == "kiln"`). The
Salamander node carries it. *Stands in:* the bonus is a kiln bonus, and
says so.

**C-M7, idempotent glyphs.** Registering a mask again with the SAME id
answers `true`. Today it answers `nil, "that mask is already <id>"` (it
never raises), so this is a convenience. Science's C-S5.

**C-M6, `add_progress(container, ticks)`**, for a sigil's speed-up at an
athanor. *Stands in:* the sigil refunds one input in N through
`on_crafted`.

**C-M5, long recipes, and time while unloaded.** *Wanted:* a station
opting in with `long = true` accepts recipes up to 960,000 ticks (40
philosophical days), and a lit long station advances by the ticks that
passed while its chunk was unloaded, when it is next loaded (its fuel
permitting). *Why:* `max_ticks` is 72,000, and a furnace in an unloaded
chunk is paused (`furnace.lua`), so the Red Stone is 13 h 20 min with a
player standing by it. *Stands in:* chains of steps of at most three days,
each step's output moved back into the inputs by hand (or by the
homunculus).

**C-M1, a glyph as an ingredient or a tool.**
`inputs = { { glyph = "<id>", material = "<id or #group>", count = n } }`
consumes carved stacks whose `glyph_of` is that id (any registered
variant); the same form in `tools` finds one without consuming it. A carved
stack is still never an ingredient by default — naming the glyph is the
opt-in, because the carving IS the ingredient. Science's C-S3; asked once,
together. *Stands in:* relic recipes register their plain inputs and this
mod takes the carved parts itself around `perform` (brief §7.5).

## Tiamat Default Life

**L-M7, the phoenix.** `on_death(fn(uuid, pos, drops))` with the dropped
stacks' entities, or `keep_inventory(uuid)` once. *Stands in:* a feather
that points to where you died.

**L-M6, air.** `set_air(uuid, n)` or a `water_breathing` effect, for the
undine's gift.

**L-M5, steer a Life creature.** `follow(entity, uuid, ticks)`, for the
Venus talisman.

**L-M4, reading the worn view.** Confirm that another mod may read
`game.inventory(uuid, "tiamat_default_life:worn")` and rely on its four
slots. The engine allows it today (views are every player's and the name
is not checked for ownership); this asks that it be a promise.

**L-M3, composed abilities.** `set_ability(uuid, source, { speed_mul, fly })`,
combined by Life with its own cold and hunger. `set_player_abilities` is one
table a player, replaced whole, last writer wins. *Stands in:* this mod
never calls it; swiftness and sylph flight are `push_player` nudges, tried
for rubber-banding before they ship.

**L-M2, effects and health on others.** `add_effect(target, id, ticks)`,
`cure(target, id)`, `heal(target, n)`, `hurt(target, n, kind, source)`, for
players and Life's creatures. Unlocks sprayed elixirs, the panacea, the
undine's healing, the Sol, Mars and Jupiter talismans and the basilisk's
stare on Life's creatures. *Stands in:* each says so and does less.

**L-M1, a per-player stat ceiling.** `set_stat_max(uuid, id, max)`; a bar
at max 0 is not drawn. *Why:* Quintessence is a Life stat, and today every
stat has one max and is drawn for every player — children and science
players included. *Stands in:* the stat starts at 0 and this mod clamps it.
Wanted before Quintessence ships (tier 3), not before the Apothecary's
Bench, which has no bar.

## Tiamat Default World

**W-M3, pyrite's random tick.** One handler a material; World does not
tick pyrite. Leave it to this mod (pyrite in the rain weathers to green
vitriol), or tick it in World and call this mod's export. *Stands in:* this
mod's own list of pyrite blocks a player placed.

**W-M2 (optional), the magical shells.** If World builds `hot_magical` /
`cold_magical`, this mod reads `hot_fiber_stone` as salamander's wool and
`caul` as the world-egg's membrane. Nothing waits on it.

**W-M1, cinnabar.** A `cinnabar` block (tags `ore`, `mineral`; hardness
1.8; drops itself) as crust round Volcanic Foothills fumaroles and Geyser
Basin throats, and seams in Mineral Vein Tunnels. Science needs it too.
*Stands in:* quicksilver from sulfur crust at a ninth of the yield, in a
recipe named as a stand-in.

## Tiamat Default UI

~~**U-M2, say that `widgets` answer views.**~~ A widget built by the exported
builders reaches another mod as a read-only view, and `game.show_dialog`
reads a view's colour as no numbers at all ("`text_colour` wants three or
four numbers, got 0"). A tab's tree is copied by the interface, so tabs never
meet it; a mod showing its own dialog in the interface's look does. *Wanted:*
one line in `docs/exports.md`. *Stands in:* this mod deep-copies each widget
(`util.plain`). Found building the Mute Book, 2026-09-29.
*Answered (interface ae8954a):* `docs/exports.md`, under "Callbacks it
accepts", now says it: everything the exports answer is a view, and a tree
for `game.show_dialog` must be plain tables. Keep `util.plain`.

~~**U-M1, shape-crafter presets from siblings.**~~
`add_preset{ id, label, mask, visible = fn(player) -> bool }`: buttons
beside Slab, Stairs and Pillar, shown when `visible` answers true. The
biggest single thing for children: "carve the Sun" is one click, not eight.
*Answered (interface ae8954a, 2026-09-29):* `add_preset{ id, label, mask,
visible? }` on the interface's exports, exactly as asked. Four to a row after
Block, Slab, Stairs and Pillar; `label` 1–8 bytes (a button is a quarter of
the column at 800x600); `mask` in `x + 3*y + 9*z`, neither empty nor full;
`visible(player)` asked each time the crafter is drawn, so keep it a lookup;
eight added presets show at most, in the order added. The crafter is now a
block's tab (the shape crafter block), so presets show where it is used.

## Tiamat Default Progress

**P-M1, a branch label and a reveal rule.** A node field
`branch = "Menstrua"` the Research tab groups by, and an option to show a
path node only when all but one of its requirements are held. This path
registers 97 nodes; today a path's nodes are one flat list under its label.

## Tiamat Weather

**Wx-M1, a layered sky overlay.**
`add_overlay(uuid, source, { intensity, sky, sky_mix, saturation } | nil)`,
blended by Weather into what it writes. `set_sky_modifier` is one modifier
a player and the last writer wins; Weather writes it whenever its value
changes. For night-sight, the Luna talisman and woven worlds' skies. Shared
with science (Wx-S2). *Stands in:* this mod never calls `set_sky_modifier`.
