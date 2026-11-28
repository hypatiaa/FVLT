import Mathlib.NumberTheory.LucasPrimality
import Mathlib.Algebra.Polynomial.Eval.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Nat.ModEq
import Mathlib.Data.Nat.Sqrt
import Mathlib.Tactic

/-!
Formal Verification of Fix B: Exact 3-Prime 59-Bit NTT, Garner CRT,
and Translated Factorial-Block Least-Prime Search (`Nat.minFac`).

Verified against Mathlib 4.35.0 (`rule30_theorem_library/v36`, zero `sorry`,
zero `native_decide`, standard axioms `[propext, Classical.choice, Quot.sound]` only).
-/

namespace PollardStrassenNTT

/-! ### 1. Pure Kernel Binary Modular Exponentiation (Structural Fuel, Zero `native_decide`) -/

def powModFuel (fuel b e m : ℕ) : ℕ :=
  Nat.rec (motive := fun _ => ℕ → ℕ)
    (fun _ => 1 % m)
    (fun _ ih e' =>
      if e' = 0 then 1 % m
      else
        let half := ih (e' / 2)
        let sq := (half * half) % m
        if e' % 2 = 0 then sq else (sq * (b % m)) % m)
    fuel e

def powMod (b e m : ℕ) : ℕ := powModFuel 60 b e m

theorem powModFuel_eq (fuel b e m : ℕ) (hfuel : e < 2 ^ fuel) :
    powModFuel fuel b e m = b ^ e % m := by
  induction fuel generalizing b e with
  | zero =>
    obtain rfl : e = 0 := by omega
    rfl
  | succ fuel ih =>
    have hstep : powModFuel (fuel + 1) b e m =
        if e = 0 then 1 % m
        else
          let half := powModFuel fuel b (e / 2) m
          let sq := (half * half) % m
          if e % 2 = 0 then sq else (sq * (b % m)) % m := rfl
    rw [hstep]
    by_cases he : e = 0
    · simp [he]
    · simp only [he, ↓reduceIte]
      have hlt : e / 2 < 2 ^ fuel := by
        rw [pow_succ'] at hfuel
        omega
      rw [ih b (e / 2) hlt]
      have hsq : (b ^ (e / 2) % m * (b ^ (e / 2) % m)) % m = (b ^ (e / 2) * b ^ (e / 2)) % m :=
        (Nat.mul_mod (b ^ (e / 2)) (b ^ (e / 2)) m).symm
      by_cases he2 : e % 2 = 0
      · simp only [he2, ↓reduceIte]
        rw [hsq, ← pow_add]
        have heq : e / 2 + e / 2 = e := by omega
        rw [heq]
      · simp only [he2, ↓reduceIte]
        rw [hsq, (Nat.mul_mod (b ^ (e / 2) * b ^ (e / 2)) b m).symm, ← pow_add, ← pow_succ]
        have heq : e / 2 + e / 2 + 1 = e := by omega
        rw [heq]

theorem powMod_eq (b e m : ℕ) (he : e < 2 ^ 60) : powMod b e m = b ^ e % m :=
  powModFuel_eq 60 b e m he

lemma zmod_pow_eq_of_powMod {p b e r : ℕ} (he : e < 2 ^ 60) (h : powMod b e p = r) :
    ((b : ZMod p) ^ e) = (r : ZMod p) := by
  have hmod : b ^ e % p = r := (powMod_eq b e p he).symm.trans h
  have hcast : ((b ^ e : ℕ) : ZMod p) = ((b ^ e % p : ℕ) : ZMod p) := by
    have := Nat.div_add_mod (b ^ e) p
    conv_lhs => rw [← this]
    push_cast
    simp
  calc
    ((b : ZMod p) ^ e) = ((b ^ e : ℕ) : ZMod p) := by push_cast; rfl
    _ = ((b ^ e % p : ℕ) : ZMod p) := hcast
    _ = (r : ZMod p) := by rw [hmod]

lemma zmod_pow_ne_one_of_powMod {p b e : ℕ} (r : ℕ) (hp : 1 < p) (he : e < 2 ^ 60)
    (h : powMod b e p = r) (hr1 : r ≠ 1) (hrp : r < p) : ((b : ZMod p) ^ e) ≠ 1 := by
  intro hEq
  rw [zmod_pow_eq_of_powMod he h] at hEq
  have hcast : (r : ZMod p) = ((1 : ℕ) : ZMod p) := by simpa using hEq
  have : NeZero p := ⟨by omega⟩
  have hmod : r % p = 1 % p := (ZMod.natCast_eq_natCast_iff' r 1 p).mp hcast
  rw [Nat.mod_eq_of_lt hrp, Nat.mod_eq_of_lt hp] at hmod
  exact hr1 hmod

theorem prime_and_orderOf_of_lucas {p g : ℕ} (hp : 1 < p) (hpe : p - 1 < 2 ^ 60)
    (ha : powMod g (p - 1) p = 1)
    (hd : ∀ q : ℕ, q.Prime → q ∣ p - 1 → ((g : ZMod p) ^ ((p - 1) / q)) ≠ 1) :
    Nat.Prime p ∧ orderOf (g : ZMod p) = p - 1 := by
  have h1 : ((g : ZMod p) ^ (p - 1)) = 1 := by
    simpa using zmod_pow_eq_of_powMod hpe ha
  have hprime : Nat.Prime p := lucas_primality p (g : ZMod p) h1 hd
  have hord : orderOf (g : ZMod p) = p - 1 :=
    orderOf_eq_of_pow_and_pow_div_prime (Nat.sub_pos_of_lt hp) h1 hd
  exact ⟨hprime, hord⟩

/-! ### 2. Exact 59-Bit NTT Primes, Primitive Roots, and Order-2^k Roots -/

abbrev P1 : ℕ := 576460752034988033
abbrev G1 : ℕ := 3
abbrev P2 : ℕ := 576460750961246209
abbrev G2 : ℕ := 13
abbrev P3 : ℕ := 576460750625701889
abbrev G3 : ℕ := 3

abbrev P1_INV_P2 : ℕ := 432345562684063746
abbrev P1P2_INV_P3 : ℕ := 148232762401386540

private lemma prime_167 : Nat.Prime 167 := by norm_num
private lemma prime_3673 : Nat.Prime 3673 := by norm_num
private lemma prime_389 : Nat.Prime 389 := by norm_num
private lemma prime_151 : Nat.Prime 151 := by norm_num
private lemma prime_331 : Nat.Prime 331 := by norm_num
private lemma prime_29 : Nat.Prime 29 := by norm_num
private lemma prime_43 : Nat.Prime 43 := by norm_num
private lemma prime_113 : Nat.Prime 113 := by norm_num
private lemma prime_127 : Nat.Prime 127 := by norm_num

section LucasPrimes
set_option maxRecDepth 4096

private theorem prime_1226783 : Nat.Prime 1226783 := by
  refine (prime_and_orderOf_of_lucas (p := 1226783) (g := 5) (by norm_num) (by norm_num) rfl ?_).1
  intro q hq hqd
  have hfac : 1226783 - 1 = 2 * 167 * 3673 := by norm_num
  rw [hfac] at hqd
  rcases hq.dvd_mul.mp hqd with h12 | h3673
  · rcases hq.dvd_mul.mp h12 with h2 | h167
    · have := (Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp h2; subst this
      exact zmod_pow_ne_one_of_powMod 1226782 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
    · have := (Nat.prime_dvd_prime_iff_eq hq prime_167).mp h167; subst this
      exact zmod_pow_ne_one_of_powMod 858056 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
  · have := (Nat.prime_dvd_prime_iff_eq hq prime_3673).mp h3673; subst this
    exact zmod_pow_ne_one_of_powMod 752584 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)

private theorem prime_8589934567 : Nat.Prime 8589934567 := by
  refine (prime_and_orderOf_of_lucas (p := 8589934567) (g := 7) (by norm_num) (by norm_num) rfl ?_).1
  intro q hq hqd
  have hfac : 8589934567 - 1 = 2 * 3 ^ 2 * 389 * 1226783 := by norm_num
  rw [hfac] at hqd
  rcases hq.dvd_mul.mp hqd with h123 | hbig
  · rcases hq.dvd_mul.mp h123 with h23 | h389
    · rcases hq.dvd_mul.mp h23 with h2 | h3p
      · have := (Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp h2; subst this
        exact zmod_pow_ne_one_of_powMod 8589934566 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
      · have h3 := hq.dvd_of_dvd_pow h3p
        have := (Nat.prime_dvd_prime_iff_eq hq Nat.prime_three).mp h3; subst this
        exact zmod_pow_ne_one_of_powMod 3439254975 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
    · have := (Nat.prime_dvd_prime_iff_eq hq prime_389).mp h389; subst this
      exact zmod_pow_ne_one_of_powMod 6296271638 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
  · have := (Nat.prime_dvd_prime_iff_eq hq prime_1226783).mp hbig; subst this
    exact zmod_pow_ne_one_of_powMod 5546712929 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)

private theorem prime_2147483647 : Nat.Prime 2147483647 := by
  refine (prime_and_orderOf_of_lucas (p := 2147483647) (g := 7) (by norm_num) (by norm_num) rfl ?_).1
  intro q hq hqd
  have hfac : 2147483647 - 1 = 2 * 3 ^ 2 * 7 * 11 * 31 * 151 * 331 := by norm_num
  rw [hfac] at hqd
  rcases hq.dvd_mul.mp hqd with h1 | h331
  · rcases hq.dvd_mul.mp h1 with h2 | h151
    · rcases hq.dvd_mul.mp h2 with h3 | h31
      · rcases hq.dvd_mul.mp h3 with h4 | h11
        · rcases hq.dvd_mul.mp h4 with h5 | h7
          · rcases hq.dvd_mul.mp h5 with h2d | h3p
            · have := (Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp h2d; subst this
              exact zmod_pow_ne_one_of_powMod 2147483646 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
            · have h3d := hq.dvd_of_dvd_pow h3p
              have := (Nat.prime_dvd_prime_iff_eq hq Nat.prime_three).mp h3d; subst this
              exact zmod_pow_ne_one_of_powMod 1513477735 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
          · have := (Nat.prime_dvd_prime_iff_eq hq (by norm_num : Nat.Prime 7)).mp h7; subst this
            exact zmod_pow_ne_one_of_powMod 1205362885 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
        · have := (Nat.prime_dvd_prime_iff_eq hq (by norm_num : Nat.Prime 11)).mp h11; subst this
          exact zmod_pow_ne_one_of_powMod 1969212174 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
      · have := (Nat.prime_dvd_prime_iff_eq hq (by norm_num : Nat.Prime 31)).mp h31; subst this
        exact zmod_pow_ne_one_of_powMod 512 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
    · have := (Nat.prime_dvd_prime_iff_eq hq prime_151).mp h151; subst this
      exact zmod_pow_ne_one_of_powMod 535044134 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
  · have := (Nat.prime_dvd_prime_iff_eq hq prime_331).mp h331; subst this
    exact zmod_pow_ne_one_of_powMod 1761855083 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)

private theorem prime_715827881 : Nat.Prime 715827881 := by
  refine (prime_and_orderOf_of_lucas (p := 715827881) (g := 3) (by norm_num) (by norm_num) rfl ?_).1
  intro q hq hqd
  have hfac : 715827881 - 1 = 2 ^ 3 * 5 * 29 * 43 * 113 * 127 := by norm_num
  rw [hfac] at hqd
  rcases hq.dvd_mul.mp hqd with h1 | h127
  · rcases hq.dvd_mul.mp h1 with h2 | h113
    · rcases hq.dvd_mul.mp h2 with h3 | h43
      · rcases hq.dvd_mul.mp h3 with h4 | h29
        · rcases hq.dvd_mul.mp h4 with h2p | h5d
          · have h2d := hq.dvd_of_dvd_pow h2p
            have := (Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp h2d; subst this
            exact zmod_pow_ne_one_of_powMod 715827880 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
          · have := (Nat.prime_dvd_prime_iff_eq hq (by norm_num : Nat.Prime 5)).mp h5d; subst this
            exact zmod_pow_ne_one_of_powMod 393640937 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
        · have := (Nat.prime_dvd_prime_iff_eq hq prime_29).mp h29; subst this
          exact zmod_pow_ne_one_of_powMod 625870675 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
      · have := (Nat.prime_dvd_prime_iff_eq hq prime_43).mp h43; subst this
        exact zmod_pow_ne_one_of_powMod 470630449 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
    · have := (Nat.prime_dvd_prime_iff_eq hq prime_113).mp h113; subst this
      exact zmod_pow_ne_one_of_powMod 451431393 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
  · have := (Nat.prime_dvd_prime_iff_eq hq prime_127).mp h127; subst this
    exact zmod_pow_ne_one_of_powMod 72367751 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)

theorem prime_and_orderOf_P1 : Nat.Prime P1 ∧ orderOf (G1 : ZMod P1) = P1 - 1 := by
  refine prime_and_orderOf_of_lucas (p := P1) (g := G1) (by norm_num) (by norm_num) rfl ?_
  intro q hq hqd
  have hfac : P1 - 1 = 2 ^ 28 * 2147483647 := by norm_num
  rw [hfac] at hqd
  rcases hq.dvd_mul.mp hqd with h2p | hbig
  · have h2d := hq.dvd_of_dvd_pow h2p
    have := (Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp h2d; subst this
    exact zmod_pow_ne_one_of_powMod 576460752034988032 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
  · have := (Nat.prime_dvd_prime_iff_eq hq prime_2147483647).mp hbig; subst this
    exact zmod_pow_ne_one_of_powMod 543731939593465800 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)

theorem prime_and_orderOf_P2 : Nat.Prime P2 ∧ orderOf (G2 : ZMod P2) = P2 - 1 := by
  refine prime_and_orderOf_of_lucas (p := P2) (g := G2) (by norm_num) (by norm_num) rfl ?_
  intro q hq hqd
  have hfac : P2 - 1 = 2 ^ 28 * 3 * 715827881 := by norm_num
  rw [hfac] at hqd
  rcases hq.dvd_mul.mp hqd with h23 | hbig
  · rcases hq.dvd_mul.mp h23 with h2p | h3d
    · have h2d := hq.dvd_of_dvd_pow h2p
      have := (Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp h2d; subst this
      exact zmod_pow_ne_one_of_powMod 576460750961246208 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
    · have := (Nat.prime_dvd_prime_iff_eq hq Nat.prime_three).mp h3d; subst this
      exact zmod_pow_ne_one_of_powMod 302491381546841936 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
  · have := (Nat.prime_dvd_prime_iff_eq hq prime_715827881).mp hbig; subst this
    exact zmod_pow_ne_one_of_powMod 411358173701372774 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)

theorem prime_and_orderOf_P3 : Nat.Prime P3 ∧ orderOf (G3 : ZMod P3) = P3 - 1 := by
  refine prime_and_orderOf_of_lucas (p := P3) (g := G3) (by norm_num) (by norm_num) rfl ?_
  intro q hq hqd
  have hfac : P3 - 1 = 2 ^ 26 * 8589934567 := by norm_num
  rw [hfac] at hqd
  rcases hq.dvd_mul.mp hqd with h2p | hbig
  · have h2d := hq.dvd_of_dvd_pow h2p
    have := (Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp h2d; subst this
    exact zmod_pow_ne_one_of_powMod 576460750625701888 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)
  · have := (Nat.prime_dvd_prime_iff_eq hq prime_8589934567).mp hbig; subst this
    exact zmod_pow_ne_one_of_powMod 329967759833428780 (by norm_num) (by norm_num) rfl (by norm_num) (by norm_num)

end LucasPrimes

theorem prime_P1 : Nat.Prime P1 := prime_and_orderOf_P1.1
theorem prime_P2 : Nat.Prime P2 := prime_and_orderOf_P2.1
theorem prime_P3 : Nat.Prime P3 := prime_and_orderOf_P3.1

lemma orderOf_div_2pow {R : Type*} [Monoid R] (g : R) (m k : ℕ)
    (hm_pos : 0 < m) (hord : orderOf g = m) (hdvd : 2 ^ k ∣ m) :
    orderOf (g ^ (m / 2 ^ k)) = 2 ^ k := by
  have hd_pos : 0 < m / 2 ^ k := by
    rcases hdvd with ⟨t, ht⟩
    have ht0 : t ≠ 0 := by
      intro h0
      rw [h0, mul_zero] at ht
      omega
    rw [ht, Nat.mul_div_cancel_left t (pow_pos (by decide : 0 < 2) k)]
    exact Nat.pos_of_ne_zero ht0
  rw [orderOf_pow' g (Nat.ne_of_gt hd_pos), hord]
  have hdvd_d : m / 2 ^ k ∣ m := Nat.div_dvd_of_dvd hdvd
  rw [Nat.gcd_eq_right hdvd_d]
  exact Nat.div_div_self hdvd (Nat.ne_of_gt hm_pos)

theorem ntt_root_order_P1 (k : ℕ) (hk : k ≤ 26) :
    orderOf ((G1 : ZMod P1) ^ ((P1 - 1) / 2 ^ k)) = 2 ^ k := by
  refine orderOf_div_2pow (G1 : ZMod P1) (P1 - 1) k (by norm_num) prime_and_orderOf_P1.2 ?_
  exact dvd_trans (Nat.pow_dvd_pow 2 (by omega : k ≤ 28)) (by norm_num : 2 ^ 28 ∣ P1 - 1)

theorem ntt_root_order_P2 (k : ℕ) (hk : k ≤ 26) :
    orderOf ((G2 : ZMod P2) ^ ((P2 - 1) / 2 ^ k)) = 2 ^ k := by
  refine orderOf_div_2pow (G2 : ZMod P2) (P2 - 1) k (by norm_num) prime_and_orderOf_P2.2 ?_
  exact dvd_trans (Nat.pow_dvd_pow 2 (by omega : k ≤ 28)) (by norm_num : 2 ^ 28 ∣ P2 - 1)

theorem ntt_root_order_P3 (k : ℕ) (hk : k ≤ 26) :
    orderOf ((G3 : ZMod P3) ^ ((P3 - 1) / 2 ^ k)) = 2 ^ k := by
  refine orderOf_div_2pow (G3 : ZMod P3) (P3 - 1) k (by norm_num) prime_and_orderOf_P3.2 ?_
  exact dvd_trans (Nat.pow_dvd_pow 2 hk) (by norm_num : 2 ^ 26 ∣ P3 - 1)

/-! ### 3. 3-Prime Garner CRT Reconstruction & 64-Bit Dynamic Range -/

theorem coprime_P1_P2 : Nat.Coprime P1 P2 := by norm_num
theorem coprime_P1_P3 : Nat.Coprime P1 P3 := by norm_num
theorem coprime_P2_P3 : Nat.Coprime P2 P3 := by norm_num
theorem coprime_P1P2_P3 : Nat.Coprime (P1 * P2) P3 :=
  Nat.Coprime.mul_left coprime_P1_P3 coprime_P2_P3

theorem ntt_dynamic_range_u64 : 2 ^ 26 * (2 ^ 64 - 1) ^ 2 < P1 * P2 * P3 := by norm_num
theorem garner_inv1_spec : (P1 * P1_INV_P2) % P2 = 1 := by norm_num
theorem garner_inv2_spec : ((P1 * P2) * P1P2_INV_P3) % P3 = 1 := by norm_num

def garner3_raw (r1 r2 r3 : ℕ) : ℕ :=
  let v1 := r1
  let v1_p2 := v1 % P2
  let v1_p3 := v1 % P3
  let diff2 := (r2 + P2 - v1_p2) % P2
  let v2 := (diff2 * P1_INV_P2) % P2
  let t12 := ((v2 * (P1 % P3)) % P3 + v1_p3) % P3
  let diff3 := (r3 + P3 - t12) % P3
  let v3 := (diff3 * P1P2_INV_P3) % P3
  v1 + v2 * P1 + v3 * (P1 * P2)

def garner3_mod (r1 r2 r3 n : ℕ) : ℕ :=
  let v1 := r1
  let v1_p2 := v1 % P2
  let v1_p3 := v1 % P3
  let diff2 := (r2 + P2 - v1_p2) % P2
  let v2 := (diff2 * P1_INV_P2) % P2
  let t12 := ((v2 * (P1 % P3)) % P3 + v1_p3) % P3
  let diff3 := (r3 + P3 - t12) % P3
  let v3 := (diff3 * P1P2_INV_P3) % P3
  let p1_n := P1 % n
  let p1p2_n := (p1_n * (P2 % n)) % n
  ((v1 % n) + ((v2 % n) * p1_n) % n + ((v3 % n) * p1p2_n) % n) % n

private lemma mod_add_sub_cancel (a b m : ℕ) (ha : a < m) (hb : b < m) :
    (b + (a + m - b) % m) % m = a := by
  rw [Nat.add_mod, Nat.mod_mod_of_dvd _ (dvd_refl m), ← Nat.add_mod]
  by_cases hba : b ≤ a
  · have heq : b + (a + m - b) = a + 1 * m := by omega
    rw [heq, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt ha]
  · have heq : b + (a + m - b) = a + m := by omega
    rw [heq, Nat.add_mod_right, Nat.mod_eq_of_lt ha]

private lemma garner_step_mod (a b inv p x : ℕ)
    (hinv : (p * inv) % b = 1) (hx : x < b) (ha : a < b) :
    (a + (((x + b - a) % b * inv) % b) * p) % b = x := by
  have h1 : ((((x + b - a) % b * inv) % b) * p) % b = (((x + b - a) % b * inv) * p) % b := by
    rw [Nat.mul_mod, Nat.mod_mod_of_dvd _ (dvd_refl b), ← Nat.mul_mod]
  have h2 : (((x + b - a) % b * inv) * p) % b = ((x + b - a) % b * ((p * inv) % b)) % b := by
    rw [mul_assoc, mul_comm inv p, Nat.mul_mod, Nat.mod_mod_of_dvd _ (dvd_refl b), ← Nat.mul_mod]
  rw [Nat.add_mod a _ b, h1, h2, hinv, mul_one, ← Nat.add_mod]
  exact mod_add_sub_cancel x a b hx ha

private lemma mod_three_sum_eq (v1 v2 v3 p1 p2 n : ℕ) :
    ((v1 % n) + ((v2 % n) * (p1 % n)) % n + ((v3 % n) * ((p1 % n * (p2 % n)) % n)) % n) % n =
    (v1 + v2 * p1 + v3 * (p1 * p2)) % n := by
  have h1 : ((v2 % n) * (p1 % n)) % n = (v2 * p1) % n := (Nat.mul_mod v2 p1 n).symm
  have h2 : ((v3 % n) * ((p1 % n * (p2 % n)) % n)) % n = (v3 * (p1 * p2)) % n := by
    rw [← Nat.mul_mod p1 p2 n, ← Nat.mul_mod v3 (p1 * p2) n]
  rw [h1, h2]
  rw [Nat.add_mod (v1 % n + (v2 * p1) % n) ((v3 * (p1 * p2)) % n) n,
      Nat.mod_mod_of_dvd (v3 * (p1 * p2)) (dvd_refl n)]
  have h3 : (v1 % n + (v2 * p1) % n) % n = (v1 + v2 * p1) % n := (Nat.add_mod v1 (v2 * p1) n).symm
  rw [h3]
  exact (Nat.add_mod (v1 + v2 * p1) (v3 * (p1 * p2)) n).symm

theorem garner3_raw_exact (X : ℕ) (hX : X < P1 * P2 * P3) :
    garner3_raw (X % P1) (X % P2) (X % P3) = X := by
  unfold garner3_raw
  dsimp only
  set v1 := X % P1
  set v2 := ((X % P2 + P2 - v1 % P2) % P2 * P1_INV_P2) % P2
  set u12 := v1 + v2 * P1
  set t12 := ((v2 * (P1 % P3)) % P3 + v1 % P3) % P3
  set v3 := ((X % P3 + P3 - t12) % P3 * P1P2_INV_P3) % P3
  have hv1_lt : v1 < P1 := Nat.mod_lt X (by decide)
  have hv2_lt : v2 < P2 := Nat.mod_lt _ (by decide)
  have hv3_lt : v3 < P3 := Nat.mod_lt _ (by decide)
  have hu12_lt : u12 < P1 * P2 := by
    calc u12 = v1 + v2 * P1 := rfl
      _ < P1 + v2 * P1 := Nat.add_lt_add_right hv1_lt _
      _ = (v2 + 1) * P1 := by ring
      _ ≤ P2 * P1 := Nat.mul_le_mul_right P1 hv2_lt
      _ = P1 * P2 := mul_comm P2 P1
  have hu12_p1 : u12 % P1 = X % P1 := by
    simp [u12, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hv1_lt, v1]
  have hu12_p2 : u12 % P2 = X % P2 := by
    have hsplit : u12 % P2 = (v1 % P2 + v2 * P1) % P2 := by
      change (v1 + v2 * P1) % P2 = (v1 % P2 + v2 * P1) % P2
      rw [Nat.add_mod v1 (v2 * P1) P2, Nat.add_mod (v1 % P2) (v2 * P1) P2,
          Nat.mod_mod_of_dvd v1 (dvd_refl P2)]
    rw [hsplit]
    exact garner_step_mod (v1 % P2) P2 P1_INV_P2 P1 (X % P2) garner_inv1_spec
      (Nat.mod_lt X (by decide)) (Nat.mod_lt v1 (by decide))
  have ht12_eq : t12 = u12 % P3 := by
    change ((v2 * (P1 % P3)) % P3 + v1 % P3) % P3 = (v1 + v2 * P1) % P3
    rw [Nat.mul_mod v2 (P1 % P3) P3, Nat.mod_mod_of_dvd _ (dvd_refl P3), ← Nat.mul_mod]
    rw [← Nat.add_mod (v2 * P1) v1 P3, add_comm (v2 * P1) v1]
  have hy_lt : u12 + v3 * (P1 * P2) < P1 * P2 * P3 := by
    calc u12 + v3 * (P1 * P2)
      _ < P1 * P2 + v3 * (P1 * P2) := Nat.add_lt_add_right hu12_lt _
      _ = (v3 + 1) * (P1 * P2) := by ring
      _ ≤ P3 * (P1 * P2) := Nat.mul_le_mul_right (P1 * P2) hv3_lt
      _ = P1 * P2 * P3 := mul_comm P3 (P1 * P2)
  have hy_p12 : (u12 + v3 * (P1 * P2)) % (P1 * P2) = X % (P1 * P2) := by
    have hmeq : u12 ≡ X [MOD P1 * P2] :=
      (Nat.modEq_and_modEq_iff_modEq_mul coprime_P1_P2).mp ⟨hu12_p1, hu12_p2⟩
    change u12 % (P1 * P2) = X % (P1 * P2) at hmeq
    rw [Nat.mod_eq_of_lt hu12_lt] at hmeq
    rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hu12_lt]
    exact hmeq
  have hy_p3 : (u12 + v3 * (P1 * P2)) % P3 = X % P3 := by
    have ht12_lt : t12 < P3 := by rw [ht12_eq]; exact Nat.mod_lt u12 (by norm_num)
    have hsplit : (u12 + v3 * (P1 * P2)) % P3 = (t12 + v3 * (P1 * P2)) % P3 := by
      rw [Nat.add_mod u12 (v3 * (P1 * P2)) P3, ← ht12_eq, Nat.add_mod t12 (v3 * (P1 * P2)) P3,
          Nat.mod_eq_of_lt ht12_lt]
    rw [hsplit]
    exact garner_step_mod t12 P3 P1P2_INV_P3 (P1 * P2) (X % P3) garner_inv2_spec
      (Nat.mod_lt X (by norm_num)) ht12_lt
  have hy_all : (u12 + v3 * (P1 * P2)) ≡ X [MOD P1 * P2 * P3] :=
    (Nat.modEq_and_modEq_iff_modEq_mul coprime_P1P2_P3).mp ⟨hy_p12, hy_p3⟩
  change (u12 + v3 * (P1 * P2)) % (P1 * P2 * P3) = X % (P1 * P2 * P3) at hy_all
  rw [Nat.mod_eq_of_lt hy_lt, Nat.mod_eq_of_lt hX] at hy_all
  exact hy_all

theorem garner3_mod_exact (X n : ℕ) (hX : X < P1 * P2 * P3) :
    garner3_mod (X % P1) (X % P2) (X % P3) n = X % n := by
  have hraw := garner3_raw_exact X hX
  have hmod : garner3_raw (X % P1) (X % P2) (X % P3) % n = X % n := congrArg (· % n) hraw
  rw [← hmod]
  unfold garner3_raw garner3_mod
  dsimp only
  set v1 := X % P1
  set v2 := ((X % P2 + P2 - v1 % P2) % P2 * P1_INV_P2) % P2
  set t12 := ((v2 * (P1 % P3)) % P3 + v1 % P3) % P3
  set v3 := ((X % P3 + P3 - t12) % P3 * P1P2_INV_P3) % P3
  exact mod_three_sum_eq v1 v2 v3 P1 P2 n

/-! ### 4. Translated Factorial Block Polynomial & Least-Prime-Divisor (`Nat.minFac`) Preservation -/

noncomputable def shiftedBlockPoly (w : ℕ) : Polynomial ℕ :=
  ∏ i ∈ Finset.Icc 1 w, (Polynomial.X + Polynomial.C i)

theorem shiftedBlockPoly_eval (w j : ℕ) :
    (shiftedBlockPoly w).eval (j * w) = ∏ k ∈ Finset.Icc (j * w + 1) ((j + 1) * w), k := by
  unfold shiftedBlockPoly
  rw [Polynomial.eval_prod]
  simp only [Polynomial.eval_add, Polynomial.eval_X, Polynomial.eval_C]
  refine Finset.prod_bij (fun i _ => j * w + i) ?_ ?_ ?_ ?_
  · intro i hi
    simp only [Finset.mem_Icc] at hi ⊢
    constructor
    · omega
    · calc j * w + i ≤ j * w + w := Nat.add_le_add_left hi.2 _
        _ = (j + 1) * w := by ring
  · intro a _ b _ hab
    omega
  · intro k hk
    simp only [Finset.mem_Icc] at hk
    refine ⟨k - j * w, Finset.mem_Icc.mpr ⟨by omega, ?_⟩, by omega⟩
    have hmul : (j + 1) * w = j * w + w := by ring
    omega
  · intro i _
    rfl

def blockProd (n w j : ℕ) : ℕ :=
  ∏ k ∈ Finset.Icc (j * w + 1) (min ((j + 1) * w) (Nat.sqrt n)), k

private lemma dvd_blockProd_of_mem {n w j k : ℕ}
    (hk : k ∈ Finset.Icc (j * w + 1) (min ((j + 1) * w) (Nat.sqrt n))) :
    k ∣ blockProd n w j :=
  Finset.dvd_prod_of_mem _ hk

private lemma blockProd_mem_of_bounds {n w p : ℕ} (hw : 1 ≤ w) (hp1 : 1 ≤ p)
    (hps : p ≤ Nat.sqrt n) :
    p ∈ Finset.Icc (((p - 1) / w) * w + 1) (min (((p - 1) / w + 1) * w) (Nat.sqrt n)) := by
  simp only [Finset.mem_Icc]
  have hrem : ((p - 1) / w) * w + (p - 1) % w = p - 1 := by
    have := Nat.div_add_mod (p - 1) w
    linarith
  have hmod_lt : (p - 1) % w < w := Nat.mod_lt (p - 1) (by omega)
  have hmul : ((p - 1) / w + 1) * w = ((p - 1) / w) * w + w := by ring
  refine ⟨by omega, le_min ?_ hps⟩
  rw [hmul]
  omega

theorem first_noncoprime_in_first_hit_block_eq_minFac {n w j k : ℕ}
    (hn : 2 ≤ n) (hw : 1 ≤ w)
    (hprev : ∀ j' < j, Nat.gcd n (blockProd n w j') = 1)
    (hk_mem : k ∈ Finset.Icc (j * w + 1) (min ((j + 1) * w) (Nat.sqrt n)))
    (hk_gcd : 1 < Nat.gcd n k)
    (hk_least : ∀ m ∈ Finset.Icc (j * w + 1) (k - 1), Nat.gcd n m = 1) :
    k = n.minFac := by
  set p := n.minFac
  have hp_prime : p.Prime := Nat.minFac_prime (by omega)
  have hp_dvd : p ∣ n := Nat.minFac_dvd n
  have hp_ge2 : 2 ≤ p := hp_prime.two_le
  have hk_bounds := Finset.mem_Icc.mp hk_mem
  have hk_le_sqrt : k ≤ Nat.sqrt n := le_trans hk_bounds.2 (min_le_right _ _)
  have hk_pos : 0 < k := by omega
  have hpk : p ≤ k := by
    set q := (Nat.gcd n k).minFac
    have hq_prime : q.Prime := Nat.minFac_prime (by omega)
    have hq_dvd_g : q ∣ Nat.gcd n k := Nat.minFac_dvd (Nat.gcd n k)
    have hq_dvd_n : q ∣ n := dvd_trans hq_dvd_g (Nat.gcd_dvd_left n k)
    have hq_dvd_k : q ∣ k := dvd_trans hq_dvd_g (Nat.gcd_dvd_right n k)
    have hp_le_q : p ≤ q := Nat.minFac_le_of_dvd hq_prime.two_le hq_dvd_n
    have hq_le_k : q ≤ k := Nat.le_of_dvd hk_pos hq_dvd_k
    exact le_trans hp_le_q hq_le_k
  by_contra hne
  have hp_lt_k : p < k := lt_of_le_of_ne hpk (Ne.symm hne)
  have hp_not_in_cur : ¬ (j * w + 1 ≤ p) := by
    intro hle
    have hmem : p ∈ Finset.Icc (j * w + 1) (k - 1) := Finset.mem_Icc.mpr ⟨hle, by omega⟩
    have hg1 : Nat.gcd n p = 1 := hk_least p hmem
    have hpd : p ∣ Nat.gcd n p := Nat.dvd_gcd hp_dvd (dvd_refl p)
    rw [hg1] at hpd
    exact hp_prime.ne_one (Nat.dvd_one.mp hpd)
  have hp_le_jw : p ≤ j * w := by omega
  set j' := (p - 1) / w
  have hj'_lt : j' < j := by
    by_contra hj_ge
    have hge : j ≤ j' := by omega
    have hmul1 : j * w ≤ j' * w := Nat.mul_le_mul_right w hge
    have hdiv_le : j' * w ≤ p - 1 := Nat.div_mul_le_self (p - 1) w
    omega
  have hp_mem : p ∈ Finset.Icc (j' * w + 1) (min ((j' + 1) * w) (Nat.sqrt n)) :=
    blockProd_mem_of_bounds hw (by omega) (le_trans (le_of_lt hp_lt_k) hk_le_sqrt)
  have hp_dvd_bp : p ∣ blockProd n w j' := dvd_blockProd_of_mem hp_mem
  have hp_dvd_gcd : p ∣ Nat.gcd n (blockProd n w j') := Nat.dvd_gcd hp_dvd hp_dvd_bp
  rw [hprev j' hj'_lt] at hp_dvd_gcd
  exact hp_prime.ne_one (Nat.dvd_one.mp hp_dvd_gcd)

theorem prime_of_all_blocks_coprime {n w : ℕ} (hn : 2 ≤ n) (hw : 1 ≤ w)
    (hall : ∀ j, j * w < Nat.sqrt n → Nat.gcd n (blockProd n w j) = 1) :
    Nat.Prime n := by
  by_contra hnot
  set p := n.minFac
  have hp_prime : p.Prime := Nat.minFac_prime (by omega)
  have hp_dvd : p ∣ n := Nat.minFac_dvd n
  have hp_sq : p * p ≤ n := by simpa [sq] using Nat.minFac_sq_le_self (by omega) hnot
  have hp_sqrt : p ≤ Nat.sqrt n := Nat.le_sqrt.mpr hp_sq
  have hp_ge2 : 2 ≤ p := hp_prime.two_le
  set j := (p - 1) / w
  have hjw : j * w < Nat.sqrt n := by
    have h1 : j * w ≤ p - 1 := Nat.div_mul_le_self (p - 1) w
    omega
  have hp_mem : p ∈ Finset.Icc (j * w + 1) (min ((j + 1) * w) (Nat.sqrt n)) :=
    blockProd_mem_of_bounds hw (by omega) hp_sqrt
  have hp_dvd_bp : p ∣ blockProd n w j := dvd_blockProd_of_mem hp_mem
  have hp_dvd_gcd : p ∣ Nat.gcd n (blockProd n w j) := Nat.dvd_gcd hp_dvd hp_dvd_bp
  rw [hall j hjw] at hp_dvd_gcd
  exact hp_prime.ne_one (Nat.dvd_one.mp hp_dvd_gcd)

end PollardStrassenNTT
