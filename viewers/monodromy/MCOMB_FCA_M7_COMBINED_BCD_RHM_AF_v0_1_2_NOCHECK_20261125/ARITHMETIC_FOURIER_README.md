# Arithmetic–Fourier panel v0.1 (builder candidate)

Package `MCOMB_FCA_M7_COMBINED_BCD_AF_v0_1_20261001`. Builder candidate only: nothing here is accepted, sealed or passed. A separate verifier, the oversight seat and Astra come after the builder.

**Credit.** Purpose and atom reading: saphir. Schema handoff, panel reviews and audits: Astra. Schema construction: Fable (Claude). Panel handoff: the handoff drafter (Claude) under the oversight seat. Build and checks: the builder (Claude).

## What changed from the accepted combined B/C/D package

- `monodromy-31-linked-reduction.html`: the accepted viewer `3cd1352f0b5846fb22f673dffae627f1191a00601c611128bb661224a7d1da9c` plus ONE block between `<!-- ARITHMETIC_FOURIER_V0_1_BEGIN -->` and `<!-- ARITHMETIC_FOURIER_V0_1_END -->`, inserted immediately before `</body>`. Removing the block (markers inclusive, plus its final LF) recovers `3cd1352f0b5846fb22f673dffae627f1191a00601c611128bb661224a7d1da9c` byte for byte. New viewer SHA-256: `bfcbd55cb5859b80a9d9a731aa5915bfbb6c55bfec44dfa4ce0d521b928897b2`.
- `BUILD_PINS.json`: one new section `arithmeticFourier` and the new value of `viewerSha256`; every other key is unchanged.
- Added: `afp-core.js` (BigInt port of af_reference 0.1.1), `afp-worker.js` (worker glue), `afp-ui.js` (panel), `afp-sources-data.js` (generated: the five registered snapshots, base64), this README.
- `server.cjs` is byte-identical (`20caf5398cef57f988700adc27c8cdbe49dbe538d7e570ebfa482926d8424311`). Every other inherited file is byte-identical.

## Identity

`hostSha256 = sha256(canonical(identity))` = `b5e2c961a55b98645397ebd29e07601113aaa0f55dde28db239df6397005d34b` (identity schema `MCOMB_ARITHMETIC_FOURIER_HOST_IDENTITY_V1`, in `BUILD_PINS.json` → `arithmeticFourier.identity`). Module digests: `afp-core.js` `163aa1a5949f6eff371407f496f208b10dc548db962740dce49192fe284582cc`, `afp-sources-data.js` `dca5361aeae2890e34af8bc8454245a433cb986da27d044d792a963668838477`, `afp-worker.js` `64c19351c56e722cdc6e3b2de28835938891a67a6bb4225093a5d62bf117d16b`, `afp-ui.js` `df2c587239be144d7e857332ae4d0498ea9d5a5439f6a062edf9c3c560681d62`, `embedded-worker-source` `fe83fd3ecc91261e25cf464553e93b8bb0aad6719933f46cd0bb2bc90200baa7`.

## Use

Served mode (the exact curve binding needs the host's T4 replay): `node server.cjs` in this folder starts the package server on a random 127.0.0.1 port and prints the URL. Under `file://` the panel opens, shows `CURVE_RECORD_UNAVAILABLE` with its reason, keeps the atom and origin controls usable and offers no export (Astra's decision on O1). Toggle: the "Arithmetic–Fourier" micro-button.

The panel shows the record scope text and its boundary: these rows are finite local facts for one exact model and one atom; they do not enter the BSD leading-term comparison and they say nothing about RH.

Governing documents: `ARITHMETIC_FOURIER_PANEL_HANDOFF_v0_1_1_20261001/` (MANIFEST `2bc1f181ec2ce66f1ba0f50650c8e55b26ef6665945a35a92d22e70a455a8516`) with erratum E1 (`526a32f5054da2d6316291309ffd6288bd826ba286a12cef097fa8fa2bc25018`). Build, tests and evidence: `ARITHMETIC_FOURIER_PANEL_WORK_v0_1_20261001/`.
