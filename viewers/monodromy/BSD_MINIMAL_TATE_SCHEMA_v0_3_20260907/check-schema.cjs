require('./verify.cjs').run('schema').catch(e=>{console.error(e.message);process.exitCode=1;});
