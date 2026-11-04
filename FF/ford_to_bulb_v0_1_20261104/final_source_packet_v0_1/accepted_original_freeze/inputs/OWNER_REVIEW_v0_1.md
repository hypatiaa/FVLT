# FF-4 owner design review v0.1

2026-11-04. **Verdict: ACCEPT WITH CHANGES.** Preserve the complete C1 order statement, using the finite common-word route in `C1_PROOF_ROUTE_v0_1.md`. Defer B6 outside this execution scope. No Lean/Sage build, preregistration or signature freeze was performed in this review.

Reviewed order: `WORK_ORDER_v0_1.md`, SHA-256 `cbfa51a7322e85766605ca4ca7cfbd4a4fb5129ba7f5d48aaeb88a11864393e9`. Reviewed evidence: `SAGE_EVIDENCE_v0_1.md`, SHA-256 `9708a994d4cc6fefdb183dd961088e620161eb3472ef88ffbadf88a37fd08022`. The evidence describes exact finite Sage checks; this review did not rerun them or convert them into proofs.

Robin's direct FF-4 go was relayed firsthand by the root coordination chat. It authorizes proceeding through the review workflow. It does not accept the draft, freeze or runner in advance. After the changes below are incorporated and the controlling review decisions are recorded, do not ask Robin for the same go again. Do not infer that the separately gated B6 is included.

## Required corrections before the statement freeze

1. **Correct the cycle wording.** The two displayed angles are points in the same q-point cycle; two angles do not themselves constitute a q-point orbit for q>2. B2 and B3 should establish exact individual period and common-cycle membership separately.
2. **Make all domains explicit.** Use positive natural p,q with 0<p<q and coprimality as explicit theorem binders or record fields. One-based digits j=1,...,q must become Fin q indices i with j=i+1, and exponent q-1-i. Establish q>=2, M>0, and 0<Nminus<Nplus<M. For the minus digit, prove j*p>=1 before arithmetic with natural subtraction. No endpoint value of Psi is defined at 0 or 1.
3. **State precisely what is mapped.** A reduced Ford *address* is mapped to an exact rational angle pair. A source record (p,q,guards) with a proved canonical rational-address bridge is a suitable primary domain; alternatively use an explicitly partial rational-domain map. Do not claim a map on unlabelled complex points or on arbitrary points of a Ford circle. Call [thetaMinus,thetaPlus] the combinatorial angle interval; it is not itself the complex-plane wake.
4. **Freeze cyclic order, rank and gaps.** Rank counts elements of the distinct orbit set below the canonical representative in [0,M). Prove the orbit has q distinct points before using rank as a cycle coordinate. State rank shift modulo q, including the return edge. Define all q directed cyclic gaps, including the wrap gap M+first-last. B5 identifies the ordered edge Nminus -> Nplus as the unique gap of size one; all other directed gaps are at least two. Do not omit the wrap edge or interpret an unordered pair as two gaps.
5. **Keep full C1 and derive C2.** The attached finite prefix-count/common-denominator derivation resolves the mathematical proof route for all reduced fractions in (0,1). It does not rely on B6 or analytic landing. C2 must explicitly require both endpoint fractions in the domain of Psi and state both strict separations around the mediant's interval. The mediant's canonical reduction comes from FF-1. No proof-time narrowing to bounded denominators or neighbouring inputs is permitted.
6. **Freeze C3's equality case.** Prefer canonical rational x<y with fareyAdj x y and x<z<y: x.den+y.den<=z.den, with equality iff z=mediant x y. If raw pairs are used, put positivity and reducedness of every denominator/numerator pair in explicit binders. The denominator-bound helper used in FF-3 is private: do not treat its mangled name as a public library API. Reprove a private helper here or review an explicit public interface. Equality follows by forcing the two positive unimodular coordinates to be one; it is not supplied merely by adjacent_mediant.
7. **Separate A1's formal algebra from its interpretation.** Freeze the polynomial fixed-point identity, the explicit quadratic multiplier identity, and the primitive-root claim as distinct statements. For the exponential specialization, bind the exact canonical lambda and the p,q guards. If parabolic terminology is retained, define its convention or leave it in cited interpretation. Under Milnor's convention root-of-unity multiplier is parabolic; this is not an error in the draft. However these identities do not formalize parameter rays, their landing, an attracting cycle, or limb geometry. The analytic-exclusion paragraph should explicitly allow the polynomial fixed-point/multiplier facts requested in A1.
8. **Defer B6 explicitly.** It is outside the present deliverables and source inventory. No formal result should silently assume uniqueness to prove rank, order or ray identification. It can receive its own work order/freeze/go later.

## Concrete proof architecture

Use a shared finite mechanical-word layer. For u in {0,...,q-1}, let W(u) be the length-q binary integer whose j-th digit is one iff (u+(j-1)*p mod q)>=q-p. Then Nminus=W(p-1), Nplus=W(p).

Prove the prefix count of this word is floor((u+n*p)/q). For u<v, prefix counts are weakly ordered; coprimality makes n*p mod q range over all residues, giving a strict prefix witness. A first-difference binary-word lemma then proves W(u)<W(v). This provides the sorted enumeration and rank(W(u))=u.

Doubling is cyclic left shift of the length-q word and sends W(u) to W((u+p) mod q). Consequently its rank shift is p; coprimality makes the cycle length exactly q and connects the two distinguished points. This proves B2-B4 without assuming B6. B2 also has a possible independent proof from the number p of one-digits and primitivity of the periodic word, but the rank construction already supplies the needed period fact.

For B1, the two original digit words differ only at positions q-1 and q: their suffixes are 01 and 10. The bijection of nonzero multiplication residues proves that these are the only differing positions. Their integer values differ by 2-1=1.

For B5, W(u) is odd for u<p and even for u>=p. Strict adjacent values within either block therefore differ by at least two. The sole transition is W(p-1)->W(p), whose difference is one by B1. The wrap gap is at least two because 0<W(0) and W(q-1)<M. This avoids a separate analytic shortest-arc argument.

For C1, use the attached full derivation. At L=q*q', all upper-word prefix counts are at most the lower-word prefix counts of the larger fraction, and the total counts are strictly ordered. Compare the finite binary integers at length L, then use the exact repeated-word identity to obtain rational-angle order. This avoids real infinite sums and binary-expansion ambiguity.

Suggested modules: exact domain/digits/angles; generic finite mechanical-word lemmas; cycle/rank/gaps B1-B5; angle order/mediants C1-C3; independent complex parameter algebra A1. These are design groupings, not accepted module names or frozen headers yet. Establish computational definitions separately from noncomputable complex-exponential statements. Use exact Nat/Int/Rat arithmetic for all combinatorial values.

## Feasibility and risk

A1's polynomial identities, B1 and C2 are relatively small once their data are fixed. The substantive reusable work is the floor-increment/prefix-sum layer, finite binary comparison, repetition under a common denominator, and the residue-index sorting proof for B4. C1 is feasible without weakening its domain, but it is not a one-line appeal to the finite evidence. C3 needs its own equality-case proof. Keep these as bounded chunks and preserve failures.

The two discarded digit rules are provenance, not counterexamples to the current rule. The finite confirmations support the intended definitions but cannot discharge universal period, uniqueness, order or denominator statements. This review adds a paper proof route, not a new finite run, Lean result or novelty claim.

## Sources and semantic boundary

[Milnor, Periodic Orbits, External Rays and the Mandelbrot Set](https://www.math.stonybrook.edu/files/dynamics/orm.pdf), Theorem 3.1, treats common landing of the characteristic parameter rays and the associated wake. That is an external analytic result, not a consequence to attribute to the finite Lean model. His introduction uses the root-of-unity multiplier convention for parabolic parameters. A precise main-cardioid specialization/identification with this digit rule must be documented before an external semantic caption claims the displayed pair is that bulb's ray pair.

[Goldberg, Fixed points of polynomial maps. I. Rotation subsets of the circles](https://www.numdam.org/item/ASENS_1992_4_25_6_679_0/) is the 1992 primary reference for rotation subsets. Its complete classification/uniqueness result is not assumed in the proposed combinatorial proof. Bibliographic availability is not a checked theorem-to-definition identification. No novelty claim is made.

## Inputs, governance and next step

I read and hash-matched FF-3's final audit `cf9f59c9faf849a378dcec1b2eca87116861e3119eb064adef11572c8d3e92a3` (#1554) and v23's readiness receipt `827d34c802998cac717f12560faf69754c4864a9640605f6be42fb04f743fdad` (#1556). Those are verified local records, not a new live inspection of the hosts. At FF-4's own freeze verify the then-current latest library, its full checksums/read-only state, toolchain, Mathlib, checker and actual imported source closure. Do not reuse FF-3's v22 binding or its module-whitelisted runner unchanged.

Request a corrected successor of the order incorporating the eight items above, preserving v0.1. Then prepare exact proposed definitions and public headers, a fresh FF-4 runner/template and a closed input packet for manager review. FF-3's all-match-binding and proof-retry policies should be requested explicitly for FF-4, not assumed inherited merely from the phrase 'as for FF-3'. No mathematical build or preregistration occurs before those decisions.

All Lean/Sage compute stays on nucleus over Tailscale, with scout/membrane only as governed backups; none on Neo. Keep G1 excluded. Maintain resource caps, clocks before proof writing/staging, exact jobs posted before launch, standard axiom parsing, all-introduced-constant replay and independent clean rebuild/fidelity review. No viewer edit, kernel edit, commit, release or sync is authorized by this design verdict.

Credit: Robin Miller's observation and instruments; framework assembled by Robin Miller, with classical components of others. The owner supplies this review and finite proof plan. No kernel standing is conferred on the extension.
