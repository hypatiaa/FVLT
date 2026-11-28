import FVLTMCombHelixV1
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Complex.Log

/-!
# Centered-comb lemma: PROOF BUILD v0.1 (2026-11-10). Not a library module.

Proof build of the frozen statement file `FVLTCenteredCombLemmaV1_statements.lean`
(SHA-256 68f202c9456994fcf9e3f930c468d79563983a4b27e48cc6f8141dcc50f29080, statement draft v0.1.1).
The defs K, comb, tooth, toothReal and the 15 theorem headers (with docstrings) are copied byte-for-byte;
only each `sorry` is replaced. Helper lemmas are added in the same namespace before their first use.
One extra Mathlib import (`Mathlib.Analysis.SpecialFunctions.Complex.Log`, for `Complex.exp_eq_one_iff`).
Pending independent verification.
-/
noncomputable section
namespace FVLT.CenteredCombLemmaV1
open HelixFrameV1 HelixGearboxV1 MCombHelixV1
open scoped BigOperators

/-- The comb kernel as its defining cosine sum: K_m(B) = Σ_{c ∈ C_m} cos(c B). -/
def K (m : ℕ) (B : ℝ) : ℝ := ∑ c ∈ offsets m, Real.cos ((c : ℝ) * B)

/-- The comb with one real amplitude r: Σ_{c ∈ C_m} r·e^{iθ_c}, on the companion's domain N ∈ ℕ, t1, t2 ∈ ℤ. -/
def comb (m N : ℕ) (t1 t2 : ℤ) (r s : ℝ) : ℂ := ∑ c ∈ offsets m, (r : ℂ) * branch N t1 t2 c s

/-- The tooth z_c = r e^{iθ_c}, on the companion's domain. -/
def tooth (N : ℕ) (t1 t2 : ℤ) (r s : ℝ) (c : ℤ) : ℂ := (r : ℂ) * branch N t1 t2 c s

/-- The same tooth with real parameters, for the labelled generalization T4r only. -/
def toothReal (N t1 t2 r s : ℝ) (c : ℤ) : ℂ := (r : ℂ) * branch N t1 t2 c s

/-! ### Helper lemmas (build only) -/

/-- Helper: `phase x = cos x + i sin x` with real cos and sin. -/
theorem helper_phase_cos_sin (x : ℝ) :
    phase x = ((Real.cos x : ℝ) : ℂ) + ((Real.sin x : ℝ) : ℂ) * Complex.I := by
  rw [phase, Complex.exp_mul_I, Complex.ofReal_cos, Complex.ofReal_sin]

/-- Helper: `phase x = 1` iff x is an integer multiple of 2π. -/
theorem helper_phase_eq_one_iff (x : ℝ) : phase x = 1 ↔ ∃ n : ℤ, x = n * (2 * Real.pi) := by
  rw [phase, Complex.exp_eq_one_iff]
  constructor
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    have h : ((x : ℝ) : ℂ) = (((n : ℝ) * (2 * Real.pi) : ℝ) : ℂ) := by
      apply mul_right_cancel₀ Complex.I_ne_zero
      rw [hn]
      push_cast
      ring
    exact_mod_cast h
  · rintro ⟨n, rfl⟩
    exact ⟨n, by push_cast; ring⟩

/-- Helper: `sin (x/2) = 0` iff `phase x = 1`. -/
theorem helper_sin_half_eq_zero_iff (x : ℝ) : Real.sin (x / 2) = 0 ↔ phase x = 1 := by
  rw [Real.sin_eq_zero_iff, helper_phase_eq_one_iff]
  constructor
  · rintro ⟨n, hn⟩
    exact ⟨n, by linarith⟩
  · rintro ⟨n, hn⟩
    exact ⟨n, by linarith⟩

/-- Helper: powers of a phase. -/
theorem helper_phase_pow (x : ℝ) (n : ℕ) : phase x ^ n = phase ((n : ℝ) * x) := by
  rw [phase, phase, ← Complex.exp_nat_mul]
  congr 1
  push_cast
  ring

/-- Helper: conjugate of a real-amplitude tooth. -/
theorem helper_star_tooth (r x : ℝ) : star ((r : ℂ) * phase x) = (r : ℂ) * phase (-x) := by
  rw [phase, phase, star_mul', Complex.star_def, Complex.conj_ofReal,
    ← Complex.exp_conj, map_mul, Complex.conj_ofReal, Complex.conj_I]
  push_cast
  ring_nf

/-- Helper: sums over `offsets m` as sums over `range m`. -/
theorem helper_sum_offsets_range (m : ℕ) (f : ℤ → ℝ) :
    ∑ c ∈ offsets m, f c =
      ∑ j ∈ Finset.range m,
        f (if m % 2 = 0 then 2 * (j : ℤ) + 1 - (m : ℤ) else (j : ℤ) - (m / 2 : ℕ)) := by
  classical
  rw [offsets, Finset.sum_image (fun i _ j _ h => offset_injective m h)]
  exact Fin.sum_univ_eq_sum_range
    (fun j => f (if m % 2 = 0 then 2 * (j : ℤ) + 1 - (m : ℤ) else (j : ℤ) - (m / 2 : ℕ))) m

/-- Helper: the odd sines cancel over the symmetric offset set. -/
theorem helper_sin_sum_zero (m : ℕ) (B : ℝ) :
    ∑ c ∈ offsets m, Real.sin ((c : ℝ) * B) = 0 := by
  have h := Finset.sum_equiv (Equiv.neg ℤ) (s := offsets m) (t := offsets m)
    (f := fun c => Real.sin ((c : ℝ) * B)) (g := fun c => -Real.sin ((c : ℝ) * B))
    (fun c => by simp [neg_mem_offsets_iff])
    (fun c _ => by simp [neg_mul, Real.sin_neg])
  rw [Finset.sum_neg_distrib] at h
  linarith

/-- Helper: odd telescoping, sin(B/2) K_m(B) = sin(mB/2). -/
theorem helper_K_odd_mul (m : ℕ) (hm : m % 2 = 1) (B : ℝ) :
    Real.sin (B / 2) * K m B = Real.sin (m * B / 2) := by
  obtain ⟨M, rfl⟩ : ∃ M, m = 2 * M + 1 := ⟨m / 2, by omega⟩
  have hM : (2 * M + 1) / 2 = M := by omega
  have hne : ¬ ((2 * M + 1) % 2 = 0) := by omega
  rw [K, helper_sum_offsets_range, Finset.mul_sum]
  simp only [hne, ite_false, hM]
  set f : ℕ → ℝ := fun j => Real.sin (((j : ℝ) - M - 1 / 2) * B) with hf
  have key : ∀ j ∈ Finset.range (2 * M + 1),
      2 * (Real.sin (B / 2) * Real.cos ((((j : ℤ) - (M : ℤ) : ℤ) : ℝ) * B)) = f (j + 1) - f j := by
    intro j _
    simp only [hf]
    have h := Real.sin_sub_sin ((((j + 1 : ℕ) : ℝ) - M - 1 / 2) * B) ((((j : ℕ) : ℝ) - M - 1 / 2) * B)
    rw [show (((((j + 1 : ℕ) : ℝ) - M - 1 / 2) * B) - ((((j : ℕ) : ℝ) - M - 1 / 2) * B)) / 2 = B / 2 by
          push_cast; ring,
        show (((((j + 1 : ℕ) : ℝ) - M - 1 / 2) * B) + ((((j : ℕ) : ℝ) - M - 1 / 2) * B)) / 2 =
          (((j : ℤ) - (M : ℤ) : ℤ) : ℝ) * B by push_cast; ring] at h
    linarith
  have h2 : 2 * ∑ j ∈ Finset.range (2 * M + 1),
      Real.sin (B / 2) * Real.cos ((((j : ℤ) - (M : ℤ) : ℤ) : ℝ) * B) = f (2 * M + 1) - f 0 := by
    rw [Finset.mul_sum, ← Finset.sum_range_sub]
    exact Finset.sum_congr rfl key
  have e1 : f (2 * M + 1) = Real.sin (((2 * M + 1 : ℕ) : ℝ) * B / 2) := by
    simp only [hf]
    congr 1
    push_cast
    ring
  have e0 : f 0 = -Real.sin (((2 * M + 1 : ℕ) : ℝ) * B / 2) := by
    simp only [hf]
    rw [← Real.sin_neg]
    congr 1
    push_cast
    ring
  rw [e1, e0] at h2
  linarith

/-- Helper: even telescoping, sin(B) K_m(B) = sin(mB). -/
theorem helper_K_even_mul (m : ℕ) (hm : m % 2 = 0) (B : ℝ) :
    Real.sin B * K m B = Real.sin (m * B) := by
  rw [K, helper_sum_offsets_range, Finset.mul_sum]
  simp only [hm, ite_true]
  set f : ℕ → ℝ := fun j => Real.sin ((2 * (j : ℝ) - m) * B) with hf
  have key : ∀ j ∈ Finset.range m,
      2 * (Real.sin B * Real.cos (((2 * (j : ℤ) + 1 - (m : ℤ) : ℤ) : ℝ) * B)) = f (j + 1) - f j := by
    intro j _
    simp only [hf]
    have h := Real.sin_sub_sin ((2 * ((j + 1 : ℕ) : ℝ) - m) * B) ((2 * ((j : ℕ) : ℝ) - m) * B)
    rw [show ((2 * ((j + 1 : ℕ) : ℝ) - m) * B - (2 * ((j : ℕ) : ℝ) - m) * B) / 2 = B by
          push_cast; ring,
        show ((2 * ((j + 1 : ℕ) : ℝ) - m) * B + (2 * ((j : ℕ) : ℝ) - m) * B) / 2 =
          (((2 * (j : ℤ) + 1 - (m : ℤ) : ℤ) : ℝ) * B) by push_cast; ring] at h
    linarith
  have h2 : 2 * ∑ j ∈ Finset.range m,
      Real.sin B * Real.cos (((2 * (j : ℤ) + 1 - (m : ℤ) : ℤ) : ℝ) * B) = f m - f 0 := by
    rw [Finset.mul_sum, ← Finset.sum_range_sub]
    exact Finset.sum_congr rfl key
  have e1 : f m = Real.sin ((m : ℝ) * B) := by
    simp only [hf]
    congr 1
    ring
  have e0 : f 0 = -Real.sin ((m : ℝ) * B) := by
    simp only [hf]
    rw [← Real.sin_neg]
    congr 1
    push_cast
    ring
  rw [e1, e0] at h2
  linarith

/-! ### (i) Factorization -/

/-- T1. The symmetric phase sum is real and equals the kernel. -/
theorem phase_sum_eq_K (m : ℕ) (B : ℝ) :
    (∑ c ∈ offsets m, phase ((c : ℝ) * B)) = ((K m B : ℝ) : ℂ) := by
  simp only [helper_phase_cos_sin]
  rw [Finset.sum_add_distrib, ← Finset.sum_mul, ← Complex.ofReal_sum, ← Complex.ofReal_sum,
    helper_sin_sum_zero, K]
  simp

/-- T2. Factorization: Σ z_c = r e^{iA} K_m(B), with A = t1 s π and B = t2 s π / N. -/
theorem comb_factor (m N : ℕ) (hN : 1 ≤ N) (t1 t2 : ℤ) (r s : ℝ) :
    comb m N t1 t2 r s =
      (r : ℂ) * phase (Real.pi * t1 * s) * ((K m (Real.pi * s * t2 / N) : ℝ) : ℂ) := by
  have h1 : comb m N t1 t2 r s = coherent m (N : ℝ) (t1 : ℝ) (t2 : ℝ) (fun _ => (r : ℂ)) s := rfl
  rw [h1, coherent_factor]
  have h2 : ∑ c ∈ offsets m, (fun _ => (r : ℂ)) c * phase (Real.pi * s * (c : ℝ) * (t2 : ℝ) / (N : ℝ)) =
      (r : ℂ) * ∑ c ∈ offsets m, phase ((c : ℝ) * (Real.pi * s * t2 / N)) := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl (fun c _ => ?_)
    simp only []
    congr 2
    ring
  rw [h2, phase_sum_eq_K, alpha]
  ring

/-- T3a. Odd closed form (Dirichlet), where the denominator does not vanish. -/
theorem K_odd_closed (m : ℕ) (hm : m % 2 = 1) (B : ℝ) (hB : Real.sin (B / 2) ≠ 0) :
    K m B = Real.sin (m * B / 2) / Real.sin (B / 2) := by
  rw [eq_div_iff hB, mul_comm]
  exact helper_K_odd_mul m hm B

/-- T3b. Even closed form, where the denominator does not vanish. -/
theorem K_even_closed (m : ℕ) (hm : m % 2 = 0) (B : ℝ) (hB : Real.sin B ≠ 0) :
    K m B = Real.sin (m * B) / Real.sin B := by
  rw [eq_div_iff hB, mul_comm]
  exact helper_K_even_mul m hm B

/-- T3c. Removable points, both parities: K_m = m at B ≡ 0 (mod 2π). -/
theorem K_at_zero_class (m : ℕ) (k : ℤ) : K m (2 * Real.pi * k) = m := by
  have h : ∀ c ∈ offsets m, Real.cos ((c : ℝ) * (2 * Real.pi * k)) = 1 := by
    intro c _
    rw [show (c : ℝ) * (2 * Real.pi * k) = ((c * k : ℤ) : ℝ) * (2 * Real.pi) by push_cast; ring]
    exact Real.cos_int_mul_two_pi _
  rw [K, Finset.sum_congr rfl h]
  simp [offsets_card]

/-- T3d. Even m: K_m = −m at B ≡ π (mod 2π) (the lemma's sharpening: opposite values). -/
theorem K_even_at_pi_class (m : ℕ) (hm : m % 2 = 0) (k : ℤ) :
    K m (Real.pi + 2 * Real.pi * k) = -(m : ℝ) := by
  have h : ∀ c ∈ offsets m, Real.cos ((c : ℝ) * (Real.pi + 2 * Real.pi * k)) = -1 := by
    intro c hc
    obtain ⟨n, hn⟩ : ∃ n : ℤ, c = 2 * n + 1 := by
      rcases Finset.mem_image.mp hc with ⟨j, _, rfl⟩
      refine ⟨(j : ℤ) - ((m / 2 : ℕ) : ℤ), ?_⟩
      simp only [offset, hm, ite_true]
      omega
    have hc' : (c : ℝ) = 2 * n + 1 := by exact_mod_cast hn
    rw [show (c : ℝ) * (Real.pi + 2 * Real.pi * k) = ((n + c * k : ℤ) : ℝ) * (2 * Real.pi) + Real.pi by
      push_cast; rw [hc']; ring]
    exact Real.cos_int_mul_two_pi_add_pi _
  rw [K, Finset.sum_congr rfl h]
  simp [offsets_card]

/-! ### (ii) ALIGN -/

/-- Helper: the ALIGN condition for one tooth, real parameters. -/
theorem helper_align_tooth_iff (N t1 t2 r s : ℝ) (hr : r ≠ 0) (c : ℤ) :
    toothReal N t1 t2 r s (-c) = star (toothReal N t1 t2 r s c) ↔ ∃ k : ℤ, t1 * s = k := by
  have hr' : (r : ℂ) ≠ 0 := by exact_mod_cast hr
  simp only [toothReal, branch]
  rw [helper_star_tooth, mul_right_inj' hr',
    show Real.pi * s * (t1 + ((-c : ℤ) : ℝ) * t2 / N) =
      Real.pi * s * t1 * 2 + -(Real.pi * s * (t1 + (c : ℝ) * t2 / N)) by push_cast; ring,
    phase_add]
  constructor
  · intro h
    have h1 : phase (Real.pi * s * t1 * 2) = 1 :=
      mul_right_cancel₀ (phase_ne_zero _) (h.trans (one_mul _).symm)
    obtain ⟨n, hn⟩ := (helper_phase_eq_one_iff _).mp h1
    have h3 : Real.pi * (t1 * s) = Real.pi * n := by linarith
    exact ⟨n, mul_left_cancel₀ Real.pi_ne_zero h3⟩
  · rintro ⟨k, hk⟩
    have h1 : phase (Real.pi * s * t1 * 2) = 1 :=
      (helper_phase_eq_one_iff _).mpr
        ⟨k, by rw [show Real.pi * s * t1 * 2 = (t1 * s) * (2 * Real.pi) by ring, hk]⟩
    rw [h1, one_mul]

/-- T4. ALIGN on the companion's domain: z_{−c} = conj z_c for every offset iff t1 s ∈ ℤ. The reality of r ≠ 0
is load-bearing; m ≥ 2 gives a nonempty offset set. -/
theorem align_iff (m N : ℕ) (hm : 2 ≤ m) (hN : 1 ≤ N) (t1 t2 : ℤ) (r s : ℝ) (hr : r ≠ 0) :
    (∀ c ∈ offsets m, tooth N t1 t2 r s (-c) = star (tooth N t1 t2 r s c)) ↔
      ∃ k : ℤ, (t1 : ℝ) * s = k := by
  have hne : (offsets m).Nonempty := by
    rw [← Finset.card_pos, offsets_card]
    omega
  constructor
  · intro h
    obtain ⟨c, hc⟩ := hne
    exact (helper_align_tooth_iff (N : ℝ) (t1 : ℝ) (t2 : ℝ) r s hr c).mp (h c hc)
  · intro h c _
    exact (helper_align_tooth_iff (N : ℝ) (t1 : ℝ) (t2 : ℝ) r s hr c).mpr h

/-- T4r. GENERALIZATION, beyond the companion's stated domain (labelled; not a formalization of the lemma):
the same equivalence for real N, t1, t2 (the c t2 / N parts cancel in θ_c + θ_{−c}). -/
theorem align_iff_real (m : ℕ) (hm : 2 ≤ m) (N t1 t2 r s : ℝ) (hr : r ≠ 0) :
    (∀ c ∈ offsets m, toothReal N t1 t2 r s (-c) = star (toothReal N t1 t2 r s c)) ↔
      ∃ k : ℤ, t1 * s = k := by
  have hne : (offsets m).Nonempty := by
    rw [← Finset.card_pos, offsets_card]
    omega
  constructor
  · intro h
    obtain ⟨c, hc⟩ := hne
    exact (helper_align_tooth_iff N t1 t2 r s hr c).mp (h c hc)
  · intro h c _
    exact (helper_align_tooth_iff N t1 t2 r s hr c).mpr h

/-- T5. At ALIGN the sum is real (Im Σ = 0 exactly). -/
theorem align_im_zero (m N : ℕ) (hN : 1 ≤ N) (t1 t2 : ℤ) (r s : ℝ) (h : ∃ k : ℤ, (t1 : ℝ) * s = k) :
    (comb m N t1 t2 r s).im = 0 := by
  obtain ⟨k, hk⟩ := h
  rw [comb_factor m N hN t1 t2 r s]
  have hph : phase (Real.pi * t1 * s) = ((Real.cos (Real.pi * t1 * s) : ℝ) : ℂ) := by
    rw [helper_phase_cos_sin,
      show Real.pi * (t1 : ℝ) * s = (k : ℝ) * Real.pi by rw [mul_assoc, hk]; ring,
      Real.sin_int_mul_pi]
    simp
  rw [hph, ← Complex.ofReal_mul, ← Complex.ofReal_mul, Complex.ofReal_im]

/-! ### (iii) SPREAD -/

/-- T6a. Odd m: K_m(B) = 0 iff e^{iB} is an m-th root of unity other than 1. -/
theorem spread_odd (m : ℕ) (hm : m % 2 = 1) (B : ℝ) :
    K m B = 0 ↔ (phase B ^ m = 1 ∧ phase B ≠ 1) := by
  have hm0 : (m : ℝ) ≠ 0 := by
    have : m ≠ 0 := by omega
    exact_mod_cast this
  rw [helper_phase_pow]
  by_cases h1 : phase B = 1
  · obtain ⟨n, hn⟩ := (helper_phase_eq_one_iff B).mp h1
    have hK : K m B = m := by
      rw [hn, show (n : ℝ) * (2 * Real.pi) = 2 * Real.pi * n by ring]
      exact K_at_zero_class m n
    simp [hK, hm0, h1]
  · have hs : Real.sin (B / 2) ≠ 0 := fun h => h1 ((helper_sin_half_eq_zero_iff B).mp h)
    rw [K_odd_closed m hm B hs, div_eq_zero_iff, or_iff_left hs,
      show (m : ℝ) * B / 2 = ((m : ℝ) * B) / 2 by ring, helper_sin_half_eq_zero_iff]
    simp [h1]

/-- T6b. Even m: K_m(B) = 0 iff e^{2iB} is an m-th root of unity other than 1. -/
theorem spread_even (m : ℕ) (hm : m % 2 = 0) (hm2 : 2 ≤ m) (B : ℝ) :
    K m B = 0 ↔ (phase (2 * B) ^ m = 1 ∧ phase (2 * B) ≠ 1) := by
  have hm0 : (m : ℝ) ≠ 0 := by
    have : m ≠ 0 := by omega
    exact_mod_cast this
  rw [helper_phase_pow]
  by_cases h1 : phase (2 * B) = 1
  · obtain ⟨n, hn⟩ := (helper_phase_eq_one_iff _).mp h1
    have hB : B = n * Real.pi := by linarith
    have hK : K m B = m ∨ K m B = -(m : ℝ) := by
      rcases Int.even_or_odd' n with ⟨k, hk | hk⟩
      · left
        rw [hB, hk, show ((2 * k : ℤ) : ℝ) * Real.pi = 2 * Real.pi * k by push_cast; ring]
        exact K_at_zero_class m k
      · right
        rw [hB, hk, show ((2 * k + 1 : ℤ) : ℝ) * Real.pi = Real.pi + 2 * Real.pi * k by push_cast; ring]
        exact K_even_at_pi_class m hm k
    constructor
    · intro h0
      exfalso
      rcases hK with h | h
      · rw [h] at h0
        exact hm0 h0
      · rw [h] at h0
        exact hm0 (neg_eq_zero.mp h0)
    · rintro ⟨_, h2⟩
      exact absurd h1 h2
  · have hs : Real.sin B ≠ 0 := by
      intro h
      apply h1
      rw [← helper_sin_half_eq_zero_iff, show 2 * B / 2 = B by ring]
      exact h
    rw [K_even_closed m hm B hs, div_eq_zero_iff, or_iff_left hs,
      show (m : ℝ) * B = ((m : ℝ) * (2 * B)) / 2 by ring, helper_sin_half_eq_zero_iff]
    simp [h1]

/-! ### (iv) Four-state fixture, exact rows (m = 5, t1 = t2 = 1, r = N) -/

/-- Helper: the five offsets. -/
theorem helper_offsets_five : offsets 5 = {-2, -1, 0, 1, 2} := by decide

/-- Helper: K_5(B) = 1 + 2 cos B + 2 cos 2B. -/
theorem helper_K_five (B : ℝ) : K 5 B = 1 + 2 * Real.cos B + 2 * Real.cos (2 * B) := by
  rw [K, helper_offsets_five]
  simp [Finset.sum_insert, neg_mul, Real.cos_neg]
  ring

/-- Helper: cos(2π/5) = (√5 − 1)/4. -/
theorem helper_cos_two_pi_div_five : Real.cos (2 * Real.pi / 5) = (Real.sqrt 5 - 1) / 4 := by
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  rw [show 2 * Real.pi / 5 = 2 * (Real.pi / 5) by ring, Real.cos_two_mul, Real.cos_pi_div_five]
  linear_combination (1 / 8 : ℝ) * h5

/-- Helper: cosine is 2π-periodic (shift by an integer number of turns). -/
theorem helper_cos_period (x y : ℝ) (n : ℤ) (h : x = y + n * (2 * Real.pi)) :
    Real.cos x = Real.cos y := by
  rw [h, Real.cos_add_int_mul_two_pi]

/-- T7a. ALIGN only: N = 5, s = 19: sin A = 0 and K_5(B) = 1 + √5. -/
theorem fixture_align_only :
    Real.sin (Real.pi * 1 * 19) = 0 ∧ K 5 (Real.pi * 19 * 1 / 5) = 1 + Real.sqrt 5 := by
  constructor
  · rw [show Real.pi * 1 * 19 = ((19 : ℤ) : ℝ) * Real.pi by push_cast; ring]
    exact Real.sin_int_mul_pi 19
  · rw [helper_K_five,
      helper_cos_period (Real.pi * 19 * 1 / 5) (-(Real.pi / 5)) 2 (by push_cast; ring),
      helper_cos_period (2 * (Real.pi * 19 * 1 / 5)) (-(2 * Real.pi / 5)) 4 (by push_cast; ring),
      Real.cos_neg, Real.cos_neg, Real.cos_pi_div_five, helper_cos_two_pi_div_five]
    ring

/-- T7b. ALIGN + SPREAD: N = 5, s = 18: sin A = 0 and K_5(B) = 0. -/
theorem fixture_align_spread :
    Real.sin (Real.pi * 1 * 18) = 0 ∧ K 5 (Real.pi * 18 * 1 / 5) = 0 := by
  constructor
  · rw [show Real.pi * 1 * 18 = ((18 : ℤ) : ℝ) * Real.pi by push_cast; ring]
    exact Real.sin_int_mul_pi 18
  · rw [helper_K_five,
      helper_cos_period (Real.pi * 18 * 1 / 5) (-(2 * Real.pi / 5)) 2 (by push_cast; ring),
      helper_cos_period (2 * (Real.pi * 18 * 1 / 5)) (Real.pi / 5 + Real.pi) 3 (by push_cast; ring),
      Real.cos_neg, Real.cos_add_pi, Real.cos_pi_div_five, helper_cos_two_pi_div_five]
    ring

/-- T7c. SPREAD only: N = 4, s = 8/5: sin A ≠ 0 and K_5(B) = 0, so the sum vanishes without alignment. -/
theorem fixture_spread_only :
    Real.sin (Real.pi * 1 * (8 / 5)) ≠ 0 ∧ K 5 (Real.pi * (8 / 5) * 1 / 4) = 0 := by
  constructor
  · intro h
    obtain ⟨n, hn⟩ := Real.sin_eq_zero_iff.mp h
    have h2 : ((n : ℝ) - 8 / 5) * Real.pi = 0 := by linarith
    rcases mul_eq_zero.mp h2 with h3 | h3
    · have h4 : (n : ℝ) * 5 = 8 := by linarith
      have h5 : n * 5 = 8 := by exact_mod_cast h4
      omega
    · exact Real.pi_ne_zero h3
  · rw [helper_K_five,
      helper_cos_period (Real.pi * (8 / 5) * 1 / 4) (2 * Real.pi / 5) 0 (by push_cast; ring),
      helper_cos_period (2 * (Real.pi * (8 / 5) * 1 / 4)) (Real.pi - Real.pi / 5) 0
        (by push_cast; ring),
      Real.cos_pi_sub, Real.cos_pi_div_five, helper_cos_two_pi_div_five]
    ring

/-! The fourth row ("neither", N = 5, s = 474/25) is a float fixture (K_5 ≈ 3.109664, Q ≈ 1.948721) and its
field-degree column (ℚ(ζ₁₂₅), degree 100) is not stated here; both stay in the lemma's numerical register. -/

/-! ### (v) Clifford witness -/

/-- T8. ALIGN is the meridian coincidence γ = π t1 s ≡ 0 (mod π). The chart identity itself is v36's
`MCombHelixV1.coherent_chart`. -/
theorem align_iff_meridian (t1 s : ℝ) :
    Real.sin (Real.pi * t1 * s) = 0 ↔ ∃ k : ℤ, t1 * s = k := by
  rw [Real.sin_eq_zero_iff]
  constructor
  · rintro ⟨n, hn⟩
    exact ⟨n, mul_left_cancel₀ Real.pi_ne_zero (by linarith)⟩
  · rintro ⟨k, hk⟩
    exact ⟨k, by rw [mul_assoc, hk]; ring⟩

end FVLT.CenteredCombLemmaV1

#print axioms FVLT.CenteredCombLemmaV1.phase_sum_eq_K
#print axioms FVLT.CenteredCombLemmaV1.comb_factor
#print axioms FVLT.CenteredCombLemmaV1.K_odd_closed
#print axioms FVLT.CenteredCombLemmaV1.K_even_closed
#print axioms FVLT.CenteredCombLemmaV1.K_at_zero_class
#print axioms FVLT.CenteredCombLemmaV1.K_even_at_pi_class
#print axioms FVLT.CenteredCombLemmaV1.align_iff
#print axioms FVLT.CenteredCombLemmaV1.align_iff_real
#print axioms FVLT.CenteredCombLemmaV1.align_im_zero
#print axioms FVLT.CenteredCombLemmaV1.spread_odd
#print axioms FVLT.CenteredCombLemmaV1.spread_even
#print axioms FVLT.CenteredCombLemmaV1.fixture_align_only
#print axioms FVLT.CenteredCombLemmaV1.fixture_align_spread
#print axioms FVLT.CenteredCombLemmaV1.fixture_spread_only
#print axioms FVLT.CenteredCombLemmaV1.align_iff_meridian
