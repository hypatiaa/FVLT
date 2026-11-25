# Startup application repair (v0.6)

The sealed v0.5 run failed its file-mode family application check. The previous model remained active: a passive initial mcomb/Cayley notification changed the V1 epoch while the exact-model worker request was pending, so the requested curve was discarded before import. The failure receipt is retained beside the v0.5 package; neither v0.5 nor its sealed bytes were repaired in place.

Exact-model construction takes coefficients and a differential multiplier; it does not depend on the mcomb source. v0.6 therefore defers passive source-signature invalidation while model construction is pending. A counter covers overlapping preparations and is released in finally. Assessment refresh waits for those preparations; the eventual replay gathers the then-current source. Explicit newer applications and input edits still invalidate the epoch, superseding old work. Existing response signatures, context guards and all six invalidations remain in force.

A deterministic browser regression changes the prime-cutoff/source signature and dispatches a source notification during exact-model preparation. The requested curve must still be applied, and the final packet must contain the latest cutoff. The immediate fresh-file application, 429/latest-curve, tampered-response, explicit input invalidation and server-loss checks are retained.

The repair changes client lifecycle only; all T4/server/worker/spectral bytes remain unchanged. It does not expand the period family or arithmetic domain.
