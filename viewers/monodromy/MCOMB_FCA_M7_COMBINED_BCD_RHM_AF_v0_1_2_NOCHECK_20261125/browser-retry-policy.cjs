'use strict';
// One retry only for an explicit browser wait timeout. Assertion and watchdog errors stay failures.
function eligible(name,r){if(r.status===0||r.error||!name.includes('browser'))return false;const text=(r.stderr||'')+(r.stdout||'');return /(?:TimeoutError:|(?:waitForFunction|waitForSelector|locator\.[\w]+): Timeout \d+ms exceeded)/.test(text);}
module.exports={eligible};
