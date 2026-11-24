const app = document.querySelector('#vote-app');
const esc = value => String(value ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
let config, categories, client, session, saved = {};
const frame = content => `<div class="shell ballot-shell"><div class="wrap"><header class="topbar"><a class="brand" href="./"><span class="brand-mark" aria-hidden="true"><span>✦</span></span><span>${esc(config.eventName)}<br>${esc(config.edition)}</span></a><a class="ballot-back" href="./">← Torna alle nomination</a></header>${content}<footer class="footer"><span>${esc(config.eventName)} / ${esc(config.edition)}</span></footer></div></div>`;
const message = (title, details) => { app.innerHTML = frame(`<section class="ballot-intro"><div class="eyebrow">Votazioni</div><h1>${esc(title)}</h1><p>${esc(details)}</p></section>`); };
function loginView() {
 app.innerHTML = frame(`<section class="ballot-intro"><div class="eyebrow">Votazioni / ${esc(config.edition)}</div><h1>Ora tocca <em>a te.</em></h1><p>Accedi con Twitch per votare. Puoi votare una volta per categoria.</p><button class="button" id="login">Accedi con Twitch <span aria-hidden="true">↗</span></button><p class="ballot-note">I voti inviati non possono essere modificati.</p><p id="status" class="ballot-status" role="status"></p></section>`);
 document.querySelector('#login').addEventListener('click', async e => {
  const button=e.currentTarget, status=document.querySelector('#status'); button.disabled=true;status.textContent='Apertura di Twitch...';
  try { const {error}=await client.auth.signInWithOAuth({provider:'twitch',options:{redirectTo:new URL('vote.html',location.href).href}});if(error)throw error; }
  catch {status.textContent='Impossibile aprire Twitch. Riprova.';button.disabled=false;}
 });
}
function ballotView() {
 const voted=Object.keys(saved).length;
 app.innerHTML=frame(`<section class="ballot-intro ballot-intro-small"><div class="eyebrow">Votazioni / ${esc(config.edition)}</div><h1>Le tue <em>scelte.</em></h1><p>Scegli un candidato per categoria. Puoi inviare anche solo alcune categorie e tornare in seguito.</p><div class="ballot-account"><span>Accesso Twitch attivo · ${voted} / ${categories.length} categorie votate</span><button type="button" id="logout">Esci</button></div></section><form id="ballot"><p class="ballot-note">I voti inviati sono definitivi e non possono essere modificati.</p>${categories.map((cat,i)=>{const locked=Object.hasOwn(saved,cat.id);return `<fieldset class="ballot-category" ${locked?'disabled':''}><legend><span class="section-number">Categoria / ${String(i+1).padStart(2,'0')}</span><strong>${esc(cat.title)}</strong></legend>${locked?'<p class="ballot-voted">Voto registrato</p>':''}<div class="${cat.layout==='list'?'ballot-options':'ballot-cards'}">${cat.nominees.map(n=>cat.layout==='list'?`<label class="ballot-option"><input type="radio" name="${esc(cat.id)}" value="${esc(n.id)}" ${saved[cat.id]===n.id?'checked':''}><span>${esc(n.name)}</span></label>`:`<label class="ballot-card"><span class="ballot-card-art"><img class="${n.imageFit==='contain'?'image-contain':''}" src="${esc(n.image||'')}" alt="" loading="lazy" onerror="this.remove()"></span><span class="ballot-card-choice"><input type="radio" name="${esc(cat.id)}" value="${esc(n.id)}" ${saved[cat.id]===n.id?'checked':''}><span>${esc(n.name)}</span></span></label>`).join('')}</div></fieldset>`}).join('')}<div class="ballot-submit"><button class="button" type="submit" ${voted===categories.length?'disabled':''}>Invia i voti <span aria-hidden="true">↗</span></button><p id="status" class="ballot-status" role="status" aria-live="polite"></p></div></form>`);
 document.querySelector('#logout').addEventListener('click',async()=>{await client.auth.signOut();session=null;loginView()});
 document.querySelector('#ballot').addEventListener('submit',submitBallot);
}
async function refreshVotes(){
 const {data,error}=await client.rpc('award_my_votes');if(error)throw error;
 saved=Object.fromEntries((data||[]).map(row=>[row.category_id,row.nominee_id]));
}
async function submitBallot(event){
 event.preventDefault();const form=event.currentTarget,status=document.querySelector('#status'),button=form.querySelector('button[type="submit"]');
 const choices=Object.fromEntries(new FormData(form).entries());
 if(!Object.keys(choices).length){status.textContent='Scegli almeno un candidato prima di inviare.';return;}
 if(!confirm('Confermi i voti selezionati? Dopo l’invio non potrai modificarli.'))return;
 button.disabled=true;status.textContent='Invio in corso...';
 try {
  const {error}=await client.rpc('award_cast_votes',{choices});if(error)throw error;
  try {await refreshVotes();ballotView();document.querySelector('#status').textContent='Voti registrati.';}
  catch {message('Voti inviati','I voti sono stati registrati. Ricarica la pagina per vedere le tue scelte.');}
 } catch(error) {
  if(error.code==='23505'||/gia votato/i.test(error.message||'')){
   try{await refreshVotes();ballotView();document.querySelector('#status').textContent='Una categoria era già stata votata. Controlla le scelte e riprova.';return}catch{}
  }
  status.textContent=/votazioni chiuse/i.test(error.message||'')?'Le votazioni sono chiuse.':'Invio non riuscito. Controlla la connessione e riprova.';button.disabled=false;
 }
}
async function init(){
 try{
  const responses=await Promise.all([fetch('config.json'),fetch('categories.json')]);if(responses.some(r=>!r.ok))throw Error('Dati non disponibili');
  [config,categories]=await Promise.all(responses.map(r=>r.json()));
  const settings=config.supabase;
  if(!config.publicModeEnabled||!config.votingEnabled||config.votingProvider!=='supabase'||!settings?.url||!settings?.publishableKey){message('Votazioni non disponibili','Le votazioni sul sito non sono attive.');return;}
  if(!window.supabase)throw Error('Servizio non disponibile');
  client=window.supabase.createClient(settings.url,settings.publishableKey);
  const {data,error}=await client.auth.getSession();if(error)throw error;session=data.session;
  if(!session){loginView();return;}
  await refreshVotes();ballotView();
 }catch{if(!config)config={eventName:'GOTYFROMHOENN',edition:''};message('Impossibile caricare le votazioni','Controlla la connessione e ricarica la pagina.');}
}
init();
