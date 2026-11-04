"""Assemble one rule30 theorem library version on nucleus (sources only; no build).

Usage: python3 -I assemble_vN.py VERSION DELIVERIES.json CLOSURE_REPORT.json [PREV_VERSION] < /dev/null
DELIVERIES.json is an ordered list of [delivery folder, bus number]; a file found in several
deliveries is attributed to the first one listed. CLOSURE_REPORT.json comes from
resolve_closure_vN.py. With PREV_VERSION, every file of the previous version must be present with
identical bytes; any difference is printed as CHANGED and recorded in the manifest.

Layout of ~/rule30_theorem_library/VERSION:
  kit/                 byte-identical copy of the kit verifier 7d665044 sources (no .lake)
  theorems/            the verified theorem files, byte-identical to their deliveries
  lakefile.toml        libraries Rule30LibKitExtensions, Ruliology (kit/lean), Rule30Lib; Mathlib 56a00585
  lean-toolchain       leanprover/lean4:v4.35.0
  LIBRARY_MANIFEST.json, SHA256SUMS
Refuses to run if VERSION already exists (versioned, additive only).
"""
import hashlib
import json
import os
import shutil
import sys

HOME = os.path.expanduser("~")
FVLT = os.path.join(HOME, "fvlt_formalization_20261028")
# Delivery folders live under Codex's tree on nucleus, or under the library's staging folder for
# deliveries made elsewhere (Gemini's, copied from scout with the hash checked).
STAGING = os.path.join(HOME, "rule30_theorem_library", "staging")
ROOTS = [FVLT, STAGING]


def fpath(d, *rest):
    """Path inside delivery folder d, under the first root that holds it."""
    for r in ROOTS:
        if os.path.isdir(os.path.join(r, d)):
            return os.path.join(r, d, *rest)
    raise SystemExit("delivery folder not found: %s" % d)
KIT = os.path.join(HOME, "rule30_prize_research_2026_10_26",
                   "Rule30PrizeKit_verifier_7d665044_20261027")
LIBROOT = os.path.join(HOME, "rule30_theorem_library")
VERSION = sys.argv[1]
OUT = os.path.join(LIBROOT, VERSION)
MATHLIB_REV = "56a005855ea17e0b0958f73ec801ae140b0a1679"
TOOLCHAIN = "leanprover/lean4:v4.35.0\n"

# Delivery folder -> bus message, in attribution order.
with open(sys.argv[2]) as _f:
    _rows = json.load(_f)
DELIVERIES = {r[0]: r[1] for r in _rows}
# Optional third field: the producing seat; Codex unless stated.
PRODUCERS = {r[0]: (r[2] if len(r) > 2 else "Codex (codex-fvlt-formalization, GPT)") for r in _rows}
CLOSURE_REPORT = sys.argv[3]
PREV = sys.argv[4] if len(sys.argv) > 4 else None
PIN_FILES = ["MANIFEST.json", "MANIFEST.sha256", "SOURCE_PINS.json", "NEW_THEOREMS.json"]
VERIFIER = "verified by skeleton (Claude Opus 5.5)"


def sha(path):
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()


def main():
    if os.path.exists(OUT):
        print("REFUSED: %s exists; make a new version instead" % OUT)
        return 1
    with open(CLOSURE_REPORT) as f:
        closure = {k: v for k, v in json.load(f).items() if k.endswith(".lean")}

    os.makedirs(os.path.join(OUT, "theorems"))
    shutil.copytree(KIT, os.path.join(OUT, "kit"),
                    ignore=shutil.ignore_patterns(".lake", "build", "*.olean*", "*.ilean", "*.ir*"))

    entries = []
    for rel, versions in sorted(closure.items()):
        (short, folders), = versions.items()
        src_folder = next((d for d in DELIVERIES if d in folders), folders[0])
        src = fpath(src_folder, rel)
        h = sha(src)
        assert h.startswith(short), (rel, h, short)
        dst = os.path.join(OUT, "theorems", rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(src, dst)
        assert sha(dst) == h
        entries.append({
            "path": "theorems/" + rel,
            "module": rel[:-5].replace("/", "."),
            "sha256": h,
            "source_delivery": src_folder,
            "also_in": sorted(set(folders) - {src_folder}),
            "bus": DELIVERIES.get(src_folder),
        })

    deliveries = {}
    for d, bus in DELIVERIES.items():
        pins = {p: sha(fpath(d, p)) for p in PIN_FILES
                if os.path.isfile(fpath(d, p))}
        deliveries[d] = {"bus": bus, "pin_files": pins, "producer": PRODUCERS[d] + "; " + VERIFIER}

    kit_files = []
    for dirpath, _, filenames in os.walk(os.path.join(OUT, "kit")):
        for fn in filenames:
            p = os.path.join(dirpath, fn)
            kit_files.append({"path": os.path.relpath(p, OUT).replace(os.sep, "/"), "sha256": sha(p)})
    kit_files.sort(key=lambda e: e["path"])

    # Additive check against the previous version: same files, same bytes.
    comparison = None
    if PREV:
        with open(os.path.join(LIBROOT, PREV, "LIBRARY_MANIFEST.json")) as f:
            prev = json.load(f)
        old = {e["path"]: e["sha256"] for e in prev["theorems"] + prev["kit_files"]}
        new = {e["path"]: e["sha256"] for e in entries + kit_files}
        changed = sorted(p for p in old if p in new and new[p] != old[p])
        dropped = sorted(p for p in old if p not in new)
        added = sorted(p for p in new if p not in old)
        for p in changed:
            print("CHANGED %s" % p)
        for p in dropped:
            print("DROPPED %s" % p)
        comparison = {"previous_version": PREV,
                      "previous_manifest_sha256": sha(os.path.join(LIBROOT, PREV, "LIBRARY_MANIFEST.json")),
                      "unchanged": len(old) - len(changed) - len(dropped),
                      "changed": changed, "dropped": dropped, "added": added}

    # Verified files in the kit's Ruliology namespace that are not kit files. They get their
    # own library, declared before the kit library, so Lake resolves them here: a required kit
    # package would claim every Ruliology.* module and never look in theorems/.
    extra = [e["module"] for e in entries if e["module"].startswith("Ruliology.")]
    roots = [e["module"] for e in entries if not e["module"].startswith("Ruliology.")]
    quote = lambda mods: ", ".join('"%s"' % m for m in mods)
    lean_args = 'moreLeanArgs = ["-s65536", "-M8192", "-DElab.async=false"]\n'
    lakefile = (
        'name = "rule30lib"\n'
        'version = "1.0.0"\n'
        'defaultTargets = ["Rule30LibKitExtensions", "Rule30Lib"]\n\n'
        '[[require]]\nname = "mathlib"\nscope = "leanprover-community"\n'
        'git = "https://github.com/leanprover-community/mathlib4"\n'
        'rev = "%s"\n\n'
        '# Verified new files in the Ruliology namespace (not kit files).\n'
        '[[lean_lib]]\nname = "Rule30LibKitExtensions"\nsrcDir = "theorems"\nroots = [%s]\n%s\n'
        '# Kit 7d665044 core statements, built from the byte-identical copy in kit/lean.\n'
        '[[lean_lib]]\nname = "Ruliology"\nsrcDir = "kit/lean"\nroots = ["Ruliology"]\n\n'
        '# Verified new theorems, byte-identical to their deliveries (see LIBRARY_MANIFEST.json).\n'
        '[[lean_lib]]\nname = "Rule30Lib"\nsrcDir = "theorems"\nroots = [%s]\n%s'
    ) % (MATHLIB_REV, quote(extra), lean_args, quote(roots), lean_args)
    with open(os.path.join(OUT, "lakefile.toml"), "w", newline="\n") as f:
        f.write(lakefile)
    with open(os.path.join(OUT, "lean-toolchain"), "w", newline="\n") as f:
        f.write(TOOLCHAIN)

    manifest = {
        "library": "rule30lib",
        "version": VERSION,
        "comparison_with_previous": comparison,
        "date": "2026-10-30",
        "rule": "versioned and additive: never edit a version; a file enters only after skeleton verifies its delivery",
        "toolchain": TOOLCHAIN.strip(),
        "mathlib_rev": MATHLIB_REV,
        "kit": "Rule30PrizeKit_verifier_7d665044_20261027",
        "lakefile_sha256": sha(os.path.join(OUT, "lakefile.toml")),
        "deliveries": deliveries,
        "theorems": entries,
        "kit_files": kit_files,
        "assembled_by": "Claude Opus 5.5 (Fourier viewer session), at saphir's request via skeleton",
    }
    with open(os.path.join(OUT, "LIBRARY_MANIFEST.json"), "w", newline="\n") as f:
        json.dump(manifest, f, indent=1, sort_keys=True)
        f.write("\n")
    # Flat checksum list for `sha256sum -c` on either host.
    with open(os.path.join(OUT, "SHA256SUMS"), "w", newline="\n") as f:
        for e in sorted(entries + kit_files, key=lambda e: e["path"]):
            f.write("%s  %s\n" % (e["sha256"], e["path"]))
        for p in ("lakefile.toml", "lean-toolchain", "LIBRARY_MANIFEST.json"):
            f.write("%s  %s\n" % (sha(os.path.join(OUT, p)), p))
    print(json.dumps({"version": VERSION, "theorems": len(entries), "kit_files": len(kit_files),
                      "added": comparison and comparison["added"],
                      "changed": comparison and comparison["changed"],
                      "dropped": comparison and comparison["dropped"],
                      "manifest_sha256": sha(os.path.join(OUT, "LIBRARY_MANIFEST.json")),
                      "sha256sums_sha256": sha(os.path.join(OUT, "SHA256SUMS"))}))
    return 0


if __name__ == "__main__":
    sys.exit(main())
