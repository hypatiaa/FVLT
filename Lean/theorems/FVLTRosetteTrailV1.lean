import FVLTCoupledPointV1
import Mathlib.NumberTheory.Divisors

/-!
# Factorial trail assembled with the coupled FVLT point

FVLT v3.3.0 II.5a, integer reference rosette, n6 = alpha = 1.
The trail is finite but the theorems are uniform in the factorial setting.
No Rule 30 dynamics or general alpha/tilt claim is made here.
-/
namespace FVLT.RosetteTrailV1

open CoupledPointV1

def cap (n1 : ℕ) : ℕ := Nat.factorial n1 + 1

/-- Trail positions phi3 = 0,...,n1!. -/
abbrev Trail (n1 : ℕ) := Fin (cap n1)

/-- The original descending choice n3 = n1! + 1 - phi3. -/
def selected (n1 : ℕ) (i : Trail n1) : ℕ := cap n1 - i.val

theorem cap_pos (n1 : ℕ) : 0 < cap n1 := by simp [cap]

theorem selected_pos (n1 : ℕ) (i : Trail n1) : 0 < selected n1 i := by
  have hi := i.isLt
  unfold selected
  omega

theorem selected_le_cap (n1 : ℕ) (i : Trail n1) : selected n1 i ≤ cap n1 :=
  Nat.sub_le _ _

theorem selected_ne_zero (n1 : ℕ) (i : Trail n1) : selected n1 i ≠ 0 :=
  Nat.ne_of_gt (selected_pos n1 i)

theorem selected_injective (n1 : ℕ) : Function.Injective (selected n1) := by
  intro i j h
  apply Fin.ext
  have hi := i.isLt
  have hj := j.isLt
  unfold selected at h
  omega

def indexOf (n1 n : ℕ) (hn : 0 < n) (hcap : n ≤ cap n1) : Trail n1 :=
  ⟨cap n1 - n, by have hc := cap_pos n1; omega⟩

theorem selected_indexOf (n1 n : ℕ) (hn : 0 < n) (hcap : n ≤ cap n1) :
    selected n1 (indexOf n1 n hn hcap) = n := by
  simp only [selected, indexOf]
  omega

theorem indexOf_selected (n1 : ℕ) (i : Trail n1) :
    indexOf n1 (selected n1 i) (selected_pos n1 i) (selected_le_cap n1 i) = i := by
  apply selected_injective n1
  exact selected_indexOf _ _ _ _

theorem exists_unique_selected (n1 n : ℕ) :
    (∃! i : Trail n1, selected n1 i = n) ↔ 0 < n ∧ n ≤ cap n1 := by
  constructor
  · rintro ⟨i, hi, _⟩
    rw [← hi]
    exact ⟨selected_pos n1 i, selected_le_cap n1 i⟩
  · rintro ⟨hn, hc⟩
    refine ⟨indexOf n1 n hn hc, selected_indexOf _ _ _ _, ?_⟩
    intro j hj
    apply selected_injective n1
    rw [hj, selected_indexOf]

/-- Selection feeds one shared positive modulus into the existing constructor. -/
def modulus (n1 : ℕ) (i : Trail n1) : Modulus :=
  ⟨selected n1 i, selected_pos n1 i⟩

@[simp] theorem modulus_n3 (n1 : ℕ) (i : Trail n1) :
    (modulus n1 i).n3 = selected n1 i := rfl

theorem chosen_teeth (n1 : ℕ) (i : Trail n1) (t1 t2 : ℤ) :
    tooth1 (modulus n1 i) t1 t2 = (selected n1 i : ℤ) * t1 - t2 ∧
    tooth2 (modulus n1 i) t1 t2 = (selected n1 i : ℤ) * t1 + t2 := by
  constructor <;> rfl

/-- false selects arm 1; true selects arm 2. Both use the same modulus. -/
noncomputable def trailPoint (n1 : ℕ) (i : Trail n1) (arm : Bool)
    (t1 t2 s : ℤ) : ℂ :=
  if arm then z2 (modulus n1 i) t1 t2 s else z1 (modulus n1 i) t1 t2 s

theorem trailPoint_norm (n1 : ℕ) (i : Trail n1) (arm : Bool) (t1 t2 s : ℤ) :
    ‖trailPoint n1 i arm t1 t2 s‖ = (selected n1 i : ℝ) := by
  cases arm <;> simp [trailPoint, norm_z1, norm_z2]

theorem trailPoint_contact (n1 : ℕ) (i : Trail n1) (arm : Bool) (t1 t2 s : ℤ) :
    (trailPoint n1 i arm t1 t2 s).im = 0 ↔ (selected n1 i : ℤ) ∣ t2 * s := by
  cases arm <;> simp [trailPoint, z1_real_iff_divides, z2_real_iff_divides]

theorem reference_contact (n1 : ℕ) (i : Trail n1) (arm : Bool) (s : ℕ) :
    (trailPoint n1 i arm 1 1 s).im = 0 ↔ selected n1 i ∣ s := by
  rw [trailPoint_contact]
  simpa using (Int.natCast_dvd_natCast :
    ((selected n1 i : ℤ) ∣ (s : ℤ)) ↔ selected n1 i ∣ s)

noncomputable def contactFinset (n1 s : ℕ) (arm : Bool) : Finset ℕ := by
  classical
  exact (Finset.univ.filter (fun i : Trail n1 =>
    (trailPoint n1 i arm 1 1 s).im = 0)).image (selected n1)

/-- Exact bounded contact set, including the special s=0 column. -/
theorem mem_contactFinset (n1 s n : ℕ) (arm : Bool) :
    n ∈ contactFinset n1 s arm ↔ 0 < n ∧ n ≤ cap n1 ∧ n ∣ s := by
  classical
  simp only [contactFinset, Finset.mem_image, Finset.mem_filter, Finset.mem_univ,
    true_and, reference_contact]
  constructor
  · rintro ⟨i, hd, rfl⟩
    exact ⟨selected_pos n1 i, selected_le_cap n1 i, hd⟩
  · rintro ⟨hn, hc, hd⟩
    refine ⟨indexOf n1 n hn hc, ?_, selected_indexOf _ _ _ _⟩
    simpa only [selected_indexOf] using hd

/-- Every positive column in the factorial window recovers its complete atom. -/
theorem contactFinset_eq_divisors (n1 s : ℕ) (arm : Bool)
    (hs : 0 < s) (hwindow : s ≤ cap n1) :
    contactFinset n1 s arm = Nat.divisors s := by
  ext n
  rw [mem_contactFinset, Nat.mem_divisors]
  constructor
  · rintro ⟨_, _, hd⟩
    exact ⟨hd, Nat.ne_of_gt hs⟩
  · rintro ⟨hd, _⟩
    have hn : 0 < n := Nat.pos_of_dvd_of_pos hd hs
    have hns : n ≤ s := Nat.le_of_dvd hs hd
    exact ⟨hn, hns.trans hwindow, hd⟩

theorem reference_arms_same_contacts (n1 s : ℕ) :
    contactFinset n1 s false = contactFinset n1 s true := by
  ext n
  simp only [mem_contactFinset]

end FVLT.RosetteTrailV1

