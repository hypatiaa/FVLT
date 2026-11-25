/* Tooth contact 0.1 schedule worker (worker D): epoch-tagged tc/ messages, no host access.
 * In: { type: 'tc/generate', epoch, config }. Out: { type: 'tc/schedule', epoch, rows } or { type: 'tc/error', epoch, error }. */
self.onmessage = event => {
  const msg = event.data || {};
  if (msg.type !== 'tc/generate') { self.postMessage({ type: 'tc/error', epoch: msg.epoch ?? null, error: 'unknown message type' }); return; }
  try { self.postMessage({ type: 'tc/schedule', epoch: msg.epoch, rows: self.McombToothContactCoreV1.schedule(msg.config) }); }
  catch (error) { self.postMessage({ type: 'tc/error', epoch: msg.epoch, error: String(error && error.message) }); }
};
