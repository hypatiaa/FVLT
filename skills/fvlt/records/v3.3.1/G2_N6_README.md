# Correction candidate: Lemma II.23.9a, guard G2 (2026-10-30)

**Status: adopted by saphir 2026-10-30 ("our kernel needs to comply with the lean. I am good with that") at head `cbc595e`, and released in **v3.3.1**, LOCKED by saphir 2026-10-30 ("v3.3.1, lock it"), built in `kernel/post-v3.3.0/` from the locked v3.3.0 bytes (see its README and `docs/releases/v3.3.1/`; one placement adjustment to the lock-note sentence). Originally: candidate, not applied.** The locked v3.3.0 kernel (`kernel/successor/kernel.md`, SHA-256 `35ca26ee…e2b5ce`) and `CORRECTIONS.json` are unchanged. `CHANGES.json` holds the exact replacement (old/new text), ready to be folded into the next successor version through the normal repair process once it is reviewed and saphir adopts it.

**Request.** From skeleton (Claude Opus 5.5), relaying Stage 2 fresh semantic review row S2-0172. saphir, 2026-10-30: "Send the kernel issue to idea catalog to fix. Go with the corrected meaning."

## The problem
G2 (v3.3.0 lines 3101–3103) calls the branch change c ↦ −c "the $n_6$ / χ winding-reversal". That identifies it with two operations that are something else.

**Not the sign of $n_6$.** *Revised 2026-10-30 after saphir's clarification: "N6 was the flip across the y axis." The G2 text now also says that the lift itself does not apply the sign.*
- The sign of $n_6$ is the flip across the $y$ axis, $z\mapsto-\bar z$. FVLT Explorer v2.3.1 implements it the same way (§4.4: negate the real parts). On a phasor $re^{i\pi a}$ the flip gives $re^{i\pi(1-a)}$: a winding reversal plus a constant phase.
- On the II.23.9 lift, flipping both coordinates sends $(p,q)\mapsto(-p,-q)$ up to constant phases. c ↦ −c fixes $p$, so the two agree only when $p=Nt_1=0$.
- Def II.23.9 uses $\rho=|n_6|N^\alpha$ (line 3057), which ignores the sign.
- The first draft of this candidate followed the printed Rmk II.5a formula, which multiplies by the signed scalar $n_6$ and so gives a half-turn $z\mapsto -z$. That does not match the stated meaning. See "Open finding" below.

**Not chirality χ.** This is new here: skeleton asked for χ to be checked against its definition. As stated, the old parenthetical pairs $n_6$ and χ; both reverse the whole angular argument. The error is equating either one with c ↦ −c.
- χ is the §4.4 parity flip. The kernel says it "flips the entire angular argument" (line 1809, the Def 9.7o distinction).
- On the branch lift $(p,q)_c = (Nt_1, -ct_2)$, flipping the whole argument sends $(p,q) \mapsto (-p,-q)$ and the quotient degree $k_c \mapsto -k_c$.
- c ↦ −c fixes $p$ and sends only $q \mapsto -q$, so the degree goes from $Nt_1 + ct_2$ to $Nt_1 - ct_2$.
- The two coincide exactly when $p = Nt_1 = 0$, the static first coordinate.
- So χ does not name the c ↦ −c reversal either, and the candidate drops it.
- This reading takes the §4.4 description at face value on the II.23.9 lift. The kernel does not define χ on that lift, so the G2 text states the comparison conditionally: χ, *extended coordinatewise to the lift*, would reverse both windings. *Hedged 2026-10-30 after skeleton's fresh review of head f2dc33f.*

**What stays.** c ↦ −c sends q ↦ −q with p fixed. On the torus it is $(z_1,z_2) \mapsto (z_1,\bar z_2)$: winding reversal of the second coordinate only, a mirror pair of torus flows, with the reflected gearbox pair $Nt_1 \pm ct_2$. All of this is correct and kept.

## Second change: Rmk II.5a, the sign of $n_6$ (decided 2026-10-30)
**Decision.** saphir, relayed by skeleton (Stack Bus #1060; "I prefer Opus idea"): restate II.5a so that the sign of $n_6$ is the $y$-axis reflection $z\mapsto-\bar z$, not multiplication by −1. The old scalar reading stays correct as a statement about the scalar operation; it is history, not the sign of $n_6$.

**Parameter change** (`N6-II5a-SIGN-AS-Y-REFLECTION`, v3.3.0 lines 661–666):
- $n_6$ now enters as **magnitude** $|n_6|$, through the radius $r_\alpha = |n_6|n_3^\alpha$, the same as the old $|R_\alpha|$.
- Its **sign** sets the orientation:
  - for $n_6<0$, $z_j = -r e^{-i\theta_j} = -\overline{re^{i\theta_j}}$, where the old form gave $-re^{+i\theta_j}$;
  - $n_6>0$ and $n_6=0$ are unchanged.
- An inserted paragraph states the correction, the difference from the old half-turn, and that the two agree only on the real axis.

**Guards kept:**
- the $n_3=0$ exclusion and the $n_6=0$ collapse;
- the conjugate pair $z_2=\overline{z_1}$ at integer $s$ and integer $t_1$, since $\overline{-\bar w}=-w$;
- the contact identity, unchanged because $\operatorname{Im}(-\bar z)=\operatorname{Im}z$, and its negative real ray;
- the $n_6=1$ reference specialization;
- the Scope paragraph, including Robin's in-body S2 closure lock of 2026-08-19, which is not touched.

**Reader notes.**
- **(a) What changes in the picture.** For $n_6<0$ the phase addresses satisfy $a_1+a_2=2t_1s$. Whenever $t_1s$ is an integer, in particular at integer $s$ and integer $t_1$ where II.5a states the conjugate pair, the new point pair is the old pair with $z_1$ and $z_2$ swapped. The drawn rosette is then unchanged; only the labels and the sign of $\operatorname{Im}z_1$ change. The image itself changes only when $t_1s$ is not an integer and at least one old point is off the real axis. Recorded in `CHANGES.json` (`reader_notes`), checked in section 6 of the script.
- **(b) Label mismatch, recorded, not resolved.** FVLT Explorer v2.3.1 labels its $n_6$ $y$-flip "§4.4 Chirality". Kernel χ is per-phasor conjugation $z\mapsto\bar z$ (line 1809), which differs from the $y$-reflection $z\mapsto-\bar z$ by a constant half-turn. The candidate does not equate them.

**Contact hypothesis** (`N6-II5a-CONTACT-GUARD`): "Assume $R_\alpha(n_3)\ne0$" becomes "Assume $n_6\ne0$". This sentence was introduced by REPAIR-HUNK-036, so the change amends that replacement's new text rather than the base.

**χ, pinned to its definition.**
- §4.4 (line 1305) defines chirality as the parity that decides whether the phasor advances clockwise or counterclockwise. Line 1809 says it flips the entire angular argument, i.e. per-phasor conjugation $z\mapsto\bar z$.
- The $y$-axis reflection is $z\mapsto-\bar z$, which differs from χ by a constant half-turn.
- The candidate does not identify the two. It says only that both reverse both windings and that neither is c ↦ −c.

**Explorer pin.** FVLT Explorer v2.3.1 (sha256 `08ac40ff…8726`, uploaded 2026-10-20, not bundled), `computeState`/`computeWalk`: sign($n_6$) negates the real parts.

**Lean.** An additive successor module for the reflection law is being built by codex-fvlt-formalization. `FVLTN6MirrorV1.point_neg_scale_halfturn` stays, as a true statement about the scalar operation.

## Constraints honoured
- **No in-place edit of the locked bytes.** No status label changes; Lemma II.23.9a stays "unconditional".
- **Item lock.** The G2 text is in the item-locked II.23.9 fold (Robin, 2026-07-23; lock record `LOCK_RECORD_II_23_9_2026-07-23.md`). The bookkeeping is now part of the change set, so it is applied together with G2:
  - `G2-N6-LOCK-NOTE-VII2a` (line 4665, amends the new text of `REPAIR14-FIX2-II239-HEADER`): "two declared edits" becomes three, adding G2-N6-CHI-PARENTHETICAL beside `REPAIR-HUNK-146` and `REPAIR14-C-02-POINTER`.
  - `G2-N6-CONCORDANCE-ROW` (line 4621, base text): the Lemma II.23.9a row, "folded verbatim from the locked entry", gains a pointer to the declared G2 edit.
  - `G2-N6-RELEASE-SCOPE-a/b/c` (line 7, amends the new text of `REPAIR-HUNK-002`): twenty-two item-locked replacements become twenty-three (the 22 was recounted by script), the II.23.9 entry lists the new edit, and G2 is added to the locked statements whose mathematics is corrected. That last classification is this candidate's reading; if saphir prefers to call it a gloss correction, drop `-c`.
  - The next release's item-lock intersection list (`docs/releases/<version>/ITEM_LOCK_INTERSECTIONS*`) must also list it.
- **II.5a lock.** The II.5a edits are outside its only lock span, the S2 closure paragraph (line 697, `ITEM_LOCK_INTERSECTIONS_v2.json`).
- **Base match.** The replacement's old text occurs exactly once in both the v3.2.7 base (`kernel/next/kernel.md`), against which `CORRECTIONS.json` applies, and in v3.3.0.

## Evidence
`check_g2_n6.py` (stdlib, exact rationals), output `check_g2_n6.out`: **1,536 + 42 + 14,580 + 6,294 checks pass**. Only checks that actually run are counted; the earlier figure 16,200 for the restated II.5a over-counted the $n_6<0$ reflection check, which runs only for negative $n_6$. Each section reports substantive checks and checks that hold by construction (restating a definition or the normal form) separately:

| Section | Checks | Substantive | By construction |
|---|---:|---:|---:|
| 1–3. Printed II.5a, ρ, c ↦ −c vs χ | 1,536 | 360 | 1,176 |
| 4. $y$-axis flip | 42 | 24 | 18 |
| 5. Restated II.5a | 14,580 | 9,720 | 4,860 |
| 6. Reader note (a) | 6,294 | 6,294 | 0 |

They cover:
- the printed II.5a scalar half-turn (address + 1), and the $y$-axis flip ($a\mapsto 1-a$), which equals the scalar half-turn only on the real axis;
- ρ ignoring the sign of n₆;
- p fixed and q ↦ −q under c ↦ −c, with the reflected gearbox pair;
- χ coinciding with c ↦ −c exactly when p = 0;
- for restated II.5a: the radius is unchanged, $n_6<0$ is the $y$-reflection of $n_6>0$ (both by construction), and the conjugate pair and contact set are preserved (identical to the old contact set);
- reader note (a): for $n_6<0$ the new pair is the old pair swapped exactly when $t_1s$ is an integer, and the drawn image changes exactly when $t_1s$ is not an integer and an old point is off the real axis.

Run with `python -I -B check_g2_n6.py`.

## Next steps
1. Independent review of this exact text.
2. saphir's adoption.
3. Fold into `CORRECTIONS.json` as a successor version (v3.3.1 candidate), with the item-lock record above.
