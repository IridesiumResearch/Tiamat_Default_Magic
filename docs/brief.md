<!-- SPDX-FileCopyrightText: Iridesium -->
<!-- SPDX-License-Identifier: GPL-3.0-only -->

# Tiamat Default Magic: starting brief

*Draft 0, 2026-09-29, written by the engine session when this repository was
scaffolded. For an AI coding assistant and the person supervising it.*

**What this file is.** The long plan is the designer's two-path design
(`schism_design.md`), which is not in this repository. This brief collects
what that design and the sibling mods have already fixed about the magic
tree, and the contracts this mod builds on. It does not design the tree.
Where it is silent the answer is the designer's: ask, and do not invent. When
the designer's build prompt for this mod arrives, it replaces this file.

Read first, in this order: `AGENTS.md` and `stubs/game.lua` (the engine's mod
API; the stubs win over anything written here), then the `docs/exports.md` of
Progress, Craft, Life, World and the interface, which are the only ways into
those mods.

---

## 1. One paragraph

`tiamat_default_magic` is one of the two doors at the Fork. A player climbs
the shared tree (tiers 0 to 2) in Craft and Progress, makes the Keystone, and
chooses: this mod, or `tiamat_default_science`. The choice is per player and
final unless the world was made with Progress's `repath` option. This mod
owns the magic door, the magic nodes of tiers 3 to 7, and everything those
nodes unlock. Progress owns the graph, the insight and the lock; this mod
registers into it and never keeps a second copy of who chose what.

## 2. Where it sits

| Mod | What this mod takes from it |
|---|---|
| `tiamat_default_progress` | `register_path`, `register_node`, `has`, `path`, `award`, `register_study`, `register_discovery`, `on_fork`, `on_repath` |
| `tiamat_default_craft` | the recipe registry (`register`, `register_station`, `register_fuel`, `register_group`), tool classes (`register_class`, `register_tool`, `classify`, `wear`), glyphs (`register_glyph`, `glyph_of`) |
| `tiamat_default_life` | `add_stat`, `stat`, `set_stat`, `spend_stat` for mana; `mode`, `is_ghost`; creatures and food through its `add_*` exports |
| `tiamat_default_world` | the ores and blocks it generates; `biome_under`, `depth_under` |
| `tiamat_default_ui` | `add_tab`, the theme and widget builders |
| `tiamat_default_science` | nothing. The two trees do not call each other; trade between players is inventories and needs no code |

Every one is an `optional_depends`. The mod must load and pass its checks on
a bare engine, and degrade one sibling at a time: no Progress means no door
and no gating; no Craft means no recipes.

## 3. What is already decided

Each line names where it is recorded. Anything not listed here is open.

**The shape of the climb** (Progress, `docs/brief.md` and `docs/exports.md`)

- Tiers 3 to 7. Default costs in insight: 100, 200, 400, 800, 1500. Four to
  six nodes a tier.
- A node id is `<path>.<name>`. Every node of tier 3 or more must require
  `shared.fork`, directly or through what it requires, or Progress disables
  it and logs why.
- Both trees' content is always loaded, because registries freeze at load.
  The lock is a question asked at run time: `progress.has(uuid, node)`
  answers `false`, always, for a node of the other path.
- The shared tree is affordable from exploring and making alone; the path
  trees are priced so that a player needs the research table. This mod's
  studies (`register_study`) and milestones (`award`) are how its own
  materials pay insight.

**The door** (Progress, `docs/brief.md` section 7.1, given there as the example)

- The door block is `tiamat_default_magic:attunement_stone`. The path's
  label is "The Attuned".
- Its recipe in the example: the Keystone (added by Progress), four silver
  ingots and 27 units of ironwood log.
- `on_choose` sets the player's mana: the example gives a maximum of 10.
- On `on_repath` away from magic, this mod wipes the player's mana.

**Mana** (Life, `docs/exports.md`)

- Mana is a Life stat registered with `add_stat`, so it is drawn in Life's
  status tray and saved with the player. This mod does not own a second HUD
  for it.

**The same rock, two readings** (Craft, `docs/brief.md` section 3.1)

| World block | Magic reading |
|---|---|
| `sulfur` | alchemy |
| `silver_ore` | wards, foci |
| `gold_ore` | foci |
| `crystal` | mana lenses |
| `orichalcum` | "glimmer": inert until attuned; mana crystals |

Copper, tin, iron, coal, salt, lead, chromium, diamond, `metal`, pyrite and
pitchblende have no magic reading recorded. Craft reserves every ore: none
is to be given a throwaway use.

**Stations and classes** (Craft, `docs/brief.md`)

- This mod adds an alembic, as a station in Craft's registry. It writes no
  job loop of its own.
- Its block class is `warded`, registered with `register_class`.
- A spell that uses a tool charges wear through `craft.wear`.

**Where both trees end** (the designer's plan, as recorded by the engine
session on 2026-09-27)

- Both trees end at making creatures and at making or remaking worlds, and
  they reach both through mechanisms shared with Science:
  - **Glyphs.** A carved 27-cell shape that means something. Magic reads
    them as runes; Science reads the same masks as punch cards. Craft keeps
    the registry.
  - **A creature trait vector.** Magic calls the traits essences; Science
    calls them genomes.
  - **Worlds as domains registered before the freeze.** Magic creates and
    destroys worlds; Science modifies them.
- The world already generates `hot_fiber_stone` and `cold_fiber_stone` in
  what its block list calls the hot and cold magical caves.

## 4. Rules that bind

From the engine's charter and `AGENTS.md`. These fail quietly when broken.

1. Everything is registered while `init.lua` runs. A `register_*` call after
   that is a hard error.
2. Identity is the player's UUID. Never key anything on a display name.
3. Arithmetic that decides anything is in whole numbers. No floats in
   rules, no `math.random`: randomness comes from the engine's seeded
   streams.
4. One callback per hook per mod: `hooks.lua` registers each engine hook
   once and fans out.
5. An export never raises. Bad input answers `nil` and a reason a person
   can read.
6. Quantities are units: 27 to a block. A recipe conserves units or says
   plainly that it does not.
7. The engine knows no content. If something cannot be built through the
   API, that is an engine ask (section 6), not a workaround.

## 5. The repository

```
mods/tiamat_default_magic/   the mod: what ships
stubs/game.lua, AGENTS.md    the engine's API, vendored (MIT); re-copy when the engine moves
docs/brief.md                this file
docs/exports.md              what this mod offers others; LICENSE.EXCEPTION names it
docs/assets.md               third-party assets and their licences
docs/engine-asks.md          what this mod needs from the engine
docs/sibling-asks.md         what it needs from the other default mods
scripts/check-spdx.sh        every source file carries both SPDX lines
scripts/check-dco.sh         every commit is signed off
```

`mods/tiamat_default_magic/init.lua` is the engine's template as it came: a
tour that registers a beacon, a hand, a sound, an action and a dialog. It is
there as a worked example and is the first thing to replace.

Check the mod without starting a world, from the engine repository, in a
directory that holds this mod and the engine's `core` (the manifest depends
on it). The engine's `game/` is one, once this mod is linked into it:

```sh
cargo run -p server -- --check-mods game
```

Commits are signed off (`git commit -s`, or enable the hook once with
`git config core.hooksPath .githooks`). The licence is GPL-3.0-only with this
mod's own Additional Permission; `CONTRIBUTING.md` has the terms.

## 6. Asks

An ask is written in this repository first, in `docs/engine-asks.md` or
`docs/sibling-asks.md`: what was wanted, why the mod cannot do it, and the
smallest change that would. The engine's copy of the open ones is
`docs/engine-asks/tiamat_default_magic.md` in the engine repository.

The engine session expects these from the two trees and has not built them:

- A way to drop a domain's saved chunks from Lua, for a world that is
  destroyed.
- Whatever creating a world at run time turns out to need beyond domains
  registered before the freeze.

## 7. First steps

Only as far as section 3 reaches.

1. Replace the tour: `init.lua` for load order only, `config.lua`,
   `hooks.lua`. Set `optional_depends` in `mod.toml`.
2. Register the path and the door with Progress. Register mana with Life and
   set it in `on_choose`; wipe it in `on_repath`.
3. Register the alembic and the `warded` class with Craft.
4. Stop. Tiers 3 to 7 need the designer's node list.

## 8. Open, for the designer

1. The node list: every node of tiers 3 to 7, its cost, what it requires
   and what it unlocks.
2. What a spell is: how it is cast, what it costs in mana, and what it may
   do to the world.
3. Mana's regeneration, and whether anything but the door raises its
   maximum.
4. The alembic's recipes, and what wards and foci do.
5. How attuning orichalcum works.
6. Which glyphs are runes, and what each means.
7. The creature trait vector: its traits, their ranges, and who owns the
   registry that both trees read.
8. Creating and destroying worlds: how many, what a player needs to do it,
   and what happens to players standing in a world that is destroyed.
