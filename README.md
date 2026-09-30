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
seconds. The sigils and the salamander come with the glyphs, next.

## What is here

| File | What |
|---|---|
| `mods/tiamat_default_magic/` | The mod. `init.lua` decides load order; `config.lua` holds every number; the rest is one file a system. |
| `tools/make_textures.py` | Draws the placeholder textures. Standard library only; the same bytes on every machine. |
| `tools/check_tree.py` | Proves the tree sound from `tree.lua` and prints the pacing table (brief §13). |
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
