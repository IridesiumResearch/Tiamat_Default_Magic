# SPDX-FileCopyrightText: Iridesium
# SPDX-License-Identifier: GPL-3.0-only
"""Proves the glyph table sound, from the very file the mod loads.

Reads mods/tiamat_default_magic/glyph_table.lua and checks that:

- every mask is a real carving: at least one cell, not all 27;
- no two magic glyphs share a mask in any of their 48 orientations
  (Craft keeps one meaning a mask, so a clash would silently lose one);
- no magic glyph is one of the interface's own presets (Slab, Stairs,
  Pillar) in any orientation, nor one of Tiamat Default Science's glyphs;
- a preset label is 1 to 8 bytes, the interface's limit;
- every sigil names a planet and an ore, every element glyph materials.

Science's masks are its designer's table (Tiamat_default_science-PROMPT.md
§7.1, draft of 2026-09-28), copied here until that mod registers them: at
run time Craft refuses a clash either way, and the native check would say.

Then prints the table: glyph, cells, orientations. Standard library only.
Run from the repository root:

    python tools/glyphs.py
"""
import itertools
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from check_tree import Reader  # noqa: E402  (the same reader, the same rules)

TABLE = Path(__file__).resolve().parent.parent / "mods" / "tiamat_default_magic" / "glyph_table.lua"

SCIENCE = {
    "rod": 74752, "plate": 1838599, "gear": 10560552, "wheel": 14775352, "pipe": 134142975,
    "coil": 119450567, "ring": 1837575, "gnomon": 1846791, "cairn": 1912327, "bracket": 79,
    "nozzle": 6061591, "rail": 1313285,
}


def preset(rule):
    return sum(1 << (x + 3 * y + 9 * z) for z in range(3) for y in range(3) for x in range(3) if rule(x, y, z))


INTERFACE = {
    "slab": preset(lambda x, y, z: y == 0),
    "stairs": preset(lambda x, y, z: y <= z),
    "pillar": preset(lambda x, y, z: x == 1 and z == 1),
}
FULL = (1 << 27) - 1


def variants(mask):
    cells = [(i % 3, (i // 3) % 3, i // 9) for i in range(27) if mask >> i & 1]
    out = set()
    for order in itertools.permutations(range(3)):
        for flips in itertools.product((0, 1), repeat=3):
            m = 0
            for c in cells:
                v = [c[order[a]] for a in range(3)]
                v = [2 - v[a] if flips[a] else v[a] for a in range(3)]
                m |= 1 << (v[0] + 3 * v[1] + 9 * v[2])
            out.add(m)
    return out


def main():
    r = Reader(TABLE.read_text(encoding="utf8"))
    r.take("name", "return")
    glyphs = r.value()
    problems = []
    seen = {}
    others = {f"interface {k}": variants(v) for k, v in INTERFACE.items()}
    others.update({f"science {k}": variants(v) for k, v in SCIENCE.items()})
    rows = []
    for g in glyphs:
        gid, mask = g["id"], g["mask"]
        if not 0 < mask < FULL:
            problems.append(f"{gid}: mask {mask} is empty or whole")
            continue
        vs = variants(mask)
        for other, ovs in list(seen.items()) + list(others.items()):
            if vs & ovs:
                problems.append(f"{gid} is {other} in some orientation")
        seen[gid] = vs
        if "label" in g and not 1 <= len(g["label"].encode("utf8")) <= 8:
            problems.append(f"{gid}: label {g['label']!r} is not 1 to 8 bytes")
        if "planet" in g and "ore" not in g:
            problems.append(f"{gid}: a sigil without an ore")
        if "element" in g and not g.get("materials"):
            problems.append(f"{gid}: an element without materials")
        rows.append((gid, bin(mask).count("1"), len(vs)))
    if problems:
        print("THE GLYPHS ARE NOT SOUND:")
        for p in problems:
            print("  " + p)
        return 1
    print(f"{len(rows)} glyphs, sound: none shares a mask with another, the interface's presets or science's.")
    print(f"{'glyph':<14} {'cells':>5} {'orientations':>12}")
    for gid, cells, n in rows:
        print(f"{gid:<14} {cells:>5} {n:>12}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
