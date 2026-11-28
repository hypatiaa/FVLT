"""Recompile the local sources, replay their kernel declarations, and audit the axioms."""
import argparse
import hashlib
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


HERE = Path(__file__).resolve().parent
MATHLIB_PIN = "56a005855ea17e0b0958f73ec801ae140b0a1679"
BASE_SHA = "25b6b49f5b1e14a170dfcae5d6c82fc98a6cc746bdb6fbc745dc7fa4fd2aeb60"
MODULES = ("FareyOrbitSeven", "FareyOrbitPhasors", "TwistedCount",
           "FareyRankInversion", "FareyQuadraticProjection")


def run(cmd, cwd, env):
    result = subprocess.run(cmd, cwd=cwd, env=env, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, encoding="utf-8", errors="replace")
    if result.returncode:
        raise RuntimeError(f"{cmd} failed\n{result.stdout}")
    return result.stdout.strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--packages", type=Path, default=HERE.parent /
                        "rule30_prize_research_2026_10_26/Rule30PrizeKit/.lake/packages")
    parser.add_argument("--bin", type=Path, default=Path.home() /
                        ".elan/toolchains/leanprover--lean4---v4.35.0/bin")
    args = parser.parse_args()
    packages, binaries = args.packages.resolve(), args.bin.resolve()
    suffix = ".exe" if os.name == "nt" else ""
    lean, checker = (str(binaries / (name + suffix)) for name in ("lean", "leanchecker"))
    assert hashlib.sha256((HERE / "TwistedCount.lean").read_bytes()).hexdigest() == BASE_SHA
    assert run(["git", "rev-parse", "HEAD"], packages / "mathlib", os.environ) == MATHLIB_PIN
    libs = sorted(packages.glob("*/.lake/build/lib/lean"))
    with tempfile.TemporaryDirectory(prefix="farey-orbit-seven-") as tmp:
        work = Path(tmp)
        env = {**os.environ, "PATH": str(binaries) + os.pathsep + os.environ["PATH"],
               "LEAN_PATH": os.pathsep.join(map(str, [work, *libs]))}
        version = run([lean, "--version"], work, env)
        assert "version 4.35.0" in version, version
        log = [version, "Mathlib " + MATHLIB_PIN]
        exports = []
        for module in MODULES:
            name = module + ".lean"
            shutil.copyfile(HERE / name, work / name)
            source = (work / name).read_text(encoding="utf-8-sig")
            run([lean, "-j2", "-DwarningAsError=true", "-o", module + ".olean", name], work, env)
            log.append(f"compile {module}: PASS")
            print(log[-1], flush=True)
            if module != "TwistedCount":
                namespace = re.search(r"^namespace (\w+)", source, re.M)[1]
                for ident in re.findall(r"^(?:theorem|lemma) (\w+)", source, re.M):
                    exports.append(namespace + "." + ident)
        audit = ["import FareyOrbitPhasors", "import FareyQuadraticProjection",
                 *("#print axioms " + ident for ident in exports)]
        (work / "Audit.lean").write_text("\n".join(audit) + "\n", encoding="utf-8")
        report = run([lean, "Audit.lean"], work, env)
        standard = {"propext", "Classical.choice", "Quot.sound"}
        for ident in exports:
            match = re.search(re.escape("'" + ident + "'") +
                              r" (?:does not depend on any axioms|depends on axioms: \[([^\]]*)\])", report)
            assert match, ident
            used = {val.strip() for val in (match[1] or "").split(",") if val.strip()}
            assert used <= standard, (ident, used)
        log += [f"{len(exports)} public theorem axiom checks passed.", report]
        for module in MODULES:
            result = run([checker, module], work, env)
            log.extend([f"leanchecker {module}: PASS", result])
            print(log[-2], flush=True)
        (HERE / "REPLAY.log").write_text("\n".join(log) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
