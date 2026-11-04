# Last FF-3 theorem: implementation plan, not a proof

2026-11-04. The frozen `farey_consecutive_det` statement remains OPEN. Its conclusion is that consecutive strictly increasing entries x,y of `fareyList B` satisfy x.den*y.num - x.num*y.den = 1. This file changes no frozen statement and confers no proof standing.

The set-membership and strict-list bridges are now proved. A narrow filename/source inspection of the current dependencies found no ready Farey-successor theorem; this is not an exhaustive literature or library search. The following classical construction is a candidate route.

1. **Bounded successor construction.** For a reduced x=a/b in [0,1), with b<=B, construct integers c,d with 1<=d<=B, B<b+d, and b*c-a*d=1. Use coprimality of a,b to obtain a solution modulo b, then choose the largest admissible representative d<=B. For x=0 the explicit choice is c=1,d=B. Show c/d lies in [0,1] and is reduced by the existing determinant-one coprimality theorem. This construction still needs a Lean proof.
2. **Unimodular interval denominator bound.** If x=a/b<w=c/d and b*c-a*d=1, any reduced z=e/f strictly between them has positive integer coefficients A=c*f-e*d and C=e*b-a*f. Hence A>=1, C>=1, and A*b+C*d=f by a ring identity. Therefore f>=b+d. This needs its own private Lean lemma with explicit binders and cast/order bridges.
3. **Exclude intervening set members.** Since b+d>B, no member of `fareySet B` lies strictly between x and the constructed successor. Both endpoints are in the set by the proved membership characterization.
4. **Identify the next list entry.** Use strictness of the sorted list and membership-to-index witnesses to show that no set member lies between entries k and k+1. Compare that next entry with the constructed successor in both directions; the denominator bound excludes an earlier member and index consecutivity excludes a later one. Conclude equality and the signed determinant identity.

Keep all helper results private unless an additional public interface is explicitly reviewed. Append the unchanged frozen final header only with a real proof; no placeholder, extra axiom, `native_decide`, finite bound or assumed Lemma 6a. The source must retain all eight currently proved Sweep bodies and the pinned Data/Phase dependencies. Any repair is additive, and every attempt needs its own comparison and exact posted job.

Start under a fresh batch clock before proof writing/staging, with latest library/toolchain hashes, fresh capacity/reservation and an all-match posted binding. Do not reuse closed Batch05. Final acceptance additionally needs integrated verification, independent replay and statement-fidelity review. No further human go is required within the existing authorized FF-3 scope; all established gates still apply.
