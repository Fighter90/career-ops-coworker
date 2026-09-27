# career-ops-coworker

**An [OpenWorker](https://github.com/andrewyng/openworker) coworker that runs your job search — end to end, on your machine.**

Scan job boards, score every posting against your CV, tailor a CV + cover letter grounded **only** in your real experience, track applications, draft follow-ups, and open the dashboard — all from OpenWorker. It delivers **finished deliverables**, never fabricates a CV fact, and asks before it sends or writes anything.

It's a thin, **code-free** steering layer over the open-source **[`career-ops`](https://github.com/Fighter90/career-ops)** pipeline (and its web UI, **[`career-ops-ui`](https://github.com/Fighter90/career-ops-ui)**). The whole coworker is one Markdown file — [`career-ops.md`](../career-ops.md).

> ✅ **Verified installable** against OpenWorker's own `parse_manifest` / `load_manifest_file` loader — and against its repo installer (`install_from_git` → `install_from_dir`), so the **GitHub-URL, folder, and .zip** install paths all work. The underlying pipeline is verified to pull live vacancies (e.g. 200+ postings from a public Greenhouse board) and to launch the dashboard on `127.0.0.1:4317`.

---

## Install

### 1 · One command (sets up everything the coworker drives)

```bash
curl -fsSL https://raw.githubusercontent.com/Fighter90/career-ops-coworker/main/install.sh | bash
```

This **idempotent, non-destructive** installer **checks for an existing `career-ops` project and `web-ui` dashboard and reuses them untouched** if they're already installed — cloning only what's missing, and installing npm dependencies only when they're absent. Your `cv.md` / `portals.yml` / `config/` are **never** modified. Re-run it any time; it only fills gaps. When it finishes it prints the three ways to install the persona in OpenWorker (below).

| Override | Effect |
|---|---|
| `CAREER_OPS_ROOT=/path` | use/create the `career-ops` project here (default `~/career-ops`); an existing project there is detected and reused |
| `SKIP_UI=1` | don't set up the `web-ui` dashboard |
| `NO_CLONE_COWORKER=1` | don't clone this repo locally (URL/zip install only) |

> Prefer to do it by hand? The **[full walkthrough](#deploying--running--full-walkthrough)** below explains every step.

### 2 · Install the coworker in OpenWorker

Install [OpenWorker](https://openworker.com) and add a model key (Anthropic / OpenAI / Google, **or** a local [Ollama](https://ollama.com)). Then open **Install a coworker** and add this coworker **any one of three ways**:

| Method | What to do | Notes |
|---|---|---|
| **A · GitHub URL** | choose **GitHub URL**, paste `https://github.com/Fighter90/career-ops-coworker`, click **Install** | OpenWorker clones the repo and installs the persona. Works because **`career-ops.md` is the repo's only top-level Markdown file** (OpenWorker treats every root `*.md` as a persona). |
| **B · .zip** | download **`career-ops-coworker.zip`** from [Releases](https://github.com/Fighter90/career-ops-coworker/releases), then use the **.zip** option | The bundle is just the persona (as `manifest.md`) — OpenWorker's own share format. Rebuild locally with `bash scripts/build-bundle.sh`. |
| **C · Import / folder** | choose the file and pick **`career-ops.md`** (or point the **folder** option at a local clone) | The classic single-file import; the folder path also works now that the root holds only the persona. |

OpenWorker shows the coworker's **declared capabilities** (`tools: [files, search, shell, todo]`, `requires_folder: true`, recommended connectors) and lands it **disabled pending your consent** — approve it, then open a **Job-Search Coworker** session and choose your `career-ops` folder. Ask, in plain language:

> *"Scan my boards and give me the top 5 fits this week."*

> ⚠️ **Trust note (from OpenWorker):** only install coworkers from sources you can hold accountable — a coworker runs with access to your system. This one ships **no code**; read [`career-ops.md`](../career-ops.md) before installing so you know exactly how it behaves.

---

## Deploying & running — full walkthrough

Nothing here is a service you host; the coworker runs **on your machine inside the OpenWorker desktop app**, driving a local `career-ops` project folder. The [one-command installer](#1--one-command-sets-up-everything-the-coworker-drives) does Steps 2–4 for you; this section is the manual version (budget ~15 minutes for a first setup).

### Step 0 — Prerequisites

| Need | Why | Get it |
|---|---|---|
| **[OpenWorker](https://openworker.com)** | the desktop app that runs the coworker | openworker.com (macOS / Windows), or run from [source](https://github.com/andrewyng/openworker) |
| **Node.js ≥ 18** + **npm** | the `career-ops` pipeline + the dashboard are Node programs | [nodejs.org](https://nodejs.org) — check with `node -v` |
| **git** | to clone the repos | preinstalled on macOS/Linux; [git-scm.com](https://git-scm.com) on Windows |
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

### Step 4 — Install the coworker into OpenWorker

Pick whichever is easiest — all three land the same persona (see [Install → 2](#2--install-the-coworker-in-openworker) for the details):

- **GitHub URL** — paste `https://github.com/Fighter90/career-ops-coworker` into **Install a coworker → GitHub URL**.
- **.zip** — download `career-ops-coworker.zip` from [Releases](https://github.com/Fighter90/career-ops-coworker/releases) and use the **.zip** option.
- **Import** — clone and pick `career-ops.md`:
  ```bash
  git clone https://github.com/Fighter90/career-ops-coworker
  # OpenWorker → Install a coworker → pick career-ops.md
  ```

OpenWorker copies it into its managed install area (a **snapshot** — later edits to the source don't change an installed copy; **re-install to update**) and reads the persona's declared capabilities: `tools: [files, search, shell, todo]`, `requires_folder: true`, and the recommended connectors below.

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

Because install is a **snapshot**, re-install to pick up changes:

```bash
# URL/zip: re-run Install a coworker (same URL, or a fresh .zip) — it replaces the snapshot
# Import:  cd career-ops-coworker && git pull   → re-import career-ops.md
```

Update the pipeline + dashboard the same way you would any repo (`git pull && npm install` in `career-ops`, `git pull` in `web-ui`). Or just re-run the [one-command installer](#1--one-command-sets-up-everything-the-coworker-drives) — it updates in place.

### Verify the install

```bash
python3 scripts/validate-persona.py    # → "INSTALLABLE ✓" (needs: pip install pyyaml)
```

This runs the exact rules OpenWorker's own loader applies (id slug, permission mode, catalog tool ids, `recommends ⊆ connectors`). CI runs it on every push, plus a 17-locale help-parity check.

### Troubleshooting

| Symptom | Fix |
|---|---|
| **URL/folder install errors on a `*.md`** | OpenWorker installs **every** top-level `*.md` in the repo as a persona. This repo keeps `career-ops.md` as the **only** root Markdown file (README/CHANGELOG/CLAUDE live under `.github/` and `docs/`) precisely so the repo installer succeeds — don't add other `.md` files at the root. |
| **"choose a folder" keeps asking** | the persona is `requires_folder: true` — point it at the `career-ops` directory (the one with `cv.md`). |
| **Scan returns 0 postings** | check `portals.yml` is valid and the board slug is right; run `node scan.mjs --dry-run` from the folder to see errors. On a full-tunnel VPN, some boards (e.g. hh.ru) 403 — disconnect the VPN while scanning. |
| **A `config/profile.yml` setting seems ignored** (wrong output language, default `spend_tier`) | usually a misspelled key — run `node validate-profile.mjs` from the project folder to name it, and `npm run doctor` for the full setup checklist. |
| **"open the dashboard" fails** | ensure `web-ui/` exists inside the project (Step 3), or pass `CAREER_OPS_ROOT=/path/to/career-ops bash web-ui/bin/start.sh` if it lives elsewhere. |
| **Model errors / rate limits** | switch or fix the key in **OpenWorker's** settings (not this repo); lower `spend_tier` in `config/profile.yml` to use a cheaper model. |
| **A tailored CV looks thin** | that's the truthfulness gate working — it won't invent experience. Add the real detail to `cv.md` and re-tailor. |

More in the [full user guide](../help/en.md) (§10 Troubleshooting), in every language.

---

## Documentation

The full user guide lives in **[`help/`](../help/)**, translated into every language the `career-ops-ui` project ships:

| | | | |
|---|---|---|---|
| 🇬🇧 [English](../help/en.md) | 🇪🇸 [Español](../help/es.md) | 🇧🇷 [Português](../help/pt-BR.md) | 🇰🇷 [한국어](../help/ko-KR.md) |
| 🇯🇵 [日本語](../help/ja.md) | 🇷🇺 [Русский](../help/ru.md) | 🇨🇳 [简体中文](../help/zh-CN.md) | 🇹🇼 [繁體中文](../help/zh-TW.md) |
| 🇫🇷 [Français](../help/fr.md) | 🇵🇱 [Polski](../help/pl.md) | 🇺🇦 [Українська](../help/uk.md) | 🇩🇰 [Dansk](../help/da.md) |
| 🇸🇦 [العربية](../help/ar.md) | 🇩🇪 [Deutsch](../help/de.md) | 🇮🇹 [Italiano](../help/it.md) | 🇹🇷 [Türkçe](../help/tr.md) |
| 🇮🇳 [हिन्दी](../help/hi.md) | | | |

See the [CHANGELOG](../docs/CHANGELOG.md) for version history.

---

## What's in this repo

| Path | What it is |
|---|---|
| [`career-ops.md`](../career-ops.md) | **The coworker.** A persona: YAML frontmatter (declared capabilities + recommended connectors) + a system-prompt body. **The only top-level `.md`** — so OpenWorker's repo/URL installer picks it up cleanly. |
| [`install.sh`](../install.sh) | One-command installer — sets up the `career-ops` pipeline + `web-ui` (idempotent, non-destructive) and prints the OpenWorker install steps. |
| [`help/`](../help/) | The user guide, ×17 locales. |
| [`scripts/`](../scripts/) | `validate-persona.py` (the loader-rule check CI runs) + `build-bundle.sh` (builds the `.zip`). |
| [`.github/README.md`](README.md) · [`docs/CHANGELOG.md`](../docs/CHANGELOG.md) · [`docs/CLAUDE.md`](../docs/CLAUDE.md) | This README (GitHub renders it at the repo root), the changelog, and the repo-editing guide — kept **out of the root** so they don't look like personas to OpenWorker's installer. |
| [`.claude/`](../.claude/) | Config for editing this repo with Claude Code. |
| `LICENSE` | MIT. |

A coworker is **not code** — OpenWorker runs none of this repo as a program. Per its install note: *"no third-party code runs, but the instructions steer the coworker."*

---

## What it does

| Stage | What happens | Commands it drives |
|---|---|---|
| **Scan** | Pulls fresh postings from the boards in your `portals.yml`. Zero API tokens — pure HTTP. | `npm run scan` (`node scan.mjs`), `--dry-run` / `--company` / `--since` |
| **Score fit** | Rates each posting 0–5 against your CV + profile + two-pager, with the concrete gaps. | reads `cv.md`, `config/profile.yml`, `config/two-pager.yml` |
| **Tailor** | Writes a role-specific CV + cover letter as files, grounded **only** in your real experience. | `npm run cv:verify-facts` (truthfulness gate) + `npm run cv:verify-ats` (parseability gate) |
| **Track** | Updates `data/applications.md` with the project's canonical status — through the project's own write path, never by hand-editing the status cell. | `node set-status.mjs <report#\|company> <State>` (`--on YYYY-MM-DD`), `npm run merge` (new rows), `npm run tracker` |
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

> ⚠️ **Trust note (from OpenWorker):** only install coworkers from sources you can hold accountable — a coworker runs with access to your system. This one ships no code; read [`career-ops.md`](../career-ops.md) before installing so you know exactly how it behaves.

---

## Related projects & links

- **OpenWorker** — the host app this coworker runs in: [openworker.com](https://openworker.com) · [roster](https://openworker.com/#roster) · [github.com/andrewyng/openworker](https://github.com/andrewyng/openworker)
- **career-ops** — the job-search engine this coworker drives: [github.com/Fighter90/career-ops](https://github.com/Fighter90/career-ops) · [career-ops.org](https://career-ops.org) (based on upstream [santifer/career-ops](https://github.com/santifer/career-ops))
- **career-ops-ui** — the dashboard this coworker can launch: [github.com/Fighter90/career-ops-ui](https://github.com/Fighter90/career-ops-ui) · [cvstart.org](https://cvstart.org) · [wiki](https://github.com/Fighter90/career-ops-ui/wiki)

## License

MIT — see [LICENSE](../LICENSE). Not affiliated with OpenWorker or Andrew Ng; it targets the OpenWorker coworker format and the open-source `career-ops` project (both MIT).
