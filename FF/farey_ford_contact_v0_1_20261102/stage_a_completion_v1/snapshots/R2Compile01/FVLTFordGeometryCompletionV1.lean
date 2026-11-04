import FVLTFareyArithmeticCompletionV1
import FVLTFordGeometryV1
import Mathlib.Tactic

/-! FF-1 R2: classical Ford disk separation and kiss uniqueness.
Framework assembled by Robin Miller; classical components: Farey, Ford (1938),
Apostol ch. 5; structural reference Paulson, Isabelle AFP (2025).
-/
namespace FVLT.FordGeometryV1
open FVLT.FareyContactV1
noncomputable section

def disk (x : ℚ) : Set ℂ := {z | ‖z - centre x‖ < radius x}
def realAxis : Set ℂ := {z | z.im = 0}
def tangent (x y : ℚ) : Prop :=
  x ≠ y ∧ ∃ z : ℂ, boundary x ∩ boundary y = {z}

private theorem det_nonzero (x y : ℚ) (hne : x ≠ y) : det x y ≠ 0 := by
  intro h
  apply hne
  calc
    x = (x.num:ℚ)/(x.den:ℚ) := (Rat.num_div_den x).symm
    _ = (y.num:ℚ)/(y.den:ℚ) := by
      apply (div_eq_div_iff (by exact_mod_cast x.den_ne_zero)
        (by exact_mod_cast y.den_ne_zero)).mpr
      have hh : x.num*(y.den:ℤ) = y.num*(x.den:ℤ) := sub_eq_zero.mp h
      exact_mod_cast hh
    _ = y := Rat.num_div_den y

private theorem centre_norm_ge (x y : ℚ) (hne : x ≠ y) :
    radius x + radius y ≤ ‖centre x-centre y‖ := by
  have hd : 1 ≤ |det x y| := by have := abs_pos.mpr (det_nonzero x y hne); omega
  have hd' : (1:ℝ) ≤ |(det x y:ℝ)| := by exact_mod_cast hd
  have hnum : 0 ≤ (det x y:ℝ)^2-1 := by nlinarith [sq_abs (det x y:ℝ)]
  have hden : 0 ≤ (x.den:ℝ)^2*(y.den:ℝ)^2 := mul_nonneg (sq_nonneg _) (sq_nonneg _)
  have hi := ford_distance_identity x y hne
  have hn := div_nonneg hnum hden
  have hx := radius_pos x
  have hy := radius_pos y
  nlinarith [norm_nonneg (centre x-centre y)]

private theorem centre_norm_gt (x y : ℚ) (hne : x ≠ y)
    (hsep : 2 ≤ |det x y|) : radius x+radius y < ‖centre x-centre y‖ := by
  have hd : (2:ℝ) ≤ |(det x y:ℝ)| := by exact_mod_cast hsep
  have hnum : 0 < (det x y:ℝ)^2-1 := by nlinarith [sq_abs (det x y:ℝ)]
  have hx : (x.den:ℝ) ≠ 0 := by exact_mod_cast x.den_ne_zero
  have hy : (y.den:ℝ) ≠ 0 := by exact_mod_cast y.den_ne_zero
  have hn := div_pos hnum (mul_pos (sq_pos_of_ne_zero hx) (sq_pos_of_ne_zero hy))
  have hi := ford_distance_identity x y hne
  have hrx := radius_pos x
  have hry := radius_pos y
  nlinarith [norm_nonneg (centre x-centre y)]

private theorem centre_triangle (x y : ℚ) (z : ℂ) :
    ‖centre x-centre y‖ ≤ ‖z-centre x‖+‖z-centre y‖ := by
  have h := norm_sub_le (centre x) z (centre y)
  rwa [norm_sub_rev (centre x) z] at h

theorem ford_open_disjoint (x y : ℚ) (hne : x ≠ y) : Disjoint (disk x) (disk y) := by
  apply Set.disjoint_left.mpr
  intro z hx hy
  have h1 : ‖z-centre x‖ < radius x := hx
  have h2 : ‖z-centre y‖ < radius y := hy
  have h3 := centre_triangle x y z
  have h4 := centre_norm_ge x y hne
  linarith

theorem ford_boundary_disjoint (x y : ℚ) (hne : x ≠ y)
  (hsep : 2 ≤ |det x y|) : Disjoint (boundary x) (boundary y) := by
  apply Set.disjoint_left.mpr
  intro z hx hy
  have h1 : ‖z-centre x‖ = radius x := hx
  have h2 : ‖z-centre y‖ = radius y := hy
  have h3 := centre_triangle x y z
  have h4 := centre_norm_gt x y hne hsep
  linarith

private theorem weighted_norm_identity (u v : ℂ) (r s : ℝ) :
    ‖(s:ℂ)*u+(r:ℂ)*v‖^2 =
      (s+r)*(s*‖u‖^2+r*‖v‖^2)-r*s*‖u-v‖^2 := by
  simp only [Complex.sq_norm,Complex.normSq_apply,Complex.add_re,Complex.add_im,
    Complex.mul_re,Complex.mul_im,Complex.sub_re,Complex.sub_im,
    Complex.ofReal_re,Complex.ofReal_im]
  ring

private theorem circle_inter_unique (c d z w : ℂ) (r s : ℝ)
    (hr : 0 < r) (hs : 0 < s) (hcd : ‖c-d‖^2 = (r+s)^2)
    (hz : ‖z-c‖ = r ∧ ‖z-d‖ = s)
    (hw : ‖w-c‖ = r ∧ ‖w-d‖ = s) : z = w := by
  have lin : ∀ v : ℂ, ‖v-c‖ = r → ‖v-d‖ = s →
      (s:ℂ)*(v-c)+(r:ℂ)*(v-d) = 0 := by
    intro v hvc hvd
    have hdist : ‖(v-c)-(v-d)‖^2 = (r+s)^2 := by
      rw [show (v-c)-(v-d) = d-c by ring,norm_sub_rev]
      exact hcd
    have hn : ‖(s:ℂ)*(v-c)+(r:ℂ)*(v-d)‖^2 = 0 := by
      rw [weighted_norm_identity,hvc,hvd,hdist]
      ring
    apply norm_eq_zero.mp
    nlinarith [norm_nonneg ((s:ℂ)*(v-c)+(r:ℂ)*(v-d))]
  have hz' := lin z hz.1 hz.2
  have hw' := lin w hw.1 hw.2
  have hprod : ((s:ℂ)+(r:ℂ))*(z-w) = 0 := by
    linear_combination hz' - hw'
  have hne : (s:ℂ)+(r:ℂ) ≠ 0 := by
    exact_mod_cast (ne_of_gt (add_pos hs hr))
  exact sub_eq_zero.mp ((mul_eq_zero.mp hprod).resolve_left hne)

theorem ford_real_axis (x : ℚ) : boundary x ∩ realAxis = {(x : ℂ)} := by
  ext z
  constructor
  · rintro ⟨hz, hi⟩
    have him : z.im = 0 := hi
    have hn : ‖z-centre x‖ = radius x := hz
    have hsq : (z.re-(x:ℝ))^2 = 0 := by
      have he := congrArg (fun t : ℝ => t^2) hn
      rw [Complex.sq_norm] at he
      simp [Complex.normSq_apply,centre,him] at he
      nlinarith
    have hre : z.re = (x:ℝ) := by nlinarith [sq_nonneg (z.re-(x:ℝ))]
    apply Set.mem_singleton_iff.mpr
    apply Complex.ext
    · simpa using hre
    · simpa using him
  · intro hz
    have he : z = (x:ℂ) := Set.mem_singleton_iff.mp hz
    subst z
    constructor
    · change ‖(x:ℂ)-centre x‖ = radius x
      rw [show (x:ℂ)-centre x = -(radius x:ℂ)*Complex.I by unfold centre; ring]
      simp [abs_of_pos (radius_pos x)]
    · simp [realAxis]

theorem kiss_unique (x y : ℚ) (h : fareyAdj x y) :
  boundary x ∩ boundary y = {kiss x y} := by
  have hne : x ≠ y := by intro he; subst y; exact fareyAdj_irrefl x h
  have hdint : (det x y)^2 = 1 := by
    have hh : |det x y| = 1 := h
    nlinarith [sq_abs (det x y)]
  have hd : (det x y:ℝ)^2 = 1 := by exact_mod_cast hdint
  have hi := ford_distance_identity x y hne
  rw [hd] at hi
  have hcd : ‖centre x-centre y‖^2 = (radius x+radius y)^2 := by simpa using hi
  have hk := kiss_membership x y h
  ext z
  constructor
  · intro hz
    apply Set.mem_singleton_iff.mpr
    exact circle_inter_unique (centre x) (centre y) z (kiss x y)
      (radius x) (radius y) (radius_pos x) (radius_pos y) hcd hz hk
  · intro hz
    simpa only [Set.mem_singleton_iff.mp hz] using hk

theorem ford_tangent_iff (x y : ℚ) (hne : x ≠ y) : tangent x y ↔ fareyAdj x y := by
  constructor
  · rintro ⟨_,z,hz⟩
    have hm : z ∈ boundary x ∩ boundary y := by rw [hz]; exact Set.mem_singleton z
    have hd : 1 ≤ |det x y| := by have := abs_pos.mpr (det_nonzero x y hne); omega
    by_contra hh
    have hs : 2 ≤ |det x y| := by change ¬ |det x y| = 1 at hh; omega
    exact Set.disjoint_left.mp (ford_boundary_disjoint x y hne hs) hm.1 hm.2
  · intro h
    exact ⟨hne,kiss x y,kiss_unique x y h⟩

theorem two_squares (a c : ℤ) (q s : ℤ) :
  (a*q + c*s)^2 + (a*s - c*q)^2 = (a^2 + c^2)*(q^2 + s^2) := by ring

theorem kiss_integer_identity (x y : ℚ) (h : fareyAdj x y) :
  (kissN x y)^2 + 1 = (x.num^2 + y.num^2) * (kissM x y : ℤ) := by
  have hd : (det x y)^2 = 1 := by
    have hh : |det x y| = 1 := h
    nlinarith [sq_abs (det x y)]
  calc
    _ = (kissN x y)^2+(det x y)^2 := by rw [hd]
    _ = _ := by simpa [kissN,kissM,det] using two_squares x.num y.num (x.den:ℤ) (y.den:ℤ)

theorem kiss_real_identity (x y : ℚ) (h : fareyAdj x y) :
  (kissN x y : ℝ)^2 + 1 =
    ((x.num : ℝ)^2 + (y.num : ℝ)^2) * (kissM x y : ℝ) := by
  exact_mod_cast kiss_integer_identity x y h

#print axioms FVLT.FordGeometryV1.ford_open_disjoint
#print axioms FVLT.FordGeometryV1.ford_boundary_disjoint
#print axioms FVLT.FordGeometryV1.ford_tangent_iff
#print axioms FVLT.FordGeometryV1.ford_real_axis
#print axioms FVLT.FordGeometryV1.kiss_unique
#print axioms FVLT.FordGeometryV1.two_squares
#print axioms FVLT.FordGeometryV1.kiss_integer_identity
#print axioms FVLT.FordGeometryV1.kiss_real_identity
#print axioms det_nonzero
#print axioms centre_norm_ge
#print axioms centre_norm_gt
#print axioms centre_triangle
#print axioms weighted_norm_identity
#print axioms circle_inter_unique
end
end FVLT.FordGeometryV1
