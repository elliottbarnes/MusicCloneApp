export const catalog = Object.freeze([
 {id:'night',name:'Night Windows',artist:'Parallel Lines',color:'mint'},
 {id:'tide',name:'Low Tide',artist:'Mara Vale',color:'orange'},
 {id:'signal',name:'Soft Signal',artist:'Signal Garden',color:'purple'},
 {id:'orbit',name:'Small Orbit',artist:'North Arcade',color:'blue'},
 {id:'paper',name:'Paper Cities',artist:'June Atlas',color:'rose'},
 {id:'blue',name:'Blue Hour',artist:'Static Coast',color:'sand'},
]);
export function search(query) {
 const q=query.trim().toLocaleLowerCase('en');
 return q ? catalog.filter(a=>(a.name+' '+a.artist).toLocaleLowerCase('en').includes(q)) : [];
}
export class Player {
 constructor(){this.reset();}
 reset(){this.album=null;this.playing=false;this.progress=0;}
 play(id){const album=catalog.find(a=>a.id===id);if(!album) throw Error('Unknown album');this.album=album;this.playing=true;this.progress=0;}
 toggle(){if(!this.album)return;if(this.progress>=1)this.progress=0;this.playing=!this.playing;}
 seek(value){if(!this.album || !Number.isFinite(value))return;this.progress=Math.max(0,Math.min(1,value));if(this.progress===1)this.playing=false;}
 advance(seconds){if(this.playing && Number.isFinite(seconds) && seconds>0)this.seek(this.progress+seconds/180);}
}
export class Library {
 constructor(){this.ids=new Set();}
 toggle(id){if(!catalog.some(a=>a.id===id))throw Error('Unknown album');this.ids.has(id)?this.ids.delete(id):this.ids.add(id);}
 get albums(){return catalog.filter(a=>this.ids.has(a.id));}
}
