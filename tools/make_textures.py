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


def tablet():
    """The Emerald Tablet: green crystal, a flat colour, with gilt letters in rows."""
    c = Canvas((52, 150, 96))
    for y in (3, 6, 9, 12):
        for x in range(3, 13):
            if (x * 7 + y * 3) % 5 != 0:            # letters, not a stripe
                c.dot(x, y, (214, 186, 100))
    return c


ITEMS = {
    "emerald_tablet": tablet,
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


BRICK = (150, 84, 60)
BRICK_DARK = (104, 56, 40)


def furnace(glow=None):
    """The athanor: a brick tower, its mouth dark or glowing."""
    c = Canvas(BRICK)
    for y in range(0, SIZE, 4):
        c.rect(0, y, 15, y, BRICK_DARK)
        for x in range((y // 4 % 2) * 4, SIZE, 8):
            c.rect(x, y, x, y + 3, BRICK_DARK)
    c.rect(5, 9, 10, 14, glow or (40, 30, 26))
    return c


def flask(neck, body, liquid=None):
    """Glassware: a neck `neck` wide over a body `body` wide."""
    c = Canvas()
    n0 = 8 - neck // 2
    c.rect(n0, 2, n0 + neck - 1, 7, GLASS_EDGE)
    b0 = 8 - body // 2
    c.rect(b0, 8, b0 + body - 1, 14, GLASS_EDGE)
    c.rect(b0 + 1, 9, b0 + body - 2, 13, liquid or GLASS)
    return c


def retort():
    c = flask(2, 8)
    for i in range(6):
        c.dot(9 + i, 4 + i // 2, GLASS_EDGE)    # the beak
    return c


def dish(fill):
    """A clay dish of something: the baths, the cupel."""
    c = Canvas()
    c.rect(2, 9, 13, 9, fill)
    c.rect(2, 10, 13, 13, CLAY)
    c.rect(4, 14, 11, 14, CLAY_DARK)
    return c


def pipe():
    c = Canvas()
    for i in range(12):
        c.dot(2 + i, 13 - i, (90, 96, 108))
        c.dot(3 + i, 13 - i, (60, 64, 74))
    return c


def crystal(colour, light):
    c = Canvas()
    for x0, h in [(4, 6), (7, 9), (10, 5)]:
        c.rect(x0, 14 - h, x0 + 2, 14, colour)
        c.rect(x0, 14 - h, x0, 14, light)
    return c


# Colours of the Art's matter.
CALX = {
    "litharge": (230, 196, 90), "minium": (214, 70, 44), "putty": (236, 234, 226),
    "aes_ustum": (46, 40, 38), "crocus_martis": (190, 96, 40), "bone_ash": (232, 228, 214),
    "caput_mortuum": (110, 36, 34), "salt_of_tartar": (240, 236, 224), "sal_saturni": (246, 244, 236),
    "salt_of_venus": (70, 160, 150), "verdigris": (70, 170, 120), "principle_salt": (220, 214, 200),
}
LIQUID = {
    "vinum": (120, 30, 50), "vinegar": (170, 110, 60), "distilled_vinegar": (230, 224, 200),
    "aqua_vitae": (224, 232, 236), "spirit_of_wine": (240, 246, 250), "oil_of_vitriol": (200, 190, 150),
    "principle_mercury": (200, 214, 230), "principle_sulfur": (220, 170, 60),
}
PLANET = {
    "sol": (240, 190, 50), "luna": (200, 210, 230), "venus": (90, 190, 110), "mars": (200, 50, 40),
    "mercury": (150, 160, 180), "jupiter": (80, 110, 210), "saturn": (60, 56, 70),
}
ELIXIR = {
    "elixir_vigour": "sol", "elixir_night_sight": "luna", "elixir_hearts_ease": "venus",
    "elixir_fortitude": "mars", "elixir_swiftness": "mercury", "draught_warming": "jupiter",
    "draught_cooling": "saturn",
}

LAB = {
    "athanor": furnace,
    "athanor_lit": lambda: furnace((250, 170, 60)),
    "blowpipe": pipe,
    "phial": lambda: phial(GLASS),
    "alembic": lambda: flask(4, 10),
    "retort": retort,
    "bain_marie": lambda: dish((110, 160, 220)),
    "ash_bath": lambda: dish((130, 126, 120)),
    "sand_bath": lambda: dish((214, 196, 150)),
    "cupel": lambda: dish((232, 228, 214)),
    "silver_grain": lambda: heap((200, 204, 214), (240, 242, 248)),
    "verdigris_salve": lambda: cup((110, 180, 120)),
    "green_vitriol": lambda: crystal((80, 170, 110), (150, 220, 170)),
    "blue_vitriol": lambda: crystal((40, 90, 210), (120, 170, 250)),
    "salamander_ember": lambda: heap((240, 110, 30), (255, 220, 90)),
}
for _name, _colour in CALX.items():
    LAB[_name] = (lambda col: lambda: heap(col, tuple(min(255, v + 40) for v in col)))(_colour)
for _name, _colour in LIQUID.items():
    LAB[_name] = (lambda col: lambda: flask(2, 8, col))(_colour)
for _planet, _colour in PLANET.items():
    LAB["tincture_" + _planet] = (lambda col: lambda: flask(2, 6, col))(_colour)
for _name, _planet in ELIXIR.items():
    LAB[_name] = (lambda col: lambda: phial(col))(PLANET[_planet])
# Tier 4.
LAB.update({
    "aludel": lambda: flask(6, 10, (190, 150, 110)),
    "pelican": lambda: flask(2, 10),
    "philosophers_egg": lambda: flask(4, 8, (240, 236, 220)),
    "quicksilver": lambda: flask(2, 8, (200, 206, 216)),
    "phosphorus": lambda: crystal((236, 240, 200), (250, 255, 230)),
    "phosphorus_spill": pipe,
    "green_lion": lambda: flask(2, 8, (60, 170, 70)),
    "aqua_fortis": lambda: flask(2, 8, (230, 200, 140)),
    "aqua_regia": lambda: flask(2, 8, (230, 150, 60)),
    "spirit_of_salt": lambda: flask(2, 8, (220, 230, 210)),
    "conjoined_matter": lambda: flask(4, 8, (170, 120, 150)),
    "caput_corvi": lambda: flask(4, 8, (24, 22, 28)),
    "peacock_matter": lambda: flask(4, 8, (60, 150, 170)),
})
for _name, _colour in {
    "flowers_of_sulfur": (240, 220, 60), "vermilion": (220, 40, 30), "amalgam_gold": (220, 190, 110),
    "amalgam_silver": (200, 204, 214), "amalgam_tin": (190, 196, 200), "saltpeter": (240, 240, 236),
    "sal_mirabilis": (236, 244, 246), "sal_ammoniac": (230, 226, 220),
}.items():
    LAB[_name] = (lambda col: lambda: heap(col, tuple(min(255, v + 30) for v in col)))(_colour)
ITEMS.update(LAB)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, make in ITEMS.items():
        (OUT / f"{name}.png").write_bytes(png(make().p))
    print(f"wrote {len(ITEMS)} textures to {OUT}")


if __name__ == "__main__":
    main()
