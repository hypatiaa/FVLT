# Basel link v0.1.2 — divisor-cone readout linked into the Fourier host (repair successor)

## Repair of v0.1.1 (Astra delta audit: F1 closed; HOLD F2, 2026-09-28)

These are pinned and never written: candidate `MCOMB_FCA_M7_BASEL_LINK_v0_1_1_20260928` (viewer `9859cac0…`, pins `8b61e1c5…`) and `BASEL_FOURIER_HOST_LINK_ASTRA_DELTA_AUDIT_20260928/AUDIT.md` (`b30eaa56…`).

**F2 (keyboard isolation).** With the β slider focused, ← moved the host orbit φ₃ and Shift+→ moved the host spin, while β stayed put. The cause is the host's window-level keydown shortcut, which exempts only its own sliders. The builder tests had driven β through a diagnostic setter, which bypassed this event path.

**Repair.**
- Navigation keys pressed inside the panel (Arrow keys, Home, End, PageUp, PageDown) stop propagating at the panel root. This is the same pattern the host uses for its own inspector.
- No `preventDefault`, so native range, select and text behaviour is unchanged.
- The pinned host is not modified.
- Escape is deliberately not isolated: the host's Esc ↔ fullscreen toggle is a whole-viewer view action and changes no arithmetic state.
- The ∑ Basel cone toggle button itself sits in the host's s row, outside the panel, and behaves like the other host buttons there.

**New tests** (real key presses, no diagnostic setters):
- F2 reproduced on the pinned v0.1.1: ← moved φ₃, Shift+→ moved s, β stayed 2.
- In v0.1.2, the focused β slider responds natively to ←, →, Shift+←, Shift+→, ↑, ↓, PageUp, PageDown, Home and End. The slider, readout and panel agree, and the host φ₃, s / sExact and full state are unchanged.
- The cutoff select keeps its native keys (↓ 50, ↓ 100, End 200, Home 13, typing "5" gives 50), with the panel following. Left/Right with or without Shift leave the host unchanged.
- The divisor text input and the lattice canvas leave the host unchanged under arrows, with or without Shift.
- With focus outside the panel, host ← still steps φ₃ and Shift+→ still steps s. The host s slider keeps its own keys.

**Retry scope (Astra's nonblocking note), extended deliberately.** Every render trigger gets **3 attempts in total**, counting the first:
- a host change (new shell or base), retried by the poll;
- a β, cutoff or resize re-render on an unchanged host key, now also retried by the poll.

After the third failed attempt the failing section stays visibly "unavailable: display error" until the next trigger. Tests cover a single queued failure recovering on retry, and three queued failures staying failed and then recovering on the next β change.

# v0.1.1 (for reference)

**Standing: builder checks PASS; unsealed; re-audit pending.** No seal, seating or lock. Builder: Claude Opus 5.5, 2026-09-28. Idea: saphir. Mathematics, corrections and audits: Astra.

## Repair of v0.1 (Astra host-link audit, HOLD F1, 2026-09-28)

These are pinned and never written: the audited candidate `MCOMB_FCA_M7_BASEL_LINK_v0_1_20260928` (viewer `32cd10af…`, pins `3eab1f4d…`) and Astra's report `BASEL_FOURIER_HOST_LINK_ASTRA_AUDIT_20260928/AUDIT.md` (`40a0b218…`).

**F1.** After an atom the host accepts but M7 cannot take (direct base 1000003, a prime above M7's 10⁶ cap), `F.definition` threw. The panel then kept an older **AGREE**, divisor 24, and the old bars and strip, next to the new atom and Z.

**Repair:**
- **M7 domain checked first.** At most 16 primes, each ≤ 10⁶, exponents ≤ 64, B ≤ 256 bits. Outside it the route is `UNAVAILABLE / M7_DOMAIN`, with the cap stated in words (for 1000003, also that it lies outside the accepted schema's input domain). The M7 domain is not widened.
- **Unexpected host errors caught locally.** Any error raised by the host transform becomes `UNAVAILABLE / M7_HOST_ERROR`, with its message. The exact Euler route stays available in every case.
- **One atom per screen.** Every render first clears every section. Each section then renders independently and is stamped `data-atom = B`. A failing section shows "unavailable: display error" and is stamped empty, so no readout can present another atom as current.
- **Errors cleared on recovery.** Stored and visible errors are both cleared. A failed render is retried by the poll. In v0.1.2 every trigger gets 3 attempts in total (see above).
- **Test-only diagnostics hook.** `injectFaultOnce('m7' | section)` exercises these paths.

**New tests** (19 in the Basel browser suite, now 54 in all):
- Astra's path 24 → 1000003 → 999983 → 24, plus 1000003 → 7!, then 10! → 1000003 → 720. At every step every section describes the current B only, with the M7 status, Z, selected divisor, bars, strip and cursor all current and no error.
- An injected M7 exception gives `M7_HOST_ERROR`, then recovers.
- An injected bars failure leaves the others stamped current and the error shown for that B; the next poll recovers.
- An injected atom-section failure leaves no stored M7 result, then recovers.
- The retry cap after 3 failures, followed by recovery on a β change.

**Test finding (host, not panel).** v0.1's "opening leaves host state unchanged" check passed by timing. The unmodified host changes `state.cliffordLeafMode` from arithmetic to sweep about 0.25 s after load, when its elliptic-bridge module applies. The baseline is now taken only once host state has been quiescent for 1 s.

## The integration

This is an additive successor of the contact-sweep repair host `MCOMB_FCA_M7_CONTACT_SWEEP_REPAIR_20260926`. Its viewer `7e14d3756872f336195fea0b7ed4c88af8cb167ff1b64b82f99d6d7b0bc2a9e5` and `BUILD_PINS.json` `a6386022d44917ed06e28fa87beab52b9ac925698c529aae6fe5aad4b5d4a77a` are pinned and never written.

**What changed from the host:**
- The viewer is the host viewer plus **one** delimited block before `</body>`, between `<!-- BASEL_LINK_V0_1_2_BEGIN -->` and `<!-- BASEL_LINK_V0_1_2_END -->`. Remove the block and you get the host viewer back byte for byte.
- `BUILD_PINS.json` keeps every host entry except `viewerSha256`, and adds a `baselLink` section.
- Three files are added: `basel-core.js` (prototype v0.1.3 core, byte-identical), `basel-link-ui.js`, and this README.
- The other 171 files are byte-identical copies. Copied host documents describe the predecessor.

## What it is

An opt-in **∑ Basel cone** button sits beside the ◎ Contact sweep button. It opens a panel on Z_B(β) = Σ_{d|B} d^−β for the **host shell base B**, with:
- the divisor lattice, with selection;
- an integer Dirichlet exponent β;
- the gap bars (absent primes and exponent tails);
- the prime strip with certified logs, and the π(x) staircase;
- the factorial-shell chart.

This is the content of prototype v0.1.3, now fed by the host.

- **Atom = shell base B.** The host's own N is its orbit, N = B + 1 − φ₃. It is a different quantity and is never used here.
- **Read-only seam.** The panel reads `liftSourceSnapshot().shellBase / shellMode / n1`, polling every 250 ms, and only while it is open.
  - It never writes host state, calls no host setter and dispatches no events.
  - Shells are stepped with the host's own n₁ buttons or its direct base; the panel follows.
- **Spin independence.** The panel never reads the host spin s / sExact. β is panel-local.
- **Divisor route = the host's actual M7 transform.** It calls `window.McombFCAV1.definition / tuples / value / transforms` with the accepted v0.1.2 adapter:
  - input g(d) = (B/d)^β in canonical tuple order, with zeta ÷ B^β;
  - the Möbius round trip is asserted;
  - the result is cross-checked against the exact Euler route: "AGREE", or "CROSS-CHECK FAILED" if they differ.

  Outside the M7 domain or budgets the route states `M7_DOMAIN`, `M7_OBJECT_BUDGET`, `M7_VALUE_BITS` or `M7_HOST_ERROR` in words, and the exact Euler route stands alone.
- **β = 1** (Astra). The panel shows E_B(1) = B/φ(B) and the exact identity Z_B(1) = E_B(1)·∏_{p|B}(1 − p^−(v+1)); the second product is exactly what the finite exponent bounds omit. In factorial mode it adds the Mertens asymptotic e^γ log k, labelled as an asymptotic comparison only.
- **Prime strip.** It needs P ≥ the largest prime of B. With a direct base whose largest prime exceeds 200, the strip is unavailable and says so in words.

**Prototype-only quantities.** The prime strip, certified logs, remainder R_P and β = 1 display are not in the accepted schema BASEL_FOURIER_READOUT v0.1.2 (Astra delta audit PASS). Nothing is exported. Exporting them needs an explicitly versioned schema successor.

## Checks (builder, 2026-09-28)

Run everything with `node run-checks.cjs` in `../BASEL_FOURIER_HOST_LINK_WORK_v0_1_2_20260928/`. The evidence is in `evidence/` there.

| Suite | Result | What it establishes |
|---|---|---|
| integrity (`test-link-integrity.cjs`) | 17 PASS | as below, plus: the audited v0.1 candidate and Astra's audit evidence are unchanged. Earlier checks: | all pins verify; the viewer minus the block = host viewer byte for byte; 171 inherited files identical; host BUILD_PINS preserved except viewerSha256; identity recomputes; static checks: the link module never references host `state`, calls no setter, dispatches no events, never reads s / sExact, and does read `liftSourceSnapshot()` and call `McombFCAV1.transforms` |
| Basel browser (`test-link-browser.cjs`) | 67 PASS | v0.1.2 adds 13: F2 before/after with real keys, the select, text input and canvas, host shortcuts outside the panel, and same-key retry and cap. Earlier: 54 checks, | the v0.1 list below, plus the F1 repair tests above and a host-quiescence wait before the baseline |
| contact-sweep regression (`test-contact-regression.cjs`) | 31 PASS | the contact sweep's **own** browser suite, unmodified except for the package path, run against this viewer (served and standalone), with 0 page errors. Its console errors are the same kinds as in its original run: offline fonts and its own deliberate `/assess` abort and rate-limit probes |

The Basel browser suite covers:
- opt-in, and opening leaves host state unchanged;
- 4! from the host default, with the M7 output equal to an independent call of the host transform (zeta, inverse, tuples, M7_0.1.0) and the adapter input correct;
- following the host n₁ buttons from 6! to 13!, with Z, gap, absent-prime and tail values equal to the accepted fixtures;
- M7 AGREE up to 9! and `M7_OBJECT_BUDGET` from 10!;
- prime-step and exponent-step arrows, π(k) = ω(k!), and the chart cursor;
- 13! at β = 3 (Apéry), and the β = 1 identity (7!: E = 35/8);
- a β sweep 0–32, every cutoff, clicks and hovers, leaving the full host `state` unchanged;
- the host spin changed through the host input (sExact 0 → 3/2), with every panel value unchanged, and β changes leaving s unchanged;
- a direct base of 720, and 2·999983 with the strip unavailable;
- a closed panel not polling;
- the contact sweep opening alongside;
- no errors.

These are builder checks, not independent acceptance.

## Open

- Independent audit of this link.
- Noninteger β: UNRESOLVED.
- N = 1 host UI reachability: the host's factorial buttons start at 3!, and its direct base starts at 2.
- An export contract for the prototype-only quantities.
