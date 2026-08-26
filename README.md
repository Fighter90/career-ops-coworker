# career-ops-coworker

**An [OpenWorker](https://github.com/andrewyng/openworker) coworker that runs your job search — end to end, on your machine.**

Scan job boards, score every posting against your CV, tailor a CV + cover letter grounded **only** in your real experience, track applications, draft follow-ups, and open the dashboard — all from OpenWorker. It delivers **finished deliverables**, never fabricates a CV fact, and asks before it sends or writes anything.

It's a thin, **code-free** steering layer over the open-source **[`career-ops`](https://github.com/Fighter90/career-ops)** pipeline (and its web UI, **[`career-ops-ui`](https://github.com/Fighter90/career-ops-ui)**). The whole coworker is one Markdown file — [`career-ops.md`](./career-ops.md).

> ✅ **Verified installable** against OpenWorker's own `parse_manifest` / `load_manifest_file` loader, and the underlying pipeline is verified to pull live vacancies (e.g. 200+ postings from a public Greenhouse board) and to launch the dashboard on `127.0.0.1:4317`.

---

## Quick start (TL;DR)

```bash
# 1. Install OpenWorker + add a model key   → https://openworker.com
# 2. Clone the pipeline (your data lives here) and install its deps
git clone https://github.com/Fighter90/career-ops && cd career-ops && npm install
# 3. Add the dashboard (optional) so "open the dashboard" works
git clone https://github.com/Fighter90/career-ops-ui web-ui
# 4. Clone this coworker
git clone https://github.com/Fighter90/career-ops-coworker
```

In OpenWorker: **New coworker → Import** → pick `career-ops.md` → open a **Job-Search Coworker** session → choose your `career-ops` folder → ask *"Scan my boards and give me the top 5 fits this week."*

**New here? Follow the full walkthrough below** — it explains every step, the folder layout, connectors, and how to launch the dashboard.

---

## Deploying & running — full walkthrough

Nothing here is a service you host; the coworker runs **on your machine inside the OpenWorker desktop app**, driving a local `career-ops` project folder. Budget ~15 minutes for a first setup.

### Step 0 — Prerequisites

| Need | Why | Get it |
|---|---|---|
| **[OpenWorker](https://openworker.com)** | the desktop app that runs the coworker | openworker.com (macOS / Windows), or run from [source](https://github.com/andrewyng/openworker) |
| **Node.js ≥ 18** + **npm** | the `career-ops` pipeline + the dashboard are Node programs | [nodejs.org](https://nodejs.org) — check with `node -v` |
| **git** | to clone the two repos | preinstalled on macOS/Linux; [git-scm.com](https://git-scm.com) on Windows |
| **One model API key** | the coworker's reasoning (scoring, tailoring). Anthropic / OpenAI / Google, **or a fully local [Ollama](https://ollama.com)** | your provider's console; add it **in OpenWorker's model settings**, not here |

> This coworker ships **no code and no keys** — you add the model key to OpenWorker, and the pipeline reads job boards over plain HTTP (no key needed to scan).

### Step 1 — Install OpenWorker and add a model key

1. Install OpenWorker from [openworker.com](https://openworker.com) and open it.
2. In its **model / API-key settings**, paste a key for one provider (Anthropic, OpenAI, or Google), **or** point it at a local **Ollama** if you want to run entirely offline.
3. Confirm OpenWorker can reach the model (it shows the active model in the session header).

### Step 2 — Set up the `career-ops` project folder (your data)

This folder is where **your CV, job boards, and results live** — it never leaves your machine.

```bash
git clone https://github.com/Fighter90/career-ops
cd career-ops
npm install                       # installs the pipeline's dependencies
cp .env.example .env              # optional: only if you'll run live LLM evals from the CLI too
```

Then create/edit three files (see the [`career-ops` README](https://github.com/Fighter90/career-ops) for the full schema):

| File | What to put in it |
|---|---|
| **`cv.md`** | your real CV in Markdown — the single source of truth the coworker is grounded in (it will **never** invent facts beyond this). |
| **`config/profile.yml`** | target roles, seniority, locations, remote preference, salary expectation, `spend_tier` (controls model cost). |
| **`portals.yml`** | the job boards to scan. Start from the examples — e.g. a Greenhouse/Lever/Ashby company slug, or a board-wide entry like `{ name: Torre, provider: torre, search: "engineering manager", enabled: true }`. |
| *(optional)* **`config/two-pager.yml`** | a candidate "two-pager" (loves / must-haves / deal-breakers) that sharpens fit scoring. |

> **Tip:** run `node scan.mjs --dry-run` once from this folder to confirm it pulls postings before wiring up OpenWorker.

### Step 3 — (Optional) add the dashboard so "open the dashboard" works

The coworker can launch the **[`career-ops-ui`](https://github.com/Fighter90/career-ops-ui)** web dashboard. It expects it at `career-ops/web-ui/`:

```bash
# from inside your career-ops folder:
git clone https://github.com/Fighter90/career-ops-ui web-ui
```

If you keep the dashboard elsewhere, that's fine too — see [**Launch the dashboard**](#launch-the-career-ops-ui-dashboard-from-openworker) below for the `CAREER_OPS_ROOT=` form.

### Step 4 — Import the coworker into OpenWorker

```bash
git clone https://github.com/Fighter90/career-ops-coworker
```

In OpenWorker:

1. **New coworker → Import**, and pick **`career-ops.md`** from the cloned repo.
2. OpenWorker copies it into its managed install area (a snapshot — later edits to the repo don't change an installed copy; **re-import to update**).
3. It reads the persona's declared capabilities: `tools: [files, search, shell, todo]`, `requires_folder: true`, and the recommended connectors below.

### Step 5 — Grant connectors (optional, each is approved by you)

The persona **recommends** three connectors; grant only what you want. Reads are free; **anything consequential is approval-gated**.

| Connector | Enables | Tier |
|---|---|---|
| **Gmail** | read recruiter replies; **draft** follow-up / thank-you emails (sending asks first) | core |
| **Google Calendar** | place interview slots + prep reminders (asks first) | core |
| **GitHub** | back CV bullets with your public projects / publications | optional |

You can skip all three and still scan, score, tailor, and track — those need only the folder.

### Step 6 — Open a session and pick your folder

1. Open a **Job-Search Coworker** session in OpenWorker.
2. When it asks for a folder (`requires_folder: true`), choose your **`career-ops`** directory.
3. You're ready. Try, in plain language:

> *"Scan my boards and give me the top 5 fits this week."*
> *"Tailor my CV for this posting: `<URL>` and write a cover letter."*
> *"Who's waiting on a reply — draft follow-ups."*
> *"Open the dashboard."*

### Step 7 — First run, end to end

A typical first session: **scan** → **score fits (0–5)** → you pick one → **tailor** a grounded CV + cover letter (files written into the project) → **track** the application → **draft** a follow-up when a reply lands. Every send/write/CV-overwrite pauses for your approval; nothing is fabricated.

### Updating the coworker

Because install is a **snapshot**, pull the repo and **re-import** `career-ops.md`:

```bash
cd career-ops-coworker && git pull
# then in OpenWorker: New coworker → Import → career-ops.md  (replaces the installed copy)
```

Update the pipeline + dashboard the same way you would any repo (`git pull && npm install` in `career-ops`, `git pull` in `web-ui`).

### Verify the install

```bash
python3 scripts/validate-persona.py    # → "INSTALLABLE ✓" (needs: pip install pyyaml)
```

This runs the exact rules OpenWorker's own loader applies (id slug, permission mode, catalog tool ids, `recommends ⊆ connectors`). CI runs it on every push, plus a 17-locale help-parity check.

### Troubleshooting

| Symptom | Fix |
|---|---|
| **"choose a folder" keeps asking** | the persona is `requires_folder: true` — point it at the `career-ops` directory (the one with `cv.md`). |
| **Scan returns 0 postings** | check `portals.yml` is valid and the board slug is right; run `node scan.mjs --dry-run` from the folder to see errors. On a full-tunnel VPN, some boards (e.g. hh.ru) 403 — disconnect the VPN while scanning. |
| **"open the dashboard" fails** | ensure `web-ui/` exists inside the project (Step 3), or pass `CAREER_OPS_ROOT=/path/to/career-ops bash web-ui/bin/start.sh` if it lives elsewhere. |
| **Model errors / rate limits** | switch or fix the key in **OpenWorker's** settings (not this repo); lower `spend_tier` in `config/profile.yml` to use a cheaper model. |
| **A tailored CV looks thin** | that's the truthfulness gate working — it won't invent experience. Add the real detail to `cv.md` and re-tailor. |

More in the [full user guide](./help/en.md) (§10 Troubleshooting), in every language.

---

## Documentation

The full user guide lives in **[`help/`](./help/)**, translated into every language the `career-ops-ui` project ships:

| | | | |
|---|---|---|---|
| 🇬🇧 [English](./help/en.md) | 🇪🇸 [Español](./help/es.md) | 🇧🇷 [Português](./help/pt-BR.md) | 🇰🇷 [한국어](./help/ko-KR.md) |
| 🇯🇵 [日本語](./help/ja.md) | 🇷🇺 [Русский](./help/ru.md) | 🇨🇳 [简体中文](./help/zh-CN.md) | 🇹🇼 [繁體中文](./help/zh-TW.md) |
| 🇫🇷 [Français](./help/fr.md) | 🇵🇱 [Polski](./help/pl.md) | 🇺🇦 [Українська](./help/uk.md) | 🇩🇰 [Dansk](./help/da.md) |
| 🇸🇦 [العربية](./help/ar.md) | 🇩🇪 [Deutsch](./help/de.md) | 🇮🇹 [Italiano](./help/it.md) | 🇹🇷 [Türkçe](./help/tr.md) |
| 🇮🇳 [हिन्दी](./help/hi.md) | | | |

See the [CHANGELOG](./CHANGELOG.md) for version history.

---

## What's in this repo

| File | What it is |
|---|---|
| [`career-ops.md`](./career-ops.md) | **The coworker.** A persona: YAML frontmatter (declared capabilities + recommended connectors) + a system-prompt body. This is what you import into OpenWorker. |
| [`help/`](./help/) | The user guide, ×17 locales. |
| [`CHANGELOG.md`](./CHANGELOG.md) | Version history. |
| [`CLAUDE.md`](./CLAUDE.md) · [`.claude/`](./.claude/) | Guidance + config for editing this repo with Claude Code. |
| `LICENSE` | MIT. |

A coworker is **not code** — OpenWorker runs none of this repo as a program. Per its install note: *"no third-party code runs, but the instructions steer the coworker."*

---

## What it does

| Stage | What happens | Commands it drives |
|---|---|---|
| **Scan** | Pulls fresh postings from the boards in your `portals.yml`. Zero API tokens — pure HTTP. | `npm run scan` (`node scan.mjs`), `--dry-run` / `--company` / `--since` |
| **Score fit** | Rates each posting 0–5 against your CV + profile + two-pager, with the concrete gaps. | reads `cv.md`, `config/profile.yml`, `config/two-pager.yml` |
| **Tailor** | Writes a role-specific CV + cover letter as files, grounded **only** in your real experience. | `npm run cv:verify-facts` (truthfulness gate) |
| **Track** | Updates `data/applications.md` with the project's canonical status. | `npm run tracker` |
| **Follow up** | Drafts the email; sending is approval-gated. | Gmail connector |
| **Interviews** | Places slots on your calendar; approval-gated. | Google Calendar connector |
| **Dashboard** | Opens the `career-ops-ui` web UI locally. | `bash web-ui/bin/start.sh` → `http://127.0.0.1:4317` |

---

## Launch the career-ops-ui dashboard from OpenWorker

Ask *"open the dashboard"* and the coworker starts the local web UI — a browser view of your scan results, tracker, CV Studio, and stats:

```bash
bash web-ui/bin/start.sh            # installs deps, serves http://127.0.0.1:4317
PORT=8080 bash web-ui/bin/start.sh  # custom port
# fallback:
cd web-ui && npm start              # node server/index.mjs
```

It's a **long-running, local-only** server (binds `127.0.0.1`, sends data nowhere). The coworker starts it in the background, waits for `GET /api/health`, and hands you the URL. Stop it with Ctrl-C or by killing the `node server/index.mjs` process.

---

## Recommended connections (optional — you approve each)

| Connection | Why | Tier |
|---|---|---|
| **Gmail** | read recruiter replies; draft follow-up / thank-you emails (**sending is approval-gated**) | core |
| **Google Calendar** | place interview slots + prep reminders | core |
| **GitHub** | back CV bullets with your public projects / publications | optional |
| **filesystem (MCP)** | mount the project folder explicitly, if you prefer MCP | optional |

---

## Safety model

- **Truthfulness is the product.** Every claim on a tailored CV traces to a real fact in your `cv.md`. The coworker is instructed to **never invent** an employer, date, metric, title, or skill — it flags gaps instead of papering over them.
- **Read-only by default.** Scanning and scoring are free; **sending email, changing your calendar, writing outside the project, or overwriting `cv.md` are approval-gated**.
- **Local & private.** Your CV, salary numbers, and reports stay on your machine; they're never posted to a connector you didn't ask for.

> ⚠️ **Trust note (from OpenWorker):** only install coworkers from sources you can hold accountable — a coworker runs with access to your system. This one ships no code; read [`career-ops.md`](./career-ops.md) before installing so you know exactly how it behaves.

---

## Related projects & links

- **OpenWorker** — the host app this coworker runs in: [openworker.com](https://openworker.com) · [roster](https://openworker.com/#roster) · [github.com/andrewyng/openworker](https://github.com/andrewyng/openworker)
- **career-ops** — the job-search engine this coworker drives: [github.com/Fighter90/career-ops](https://github.com/Fighter90/career-ops) · [career-ops.org](https://career-ops.org) (based on upstream [santifer/career-ops](https://github.com/santifer/career-ops))
- **career-ops-ui** — the dashboard this coworker can launch: [github.com/Fighter90/career-ops-ui](https://github.com/Fighter90/career-ops-ui) · [cvstart.org](https://cvstart.org) · [wiki](https://github.com/Fighter90/career-ops-ui/wiki)

## License

MIT — see [LICENSE](./LICENSE). Not affiliated with OpenWorker or Andrew Ng; it targets the OpenWorker coworker format and the open-source `career-ops` project (both MIT).
