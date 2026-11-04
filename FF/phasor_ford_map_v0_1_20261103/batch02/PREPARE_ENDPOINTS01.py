from pathlib import Path
import re, json, hashlib, shutil
p = Path(__file__).resolve().parent
root = p.parent
attempt = p / 'attempts' / 'Endpoints01'
src = attempt / 'src'
src.mkdir(parents=True, exist_ok=False)
(attempt / 'build').mkdir()
shutil.copyfile(p / 'attempts/Data02/src/FVLTRosetteFordDataV1.lean', src / 'FVLTRosetteFordDataV1.lean')
headers = (root / 'freeze_packet_v0_1/FF3_HEADERS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8')
section = headers.split('-- FVLTRosetteFordEndpointsV1:')[1].split('end FVLT.PhasorFordV1')[0]
items = list(re.finditer(r'^theorem\s+(\w+)', section, re.M))
proofs = [r'''by
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
''',r'''by
  unfold classifyEdge
  split_ifs <;> simp_all
''',r'''by
  by_cases h : x = y
  · subst y
    simp [classifyEdge, fareyAdj, det]
  · simp [classifyEdge, h, fareyAdj]
''',r'''by
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
''',r'''by
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
''',r'''by
  exact classify_tangent_iff (x k.castSucc) (x k.succ)
''',r'''by
  exact ⟨by simp [endpointCertificate, show |det (x k.castSucc) (x k.succ)| = 1 from h],
    adjacent_kissQ _ _ h⟩
''',r'''by
  have hn : |det (x k.castSucc) (x k.succ)| ≠ 1 := h
  simp [endpointCertificate, hn]
''']
assert len(items) == len(proofs) == 8
out = 'import FVLTRosetteFordDataV1\n\nopen FVLT.FareyContactV1 FVLT.FordExactCoordinatesV1\nnamespace FVLT.PhasorFordV1\n\n'
for i, item in enumerate(items):
    end = items[i+1].start() if i+1 < len(items) else len(section)
    header = section[item.start():end].strip()
    out += header + ' := ' + proofs[i] + '\n'
out += 'end FVLT.PhasorFordV1\n'
(src / 'FVLTRosetteFordEndpointsV1.lean').write_text(out, encoding='utf-8')
names = ['FVLT.PhasorFordV1.' + x.group(1) for x in items]
(attempt / 'AuditRosetteFordEndpointsV1.lean').write_text('import FVLTRosetteFordEndpointsV1\n' + ''.join('#print axioms '+n+'\n' for n in names), encoding='utf-8')
sha = lambda f: hashlib.sha256(f.read_bytes()).hexdigest()
sourcehash = {f.name:sha(f) for f in sorted(src.glob('*.lean'))}
c = json.loads((p/'COMPARE_DATA02.json').read_text())
c.update(source_sha256=sourcehash, present_targets=names, axiom_report_targets=names,
         header_comparison='All eight public headers copied verbatim from frozen Endpoints section; bodies appended; no extra public declarations')
(p/'COMPARE_ENDPOINTS01.json').write_text(json.dumps(c,indent=2)+'\n')
print(json.dumps({'source_sha256':sourcehash,'comparison':sha(p/'COMPARE_ENDPOINTS01.json'),'targets':names},indent=2))
