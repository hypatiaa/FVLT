# Portable verification runtimes

Use Node.js with the built-in APIs required by these scripts (Node 20 or later recommended), Python >= 3.9 with Draft 2020-12 `jsonschema`, and Playwright with an installed Chromium executable for browser checks. The recorded builder run uses Node 24.13.0, Python 3.12.14, jsonschema 4.26.0 and Playwright 1.61.1. Other installations must pass the capability probes and verification suites; these versions are provenance, not a portability claim for every version.

Python discovery tries an explicit `BSD_AUDIT_PYTHON`, otherwise active virtual/Conda environments, project/ancestor `.venv`, `venv` and `.bsd-audit-venv`, then PATH `python3`/`python` and the Windows `py -3` launcher. A candidate must import jsonschema and support Draft 2020-12. The resolved `sys.executable` is passed into the scratch workers. No default path points to a particular user's home or another project's vendor directory.

One setup route, performed by the auditor before verification, is:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r path/to/package/requirements-verification.txt
npm install --no-save playwright@1.61.1
npx playwright install chromium
node path/to/package/runtime-discovery.cjs
```

Create the environment in a workspace/ancestor directory, outside an immutable audit package. On POSIX, the environment's Python is `.venv/bin/python`. If Python is not on PATH, use an installed interpreter's executable to create the environment. Installation commands require the usual network access; the verifier never runs them.

| Optional variable | Meaning |
|---|---|
| BSD_AUDIT_PYTHON | Python executable; specify a path, not shell flags. A failed explicit override is an error. |
| BSD_SCHEMA_PYTHON_VENDOR | Explicit directory inserted into Python's import path. There is no default vendor path. A nonexistent directory is an error. |
| BSD_AUDIT_PLAYWRIGHT | Playwright module path or resolvable module name. Otherwise Node resolves `playwright` from the project and its ancestors. |
| BSD_AUDIT_CHROMIUM | Installed Chromium executable. Otherwise use the executable associated with the resolved Playwright installation. |

`BSD_AUDIT_RESOLVED_PYTHON` and `BSD_AUDIT_PLAYWRIGHT_MODULE` are internal worker bindings set by the runner. Do not configure them as substitutes for the public overrides. Commands are launched as argument arrays, so paths containing spaces do not need embedded quote characters. Bytecode writing is disabled during verification.

The scratch receipt records the chosen executable/module, Python and jsonschema versions, discovery attempts, Playwright version and browser executable. Missing capabilities fail explicitly and leave a failed receipt with the source-integrity result. A version/path receipt identifies the local runtime; it is not a cryptographic attestation of the runtime distribution. A production certificate backend must additionally pin its distribution and proof settings as specified in the implementation plan.

During the v0.2 builder run, package downloads were unavailable. A project `.bsd-audit-venv` was created outside the package using an existing Python installation, then populated with already-installed local jsonschema dependencies (jsonschema 4.26.0, attrs 26.1.0, jsonschema-specifications 2025.9.1, referencing 0.37.0, rpds-py 2026.6.3 and typing-extensions 4.16.0). Those files came from the existing `TARGET_PAIR_WORKSPACE_v0_3_20260906/tests/vendor` directory without modifying it. This was a one-time environment bootstrap; neither discovery nor the checker depends on that project path. Version 0.3 reuses that project environment through the same unchanged capability discovery. Its own receipt records the runtimes used for its ten suites.
