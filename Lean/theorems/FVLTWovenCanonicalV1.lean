import Mathlib.Data.Int.ModEq
import Mathlib.Tactic

/-!
Canonical integer representatives for changing finite rings, and a sufficient
no-alias margin around the finite-speed support. No Rule30 recurrence or fixed
cylinder failure assertion is built into these arithmetic lemmas.
-/

namespace FVLT.WovenCanonicalV1

def offset (L : ℕ) : ℤ := (((L - 1) / 2 : ℕ) : ℤ)

def lower (L : ℕ) : ℤ := -offset L

def upper (L : ℕ) : ℤ := ((L / 2 : ℕ) : ℤ)

def InWindow (L : ℕ) (i : ℤ) : Prop := lower L ≤ i ∧ i ≤ upper L

def rep (L : ℕ) (i : ℤ) : ℤ := (i + offset L) % (L : ℤ) - offset L

theorem half_partition (L : ℕ) (hL : 0 < L) :
    (L - 1) / 2 + L / 2 + 1 = L := by omega

theorem half_partition_int (L : ℕ) (hL : 0 < L) :
    offset L + upper L + 1 = (L : ℤ) := by
  dsimp [offset, upper]
  exact_mod_cast half_partition L hL

theorem offset_le_upper (L : ℕ) : offset L ≤ upper L := by
  dsimp [offset, upper]
  omega

theorem zero_in_window (L : ℕ) : InWindow L 0 := by
  dsimp [InWindow, lower, offset, upper]
  omega

theorem rep_bounds (L : ℕ) (hL : 0 < L) (i : ℤ) : InWindow L (rep L i) := by
  have hp := half_partition_int L hL
  have hLZ : 0 < (L : ℤ) := by exact_mod_cast hL
  have hn := Int.emod_nonneg (i + offset L) (ne_of_gt hLZ)
  have hu := Int.emod_lt_of_pos (i + offset L) hLZ
  dsimp [InWindow, lower, rep]
  constructor <;> omega

theorem rep_eq_self (L : ℕ) (hL : 0 < L) (i : ℤ) (hi : InWindow L i) :
    rep L i = i := by
  have hp := half_partition_int L hL
  rcases hi with ⟨hi0, hi1⟩
  change -offset L ≤ i at hi0
  have hlo : 0 ≤ i + offset L := by omega
  have hhi : i + offset L < (L : ℤ) := by omega
  unfold rep
  rw [Int.emod_eq_of_lt hlo hhi]
  omega

theorem rep_idempotent (L : ℕ) (hL : 0 < L) (i : ℤ) :
    rep L (rep L i) = rep L i :=
  rep_eq_self L hL _ (rep_bounds L hL i)

/-- Congruence is an exact integer remainder identity, including negative inputs. -/
theorem rep_mod (L : ℕ) (i : ℤ) : rep L i % (L : ℤ) = i % (L : ℤ) := by
  have h := (Int.mod_modEq (i + offset L) (L : ℤ)).add_right (-offset L)
  simpa [rep, sub_eq_add_neg, add_assoc] using h

theorem rep_eq_iff_mod (L : ℕ) (_hL : 0 < L) (i j : ℤ) :
    rep L i = rep L j ↔ i % (L : ℤ) = j % (L : ℤ) := by
  constructor
  · intro h
    calc
      i % (L : ℤ) = rep L i % (L : ℤ) := (rep_mod L i).symm
      _ = rep L j % (L : ℤ) := by rw [h]
      _ = j % (L : ℤ) := rep_mod L j
  · intro h
    have hs : Int.ModEq (L : ℤ) (i + offset L) (j + offset L) :=
      (show Int.ModEq (L : ℤ) i j from h).add_right (offset L)
    exact congrArg (fun z : ℤ => z - offset L) hs

theorem window_unique (L : ℕ) (hL : 0 < L) (i j : ℤ)
    (hi : InWindow L i) (hj : InWindow L j)
    (hmod : i % (L : ℤ) = j % (L : ℤ)) : i = j := by
  have h := (rep_eq_iff_mod L hL i j).mpr hmod
  simpa only [rep_eq_self L hL i hi, rep_eq_self L hL j hj] using h

theorem inWindow_abs_bound (L : ℕ) (i : ℤ) (hi : InWindow L i) :
    |i| ≤ ((L / 2 : ℕ) : ℤ) := by
  have hp := offset_le_upper L
  rcases hi with ⟨hi0, hi1⟩
  change -offset L ≤ i at hi0
  exact abs_le.mpr ⟨by change -upper L ≤ i; omega, hi1⟩

/-- An odd-length core interval is contained even when L has the asymmetric even seam. -/
theorem core_in_window (L t : ℕ) (hcap : 2 * t + 1 ≤ L)
    (i : ℤ) (hi : |i| ≤ (t : ℤ)) : InWindow L i := by
  have hi' := abs_le.mp hi
  dsimp [InWindow, lower, offset, upper]
  omega

theorem rep_core (L t : ℕ) (hcap : 2 * t + 1 ≤ L)
    (i : ℤ) (hi : |i| ≤ (t : ℤ)) : rep L i = i :=
  rep_eq_self L (by omega) i (core_in_window L t hcap i hi)

/-- Congruent integers at distance strictly less than the positive modulus coincide. -/
theorem eq_of_mod_of_sub_bounds (L : ℕ) (_hL : 0 < L) (i j : ℤ)
    (hmod : i % (L : ℤ) = j % (L : ℤ))
    (hlo : -(L : ℤ) < i - j) (hhi : i - j < (L : ℤ)) : i = j := by
  have hd : (L : ℤ) ∣ i - j :=
    (Int.modEq_iff_dvd).mp (show Int.ModEq (L : ℤ) j i from hmod.symm)
  by_cases hz : i - j = 0
  · exact sub_eq_zero.mp hz
  · rcases lt_or_gt_of_ne hz with hn | hp
    · have hnpos : 0 < -(i - j) := by omega
      have hle := Int.le_of_dvd hnpos (dvd_neg.mpr hd)
      omega
    · have hle := Int.le_of_dvd hp hd
      omega

/-- A wrapped label cannot enter an old support core when the whole parent range
is strictly closer than one modulus to every point of that core. -/
theorem no_alias_core (L t B : ℕ) (hL : 0 < L) (hgap : B + t < L)
    (i : ℤ) (hi : |i| ≤ (B : ℤ)) (hc : |rep L i| ≤ (t : ℤ)) :
    rep L i = i := by
  have hi' := abs_le.mp hi
  have hc' := abs_le.mp hc
  have hg : (B : ℤ) + (t : ℤ) < (L : ℤ) := by exact_mod_cast hgap
  exact eq_of_mod_of_sub_bounds L hL (rep L i) i (rep_mod L i)
    (by omega) (by omega)

/-- All three parents of a current canonical representative avoid old-core aliases
under the stated changing-ring growth margin. -/
theorem parent_no_alias (L Lnext t : ℕ) (hL : 0 < L) (_hnext : 0 < Lnext)
    (hgap : Lnext / 2 + t + 1 < L) (j δ : ℤ)
    (hj : InWindow Lnext j) (hδ : |δ| ≤ 1)
    (hc : |rep L (j + δ)| ≤ (t : ℤ)) : rep L (j + δ) = j + δ := by
  have hjabs := inWindow_abs_bound Lnext j hj
  have hs := abs_add_le j δ
  have hi : |j + δ| ≤ ((Lnext / 2 + 1 : ℕ) : ℤ) := by
    push_cast
    omega
  exact no_alias_core L t (Lnext / 2 + 1) hL (by omega) (j + δ) hi hc

theorem parent_outside_core (L Lnext t : ℕ) (hL : 0 < L) (hnext : 0 < Lnext)
    (hgap : Lnext / 2 + t + 1 < L) (j δ : ℤ)
    (hj : InWindow Lnext j) (hδ : |δ| ≤ 1) (hout : (t : ℤ) < |j + δ|) :
    (t : ℤ) < |rep L (j + δ)| := by
  by_contra h
  have hc : |rep L (j + δ)| ≤ (t : ℤ) := by omega
  have he := parent_no_alias L Lnext t hL hnext hgap j δ hj hδ hc
  rw [he] at hc
  omega

/-- One explicit unbounded length schedule satisfying the sufficient margins. -/
theorem length_two_five_cap (t : ℕ) : 2 * t + 3 ≤ 2 * t + 5 := by omega

theorem length_two_five_gap (t : ℕ) :
    (2 * (t + 1) + 5) / 2 + t + 1 < 2 * t + 5 := by omega

end FVLT.WovenCanonicalV1
