import FVLTS4kCoreV1

/-! PRIVATE S4k source preparation only; no compilation or execution claimed.
All-phase BaseFinite follows governing Addendum 1, replacing the old sketch.
The finite-maximum method is credited to the shared theorem kit. -/
set_option autoImplicit false

namespace FVLT.S4kDomReductionV1

open Ruliology.CellularAutomata Rule30DrivenLeft
open FVLT.S4kCoreV1

/-- A common inclusive deadline for every phase at this physical width. -/
def UniformDeadBy (c : Nat → Bool) (P W T : Nat) : Prop :=
  ∀ φ : Fin P, DeadBy (phase c φ) W T

/-- Local finiteness; there is deliberately no default death time. -/
def PhaseFinite (c : Nat → Bool) (P W : Nat) : Prop :=
  ∀ φ : Fin P, ∃ D : Nat, DeadBy (phase c φ) W D

/-- The authorized maximum of phasewise LEAST death times, only in a finite
context. This is not an executable candidate seed map. -/
noncomputable def DStar (c : Nat → Bool) (P W : Nat)
    (h : PhaseFinite c P W) : Nat := by
  classical
  exact Finset.univ.sup (fun φ : Fin P => Nat.find (h φ))

theorem dStar_deadBy (c : Nat → Bool) (P W : Nat)
    (h : PhaseFinite c P W) : UniformDeadBy c P W (DStar c P W h) := by
  classical
  intro φ
  apply deadBy_mono (D := Nat.find (h φ))
  · exact Finset.le_sup (f := fun φ : Fin P => Nat.find (h φ))
      (Finset.mem_univ φ)
  · exact Nat.find_spec (h φ)

/-- The finite maximum is the LEAST common deadline, not just an upper bound. -/
theorem dStar_le_iff (c : Nat → Bool) (P W T : Nat)
    (h : PhaseFinite c P W) :
    DStar c P W h ≤ T ↔ UniformDeadBy c P W T := by
  classical
  constructor
  · intro ht φ
    exact deadBy_mono ht (dStar_deadBy c P W h φ)
  · intro ht
    unfold DStar
    exact Finset.sup_le (fun φ _ => Nat.find_min' (h φ) (ht φ))

theorem uniform_step (c : Nat → Bool) (P Δ W0 : Nat)
    (F : Fin P → Nat → (Int → Bool) → Int → Bool)
    (ψ : Fin P → Fin P) (hd : DOMContract c P Δ W0 F ψ)
    {W T : Nat} (hw : W0 ≤ W) (ht : UniformDeadBy c P W T) :
    UniformDeadBy c P (W + P) (T + Δ) := by
  intro φ s hs hsurv
  obtain ⟨hwidth, htransport⟩ := hd φ W hw s hs
  exact ht (ψ φ) (F φ W s) hwidth (htransport T hsurv)

/-- One common finite maximum covers the entire finite base rectangle. -/
theorem base_uniform (c : Nat → Bool) (P W0 : Nat)
    (hb : BaseFinite c P W0) :
    ∃ B : Nat, ∀ W : Nat, W < W0 + P → UniformDeadBy c P W B := by
  classical
  let b : Fin (W0 + P) → Nat := fun w => DStar c P w.val (fun φ => hb φ w.val w.isLt)
  let B := Finset.univ.sup b
  refine ⟨B, ?_⟩
  intro W hW φ
  exact deadBy_mono (Finset.le_sup (f := b) (Finset.mem_univ (⟨W, hW⟩ : Fin (W0 + P))))
    (dStar_deadBy c P W (fun φ => hb φ W hW) φ)

/-- Strong induction descends by the positive stride P. No periodicity,
phase-surjectivity, or phase-return hypothesis is used. -/
theorem all_widths_uniform (c : Nat → Bool) (P Δ W0 : Nat)
    (F : Fin P → Nat → (Int → Bool) → Int → Bool)
    (ψ : Fin P → Fin P) (hp : 0 < P)
    (hd : DOMContract c P Δ W0 F ψ) (hb : BaseFinite c P W0) :
    ∀ W : Nat, ∃ T : Nat, UniformDeadBy c P W T := by
  obtain ⟨B, hB⟩ := base_uniform c P W0 hb
  intro W
  induction W using Nat.strong_induction_on with
  | h W ih =>
    by_cases hw : W < W0 + P
    · exact ⟨B, hB W hw⟩
    · have hsmall : W - P < W := by omega
      obtain ⟨T, hT⟩ := ih (W - P) hsmall
      have hstart : W0 ≤ W - P := by omega
      have he : W - P + P = W := by omega
      refine ⟨T + Δ, ?_⟩
      simpa only [he] using uniform_step c P Δ W0 F ψ hd hstart hT

theorem all_widths_finite (c : Nat → Bool) (P Δ W0 : Nat)
    (F : Fin P → Nat → (Int → Bool) → Int → Bool)
    (ψ : Fin P → Fin P) (hp : 0 < P)
    (hd : DOMContract c P Δ W0 F ψ) (hb : BaseFinite c P W0) :
    ∀ W : Nat, PhaseFinite c P W := by
  intro W φ
  obtain ⟨T, hT⟩ := all_widths_uniform c P Δ W0 F ψ hp hd hb W
  exact ⟨T, hT φ⟩

/-- Iterated DOM on one residue ladder, with exact number n of steps. -/
theorem ladder_deadline (c : Nat → Bool) (P Δ W0 : Nat)
    (F : Fin P → Nat → (Int → Bool) → Int → Bool)
    (ψ : Fin P → Fin P) (hd : DOMContract c P Δ W0 F ψ)
    {r T : Nat} (hr : W0 ≤ r) (ht : UniformDeadBy c P r T) :
    ∀ n : Nat, UniformDeadBy c P (r + n * P) (T + Δ * n) := by
  intro n
  induction n with
  | zero => simpa using ht
  | succ n ih =>
    have hs : W0 ≤ r + n * P := by omega
    have hn := uniform_step c P Δ W0 F ψ hd hs ih
    simpa only [Nat.succ_mul, Nat.mul_succ, Nat.add_assoc] using hn

/-- Sharp residue-ladder bound, conditional on the same DOM and finite base. -/
theorem dStar_ladder (c : Nat → Bool) (P Δ W0 : Nat)
    (F : Fin P → Nat → (Int → Bool) → Int → Bool)
    (ψ : Fin P → Fin P) (hp : 0 < P)
    (hd : DOMContract c P Δ W0 F ψ) (hb : BaseFinite c P W0)
    {r : Nat} (hr : W0 ≤ r) (n : Nat) :
    DStar c P (r + n * P) (all_widths_finite c P Δ W0 F ψ hp hd hb _) ≤
      DStar c P r (all_widths_finite c P Δ W0 F ψ hp hd hb r) + Δ * n := by
  apply (dStar_le_iff c P (r + n * P) _ _).mpr
  exact ladder_deadline c P Δ W0 F ψ hd hr (dStar_deadBy c P r _) n

/-- Residue decomposition with the exact quotient used in Addendum 1. -/
theorem residue_decomposition (P W0 W : Nat) (hp : 0 < P) (hw : W0 ≤ W) :
    let r := W0 + (W - W0) % P
    W0 ≤ r ∧ r < W0 + P ∧ r ≤ W ∧
      W = r + ((W - r) / P) * P ∧ W % P = r % P := by
  dsimp
  have hm := Nat.mod_lt (W - W0) hp
  have he : (W - W0) % P + ((W - W0) / P) * P = W - W0 := by
    simpa only [Nat.mul_comm P] using Nat.mod_add_div (W - W0) P
  let n := (W - W0) / P
  have hs : W - (W0 + (W - W0) % P) = n * P := by
    dsimp [n]
    omega
  have hq : (W - (W0 + (W - W0) % P)) / P = n := by
    rw [hs]
    exact Nat.mul_div_cancel n hp
  have hrepr : W = W0 + (W - W0) % P + n * P := by
    dsimp [n]
    omega
  refine ⟨by omega, by omega, by omega, ?_, ?_⟩
  · rw [hq]
    exact hrepr
  · calc
      W % P = (W0 + (W - W0) % P + n * P) % P := congrArg (fun x : Nat => x % P) hrepr
      _ = (W0 + (W - W0) % P) % P := by simp

/-- Exact governing G4. Multiplication is applied AFTER the exact quotient. -/
theorem dStar_residue_bound (c : Nat → Bool) (P Δ W0 : Nat)
    (F : Fin P → Nat → (Int → Bool) → Int → Bool)
    (ψ : Fin P → Fin P) (hp : 0 < P)
    (hd : DOMContract c P Δ W0 F ψ) (hb : BaseFinite c P W0)
    {W : Nat} (hw : W0 + P ≤ W) :
    let r := W0 + (W - W0) % P
    DStar c P W (all_widths_finite c P Δ W0 F ψ hp hd hb W) ≤
      DStar c P r (all_widths_finite c P Δ W0 F ψ hp hd hb r) + Δ * ((W-r)/P) := by
  dsimp
  let r := W0 + (W - W0) % P
  obtain ⟨hr, _, _, he, _⟩ := residue_decomposition P W0 W hp (by omega)
  have hh := dStar_ladder c P Δ W0 F ψ hp hd hb hr ((W-r)/P)
  dsimp [r] at hh
  simpa only [← he] using hh

/-- Actual S4j obstruction, reached through width coverage and pin survival. -/
theorem dom_base_noFinitePins (c : Nat → Bool) (P Δ W0 : Nat)
    (F : Fin P → Nat → (Int → Bool) → Int → Bool)
    (ψ : Fin P → Fin P) (hp : 0 < P)
    (hd : DOMContract c P Δ W0 F ψ) (hb : BaseFinite c P W0) :
    FVLT.S4jBoundedDeathV1.NoFinitePins c := by
  intro s hs hpin
  obtain ⟨W, hW⟩ := finiteLeft_hasWidth hs
  obtain ⟨T, hT⟩ := all_widths_uniform c P Δ W0 F ψ hp hd hb W
  have hzero : phase c (⟨0, hp⟩ : Fin P) = c := by
    funext t
    simp [phase]
  have hdead := hT (⟨0, hp⟩ : Fin P)
  rw [hzero] at hdead
  exact hdead s hW (pins_surv hpin T)

/-- K1 conditional, using the existing S4j library theorem. No driver instance
or admissible explicit map is asserted by this reduction. -/
theorem dom_base_boundedDeath (c : Nat → Bool) (P Δ W0 : Nat)
    (F : Fin P → Nat → (Int → Bool) → Int → Bool)
    (ψ : Fin P → Fin P) (hp : 0 < P)
    (hd : DOMContract c P Δ W0 F ψ) (hb : BaseFinite c P W0) :
    FVLT.S4jBoundedDeathV1.BoundedDeath c :=
  FVLT.S4jBoundedDeathV1.noFinitePins_boundedDeath c
    (dom_base_noFinitePins c P Δ W0 F ψ hp hd hb)

end FVLT.S4kDomReductionV1


