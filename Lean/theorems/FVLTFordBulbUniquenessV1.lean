import FVLTFordBulbCombinatoricsV1
import Mathlib.Data.Finset.Card
import Mathlib.Data.Nat.ModEq
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Zify

/-!
FF-4 B6: uniqueness of the rotation-p/q doubling cycle on q-bit words.

A finite set S of residues mod 2^q - 1 is an admissible rotation-p/q cycle when it has
q elements, is closed under doubling, and doubling shifts every rank in S by p mod q
(definition D2 of the accepted lane C design). Every such S equals the FF-4 orbit set.
The statements are exact statements about natural numbers; no analytic dynamics, ray
landing, wake or limb geometry, and no Rule 30 claim is made here.

B6 belongs to saphir's FF-4 Ford-to-bulb programme; the design is lane C's.
The framework was assembled by Robin Miller; its components are classical results of others.
-/
set_option autoImplicit false
open scoped BigOperators
namespace FVLT.FordBulbV1

-- BEGIN FROZEN DEFINITIONS
/-- Rank of `n` inside a finite set: the number of members below `n`.
    For `S = orbitSet d` this is FF-4's `rank d` by definition. -/
def setRank (S : Finset ℕ) (n : ℕ) : ℕ := (S.filter (fun x => x < n)).card

/-- Upper-half indicator for q-bit words: `1` iff `2 ^ (q - 1) ≤ x`. -/
def topBit (q x : ℕ) : ℕ := if 2 ^ (q - 1) ≤ x then 1 else 0

/-- Admissible rotation-p/q cycle of doubling on q-bit words (definition D2). -/
structure IsRotationCycle (d : RotationAddress) (S : Finset ℕ) : Prop where
  lt_modulus : ∀ x ∈ S, x < modulus d
  card_eq   : S.card = d.q
  maps_to   : ∀ x ∈ S, doubleNum d x ∈ S
  rank_step : ∀ x ∈ S, setRank S (doubleNum d x) = (setRank S x + d.p) % d.q

/-- The address 2/5, used only by the negative control `weight_is_not_admissible`. -/
def address25 : RotationAddress := ⟨2, 5, by decide, by decide, by decide⟩
-- END FROZEN DEFINITIONS


/-- B6.0: bridge to FF-4; `setRank` on the orbit set is FF-4's `rank`. -/
theorem setRank_orbitSet (d : RotationAddress) (n : ℕ) :
    setRank (orbitSet d) n = rank d n := by
  rfl

/-- H1: one doubling step on a residue below the modulus. -/
theorem double_add_topBit (d : RotationAddress) (x : ℕ) (hx : x < modulus d) :
    doubleNum d x + topBit d.q x * modulus d = 2 * x := by
  have hq := q_at_least_two d
  have hpow : 2 ^ d.q = 2 * 2 ^ (d.q - 1) := by
    rw [← pow_succ']
    congr 1
    omega
  unfold doubleNum topBit
  unfold modulus at hx ⊢
  rw [hpow] at hx ⊢
  generalize 2 ^ (d.q - 1) = t at hx ⊢
  split_ifs with h
  · have h1 : 2 * t - 1 ≤ 2 * x := by omega
    have h2 : 2 * x - (2 * t - 1) < 2 * t - 1 := by omega
    rw [Nat.mod_eq_sub_mod h1, Nat.mod_eq_of_lt h2]
    omega
  · rw [Nat.mod_eq_of_lt (by omega)]
    omega

/-- H2: the iterate is repeated doubling (public restatement of an FF-4 private step). -/
theorem iterateNum_succ_eq (d : RotationAddress) (x i : ℕ) :
    iterateNum d x (i + 1) = doubleNum d (iterateNum d x i) := by
  unfold iterateNum doubleNum
  rw [Nat.mul_mod_mod, pow_succ', mul_assoc]

private theorem pow_q_mod_modulus (d : RotationAddress) : 2 ^ d.q % modulus d = 1 := by
  have hq := q_at_least_two d
  have h4 : 4 ≤ 2 ^ d.q := by
    calc 4 = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ d.q := Nat.pow_le_pow_right (by norm_num) hq
  unfold modulus
  generalize 2 ^ d.q = t at h4 ⊢
  obtain ⟨m, rfl⟩ : ∃ m, t = m + 1 := ⟨t - 1, by omega⟩
  rw [Nat.add_sub_cancel, Nat.add_mod_left, Nat.mod_eq_of_lt (by omega)]

private theorem telescope (d : RotationAddress) (x : ℕ) (hx : x < modulus d) (n : ℕ) :
    2 ^ n * x = iterateNum d x n +
      modulus d * ∑ i ∈ Finset.range n, topBit d.q (iterateNum d x i) * 2 ^ (n - 1 - i) := by
  induction n with
  | zero => simp [iterateNum, Nat.mod_eq_of_lt hx]
  | succ n ih =>
    have hy : iterateNum d x n < modulus d := Nat.mod_lt _ (modulus_pos d)
    have h1 := double_add_topBit d _ hy
    rw [← iterateNum_succ_eq] at h1
    have hsum : ∑ i ∈ Finset.range (n + 1), topBit d.q (iterateNum d x i) * 2 ^ (n + 1 - 1 - i)
        = 2 * ∑ i ∈ Finset.range n, topBit d.q (iterateNum d x i) * 2 ^ (n - 1 - i)
          + topBit d.q (iterateNum d x n) := by
      rw [Finset.sum_range_succ, Finset.mul_sum]
      congr 1
      · apply Finset.sum_congr rfl
        intro i hi
        rw [Finset.mem_range] at hi
        have e : n + 1 - 1 - i = (n - 1 - i) + 1 := by omega
        rw [e, pow_succ]
        ring
      · simp
    rw [hsum, pow_succ, mul_comm (2 ^ n) 2, mul_assoc, ih]
    generalize ∑ i ∈ Finset.range n, topBit d.q (iterateNum d x i) * 2 ^ (n - 1 - i) = B
    generalize iterateNum d x n = y at h1
    generalize iterateNum d x (n + 1) = y' at h1
    generalize topBit d.q y = b at h1
    nlinarith [h1]

/-- H3 (lemma L2): a residue below the modulus is the binary word of its top bits
    along the doubling orbit, most significant first. -/
theorem bit_expansion (d : RotationAddress) (x : ℕ) (hx : x < modulus d) :
    x = ∑ i ∈ Finset.range d.q, topBit d.q (iterateNum d x i) * 2 ^ (d.q - 1 - i) := by
  have h := telescope d x hx d.q
  have hy : iterateNum d x d.q = x := by
    unfold iterateNum
    rw [Nat.mul_mod, pow_q_mod_modulus, one_mul, Nat.mod_mod, Nat.mod_eq_of_lt hx]
  rw [hy] at h
  have h1 : 1 ≤ 2 ^ d.q := Nat.one_le_two_pow
  have hM : 2 ^ d.q = modulus d + 1 := by unfold modulus; omega
  rw [hM] at h
  generalize ∑ i ∈ Finset.range d.q, topBit d.q (iterateNum d x i) * 2 ^ (d.q - 1 - i) = B at h ⊢
  have h2 : modulus d * x = modulus d * B := by nlinarith [h]
  exact Nat.eq_of_mul_eq_mul_left (modulus_pos d) h2

/-- H4: `setRank` is strictly monotone on the members of a finite set. -/
theorem setRank_lt_setRank (S : Finset ℕ) {x y : ℕ} (hx : x ∈ S) (hy : y ∈ S) (hxy : x < y) :
    setRank S x < setRank S y := by
  unfold setRank
  apply Finset.card_lt_card
  rw [Finset.ssubset_iff_of_subset]
  · exact ⟨x, by simp [hx, hxy], by simp⟩
  · intro z hz
    simp only [Finset.mem_filter] at hz ⊢
    exact ⟨hz.1, by omega⟩

/-- H5: the rank of a member is below the cardinality. -/
theorem setRank_lt_card (S : Finset ℕ) {x : ℕ} (hx : x ∈ S) : setRank S x < S.card := by
  unfold setRank
  exact Finset.card_lt_card (Finset.filter_ssubset.mpr ⟨x, hx, lt_irrefl x⟩)

private theorem setRank_injOn (S : Finset ℕ) : Set.InjOn (setRank S) S := by
  intro a ha b hb hab
  have ha' : a ∈ S := Finset.mem_coe.mp ha
  have hb' : b ∈ S := Finset.mem_coe.mp hb
  rcases lt_trichotomy a b with h | h | h
  · exact absurd hab (ne_of_lt (setRank_lt_setRank S ha' hb' h))
  · exact h
  · exact absurd hab (ne_of_gt (setRank_lt_setRank S hb' ha' h))

/-- H6: every rank below the cardinality is attained by a member. -/
theorem setRank_surj (S : Finset ℕ) {r : ℕ} (hr : r < S.card) :
    ∃ x ∈ S, setRank S x = r := by
  have hsub : S.image (setRank S) ⊆ Finset.range S.card := by
    intro r' hr'
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hr'
    exact Finset.mem_range.mpr (setRank_lt_card S hx)
  have hcard : (S.image (setRank S)).card = S.card := Finset.card_image_of_injOn (setRank_injOn S)
  have heq : S.image (setRank S) = Finset.range S.card :=
    Finset.eq_of_subset_of_card_le hsub (by rw [hcard, Finset.card_range])
  have hmem : r ∈ S.image (setRank S) := by
    rw [heq]
    exact Finset.mem_range.mpr hr
  obtain ⟨x, hx, hxr⟩ := Finset.mem_image.mp hmem
  exact ⟨x, hx, hxr⟩

private theorem rank_lt_q (d : RotationAddress) {S : Finset ℕ}
    (h : IsRotationCycle d S) {x : ℕ} (hx : x ∈ S) : setRank S x < d.q := by
  have := setRank_lt_card S hx
  rw [h.card_eq] at this
  exact this

/-- H7 (lemma L1): in an admissible cycle the members with top bit 1 are exactly
    the p members of largest rank. -/
theorem rotation_cycle_high_block (d : RotationAddress) {S : Finset ℕ}
    (h : IsRotationCycle d S) {x : ℕ} (hx : x ∈ S) :
    topBit d.q x = 1 ↔ d.q - d.p ≤ setRank S x := by
  have hp := d.p_pos
  have hpq := d.p_lt_q
  have hc := h.card_eq
  obtain ⟨a, ha, hra⟩ := setRank_surj S (r := d.q - d.p - 1) (by omega)
  obtain ⟨b, hb, hrb⟩ := setRank_surj S (r := d.q - d.p) (by omega)
  have hab : a < b := by
    rcases Nat.lt_or_ge a b with h' | h'
    · exact h'
    · rcases Nat.eq_or_lt_of_le h' with h'' | h''
      · subst h''
        omega
      · have := setRank_lt_setRank S hb ha h''
        omega
  have hda := h.rank_step a ha
  have hdb := h.rank_step b hb
  rw [hra] at hda
  rw [hrb] at hdb
  have e1 : (d.q - d.p - 1 + d.p) % d.q = d.q - 1 := by
    rw [show d.q - d.p - 1 + d.p = d.q - 1 by omega]
    exact Nat.mod_eq_of_lt (by omega)
  have e2 : (d.q - d.p + d.p) % d.q = 0 := by
    rw [show d.q - d.p + d.p = d.q by omega]
    exact Nat.mod_self _
  rw [e1] at hda
  rw [e2] at hdb
  have hneq : topBit d.q a ≠ topBit d.q b := by
    intro heq
    have h1 := double_add_topBit d a (h.lt_modulus a ha)
    have h2 := double_add_topBit d b (h.lt_modulus b hb)
    rw [← heq] at h2
    have hlt : doubleNum d a < doubleNum d b := by
      generalize topBit d.q a * modulus d = c at h1 h2
      omega
    have := setRank_lt_setRank S (h.maps_to a ha) (h.maps_to b hb) hlt
    omega
  have hta0 : topBit d.q a = 0 := by
    unfold topBit at hneq ⊢
    split_ifs at hneq ⊢ <;> omega
  have hsmall : a < 2 ^ (d.q - 1) := by
    unfold topBit at hta0
    split_ifs at hta0 with hh <;> omega
  have hbig : 2 ^ (d.q - 1) ≤ b := by
    have htb : topBit d.q b ≠ 0 := by rw [← hta0]; exact hneq.symm
    unfold topBit at htb
    split_ifs at htb with hh <;> omega
  constructor
  · intro hx1
    by_contra hlt
    have hxa : x ≤ a := by
      rcases Nat.lt_or_ge a x with h' | h'
      · have := setRank_lt_setRank S ha hx h'
        omega
      · exact h'
    unfold topBit at hx1
    split_ifs at hx1 <;> omega
  · intro hge
    have hbx : b ≤ x := by
      rcases Nat.lt_or_ge x b with h' | h'
      · have := setRank_lt_setRank S hx hb h'
        omega
      · exact h'
    unfold topBit
    split_ifs with hh
    · rfl
    · omega

/-- H8: iterated rank step. -/
theorem rotation_cycle_iterate (d : RotationAddress) {S : Finset ℕ}
    (h : IsRotationCycle d S) {x : ℕ} (hx : x ∈ S) (i : ℕ) :
    iterateNum d x i ∈ S ∧
      setRank S (iterateNum d x i) = (setRank S x + i * d.p) % d.q := by
  induction i with
  | zero =>
    have hxm := h.lt_modulus x hx
    have h0 : iterateNum d x 0 = x := by simp [iterateNum, Nat.mod_eq_of_lt hxm]
    rw [h0, zero_mul, add_zero, Nat.mod_eq_of_lt (rank_lt_q d h hx)]
    exact ⟨hx, rfl⟩
  | succ i ih =>
    obtain ⟨hmem, hrank⟩ := ih
    rw [iterateNum_succ_eq]
    refine ⟨h.maps_to _ hmem, ?_⟩
    rw [h.rank_step _ hmem, hrank, Nat.add_mul, one_mul, ← add_assoc]
    exact Nat.mod_add_mod _ _ _

/-- H9: each member of an admissible cycle is the FF-4 mechanical word of its rank. -/
theorem rotation_cycle_point_eq_word (d : RotationAddress) {S : Finset ℕ}
    (h : IsRotationCycle d S) {x : ℕ} (hx : x ∈ S) :
    ∃ hr : setRank S x < d.q, x = wordValue d ⟨setRank S x, hr⟩ := by
  refine ⟨rank_lt_q d h hx, ?_⟩
  conv_lhs => rw [bit_expansion d x (h.lt_modulus x hx)]
  unfold wordValue blockValue
  apply Finset.sum_congr rfl
  intro i _
  congr 1
  obtain ⟨hmem, hrank⟩ := rotation_cycle_iterate d h hx i
  have hb := rotation_cycle_high_block d h hmem
  rw [hrank] at hb
  unfold rawDigit
  split_ifs with hc
  · exact hb.mpr hc
  · have hne : topBit d.q (iterateNum d x i) ≠ 1 := fun h1 => hc (hb.mp h1)
    unfold topBit at hne ⊢
    split_ifs at hne ⊢ <;> omega

/-- B6.1 (existence): the FF-4 orbit set is an admissible rotation-p/q cycle. -/
theorem orbitSet_isRotationCycle (d : RotationAddress) : IsRotationCycle d (orbitSet d) := by
  refine ⟨?_, orbit_card d, ?_, ?_⟩
  · intro x hx
    rw [orbit_set_eq] at hx
    obtain ⟨u, _, rfl⟩ := Finset.mem_image.mp hx
    exact (word_bounds d u).2
  · intro x hx
    rw [orbit_set_eq] at hx ⊢
    obtain ⟨u, _, rfl⟩ := Finset.mem_image.mp hx
    rw [double_word]
    exact Finset.mem_image_of_mem _ (Finset.mem_univ _)
  · intro x hx
    exact rank_step d x hx

/-- B6.2 (uniqueness): every admissible rotation-p/q cycle is the FF-4 orbit set.
    This quantifies over all finite sets `S`, not over one constructed orbit. -/
theorem rotation_cycle_unique (d : RotationAddress) (S : Finset ℕ)
    (h : IsRotationCycle d S) : S = orbitSet d := by
  have hsub : S ⊆ orbitSet d := by
    intro x hx
    obtain ⟨hr, hxw⟩ := rotation_cycle_point_eq_word d h hx
    rw [orbit_set_eq, Finset.mem_image]
    exact ⟨_, Finset.mem_univ _, hxw.symm⟩
  exact Finset.eq_of_subset_of_card_le hsub (by rw [orbit_card, h.card_eq])

/-- B6.3: admissibility characterizes the FF-4 orbit set. -/
theorem isRotationCycle_iff (d : RotationAddress) (S : Finset ℕ) :
    IsRotationCycle d S ↔ S = orbitSet d := by
  constructor
  · exact rotation_cycle_unique d S
  · intro hS
    subst hS
    exact orbitSet_isRotationCycle d

/-- B6.4 (classification): let `S` be the doubling orbit of `x₀` mod `2 ^ q - 1`, given
    explicitly as the image over `range q`; with `hcard` this is the exact-period
    hypothesis. If doubling shifts ranks in `S` by some `k < q`, then `0 < k` and
    `Nat.Coprime k q` are conclusions (they are fields of the produced address `d`),
    and `S` is the FF-4 orbit set of `d`. -/
theorem rotation_cycle_classification (q k x₀ : ℕ) (S : Finset ℕ) (hq : 2 ≤ q)
    (hS : S = (Finset.range q).image (fun i => (2 ^ i * x₀) % (2 ^ q - 1)))
    (hcard : S.card = q) (hk : k < q)
    (hrot : ∀ x ∈ S, setRank S ((2 * x) % (2 ^ q - 1)) = (setRank S x + k) % q) :
    ∃ d : RotationAddress, d.q = q ∧ d.p = k ∧ S = orbitSet d := by
  have h4 : 4 ≤ 2 ^ q := by
    calc 4 = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ q := Nat.pow_le_pow_right (by norm_num) hq
  set M := 2 ^ q - 1 with hMdef
  have hMpos : 0 < M := by omega
  have hpowM : 2 ^ q % M = 1 := by
    have e : 2 ^ q = M + 1 := by omega
    rw [e, Nat.add_mod_left, Nat.mod_eq_of_lt (by omega)]
  have hin : ∀ i, i < q → (2 ^ i * x₀) % M ∈ S := by
    intro i hi
    rw [hS]
    exact Finset.mem_image_of_mem _ (Finset.mem_range.mpr hi)
  have hmaps : ∀ x ∈ S, (2 * x) % M ∈ S := by
    intro x hx
    rw [hS, Finset.mem_image] at hx
    obtain ⟨i, hi, hix⟩ := hx
    have hix' : (2 ^ i * x₀) % M = x := hix
    rw [Finset.mem_range] at hi
    rw [← hix']
    have e : (2 * ((2 ^ i * x₀) % M)) % M = (2 ^ (i + 1) * x₀) % M := by
      rw [Nat.mul_mod_mod, pow_succ', mul_assoc]
    rw [e]
    rcases Nat.lt_or_ge (i + 1) q with hlt | hge
    · exact hin (i + 1) hlt
    · have hiq : i + 1 = q := by omega
      have e2 : (2 ^ (i + 1) * x₀) % M = (2 ^ 0 * x₀) % M := by
        rw [hiq, Nat.mul_mod, hpowM, one_mul, Nat.mod_mod, pow_zero, one_mul]
      rw [e2]
      exact hin 0 (by omega)
  have hrlt : ∀ x ∈ S, setRank S x < q := by
    intro x hx
    have := setRank_lt_card S hx
    omega
  have hk0 : 0 < k := by
    rcases Nat.eq_zero_or_pos k with hk0 | hk0
    · exfalso
      have hfix : ∀ x ∈ S, x = 0 := by
        intro x hx
        have hxM : x < M := by
          have hx' := hx
          rw [hS, Finset.mem_image] at hx'
          obtain ⟨i, _, hix⟩ := hx'
          rw [← hix]
          exact Nat.mod_lt _ hMpos
        have hr := hrot x hx
        rw [hk0, add_zero, Nat.mod_eq_of_lt (hrlt x hx)] at hr
        have heq : (2 * x) % M = x := setRank_injOn S (hmaps x hx) hx hr
        rcases Nat.lt_or_ge (2 * x) M with h2 | h2
        · rw [Nat.mod_eq_of_lt h2] at heq
          omega
        · rw [Nat.mod_eq_sub_mod h2, Nat.mod_eq_of_lt (by omega)] at heq
          omega
      have hsub : S ⊆ {0} := fun x hx => Finset.mem_singleton.mpr (hfix x hx)
      have := Finset.card_le_card hsub
      simp at this
      omega
    · exact hk0
  have hiter : ∀ i, (2 ^ i * x₀) % M ∈ S ∧
      setRank S ((2 ^ i * x₀) % M) = (setRank S ((2 ^ 0 * x₀) % M) + i * k) % q := by
    intro i
    induction i with
    | zero =>
      refine ⟨hin 0 (by omega), ?_⟩
      rw [zero_mul, add_zero, Nat.mod_eq_of_lt (hrlt _ (hin 0 (by omega)))]
    | succ i ih =>
      obtain ⟨hm, hr⟩ := ih
      have e : (2 * ((2 ^ i * x₀) % M)) % M = (2 ^ (i + 1) * x₀) % M := by
        rw [Nat.mul_mod_mod, pow_succ', mul_assoc]
      have hm' := hmaps _ hm
      rw [e] at hm'
      refine ⟨hm', ?_⟩
      have hstep := hrot _ hm
      rw [e, hr, Nat.mod_add_mod] at hstep
      rw [Nat.add_mul, one_mul, ← add_assoc]
      exact hstep
  have hr0q : setRank S ((2 ^ 0 * x₀) % M) < q := hrlt _ (hin 0 (by omega))
  obtain ⟨s, hs, hsr⟩ := setRank_surj S (r := (setRank S ((2 ^ 0 * x₀) % M) + 1) % q)
    (by rw [hcard]; exact Nat.mod_lt _ (by omega))
  have hs' := hs
  rw [hS, Finset.mem_image] at hs'
  obtain ⟨i, _, his⟩ := hs'
  have his' : (2 ^ i * x₀) % M = s := his
  have hti := (hiter i).2
  rw [his', hsr] at hti
  have hmod : setRank S ((2 ^ 0 * x₀) % M) + k * i ≡ setRank S ((2 ^ 0 * x₀) % M) + 1 [MOD q] := by
    unfold Nat.ModEq
    rw [Nat.mul_comm k i]
    exact hti.symm
  have hcop : Nat.Coprime k q := Nat.coprime_of_mul_modEq_one i (Nat.ModEq.add_left_cancel' _ hmod)
  let d : RotationAddress := ⟨k, q, hk0, hk, hcop⟩
  have hcyc : IsRotationCycle d S := by
    refine ⟨?_, hcard, ?_, ?_⟩
    · intro x hx
      have hx' := hx
      rw [hS, Finset.mem_image] at hx'
      obtain ⟨j, _, hjx⟩ := hx'
      rw [← hjx]
      exact Nat.mod_lt _ hMpos
    · intro x hx
      exact hmaps x hx
    · intro x hx
      exact hrot x hx
  exact ⟨d, rfl, rfl, rotation_cycle_unique d S hcyc⟩

/-- B6.5: the orbit set determines the address. -/
theorem orbitSet_injective (d e : RotationAddress) (h : orbitSet d = orbitSet e) : d = e := by
  have hq : d.q = e.q := by rw [← orbit_card d, ← orbit_card e, h]
  have hq0 : 0 < d.q := by have := q_at_least_two d; omega
  have hx : wordValue d ⟨0, hq0⟩ ∈ orbitSet d := by
    rw [orbit_set_eq]
    exact Finset.mem_image_of_mem _ (Finset.mem_univ _)
  have hx' : wordValue d ⟨0, hq0⟩ ∈ orbitSet e := h ▸ hx
  have hr0 : rank d (wordValue d ⟨0, hq0⟩) = 0 := rank_word d ⟨0, hq0⟩
  have hrank : ∀ n, rank d n = rank e n := by
    intro n
    unfold rank
    rw [h]
  have hdbl : doubleNum d (wordValue d ⟨0, hq0⟩) = doubleNum e (wordValue d ⟨0, hq0⟩) := by
    generalize wordValue d ⟨0, hq0⟩ = w
    unfold doubleNum modulus
    rw [hq]
  have h1 := rank_step d _ hx
  have h2 := rank_step e _ hx'
  rw [hr0, zero_add, Nat.mod_eq_of_lt d.p_lt_q] at h1
  have hre : rank e (wordValue d ⟨0, hq0⟩) = 0 := by rw [← hrank]; exact hr0
  rw [hre, zero_add, Nat.mod_eq_of_lt e.p_lt_q, ← hdbl, ← hrank, h1] at h2
  cases d
  cases e
  dsimp only at h2 hq
  subst h2
  subst hq
  rfl

/-- B6.6: the rotation numerator equals the number of members in the upper half. -/
theorem rotation_cycle_upper_count (d : RotationAddress) {S : Finset ℕ}
    (h : IsRotationCycle d S) :
    (S.filter (fun x => 2 ^ (d.q - 1) ≤ x)).card = d.p := by
  have hpq := d.p_lt_q
  have hfil : S.filter (fun x => 2 ^ (d.q - 1) ≤ x) =
      S.filter (fun x => d.q - d.p ≤ setRank S x) := by
    apply Finset.filter_congr
    intro x hx
    rw [← rotation_cycle_high_block d h hx]
    unfold topBit
    split_ifs with hh <;> simp [hh]
  rw [hfil]
  have hinj : Set.InjOn (setRank S) (S.filter (fun x => d.q - d.p ≤ setRank S x)) := by
    apply Set.InjOn.mono _ (setRank_injOn S)
    intro x hx
    exact Finset.mem_coe.mpr (Finset.mem_filter.mp (Finset.mem_coe.mp hx)).1
  rw [← Finset.card_image_of_injOn hinj]
  have himg : (S.filter (fun x => d.q - d.p ≤ setRank S x)).image (setRank S) =
      Finset.Ico (d.q - d.p) d.q := by
    ext r
    simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_Ico]
    constructor
    · rintro ⟨x, ⟨hx, hge⟩, rfl⟩
      exact ⟨hge, rank_lt_q d h hx⟩
    · rintro ⟨hge, hlt⟩
      obtain ⟨x, hx, hxr⟩ := setRank_surj S (r := r) (by rw [h.card_eq]; exact hlt)
      exact ⟨x, ⟨hx, by rw [hxr]; exact hge⟩, hxr⟩
  rw [himg, Nat.card_Ico]
  omega

/-- B6.N1 (negative control): the doubling orbit of 3 mod 31 has weight 2 (two members
    in the upper half) but is not an admissible rotation-2/5 cycle. -/
theorem weight_is_not_admissible :
    ({3, 6, 12, 17, 24} : Finset ℕ) = (Finset.range 5).image (fun i => (2 ^ i * 3) % 31) ∧
      (({3, 6, 12, 17, 24} : Finset ℕ).filter (fun x => 16 ≤ x)).card = 2 ∧
        ¬ IsRotationCycle address25 {3, 6, 12, 17, 24} := by
  refine ⟨by decide, by decide, ?_⟩
  intro hc
  exact absurd (hc.rank_step 3 (by decide)) (by decide)

end FVLT.FordBulbV1
