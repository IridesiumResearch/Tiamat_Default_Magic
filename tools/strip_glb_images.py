# SPDX-FileCopyrightText: Iridesium
# SPDX-License-Identifier: GPL-3.0-only
"""Takes the embedded pictures out of a .glb, so the engine will load it.

The engine refuses a model that carries its own image: the skin travels
separately, as the PNG beside the model that `register_model{ texture }`
names. Art exported from Blender usually embeds it. This rewrites the file
without its `images`, `textures` and `samplers` and without the buffer
slices they used, leaving the mesh, skeleton, materials and clips as they
were, and refuses to touch a file whose embedded image differs from the
PNG beside it (pass --force to strip it anyway).

    python tools/strip_glb_images.py mods/tiamat_default_magic/models/basilisk_1.glb
"""
import json
import struct
import sys
from pathlib import Path


def read(path):
    b = path.read_bytes()
    magic, version, _ = struct.unpack("<III", b[:12])
    assert magic == 0x46546C67 and version == 2, f"{path}: not a glTF 2 binary"
    jl = struct.unpack("<I", b[12:16])[0]
    doc = json.loads(b[20:20 + jl])
    bl = struct.unpack("<I", b[20 + jl:24 + jl])[0]
    return doc, b[28 + jl:28 + jl + bl]


def write(path, doc, blob):
    js = json.dumps(doc, separators=(",", ":")).encode()
    while len(js) % 4:
        js += b" "
    body = struct.pack("<II", len(js), 0x4E4F534A) + js + struct.pack("<II", len(blob), 0x004E4942) + blob
    path.write_bytes(struct.pack("<III", 0x46546C67, 2, 12 + len(body)) + body)


def strip(path, force=False):
    doc, blob = read(path)
    images = doc.get("images") or []
    if not images:
        print(f"{path}: no embedded images")
        return
    drop = {img["bufferView"] for img in images if "bufferView" in img}
    png = path.with_suffix(".png")
    for view in drop:
        v = doc["bufferViews"][view]
        embedded = blob[v.get("byteOffset", 0):v.get("byteOffset", 0) + v["byteLength"]]
        if not force and (not png.exists() or png.read_bytes() != embedded):
            sys.exit(f"{path}: its embedded image is not {png.name}; export the PNG beside it, or pass --force")
    out, views, remap = b"", [], {}
    for i, v in enumerate(doc["bufferViews"]):
        if i in drop:
            continue
        while len(out) % 4:
            out += b"\0"
        o = v.get("byteOffset", 0)
        nv = dict(v, byteOffset=len(out))
        out += blob[o:o + v["byteLength"]]
        remap[i] = len(views)
        views.append(nv)
    while len(out) % 4:
        out += b"\0"
    doc["bufferViews"] = views
    doc["buffers"][0]["byteLength"] = len(out)
    for a in doc.get("accessors", []):
        if "bufferView" in a:
            a["bufferView"] = remap[a["bufferView"]]
    for key in ("images", "textures", "samplers"):
        doc.pop(key, None)
    for m in doc.get("materials", []):
        pbr = m.get("pbrMetallicRoughness", {})
        pbr.pop("baseColorTexture", None)
        for key in ("normalTexture", "occlusionTexture", "emissiveTexture"):
            m.pop(key, None)
    write(path, doc, out)
    print(f"{path}: {len(drop)} embedded image(s) taken out; the skin is {png.name}")


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--force"]
    if not args:
        sys.exit(__doc__)
    for arg in args:
        strip(Path(arg), force="--force" in sys.argv)
