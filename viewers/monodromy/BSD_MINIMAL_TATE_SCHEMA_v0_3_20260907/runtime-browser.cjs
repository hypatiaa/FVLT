'use strict';
const modulePath=process.env.BSD_AUDIT_PLAYWRIGHT_MODULE;
if(!modulePath)throw Error('Use the scratch verifier so Playwright is discovered and recorded');
const playwright=require(modulePath);
module.exports={chromium:{launch:options=>playwright.chromium.launch({...options,executablePath:process.env.BSD_AUDIT_CHROMIUM})}};
