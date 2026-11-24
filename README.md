# GOTYFROMHOENN — Nomination Reveal

Webapp statica per annunciare le nomination in diretta e consultarle dopo l'evento. Non contiene votazioni interne, classifiche o risultati. Le categorie e le nomination sono state importate dal modulo Google; gli artwork includono immagini locali dei giochi e della community; le immagini sono sostituibili.

## Avvio locale

Serve un server HTTP per caricare i JSON; aprire direttamente `index.html` con `file://` non è sufficiente. Dalla cartella del progetto:

```sh
python -m http.server 8000
```

Apri `http://localhost:8000/` per la consultazione oppure `http://localhost:8000/?mode=presentation` per la presentazione. Non occorre installare dipendenze per usare il sito.

## Contenuti e artwork

Modifica `categories.json`: ogni categoria ha `id`, `title`, `description` e un array `nominees`. Ogni candidato ha `id`, `name`, `image` e, facoltativamente, `subtitle`. L'ordine nel file è l'ordine del reveal. Le categorie possono rappresentare giochi, persone, momenti o altro. Gli SVG in `assets/nominees/` sono immagini dimostrative; i JPG `steam-*.jpg` sono artwork Steam salvati localmente: sostituiscili o aggiorna i percorsi nel JSON con immagini locali (ad esempio WebP o JPG). Per una resa coerente usa immagini verticali, possibilmente 4:5, e verifica che il testo resti leggibile. Le immagini mancanti mostrano un fondo grafico. Oltre 12 candidati, la presentazione usa pagine successive di massimo 12 schede, mantenendo l'ordine del reveal. Per le categorie con `"layout": "list"` usa una lista compatta, con pagine fino a 24 nomi.

In `config.json`, `eventName` ed `edition` impostano il nome e l'edizione; `logo` indica un logo locale opzionale. Se il file non esiste, viene mostrato il marchio tipografico di riserva.

## Votazioni e modalità pubblica

`votingUrl` contiene l'indirizzo del Google Forms. `votingEnabled` controlla la visibilità dei pulsanti di voto e del QR; `publicModeEnabled` controlla la consultazione pubblica. Sono entrambi attivi nella configurazione attuale. Per nascondere la consultazione prima dell'annuncio imposta `publicModeEnabled` a `false`; imposta anche `votingEnabled` a `false` se non vuoi mostrare il voto in presentazione. Riattiva entrambi dopo l'annuncio. Queste opzioni controllano solo l'interfaccia: i dati pubblicati restano accessibili.

Il QR locale `assets/branding/vote-qr.png` contiene l'URL configurato al momento della consegna. Se cambi `votingUrl`, rigenera anche il QR. Ad esempio, con Python e il pacchetto `qrcode` con supporto immagini installato:

```sh
python -c "import json,qrcode; c=json.load(open('config.json',encoding='utf-8-sig')); qrcode.make(c['votingUrl']).save('assets/branding/vote-qr.png')"
```

Tutti i collegamenti aprono il modulo in una nuova scheda; il modulo non è incorporato.

## Comandi del presentatore

- **Spazio / freccia destra** o clic sullo stage: prossimo passo. Puoi anche cliccare sulla prossima carta nascosta per scoprirla immediatamente, seguendo l'ordine del JSON. L'ultimo candidato rimane visibile fino a un ulteriore comando. Nelle categorie con piu pagine, il primo comando dopo l'ultima carta apre la pagina successiva ancora coperta.
- **Freccia sinistra**: passo precedente, anche nascondendo l'ultimo candidato.
- **F**: attiva/disattiva lo schermo intero. **Esc** usa il comportamento standard del browser.
- **R**: reset della categoria corrente, previa conferma.
- **H**: mostra/nasconde il pannello con avanzamento, selettore categoria, reveal completo e ritorno all'inizio.

La presentazione riparte dalla schermata iniziale a ogni ricarica della pagina. Prova prima della diretta la risoluzione 1920×1080, il fullscreen, i comandi e la cattura OBS. La presentazione non avanza automaticamente; ogni comando mostra subito la carta successiva.

## Audio opzionale

Non sono inclusi file audio. Per usarli, inserisci file autorizzati in `assets/audio/` e aggiungi a `config.json` per esempio:

```json
"soundEnabled": true,
"audioVolume": 0.6,
"audio": {
  "category": "assets/audio/category.mp3",
  "reveal": "assets/audio/reveal.mp3",
  "complete": "assets/audio/complete.mp3",
  "transition": "assets/audio/transition.mp3"
}
```

`audioVolume` va da 0 a 1. Il browser può limitare l'audio fino alla prima interazione dell'utente.

## Pubblicazione su GitHub Pages

Carica tutti i file e la cartella `assets` nel repository. Nelle impostazioni GitHub Pages scegli il branch e la cartella che contengono `index.html` (normalmente la root), quindi attendi la pubblicazione. Tutti i percorsi sono relativi e funzionano anche sotto il percorso del repository. L'indirizzo base apre la consultazione; aggiungi `?mode=presentation` per la diretta. Verifica anche il QR e il link di voto sul sito pubblicato.
