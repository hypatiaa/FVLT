require('./verify.cjs').run('browser').catch(e=>{console.error(e.message);process.exitCode=1;});
