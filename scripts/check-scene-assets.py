#!/usr/bin/env python3
"""Verify the exact selected starter originals, in source or a built app ZIP."""
import hashlib
import json
from pathlib import Path
import struct
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = {
    "office-professional", "care-service", "higher-education-campus",
    "acute-healthcare", "aged-care", "allied-health-ndis",
    "financial-services", "mining-resources",
}


def verify(read, names):
    records = json.loads(read("provenance.json"))["assets"]
    expected = {f"stagemark-{name}.png" for name in EXPECTED}
    assert {item["filename"] for item in records} == expected and len(records) == 8
    assert set(names) == expected | {"provenance.json"}, "Unexpected or missing bundled asset"
    for item in records:
        data = read(item["filename"])
        assert data[:8] == b"\x89PNG\r\n\x1a\n"
        assert struct.unpack(">II", data[16:24]) == (1672, 941), item["filename"]
        assert hashlib.sha256(data).hexdigest() == item["sha256"], item["filename"]
    print("Verified eight original starter PNGs; Operations excluded.")


if __name__ == "__main__":
    if len(sys.argv) == 2:
        with zipfile.ZipFile(sys.argv[1]) as archive:
            matches = [name for name in archive.namelist() if name.endswith("/Contents/Resources/SceneBackdrops/provenance.json") and not name.startswith("__MACOSX/")]
            assert len(matches) == 1, "Expected one app resource collection"
            prefix = matches[0].removesuffix("provenance.json")
            names = [name.removeprefix(prefix) for name in archive.namelist() if name.startswith(prefix) and not name.endswith("/")]
            verify(lambda name: archive.read(prefix + name), names)
    elif len(sys.argv) == 1:
        directory = ROOT / "Resources/SceneBackdrops"
        verify(lambda name: (directory / name).read_bytes(), [p.name for p in directory.iterdir() if p.is_file()])
    else:
        sys.exit("Usage: check-scene-assets.py [app.zip]")
