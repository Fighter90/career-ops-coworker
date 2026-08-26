<!-- Locale: Polish (pl). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — przewodnik użytkownika

Kompletny przewodnik po instalacji i uruchamianiu coworkera **career-ops** wewnątrz **[OpenWorker](https://openworker.com)**. Coworker zamienia OpenWorker w operatora poszukiwania pracy: skanuje tablice ofert, ocenia każde ogłoszenie względem Twojego CV, przygotowuje ugruntowane CV + list motywacyjny, śledzi aplikacje i tworzy szkice follow-upów — a także może otworzyć dla Ciebie dashboard `career-ops-ui`.

## 1. What this is (and isn't)

- **To jest** *persona* — pojedynczy plik Markdown ([`career-ops.md`](../career-ops.md)) z YAML-frontmatter (jakich możliwości potrzebuje) plus systemowy prompt (jak się zachowuje). „Coworker ⊇ skill”.
- **To nie jest** program. OpenWorker **nie** uruchamia zawartości tego repozytorium jako kodu. Frontmatter *deklaruje* zweryfikowane możliwości i rekomendowane konektory; prompt *steruje* agentem. Dlatego na ekranie instalacji widnieje: „no third-party code runs, but the instructions steer the coworker”.
- **Zarządza pipeline'em [`career-ops`](https://github.com/santifer/career-ops)**, a nie usługą hostowaną. Wszystko dzieje się na Twojej maszynie, w Twoim folderze projektu, z Twoim kluczem modelu.

## 2. Requirements

1. **Zainstalowany OpenWorker** — pobierz z [openworker.com](https://openworker.com) (macOS / Windows) lub uruchom ze źródeł. Dodaj klucz modelu (Anthropic, OpenAI, Google lub lokalny model przez Ollama).
2. **Folder projektu `career-ops`** na Twojej maszynie, skonfigurowany z Twoimi danymi:
   ```bash
   git clone https://github.com/santifer/career-ops
   cd career-ops
   # postępuj zgodnie z README tego projektu, aby utworzyć cv.md, config/profile.yml, portals.yml
   ```
   Coworker działa *wewnątrz* tego folderu i czyta/zapisuje `cv.md`, `config/profile.yml`, `config/two-pager.yml`, `portals.yml`, `data/applications.md` oraz `reports/`.

## 3. Install the coworker into OpenWorker

1. Pobierz `career-ops.md` — sklonuj to repozytorium lub pobierz pojedynczy plik.
2. W OpenWorker: **New coworker → Import** i wybierz `career-ops.md` (lub wskaż OpenWorker folder tego repozytorium).
3. Podczas importu plik zostaje **zapisany jako migawka w zarządzanym obszarze OpenWorker**. Późniejsze zmiany w tym repozytorium nie modyfikują zainstalowanej kopii — zaimportuj ponownie, aby zaktualizować; pole `version:` steruje adnotacją „replaces vN”.
4. Otwórz sesję z **Job-Search Coworker** i wybierz folder `career-ops` jako folder roboczy.

> **Zaufanie:** instaluj tylko tych coworkerów, których potrafisz przeczytać i za których możesz wziąć odpowiedzialność — coworker działa z dostępem do Twojego systemu. Ten nie zawiera kodu; mimo to najpierw otwórz [`career-ops.md`](../career-ops.md), aby dokładnie wiedzieć, jak polecono mu się zachowywać.

## 4. First run

Poproś o coś konkretnego, na przykład:
- *„Przeskanuj moje tablice ofert i podaj mi 5 najlepiej dopasowanych ofert na ten tydzień”.*
- *„Dopasuj moje CV do tego ogłoszenia: <wklej JD lub URL>”.*
- *„Które aplikacje wymagają follow-upu — przygotuj je”.*
- *„Otwórz dashboard”.*

Coworker zaczyna każde zadanie od krótkiego planu (panel postępu), pracuje etap po etapie i kończy **konkretnym rezultatem oraz wskazaniem, gdzie się znajduje** — lista finalistów, plik dopasowanego CV, aktualizacja trackera lub szkic wiadomości e-mail.

## 5. The workflow, stage by stage

- **Scan** — uruchamia skaner projektu (`npm run scan` → `node scan.mjs`; flagi takie jak `--dry-run`, `--company "<Name>"`, `--since 7`). Zero tokenów API — czysty HTTP wobec publicznych tablic ofert. Raportuje, ile ogłoszeń i z jakich źródeł.
- **Score fit** — ocenia każde ogłoszenie w skali **0–5** względem Twojego CV + profile + two-pager, z jednozdaniowym uzasadnieniem i konkretnymi brakami. Rankinguje i pokazuje kilka najlepszych.
- **Tailor** — na żądanie tworzy CV pod konkretną rolę i list motywacyjny jako pliki (w `reports/` lub `applications/`). Ugruntowane **wyłącznie** w faktach już obecnych w Twoim CV; nigdy nie wymyśla pracodawcy, daty, metryki ani umiejętności i sygnalizuje brak, zamiast go zamaskować. (`npm run cv:verify-facts` to projektowa bramka prawdziwości.)
- **Track** — dodaje/aktualizuje wiersz w `data/applications.md` z kanonicznym statusem, którego projekt już używa.
- **Follow up** — sprawdza rytm kontaktu i **przygotowuje szkic** wiadomości; wysyłka wymaga zatwierdzenia.
- **Interviews** — na żądanie umieszcza terminy rozmów w Twoim kalendarzu i dodaje przypomnienia o przygotowaniu (za zatwierdzeniem).

## 6. Launch the career-ops-ui dashboard from OpenWorker

Poproś *„otwórz dashboard”*, a coworker uruchomi lokalny interfejs webowy:
- Zalecane: `bash web-ui/bin/start.sh` — w razie potrzeby instaluje zależności i serwuje pod `http://127.0.0.1:4317`. Ustaw `PORT=`, aby zmienić port, lub `CAREER_OPS_ROOT=`, jeśli UI znajduje się poza projektem. Wariant zapasowy: `cd web-ui && npm start`.
- To **długo działający, wyłącznie lokalny** serwer (nasłuchuje na `127.0.0.1`), który czyta te same pliki i nigdzie nie wysyła danych. Coworker uruchamia go w tle, czeka na odpowiedź `GET /api/health`, a następnie przekazuje Ci URL.
- Zatrzymaj go klawiszami Ctrl-C w jego terminalu lub zabijając proces `node server/index.mjs`.

## 7. Connections (optional — you approve each)

| Podłączenie | Po co | Poziom |
|---|---|---|
| **Gmail** | czytanie odpowiedzi rekruterów; przygotowywanie szkiców follow-upów / wiadomości z podziękowaniami (wysyłka wymaga zatwierdzenia) | core |
| **Google Calendar** | umieszczanie terminów rozmów i przypomnień o przygotowaniu | core |
| **GitHub** | podpieranie punktów CV Twoimi publicznymi projektami i publikacjami | optional |
| **filesystem (MCP)** | jawne zamontowanie folderu projektu, jeśli wolisz MCP od wbudowanych narzędzi plikowych | optional |

Podłączenia są zadeklarowane w uprawnieniu `connectors:` we frontmatterze i widoczne w panelu podłączeń sesji. Każdy zapis lub wysyłka i tak najpierw pyta.

## 8. Safety model

- **Prawdziwość to produkt.** Sfabrykowany fakt w CV może zakończyć proces rekrutacji. Każde twierdzenie ma źródło w Twoim `cv.md`; każdy dopasowany punkt to rzeczywista rzecz, którą zrobiłeś. Gdy nie ma pewności, czy CV potwierdza dane twierdzenie, coworker je pomija i sygnalizuje.
- **Domyślnie tylko odczyt.** Skanowanie i ocenianie są darmowe. **Wysyłanie e-maili, zmiana kalendarza, zapis poza projektem lub nadpisanie `cv.md` wymagają zatwierdzenia** — coworker informuje, co zrobi, i czeka.
- **Lokalnie i prywatnie.** Twoje CV, dane o wynagrodzeniach i raporty pozostają na Twojej maszynie i nigdy nie są wysyłane do konektora, o który nie prosiłeś.

## 9. Scheduling (automations)

Coworker deklaruje `scheduling: true`, więc w OpenWorker możesz ustawić cykliczne uruchomienia — na przykład **poranny brief skanowania** („w każdy dzień roboczy o 8:00 przeskanuj i podaj mi najlepsze nowe dopasowania”) lub **cotygodniowy przegląd follow-upów**. Uruchomienia trafiają do aplikacji z pełnymi transkryptami; uruchomienia bez nadzoru odkładają swoje prośby o zatwierdzenie w inboxie, zamiast działać samodzielnie.

## 10. Troubleshooting

- **„Nie znaleziono ogłoszeń”.** Sprawdź, czy `portals.yml` zawiera włączone firmy/tablice ofert i czy Twoja sieć do nich dociera (niektóre regionalne tablice są blokowane przez VPN w trybie pełnego tunelu — rozłącz go i przeskanuj ponownie). Aby zobaczyć podgląd, spróbuj `npm run scan -- --dry-run`.
- **Dashboard się nie otwiera.** Upewnij się, że zainstalowany jest Node ≥ 18 i że port 4317 jest wolny (`PORT=8080 bash web-ui/bin/start.sh`). Sprawdź `http://127.0.0.1:4317/api/health`.
- **Dopasowane CV wygląda ubogo.** To działa bramka prawdziwości — nie wymyśli doświadczenia. Dodaj rzeczywiste dowody do `cv.md` (lub swojego GitHuba) i dopasuj ponownie.
- **Coworker nie wysyła wiadomości e-mail.** Tak zaprojektowano — wysyłki wymagają zatwierdzenia. Zatwierdź prośbę o potwierdzenie lub zmień tryb uprawnień w OpenWorker, jeśli chcesz mieć mniej zapytań (najpierw zrozum kompromis).

## 11. Update & uninstall

- **Aktualizacja:** zaktualizuj to repozytorium (lub pobierz ponownie `career-ops.md`) i zaimportuj ponownie do OpenWorker; podniesienie `version:` pokaże adnotację „replaces vN”.
- **Odinstalowanie:** usuń coworkera z listy coworkerów w OpenWorker. Pliki Twojego projektu `career-ops` pozostają nietknięte — coworker jedynie czytał i zapisywał pliki, które zatwierdziłeś.

## 12. FAQ

- **Czy potrzebuje moich danych w chmurze?** Nie. Wszystko jest lokalne; cokolwiek widzą wyłącznie wybrany przez Ciebie model i konektory — i tylko to, co zatwierdzisz.
- **Które modele działają najlepiej?** Silne modele z obsługą tool-callingu (frontmatter rekomenduje `anthropic:claude-opus-4-8` i `openai:gpt-5.5`); sprawdzi się też wydajny lokalny model przez Ollama.
- **Czy może aplikować na oferty za mnie?** Przygotowuje wszystko — dopasowane CV, list motywacyjny, wiersz w trackerze, follow-up — ale każde działanie na zewnątrz (wysyłkę) zatwierdzasz Ty. To coworker, a nie autopilot.
- **Czy jest to powiązane z OpenWorker?** Nie. Projekt jest ukierunkowany na format coworkera OpenWorker i open-source'owy projekt `career-ops`; oba są na licencji MIT.
