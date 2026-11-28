"""Rebuild every module, check its local dependencies, and independently replay its kernel declarations."""
import argparse
import hashlib
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


HERE = Path(__file__).resolve().parent
MATHLIB = "56a005855ea17e0b0958f73ec801ae140b0a1679"
TWISTED_COUNT = "25b6b49f5b1e14a170dfcae5d6c82fc98a6cc746bdb6fbc745dc7fa4fd2aeb60"
MODULES = ("TwistedCount", "PrimeQuadraticPeriods", "FareyPrimeCharacterEnergy",
           "FareyPrimeCharacterFormula", "FareyPrimeCharacterParity")
ALLOWED_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}


def run(cmd, cwd, env):
    result = subprocess.run(cmd, cwd=cwd, env=env, encoding="utf-8", errors="replace",
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if result.returncode:
        raise RuntimeError(f"{cmd} failed\n{result.stdout}")
    return result.stdout.strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--packages", type=Path, default=Path.home() /
                        "rule30_prize_research_2026_10_26/Rule30PrizeKit/.lake/packages")
    parser.add_argument("--bin", type=Path, default=Path.home() /
                        ".elan/toolchains/leanprover--lean4---v4.35.0/bin")
    args = parser.parse_args()
    packages, binaries = args.packages.resolve(), args.bin.resolve()
    suffix = ".exe" if os.name == "nt" else ""
    lean, checker = (str(binaries / (name + suffix)) for name in ("lean", "leanchecker"))
    assert run(["git", "rev-parse", "HEAD"], packages / "mathlib", os.environ) == MATHLIB
    assert hashlib.sha256((HERE / "TwistedCount.lean").read_bytes()).hexdigest() == TWISTED_COUNT
    with tempfile.TemporaryDirectory(prefix="farey-prime-chars-") as temp:
        work = Path(temp)
        libs = sorted(packages.glob("*/.lake/build/lib/lean"))
        env = {**os.environ, "PATH": str(binaries) + os.pathsep + os.environ["PATH"],
               "LEAN_PATH": os.pathsep.join(map(str, [work, *libs]))}
        version = run([lean, "--version"], work, env)
        assert "version 4.35.0" in version
        log = [version, "Mathlib " + MATHLIB]
        exports = []
        for module in MODULES:
            source = HERE / (module + ".lean")
            digest = hashlib.sha256(source.read_bytes()).hexdigest()
            shutil.copyfile(source, work / source.name)
            run([lean, "-j2", "-DwarningAsError=true", "-o", module + ".olean", source.name], work, env)
            log.append(f"compile {module} PASS SHA-256 {digest}")
            if module != "TwistedCount":
                content = source.read_text(encoding="utf-8-sig")
                ns = re.search(r"^namespace (\w+)$", content, re.M).group(1)
                exports.extend(ns + "." + name for name in
                               re.findall(r"^(?:theorem|lemma) (\w+)\b", content, re.M))
        audit = ["import " + module for module in MODULES]
        audit.extend("#print axioms " + name for name in exports)
        (work / "Audit.lean").write_text("\n".join(audit) + "\n", encoding="utf-8")
        result = run([lean, "Audit.lean"], work, env)
        for name in exports:
            match = re.search(re.escape("'" + name + "'") +
                              r" (?:does not depend on any axioms|depends on axioms: \[([^\]]*)\])", result)
            assert match, name
            used = {s.strip() for s in (match[1] or "").split(",") if s.strip()}
            assert used <= ALLOWED_AXIOMS, (name, used)
        log += [f"{len(exports)} public theorem axiom checks passed.", result]
        for module in MODULES:
            run([checker, module], work, env)
            log.append(f"leanchecker {module} PASS")
        print("\n".join(log))


if __name__ == "__main__":
    main()
