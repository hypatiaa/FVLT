# V1 v0.4 trust and transport contract

## Local verifier

`server.cjs` binds `listen(0, '127.0.0.1')`; there is no host or port option. Only `GET /` and `POST /assess` exist. The latter accepts the raw full T4 packet, not a path, command, curve-builder request or bare record. A fixed stdin adapter calls the frozen sibling `assess.cjs`. All arithmetic/schema work caps remain inherited. Additional transport caps are 32 MB input, one active assessment, a 120-second child deadline and 2 MB output. The server and child write no files. `PYTHONDONTWRITEBYTECODE=1` prevents Python cache writes.

Every request must have the exact Host. Assessment additionally requires the exact Origin, JSON content type, per-launch 256-bit bearer token, nonce and context identifier. Rejected requests close their connection, including requests with unread oversized bodies. There is no permissive CORS response, preflight handler, filesystem endpoint or download/install path. Tokens never appear in URLs, logs or exports.

The server signs a literal JSON payload using a fresh ECDSA P-256 key. Its public key arrives with the initial trusted loopback page. The signature binds the launch ID, request nonce, opaque V1 context ID, SHA-256 of raw request bytes and the T4 assessment. The browser checks the signature, all request bindings, certificate ID, canonical packet hash, model/context/normalization/marking identities and pinned mathematical verifier hashes. This detects altered/transplanted responses after the initial page load; it does not defend against replacement of the initial trusted page, malicious local code or a compromised runtime.

The frozen T4 certificate hashes the canonical packet; the response additionally hashes its exact wire bytes. The six panels display the packet hash, certificate ID and hashes of both mathematical verifiers and public gate/bridge files. A local response is not a cold-audit receipt.

## Preparation and source binding

The browser worker bundles literal copies of the existing exact arithmetic modules with a fixed CommonJS registry. Its filesystem shim can only return those literal source bytes; it has no arbitrary module or file access. Its synchronous SHA-256 and assertion shims support untrusted packet generation. They grant no certification. The existing Node/Python public T4 gate replays the whole packet.

V1 preserves either the full linked elliptic packet and its exact source bytes/hash, or the full Cayley packet and capture. Both sources are independently replayed under their inherited contracts before view preparation. The full V1 wrapper is strictly shaped, duplicate keys are rejected, and imported views are rebuilt. A coherently forged T4 packet may only become arithmetic evidence after the public gate accepts it. Spectral data, Cayley coordinates and graph invariants are not T4 parent inputs.

Legacy model transformations and twists become exact five-coefficient records. Legacy scaling direction is inverted explicitly. General model input is mapped to its short plotting presentation with u=1, r=-b2/12, s=-a1/2, t=-(a3+r*a1)/2. For the input-to-final tuple, x=u²x'+r and y=u³y'+su²x'+t; pullback of the target model differential is u times the input model differential. The selected multiplier becomes c/u, retaining its sign. Every point visit maps through both exact coordinate changes; no deduplication occurs.

The basis matrix M has determinant one. Period bases transform by M and the exact differential multiplier; phase coordinates transform by inverse transpose. Numerical periods are kept separate from the exact transport identities and T4's Néron normalization certificate. Unsupported period displays do not invalidate exact arithmetic.

## Context lifecycle

All six bindings clear synchronously on registered input changes and explicit switches; asynchronous source changes are observed through inherited events and a 250 ms state check. A context epoch, source signature, request nonce and signed response binding prevent old jobs from committing. Held source is explicitly labelled. Active assessments are replayed about every eight seconds; a stopped server clears all six assessments when this health replay fails. `file://` never asserts online verification.

The original plotting and source-record code remains byte-preserved. A new read-only projection connects the BSD table, summary and leading-term comparison to the same authenticated T4 assessment used by the six badges. Its closure receives an assessment only after the signed-response consumer checks it. The projector additionally binds the legacy curve/context, full packet hash, exact model, normalization and marking; it checks the complete bad-prime inventory and recomputes the product from all local transfers. Its snapshot API is read-only and cannot commit an assessment.

A complete T4 result creates a transient Tamagawa component with `LOCAL_T4_PUBLIC_GATE_VERIFIED`, retaining its full certificate and identities. The original BSD comparison engine consumes this component with the other independently evidenced inputs. The source record is never mutated, and a conflicting source Tamagawa claim stays visible but does not replace the verified component. Invalidation clears the derived row, local factors and comparison contribution synchronously; source claims retain their original evidence status. Partial inventory displays only its listed local certificates and never contributes a complete T4 Tamagawa input or global normalization.

The full packet export retains the original source bytes and full T4 packet; the derived comparison is reconstructed after fresh verification. The legacy export remains explicitly labelled as a source record. Neither export makes `CERTIFIED` text authoritative on import. Exact local membership and finite prime counts remain separately labelled computations. T4 certifies reduction and normalization, not the numerical period or every browser-rendered number. Rank compatibility, dependence on BSD and independent-versus-inferred Sha checks remain those of the original comparison engine.

## Boundaries

The trial prime bound is 1009. An unresolved remaining cofactor yields `UNAVAILABLE`, no global certificate, no global Néron assertion and no complete conductor/Tamagawa product. Locally replayed factors remain available. No height, elliptic logarithm, rank, regulator, leading L-value or Sha conclusion is added. Sage on Serena/Nucleus remains a separate line item.

The v0.3 display, queue, identity namespaces and reference benchmark contract is detailed in REVIEW_REPAIRS.md. Server endpoints, caps and arithmetic verifiers are unchanged from v0.2. Each authorization operation passes through a per-page queue; an obsolete epoch cannot start or commit. HTTP 429 triggers visible bounded retry, and context invalidation clears every verdict and identity. Certificate context is bound to the full T4 record, in addition to the signed linked-view context.

F1 verification-output isolation is specified in F1_REPAIR.md. Sealed historical receipts are immutable inputs, not output targets. A post-seal default verifier receipt must identify this candidate manifest and remain outside the sealed directory. This harness repair does not alter the server socket idle timeout noted in the v0.3 audit.

## Additive V1 v0.6 family contract

See FAMILY_DISPLAY.md. The family is a preview and exact-input selector, not a new verifier. Singular input cannot be applied. No preview operation changes an arithmetic context; applying a nonsingular tile uses the shared exact-model operation and all inherited stale-context checks. Exact j/discriminant calculations and numerical curve paths have distinct fields. Unsupported marked periods stay unavailable. The per-launch server and all arithmetic/public-gate code remain unchanged.

## Additive V1 v0.6 family contract

See FAMILY_DISPLAY.md. The family is a preview and exact-input selector, not a new verifier. Singular input cannot be applied. No preview operation changes an arithmetic context; applying a nonsingular tile uses the shared exact-model operation and all inherited stale-context checks. Exact j/discriminant calculations and numerical curve paths have distinct fields. Unsupported marked periods stay unavailable. The per-launch server and all arithmetic/public-gate code remain unchanged.
