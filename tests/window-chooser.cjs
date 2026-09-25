const assert=require('node:assert/strict');
const fs=require('node:fs');
const vm=require('node:vm');
const p=vm.createContext({});
vm.runInContext(fs.readFileSync(__dirname+'/../components/WindowPolicy.js','utf8'),p);
const a={address:'aaa',window:{title:'Terminal',activated:true},workspaceId:1,workspaceName:'1'};
const b={address:'bbb',window:{title:'Terminal',activated:false},workspaceId:2,workspaceName:'2'};
const c={address:'ccc',window:{title:'',activated:false},workspaceId:-99,workspaceName:'special:scratchpad'};
let selection={local:[a],remote:[b,c]};
let rows=p.windowRows(selection);
assert.equal(rows.length,5);
assert.equal(rows[0].title,'Este escritorio · 1');
assert.equal(rows[1].address,'aaa');
assert.equal(rows[1].active,true);
assert.equal(rows[2].title,'Otros escritorios · 2');
assert.equal(rows[3].subtitle,'Ventana 2 · Escritorio 2');
assert.equal(rows[4].title,'Ventana sin título');
assert.equal(rows[4].subtitle,'Ventana 3 · special:scratchpad');
assert.equal(p.findWindow(selection,'bbb'),b); // Identical titles must not confuse targets.
assert.equal(p.findWindow(selection,'gone'),null);
b.window.title='Proyecto nuevo';
assert.equal(p.windowRows(selection)[3].title,'Proyecto nuevo');
selection={local:[b,a],remote:[c]};
assert.equal(p.windowRows(selection)[1].subtitle,'Ventana 2 · Escritorio 2'); // Stable number after MRU change.
selection={local:[],remote:[a,c]};
assert.equal(p.findWindow(selection,'bbb'),null); // Closed target must not be activated.
assert.equal(p.windowRows(selection)[0].title,'Otros escritorios · 2');
assert.equal(p.windowRows({local:[],remote:[]}).length,0);
console.log('15 window chooser checks passed');
