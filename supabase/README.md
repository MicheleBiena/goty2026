# Votazioni sul sito con Supabase e Twitch

La modalita Google rimane attiva fino a quando `votingProvider` resta `google` in `config.json`. Non cambiare provider finche non sono stati completati e verificati tutti i passaggi qui sotto.

## 1. Progetto Supabase

1. Crea un progetto gratuito su https://supabase.com/dashboard e attendi che sia pronto. Il progetto memorizzera gli account autenticati e i voti; scegli una regione adeguata al pubblico.
2. Apri **SQL Editor**, copia tutto il contenuto di `supabase/setup.sql` ed eseguilo una sola volta su un progetto nuovo. Crea le opzioni valide, le tabelle e le funzioni per votare. Il contenuto riflette i candidati presenti in `categories.json` al momento della preparazione: se cambi categorie o candidati, aggiorna anche `award_vote_options` nel database prima di aprire le votazioni.
3. Nel progetto prendi **Project URL** e **Publishable key** (chiave `sb_publishable_...`). Sono dati pubblici. Non usare o condividere chiavi `sb_secret_...`, `service_role`, password del database o credenziali Twitch.
4. In **Authentication > URL Configuration**, imposta il Site URL a `https://michelebiena.github.io/goty2026/` e aggiungi ai Redirect URLs `https://michelebiena.github.io/goty2026/vote.html`. Per test locali aggiungi anche `http://localhost:8000/vote.html` e/o `http://127.0.0.1:8000/vote.html` in base all'indirizzo usato.

## 2. Accesso Twitch

Segui la guida ufficiale https://supabase.com/docs/guides/auth/social-sign-in/auth-twitch:

1. Attiva la verifica a due fattori sull'account Twitch e accedi alla Twitch Developer Console: https://dev.twitch.tv/console/apps.
2. In Supabase apri **Authentication > Sign In / Providers > Twitch** e copia il callback URL del provider, che termina con `/auth/v1/callback`.
3. Registra un'app nella Twitch Developer Console usando esattamente quel callback URL. Crea Client ID e Client Secret.
4. Inserisci Client ID e Client Secret **solo nel pannello Supabase**, nella configurazione del provider Twitch, e attiva il provider. Non inserire il Client Secret nei file del sito, nel repository o in chat.

## 3. Collegamento e verifica prima dell'apertura

1. In `config.json`, inserisci Project URL in `supabase.url` e la sola Publishable key in `supabase.publishableKey`.
2. Imposta `votingProvider` a `supabase` e verifica che `votingEnabled` e `publicModeEnabled` siano `true`. I pulsanti apriranno `vote.html`; la presentazione e la consultazione restano su GitHub Pages.
3. Il QR nella presentazione e un file statico: rigeneralo con l'URL pubblico **https://michelebiena.github.io/goty2026/vote.html** prima di pubblicare il cambio. Con Python e il pacchetto `qrcode` con supporto immagini installato:

```sh
python -c "import qrcode; qrcode.make('https://michelebiena.github.io/goty2026/vote.html').save('assets/branding/vote-qr.png')"
```

4. Prova l'accesso Twitch, il ritorno alla pagina, l'invio di una scelta, il rientro e il tentativo di votare di nuovo nella stessa categoria. Prova anche un altro account e la chiusura delle votazioni. Verifica i risultati nel SQL Editor. I voti di prova vengono memorizzati: rimuovili dal database prima dell'apertura ufficiale, con attenzione.
5. Solo dopo le prove, pubblica i file aggiornati. I voti del precedente Google Forms restano su Google e non vengono importati automaticamente.

Non pubblicare chiavi segrete. Il sito pubblico riceve solo la chiave publishable; le tabelle non sono direttamente accessibili ai visitatori. Le due funzioni SQL verificano l'identita Twitch, validano i candidati e impediscono piu di un voto per categoria per account. I voti inviati sono definitivi, ma e possibile tornare a votare nelle categorie ancora non votate. Gli account Twitch multipli possono comunque votare separatamente.

## Risultati e chiusura

Dal SQL Editor, per vedere i conteggi:

```sql
select category_id, nominee_id, count(*) as voti
from public.award_votes
group by category_id, nominee_id
order by category_id, voti desc;
```

Gli ID corrispondono a quelli in `categories.json`. Per chiudere lato server, impedendo nuovi invii anche tramite chiamate dirette:

```sql
update public.award_voting_settings set is_open = false where id = true;
```

Per riaprire, imposta `is_open = true`. `votingEnabled` nasconde l'interfaccia, ma da solo non chiude l'API: usa anche il comando SQL. Esporta i risultati prima di eliminare il progetto. Per ripristinare il modulo Google, imposta `votingProvider` a `google` e rigenera il QR con `votingUrl`.

La piattaforma memorizza l'identificativo dell'account autenticato associato ai voti e l'ora di invio; spiega ai partecipanti il trattamento dei dati e la durata della conservazione. Un account Twitch corrisponde a un votante, non necessariamente a una persona unica.
