import GarciaPairs
namespace AtlasPairs
open Finset ArithmeticFunction Filter
open scoped ArithmeticFunction.Moebius ArithmeticFunction.zeta Topology
noncomputable section

private theorem root_eq_one {n : ℕ} (_hn : 0<n) : Nat.floorRoot 2 n = 1 ↔ Squarefree n := by
  constructor
  · intro he a ha
    have h : a ∣ Nat.floorRoot 2 n := Nat.pow_dvd_iff_dvd_floorRoot.mp (by simpa [sq] using ha)
    rw [he] at h
    simpa using h
  · intro hs
    have h : IsUnit (Nat.floorRoot 2 n) := hs _ (by simpa [sq] using (Nat.floorRoot_pow_dvd (n:=2) (a:=n)))
    simpa using h

private theorem divisor_indicator {n H : ℕ} (hn : 0<n) (hH : n < (H+1)^2) :
    (μ n:ℝ)^2 = ∑ h ∈ Icc 1 H, if h^2 ∣ n then (μ h:ℝ) else 0 := by
  let k := Nat.floorRoot 2 n
  have hk : k ≠ 0 := Nat.floorRoot_ne_zero.mpr ⟨by decide,hn.ne'⟩
  have same : ((Icc 1 H).filter (fun h => h^2 ∣ n)) = k.divisors := by
    ext h; rw [Nat.mem_divisors,mem_filter,mem_Icc]
    constructor
    · exact fun ⟨_,d⟩ => ⟨Nat.pow_dvd_iff_dvd_floorRoot.mp d,hk⟩
    · rintro ⟨d,_⟩
      have d' := (Nat.pow_dvd_iff_dvd_floorRoot.mpr d : h^2 ∣ n)
      have := Nat.le_of_dvd hn d'
      have hp := Nat.pos_of_mem_divisors (Nat.mem_divisors.mpr ⟨d,hk⟩)
      exact ⟨⟨hp,by by_contra! Hh; nlinarith [Nat.pow_le_pow_left Hh 2]⟩,d'⟩
  rw [← sum_filter, same]
  have idn := congrArg (fun f : ArithmeticFunction ℤ => f k) moebius_mul_coe_zeta
  change (μ * ζ : ArithmeticFunction ℤ) k = _ at idn
  rw [coe_mul_zeta_apply,one_apply] at idn
  have eq : (μ n)^2 = ∑ h ∈ k.divisors, μ h := by
    rw [idn,moebius_sq]; simp [k,root_eq_one hn]
  exact_mod_cast eq

theorem squarefree_floor_sum {t : ℝ} (ht : 0 ≤ t) :
    count 1 t = ∑ h ∈ Icc 1 ⌊Real.sqrt t⌋₊, (μ h:ℝ)*⌊t/(h:ℝ)^2⌋₊ := by
  let H := ⌊Real.sqrt t⌋₊
  have upper : t < ((H+1:ℕ):ℝ)^2 := by
    have hlt : Real.sqrt t < H+1 := Nat.lt_floor_add_one _
    push_cast; nlinarith [Real.sq_sqrt ht, mul_pos (sub_pos.mpr hlt) (by positivity : 0 < (H:ℝ)+1+Real.sqrt t)]
  unfold count
  rw [filter_true_of_mem (fun n (_ : n ∈ Icc 1 ⌊t⌋₊) => Nat.coprime_one_right n)]
  calc _ = ∑ n ∈ Icc 1 ⌊t⌋₊, ∑ h ∈ Icc 1 H, if h^2 ∣ n then (μ h:ℝ) else 0 := by
          apply sum_congr rfl; intro n hn
          have h := (Nat.le_floor_iff ht).mp (mem_Icc.mp hn).2
          exact divisor_indicator (mem_Icc.mp hn).1 (by exact_mod_cast h.trans_lt upper)
       _ = _ := by
         rw [sum_comm]; apply sum_congr rfl; intro h _
         rw [← sum_filter,sum_const,nsmul_eq_mul,mul_comm]
         congr 1
         have eq : Icc 1 ⌊t⌋₊ = Ioc 0 ⌊t⌋₊ := by ext n; simp; omega
         rw [eq,Nat.Ioc_filter_dvd_card_eq_div,← Nat.floor_div_natCast]; norm_cast

private def term (n : ℕ) : ℝ := (μ n:ℝ)/(n:ℝ)^2

private theorem series_value : HasSum term (6/Real.pi^2) := by
  have hs : 1 < (2:ℂ).re := by norm_num
  have H := (LSeriesSummable_moebius_iff.mpr hs).LSeriesHasSum
  have he := LSeries_one_mul_Lseries_moebius hs
  rw [LSeries_one_eq_riemannZeta hs,riemannZeta_two] at he
  have v : LSeries (fun n => (μ n:ℂ)) 2 = ((6/Real.pi^2:ℝ):ℂ) := by
    push_cast
    apply (eq_div_iff (by exact_mod_cast pow_ne_zero 2 Real.pi_ne_zero)).mpr
    linear_combination 6*he
  rw [LSeriesHasSum,v] at H
  have eq : (fun n => (LSeries.term (fun k => (μ k:ℂ)) 2 n).re) = term := by
    funext n
    rcases eq_or_ne n 0 with rfl|hn
    · simp [term]
    · rw [LSeries.term_of_ne_zero hn]
      simp [term, ← Complex.ofReal_div, ← Complex.ofReal_pow, ← Complex.ofReal_intCast, ← Complex.ofReal_natCast]
  simpa only [eq,Complex.ofReal_re] using Complex.hasSum_re H

private theorem tail_bound (H M : ℕ) (hH : 1 ≤ H) :
    ∑ n ∈ Ioc H M, (1:ℝ)/(n:ℝ)^2 ≤ 1/(H:ℝ) := by
  suffices ∀ k : ℕ, (∑ n ∈ Ioc H (H+k), (1:ℝ)/(n:ℝ)^2) ≤ 1/(H:ℝ)-1/((H+k:ℕ):ℝ) by
    rcases le_or_gt H M with hm|hm
    · obtain ⟨k,rfl⟩ := Nat.exists_eq_add_of_le hm
      exact (this k).trans (sub_le_self _ (by positivity))
    · simp [Ioc_eq_empty_of_le hm.le]
  intro k; induction k with
  | zero => simp
  | succ k ih =>
    rw [← Nat.add_assoc, sum_Ioc_succ_top (by omega)]
    push_cast at ih ⊢
    have p : (0:ℝ)<H := by exact_mod_cast hH
    have small : 1/((H:ℝ)+k+1)^2 ≤ 1/(H+k)-1/(H+k+1) := by field_simp; nlinarith
    linarith

theorem base_error {t : ℝ} (ht : 1 ≤ t) :
    |count 1 t - t*(6/Real.pi^2)| ≤ 3*Real.sqrt t := by
  let H := ⌊Real.sqrt t⌋₊
  have st : 1 ≤ Real.sqrt t := by simpa using Real.sqrt_le_sqrt ht
  have hp : 1 ≤ H := Nat.le_floor (by exact_mod_cast st)
  have hl : (H:ℝ) ≤ Real.sqrt t := Nat.floor_le (Real.sqrt_nonneg _)
  have hlt : Real.sqrt t < (H:ℝ)+1 := Nat.lt_floor_add_one _
  have ht0 : 0 ≤ t := by linarith
  have mup (n : ℕ) : |(μ n:ℝ)| ≤ 1 := by rcases moebius_eq_or n with h|h|h <;> norm_num [h]
  have trunc : |count 1 t - t*∑ n ∈ Icc 1 H,term n| ≤ H := by
    rw [squarefree_floor_sum ht0,mul_sum,← sum_sub_distrib]
    apply (abs_sum_le_sum_abs ..).trans
    calc _ ≤ ∑ _n ∈ Icc 1 H, (1:ℝ) := by
          apply sum_le_sum; intro n _
          rw [show (μ n:ℝ)*⌊t/(n:ℝ)^2⌋₊-t*term n =
            (μ n:ℝ)*(↑⌊t/(n:ℝ)^2⌋₊-t/(n:ℝ)^2) by unfold term; ring,abs_mul]
          apply (mul_le_mul (mup _) _ (abs_nonneg _) zero_le_one).trans_eq (one_mul 1)
          rw [abs_le]; constructor
          · linarith [Nat.lt_floor_add_one (t/(n:ℝ)^2)]
          · linarith [Nat.floor_le (show 0 ≤ t/(n:ℝ)^2 by positivity)]
         _ = _ := by simp
  have convergence : Tendsto (fun M : ℕ => ∑ n ∈ Icc 1 M, term n) atTop (nhds (6/Real.pi^2)) := by
    have h := series_value.tendsto_sum_nat.comp (tendsto_add_atTop_nat 1)
    convert h using 1
    funext M; change _ = ∑ n ∈ range (M+1),term n
    have eq : range (M+1) = insert 0 (Icc 1 M) := by ext i; simp; omega
    rw [eq,sum_insert (by simp)]; simp [term]
  have rest : |6/Real.pi^2-∑ n ∈ Icc 1 H,term n| ≤ 1/(H:ℝ) := by
    apply le_of_tendsto ((convergence.sub_const _).abs)
    filter_upwards [eventually_ge_atTop H] with M hM
    have spl : Icc 1 M = Icc 1 H ∪ Ioc H M := by ext n; simp; omega
    rw [spl,sum_union (by apply disjoint_left.mpr; intro n ha hb; simp at ha hb; omega),add_sub_cancel_left]
    calc _ ≤ ∑ n ∈ Ioc H M, |term n| := abs_sum_le_sum_abs ..
         _ ≤ ∑ n ∈ Ioc H M, 1/(n:ℝ)^2 := by
           apply sum_le_sum; intro n _; rw [term,abs_div,abs_of_nonneg (sq_nonneg (n:ℝ))]; exact div_le_div_of_nonneg_right (mup n) (sq_nonneg _)
         _ ≤ _ := tail_bound H M hp
  have hp' : (0:ℝ) < H := by exact_mod_cast hp
  have tailCost : t*(1/(H:ℝ)) ≤ 2*Real.sqrt t := by
    rw [mul_one_div,div_le_iff₀ hp']
    have h1 : (1:ℝ) ≤ H := by exact_mod_cast hp
    nlinarith [Real.sq_sqrt ht0,mul_nonneg (Real.sqrt_nonneg t)
      (show 0 ≤ 2*(H:ℝ)-Real.sqrt t by linarith)]
  calc _ ≤ |count 1 t - t*∑ n ∈ Icc 1 H,term n| +
        |t*((6/Real.pi^2)-∑ n ∈ Icc 1 H,term n)| := by
          rw [show count 1 t-t*(6/Real.pi^2) = (count 1 t-t*∑ n ∈ Icc 1 H,term n)-
            t*((6/Real.pi^2)-∑ n ∈ Icc 1 H,term n) by ring]; apply abs_sub
       _ ≤ _ := by rw [abs_mul,abs_of_nonneg ht0]; linarith [mul_le_mul_of_nonneg_left rest ht0]
end
end AtlasPairs

