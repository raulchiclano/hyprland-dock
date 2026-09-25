const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const a = vm.createContext({});
vm.runInContext(fs.readFileSync(__dirname + '/../components/Applications.js', 'utf8'), a);
const entries = [
  {id:'foot',startupClass:'foot',command:['foot']},
  {id:'spotify',startupClass:'Spotify',command:['spotify']},
  {id:'org.editor.Code',startupClass:'Code',command:['code']},
  {id:'WhatsApp',command:['browser','--app=https://web.whatsapp.com/']}
];
const w = appId => ({appId});
const windows = [w('foot'),w('Spotify'),w('Spotify'),w('Code')];
let result = a.unpinned(['foot'],entries,windows);
assert.equal(result.length,2);
assert.equal(result[0].desktopId,'spotify');
assert.equal(result[0].windows.length,2);
assert.equal(result[1].desktopId,'org.editor.Code');
assert.equal(a.unpinned(['FOOT.desktop','spotify','org.editor.Code'],entries,windows).length,0);
assert.equal(a.unpinned(['foot'],entries,windows.slice(0,1)).length,0);
assert.equal(a.unpinned([],entries,[w('Spotify')]).length,1);
assert.equal(a.unpinned(['WhatsApp'],entries,[w('chrome-web.whatsapp.com__-Default')]).length,0);
result=a.unpinned([],entries,[w('Unknown.App'),w('unknown.app')]);
assert.equal(result.length,1);
assert.equal(result[0].entry,null);
assert.equal(result[0].desktopId,'');
assert.equal(result[0].windows.length,2);
assert.equal(a.unpinned([],entries,[w(''),w('')]).length,2);
assert.equal(a.unpinned([],entries,[null]).length,0);
// Model can arrive after windows; re-resolution must replace generic entries.
assert.equal(a.unpinned([],[],[w('Spotify')])[0].entry,null);
assert.equal(a.unpinned([],entries,[w('Spotify')])[0].entry.id,'spotify');
// Pinning removes only that application's temporary entry; unpinning brings it back.
assert.equal(a.unpinned(['foot','spotify'],entries,windows).length,1);
assert.equal(a.unpinned(['foot'],entries,windows).length,2);
console.log('18 application grouping checks passed');
