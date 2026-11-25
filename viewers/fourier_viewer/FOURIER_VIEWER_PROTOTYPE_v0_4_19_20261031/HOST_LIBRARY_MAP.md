# Host library map: breaking the frozen FVLT Fourier host into plug-in libraries

Date: 2026-10-13. Read-only analysis for the Fourier viewer prototype v0.1 (SCHEMA.md and addenda 1 to 4). No code was extracted or ported. The frozen host was only read.

**Input (frozen, never edited):** `C:/Users/robin/s6_atom/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html`, 2,694,022 bytes, 25,364 lines. In this document "L" is a line number in that file and "bN" is script block N from section 1.

**Method.** Every count below was produced by node scripts (kept in the session scratchpad, not in the project). The scripts do four things.
1. Split the file at `<script>` tags and at the `<!-- X_BEGIN/END -->` markers.
2. Mask comments, strings, regex literals and template text, then track brace depth to find every named function (declarations, plus `const x = function` or arrow bindings), with exact line ranges.
3. Flag each function lexically for DOM use (`document`, `window`, `getContext`, `addEventListener`, `.style`, `innerHTML` and similar), for `state.` reads and writes, for float tokens and for BigInt tokens. Name matching builds the call graph.
4. Test headless loadability by feeding the extracted source text to `vm.Script` in an empty sandbox. The frozen file was never opened for writing.

Register tags in the function lists are lexical heuristics, not proofs: `flt` = Math.sin/cos/sqrt/log/pow/atan/hypot/PI, `Number(...)`, `parseFloat`, `toFixed` or a decimal literal; `big` = BigInt literal or `BigInt`; `mix` = both; `DOM` = touches the document or canvas; `Sr` / `Srw` = reads / reads and writes the host `state` object. `Number(` on a BigInt counts as `flt`, so `flt` over-reports. Anything not backed by a script run is marked INFERRED.

---

## 1. Script inventory

The file has **31 `<script>` blocks**: 28 JavaScript and 3 `application/json` data blocks (b9, b18, b22). There are **24 distinct HTML-comment marker names** (not 17). Seven of them (b1 to b7, the MCOMB_CAYLEY_V1 exact, core, spectrum, capture, packet, store and graph parts) sit at the top of the file, L4 to L2671, before the main script. The rest follow the main script. A further 5 marker pairs are JavaScript comments inside b10: PLANE_CLIFFORD_LIFT_CORE_V2 (L4647 to L5342), PLANE_CLIFFORD_MERIDIONAL_SWEEP_V1 (L5424 to L5671), SELECTABLE_SHELL_LIFT_ADAPTER_V1 (L5673 to L5742), SIGNED_SPIN_LIFT_ADAPTER_V1 (L5744 to L6103) and ELLIPTIC_BRIDGE_V27 (L16100 to L16406).

| # | lines | bytes | kind | marker (HTML comment) | named fns (any depth) | fns touching DOM | note |
|---|---|---|---|---|---|---|---|
| 1 | 5–54 | 5,242 | JS | MCOMB_CAYLEY_V1_exact | 24 | 0 | Cayley exact arithmetic C |
| 2 | 58–77 | 4,558 | JS | MCOMB_CAYLEY_V1_core | 6 | 0 | Cayley core |
| 3 | 81–101 | 1,396 | JS | MCOMB_CAYLEY_V1_spectrum | 1 | 0 | Cayley spectrum job |
| 4 | 105–158 | 4,631 | JS | MCOMB_CAYLEY_V1_capture | 3 | 0 | Cayley capture |
| 5 | 162–184 | 3,366 | JS | MCOMB_CAYLEY_V1_packet | 4 | 0 | Cayley packet |
| 6 | 188–222 | 4,310 | JS | MCOMB_CAYLEY_V1_store | 0 | 0 | Cayley store |
| 7 | 2644–2670 | 2,945 | JS | MCOMB_CAYLEY_V1_graph | 3 | 0 | Cayley graph model |
| 8 | 3330–4527 | 55,858 | JS | (none) | 56 | 0 | Alpoge rank-4 exact engine (out of scope) |
| 9 | 4528–4644 | 2,602 | JSON data | (none) | - | - | JSON fixture (rank-4) |
| 10 | 4645–16441 | 535,727 | JS | (none) | 475 | 85 | MAIN monolith (host) |
| 11 | 16445–16672 | 37,495 | JS | BSD_CURVE_RECORD_V1 | 46 | 3 | BSD curve record (UMD) |
| 12 | 16676–16718 | 3,534 | JS | PANEL_CONTROLS_V1 | 3 | 2 | display-only panel disclosures |
| 13 | 16722–16929 | 36,212 | JS | MCOMB_ELLIPTIC_LINK_V1 | 44 | 7 | mcomb to elliptic link (UMD) |
| 14 | 16933–17020 | 10,630 | JS | MCOMB_CONNECTED_PANELS_V1 | 14 | 6 | connected panels |
| 15 | 17024–17192 | 39,545 | JS | MCOMB_CARRIER_ADDITION_V1 | 41 | 11 | carrier addition (UMD) |
| 16 | 17196–17212 | 1,152 | JS | BSD_REDUCTION_AUDIT_V1 | 1 | 1 | display correction |
| 17 | 17216–17249 | 6,184 | JS | MCOMB_CAYLEY_V1_host | 6 | 4 | Cayley host adapter (DOM) |
| 18 | 17251–17251 | 11,629 | JSON data | (none) | - | - | JSON: Cayley worker source |
| 19 | 17253–17276 | 3,627 | JS | MCOMB_CAYLEY_V1_camera | 5 | 1 | Cayley camera (DOM) |
| 20 | 17280–17408 | 23,781 | JS | MCOMB_CAYLEY_V1_inspector | 19 | 9 | Cayley inspector UI |
| 21 | 17412–17412 | 8,638 | JS | BSD_LINKED_VIEW_V1 | 0 | 0 | build pins only |
| 22 | 17413–17413 | 385,952 | JSON data | BSD_LINKED_VIEW_V1 | - | - | JSON: bsd generator bundle (386 KB) |
| 23 | 17414–18907 | 648,356 | JS | BSD_LINKED_VIEW_V1 | 393 | 71 | BSD linked view bundle (M3 to M7 cores, T-chain, U1/P1/PT1, UI) |
| 24 | 18909–19031 | 20,492 | JS | (none) | 23 | 13 | M7 diagram cameras, display-only |
| 25 | 19033–19928 | 71,613 | JS | CONTACT_SWEEP_V0_1_1 | 90 | 13 | contact sweep (core + validate + UI + worker string) |
| 26 | 19931–20624 | 59,256 | JS | BASEL_LINK_V0_1_2 | 80 | 14 | Basel link (core + UI) |
| 27 | 20627–21087 | 34,773 | JS | COMBINED_BCD_V0_1_RECIPROCAL | 41 | 6 | reciprocal link (record + UI) |
| 28 | 21090–21924 | 103,600 | JS | COMBINED_BCD_V0_1_SHELL_PRIME_COUNT | 74 | 4 | shell prime count (core + UI + worker string) |
| 29 | 21927–23121 | 105,585 | JS | COMBINED_BCD_V0_1_TOOTH_CONTACT | 126 | 13 | tooth contact (core + validate + UI + worker string) |
| 30 | 23124–23876 | 74,879 | JS | RH_MARGIN_V0_1 | 78 | 10 | RH margin (core + UI + worker string) |
| 31 | 23879–25360 | 231,810 | JS | ARITHMETIC_FOURIER_V0_1 | 117 | 9 | arithmetic-Fourier (data + core + UI + worker string) |


Notes on the inventory:
- **b10 is the monolith**: L4645 to L16441, 535,727 bytes, 11,797 lines. It holds **475 named functions**: 427 `function` declarations and 48 arrow or function-expression bindings. Of the 427 declarations, 271 are at depth 0, 136 sit inside 10 IIFE module objects, and 20 are nested deeper. The "about 427 functions" in the brief matches the declaration count. The depth-0 census found 366 items: 271 functions and 95 value bindings (constants, caches, DOM handles, the `state` object and the 10 module objects). It also missed 15 second declarators in multi-name statements, such as `T_MAX` in `const T_MIN = -100, T_MAX = 100;` at L13575 (found by a separate scan).
- b8 and b9 (L3330 to L4644) are the Alpoge rank-4 engine and fixture. Unmarked. Per addendum 4 they go to the separate Rank-4 viewer.
- b22 (386 KB) is a JSON bundle (the BSD generator). b23 (648 KB) is the BSD linked-view bundle. It also carries an in-page CommonJS registry: the `FACTORIES["/pt1/...cjs"]` source copies at L17436 to L17870.
- b24 is unmarked but sits after BSD_LINKED_VIEW_V1 (M7 display cameras, display-only).
- Block 10 contains 388 `getElementById` calls and 127 top-level event-binding lines outside any function (see section 3).

### 1a. The marker blocks are inlined copies of the sibling source files

The host folder holds 105 `.js` and `.cjs` files. Of 68 non-test, non-tool sibling sources, **63 are byte-contained in the host** (56 whole-file matches, 7 embedded as escaped worker-source strings) and 5 are NOT contained byte-for-byte: `contact-core.js`, `contact-validate.js`, `contact-ui.js`, `basel-core.js`, `basel-link-ui.js`. For those 5, sampled lines match 100% inside b25 and b26 (so the inline copies differ only slightly, INFERRED), and the line ranges used below for contact-core and basel-core are approximate (INFERRED). The folder also has 26 `test-*.cjs` files. Where a sibling file is contained, that file is a ready-made, DOM-free-loadable original that a parity test can compare against, in addition to the extracted text.

| sibling source file (read-only reference folder) | match mode | in host | named fns | touching DOM | float-lexical fns | BigInt-lexical fns |
|---|---|---|---|---|---|---|
| adapter.js | escaped-string | b22 L17413–17413 | 0 | 0 | 0 | 0 |
| generator-worker.js | whole | b22 L17413–17413 | 0 | 0 | 0 | 0 |
| sha256.js | whole | b23 L17415–17424 | 2 | 0 | 1 | 1 |
| strict-json.js | whole | b23 L17426–17434 | 4 | 0 | 0 | 0 |
| pt1-group.cjs | whole | b23 L17604–17631 | 17 | 0 | 2 | 2 |
| pt1-replay.cjs | whole | b23 L17635–17680 | 6 | 0 | 0 | 1 |
| pt1-producer.cjs | whole | b23 L17684–17702 | 2 | 0 | 0 | 1 |
| u1-interval.cjs | whole | b23 L17718–17755 | 19 | 0 | 0 | 11 |
| u1-engine.cjs | whole | b23 L17759–17784 | 6 | 0 | 1 | 5 |
| u1-replay.cjs | whole | b23 L17788–17797 | 6 | 0 | 0 | 0 |
| p1-engine.cjs | whole | b23 L17801–17840 | 5 | 0 | 0 | 3 |
| p1-replay.cjs | whole | b23 L17844–17868 | 5 | 0 | 0 | 1 |
| loader.js | whole | b23 L17871–17885 | 4 | 0 | 0 | 0 |
| pt1-browser-api.js | whole | b23 L17887–17893 | 0 | 0 | 0 | 0 |
| provenance.js | whole | b23 L17908–17930 | 4 | 0 | 1 | 0 |
| register-model.js | whole | b23 L17932–17976 | 2 | 0 | 0 | 1 |
| register-ui.js | whole | b23 L17978–18022 | 3 | 3 | 0 | 2 |
| pt1-linked.js | whole | b23 L18024–18039 | 6 | 5 | 0 | 0 |
| u1-linked.js | whole | b23 L18041–18051 | 7 | 5 | 0 | 0 |
| p1-linked.js | whole | b23 L18053–18072 | 6 | 5 | 2 | 2 |
| client.js | whole | b23 L18075–18146 | 22 | 8 | 1 | 0 |
| spectral.js | whole | b23 L18148–18165 | 1 | 0 | 1 | 1 |
| spectral-ui.js | whole | b23 L18167–18173 | 4 | 2 | 0 | 0 |
| family-model.js | whole | b23 L18175–18203 | 9 | 0 | 2 | 3 |
| family-ui.js | whole | b23 L18205–18243 | 8 | 4 | 1 | 0 |
| plot-interaction.js | whole | b23 L18245–18397 | 33 | 9 | 11 | 0 |
| atom-core.js | whole | b23 L18400–18451 | 27 | 0 | 8 | 19 |
| atom-packet.js | whole | b23 L18453–18460 | 4 | 0 | 0 | 0 |
| walk-core.js | whole | b23 L18463–18531 | 13 | 0 | 4 | 6 |
| walk-host.js | whole | b23 L18533–18553 | 2 | 0 | 0 | 1 |
| atom-ui.js | whole | b23 L18555–18632 | 23 | 10 | 4 | 2 |
| structure-core.js | whole | b23 L18635–18705 | 19 | 0 | 2 | 9 |
| structure-packet.js | whole | b23 L18707–18719 | 4 | 0 | 0 | 0 |
| structure-worker.js | escaped-string | b23 L18721–18721 | 0 | 0 | 0 | 0 |
| structure-ui.js | whole | b23 L18722–18769 | 18 | 6 | 1 | 0 |
| history-core.js | whole | b23 L18771–18791 | 6 | 0 | 1 | 5 |
| history-packet.js | whole | b23 L18793–18802 | 4 | 0 | 0 | 0 |
| history-worker.js | whole | b23 L18804–18804 | 0 | 0 | 0 | 0 |
| history-ui.js | whole | b23 L18805–18831 | 14 | 3 | 1 | 0 |
| fca-core.js | whole | b23 L18833–18865 | 21 | 6 | 4 | 16 |
| fca-packet.js | whole | b23 L18867–18870 | 2 | 0 | 1 | 0 |
| fca-worker.js | whole | b23 L18872–18872 | 0 | 0 | 0 | 0 |
| fca-ui.js | whole | b23 L18873–18905 | 15 | 5 | 3 | 4 |
| camera-ui.js | whole | b24 L18910–18951 | 9 | 4 | 2 | 0 |
| crystal-placement.js | whole | b24 L18953–18972 | 1 | 0 | 1 | 0 |
| fca-3d-ui.js | whole | b24 L18974–19028 | 13 | 9 | 4 | 2 |
| contact-worker.js | escaped-string | b25 L19035–19035 | 0 | 0 | 0 | 0 |
| reciprocal-record.js | whole | b27 L20629–20875 | 28 | 0 | 0 | 6 |
| reciprocal-link-ui.js | whole | b27 L20877–21085 | 13 | 6 | 0 | 1 |
| spc-worker.js | escaped-string | b28 L21092–21092 | 0 | 0 | 0 | 0 |
| spc-core.js | whole | b28 L21093–21430 | 36 | 0 | 0 | 10 |
| spc-ui.js | whole | b28 L21432–21922 | 38 | 4 | 0 | 0 |
| tooth-worker.js | escaped-string | b29 L21929–21929 | 0 | 0 | 0 | 0 |
| tooth-core.js | whole | b29 L21930–22221 | 36 | 0 | 1 | 12 |
| tooth-validate.js | whole | b29 L22223–22436 | 22 | 0 | 0 | 1 |
| tooth-ui.js | whole | b29 L22438–23119 | 68 | 13 | 11 | 9 |
| rhm-worker.js | escaped-string | b30 L23126–23126 | 0 | 0 | 0 | 0 |
| rhm-core.js | whole | b30 L23127–23502 | 51 | 0 | 1 | 31 |
| rhm-ui.js | whole | b30 L23504–23874 | 27 | 10 | 0 | 2 |
| afp-sources-data.js | whole | b31 L23881–23883 | 0 | 0 | 0 | 0 |
| afp-worker.js | escaped-string | b31 L23884–23884 | 0 | 0 | 0 | 0 |
| afp-core.js | whole | b31 L23885–24869 | 75 | 1 | 9 | 28 |
| afp-ui.js | whole | b31 L24870–25359 | 42 | 8 | 0 | 1 |

---

## 2. Library candidates

The `state` object is at L7440 to L7498. It is the single shared mutable store of the host, a plain object literal with no DOM. It carries **two registers side by side**: `t1`, `t2` and `s` are Numbers, "drawing projections", next to the authoritative exact strings `t1Exact`, `t2Exact` and `sExact`. The prototype's shared-state schema replaces this object. The host's seam to the instruments is `liftSourceSnapshot()` (L8813 to L8833).

### 2A. exact-lib candidates (duplicated helpers)

Counts are of definitions found by the scripted walk (`bN:line`). Semantic equivalence between copies is INFERRED until a cross-copy property test is run (see parity note below the table). Rows list every copy found.

| helper family | copies | where |
|---|---|---|
| `gcd` (+ `gcdBigInt`, `gcdNumber`) | **16** (14 named `gcd`, 2 variants) | b1:12; b8:3346; b10:6244; b10:11378 (inside OrbitPointIndexV26); b10:16107 (inside EllipticModelV27); b15:17164; b23:17443, 18178; b25:19066; b26:19966; b27:20662; b29:21957; b30:23145; b31:23910; variants `gcdBigInt` b10:4664 (inside PlaneCliffordLiftCore), `gcdNumber` b10:8295 (inside PlaneCliffordActualOrbitGuideV1) |
| `lcm` | 3 | b8:3357; b10:6358; b23:18406 |
| `abs` for BigInt | 8 | `abs` b1:11, b8:3344, b10:16106, b26:19965, b29:21956, b30:23144; `absBig` b28:21185; `absBigInt` b10:4662 |
| floor/ceil division and modulo | 9 | `mod` b1:23, b10:11383, b11:16482; `nonnegativeModulo` b10:6573; `floorDiv` b26:19977, b31:23907; `ceilDiv` b26:19981; `fdiv`, `cdiv` b30:23159 to 23160 |
| modular power | 3 | `modPowBigInt` b10:6149; `modpow` b27:20676; `modPowBig` b28:21198 |
| integer square root | 6 | `sqrtInt` b10:16124, b13:16784, b23:17624; `sqrtQ` b23:17625; `isqrt` b23:17724; `sqrt` b23:17730 |
| primality | 5 true tests + 4 `prime` validators | `isPrime` b10:6122 (Number-based), b27:20679; `isPrimeSafeBigInt` b10:6161; `isPrimeBig` b28:21204; `_is_prime` b31:24098; `prime` b11:16481, b23:17502, 17627, 18407 |
| factoring, totient, Moebius | about 14 | `factorSafePositiveInteger` b10:6453; `euler` b10:6478; `moebius` b10:6526; `ramanujanSum` b10:6541; `factorize` b26:20235; `factor` b23:18408; `factorialFactors` b26:20006; `primeDivisorSetBig` b28:21188; `eulerTotientBig` b28:21197; `factor_in_domain` b30:23395; `n_over_phi` b30:23413; `factor_over` b31:24310; `factorial` x3 (b10:6492, b25:19093, b29:21989); `factorialBig` x2 (b28:21187, b30:23446) |
| rational objects `{n,d}` | `rat` x7, `rational` x5, `frac`/`fraction` x3 | `rat` b1:15, b10:11379 (OrbitPointIndexV26), b10:16108 (EllipticModelV27), b23:17444, b25:19278, b27:20669, b29:22258; `rational` b8:3483, b11:16473, b23:18468, b25:19079, b29:21974; `frac` b26:19967; `fraction` b23:18179, 18252 |
| rational arithmetic | add x14, mul x7, div x5, cmp x5, compare x7, sub x2, neg x2, same x5, eq x2 | one set per block, for example `add` at b1:22, b8:3407, b10:11382, b10:16115, b11:16470, b23:17447, b26:19973, b30:23154 (full list is in the scripted output) |
| rational parse and reduce | about 14 | `parseCanonicalRationalBigInt` b10:4688; `reduceRationalBigInt` b10:4675 (both in PlaneCliffordLiftCore); `parseSignedCanonicalRationalBigInt` b10:5752; `signedRationalText` b10:5768; `parseGearboxRational` b10:5780; `parseExactS` b10:6342; `normalizeFraction` b10:6247; `reduceExactPair` b10:6336; `decimalLiteralToFraction` b10:6256; `parseRationalText` b25:19096, b29:22000; `parseRat` b30:23487; `parseDec` b26:19988; `canonicalFraction` b28:21217 |
| canonical JSON | 14 | `canonical` b1:48, b11:16466, b23:17454, b25:19337, b29:22336, b31:24032; `canonicalStringify` b8:3785; `canonicalSerialize` b10:5078 (+ `normalizeJsonValue` b10:5055); `canonicalJson` b28:21357; `canonicalText` b27:20804, b30:23376; `canonicalBytes` b27:20809, b29:22205, b30:23377 |
| strict JSON (duplicate-key rejection) | 7 | `strictJSON` b23:17427 (=`strict-json.js`), b23:17707 and b23:17899 (two more copies inside the BSD bundle); `parseStrict` b27:20813, b28:21291; `strictParse` b29:22380; `strictUtf8` b31:23977 |
| SHA-256 | 3 pure-JS implementations + async `crypto.subtle` uses | `sha256Hex` b8:3789, b31:23921; `sha256` b23:17417 (=`sha256.js`, comment says "Synchronous SHA-256 for untrusted browser packet preparation only"); `crypto.subtle` tokens: b1 x1, b11 x1, b18 x1, b22 x3, b23 x5 |
| `fail(msg)` thrower | 17 | b1:10, b11:16462, b13:16728, b15:17030, b23:17442, 18405, 18467, 18638, 18774, b25:19267, 19605, b27:20815, b28:21298, b29:22246, 22382, 22716, b31:24813 |
| cyclotomic code | **no ring arithmetic**. Label strings, exponent-term lists and branch orders only | `stateCyclotomicField` b10:6365 to 6426 (builds the label string `Q(zeta_B)` and an exactness note, reads `state`, **mixed**: label only); `rootOrderHalfPi` b10:6360; `nextCombStop` branch order `ord = m/gcd(r,m)` b10:13401 to 13448; `assess` b23:18151 to 18163 (spectral.js: an exact multiset of zeta_q exponent/coefficient terms, **with a float evaluation tail at L18161** using `Math.cos/Math.sin`); `spectralOrders` b23:18444; `zetaComparison` b26:20042 and `Z` b26:20029 (exact Euler product Z_N(beta) as fractions, compared with a table of zeta(beta) enclosures) |

**Prototype status.** `exact-lib/exact.js` (87 lines) already carries gcd, rat, parse, parseInteger, parseProduct, canonical, parseStrict, utf8 and sha256.

**Registers.** All of these are exact BigInt, with these exceptions:
- `isPrime` b10:6122 and `gcdNumber` b10:8295 are Number-based;
- `modPowBigInt` and `isPrimeSafeBigInt` are BigInt with Number guards (INFERRED from the `B29` token count);
- `roundedOrNull` b10:14711 is float.

**Dependencies.** None among themselves, except that the host's exact-rational host functions (`parseSignedCanonicalRationalBigInt`, `signedRationalText`, `exportExactRational`, `reduceExactPair` and others) call `PlaneCliffordLiftCore.reduceRationalBigInt` and `parseCanonicalRationalBigInt` (scripted edge EXACT to CLIFFORD-CORE, 3 functions). So the BigInt-rational subset of PlaneCliffordLiftCore, L4662 to L4764, must be absorbed into exact-lib first.

**Shared state.** None.

**Existing tests.** Host: none for the helpers as such. Siblings: `test-core.worker.cjs`, `check-integrity.cjs` and the per-module `test-*.worker.cjs` suites exercise them indirectly (INFERRED from file names, not run).

**Frozen-source parity.** Two routes. (1) Cross-copy N-version parity: slice each of the 16 `gcd` copies (and each rational, canonical, strict-JSON and sha256 copy) by its line range, load them into separate `vm` contexts and run the same random inputs through all of them. This also exposes any copy that differs (for example, a Number-based copy past 2^53). (2) The UMD siblings `sha256.js`, `strict-json.js`, `afp-core.js` (exports `gcd`, `floorDiv`, `floorMod`, `sha256Hex` and more), `rhm-core.js` and `reciprocal-record.js` load headless with plain `require` (tested, section 2D).

### 2B. host-core candidates (the main script b10)

Headless loadability, **tested**: the 366 depth-0 items of b10 were cut out by line range and compiled in source order into one empty `vm` context (a `state` literal taken from L7440 to L7498). **289 loaded.** 75 were skipped because their source text mentions `document`, `window`, `localStorage`, `requestAnimationFrame`, `getContext`, `navigator`, `URL.createObjectURL` or `Blob`. Of the skipped 75, 60 are functions, and 15 are value bindings: DOM handles (the SVG and canvas elements), the OrbitPointIndexV26, AlpogeRank4BridgeV1 and EllipticModelV27 modules (EllipticModelV27 is pure at L16104 to L16233 and loads headless when cut at that range; its only `window` token is the word in an error message at L16178), and the self-check nodes. (291 items were attempted; the other 2 raised load-time errors because they call skipped DOM functions (`spectralGearboxSelfCheck` L16423, `monodromy20SelfCheck` L16429.) Smoke calls then ran headless: `combOffsets(5)`, `computeVernier(23,4,0.5)`, `stableGearboxAngle`, `gcd`, `nextCombStop`, `divisorsOnAxis`, `liftSourceSnapshot`, and `typeof` checks on `analyzeSpectralWilsonGearbox`, `analyzeIndependentWilsonCandidate`, `spreadFrameExact`, `HopfBaseDisplayV1`. All returned plausible values.

Function counts per group are for the 271 depth-0 functions of b10; module-internal functions are listed with each module. Lists are sorted by line.

#### HC-1 shell and phi3 (7 functions)
- **Covers:** selectedShellBase L6508–6510 [Sr]; selectedShellSpan L6511–6511; selectedShellDescription L6512–6517 [Sr]; selectedShellFileTag L6518–6522 [Sr]; currentN L7667–7669 [Sr]; invalidateShellCaches L13195–13202; parseDirectShell L13241–13247 [flt]. Also depth-0 values `getPhi` L6488, `euler` memo L6476, `FACTORIAL_N1_MIN/MAX` L6490 to 6491, `DIRECT_SHELL_MIN/MAX` L6502 to 6503, `primalityMemo` L6121, `safeFactorMemo` L6452.
- **DOM-free core:** exists. All functions are DOM-free. They read `state` through `selectedShellBase()` and `currentN()` (pure functions of `state.shellMode`, `state.directBase`, `state.n1`, `state.phi3`). The writers `applySelectedShell` (L13221) and `stepPhi3` (L13301) are controllers (see HC-14).
- **Register:** exact, on Number integers (INFERRED: the lexical scan finds no BigInt tokens here). B = n1!, N = B + 1 - phi3. The only float token is one in `parseDirectShell` L13241 to 13247 (INFERRED to be a `Number` conversion; read it before cutting).
- **Depends on:** exact-lib (`factorial`, `euler`). **State:** reads `shellMode`, `directBase`, `n1`, `phi3`.
- **Tests:** none in host. Prototype `host-core/shell-core.js` (73 lines) holds number-theory readouts (factor, totient, divisors, Wilson witness), so the shell-base functions have no prototype counterpart yet (INFERRED from its function list).
- **Parity:** all load in the headless vm; compare `selectedShellBase` and `currentN` against the rebuilt shell-core over a grid of (shellMode, n1, directBase, phi3).

#### HC-2 gearbox exact registers: t1, t2, s, lift adapters (29 functions)
- **Covers:** registeredRadialPresetLaneActive L5418–5422 [Sr]; parseGearboxRational L5780–5814 [mix]; gearboxExactKey L5816–5819; gearboxExactText L5821–5823 [Sr]; gearboxExactPair L5825–5827; integerGearboxActive L5829–5836 [big]; exactRationalLiftLaneActive L5842–5856 [big,Sr]; exactRationalGearboxPhaseMetadata L5869–5894 [big]; buildExactRationalLiftAdapter L5900–5932 [mix]; buildExactRationalLiftCertificate L5934–6018 [mix]; exactGearboxProductIsInteger L6020–6027 [big]; centerSignedExactSpin L6029–6045 [mix]; centerNumericSpin L6047–6058; frozenCoreExactSpin L6060–6071 [big]; adaptSignedLiftSpecForFrozenCore L6073–6077; projectSignedLiftSpecs L6079–6085; signedPhaseMetadata L6087–6102 [big]; parseSDirectInput L6266–6268; formatSDisplay L6270–6275 [Sr]; formatSInputValue L6277–6281 [Sr]; exactSpinString L6316–6318 [flt,Sr]; sToFraction L6319–6327; parseExactS L6342–6357 [Sr]; stateCyclotomicField L6365–6426 [Sr]; spreadBranchOrder L6435–6447 [big,Sr]; gearboxInvariant L6569–6571; parseCanonicalGearboxSpin L6991–7007 [flt]; gearboxStepDenominator L13590–13599 [flt,Sr]; gearboxStepText L13601–13604.
- **DOM-free core:** exists, all DOM-free. The SELECTABLE_SHELL_LIFT_ADAPTER_V1 and SIGNED_SPIN_LIFT_ADAPTER_V1 marker regions (L5673 to L6103) are already separated from rendering in the host.
- **Register:** **exact BigInt** for the parse and certificate functions. `parseSignedCanonicalRationalBigInt`, `parseGearboxRational` and `buildExactRationalLiftCertificate` are `big`. **Mixing lines:** `parseGearboxRational` L5811 to 5812 (`Number(num)/Number(den)` display value), `buildExactRationalLiftAdapter` L5901 and L5926 to 5929, `buildExactRationalLiftCertificate` L5956, `centerSignedExactSpin` L6030 and L6042, `parseCanonicalGearboxSpin` L6996 to 7002, `exactSpinString` L6317 (**float-sourced exactness test: `Math.abs(s - state.s) < 1e-10` decides whether the exact string `state.sExact` is trusted**), `sToFraction` L6319 to 6327 (**falls back to float `Math.round(s*100)` over 100**).
- **Depends on:** exact-lib, PlaneCliffordLiftCore (10 edges), HC-1. **State:** reads `t1Exact`, `t2Exact`, `sExact`, `s`, `t1`, `t2`, `m`, `shellMode`.
- **Tests:** the host self-check `runSpectralGearboxSelfCheck` L15052 to L15229 (published as `window.FVLT_GEARBOX_V0_2_2`, L15233). Prototype: `host-core/gearbox-core.js` (30 lines) covers the gearbox-defect readout only.
- **Parity:** extract by range into the headless vm; compare `parseGearboxRational`, `integerGearboxActive`, `exactRationalGearboxPhaseMetadata` and `centerSignedExactSpin` outputs to the rebuilt gearbox/comb-core `enterSpin` and `dialChange`.

#### HC-3 comb, Vernier, channel and flank readouts (21 functions)
- **Covers:** trilatticeEntropy L7075–7080 [flt]; spineAdherence L7085–7088; timeArrow L7092–7094; getChannelAnalysis L7097–7131 [flt]; getHarmonicContrast L7146–7153; getBracket L7159–7162; getFlankAnalysis L7164–7183 [flt]; classifyResidentPair L7188–7247; shellChannelClass L7249–7251; buildShellFlankRegister L7253–7264; combOffsets L7319–7327; combKernel L7333–7339 [flt]; reducedHalfTurns L7351–7357; stableGearboxAngle L7359–7363 [flt]; computeVernier L7365–7431 [flt,Sr]; positiveDivisorsAtMost L9401–9419; divisorsOnAxis L9429–9455 [mix,Sr]; signedToothLabel L9704–9706; spreadFrameExact L11052–11086 [mix,Sr]; nextCombStop L13401–13448 [flt,Sr]; combLabel L14027–14031.
- **DOM-free core:** exists, all DOM-free. But `computeVernier` (L7365 to 7431) **reads `state` directly** (`state.t1`, `t2`, `n6`, `alpha`, `m`) and returns floats. It needs to be given an explicit parameter object.
- **Register:** `combOffsets` is exact integer. `combKernel`, `reducedHalfTurns`, `stableGearboxAngle`, `computeVernier` are **float** (Math.cos/sin/pow). **Mixing lines:** `computeVernier` L7385, 7389, 7390, 7414, 7419, 7423 (the radius `state.n6 * Math.pow(...)`, then `Math.cos/Math.sin` of the angle); `stableGearboxAngle` L7362 (`Math.PI * reducedHalfTurns(...)`). `getHarmonicContrast` L7146 to 7153 divides integers in floating point. `getChannelAnalysis` L7097 to 7131, `getFlankAnalysis` L7164 to 7183, `trilatticeEntropy` L7075 to 7080 contain float logs and ratios. `nextCombStop` L13401 to 13448 is **Number-integer arithmetic with `Number.isSafeInteger` guards and a float epsilon: `const x = state.s * D; const eps = 1e-6 * Math.max(1, Math.abs(x))` (L13407 to 13409)**. So the stop decision is float-sourced. `divisorsOnAxis` L9429 to 9455 mixes exact BigInt divisor membership with float screen coordinates (L9432 `Math.round(s)`, L9441).
- **Depends on:** HC-1, HC-2, exact-lib (8 edges to EXACT group). **State:** reads `t1`, `t2`, `n6`, `alpha`, `m`, `s`; no writes in this group.
- **Tests:** host comments cite `verify_triad_gearbox.js` (L307), `verify_mcomb.js` (L372, L7398, "not bundled"), `verify_branch_tags.js` (L386). None is available in the host folder. The prototype has `host-core/comb-core.js` (209 lines, exact) and `comb-numeric.js` (112 lines, float with error bounds), and `parity-sample.cjs`, which compares against the cubic_Fourier v0.3.2 reference (a different frozen source).
- **Parity:** compare `combOffsets`, `computeVernier` tooth sets, `nextCombStop` and `divisorsOnAxis` against the rebuilt exact core by loading from the headless vm. Expect and classify differences (the epsilon-based stop is a known "reference defect reproduced by exact arithmetic" class in `parity-sample.cjs`).

#### HC-4 spectral gearbox, Wilson, paired modulus (10 functions)
- **Covers:** parseWilsonCandidate L6141–6147 [big]; analyzeIndependentWilsonCandidate L6188–6242 [mix,Sr]; spectralGearboxSnapshot L6577–6595 [Sr]; assertSpectralSourceSnapshot L6597–6614; spectralSignatureClass L6616–6623; analyzeSpectralWilsonGearbox L6625–6792; assertSpectralWilsonGearboxRecord L6794–6854; analyzePairedModulus L6856–6989; assertPairedModulusRecord L7009–7064 [flt]; independentWilsonShellKey L9517–9521 [Sr]. Also `window.FVLT_GEARBOX_V0_2_2` publication L15233, constants `SPECTRAL_GEARBOX_SOURCE_FILE/SHA256`, `PREDECESSOR_*` L6562 to 6567, `WILSON_CANDIDATE_MAX`, `WILSON_FULL_POLYGON_MAX` L6138 to 6139.
- **DOM-free core:** exists. The overlay renderers (`renderIndependentWilsonCandidateOverlay` L9532, `renderSpectralWilsonGearboxOverlay` L9611, `updateSpectralGearboxCard` L12206) are separate. `analyzeSpectralWilsonGearbox` (L6625 to 6792) and `analyzePairedModulus` (L6856 to 6989) are pure (no `state`).
- **Register:** exact (BigInt in `analyzeIndependentWilsonCandidate`, `isPrimeSafeBigInt`, `modPowBigInt`). Mixed lines: `parseCanonicalGearboxSpin` L6996 to 7002; `assertPairedModulusRecord` L7035; `analyzeIndependentWilsonCandidate` L6228. `pairedMirrorGeometry` L9503 to 9515 is drawing-register float (S9).
- **Depends on:** HC-1, HC-2, exact-lib. **State:** `spectralGearboxSnapshot` L6577 reads 9 state fields (this is the adapter); the analyzers take the snapshot.
- **Tests:** `runSpectralGearboxSelfCheck` (in-host, DOM tail); `spectralGearboxSelfCheck` L16423 node. The host cites `gearboxInvariant` assertions.
- **Parity:** load by range in the vm; run `analyzeSpectralWilsonGearbox` and `analyzePairedModulus` over a grid of snapshots against any rebuilt analyzer.

#### HC-5 Clifford lift core (marker PLANE_CLIFFORD_LIFT_CORE_V2): module `PlaneCliffordLiftCore` L4648 to L5341 (33 inner functions)
- **Covers:** absBigInt L4662–4662 [big]; gcdBigInt L4664–4673 [big]; reduceRationalBigInt L4675–4686 [big]; parseCanonicalRationalBigInt L4688–4699 [big]; normalizePhaseRemainder L4701–4710 [big]; exactPiAngleMod2 L4712–4726 [mix]; phaseIsMinusHalfMod2 L4728–4731 [big]; rhoExactFor L4733–4742 [big]; classifyRhoExact L4744–4749 [big]; rationalExport L4751–4757; rhoExport L4759–4764 [flt]; liftToS3 L4766–4840 [mix]; stereographicProject L4842–4868; complexDivide L4870–4876; normalizedComplexError L4878–4880 [flt]; torusEquationRelativeError L4882–4888 [flt]; makeLiftPoint L4890–4938 [mix]; roundDisplayNumber L4940–4943 [flt]; buildLiftPayload L4945–5053 [flt]; normalizeJsonValue L5055–5076; canonicalSerialize L5078–5080; selectHeadIndices L5082–5089; factorialForLift L5091–5096; assertLiftOffsets L5098–5103; buildCurrentLiftSpecs L5105–5120; buildLiftRosetteSpecs L5122–5146; buildLiftFullStackSpecs L5148–5179 [flt]; concatenateActualSpecs L5181–5184; projectLiftSpecs L5186–5205; selectAndProjectLiftSpecs L5207–5210; rotateCameraPoint L5212–5227 [flt]; createReferenceGuide L5229–5258 [flt]; prepareCameraScreen L5260–5303 [flt]. Companions: `ContinuousRadialDisplayV1` L5350 to 5416 (liftToS3 L5353–5391 [flt]; projectSpecs L5393–5413).
- **DOM-free core:** **exists and is already a pure IIFE with no document or window token.** Scripted dependency check: zero host-function calls and zero `state` refs.
- **Register: mixed by design.** Exact BigInt for the phase (`parseCanonicalRationalBigInt`, `reduceRationalBigInt`, `rhoExactFor`). Float for the lift. **The BigInt-to-float boundary is `exactPiAngleMod2` L4712 to 4726** (BigInt rounded to 53 fractional bits, ties to even, then `Number(word)/9007199254740992 * Math.PI`, algorithm id `BIGINT_MOD2_Q53_TIES_EVEN_V1` at L4649). Float lines: `liftToS3` L4775 to 4813 (`Math.PI`, `Math.cos/sin`, `Math.pow(N, alpha)` at L4808, `Math.sqrt` L4809), `stereographicProject` L4842 to 4868, `makeLiftPoint` L4890 to 4938, `roundDisplayNumber` L4940, `torusEquationRelativeError` L4882. The module's constants include `STEREOGRAPHIC_EPSILON = 1e-9` (L4650).
- **Depends on:** nothing (it is the root). exact-lib duplicates its internal gcd/abs/reduce/parse (L4662 to 4699). **State:** none.
- **Tests:** none named; `buildLiftPayload` L4945 to 5053 produces a payload with exactness metadata that the host gates (INFERRED).
- **Parity:** load L4645 to L5341 whole into the vm (loaded in the test). Compare `reduceRationalBigInt`, `parseCanonicalRationalBigInt`, `exactPiAngleMod2` and `liftToS3` with rebuilt exact-lib and numeric cores.

#### HC-6 Clifford lift glue (24 functions)
- **Covers:** buildSelectedLiftFullStackSpecs L5678–5719 [flt]; annotateLiftPayloadShellSelection L5721–5741; liftSourceSnapshot L8813–8833 [Sr]; rationalGearboxOrbitAdapter L8842–8865 [mix]; annotateRationalOrbitPath L8867–8885 [big]; createDisplayOrbitGuide L8887–8902; classifyDisplayOrbit L8904–8914; buildRationalLiftRosetteSpecs L8916–8939; liftStackExactCacheKey L8941–8943; liftRosetteExactCacheKey L8945–8950; buildLiftRosetteSpecsCached L8952–8963; buildLiftFullStackSpecsCached L8965–8976; getLiftStackCacheDiagnostics L8978–8989; getLiftRosetteCacheDiagnostics L8991–9002; getLiftCacheDiagnostics L9004–9009; projectSelectedActualSpecs L9011–9107; buildCliffordActualPoints L9249–9284; buildCurrentLiftPayload L9286–9399 [mix,DOM,Srw]; cliffordStateLabel L10031–10037; cliffordGuideDepthBounds L10039–10048 [flt]; leafSweepAvailable L10398–10400; activeLeafGeometry L10402–10411 [Sr]; buildSliceCoordinateFieldPaths L11090–11144 [flt]; buildMeridionalSweepDisplayPoints L11146–11214 [mix,Srw]. Also depth-0 caches `_liftStackCache` family L7921 to 7927 (mutable `let`).
- **DOM-free core:** exists for all but `buildCurrentLiftPayload` (L9286 to 9399), which mixes DOM and `window` (flag `DW`) and has 25 `state.` references, 6 of them writes (lexical count). Needs splitting.
- **Register:** mixed. Exact-keyed caches (`liftStackExactCacheKey`) over float coordinates. **Mixing lines:** `buildCurrentLiftPayload` L9343, 9365, 9367, 9388 (**`point.k = Number(phases.frequency.numerator) / Number(phases.frequency.denominator)` at L9343 sources a float k next to `k_exact`**), `buildSelectedLiftFullStackSpecs` L5678 to 5719, `buildMeridionalSweepDisplayPoints` L11146 to 11214 (L11160, 11193, 11194), `buildSliceCoordinateFieldPaths` L11090 to 11144 (float-heavy, 20 float tokens).
- **Depends on:** HC-5 (10 edges), HC-3 (`computeVernier`, `combOffsets`, `spreadFrameExact`), HC-2, HC-1, exact-lib, HC-8 (`leafEtaFromStep`; this is a cycle with HC-9, see section 4). **State:** `liftSourceSnapshot` (13 reads) is the host's snapshot seam.
- **Tests:** none named.
- **Parity:** all but `buildCurrentLiftPayload` load in the vm; compare payload structure and exact fields (`k_exact`, `sExact`) between host and rebuilt `comb-core`/`comb-numeric` (`lift` outputs).

#### HC-7 fraction stack (6 functions; addendum 3)
- **Covers:** fractionSpinSpreadZero L9132–9145; fractionStackLattice L9155–9164; fractionStackGateReason L9166–9178; buildFractionStackPointsCached L9180–9227 [Sr]; getFracStackDiagnostics L9229–9234 [Sr]; withFractionStack L9240–9247 [Sr]. Plus depth-0 cache values `_fracStackCache`, `_fracStackCacheKey`, `_fracStackRawCount` (L9127), `FRACTION_STACK_MAX_HEADS/ORDER` (L9125 to 9126).
- **DOM-free core:** exists, all DOM-free. Addendum 3 names the range L9112 to L9200 and the caption at L11830.
- **Register:** exact (lattice and gate reasons are exact integer/fraction arithmetic). Float only inside the lift it feeds.
- **Depends on:** HC-2, HC-1, exact-lib, HC-3, HC-5. **State:** `buildFractionStackPointsCached` reads 1 and `getFracStackDiagnostics` reads 2 state fields.
- **Tests:** the host cites verify_spread_frame.py (61/61 exact rationals, L735; earlier 46/46 at L701) for the spread-frame maths, not run here. Prototype: `host-core/fraction-stack-core.js` (52 lines) exists.
- **Parity:** load in the vm; compare `fractionStackLattice` and `fractionStackGateReason` with the prototype across (m, t2, s, N).

#### HC-8 orbit, knot and branch registers; ActualOrbitGuide (31 functions + module)
- **Covers:** isBranchOffsetVisible L10239–10241 [Sr]; branchVisibilitySignature L10243–10245 [Sr]; formatCliffordRho L10369–10374 [flt]; leafEtaFromStep L10376–10379 [flt,DOM]; leafEtaStepFromRho L10381–10384 [flt]; leafEtaPiLabel L10386–10396 [flt,DOM]; cliffordRhoLabel L10467–10502 [flt,Sr]; signedOrbitOffset L10504–10507; orbitIntegerLabel L10509–10511; orbitPrimitiveType L10513–10515; orbitRawType L10517–10522; orbitBranchMultiplicity L10528–10530; orbitFactorizationText L10532–10539; orbitKnotRelationRecord L10541–10600; buildOrbitBranchRegister L10602–10620; canonicalTorusKnotRecord L10622–10628; canonicalKnotFamilyLabels L10630–10651; lissajousShadowBranchFence L10653–10658; lissajousFrequencyMapText L10660–10666; lissajousShadowSummaryFence L10668–10683; orbitClassificationText L10685–10694; invalidateBranchFilter L10698–10700; c0PhaseBetaRadians L10702–10705 [flt,Sr]; c0PhasePiLabel L10707–10715; c0PhasePositionLabel L10717–10724; buildBranchFilterGuide L10785–10803 [Sr]; cliffordOrbitLabel L10908–10988 [Sr]; sweepGammaLabelText L11221–11228 [flt,Sr]; sweepSliderPosition L11230–11232 [flt,Sr]; spreadFrameTagText L11240–11254 [Sr]; arithmeticRhoForSnapshot L12853–12856 [flt]. Module `PlaneCliffordActualOrbitGuideV1` L8275 to 8811 (17 inner: gcdNumber L8295–8304; projectProductPoint L8306–8317 [flt]; projectEtaPoint L8319–8322; sampleC0PhasePathAtEta L8328–8346 [flt]; sampleC0PhasePath L8348–8366 [flt]; createC0PhaseFoliationAtEta L8368–8400 [flt]; createC0PhaseFoliation L8402–8429 [flt]; createLeafAtEta L8431–8510; createLeaf L8512–8561 [flt]; classifyOrbit L8563–8590; selectOffsets L8592–8597; sampleOrbitAtEta L8599–8651 [flt]; sampleOrbit L8653–8699 [flt]; createOrbitsAtEta L8701–8731; createOrbits L8733–8759; combineGuides L8761–8784; append L8766–8775).
- **DOM-free core:** exists, all DOM-free (module has no document token).
- **Register:** the knot/Lissajous records are exact integer; the module samples floats (`Math.PI` x9, `Math.sqrt`, `Math.cos/sin`).
- **Depends on:** HC-5 (7 edges), HC-3 (`combOffsets`), HC-2, HC-6 (cycle), HC-1. **State:** `cliffordOrbitLabel` and `cliffordRhoLabel` read 2 fields each; module reads none.
- **Tests:** none named.
- **Parity:** load in the vm; compare `canonicalTorusKnotRecord` and `classifyOrbit` over (p, q) grids.

#### HC-9 meridional sweep (10 inner functions)
- **Covers:** module `PlaneCliffordMeridionalSweepV1` L5467 to 5670: emptyDiagnostics L5482–5493; rotateWorldZ L5495–5511 [flt]; selectUniformIndices L5516–5526; eligibleStackPoints L5531–5537; cloneRotated L5539–5560; buildSingleSliceDisplay L5562–5580; buildVolumeSweepDisplay L5582–5636; resetDiagnostics L5638–5641; getDiagnostics L5643–5645; planeEquationText L5648–5653 [flt]. Host glue `buildMeridionalSweepDisplayPoints` (HC-6) and the sweep controllers (HC-14).
- **DOM-free core:** exists (module has no document token). **Register:** float (`rotateWorldZ`, `planeEquationText` use `Math.cos/sin` and `toFixed`). **Depends on:** HC-5. **State:** none in the module.
- **Parity:** module loads in the vm; compare `buildSingleSliceDisplay` and `buildVolumeSweepDisplay` on fixed inputs.

#### HC-10 Hopf base and S3 leaf geometry (marker-less modules)
- **Covers:** `HopfBaseDisplayV1` L8027 to 8135 (6 inner: assertComplexPair L8032–8036; assertSpherePoint L8038–8048; fromPair L8050–8063; fromAffine L8065–8074; fromLiftPoint L8076–8079; sample L8081–8096); `S3LeafSweepDisplayV1` L8141 to 8261 (8 inner: clampEta L8145–8148; etaFromRho L8150–8154 [flt]; rhoFromEta L8156–8161 [flt]; geometryForEta L8163–8188 [flt]; projectLeafPoint L8190–8200 [flt]; reprojectPoint L8202–8215 [flt]; reprojectPoints L8217–8221; close L8232–8233); `PlaneCliffordVisualGuideV1` L7932 to 8018 (projectBalancedPoint L7938–7948 [flt]; samplePath L7950–7956; meridian L7958–7960; parallel L7962–7964; hopfFiber L7966–7968; oppositeFiber L7970–7972; weave L7974–7983; create L7985–8002 [flt]); host Hopf and camera maths: periodicCameraAngleDistance L7624–7627 [flt]; activeCliffordCameraPresetKey L7629–7637 [Sr]; prepareCliffordGuidePath L10087–10101; splitPreparedGuidePath L10218–10237 [flt]; activeHopfBaseCameraPresetKey L11895–11903 [Sr]; rotateHopfBasePoint L11929–11938 [flt,Sr]; hopfBaseScreenPoint L11940–11947; hopfLatitudePoints L11972–11979 [flt]; hopfLongitudePoints L11981–11990 [flt]; formatHopfNumber L11992–11996 [flt]; formatComplexPair L11998–12003.
- **DOM-free core:** exists. The three modules have no document token; the camera functions are DOM-free, and the draw/sync functions are UI (section 3).
- **Register:** **float, with exact gates.** `HopfBaseDisplayV1` has built-in `fixtures` (L8098 to 8103), a `gate` (L8117 to 8122) and `TOLERANCE = 2e-12` (L8030). `S3LeafSweepDisplayV1` has `fixtures` L8223 to 8228, `tolerance` L8229, `gate` L8240 to 8244, and uses `Math.atan2/cos/sin`. **These two gates are the embedded float reference checks of the geometry modules** (the rank-4 gates in section 2C are separate).
- **Depends on:** HC-5 (`PlaneCliffordLiftCore`); `HopfBaseDisplayV1` also calls `registeredRadialPresetLaneActive` (host function that reads `state`, 4 refs; scripted edge). **State:** none in the modules.
- **Parity:** load in the vm and run the embedded gates; compare against `comb-numeric.js` `hopf`, `hopfBase`, `fromAffine` and `gateFixtures`.

#### HC-11 trail, rosette, stack builders (5 functions)
- **Covers:** trailAlignExact L7796–7806 [big,Sr]; buildTrail L7808–7845 [Sr]; buildRosette L7861–7878 [Sr]; buildFullStack L7887–7916 [flt,Sr]; buildPinchMarkerSamples L9471–9501 [flt,Sr]. Plus depth-0 caches `_stackCache`, `_stackCacheKey`, `_stackDrawSig` (L7886, mutable `let`).
- **DOM-free core:** exists. **Register:** exact predicate (`trailAlignExact` is BigInt) feeding float coordinates from `computeVernier`. **Mixing line:** `buildFullStack` L7905.
- **Depends on:** HC-3, HC-2, HC-1. **State:** reads 4 to 8 state fields per function (`buildFullStack` 8). **Tests:** none.
- **Parity:** vm load; compare `trailAlignExact` exact results and the trail point count against the prototype.

#### HC-12 view scaling and palette (8 functions, drawing register)
- **Covers:** alphaScale L7715–7729 [flt,Sr]; currentRadius L7734–7737 [flt,Sr]; dotScale L7749–7755 [flt,Sr]; toothPairIndex L7776–7779 [Sr]; toothColor L7780–7784; toothColorRgba L7785–7788; toScreen L9457–9463 [Sr]; pairedMirrorGeometry L9503–9515 [flt,Sr], plus constants `TOOTH_PAIR_PALETTE` L7767 to 7774, `CARRIER_COLOR` L7775. These are screen scales and colours: keep in the panel, not a library.

#### HC-13 export and self-checks (3 functions)
- **Covers:** buildExportData L14715–14973 [flt,DOM,Sr]; downloadFile L14975–14982 [DOM]; runSpectralGearboxSelfCheck L15052–15229 [mix,DOM]. `buildExportData` L14715 to 14973 reads 45 state refs and mentions the string `exactGates: '26/26 PASS'` (L14796): **a hard-coded pass banner** with no reproducing code in the host.
- **Note:** this is the adapter layer for the viewer's JSON/PNG exports, not a library.

#### HC-14 state controllers and commit actions (21 functions, DOM-free state writers)
- **Covers:** synchronizeIndependentWilsonCandidateVisibility L9523–9530 [Srw]; ensureSelectedToothAvailable L9692–9702 [Srw]; selectCurrentTooth L9723–9733 [Srw]; applyHopfBaseCameraPreset L11913–11918 [Srw]; resetHopfBaseCamera L11920–11927 [Srw]; stopCliffordWeaveAnimation L12664–12672 [Srw]; stopMeridionalSweepAnimation L12705–12713 [Srw]; setMeridionalSweepMode L12743–12754 [Srw]; commitCliffordLeafSliderRender L12837–12843; stopCliffordLeafSweepAnimation L12858–12867 [Srw]; setCliffordLeafMode L12913–12927 [Srw]; applySelectedShell L13221–13239 [Srw]; stepPhi3 L13301–13310 [Srw]; setGearboxStepDenominator L13628–13638 [flt,Srw]; setRadialParameterMode L13722–13768 [Srw]; setContinuousRadialParameter L13770–13788 [flt,Srw]; commitContinuousGearboxSlider L13823–13835 [mix]; setContinuousIntegerParameter L13837–13856 [flt,Srw]; stepT L13972–13988 [big]; setM L14065–14077 [Srw]; toggleSpectralGearboxOverlay L14169–14172 [Srw].
- These are the host's `set*`, `step*`, `apply*`, `stop*` and `toggle*` functions. They write `state` (the host has 69 writes across this group) and call the render functions. They map to the viewer's **commit actions**, not to a library. `stepS` (L13450 to 13502) and `setSValue` (L6290 to 6311) are **mixed controller plus DOM** (flag DOM, 4 and 2 writes) and must be split into a commit action and a message to the panel (they write `s-direct-note`, call `syncSValueControls()` and `render()`).

#### HC-15 shared state schema and adapter seam
- **Covers:** `state` L7440 to 7498; `DEFAULT_*_CAMERA` presets L7436 to 7439, 7500 to 7560; `liftSourceSnapshot` L8813.
- **Register:** dual (Number projection plus exact string, see the intro of section 2).
- **Parity:** the `state` literal loads headless; use it to seed the frozen-function parity runs.

### 2C. Out of scope (kept for the record)
- **Rank-4 / Alpoge**: b8 (L3330 to 4527, 56 functions, UMD `AlpogeRank4MonodromyExactV1`, loads headless by itself), b9, `AlpogeRank4BridgeV1` L15273 to 15816 (36 inner, 64 document tokens), and the host functions `renderAlpogeMonodromyView`, `monodromy20Gate`, `monodromy20BracketPaths`, `monodromy20FixtureReport`, `runMonodromy20ClassifierGates`, `runMonodromy20MutationMatrix` (L15818 to 16087). Per addendum 4 they belong to the separate Rank-4 viewer.

### 2D. One library per marker-block instrument

For every block the DOM-free core is the sibling `*-core.js`, `*-record.js` or `*-validate.js` where one exists. The host block mixes core, UI and worker string in a single script, so loading the *whole block* headless fails (tested: all of b11 to b17, b20, b23 to b31 fail in an empty vm; b1 to b7, b19, b21 load). The core must be loaded by segment (a range cut) or from the sibling file.

Headless `require` of sibling files in plain node (tested): LOADS and exports: `sha256.js`, `strict-json.js`, `contact-core.js` (36 exports), `contact-validate.js` (5), `basel-core.js` (35), `reciprocal-record.js` (14), `spc-core.js` (32), `tooth-core.js` (44), `tooth-validate.js` (7), `rhm-core.js` (31), `afp-core.js` (58), `atom-packet.js`, `family-model.js`, `register-model.js`, `spectral.js`, `provenance.js`, `pt1-group.cjs`, `pt1-replay.cjs`, `pt1-producer.cjs`, `u1-interval.cjs` (27), `u1-engine.cjs`, `u1-replay.cjs`, `p1-engine.cjs`, `p1-replay.cjs`. FAIL as bare require: `atom-core.js` and `walk-core.js` (need a global `McombCayleyCoreV1` from the Cayley block), `walk-host.js` (needs the host's `analyzePairedModulus`: a host seam), `afp-sources-data.js` (needs `window`). `structure-core.js`, `history-core.js`, `fca-core.js` and their packets load but export nothing through `module.exports` (they attach to a global, INFERRED).

Float counts per segment are in the table of section 1a. Float lines found by the scripted walk in the exact cores:

| core | float lines (all are display or enclosure tails, not exact sources) |
|---|---|
| contact-core + validate (INFERRED range L19036 to 19385) | none |
| basel-core (INFERRED range L19933 to 20171) | L19999 `toNumber` (Math.pow), L20140, 20148, 20160 (log enclosure display, `Math.log`/`Math.exp`, `1e-300`) |
| reciprocal-record L20629 to 20875, spc-core L21093 to 21430, tooth-core L21930 to 22221, tooth-validate L22223 to 22436, rhm-core L23127 to 23502, afp-core L23885 to 24869 | none by the float-token scan (afp-core has 9 functions with `Number(` conversions; the lexical `flt` flag is not a proof) |
| atom-core L18400 to 18451 | L18428, 18431, 18433 (`Math.cos/sin/hypot`, `Math.PI`, `1e-10`): geometry of the atom diagram |
| walk-core L18463 to 18531 | L18522 (`Number.EPSILON`) |
| spectral.js L18148 to 18165 | L18161 (exact terms evaluated to a float re/im) |
| Cayley core L58 to 77 | L73 (`Math.cos`, `Math.PI`) |
| Cayley graph L2644 to 2670 | L2664, 2666 (layout trig) |
| EllipticModelV27 L16104 to 16233 | 16 float lines: `periods` L16155 to 16187 (Float64 AGM periods, `Math.sqrt`, `1e80`/`1e-80` guards, 20 float tokens), `ellipticK`, `agm` L16147 to 16151; exact rational model arithmetic is separate (the file's own header says so) |
| mcomb-elliptic-link L16722 to 16929 | 16 float lines (periods, `Math.hypot/exp/sin/cos`) |
| carrier-addition L17024 to 17192 | 11 float lines (tolerances `2e-8`, `1e-11`, concordance checks); header says "exact phase identities and rational arithmetic are separate from numerical concordance" |

The 14 instruments:

| # | instrument (marker) | block and lines | DOM-free core | register | host dependencies (scripted) | references to tests and reference checkers |
|---|---|---|---|---|---|---|
| I1 | MCOMB_CAYLEY_V1 (exact, core, spectrum, capture, packet, store, graph) | b1 L5 to 54; b2 L58 to 77; b3 L81 to 101; b4 L105 to 158; b5 L162 to 184; b6 L188 to 222; b7 L2644 to 2670 | **all seven load headless** in an empty vm (tested) | exact BigInt; float only in b2 L73 and b7 L2664 to 2666 | none (zero host-name references) | `test-core.worker.cjs`, `test-interaction-browser.worker.cjs`, `verify.cjs` (siblings, INFERRED mapping); "same bytes in Node and browser" (b1 header) |
| I1u | Cayley UI: host adapter, camera, inspector | b17 L17216 to 17249; b19 L17253 to 17276; b20 L17280 to 17408 | no (DOM) | n/a | `liftSourceSnapshot`, `isBranchOffsetVisible`, `selectCurrentTooth`, `state`, `OrbitPointIndexV26`, `store` | same |
| I2 | BSD_CURVE_RECORD_V1 | b11 L16445 to 16672 | UMD: node path is `require('../v27_elliptic_bridge.js')`; **whole block fails headless (`document`)**: 3 DOM functions to split | exact rational bookkeeping ("no analytic-rank oracle") | `EllipticModelV27` | none named |
| I3 | MCOMB_ELLIPTIC_LINK_V1 + ELLIPTIC_BRIDGE_V27 | b13 L16722 to 16929; model L16104 to 16233 (pure); bridge UI L16235 to 16405 | model yes; link block needs `CliffordEllipticBridgeV27` | mixed (periods float) | 17 host names incl. `setSValue`, `combOffsets`, `liftSourceSnapshot`, `render`, `invalidateShellCaches`, `loadSevenJetState`, `S3LeafSweepDisplayV1`, `OrbitPointIndexV26` | none named |
| I4 | MCOMB_CONNECTED_PANELS_V1 | b14 L16933 to 17020 | no | n/a | `liftSourceSnapshot`, `OrbitPointIndexV26`, `EllipticModelV27` | none |
| I5 | MCOMB_CARRIER_ADDITION_V1 | b15 L17024 to 17192 | UMD with `require` paths to `../MCOMB_ELLIPTIC_BSD_LINK_v0_1_20260907/...` (out of folder) | mixed | 8 host names | none |
| I6 | BSD_LINKED_VIEW_V1 (M3 to M7 cores, history, structure, T-chain, U1/P1/PT1, spectral, family, register, plot-interaction) | b21 L17412; b22 L17413 (386 KB JSON); b23 L17414 to 18907 | **yes, per sibling segment** (list in section 1a): atom-core 27 fns, walk-core 13, structure-core 19, history-core 6, fca-core 21, spectral.js 1, family-model 9, register-model 2, plus U1/P1/PT1 engines | exact BigInt (atom/walk/structure/history/fca have 6 to 19 BigInt fns each); float in atom geometry, family-model trig (L18190 to 18200), plot-interaction (9 DOM fns, 18 float lines) | 6 host names: `selectedShellBase`, `analyzePairedModulus`, `liftSourceSnapshot`, `updateSpectralGearboxCard`, `OrbitPointIndexV26`, `EllipticModelV27` | 26 `test-*.worker.cjs` files, `p1-reference.json`, `check-p1-independent.py`, `check-u1-independent.py`, `pt1-independent.py`, `pt1-fixtures.json`, `pt1-example-packets.json`, `verify.cjs`; the T1 to T4 Tate engines (`t1.cjs`, `t2.cjs`, `t3.cjs`, `tame-tate.cjs`, `small-prime-tate.cjs`, `global-reduction.cjs`, `model-replay.cjs`) are named at L17412 and live in sibling `BSD_*` folders, not in this one; M4 to M7 and P1/U1/PT1 have `*_PREDECESSOR_*` documents |
| I7 | M7 diagram cameras (no marker) | b24 L18909 to 19031 | `crystal-placement.js` (1 function) is pure; `camera-ui.js`, `fca-3d-ui.js` are UI | float | none | `test-fca-browser.worker.cjs` |
| I8 | CONTACT_SWEEP_V0_1_1 | b25 L19033 to 19928; core ~L19036 to 19385 (INFERRED), UI ~L19387 to 19924 | core + validate yes (siblings load) | exact BigInt (0 float lines in the core); UI has 8 float fns | 11 host names incl. `setSValue`, `selectedShellBase`, `currentN`, `updateSSliderRange`, `liftSourceSnapshot`, `applySelectedShell`, `updateStepperState`, `commitGearboxRational`, `toggleAnim`, `phi3Slider`; 8 `state` refs | schema files `contact-sweep.schema.json` and `contact-sweep-0.3.schema.json`; `CONTACT_SWEEP_README.md` cites `CONTACT_SWEEP_CHECKS.md`; browser suite (31 PASS regression per BASEL README) |
| I9 | BASEL_LINK_V0_1_2 | b26 L19931 to 20624; core ~L19933 to 20171 (INFERRED) | yes (basel-core loads, 35 exports) | exact BigInt + float log enclosure display lines | `liftSourceSnapshot`; load needs contact-sweep diagnostics ("Basel link modules or host seam missing") | `BASEL_LINK_README.md`: `run-checks.cjs` in `BASEL_FOURIER_HOST_LINK_WORK_v0_1_2_20260928`; 67 browser, 17 integrity, 31 regression checks (as stated in README, not rerun); `test_core.cjs` cited at L19953 |
| I10 | COMBINED_BCD_V0_1_RECIPROCAL | b27 L20627 to 21087 | yes (`reciprocal-record.js`, 14 exports) | exact BigInt (0 float) | `liftSourceSnapshot`; needs Basel diagnostics | `reciprocal_record.py` reference cited at L20630 (RECIPROCAL_RECORD_SPEC_v0_1_1_20260929) |
| I11 | COMBINED_BCD_V0_1_SHELL_PRIME_COUNT | b28 L21090 to 21924 | yes (`spc-core.js`, 32 exports) | exact BigInt | `parseGearboxRational`, `gearboxExactText`, `isPrime`, `factorSafePositiveInteger`, `liftSourceSnapshot` | spc worker string; no external reference checker named |
| I12 | COMBINED_BCD_V0_1_TOOTH_CONTACT | b29 L21927 to 23121 | yes (`tooth-core.js` 44 exports, `tooth-validate.js` 7) | exact BigInt (12 BigInt fns, 1 float) | 11 host names (as I8) | `tooth_contact_contract.py` (TOOTH_CONTACT_SCHEMA_v0_1_1_20260926) cited at L21929 |
| I13 | RH_MARGIN_V0_1 | b30 L23124 to 23876 | yes (`rhm-core.js`, 31 exports) | exact BigInt (33 BigInt fns); header: statement-for-statement BigInt port of `rh_criteria_readout.py` | `liftSourceSnapshot` | `rh_criteria_readout.py` and `rh_enclosures.py` cited at L23126 |
| I14 | ARITHMETIC_FOURIER_V0_1 | b31 L23879 to 25360 | yes (`afp-core.js`, 58 exports, loads in plain node) | exact BigInt (28 BigInt fns), 9 `Number(` fns | none (zero host names), but needs the exact curve model of I6 per addendum 4 (INFERRED from README: "exact curve binding needs the host's T4 replay") | `af_reference.py` cited at L23884; `build/build-af.cjs` generator |
| I15 | OrbitPointIndexV26 (no marker) | b10 L11360 to 11543 (25 inner: phases L11388–11399 [mix]; update L11400–11432 [mix,DOM,Sr]; unwrapped L11434–11491 [mix,DOM]; line L11446–11446 [flt]; text L11447–11447 [DOM]; select L11492–11492 [Srw]; foliation L11493–11498; draw L11499–11507 [flt,DOM,Sr]; plane L11522–11538 [flt,DOM]; moveBeta L11539–11539; currentSelection L11540–11540; selectAddress L11541–11541; $ L11376–11376 [DOM]; gcd L11378–11378 [big]; rat L11379–11379 [big]; parse L11380–11380 [big]; mul L11381–11381; add L11382–11382; mod L11383–11383 [big]; str L11384–11384 [big]; num L11385–11385 [flt]; key L11386–11386; enabled L11387–11387; wrap L11444–11444; xy L11445–11445) | **no: tightly host-coupled.** Calls `liftSourceSnapshot`, `buildCliffordActualPoints`, `activeLeafGeometry`, `setSValue`, `render`, `isBranchOffsetVisible`, `toothColor`, `toScreen`, and has its own gcd/rat/mod copies at L11378 to 11383 | mixed (its `phases` and `unwrapped` use BigInt + float 6 to 16 tokens) | 9 `state` refs | none |
| I16 | UI chrome only: PANEL_CONTROLS_V1 (b12 L16676 to 16718), BSD_REDUCTION_AUDIT_V1 (b16 L17196 to 17212) | | no (display-only) | n/a | | none; no library |

**Existing parity precedent:** `host-core/parity-sample.cjs` already loads a frozen reference read-only with `require` and classifies each difference. The same harness shape works for the sibling files above.

---

## 3. Rendering and UI code that stays out of the libraries

Counted at depth 0 in b10 (the 271-function census):
- **UR render / draw / DOM sync: 69 functions**, L6283 to L14457 (2,845 lines in total). They include the heavy renderers `renderPhasorSvg` L9735 to 10029 (36 `state.` refs, 43 float tokens), `renderClifford` L11546 to 11880 (35 `state.` refs, 36 float), `renderHopfBase` L12018 to 12201 (37 float), `updateCards` L12322 to 12623 (39 `state.` refs), `updateSpectralGearboxCard` L12206 to 12320, `render` L12628 to 12654, plus the nine guide-drawing `draw*` helpers L10050 to L10367, the `sync*Controls` family and the animation steps. Full list with line ranges: syncSValueControls L6283–6288 [DOM]; setSValue L6290–6311 [flt,DOM,Srw]; syncCliffordCameraPresetControls L7639–7645 [DOM]; applyCliffordCameraPreset L7647–7661 [DOM,Srw]; updateSSliderRange L7670–7680 [DOM,Srw]; el L7757–7762 [DOM]; renderIndependentWilsonCandidateOverlay L9532–9609 [flt,DOM,Sr]; renderSpectralWilsonGearboxOverlay L9611–9690 [flt,DOM,Sr]; syncCrossViewSelectionLabel L9708–9721 [DOM,Sr]; renderPhasorSvg L9735–10029 [flt,DOM,Sr]; drawDepthCuedGuideMesh L10050–10085 [flt]; drawDepthCuedGuidePath L10103–10143 [flt]; drawDepthCuedGuideSamples L10149–10177 [flt]; drawDashedGuidePath L10179–10200 [flt]; drawFaintGuidePath L10202–10216; drawC0PhaseFoliationBackground L10247–10257 [flt,Sr]; drawC0PhaseFoliationSelection L10259–10275 [flt,Sr]; drawCliffordActualOrbits L10277–10306 [flt,Sr]; drawCliffordVisualGuide L10308–10367 [flt,Sr]; syncCliffordLeafSweepControls L10413–10465 [flt,DOM,Sr]; syncC0PhaseFoliationControls L10726–10780 [DOM,Sr]; syncBranchFilter L10805–10906 [DOM,Sr]; syncCliffordGuideControls L10990–11013 [DOM,Sr]; renderMeridionalSweepLabel L11256–11293 [flt,DOM,Sr]; syncMeridionalSweepControls L11295–11330 [flt,DOM,Sr]; syncLiftExportAvailability L11332–11356 [DOM,Sr]; renderClifford L11546–11880 [flt,DOM,Sr]; syncHopfBaseCameraControls L11905–11911 [DOM]; drawHopfBasePath L11949–11970; drawHopfBaseAxis L12005–12016; renderHopfBase L12018–12201 [flt,DOM,Sr]; updateSpectralGearboxCard L12206–12320 [DOM,Sr]; updateCards L12322–12623 [flt,DOM,Sr]; render L12628–12654 [DOM,Sr]; cliffordWeaveAnimationStep L12674–12689 [flt,DOM,Srw]; startCliffordWeaveAnimation L12691–12700 [DOM,Srw]; meridionalSweepAnimationStep L12715–12732 [flt,DOM,Srw]; startMeridionalSweepAnimation L12734–12741 [DOM,Srw]; cancelCliffordLeafSliderRender L12830–12835; scheduleCliffordLeafSliderRender L12845–12851; cliffordLeafSweepAnimationStep L12869–12896 [flt,DOM,Srw]; startCliffordLeafSweepAnimation L12898–12911 [DOM,Srw]; syncViewMode L12979–13071 [DOM,Srw]; setViewMode L13073–13086 [DOM,Srw]; syncShellControls L13204–13219 [DOM,Sr]; applyDirectShellInput L13249–13260 [DOM]; buildFactorialButtons L13262–13272 [DOM]; updateFactorialButtons L13273–13277 [DOM,Sr]; updateStepperState L13312–13317 [DOM,Sr]; applyDirectSInput L13377–13386 [DOM]; stepS L13450–13502 [flt,DOM,Srw]; formatRadialControlValue L13585–13588 [flt]; syncGearboxStepControls L13606–13626 [flt,DOM]; syncRadialParameterControls L13640–13712 [flt,DOM,Sr]; scheduleRadialDisplayRender L13714–13720 [DOM]; commitGearboxRational L13790–13821 [DOM,Srw]; wireSlowStepButton L13858–13894 [DOM]; setTrinary L13896–13904 [DOM,Srw]; buildMSelect L14032–14043 [DOM,Sr]; syncMSelect L14044–14054 [DOM]; syncMRegisterTag L14055–14064 [DOM]; loadSevenJetState L14082–14122 [flt,DOM,Srw]; applyIndependentWilsonCandidateInput L14133–14150 [DOM,Srw]; updatePlayButtons L14191–14199 [DOM,Sr]; toggleAnim L14200–14210 [DOM,Srw]; animationStep L14223–14263 [DOM,Srw]; toggleFullscreen L14396–14403 [DOM]; pickTargetsForCurrentView L14415–14427 [Sr]; pickCurrentToothAt L14429–14457 [flt,Sr].
- **CT state controllers and commit-action candidates: 21 functions**, L9523 to L14172 (see HC-14 for the list).
- **VS view scaling: 8 functions** (HC-12).
- **Top-level event binding outside any function: 127 lines in 9 clusters** (`addEventListener`, `.onclick`, `.oninput`, `.onchange`, `.onpointer*`) at L12757 to 12815 (11), 12929 to 12973 (10), 13088 to 13184 (20), 13279 to 13365 (10), 13503 to 13565 (11), 13906 to 14006 (12), **14125 to 14667 (40, the keyboard, pointer and pinch handlers)**, 14984 to 15023 (4, the CSV-export click handler with its own `lbl` helper), 16380 to 16395 (11). A further 37 binding lines sit inside functions and modules, giving 166 in all.
- **Inside the marker blocks:** DOM-touching functions per block (lexical): b11 3, b12 2, b13 7, b14 6, b15 11, b16 1, b17 4, b19 1, b20 9, **b23 71**, b24 13, b25 13, b26 14, b27 6, b28 4, b29 13, b30 10, b31 9. In the sibling segment table of section 1a, `*-ui.js`, `client.js`, `plot-interaction.js`, `camera-ui.js`, `fca-3d-ui.js` and `*-linked.js` are the rendering parts. The in-block UI is: tooth-ui 68 fns (13 DOM), spc-ui 38, afp-ui 42, rhm-ui 27, atom-ui 23, structure-ui 18, history-ui 14, fca-ui 15, plot-interaction 33, client 22, reciprocal-link-ui 13.
- **DOM-guarded UI inside the pure region of b10:** `CliffordEllipticBridgeV27` L16235 to L16405 (18 functions, guarded by `typeof document`), the UI of `OrbitPointIndexV26` (its `draw`, `plane`, `update`, `unwrapped`) and `AlpogeRank4BridgeV1` (out of scope).
- b10 also creates 12 DOM handles at depth 0 (`phasorSvg` L7686, `allNCanvas`, `cliffordCanvas`, `hopfBaseCanvas`, `leafEtaSlider` L12947, `phi3Slider` L13289, `sSlider` L13364, `mContinuousControl` L13948, `svgFrame` L14413, `sDirectInput` L16416 and two self-check nodes).

---

## 4. Dependency order

Evidence: the scripted name-match call graph between the 15 groups of the 271 depth-0 functions plus 10 module objects, and the per-block host-name references. Edges counted as number of calling functions.

```
L0  exact-lib                      (16 gcd, rational, BigInt, canonical/strict JSON, sha256 copies merged;
                                    absorbs PlaneCliffordLiftCore L4662-L4764 BigInt rational helpers)
        |
L1  shared-state schema (HC-15)    shell-core (HC-1)        clifford-lift-core (HC-5, ContinuousRadialDisplayV1)
        |                              |                          |
L2  gearbox-core (HC-2) ---------------+------------------------->|
        |
L3  comb / Vernier / readouts (HC-3)      spectral-wilson (HC-4)
        |
L4  lift-glue (HC-6) <-> orbit-knot (HC-8)   [cycle: merge or move leafEta* into clifford-lift-core]
    fraction-stack (HC-7)   trail-stack (HC-11)   meridional-sweep (HC-9)   hopf-geometry (HC-10)
        |
L5  instruments: Cayley (b1 -> b2 -> b3..b7) ; BSD curve record (b11) ; elliptic model -> elliptic link (b13), carrier addition (b15),
    connected panels (b14) ; BSD linked view (b23 segments: atom -> walk/structure/history/fca) ;
    contact (b25) -> Basel (b26) -> reciprocal (b27) ; shell-prime-count (b28) ; tooth-contact (b29) ; rh-margin (b30) ;
    arithmetic-fourier (b31) -> exact curve (b23)
        |
L6  panels + adapters (render/draw/sync) and commit actions (HC-14), wired through the shared state
```

Scripted edge evidence (calling groups to called groups):
- COMB to EXACT 8, GEARBOX 3, SHELL 4, CLIFFORD-CORE 1.
- GEARBOX to EXACT 16, CLIFFORD-CORE 10, SHELL 1.
- SPECTRAL-WILSON to EXACT 6, GEARBOX 6, SHELL 1.
- FRAC-STACK to EXACT 3, GEARBOX 3, COMB 1, SHELL 1.
- LIFT-GLUE to CLIFFORD-CORE 10, EXACT 5, GEARBOX 5, COMB 3, SHELL 2, FRAC-STACK 1, ORBIT-KNOT 2.
- ORBIT-KNOT to CLIFFORD-CORE 7, COMB 3, GEARBOX 2, LIFT-GLUE 2, SHELL 1.
- TRAIL-STACK to COMB 4, GEARBOX 2, SHELL 2.
- UI-RENDER to every group (16 to GEARBOX, 14 to ORBIT-KNOT, 13 to SHELL, 12 to HOPF-CAM, 11 to CONTROLLER).
- No library group calls UI-RENDER except through name collisions, such as `render` in two spectral functions (false positive: the word, not a call, INFERRED).
- The instruments depend on the host only through `liftSourceSnapshot` (referenced from 10 blocks: b13, b14, b17, b23, b25 to b30), plus controls in b25 and b29.
- b27's load error names missing Basel diagnostics, so b27 depends on b26 (INFERRED from the error text; b25 and b26 also failed in the same run).

Instrument-internal order (from load errors of an empty vm): b1 to b7 form a chain with no host dependency; b17, b19 and b20 need the Cayley adapter; b13 and b15 need `CliffordEllipticBridgeV27`; b14 needs `EllipticModelV27`.

---

## 5. Risks

**Hidden globals and cross-block coupling**
1. `state` (L7440) is read by name from inside **126 of the 475 named functions of b10** and by b13, b15, b17, b25, b29 (scripted `state.` refs: 15, 2, 2, 8, 8). Writers are spread over the controllers and the renderers: the controller group has 69 `state` writes (`setRadialParameterMode` L13722 to 13768 alone has 29) and the UI-render group has another 106 (lexical count).
2. 20 depth-0 `let`/`var` statements are mutable module globals: `_planePickTargets`, `_cliffordPickTargets`, `_hopfBasePickTargets` (L7693 to 7695), `_stackCache*` L7886, the six `_lift*` cache families L7921 to 7927, `_fracStack*` L9127, `branchFilterSignature` L10696, `cliffordLeafSlider*` timers L12826 to 12828, `_lastFsExit`, `radialDisplayRenderFrame`, `selectionPointerStart`, `pinchStart`. Four memo containers (`primalityMemo` L6121, `safeFactorMemo` L6452, `eulerMemo` L6476, `moebiusMemo` L6525) are plain module-level objects. Whether `invalidateShellCaches` (L13195) clears them was not checked.
3. Instruments are bound by free names, not by import: the marker blocks reference host functions `liftSourceSnapshot`, `setSValue`, `render`, `applySelectedShell`, `selectCurrentTooth`, `commitGearboxRational`, `toggleAnim`, `phi3Slider` and others (b13: 17 names; b25 and b29: 11 each; b15: 8). A re-homed library must receive these as explicit adapter arguments (the "declared reads and commit actions" of the adapter).
4. Window publications: `window.FVLT_GEARBOX_V0_2_2` L15233, `FVLT_ALPOGE_RANK4_MONODROMY_V1` L15820, `FVLT_MONODROMY_20` L16089, `CliffordEllipticBridgeV27` L16238. Each of the later marker blocks publishes 3 to 5 `window.Mcomb*` names (BuildPins, Core, Diagnostics, WorkerSource; for example `McombContactSweepCoreV1`, `McombBaselLinkBuildPins`). Order of block execution matters: b13 and b15 fail if `CliffordEllipticBridgeV27` is not defined.
5. A naive name census **misses multi-declarator constants** (15 such second declarators, for example `T_MAX` L13575, `M_MAX` L14022, `SVG_H` and `cy` L7690 to 7691, the `_lift*CacheKey` names). `divisorsOnAxis` failed in the headless test until these were included. Any extraction must slice whole statements.
6. Embedded source strings: b25, b28, b29, b30, b31 carry the worker source as a string (for example `window.McombContactSweepWorkerSource`), duplicating the core. b22's JSON bundle (386 KB) and b23's `FACTORIES` registry (L17436 to L17870) are further copies of the BSD engines. The same code therefore exists up to three times in the page. A parity test must name which copy it checks.
7. `walk-host.js` (b23 L18533 to 18553) uses the host's `analyzePairedModulus` by free name; `atom-core.js` and `walk-core.js` use a global `McombCayleyCoreV1`.

**Shared mutable state in the libraries**
8. `computeVernier`, `nextCombStop`, `divisorsOnAxis`, `trailAlignExact`, `spreadFrameExact`, `selectedShellBase` read `state` directly instead of taking arguments (45 of the 144 functions in the nine HC library-candidate groups have `state.` refs). Pure re-homing needs signature changes, which breaks "re-homed copies" if the parity tests call the frozen versions with a mutated `state`. Plan a thin wrapper that sets the sandbox `state` and calls the frozen function (as the headless smoke test did).
9. The caches `_liftStackCache` and others key on exact strings but store float point arrays; they are invalidated by `invalidateShellCaches` (L13195) and per-call keys. If a library re-homes the builders, the cache must move with its key function.

**Float-sourced exact claims** (each is a place where an exact-looking result depends on a float test)
10. `exactSpinString` L6316: trusts `state.sExact` only if `Math.abs(s - state.s) < 1e-10`.
11. `sToFraction` L6319 to 6327: for non-exact `s` returns a fraction from `Math.round(s*100)/100`.
12. `nextCombStop` L13401 to 13448: next stop found by `Math.floor((x - offset)/step + eps)` with `eps = 1e-6*max(1,|x|)` and `x = state.s * D` in floating point. `parity-sample.cjs` already treats this class as "reference defect reproduced".
13. `divisorsOnAxis` L9429: `Math.round(s)` selects the integer spin, then exact BigInt membership follows. `exactPiAngleMod2` L4712 is exact until the final division by 2^53 (a deliberate boundary).
14. `computeVernier`: `state.t1`, `t2`, `s` are Number projections of the exact strings; for large shells (13!) the code splits `t1*s` into reduced half-turns (explained in the comment just above `reducedHalfTurns`, L7351) because `k*s` can exceed 2^53.
15. `parseGearboxRational` L5811: `Number(num)/Number(den)` display value, checked for finiteness only.
16. `getHarmonicContrast` L7146: integer ratio computed in floating point and exported as a number.
17. `buildExportData` L14796: constant `exactGates: '26/26 PASS'`, a hard-coded gate banner.
18. `spectral.js` `assess` (b23 L18161): exact cyclotomic terms evaluated to float re/im in the same function that returns exact `nullity` and `zero` fields.
19. `buildCurrentLiftPayload` L9343: float `point.k` beside `point.k_exact`.

**Code that cannot be loaded headless**
20. 75 of 366 depth-0 items in b10 (60 functions and 15 values) reference the document or canvas. The marker blocks b11 to b17, b20, b23 to b31 fail as whole blocks in an empty vm, because each block's script mixes core and UI. Section 2D lists the sibling-file or range-cut route that works.
21. The `CliffordEllipticBridgeV27` UI sits inside the `ELLIPTIC_BRIDGE_V27` marker, directly after the pure `EllipticModelV27`, behind `if(typeof document!=='undefined')`; cut at L16233.
22. `afp-sources-data.js` (63 KB base64 of five registered snapshots) assigns on `window` at load.

**Parity-test hazards**
23. The 5 non-matching sibling files (contact-core, contact-validate, contact-ui, basel-core, basel-link-ui) mean the host's inline copy and the sibling file may differ. Always compare against the host text.
24. Test files reside outside this folder for contact, Basel, tooth, RH margin and arithmetic-Fourier (READMEs name `run-checks.cjs`, `CONTACT_SWEEP_CHECKS.md`; not located or run here).
25. The lexical register tags over-report floats (`Number(` on BigInt), so the register of each library must be confirmed by a read before the exact core is cut.

---

## 6. Coverage statement

**Scripted total: 1,773 named function definitions** (declarations and `const x = function/arrow` bindings, any depth) across the 28 JavaScript blocks. Of these, b10 has 475, of which **271 are at depth 0**.

**Assigned: 1,773 of 1,773, 0 unassigned.** The assignment worked in three tiers.
1. The 271 depth-0 functions of b10 were each assigned by name to one of 15 groups: gearbox 29, lift glue 24, exact seeds 20, spectral/Wilson 10, UI render 69, shell 7, comb 21, Hopf/camera 11, view scaling 8, trail/stack 5, fraction stack 6, controllers 21, orbit/knot 31, export/self-check 3, Rank-4 6. The assignment started with explicit name lists. UI render and controllers were assigned by pattern rules (names starting render, draw, sync, update, schedule, wire, set, step, apply, toggle, start, stop, commit and similar) or by the DOM flag, and every pattern assignment was reviewed. The review moved `invalidateShellCaches` and `combLabel` out of the UI group.
2. The 204 other b10 functions were assigned to their enclosing module (171, to the 10 IIFE modules by line range) or to their enclosing depth-0 function (14), plus 19 by explicit line-range rule (see below).
3. The functions of the other 27 blocks were assigned by block (905) or, for b23, by sibling-file segment (353) and by explicit line range (40).

Assigned totals by tier: b10 depth-0 271; b10 inside modules 171; b10 nested in depth-0 functions 14; b10 by line-range rule 19; b23 by sibling segment 353; b23 by line-range rule 40; all other blocks 905. Sum 1,773.

**Functions that no name or segment rule matched and were assigned only by an explicit line-range rule (59, so they are the least certain assignments):** message@b10:16275, canBind@b10:16276, isBound@b10:16277, detach@b10:16278, invalidate@b10:16279, apply@b10:16280, line@b10:16293, selectedPoint@b10:16294, chart@b10:16303, refresh@b10:16327, useOrbit@b10:16353, snapshot@b10:16361, importRecord@b10:16372, lbl@b10:15006, f@b10:16271, z@b10:16272, rationalText@b10:16273, data@b10:16274, el@b10:16305, rat@b23:17444, R@b23:17445, canonical@b23:17454, shape@b23:17456, invariants@b23:17457, model@b23:17466, transform@b23:17467, inverse@b23:17472, compose@b23:17474, pointOn@b23:17475, pointMap@b23:17476, phaseMap@b23:17477, verifyTransport@b23:17478, depth@b23:17480, evidence@b23:17483, prime@b23:17502, strictJSON@b23:17707, string@b23:17710, value@b23:17711, strictJSON@b23:17899, string@b23:17902, value@b23:17903, fail@b23:17442, gcd@b23:17443, S@b23:17446, add@b23:17447, neg@b23:17448, mul@b23:17449, div@b23:17450, pow@b23:17451, times@b23:17452, sum@b23:17453, hash@b23:17455, sourceJSON@b23:17482, valuation@b23:17503, modulo@b23:17507, square@b23:17513, checkAdditiveTamagawa@b23:17514, ws@b23:17709, ws@b23:17901. They fall in three regions. The first is the DOM-guarded bridge UI `CliffordEllipticBridgeV27` (b10 L16235 to 16405; 18 functions) and the CSV-export click handler (L14984 to 15023, `lbl`). The second is the in-page `model-replay.cjs` factory (b23 L17436 to 17603; 32 functions: `rat`, `R`, `canonical`, `shape`, `model`, `transform`, `inverse`, `compose`, `pointOn`, `pointMap`, `phaseMap`, `verifyTransport`, `prime`, `valuation`, `modulo`, `square`, `checkAdditiveTamagawa` and the like). The third is two more `strictJSON` copies (b23 L17707 and L17899, with `string`, `value`, `ws`).

**Group totals over the whole file (all 1,773):**

| group | functions |
|---|---|
| Instrument: tooth-contact | 126 |
| Instrument: arithmetic-fourier | 117 |
| EXCLUDED-rank4 | 98 |
| Instrument: contact-sweep | 90 |
| Instrument: basel-link | 80 |
| HC-clifford-core | 79 |
| Instrument: rh-margin | 78 |
| UI-render | 76 |
| Instrument: shell-prime-count | 74 |
| Instrument: bsd-curve-record | 46 |
| Instrument: mcomb-elliptic-link | 44 |
| Instrument: mcomb-carrier-addition | 41 |
| Instrument: reciprocal-link | 41 |
| Instrument: bsd-linked-view / plot-interaction.js | 33 |
| Instrument: bsd-linked-view / FACTORIES model-replay.cjs (in-page module registry) | 32 |
| HC-orbit-knot | 31 |
| HC-gearbox | 30 |
| Instrument: bsd-linked-view / atom-core.js | 27 |
| HC-lift-glue | 26 |
| Instrument: orbit-point-index (host-coupled) | 25 |
| Instrument: elliptic-bridge-v27 model | 25 |
| Instrument: mcomb-cayley (exact C) | 24 |
| HC-comb | 24 |
| Instrument: bsd-linked-view / atom-ui.js | 23 |
| Instrument: m7 fca diagram cameras (UI) | 23 |
| Instrument: bsd-linked-view / client.js | 22 |
| UI-controller | 21 |
| Instrument: bsd-linked-view / fca-core.js | 21 |
| EXACT-lib seeds | 20 |
| Instrument: mcomb-cayley (inspector, UI) | 19 |
| Instrument: bsd-linked-view / u1-interval.cjs | 19 |
| Instrument: bsd-linked-view / structure-core.js | 19 |
| Instrument: elliptic-bridge-v27 UI (CliffordEllipticBridgeV27, DOM-guarded) | 18 |
| Instrument: bsd-linked-view / structure-ui.js | 18 |
| Instrument: bsd-linked-view / pt1-group.cjs | 17 |
| Instrument: bsd-linked-view / fca-ui.js | 15 |
| Instrument: mcomb-connected-panels | 14 |
| Instrument: bsd-linked-view / history-ui.js | 14 |
| Instrument: bsd-linked-view / walk-core.js | 13 |
| HC-hopf-camera | 11 |
| HC-spectral-wilson | 10 |
| Instrument: bsd-linked-view / family-model.js | 9 |
| UI-view-scale | 8 |
| exact-lib duplicate: strictJSON (in BSD bundle, not a sibling file) | 8 |
| Instrument: bsd-linked-view / family-ui.js | 8 |
| HC-shell | 7 |
| Instrument: bsd-linked-view / u1-linked.js | 7 |
| Instrument: mcomb-cayley (core) | 6 |
| HC-hopf-core | 6 |
| HC-fraction-stack | 6 |
| Instrument: mcomb-cayley (host adapter, UI) | 6 |
| Instrument: bsd-linked-view / pt1-replay.cjs | 6 |
| Instrument: bsd-linked-view / u1-engine.cjs | 6 |
| Instrument: bsd-linked-view / u1-replay.cjs | 6 |
| Instrument: bsd-linked-view / pt1-linked.js | 6 |
| Instrument: bsd-linked-view / p1-linked.js | 6 |
| Instrument: bsd-linked-view / history-core.js | 6 |
| HC-trail-stack | 5 |
| Instrument: mcomb-cayley (camera, UI) | 5 |
| Instrument: bsd-linked-view / p1-engine.cjs | 5 |
| Instrument: bsd-linked-view / p1-replay.cjs | 5 |
| Instrument: mcomb-cayley (packet) | 4 |
| Export-check | 4 |
| Instrument: bsd-linked-view / strict-json.js | 4 |
| Instrument: bsd-linked-view / loader.js | 4 |
| Instrument: bsd-linked-view / provenance.js | 4 |
| Instrument: bsd-linked-view / spectral-ui.js | 4 |
| Instrument: bsd-linked-view / atom-packet.js | 4 |
| Instrument: bsd-linked-view / structure-packet.js | 4 |
| Instrument: bsd-linked-view / history-packet.js | 4 |
| Instrument: mcomb-cayley (capture) | 3 |
| Instrument: mcomb-cayley (graph) | 3 |
| UI-chrome (panel controls) | 3 |
| Instrument: bsd-linked-view / register-ui.js | 3 |
| Instrument: bsd-linked-view / sha256.js | 2 |
| Instrument: bsd-linked-view / pt1-producer.cjs | 2 |
| Instrument: bsd-linked-view / register-model.js | 2 |
| Instrument: bsd-linked-view / walk-host.js | 2 |
| Instrument: bsd-linked-view / fca-packet.js | 2 |
| Instrument: mcomb-cayley (spectrum) | 1 |
| UI-wiring (top-level event handler: CSV export click) | 1 |
| UI-chrome (bsd reduction audit display) | 1 |
| Instrument: bsd-linked-view / spectral.js | 1 |

**Not functions (not counted above):** the 95 depth-0 value bindings of b10 plus the 15 second declarators found by a separate scan, the 3 JSON blocks, and the object methods inside literals (`name(){}` forms), which the scripted walk does not enumerate. Object-literal method counts were not measured, so completeness is claimed only for named declarations and bindings.

**What was not done.** No sibling test suite was run. The Python reference checkers were not located or run. No claim here is a certificate of parity; it is a plan for where parity tests attach.
