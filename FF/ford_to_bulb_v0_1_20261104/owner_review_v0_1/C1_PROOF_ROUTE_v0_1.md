# FF-4 C1: a finite common-word proof route

2026-11-04. Owner design derivation for the full C1 statement. This is a mathematical implementation plan, not a Lean proof or a new computational result. No scope restriction to Farey neighbours is required by this route.

## Target and conventions

Let 0<p<q and 0<p'<q' be coprime natural pairs with p*q'<p'*q. Keep the draft's digit rules for every positive integer j, extending each word periodically:

    plus(p,q,j)  = 1 iff (j*p mod q) >= q-p
    minus(p,q,j) = 1 iff ((j*p-1) mod q) >= q-p.

Bits are natural numbers 0 or 1. Since j>=1 and p>=1, the second formula has no natural-subtraction underflow. The binary word numerator of length q has weight 2^(q-j) at position j. The angle denominator is 2^q-1.

The proposed proof uses only natural/integer arithmetic, finite binary lists, and exact rational division. It does not use parameter-ray landing, real infinite series, irrational rotation theory, uniqueness B6, or an assumed monotonicity theorem.

## 1. Telescoping prefix counts

For n>=0, let Splus(n), Sminus(n) count the ones in positions 1 through n of the corresponding extended words. Prove:

    Splus(p,q,n)  = ((n+1)*p) / q
    Sminus(p,q,n) = ((n+1)*p-1) / q

where / is natural Euclidean division.

For the plus word, the digit at j is exactly

    ((j+1)*p)/q - (j*p)/q.

For the minus word, it is exactly

    ((j+1)*p-1)/q - (j*p-1)/q.

The increments are 0 or 1 because 0<p<q. The initial floors p/q and (p-1)/q are both zero. Establish these facts before telescoping natural subtraction; do not use ring reasoning that silently treats truncated subtraction as integer subtraction.

## 2. Compare all prefix counts

For every n>=0, prove

    Splus(p,q,n) <= Sminus(p',q',n).

Set m=n+1 and k=(m*p)/q. Euclidean division gives k*q<=m*p. From p*q'<p'*q and m>=1:

    k*q*q' <= m*p*q' < m*p'*q.

Cancel q>0, obtaining k*q'<m*p', hence k*q'<=m*p'-1. Since q'>0, divide to get k<=(m*p'-1)/q'. This is the desired prefix inequality. Coprimality is not needed for this particular lemma, although it remains in the map's domain and period theorems.

## 3. A finite strict witness

Take L=q*q'. At the full common length the prefix counts become

    Splus(p,q,L)  = p*q'
    Sminus(p',q',L) = p'*q.

These are strictly ordered by the input cross-product inequality. Thus there is a first prefix length h, with 1<=h<=L, where the counts differ. Before h the counts, and hence each preceding bit, coincide. At h, prefix domination and binary digits force the plus bit to be 0 and the minus bit to be 1.

Let Rplus and Rminus be the length-L binary integer values. The first different bit contributes 2^(L-h) in favour of Rminus. Every possible adverse contribution from the shorter tail is at most 2^(L-h)-1. Therefore Rplus<Rminus. Package this as a general finite binary-word comparison lemma, reusable by the rank proof.

## 4. Return to the original angles

Both extended words have their declared periods q and q' (periodicity here need not yet be minimal). Since L is a common multiple, their repeated-word values satisfy the exact geometric identities

    Rplus*(2^q-1)   = Nplus*(2^L-1)
    Rminus*(2^q'-1) = Nminus'*(2^L-1).

Equivalently, as exact rationals:

    Rplus/(2^L-1)  = thetaPlus(p,q)
    Rminus/(2^L-1) = thetaMinus(p',q').

All three denominators are positive. The strict integer comparison at the common denominator proves

    thetaPlus(p,q) < thetaMinus(p',q').

No infinite-binary-representation ambiguity enters this argument.

## Lean obligations and dependency direction

Freeze generic finite-word definitions and explicit guarded theorem headers before building. Needed private/general lemmas are: one-step floor increments, telescoping prefix sums, periodic repetition of a binary word, the geometric-sum multiplication identity, a first-difference lemma for finite binary words, and positive rational denominator cancellation.

This route is finite and mathematically direct, but the generic list/sum lemmas are substantive formalization work. Successful Lean compilation and replay are still required. If an implementation obstacle appears, preserve the attempt; do not replace C1 by a weaker claim during proof repair.

C2 then follows from full C1 and the two strict inequalities placing a mediant between its input fractions, with FF-1 supplying canonical reduction for Farey neighbours. C3 is an independent denominator-minimality result. Neither C1 nor C2 should depend on the optional B6 uniqueness theorem.
