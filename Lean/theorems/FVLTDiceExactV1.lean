import Ruliology.CellularAutomata.Rule30Prize
import Mathlib.Tactic

/-!
# FVLT dice: exact draws, the exact fair spiral pick, and the M = 2 bridge to Rule 30

Formalizes three facts about the FVLT rosette picker, modelled on `fvlt_rosette_picker_v0_2_11.html`
(functions `draw`, `bigBelow`, `divisorsFast`, `spiralWeights`, `spiralPick`, `word`), at saphir's request
(2026-11-07): "Prove m = 2 equivalence and the exactness of the fair spiral pick (P(n) = 1/M given uniform
words) in lean". Author: Claude Opus 5.5 (skeleton seat). v0.1.1 answers the v0.1 fidelity review's flags; v0.1.2 answers the v0.1.1 review (stage2_count names the divisor; mask_exact covers bigBelow's mask).

"Given uniform words" is the modelling assumption: the theorems count accepted words or draws (each equally
likely, draws independent), they do not formalize a probability space.

1. `draw_preimage_card`: the page's rejection draw is exact. A word `w` below `B` is accepted iff
   `w < B - B % M`, and the roll is then `w % M + 1`; every residue has exactly `B / M` accepted preimages.
2. `fair_pick_exact`: the light spiral-first pick. Stage 1 draws `n1` uniformly in `1..M` and `k` uniformly in
   `1..⌊M/n1⌋`; the spiral is `s = k * n1`. Stage 2 picks a divisor `n` of `s` with the page's integer weight
   `L_s / ⌊M/n⌋`, where `L_s` is the lcm of `⌊M/d⌋` over the divisors `d` of `s`. With uniform draws, every
   `n` in `1..M` has probability exactly `1/M`. Stage 2's loop over the ascending divisor list returns divisor
   `n` for exactly `weight M s n` of the `W_s` draws (`selection_count`, `stage2_count`, section 2b), which is
   the weight / total in `stageTwoProb`; the draw of `v` is exact by `draw_preimage_card`, or by `mask_exact` and `below_exact` for `bigBelow`.
3. The M = 2 bridge: for a bit stream `c` packed into 32-bit words most significant bit first (the page's
   decoding of `rule30_center_4194304.bin`), every word is accepted for `M = 2`, and Plain roll `i` made from
   word `i` is even iff `c (32 i + 31)` is black. On the page, roll `i` uses word `i` in a Plain-mode run that
   starts at bit 0 with the naive overlay off (the overlay draws further words per roll; a single-roll sequence
   continues from the current position). So the even count after `n` such rolls equals the number of black bits among
   `c 31, c 63, …, c (32 n - 1)` (`evenCount_eq_strideCount`), and the even share has density 1/2 iff those
   bits do (`even_share_half_iff`). For `c = Rule30Prize.center` this concerns the centre column at positions
   `≡ 31 (mod 32)`; `problem2_iff` restates the kit's `Problem2` in the same form. The page's finite file is
   the start of that column (checked outside Lean: 3,000 bits against a plain simulation, 40 against Wolfram
   Language); the Lean statements are about the whole infinite column. Nothing here proves anything about Rule 30
   itself.

The framework was assembled by Robin Miller; its components are classical results of others.
-/

namespace FVLT.DiceExactV1

open Finset

/-! ## 1. The rejection draw -/

/-- The page's acceptance limit: a word `w < B` is used iff `w < B - B % M`. -/
def limit (B M : ℕ) : ℕ := B - B % M

theorem limit_eq (B M : ℕ) : limit B M = M * (B / M) := by
  unfold limit
  have := Nat.mod_add_div B M
  omega

/-- **Rejection is exact**: among accepted words, every residue `r < M` (roll `r + 1`) has exactly `B / M`
preimages. -/
theorem draw_preimage_card (B M r : ℕ) (hM : 0 < M) (hr : r < M) :
    ((range (limit B M)).filter (fun w => w % M = r)).card = B / M := by
  rw [limit_eq]
  have himg : (range (M * (B / M))).filter (fun w => w % M = r) =
      (range (B / M)).image (fun j => r + M * j) := by
    ext w
    simp only [mem_filter, mem_range, mem_image]
    constructor
    · rintro ⟨hw, hwr⟩
      refine ⟨w / M, ?_, ?_⟩
      · exact (Nat.div_lt_iff_lt_mul hM).2 (by rwa [mul_comm] at hw)
      · have := Nat.mod_add_div w M
        omega
    · rintro ⟨j, hj, rfl⟩
      refine ⟨?_, ?_⟩
      · have h1 : r + M * j < M * (j + 1) := by nlinarith
        have h2 : M * (j + 1) ≤ M * (B / M) := Nat.mul_le_mul_left M hj
        omega
      · rw [Nat.add_mul_mod_self_left]
        exact Nat.mod_eq_of_lt hr
  rw [himg, card_image_of_injective, card_range]
  intro a b hab
  have : M * a = M * b := by simpa using hab
  exact Nat.eq_of_mul_eq_mul_left hM this

/-! ## 2. The fair spiral pick -/

/-- `q M d = ⌊M/d⌋`, the number of spirals through `d` (multiples of `d` up to `M`). -/
def q (M d : ℕ) : ℕ := M / d

/-- `L_s`: the lcm of `q M d` over the divisors `d` of `s` (the page's `Ls`). -/
def Ls (M s : ℕ) : ℕ := s.divisors.lcm (q M)

/-- The page's integer weight of divisor `d` on spiral `s`. -/
def weight (M s d : ℕ) : ℕ := Ls M s / q M d

/-- The page's total weight `W_s`. -/
def total (M s : ℕ) : ℕ := ∑ d ∈ s.divisors, weight M s d

/-- Stage 2: the probability of divisor `n` on spiral `s` (weight / total; `0` if `n` does not divide `s`). -/
def stageTwoProb (M s n : ℕ) : ℚ := if n ∣ s then (weight M s n : ℚ) / (total M s : ℚ) else 0

/-- The full pick: `n1` uniform on `1..M`, `k` uniform on `1..q M n1`, `s = k * n1`, then stage 2. -/
def pickProb (M n : ℕ) : ℚ :=
  ∑ n1 ∈ Ioc 0 M, ∑ k ∈ Ioc 0 (q M n1),
    (1 / (M : ℚ)) * (1 / (q M n1 : ℚ)) * stageTwoProb M (k * n1) n

/-- A remark (the selection itself is section 2b): with cumulative weights, the values `v` that select position `i` form the
interval `[P_i, P_i + w_i)`, which has exactly `w_i` elements. -/
theorem interval_card (P w : ℕ) : (Ico P (P + w)).card = w := by simp

theorem div_bounds {M s d : ℕ} (hs : s ∈ Ioc 0 M) (hd : d ∈ s.divisors) : 0 < d ∧ d ≤ M := by
  rw [Nat.mem_divisors] at hd
  rw [mem_Ioc] at hs
  exact ⟨Nat.pos_of_dvd_of_pos hd.1 hs.1, (Nat.le_of_dvd hs.1 hd.1).trans hs.2⟩

theorem q_pos {M s d : ℕ} (hs : s ∈ Ioc 0 M) (hd : d ∈ s.divisors) : 0 < q M d :=
  Nat.div_pos (div_bounds hs hd).2 (div_bounds hs hd).1

theorem Ls_pos {M s : ℕ} (hs : s ∈ Ioc 0 M) : 0 < Ls M s := by
  unfold Ls
  apply Nat.pos_of_ne_zero
  rw [Ne, Finset.lcm_eq_zero_iff]
  rintro ⟨d, hd, h0⟩
  have := q_pos hs (Finset.mem_coe.1 hd)
  omega

theorem weight_cast {M s d : ℕ} (hs : s ∈ Ioc 0 M) (hd : d ∈ s.divisors) :
    (weight M s d : ℚ) = (Ls M s : ℚ) / (q M d : ℚ) := by
  have hdv : q M d ∣ Ls M s := Finset.dvd_lcm hd
  unfold weight
  rw [Nat.cast_div hdv]
  exact_mod_cast (q_pos hs hd).ne'

theorem total_cast {M s : ℕ} (hs : s ∈ Ioc 0 M) :
    (total M s : ℚ) = (Ls M s : ℚ) * ∑ d ∈ s.divisors, 1 / (q M d : ℚ) := by
  unfold total
  push_cast
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl (fun d hd => ?_)
  rw [weight_cast hs hd, div_eq_mul_one_div]

theorem inv_sum_pos {M s : ℕ} (hs : s ∈ Ioc 0 M) : 0 < ∑ d ∈ s.divisors, 1 / (q M d : ℚ) := by
  apply Finset.sum_pos
  · intro d hd
    have := q_pos hs hd
    positivity
  · exact ⟨s, Nat.mem_divisors_self s (by have := (mem_Ioc.1 hs).1; omega)⟩

/-- Per spiral: P(s) times P(n | s) equals `1 / (M ⌊M/n⌋)` for every divisor `n` of `s`. -/
theorem stage_product {M s n : ℕ} (hs : s ∈ Ioc 0 M) (hn : n ∣ s) :
    (∑ d ∈ s.divisors, 1 / ((M : ℚ) * (q M d : ℚ))) * stageTwoProb M s n
      = 1 / ((M : ℚ) * (q M n : ℚ)) := by
  have hM : (0 : ℚ) < M := by have := (mem_Ioc.1 hs); exact_mod_cast (by omega : 0 < M)
  have hnd : n ∈ s.divisors := Nat.mem_divisors.2 ⟨hn, by have := (mem_Ioc.1 hs).1; omega⟩
  have hqn : (0 : ℚ) < q M n := by exact_mod_cast q_pos hs hnd
  have hL : (0 : ℚ) < Ls M s := by exact_mod_cast Ls_pos hs
  have hS := inv_sum_pos hs
  have hsplit : (∑ d ∈ s.divisors, 1 / ((M : ℚ) * (q M d : ℚ)))
      = (1 / (M : ℚ)) * ∑ d ∈ s.divisors, 1 / (q M d : ℚ) := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl (fun d _ => ?_)
    rw [one_div_mul_one_div]
  unfold stageTwoProb
  simp only [hn, ↓reduceIte]
  rw [hsplit, weight_cast hs hnd, total_cast hs]
  field_simp

/-- Stage 1 reindexed: summing over `k ≤ ⌊M/n1⌋` at `s = k * n1` is summing over the multiples `s ≤ M` of `n1`. -/
theorem inner_reindex (M n1 : ℕ) (hn1 : 0 < n1) (f : ℕ → ℚ) :
    ∑ k ∈ Ioc 0 (q M n1), f (k * n1) = ∑ s ∈ (Ioc 0 M).filter (n1 ∣ ·), f s := by
  have himg : (Ioc 0 M).filter (n1 ∣ ·) = (Ioc 0 (q M n1)).image (fun k => k * n1) := by
    ext s
    simp only [mem_filter, mem_Ioc, mem_image, q]
    constructor
    · rintro ⟨⟨h0, hM⟩, ⟨k, rfl⟩⟩
      refine ⟨k, ⟨?_, ?_⟩, by ring⟩
      · rcases Nat.eq_zero_or_pos k with hk | hk
        · simp [hk] at h0
        · exact hk
      · rw [Nat.le_div_iff_mul_le hn1, mul_comm]
        exact hM
    · rintro ⟨k, ⟨hk0, hkM⟩, rfl⟩
      exact ⟨⟨Nat.mul_pos hk0 hn1, (Nat.le_div_iff_mul_le hn1).1 hkM⟩, ⟨k, by ring⟩⟩
  rw [himg, sum_image]
  intro a _ b _ h
  exact Nat.eq_of_mul_eq_mul_right hn1 h

theorem divisors_eq_filter {M s : ℕ} (hs : s ∈ Ioc 0 M) :
    (Ioc 0 M).filter (· ∣ s) = s.divisors := by
  ext d
  simp only [mem_filter, mem_Ioc, Nat.mem_divisors]
  have := mem_Ioc.1 hs
  constructor
  · rintro ⟨_, hd⟩
    exact ⟨hd, by omega⟩
  · rintro ⟨hd, hs0⟩
    exact ⟨⟨Nat.pos_of_dvd_of_pos hd (by omega), (Nat.le_of_dvd (by omega) hd).trans this.2⟩, hd⟩

/-- **The fair spiral pick is exact**: with uniform draws, every `n` in `1..M` has probability `1/M`. -/
theorem fair_pick_exact (M n : ℕ) (hn : 0 < n) (hnM : n ≤ M) : pickProb M n = 1 / (M : ℚ) := by
  have hM : 0 < M := lt_of_lt_of_le hn hnM
  unfold pickProb
  -- stage 1 as a sum over spirals s, then swap the order of summation
  have h1 : ∀ n1 ∈ Ioc 0 M,
      ∑ k ∈ Ioc 0 (q M n1), (1 / (M : ℚ)) * (1 / (q M n1 : ℚ)) * stageTwoProb M (k * n1) n
        = ∑ s ∈ Ioc 0 M, if n1 ∣ s then (1 / (M : ℚ)) * (1 / (q M n1 : ℚ)) * stageTwoProb M s n else 0 := by
    intro n1 hn1
    rw [inner_reindex M n1 (mem_Ioc.1 hn1).1 (fun s => (1 / (M : ℚ)) * (1 / (q M n1 : ℚ)) * stageTwoProb M s n),
      sum_filter]
  rw [sum_congr rfl h1, sum_comm]
  have h2 : ∀ s ∈ Ioc 0 M,
      (∑ n1 ∈ Ioc 0 M, if n1 ∣ s then (1 / (M : ℚ)) * (1 / (q M n1 : ℚ)) * stageTwoProb M s n else 0)
        = if n ∣ s then 1 / ((M : ℚ) * (q M n : ℚ)) else 0 := by
    intro s hs
    rw [← sum_filter, divisors_eq_filter hs]
    split_ifs with hns
    · rw [← stage_product hs hns, Finset.sum_mul]
      refine sum_congr rfl (fun d _ => ?_)
      rw [one_div_mul_one_div]
    · unfold stageTwoProb
      simp [hns]
  rw [sum_congr rfl h2, ← sum_filter, sum_const, Nat.Ioc_filter_dvd_card_eq_div, nsmul_eq_mul]
  have hq : (0 : ℚ) < q M n := by exact_mod_cast Nat.div_pos hnM hn
  unfold q at hq ⊢
  field_simp

/-! ## 2b. Stage 2's selection rule, formally

The page lists the divisors of `s` in increasing order (`divisorsFast`), draws `v` uniformly in `0..W_s - 1`, and
returns the first divisor whose running weight sum exceeds `v` (`if (v < acc) ...; break`). With prefix sums
`P_i` (the sum of the first `i` weights), the loop returns position `i` iff `v < P_(i+1)` and `v < P_(j+1)` fails
for every `j < i`. `selection_count` shows exactly `w_i` values of `v` return position `i`, and `stage2_count`
instantiates it with the page's weight list, whose sum is `W_s`. So, given a uniform `v`, divisor `n` is returned
with probability `weight n / W_s`, which is `stageTwoProb`. The draw of `v` itself is exact by `draw_preimage_card`
(the page uses `draw(W_s) - 1` when `W_s ≤ 2^30`) or by `below_exact` (`bigBelow`: uniform `k`-bit words, keep
those below `W_s`). -/

/-- Prefix sum `P_i`: the sum of the first `i` weights. -/
def prefixSum (ws : List ℕ) (i : ℕ) : ℕ := (ws.take i).sum

theorem prefixSum_mono (ws : List ℕ) {a b : ℕ} (h : a ≤ b) : prefixSum ws a ≤ prefixSum ws b := by
  unfold prefixSum
  have ht : (ws.take b).take a = ws.take a := by rw [List.take_take, Nat.min_eq_left h]
  calc (ws.take a).sum = ((ws.take b).take a).sum := by rw [ht]
    _ ≤ ((ws.take b).take a).sum + ((ws.take b).drop a).sum := Nat.le_add_right _ _
    _ = (ws.take b).sum := List.sum_take_add_sum_drop _ _

theorem prefixSum_succ (ws : List ℕ) (i : ℕ) (hi : i < ws.length) :
    prefixSum ws (i + 1) = prefixSum ws i + ws[i] := by
  unfold prefixSum
  exact List.sum_take_succ ws i hi

theorem prefixSum_length (ws : List ℕ) : prefixSum ws ws.length = ws.sum := by
  unfold prefixSum
  rw [List.take_of_length_le (le_refl _)]

/-- The page's loop returns position `i` for draw `v` iff `v` lies in `[P_i, P_(i+1))`. -/
theorem loop_returns_iff (ws : List ℕ) (v i : ℕ) :
    (v < prefixSum ws (i + 1) ∧ ∀ j < i, ¬ v < prefixSum ws (j + 1)) ↔
      (prefixSum ws i ≤ v ∧ v < prefixSum ws (i + 1)) := by
  constructor
  · rintro ⟨h1, h2⟩
    refine ⟨?_, h1⟩
    rcases Nat.eq_zero_or_pos i with h0 | hpos
    · subst h0
      simp [prefixSum]
    · have := h2 (i - 1) (by omega)
      rw [Nat.sub_add_cancel hpos] at this
      omega
  · rintro ⟨h1, h2⟩
    refine ⟨h2, fun j hj => ?_⟩
    have := prefixSum_mono ws (show j + 1 ≤ i by omega)
    omega

/-- **Stage 2 is exact**: among the draws `v < Σ ws`, exactly `ws[i]` make the page's loop return position `i`. -/
theorem selection_count (ws : List ℕ) (i : ℕ) (hi : i < ws.length) :
    ((range ws.sum).filter
      (fun v => v < prefixSum ws (i + 1) ∧ ∀ j < i, ¬ v < prefixSum ws (j + 1))).card = ws[i] := by
  have hle : prefixSum ws (i + 1) ≤ ws.sum := by
    rw [← prefixSum_length]
    exact prefixSum_mono ws (by omega)
  have hset : (range ws.sum).filter
      (fun v => v < prefixSum ws (i + 1) ∧ ∀ j < i, ¬ v < prefixSum ws (j + 1)) =
      Ico (prefixSum ws i) (prefixSum ws (i + 1)) := by
    ext v
    simp only [mem_filter, mem_range, mem_Ico]
    rw [loop_returns_iff]
    constructor
    · rintro ⟨_, h⟩
      exact h
    · rintro h
      exact ⟨lt_of_lt_of_le h.2 hle, h⟩
  rw [hset, Nat.card_Ico, prefixSum_succ ws i hi]
  omega

/-- The page's weight list: the divisors of `s` in increasing order, each with its integer weight. -/
def weightList (M s : ℕ) : List ℕ := ((s.divisors).sort (· ≤ ·)).map (weight M s)

theorem weightList_sum (M s : ℕ) : (weightList M s).sum = total M s := by
  unfold weightList total
  rw [Finset.sum_eq_multiset_sum, ← Multiset.sum_coe, ← Multiset.map_coe, Finset.sort_eq]

/-- **Stage 2 for the page's list**: divisor `n` of `s` sits at some position `i` of the ascending list, and
exactly `weight M s n` of the `W_s` equally likely draws make the loop return it. -/
theorem stage2_count (M s n : ℕ) (hn : n ∈ s.divisors) :
    ∃ i, ∃ hi : i < ((s.divisors).sort (· ≤ ·)).length, ((s.divisors).sort (· ≤ ·))[i] = n ∧
      ((range (total M s)).filter (fun v => v < prefixSum (weightList M s) (i + 1) ∧
        ∀ j < i, ¬ v < prefixSum (weightList M s) (j + 1))).card = weight M s n := by
  have hmem : n ∈ (s.divisors).sort (· ≤ ·) := (Finset.mem_sort _).2 hn
  obtain ⟨i, hi, hget⟩ := List.mem_iff_getElem.1 hmem
  have hi' : i < (weightList M s).length := by simpa [weightList] using hi
  have hw : (weightList M s)[i] = weight M s n := by
    simp only [weightList, List.getElem_map, hget]
  refine ⟨i, hi, hget, ?_⟩
  rw [← weightList_sum, selection_count _ i hi', hw]

/-- `bigBelow`'s mask is exact: if `x` is uniform on `0..2^K - 1` (the page's `words` concatenated 32-bit words,
`K = 32 * words`; independent uniform words give a uniform concatenation, the modelling assumption), then
`x AND (2^k - 1)` takes every value `v < 2^k` for exactly `2^K / 2^k` values of `x`, when `k ≤ K`. -/
theorem mask_exact (K k v : ℕ) (hk : k ≤ K) (hv : v < 2 ^ k) :
    ((range (2 ^ K)).filter (fun x => x &&& (2 ^ k - 1) = v)).card = 2 ^ K / 2 ^ k := by
  have hmask : ∀ x : ℕ, x &&& (2 ^ k - 1) = x % 2 ^ k := fun x => Nat.and_two_pow_sub_one_eq_mod x k
  simp only [hmask]
  have hlim : limit (2 ^ K) (2 ^ k) = 2 ^ K := by
    unfold limit
    rw [Nat.mod_eq_zero_of_dvd (Nat.pow_dvd_pow 2 hk), Nat.sub_zero]
  have := draw_preimage_card (2 ^ K) (2 ^ k) v (Nat.two_pow_pos k) hv
  rwa [hlim] at this

/-- `bigBelow` is exact: uniform `K`-bit words, kept only below `X ≤ 2^K`, hit every `v < X` exactly once. -/
theorem below_exact (K X v : ℕ) (hv : v < X) (hX : X ≤ 2 ^ K) :
    ((range (2 ^ K)).filter (fun w => w < X ∧ w = v)).card = 1 := by
  rw [Finset.card_eq_one]
  refine ⟨v, ?_⟩
  ext w
  simp only [mem_filter, mem_range, mem_singleton]
  constructor
  · rintro ⟨_, _, h⟩
    exact h
  · rintro rfl
    exact ⟨by omega, hv, rfl⟩

/-! ## 3. The M = 2 bridge -/

/-- Word `i` of a bit stream, 32 bits, most significant bit first (the page's decoding of the bits file). -/
def word (c : ℕ → Bool) (i : ℕ) : ℕ :=
  ∑ j ∈ range 32, if c (32 * i + j) then 2 ^ (31 - j) else 0

theorem word_lt (c : ℕ → Bool) (i : ℕ) : word c i < 2 ^ 32 := by
  unfold word
  calc (∑ j ∈ range 32, if c (32 * i + j) then 2 ^ (31 - j) else 0)
      ≤ ∑ j ∈ range 32, 2 ^ (31 - j) := sum_le_sum (fun j _ => by split_ifs <;> simp)
    _ < 2 ^ 32 := by simp [Finset.sum_range_succ]

/-- The last bit of word `i` is the stream bit `32 i + 31`. -/
theorem word_mod_two (c : ℕ → Bool) (i : ℕ) :
    word c i % 2 = if c (32 * i + 31) then 1 else 0 := by
  unfold word
  rw [Finset.sum_range_succ]
  have h : 2 ∣ ∑ j ∈ range 31, (if c (32 * i + j) then 2 ^ (31 - j) else 0) := by
    apply Finset.dvd_sum
    intro j hj
    rw [mem_range] at hj
    split_ifs
    · exact dvd_pow_self 2 (by omega)
    · exact dvd_zero 2
  obtain ⟨m, hm⟩ := h
  rw [hm]
  split_ifs <;> omega

/-- For `M = 2` no 32-bit word is rejected. -/
theorem limit_two : limit (2 ^ 32) 2 = 2 ^ 32 := by norm_num [limit]

theorem word_accepted (c : ℕ → Bool) (i : ℕ) : word c i < limit (2 ^ 32) 2 := by
  rw [limit_two]
  exact word_lt c i

/-- The page's Plain-mode roll for `M = 2` from an accepted word. -/
def roll2 (w : ℕ) : ℕ := w % 2 + 1

theorem roll2_even_iff (c : ℕ → Bool) (i : ℕ) : roll2 (word c i) % 2 = 0 ↔ c (32 * i + 31) = true := by
  unfold roll2
  have h := word_mod_two c i
  cases hc : c (32 * i + 31)
  · rw [hc] at h
    simp only [Bool.false_eq_true, ↓reduceIte] at h
    simp only [Bool.false_eq_true, iff_false]
    omega
  · rw [hc] at h
    simp only [↓reduceIte] at h
    simp only [iff_true]
    omega

/-- Even rolls among the first `n` Plain rolls with `M = 2`. -/
def evenCount (c : ℕ → Bool) (n : ℕ) : ℕ := ((range n).filter (fun i => roll2 (word c i) % 2 = 0)).card

/-- Black bits among `c 31, c 63, …, c (32 n - 1)`. -/
def strideCount (c : ℕ → Bool) (n : ℕ) : ℕ := ((range n).filter (fun i => c (32 * i + 31) = true)).card

theorem evenCount_eq_strideCount (c : ℕ → Bool) (n : ℕ) : evenCount c n = strideCount c n := by
  unfold evenCount strideCount
  exact congrArg Finset.card (filter_congr (fun i _ => roll2_even_iff c i))

/-- Density 1/2 in the kit's integer form (`Rule30Prize.Problem2`). -/
def HalfDensity (f : ℕ → ℕ) : Prop :=
  ∀ k : ℕ, 0 < k → ∃ N, ∀ n, N ≤ n → k * (2 * (f n : ℤ) - n).natAbs ≤ n

/-- **The M = 2 equivalence**: the even share of Plain rolls tends to 1/2 iff the stream bits at positions
`≡ 31 (mod 32)` have density 1/2. -/
theorem even_share_half_iff (c : ℕ → Bool) :
    HalfDensity (evenCount c) ↔ HalfDensity (strideCount c) := by
  rw [show evenCount c = strideCount c from funext (evenCount_eq_strideCount c)]

/-- The kit's Problem 2 is `HalfDensity` of the centre column's black count. -/
theorem problem2_iff :
    Ruliology.CellularAutomata.Rule30Prize.Problem2 ↔
      HalfDensity Ruliology.CellularAutomata.Rule30Prize.blackCount := Iff.rfl

/-- The M = 2 equivalence for Rule 30's centre column. -/
theorem rule30_even_share_half_iff :
    HalfDensity (evenCount Ruliology.CellularAutomata.Rule30Prize.center) ↔
      HalfDensity (strideCount Ruliology.CellularAutomata.Rule30Prize.center) :=
  even_share_half_iff _

end FVLT.DiceExactV1
