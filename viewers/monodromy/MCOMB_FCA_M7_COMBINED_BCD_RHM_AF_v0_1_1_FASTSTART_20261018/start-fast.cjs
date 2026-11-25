// MCOMB_FCA_M7_COMBINED_BCD_RHM_AF v0.1.1 FASTSTART (2026-10-18)
// Additive successor of ../MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004 (the merged viewer).
// It adds nothing to the viewer and changes nothing in the parent package: it only starts the
// parent's own server.cjs with the parent's own option { skipIntegrity: true }, so the startup
// chain of predecessor package inventories is skipped. start() still reads BUILD_PINS.json and
// refuses to serve if the viewer page's SHA-256 does not match viewerSha256.
// Purpose: time saving for local use while the viewer is redone (saphir, 2026-10-18).
// Standing: unsealed; local use allowed (2026-10-07). No host, port or path arguments.
'use strict';
const path = require('node:path'), fs = require('node:fs'), crypto = require('node:crypto');
const PARENT = path.join(__dirname, '..', 'MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004');
const PINS = {
  'server.cjs': '20caf5398cef57f988700adc27c8cdbe49dbe538d7e570ebfa482926d8424311',
  'BUILD_PINS.json': '5bafe8bb6353658c49da47ade393d22e8b197680fc6e1b70b136728105fe9341',
  'monodromy-31-linked-reduction.html': 'b4cee4e30a753eda7c62f72e8043d6d5c9b3f69c3c2e1dd0da9a3f9ab5b8e248'
};
if (process.argv.length !== 2) throw Error('No host, port or path arguments accepted');
for (const [name, sha] of Object.entries(PINS)) {
  const got = crypto.createHash('sha256').update(fs.readFileSync(path.join(PARENT, name))).digest('hex');
  if (got !== sha) throw Error('Parent pin mismatch for ' + name + ': ' + got);
}
const { start } = require(path.join(PARENT, 'server.cjs'));
start({ skipIntegrity: true }).then(q => {
  console.log('Merged viewer v0.1.1 FASTSTART (parent inventory check skipped; viewer hash checked): ' + q.origin + '/');
  for (const s of ['SIGINT', 'SIGTERM']) process.on(s, () => q.close().then(() => process.exit(0)));
}).catch(e => { console.error(e.message); process.exit(1); });
