import test from 'node:test';
import assert from 'node:assert/strict';
import {catalog,search,Player,Library} from '../../demo/core.mjs';
test('catalog IDs are distinct and search includes artists',()=>{assert.equal(new Set(catalog.map(a=>a.id)).size,6);assert.deepEqual(search('  MARA ' ).map(a=>a.id),['tide']);assert.deepEqual(search(' '),[]);assert.deepEqual(search('<script>'),[]);});
test('player bounds, end, pause and restart',()=>{const p=new Player();p.toggle();assert.equal(p.playing,false);p.play('night');p.seek(.5);p.seek(NaN);assert.equal(p.progress,.5);p.advance(90);assert.equal(p.progress,1);assert.equal(p.playing,false);p.toggle();assert.equal(p.progress,0);assert.equal(p.playing,true);p.toggle();p.advance(50);assert.equal(p.progress,0);p.seek(-1);assert.equal(p.progress,0);p.reset();assert.equal(p.album,null);});
test('invalid albums cannot enter state',()=>{assert.throws(()=>new Player().play('bogus'));assert.throws(()=>new Library().toggle('bogus'));});
test('library toggles deduplicate and remove',()=>{const l=new Library();l.toggle('tide');assert.equal(l.albums.length,1);l.toggle('tide');assert.equal(l.albums.length,0);});
