import SquarefreeBase
namespace AtlasPairs
open Finset ArithmeticFunction
open scoped ArithmeticFunction.Moebius
noncomputable section

private def good (s : Finset ℕ) (t : ℝ) :=
  (Icc 1 ⌊t⌋₊).filter fun n => Squarefree n ∧ ∀ p ∈ s, ¬ p ∣ n

private def dens (s : Finset ℕ) : ℝ := 6/Real.pi^2 * ∏ p ∈ s, (p:ℝ)/(p+1)
private def cost (s : Finset ℕ) : ℝ :=
  3*2^s.card*(if 2 ∈ s then 2 else 1)*(if 3 ∈ s then 2 else 1)

private theorem good_count {m : ℕ} (hm : 1 ≤ m) (t : ℝ) :
    count m t = ((good m.primeFactors t).card:ℝ) := by
  classical
  have hf (n : ℕ) : n.Coprime m ↔ ∀ p ∈ m.primeFactors, ¬p ∣ n := by
    rw [Nat.coprime_iff_gcd_eq_one]
    constructor
    · intro h p hp hpn
      have hd := Nat.dvd_gcd hpn (Nat.dvd_of_mem_primeFactors hp)
      rw [h] at hd; exact (Nat.prime_of_mem_primeFactors hp).not_dvd_one hd
    · intro h; by_contra hn
      obtain ⟨p,hp,hd⟩ := Nat.exists_prime_and_dvd hn
      exact h p (Nat.mem_primeFactors.mpr ⟨hp,(Nat.dvd_gcd_iff.mp hd).2,by omega⟩) (Nat.dvd_gcd_iff.mp hd).1
  unfold count good
  rw [sum_filter]
  have h (n : ℕ) : (if n.Coprime m then (μ n:ℝ)^2 else 0) =
      if Squarefree n ∧ ∀ p ∈ m.primeFactors, ¬p ∣ n then (1:ℝ) else 0 := by
    simp only [← hf n]
    have hsq : (μ n:ℝ)^2 = if Squarefree n then 1 else 0 := by
      rw [← Int.cast_pow,moebius_sq]; split_ifs <;> norm_num
    rw [hsq]; split_ifs <;> tauto
  simp_rw [h]
  rw [← sum_filter]; simp

private theorem remove_prime {s : Finset ℕ} {p : ℕ} (hp : p.Prime) (fresh : p ∉ s)
    (pr : ∀ l ∈ s, l.Prime) (t : ℝ) :
    (good s t).card = (good (insert p s) t).card + (good (insert p s) (t/p)).card := by
  classical
  let S := insert p s
  let A := good S t
  let B := good S (t/p)
  have pos : 0 < p := hp.pos
  have part : good s t = A ∪ B.image (fun n => p*n) := by
    ext n
    constructor
    · intro hn
      obtain ⟨hi,hs,ha⟩ := mem_filter.mp hn
      obtain ⟨lo,up⟩ := mem_Icc.mp hi
      by_cases hd : p ∣ n
      · obtain ⟨k,rfl⟩ := hd
        apply mem_union_right; apply mem_image.mpr
        obtain ⟨cop,_,sq⟩ := Nat.squarefree_mul_iff.mp hs
        refine ⟨k,mem_filter.mpr ⟨mem_Icc.mpr ⟨Nat.pos_of_mul_pos_left lo,?_⟩,
          sq,?_⟩,rfl⟩
        · rw [Nat.floor_div_natCast]; exact (Nat.le_div_iff_mul_le pos).mpr (by simpa [mul_comm] using up)
        · intro l hl
          rcases mem_insert.mp hl with rfl|hl
          · exact hp.coprime_iff_not_dvd.mp cop
          · exact fun h => ha l hl (dvd_mul_of_dvd_right h _)
      · exact mem_union_left _ (mem_filter.mpr ⟨hi,hs,by simpa [S,hd] using ha⟩)
    · intro hn
      rcases mem_union.mp hn with ha|hb
      · obtain ⟨hi,hs,hp'⟩ := mem_filter.mp ha
        exact mem_filter.mpr ⟨hi,hs,fun l hl => hp' l (mem_insert_of_mem hl)⟩
      · obtain ⟨k,hk,rfl⟩ := mem_image.mp hb
        obtain ⟨hi,hs,H⟩ := mem_filter.mp hk
        obtain ⟨lo,up⟩ := mem_Icc.mp hi
        have c := hp.coprime_iff_not_dvd.mpr (H p (mem_insert_self ..))
        apply mem_filter.mpr
        refine ⟨mem_Icc.mpr ⟨Nat.mul_pos pos lo,?_⟩,(Nat.squarefree_mul c).mpr ⟨hp.squarefree,hs⟩,?_⟩
        · rw [Nat.floor_div_natCast] at up; simpa [mul_comm] using (Nat.le_div_iff_mul_le pos).mp up
        · intro l hl hd
          rcases (pr l hl).dvd_mul.mp hd with h|h
          · have e := (Nat.prime_dvd_prime_iff_eq (pr l hl) hp).mp h
            exact fresh (e ▸ hl)
          · exact H l (mem_insert_of_mem hl) h
  have disj : Disjoint A (B.image (fun n => p*n)) := by
    apply disjoint_left.mpr
    rintro _ hn hn'
    obtain ⟨k,_,rfl⟩ := mem_image.mp hn'
    exact (mem_filter.mp hn).2.2 p (mem_insert_self ..) (dvd_mul_right ..)
  rw [part,card_union_of_disjoint disj,card_image_of_injective _ (mul_right_injective₀ hp.ne_zero)]

private theorem dens_le (s : Finset ℕ) : 0 ≤ dens s ∧ dens s ≤ 1 := by
  have h : 6/Real.pi^2 ≤ 1 := (div_le_one (sq_pos_of_pos Real.pi_pos)).mpr (by nlinarith [Real.pi_gt_three])
  unfold dens
  have hp : (∏ p ∈ s, (p:ℝ)/(p+1)) ≤ ∏ _p ∈ s, (1:ℝ) :=
    prod_le_prod₀ (fun _ _ => by positivity) (fun p _ => (div_le_one (by positivity)).mpr (by linarith))
  simp only [prod_const_one] at hp
  exact ⟨by positivity, (mul_le_mul_of_nonneg_right h (by positivity)).trans (by simpa using hp)⟩

private theorem cost_ge (s : Finset ℕ) : 1 ≤ cost s := by
  unfold cost; split_ifs <;> nlinarith [one_le_pow₀ (by norm_num : (1:ℝ) ≤ 2) (n:=s.card)]

private theorem tiny (s : Finset ℕ) {t : ℝ} (ht : 0 ≤ t) (ht' : t < 1) :
    |((good s t).card:ℝ)-t*dens s| ≤ cost s*Real.sqrt t := by
  have e : good s t = ∅ := by simp [good,Nat.floor_eq_zero.mpr ht']
  have h := dens_le s
  rw [e]; simp only [card_empty,Nat.cast_zero,zero_sub,abs_neg,abs_mul,abs_of_nonneg ht,abs_of_nonneg h.1]
  calc _ ≤ t*1 := mul_le_mul_of_nonneg_left h.2 ht
       _ ≤ Real.sqrt t := by
         rw [mul_one]; exact (Real.le_sqrt ht ht).mpr (by nlinarith [mul_nonneg ht (sub_nonneg.mpr ht'.le)])
       _ ≤ _ := le_mul_of_one_le_left (Real.sqrt_nonneg _) (cost_ge s)

private theorem product_error (s : Finset ℕ) (prime : ∀ p ∈ s, p.Prime) :
    ∀ t : ℝ, 0 ≤ t → |((good s t).card:ℝ)-t*dens s| ≤ cost s*Real.sqrt t := by
  classical
  induction s using Finset.induction_on with
  | empty =>
    intro t ht
    by_cases H : 1 ≤ t
    · have hc := good_count (m:=1) (by decide) t
      simpa [dens,cost,hc] using (base_error H)
    · exact tiny _ ht (by linarith)
  | @insert p s fresh ih =>
    have hp := prime p (mem_insert_self ..)
    have pr (l) (hl : l ∈ s) := prime l (mem_insert_of_mem hl)
    have old := ih pr
    let S := insert p s
    have pp : (0:ℝ) < p := by exact_mod_cast hp.pos
    have mass : dens s = dens S + dens S/p := by
      dsimp [dens,S]; rw [prod_insert fresh]; field_simp
    let k : ℝ := if p=2 ∨ p=3 then 4 else 2
    have growth : cost S = k*cost s := by
      dsimp [cost,S,k]; rw [card_insert_of_notMem fresh,pow_succ]
      by_cases h2 : p=2
      · subst p; simp [fresh]; ring
      by_cases h3 : p=3
      · subst p; simp [fresh]; ring
      simp [h2,h3,Ne.symm h2,Ne.symm h3]; ring
    have kpos : 0 < k := by unfold k; split_ifs <;> norm_num
    have squeeze : 1+k/Real.sqrt p ≤ k := by
      have sp := Real.sqrt_pos.mpr pp
      suffices hk : k/Real.sqrt p ≤ k-1 by linarith
      apply (div_le_iff₀ sp).mpr
      by_cases h : p=2 ∨ p=3
      · have hlow : (4/3:ℝ) ≤ Real.sqrt p := (Real.le_sqrt (by norm_num) pp.le).mpr (by
          have : (2:ℝ) ≤ p := by exact_mod_cast hp.two_le
          linarith)
        simp [k,h]; linarith
      · have hlow : (2:ℝ) ≤ Real.sqrt p := (Real.le_sqrt (by norm_num) pp.le).mpr (by
          have := hp.two_le; exact_mod_cast (show 2^2 ≤ p by omega))
        simp [k,h]; linarith
    intro t ht
    induction eqj : ⌊t⌋₊ using Nat.strong_induction_on generalizing t with
    | h j rec =>
      by_cases small : t < 1
      · exact tiny _ ht small
      have d : ⌊t/p⌋₊ < j := by
        rw [Nat.floor_div_natCast,eqj]; apply Nat.div_lt_self
        · rw [← eqj]; exact Nat.le_floor (by push_cast; linarith)
        · exact hp.one_lt
      have short := rec _ d (t/p) (div_nonneg ht pp.le) rfl
      have countId : ((good s t).card:ℝ) = (good S t).card + ((good S (t/p)).card:ℝ) := by
        exact_mod_cast remove_prime hp fresh pr t
      have iden : ((good S t).card:ℝ)-t*dens S =
          (((good s t).card:ℝ)-t*dens s) - (((good S (t/p)).card:ℝ)-(t/p)*dens S) := by
        rw [mass,countId]; ring
      change |((good S t).card:ℝ)-t*dens S| ≤ _
      rw [iden]; apply (abs_sub ..).trans
      have sc := add_le_add (old t ht) short
      rw [Real.sqrt_div ht,growth] at sc
      apply sc.trans
      rw [growth]
      have cc := cost_ge s
      calc _ = (1+k/Real.sqrt p)*(cost s*Real.sqrt t) := by ring
           _ ≤ _ := by simpa only [mul_assoc] using mul_le_mul_of_nonneg_right squeeze
                         (mul_nonneg (by linarith) (Real.sqrt_nonneg _))

theorem uniform_squarefree (m : ℕ) (hm : 1 ≤ m) (t : ℝ) (ht : 1 ≤ t) :
    |count m t - t*density m| ≤ 12*(2:ℝ)^m.primeFactors.card*Real.sqrt t := by
  rw [good_count hm]
  apply (product_error m.primeFactors (fun _ => Nat.prime_of_mem_primeFactors) t (by linarith)).trans
  gcongr
  unfold cost; split_ifs <;> nlinarith [pow_pos (by norm_num : 0 < (2:ℝ)) m.primeFactors.card]
end
end AtlasPairs

