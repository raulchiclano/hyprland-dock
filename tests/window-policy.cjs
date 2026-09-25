const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const p = vm.createContext({});
vm.runInContext(fs.readFileSync(__dirname + '/../components/WindowPolicy.js', 'utf8'), p);
const w1={appId:'foot',activated:false}, w2={appId:'foot',activated:false}, w3={appId:'foot',activated:false};
const h=(w,id,rank,extra={})=>({wayland:w,workspace:{id,name:String(id)},monitor:{id:0},lastIpcObject:{focusHistoryID:rank,...extra}});
let hs=[h(w1,2,0),h(w2,1,4),h(w3,1,2)];
let s=p.select([w1,w2,w3],hs,1,0);
assert.equal(s.local.length,2);
assert.equal(s.local[0].window,w3); // Local MRU, not global MRU or model order.
assert.equal(s.remote[0].window,w1);
assert.equal(p.select([w1],hs,1,0).local.length,0);
assert.equal(p.select([w1],hs,2,0).local[0].window,w1);
w2.activated=true;
assert.equal(p.select([w1,w2,w3],hs,1,0).local[0].window,w2);
w2.activated=false;
hs[1].lastIpcObject.focusHistoryID=1;
assert.equal(p.select([w1,w2,w3],hs,1,0).local[0].window,w2);
assert.equal(p.select([w1],[],1,0).local.length,0); // Never guess identity from title.
assert.equal(p.select([null],hs,1,0).remote.length,0);
assert.equal(p.select([w1],[h(w1,-99,0)],-99,0).local.length,1);
assert.equal(p.select([w1],[h(w1,2,0,{pinned:true})],1,0).local.length,1);
assert.equal(p.select([w1],[h(w1,2,0,{pinned:true})],1,1).local.length,0);
for(const id of ['foot','footclient']) assert.equal(p.launchPlan({id},true).kind,'entry');
for(const id of ['spotify','chatgpt','unknown']) {
 assert.equal(p.launchPlan({id},true).kind,'blocked');
 assert.equal(p.launchPlan({id},false).kind,'entry');
}
assert.equal(p.launchPlan(null,false).kind,'blocked');
const newWindow={id:'new-window'},newEmpty={id:'new-empty-window'},blank={id:'new-blank-window'};
assert.equal(p.launchPlan({id:'org.gnome.Nautilus',actions:[newWindow]},true).action,newWindow);
assert.equal(p.launchPlan({id:'code',actions:[newEmpty]},true).action,newEmpty);
assert.equal(p.launchPlan({id:'zen',actions:[newWindow,blank]},true).action,blank);
assert.equal(p.launchPlan({id:'zen',actions:[newWindow]},true).kind,'blocked');
assert.equal(p.intent(1,true,false),'focus');
assert.equal(p.intent(3,true,false),'focus');
assert.equal(p.intent(0,true,false),'launch');
assert.equal(p.intent(0,false,false),'menu');
assert.equal(p.intent(0,true,false),'launch');
assert.equal(p.intent(1,true,true),'launch');
assert.equal(p.intent(1,false,true),'menu');
assert.equal(p.focusRequest('abc123',true),'hl.dsp.focus({ window = "address:0xabc123" })');
assert.equal(p.focusRequest('0xabc123',false),'focuswindow address:0xabc123');
assert.equal(p.focusRequest('bad;command',true),'');
console.log('35 workspace and launch-policy checks passed');
