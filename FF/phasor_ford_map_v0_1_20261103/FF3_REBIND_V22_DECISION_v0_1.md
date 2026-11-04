# FF-3 rebinding to library v22: decision v0.1

2026-11-04. Skeleton (Claude Opus 5.5). This supplements `FF3_FREEZE_DECISION_v0_1.md` (`9e7d01b9...`, bus #1511). The routine process is settled under saphir's FF-3 go (#1509) and "Yes, review it".

**Why.** The FF-3 freeze pins library v21, and its runner `f9acf65a...` refuses to run when a newer version exists. Shared library **v22** (the kit separation, READY in #1512) is now the latest. Under #1511 that case returns for review, and this is that review.

**What v22 changed for FF-3:** nothing that FF-3 depends on. I checked on nucleus:
- the six inherited Farey/Ford sources (`FVLTFareyArithmeticCompletionV1`, `FVLTFareyCertificatesV1`, `FVLTFareyContactV1`, `FVLTFordExactCoordinatesV1`, `FVLTFordGeometryV1`, `FVLTFordRationalV1`) are byte-identical in v21 and v22;
- `lake-manifest.json` is identical (`1f0e0c1c...`), so Mathlib is unchanged;
- `lean-toolchain` is unchanged (`ca5f1f60...`);
- v22 only moved 14 kit research files, which FF-3 does not import, and added their build roots.

**Decision: ACCEPT an additive successor runner and template, without a further skeleton turn, if they differ from `f9acf65a...` and `c8a12220...` only in these fields:**
- **Runner:**
  - `LIB` becomes `/home/saphir/rule30_theorem_library/v22`;
  - the assertion `latest == 21` becomes `latest == 22`, with its message unchanged in meaning;
  - the version string in the docstring.
- **Template:**
  - `library` becomes the v22 path;
  - `library_expected` becomes the v22 pins:
    - `SHA256SUMS` `c7b6b52eb173959f360011ddbabd65f5828c8f788cd1b52a066749e2ae567505`;
    - `LIBRARY_MANIFEST.json` `47b72d67db15badcf4da63c8ded7c9e7a71e12fcb5e8bd1cf69b341d3b4ff92c`;
    - `lake-manifest.json` `1f0e0c1c0a06e2a9ecc117aed82f7a8ee62b418235e10686d3bda2d6986ea527`;
    - `lakefile.toml` `3aabc87bcb333679e16900efa8a0d26b1fa18b6995c7da6484ff996a14350be3`;
    - `lean-toolchain` `ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c`;
  - `runner_sha256` becomes the successor runner's hash.

**Conditions:**
- Post both successor files with their hashes and a script-produced diff against the originals before any binding.
- The definitions `3c606060...`, the headers `b8a052dc...`, the target index, the checker `9c6f2ac1...` and every limit stay unchanged.
- All other #1511 rules apply: all-match binding on posting, proof-only retries and the final independent audit.
- A library newer than v22 again returns for review.
