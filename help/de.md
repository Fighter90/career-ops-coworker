<!-- Locale: German (de). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — Benutzerhandbuch

Eine vollständige Anleitung zur Installation und zum Ausführen des **career-ops**-Coworkers innerhalb von **[OpenWorker](https://openworker.com)**. Der Coworker macht OpenWorker zu einem Job-Search-Operator: Er durchsucht Jobbörsen, bewertet jede Stellenanzeige anhand Ihres CV, passt ein fundiertes CV + Anschreiben an, verfolgt Bewerbungen und entwirft Follow-ups — und er kann das `career-ops-ui`-Dashboard für Sie öffnen.

## 1. What this is (and isn't)

- **Es ist** eine *Persona* — eine einzelne Markdown-Datei ([`career-ops.md`](../career-ops.md)) mit YAML-Frontmatter (welche Fähigkeiten sie anfordert) plus einem System-Prompt (wie sie sich verhält). „Ein Coworker ⊇ ein Skill."
- **Es ist kein** Programm. OpenWorker führt **nichts** aus diesem Repository als Code aus. Das Frontmatter *deklariert* geprüfte Fähigkeiten und empfohlene Konnektoren; der Prompt *steuert* den Agenten. Deshalb steht auf dem Installationsbildschirm: „no third-party code runs, but the instructions steer the coworker".
- **Er steuert die [`career-ops`](https://github.com/Fighter90/career-ops)-Pipeline**, keinen gehosteten Dienst. Alles geschieht auf Ihrer Maschine, in Ihrem Projektordner, mit Ihrem Modell-Schlüssel.

## 2. Requirements

1. **OpenWorker** installiert — laden Sie es von [openworker.com](https://openworker.com) (macOS / Windows) herunter oder führen Sie es aus dem Quellcode aus. Fügen Sie einen Modell-Schlüssel hinzu (Anthropic, OpenAI, Google oder ein lokales Modell über Ollama).
2. **Ein `career-ops`-Projektordner** auf Ihrer Maschine, eingerichtet mit Ihren Daten:
   ```bash
   git clone https://github.com/Fighter90/career-ops
   cd career-ops
   # folgen Sie dem README dieses Projekts, um cv.md, config/profile.yml, portals.yml zu erstellen
   ```
   Der Coworker arbeitet *innerhalb* dieses Ordners und liest/schreibt `cv.md`, `config/profile.yml`, `config/two-pager.yml`, `portals.yml`, `data/applications.md` und `reports/`.

**Die Dateien, die du einrichtest** (vollständiges Schema im [`career-ops`-README](https://github.com/Fighter90/career-ops)):

| Datei | Was hineingehört |
|---|---|
| `cv.md` | dein echter Lebenslauf in Markdown — die einzige Wahrheitsquelle, auf die sich der Coworker stützt (er erfindet nichts darüber hinaus). |
| `config/profile.yml` | Zielrollen, Seniorität, Standorte, Remote-Präferenz, Gehalt und `spend_tier` (steuert die Modellkosten). |
| `portals.yml` | die zu scannenden Boards — ein Greenhouse/Lever/Ashby-Firmen-Slug oder ein board-weiter Eintrag wie `{ name: Torre, provider: torre, search: "engineering manager", enabled: true }`. |
| `config/two-pager.yml` *(optional)* | Vorlieben / Must-haves / Dealbreaker, die den Passungs-Score schärfen. |

Führe `node scan.mjs --dry-run` einmal aus diesem Ordner aus, um zu bestätigen, dass Anzeigen geladen werden, bevor du OpenWorker anbindest.

**(optional)** klone [`career-ops-ui`](https://github.com/Fighter90/career-ops-ui) nach `career-ops/web-ui/`, damit *„öffne das Dashboard“* funktioniert (siehe §6).

## 3. Install the coworker into OpenWorker

> **Neu hier?** Das [README](https://github.com/Fighter90/career-ops-coworker#deploying--running--full-walkthrough) des Repos enthält eine vollständige Schritt-für-Schritt-Bereitstellung (Voraussetzungen → Modell-Key → Ordner → Connectors → erster Lauf → Dashboard → Update → Fehlerbehebung). Dieser Abschnitt ist die Kurzfassung.

**Am schnellsten — ein Befehl.** Er richtet die Pipeline ein, die der Coworker steuert (idempotent — nutzt ein vorhandenes `career-ops` / `web-ui` weiter) und gibt dann die OpenWorker-Schritte aus:

```bash
curl -fsSL https://raw.githubusercontent.com/Fighter90/career-ops-coworker/main/install.sh | bash
```

Füge ihn in OpenWorkers **Install a coworker** auf eine von drei Arten hinzu: **GitHub URL** (`https://github.com/Fighter90/career-ops-coworker`), **.zip** (aus den Releases) oder **Import** der Datei `career-ops.md`. Alle drei installieren dieselbe Persona — deaktiviert bis zu deiner Zustimmung.

1. Besorgen Sie sich `career-ops.md` — klonen Sie dieses Repository oder laden Sie die einzelne Datei herunter.
2. In OpenWorker: **New coworker → Import** und wählen Sie `career-ops.md` (oder verweisen Sie OpenWorker auf den Ordner dieses Repositorys).
3. Beim Import wird die Datei **als Snapshot in den verwalteten Bereich von OpenWorker übernommen**. Spätere Änderungen in diesem Repository verändern eine installierte Kopie nicht — importieren Sie erneut, um zu aktualisieren; das Feld `version:` steuert den Hinweis „replaces vN".
4. Öffnen Sie eine Sitzung mit **Job-Search Coworker** und wählen Sie Ihren `career-ops`-Ordner als Arbeitsordner.

> **Vertrauen:** Installieren Sie nur Coworker, die Sie lesen und für die Sie geradestehen können — ein Coworker läuft mit Zugriff auf Ihr System. Dieser enthält keinen Code; öffnen Sie dennoch zuerst [`career-ops.md`](../career-ops.md), damit Sie genau wissen, wie ihm vorgegeben wird, sich zu verhalten.

## 4. First run

Bitten Sie um etwas Konkretes, zum Beispiel:
- *„Durchsuche meine Jobbörsen und gib mir die Top 5 der passenden Stellen für diese Woche."*
- *„Passe mein CV an diese Stellenanzeige an: <JD oder URL einfügen>."*
- *„Welche Bewerbungen brauchen ein Follow-up, und entwirf sie."*
- *„Öffne das Dashboard."*

Der Coworker beginnt jede Aufgabe mit einem kurzen Plan (dem Fortschrittspanel), arbeitet Schritt für Schritt und schließt mit dem **tatsächlichen Ergebnis und dem Hinweis, wo es liegt** ab — einer Shortlist, einer angepassten CV-Datei, einer Tracker-Aktualisierung oder einer entworfenen E-Mail.

## 5. The workflow, stage by stage

- **Scan** — führt den Projekt-Scanner aus (`npm run scan` → `node scan.mjs`; Flags wie `--dry-run`, `--company "<Name>"`, `--since 7`). Null API-Tokens — reines HTTP gegen öffentliche Jobbörsen. Meldet, wie viele Stellenanzeigen und aus welchen Quellen.
- **Score fit** — bewertet jede Stellenanzeige **0–5** anhand Ihres CV + profile + two-pager, mit einer einzeiligen Begründung und den konkreten Lücken. Ordnet sie und hebt die besten wenigen hervor.
- **Tailor** — schreibt auf Anfrage ein rollenspezifisches CV und ein Anschreiben als Dateien (unter `reports/` oder `applications/`). Ausschließlich in Fakten begründet, die bereits in Ihrem CV stehen; er erfindet niemals einen Arbeitgeber, ein Datum, eine Kennzahl oder eine Fähigkeit und markiert eine Lücke, statt sie zu übertünchen. (`npm run cv:verify-facts` ist das Wahrhaftigkeits-Gate des Projekts.)
- **Track** — hängt die Zeile in `data/applications.md` an bzw. aktualisiert sie mit dem kanonischen Status, den das Projekt bereits verwendet.
- **Follow up** — prüft die Kadenz und **entwirft** die E-Mail; das Senden erfordert eine Freigabe.
- **Interviews** — platziert auf Anfrage Interview-Termine in Ihrem Kalender und fügt Erinnerungen zur Vorbereitung hinzu (freigabepflichtig).

## 6. Launch the career-ops-ui dashboard from OpenWorker

Bitten Sie *„öffne das Dashboard"*, und der Coworker startet das lokale Web-UI:
- Bevorzugt: `bash web-ui/bin/start.sh` — installiert bei Bedarf Abhängigkeiten und stellt unter `http://127.0.0.1:4317` bereit. Setzen Sie `PORT=`, um den Port zu ändern, oder `CAREER_OPS_ROOT=`, falls das UI außerhalb des Projekts liegt. Ausweichlösung: `cd web-ui && npm start`.
- Es ist ein **langlebiger, rein lokaler** Server (bindet an `127.0.0.1`), der dieselben Dateien liest und Daten nirgendwohin sendet. Der Coworker startet ihn im Hintergrund, wartet, bis `GET /api/health` antwortet, und übergibt Ihnen dann die URL.
- Stoppen Sie ihn mit Ctrl-C in seinem Terminal oder indem Sie den Prozess `node server/index.mjs` beenden.

## 7. Connections (optional — you approve each)

| Verbindung | Wofür | Stufe |
|---|---|---|
| **Gmail** | Antworten von Recruitern lesen; Follow-up- / Dankes-E-Mails entwerfen (das Senden erfordert eine Freigabe) | core |
| **Google Calendar** | Interview-Termine und Erinnerungen zur Vorbereitung platzieren | core |
| **GitHub** | CV-Punkte mit Ihren öffentlichen Projekten und Publikationen untermauern | optional |
| **filesystem (MCP)** | den Projektordner explizit einbinden, falls Sie MCP den integrierten Datei-Tools vorziehen | optional |

Verbindungen werden im `connectors:`-Grant des Frontmatters deklariert und in der Verbindungsleiste der Sitzung angezeigt. Jedes Schreiben oder Senden fragt trotzdem zuerst nach.

## 8. Safety model

- **Wahrhaftigkeit ist das Produkt.** Ein erfundener Fakt im CV kann ein Einstellungsverfahren beenden. Jede Aussage lässt sich auf Ihr `cv.md` zurückführen; jeder angepasste Punkt ist etwas, das Sie tatsächlich getan haben. Wenn unklar ist, ob das CV eine Aussage stützt, lässt der Coworker sie weg und markiert sie.
- **Standardmäßig nur Lesen.** Scannen und Bewerten sind kostenlos. **Das Senden von E-Mails, das Ändern Ihres Kalenders, das Schreiben außerhalb des Projekts oder das Überschreiben von `cv.md` erfordern eine Freigabe** — der Coworker sagt, was er tun wird, und wartet.
- **Lokal und privat.** Ihr CV, Ihre Gehaltszahlen und Berichte bleiben auf Ihrer Maschine und werden niemals an einen Konnektor gesendet, den Sie nicht angefordert haben.

## 9. Scheduling (automations)

Der Coworker deklariert `scheduling: true`, sodass Sie in OpenWorker wiederkehrende Läufe einrichten können — zum Beispiel ein **morgendliches Scan-Briefing** („jeden Werktag um 8 Uhr scannen und mir die besten neuen passenden Stellen geben") oder einen **wöchentlichen Follow-up-Durchlauf**. Läufe landen mit vollständigen Transkripten in der App; unbeaufsichtigte Läufe parken ihre Freigabeanfragen im Inbox, statt eigenständig zu handeln.

## 10. Troubleshooting

- **„Keine Stellenanzeigen gefunden."** Vergewissern Sie sich, dass in `portals.yml` aktivierte Unternehmen/Jobbörsen aufgeführt sind und dass Ihr Netzwerk sie erreicht (einige regionale Jobbörsen werden hinter einem Full-Tunnel-VPN blockiert — trennen Sie es und scannen Sie erneut). Versuchen Sie `npm run scan -- --dry-run` für eine Vorschau.
- **Das Dashboard öffnet sich nicht.** Stellen Sie sicher, dass Node ≥ 18 installiert und Port 4317 frei ist (`PORT=8080 bash web-ui/bin/start.sh`). Prüfen Sie `http://127.0.0.1:4317/api/health`.
- **Ein angepasstes CV wirkt dünn.** Das ist das Wahrhaftigkeits-Gate bei der Arbeit — es erfindet keine Erfahrung. Fügen Sie die echten Belege zu `cv.md` (oder Ihrem GitHub) hinzu und passen Sie erneut an.
- **Der Coworker sendet keine E-Mail.** So gewollt — Sendevorgänge erfordern eine Freigabe. Bestätigen Sie den Check-in oder wechseln Sie in OpenWorker den Berechtigungsmodus, wenn Sie weniger Nachfragen möchten (verstehen Sie zuerst den Kompromiss).

## 11. Update & uninstall

- **Aktualisieren:** aktualisieren Sie dieses Repository (oder laden Sie `career-ops.md` erneut herunter) und importieren Sie es erneut in OpenWorker; die Erhöhung von `version:` zeigt einen Hinweis „replaces vN".
- **Deinstallieren:** entfernen Sie den Coworker in der Coworker-Liste von OpenWorker. Ihre `career-ops`-Projektdateien bleiben unberührt — der Coworker hat nur die Dateien gelesen und geschrieben, die Sie freigegeben haben.

## 12. FAQ

- **Braucht er meine Daten in der Cloud?** Nein. Alles ist lokal; überhaupt etwas sehen nur das von Ihnen gewählte Modell und die Konnektoren — und nur das, was Sie freigeben.
- **Welche Modelle funktionieren am besten?** Starke Modelle mit Tool-Calling (das Frontmatter empfiehlt `anthropic:claude-opus-5` und `openai:gpt-5.5`); ein leistungsfähiges lokales Modell über Ollama funktioniert ebenfalls.
- **Kann er sich für mich auf Stellen bewerben?** Er bereitet alles vor — das angepasste CV, das Anschreiben, die Tracker-Zeile, das Follow-up — aber jede nach außen gerichtete Aktion (ein Sendevorgang) müssen Sie freigeben. Er ist ein Coworker, kein Autopilot.
- **Steht dies in Verbindung mit OpenWorker?** Nein. Es zielt auf das Coworker-Format von OpenWorker und das Open-Source-Projekt `career-ops` ab; beide sind MIT-lizenziert.
