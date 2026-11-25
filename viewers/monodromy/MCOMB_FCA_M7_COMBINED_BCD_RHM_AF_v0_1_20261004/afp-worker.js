/* arithmetic-fourier panel v0.1: worker glue (builder candidate; credit as in afp-core.js).
 * The embedded worker source is afp-core.js, one LF, then this file. One job at a time; every message carries the
 * job identity (revision, inputDigest) of the panel, which the panel checks before any state change. Message types: afp/.
 */
(function () {
  'use strict';
  const C = self.McombArithmeticFourierCoreV1;
  const now = () => (self.performance && performance.now ? performance.now() : Date.now());
  const ascii = raw => { let s = ''; for (let i = 0; i < raw.length; i += 8192) s += String.fromCharCode.apply(null, raw.subarray(i, i + 8192)); return s; };
  const filesMap = f => { const m = new Map(); if (f) for (const k of Object.keys(f)) m.set(k, f[k]); return m; };
  self.onmessage = ev => {
    const m = ev.data || {};
    const echo = { revision: m.revision, inputDigest: m.inputDigest };
    try {
      if (m.type === 'afp/build') {
        const t0 = now();
        const record = C.build(m.inputs);
        const raw = C.serialize(record);
        const t1 = now();
        C.import_and_validate(raw);
        const t2 = now();
        C.validateBound(raw, { modelId: m.binding.modelId, n: m.inputs.atom });
        const t3 = now();
        let assessment = null, assessRefusal = null;
        const files = filesMap(m.files);
        if (files.size) {
          try { assessment = C.assess(raw, files); }
          catch (e) { if (e instanceof C.ContractError) assessRefusal = e.message; else throw e; }
        }
        const t4 = now();
        self.postMessage({ type: 'afp/result', ...echo, text: ascii(raw), recordSha256: C.sha256Hex(raw), record, assessment, assessRefusal,
          timings: { buildMs: t1 - t0, importValidateMs: t2 - t1, validateBoundMs: t3 - t2, assessMs: t4 - t3, totalMs: t4 - t0 } });
      } else if (m.type === 'afp/validate') {
        const raw = C.asciiBytes(m.text);
        C.import_and_validate(raw);
        C.validateBound(raw, { modelId: m.modelId, n: m.n });
        const files = filesMap(m.files);
        if (m.assess && files.size) C.assess(raw, files);
        self.postMessage({ type: 'afp/validated', ...echo, ok: true, sha256: C.sha256Hex(raw) });
      } else if (m.type === 'afp/parity') {
        const raw = C.serialize(C.build(m.inputs));
        self.postMessage({ type: 'afp/parity-result', id: m.id, ok: true, text: ascii(raw) });
      }
    } catch (e) {
      if (e instanceof C.ContractError) self.postMessage({ type: m.type === 'afp/parity' ? 'afp/parity-result' : m.type === 'afp/validate' ? 'afp/validated' : 'afp/refused',
        ...echo, id: m.id, ok: false, code: C.codeOf(e), message: e.message });
      else self.postMessage({ type: m.type === 'afp/parity' ? 'afp/parity-result' : m.type === 'afp/validate' ? 'afp/validated' : 'afp/error',
        ...echo, id: m.id, ok: false, code: 'INTERNAL_ERROR', message: String(e && e.message || e) });
    }
  };
  self.postMessage({ type: 'afp/ready' });
})();
