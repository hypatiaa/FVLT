import PairHeight

namespace AtlasPairs
open Finset ArithmeticFunction
open scoped ArithmeticFunction.Moebius
noncomputable section

def actualPairs (N Y : ℕ) : Finset (ℕ × ℕ) :=
  ((Icc 1 N) ×ˢ (Icc 1 N)).filter fun (q,r) =>
    N < 2*q ∧ q < r ∧ (q*r).Coprime 6 ∧ r / q.gcd r ≤ Y

private def scales (N a b : ℕ) := (Ioc (N/(2*a)) (N/b)).filter fun d => d.Coprime 6
private abbrev Triple := (Σ _ : ℕ, Σ _ : ℕ, ℕ)
private def triples (N Y : ℕ) : Finset Triple :=
  (Icc 1 Y).sigma fun b => (rows b).sigma fun a => scales N a b

private def original (t : Triple) : ℕ × ℕ := (t.2.2*t.2.1,t.2.2*t.1)
private def reduced (z : ℕ × ℕ) : Triple :=
  let d := z.1.gcd z.2
  ⟨z.2/d,z.1/d,d⟩

private theorem forward {N Y} {t : Triple} (ht : t ∈ triples N Y) :
    original t ∈ actualPairs N Y ∧ reduced (original t) = t := by
  obtain ⟨b,a,d⟩ := t
  obtain ⟨hb,ha⟩ := mem_sigma.mp ht
  obtain ⟨ha,hd⟩ := mem_sigma.mp ha
  obtain ⟨⟨a1,ab⟩,ba,cab,c6⟩ := (show _ from (by simpa only [rows,mem_filter,mem_Ico] using ha))
  obtain ⟨⟨lo,hi⟩,d6⟩ := (show _ from (by simpa only [scales,mem_filter,mem_Ioc] using hd))
  obtain ⟨b1,bY⟩ := mem_Icc.mp hb
  have d1 : 0 < d := Nat.zero_le _ |>.trans_lt lo
  have lower := (Nat.div_lt_iff_lt_mul (by omega : 0<2*a)).mp lo
  have upper := (Nat.le_div_iff_mul_le b1).mp hi
  have ord := Nat.mul_lt_mul_of_pos_left ab d1
  have gcd : (d*a).gcd (d*b) = d := by rw [Nat.gcd_mul_left,cab.gcd_eq_one,mul_one]
  have dr := Nat.mul_div_cancel_left b d1
  have dq := Nat.mul_div_cancel_left a d1
  constructor
  · change (d*a,d*b) ∈ _
    apply mem_filter.mpr
    refine ⟨mem_product.mpr ⟨mem_Icc.mpr ⟨Nat.mul_pos d1 a1,ord.le.trans upper⟩,
        mem_Icc.mpr ⟨Nat.mul_pos d1 b1,upper⟩⟩,?_,ord,?_,?_⟩
    · simpa [mul_left_comm,mul_comm,mul_assoc] using lower
    · simp only [Nat.coprime_mul_iff_left] at c6 ⊢
      exact ⟨⟨d6,c6.1⟩,d6,c6.2⟩
    · simpa only [gcd,dr] using bY
  · simp only [original,reduced,gcd,dr,dq]

private theorem backward {N Y} {z : ℕ × ℕ} (hz : z ∈ actualPairs N Y) :
    reduced z ∈ triples N Y ∧ original (reduced z) = z := by
  obtain ⟨q,r⟩ := z
  obtain ⟨hp,lower,qr,c6,hY⟩ := mem_filter.mp hz
  obtain ⟨hq,hr⟩ := mem_product.mp hp
  obtain ⟨q1,_⟩ := mem_Icc.mp hq
  obtain ⟨r1,rN⟩ := mem_Icc.mp hr
  let d := q.gcd r
  let a := q/d
  let b := r/d
  have d1 : 0 < d := Nat.gcd_pos_of_pos_left _ q1
  have dq : d*a=q := by rw [mul_comm]; exact Nat.div_mul_cancel (Nat.gcd_dvd_left ..)
  have dr : d*b=r := by rw [mul_comm]; exact Nat.div_mul_cancel (Nat.gcd_dvd_right ..)
  have ab : a<b := Nat.lt_of_mul_lt_mul_left (by simpa only [dq,dr] using qr : d*a<d*b)
  have a1 : 0<a := Nat.pos_of_mul_pos_left (show 0<d*a by rw [dq]; exact q1)
  have b1 : 0<b := a1.trans ab
  have ba : b<2*a := Nat.lt_of_mul_lt_mul_left (show d*b<d*(2*a) by
    rw [dr,show d*(2*a)=2*(d*a) by ring,dq]; exact rN.trans_lt lower)
  have H : (d*a*(d*b)).Coprime 6 := by simpa only [dq,dr] using c6
  simp only [Nat.coprime_mul_iff_left] at H
  constructor
  · apply mem_sigma.mpr
    refine ⟨mem_Icc.mpr ⟨b1,hY⟩,mem_sigma.mpr ⟨mem_filter.mpr ⟨mem_Ico.mpr ⟨a1,ab⟩,ba,
      Nat.coprime_div_gcd_div_gcd d1,Nat.coprime_mul_iff_left.mpr ⟨H.1.2,H.2.2⟩⟩,?_⟩⟩
    apply mem_filter.mpr
    refine ⟨mem_Ioc.mpr ⟨(Nat.div_lt_iff_lt_mul (by omega : 0<2*a)).mpr ?_,
      (Nat.le_div_iff_mul_le b1).mpr (dr.le.trans rN)⟩,H.1.1⟩
    change N < d*(2*a); rw [show d*(2*a)=2*(d*a) by ring,dq]; exact lower
  · change (d*a,d*b) = (q,r); rw [dq,dr]

private theorem sign_weight (d a b : ℕ) :
    (μ (d*a):ℝ)*(μ (d*b):ℝ) =
      if d.Coprime a ∧ d.Coprime b then (μ a:ℝ)*(μ b:ℝ)*(μ d:ℝ)^2 else 0 := by
  by_cases ha : d.Coprime a
  · by_cases hb : d.Coprime b
    · rw [ite_eq_left ⟨ha,hb⟩,isMultiplicative_moebius.map_mul_of_coprime ha,
        isMultiplicative_moebius.map_mul_of_coprime hb]; push_cast; ring
    · have h : ¬Squarefree (d*b) := fun hs => hb (Nat.squarefree_mul_iff.mp hs).1
      simp [hb,moebius_eq_zero_of_not_squarefree h]
  · have h : ¬Squarefree (d*a) := fun hs => ha (Nat.squarefree_mul_iff.mp hs).1
    simp [ha,moebius_eq_zero_of_not_squarefree h]

private theorem prefixSum (N m b : ℕ) :
    count m ((N:ℝ)/b) = ∑ d ∈ Icc 1 (N/b), if d.Coprime m then (μ d:ℝ)^2 else 0 := by
  unfold count; rw [Nat.floor_div_natCast,Nat.floor_natCast,sum_filter]

private theorem cell {N a b : ℕ} (ha : a ∈ rows b) :
    (∑ d ∈ scales N a b, 2*(μ (d*a):ℝ)*(μ (d*b):ℝ)) =
    2*(μ a:ℝ)*(μ b:ℝ)*(count (6*a*b) ((N:ℝ)/b)-count (6*a*b) ((N:ℝ)/(2*a))) := by
  obtain ⟨hi,ba,_,_⟩ := mem_filter.mp ha
  obtain ⟨a1,ab⟩ := mem_Ico.mp hi
  have b1 : 0<b := lt_of_lt_of_le (show 0<a from a1) ab.le
  let l := N/(2*a)
  let u := N/b
  have lu : l ≤ u := Nat.div_le_div_left ba.le b1
  have partition : Icc 1 u = Icc 1 l ∪ Ioc l u := by
    ext d; simp only [mem_Icc,mem_union,mem_Ioc]; have := Nat.zero_le l; omega
  have dis : Disjoint (Icc 1 l) (Ioc l u) := disjoint_left.mpr fun d h h' =>
    (not_lt_of_ge (mem_Icc.mp h).2) (mem_Ioc.mp h').1
  rw [show (2:ℝ)*a=((2*a:ℕ):ℝ) by norm_num,prefixSum,prefixSum]
  change _ = _*((∑ d ∈ Icc 1 u, _)-(∑ d ∈ Icc 1 l, _))
  rw [partition,sum_union dis,add_sub_cancel_left,mul_sum]
  unfold scales; rw [sum_filter]
  apply sum_congr rfl; intro d _
  rw [mul_assoc,sign_weight]
  simp only [Nat.coprime_mul_iff_right]
  split_ifs <;> first | tauto | ring

theorem actual_reindex (N Y : ℕ) :
    (∑ z ∈ actualPairs N Y, 2*(μ z.1:ℝ)*(μ z.2:ℝ)) = lowPairs N Y := by
  let f (t : Triple) := 2*(μ (original t).1:ℝ)*(μ (original t).2:ℝ)
  have swap : (∑ t ∈ triples N Y, f t) = ∑ z ∈ actualPairs N Y, 2*(μ z.1:ℝ)*(μ z.2:ℝ) :=
    sum_bij' (fun t _ => original t) (fun z _ => reduced z)
      (fun _ h => (forward h).1) (fun _ h => (backward h).1)
      (fun _ h => (forward h).2) (fun _ h => (backward h).2)
      (fun _ _ => rfl)
  rw [←swap]; unfold triples; rw [sum_sigma]; unfold lowPairs
  apply sum_congr rfl; intro b _; rw [sum_sigma]; apply sum_congr rfl
  intro a ha; exact cell ha

/-- Original denominators at any height through the integer cube-root cutoff. -/
theorem actual_cube_height_error {e : ℝ} (he : 0 < e) :
    ∃ A : ℝ, 0<A ∧ ∀ (N Y : ℕ), 2*Y ≤ N → Y^3 ≤ N →
    |(∑ z ∈ actualPairs N Y, 2*(μ z.1:ℝ)*(μ z.2:ℝ))-(N:ℝ)*pairCoefficient Y| ≤ A*(N:ℝ)^(1+e) := by
  obtain ⟨K,hK,h⟩ := cube_height_error he
  exact ⟨K,hK,fun N Y h1 h2 => by rw [actual_reindex]; exact h N Y (by exact_mod_cast h1) (by exact_mod_cast h2)⟩
/-- At the exact integer cube-root height, including its endpoint. -/
theorem actual_cube_root_error {e : ℝ} (he : 0 < e) :
    ∃ A : ℝ, 0 < A ∧ ∀ N : ℕ, 2 ≤ N →
      let Y := Nat.nthRoot 3 N
      |(∑ z ∈ actualPairs N Y, 2*(μ z.1:ℝ)*(μ z.2:ℝ))-(N:ℝ)*pairCoefficient Y| ≤ A*(N:ℝ)^(1+e) := by
  obtain ⟨K,hK,h⟩ := actual_cube_height_error he
  refine ⟨K,hK,fun N hN => ?_⟩
  let y := Nat.nthRoot 3 N
  have hc : y^3 ≤ N := Nat.pow_nthRoot_le_iff.mpr (Or.inl (by decide))
  apply h N y _ hc
  by_cases hy : y ≤ 1
  · omega
  · have hp : 2 ≤ y*y := by nlinarith [Nat.mul_le_mul (by omega : 2≤y) (by omega : 2≤y)]
    calc 2*y ≤ (y*y)*y := Nat.mul_le_mul_right _ hp
         _ = y^3 := by ring
         _ ≤ N := hc
end
end AtlasPairs
