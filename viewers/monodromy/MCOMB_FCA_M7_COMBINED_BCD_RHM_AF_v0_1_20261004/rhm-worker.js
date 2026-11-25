/* RH margin panel v0.1 worker. Runs after rhm-core.js in the same worker source (the embedded source is
 * rhm-core.js + "\n" + rhm-worker.js). Builds one rh_atom_margins record per request off the main thread.
 * Messages: in  {type: 'rhm/build', epoch, key, inputs, source, holdMs}
 *           out {type: 'rhm/ready'} once; {type: 'rhm/result', epoch, key, ms, text} or {type: 'rhm/refusal', epoch, key, ms, name, message}.
 * holdMs is a test hook only: the reply is delayed by that many ms (the build itself is unchanged).
 * Build: RH margin builder (Claude). Specification: Astra. Idea: saphir.
 */
(function () {
  'use strict';
  const C = self.McombRhMarginCoreV1;
  self.onmessage = ev => {
    const m = ev.data;
    if (!m || m.type !== 'rhm/build') return;
    const t0 = performance.now();
    let reply;
    try {
      const rec = C.buildAtom(m.inputs);
      reply = { type: 'rhm/result', epoch: m.epoch, key: m.key, text: C.canonicalText(C.withSource(rec, m.source)) };
    } catch (e) {
      reply = { type: 'rhm/refusal', epoch: m.epoch, key: m.key, name: e && e.name ? String(e.name) : 'Error', message: e && e.message ? String(e.message) : String(e) };
    }
    reply.ms = performance.now() - t0;
    const hold = Number.isSafeInteger(m.holdMs) && m.holdMs > 0 ? m.holdMs : 0;
    if (hold) setTimeout(() => self.postMessage(reply), hold); else self.postMessage(reply);
  };
  self.postMessage({ type: 'rhm/ready' });
})();
