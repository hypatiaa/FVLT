# M6 API

McombHistoryV1 exports VERSION, LIMITS, definition, options, derive and fold. Input keys are domain,m,q,orders,step,start. domain INTEGER uses null q/orders/step and a canonical integer start. QUOTIENT uses positive q and a canonical residue start. ATOM uses null q and canonical order/step/start tuples. m is a canonical integer 1..720, independently checked against the source via packet replay.

Options are depth (integer 0..64), nodeLimit (1..2048), cellLimit (1..262144), ell (null or canonical prime string 2..65521). Recurrence operations cap 4000000. Scalar inputs are bounded to 256 bits. Sidecars are at most 16000000 UTF-8 bytes; nested predecessor gates retain their own limits. derive returns separate tree and count statuses. fold(tree,depth) returns endpoint groups with original history IDs; incomplete-depth folds explicitly say DISPLAYED_SUBSET.

McombHistoryPacketV1.construct(binding,controls,options) / replay(bytes). Binding is {kind:CAYLEY|ATOM,bytes:original source packet}. Controls are domain,start. Atom sources support manual M4 and shell-walk M4 packets, replayed before derivation. The packet schema is MCOMB_WALK_HISTORIES_V1. Canonical SHA-256 hashes all fields with exactDigest set to an empty string. Strict parsing refuses duplicate keys. Full recomputation rejects any false word, endpoint, count, truncation status or authority. Old schemas are unchanged.

McombHistoryAdapterV1 exports configure(domain), compute(), follow(), reopen(bytes), cancel(), snapshot(), and state. Worker jobs carry a ticket and bind to a fresh source key. Late and stale responses cannot commit. Edited controls cancel outstanding work and clear export authority. Imports start held; rejected imports clear their binding and cannot be re-applied. Rebinding requires explicit follow. No method changes the host or writes BSD evidence.

M5 additions: McombStructureV1.representativeComparison(input) provides a separately scoped signed-representative comparison. createSearch(input,stepLimit=250000) supports local controlled-budget testing; inspect and packet replay keep the production cap. Legacy default result shapes and values remain unchanged.
