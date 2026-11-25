# Audit H1/H2 repairs before T1

Version 0.3, 2026-09-07. **Builder-verified audit candidate.** The exact model, differential and source record remain the organizing objects. Fable's independently audited v0.2 bytes are preserved; its report and receipt are pinned as provenance for these repairs.

## H1: tame additive Kodaira consistency

Let d=v_p(Delta) on the submitted p-integral model. Under the submitted p-minimality claim, for additive reduction at p>=5:

| Condition | Required d | Required Kodaira label |
|---|---|---|
| v_p(j)>=0 | 2 | II |
| v_p(j)>=0 | 3 | III |
| v_p(j)>=0 | 4 | IV |
| v_p(j)>=0 | 6 | I0* |
| v_p(j)>=0 | 8 | IV* |
| v_p(j)>=0 | 9 | III* |
| v_p(j)>=0 | 10 | II* |
| v_p(j)=-m<0 | 6+m, m>=1 | I_m* |

The tame specialization of the Kodaira classification gives this table. The short-model valuation characterization is supported by [Dokchitser and Dokchitser, Theorem 1 and Proposition 2](https://www.impan.pl/shop/en/publication/transaction/download/product/82291); [Sage's Tate implementation](https://raw.githubusercontent.com/sagemath/sage/develop/src/sage/schemes/elliptic_curves/ell_local_data.py) also supplies the conductor/discriminant relationships for the terminal types. Combining the tame additive exponent f_p=2 with those relationships yields the listed discriminant valuations. In the potentially multiplicative starred branch, the pole order of j determines the index m.

The implementation computes rational valuations exactly. It handles j=0 before valuation evaluation, using the mathematical convention v_p(0)=+infinity; no floating-point infinity is stored or hashed. The rule runs only after the existing bad-prime and c4 reduction checks, and only for additive reports at p>=5. Good reduction, including c4=0, remains on its separate exact certificate path. No tame table is applied to primes 2 or 3.

At p=5, the audit's II* and I0* labels with d=2 now reject. The forged IV* label on y²=x³−75x+875, with d=7 and v_5(j)=-1, also rejects: the consistent label is I1*. Tests additionally cover I2*, I3* and I4*, whose d=8,9,10 coincide with other table rows; checking d alone would miss these distinctions. A nonminimal presentation that has d outside the table or breaks d=6+m also rejects under its submitted minimality claim.

These checks reject necessary-condition failures. A surviving report does not prove minimality, the actual component splitting, or the actual additive Tamagawa number. Its assessment remains `CONSISTENCY_CHECKED_SOURCE_REPORT` and `tamagawaAssessment: NOT_LOCALLY_CERTIFIED`.

## H2: conductor bounds over Q

Require f_2<=8, f_3<=5, and f_p<=2 for p>=5. Also require f_p<=d, using conductor-discriminant divisibility. These constraints are stated in [MIT 18.783 lecture 24, slide 18](https://ocw.mit.edu/courses/18-783-elliptic-curves-fall-2025/mit18_783_f25_lec_s_24.pdf). They apply to this package's Q-domain; they must not be exported unchanged to arbitrary ramified number fields.

The audit's y²=x³−1 report at 2 with f=12 and wild contribution 10 now rejects. The boundary test at 2 uses the exact model `[0,1,0,-13,-21]` of [LMFDB 256.a1](https://www.lmfdb.org/EllipticCurve/Q/256/a/1), with d=15, type III*, f=8 and c_2=2. The checker admits that source report and rejects the coherent f=9, wild=7 forgery. The p=3 boundary uses y²=x³+3: the type-II terminal condition v_3(a6)=1 in Tate's algorithm gives d=f=5 and c_3=1; f=6, wild=4 rejects. Both examples retain source-report status and demonstrate that wild valuations are not checked using the tame table.

The added inequality rejects f=5 on the audit's d=4 model even though 5 is below the universal cap at 2. These gates do not determine the true wild contribution. Full characteristic-specific Tate replay and the complete Ogg identity check remain in the planned production stages.

## Evidence and compatibility

The main packet's structure and five original fixtures are unchanged. The schema's draft annotation advances to 0.3; new semantic checks intentionally reject the recorded forgeries. Good-prime certificates now name verifier 0.3.0 and its exact source hash. Their dedicated reference-schema URI advances too. A v0.2 certificate remains an artifact of its own pinned schema/verifier, and is not silently relabeled as newly verified.

`check-valuation-gates.worker.cjs` supplies 25 new groups. It reproduces all four reported acceptances against the unchanged predecessor and requires new rejections, checks 56 competing tame labels, both wild upper boundaries, exact rational model changes, zero and negative j valuation cases, public schema-first entry and preserved G2 certificates. `valuation-forgery-reproductions.json` holds the complete four input packets for a cold seat. These are builder tests, not an independent second audit.

The ten-suite verification retains all 157 previous groups and adds these 25, for 182 groups. The 84 inherited pair and doubling cases continue to require explicit PASS. The viewer, exact point entry, mcomb links and runtime discovery are inherited unchanged. T1 remains the next construction after these repair gates; no full Tate algorithm, bad-prime certificate or height calculation is claimed here.
