import FVLTS4hInfinitePinsV1
import FVLTS4hFiniteTailV1
import FVLTS4lZeroBoundaryV1
import Ruliology.CellularAutomata.Rule30ZeroBoundary

/-! PRIVATE S4m Part A. SOURCE ONLY, not elaborated. Initial white coordinates
and temporal Theta parameters are distinct. No finite-state result, mortality
result or novelty is claimed. Definitions inherited from S4h/S4l and the kit. -/
set_option autoImplicit false

namespace FVLT.S4mCoordinatesV1

open Ruliology.CellularAutomata Rule30DrivenLeft Rule30ZeroBoundary
open FVLT.S4gLeftScreenV1 FVLT.S4gForcedBitCountV1 FVLT.S4gLBEImplicationV1
open FVLT.S4hInfinitePinsV1 FVLT.S4hFiniteTailV1 FVLT.S4kCoreV1
open FVLT.S4lZeroBoundaryV1

/-- Literal black-even driver 10; its seed index n is physical depth n+1. -/
def c10 : Nat → Bool := singleBlack 2 ⟨0, by omega⟩
/-- Literal black-odd driver 01. -/
def c01 : Nat → Bool := singleBlack 2 ⟨1, by omega⟩

def white10 (i : Nat) : WhiteInfinite c10 :=
  ⟨2 * i + 1, by simp [c10, singleBlack, show (2 * i + 1) % 2 = 1 by omega]⟩
def black10 (i : Nat) : BlackInfinite c10 :=
  ⟨2 * i, by simp [c10, singleBlack, show (2 * i) % 2 = 0 by omega]⟩
def white01 (i : Nat) : WhiteInfinite c01 :=
  ⟨2 * i, by simp [c01, singleBlack, show (2 * i) % 2 = 0 by omega]⟩
def black01 (i : Nat) : BlackInfinite c01 :=
  ⟨2 * i + 1, by simp [c01, singleBlack, show (2 * i + 1) % 2 = 1 by omega]⟩

def input10 (u : Nat → Bool) : WhiteInfinite c10 → Bool := fun j => u (j.val / 2)
def input01 (u : Nat → Bool) : WhiteInfinite c01 → Bool := fun j => u (j.val / 2)
noncomputable def completion10 (u : Nat → Bool) : Nat → Bool := infiniteBits c10 (input10 u)
noncomputable def completion01 (u : Nat → Bool) : Nat → Bool := infiniteBits c01 (input01 u)
noncomputable def body10 (u : Nat → Bool) (i : Nat) : Bool := Phi c10 (input10 u) (black10 i)
noncomputable def body01 (u : Nat → Bool) (i : Nat) : Bool := Phi c01 (input01 u) (black01 i)

/-- Prefix equality is about physical white-input order, never temporal heads. -/
def SamePrefix (u v : Nat → Bool) (n : Nat) : Prop := ∀ i : Nat, i < n → u i = v i

def appendPrefix {n : Nat} (u : Fin n → Bool) (z : Nat → Bool) (i : Nat) : Bool :=
  if h : i < n then u ⟨i, h⟩ else z (i - n)

/-- Unrestricted all-continuation residuals. The stripped delays differ by phase. -/
def Residual10 {n : Nat} (u v : Fin n → Bool) : Prop :=
  ∀ z : Nat → Bool, ∀ i : Nat,
    body10 (appendPrefix u z) (n + 1 + i) = body10 (appendPrefix v z) (n + 1 + i)
def Residual01 {n : Nat} (u v : Fin n → Bool) : Prop :=
  ∀ z : Nat → Bool, ∀ i : Nat,
    body01 (appendPrefix u z) (n + i) = body01 (appendPrefix v z) (n + i)

/-- Temporal odd-time zero-boundary head, extracted from an initial-white completion. -/
noncomputable def temporalOfInitial (u : Nat → Bool) (i : Nat) : Bool :=
  zrow (depthRow (bitRow (completion10 u))) (2 * i + 1) 1
/-- The white INITIAL coordinates of Theta f, at physical even depths. -/
def initialOfTemporal (f : Nat → Bool) (i : Nat) : Bool := Theta f (2 * i + 2)

theorem completion10_white (u : Nat → Bool) (i : Nat) :
    completion10 u (2 * i + 1) = u i := by
  have hh := infiniteBits_white c10 (input10 u) (white10 i)
  change completion10 u (2 * i + 1) = u ((2 * i + 1) / 2) at hh
  simpa only [show (2 * i + 1) / 2 = i by omega] using hh

theorem completion01_white (u : Nat → Bool) (i : Nat) :
    completion01 u (2 * i) = u i := by
  have hh := infiniteBits_white c01 (input01 u) (white01 i)
  change completion01 u (2 * i) = u ((2 * i) / 2) at hh
  simpa only [show (2 * i) / 2 = i by omega] using hh

theorem body10_at (u : Nat → Bool) (i : Nat) :
    body10 u i = completion10 u (2 * i) := rfl

theorem body01_at (u : Nat → Bool) (i : Nat) :
    body01 u i = completion01 u (2 * i + 1) := rfl

theorem body10_zero (u : Nat → Bool) : body10 u 0 = true := by
  have hh := infiniteBits_pins c10 (input10 u) 0 (by rfl)
  change completion10 u 0 = true at hh
  exact hh

/-- n initial white bits determine seed coordinates0..2n, including black output n. -/
theorem completion10_prefix (u v : Nat → Bool) (n k : Nat)
    (huv : SamePrefix u v n) (hk : k ≤ 2 * n) :
    completion10 u k = completion10 v k := by
  apply infiniteBits_causal c10 (input10 u) (input10 v) (2 * n + 1) ?_ k (by omega)
  intro j hj
  have hp := j.property
  have hm : j.val % 2 = 1 := by
    by_contra hn
    have hz : j.val % 2 = 0 := by omega
    have hb : c10 j.val = true := by simp [c10, singleBlack, hz]
    rw [hb] at hp
    contradiction
  exact huv (j.val / 2) (by omega)

/-- n initial white bits determine seed coordinates<2n for the other phase. -/
theorem completion01_prefix (u v : Nat → Bool) (n k : Nat)
    (huv : SamePrefix u v n) (hk : k < 2 * n) :
    completion01 u k = completion01 v k := by
  apply infiniteBits_causal c01 (input01 u) (input01 v) (2 * n) ?_ k hk
  intro j hj
  exact huv (j.val / 2) (by omega)

theorem body10_causal (u v : Nat → Bool) (n i : Nat)
    (huv : SamePrefix u v n) (hi : i ≤ n) : body10 u i = body10 v i := by
  rw [body10_at, body10_at]
  exact completion10_prefix u v n (2 * i) huv (by omega)

theorem body01_causal (u v : Nat → Bool) (n i : Nat)
    (huv : SamePrefix u v n) (hi : i < n) : body01 u i = body01 v i := by
  rw [body01_at, body01_at]
  exact completion01_prefix u v n (2 * i + 1) huv (by omega)

/-- Reconstruction uniqueness identifies the full positive-depth initial row. -/
theorem completion10_theta (u : Nat → Bool) (d : Nat) (hd : 1 ≤ d) :
    depthRow (bitRow (completion10 u)) d = Theta (temporalOfInitial u) d := by
  have hs : ∀ K : Nat, Surv c10 (bitRow (completion10 u)) K :=
    fun K => pins_surv (infiniteBits_pins c10 (input10 u)) K
  have hc : IsolatedBlack c10 := singleBlack_isolated (by omega) ⟨0, by omega⟩
  have hx : InX (depthRow (bitRow (completion10 u))) := by
    intro i
    have hb : c10 (2 * i) = true := by simp [c10, singleBlack, show (2 * i) % 2 = 0 by omega]
    have hh := (all_surv_iff_zeroSamples c10 _ hc).mp hs (2 * i) hb
    have he := L_eq_zrow (bitRow (completion10 u)) (2 * i) 1 (Nat.le_refl 1)
    change L (fun _ => false) (bitRow (completion10 u)) (2 * i) (-1) =
      zrow (depthRow (bitRow (completion10 u))) (2 * i) 1 at he
    exact he.symm.trans hh
  have he := congrFun (Theta_unique hx (f := temporalOfInitial u) (fun _ => rfl)) d
  rw [zrow_zero_of_pos _ hd] at he
  exact he

/-- Theta's constrained temporal history gives actual driven pins in phase10. -/
theorem theta_pins10 (f : Nat → Bool) :
    Pins c10 (bitRow (fun n => Theta f (n + 1))) := by
  let a : Nat → Bool := fun n => Theta f (n + 1)
  have hag : ∀ d : Nat, 1 ≤ d → depthRow (bitRow a) d = Theta f d := by
    intro d hd
    have hn : d - 1 + 1 = d := by omega
    have he := bitRow_at a (d - 1)
    change bitRow a (-((d - 1 + 1 : Nat) : Int)) = Theta f (d - 1 + 1) at he
    change bitRow a (-(d : Int)) = Theta f d
    simpa only [hn] using he
  have hc : IsolatedBlack c10 := singleBlack_isolated (by omega) ⟨0, by omega⟩
  intro t ht
  have hz : ZeroSamples c10 (bitRow a) t := by
    intro j hj hb
    have hm : j % 2 = 0 := by simpa [c10, singleBlack] using hb
    have he := L_eq_zrow (bitRow a) j 1 (Nat.le_refl 1)
    change L (fun _ => false) (bitRow a) j (-1) = zrow (depthRow (bitRow a)) j 1 at he
    rw [he, zrow_congr hag]
    have hh := Theta_inX f (j / 2)
    rwa [show 2 * (j / 2) = j by omega] at hh
  exact (surv_iff_zeroSamples c10 (bitRow a) t hc).mpr hz t (Nat.le_refl t) ht

/-- Initial-white completion and temporal reconstruction give the same row. -/
theorem completion10_initialOfTemporal (f : Nat → Bool) (k : Nat) :
    completion10 (initialOfTemporal f) k = Theta f (k + 1) := by
  have he := infiniteBits_unique c10 (input10 (initialOfTemporal f))
    (fun n => Theta f (n + 1)) (theta_pins10 f) (by
      intro j
      have hp := j.property
      have hm : j.val % 2 = 1 := by
        by_contra hn
        have hz : j.val % 2 = 0 := by omega
        have hb : c10 j.val = true := by simp [c10, singleBlack, hz]
        rw [hb] at hp
        contradiction
      change Theta f (j.val + 1) = Theta f (2 * (j.val / 2) + 2)
      congr 1
      omega)
  exact congrFun he.symm k

theorem initialOfTemporal_temporalOfInitial (u : Nat → Bool) :
    initialOfTemporal (temporalOfInitial u) = u := by
  funext i
  have he := completion10_theta u (2 * i + 2) (by omega)
  have hb := bitRow_at (completion10 u) (2 * i + 1)
  rw [show 2 * i + 1 + 1 = 2 * i + 2 by omega] at hb
  change bitRow (completion10 u) (-((2 * i + 2 : Nat) : Int)) =
    Theta (temporalOfInitial u) (2 * i + 2) at he
  rw [hb, completion10_white] at he
  exact he.symm

theorem temporalOfInitial_initialOfTemporal (f : Nat → Bool) :
    temporalOfInitial (initialOfTemporal f) = f := by
  have hag : ∀ d : Nat, 1 ≤ d →
      depthRow (bitRow (completion10 (initialOfTemporal f))) d = Theta f d := by
    intro d hd
    have hn : d - 1 + 1 = d := by omega
    have hb := bitRow_at (completion10 (initialOfTemporal f)) (d - 1)
    rw [hn] at hb
    have hc := completion10_initialOfTemporal f (d - 1)
    rw [hn] at hc
    exact hb.trans hc
  funext i
  change zrow (depthRow (bitRow (completion10 (initialOfTemporal f)))) (2 * i + 1) 1 = f i
  rw [zrow_congr hag]
  exact Theta_free f i

/-- The kit shift law transports through the parameter bridge, not by u↦tail u. -/
theorem completion10_two_step (u : Nat → Bool) :
    zrow (depthRow (bitRow (completion10 u))) 2 =
      Theta (fun i => temporalOfInitial u (i + 1)) := by
  funext d
  rw [zrow_congr (completion10_theta u)]
  exact congrFun (two_step_shift (temporalOfInitial u)) d

/-- The only nonzero Fin2 phase interchanges the two literal drivers. -/
theorem phase10_one : phase c10 (⟨1, by omega⟩ : Fin 2) = c01 := by
  funext t
  change decide ((t + 1) % 2 = 0) = decide (t % 2 = 1)
  have hh : ((t + 1) % 2 = 0) ↔ (t % 2 = 1) := by omega
  simp only [hh]

theorem phase01_one : phase c01 (⟨1, by omega⟩ : Fin 2) = c10 := by
  funext t
  change decide ((t + 1) % 2 = 1) = decide (t % 2 = 0)
  have hh : ((t + 1) % 2 = 1) ↔ (t % 2 = 0) := by omega
  simp only [hh]

end FVLT.S4mCoordinatesV1

