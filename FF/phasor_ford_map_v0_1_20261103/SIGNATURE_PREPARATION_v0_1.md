# FF-3 signature preparation v0.1

Status: paperwork only, not a frozen Lean signature file. No proof drafting, numerical checks or builds. Sequencing decision b6e8581597fdc305c3f9b95466cf286e0fc8b9a4df6509c82c8735e43e1d7146 puts FF-2 first. FF-3 builds must wait for FF-2's recorded outcome, then this job's own accepted input/signature/template gates.

The owner read the complete accepted WORK_ORDER_v0_2.md and REVIEW_v0_2.md. The final input packet must pin their complete hashes along with the conditional go, sequencing decision, historical v3.3.1 kernel, current library v20 manifest/checksums/toolchain, exact imported Ford modules, and strict replay checker. The unaudited Lemma 6a is reference material only, never an assumed lemma.

## Data choices to make explicit in the freeze

Lifted data has t1,t2 : Int, s : Rat, n3 : Nat, hn3 : 0<n3, r : Real, hr : r≠0. The address is t2*s/n3 in Rat; the phase address is t1*s minus that address. All casts must be explicit. The circle map ignores amplitude; the real-axis phasor theorem uses its nonzero guard. Integer specialization binds an Int spin explicitly and does not put an integer-parity hypothesis on the general rational-spin law.

P1–P4 retain their exact accepted multiplication identities with positive denominator binders. The signed column parameter u is Int, independent of the separately positive reference spin. The zero-spin/stall case is a named result. Do not change signed abs(u) to u or use unproved division cancellation.

## P5 precise domains and statement contracts

Bind B : Nat, hB : 1≤B. Define

    fareySet B = {x : Rat | 0≤x ∧ x≤1 ∧ x.den≤B}

as an actually finite set through bounded reduced numerator/denominator enumeration, with a bridge to the displayed membership predicate. Define shellEvents B through N : Nat with 2≤N and N≤B+1, rational s with 0≤s≤N, and integral full phase address for t1=t2=1. Its image set records only the Ford addresses s/N; it is deduplicated before sorting.

For an individual shell bind N : Nat, hN : 2≤N, s : Rat, hs0 : 0≤s, hsN : s≤(N:Rat). The contact parametrization is

    phaseAddress 1 1 s N ∈ range (Int.cast : Int → Rat)
      ↔ ∃ m : Nat, m≤N-1 ∧
          s = (m:Rat)*(N:Rat)/((N:Rat)-1).

The forward result should provide exactly the admissible index; the reverse should establish the guard and contact, not just identify a candidate. The resulting Ford address equals m/(N-1). No radius/amplitude-zero event is included.

State shellEventAddresses B hB = fareySet B, then define the strictly increasing ordered list from that same finite set. State consecutive determinant +1 on indices k with k+1<length, using canonical rational numerator and positive denominator. The determinant order is b*c-a*d for increasing a/b<c/d. Repeated raw events at 0 and 1 do not become duplicate list entries. B=0 has no theorem in this scope.

## P6 precise path and edge classification

Bind m : Nat and x : Fin (m+1) → Rat. Edge indices are Fin m, using castSucc and succ to name endpoints without hidden index proofs. For each edge exactly one of the following holds:

1. Tangent: audited fareyAdj holds, and the exact rational kissQ satisfies boundaryCheckQ on both endpoint circles.
2. Stall: the two rational addresses are equal.
3. Break: they differ, are not fareyAdj, and their absolute reduced determinant is at least 2.

The final signature packet must state both exhaustiveness and pairwise exclusion. It must include determinant zero iff address equality, rather than treating that fact as a caption. m=0 is one circle and no edges; it needs no artificial initial-edge hypothesis.

Only tangent edges receive kiss-point certificates. Interior circle k may have adjacent neighbours on either side without those two neighbours being adjacent to one another. No arc, orientation choice, parametrization, continuity, dynamical transfer, inverse recovery from an unlabelled phasor, or kernel promotion is part of P6.

## Job-template preparation

Use a separate bounded nucleus job family, never a build parallel to FF-2. Freeze actual input and declaration bytes, runner/checker hashes, isolated output paths, resource reservation and current library preflight before binding. Retain compile, named axiom reporting and strict all-constant replay as distinct evidence. Any signature change returns to review. The completed discrete result may support an Idea Catalog candidate only after fidelity and mathematical review; historical kernel bytes remain unchanged.
