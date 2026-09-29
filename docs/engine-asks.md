<!-- SPDX-FileCopyrightText: Iridesium -->
<!-- SPDX-License-Identifier: GPL-3.0-only -->

# Engine asks from Tiamat Default Magic

What this mod has needed from the engine, found by planning and building
it. Each entry says what was wanted, why the mod cannot do it, and the
smallest engine change that would. Newest first. Landed items stay here,
marked, as the record; the open ones are copied, without the history, to the
engine's `docs/engine-asks/tiamat_default_magic.md`, so the engine side
finds every mod's open asks in one place.

## E-M3, actions that fire — open, 2026-09-29

*Wanted:* `register_on_action` delivering presses. *Why:* the stubs say
`register_action` is "stored now, inert until Task 13", and the brief binds
the *Mutus Liber* to J and the familiars to K. *Stands in:* the book opens
when it is used (`register_on_use{ anywhere = true }`) and on `magic book`
in chat. Nothing to build here; this records that the mod waits on Task 13.

## E-M2, a sky per instance — open, 2026-09-28

*Wanted:* a domain instance's sky set at run time, so a woven world has its
own sky without a per-player overlay. *Why:* `register_sky{ domain }` is
per template and registration-only. *Stands in:* Weather's overlay
(Wx-M1), per player, on arrival.

## E-M1, the instance in the generator — open, 2026-09-28

*Wanted:* `pos.domain = "template/key"` in a generator's position. *Why:*
a generator is told `{ x, y, z, seed }` only, so two instances of one
template generate the same world. *Stands in:* the offset trick (brief
§6.11): each woven world lives in its own far slice of the template's
coordinates. Science asks the same (E-S2).

Before building on the offset trick, confirm how far out the client stays
exact: a slot at `(slot × 2 + 1) × 2^20` is a million blocks out, and the
brief's sky parameter (`slot // 64`) puts players past 2^27. If that is
past what the client renders without jitter, the parameters move into
storage keyed by the instance and the slots stay few.
