# M-comb Cayley inspector — Codex implementation plan v3

**Plan version: v3 · 2026-09-21**  
Contract: `MCOMB_CAYLEY_VISUALIZATION_SCHEMA_v0_1.md`, document revision **v0.1-C**  
**First implementation run: M0–M2 only, then stop for audit.**  
**v3 includes the spin-parser defect repair requirement (SPIN-EXACT-001), corrected PARSE2 cases, and CAP9.**  
Status: plan only; the parser repair and viewer implementation have not been built or browser-tested.

Version key: **v3** identifies this implementation plan; **v0.1-C** identifies the unchanged schema; **30.1** identifies the baseline Monodromy viewer. The earlier download ending in `_v1.md` contained plan revision 3 under an outdated filename.

## 1. Objective and authority

Implement the reviewed schema in the supplied Monodromy .30.1 viewer. Preserve the existing exact source and add a weighted Cayley inspector whose graph, kernel, multiplicities and selected addresses stay synchronized. Support direct-host captures through m=720 without a configured curve, as well as the existing narrower elliptic capture route.

The schema is the mathematical and record-format contract. This plan supplies task order, code boundaries, tests and delivery gates. It does not revise that contract. Read the schema in full before implementation, especially §§2–5, 9–12 and the later FCA extension in §15. Respect applicable repository instructions if working in a checkout.

Keep v0.1-C fixed as the audit baseline. If implementation reveals a contradiction or missing semantic decision, record a precise deviation with an example and proposed resolution. Continue independent work; do not silently change the source meanings, fixture expectations or schema to make a test pass. Routine file organization, drawing choices and internal function names can be resolved locally.

### Required input roles and SHA-256 pins

Resolve inputs by content hash. Names below identify the supplied copies in this workspace; transfers may rename the schema to `MCOMB_CAYLEY_VISUALIZATION_SCHEMA_v0_1_c.md` or remove the atom viewer's `(6)` suffix. Neither filename spelling is an admission condition.

| Input | SHA-256 |
|---|---|
| `MCOMB_CAYLEY_VISUALIZATION_SCHEMA_v0_1.md` | `46c7f214d606aab9014bac0d4631150a79ad7a0da39a6362acd05621302d2948` |
| `monodromy-30-1-reduction-audit.html` | `5dc69781082a3d2b41e1b38b49f71c44ec349a219221ed19b15969f8c0c0ee84` |
| `helix_atlas_doily_witness_v27_patched_3_wl2(6).html` | `3d65e14af4b0887b543e48d986ccc6367b0129afc150e0f9a254bd407b3ab106` |

The atom file is needed when implementing M4 and M7, not to admit a direct-host cyclic capture. The Div(12) demonstration is explanatory material, not an implementation dependency or test oracle.

Implement `verify:pins` as role resolution within the explicitly supplied input paths/directories, not a whole-machine scan. Hash candidate bytes and write a manifest mapping each role to its actual path and expected/observed hash. Filename hints may narrow candidates but must not reject a matching hash. For byte-identical duplicates choose a deterministic path and list the aliases. Report a genuinely missing hash as a missing role. Later commands read this manifest rather than hard-coded filenames.

Verify input pins before patching. A mismatch requires identifying the actual source version and recording the difference; do not stamp the supplied pins onto different bytes. Preserve clean copies of supplied inputs. Produce a separate integrated preview, provisionally named `monodromy-30-1-cayley-preview.html`; do not overwrite the baseline or relabel unrelated module versions. The schema remains v0.1-C regardless of a downloaded filename.

## 2. Delivery milestones

| Milestone | Deliverable | Required gate | Depends on |
|---|---|---|---|
| M0 | Pinned baseline, module/build scaffold and source map | Input pins and baseline behavior recorded | Inputs |
| M1 | Pure exact core, spin-parser defect repair, spectrum evaluator | Q1–Q9, P1–P4, injectivity, large-comb arithmetic, corrected PARSE2 | M0 |
| M2 | Both capture routes, state lifecycle and export/replay | Actual capture binding, deterministic stale-result rejection, import validation | M1 |
| M3 | Integrated graph/kernel inspector with linked selection | Browser interaction checks and host regressions | M2 |
| M4 | Atom adapter, cosets and coordinate contributions | A1–A6, projection/height and binding checks | M3 |
| M5 | Neighborhood inspector and bounded clique certificates | S1/S2, general-t scope, witness/upper-bound verification | M4 |
| M6 | Walk histories and modular count patterns | W1/W2, folded counts and truncation semantics | M5 |
| M7 | FCA context views and separate walk semantics | Schema §15 context, orientation and incidence checks | M6 |

**The first execution is limited to M0–M2.** Deliver that code and audit package, then stop the run. M3–M7 remain the planned later sequence; the default execution prompt does not authorize continuing into them. This is a deliberate scope boundary so capture and stale-result logic can receive independent review before more features depend on it, not a permission prompt inserted into M0–M2. Complete and test M0–M2 autonomously. M2 is the first audit-ready code checkpoint; M3 will be the first usable visualization release. Never label M2 as a finished visualization or M3 as the entire extended schema.

Compatible quotient towers, nested divisor intervals, doily/Farey incidence exploration and free frequency sets are later extension tasks, described in §11 below. Do not turn these optional extensions into prerequisites for the first usable release.

## 3. Suggested code organization

Keep pure modules testable without the DOM, curve model or BSD register. Reuse an existing project layout if present. For a standalone-file workflow, use a small source directory and a deterministic assembler that embeds the same tested code into the preview HTML.

| Proposed file | Responsibility |
|---|---|
| `cayley/exact.js` | Bounded input parsing, normalized BigInt rationals, gcd/lcm, phases |
| `cayley/core.js` | Canonical offsets, integer and quotient records, sparse weights, simple conversion |
| `cayley/spectrum.js` | Exact character descriptors and numerical evaluation |
| `cayley/capture.js` | Direct and elliptic source adapters, origin/provenance admission |
| `cayley/store.js` | Immutable snapshots, source revision, selection, live/held/blocked lifecycle |
| `cayley/packet.js` | Canonicalization, hashing, export and recomputing import |
| `cayley/jobs.js` | Worker requests, cancellation, revision/digest checks and bounded caches |
| `cayley/panel.js` | Host mounting, graph/kernel rendering, accessible linked selection |
| `cayley/atom.js` | Exponent groups, orbit/coset maps, contributions and height |
| `cayley/structure.js` | Neighborhoods, boundary profiles and clique search |
| `cayley/walks.js` | History words, endpoints, counts and modulo-ell recurrence |
| `cayley/fca.js` | Incidence contexts, closures, concept labels and strand matrix certificates |
| `tests/fixtures.json` | Concrete Q/P/A/S/W cases, preserving schema IDs |
| `tests/*.test.js` | Pure arithmetic, capture/state and packet tests |
| `tests/browser/*` | Tests loading the actual assembled viewer |
| `scripts/build-viewer.mjs` | Embed modules once, validate markers and generate hashes |
| `audit/` | Machine-readable outcomes, environment, input/output pins and human handoff |

These filenames are proposed. Choose ESM or another module format compatible with the host and test runner; do not maintain separately edited browser and test implementations. Node's built-in test runner is sufficient for the pure core. Use an actual browser runner for integrated behavior. Pin any introduced tooling dependencies and document installation/replay commands. A Node DOM stub is not a browser test.

The pinned Monodromy host has no external script tags. Preserve that property: do not add runtime script/CDN dependencies for the Cayley core. Verify offline operation of the resulting preview in its browser smoke check rather than inferring it from the absence of script tags alone. Development/test dependencies may be installed locally and pinned.

## 4. M0: source map and baseline

1. Verify the three pins and record repository status, if applicable. Preserve unrelated user changes.
2. Locate by symbol and enclosing scope, not hard-coded line number or the first text match: `combOffsets`, `combKernel`, `computeVernier`, `liftSourceSnapshot`, `OrbitPointIndexV26`, `McombElliptic.validateSource`, `McombEllipticLink.current`, `mcomb:transport`, and the host selection/render paths. The file has multiple functions named `render`; identify the main host function by its view-mode branches and neighboring main-render marker. Likewise scope function extraction when helper names repeat inside embedded modules.
3. Inventory source mutations and real control paths, including animation, direct entry, sliders, steppers, presets, imports and shell controls. The host has no single existing source-commit event. Locate `matchesHost`, which compares a capture against a fresh `liftSourceSnapshot()` and selected index point; use the same fresh-snapshot principle. Record where animation makes exact input unavailable and where selected N/s differ from live N/s.
4. Record the existing `{source, selection, visibleOffsets}` capture shape. Trace how selection and branch visibility are currently changed so the inspector can call the same mechanisms.
5. Locate the existing render/update paths and a collapsible panel mounting point near the m-comb controls. `render()` has early returns; snapshot detection must cover every branch. Mount once; teardown removes listeners and cancels jobs. Use namespaced IDs and module markers. Do not rely on attaching listeners to a selected subset of controls.
6. Establish a small baseline browser smoke check: viewer loads, the resident pair renders, comb order/selection/visibility controls work, and one existing export path still functions. If a pre-existing failure exists, record it before any patch.

7. Record the confirmed `SPIN-EXACT-001` defect below, reproduce it with functions extracted from the pinned source, and trace propagation into live/current-index captures. This is an authorized, scoped host bug fix in the preview; keep the pinned original untouched and include the repair in its own reviewable diff.

**Output:** source map with symbols and responsibilities, input manifest, build command, baseline outcomes and defect record. Do not refactor unrelated carrier, elliptic, BSD or Fourier code.

## 5. M1: exact arithmetic and weighted operator

### Work items

- Parse exact integers/rationals with positive denominator, gcd reduction and nonnegative modular residues. Impose explicit input-byte and work quotas. Reject unsafe numeric integers before conversion. Separate typed-input grammar from strict canonical packet parsing; a decimal typed as an authoritative source is not a rounded decimal copied from a drawing.
- Generate the complete canonical C_m for m=1…720. Use one pure definition and compare it against the host's actual `combOffsets` over the shared range. Preserve the host function unless a documented bug requires changing it.
- Derive θ=h/q, C, D₁ and P_c using exact arithmetic. Reduce θ before numerical evaluation. Unit order q must never come from the selected pair's cD₁.
- Build sparse residue weights by iterating tooth labels, without allocating q entries. Derive every tooth's displacement order and its exact torus address.
- Derive injectivity from residues and check the shortcut. Look up diagonalWeight by residue `"0"`. Derive the odd identity subtraction only when valid.
- Keep spectrum descriptors exact and numerical evaluations labeled. For each k, retain k/q and the defining offset sum. Evaluate the captured physical kernel at k=h.
- Implement resource-limited full spectrum work in a worker or testable job abstraction. Above budget, evaluate explicitly requested indices; do not describe their minimum as the complete quotient minimum.
- Separate torsion sampling q from auxiliary resolution p. No UI is required yet, but the computation API must retain the domain.

### Tests and gate

Run the implementation against Q1–Q9 and P1–P4. Compare weighted matrices constructed by explicit translated tooth actions with Fourier character vectors: `L f_k = λ_k f_k`. This tests the actual operator independently of the cosine evaluator. For the small fixed spectra, check the listed eigenvalues and multiplicities too.

Run the 3,100 injectivity cases m=1…31, q=1…100 against explicit residue collisions. For valid conversion, verify symmetric 0/1 off-diagonal entries, no loops and expected degree. Target m=32/q3, m=720/q2, m=720/q1440 and m=720/q1438 to cover the full-host boundary.

Add `PARSE1` against the actual pinned `parseGearboxRational`, not a test-only transcription. Its accepted UI grammar includes trimmed signed integers, fractions with unsigned denominator, finite decimals (`.5`, `1.`, `+0.25`), and Unicode minus normalized to ASCII. Compare reduced numerator/denominator, canonical exact text and accept/reject outcome. Test leading zeroes, signed zero, reducible fractions, zero denominator, internal spaces, negative denominator, exponent notation, Unicode minus, safe-integer numerator/denominator boundaries **after reduction**, and the actual T_MIN/T_MAX bounds (−100/+100 in .30.1), including just-outside cases. A large raw fraction reducing to a safe in-range value must be tested, not rejected merely for unreduced magnitude unless the documented byte quota is exceeded.

Reuse correct host parsing logic where possible; otherwise make the compatibility parser agree on its admitted domain. Keep pure-core BigInt capability, typed gearbox limits, spin-input limits and elliptic limits as separately named validators. An `sExact` string can be syntactically canonical while already containing a rounded value: the confirmed spin defect below is an explicit exception to behavioral equivalence. `PARSE2` covers the corrected spin path and canonical serialization, including supported products, quotients, integer powers, whitespace removal, multiplication-symbol normalization and typed finite decimals. The two UI grammars are not interchangeable. Do not broaden strict packet grammar just because the UI accepts decimal entry. Compare unchanged ordinary inputs with the host; compare the defect cases with independently calculated exact values or explicit refusal, never with the buggy host result.

### Required host repair: SPIN-EXACT-001

The pinned .30.1 `parseSDirectInput` parses literals, powers and rational intermediates as JavaScript Numbers. Its `normalizeFraction` requires integer-valued Numbers, not safe integers. Rounded values can therefore be serialized into `sExact` as though exact. This is a source defect, not a new Cayley mathematical convention.

The following outputs were reproduced by executing the pinned host's own `gcd`, `normalizeFraction`, `decimalLiteralToFraction` and `parseSDirectInput` in an isolated Node context. Expected values below are the **unwrapped parse results**, before host centering modulo 2N.

| PARSE2 case | Typed input | Incorrect .30.1 exact text | Correct reduced value |
|---|---|---|---|
| P2-A | `9007199254740993` | `9007199254740992` | `9007199254740993` |
| P2-B | `3^40/7` | `12157665459056929000/7` | `12157665459056928801/7` |
| P2-C | `123456789012345678/10` | `12345678901234568` | `61728394506172839/5` |
| P2-D | `0.1234567890123456789` | `4822530820794753/39062500000000000` | `1234567890123456789/10000000000000000000` |
| P2-E | `74/3` | `74/3` | `74/3` (ordinary compatibility control) |

**Preferred implementation:** evaluate the existing admitted spin expression grammar with bounded BigInt rational arithmetic. Construct decimal numerators from digit strings, evaluate integer powers with a preflight resource bound, cross-cancel products/quotients where useful, normalize signs/gcd, and serialize the exact result. Use Number only for a separately labelled drawing value. Preserve the host's signed-literal/power semantics and grammar; do not use `eval`. Put byte, term, exponent and intermediate-bit budgets before costly allocation/exponentiation. Reject division by zero and resource-limit violations explicitly.

An acceptable smaller repair is conservative refusal of exactness whenever a literal or **any intermediate** cannot be proved a safe integer. Checking only the final rounded Number, or checking after cancellation of already-rounded operands, is insufficient. If this alternative is used, record it as a deliberate admission limitation. Every P2-A…D must either produce its true value through the exact path or be explicitly refused as exact; matching the incorrect legacy strings is a test failure.

Trace and repair the entire path `parseSDirectInput → applyDirectSInput → setSValue → centerSignedExactSpin → state.sExact`. Center from the correct exact rational using BigInt, then derive a finite display approximation. Do not pass through a Number intermediate and reconstruct the rational afterward. Distinguish the raw-input exact value from the centered captured value. Audit other writers using the same Number-based helpers, including the slider and stop paths, for unsafe values reaching exact capture. Either make their arithmetic safe/exact or block those unproved cases; do not silently expand the patch to unrelated modules.

If a syntactically valid input is outside supported exact arithmetic but a finite approximate display is retained, set `sExact=null`, show that exact capture is unavailable, invalidate old source-dependent jobs and rebuild/clear current-lane index data. Both following capture routes must then be BLOCKED. An explicitly HELD earlier record may remain visible with its original label. If the input is rejected without changing the source (for example invalid syntax or resource refusal), clearly retain the earlier captured value and label the new entry rejected; it must never appear accepted. No fallback may leave the new approximate value paired with the previous exact string.

### Selected-index propagation and tests

Source inspection confirms that `buildCurrentLiftSpecs` copies `sourceState.sExact`, `projectSelectedActualSpecs` passes current specs to `projectSignedLiftSpecs`, and the latter assigns `indexSExact=spec.sExact`. The elliptic builder then consumes the selected point's N and indexSExact. Thus the current-index lane is exposed to the parser defect even though some generated rosette/stack/fraction-stack addresses have separate construction paths. Canonical parsing downstream cannot recover the original typed value.

Add a browser test with N=3 and typed input `9007199254740993`: the correct centered spin is 3, whereas the legacy parse centers its wrong integer to 2. If the new parser admits the input, require sExact=3 and regenerated current-index indexSExact=3, then follow that point through direct-index and elliptic capture (subject to the existing elliptic setup). If the chosen safe-only parser refuses it, require the explicit refusal/inexact behavior above and no newly accepted exact address. This catches the case where a large-input error becomes a small, apparently admissible captured rational.

Test P2-A…D through the corrected actual input handler, not just the pure helper. Retain an ordinary-input regression for P2-E and the existing typed grammar. Enumerate each index lane's provenance, verify current selections/caches are refreshed after correction/refusal, and check independent generated lanes under their own arithmetic gates. Legacy imported strings without original input provenance cannot be retroactively certified as faithfully parsed; retain their source-reported provenance rather than claiming the new parser repaired their history.

M2 cannot pass until this defect is repaired or conservatively blocked in the delivered preview and PARSE2 verifies the real input/capture path. Include original reproduction and corrected outcomes as different records in the audit package.

Also test negative θ, q=1, zero t₂, negative amplitude sign, a selected pair with smaller displacement order, malformed rational input, and a synthetic huge q that permits sparse construction but forbids dense allocation. Synthetic core inputs must not be misreported as admitted host captures.

**Output:** executable core, fixture results and numerical residuals. Mathematical finite checks previously performed on scripts do not count as passing these implementation tests.

## 6. M2: capture, lifecycle, persistence and stale work

### Two capture routes

**Direct-host capture (`DIRECT_HOST_CAPTURE`):** factor the exact capture helper from actual host logic. Allow the user to choose `EXACT_LIVE_REGISTER` or `EXACT_INDEX_ADDRESS`. The latter takes N and s from the selected exact index point; the former uses the exact live snapshot. Retain t₁/t₂ rational strings and full offsets. Support m≤720, independently of the elliptic validator. Preserve exact values accepted from typed finite decimals through the host's declared input parser. Do not infer exact s from a rounded display value or reconstruct an integer from an unsafe Number. A configured curve is not required. `liftSourceSnapshot()` is globally available in the pinned host; call it directly rather than scraping controls.

**Elliptic capture (`ELLIPTIC_CAPTURE`):** use `McombEllipticLink.current.capture` and its existing admission. Preserve the curve/exact-spin/index prerequisites, m≤31, N≤10⁶, nonzero sign and existing rational limits. Read the captured N/s, not whichever controls happen to be visible. Do not weaken its validator to admit a large comb.

Implement the proposed `mcomb:cayley-source` event by **change detection in the existing update path**. Build a deterministic capture/binding signature from a fresh snapshot and the selected route/origin; compare it to the last observed signature; invalidate prior work, advance the revision and emit only when the effective signature changes. The signature includes admission status and reasons when a source is blocked, so losing sExact is observable. Include host inputs relevant to the selected binding and amplitude display; do not add camera coordinates to the mathematical signature. Keep visibility/selection notifications separate when they do not change the effective source.

Do not assume a central commit function exists or patch only individual controls. Wrap or instrument the actual render/update path so early returns and selected-index updates are covered; use a re-entrancy guard and no-op signature comparison. Check whether index preparation can change the selected point during rendering and observe the resulting state before publishing a LIVE result. CAP7's path inventory must prove coverage. No new polling or requestAnimationFrame loop is added. Existing `mcomb:transport` still triggers elliptic refresh, but a notification alone is not proof that its cached capture matches the host.

The synchronous signature comparison must not await SHA-256: invalidate immediately, then compute the export/provenance digest under the captured revision. Before accepting an async result, recheck a fresh host signature as well as sourceRevision/inputDigest. This prevents a scheduled-render gap or delayed hash from committing a stale result after a mutation. Expose this comparison through the store/job seam for deterministic tests. Invalid or mismatched state becomes BLOCKED or explicitly HELD; it never leaves the old capture labeled LIVE.

### Store and jobs

Implement an immutable snapshot plus monotonically advancing sourceRevision. Keep selected IDs and the visibility mask outside the mathematical operator. On source replacement, route change or blocking input, invalidate old jobs before their results can be committed. Every async result carries both sourceRevision and inputDigest. Test the production commit guard, not a duplicate test-only implementation.

Provide LIVE, HELD and BLOCKED display binding states without treating them as computation statuses. HELD means a labeled saved capture; import starts HELD. A blocked route must not present the previous capture as LIVE. Selection changes need not rebuild weights. Visibility changes may change capture provenance but must not change the full operator; mathematical cache keys remain separate from capture-byte hashes.

### Packet

Implement the schema's V1 envelope including captureBinding, nullable atomRecord/fcaRecord and exactDigest. Define exact field canonicalization and byte hashing explicitly. Check all redundant bindings, then recompute derived values on import. Imported claims are not trusted merely because their digest matches or their status says CERTIFIED. Render imported text as text.

When a packet contains an extension not yet implemented, preserve the original bytes for inspection but refuse to treat the unsupported extension as validated. Surface a precise unsupported-version/feature reason. An early milestone must not silently discard or falsely validate later records.

### Mandatory integration cases

| ID | Action | Required observation |
|---|---|---|
| CAP1 | Captured point N=3,s=1; live register N=5,s=2; t₂=2 | Index origin gives θ=1/3; live origin gives θ=2/5; route/origin and captured N/s are explicit |
| CAP2 | Direct route, no configured curve, m=32 and m=720 | Admitted exact operator; no accidental elliptic m≤31 dependency |
| CAP3 | Same large comb through elliptic route | Existing admission refusal and reason; no silent fallback route |
| CAP4 | Start with valid capture, then exact spin becomes unavailable | BLOCKED or explicitly HELD; no fabricated rational and no stale LIVE result |
| CAP5 | Change only visible branch mask | Full offsets, weights and spectrum unchanged; mask updates |
| CAP6 | Change selected pair c while retaining source | Selected displacement can change; unit q does not |
| CAP7 | Exercise every inventoried real mutation path for s/sExact, m, t₁/t₂, n₆, shell-derived N, route/origin and exact index selection | Fresh-snapshot signature catches every effective change in the selected source or its admission; revision advances and old results cannot remain LIVE. Record control-path coverage, not just one setter per field |
| CAP8 | Redraw, move camera or submit an equivalent/no-op exact value | No source-revision churn; presentation updates do not rebuild the unchanged operator |
| CAP9 | Enter a SPIN-EXACT-001 regression value and select the current orbit-index address | Correct exact parse/centering and regenerated indexSExact, or explicit refusal/inexact behavior; no rounded value promoted to exact through either route |
| JOB1 | Queue job A; change source; complete job B then A | Only B can update current results |
| JOB2 | Queue job A; block the source or switch route; complete A | A cannot repopulate the current panel |
| PKT1 | Export, reopen and recompute | Exact derived fields agree; reopened binding is HELD |
| PKT2 | Alter residue weights, q, captured N/s or source bytes | Binding/recomputation/hash validation rejects as appropriate |
| PKT3 | Rehash a forged derived value consistently | Still rejected by recomputation; hashing alone is not the validator |

Make JOB1/JOB2 deterministic with controllable completion order and explicit awaits, not timing guesses or long sleeps. Include completion after a source mutation but **before its scheduled redraw/hash finishes**; fresh comparison must still reject the old result. Exercise both a unit-level scheduler and the integrated event path. For CAP1, if the UI cannot naturally hold the exact fixture simultaneously, use a documented adapter seam for precise values and add a real-browser mismatch case available through actual controls; label which test exercises which layer. CAP7 applies to changes relevant to the chosen origin: changing an unrelated live N while following a fixed exact index N does not replace that captured N. Explicit HELD mode retains its record with the correct label rather than pretending to follow mutations.

Check host regression after wiring the shared helper. Compare the old and refactored source capture on supported unchanged states. Run at least one existing linked elliptic export/import path and verify no new BSD evidence is written by opening or selecting the inspector.

**Output:** the first audit-ready build, containing the real core, both routes, binding-state behavior, packet replay and results for CAP/JOB/PKT. Include a minimal readout or test harness if the graph is not ready. Do not claim an integrated visualization yet.

## 7. M3: first usable visualization

### UI work

1. Add a collapsible Cayley inspector with route/origin, captured N/s, m, q, current binding state and any admission reason. Keep technical provenance in an expandable detail area.
2. Render the weighted graph with stable residue IDs, labelled loops and edge weights. Occupancy of the selected tooth multiset is separate from operator edges. A residue with several labels offers all those labels.
3. Link tooth selection to the existing phasor selection mechanism. Inspecting an unoccupied vertex must not manufacture a tooth. Use guards to avoid reciprocal event loops.
4. Draw K_m over turns and quotient samples, identifying h/q as the captured physical sample. Selecting a sample overlays its character phases; it does not move s. Provide an explicit operator selector for L versus its valid simple conversion.
5. Show complete versus partial spectrum status, sampled minimum and any analytic sampling bound. First release may show the analytic formula and numerical endpoints without a certified-interval badge. Do not claim rigorous numerical enclosure unless interval arithmetic is actually implemented.
6. Add the auxiliary sampling control p with separate labels and state. It does not change physical q, D₁ or coincidence weights.
7. Implement local graph inspection beyond display budgets. Exact q and sparse tooth weights remain available even when the whole graph is not drawn. Omitted vertices/edges must be disclosed.
8. Add export/reopen controls and HELD/live-source rebinding. Exports use captured data, not values reread independently from controls at export time.

### Browser gate

Load the actual assembled HTML. Exercise wheel/strip layouts, collision selection, h≠1, odd identity shift, source mismatch, route change, inexact-source blocking, held import, hidden masks, large combs and above-budget q. Repeat JOB1/JOB2 through the panel's real result handler.

Check a narrow screen and a desktop layout, keyboard selection, touch-sized controls, readable light/dark contrast, and the host camera/phasor interaction. Inspect console errors. Browser execution failures or unavailable dependencies are reported as blocked checks, not transformed into passes by a mock DOM.

Re-run the bounded host baseline regression and linked export smoke test. Avoid an unlimited unrelated regression campaign; broaden testing only for a concrete affected path.

**Output:** first usable integrated preview, build hash, source diff, runnable tests, result report and audit handoff. This release must meet schema §12's first-release criteria.

## 8. M4–M7: implement the remaining specified views

**Mount decision:** these later panels live in the same Monodromy Cayley preview, under its atom/context inspector. The supplied atom viewer remains an unmodified pinned reference; no second patched viewer or cross-window synchronization is required by this plan. Extract the pure `divisorPosition` function from that pinned source into the test harness with its provenance and only its actual dependencies; do not execute the entire atom UI merely to obtain it. A tested build-time extraction or verbatim reusable function can supply the implementation comparison. Do not introduce a manually maintained second formula and call it an actual-source test. This decision is recorded now but M4–M7 are outside the first M0–M2 run.

### M4 — atom adapter and cosets

- Implement exact exponent tuples, group size, selected-step order and orbit/coset labels. Presets: Div(6), Div(12), Div(36), with Div(720) as the larger example.
- Reuse the source's factor order, zero-based anchors and chirality conventions. Validate factorization inputs within a stated supported domain; do not infer exact factorization from an approximate display.
- Show every coordinate contribution, resultant, centroid and height. Compare the factorized formula against a direct sum using the actual source `divisorPosition`, where callable, rather than only another port of the formula.
- Default to shared offsets across atom and torsion records. Admit a cyclic isomorphism or quotient homomorphism only when its order condition holds and the map is declared.
- Keep exact address equality, exact character-phase equality and numerical planar proximity distinct. Treat the known diagonal collapses symbolically when claiming exact coincidence.
- Gate on A1–A6, an atom character with a nontrivial kernel, a zero step, all three chiralities, coset changes and a cyclic ambient group with a nongenerating step. Respect the coset enumeration budget.

### M5 — local structure and certificates

- Implement explicitly named integer, quotient-simple and atom-strand contexts. Do not derive unweighted clique claims from L when conversion is unavailable.
- Build H=N(0)'s induced graph, triangle counts and opposite-neighborhood boundaries. General t uses the full-graph definition.
- Implement witness plus lower/upper bounds, cancellation and resumable bounded search. A complete clique check must verify both witness adjacency and the justification of the matching upper bound.
- Implement position-dependent lifting thresholds, not merely a universal 3M/4M display. Preserve the spectral-sampling caveat.
- Gate on S1/S2, small brute-force clique comparisons, general-t membership, and timeout/partial-result behavior. Fixture S2 is a structure-core experiment with explicit P; it does not force a free-frequency host UI into this release.

### M6 — histories and count patterns

- Generate words of original tooth labels; do not merge distinct histories because their quotient actions agree. Show exact endpoints and prefix states.
- Fold histories only on request, retaining multiplicities. Enforce depth/node caps visibly.
- Add integer-cover and finite-quotient count recurrences, optional reduction modulo ell, and their declared domains. ell is distinct from q and any curve-reduction prime.
- Gate on W1/W2, exact folding of integer counts into a small quotient, multiplicity-preserving loops, and truncation status. Compare spectral evolution only in the complex-valued lane where it is defined.

### M7 — FCA and order-aware semantics

- Implement schema §15's context IDs and their actual incidences. Default to LE for ascending divisor labels; GE shows its reversal. Keep context, graph relation and transform selections distinguishable.
- Build strands separately from nominal hyperplane attributes. Preserve a selected divisor across context changes; a selected concept extent is a different selection type.
- Declare the nominal translation action; do not treat ordinal translation as an automorphism. Validate allowed record combinations.
- Implement the B Bᵀ=rI+A certificate with a zero-sum attaining witness. Do not claim equality from positive semidefiniteness alone.
- Provide GROUP_WALK, DIVISIBILITY_ASCENT and ORDER_ANNOTATED_GROUP_WALK as distinct semantics. Ascent changes the operator; it cannot keep a cyclic-Fourier badge by inheritance.
- Gate on the four context-count examples, order orientation, incidence matrix shapes, nullspace witnesses and nonzero translations failing to preserve the least element. Handle N=1 explicitly and respect concept-enumeration budgets.

## 9. Test and audit record

Before finishing each milestone, update a traceability table mapping each schema fixture/requirement to implementation symbol, test ID and outcome. Use `PASS`, `FAIL`, `BLOCKED` or `NOT_RUN`; report expected values, actual values and numerical tolerances/residuals where relevant. Do not count a skipped or mocked browser check as a real integrated pass.

Record input pins, output hashes, module hashes, runtime/tool versions, exact test commands, and any random seeds. Separate:

- spec arithmetic previously checked;
- implementation tests executed on this build;
- real-browser integration checks;
- independent external audit reports, if supplied later.

Fable's schema review is not a test result for future code. Deliver enough code and deterministic fixtures for an auditor to rerun the checks independently. A hash proves which artifact was checked, not its correctness.

Recommended commands to implement and document (names may adapt to the repository):

```text
npm run verify:pins
npm run test:core
npm run test:capture
npm run test:packet
npm run build:viewer
npm run test:embedded
npm run test:browser
npm run audit:package
```

`test:embedded` must establish that the assembled HTML runs the same module bytes or deterministic bundle tested above, then smoke-test its public API. This closes the gap where a correct source module is never actually loaded by the delivered viewer. These commands are a requested implementation interface, not commands already present in the supplied files.

## 10. Required milestone deliverables

At M2, M3 and later release checkpoints provide:

1. Integrated preview or, for M2, a clearly labelled core/adapter build.
2. Modular source and the reproducible assembler/build command.
3. Fixture definitions and executable tests.
4. Machine-readable test results and concise audit summary.
5. Baseline-to-build patch/diff and input/output/module hashes.
6. One exact exported capture and a command or UI sequence that reopens it.
7. A traceability/limitations file listing implemented scope and unimplemented extension points.

Package these in a portable folder or zip for the reviewer. Source files and the generated viewer must remain readable without access to this conversation. In a git-backed project, record commits and keep the working changes scoped; otherwise include the exact baseline filenames and patch instructions. Do not publish or send the package to other people as part of this implementation task unless explicitly requested.

## 11. Later extension queue

These features retain their schema status as later extensions. Give each its own domain, exact map and acceptance fixtures when scheduled:

- Compatible quotient towers: declared divisibility chain of moduli; reduction maps and commuting translation sums; new exact physical source at each physical level.
- Nested divisor intervals: [u,v]→Div(v/u) preserves order, not automatically the parent's cyclic action.
- Doily and Farey objects: explicit incidence/contact maps and relation IDs; no inherited comb spectrum.
- Free positive-frequency sets, including Div(N) as additive labels: new integer-record variant and direct weight checks, not canonical m-comb shortcuts.
- CSV exports and stronger certified numerical enclosures.

Do not add empty controls implying these features already work. Keep ordinary product flows focused on graph, address, phase and selection; expose provenance and derivations in expandable inspection views.

## 12. Codex execution prompt

Use this with the three pinned inputs attached:

> Implement **M0 through M2 only** using the pinned schema revision v0.1-C and this implementation plan revision 3. Locate inputs by their full hashes, accepting renamed copies, and record the resolved paths in a manifest. Preserve the baseline HTML and produce a separate core/adapter preview with a reproducible build. Reproduce and repair or conservatively block the documented SPIN-EXACT-001 host defect before accepting exact captures; PARSE2 must use true rational values or explicit refusal, not buggy legacy outputs. Implement the exact core, both capture routes, snapshot-change detection in the existing update path, fresh-host commit guards, source lifecycle and export/replay. Run Q/P and large-comb fixtures, PARSE1 compatibility and corrected PARSE2 tests, CAP1–CAP9 and deterministic stale-result tests, including mutation-before-redraw and spin-parser-to-selected-index propagation. Use the actual modules and assembled host for integration checks. Deliver the M2 build, source, tests, results, hashes, diff, replay fixture, defect/fix record, control-path coverage and limitations, then **stop for the independent code audit**. Do not begin M3–M7 in this run. Keep the schema fixed and document semantic deviations. Distinguish specification arithmetic, implementation tests, browser checks and external audit. Do not mark unimplemented or untested features complete.

## 13. Plan preparation status

This handoff was prepared against the locally available v0.1-C bytes; their full SHA-256 matches the reviewed `46c7f214d606…` baseline. The schema's source interfaces, budgets, fixture IDs and delivery sequence were read while preparing it. No viewer implementation was performed as part of writing this plan, and none of the proposed code/test commands above has been represented as already passing.

Revision 2 incorporates the practical review: hash-based role resolution tolerates filename aliases; fresh-snapshot detection replaces the assumption of a unique host commit site; parser compatibility distinguishes typed exact decimals from displayed approximations; later atom/FCA panels have a single declared mount; and the first run stops at M2. Source reads confirmed the global snapshot function, `matchesHost` pattern, render early returns, gearbox grammar and bounds, and absence of external script tags. CAP7 coverage and parser-equivalence results are required future implementation evidence, not claims made by this plan.

Revision 3 records SPIN-EXACT-001, reproduces all four reported host misparses plus the unchanged 74/3 control, requires repair/refusal before M2, replaces buggy-parser equivalence with exact-value/refusal tests, and adds CAP9 for propagation through centering and current-index capture. The original source and schema remain unchanged; the repair is work required of the implementation preview. The propagation finding is grounded in source reads, not a claim that an end-to-end browser test has already run.
