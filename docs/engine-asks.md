<!-- SPDX-FileCopyrightText: Iridesium -->
<!-- SPDX-License-Identifier: GPL-3.0-only -->

# Engine asks from Tiamat Default Magic

What this mod has needed from the engine, found by planning and building
it. Each entry says what was wanted, why the mod cannot do it, and the
smallest engine change that would. Newest first. Landed items stay here,
marked, as the record; the open ones are copied, without the history, to the
engine's `docs/engine-asks/tiamat_default_magic.md`, so the engine side
finds every mod's open asks in one place.

Nothing open as of 2026-09-30: E-M1 and E-M2 landed and E-M3 was answered.

## Milestone 0.5.0's asks of every mod — adopted 2026-10-15

Not an ask; the engine's three for every mod (its `docs/milestone-0.5.0.md`,
2026-10-13). **A4:** `stubs/game.lua` and `AGENTS.md` re-vendored from the
engine's `api/` at 5049d115 (API 1.0; only additions since the last copy).
**A3 / E8:** `.github/workflows/conform.yml` is the engine's
`docs/mod-conformance.md` workflow, run on every push and nightly against
the engine's `main`: `scripts/conform.sh mods/tiamat_default_magic`. Locally,
`--check-mods game` from a server rebuilt past 6423b50d (the link files) is
OK, all 18 mods loaded. The nightly soak needs nothing from this repo.

## Model and whole blocks — landed on main 2026-10-05

Not an ask; a dependency. The athanor (cold and lit) and the Emerald Tablet
are drawn as models and so are `whole`, and the Hermetic Lamp is `whole`
(brief §8), through `register_block`'s `whole`, `model` and `shape`. Those
came in on the engine's `feat/model-blocks` (8870b780), merged to main;
`register_block` refuses a field it does not know, so this mod needs an
engine at or after that commit. `--check-mods` is clean, and all 34 native
checks pass (`the blocks` reads the engine's rules for each of the five).

## E-M3, actions that fire — answered 2026-09-30

*Wanted:* `register_on_action` delivering presses. *Why:* the stubs say
`register_action` is "stored now, inert until Task 13", and the brief binds
the *Mutus Liber* to J and the familiars to K. *Stands in:* the book opens
when it is used (`register_on_use{ anywhere = true }`) and on `magic book`
in chat. *Answered (engine 3acedd1e):* actions fire, and nothing was
needed of the engine; the stubs' note was stale. The book is on J
(`tiamat_default_magic:mutus_liber`) and the familiars on K
(`tiamat_default_magic:familiar`, the next bound one walks), with the
use and chat words kept as second ways in.

## E-M2, a sky per instance — landed 2026-09-30

*Wanted:* a domain instance's sky set at run time, so a woven world has its
own sky without a per-player overlay. *Why:* `register_sky{ domain }` is
per template and registration-only. *Landed (engine 8275173):*
`set_domain_sky(id, spec)`, and `sky` in `create_domain`'s options; everyone
inside sees it, and anyone arriving later. A woven world's sky is set on
the instance when it is woven (brief §6.11).

## E-M1, the instance in the generator — landed 2026-09-30

*Wanted:* `pos.domain = "template/key"` in a generator's position. *Why:*
a generator is told `{ x, y, z, seed }` only, so two instances of one
template generate the same world. *Stands in:* the offset trick (brief
§6.11): each woven world lives in its own far slice of the template's
coordinates. Science asks the same (E-S2).

*Landed (engine 61b4c3e):* a generator's `pos` carries `domain` in every
VM that generates. The engine also answered the question asked here: valid
coordinates are −60,000 to 59,999 a side, so the offset trick's slots
were all past the world's edge. It is dropped; a woven world's parameters
are written into its instance key instead (brief §6.11).
