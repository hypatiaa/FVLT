# Exact spectral register

Let O=offsets(m) be the actual inherited offset list. For odd m=2h+1, O={-h,...,h}. For even m, O={-(m-1),-(m-3),...,m-1}. Tooth labels are retained even if their residues collide. If sigma is the amplitude sign and rho the positive channel magnitude, then

    z_c(s) = sigma*rho*exp(i*pi*t1*s)*exp(i*c*theta), theta=pi*t2*s/N,
    sum_c z_c(s) = sigma*rho*exp(i*pi*t1*s)*K_m(theta),
    K_m(theta) = sum_{c in O} exp(i*c*theta).

These are exact identities for every real s. Float64 values and plotted curves are numerical evaluations, not the identity's evidence. The captured source records sigma, t1, t2, s and N; it does not record rho. The export explicitly says that magnitude is not part of the Cayley source. The sign is preserved separately and also contributes a half-turn to the exact total carrier phase when negative.

Set q=den((t2*s/(2N)) mod 1), using the inherited exact rational reducer. L acts on Z/q by the sum of translations by the listed offsets, with occupancy as integer weight. For the character chi_j(x)=zeta_q^(jx), L chi_j=lambda_j chi_j, with lambda_j=sum_c zeta_q^(jc). The export represents this as an exact cyclotomic sum: root order q plus combined exponent/coefficient terms. It also retains the original offsets and the quotient occupancy weights. A Float64 evaluation is labelled separately. The carrier is not part of L; once q and offsets are fixed it cannot change the spectrum. N can change q.

## Full operator

For odd m=2h+1,

    z^h K_m(z) = (z^m-1)/(z-1).

The zero characters are the common m-th and q-th roots other than 1. Thus nullity(L)=gcd(m,q)-1, including collisions and m=1. For even m,

    z^(m-1) K_m(z) = (z^(2m)-1)/(z^2-1).

Removing the roots with z²=1 gives nullity(L)=gcd(2m,q)-gcd(2,q). These counts use diagonalization by the q characters; they do not use approximate zero thresholds.

## Simple conversion

The inherited collision gate must pass before the operator is labelled a simple graph. With injective teeth, even m has no loop and its simple operator is L. Odd m has one central loop and the simple operator is L-I. L-I can also be inspected as a weighted operator when teeth collide, without a simple-graph label.

For odd m=2h+1>1,

    z^h(K_m-1) = (1+...+z^(h-1))*(1+z^(h+1))
               = ((z^h-1)/(z-1))*(z^(h+1)+1).

The first factor contributes gcd(h,q)-1 roots; the second contributes gcd(2h+2,q)-gcd(h+1,q). Their intersection is the single root -1 exactly when both h and q are even. Therefore

    nullity(L-I) = gcd(h,q)-1 + gcd(2h+2,q)-gcd(h+1,q)-[h and q even]
                = gcd(h,q)+gcd(2h+2,q)-gcd(h+1,q)-gcd(h,q,2).

The runtime uses the latter closed gcd formula. For m=1, K_1-1=0 and nullity is q; this is special-cased. There is no polynomial factorization at runtime.

As a separate explanation/regression witness, the distinct cyclotomic orders are d>1 dividing h, together with d dividing 2h+2 but not h+1. Count phi(d) once when d divides q, regardless of repeated polynomial factors. For example m=5 has a repeated Phi_2; its repeated occurrence does not double the nullity. For m=7,

    z^3(K_7-1)=Phi_3(z)*Phi_8(z),
    nullity(L-I)=2[3 divides q]+4[8 divides q].

For m=9, q=12 the full operator has nullity 2, disproving the prime-only shortcut (m-1)[m divides q] as a general rule. For the seven-channel preset N=4,t1=t2=1, K_7(theta)=1+2cos(theta)+2cos(2theta)+2cos(3theta), theta=pi*s/4 and the carrier is exp(i4theta). Its sine-quotient expression has limiting value 7 at removable singularities. The continuous identity is exact; interpreting it as the spectrum of the fixed finite operator restricts theta to its character samples.

## Evidence scope

These are `EXACT_DERIVED_SPECTRAL` identities and finite character calculations. They imply no elliptic rank, Tate reduction, height, regulator or BSD conclusion. That would require an explicit curve-dependent construction and a further arithmetic theorem. Spectral records are separately exported and never enter the T4 parent or arithmetic evidence chain.

Tests use independently assembled integer adjacency matrices with exact fraction-free row reduction (626 cases), distinct cyclotomic degree counts (4,667 cases), exact character-action coefficient identities, both parity conventions, the collision gate, amplitude sign/carrier independence, and numerical checks of the continuous identity. Numerical checks supplement the polynomial proof and are not its replacement.
