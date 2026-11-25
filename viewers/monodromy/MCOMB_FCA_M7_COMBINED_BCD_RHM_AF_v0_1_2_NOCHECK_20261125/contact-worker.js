/* Contact sweep 0.1 schedule worker: epoch-tagged replies, no host access. */
self.onmessage = event => {
  const { epoch, config } = event.data;
  try { self.postMessage({ epoch, rows: self.McombContactSweepCoreV1.schedule(config) }); }
  catch (error) { self.postMessage({ epoch, error: String(error && error.message) }); }
};
