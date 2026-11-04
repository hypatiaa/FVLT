import FVLTS4hFiniteTailV1
import FVLTS4hAlternatingZeroV1

set_option autoImplicit false

/-! Additive S4i framework. No decision of finite-state realizability is made.
The residual drops exactly one black output per consumed white input.
In phase10 the first output is before the first input in natural seed order;
in phase01 it is after that input. These are explicitly different maps. -/
namespace FVLT.S4iResidualV1

open Ruliology.CellularAutomata Rule30DrivenLeft
open FVLT.S4gLBEImplicationV1
open FVLT.S4hInfinitePinsV1 FVLT.S4hFiniteTailV1
open FVLT.S4hAlternatingZeroV1

abbrev Stream := Nat → Bool

def prepend (p : List Bool) (x : Stream) : Stream :=
  p.foldr (fun b y n => match n with
    | 0 => b
    | k + 1 => y k) x

def residual (F : Stream → Stream) (p : List Bool) : Stream → Stream :=
  fun x k => F (prepend p x) (p.length + k)

/-- A deterministic synchronous Boolean Mealy machine, with no final-output
word and no silent steps. A Moore output is the special case ignoring input. -/
structure Machine (S : Type) where
  step : S → Bool → S
  emit : S → Bool → Bool

def run {S : Type} (M : Machine S) (q : S) (p : List Bool) : S :=
  p.foldl M.step q

def eval {S : Type} (M : Machine S) (q : S) (x : Stream) (k : Nat) : Bool :=
  Nat.rec (motive := fun _ => S → Stream → Bool)
    (fun r y => M.emit r (y 0))
    (fun _ ih r y => ih (M.step r (y 0)) (fun n => y (n + 1))) k q x

def Realizes {S : Type} (M : Machine S) (q : S) (F : Stream → Stream) : Prop :=
  F = eval M q

theorem eval_prepend {S : Type} (M : Machine S) (q : S)
    (p : List Bool) (x : Stream) (k : Nat) :
    eval M q (prepend p x) (p.length + k) = eval M (run M q p) x k := by
  induction p generalizing q with
  | nil => simp [prepend, run]
  | cons b p ih =>
    simpa [List.length_cons, Nat.succ_add, prepend, eval, run] using
      ih (M.step q b)

theorem residual_eq_state {S : Type} (M : Machine S) (q : S)
    (F : Stream → Stream) (hF : Realizes M q F) (p : List Bool) :
    residual F p = eval M (run M q p) := by
  change F = eval M q at hF
  rw [hF]
  funext x k
  exact eval_prepend M q p x k

theorem equal_state_equal_residual {S : Type} (M : Machine S) (q : S)
    (F : Stream → Stream) (hF : Realizes M q F) (p r : List Bool)
    (h : run M q p = run M q r) : residual F p = residual F r := by
  rw [residual_eq_state M q F hF p, residual_eq_state M q F hF r, h]

theorem finite_residuals {S : Type} [Fintype S] (M : Machine S) (q : S)
    (F : Stream → Stream) (hF : Realizes M q F) :
    ∃ R : Finset (Stream → Stream), R.card ≤ Fintype.card S ∧
      ∀ p : List Bool, residual F p ∈ R := by
  classical
  refine ⟨Finset.univ.image (eval M), ?_, ?_⟩
  · exact (Finset.card_image_le).trans (by simp)
  · intro p
    rw [residual_eq_state M q F hF p]
    exact Finset.mem_image.mpr ⟨run M q p, Finset.mem_univ _, rfl⟩

/-- Every pairwise-distinct finite family of full residuals injects into the
machine states. Prefixes may have different lengths. -/
theorem residual_family_state_bound {S I : Type} [Fintype S] [Fintype I]
    (M : Machine S) (q : S) (F : Stream → Stream) (hF : Realizes M q F)
    (p : I → List Bool) (hp : Function.Injective (fun i => residual F (p i))) :
    Fintype.card I ≤ Fintype.card S := by
  apply Fintype.card_le_of_injective (fun i => run M q (p i))
  intro i j hij
  apply hp
  exact equal_state_equal_residual M q F hF (p i) (p j) hij

theorem distinct_n_residuals_state_bound {S : Type} [Fintype S]
    (M : Machine S) (q : S) (F : Stream → Stream) (hF : Realizes M q F)
    (n : Nat) (p : Fin n → List Bool)
    (hp : Function.Injective (fun i => residual F (p i))) :
    n ≤ Fintype.card S := by
  simpa using residual_family_state_bound M q F hF p hp

/-- Finite suffix/output witnesses are enough to certify a finite lower bound.
The witnesses are hypotheses to check, not an assumption of all-n separation. -/
theorem witness_state_bound {S I : Type} [Fintype S] [Fintype I]
    (M : Machine S) (q : S) (F : Stream → Stream) (hF : Realizes M q F)
    (p : I → List Bool)
    (hw : ∀ i j, i ≠ j → ∃ x k, residual F (p i) x k ≠ residual F (p j) x k) :
    Fintype.card I ≤ Fintype.card S := by
  apply residual_family_state_bound M q F hF p
  intro i j hij
  by_contra hne
  obtain ⟨x, k, hk⟩ := hw i j hne
  exact hk (congrFun (congrFun hij x) k)

theorem unbounded_residuals_no_finite_machine (F : Stream → Stream)
    (hu : ∀ n : Nat, ∃ p : Fin n → List Bool,
      Function.Injective (fun i => residual F (p i)))
    {S : Type} [Fintype S] (M : Machine S) (q : S) : ¬ Realizes M q F := by
  intro hF
  obtain ⟨p, hp⟩ := hu (Fintype.card S + 1)
  have h := distinct_n_residuals_state_bound M q F hF _ p hp
  omega

def driver (phase : Bool) (n : Nat) : Bool :=
  if n % 2 = 0 then phase else !phase

def whiteAt (phase : Bool) (k : Nat) : Nat := 2 * k + if phase then 1 else 0
def blackAt (phase : Bool) (k : Nat) : Nat := 2 * k + if phase then 0 else 1

theorem driver_alternates (phase : Bool) (n : Nat) :
    driver phase (n + 1) = !driver phase n := by
  by_cases hn : n % 2 = 0
  · have hs : (n + 1) % 2 ≠ 0 := by omega
    simp [driver, hn, hs]
  · have hs : (n + 1) % 2 = 0 := by omega
    simp [driver, hn, hs]

theorem whiteAt_white (phase : Bool) (k : Nat) :
    driver phase (whiteAt phase k) = false := by
  cases phase <;> simp [driver, whiteAt, Nat.add_mod, Nat.mul_mod]

theorem blackAt_black (phase : Bool) (k : Nat) :
    driver phase (blackAt phase k) = true := by
  cases phase <;> simp [driver, blackAt, Nat.add_mod, Nat.mul_mod]

def whiteIndex (phase : Bool) (k : Nat) : WhiteInfinite (driver phase) :=
  ⟨whiteAt phase k, whiteAt_white phase k⟩
def blackIndex (phase : Bool) (k : Nat) : BlackInfinite (driver phase) :=
  ⟨blackAt phase k, blackAt_black phase k⟩

theorem whiteAt_half (phase : Bool) (k : Nat) : whiteAt phase k / 2 = k := by
  cases phase <;> simp [whiteAt] <;> omega

theorem whiteAt_of_white (phase : Bool) (n : Nat) (hn : driver phase n = false) :
    whiteAt phase (n / 2) = n := by
  cases phase <;> by_cases hp : n % 2 = 0 <;>
    simp_all [driver, whiteAt] <;> omega

theorem blackAt_of_black (phase : Bool) (n : Nat) (hn : driver phase n = true) :
    blackAt phase (n / 2) = n := by
  cases phase <;> by_cases hp : n % 2 = 0 <;>
    simp_all [driver, blackAt] <;> omega

def expandWhite (phase : Bool) (x : Stream) : WhiteInfinite (driver phase) → Bool :=
  fun i => x (i.val / 2)
def compressWhite (phase : Bool) (u : WhiteInfinite (driver phase) → Bool) : Stream :=
  fun k => u (whiteIndex phase k)
def compressBlack (phase : Bool) (v : BlackInfinite (driver phase) → Bool) : Stream :=
  fun k => v (blackIndex phase k)

theorem expand_compress_white (phase : Bool)
    (u : WhiteInfinite (driver phase) → Bool) :
    expandWhite phase (compressWhite phase u) = u := by
  funext i
  apply congrArg u
  apply Subtype.ext
  exact whiteAt_of_white phase i.val i.property

theorem compress_expand_white (phase : Bool) (x : Stream) :
    compressWhite phase (expandWhite phase x) = x := by
  funext k
  change x (whiteAt phase k / 2) = x k
  rw [whiteAt_half]

/-- This is the actual S4h Phi in explicit increasing initial-bit coordinates.
phase=true means 10: white at 2k+1, black at 2k.
phase=false means 01: white at 2k, black at 2k+1. -/
noncomputable def compressedPhi (phase : Bool) (x : Stream) : Stream :=
  compressBlack phase (Phi (driver phase) (expandWhite phase x))

/-- Both compressed maps are causal in the synchronous convention: the first
n output bits depend only on the first n input bits. -/
theorem compressedPhi_causal (phase : Bool) (x y : Stream) (n : Nat)
    (h : ∀ j, j < n → x j = y j) (k : Nat) (hk : k < n) :
    compressedPhi phase x k = compressedPhi phase y k := by
  change infiniteBits (driver phase) (expandWhite phase x) (blackAt phase k) =
    infiniteBits (driver phase) (expandWhite phase y) (blackAt phase k)
  apply infiniteBits_causal (driver phase) _ _ (blackAt phase k + 1) _ _
    (Nat.lt_succ_self _)
  intro i hi
  change x (i.val / 2) = y (i.val / 2)
  apply h
  cases phase <;> simp [blackAt] at hi <;> omega

/-- phase10 is strictly causal: black bit k occurs before white bit k.
No corresponding strict-causality assertion is made for phase01. -/
theorem compressedPhi_true_strict_causal (x y : Stream) (k : Nat)
    (h : ∀ j, j < k → x j = y j) :
    compressedPhi true x k = compressedPhi true y k := by
  change infiniteBits (driver true) (expandWhite true x) (blackAt true k) =
    infiniteBits (driver true) (expandWhite true y) (blackAt true k)
  apply infiniteBits_causal (driver true) _ _ (blackAt true k + 1) _ _
    (Nat.lt_succ_self _)
  intro i hi
  change x (i.val / 2) = y (i.val / 2)
  apply h
  have he := whiteAt_of_white true i.val i.property
  simp [blackAt] at hi
  simp [whiteAt] at he
  omega

theorem expandWhite_eventuallyZero (phase : Bool) (x : Stream) :
    WhiteEventuallyZero (driver phase) (expandWhite phase x) ↔ EventuallyZero x := by
  constructor
  · rintro ⟨N, hN⟩
    refine ⟨N, fun k hk => ?_⟩
    have hNk : N ≤ (whiteIndex phase k).val := by
      change N ≤ whiteAt phase k
      cases phase <;> simp [whiteAt] <;> omega
    have h := hN (whiteIndex phase k) hNk
    change x (whiteAt phase k / 2) = false at h
    simpa only [whiteAt_half] using h
  · rintro ⟨N, hN⟩
    refine ⟨2 * N + 2, fun i hi => ?_⟩
    exact hN (i.val / 2) (by omega)

theorem compressBlack_eventuallyZero (phase : Bool)
    (v : BlackInfinite (driver phase) → Bool) :
    BlackEventuallyZero (driver phase) v ↔ EventuallyZero (compressBlack phase v) := by
  constructor
  · rintro ⟨N, hN⟩
    refine ⟨N, fun k hk => hN (blackIndex phase k) ?_⟩
    change N ≤ blackAt phase k
    cases phase <;> simp [blackAt] <;> omega
  · rintro ⟨N, hN⟩
    refine ⟨2 * N + 2, fun i hi => ?_⟩
    have h := hN (i.val / 2) (by omega)
    have he : blackIndex phase (i.val / 2) = i := by
      apply Subtype.ext
      exact blackAt_of_black phase i.val i.property
    change v (blackIndex phase (i.val / 2)) = false at h
    simpa only [he] using h

theorem compressedPhi_zero (phase : Bool) :
    compressedPhi phase (fun _ => false) = fun _ => true := by
  funext k
  exact congrFun (alternating_Phi_zero (driver phase) (driver_alternates phase))
    (blackIndex phase k)

theorem compressedPhi_zero_not_eventuallyZero (phase : Bool) :
    ¬ EventuallyZero (compressedPhi phase (fun _ => false)) := by
  rw [compressedPhi_zero]
  rintro ⟨N, hN⟩
  have h := hN N (Nat.le_refl N)
  cases h

/-- Exact coordinate transfer of the inherited finite-support criterion.
This does not exclude nonzero finite white prefixes followed by zero tails. -/
theorem finite_pins_iff_compressed_zero_tails (phase : Bool) :
    (∃ s : Int → Bool, FiniteLeft s ∧ Pins (driver phase) s) ↔
      ∃ x : Stream, EventuallyZero x ∧ EventuallyZero (compressedPhi phase x) := by
  rw [finite_pinned_iff_zero_to_zero]
  constructor
  · rintro ⟨u, hu, hv⟩
    refine ⟨compressWhite phase u, ?_, ?_⟩
    · apply (expandWhite_eventuallyZero phase _).mp
      simpa only [expand_compress_white] using hu
    · change EventuallyZero (compressBlack phase
        (Phi (driver phase) (expandWhite phase (compressWhite phase u))))
      rw [expand_compress_white]
      exact (compressBlack_eventuallyZero phase _).mp hv
  · rintro ⟨x, hx, hy⟩
    refine ⟨expandWhite phase x, (expandWhite_eventuallyZero phase x).mpr hx, ?_⟩
    exact (compressBlack_eventuallyZero phase _).mpr hy

/-- Direct specialization: any finite residual-witness family for the actual
compressed Phi bounds every synchronous realization of that same phase. -/
theorem compressedPhi_witness_state_bound {S I : Type} [Fintype S] [Fintype I]
    (phase : Bool) (M : Machine S) (q : S)
    (hF : Realizes M q (compressedPhi phase)) (p : I → List Bool)
    (hw : ∀ i j, i ≠ j → ∃ x k,
      residual (compressedPhi phase) (p i) x k ≠
        residual (compressedPhi phase) (p j) x k) :
    Fintype.card I ≤ Fintype.card S :=
  witness_state_bound M q (compressedPhi phase) hF p hw

end FVLT.S4iResidualV1
