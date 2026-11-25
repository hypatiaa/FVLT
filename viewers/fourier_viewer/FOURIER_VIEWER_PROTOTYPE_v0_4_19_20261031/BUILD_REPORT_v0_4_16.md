# BUILD REPORT v0.4.16 (2026-10-28): D1, the Rule 30 ladder-monodromy card

Builder: subagent, Claude Opus 5.5. Brief: `FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028_BRIEF/BUILD_BRIEF_v0_4_16_RULE30_D1.md`. Go: saphir, relayed by the rule30 skeleton seat ("Go, build D1"). Scope: `RULE30_SURFACES_VIEWER_TRACK_REPLY_v0_1_20261028.md` (D1 only; D2 and D3 not built). The idea of writing Rule 30 on surfaces is saphir's; the exact facts F1–F3 come from the rule30 track and its kit.

- **Base v0.4.14.** New folder `FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028/`, a whole copy of `FOURIER_VIEWER_PROTOTYPE_v0_4_14_20261021/`, including its shots, SHA256SUMS.txt and build/_logs. This build's runs then overwrote the logs and shots whose names coincide. `SUMMARY_v0414.txt` is the copied v0.4.14 file, unchanged.
- **v0.4.15 is skipped**: that number is reserved for the held scene-model / Landau design. Its folder was not read and not built.
- **Nothing outside the new folder was edited**, except VIEWERS_LATEST: three files got additive rows, and the new copy was added there. v0.4.14 was checked unchanged after the build: `dist/comb-hopf.html` fc8b714f7d0e44ef802cdf52d77195364e263b35d6b1aa920a29a730d9ac91ce (= its SHA256SUMS entry), `SHA256SUMS.txt` e56479ae325f07fd5d2f668f869857a5c73e9f60f578e0aec32ce561a363194a.
- **rule30 files**: only the three named files were read and hashed. Nothing there was run, copied into or modified. No git, no network, no Python (Node only).

## What was built

1. `host-core/rule30-ladder-core.js` (fv-rule30-ladder-core 0.1.0, `FVRule30Ladder`). Integers only: BigInt x mod 2^35, plain integers for t, N, per and S. No DOM and no float token. It exports the orbit, A(j, t), ψ_j, N_j(t), per_n, S_j, the doubling set, k(q, S_j), the ones count, the lifted curve and the card record. The curve comes as exact reduced rationals of a turn, `{base: [num, den], fibre: [num, den]}`. lift_iff is asserted (it throws) for every j ≤ 34 when a rule's table is built.
2. `fixtures/rule30-ladder-fixture.json`, transcribed by `build/transcribe-rule30-fixture.cjs`. That script is a parser, not a recomputation: it checks the three pins first, and checks that the manifest lists both outputs. The JSON records the source hashes:
   - `opus_two_adic_n2_densities_v0_1_20261028.output.txt` 72d0bd143c106c37ff3b1e8a46aa44d7605a8c17a88bee0990b0ce886fc7efcf
   - `opus_two_adic_n2_lemma_check_v0_1_20261028.output.txt` fa24e8067419383eb0184b4868468a3d6b1c5072ac20e8cd1e75ef887585defd
   - `opus_two_adic_n2_v0_1_20261028.sha256` 677bfe28bae82f6fed3b4716a2fceacd521e2c8c281b5063d1f0fe173e8035a8
   Convention, as the brief states it: line j's `per=` is per_{j+1}, and `ones` is counted over per_{j+1}. The doubling set is {j ∈ 1…34 : per_{j+1} = 2·per_j}.
3. `host-core/test-rule30-ladder.cjs`, wired into `build/runall.sh` as `test-rule30-ladder` in the same way as test-mirror. It checks the following.
   - Against the fixture, for rules 30, 90 and 150: per_{j+1} for every j ≤ 34, the doubling set and the ones count over per_{j+1}. Also the density, the excess, the stall-row counts, and the printed mean and max as 4-place roundings of the exact rationals.
   - An independent BigInt reference orbit, computed inside the test.
   - F1 for all t < per_35 at every j ≤ 34, and N_j by direct count.
   - lift_iff, S_j independent of the starting point, and the antiperiodicity lemma on doubling rows.
   - Closure after exactly k turns for every j and q, and monotonicity of the lift.
   - The card cases of the browser check, dial refusals, and a lexical check for float tokens and DOM access.
4. **Clifford card D1** (`instruments/comb-hopf/view-clifford.js`).
   - Controls: Layers ▸ "Rule 30 ladder (D1)" (view key `rl`). While it is on, the Layers menu also has a rule select, ◀ j / row select / j ▶, and a lift-q select (keys `rlr`, `rlj`, `rlq`).
   - Picture: while D1 is on it replaces the comb picture on the Clifford tab. It is one torus leaf (the Clifford torus, ρ = 1), with base angle 2π·t/per_j and fibre angle 2π·N_j(t)/q for t = 0 … k·per_j, drawn by the declared lift rule. Event steps are amber and other steps cyan. Also drawn: the base circle (grey dashed), and the fibre circle at base 0 (violet dotted) with the returns after each base cycle (violet rings; the white ring is t = 0, which is also the closure).
   - Caption: the exact label "row j, rule R, q = q: S_j = …, closes after k turn(s)", the monodromy line ("monodromy nontrivial" or "trivial (stall)") with per_j stated as the cycle of the rows below j, and every degenerate label.
   - Card (cards column): the exact registers, a live F1 check, the doubling set, a t / A / ψ / N table, the lift rule and the not-claimed line.
5. Smaller changes:
   - `panel.js`: two lines. One is the D1 card hook in `cardsHtml`; the other stops the branch chips being appended to the Layers menu while D1 is on.
   - `index.html`: one script tag.
   - `build/package.cjs`: version string `comb-hopf v0.4.16`.
   - `instruments/comb-hopf/README.md`: a v0.4.16 section with the dial ledger and the declared lift rule.
   - `SCHEMA_ADDENDUM_23.md`: the card's state, dials and exact registers.
6. `dist/comb-hopf.html` was rebuilt with `build/package.cjs`, and `dist/MANIFEST.sha256` and `SHA256SUMS.txt` were regenerated. SHA256SUMS lists every file in the folder except itself, in the same format as v0.4.14.
7. Copied to `VIEWERS_LATEST/fourier_viewer_comb-hopf_v0_4_16.html` (1da7dc8f…, byte-identical). Rows were added to `VIEWERS_LATEST/index.html`, `README.md` (the latest table and the notes) and `SHA256SUMS.txt` (one appended line). These edits were additive only. The v0.4.14 rows were not edited, so they still say "(latest)" / "**latest**" next to the new v0.4.16 row (see Open).

## Checks (one sequential run of `build/runall.sh`, true counts)

**Old suites.** Every old suite has the same pass and fail counts as in the v0.4.14 report. Its FAIL lines are also the same, compared line by line with the v0.4.14 logs, with three exceptions. They are provenance tests whose single FAIL line now also lists the new files:
- test-v042: the existing FAIL lists every file that differs from v0.4.1. It now also lists `rule30-ladder-core.js` and `test-rule30-ladder.cjs`.
- test-v0412 and test-v0413: the existing FAIL lists the source files that differ from v0.4.11 / v0.4.12. It now also lists `host-core/rule30-ladder-core.js`.

Their counts are unchanged (5/1, 11/1, 5/1). No old test was edited.

**New: test-rule30-ladder, 55 passed, 0 failed.**

**New: browser-check-v0416, 218 passed, 0 failed** (109 per viewport, at 1280×800 and 375×812). It covers:
- The cases: rule 30 j = 3 (doubling), rule 30 j = 5 (stall) and rule 90 j = 3 (density 0), each at q = 1, 2, 4 and 8. For each it checks that the curve's data attributes equal the core, the event and base segment counts, the caption label and monodromy text, the degenerate labels in the caption and the card, the card fields, the return marks, ink on the canvas, and no horizontal page scroll.
- The Layers dials, by click and by select; the address round trip; refused dials labelled.
- Fourier and Hopf unchanged by `rl=1`.
- D1 off identical to the v0.4.14 build (stage, canvas, caption, about, cards, address) on 8 states.
- Visible-control counts equal to v0.4.14 on 6 states per viewport, and at most 41 controls with D1 on and the menus closed.
- No page errors and no console errors.

**Disclosures.**
- (a) I wrote both the checks and the card. The independent verifier has not run yet.
- (b) My first run of browser-check-v0416 had 4 FAILs. They were bugs in the check, and I fixed only the check. One: the address test expected `view=rl=1`, but comb-core percent-encodes the view string (`view=rl%3D1`). Two: the cyan-ink threshold (> 50 px) was too high for rule 30 j = 5 at 375 px, where only 2 of 8 steps are non-event steps; it is now > 5 px. Nothing in the viewer changed.
- (c) The ink test counts canvas pixels of the matching colour. It shows that both colours are drawn, not that the geometry is right. The geometry is checked through the data attributes and the core.

## Screenshots

Files: `shot_v0416_{1280x800,375x812}_{r30_j3_q2, r30_j5_q2, r90_j3_q2, r30_j3_q1, r30_j3_q4, r30_j3_q8, r30_j0_q2, r30_j15_q8, r150_j7_q4, r30_layers_menu}.png`. The 375 shots are full-page, except the menu shot.

I looked at these: at 1280, r30 j3 q2, j5 q2, r90 j3 q2, r30 j3 q1, j3 q8, j15 q8 and j0 q2; at 375, r30 j3 q2 (full page) and the Layers menu. I did not view these individually: at 1280, j3 q4, r150 j7 q4 and the Layers menu; at 375, the other 8.

What I saw:
- **Rule 30, j = 3, q = 2** (S_3 = 1, doubling): a closed curve that goes round the base twice. Each base turn has one cyan and one amber step, and each amber step crosses the tube by half a turn. The return after one base cycle ("turn 1") sits opposite t = 0 on the violet fibre circle. The caption reads "monodromy nontrivial" in green.
- **j = 5, q = 2** (S_5 = 6, stall): one base turn, mostly amber (6 events in 8 steps), with large excursions round the tube, closing at t = 0. The caption reads "trivial (stall)" in amber.
- **Rule 90, j = 3** (S_3 = 0, density 0): a plain cyan base circle, with both degenerate labels in amber above the picture.
- **j = 0**: a plain base circle, with the S_j = 0 and j = 0 labels.
- **j = 3, q = 8**: an (8, 1) winding of eight base turns, with returns 1 … 7 marked in order round the fibre circle (1/8, 2/8, …). The labels "turn 4" to "turn 7" crowd together on the inner side of the tube, but they are still legible at 1280.
- **j = 15, q = 8** (per_15 = 64, S_15 = 41): a dense amber winding that fills the torus. The return marks are legible, but their labels overlap the curve. Correct, but busy.
- **j = 3, q = 1**: the curve goes once round the base and makes one full fibre loop on the event step. The q = 1 label explains this (see Open 1).
- **375 px**: the picture fits the width, with two or three caption lines above it. The D1 card is long; it is the first card in the column. The Layers menu shows the D1 toggle (pressed, with its colour swatches), then the rule select and ◀ j. There is no horizontal scroll (checked).

The only things that looked wrong to me were the busy high-j pictures and the crowded turn labels. The torus mesh is faint (the same alpha range as the comb's leaf). saphir's judgement on the colours and the density is the one that counts.

## Open

1. **q = 1 reading.** The brief asks for the label "fibre constant (q = 1)". It also says that an event advances the fibre by 2π/q and never takes the short way. At q = 1 these disagree. The sampled fibre N_j(t)/1 is 0 mod 1 at every t, but the lift rule draws each event as one full forward fibre loop. I followed the lift rule, so the curve is the lift of N and not its shadow, and the caption states both facts (SCHEMA_ADDENDUM_23 §5.1). If the owner meant "no fibre motion at q = 1", that is a one-line change in the core's `curve` and its test. This is the owner's call.
2. **Exports.** The JSON, state, CSV, Lift JSON and pair exports do not carry D1. The address and the PNG do.
3. **Dense pictures.** At high j (per_j ≥ 64 at q = 8) the pictures are dense and the turn labels overlap the curve. I did not add any label decluttering.
4. **VIEWERS_LATEST.** The v0.4.14 card and table row still say "latest", because the brief allows additive edits only. The new v0.4.16 rows also say "latest". Someone should decide whether to relabel the v0.4.14 rows.
5. **Base and fibre.** Putting the base on z₁ and the fibre on z₂ is my choice, stated in the addendum. The brief does not fix it.
6. **Regenerated shots.** The old browser checks write their screenshots into the folder. Running them here regenerated the earlier versions' `shot_*` / `export_*` files, so they count as new files in this folder (listed below).

## Files added or changed (relative to the v0.4.14 copy; sha256). This report and SHA256SUMS.txt are not listed; SHA256SUMS.txt covers every file.

```
added 2c7047d832a84e40ccd92ef764daf2678209d48befbf5e09c258342da482f177 SCHEMA_ADDENDUM_23.md
added 48459c66262710e5c6c9c9777fcea2937b95a2daf14c1ee63a83d7fdd67c51e9 build/browser-check-v0416.cjs
changed b8f80bede254f6584b39dcbbf8f0cd536bc48c848322f430782a401f8ec9b1fd build/package.cjs
changed dc9e5efc2583dfa4b1ff9a74c60649f6a92c02af2ebe29e3916506e7b6bccd14 build/runall.sh
added c27097f348f192045b08728ed4013e7558202ca1eacc0e44364b0d7868358eeb build/shots-v0416.cjs
added a09ca3de6d13657d71e3b4bf1d61680f347569a35e45cc2e2d2de5a45436f649 build/transcribe-rule30-fixture.cjs
changed 41c35e57bebf40a79d7042e80ae4883466eaf4a4747dd7696e6f3347ba4e2fb3 dist/MANIFEST.sha256
changed 1da7dc8f8cad8c31f22e302a92e763fdc95b71abf4d3dc559fcad33df88c1b71 dist/comb-hopf.html
added 59aa59dcf1614207d655d197c62ab4cb366e1451945971cc711d7ad20075f99d export_clifford.png
added 5d130ddbc7c3b55ba3bffbd83dc7377d99e1b7701069a508ece249ff4560823e export_fourier.png
added 9b4e02e083623c72bc2d86c478726e473a03635e17d88d5f557840e96fe367d7 export_hopf.png
added 51f7794592642fef9d1cb220634a3d9764a440d82842893ecc4b3a42b3d8f274 fixtures/rule30-ladder-fixture.json
added 67b248091447f04470c212c65ff5545edb85595b87471b28c03123ebd39449fc host-core/rule30-ladder-core.js
added 3a0a401cebd81a6ed3190bf091d49b8b2111ca04e0266637ca6c5cc8e47c4be3 host-core/test-rule30-ladder.cjs
changed 59aeaaf6f8452ecc1e03db0afb4456526f61a5513d2b05c8e291ad7c120b2bcc instruments/comb-hopf/README.md
changed 91d29d65c981369b344fa626d87a9e491707c10b5ffe325f4289460bd6034bfd instruments/comb-hopf/index.html
changed 09d15db46f6302f8d8af2fcd79f10038406ba8146b273805d5d154abaa0c70c1 instruments/comb-hopf/panel.js
changed 95564066d8709859db76d5035522535ef5318ba6f82d2c2b9e919aa9560cd4a7 instruments/comb-hopf/view-clifford.js
added e2b02b99abd25a5108c3daa70105a5eb5ed6d12ab522851e67451e9e0fbe2f7f shot_1280x800_clifford.png
added 25a93ffbed23c7f2459f417316c2db9e1da6e52929c312c1d1fa99ef39efba14 shot_1280x800_clifford_branches.png
added 1185288de4ed99f5ddcd638f90c68ab1422f990daea69bcc80ac262b7e7fe391 shot_1280x800_clifford_fraction.png
added 5106a52eb53308f2ad49ea9f2c180f558d349960d5334e1482a478053dcb2188 shot_1280x800_clifford_rho0.png
added b0a4e0446d1d2a1be1104c5146c5604b56f9022e95daf904aa2d27bb6b03d797 shot_1280x800_fourier.png
added 4e76f2d5583fa23045e6e1ed5a44d4e8bbcc5a935add033aa177d4f45ffd69a1 shot_1280x800_hopf.png
added 121687c15cb6814732e6aaf90315dc3188145169b070354fe36bc8acb6c19ad0 shot_1280x800_panels.png
added f87911a11d5683da8088f5cb5ec5d21c7242d399100e5f2ca4669ae6b4e4b410 shot_375x812_clifford.png
added d15f0e535ec82f8080d2f2934dbfc911851904e178e455a6ff4844309431db52 shot_375x812_clifford_branches.png
added d241a94f4c61a901c1c67d32fe90e5b83dc999e5a7768d445333c9582a49cb1d shot_375x812_fourier.png
added b4e2efa1b3550a805c80478f3635302cfe9160c4939c9fcbdb3eeb22503dc4b1 shot_375x812_hopf.png
added 807d643754bb5e80c1d4ab36d8c8b23c026a16acc8b01551c744f1684de90643 shot_375x812_panels.png
added 4d7a83b65c5631b0b04ad988619f0371bc85b7cec975c26744506b80ffd2846d shot_v02_clifford_1280x800.png
added 997e1d89d6d349429d7c77faa140d0b057c905d1eda3b296a7c4c4083b440db2 shot_v02_clifford_375x812.png
added 998ada303b4df0cae2c04a460851932b20a206e2b3cb924b2487bf3451eac6a6 shot_v02_fourier_1280x800.png
added f5be9a090ef2cab111920af7ebcbda2fc19956e7aa13238fc16fb7b952cd6009 shot_v02_fourier_375x812.png
added 9c81cab6f63fd8d0e3a90011c98c027c302d16e3b7331339e9fe3029f918abdd shot_v02_hopf_1280x800.png
added 3280cfa2857162609cda35763100af930d801f05d3ee2fa056a67745e407a1da shot_v02_hopf_375x812.png
added c022e157ef066f954aa1a1bdb8b9b679828ccb56c8047ae57b01274823344562 shot_v02_panels_1280x800.png
added b4a4a0257fb9a0b0ea604ddfbe1491be29b20a4ce735849eea5ccd6aa75f8838 shot_v02_panels_375x812.png
added bf3e6192ba475cffaeba00e537e31ff8aed3bdee25049042b8400896e6ad294f shot_v0410_1280x800_N10.png
added 5252a1ccda359bdabf84581d26dbee7ca56b4ec08f76bd221b1d83efe7c874fa shot_v0410_1280x800_N101.png
added 1702661383c01700143f5f250143fa38c0dfa2fcab4f8bf8c1197681bf13e32c shot_v0410_1280x800_N17.png
added da2912b9ef4a5eba8ba1d1bd2ab9ba425d10833592d5cc07c9c0e0489ffd71f0 shot_v0410_1280x800_N26.png
added 56398334d3ea6a1234e360d7426bb134476a189b056234b9f91b75c9d73a6350 shot_v0410_375x812_N10.png
added 55718d8db9ad22398178e703c17a3a93a13c0b1c8669b5cc61ea7c16f43dd628 shot_v0410_375x812_N101.png
added ba4fbb4fd6ed64ac62cd8e860c708ff84889fdc13786caccb0c639485adfb624 shot_v0410_375x812_N17.png
added 8451b82deb1f5f55c0cce5951fea03647950a70b2aea08f99e639cdf0cec98ad shot_v0410_375x812_N26.png
added 703e941a54698c24973c548d63833f6caf4ff863669895c3c3c5e7ab53d2d786 shot_v0411_1280x800_clifford_reciprocal.png
added aea5c07c3ff796a96836db56ee925f1ee6c28cdbc830394eae12a215b742db83 shot_v0411_1280x800_fourier_reciprocal.png
added 3280f41e1eadf81bf236092a8696b96d82bbb1a219ae0a38c01dc701071018b0 shot_v0411_1280x800_hopf_reciprocal.png
added 0b6623d43dc68bc9d119c6c1ce18aba251ac359b56434b22b3bfa74a1bf3f2bb shot_v0411_375x812_clifford_reciprocal.png
added 5a293910663c501307e029a953ee1d32677325a035a82bdde9d600d21c3573af shot_v0411_375x812_fourier_reciprocal.png
added 8a153e2fa5ebc004c12d4e6c939508db94546d3be22060fca386a19b9aba3045 shot_v0411_375x812_hopf_reciprocal.png
added 7d85f78e880570590c8378ec7829eb6f35eb54e63fc5feb74ca4a658e37268b4 shot_v0412_1280x800_fourier_log_alpham1.png
added 291a8295a32246c7d782795d4adf9db725cfc2238c120c144e25289d074d83f4 shot_v0412_1280x800_fourier_log_alphap1.png
added 245126922ce90647b0502929a1b329b8ac28482d112d4dbc0ea2824d325afd50 shot_v0412_375x812_fourier_log_alpham1.png
added 4e87cda9aa851efdf41bc51d130dda1df1a407a222b9c77041a2b5f9545ade2c shot_v0412_375x812_fourier_log_alphap1.png
added 7d85f78e880570590c8378ec7829eb6f35eb54e63fc5feb74ca4a658e37268b4 shot_v0413_1280x800_fourier_log_alpham1.png
added 291a8295a32246c7d782795d4adf9db725cfc2238c120c144e25289d074d83f4 shot_v0413_1280x800_fourier_log_alphap1.png
added 85c5e97b22866d7d54b371a8a4f0ce2c25e8f9ac945a8060f1e65b637e056dbe shot_v0413_1280x800_fourier_log_s1209_alpham1.png
added e64bf0c59130caf50014d2f4e559a9898d2097d7b29b7088556c9294395ea362 shot_v0413_1280x800_fourier_log_s1209_alphap1.png
added 245126922ce90647b0502929a1b329b8ac28482d112d4dbc0ea2824d325afd50 shot_v0413_375x812_fourier_log_alpham1.png
added 4e87cda9aa851efdf41bc51d130dda1df1a407a222b9c77041a2b5f9545ade2c shot_v0413_375x812_fourier_log_alphap1.png
added 138a64625a760a2bf739b1432ddc890f828488632f3facf4f40e0baab9d7b55a shot_v0413_375x812_fourier_log_s1209_alpham1.png
added 5a67ccf4e7df6e212ce4a53639aec05c3deec9eaa8069f90da843bf61ea216e8 shot_v0413_375x812_fourier_log_s1209_alphap1.png
added a79b800950e5cbe9f8572edf2ec41e32f925ddfe1742f81b1c0987ce96f2787d shot_v0416_1280x800_r150_j7_q4.png
added 4e69e4bc9861a56360e0736b69a7dffb0eccbec1c5eb419af758dee0767bfa37 shot_v0416_1280x800_r30_j0_q2.png
added 0353263116f94e20200efde21188f1beec0126d4b46bb2d4539d1eb3bf52ec7a shot_v0416_1280x800_r30_j15_q8.png
added eaf1217032c64852d79bd79151f88337846cc3e063d1406ae14f0e3a151ce3f2 shot_v0416_1280x800_r30_j3_q1.png
added e6c70b6c8a237bebc123c2c0689f3ce34d96393a9628c44681e6bd2dc5245d5f shot_v0416_1280x800_r30_j3_q2.png
added e3665b67ec72d9f43aeeffab0b29ae159a042ee41856d4ce07281da298a33022 shot_v0416_1280x800_r30_j3_q4.png
added 7783fd000885f053ba402278808bb163f68ea588f02d1b38dceaa74f735340e7 shot_v0416_1280x800_r30_j3_q8.png
added f96ac61b0ea6d3dd21f9a41a57aa2c778d2121a239bf3e19d45e08923c229968 shot_v0416_1280x800_r30_j5_q2.png
added 2c1000b16da3d936b06bfeef0d6c09d972c180658939b0ed842665aff6df5357 shot_v0416_1280x800_r30_layers_menu.png
added bd58f116b9c9ca88e535c2ed14a0079943261e22c9fce107beca329755abab43 shot_v0416_1280x800_r90_j3_q2.png
added 86da3a5fb0a3969aaf6fc616b0e2c421189d27ae2005c2c10badd54cce604a8e shot_v0416_375x812_r150_j7_q4.png
added a5e50a69c31e1dc45c9a2ebd14990f97de43261fd4c370b484c9424e80cb7ff3 shot_v0416_375x812_r30_j0_q2.png
added 53a46d31724b9693c2b2fea46b8fb5084c041e6f700cb748302dd4f0018ed4d6 shot_v0416_375x812_r30_j15_q8.png
added b25ad0bfdcf7cce6237db39ab8a5b4832aebec3d352ac0c7ac2ea5b94046a054 shot_v0416_375x812_r30_j3_q1.png
added 3d4ed1c5661e53eddf48a83347bff4d237fff7f13682e3c3f95c5b72009ba0b0 shot_v0416_375x812_r30_j3_q2.png
added f2071bc41723d0d3d88e234553776b88d4383e134a6bd3a9825be6d7a80f0155 shot_v0416_375x812_r30_j3_q4.png
added 073cde91fddcab168e2ba60d5e36739a2411a3fe585f1094add43acbb7f2493c shot_v0416_375x812_r30_j3_q8.png
added c96a6166cc0a0e0338cdd1a3eb63d2c822a4afced0b904efb81ae59c087b15bc shot_v0416_375x812_r30_j5_q2.png
added dc1a1933c29e2eac3e911eca36b9abb8da87f809b2f028029be296ed0e1a3d8b shot_v0416_375x812_r30_layers_menu.png
added 10d1dfceb4e3709faaa8b056ec6f1aef78a6a73399bfcaaeb680ec3062f16e12 shot_v0416_375x812_r90_j3_q2.png
added e42b6177c987add3259dbd5871937d309a213c9e613f2494c78aa77c558c5339 shot_v041_1280x800_B1_integer_clifford.png
added cc4a6cd871251775d3cf54164ce50fef08a4c52ffe4a335caf9c67de9549f5f1 shot_v041_1280x800_B1_integer_fourier.png
added 118e698c8d9e47d43adb51115ca8995b9c8853a4ab73d8884bd508e53561fa9b shot_v041_1280x800_N1_foliation.png
added da9dbd96c520126f1ad750bab429251a00e5621927e103b9a4349aa067e6aaf8 shot_v041_1280x800_foliation_even.png
added a49a1e214219ccc50049d35b91c30bc903e9883d2b3eddf8fbfb90f2e5a32776 shot_v041_1280x800_foliation_odd.png
added 305afd9c9381480ef02e5b23e153b4d52ec4244011ffd3f6c965a5bb58ae749e shot_v041_1280x800_foliation_odd_layers.png
added 95ebc5f31ce65f2520ed1af74199bd6750512068e1a28f4ef9f8471c2e197981 shot_v041_1280x800_n1_1_clifford.png
added f4890d82fffa214787ef511351df4e5914c8f6f361951a510dcf9a6432663dfb shot_v041_1280x800_n1_1_continuous_clifford.png
added 2d714ff535d23378e64e4c62f0922c8e94636f48ccd1ea40ad5ba0b7d6f2f5b6 shot_v041_1280x800_n1_1_continuous_fourier.png
added ed8a613b1fd9e7b3a36d6eab4f4648a5ad2c250c294c0676adfcef2abfe73b6e shot_v041_1280x800_n1_1_fourier.png
added dd8e55c009678a4c26d47c09a883dbc530a83e24f5ed335515af597aca7cb480 shot_v041_1280x800_n1_2_clifford.png
added e5b7418d82e140cee521322d9457f1740a487a62b17ef95dff266c40b4d289b0 shot_v041_1280x800_n1_2_fourier.png
added 5dee892ed9ff5e61aa00a0107d8fe76890623e871c61cf2ceafbc8abeec63778 shot_v041_1280x800_star_counterexample.png
added e62bb2ddb2317d5336c11aabfdbc0a0e09541bbe89b2204b56e8f105879d3ea1 shot_v041_375x812_B1_integer_clifford.png
added 05330dfe9ab3fda10ca6f3c2b83f348bfaf20d84cc6b05d8e01710c03042ad07 shot_v041_375x812_B1_integer_fourier.png
added 455a9f7a853e144afe0948c90926bf912ac67b0e25cdf3687d478436fa8ee1bd shot_v041_375x812_N1_foliation.png
added 552892bc16a0bd674ab11928f7d97a1ae25ca7da17e707a5b58871de275548d3 shot_v041_375x812_foliation_even.png
added 579eee328bdc77c7ff53873d069ad85f1753532edb3fbd435500aa626e1ff2ec shot_v041_375x812_foliation_odd.png
added a4f7bb058cd46385f49f092296496de00c3caa018a9416ae3c81b18ffd0ef67f shot_v041_375x812_foliation_odd_layers.png
added dd366d843e993ac13c289f919470e2ec5f10c47196daed2fc272589573e2e1d7 shot_v041_375x812_n1_1_clifford.png
added 72110ffd418959976dec747188317d610a5df81c034ed8d5117c0fbee6745650 shot_v041_375x812_n1_1_continuous_clifford.png
added 18c5a351a3e85352bf08f9f19855670f2098394bf687a876957970a355ae2a24 shot_v041_375x812_n1_1_continuous_fourier.png
added f0fff4b2a3df14c439056bcae0a17206aef62413a4d09f5c35c44ea1b9b5f696 shot_v041_375x812_n1_1_fourier.png
added f7d843f5a21f68b10a9f2e5b1f11da1ae35d75c897e7026269e502f1edf25b55 shot_v041_375x812_n1_2_clifford.png
added 2b5b0604d09e3df40825d1b0fb8b4ca1183b54e9c358ecf439187efcf54b4cd9 shot_v041_375x812_n1_2_fourier.png
added f4a5afaa752341ffa38715b59df4dfa36c0b87eafa01dfa0a69198f488bcfd6a shot_v041_375x812_star_counterexample.png
added b31c3060a4913c946615c826848a7f0dd00674c4bd5c927b51e73f9505fd3981 shot_v042_1280x800_B1_integer_from_default.png
added 5004b2677bf522c590ca888b070ab23a9546472cf5384840bc0a074961eb8525 shot_v042_1280x800_N0_wilson.png
added ed8a613b1fd9e7b3a36d6eab4f4648a5ad2c250c294c0676adfcef2abfe73b6e shot_v042_1280x800_n1_1_from_default.png
added 5071fb2a3d44c817759a958322f247884c6bae0eb9737940dc52754d4419709e shot_v042_1280x800_n1_2_from_default.png
added 42604bd177dedff22e868f9c986e5e34d8bfa3f3c6b4e21c4dc0bdba2900e7bd shot_v042_375x812_B1_integer_from_default.png
added 0680ace03032c55f1bf727c2453de599d2c71d7e18da23636fc5cfae44e4fd0f shot_v042_375x812_N0_wilson.png
added f0fff4b2a3df14c439056bcae0a17206aef62413a4d09f5c35c44ea1b9b5f696 shot_v042_375x812_n1_1_from_default.png
added 2ac717619a523be6b772055d1d374f8bfc2c1078a1d9aca07a90bda6efcc0977 shot_v042_375x812_n1_2_from_default.png
added 2e3bff4cf1583f4582b37e58c89d61c084b8f32db9b5f732f9267ffdc74d41fd shot_v044_1280x800_panels_robin_CA5040.png
added 016a69b623bc1c4f9c6b27d5b6db2c7596e9f711a35777677fcefaba247506a6 shot_v044_1280x800_panels_robin_CA55440.png
added 7b42a95e7b60a62b9c606c4a7b09b60c8d1143e80ee92de03c9c514c160abab8 shot_v044_1280x800_panels_robin_CA55440_c1c2.png
added 95415411e789800cc5bd39f31810ea888c01d82cbed03efd7930b23eb2566932 shot_v044_1280x800_panels_robin_CA55440_constants.png
added 0e2315f9cf6459ae6a02929e5a52853c64e123033abed3b77510bd3d8a2036c9 shot_v044_1280x800_panels_robin_CA55440_factors.png
added 04496db8871d2f398c1cc1d7d33c289d98c157904dc5ea5c17d16bd5f246308f shot_v044_1280x800_panels_robin_CA720720.png
added 16914562ae16154ba252152b0c3abccdfc9c603a385b670a15a3e58e86e8493c shot_v044_1280x800_topbar_CA5040.png
added 99b1f57ee6046cbdd1b3b6215faf5ac719afe0f03a0f6c3bbd68ceb52d5fd3e8 shot_v044_375x812_panels_robin_CA5040.png
added 47f15d9f7ae2e08f57b8f01b9ec2a0112a24476bd2a8fe0cd08d04eae4be5575 shot_v044_375x812_panels_robin_CA55440.png
added fbd4e72c91c11f29688bfa9ec66982c97adb20e08a303faa034ed19998277820 shot_v044_375x812_panels_robin_CA55440_c1c2.png
added 2a17bc0a985694997092d6fae2b3213149dce488e4a6cd09c1bd968fcd5ab56b shot_v044_375x812_panels_robin_CA55440_constants.png
added ec0547dfa43de154e9b78827989a0d9b75a3adf2bef782b190f2cec03ba9debf shot_v044_375x812_panels_robin_CA55440_factors.png
added e66c87e4530f91735e593917d6458b6b4a49d76f62362522aa6bd9288e2c3057 shot_v044_375x812_panels_robin_CA720720.png
added 5c109be4c8b110766b8b7223a5d88855c7722450b4f2ebea1ef71175ff8ac71f shot_v044_375x812_topbar_CA5040.png
added 526cf07b885de0c1000a2e5cc23231f41f9901fbba82e0d821d9a5ecbc43235b shot_v045_1280x800_fourier_CA5040_fresh.png
added d5a74cd3163cdc761a35d44a7d76a8863bcfbb56c321482beb152ba53874bcc4 shot_v045_1280x800_panels_CA5040_fresh.png
added db50ba83cabeb9506b4862c301c1595c6fae71e388ef11341d07b49d3c14f57c shot_v045_1280x800_panels_CA55440_fresh.png
added 4c1815a4bc7245f69eb2280c60de194c6b26e55a755e3ee77836fe98ac0d01ba shot_v045_375x812_fourier_CA5040_fresh.png
added 5280bbe181109169e2b28d7d767a252570ba41163b5465e27343df5065903677 shot_v045_375x812_panels_CA5040_fresh.png
added 3be9d6f78c1866f0448e236c38a5b8a099c39c177b837ae764be6a2762ecae8b shot_v045_375x812_panels_CA55440_fresh.png
added d69855c5afe00ee141e787d0d068b221d98a962c85960fef6472c0b2db966660 shot_v046_1280x800_integer_row.png
added b77e791d7cde4aea82417e2b6f385b76c8e245d84dbc210a696f006ca5382f33 shot_v046_1280x800_nfact_row.png
added 6900fac1c672a3619a49ca1a85bb0743b785d1229500e1753e8275e2eb8c183f shot_v046_375x812_integer_row.png
added d462b514e705d54f871f79ca006e8a5de406fd487bac00de385b3fcde77270d8 shot_v046_375x812_nfact_row.png
added afa79ca9150ee27afef466c84f499203e7ed29bf9387e1ed19888e119e0a1470 shot_v048_1280x800_fourier_caption_tilt_m1.png
added 24a818f739605d8f02ba9f587f0967447853e11d2a10075e82cf539f0f739a2e shot_v048_1280x800_fourier_caption_tilt_p1.png
added ed7c7ed02e4d81127ab02d66736bdb5c613f24ffcce2e752ae31f0ef212e6ea3 shot_v048_375x812_fourier_caption_tilt_m1.png
added d6679ffa9e610c0bd91ebd31b4d6815e7287f409c18847eb0720552b9c1c344c shot_v048_375x812_fourier_caption_tilt_p1.png
added 1ca17da959462aea16583f60002cd035af7df64690629ad009d5cd0150448c56 shot_v049_1280x800_clifford_fullstack_alpha_1.png
added 8c7168bb299696ee857eb5cdfc4e70e404fec6ace8df7e02552d61301f7c40c7 shot_v049_1280x800_clifford_fullstack_alpha_1_2.png
added 9e3f4291f31b3f4f46e84d2a0c46658a0b6565b64c3c1c6636e130fc004d1748 shot_v049_1280x800_clifford_fullstack_alpha_m1.png
added 00a311220af5ffa41bf177d4dc565c1aeb6a9f2cc84ae011cda63bb98306bd0d shot_v049_1280x800_fourier_fullstack_N5_s0_alpha_1.png
added 15ef47e2fd5cc157b7a4db67ce666d5687c2f87621eecdc8c772dfef5db5f16a shot_v049_1280x800_fourier_fullstack_N5_s1_alpha_1.png
added 7a432fa0277f46de53e8b9870364fb903ae19e7b7dc7456537b56ef6ca53b85a shot_v049_1280x800_fourier_fullstack_alpha_1.png
added b9c87cdceba02c5c1acbe1ac1844165b3af455918538eef6ceb43fce7b753b07 shot_v049_1280x800_fourier_fullstack_alpha_1_2.png
added b7c0841baaaeaee9360731e301d09690b93b5557e32af3b4dc6b1f63a4cf606e shot_v049_1280x800_fourier_fullstack_alpha_m1.png
added 000c71c1510fb61d3833da8f0ccbbd0bbecd49c71bcc1a88f5db0a54a9ce2f9e shot_v049_375x812_clifford_fullstack_alpha_1.png
added 4e2a8d238072a5cd52ecec2dfb78eb0bd9594093d7e25b7112e111ed7c679895 shot_v049_375x812_clifford_fullstack_alpha_1_2.png
added afd5828a089f093799bad1187678674b2e2df4a83a30a4e7882337ac0328dc56 shot_v049_375x812_clifford_fullstack_alpha_m1.png
added a4273ea7de5c27d132378ddda3c58f3d2c78cf4f1c314390391c85a1f8e01205 shot_v049_375x812_fourier_fullstack_alpha_1.png
added 2c1dd11ac985696cdf49c0167c3c62cdac3e274839d0151a27b2d3d56b31ade6 shot_v049_375x812_fourier_fullstack_alpha_1_2.png
added 11ac51efe8c998fba7933a19172ec17e0deb05837fd42a2c894b9785574bcf99 shot_v049_375x812_fourier_fullstack_alpha_m1.png
added 650bdb01d4379ebf581b88e8963ffc7a8c42ed83c55659ae06e51e74e591f150 shot_v04_1280x800_clifford_even.png
added b6d84398046dd949fef5870aae497d97b752e594437eadc9ca06ff5e5a97c46b shot_v04_1280x800_clifford_even_layers.png
added 9ce866ef92c0d41c55bf0c74636f7987078696f187545ffe5b1fcdcbb1cc6bea shot_v04_1280x800_clifford_odd.png
added 170a63b05c207635aa7388f622d9462de407d21caa7b2565e464b39c0c480b1f shot_v04_1280x800_clifford_odd_layers.png
added bcd844c643c712a523bfb01101104b9d684ebae495260a6ebd5e82925cc78762 shot_v04_1280x800_fourier.png
added 1dfe52d590c613b0fcbe43c63ed1a1ac50bdee9a1ce8187aad1bc80e7cbc421c shot_v04_1280x800_fourier_counterexample.png
added d762f3314504e1bff2c827f8e5dad81d4a9ab4a8caeaedab8d1e69e078852b72 shot_v04_375x812_clifford_even.png
added 6bb361537c0def61fea96f364f5788794729b488aee091f7479964f78dd991d8 shot_v04_375x812_clifford_even_layers.png
added 7f043613159bbcd6ca8e79c8ae60141d7b806beb0d3780b21c00565e03855f00 shot_v04_375x812_clifford_odd.png
added 3387a4f9f9630ab4d6f7d06f1eb1e86456dd8fc9f1d6b8da68693e99593110a7 shot_v04_375x812_clifford_odd_layers.png
added 6baeadc1b069e2fc7268416030e3fdfc76ab5bb5b0fdebbda3db9a9fc4a49c84 shot_v04_375x812_fourier.png
added 222abd45e181469b42a2a95c19975f7959a00fe219d8e1f9b44bd2ca190ce16c shot_v04_375x812_fourier_counterexample.png
log 654bef3bd7dcbe39991e09196005be49c0cf396984f8846070703f6ffe2fe937 build/_logs/SUMMARY_v0416.txt
log 33d08685bf574e19564c1933c4616f9a540e94460e341b7be65add0aa247782d build/_logs/browser-check-v0410.run.log
log af5b025a73ab2f0a868eb2c90d5924e37c309bbc94f5c490ed9b85184ffe8c90 build/_logs/browser-check-v0414.run.log
log a084acc8bbda34125bff8e0691e87fb2df8002355b1a9828ecc1b9249d6bcc51 build/_logs/browser-check-v0416.run.log
log 7457983988ec7b79e649f4a978a78d46ef753af824734d25b4f4c007a6d1e292 build/_logs/browser-check-v049.run.log
log c25ba07d564801fe2ed64f5721c8c2fcff22261fa975147e6035d1fa2c791904 build/_logs/browser-check.run.log
log b9135a8a7cc8624303e4e3a74528ab0dbced578caee5f16c0e4c672aa503645d build/_logs/test-rule30-ladder.run.log
log e4ebc8a9f9195c7a4f39ec732645f418e6330cfcf58d29046e6f323dbb9a62ca build/_logs/test-v0412.run.log
log 35708293d48957cd4b8b5e657f748a0dc35044a48a24e76f1f107f539393b19d build/_logs/test-v0413.run.log
log d2e2de5d2894d947b10f72d0aeed325e6db4864ee524140d7729d374594417db build/_logs/test-v042.run.log
```

## Test output, verbatim: build/_logs/SUMMARY_v0416.txt

```
test-exact exit=0 test-exact: 21 passed, 0 failed
test-core exit=1 test-core: 159 passed, 1 failed
contrast-check exit=0 contrast-check: 93 pass, 0 fail
test-mirror exit=0 test-mirror (T-MA): 14 passed, 0 failed
test-v041 exit=1 test-v041: 10 passed, 1 failed
test-v042 exit=1 test-v042: 5 passed, 1 failed
test-v044 exit=0 11 passed, 0 failed
test-v047 exit=0 test-v047 unit: 33 pass, 0 fail
test-v049 exit=0 v0.4.9 unit check: 25 pass / 0 fail
test-v0410 exit=1 SUMMARY test-v0410: 19 pass / 1 fail
test-v0411 exit=1 SUMMARY test-v0411: 15 pass, 1 fail
test-v0412 exit=1 SUMMARY test-v0412: 11 pass, 1 fail
test-v0413 exit=1 SUMMARY test-v0413: 5 pass, 1 fail
test-v0414 exit=0 SUMMARY test-v0414 22 passed, 0 failed
test-rule30-ladder exit=0 SUMMARY test-rule30-ladder: 55 passed, 0 failed
browser-check-mirror exit=1 browser-check-mirror: 120 passed, 2 failed
browser-check-v041 exit=0 browser-check-v041: 66 passed, 0 failed
browser-check-v042 exit=0 browser-check-v042: 46 passed, 0 failed
browser-check-v043 exit=0 browser-check-v043: 36 passed, 0 failed
browser-check-v044 exit=1 218 passed, 4 failed
browser-check-v045 exit=0 58 passed, 0 failed
browser-check-v046 exit=0 16 passed, 0 failed
browser-check-v047 exit=1 browser-check-v047: 58 passed, 2 failed
browser-check-v048 exit=0 v0.4.8 browser check: 19 pass / 0 fail
browser-check-v049 exit=0 v0.4.9 browser check: 52 pass / 0 fail
browser-check-v0410 exit=0 SUMMARY browser-check-v0410: 104 pass / 0 fail
browser-check-v0411 exit=0 SUMMARY browser-check-v0411: 82 pass, 0 fail
browser-check-v0412 exit=0 SUMMARY browser-check-v0412: 78 pass, 0 fail
browser-check-v0413 exit=0 SUMMARY browser-check-v0413: 74 pass, 0 fail
browser-check-v0414 exit=0 SUMMARY browser-check-v0414 96 passed, 0 failed
browser-check-v0416 exit=0 SUMMARY browser-check-v0416: 218 passed, 0 failed
browser-check exit=1 browser-check: 542 passed, 23 failed
ALLDONE
```

## Test output, verbatim: build/_logs/test-rule30-ladder.run.log

```
PASS fixture source hashes recorded (densities 72d0bd14…, lemma fa24e806…, manifest 677bfe28…)
PASS pinned sources still match their sha256 (read only; 3 of 3 present)
PASS rule 30: per_35 = 8192 (fixture) = core 8192 = reference 8192
PASS rule 30: core orbit = reference orbit mod 2^35 (all 8192 states)
PASS rule 30: per_{j+1} for every j = 0 … 34 matches the fixture
PASS rule 30: ones over per_{j+1} for every j matches the fixture (and density, excess)
PASS rule 30: doubling set (j in 1 … 34) = fixture [1, 3, 4, 6, 7, 9, 15, 16, 24, 25, 27, 29, 34]
PASS rule 30: j = 0 is a stall (per_0 = per_1 = 1, S_0 = 0, ψ_0 ≡ 0)
PASS rule 30: stall rows 21, of which density exactly 1/2: 5
PASS rule 30: stall-row mean / max |ones − zeros|/per as printed (0.0342, 0.2500; exact rational, rounded half-up to 4 places for the comparison only)
PASS rule 30: F1 A(j,t) = (A(j,0) + N_j(t)) mod 2 for all t < per_35, j ≤ 34 (A from the reference orbit)
PASS rule 30: N_j(t) by direct count of ψ_j(s) = 1 over s < t (ψ from the reference orbit) for t ≤ 2·per_35
PASS rule 30: lift_iff per_{j+1} = 2·per_j ⇔ S_j odd (else per_{j+1} = per_j), every j ≤ 34
PASS rule 30: S_j is the same from every starting point on the base cycle (all windows of length per_j, j ≤ 34)
PASS rule 30: antiperiodicity lemma on doubling rows: A(j, t + per_j) = 1 − A(j, t) for t < per_j, hence ones = per_{j+1}/2
PASS rule 30: lifted curve closes after k = q/gcd(q,S_j) turns, and not earlier, for every j ≤ 34 and q ∈ {1,2,4,8}
PASS rule 30: lifted curve is monotone: base strictly increasing, fibre never decreasing, fibre step = 1/(q·sub) on events only (sub = 3, j ≤ 12)
PASS rule 90: per_35 = 32 (fixture) = core 32 = reference 32
PASS rule 90: core orbit = reference orbit mod 2^35 (all 32 states)
PASS rule 90: per_{j+1} for every j = 0 … 34 matches the fixture
PASS rule 90: ones over per_{j+1} for every j matches the fixture (and density, excess)
PASS rule 90: doubling set (j in 1 … 34) = fixture [2, 4, 8, 16, 32]
PASS rule 90: j = 0 is a stall (per_0 = per_1 = 1, S_0 = 0, ψ_0 ≡ 0)
PASS rule 90: stall rows 29, of which density exactly 1/2: 0
PASS rule 90: stall-row mean / max |ones − zeros|/per as printed (0.8405, 1.0000; exact rational, rounded half-up to 4 places for the comparison only)
PASS rule 90: F1 A(j,t) = (A(j,0) + N_j(t)) mod 2 for all t < per_35, j ≤ 34 (A from the reference orbit)
PASS rule 90: N_j(t) by direct count of ψ_j(s) = 1 over s < t (ψ from the reference orbit) for t ≤ 2·per_35
PASS rule 90: lift_iff per_{j+1} = 2·per_j ⇔ S_j odd (else per_{j+1} = per_j), every j ≤ 34
PASS rule 90: S_j is the same from every starting point on the base cycle (all windows of length per_j, j ≤ 34)
PASS rule 90: antiperiodicity lemma on doubling rows: A(j, t + per_j) = 1 − A(j, t) for t < per_j, hence ones = per_{j+1}/2
PASS rule 90: lifted curve closes after k = q/gcd(q,S_j) turns, and not earlier, for every j ≤ 34 and q ∈ {1,2,4,8}
PASS rule 90: lifted curve is monotone: base strictly increasing, fibre never decreasing, fibre step = 1/(q·sub) on events only (sub = 3, j ≤ 12)
PASS rule 150: per_35 = 64 (fixture) = core 64 = reference 64
PASS rule 150: core orbit = reference orbit mod 2^35 (all 64 states)
PASS rule 150: per_{j+1} for every j = 0 … 34 matches the fixture
PASS rule 150: ones over per_{j+1} for every j matches the fixture (and density, excess)
PASS rule 150: doubling set (j in 1 … 34) = fixture [1, 2, 4, 8, 16, 32]
PASS rule 150: j = 0 is a stall (per_0 = per_1 = 1, S_0 = 0, ψ_0 ≡ 0)
PASS rule 150: stall rows 28, of which density exactly 1/2: 1
PASS rule 150: stall-row mean / max |ones − zeros|/per as printed (0.5402, 0.9375; exact rational, rounded half-up to 4 places for the comparison only)
PASS rule 150: F1 A(j,t) = (A(j,0) + N_j(t)) mod 2 for all t < per_35, j ≤ 34 (A from the reference orbit)
PASS rule 150: N_j(t) by direct count of ψ_j(s) = 1 over s < t (ψ from the reference orbit) for t ≤ 2·per_35
PASS rule 150: lift_iff per_{j+1} = 2·per_j ⇔ S_j odd (else per_{j+1} = per_j), every j ≤ 34
PASS rule 150: S_j is the same from every starting point on the base cycle (all windows of length per_j, j ≤ 34)
PASS rule 150: antiperiodicity lemma on doubling rows: A(j, t + per_j) = 1 − A(j, t) for t < per_j, hence ones = per_{j+1}/2
PASS rule 150: lifted curve closes after k = q/gcd(q,S_j) turns, and not earlier, for every j ≤ 34 and q ∈ {1,2,4,8}
PASS rule 150: lifted curve is monotone: base strictly increasing, fibre never decreasing, fibre step = 1/(q·sub) on events only (sub = 3, j ≤ 12)
PASS card rule 30, j = 3, q = 2: per_3 = 2, S_3 odd, closes after 2 turns, monodromy nontrivial (doubling)
PASS card rule 30, j = 5, q = 2: S_5 even, closes after 1 turn, trivial (stall)
PASS card rule 90, j = 3: density 0 and S_3 = 0 (pure base circle), both labelled
PASS card j = 0: per_0 = 1, S_0 = 0, k = 1 at every q, labelled j0
PASS card q = 1: "fibre constant (q = 1)" and k = 1 for every rule and j
PASS card label text: "row 3, rule 30, q = 4: S_3 = 1, closes after 4 turns"
PASS dial refusals: rule 110, j = 35, q = 3 throw
PASS the core has no float token and no DOM access (lexical check of the source, comments stripped)
SUMMARY test-rule30-ladder: 55 passed, 0 failed
```

## Browser-check output, verbatim: build/_logs/browser-check-v0416.run.log

```
PASS 1280x800 rule 30 j = 3 (doubling) q = 1: curve data = core (per 2, S 1, k 1, steps 2, ends at base 1, fibre 1/1)
PASS 1280x800 rule 30 j = 3 (doubling) q = 1: event / base segments = core (360 / 360)
PASS 1280x800 rule 30 j = 3 (doubling) q = 1: caption label "row 3, rule 30, q = 1: S_3 = 1, closes after 1 turn" and "monodromy nontrivial"
PASS 1280x800 rule 30 j = 3 (doubling) q = 1: degenerate labels drawn [q1] in the caption and the card
PASS 1280x800 rule 30 j = 3 (doubling) q = 1: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 30 j = 3 (doubling) q = 1: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 1280x800 rule 30 j = 3 (doubling) q = 1: ink on the canvas (amber events and cyan base steps; amber 1015, cyan 190)
PASS 1280x800 rule 30 j = 3 (doubling) q = 1: no horizontal page scroll
PASS 1280x800 rule 30 j = 3 (doubling) q = 2: curve data = core (per 2, S 1, k 2, steps 4, ends at base 2, fibre 1/1)
PASS 1280x800 rule 30 j = 3 (doubling) q = 2: event / base segments = core (720 / 720)
PASS 1280x800 rule 30 j = 3 (doubling) q = 2: caption label "row 3, rule 30, q = 2: S_3 = 1, closes after 2 turns" and "monodromy nontrivial"
PASS 1280x800 rule 30 j = 3 (doubling) q = 2: degenerate labels drawn [] in the caption and the card
PASS 1280x800 rule 30 j = 3 (doubling) q = 2: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 30 j = 3 (doubling) q = 2: returns to base angle 0 marked: 3 (i = 0 … k)
PASS 1280x800 rule 30 j = 3 (doubling) q = 2: ink on the canvas (amber events and cyan base steps; amber 1083, cyan 380)
PASS 1280x800 rule 30 j = 3 (doubling) q = 2: no horizontal page scroll
PASS 1280x800 rule 30 j = 3 (doubling) q = 4: curve data = core (per 2, S 1, k 4, steps 8, ends at base 4, fibre 1/1)
PASS 1280x800 rule 30 j = 3 (doubling) q = 4: event / base segments = core (1440 / 1440)
PASS 1280x800 rule 30 j = 3 (doubling) q = 4: caption label "row 3, rule 30, q = 4: S_3 = 1, closes after 4 turns" and "monodromy nontrivial"
PASS 1280x800 rule 30 j = 3 (doubling) q = 4: degenerate labels drawn [] in the caption and the card
PASS 1280x800 rule 30 j = 3 (doubling) q = 4: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 30 j = 3 (doubling) q = 4: returns to base angle 0 marked: 5 (i = 0 … k)
PASS 1280x800 rule 30 j = 3 (doubling) q = 4: ink on the canvas (amber events and cyan base steps; amber 1737, cyan 1149)
PASS 1280x800 rule 30 j = 3 (doubling) q = 4: no horizontal page scroll
PASS 1280x800 rule 30 j = 3 (doubling) q = 8: curve data = core (per 2, S 1, k 8, steps 16, ends at base 8, fibre 1/1)
PASS 1280x800 rule 30 j = 3 (doubling) q = 8: event / base segments = core (2880 / 2880)
PASS 1280x800 rule 30 j = 3 (doubling) q = 8: caption label "row 3, rule 30, q = 8: S_3 = 1, closes after 8 turns" and "monodromy nontrivial"
PASS 1280x800 rule 30 j = 3 (doubling) q = 8: degenerate labels drawn [] in the caption and the card
PASS 1280x800 rule 30 j = 3 (doubling) q = 8: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 30 j = 3 (doubling) q = 8: returns to base angle 0 marked: 9 (i = 0 … k)
PASS 1280x800 rule 30 j = 3 (doubling) q = 8: ink on the canvas (amber events and cyan base steps; amber 3094, cyan 2013)
PASS 1280x800 rule 30 j = 3 (doubling) q = 8: no horizontal page scroll
PASS 1280x800 rule 30 j = 5 (stall) q = 1: curve data = core (per 8, S 6, k 1, steps 8, ends at base 1, fibre 6/1)
PASS 1280x800 rule 30 j = 5 (stall) q = 1: event / base segments = core (540 / 180)
PASS 1280x800 rule 30 j = 5 (stall) q = 1: caption label "row 5, rule 30, q = 1: S_5 = 6, closes after 1 turn" and "trivial (stall)"
PASS 1280x800 rule 30 j = 5 (stall) q = 1: degenerate labels drawn [q1] in the caption and the card
PASS 1280x800 rule 30 j = 5 (stall) q = 1: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 30 j = 5 (stall) q = 1: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 1280x800 rule 30 j = 5 (stall) q = 1: ink on the canvas (amber events and cyan base steps; amber 4920, cyan 57)
PASS 1280x800 rule 30 j = 5 (stall) q = 1: no horizontal page scroll
PASS 1280x800 rule 30 j = 5 (stall) q = 2: curve data = core (per 8, S 6, k 1, steps 8, ends at base 1, fibre 3/1)
PASS 1280x800 rule 30 j = 5 (stall) q = 2: event / base segments = core (540 / 180)
PASS 1280x800 rule 30 j = 5 (stall) q = 2: caption label "row 5, rule 30, q = 2: S_5 = 6, closes after 1 turn" and "trivial (stall)"
PASS 1280x800 rule 30 j = 5 (stall) q = 2: degenerate labels drawn [] in the caption and the card
PASS 1280x800 rule 30 j = 5 (stall) q = 2: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 30 j = 5 (stall) q = 2: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 1280x800 rule 30 j = 5 (stall) q = 2: ink on the canvas (amber events and cyan base steps; amber 2434, cyan 64)
PASS 1280x800 rule 30 j = 5 (stall) q = 2: no horizontal page scroll
PASS 1280x800 rule 30 j = 5 (stall) q = 4: curve data = core (per 8, S 6, k 2, steps 16, ends at base 2, fibre 3/1)
PASS 1280x800 rule 30 j = 5 (stall) q = 4: event / base segments = core (1080 / 360)
PASS 1280x800 rule 30 j = 5 (stall) q = 4: caption label "row 5, rule 30, q = 4: S_5 = 6, closes after 2 turns" and "trivial (stall)"
PASS 1280x800 rule 30 j = 5 (stall) q = 4: degenerate labels drawn [] in the caption and the card
PASS 1280x800 rule 30 j = 5 (stall) q = 4: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 30 j = 5 (stall) q = 4: returns to base angle 0 marked: 3 (i = 0 … k)
PASS 1280x800 rule 30 j = 5 (stall) q = 4: ink on the canvas (amber events and cyan base steps; amber 2616, cyan 129)
PASS 1280x800 rule 30 j = 5 (stall) q = 4: no horizontal page scroll
PASS 1280x800 rule 30 j = 5 (stall) q = 8: curve data = core (per 8, S 6, k 4, steps 32, ends at base 4, fibre 3/1)
PASS 1280x800 rule 30 j = 5 (stall) q = 8: event / base segments = core (2160 / 720)
PASS 1280x800 rule 30 j = 5 (stall) q = 8: caption label "row 5, rule 30, q = 8: S_5 = 6, closes after 4 turns" and "trivial (stall)"
PASS 1280x800 rule 30 j = 5 (stall) q = 8: degenerate labels drawn [] in the caption and the card
PASS 1280x800 rule 30 j = 5 (stall) q = 8: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 30 j = 5 (stall) q = 8: returns to base angle 0 marked: 5 (i = 0 … k)
PASS 1280x800 rule 30 j = 5 (stall) q = 8: ink on the canvas (amber events and cyan base steps; amber 3428, cyan 439)
PASS 1280x800 rule 30 j = 5 (stall) q = 8: no horizontal page scroll
PASS 1280x800 rule 90 j = 3 (density 0) q = 1: curve data = core (per 2, S 0, k 1, steps 2, ends at base 1, fibre 0/1)
PASS 1280x800 rule 90 j = 3 (density 0) q = 1: event / base segments = core (0 / 720)
PASS 1280x800 rule 90 j = 3 (density 0) q = 1: caption label "row 3, rule 90, q = 1: S_3 = 0, closes after 1 turn" and "trivial (stall)"
PASS 1280x800 rule 90 j = 3 (density 0) q = 1: degenerate labels drawn [q1, S0, dens0] in the caption and the card
PASS 1280x800 rule 90 j = 3 (density 0) q = 1: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 90 j = 3 (density 0) q = 1: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 1280x800 rule 90 j = 3 (density 0) q = 1: ink on the canvas (cyan base steps; amber 0, cyan 403)
PASS 1280x800 rule 90 j = 3 (density 0) q = 1: no horizontal page scroll
PASS 1280x800 rule 90 j = 3 (density 0) q = 2: curve data = core (per 2, S 0, k 1, steps 2, ends at base 1, fibre 0/1)
PASS 1280x800 rule 90 j = 3 (density 0) q = 2: event / base segments = core (0 / 720)
PASS 1280x800 rule 90 j = 3 (density 0) q = 2: caption label "row 3, rule 90, q = 2: S_3 = 0, closes after 1 turn" and "trivial (stall)"
PASS 1280x800 rule 90 j = 3 (density 0) q = 2: degenerate labels drawn [S0, dens0] in the caption and the card
PASS 1280x800 rule 90 j = 3 (density 0) q = 2: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 90 j = 3 (density 0) q = 2: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 1280x800 rule 90 j = 3 (density 0) q = 2: ink on the canvas (cyan base steps; amber 0, cyan 403)
PASS 1280x800 rule 90 j = 3 (density 0) q = 2: no horizontal page scroll
PASS 1280x800 rule 90 j = 3 (density 0) q = 4: curve data = core (per 2, S 0, k 1, steps 2, ends at base 1, fibre 0/1)
PASS 1280x800 rule 90 j = 3 (density 0) q = 4: event / base segments = core (0 / 720)
PASS 1280x800 rule 90 j = 3 (density 0) q = 4: caption label "row 3, rule 90, q = 4: S_3 = 0, closes after 1 turn" and "trivial (stall)"
PASS 1280x800 rule 90 j = 3 (density 0) q = 4: degenerate labels drawn [S0, dens0] in the caption and the card
PASS 1280x800 rule 90 j = 3 (density 0) q = 4: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 90 j = 3 (density 0) q = 4: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 1280x800 rule 90 j = 3 (density 0) q = 4: ink on the canvas (cyan base steps; amber 0, cyan 403)
PASS 1280x800 rule 90 j = 3 (density 0) q = 4: no horizontal page scroll
PASS 1280x800 rule 90 j = 3 (density 0) q = 8: curve data = core (per 2, S 0, k 1, steps 2, ends at base 1, fibre 0/1)
PASS 1280x800 rule 90 j = 3 (density 0) q = 8: event / base segments = core (0 / 720)
PASS 1280x800 rule 90 j = 3 (density 0) q = 8: caption label "row 3, rule 90, q = 8: S_3 = 0, closes after 1 turn" and "trivial (stall)"
PASS 1280x800 rule 90 j = 3 (density 0) q = 8: degenerate labels drawn [S0, dens0] in the caption and the card
PASS 1280x800 rule 90 j = 3 (density 0) q = 8: card S_j, k, per_j, monodromy, density, F1
PASS 1280x800 rule 90 j = 3 (density 0) q = 8: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 1280x800 rule 90 j = 3 (density 0) q = 8: ink on the canvas (cyan base steps; amber 0, cyan 403)
PASS 1280x800 rule 90 j = 3 (density 0) q = 8: no horizontal page scroll
PASS 1280x800 Layers: "Rule 30 ladder (D1)" switches the card on (rule 30, j = 3, q = 2; address view=rl=1)
PASS 1280x800 j ▶ twice: j = 5, trivial (stall)
PASS 1280x800 ◀ j: j = 4
PASS 1280x800 selects: rule 150, j = 3, q = 8 → row 3, rule 150, q = 8: S_3 = 2, closes after 4 turns
PASS 1280x800 address round trip (reload): same card
PASS 1280x800 switch off: the comb picture is back, no D1 card, the dial values stay in the view string
PASS 1280x800 refused dials (j = 99, q = 3): labelled, defaults drawn
PASS 1280x800 fourier with rl=1 draws the same picture as without it
PASS 1280x800 hopf with rl=1 draws the same picture as without it
PASS 1280x800 D1 off: stage, canvas, caption, about, cards and address identical to v0.4.14 on 8 of 8 states
PASS 1280x800 visible-control counts = v0.4.14 (pairs: 39/39/41/41/39/39/41/41/39/39/41/41)
PASS 1280x800 visible controls with D1 on (menus closed): 41/41 (≤ 41)
PASS 1280x800 no page errors or console errors
PASS 375x812 rule 30 j = 3 (doubling) q = 1: curve data = core (per 2, S 1, k 1, steps 2, ends at base 1, fibre 1/1)
PASS 375x812 rule 30 j = 3 (doubling) q = 1: event / base segments = core (360 / 360)
PASS 375x812 rule 30 j = 3 (doubling) q = 1: caption label "row 3, rule 30, q = 1: S_3 = 1, closes after 1 turn" and "monodromy nontrivial"
PASS 375x812 rule 30 j = 3 (doubling) q = 1: degenerate labels drawn [q1] in the caption and the card
PASS 375x812 rule 30 j = 3 (doubling) q = 1: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 30 j = 3 (doubling) q = 1: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 375x812 rule 30 j = 3 (doubling) q = 1: ink on the canvas (amber events and cyan base steps; amber 180, cyan 94)
PASS 375x812 rule 30 j = 3 (doubling) q = 1: no horizontal page scroll
PASS 375x812 rule 30 j = 3 (doubling) q = 2: curve data = core (per 2, S 1, k 2, steps 4, ends at base 2, fibre 1/1)
PASS 375x812 rule 30 j = 3 (doubling) q = 2: event / base segments = core (720 / 720)
PASS 375x812 rule 30 j = 3 (doubling) q = 2: caption label "row 3, rule 30, q = 2: S_3 = 1, closes after 2 turns" and "monodromy nontrivial"
PASS 375x812 rule 30 j = 3 (doubling) q = 2: degenerate labels drawn [] in the caption and the card
PASS 375x812 rule 30 j = 3 (doubling) q = 2: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 30 j = 3 (doubling) q = 2: returns to base angle 0 marked: 3 (i = 0 … k)
PASS 375x812 rule 30 j = 3 (doubling) q = 2: ink on the canvas (amber events and cyan base steps; amber 201, cyan 188)
PASS 375x812 rule 30 j = 3 (doubling) q = 2: no horizontal page scroll
PASS 375x812 rule 30 j = 3 (doubling) q = 4: curve data = core (per 2, S 1, k 4, steps 8, ends at base 4, fibre 1/1)
PASS 375x812 rule 30 j = 3 (doubling) q = 4: event / base segments = core (1440 / 1440)
PASS 375x812 rule 30 j = 3 (doubling) q = 4: caption label "row 3, rule 30, q = 4: S_3 = 1, closes after 4 turns" and "monodromy nontrivial"
PASS 375x812 rule 30 j = 3 (doubling) q = 4: degenerate labels drawn [] in the caption and the card
PASS 375x812 rule 30 j = 3 (doubling) q = 4: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 30 j = 3 (doubling) q = 4: returns to base angle 0 marked: 5 (i = 0 … k)
PASS 375x812 rule 30 j = 3 (doubling) q = 4: ink on the canvas (amber events and cyan base steps; amber 311, cyan 433)
PASS 375x812 rule 30 j = 3 (doubling) q = 4: no horizontal page scroll
PASS 375x812 rule 30 j = 3 (doubling) q = 8: curve data = core (per 2, S 1, k 8, steps 16, ends at base 8, fibre 1/1)
PASS 375x812 rule 30 j = 3 (doubling) q = 8: event / base segments = core (2880 / 2880)
PASS 375x812 rule 30 j = 3 (doubling) q = 8: caption label "row 3, rule 30, q = 8: S_3 = 1, closes after 8 turns" and "monodromy nontrivial"
PASS 375x812 rule 30 j = 3 (doubling) q = 8: degenerate labels drawn [] in the caption and the card
PASS 375x812 rule 30 j = 3 (doubling) q = 8: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 30 j = 3 (doubling) q = 8: returns to base angle 0 marked: 9 (i = 0 … k)
PASS 375x812 rule 30 j = 3 (doubling) q = 8: ink on the canvas (amber events and cyan base steps; amber 557, cyan 773)
PASS 375x812 rule 30 j = 3 (doubling) q = 8: no horizontal page scroll
PASS 375x812 rule 30 j = 5 (stall) q = 1: curve data = core (per 8, S 6, k 1, steps 8, ends at base 1, fibre 6/1)
PASS 375x812 rule 30 j = 5 (stall) q = 1: event / base segments = core (540 / 180)
PASS 375x812 rule 30 j = 5 (stall) q = 1: caption label "row 5, rule 30, q = 1: S_5 = 6, closes after 1 turn" and "trivial (stall)"
PASS 375x812 rule 30 j = 5 (stall) q = 1: degenerate labels drawn [q1] in the caption and the card
PASS 375x812 rule 30 j = 5 (stall) q = 1: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 30 j = 5 (stall) q = 1: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 375x812 rule 30 j = 5 (stall) q = 1: ink on the canvas (amber events and cyan base steps; amber 897, cyan 21)
PASS 375x812 rule 30 j = 5 (stall) q = 1: no horizontal page scroll
PASS 375x812 rule 30 j = 5 (stall) q = 2: curve data = core (per 8, S 6, k 1, steps 8, ends at base 1, fibre 3/1)
PASS 375x812 rule 30 j = 5 (stall) q = 2: event / base segments = core (540 / 180)
PASS 375x812 rule 30 j = 5 (stall) q = 2: caption label "row 5, rule 30, q = 2: S_5 = 6, closes after 1 turn" and "trivial (stall)"
PASS 375x812 rule 30 j = 5 (stall) q = 2: degenerate labels drawn [] in the caption and the card
PASS 375x812 rule 30 j = 5 (stall) q = 2: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 30 j = 5 (stall) q = 2: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 375x812 rule 30 j = 5 (stall) q = 2: ink on the canvas (amber events and cyan base steps; amber 430, cyan 24)
PASS 375x812 rule 30 j = 5 (stall) q = 2: no horizontal page scroll
PASS 375x812 rule 30 j = 5 (stall) q = 4: curve data = core (per 8, S 6, k 2, steps 16, ends at base 2, fibre 3/1)
PASS 375x812 rule 30 j = 5 (stall) q = 4: event / base segments = core (1080 / 360)
PASS 375x812 rule 30 j = 5 (stall) q = 4: caption label "row 5, rule 30, q = 4: S_5 = 6, closes after 2 turns" and "trivial (stall)"
PASS 375x812 rule 30 j = 5 (stall) q = 4: degenerate labels drawn [] in the caption and the card
PASS 375x812 rule 30 j = 5 (stall) q = 4: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 30 j = 5 (stall) q = 4: returns to base angle 0 marked: 3 (i = 0 … k)
PASS 375x812 rule 30 j = 5 (stall) q = 4: ink on the canvas (amber events and cyan base steps; amber 472, cyan 52)
PASS 375x812 rule 30 j = 5 (stall) q = 4: no horizontal page scroll
PASS 375x812 rule 30 j = 5 (stall) q = 8: curve data = core (per 8, S 6, k 4, steps 32, ends at base 4, fibre 3/1)
PASS 375x812 rule 30 j = 5 (stall) q = 8: event / base segments = core (2160 / 720)
PASS 375x812 rule 30 j = 5 (stall) q = 8: caption label "row 5, rule 30, q = 8: S_5 = 6, closes after 4 turns" and "trivial (stall)"
PASS 375x812 rule 30 j = 5 (stall) q = 8: degenerate labels drawn [] in the caption and the card
PASS 375x812 rule 30 j = 5 (stall) q = 8: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 30 j = 5 (stall) q = 8: returns to base angle 0 marked: 5 (i = 0 … k)
PASS 375x812 rule 30 j = 5 (stall) q = 8: ink on the canvas (amber events and cyan base steps; amber 634, cyan 143)
PASS 375x812 rule 30 j = 5 (stall) q = 8: no horizontal page scroll
PASS 375x812 rule 90 j = 3 (density 0) q = 1: curve data = core (per 2, S 0, k 1, steps 2, ends at base 1, fibre 0/1)
PASS 375x812 rule 90 j = 3 (density 0) q = 1: event / base segments = core (0 / 720)
PASS 375x812 rule 90 j = 3 (density 0) q = 1: caption label "row 3, rule 90, q = 1: S_3 = 0, closes after 1 turn" and "trivial (stall)"
PASS 375x812 rule 90 j = 3 (density 0) q = 1: degenerate labels drawn [q1, S0, dens0] in the caption and the card
PASS 375x812 rule 90 j = 3 (density 0) q = 1: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 90 j = 3 (density 0) q = 1: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 375x812 rule 90 j = 3 (density 0) q = 1: ink on the canvas (cyan base steps; amber 0, cyan 192)
PASS 375x812 rule 90 j = 3 (density 0) q = 1: no horizontal page scroll
PASS 375x812 rule 90 j = 3 (density 0) q = 2: curve data = core (per 2, S 0, k 1, steps 2, ends at base 1, fibre 0/1)
PASS 375x812 rule 90 j = 3 (density 0) q = 2: event / base segments = core (0 / 720)
PASS 375x812 rule 90 j = 3 (density 0) q = 2: caption label "row 3, rule 90, q = 2: S_3 = 0, closes after 1 turn" and "trivial (stall)"
PASS 375x812 rule 90 j = 3 (density 0) q = 2: degenerate labels drawn [S0, dens0] in the caption and the card
PASS 375x812 rule 90 j = 3 (density 0) q = 2: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 90 j = 3 (density 0) q = 2: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 375x812 rule 90 j = 3 (density 0) q = 2: ink on the canvas (cyan base steps; amber 0, cyan 192)
PASS 375x812 rule 90 j = 3 (density 0) q = 2: no horizontal page scroll
PASS 375x812 rule 90 j = 3 (density 0) q = 4: curve data = core (per 2, S 0, k 1, steps 2, ends at base 1, fibre 0/1)
PASS 375x812 rule 90 j = 3 (density 0) q = 4: event / base segments = core (0 / 720)
PASS 375x812 rule 90 j = 3 (density 0) q = 4: caption label "row 3, rule 90, q = 4: S_3 = 0, closes after 1 turn" and "trivial (stall)"
PASS 375x812 rule 90 j = 3 (density 0) q = 4: degenerate labels drawn [S0, dens0] in the caption and the card
PASS 375x812 rule 90 j = 3 (density 0) q = 4: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 90 j = 3 (density 0) q = 4: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 375x812 rule 90 j = 3 (density 0) q = 4: ink on the canvas (cyan base steps; amber 0, cyan 192)
PASS 375x812 rule 90 j = 3 (density 0) q = 4: no horizontal page scroll
PASS 375x812 rule 90 j = 3 (density 0) q = 8: curve data = core (per 2, S 0, k 1, steps 2, ends at base 1, fibre 0/1)
PASS 375x812 rule 90 j = 3 (density 0) q = 8: event / base segments = core (0 / 720)
PASS 375x812 rule 90 j = 3 (density 0) q = 8: caption label "row 3, rule 90, q = 8: S_3 = 0, closes after 1 turn" and "trivial (stall)"
PASS 375x812 rule 90 j = 3 (density 0) q = 8: degenerate labels drawn [S0, dens0] in the caption and the card
PASS 375x812 rule 90 j = 3 (density 0) q = 8: card S_j, k, per_j, monodromy, density, F1
PASS 375x812 rule 90 j = 3 (density 0) q = 8: returns to base angle 0 marked: 2 (i = 0 … k)
PASS 375x812 rule 90 j = 3 (density 0) q = 8: ink on the canvas (cyan base steps; amber 0, cyan 192)
PASS 375x812 rule 90 j = 3 (density 0) q = 8: no horizontal page scroll
PASS 375x812 Layers: "Rule 30 ladder (D1)" switches the card on (rule 30, j = 3, q = 2; address view=rl=1)
PASS 375x812 j ▶ twice: j = 5, trivial (stall)
PASS 375x812 ◀ j: j = 4
PASS 375x812 selects: rule 150, j = 3, q = 8 → row 3, rule 150, q = 8: S_3 = 2, closes after 4 turns
PASS 375x812 address round trip (reload): same card
PASS 375x812 switch off: the comb picture is back, no D1 card, the dial values stay in the view string
PASS 375x812 refused dials (j = 99, q = 3): labelled, defaults drawn
PASS 375x812 fourier with rl=1 draws the same picture as without it
PASS 375x812 hopf with rl=1 draws the same picture as without it
PASS 375x812 D1 off: stage, canvas, caption, about, cards and address identical to v0.4.14 on 8 of 8 states
PASS 375x812 visible-control counts = v0.4.14 (pairs: 39/39/41/41/39/39/41/41/39/39/41/41)
PASS 375x812 visible controls with D1 on (menus closed): 41/41 (≤ 41)
PASS 375x812 no page errors or console errors
SUMMARY browser-check-v0416: 218 passed, 0 failed
```
