# Rule 30 theorem library

One Lake project per version, kept identical on nucleus and scout at `~/rule30_theorem_library/vN`. It holds the frozen kit 7d665044 sources and every verified new theorem file, byte-identical to its delivery. Build only on nucleus or scout, never on neo. No Wolfram.

## v1 (2026-10-30)

- **Contents:** 42 theorem files from S4a stages A–D (#1039, #1054, #1058, #1061), the n6 y-reflection successor (#1063), S4d (#1070), S4e (#1077) and S4f (#1086). Each file has exactly one source version across all deliveries. S4b (#1065) is source analysis with no Lean; S4c (#1067) has no Lean modules.
- **Pins:** Lean v4.35.0, Mathlib `56a005855ea1…`, kit `Rule30PrizeKit_verifier_7d665044_20261027` (286 files).
- `SHA256SUMS`: 332 entries, sha256 `8a73afe3ddd0755dec31d5cf5ade07bd9a3ab0ccc090b86aa5e92065e82c6a5e`.
- `LIBRARY_MANIFEST.json`: `d56fdcade006af958ce8eb223c9526e757c4bbbc829f1bbb9b7edd19711da7c6`.
- `lake-manifest.json`: `1f0e0c1c0a06e2a9ecc117aed82f7a8ee62b418235e10686d3bda2d6986ea527`.
- **Libraries:**
  - `Rule30LibKitExtensions`: verified files in the `Ruliology` namespace that are not kit files. Declared before the kit library so that Lake resolves them here.
  - `Ruliology`: the kit's `kit/lean`.
  - `Rule30Lib`: everything else.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,616 jobs (nucleus 22 s, scout 29 s, at nice 19).
  - `tools/AxiomCheck.lean` over all 42 modules: `AXIOMS_OK modules=42 constants=1045`. Every axiom is one of propext, Classical.choice and Quot.sound, with no `sorryAx` and no `ofReduceBool`.
  - The two reports are identical apart from the timing line: sha256 of all lines but the last is `25b3d3b12b525c46cb515399a6647afa5f32f509560042e272ffbde7963ca307`.
  - Logs: `v1_build_nucleus.log`, `v1_build_scout.log`, `v1_axioms_nucleus.txt`, `v1_axioms_scout.txt`. Nucleus's first attempt failed on module resolution: `v1_build_nucleus_attempt1.log`.

## v2 (2026-10-30, saphir: "Library v2, then S4h")

- **Added:** S4g (#1094; `s4g_left_black_pins_v0_1_20261030`, MANIFEST.json 829c924b…). That's 4 files: `FVLTS4gLeftScreenV1`, `FVLTS4gForcedBitCountV1`, `FVLTS4gLBEImplicationV1` and the root `S4g`.
- **Compared with v1:** 0 changed and 0 dropped. All 42 v1 theorem files and all 286 kit files are byte-identical; the S4d/S4e files that S4g inherits match v1's. `lake-manifest.json` is identical to v1's.
- `SHA256SUMS`: 336 entries, `ab00e6da390017ea655070f6d5461c54354ec158d7ed5cf6c47ada57fee0e64a`.
- `LIBRARY_MANIFEST.json`: `03d6cb7d9ab051ae5852ab362af40d0b273b78240ac51a9d1b292669ef95dbff`. It includes `comparison_with_previous`.
- `lake-manifest.json`: `1f0e0c1c…`, same as v1.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,620 jobs (nucleus 23 s, scout 30 s).
  - `AXIOMS_OK modules=46 constants=1141`.
  - The two reports are identical apart from the timing line, `6ec7d03032143c6cbdca9f19e51d4c443f539cc041370a49f3f826996b1e1c8e`. The 42 v1 module lines match the v1 report exactly.
- **Frozen:** v2, `.lake` included, is fully write-protected on both hosts.
- **Assembled with** `tools/resolve_closure_vN.py` and `tools/assemble_vN.py`, from `deliveries_v2.json`.

## v3 (2026-10-30, S4h and S4h-G released by skeleton)

- **Added, 5 files:**
  - Codex S4h (#1114; `s4h_certificate_recursion_v0_1_20261030`): `FVLTS4hInfinitePinsV1` dcd01220…, `FVLTS4hFiniteTailV1` ce3b7a17…, `FVLTS4hAlternatingZeroV1` 7ebd19fb…, and the root `S4h`.
  - Gemini S4h-G (#1115): `S4h_G_CantorShiftV1` 79586ea2…, namespace `FVLT.S4hCantorShiftV1`. It is the first delivery not made in Codex's tree. It was copied from scout's `~/s4f_compute/gemini/` into `staging/s4hg_scout_study_20261030/`, which is read-only and holds a `STAGING_RECEIPT.json`. Its hash matched skeleton's pin.
- **Compared with v2:** 0 changed and 0 dropped. `lake-manifest.json` is the same as v2's.
- **No name clashes:**
  - Module names are distinct.
  - Namespaces are distinct: `FVLT.S4hCantorShiftV1` versus Codex's `FVLT.S4hInfinitePinsV1`, `FVLT.S4hFiniteTailV1` and `FVLT.S4hAlternatingZeroV1`.
  - The axiom check imports all 51 modules into one environment, which would fail on any duplicate declaration. It didn't.
- `SHA256SUMS`: 341 entries, `4fda9f326616e9574a52357cf8ccfdbdb186530c9e977b93c07b316955e35c0d`.
- `LIBRARY_MANIFEST.json`: `601777dbda3563c63ce12878c1557062990ce8ac9dd9ea9f2de05a227ba43d15`. It now records a producer per delivery.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,625 jobs (nucleus 25 s, scout 32 s).
  - `AXIOMS_OK modules=51 constants=1267`.
  - The two reports are identical apart from the timing line, `3393aeed6e32f962a3515bd68005c20311f1d7b427f1fb85776ea353f38d71a7`. The v2 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v1, v2 and v3, each with check=OK.
- **Tools:**
  - `resolve_closure_vN.py` and `assemble_vN.py` now also look in `staging/`. A delivery row may carry a third field naming its producer.
  - The v2-era copies are kept as `*_v2tool.py`.

## v4 (2026-10-30, S4i and S4i-G released by skeleton)

- **Added, 4 files:**
  - Codex S4i (#1127, #1141): `FVLTS4iResidualV1` c2d3ef00… (79 constants), `FVLTS4iUniformPaddingV1` ad64c134… (11), and the root `S4i` 1f00e703….
  - Gemini S4i-G (#1139): `S4i_G_UniformLatchV1` 95e82908… (54 constants; axioms propext and Quot.sound).
- **Staging:** both deliveries are staged from their neo seat areas into `staging/s4i_v1_delivered/` and `staging/s4i_g_v1_delivered/`. Only the delivered files were copied, plus pin files and a `STAGING_RECEIPT.json`. Left out:
  - Codex's `UniformPadding.lean` and `UniformPaddingFixture.lean`;
  - Gemini's 8 `prior_art_*.lean` files.

  The nucleus mirror `~/fvlt_formalization_20261028/s4i_v1` lacks `FVLTS4iUniformPaddingV1.lean`, so the neo copies, whose hashes match skeleton's pins, were used.
- **Compared with v3:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- **No name clashes:** module names and namespaces are distinct (`FVLT.S4iResidualV1`, `FVLT.S4iUniformPaddingV1`, `FVLT.S4iUniformLatchV1`). The all-module import found no duplicate declarations.
- `SHA256SUMS`: 345 entries, `3c97efc89ca38baeb6ed7f7e5ea5a02f5f18d59ef9b9934ee446e95ec483b9df`.
- `LIBRARY_MANIFEST.json`: `485f02798fb9732c49b255ee961996820962cb35d9fbe89c81d37491a20af6e6`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,629 jobs (nucleus 26 s, scout 34 s).
  - `AXIOMS_OK modules=55 constants=1411`.
  - The two reports are identical apart from the timing line, `63d290c7d44420e9019f5c6ad081d512b20827eac33781564506556793548c7e`. The v3 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v1–v4, each with check=OK.

## v5 (2026-10-30, S4j and S4j-G; skeleton comparison S4J_COMPARISON_v0_1.md f2b177f6…)

- **Added, 2 files:**
  - Codex S4j (#1154): `FVLTS4jBoundedDeathV1` 459decbd… (23 constants; axioms propext, Classical.choice, Quot.sound).
  - Gemini S4j-G (#1155): `S4j_G_UniformCascadeV1` 3b0aad2e… (83 constants; axioms propext, Quot.sound; namespace `FVLT.S4jUniformCascadeV1`).
- **Staging:** both are staged from the neo seat areas into `staging/s4j_v1_delivered/` and `staging/s4j_g_v1_delivered/`, each with a `STAGING_RECEIPT.json`. Their hashes also match the nucleus copy (Codex) and the scout copy (Gemini). Left out:
  - Codex's `BoundedDeath.lean`, `BoundedDeathFixture.lean` and `LatchStatements.lean`;
  - Gemini's `evidence/` copies.
- **Compared with v4:** 0 changed and 0 dropped. `lake-manifest.json` is the same. No clashes.
- `SHA256SUMS`: 347 entries, `967991fa219d5078160b3d879b86767729dcdfa3a3471463ad88f2f6a2fdde1d`.
- `LIBRARY_MANIFEST.json`: `95854f3a170921804337fa41c1e1f26a0cc26b501d5a3626d7f29af0ade89d39`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,631 jobs (nucleus 27 s, scout 36 s).
  - `AXIOMS_OK modules=57 constants=1517`.
  - The two reports are identical apart from the timing line, `c38bf12f535d8cb7a37dc9cd753a1f32adb22d1e17a39b91ed2f8f66f3a98b61`. The v4 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v1–v5, each with check=OK.

## v6 (2026-10-30, S4k and S4k-G; skeleton comparison S4K_COMPARISON_v0_1.md cca1c990…)

- **Added, 4 files:**
  - Codex S4k (#1173):
    - `FVLTS4kCoreV1` 0389381d…: 23 constants; axioms propext and Quot.sound. It imports `FVLTS4jBoundedDeathV1`, and through it S4h.
    - `FVLTS4kCollapseV1` 586ff28a…: 10 constants.
    - `FVLTS4kDomReductionV1` 6b6462de…: 27 constants.
  - Gemini S4k-G (#1170): `S4k_G_DecreasingMeasureV1` cb5b6f9b…, 98 constants; axioms propext and Quot.sound; namespace `FVLT.S4kDecreasingMeasureV1`.
- **Staging:** `staging/s4k_v1_delivered/` and `staging/s4k_g_v1_delivered/`. The hashes match the neo seat copies, nucleus `s4k_v1/k1_proofs/` and scout. Left out:
  - `K1.lean`, `K1Fixture.lean` and the 4 `PRIOR_ART_*.lean` files;
  - Gemini's `evidence/` copy.
- **Compared with v5:** 0 changed and 0 dropped. `lake-manifest.json` is the same. No clashes.
- `SHA256SUMS`: 351 entries, `91887e635dc6b7493380de0ff74e594024a96862d4fbbce6d6d930989b77e918`.
- `LIBRARY_MANIFEST.json`: `226e2212dbecba86c7b8c8504e22dfffa5f5a57f7032a10b2af9f9b205827d60`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,635 jobs (nucleus 29 s, scout 37 s).
  - `AXIOMS_OK modules=61 constants=1675`.
  - The two reports are identical apart from the timing line, `ebca70a56fdef6da40a99099f01ba03744f7ea062f07a076959bd48458945e29`. The v5 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v6 with check=OK.

## v7 (2026-10-30, S4l and S4l-G; skeleton comparison S4L_COMPARISON_v0_1.md 6fc777d1…)

- **Added, 2 files:**
  - Codex S4l (#1191): `FVLTS4lZeroBoundaryV1` e14ea888…, 32 constants; axioms propext and Quot.sound. It imports `FVLTS4kCoreV1` and the kit's `Rule30ZeroBoundary`.
  - Gemini S4l-G (#1196): `S4l_G_ZeroBoundaryPotentialsV1` b8cf4f6b…, 84 constants; axioms propext, Classical.choice and Quot.sound; namespace `FVLT.S4lZeroBoundaryPotentialsV1`.
- **Staging:** `staging/s4l_v1_delivered/` and `staging/s4l_g_v1_delivered/`. The hashes match the neo seat copies, nucleus `s4l_v1/part1/` and scout. Left out:
  - `Part1.lean`, `Part1Fixture.lean` and all 8 `SOURCE_*.lean` files;
  - Gemini's `evidence/` copy and its `prior_art_*.lean` files.
- **No name clashes:** the two modules define single-black and zero-boundary notions independently, in separate namespaces, and share no declaration short names (Codex 15, Gemini 23). The all-module import passed.
- **Compared with v6:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 353 entries, `68bc215f4dac6c51e93d14140676715a48371f36db77178d28900a52b01aeb5a`.
- `LIBRARY_MANIFEST.json`: `ea1b21b76b939e41cb08b5b330dfe36d5b3bcce45b7508a15c6b21f1f61e5bec`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,637 jobs (nucleus 30 s, scout 40 s).
  - `AXIOMS_OK modules=63 constants=1791`.
  - The two reports are identical apart from the timing line, `cc9f40867b755300c8f6b704aa4ff1ad39eb67b51c1095e536fdcd24515b22ca`. The v6 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v7 with check=OK.

## v8 (2026-10-30, S4m Part A and S4m-G; skeleton comparison S4M_COMPARISON_v0_1.md 8ff48188…)

- **Added, 5 files:**
  - Codex S4m Part A (#1214):
    - `FVLTS4mCoordinatesV1` 82733925…: 67 constants.
    - `FVLTS4mOddPhaseThetaV1` 40216021…: 11 constants.
    - `FVLTS4mResidualV1` d4fddc2e…: 30 constants. Its namespace is the bare `FVLTS4mResidualV1`, without the `FVLT.` prefix.
    - `FVLTS4mMachineBridgeV1` 5d250bd4…: 9 constants.
  - Gemini S4m-G (#1218): `S4m_G_PeriodTwoResidualsV1` 5b2989dc…, 88 constants, namespace `FVLT.S4mPeriodTwoResidualsV1`.
  - All five use only propext, Classical.choice and Quot.sound.
- **Staging:** `staging/s4m_v1_delivered/` and `staging/s4m_g_v1_delivered/`. The hashes match the neo seat copies, nucleus `s4m_v1/part_a/` and scout. Left out:
  - `PartA.lean`, `PartAFixture.lean` and the 6 `SOURCE_*.lean` files (including `SOURCE_PREDECESSOR_00_*`);
  - Gemini's `_attempt1` and `_attempt2` copies.
- **No name clashes:** the two seats share no declaration short names (Codex 71 across 4 files, Gemini 56), and the all-module import passed.
- **Compared with v7:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 358 entries, `2124f3a69103e6bf79f9e151b6d7093338869dab6bf72f048028e7698dfcedea`.
- `LIBRARY_MANIFEST.json`: `92746b7cd4b3594a86ed12acf89449f1677c7d5d873e6b68e45177947ec13aed`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,642 jobs (nucleus 34 s, scout 43 s).
  - `AXIOMS_OK modules=68 constants=1996`.
  - The two reports are identical apart from the timing line, `403d77401282f886536da52a5b218f8f21089970920d2b0ecd88aee5b795b713`. The v7 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v8 with check=OK.

## v9 (2026-10-31, S4n and S4n-G; skeleton comparison S4N_COMPARISON_v0_1.md 348fabaf…)

- **Added, 2 files:**
  - Codex S4n (#1251): `FVLTS4nShellTransportV1` 3707e37f…, 43 constants. It imports `FVLTWovenEvolutionV1`, which has been in the library since v1.
  - Gemini S4n-G (#1252): `S4n_G_PeriodTwoTargetIV1` e71fc436…, 172 constants, namespace `FVLT.S4nPeriodTwoTargetIV1`. It imports `S4m_G_PeriodTwoResidualsV1`.
  - Both use only propext, Classical.choice and Quot.sound.
- **Staging:** `staging/s4n_v1_delivered/` and `staging/s4n_g_v1_delivered/`. The hashes match the neo seat copies, nucleus `s4n_v1/initial_transport/` and scout. Left out:
  - `TransportFixture.lean`, `IndependentFVLTReplay435.lean` and `FVLTS4nShellTransportV1_ATTEMPT_01.lean`;
  - Gemini's `_attempt1` and `_attempt2` copies.
- **No name clashes:** the two share no declaration short names (Codex 22, Gemini 113), and the all-module import passed.
- **Compared with v8:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 360 entries, `e980ae7b2020e5a3e0014fdab17b7c5afdd7fa1a08f19d483d37657b87328548`.
- `LIBRARY_MANIFEST.json`: `03e53912655009f180ecaa9b9c491a9339f97eae664bc4819370c29a89815fb9`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,644 jobs (nucleus 35 s, scout 47 s).
  - `AXIOMS_OK modules=70 constants=2211`.
  - The two reports are identical apart from the timing line, `21a82b4ca4bec841333c5d95e7da4fa1a2c6d844a5ca297fbe5e2e81aa184cc3`. The v8 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v9 with check=OK.

## v10 (2026-10-31, S4n descriptive tranche plus FVLT-H1 projectors)

- **Added, 5 files:**
  - Codex S4n descriptive tranche (#1264; DESCRIPTIVE_FINAL_MANIFEST.json ced76d61…):
    - `FVLTS4nPaddingWalkV1` c91d67ae…: 39 constants.
    - `FVLTS4nHarmonicTransportV1` a6306ef4…: 19 constants.
    - `FVLTS4nPrimeReadoutV1` 7f428966…: 34 constants.
  - Their dependencies from FVLT-H1, Gemini's Milestones A and B (#914, #915, 2026-10-28), included **unchanged**:
    - `FVLTPeriodProjectorsV1` 1d559451…: 69 constants.
    - `FVLTConductorProjectorsV1` f1cb7f30…: 46 constants.
  - All five use only propext, Classical.choice and Quot.sound.
  - Both historical modules compiled unchanged against the v10 tree; no repair was needed.
  - Credit for the projectors: the FVLT framework (assembly by Robin Miller; its components are classical results of others).
- **Staging:** `staging/s4n_v1_descriptive_delivered/` and `staging/fvlt_h1_projectors_delivered/`. The hashes match neo and nucleus `s4n_v1/descriptive/{A,B,C}`. Left out:
  - `FVLTRule30WindowBridgeV1`, which was used for comparison only;
  - attempts, fixtures, audit harnesses and `RUN_DESCRIPTIVE.py`.
- **Name clashes:**
  - The all-module import passed, so no two declarations share a full name.
  - The new modules share these short names with the rest of the library and the kit, in different namespaces: `blackCount`, `block`, `J`, `P`, `periodic_add_mul`, `phase`, `Q`, `spin`.
  - The projector modules declare their namespaces under `Ruliology.CellularAutomata.FVLT…ProjectorsV1`. So a file that opens both `Ruliology.CellularAutomata` and a projector namespace sees ambiguous `P`, `Q` and `periodic_add_mul`. Qualify those names in such files.
- **Compared with v9:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 365 entries, `72014a5e9825de07e094002c7f69de0be345f61b979d6238cd74cdbb8c8c781d`.
- `LIBRARY_MANIFEST.json`: `8b7f355f1b0afede8e974f8387f7bad1f1a5045f00bb9babe26374fe081bab8c`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,649 jobs (nucleus 36 s, scout 47 s).
  - `AXIOMS_OK modules=75 constants=2418`.
  - The two reports are identical apart from the timing line, `e45f4caf4d03afbe4c230d02244b11e322e9b37708c5333b49099591af4ef00d`. The v9 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v10 with check=OK.

## v11 (2026-10-31, S4o-G)

- **Added, 1 file:** Gemini S4o-G (#1270): `S4o_G_PeriodTwoFiniteStateV1` 4ad8e066…, 207 constants, namespace `FVLT.S4oPeriodTwoFiniteStateV1`.
  - The module-level union of axioms is propext, Classical.choice and Quot.sound.
  - It imports `S4n_G_PeriodTwoTargetIV1`.
- **Staging:** `staging/s4o_g_v1_delivered/`, with Gemini's `MANIFEST.json` and a `STAGING_RECEIPT.json`. The hash matches the neo seat copy and scout. Left out: the `_attempt1` copy and the attempt1-to-attempt2 `.diff`.
- **No name clashes:** none of its 85 short names appears anywhere else in the library or the kit, and the all-module import passed.
- **Compared with v10:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 366 entries, `af9a7003eca64b45236471bb48d23f4da67fe9f9e9216fd9624ed88b51062e09`.
- `LIBRARY_MANIFEST.json`: `d0264eeafa0e73132e5d0b9018e01940c12cc49290c92f908243d1ea0e2d16ed`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,650 jobs (nucleus 37 s, scout 53 s).
  - `AXIOMS_OK modules=76 constants=2625`.
  - The two reports are identical apart from the timing line, `0c50936ec5d369c4fba48e4125ef9a88cfc15484a13a9c5e0fba1e722c9446d8`. The v10 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v11 with check=OK.

## v12 (2026-10-31, helix and mcomb)

- **Added, 3 files** (Codex, #1280; FINAL_MANIFEST.json b79e7a2f…):
  - `FVLTHelixFrameV1` e40958c3…: 62 constants. Imports `FVLTCliffordGeometryV1`.
  - `FVLTHelixGearboxV1` 18aac2aa…: 76 constants. Imports `FVLTHelixFrameV1`, `FVLTGearboxV1` and `FVLTHopfClockBridgeV1`.
  - `FVLTMCombHelixV1` 227dd5a6…: 34 constants.
  - All use only propext, Classical.choice and Quot.sound. Namespaces: `FVLT.HelixFrameV1`, `FVLT.HelixGearboxV1`, `FVLT.MCombHelixV1`.
- **Staging:** `staging/helix_mcomb_v1_delivered/`. It is deliberately not named after the nucleus folder `helix_mcomb_v1_20261031`, which also holds a fixture and a replay harness. Left out: `HelixFixture.lean`, `IndependentFVLTReplay435.lean`, `EVIDENCE/`, `INITIAL_SOURCES/` and `RUN_HELIX.py`.
- **Name clashes:**
  - None with the existing `FVLTGearboxV1` (namespace `FVLT.GearboxV1`): there are no shared short names.
  - The all-module import passed.
  - Eight generic short names also appear elsewhere, in different namespaces:
    - `add`: Rule30XorRigidity;
    - `advance` and `advance_zero`: Rule30PackedReconstruction;
    - `branch`: Rule30ZeroBoundary;
    - `offset`: FVLTWovenCanonicalV1;
    - `phase`: FVLTAlphaAmplitudeV1, FVLTS4kCoreV1 and FVLTS4nPaddingWalkV1;
    - `rotate`: Rule30Predecessors;
    - `walk`: FVLTWalkTiltV1.

    Qualify these names if both namespaces are open.
- **Compared with v11:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 369 entries, `9bc5a6878cc1d88ce9c7f2f26234992dca47735daff8694fd6bd7b41f52ad341`.
- `LIBRARY_MANIFEST.json`: `2b970094e7a7bae9d9de434503a5bc8a0dd27333455c7d63fd06859b4ef6f350`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,653 jobs (nucleus 37 s, scout 50 s).
  - `AXIOMS_OK modules=79 constants=2797`.
  - The two reports are identical apart from the timing line, `c4026b95809505241883265092cbd875635c385601748ae55d98ba181936b83e`. The v11 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v12 with check=OK.

## v13 (2026-10-31, S4q)

- **Added, 2 files** (Codex S4q, #1298; FINAL_MANIFEST.json 06334a81…):
  - `FVLTS4qSpinGateV1` fbfd5567…: the accepted successor, not INITIAL_SOURCES d3526e21. 52 constants. Imports `S4n_G_PeriodTwoTargetIV1` and `FVLTWovenEvolutionV1`.
  - `FVLTS4qGatePhaseV1` 5edac3c9…: 8 constants. Imports `FVLTS4qSpinGateV1` and `FVLTHelixGearboxV1`.
  - Both use only propext, Classical.choice and Quot.sound. Namespaces: `FVLT.S4qSpinGateV1`, `FVLT.S4qGatePhaseV1`.
- **Staging:** `staging/s4q_v1_delivered/`. Left out:
  - `S4qFixture.lean`, `IndependentFVLTReplay435.lean` and `FVLTS4qSpinGateV1_INITIAL.lean`;
  - `INITIAL_SOURCES/` and `EVIDENCE/`.

  `JointAxioms.lean` is not in the seat folder.
- **Name clashes:** none at full-name level; the all-module import passed. Short names that recur in other namespaces:
  - `spin`: also in `FVLTS4nPrimeReadoutV1` and `S4n_G_PeriodTwoTargetIV1`.
  - `spin_false`, `spin_true`, `spin_xor`: also in `S4n_G_PeriodTwoTargetIV1`.
  - `spin_square`: also in `FVLTS4nPrimeReadoutV1`.
  - `rowStep`: also in the kit's `Rule30EtherSingleCellAux`.
  - `gate`, `rule30` and `rule150` are new to the library. `phase` is not defined in S4q.
- **Sign conventions for `spin`:**
  - `FVLT.S4qSpinGateV1.spin` is defined as the real cast of `FVLT.S4nPeriodTwoTargetIV1.spin`, an `Int` with `true ↦ -1`, `false ↦ 1`. The two agree by construction.
  - `FVLT.S4nPrimeReadoutV1.spin` (v10) uses the **opposite** sign, `true ↦ +1`, and works on sequences `ℕ → Bool`.
  - Don't mix the two without converting.
- **Compared with v12:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 371 entries, `ea9236b0b3b7a099aa2cb716eada0f2de74cc40e709c735bc183ba48c4d0ad1a`.
- `LIBRARY_MANIFEST.json`: `b57fad7b4972a6540431db6a59b141e90e9e76ae92af80b8b33d0b858cbc5a48`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,655 jobs (nucleus 39 s, scout 52 s).
  - `AXIOMS_OK modules=81 constants=2857`.
  - The two reports are identical apart from the timing line, `64f5512a0696bc3988221a38bbc3c8ac8d7a220ef6e0f61bdd91e57f52471b44`. The v12 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v13 with check=OK.

## v14 (2026-10-31, S4p-G)

- **Added, 1 file:** Gemini S4p-G (#1301): `S4p_G_PeriodTwoSubsequenceV1` 9b2dc5d2….
  - This is attempt 2, with `set_option maxRecDepth 200000` on line 4; not attempt 1, 3ecde0d9….
  - 282 constants; the module-level union of axioms is propext, Classical.choice and Quot.sound. Namespace `FVLT.S4pPeriodTwoSubsequenceV1`.
  - It imports `S4o_G_PeriodTwoFiniteStateV1`. It uses plain `decide`, with no `native_decide`, and builds in about 5 s within the library's `-M8192` limit.
- **Staging:** `staging/s4p_g_v1_delivered/`, with MANIFEST.json 32c1c541…. Left out: attempt 1, the attempt1-to-attempt2 `.diff`, the Python script and its results, and the `.out` logs.
- **No name clashes:** none of its 86 short names appears elsewhere, and the all-module import passed.
  - `uFamily` and `vFamily` are reused from S4o-G, not redefined.
  - Its `residual_{u,v}Family_succ_at_{one,two,…}` lemmas and its `zeroSpineQuad/QuintTable…` tables extend S4o-G's `…succ_at_zero` and `zeroSpineTable…` under distinct names.
- **Compared with v13:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 372 entries, `2f59d96fa5a4a36bade9489bff04475083b510d4588acc7dc3359649f12a9460`.
- `LIBRARY_MANIFEST.json`: `f381a5d16b24fee8e99063fa96b2c36526e810825bb22e16d8aebdfdad9bc4f8`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,656 jobs (nucleus 47 s, scout 57 s).
  - `AXIOMS_OK modules=82 constants=3139`.
  - The two reports are identical apart from the timing line, `534988fb878e92acbe059e1c760cff7ee9068dd92f72353e9d5b6275950a1870`. The v13 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v14 with check=OK.

## v15 (2026-10-31, S4s squeeze corners)

- **Added, 1 file:** `FVLTS4sSqueezeCornersV1` ecafdae1…, namespace `FVLT.S4sSqueezeCornersV1`.
  - Authored by skeleton (Claude Opus 5.5) and independently reviewed by Codex (#1310): PASS WITH FLAGS, all documentation-only.
  - It imports `FVLTS4qSpinGateV1`.
  - 11 named declarations: 3 definitions (`spin`, `F`, `ang`), 3 helper lemmas (`cos_ang`, `sin_ang`, `spin_inj`) and 5 headline theorems. That makes 13 constants with Lean's auxiliaries.
  - Axioms: propext, Classical.choice and Quot.sound. The file's own 5 `#print axioms` lines confirm this at build time.
- **Scope note** (documentation, not Lean): `FVLTS4sSqueezeCornersV1_CLARIFICATION_v0_1.md` 92d7f78f3dd51e68d55f79f84a7954a7e10b9bcdef2d124f5ad2213b31db4e72. It answers Codex's documentation flags and is kept in `staging/s4s_squeeze_delivered/` with the source.
- **Left out:** `FVLTS4sSqueezeCornersV1_attempt1.lean` and the review evidence files.
- **Name clashes:**
  - None at full-name level; the all-module import passed.
  - `F` also appears in the kit's `Rule30Blocks` and `Rule30Predecessors`.
  - `spin` also appears in `FVLTS4qSpinGateV1`, `S4n_G_PeriodTwoTargetIV1` and `FVLTS4nPrimeReadoutV1`. The S4s `spin` is `abbrev spin := FVLT.S4qSpinGateV1.spin`, so `true ↦ -1`, like S4q and S4n-G and opposite to S4n PrimeReadout.
  - `ang`, `spin_inj`, `cos_ang` and `sin_ang` are new to the library.
- **Compared with v14:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 373 entries, `e4b353b83c7e7d5342756ea212ce6952bca561b835fc6f91e8918270161f87f7`.
- `LIBRARY_MANIFEST.json`: `81b6c4e46e8a1e61098571d50a338492814c234538fa71b65e47b08e713558b9`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,657 jobs (nucleus 46 s, scout 59 s).
  - `AXIOMS_OK modules=83 constants=3152`.
  - The two reports are identical apart from the timing line, `60fdaa852cfe2d16196371e46535cfe683e3b567bdfe9ba3f36006e433e0d1ef`. The v14 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v15 with check=OK.

## v16 (2026-10-31, S4s Rule 150 pen)

- **Added, 1 file:** `FVLTS4sRule150PenV1` 89c0410f…, namespace `FVLT.S4sRule150PenV1`.
  - Authored by skeleton (Claude Opus 5.5) and independently reviewed by Codex (#1318): PASS WITH FLAGS, all documentation-only.
  - It imports the kit's `Rule30Realization` and `Mathlib.Tactic`.
  - 6 definitions (`c`, `dir`, `stepT`, `pen`, `pre`, `block`) and 16 theorems, as expected; 51 constants with auxiliaries.
  - Axioms: propext, Classical.choice and Quot.sound. The file's own 6 `#print axioms` lines agree.
  - The build shows the 4 deprecated-name warnings Codex noted (`if_pos`, `if_neg`, `if_true`, `if_false`); they're harmless.
- **Scope note** (documentation, not Lean): `FVLTS4sRule150PenV1_CLARIFICATION_v0_1.md` 6d4ec51cd5740f9fe7711527558ed095d161b61e189d6f8d52ccdc4d2f493b0e, kept in `staging/s4s_rule150_pen_delivered/`.
- **Left out:** `_attempt1`, `_attempt2` and the review evidence.
- **Name clashes:**
  - None at full-name level; the all-module import passed.
  - Watched names that recur in other namespaces:
    - `block`: Rule30LightCone, FVLTS4nHarmonicTransportV1;
    - `c`: kit certificate SixTailEndpoints;
    - `double`: Rule30DrivenPrefix, Rule30FeedbackErasure;
    - `pen`: FVLTTurnFourierPenV1;
    - `pre`: kit certificate SixTailBackward.
  - `dir` and `stepT` are new to the library.
  - The kit's `Rule30Realization`, which this module opens, defines none of these names, so there's no ambiguity inside the module.
- **Compared with v15:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 374 entries, `e3c6da1173eccda15b7537dd2f38a9a041f5333c210362360b07ac95dcf850d1`.
- `LIBRARY_MANIFEST.json`: `00c5b8382847e4403395c2b917e9fcebeb2bc198566c9e9fb0ca87f486346181`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,658 jobs (nucleus 44 s, scout 57 s).
  - `AXIOMS_OK modules=84 constants=3203`.
  - The two reports are identical apart from the timing line, `364329c021d57ec0686fda2043e644f7724666d44f8b22edd86c3351962f6300`. The v15 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v16 with check=OK.

## v17 (2026-10-31, S4r-G and S4r-C Stage A; unsealed #1334/#1335)

- **Added, 3 files:**
  - **Gemini S4r-G (#1332), outcome N:** `S4r_G_PeriodTwoAllLayersV2` ebab8520… (final, attempt 3), 324 constants.
    - The file name says V2, but it **declares namespace `FVLT.S4rPeriodTwoAllLayersV1`**.
    - It imports `S4p_G_PeriodTwoSubsequenceV1`.
    - Headline `FVLT.S4rPeriodTwoAllLayersV1.not_finiteResidualClasses_compressedPhi_false`: propext, Classical.choice, Quot.sound.
    - Of its 30 `#print axioms` lines, 29 report the standard three; `iterDiff_two_pow` reports propext and Quot.sound.
  - **Codex S4r-C Stage A (#1333)**, both from `attempt3/`:
    - `S4rCXorCocycleV2` f0036e72…, 31 constants, namespace `FVLT.S4rCXorCocycleV2`. It imports only `Mathlib.Tactic`. The top-level `S4rCXorCocycleV2.lean` 29cc6eb5 is the failed attempt 2 and is **not** used. Its 5 prints:
      - `unroll`: no axioms;
      - `shift`, `lift_period_iff`, `dyadic_tower`: propext and Quot.sound;
      - `least_dichotomy`: the standard three.
    - `S4rCPhaseRecurrenceV2` 864d54bd…, 4 constants. It imports `S4n_G_PeriodTwoTargetIV1`, `S4o_G_PeriodTwoFiniteStateV1` and `S4rCXorCocycleV2`. Its 3 prints all report the standard three.
- **Staging:** `staging/s4r_g_v2_delivered/` and `staging/s4r_c_v1_delivered/`. Left out: every attempt and failed source, the V1 files, diffs, receipts, logs, rss files and Python.
- **Resolver change (tools):** `resolve_closure_vN.py` now indexes only the folders listed in `deliveries_vN.json`, not Codex's whole tree. Otherwise the failed top-level copy would have made `S4rCXorCocycleV2` ambiguous.
  - On v16's delivery list, the new resolver reproduces v16's closure exactly: 84 modules, same hashes.
  - The previous tool is kept as `resolve_closure_vN_v16tool.py`.
- **Name clashes:**
  - None at full-name level; the all-module import passed.
  - The Gemini and Codex S4r modules share no short names with each other.
  - Short names that recur elsewhere, in other namespaces:
    - `shift`: Rule30TimeShiftConstraintsV1, FVLTCyclicShiftWitnessV1;
    - `xor_true_left`, `xor_true_right`, `xor_false_left`: S4j_G_UniformCascadeV1;
    - `zeroStream`: FVLTS4mResidualV1.
  - `Period`, `LeastPeriod`, `xorBlock`, `postSpine`, `cubeXor`, `deltaEven` and `iterDiff` are new to the library.
- **Compared with v16:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 377 entries, `b1751fc48239665957ec7fa74d83e31bbcf1ad144a1e637113045bff4024393e`.
- `LIBRARY_MANIFEST.json`: `d275f109a10d05b082d65a4f6d7d150e7ea402d5b0eebc4a404eddf1b3c12215`.
- **Agreement test, PASS on both hosts:**
  - `lake build` completed, 3,661 jobs (nucleus 49 s, scout 63 s).
  - `AXIOMS_OK modules=87 constants=3562`.
  - The two reports are identical apart from the timing line, `cda6c6a6cb62995a9ad38cad23fd90c061c39af885fa9f2f8819c77d4b681085`. The v16 module lines are unchanged.
- **Frozen** on both hosts. The gate's `lib` lists v17 with check=OK.

## v19 (2026-10-31, S4t-G v2)

- **Added, 1 file:** Gemini S4t-G v2: `S4t_G_PeriodTwoSurvivalV2` 8c2aee1d… (85,860 B, 1,718 lines), namespace `FVLT.S4tPeriodTwoSurvivalV2`, 230 constants.
  - It imports `FVLTS4iUniformPaddingV1`, `FVLTS4jBoundedDeathV1`, `FVLTS4kCoreV1`, `FVLTS4lZeroBoundaryV1` and `S4r_G_PeriodTwoAllLayersV2`.
  - The file sets `linter.deprecated false`.
  - Its 30 `#print axioms` all report axioms (none axiom-free) and contain no `sorryAx`. The module union is propext, Classical.choice and Quot.sound.
  - Skeleton-verified: Gemini's S4FG-T-LEAN-0003 on scout and skeleton's replay on nucleus, both against v18.
- **Staging:** `staging/s4t_g_v2_delivered/`, with MANIFEST.json 6ab07b40…. Left out: `_attempt1`, the `.diff` files and the `.out` logs.
- **No name clashes:** none of its 97 short names appears elsewhere, and the all-module import passed.
- **Compared with v18:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 381 entries, `e25d4d54d074f152c452aa7247ccbe992e14b29d58306809660a75770ae7ddd5`.
- `LIBRARY_MANIFEST.json`: `f0ee6b00fe4a622b63cac1f4fb24146e9b2808bdb0fb430ebdac074fecb258fa`.
- **Agreement test, PASS on nucleus, scout and membrane:**
  - `lake build` completed, 3,665 jobs (nucleus 53 s, scout 71 s, membrane 74 s).
  - `AXIOMS_OK modules=91 constants=3864`.
  - All three reports are identical apart from the timing line, `c48b8451caf7fa3ba7d40e0c78665e10a9cfcdfda2cae215d0a8621ac5ce108c`. The v18 module lines are unchanged.
- **Frozen** on all three hosts. The gate's `lib` lists v19 with check=OK.

## v18 (2026-10-31, S4s Parts 1–3; first version built on all three hosts)

- **Added, 3 files** (Codex S4s Parts 1–3, #1352; FINAL_MANIFEST_v0_1.json e516cd5b…), all from `attempt2/`:
  - `S4sFrobeniusV1` 59d71dc6…, 32 constants, namespace `FVLT.S4sFrobeniusV1`. It imports the kit's `Rule30Realization` and `Mathlib.Tactic`. The top-level `S4sFrobeniusV1.lean` 892ad1f3 is the failed attempt 1 and is **not** used.
  - `S4sBlockDuhamelV1` c26084b2…, 30 constants, namespace `FVLT.S4sBlockDuhamelV1`. It imports `S4sFrobeniusV1` and the kit's `Rule30Prize`. The build gives the expected unused-`change` warning at line 84.
  - `S4sPeriodConsequencesV1` a25c073b…, 10 constants, namespace `FVLT.S4sPeriodConsequencesV1`. It imports `S4sBlockDuhamelV1`.
- **Axioms: propext and Quot.sound only, with no Classical.choice.**
  - The modules carry 26 `#print axioms` lines in all (10 + 10 + 6).
  - 4 report no axioms: `A_zero`, `A_eq_kit150`, `seededCenter_eq_kit` and `seeded_step`.
- **Staging:** `staging/s4s_v1_delivered/`. Left out: the failed top-level Frobenius, receipts, logs, rss files, runners and `PROOF_REPAIR.md`.
- **Name clashes:**
  - None at full-name level; the all-module import passed.
  - `A` also appears in the kit's `Rule30DividedDifference`, and `zeroRow` in `S4l_G_ZeroBoundaryPotentialsV1`, both in other namespaces.
  - `stencil`, `aIter`, `rowXor`, `carry`, `carryCone`, `xorRange`, `seededRow`, `seededCenter`, `rule30Step` and `frobenius` are new to the library.
  - The S4s modules open only their own namespaces.
- **Compared with v17:** 0 changed and 0 dropped. `lake-manifest.json` is the same.
- `SHA256SUMS`: 380 entries, `1109b5dee872154ac43a47da3a924d695a44f0c2d1f89ed89496076c616a3d72`.
- `LIBRARY_MANIFEST.json`: `aad953b17541ba1421acef199adf775af287ea3f001957438085878b9c94d133`.
- **Agreement test, PASS on nucleus, scout and membrane:**
  - `lake build` completed, 3,664 jobs (nucleus 49 s, scout 65 s, membrane 65 s).
  - `AXIOMS_OK modules=90 constants=3634`.
  - All three reports are identical apart from the timing line, `62a831579e4e7656384c37eaafd226c2d618d459220de35f5d7ca95526d75859`. The v17 module lines are unchanged.
- **Frozen** on all three hosts.

## Third mirror: membrane (from v17)

- Membrane (Tailscale [ts-redact-4]) holds a verified copy of **v17**, set up by the session "Mirror Lean library + Sage to Membrane" with step 4 of the procedure below. Setup doc on neo: `MEMBRANE_COMPUTE_SETUP_v0_1.md` 7369e1fc….
- **Checked independently by the tooling session:**
  - `sha256sum -c` passes 377/377, and SHA256SUMS b1751fc4…, LIBRARY_MANIFEST d275f109… and lake-manifest 1f0e0c1c… all match.
  - 0 writable entries.
  - `AXIOMS_OK modules=87 constants=3562`, with the report identical to nucleus's and scout's apart from the timing line (cda6c6a6…).
  - Membrane's build script: `~/rule30_theorem_library/membrane_build_v17.sh` bac77daf….
- **Not mirrored:** versions v1–v16.
- **Access from neo:** plain `ssh membrane` works. saphir pointed the alias at the Tailscale address on 2026-10-31; the LAN address is kept commented out in `~/.ssh/config`.
- **From v18 on,** step 4 is repeated on membrane: copy, `sha256sum -c`, build, axiom check, and the report must match.

## Related instruments and evidence (not library content)

These items are recorded for reference only. They are not in any `vN` tree and are not built or axiom-checked here.

- **S4s pen viewers** (2026-10-31): skeleton-built, browser-verified, not seat-reviewed; drawing register.
  - Handoff: neo `rule30_prize_research_2026_10_26/s4s_duhamel_prior_art_20261031/PEN_VIEWERS_HANDOFF_v0_1.md`, 9df5796da2788b324618748122497eea999f9bb4d9992326fbd5800fd979f608.
  - Viewers: standalone HTML, no CDN or `https://` references (checked):
    - `squeeze_pen_v0_1/squeeze_sphere_pen_v0_1.html` 1266e83d…
    - `squeeze_pen_v0_1/squeeze_sphere_pen_v0_1_1.html` 83b015d8…
    - `squeeze_pen_v0_2/curvature_pen_v0_2.html` 941838ad…
    - `squeeze_pen_v0_2/curvature_pen_v0_2_1.html` c0f6926d…
  - Library modules they relate to: `FVLTS4sSqueezeCornersV1` (v15) and `FVLTS4sRule150PenV1` (v16).
  - Frontier-dimension result (finite): `frontier_dimension_v0_1/RESULT_v0_1.md` cc3f8244…, `RESULT_v0_1_ADDENDUM_1.md` 084d50e7… and `frontier_dimension_v0_1.py` f5afdad9….
  - Viewer integration belongs to the Fourier viewer track owner, local_e47d17a4…, and `VIEWERS_LATEST`.

## Using it

```
cd ~/rule30_theorem_library/v1
export PATH=$HOME/.elan/bin:$PATH           # on scout also $HOME/tools-env/bin, for git
lake env lean MyCheck.lean                  # a file that imports e.g. S4f or FVLTS4eUniformPeriodV1
```

The version folders are read-only (only `.lake/` is writable). Don't edit them. Put your own files outside the folder and use `lake env`.

## Adding theorems: v2, v3, …

1. A file enters only after skeleton has verified its delivery: pins match, there's no sorry, native_decide or new axiom, and there's a standard-axiom receipt.
2. On nucleus, add the delivery to a new `deliveries_vN+1.json` (an ordered list of [folder, bus]). Then:
   - `tools/resolve_closure_vN.py`: every module must resolve to exactly one source version. It exits non-zero on a missing or ambiguous module.
   - `tools/assemble_vN.py vN+1 deliveries_vN+1.json vN+1_closure_report.json vN`: refuses if `vN+1` exists, and prints CHANGED or DROPPED for any file of `vN` that differs. Never touch `vN`.
3. Build, and run `tools/AxiomCheck.lean` over all modules. Freeze the version (read-only) and pin `lake-manifest.json` into `SHA256SUMS`.
4. Copy the version to scout without `.lake`, run `sha256sum -c SHA256SUMS`, then `lake resolve-deps`, `lake exe cache get` and `lake build`, and run the axiom check. The reports must match the nucleus report apart from the timing line. From v18 on, do the same on membrane.
5. Post the version, the hashes and both receipts to skeleton.
