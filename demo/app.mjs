import {catalog,search,Player,Library} from './core.mjs';
const $=id=>document.getElementById(id), player=new Player();
let library=new Library(), view='home';
function artwork(album){const art=document.createElement('div');art.className=`art ${album.color}`;art.setAttribute('aria-hidden','true');const id=document.createElement('span');id.textContent=`SIDE A / ${String(catalog.indexOf(album)+1).padStart(2,'0')}`;const play=document.createElement('span');play.className='play-mark';play.textContent='▶';art.append(id,play);return art;}
function render(){
 const albums=view==='library'?library.albums:view==='search'?search($('query').value):catalog;
 $('albums').replaceChildren();
 for(const album of albums){
  const card=document.createElement('article');card.className='album';
  const button=document.createElement('button');button.className='preview';button.setAttribute('aria-label',`Preview ${album.name}`);button.append(artwork(album));button.addEventListener('click',()=>{player.play(album.id);updatePlayer();$('status').textContent=`Previewing ${album.name}. Playback is simulated.`;});
  const meta=document.createElement('div');meta.className='album-meta';const text=document.createElement('div');const name=document.createElement('h3');name.textContent=album.name;const artist=document.createElement('p');artist.textContent=album.artist;text.append(name,artist);
  const save=document.createElement('button');save.className='save';save.textContent=library.ids.has(album.id)?'✓':'+';save.setAttribute('aria-pressed',String(library.ids.has(album.id)));save.setAttribute('aria-label',`${library.ids.has(album.id)?'Remove':'Save'} ${album.name}`);
  save.addEventListener('click',()=>{library.toggle(album.id);render();$('status').textContent=`${album.name} ${library.ids.has(album.id)?'saved':'removed'}.`;
   // Re-render can remove a library row; keep keyboard focus on its replacement or the view control.
   const replacement=[...document.querySelectorAll('.save')].find(b=>b.getAttribute('aria-label').endsWith(album.name));(replacement||$(view)).focus();});
  meta.append(text,save);card.append(button,meta);$('albums').append(card);
 }
 $('count').textContent=library.ids.size;$('result-count').textContent=`${albums.length} album${albums.length===1?'':'s'}`;
 $('empty').hidden=albums.length>0;$('empty').textContent=view==='library'?'Your collection starts here. Save an album from Discover or Search.':$('query').value.trim()?'No matching albums. Try a different title or artist.':'Type a title or artist to begin.';
}
function navigate(next){view=next;for(const id of ['home','search','library']){if(id===view)$(id).setAttribute('aria-current','page');else $(id).removeAttribute('aria-current');}
 $('search-panel').hidden=view!=='search';$('title').textContent=view==='home'?'A small collection. A little discovery.':view==='search'?'Find your next favourite.':'A collection of your own.';
 $('description').textContent=view==='home'?'Browse, save a favourite, and explore the player controls.':view==='search'?'Search this fictional collection by album or artist.':'Saved for this session. Reset or reload to start fresh.';
 $('section-title').textContent=view==='home'?'On the shelf':view==='search'?'Search results':'Your saved albums';render();if(view==='search')$('query').focus();}
function updatePlayer(){
 $('track-title').textContent=player.album?.name??'Choose an album';$('track-artist').textContent=player.album?`${player.album.artist} · simulated`:'Playback simulation · no audio';
 $('toggle').disabled=!player.album;$('toggle').textContent=player.playing?'Ⅱ':'▶';$('toggle').setAttribute('aria-label',player.playing?'Pause preview':'Play preview');
 $('progress').disabled=!player.album;$('progress').value=Math.round(player.progress*1000);
 const sec=Math.floor(player.progress*180);$('elapsed').textContent=`${Math.floor(sec/60)}:${String(sec%60).padStart(2,'0')}`;
}
for(const id of ['home','search','library'])$(id).addEventListener('click',()=>navigate(id));
$('query').addEventListener('input',render);$('toggle').addEventListener('click',()=>{player.toggle();updatePlayer();});
$('progress').addEventListener('input',()=>{player.seek(Number($('progress').value)/1000);updatePlayer();});
$('reset-session').addEventListener('click',()=>{library=new Library();player.reset();$('query').value='';navigate('home');updatePlayer();$('status').textContent='Session reset.';});
let previous=performance.now();setInterval(()=>{const now=performance.now();player.advance((now-previous)/1000);previous=now;updatePlayer();},250);
// The simulation pauses in a hidden tab and stays paused when the visitor returns.
 document.addEventListener('visibilitychange',()=>{previous=performance.now();if(document.hidden){player.playing=false;updatePlayer();}});
render();updatePlayer();
