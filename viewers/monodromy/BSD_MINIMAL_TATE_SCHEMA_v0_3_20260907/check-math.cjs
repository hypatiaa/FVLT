require('./verify.cjs').run('math').catch(e=>{console.error(e.message);process.exitCode=1;});
