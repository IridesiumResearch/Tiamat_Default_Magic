# SPDX-FileCopyrightText: Iridesium
# SPDX-License-Identifier: GPL-3.0-only
"""Generates the placeholder textures for mods/tiamat_default_magic/textures.

A flat colour for a block, the Spindle's convention: variation across a
surface is the renderer's, never baked into the picture. An item is flat
colours in one silhouette on a clear ground, so it reads in a slot: a phial
for a drink, a heap for a powder, a sprig for a simple. Every picture here is
meant to be replaced.

No dependencies beyond the standard library, and no randomness: the same
bytes on every machine. Run from the repository root:

    python tools/make_textures.py
"""
import struct
import zlib
from pathlib import Path

SIZE = 16
OUT = Path(__file__).resolve().parent.parent / "mods" / "tiamat_default_magic" / "textures"

GLASS = (206, 226, 222)
GLASS_EDGE = (150, 176, 172)
CORK = (150, 110, 70)
CLAY = (176, 122, 88)
CLAY_DARK = (128, 86, 60)
LEATHER = (120, 78, 46)
LEATHER_DARK = (84, 52, 30)
PAGE = (232, 220, 186)
COPPER = (196, 116, 70)
COPPER_DARK = (140, 78, 44)
STEM = (70, 120, 60)


def png(pixels):
    """RGBA rows of (r, g, b, a) tuples, as PNG bytes."""
    raw = b"".join(b"\x00" + b"".join(bytes(p) for p in row) for row in pixels)

    def chunk(kind, data):
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)

    header = struct.pack(">IIBBBBB", SIZE, SIZE, 8, 6, 0, 0, 0)
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header)
            + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


class Canvas:
    def __init__(self, ground=None, alpha=255):
        fill = (ground + (alpha,)) if ground else (0, 0, 0, 0)
        self.p = [[fill for _ in range(SIZE)] for _ in range(SIZE)]

    def dot(self, x, y, colour, alpha=255):
        if 0 <= x < SIZE and 0 <= y < SIZE:
            self.p[y][x] = colour + (alpha,)

    def rect(self, x0, y0, x1, y1, colour, alpha=255):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.dot(x, y, colour, alpha)


def phial(liquid):
    """A stoppered phial, `liquid` inside: every drink."""
    c = Canvas()
    c.rect(7, 1, 8, 2, CORK)
    c.rect(7, 3, 8, 5, GLASS_EDGE)
    c.rect(5, 6, 10, 14, GLASS_EDGE)
    c.rect(6, 7, 9, 13, GLASS)
    c.rect(6, 9, 9, 13, liquid)
    c.rect(5, 15, 10, 15, GLASS_EDGE)
    return c


def cup(liquid):
    """A clay cup of tea."""
    c = Canvas()
    c.rect(3, 6, 12, 13, CLAY)
    c.rect(4, 6, 11, 8, liquid)
    c.rect(13, 8, 14, 11, CLAY_DARK)
    c.rect(4, 14, 11, 14, CLAY_DARK)
    return c


def heap(colour, light):
    """A little heap of powder."""
    c = Canvas()
    for row, (x0, x1) in enumerate([(7, 8), (6, 9), (5, 10), (4, 11), (3, 12), (2, 13)]):
        c.rect(x0, 9 + row, x1, 9 + row, colour)
    c.dot(7, 10, light)
    c.dot(6, 11, light)
    return c


def sprig(leaf, flower=None):
    """A ground simple: a sprig on a paper twist."""
    c = Canvas()
    c.rect(4, 12, 11, 14, PAGE)
    c.rect(7, 4, 8, 11, STEM)
    for x, y in [(5, 5), (10, 6), (5, 8), (10, 9), (6, 6), (9, 7)]:
        c.dot(x, y, leaf)
    if flower:
        c.rect(6, 2, 9, 3, flower)
    return c


def book():
    c = Canvas()
    c.rect(2, 2, 13, 13, LEATHER)
    c.rect(3, 3, 12, 12, LEATHER_DARK)
    c.rect(12, 3, 13, 13, PAGE)
    for x, y in [(7, 5), (6, 6), (8, 6), (7, 7), (7, 8), (6, 9), (8, 9)]:
        c.dot(x, y, (214, 180, 90))           # a gilt sun on the cover
    return c


def mortar():
    c = Canvas()
    c.rect(2, 8, 13, 9, CLAY_DARK)
    c.rect(3, 10, 12, 12, CLAY)
    c.rect(5, 13, 10, 14, CLAY_DARK)
    for i in range(6):
        c.dot(9 + i // 2, 7 - i, CLAY_DARK)    # the pestle
    return c


def still():
    c = Canvas()
    c.rect(3, 8, 10, 14, COPPER)
    c.rect(4, 9, 9, 13, COPPER_DARK)
    c.rect(5, 5, 8, 7, COPPER)
    for i in range(6):
        c.dot(9 + i, 5 + i // 2, GLASS_EDGE)   # the worm
    return c


def poultice():
    c = Canvas()
    c.rect(3, 5, 12, 11, PAGE)
    c.rect(5, 7, 10, 9, (150, 190, 90))
    return c


def lamp():
    """The Hermetic Lamp: a jar of glow caps, seen through; alpha is the glass."""
    c = Canvas((170, 230, 196), 150)
    c.rect(0, 0, 15, 0, GLASS_EDGE)
    c.rect(0, 15, 15, 15, GLASS_EDGE)
    c.rect(0, 0, 0, 15, GLASS_EDGE)
    c.rect(15, 0, 15, 15, GLASS_EDGE)
    for x, y in [(5, 10), (6, 9), (7, 10), (9, 11), (10, 10), (11, 11), (7, 6), (8, 5), (9, 6)]:
        c.dot(x, y, (220, 255, 230))
    return c


ITEMS = {
    "mutus_liber": book,
    "mortar": mortar,
    "copper_still": still,
    "poultice": poultice,
    "simple_chamomile": lambda: sprig((110, 170, 80), (250, 250, 230)),
    "simple_mint": lambda: sprig((90, 190, 120)),
    "simple_bramble": lambda: sprig((70, 130, 60), (120, 40, 90)),
    "simple_mantle": lambda: sprig((140, 180, 70), (210, 220, 90)),
    "flame_powder_blue": lambda: heap((230, 200, 60), (250, 230, 120)),    # sulfur, which burns blue
    "flame_powder_green": lambda: heap((120, 190, 150), (170, 220, 190)),  # copper filings, verdigrised
    "flame_powder_yellow": lambda: heap((240, 240, 240), (255, 255, 255)),  # salt
    "flame_powder_white": lambda: heap((220, 214, 200), (240, 236, 226)),  # ground bone
    "chamomile_tea": lambda: cup((210, 180, 80)),
    "mint_tea": lambda: cup((150, 200, 120)),
    "bramble_tea": lambda: cup((150, 80, 90)),
    "rosewater": lambda: phial((240, 170, 190)),
    "mint_water": lambda: phial((180, 230, 200)),
    "hermetic_lamp": lamp,
}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, make in ITEMS.items():
        (OUT / f"{name}.png").write_bytes(png(make().p))
    print(f"wrote {len(ITEMS)} textures to {OUT}")


if __name__ == "__main__":
    main()
