"""Run on Nucleus with its pinned Lean and Mathlib. Rebuild in a fresh directory."""
from pathlib import Path
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile

src = Path(__file__).resolve().parent
modules = sys.argv[1:] or ["FareyMerge", "GarciaPairs", "LocalPaths", "LogSurplus"]
bin_dir = Path.home() / ".elan/toolchains/leanprover--lean4---v4.35.0/bin"
packages = Path.home() / "rule30_prize_research_2026_10_26/Rule30PrizeKit/.lake/packages"
pin = subprocess.check_output(["git", "-C", packages/"mathlib", "rev-parse", "HEAD"], text=True).strip()
assert pin == "56a005855ea17e0b0958f73ec801ae140b0a1679"
print("Mathlib", pin, flush=True)
with tempfile.TemporaryDirectory() as folder:
    work = Path(folder)
    env = dict(os.environ, PATH=str(bin_dir)+":"+os.environ["PATH"],
               LEAN_PATH=":".join(map(str,[work,*packages.glob("*/.lake/build/lib/lean")])))
    def run(*args):
        proc = subprocess.run(args, cwd=work, env=env, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, text=True)
        print(proc.stdout, end="", flush=True)
        proc.check_returncode()
        return proc.stdout
    run("lean", "--version")
    for mod in modules:
        filename = mod+".lean"
        f = work/filename
        shutil.copyfile(src/filename, f)
        digest = hashlib.sha256(f.read_bytes()).hexdigest()
        run("lean", "-j2", "-DwarningAsError=true", "-o", mod+".olean", filename)
        print(f"compile {mod} PASS SHA-256 {digest}", flush=True)
        run("leanchecker", mod)
        print(f"leanchecker {mod}: PASS", flush=True)
        ns = re.search(r"^namespace (\w+)", f.read_text(), re.M)[1]
        names = re.findall(r"^theorem (\w+)", f.read_text(), re.M)
        (work/"Audit.lean").write_text("import "+mod+"\n"+"\n".join(
            "#print axioms "+ns+"."+n for n in names)+"\n")
        log = run("lean", "Audit.lean")
        for n in names:
            m = re.search(re.escape("'"+ns+"."+n+"'")+r" (?:does not depend on any axioms|depends on axioms: \[([^\]]*)\])", log)
            assert m and set(filter(None, (m[1] or "").split(", "))) <= {"propext","Classical.choice","Quot.sound"}
        print("PASS", mod, len(names), flush=True)
