"""Verify this FVLT v3.4.1 (LOCKED) skill bundle from its own directory (standard library only).

  python scripts/verify_bundle.py            # from the bundle root (the folder holding SKILL.md)

Checks: every MANIFEST.sha256 entry matches; no file is missing or unlisted; PROVENANCE.json agrees
with the manifest; the locked v3.4.1 kernel, the carried-over v3.2.6 bibliography and the v3.4.0/v3.3.1/v3.3.0/v3.2.7/v3.2.6/v3.2.5 legacy files carry their pinned hashes;
the kernel holds 187 native-id tags; every bundle path that SKILL.md names in backticks exists.
A PASS establishes integrity of the bundle, not mathematical correctness.
"""
import hashlib
import json
import re
import sys
from pathlib import Path
from urllib.parse import quote

PINS = {
    "kernel_v3_4_1.md": "7d46a830eb144cd3ad61e5f2842629e35432a68e56a2351aabe54ab698e157ce",
    "legacy/v3.4.0/kernel_v3_4_0.md": "0d6beee233602502576c1d0eedfe5a586e66f1b4e4b8a1858c39189d872ec1a2",
    "legacy/v3.4.0/SKILL_v3_4_0.md": "69b3bf048ca32f8cd1ef41094597b342284fe8bc3fc56634cd3ff89f9ed52164",
    "legacy/v3.3.1/kernel_v3_3_1.md": "e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0",
    "legacy/v3.3.1/SKILL_v3_3_1.md": "9ceeff6903db6ab347be6898047fc30ba933757c142efd2d5378f9dd11cd196b",
    "legacy/v3.3.0/kernel_v3_3_0.md": "35ca26ee4cc68fee56013a769070eb14240ddf8aa8376b038a29c3d470e2b5ce",
    "legacy/v3.3.0/SKILL_v3_3_0.md": "90e4331ac4180511f5f24d7d06687e3eaada5baa944370cb7e122fb64c6e2a0f",
    "legacy/v3.2.7/kernel_v3_2_7.md": "b8266896dad305356faa76c7248338d3aed37115f8c434f7727475f28ad42a81",
    "legacy/v3.2.6/kernel_v3_2_6.md": "4a23d62e15ada3819defe6919e56fe9f2ef6a9a10eb7f5c4082e4b6b442cdb94",
    "legacy/v3.2.6/SKILL_v3_2_6.md": "ed885147b8c0401dd7579673369e9159f057e553b67a224b503b0b5401a7cfc3",
    "bibliography_v3_2_6.md": "f109a7e1097275795bb44fa481d4f63422dce7456c3dbbd7e7348f3468a4c474",
    "legacy/v3.2.5/kernel_v3_2_5.md": "ac53e75b73c42f185248464e3daf856a3dd3fd98b56dfff971341b80b10717ef",
    "legacy/v3.2.5/SKILL_v3_2_5.md": "9b32a3291e3f37f03267d2230fc8184e70742b3b84137bb2b88b6e3a3b62afb1",
    "legacy/v3.2.5/bibliography_v3_2_5.md": "b82f8df76895ff29a41957e8ed7143750c2f0606be7b2d61a99cfa5759b2b01e",
}
NATIVE_IDS = 187


def current_work_problems(root):
    """Validate navigation boundaries offline; remote hashes require the repository builder."""
    path = root / "references/CURRENT_WORK_INDEX.json"
    if not path.is_file():
        return ["current-work navigation index is missing"]
    try:
        index = json.loads(path.read_text(encoding="utf-8"))
    except (ValueError, OSError) as exc:
        return [f"current-work navigation JSON is invalid: {exc}"]
    problems = []
    if index.get("kind") != "fvlt-current-work-navigation" or index.get("mathematical_authority") is not False:
        problems.append("current-work index must be advisory, with no mathematical authority")
    # The advisory index was built against v3.2.6 and is carried over unrefreshed in the v3.3.0, v3.3.1, v3.4.0 and v3.4.1 bundles.
    if index.get("release", {}).get("kernel_sha256") != PINS["legacy/v3.2.6/kernel_v3_2_6.md"]:
        problems.append("current-work index does not identify the v3.2.6 kernel it was built against")
    if index.get("historical_comparison_context", {}).get("target_sha256") != "d01cb3440e5aeb68f78d5414c402eb66520cd3b03583bb900ebab82954bf0efb":
        problems.append("current-work historical comparisons must retain their PR15 target")
    for group in ("release_items", "release_corrections", "catalog_records", "research_cases", "external_work"):
        for entry in index.get(group, []):
            if entry.get("mathematical_authority") is not False:
                problems.append(f"current-work {entry.get('id')} must not confer mathematical authority")
            if entry.get("release_relation") not in {"included", "external", "proposed", "unassessed"}:
                problems.append(f"current-work {entry.get('id')} has an unknown release relation")
            if group in {"research_cases", "external_work"} and entry.get("release_relation") not in {"external", "proposed"}:
                problems.append(f"current-work {entry.get('id')}: external/historical work cannot be promoted to included")
    commit = index.get("source_commit", "")
    if not re.fullmatch(r"[0-9a-f]{40}", commit):
        problems.append("current-work source commit is not an immutable full commit")
    for path, source in index.get("sources", {}).items():
        expected = f"https://github.com/hypatiaa/idea-catalog/blob/{commit}/{quote(path, safe='/')}"
        if source.get("commit") != commit or source.get("url") != expected or not re.fullmatch(r"[0-9a-f]{64}", source.get("sha256", "")):
            problems.append(f"current-work {path}: invalid immutable source pin")
    return problems


def main(root=Path(__file__).resolve().parents[1]):
    problems = []
    digest = lambda rel: hashlib.sha256((root / rel).read_bytes()).hexdigest()  # noqa: E731
    listed = {}
    for line in (root / "MANIFEST.sha256").read_text(encoding="utf-8").splitlines():
        h, rel = line.split("  ", 1)
        listed[rel] = h
    on_disk = {p.relative_to(root).as_posix() for p in root.rglob("*")
               if p.is_file() and "__pycache__" not in p.parts}
    for rel in sorted(set(listed) - on_disk):
        problems.append(f"listed but missing: {rel}")
    for rel in sorted(on_disk - set(listed) - {"MANIFEST.sha256"}):
        problems.append(f"present but not in the manifest: {rel}")
    for rel, h in sorted(listed.items()):
        if rel in on_disk and digest(rel) != h:
            problems.append(f"hash mismatch: {rel}")
    prov = json.loads((root / "PROVENANCE.json").read_text(encoding="utf-8"))
    for entry in prov["files"]:
        if listed.get(entry["path"]) != entry["sha256"]:
            problems.append(f"PROVENANCE and MANIFEST disagree on {entry['path']}")
    for rel, h in PINS.items():
        if listed.get(rel) != h:
            problems.append(f"{rel} does not carry its pinned hash {h[:12]}...")
    kernel = (root / "kernel_v3_4_1.md").read_text(encoding="utf-8")
    n = len(re.findall(r"<!-- id: ", kernel))
    if n != NATIVE_IDS:
        problems.append(f"kernel has {n} native-id tags, expected {NATIVE_IDS}")
    skill = (root / "SKILL.md").read_text(encoding="utf-8")
    for ref in sorted(set(re.findall(r"`((?:records|legacy|scripts|references)/[^`\s]+|[A-Za-z_]+_v3_(?:2_[567]|3_[01]|4_[01])\.(?:md|json)|PROVENANCE\.json|MANIFEST\.sha256)`", skill))):
        if not ((root / ref).is_file() or (ref.endswith("/") and (root / ref).is_dir())):
            problems.append(f"SKILL.md names {ref}, which is not in the bundle")
    problems.extend(current_work_problems(root))
    for p in problems:
        print(f"FAIL: {p}")
    if not problems:
        print(f"PASS: {len(listed)} manifest entries verified; pinned v3.4.1 kernel, v3.2.6 bibliography and v3.4.0/v3.3.1/v3.3.0/v3.2.7/v3.2.6/v3.2.5 legacy files intact; "
              f"{n} native-id tags; every bundle path named in SKILL.md exists; current-work advisory boundaries intact")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
