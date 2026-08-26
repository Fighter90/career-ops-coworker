<!-- Locale: Italian (it). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — Guida utente

Una guida completa all'installazione e all'esecuzione del coworker **career-ops** all'interno di **[OpenWorker](https://openworker.com)**. Il coworker trasforma OpenWorker in un operatore di ricerca lavoro: scansiona le bacheche di annunci, valuta ogni annuncio rispetto al tuo CV, adatta un CV fondato + lettera di presentazione, tiene traccia delle candidature e prepara le bozze dei follow-up — e può aprire per te il dashboard `career-ops-ui`.

## 1. What this is (and isn't)

- **È** una *persona* — un singolo file Markdown ([`career-ops.md`](../career-ops.md)) con frontmatter YAML (quali capacità richiede) più un prompt di sistema (come si comporta). «Un coworker ⊇ una skill».
- **Non è** un programma. OpenWorker **non** esegue come codice nulla di questo repository. Il frontmatter *dichiara* capacità verificate e connettori consigliati; il prompt *guida* l'agente. Ecco perché la schermata di installazione dice: «no third-party code runs, but the instructions steer the coworker».
- **Gestisce la pipeline [`career-ops`](https://github.com/Fighter90/career-ops)**, non un servizio ospitato. Tutto avviene sulla tua macchina, nella tua cartella di progetto, con la tua chiave del modello.

## 2. Requirements

1. **OpenWorker** installato — scaricalo da [openworker.com](https://openworker.com) (macOS / Windows) o eseguilo dai sorgenti. Aggiungi una chiave del modello (Anthropic, OpenAI, Google o un modello locale tramite Ollama).
2. **Una cartella di progetto `career-ops`** sulla tua macchina, configurata con i tuoi dati:
   ```bash
   git clone https://github.com/Fighter90/career-ops
   cd career-ops
   # segui il README di quel progetto per creare cv.md, config/profile.yml, portals.yml
   ```
   Il coworker opera *all'interno* di questa cartella e legge/scrive `cv.md`, `config/profile.yml`, `config/two-pager.yml`, `portals.yml`, `data/applications.md` e `reports/`.

**I file da configurare** (schema completo nel [README di `career-ops`](https://github.com/Fighter90/career-ops)):

| File | Cosa metterci |
|---|---|
| `cv.md` | il tuo CV reale in Markdown — l’unica fonte di verità su cui il coworker si basa (non inventa nulla oltre a questo). |
| `config/profile.yml` | ruoli target, seniority, sedi, preferenza remoto, retribuzione e `spend_tier` (controlla il costo del modello). |
| `portals.yml` | le board da scansionare — uno slug azienda di Greenhouse/Lever/Ashby, o una voce su tutta la board come `{ name: Torre, provider: torre, search: "engineering manager", enabled: true }`. |
| `config/two-pager.yml` *(opzionale)* | piaceri / must-have / deal-breaker che affinano il punteggio di aderenza. |

Esegui `node scan.mjs --dry-run` da questa cartella una volta per confermare che recuperi annunci prima di collegare OpenWorker.

**(opzionale)** clona [`career-ops-ui`](https://github.com/Fighter90/career-ops-ui) in `career-ops/web-ui/` così che *"apri la dashboard"* funzioni (vedi §6).

## 3. Install the coworker into OpenWorker

> **Nuovo qui?** Il [README](https://github.com/Fighter90/career-ops-coworker#deploying--running--full-walkthrough) del repo ha una guida completa di deployment passo passo (prerequisiti → chiave del modello → cartella → connettori → prima esecuzione → dashboard → aggiornamento → risoluzione problemi). Questa sezione è la versione breve.

**Il più veloce — un comando.** Prepara la pipeline che il coworker guida (idempotente — riusa un `career-ops` / `web-ui` esistente), poi stampa i passaggi di OpenWorker:

```bash
curl -fsSL https://raw.githubusercontent.com/Fighter90/career-ops-coworker/main/install.sh | bash
```

In **Install a coworker** di OpenWorker, aggiungilo in uno dei tre modi: **GitHub URL** (`https://github.com/Fighter90/career-ops-coworker`), **.zip** (dalle Releases) o **Import** del file `career-ops.md`. Tutti e tre installano la stessa persona — disattivata in attesa del tuo consenso.

1. Ottieni `career-ops.md` — clona questo repository o scarica il singolo file.
2. In OpenWorker: **New coworker → Import** e seleziona `career-ops.md` (oppure indica a OpenWorker la cartella di questo repository).
3. All'importazione il file viene **acquisito come snapshot nell'area gestita di OpenWorker**. Le modifiche successive in questo repository non cambiano una copia installata — reimporta per aggiornare; il campo `version:` determina la nota «replaces vN».
4. Apri una sessione con **Job-Search Coworker** e scegli la tua cartella `career-ops` come cartella di lavoro.

> **Fiducia:** installa solo coworker che puoi leggere e di cui puoi rispondere — un coworker viene eseguito con accesso al tuo sistema. Questo non include alcun codice; comunque, apri prima [`career-ops.md`](../career-ops.md) così saprai esattamente come gli è stato indicato di comportarsi.

## 4. First run

Chiedi qualcosa di concreto, ad esempio:
- *«Scansiona le mie bacheche e dammi le 5 migliori corrispondenze per questa settimana».*
- *«Adatta il mio CV a questo annuncio: <incolla JD o URL>».*
- *«Quali candidature hanno bisogno di un follow-up, e preparane le bozze».*
- *«Apri il dashboard».*

Il coworker inizia ogni attività con un breve piano (il pannello di avanzamento), lavora una fase alla volta e termina con il **risultato concreto e la sua posizione** — una lista ristretta, un file CV adattato, un aggiornamento del tracker o una bozza di email.

## 5. The workflow, stage by stage

- **Scan** — esegue lo scanner del progetto (`npm run scan` → `node scan.mjs`; flag come `--dry-run`, `--company "<Name>"`, `--since 7`). Zero token API — puro HTTP verso bacheche pubbliche. Riporta quanti annunci e da quali fonti.
- **Score fit** — valuta ogni annuncio **0–5** rispetto al tuo CV + profile + two-pager, con una motivazione su una riga e le lacune concrete. Ordina e mostra i migliori.
- **Tailor** — su richiesta, scrive un CV specifico per il ruolo e una lettera di presentazione come file (in `reports/` o `applications/`). Fondato **solo** sui fatti già presenti nel tuo CV; non inventa mai un datore di lavoro, una data, una metrica o una competenza, e segnala una lacuna invece di mascherarla. (`npm run cv:verify-facts` è il gate di veridicità del progetto.)
- **Track** — aggiunge/aggiorna la riga in `data/applications.md` con lo stato canonico già usato dal progetto.
- **Follow up** — verifica la cadenza e **prepara la bozza** dell'email; l'invio richiede conferma.
- **Interviews** — su richiesta, inserisce gli slot dei colloqui nel tuo calendario e aggiunge promemoria di preparazione (previa conferma).

## 6. Launch the career-ops-ui dashboard from OpenWorker

Chiedi *«apri il dashboard»* e il coworker avvia la web UI locale:
- Preferito: `bash web-ui/bin/start.sh` — installa le dipendenze se necessario e serve su `http://127.0.0.1:4317`. Imposta `PORT=` per cambiare la porta, o `CAREER_OPS_ROOT=` se la UI si trova fuori dal progetto. Alternativa: `cd web-ui && npm start`.
- È un server **a esecuzione prolungata, solo locale** (si lega a `127.0.0.1`) che legge gli stessi file e non invia dati da nessuna parte. Il coworker lo avvia in background, attende la risposta di `GET /api/health`, poi ti fornisce l'URL.
- Fermalo con Ctrl-C nel suo terminale, o terminando il processo `node server/index.mjs`.

## 7. Connections (optional — you approve each)

| Connessione | Perché | Livello |
|---|---|---|
| **Gmail** | leggere le risposte dei recruiter; preparare bozze di follow-up / email di ringraziamento (l'invio richiede conferma) | core |
| **Google Calendar** | inserire slot dei colloqui e promemoria di preparazione | core |
| **GitHub** | supportare i punti del CV con i tuoi progetti e le tue pubblicazioni pubbliche | optional |
| **filesystem (MCP)** | montare esplicitamente la cartella di progetto, se preferisci MCP agli strumenti file integrati | optional |

Le connessioni sono dichiarate nel grant `connectors:` del frontmatter e mostrate nel pannello delle connessioni della sessione. Ogni scrittura o invio chiede comunque prima conferma.

## 8. Safety model

- **La veridicità è il prodotto.** Un fatto inventato nel CV può interrompere un processo di selezione. Ogni affermazione risale al tuo `cv.md`; ogni punto adattato è qualcosa che hai realmente fatto. Quando non è certo che il CV supporti un'affermazione, il coworker la omette e la segnala.
- **Sola lettura per impostazione predefinita.** La scansione e la valutazione sono gratuite. **L'invio di email, la modifica del calendario, la scrittura al di fuori del progetto o la sovrascrittura di `cv.md` richiedono conferma** — il coworker dichiara cosa farà e attende.
- **Locale e privato.** Il tuo CV, le cifre sullo stipendio e i report restano sulla tua macchina e non vengono mai inviati a un connettore che non hai richiesto.

## 9. Scheduling (automations)

Il coworker dichiara `scheduling: true`, quindi puoi impostare esecuzioni ricorrenti in OpenWorker — ad esempio un **brief di scansione mattutino** («ogni giorno feriale alle 8, scansiona e dammi le migliori nuove corrispondenze») o una **rassegna settimanale dei follow-up**. Le esecuzioni arrivano nell'app con trascrizioni complete; le esecuzioni non presidiate parcheggiano le loro richieste di conferma nella inbox invece di agire da sole.

## 10. Troubleshooting

- **«Nessun annuncio trovato».** Verifica che `portals.yml` elenchi aziende/bacheche abilitate e che la tua rete le raggiunga (alcune bacheche regionali sono bloccate da una VPN full-tunnel — disconnettila ed esegui di nuovo la scansione). Prova `npm run scan -- --dry-run` per l'anteprima.
- **Il dashboard non si apre.** Assicurati che sia installato Node ≥ 18 e che la porta 4317 sia libera (`PORT=8080 bash web-ui/bin/start.sh`). Controlla `http://127.0.0.1:4317/api/health`.
- **Un CV adattato sembra scarno.** È il gate di veridicità che funziona — non inventa esperienza. Aggiungi le prove reali a `cv.md` (o al tuo GitHub) e riadatta.
- **Il coworker non invia un'email.** È voluto — gli invii richiedono conferma. Approva il check-in, oppure cambia la modalità dei permessi in OpenWorker se vuoi meno richieste (ma comprendi prima il compromesso).

## 11. Update & uninstall

- **Aggiornamento:** aggiorna questo repository (o riscarica `career-ops.md`) e reimporta in OpenWorker; l'incremento di `version:` mostra una nota «replaces vN».
- **Disinstallazione:** rimuovi il coworker dall'elenco dei coworker di OpenWorker. I file del tuo progetto `career-ops` restano intatti — il coworker ha sempre e solo letto e scritto i file che hai approvato.

## 12. FAQ

- **Servono i miei dati nel cloud?** No. Tutto è locale; solo il modello e i connettori che hai scelto vedono qualcosa, e solo ciò che approvi.
- **Quali modelli funzionano meglio?** Modelli forti nel tool-calling (il frontmatter raccomanda `anthropic:claude-opus-4-8` e `openai:gpt-5.5`); funziona bene anche un modello locale capace tramite Ollama.
- **Può candidarsi alle offerte al posto mio?** Prepara tutto — il CV adattato, la lettera di presentazione, la riga del tracker, il follow-up — ma ogni azione verso l'esterno (un invio) spetta a te approvarla. È un coworker, non un pilota automatico.
- **È affiliato a OpenWorker?** No. Punta al formato coworker di OpenWorker e al progetto open-source `career-ops`; entrambi sono con licenza MIT.
