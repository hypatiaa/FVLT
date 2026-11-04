"""Resolve the import closure of the verified deliveries for one library version, on nucleus.

Usage: python3 -I resolve_closure_vN.py DELIVERIES.json OUT_REPORT.json < /dev/null
DELIVERIES.json maps each delivery folder (under ~/fvlt_formalization_20261028) to its bus number.
Prints, for every non-Mathlib, non-kit module in the closure, the distinct source versions found
under ~/fvlt_formalization_20261028 (by sha256), so that ambiguous modules can be pinned from the
delivery pin files. The full report goes to OUT_REPORT.json.
"""
import hashlib
import json
import os
import re
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
                   "Rule30PrizeKit_verifier_7d665044_20261027", "lean")
with open(sys.argv[1]) as _f:
    _rows = json.load(_f)
# Accepts the ordered [folder, bus, producer?] list used by assemble_vN.py, or a plain mapping.
ROOT_DELIVERIES = sorted(r[0] for r in _rows) if isinstance(_rows, list) else sorted(_rows)
OUT_REPORT = sys.argv[2]
SKIP_DIRS = {".lake", "attempts", "final_attempts", "tools", "modules"}
IMPORT_RE = re.compile(r"^import\s+(\S+)", re.M)


def sha(path):
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()


def module_path(mod):
    return mod.replace(".", "/") + ".lean"


def index_candidates():
    """Map module path -> {sha256: [file paths]} over every delivery folder."""
    idx = {}
    for top in sorted({t for r in ROOTS if os.path.isdir(r) for t in os.listdir(r)}):
        base = fpath(top)
        if not os.path.isdir(base):
            continue
        for dirpath, dirnames, filenames in os.walk(base):
            dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
            for fn in filenames:
                if not fn.endswith(".lean") or fn == "lakefile.lean":
                    continue
                full = os.path.join(dirpath, fn)
                rel = os.path.relpath(full, base).replace(os.sep, "/")
                idx.setdefault(rel, {}).setdefault(sha(full), []).append(top)
    return idx


def main():
    idx = index_candidates()
    roots = []
    for d in ROOT_DELIVERIES:
        base = fpath(d)
        for fn in sorted(os.listdir(base)):
            if fn.endswith(".lean") and fn != "lakefile.lean":
                roots.append((d, fn))
        extra = os.path.join(base, "Ruliology")
        if os.path.isdir(extra):
            for dirpath, _, filenames in os.walk(extra):
                for fn in filenames:
                    if not fn.endswith(".lean"):
                        continue
                    rel = os.path.relpath(os.path.join(dirpath, fn), base).replace(os.sep, "/")
                    if not os.path.isfile(os.path.join(KIT, rel)):
                        roots.append((d, rel))

    seen, queue, report = set(), [], {}
    for d, rel in roots:
        queue.append((rel, d))
    while queue:
        rel, origin = queue.pop()
        if rel in seen:
            continue
        seen.add(rel)
        if os.path.isfile(os.path.join(KIT, rel)):
            continue
        versions = idx.get(rel, {})
        report[rel] = {h[:12]: sorted(set(v)) for h, v in versions.items()}
        if not versions:
            continue
        # Follow imports of every version, so nothing in the closure is missed.
        for h, tops in versions.items():
            src = fpath(tops[0], rel)
            if not os.path.isfile(src):
                # The file sits below a subfolder of the delivery; find it.
                for dirpath, dirnames, filenames in os.walk(fpath(tops[0])):
                    dirnames[:] = [x for x in dirnames if x not in SKIP_DIRS]
                    cand = os.path.join(dirpath, os.path.basename(rel))
                    if os.path.basename(rel) in filenames and sha(cand) == h:
                        src = cand
                        break
            with open(src, encoding="utf-8") as f:
                for mod in IMPORT_RE.findall(f.read()):
                    if mod.startswith(("Mathlib", "Init", "Lean", "Std", "Batteries", "Aesop", "Qq")):
                        continue
                    queue.append((module_path(mod), rel))

    missing = [r for r, v in report.items() if not v]
    ambiguous = {r: v for r, v in report.items() if len(v) > 1}
    print(json.dumps({"closure_non_kit": len(report), "missing": missing,
                      "ambiguous": ambiguous}, indent=1, sort_keys=True))
    with open(OUT_REPORT, "w") as f:
        json.dump(report, f, indent=1, sort_keys=True)
    return 1 if (missing or ambiguous) else 0


if __name__ == "__main__":
    sys.exit(main())
