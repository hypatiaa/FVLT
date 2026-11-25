# P1 real logarithm enclosure proof

Read U1_PROOF.md for exact model reduction, root isolation, AGM period bounds, dyadic arithmetic and the Taylor/Cauchy real integration primitive. P1 uses those sealed bytes. Its only Float64 operations are display geometry derived from verified endpoints.

Complete the square and depress the cubic, Y^2=X^3+A*X+B, with differential dX/(2Y). The positive primitive real period omega1 and positive-imaginary complementary basis are U1's. The logarithm is considered modulo omega1, with a separate real-component label. O has log 0 and identity component. Exact Y=0 identifies a cubic root by the isolated intervals. For three roots e1>e2>e3 their real-adapted addresses are (1/2,0), (1/2,1/2), (0,1/2), respectively. For a single root the address is (1/2,0). These are analytic half-period identities, not rounded numerical recognition.

## Rectangular case

Let h=e1-e3 and m=(e2-e3)/h. For X>e1, substitution X=e3+h/sin(phi)^2 gives the tail F(phi|m)/sqrt(h), with sin(phi)^2=h/(X-e3). With Y<0 this is the real log; with Y>0 it is omega1 minus that tail. For e3<X<e2, substitution X=e3+(e2-e3)*sin(phi)^2 gives F(phi|m)/sqrt(h), where sin(phi)^2=(X-e3)/(e2-e3). The log equals this integral for Y>0, and omega1 minus it for Y<0. The component is SECOND and adapted beta=1/2. Root separation and exact Y sign decide the branch; unresolved cases refuse.

For s=sin(phi)^2<=1/2, tan(phi)=sqrt(s/(1-s)) and F is the integral of [(1+t^2)(1+(1-m)t^2)]^-1/2 from zero to tan(phi). For s>1/2 use K(m) minus the integral of [(1+t^2)(1-m+t^2)]^-1/2 from zero to cot(phi). Both are bounded quartic integrals on endpoints <=1 in the separated case. Interval endpoints straddling the split still evaluate one valid identity and remain subject to the same bounds.

## Rhombic case

Let r be the unique real root, h=sqrt(3*r^2+A), t^2=(X-r)/h and c=3*r/h. The real-cycle substitution X=r+h*t^2 gives the positive integrand [t^4+c*t^2+1]^-1/2 /sqrt(h). Its reciprocal symmetry identifies the tail from t to infinity with the integral from zero to 1/t. When t>=1 use that bounded tail directly. Otherwise use omega1/2 minus the integral from zero to t. With Y<0 the tail is the log; with Y>0 the log is omega1 minus the tail. Adapted beta is zero and the component is IDENTITY. This covers all negative-discriminant real forms, including the former rotated square.

## Marking and wrapping

Divide the enclosed log by the enclosed positive omega1 to enclose alpha. Keep component and adapted beta independently. If marked basis rows equal M times the adapted basis rows, multiply the address by M^(-transpose), using exact integer coefficients and outward arithmetic. Marked beta need not be zero or one half. Signed selected differentials multiply both the log and basis; the coordinate transport remains explicit.

For each address interval enumerate every integer cell it intersects, including both cells at an exact integer endpoint. Clip to each closed cell, subtract its integer shift, and take all products across the two coordinates. Thus a straddled edge has both representatives; O has four closed-square corner representatives. Never select one side by rounding. Reject excessive width or cell spans.

PT1 supplies exact group operations, subgroup membership/orders, and its infinite-order witness. For order n, multiplying an enclosure by n must contain a lattice point. For a PT1 multiple nP, the difference n*address(P)-address(nP) must contain an integer in each coordinate. These are consistency checks, not arithmetic proofs. A nonzero exact multiple of a PT1 infinite-order witness is labelled with that inherited witness and scalar; this adds no rank claim. An extra exact point without PT1 authority receives no order or rank label.

## Independent checks and display

The Python cross-check uses 100-decimal quadrature directly on the cubic: for the unbounded component substitute X=r+1/t^2, and for the egg substitute X=e3+t^2. It does not use production incomplete-integral formulas. It is a numerical cross-check, not the source of the rigorous bound. Rounded PARI references need interval intersection; exact torsion fractions need exact containment.

The screen shows the actual marked period parallelogram and a flat marked torus with opposite edges identified. Polygon corners are numerical projections of enclosure endpoints; the record endpoints are the rigorous data. Filled dots have a minimum visible size and explicitly do not represent uncertainty. The separate torsion comparison has its own proof and contributes nothing to active-curve arithmetic.
