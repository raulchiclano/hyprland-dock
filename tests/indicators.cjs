const assert=require('node:assert/strict');
const fs=require('node:fs');
const vm=require('node:vm');
const p=vm.createContext({});
vm.runInContext(fs.readFileSync(__dirname+'/../components/WindowPolicy.js','utf8'),p);
const w=()=>({window:{activated:false}});
const a=w(), b=w(), remote=w();
let s={local:[],remote:[]};
assert.equal(p.indicator(s),'closed');
assert.equal(p.windowSummary('Terminal',s),'Terminal');
s.remote=[remote];
assert.equal(p.indicator(s),'remote');
assert.equal(p.windowSummary('Terminal',s),'Terminal · 0 aquí · 1 en otros escritorios');
s.local=[a];
assert.equal(p.indicator(s),'local');
s.local.push(b);
assert.equal(p.indicator(s),'multiple');
assert.equal(p.windowSummary('Terminal',s),'Terminal · 2 aquí · 1 en otros escritorios');
a.window.activated=true;
assert.equal(p.indicator(s),'active'); // Focus wins over the multi-window indication.
a.window.activated=false;
assert.equal(p.indicator(s),'multiple');
s.local=[a];s.remote=[];
assert.equal(p.windowSummary('Terminal',s),'Terminal · 1 aquí');
assert.equal(p.indicator(s),'local');
s.local=[];s.remote=[a,b,remote];
assert.equal(p.indicator(s),'remote'); // Three elsewhere are still one dim dot.
assert.equal(p.windowSummary('Terminal',s),'Terminal · 0 aquí · 3 en otros escritorios');
remote.window.activated=true;
assert.equal(p.indicator(s),'active'); // Focus wins even during a workspace metadata transition.
console.log('14 indicator and window-count checks passed');
