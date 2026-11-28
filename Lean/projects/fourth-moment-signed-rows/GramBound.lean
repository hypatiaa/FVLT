import DivisorPower
open Finset
noncomputable section
namespace FourthMoment

def I (n : ℕ) := Finset.Icc 1 n
def pairs (X : ℕ) := I X ×ˢ I X
def label (i : ℕ × ℕ) := i.1*i.2
def K (k l : ℕ) : ℝ := (k.gcd l : ℝ)^2 / ((k:ℝ)*l)
def harm (N : ℕ) : ℝ := ∑ l ∈ I N, 1/(l:ℝ)
def zsum (s : ℝ) : ℝ := ∑' i : ℕ, 1/(i:ℝ)^s
theorem harm_bound (N : ℕ) {s : ℝ} (hs : 0 < s) :
    harm N ≤ (N:ℝ)^s * zsum (1+s) := by
  have summ := Real.summable_one_div_nat_rpow.mpr (show 1 < 1+s by linarith)
  unfold harm
  calc
    _ ≤ ∑ i ∈ I N, (N:ℝ)^s*(1/(i:ℝ)^(1+s)) := by
      apply sum_le_sum
      intro i hi
      obtain ⟨hp,hl⟩ := mem_Icc.mp hi
      have h : 0 < (i:ℝ) := by exact_mod_cast hp
      rw [Real.rpow_add h, Real.rpow_one]
      have hx := Real.rpow_le_rpow h.le (show (i:ℝ) ≤ N by exact_mod_cast hl) hs.le
      field_simp
      nlinarith
    _ ≤ _ := by
      rw [← mul_sum]
      exact mul_le_mul_of_nonneg_left (summ.sum_le_tsum _ (fun _ _ => by positivity)) (by positivity)

theorem label_mem (X : ℕ) {i} (hi : i ∈ pairs X) : label i ∈ I (X*X) := by
  obtain ⟨a,b⟩ := mem_product.mp hi
  exact mem_Icc.mpr ⟨Nat.mul_pos (mem_Icc.mp a).1 (mem_Icc.mp b).1,
    Nat.mul_le_mul (mem_Icc.mp a).2 (mem_Icc.mp b).2⟩

theorem rowK (k N : ℕ) (hk : 0 < k) :
    ∑ l ∈ I N, K k l ≤ (k.divisors.card:ℝ)*harm N := by
  let f (h l : ℕ) : ℝ := if h ∣ l then (h:ℝ)/l else 0
  have dom (l : ℕ) (hl : l ∈ I N) : K k l ≤ ∑ h ∈ k.divisors, f h l := by
    have hl' := (mem_Icc.mp hl).1
    have hg : k.gcd l ∈ k.divisors := Nat.mem_divisors.mpr ⟨Nat.gcd_dvd_left ..,hk.ne'⟩
    refine le_trans ?_ (single_le_sum (f:=fun h => f h l) (fun h _ => by dsimp [f]; split <;> positivity) hg)
    simp only [f,K,ite_eq_left (Nat.gcd_dvd_right ..)]
    have h1 : (0:ℝ) < k := by exact_mod_cast hk
    have h2 : (0:ℝ) < l := by exact_mod_cast hl'
    have h3 : (k.gcd l:ℝ) ≤ k := by exact_mod_cast Nat.gcd_le_left l hk
    field_simp
    nlinarith [mul_nonneg (Nat.cast_nonneg (k.gcd l) : (0:ℝ) ≤ _) (sub_nonneg.mpr h3)]
  refine (sum_le_sum dom).trans ?_
  rw [sum_comm]
  calc
    _ ≤ ∑ _h ∈ k.divisors, harm N := by
      apply sum_le_sum
      intro h hh
      have hp := Nat.pos_of_mem_divisors hh
      simp only [f,← sum_filter]
      apply sum_le_sum_of_injOn (fun l => l/h)
      · intro i hi j hj eq
        have ha := (mem_filter.mp hi).2
        have hb := (mem_filter.mp hj).2
        simpa [Nat.div_mul_cancel ha, Nat.div_mul_cancel hb] using congrArg (· * h) eq
      · intro i hi
        obtain ⟨l,hl,rfl⟩ := mem_image.mp hi
        obtain ⟨ha,hb⟩ := mem_filter.mp hl
        have hpos := (mem_Icc.mp ha).1
        exact mem_Icc.mpr ⟨Nat.div_pos (Nat.le_of_dvd hpos hb) hp,
          (Nat.div_le_self ..).trans (mem_Icc.mp ha).2⟩
      · intro l hl
        have hd := (mem_filter.mp hl).2
        rw [Nat.cast_div hd (by exact_mod_cast hp.ne' : (h:ℝ) ≠ 0)]
        simp [div_div_eq_mul_div]
      · intros; positivity
    _ = _ := by simp

theorem pairRow (X k : ℕ) (hk : k ∈ I (X*X)) {T : ℝ}
    (ht : ∀ l ∈ I (X*X), (l.divisors.card:ℝ) ≤ T) :
    ∑ i ∈ pairs X, K k (label i) ≤ T^2*harm (X*X) := by
  let N := X*X
  have ht0 : 0 ≤ T := (Nat.cast_nonneg _).trans (ht _ hk)
  rw [← sum_fiberwise_of_maps_to (fun i hi => label_mem X (i:=i) hi) (fun i => K k (label i))]
  calc
    _ ≤ ∑ l ∈ I N, T*K k l := by
      apply sum_le_sum
      intro l hl
      let F := (pairs X).filter (label · = l)
      have hn : l ≠ 0 := (show 0 < l from (mem_Icc.mp hl).1).ne'
      have hcard : F.card ≤ l.divisors.card := by
        apply card_le_card_of_injOn Prod.fst
        · intro i hi
          obtain ⟨_,hx⟩ := mem_filter.mp hi
          exact Nat.mem_divisors.mpr ⟨⟨i.2,hx.symm⟩,hn⟩
        · rintro ⟨a,b⟩ hi ⟨c,d⟩ hj eq
          change a=c at eq
          subst c
          have ha := (mem_Icc.mp (mem_product.mp (mem_filter.mp hi).1).1).1
          have eq' := (mem_filter.mp hi).2.trans (mem_filter.mp hj).2.symm
          exact Prod.ext rfl (Nat.eq_of_mul_eq_mul_left ha eq')
      calc
        _ = ∑ _i ∈ F, K k l := sum_congr rfl fun i hi => by rw [(mem_filter.mp hi).2]
        _ = (F.card:ℝ)*K k l := by simp
        _ ≤ _ := mul_le_mul_of_nonneg_right ((show (F.card:ℝ) ≤ _ by exact_mod_cast hcard).trans (ht l hl)) (by unfold K; positivity)
    _ ≤ _ := by
      rw [← mul_sum, sq, mul_assoc]
      apply mul_le_mul_of_nonneg_left _ ht0
      exact (rowK k N (mem_Icc.mp hk).1).trans (mul_le_mul_of_nonneg_right (ht k hk) (by unfold harm; positivity))

theorem schur {ι : Type*} (S : Finset ι) (w : ι → ℝ) (L : ι → ι → ℝ)
    (hL : ∀ i j, 0 ≤ L i j) (hsym : ∀ i j, L i j = L j i)
    (T : ℝ) (hrow : ∀ i ∈ S, ∑ j ∈ S, L i j ≤ T) :
    ∑ i ∈ S, ∑ j ∈ S, w i*w j*L i j ≤ T * ∑ i ∈ S, (w i)^2 := by
  have bound : ∑ i ∈ S, ∑ j ∈ S, (w i)^2 * L i j ≤ T * ∑ i ∈ S, (w i)^2 := by
    rw [mul_sum]
    apply sum_le_sum
    intro i hi
    rw [← mul_sum,mul_comm T]
    exact mul_le_mul_of_nonneg_left (hrow i hi) (sq_nonneg _)
  have swapped : ∑ i ∈ S, ∑ j ∈ S, (w j)^2 * L i j ≤ T * ∑ i ∈ S, (w i)^2 := by
    rw [sum_comm]
    simpa only [hsym] using bound
  have h : ∑ i ∈ S, ∑ j ∈ S, (w i*w j*L i j + w i*w j*L i j) ≤
      ∑ i ∈ S, ∑ j ∈ S, ((w i)^2*L i j+(w j)^2*L i j) := by
    apply sum_le_sum; intro i _
    apply sum_le_sum; intro j _
    nlinarith [mul_nonneg (sq_nonneg (w i-w j)) (hL i j)]
  simp only [sum_add_distrib] at h
  linarith
end FourthMoment
