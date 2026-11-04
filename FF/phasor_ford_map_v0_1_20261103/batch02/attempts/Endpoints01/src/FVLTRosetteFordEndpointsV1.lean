import FVLTRosetteFordDataV1

open FVLT.FareyContactV1 FVLT.FordExactCoordinatesV1
namespace FVLT.PhasorFordV1

theorem det_zero_iff_address_equal (x y : ℚ) : det x y = 0 ↔ x = y := by
  constructor
  · intro h
    have hcross : (x.num : ℚ) * (y.den : ℚ) = (y.num : ℚ) * (x.den : ℚ) := by
      exact_mod_cast (sub_eq_zero.mp h)
    have hx : (x.den : ℚ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt x.den_pos)
    have hy : (y.den : ℚ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt y.den_pos)
    calc
      x = (x.num : ℚ) / (x.den : ℚ) := (Rat.num_div_den x).symm
      _ = (y.num : ℚ) / (y.den : ℚ) := (div_eq_div_iff hx hy).mpr hcross
      _ = y := Rat.num_div_den y
  · rintro rfl
    simp [det]

theorem classify_stall_iff (x y : ℚ) : classifyEdge x y = .stall ↔ x = y := by
  unfold classifyEdge
  split_ifs <;> simp_all

theorem classify_tangent_iff (x y : ℚ) : classifyEdge x y = .tangent ↔ fareyAdj x y := by
  by_cases h : x = y
  · subst y
    simp [classifyEdge, fareyAdj, det]
  · simp [classifyEdge, h, fareyAdj]

theorem classify_break_iff (x y : ℚ) : classifyEdge x y = .gap ↔ IsBreak x y := by
  by_cases hxy : x = y
  · subst y
    simp [classifyEdge, IsBreak]
  · have hz : det x y ≠ 0 := by
      intro h
      exact hxy ((det_zero_iff_address_equal x y).mp h)
    have ha : 0 < |det x y| := abs_pos.mpr hz
    by_cases h : fareyAdj x y
    · simp [classifyEdge, IsBreak, hxy, h, fareyAdj] at *
    · have hn : |det x y| ≠ 1 := h
      have htwo : 2 ≤ |det x y| := by omega
      simp [classifyEdge, IsBreak, hxy, h, hn, htwo]

theorem path_edge_trichotomy (m : ℕ) (x : Fin (m + 1) → ℚ) (k : Fin m) :
    let u := x k.castSucc
    let v := x k.succ
    (fareyAdj u v ∨ u = v ∨ IsBreak u v) ∧
      ¬(fareyAdj u v ∧ u = v) ∧
      ¬(fareyAdj u v ∧ IsBreak u v) ∧ ¬(u = v ∧ IsBreak u v) := by
  dsimp
  have hself (u : ℚ) : ¬fareyAdj u u := by simp [fareyAdj, det]
  by_cases h : fareyAdj (x k.castSucc) (x k.succ)
  · have hn : x k.castSucc ≠ x k.succ := by
      intro he
      exact hself (x k.succ) (he ▸ h)
    simp [h, hn, IsBreak]
  · by_cases he : x k.castSucc = x k.succ
    · simp [h, he, IsBreak]
    · have hz : det (x k.castSucc) (x k.succ) ≠ 0 := by
        intro hz
        exact he ((det_zero_iff_address_equal _ _).mp hz)
      have ha := abs_pos.mpr hz
      have hn : |det (x k.castSucc) (x k.succ)| ≠ 1 := h
      have ht : 2 ≤ |det (x k.castSucc) (x k.succ)| := by omega
      simp [h, he, IsBreak, ht]

theorem path_kind_tangent_iff (m : ℕ) (x : Fin (m + 1) → ℚ) (k : Fin m) :
    pathEdgeKind m x k = .tangent ↔ fareyAdj (x k.castSucc) (x k.succ) := by
  exact classify_tangent_iff (x k.castSucc) (x k.succ)

theorem tangent_endpoint_certificate
    (m : ℕ) (x : Fin (m + 1) → ℚ) (k : Fin m)
    (h : fareyAdj (x k.castSucc) (x k.succ)) :
    endpointCertificate m x k = some (kissQ (x k.castSucc) (x k.succ)) ∧
      boundaryCheckQ (x k.castSucc) (kissQ (x k.castSucc) (x k.succ)) = true ∧
      boundaryCheckQ (x k.succ) (kissQ (x k.castSucc) (x k.succ)) = true := by
  exact ⟨by simp [endpointCertificate, show |det (x k.castSucc) (x k.succ)| = 1 from h],
    adjacent_kissQ _ _ h⟩

theorem nontangent_no_certificate
    (m : ℕ) (x : Fin (m + 1) → ℚ) (k : Fin m)
    (h : ¬fareyAdj (x k.castSucc) (x k.succ)) : endpointCertificate m x k = none := by
  have hn : |det (x k.castSucc) (x k.succ)| ≠ 1 := h
  simp [endpointCertificate, hn]

end FVLT.PhasorFordV1
