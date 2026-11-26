# Opus delta cold-pass verdict — II.23.9 combined candidate

**Verdict:** `PASS` (independent delta cold pass of Sol's corrective patch to the prior HOLD).
**Auditor:** Fable (Claude / Opus), this session. **Date:** 2026-07-23.
**Scope:** the patched combined candidate (entry + both sub-packets + verifiers + manifests +
delta note). No registered viewer was executed. **This PASS seats nothing and locks nothing.**

```yaml
registered_instance_evaluated: false
viewer_runtime_executed: false
verifiers_executed: true
seat_status: provisional (unchanged)
lock_status: not_locked
```

## Integrity (recomputed from delivered bytes)

- `ENTRY_II_23_9.md`   staged = `f0ebab91…3c854` = patched pin = adjacent `.sha256`. ✔
  previous pin `01279868…282be` = Fable's pre-HOLD combined entry (lineage confirmed).
- `II_23_9_combined.zip` staged = `85ff7e74…10766` = patched pin = adjacent `.sha256`. ✔
- Archive: 17 files; 0 absolute / traversal / backslash / duplicate names.

## Reproduced independently (not taken from the handoff)

- Combined manifest 9/9 OK; gearbox manifest 4/4 OK; foliation manifest 5/5 OK.
- Gearbox verifier: `RESULT: ALL PASS`, reproduces pinned `EXPECTED_OUTPUT.txt` line-for-line —
  including the new `[G3] fixed branch uses reduced pair; d is cover count, not link count`,
  `[VIEWER] reduced single-traversal winding = k_c/d`, and `[DOMAIN] requires rho>0 (n6!=0)`.
- Foliation verifier (unchanged): `RESULT: ALL PASS`, reproduces its pinned output.

## Mathematical delta — confirmed correct

Independent numeric check (unreduced winding of `u_c`, reduced-once winding, cover count),
over `(p,q)=(N,-c)` with `d=gcd(|p|,|q|)`, including `d>1` cases (4,2),(6,±3),(12,3),(9,3),(8,4):

- unreduced normalized-quotient winding `= k_c = p−q` in every case; ✔
- reduced-once winding `= k_c/d` in every case; ✔
- unreduced `= d ×` reduced, i.e. the single fixed-phase branch is a **d-fold cover** of its
  reduced image (one immersed curve), **not** a d-component link. ✔

The six corrections all hold: (1) degree is of the explicit normalized map `u_c:S¹→S¹`, not a
loop into `ℂP¹≃S²`; (2) `n6=0` zero fiber fenced out of the `ℂ×` domain; (3) `k_c` (unreduced,
with multiplicity) vs `k_c/d` (rendered reduced) separated; (4) G3 classifies from the reduced
pair `(p',q')` with `d` as cover multiplicity, link reserved for the phase-offset union; (5)
verifier exercises the distinction; (6) provenance no longer self-declares a gearbox PASS.

## Sol's requested confirmations — all met

1. Updated gearbox verifier reproduces newly pinned output line-for-line. ✔
2. Unchanged foliation verifier still reproduces its pinned output. ✔
3. Both sub-manifests and combined manifest match. ✔
4. Fixed-phase reduced-pair classification correct (numeric + G3 text + verifier). ✔
5. `k_c` vs `k_c/d` distinguished consistently in Def / Lemma / Rmk / Cor. ✔
6. No prose implies the separate Lean topological-degree bridge has compiled
   (Rmk register-scope guard explicitly disclaims it). ✔
7. No seat / lock / registered-viewer run inferred from this delta PASS. ✔

## Boundary

This delta PASS establishes internal mathematical and packet consistency for the patched
9/9a/9b (and re-confirms 9c/9d, unchanged). It does **not** seat Prop/Lemma/Cor, does **not**
lock, does **not** promote the EXT-VIS instrument to a theorem-bearing register, does **not**
assert the Lean degree bridge has compiled, and does **not** authorize a registered-instrument
run. Seat placement (II.23.9, final subsection of Part II / II.23, after L2472) and the lock
remain Robin's.

— Fable (Opus)
