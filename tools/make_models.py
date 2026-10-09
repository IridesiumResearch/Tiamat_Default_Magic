# SPDX-FileCopyrightText: Iridesium
# SPDX-License-Identifier: GPL-3.0-only
"""Generates the placeholder models for mods/tiamat_default_magic/models:
the familiars, and the blocks drawn as models (the athanor, the Tablet).
The homunculus and the basilisk are the designer's own (`homunculus_1`,
`basilisk_1`) and are not written here.

A familiar is a few boxes: rigid (no clips, so the engine draws it still),
self-contained .glb with no image inside it (the engine refuses one that
embeds its picture), and a PNG beside it drawn on with the boxes' UVs.
Units are cells, three to a block; feet on y = 0; facing +Z, as the
engine's creatures are. A child should want one, not fear one. Every model
here is meant to be replaced by an artist's.

No dependencies beyond the standard library, and no randomness: the same
bytes on every machine. Run from the repository root:

    python tools/make_models.py
"""
import json
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_textures import Canvas, png  # noqa: E402

OUT = Path(__file__).resolve().parent.parent / "mods" / "tiamat_default_magic" / "models"

# Each face: the axis it faces, its sign, and its four corners' (u, v) order.
FACES = [
    ((1, 0, 0), [(1, 0, 0), (1, 1, 0), (1, 1, 1), (1, 0, 1)]),
    ((-1, 0, 0), [(0, 0, 1), (0, 1, 1), (0, 1, 0), (0, 0, 0)]),
    ((0, 1, 0), [(0, 1, 0), (0, 1, 1), (1, 1, 1), (1, 1, 0)]),
    ((0, -1, 0), [(0, 0, 1), (0, 0, 0), (1, 0, 0), (1, 0, 1)]),
    ((0, 0, 1), [(1, 0, 1), (1, 1, 1), (0, 1, 1), (0, 0, 1)]),
    ((0, 0, -1), [(0, 0, 0), (0, 1, 0), (1, 1, 0), (1, 0, 0)]),
]


def boxes_to_mesh(boxes):
    """`(lo, hi, (u0, v0, u1, v1))` boxes -> positions, normals, uvs, indices."""
    pos, nor, uv, idx = [], [], [], []
    for lo, hi, (u0, v0, u1, v1) in boxes:
        for normal, corners in FACES:
            base = len(pos)
            for k, c in enumerate(corners):
                pos.append(tuple(lo[a] if c[a] == 0 else hi[a] for a in range(3)))
                nor.append(normal)
                uv.append(((u0, v1), (u0, v0), (u1, v0), (u1, v1))[k])
            idx += [base, base + 1, base + 2, base, base + 2, base + 3]
    return pos, nor, uv, idx


def glb(pos, nor, uv, idx):
    """A self-contained glTF 2.0 binary: one mesh, one primitive, no image."""
    blob = b"".join(struct.pack("<3f", *p) for p in pos)
    n_off = len(blob)
    blob += b"".join(struct.pack("<3f", *n) for n in nor)
    t_off = len(blob)
    blob += b"".join(struct.pack("<2f", *t) for t in uv)
    i_off = len(blob)
    blob += b"".join(struct.pack("<H", i) for i in idx)
    while len(blob) % 4:
        blob += b"\x00"
    lo = [min(p[a] for p in pos) for a in range(3)]
    hi = [max(p[a] for p in pos) for a in range(3)]
    doc = {
        "asset": {"version": "2.0", "generator": "tiamat_default_magic make_models.py"},
        "scene": 0, "scenes": [{"nodes": [0]}], "nodes": [{"mesh": 0}],
        "materials": [{"pbrMetallicRoughness": {"baseColorFactor": [1, 1, 1, 1], "metallicFactor": 0}}],
        "meshes": [{"primitives": [{"attributes": {"POSITION": 0, "NORMAL": 1, "TEXCOORD_0": 2},
                                    "indices": 3, "material": 0}]}],
        "buffers": [{"byteLength": len(blob)}],
        "bufferViews": [
            {"buffer": 0, "byteOffset": 0, "byteLength": n_off, "target": 34962},
            {"buffer": 0, "byteOffset": n_off, "byteLength": t_off - n_off, "target": 34962},
            {"buffer": 0, "byteOffset": t_off, "byteLength": i_off - t_off, "target": 34962},
            {"buffer": 0, "byteOffset": i_off, "byteLength": 2 * len(idx), "target": 34963},
        ],
        "accessors": [
            {"bufferView": 0, "componentType": 5126, "count": len(pos), "type": "VEC3", "min": lo, "max": hi},
            {"bufferView": 1, "componentType": 5126, "count": len(nor), "type": "VEC3"},
            {"bufferView": 2, "componentType": 5126, "count": len(uv), "type": "VEC2"},
            {"bufferView": 3, "componentType": 5123, "count": len(idx), "type": "SCALAR"},
        ],
    }
    js = json.dumps(doc, separators=(",", ":")).encode()
    while len(js) % 4:
        js += b" "
    body = struct.pack("<II", len(js), 0x4E4F534A) + js + struct.pack("<II", len(blob), 0x004E4942) + blob
    return struct.pack("<III", 0x46546C67, 2, 12 + len(body)) + body


# The texture is split in two: the left half is hide, the right half is the
# head's face (with its eyes), so boxes pick one or the other by their UVs.
HIDE = (0.0, 0.0, 0.5, 1.0)
FACE = (0.5, 0.0, 1.0, 1.0)


def salamander():
    """Cellini's fire lizard: a stubby body, a round head, a curling tail."""
    boxes = [
        ((-0.45, 0.3, -0.9), (0.45, 0.75, 0.9), HIDE),      # body
        ((-0.38, 0.32, 0.9), (0.38, 0.78, 1.5), FACE),       # head
        ((-0.22, 0.35, -1.7), (0.22, 0.6, -0.9), HIDE),      # tail
        ((-0.12, 0.38, -2.2), (0.12, 0.55, -1.7), HIDE),     # tail tip
        ((0.35, 0.0, 0.4), (0.6, 0.35, 0.7), HIDE),          # legs
        ((-0.6, 0.0, 0.4), (-0.35, 0.35, 0.7), HIDE),
        ((0.35, 0.0, -0.7), (0.6, 0.35, -0.4), HIDE),
        ((-0.6, 0.0, -0.7), (-0.35, 0.35, -0.4), HIDE),
    ]
    c = Canvas((226, 92, 36))
    for x, y in [(1, 2), (5, 4), (2, 8), (6, 10), (3, 13), (1, 5), (6, 1), (4, 7)]:
        c.dot(x, y, (250, 200, 60))                          # the hide's yellow spots
    c.rect(8, 0, 15, 15, (236, 110, 44))                      # the face
    for x in (10, 13):
        c.rect(x, 5, x + 1, 7, (30, 20, 20))                  # eyes
        c.dot(x, 5, (250, 250, 250))
    c.rect(10, 10, 13, 10, (170, 50, 30))                     # a smile
    return boxes, c


def undine():
    """A water spirit: a slim figure rising from a swirl."""
    boxes = [
        ((-0.5, 0.0, -0.5), (0.5, 0.3, 0.5), HIDE),         # the swirl it stands in
        ((-0.3, 0.3, -0.25), (0.3, 1.1, 0.25), HIDE),       # body
        ((-0.28, 1.1, -0.28), (0.28, 1.6, 0.28), FACE),     # head
        ((0.3, 0.6, -0.1), (0.45, 1.0, 0.1), HIDE),         # arms
        ((-0.45, 0.6, -0.1), (-0.3, 1.0, 0.1), HIDE),
    ]
    c = Canvas((70, 140, 220))
    for x, y in [(1, 3), (5, 6), (2, 11), (6, 13), (3, 1)]:
        c.dot(x, y, (180, 220, 250))
    face(c, (110, 180, 240))
    return boxes, c


def gnome():
    """An earth spirit: a stout little figure in a pointed cap."""
    boxes = [
        ((-0.35, 0.0, -0.3), (0.35, 0.8, 0.3), HIDE),       # body
        ((-0.3, 0.8, -0.3), (0.3, 1.2, 0.3), FACE),         # head
        ((-0.33, 1.2, -0.33), (0.33, 1.3, 0.33), HIDE),     # the cap's brim
        ((-0.15, 1.3, -0.15), (0.15, 1.5, 0.15), HIDE),     # its point
    ]
    c = Canvas((120, 80, 50))
    c.rect(0, 0, 7, 3, (200, 50, 40))                      # a red cap
    face(c, (230, 190, 160))
    c.rect(9, 11, 14, 15, (240, 240, 236))                  # a white beard
    return boxes, c


def sylph():
    """An air spirit: a pale, light figure with wings."""
    boxes = [
        ((-0.25, 0.4, -0.2), (0.25, 1.3, 0.2), HIDE),       # body
        ((-0.25, 1.3, -0.25), (0.25, 1.8, 0.25), FACE),     # head
        ((0.25, 0.8, -0.05), (0.9, 1.5, 0.05), HIDE),       # wings
        ((-0.9, 0.8, -0.05), (-0.25, 1.5, 0.05), HIDE),
    ]
    c = Canvas((226, 236, 246))
    for x, y in [(1, 2), (5, 5), (2, 10), (6, 12)]:
        c.dot(x, y, (190, 210, 240))
    face(c, (240, 244, 250))
    return boxes, c


def face(c, skin):
    """The right half of a familiar's picture: its face, eyes and a smile."""
    c.rect(8, 0, 15, 15, skin)
    for x in (10, 13):
        c.rect(x, 5, x + 1, 7, (30, 20, 20))
        c.dot(x, 5, (250, 250, 250))
    c.rect(10, 10, 13, 10, (120, 60, 60))


# Blocks drawn as models (Sub-Node Contract §8.6): the same units, so a block
# is -1.5..1.5 across, 0..3 tall, its front +Z. Their texture is split as a
# familiar's is: the left half the body, the right half the face that shows.
def athanor_of(mouth, glow):
    """The philosophers' oven: a plinth, a brick tower, a dome, and its mouth."""
    boxes = [
        ((-1.5, 0.0, -1.5), (1.5, 0.5, 1.5), HIDE),         # the plinth
        ((-1.25, 0.5, -1.25), (1.25, 2.3, 1.25), HIDE),     # the tower
        ((-0.9, 2.3, -0.9), (0.9, 2.75, 0.9), HIDE),        # the dome
        ((-0.3, 2.75, -0.3), (0.3, 3.0, 0.3), HIDE),        # the chimney's lip
        ((-0.55, 0.65, 1.25), (0.55, 1.45, 1.32), FACE),    # the fire mouth, in front
    ]
    c = Canvas((150, 82, 58))
    for y in range(0, 16, 3):                                # courses of brick
        c.rect(0, y, 7, y, (110, 60, 44))
        for x in ((1, 5) if (y // 3) % 2 else (3, 7)):
            c.rect(x, y, x, y + 2, (110, 60, 44))
    c.rect(8, 0, 15, 15, (70, 44, 34))                       # the mouth's iron frame
    c.rect(9, 2, 14, 13, mouth)
    if glow:
        c.rect(10, 8, 13, 12, glow)
        c.rect(11, 5, 12, 7, glow)
    return boxes, c


def emerald_tablet():
    """Hermes' tablet: a green slab standing on a stone plinth."""
    boxes = [
        ((-1.5, 0.0, -1.5), (1.5, 0.6, 1.5), HIDE),         # the plinth
        ((-1.2, 0.6, -0.35), (1.2, 2.95, 0.35), FACE),      # the tablet
    ]
    c = Canvas((128, 128, 120))
    for x, y in [(1, 2), (5, 6), (2, 11), (6, 13)]:
        c.dot(x, y, (100, 100, 96))
    c.rect(8, 0, 15, 15, (30, 150, 80))                      # emerald
    c.rect(8, 0, 15, 0, (20, 110, 60))
    for y in (3, 6, 9, 12):                                  # its lines of writing
        c.rect(10, y, 13, y, (180, 240, 200))
    return boxes, c


MODELS = {"salamander": salamander, "undine": undine, "gnome": gnome, "sylph": sylph,
          "athanor": lambda: athanor_of((24, 16, 14), None),
          "athanor_lit": lambda: athanor_of((90, 30, 10), (250, 170, 40)),
          "emerald_tablet": emerald_tablet}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, make in MODELS.items():
        boxes, canvas = make()
        (OUT / f"{name}.glb").write_bytes(glb(*boxes_to_mesh(boxes)))
        (OUT / f"{name}.png").write_bytes(png(canvas.p))
    print(f"wrote {len(MODELS)} models to {OUT}")


if __name__ == "__main__":
    main()
