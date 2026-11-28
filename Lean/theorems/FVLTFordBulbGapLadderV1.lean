import FVLTFordBulbUniquenessV1
import Mathlib.Data.Finset.Sort
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Zify

/-!
FF-4 B6b: the gap ladder of the rotation-p/q doubling cycle on q-bit words.

For the FF-4 orbit set of an address p/q, the q directed gaps between consecutive members
in sorted order (the wrap gap `M + w₀ - w_{q-1}` included, `M = 2 ^ q - 1`) double along the
rotation at every rank except the wrap rank, and the gap at rank `(p - 1 + k p) mod q` is
exactly `2 ^ k`. Hence the gaps are the powers `2 ^ 0, …, 2 ^ (q - 1)`, each once.
The statements are exact statements about natural numbers; no analytic dynamics and no
Rule 30 claim is made here.

The gap-ladder observation is Gemini's (lane E), in saphir's B6 programme.
The framework was assembled by Robin Miller; its components are classical results of others.
-/
set_option autoImplicit false
open scoped BigOperators
namespace FVLT.FordBulbV1

-- BEGIN FROZEN DEFINITIONS
/-- Directed gap above rank `r` in the FF-4 orbit set: the distance from the rank-`r` word to
    the rank-`(r + 1)` word, and for the top rank `r = q - 1` the wrap gap `M + w₀ - w_{q-1}`
    (the arc through 0). Natural subtraction; its meaning is pinned by `word_add_rankGap` and
    `rankGap_sum`. Values at `r ≥ q` are not used by any statement. -/
def rankGap (d : RotationAddress) (r : ℕ) : ℕ :=
  if r + 1 < d.q then blockValue d.p d.q (r + 1) d.q - blockValue d.p d.q r d.q
  else modulus d + blockValue d.p d.q 0 d.q - blockValue d.p d.q (d.q - 1) d.q
-- END FROZEN DEFINITIONS


private theorem word_mem (d : RotationAddress) (u : ℕ) (hu : u < d.q) :
    blockValue d.p d.q u d.q ∈ orbitSet d := by
  rw [orbit_set_eq]
  exact Finset.mem_image.mpr ⟨⟨u, hu⟩, Finset.mem_univ _, rfl⟩

private theorem word_lt_modulus (d : RotationAddress) (u : ℕ) (hu : u < d.q) :
    blockValue d.p d.q u d.q < modulus d :=
  (word_bounds d ⟨u, hu⟩).2

private theorem word_lt (d : RotationAddress) (u v : ℕ) (hv : v < d.q) (huv : u < v) :
    blockValue d.p d.q u d.q < blockValue d.p d.q v d.q :=
  word_strict d (Fin.mk_lt_mk.mpr huv : (⟨u, lt_trans huv hv⟩ : Fin d.q) < ⟨v, hv⟩)

private theorem word_double_gen (d : RotationAddress) (u : ℕ) (hu : u < d.q) :
    blockValue d.p d.q ((u + d.p) % d.q) d.q + topBit d.q (blockValue d.p d.q u d.q) * modulus d
      = 2 * blockValue d.p d.q u d.q := by
  have h1 := double_add_topBit d (wordValue d ⟨u, hu⟩) (word_bounds d ⟨u, hu⟩).2
  rw [double_word] at h1
  exact h1

private theorem word_topBit (d : RotationAddress) (u : ℕ) (hu : u < d.q) :
    topBit d.q (blockValue d.p d.q u d.q) = if d.q - d.p ≤ u then 1 else 0 := by
  have hb := rotation_cycle_high_block d (orbitSet_isRotationCycle d) (word_mem d u hu)
  have hr : setRank (orbitSet d) (blockValue d.p d.q u d.q) = u := by
    rw [setRank_orbitSet]
    exact rank_word d ⟨u, hu⟩
  rw [hr] at hb
  split_ifs with hc
  · exact hb.mpr hc
  · have hne : topBit d.q (blockValue d.p d.q u d.q) ≠ 1 := fun h => hc (hb.mp h)
    unfold topBit at hne ⊢
    split_ifs at hne ⊢ <;> omega

private theorem word_double_low (d : RotationAddress) (u : ℕ) (hu : u + d.p < d.q) :
    2 * blockValue d.p d.q u d.q = blockValue d.p d.q (u + d.p) d.q := by
  have hu' : u < d.q := by omega
  have h1 := word_double_gen d u hu'
  rw [word_topBit d u hu', if_neg (show ¬ (d.q - d.p ≤ u) by omega), Nat.mod_eq_of_lt hu] at h1
  omega

private theorem word_double_high (d : RotationAddress) (u : ℕ) (hu : u < d.q)
    (hh : d.q ≤ u + d.p) :
    2 * blockValue d.p d.q u d.q = blockValue d.p d.q (u + d.p - d.q) d.q + modulus d := by
  have hpq := d.p_lt_q
  have h1 := word_double_gen d u hu
  have hm : (u + d.p) % d.q = u + d.p - d.q := by
    rw [Nat.mod_eq_sub_mod hh, Nat.mod_eq_of_lt (show u + d.p - d.q < d.q by omega)]
  rw [word_topBit d u hu, if_pos (show d.q - d.p ≤ u by omega), hm] at h1
  omega

private theorem ordered_word_at' (d : RotationAddress) (i : Fin (orderedOrbit d).length) :
    (orderedOrbit d).get i = wordValue d ⟨i.val, by rw [← orbit_length d]; exact i.isLt⟩ := by
  have hf : wordValue d = (orbitSet d).orderEmbOfFin (orbit_card d) := by
    apply Finset.orderEmbOfFin_unique (orbit_card d)
    · intro u
      rw [orbit_set_eq]
      exact Finset.mem_image.mpr ⟨u, Finset.mem_univ _, rfl⟩
    · exact word_strict d
  have hiq : i.val < d.q := by rw [← orbit_length d]; exact i.isLt
  have hv := congrFun hf ⟨i.val, hiq⟩
  rw [Finset.orderEmbOfFin_apply] at hv
  change ((orbitSet d).sort (fun a b : ℕ => a ≤ b))[i.val]'i.isLt = _
  simp only [Fin.getElem_fin] at hv
  convert hv.symm using 1

/-- G0: bridge to FF-4's `directedGap` (sorted-order gaps, wrap included). -/
theorem directedGap_eq_rankGap (d : RotationAddress) (i : Fin (orderedOrbit d).length) :
    directedGap d i = rankGap d i.val := by
  have hlen := orbit_length d
  have hiq : i.val < d.q := by rw [← hlen]; exact i.isLt
  have hs := ordered_word_at' d i
  unfold directedGap edgeEnd edgeStart rankGap
  by_cases h : i.val + 1 < (orderedOrbit d).length
  · have h' : i.val + 1 < d.q := by rw [← hlen]; exact h
    rw [dif_pos h, if_pos h, if_pos h', hs, ordered_word_at' d ⟨i.val + 1, h⟩]
    rfl
  · have h' : ¬ i.val + 1 < d.q := by rw [← hlen]; exact h
    have h0 : 0 < (orderedOrbit d).length := by omega
    rw [dif_neg h, if_neg h, if_neg h', hs, ordered_word_at' d ⟨0, h0⟩]
    have hi : i.val = d.q - 1 := by omega
    show modulus d + blockValue d.p d.q 0 d.q - blockValue d.p d.q i.val d.q = _
    rw [hi]

/-- G1: consecutive words differ by the gap (non-wrap ranks). -/
theorem word_add_rankGap (d : RotationAddress) (r : ℕ) (hr : r + 1 < d.q) :
    blockValue d.p d.q (r + 1) d.q = blockValue d.p d.q r d.q + rankGap d r := by
  have h := word_lt d r (r + 1) hr (by omega)
  unfold rankGap
  rw [if_pos hr]
  omega

/-- G2: doubling identity; holds at every non-wrap rank, including the cut rank `q - p - 1`. -/
theorem rankGap_double (d : RotationAddress) (r : ℕ) (hr : r + 1 < d.q) :
    rankGap d ((r + d.p) % d.q) = 2 * rankGap d r := by
  have hp := d.p_pos
  have hpq := d.p_lt_q
  have hlt := word_lt d r (r + 1) hr (by omega)
  have hg : rankGap d r = blockValue d.p d.q (r + 1) d.q - blockValue d.p d.q r d.q := by
    unfold rankGap
    rw [if_pos hr]
  rw [hg]
  rcases Nat.lt_or_ge (r + 1 + d.p) d.q with h1 | h1
  · have e1 := word_double_low d r (by omega)
    have e2 := word_double_low d (r + 1) h1
    have hm : (r + d.p) % d.q = r + d.p := Nat.mod_eq_of_lt (by omega)
    have hl := word_lt d (r + d.p) (r + 1 + d.p) h1 (by omega)
    rw [hm]
    unfold rankGap
    rw [if_pos (show r + d.p + 1 < d.q by omega), show r + d.p + 1 = r + 1 + d.p by omega]
    omega
  · rcases Nat.eq_or_lt_of_le h1 with h2 | h2
    · have e1 := word_double_low d r (by omega)
      have e2 := word_double_high d (r + 1) hr (by omega)
      have hm : (r + d.p) % d.q = d.q - 1 := by
        rw [Nat.mod_eq_of_lt (show r + d.p < d.q by omega)]
        omega
      rw [show r + 1 + d.p - d.q = 0 by omega] at e2
      rw [show r + d.p = d.q - 1 by omega] at e1
      have hb := word_lt_modulus d (d.q - 1) (by omega)
      rw [hm]
      unfold rankGap
      rw [if_neg (show ¬ (d.q - 1 + 1 < d.q) by omega)]
      omega
    · have e1 := word_double_high d r (by omega) (by omega)
      have e2 := word_double_high d (r + 1) hr (by omega)
      have hm : (r + d.p) % d.q = r + d.p - d.q := by
        rw [Nat.mod_eq_sub_mod (show d.q ≤ r + d.p by omega),
          Nat.mod_eq_of_lt (show r + d.p - d.q < d.q by omega)]
      have hl := word_lt d (r + d.p - d.q) (r + 1 + d.p - d.q) (by omega) (by omega)
      rw [hm]
      unfold rankGap
      rw [if_pos (show r + d.p - d.q + 1 < d.q by omega),
        show r + d.p - d.q + 1 = r + 1 + d.p - d.q by omega]
      omega

/-- G3: the wrap rank is the single exception; the excess is exactly one modulus. -/
theorem rankGap_wrap_double (d : RotationAddress) :
    2 * rankGap d (d.q - 1) = rankGap d (d.p - 1) + modulus d := by
  have hp := d.p_pos
  have hpq := d.p_lt_q
  have e1 := word_double_high d (d.q - 1) (by omega) (by omega)
  have e0 := word_double_low d 0 (by omega)
  rw [show d.q - 1 + d.p - d.q = d.p - 1 by omega] at e1
  rw [Nat.zero_add] at e0
  have hb := word_lt_modulus d (d.q - 1) (by omega)
  have hl := word_lt d (d.p - 1) d.p hpq (by omega)
  unfold rankGap
  rw [if_neg (show ¬ (d.q - 1 + 1 < d.q) by omega), if_pos (show d.p - 1 + 1 < d.q by omega),
    show d.p - 1 + 1 = d.p by omega]
  omega

private theorem unit_gap (d : RotationAddress) : rankGap d (d.p - 1) = 1 := by
  have hp := d.p_pos
  have hpq := d.p_lt_q
  have h := characteristic_adjacent d
  change blockValue d.p d.q d.p d.q = blockValue d.p d.q (d.p - 1) d.q + 1 at h
  unfold rankGap
  rw [if_pos (show d.p - 1 + 1 < d.q by omega), show d.p - 1 + 1 = d.p by omega]
  omega

private theorem ladder_step_ne_wrap (d : RotationAddress) (k : ℕ) (hk : k + 1 < d.q) :
    (d.p - 1 + k * d.p) % d.q + 1 < d.q := by
  have hp := d.p_pos
  have hpq := d.p_lt_q
  have hrq : (d.p - 1 + k * d.p) % d.q < d.q := Nat.mod_lt _ (by omega)
  by_contra hc
  have hr1 : (d.p - 1 + k * d.p) % d.q = d.q - 1 := by omega
  have hA : (d.p - 1 + k * d.p + 1) % d.q = 0 := by
    rw [Nat.add_mod, hr1, Nat.mod_eq_of_lt (show 1 < d.q by omega),
      show d.q - 1 + 1 = d.q by omega, Nat.mod_self]
  have e : d.p - 1 + k * d.p + 1 = (k + 1) * d.p := by
    rw [Nat.add_mul, one_mul]
    generalize k * d.p = t
    omega
  rw [e] at hA
  have hdvd : d.q ∣ (k + 1) * d.p := Nat.dvd_of_mod_eq_zero hA
  have hk1 : d.q ∣ k + 1 := Nat.Coprime.dvd_of_dvd_mul_right (Nat.Coprime.symm d.coprime) hdvd
  have := Nat.le_of_dvd (by omega) hk1
  omega

/-- G4 (sharp ladder): the gap at rank `(p - 1 + k p) mod q` is `2 ^ k`. -/
theorem rankGap_ladder (d : RotationAddress) (k : ℕ) (hk : k < d.q) :
    rankGap d ((d.p - 1 + k * d.p) % d.q) = 2 ^ k := by
  have hp := d.p_pos
  have hpq := d.p_lt_q
  induction k with
  | zero =>
    rw [zero_mul, add_zero, Nat.mod_eq_of_lt (show d.p - 1 < d.q by omega), pow_zero]
    exact unit_gap d
  | succ k ih =>
    have ih' := ih (by omega)
    have hne := ladder_step_ne_wrap d k hk
    have hstep := rankGap_double d _ hne
    have hr' : ((d.p - 1 + k * d.p) % d.q + d.p) % d.q = (d.p - 1 + (k + 1) * d.p) % d.q := by
      rw [Nat.mod_add_mod, Nat.add_mul, one_mul, add_assoc]
    rw [hr', ih'] at hstep
    rw [hstep, pow_succ]
    ring

private theorem ladder_last (d : RotationAddress) :
    (d.p - 1 + (d.q - 1) * d.p) % d.q = d.q - 1 := by
  have hp := d.p_pos
  have hpq := d.p_lt_q
  obtain ⟨n, hn⟩ : ∃ n, d.p = n + 1 := ⟨d.p - 1, by omega⟩
  obtain ⟨m, hm⟩ : ∃ m, d.q = m + 1 := ⟨d.q - 1, by omega⟩
  rw [hn, hm, Nat.add_sub_cancel, Nat.add_sub_cancel]
  have e : n + m * (n + 1) = m + (m + 1) * n := by ring
  rw [e, Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt (show m < m + 1 by omega)]

/-- G5: the unit, cut and wrap gaps. -/
theorem rankGap_unit_cut_wrap (d : RotationAddress) :
    rankGap d (d.p - 1) = 1 ∧ rankGap d (d.q - d.p - 1) = 2 ^ (d.q - 2) ∧
      rankGap d (d.q - 1) = 2 ^ (d.q - 1) := by
  have hq := q_at_least_two d
  have hp := d.p_pos
  have hpq := d.p_lt_q
  have hw : rankGap d (d.q - 1) = 2 ^ (d.q - 1) := by
    have h := rankGap_ladder d (d.q - 1) (by omega)
    rwa [ladder_last] at h
  refine ⟨unit_gap d, ?_, hw⟩
  have hc := rankGap_double d (d.q - d.p - 1) (by omega)
  rw [show d.q - d.p - 1 + d.p = d.q - 1 by omega, Nat.mod_eq_of_lt (show d.q - 1 < d.q by omega),
    hw] at hc
  have h2 : 2 ^ (d.q - 1) = 2 * 2 ^ (d.q - 2) := by
    rw [← pow_succ']
    congr 1
    omega
  rw [h2] at hc
  generalize 2 ^ (d.q - 2) = t at hc ⊢
  omega

private theorem ladder_inj (d : RotationAddress) {k j : ℕ} (hk : k < d.q) (hj : j < d.q)
    (h : (d.p - 1 + k * d.p) % d.q = (d.p - 1 + j * d.p) % d.q) : k = j := by
  have h1 : d.p - 1 + k * d.p ≡ d.p - 1 + j * d.p [MOD d.q] := h
  have h2 := Nat.ModEq.add_left_cancel' (d.p - 1) h1
  have h3 := Nat.ModEq.cancel_right_of_coprime (Nat.Coprime.symm d.coprime) h2
  unfold Nat.ModEq at h3
  rwa [Nat.mod_eq_of_lt hk, Nat.mod_eq_of_lt hj] at h3

private theorem ladder_surj (d : RotationAddress) {r : ℕ} (hr : r < d.q) :
    ∃ k < d.q, (d.p - 1 + k * d.p) % d.q = r := by
  have hq : 0 < d.q := by have := d.p_pos; have := d.p_lt_q; omega
  have hsub : (Finset.range d.q).image (fun k => (d.p - 1 + k * d.p) % d.q) ⊆
      Finset.range d.q := by
    intro x hx
    obtain ⟨k, _, rfl⟩ := Finset.mem_image.mp hx
    exact Finset.mem_range.mpr (Nat.mod_lt _ hq)
  have hcard : ((Finset.range d.q).image (fun k => (d.p - 1 + k * d.p) % d.q)).card = d.q := by
    rw [Finset.card_image_of_injOn, Finset.card_range]
    intro a ha b hb hab
    exact ladder_inj d (Finset.mem_range.mp (Finset.mem_coe.mp ha))
      (Finset.mem_range.mp (Finset.mem_coe.mp hb)) hab
  have heq := Finset.eq_of_subset_of_card_le hsub (by rw [hcard, Finset.card_range])
  have hmem : r ∈ (Finset.range d.q).image (fun k => (d.p - 1 + k * d.p) % d.q) := by
    rw [heq]
    exact Finset.mem_range.mpr hr
  obtain ⟨k, hk, hkr⟩ := Finset.mem_image.mp hmem
  exact ⟨k, Finset.mem_range.mp hk, hkr⟩

/-- G6 (multiset corollary, image part): the gaps are exactly the powers `2 ^ 0, …, 2 ^ (q - 1)`. -/
theorem rankGap_image (d : RotationAddress) :
    (Finset.range d.q).image (rankGap d) = (Finset.range d.q).image (fun k => 2 ^ k) := by
  have hq : 0 < d.q := by have := d.p_pos; have := d.p_lt_q; omega
  ext g
  simp only [Finset.mem_image, Finset.mem_range]
  constructor
  · rintro ⟨r, hr, rfl⟩
    obtain ⟨k, hk, hkr⟩ := ladder_surj d hr
    exact ⟨k, hk, by rw [← hkr, rankGap_ladder d k hk]⟩
  · rintro ⟨k, hk, rfl⟩
    exact ⟨_, Nat.mod_lt _ hq, rankGap_ladder d k hk⟩

/-- G7 (multiset corollary, multiplicity part): no gap value repeats, so each power occurs once. -/
theorem rankGap_injOn (d : RotationAddress) : Set.InjOn (rankGap d) (Finset.range d.q) := by
  intro r hr r' hr' h
  obtain ⟨k, hk, rfl⟩ := ladder_surj d (Finset.mem_range.mp (Finset.mem_coe.mp hr))
  obtain ⟨k', hk', rfl⟩ := ladder_surj d (Finset.mem_range.mp (Finset.mem_coe.mp hr'))
  rw [rankGap_ladder d k hk, rankGap_ladder d k' hk'] at h
  rw [Nat.pow_right_injective (le_refl 2) h]

private theorem gap_telescope (d : RotationAddress) (n : ℕ) (hn : n < d.q) :
    ∑ r ∈ Finset.range n, rankGap d r =
      blockValue d.p d.q n d.q - blockValue d.p d.q 0 d.q := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ, ih (by omega)]
    have h := word_add_rankGap d n hn
    have hle : blockValue d.p d.q 0 d.q ≤ blockValue d.p d.q n d.q := by
      rcases Nat.eq_zero_or_pos n with h0 | h0
      · rw [h0]
      · exact le_of_lt (word_lt d 0 n (by omega) h0)
    omega

/-- G8 (consistency): the `q` gaps sum to the modulus. -/
theorem rankGap_sum (d : RotationAddress) :
    ∑ r ∈ Finset.range d.q, rankGap d r = modulus d := by
  have hq := q_at_least_two d
  have hq1 : d.q - 1 + 1 = d.q := by omega
  rw [← hq1, Finset.sum_range_succ, gap_telescope d (d.q - 1) (by omega)]
  have hb := word_lt_modulus d (d.q - 1) (by omega)
  have hl := word_lt d 0 (d.q - 1) (by omega) (by omega)
  unfold rankGap
  rw [if_neg (show ¬ (d.q - 1 + 1 < d.q) by omega)]
  omega

/-- G9 (transfer): in any admissible rotation-p/q cycle `S`, consecutive members differ by the
    ladder gap of the lower member's rank. -/
theorem rotation_cycle_gap (d : RotationAddress) {S : Finset ℕ} (h : IsRotationCycle d S)
    {x y : ℕ} (hx : x ∈ S) (hy : y ∈ S) (hxy : setRank S y = setRank S x + 1) :
    y = x + rankGap d (setRank S x) := by
  obtain ⟨_, hxw⟩ := rotation_cycle_point_eq_word d h hx
  obtain ⟨hry, hyw⟩ := rotation_cycle_point_eq_word d h hy
  have hr1 : setRank S x + 1 < d.q := by rw [← hxy]; exact hry
  have hx' : x = blockValue d.p d.q (setRank S x) d.q := hxw
  have hy' : y = blockValue d.p d.q (setRank S x + 1) d.q := by rw [← hxy]; exact hyw
  have hg := word_add_rankGap d _ hr1
  omega

/-- G10 (transfer, wrap): the top and bottom members differ by the wrap gap modulo `M`. -/
theorem rotation_cycle_wrap_gap (d : RotationAddress) {S : Finset ℕ} (h : IsRotationCycle d S)
    {x y : ℕ} (hx : x ∈ S) (hy : y ∈ S) (hxr : setRank S x = d.q - 1) (hyr : setRank S y = 0) :
    modulus d + y = x + rankGap d (d.q - 1) := by
  have hq := q_at_least_two d
  obtain ⟨_, hxw⟩ := rotation_cycle_point_eq_word d h hx
  obtain ⟨_, hyw⟩ := rotation_cycle_point_eq_word d h hy
  have hx' : x = blockValue d.p d.q (d.q - 1) d.q := by rw [← hxr]; exact hxw
  have hy' : y = blockValue d.p d.q 0 d.q := by rw [← hyr]; exact hyw
  have hb := word_lt_modulus d (d.q - 1) (by omega)
  unfold rankGap
  rw [if_neg (show ¬ (d.q - 1 + 1 < d.q) by omega)]
  omega

/-- GN1 (negative control): the doubling orbit of 3 mod 31 (B6.N1, not a rotation cycle) has
    6 and 12 as consecutive members, and their gap 6 is not a power of two. -/
theorem nonrotation_gap_not_power :
    6 ∈ ({3, 6, 12, 17, 24} : Finset ℕ) ∧ 12 ∈ ({3, 6, 12, 17, 24} : Finset ℕ) ∧
      ({3, 6, 12, 17, 24} : Finset ℕ).filter (fun x => 6 < x ∧ x < 12) = ∅ ∧
        ∀ k < 5, 2 ^ k ≠ 12 - 6 := by
  decide

end FVLT.FordBulbV1
