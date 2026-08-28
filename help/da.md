<!-- Locale: Danish (da). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — brugervejledning

En komplet vejledning til at installere og køre **career-ops**-coworkeren inde i **[OpenWorker](https://openworker.com)**. Coworkeren gør OpenWorker til en jobsøgningsoperatør: den scanner jobtavler, vurderer hvert opslag op mod dit CV, tilpasser et velfunderet CV + følgebrev, holder styr på ansøgninger og skriver udkast til opfølgninger — og den kan åbne `career-ops-ui`-dashboardet for dig.

## 1. What this is (and isn't)

- **Det er** en *persona* — en enkelt Markdown-fil ([`career-ops.md`](../career-ops.md)) med YAML-frontmatter (hvilke funktioner den ønsker) plus en systemprompt (hvordan den opfører sig). »En coworker ⊇ en skill«.
- **Det er ikke** et program. OpenWorker kører **intet** af dette repo som kode. Frontmatter *erklærer* efterprøvede funktioner og anbefalede connectors; prompten *styrer* agenten. Derfor står der på installationsskærmen »no third-party code runs, but the instructions steer the coworker«.
- **Den driver [`career-ops`](https://github.com/Fighter90/career-ops)-pipelinen**, ikke en hostet tjeneste. Alt sker på din maskine, i din projektmappe, med din modelnøgle.

## 2. Requirements

1. **OpenWorker** installeret — download fra [openworker.com](https://openworker.com) (macOS / Windows) eller kør fra kildekoden. Tilføj en modelnøgle (Anthropic, OpenAI, Google eller en lokal model via Ollama).
2. **En `career-ops`-projektmappe** på din maskine, sat op med dine data:
   ```bash
   git clone https://github.com/Fighter90/career-ops
   cd career-ops
   # følg det projekts README for at oprette cv.md, config/profile.yml, portals.yml
   ```
   Coworkeren arbejder *inde i* denne mappe og læser/skriver `cv.md`, `config/profile.yml`, `config/two-pager.yml`, `portals.yml`, `data/applications.md` og `reports/`.

**Filerne du opsætter** (fuldt skema i [`career-ops` README](https://github.com/Fighter90/career-ops)):

| Fil | Hvad der skal i |
|---|---|
| `cv.md` | dit rigtige CV i Markdown — den eneste sandhedskilde, coworkeren bygger på (den opfinder intet derudover). |
| `config/profile.yml` | mål-roller, senioritet, lokationer, remote-præference, løn og `spend_tier` (styrer modelomkostningen). |
| `portals.yml` | de boards, der skal scannes — et Greenhouse/Lever/Ashby-firmaslug eller en board-bred post som `{ name: Torre, provider: torre, search: "engineering manager", enabled: true }`. |
| `config/two-pager.yml` *(valgfrit)* | kan lide / skal have / dealbreakers, der skærper match-scoren. |

Kør `node scan.mjs --dry-run` fra denne mappe én gang for at bekræfte, at den henter opslag, før du kobler OpenWorker på.

**(valgfrit)** klon [`career-ops-ui`](https://github.com/Fighter90/career-ops-ui) ind i `career-ops/web-ui/`, så *"åbn dashboardet"* virker (se §6).

## 3. Install the coworker into OpenWorker

> **Ny her?** Repoets [README](https://github.com/Fighter90/career-ops-coworker#deploying--running--full-walkthrough) har en fuld trin-for-trin-udrulning (forudsætninger → modelnøgle → mappe → connectors → første kørsel → dashboard → opdatering → fejlfinding). Dette afsnit er kortversionen.

**Hurtigst — én kommando.** Den sætter den pipeline op, som coworkeren driver (idempotent — genbruger et eksisterende `career-ops` / `web-ui`) og udskriver derefter OpenWorker-trinene:

```bash
curl -fsSL https://raw.githubusercontent.com/Fighter90/career-ops-coworker/main/install.sh | bash
```

I OpenWorkers **Install a coworker** tilføjer du den på en af tre måder: **GitHub URL** (`https://github.com/Fighter90/career-ops-coworker`), **.zip** (fra Releases) eller **Import** af filen `career-ops.md`. Alle tre installerer den samme persona — deaktiveret indtil dit samtykke.

1. Hent `career-ops.md` — klon dette repo eller download den enkelte fil.
2. I OpenWorker: **New coworker → Import**, og vælg `career-ops.md` (eller peg OpenWorker på denne repo-mappe).
3. Ved import bliver filen **taget som et snapshot i OpenWorkers administrerede område**. Senere ændringer i dette repo ændrer ikke en installeret kopi — genimportér for at opdatere; feltet `version:` styrer »replaces vN«-noten.
4. Åbn en session med **Job-Search Coworker**, og vælg din `career-ops`-mappe som arbejdsmappe.

> **Tillid:** installér kun coworkere, du kan læse og holde ansvarlige — en coworker kører med adgang til dit system. Denne indeholder ingen kode; åbn alligevel [`career-ops.md`](../career-ops.md) først, så du ved præcis, hvordan den får besked på at opføre sig.

## 4. First run

Bed om noget reelt, for eksempel:
- *»Scan mine jobtavler, og giv mig de 5 bedste match til denne uge«.*
- *»Tilpas mit CV til dette opslag: <indsæt JD eller URL>«.*
- *»Hvilke ansøgninger har brug for en opfølgning, og skriv udkast til dem«.*
- *»Åbn dashboardet«.*

Coworkeren starter hver opgave med en kort plan (Progress-panelet), arbejder ét trin ad gangen og slutter med **den faktiske leverance og hvor den ligger** — en shortlist, en tilpasset CV-fil, en opdatering af trackeren eller et udkast til en e-mail.

## 5. The workflow, stage by stage

- **Scan** — kører projektets scanner (`npm run scan` → `node scan.mjs`; flag som `--dry-run`, `--company "<Name>"`, `--since 7`). Nul API-tokens — ren HTTP mod offentlige jobtavler. Rapporterer hvor mange opslag og fra hvilke kilder.
- **Score fit** — vurderer hvert opslag **0–5** op mod dit CV + profile + two-pager, med en begrundelse på én linje og de konkrete mangler. Rangerer og fremhæver de bedste af dem.
- **Tailor** — skriver på forespørgsel et rollespecifikt CV og et følgebrev som filer (under `reports/` eller `applications/`). Funderet **kun** i fakta, der allerede findes i dit CV; den opfinder aldrig en arbejdsgiver, dato, måltal eller færdighed og markerer en mangel i stedet for at dække over den. (`npm run cv:verify-facts` er projektets sandhedsgate.)
- **Track** — tilføjer/opdaterer rækken i `data/applications.md` med den kanoniske status, som projektet allerede bruger.
- **Follow up** — tjekker kadencen og **skriver udkast** til e-mailen; afsendelse kræver godkendelse.
- **Interviews** — placerer på forespørgsel interviewtider i din kalender og tilføjer forberedelsespåmindelser (kræver godkendelse).

## 6. Launch the career-ops-ui dashboard from OpenWorker

Bed om *»åbn dashboardet«*, og coworkeren starter den lokale web-UI:
- Foretrukket: `bash web-ui/bin/start.sh` — installerer afhængigheder om nødvendigt og serverer på `http://127.0.0.1:4317`. Sæt `PORT=` for at ændre porten, eller `CAREER_OPS_ROOT=`, hvis UI'et ligger uden for projektet. Reserveløsning: `cd web-ui && npm start`.
- Det er en **langtidskørende, kun lokal** server (binder til `127.0.0.1`), som læser de samme filer og ikke sender data nogen steder hen. Coworkeren starter den i baggrunden, venter på, at `GET /api/health` svarer, og giver dig så URL'en.
- Stop den med Ctrl-C i dens terminal eller ved at dræbe processen `node server/index.mjs`.

## 7. Connections (optional — you approve each)

| Forbindelse | Hvorfor | Niveau |
|---|---|---|
| **Gmail** | læs svar fra rekrutterere; skriv udkast til opfølgnings- / takke-e-mails (afsendelse kræver godkendelse) | core |
| **Google Calendar** | placér interviewtider og forberedelsespåmindelser | core |
| **GitHub** | underbyg CV-punkter med dine offentlige projekter og publikationer | optional |
| **filesystem (MCP)** | montér projektmappen eksplicit, hvis du foretrækker MCP frem for de indbyggede filværktøjer | optional |

Forbindelser erklæres i frontmatterens `connectors:`-grant og vises i sessionens forbindelsespanel. Enhver skrivning eller afsendelse spørger stadig først.

## 8. Safety model

- **Sandhed er produktet.** En opdigtet CV-oplysning kan afslutte en ansættelsesproces. Hvert udsagn kan spores til dit `cv.md`; hvert tilpasset punkt er noget, du faktisk har gjort. Er coworkeren i tvivl om, hvorvidt CV'et understøtter et udsagn, udelader den det og markerer det.
- **Kun læsning som standard.** Scanning og scoring er gratis. **Afsendelse af e-mail, ændring af din kalender, skrivning uden for projektet eller overskrivning af `cv.md` kræver godkendelse** — coworkeren fortæller, hvad den vil gøre, og venter.
- **Lokalt og privat.** Dit CV, løntal og rapporter forbliver på din maskine og bliver aldrig sendt til en connector, du ikke har bedt om.

## 9. Scheduling (automations)

Coworkeren erklærer `scheduling: true`, så du kan opsætte tilbagevendende kørsler i OpenWorker — for eksempel et **morgen-scanningsbrief** (»scan hver hverdag klokken 8, og giv mig de bedste nye match«) eller en **ugentlig opfølgningsrunde**. Kørsler lander i appen med fulde transskriptioner; kørsler uden opsyn parkerer deres godkendelsesanmodninger i indbakken i stedet for at handle på egen hånd.

## 10. Troubleshooting

- **»Ingen opslag fundet«.** Bekræft, at `portals.yml` viser aktiverede virksomheder/jobtavler, og at dit netværk kan nå dem (nogle regionale jobtavler er blokeret bag en full-tunnel-VPN — afbryd den, og scan igen). Prøv `npm run scan -- --dry-run` for at få en forhåndsvisning.
- **Dashboardet vil ikke åbne.** Sørg for, at Node ≥ 18 er installeret, og at port 4317 er fri (`PORT=8080 bash web-ui/bin/start.sh`). Tjek `http://127.0.0.1:4317/api/health`.
- **Et tilpasset CV ser tyndt ud.** Det er sandhedsgaten, der virker — den opfinder ikke erfaring. Tilføj de reelle beviser til `cv.md` (eller din GitHub), og tilpas igen.
- **Coworkeren vil ikke sende en e-mail.** Sådan er det designet — afsendelser kræver godkendelse. Godkend check-in'et, eller skift tilladelsestilstand i OpenWorker, hvis du vil have færre bekræftelser (forstå kompromiset først).

## 11. Update & uninstall

- **Opdatering:** pull dette repo (eller download `career-ops.md` igen), og genimportér til OpenWorker; hævningen af `version:` viser en »replaces vN«-note.
- **Afinstallation:** fjern coworkeren i OpenWorkers liste over coworkere. Filerne i dit `career-ops`-projekt er urørte — coworkeren læste og skrev kun de filer, du godkendte.

## 12. FAQ

- **Skal mine data ligge i skyen?** Nej. Alt er lokalt; kun din valgte model og dine connectors ser overhovedet noget, og kun det, du godkender.
- **Hvilke modeller fungerer bedst?** Stærke modeller til tool-calling (frontmatteren anbefaler `anthropic:claude-opus-5` og `openai:gpt-5.5`); en kapabel lokal model via Ollama fungerer også.
- **Kan den søge job for mig?** Den forbereder alt — det tilpassede CV, følgebrevet, rækken i trackeren, opfølgningen — men enhver udadgående handling (en afsendelse) er din at godkende. Det er en coworker, ikke en autopilot.
- **Er dette tilknyttet OpenWorker?** Nej. Det er rettet mod OpenWorker-coworker-formatet og open source-projektet `career-ops`; begge er MIT-licenserede.
