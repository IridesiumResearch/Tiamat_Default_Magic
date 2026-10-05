<!-- SPDX-FileCopyrightText: Iridesium -->
<!-- SPDX-License-Identifier: GPL-3.0-only -->

# Tiamat Default Magic

The Hermetic Art: one of the two doors at the Fork of the default game, and
everything behind it — alchemy as it was practised, from the athanor and its
glassware through Ripley's Twelve Gates to the Philosophers' Stone.
`docs/brief.md` is the design, checked against the engine and the siblings;
the mod itself is `mods/tiamat_default_magic/`. This repository sits beside
the engine (`Tiamat`) and its siblings, and the engine's `bundle.toml` pins
the commit a release carries.

## What is built

Step 2 of the brief's build order (§17): **the Apothecary's Bench**, five
shared nodes a child can reach long before the Fork. A picture book of
recipes (the Mute Book), a mortar that grinds herbs into simples, flame
powders that turn a fire blue, green, gold or sparking white, herb teas and
a poultice, a lamp of glow caps that never goes out, and a copper still that
makes rosewater.

Step 3: **the door and the tree.** The Emerald Tablet is the magic path's
door in Progress; choosing it gives the Oath and the Mute Book. All 97
nodes of tiers 3 to 7 are registered from `tree.lua`, which
`tools/check_tree.py` reads to prove the graph sound. Most nodes unlock
nothing yet: the athanor and the Art behind it come next.

Step 4: **the athanor and tier 3.** The philosophers' furnace is a Craft
station with two vessel slots; a bath in one sets the degree of fire,
bellows make the 4th. Glassblowing, Gates I–III (calcination, solution,
separation), the cupel's silver from lead, wine, vinegar, verdigris, aqua
vitae, green vitriol and its oil, blue vitriol, a planetary tincture from
every herb, seven elixirs, and night-sight. A philosophical day is ninety
seconds.

Step 5, in part: **the glyphs and the sigils.** Fifteen carved shapes are
Craft's glyphs in every orientation (`tools/glyphs.py` proves them), the
seven planetary sigils are one click in the shape crafter, and a sigil set
against a burning athanor speeds its own metal's work. The siblings'
answers are adopted where tier 3 can use them: the athanor works while
nobody is near, a flame powder flares over its own fire, the elixir of
swiftness is quick feet, and pyrite weathers to vitriol in the rain. And
the first familiar: an athanor burning a philosophical day draws a
salamander for the adept beside it, and a handful of sulfur binds it.

Step 6: **tier 4, the menstrua and the black.** The aludel, the pelican
and the Philosophers' Egg; quicksilver from cinnabar, the strong waters in
the order they were discovered, phosphorus, theriac and palingenesis;
Gates IV and V, the nigredo, and the Peacock's Tail. The Tree of Diana
grows silver a cell at a time. Talismans struck on a carved die and worn;
the Hermetic Seal wards ground; the Ouroboros hurries an athanor. And
three more elementals: the undine in still water at night, the gnome in
the deep caves, the sylph on peaks and in storms.

**What ships** is gated: `built_tier` in `config.lua` (7 today: the whole tree) is the last
tier whose Art is built, and nodes above it are not registered, so nobody
meets a node that does nothing.

Step 7: **tier 5, the White Work.** Gates VI to VIII; the White Stone,
seven philosophical days in the Egg, which makes silver if the world
allows transmutation; Citrinitas, aurum potabile, the lesser Elixir of
Life and the quintessence; the Quintessence bar, drawn only for magic
players; Maria's kerotakis, electrum and orichalcum tools; the Caduceus;
the Circle of Four, so two familiars walk; the undine's water-breathing,
the gnome's tunnels, the sylph's wings; the Assay and Atalanta Fugiens's
emblems.

Step 8: **tier 6, the Red Work.** Gates IX to XI and the Red Stone —
forty philosophical days in the Egg — which makes gold, twice over once
exalted; the alkahest and prima materia; the Panacea; the Phoenix, which
keeps a player's things through a death once in three sun-days; the
Chymical Wedding; the homunculus, which tends athanors from a chest; the
basilisk; essences of the beasts as familiars' traits; the Greater
Elementals; the microcosm, each adept's own floating island; the
correspondence gates; and the Rose Garden.

Step 9: **tier 7, the Great Arcanum.** Gate XII, the Stone projected on
the world, base ore turned to gold ore round it; the Rebis; the Four's
quintessences, drawn from elementals in the Circle; the Loom of the Four
and woven worlds — Earth, Water, Air, Fire and Quintessence, each its
own instance, under the sky and with the veins and sea its weaver chose,
with wild spirits of its element; the World-Gate, for friends; Solve et
Coagula, which ends a world; the Universal Medicine; Lapis Infinitus;
and Thrice-Greatest, the Emerald Tablet's whole text. The gate is at 7:
all 97 nodes ship.

## What is here

| File | What |
|---|---|
| `mods/tiamat_default_magic/` | The mod. `init.lua` decides load order; `config.lua` holds every number; the rest is one file a system. |
| `tools/make_textures.py` | Draws the placeholder textures. Standard library only; the same bytes on every machine. |
| `tools/check_tree.py` | Proves the tree sound from `tree.lua` and prints the pacing table (brief §13). |
| `tools/glyphs.py` | Proves the glyph table sound from `glyph_table.lua`: no clash in any orientation. |
| `tools/make_models.py` | Draws the placeholder familiars: boxes, as `.glb`, with a PNG beside each. |
| `tests/native/` | The mod run in the engine's real script VM, beside the REAL sibling mods, with a fake server around it. |
| `docs/brief.md` | The design, and §2.1: what was checked and what changed. |
| `docs/exports.md` | What other mods may call, and every id this mod registers. |
| `docs/sibling-asks.md`, `docs/engine-asks.md` | What this mod needs from others, with what stands in until then. |
| `stubs/game.lua`, `AGENTS.md` | The engine's API, vendored (MIT). Re-copy when the engine moves. |

## Check it

Without starting a server, from the engine repository, over a directory
holding the engine's `core` mods, every sibling and this mod:

```sh
cargo run -p server -- --check-mods <that directory>
```

The native check loads the real siblings from their repositories, so the
engine and each sibling must be checked out beside this one:

```sh
cargo run --manifest-path tests/native/Cargo.toml
```

## Your editor

Any editor with the Lua language server reads `.luarc.json` and gets
completion, signatures and types for every `game.*` call from `stubs/game.lua`.
The stubs are kept in step with the engine by its CI, so when you update the
engine, copy its `api/stubs/game.lua` over yours.

## Where to read next

- `AGENTS.md` — the rules that fail quietly when broken, and the shape of every
  kind of thing a mod can register.
- `stubs/game.lua` — every function, with the reason it behaves as it does.
- The engine repository's `game/` directory — reference mods, each the
  smallest thing that proves one mechanism.

## Licence

GPL-3.0-only, © Iridesium, with an Additional Permission under GPLv3 §7 in
`LICENSE.EXCEPTION` (version 1.0, 24 September 2026): a mod that interacts
with Tiamat Default Magic only through its exports, the engine's scripting API or
the network protocol is an independent work and may be licensed however
its author likes. Copying or adapting this mod's code or assets is not
covered by that permission and stays under the GPL. `docs/exports.md`
lists the exports; the engine's `MOD-LICENSING.md` has the plain-language
version and a matrix of what needs which permission. Third-party assets
are listed in `docs/assets.md` with their own licences. Contributions are
taken under the Developer Certificate of Origin with authors retaining
copyright; see `CONTRIBUTING.md`.
