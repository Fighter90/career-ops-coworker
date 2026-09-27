<!-- Locale: English (en). Translations live beside this file as help/<lang>.md. Keep the ## / ### headings identical across locales; translate prose only, never the code, file names, CLI flags, or YAML keys. -->
# Job-Search Coworker — User Guide

A complete guide to installing and running the **career-ops** coworker inside **[OpenWorker](https://openworker.com)**. The coworker turns OpenWorker into a job-search operator: it scans boards, scores every posting against your CV, tailors a grounded CV + cover letter, tracks applications, and drafts follow-ups — and it can open the `career-ops-ui` dashboard for you.

## 1. What this is (and isn't)

- **It is** a *persona* — a single Markdown file ([`career-ops.md`](../career-ops.md)) with YAML frontmatter (what capabilities it wants) plus a system prompt (how it behaves). "A coworker ⊇ a skill."
- **It is not** a program. OpenWorker runs **none** of this repo as code. The frontmatter *declares* vetted capabilities and recommended connectors; the prompt *steers* the agent. That is why the install screen says "no third-party code runs, but the instructions steer the coworker."
- **It drives the [`career-ops`](https://github.com/Fighter90/career-ops) pipeline**, not a hosted service. Everything happens on your machine, in your project folder, with your model key.

## 2. Requirements

1. **OpenWorker** installed — download from [openworker.com](https://openworker.com) (macOS / Windows) or run from source. Add a model key (Anthropic, OpenAI, Google, or a local model via Ollama).
2. **A `career-ops` project folder** on your machine, set up with your data:
   ```bash
   git clone https://github.com/Fighter90/career-ops
   cd career-ops
   # follow that project's README to create cv.md, config/profile.yml, portals.yml
   ```
   The coworker operates *inside* this folder and reads/writes `cv.md`, `config/profile.yml`, `config/two-pager.yml`, `portals.yml`, `data/applications.md`, and `reports/`.

   **The files you set up** (full schema in the [`career-ops` README](https://github.com/Fighter90/career-ops)):

   | File | What to put in it |
   |---|---|
   | `cv.md` | your real CV in Markdown — the single source of truth the coworker is grounded in (it never invents beyond this). |
   | `config/profile.yml` | target roles, seniority, locations, remote preference, salary, and `spend_tier` (controls model cost). |
   | `portals.yml` | the job boards to scan — a Greenhouse/Lever/Ashby company slug, or a board-wide entry like `{ name: Torre, provider: torre, search: "engineering manager", enabled: true }`. |
   | `config/two-pager.yml` *(optional)* | loves / must-haves / deal-breakers that sharpen the fit scoring. |

   Run `node scan.mjs --dry-run` from this folder once to confirm it pulls postings before wiring up OpenWorker.
3. **(Optional) the dashboard** — clone [`career-ops-ui`](https://github.com/Fighter90/career-ops-ui) into `career-ops/web-ui/` so *"open the dashboard"* works (see §6).

## 3. Install the coworker into OpenWorker

> **New here?** The repo [README](https://github.com/Fighter90/career-ops-coworker#deploying--running--full-walkthrough) has a full step-by-step deployment walkthrough (prerequisites → model key → folder → connectors → first run → dashboard → updating → troubleshooting). This section is the short version.

**Fastest — one command.** It sets up the pipeline the coworker drives (idempotent — it reuses an existing `career-ops` / `web-ui`), then prints the OpenWorker steps:

```bash
curl -fsSL https://raw.githubusercontent.com/Fighter90/career-ops-coworker/main/install.sh | bash
```

In OpenWorker's **Install a coworker**, add it any of three ways: **GitHub URL** (`https://github.com/Fighter90/career-ops-coworker`), **.zip** (from Releases), or **Import** the `career-ops.md` file. All three land the same persona — disabled pending your consent.

1. Get `career-ops.md` — clone this repo or download the single file.
2. In OpenWorker: **New coworker → Import**, and pick `career-ops.md` (or point OpenWorker at this repo folder).
3. On import the file is **snapshotted into OpenWorker's managed area**. Later edits in this repo do not change an installed copy — re-import to update; the `version:` field drives the "replaces vN" note.
4. Open a session with **Job-Search Coworker** and choose your `career-ops` folder as the working folder.

> **Trust:** only install coworkers you can read and hold accountable — a coworker runs with access to your system. This one ships no code; still, open [`career-ops.md`](../career-ops.md) first so you know exactly how it is told to behave.

## 4. First run

Ask for something real, for example:
- *"Scan my boards and give me the top 5 fits for this week."*
- *"Tailor my CV for this posting: <paste JD or URL>."*
- *"Which applications need a follow-up, and draft them."*
- *"Open the dashboard."*

The coworker starts every task with a short plan (the Progress panel), works one stage at a time, and finishes with the **actual deliverable and where it lives** — a shortlist, a tailored CV file, a tracker update, or a drafted email.

## 5. The workflow, stage by stage

- **Scan** — runs the project scanner (`npm run scan` → `node scan.mjs`; flags like `--dry-run`, `--company "<Name>"`, `--since 7`). Zero API tokens — pure HTTP against public boards. Reports how many postings, from which sources.
- **Score fit** — rates each posting **0–5** against your CV + profile + two-pager, with a one-line reason and the concrete gaps. Ranks and surfaces the top handful.
- **Tailor** — on request, writes a role-specific CV and a cover letter as files (under `reports/` or `applications/`). Grounded **only** in facts already in your CV; it never invents an employer, date, metric, or skill, and flags a gap instead of papering over it. (`npm run cv:verify-facts` is the project's truthfulness gate; `npm run cv:verify-ats` is the companion parseability gate — facts checks whether a claim is TRUE, ATS whether a résumé parser can READ it.)
- **Track** — appends/updates the row in `data/applications.md` with the canonical status the project already uses. Status changes go through the project's canonical write path, `node set-status.mjs <report#|company> <State>` (add `--on YYYY-MM-DD` for the real event day) — it validates the state, holds the tracker lock and logs the transition, so the coworker never hand-edits the status cell.
- **Follow up** — checks cadence and **drafts** the email; sending is approval-gated. Due-ness comes from the project's own `node followup-cadence.mjs`, which classifies every application as urgent / overdue / waiting / cold — not from the tracker status, which answers a different question.
- **Interviews** — on request, places interview slots on your calendar and adds prep reminders (approval-gated).

## 6. Launch the career-ops-ui dashboard from OpenWorker

Ask *"open the dashboard"* and the coworker starts the local web UI:
- Preferred: `bash web-ui/bin/start.sh` — installs dependencies if needed and serves on `http://127.0.0.1:4317`. Set `PORT=` to change the port, or `CAREER_OPS_ROOT=` if the UI lives outside the project. Fallback: `cd web-ui && npm start`.
- It's a **long-running, local-only** server (binds `127.0.0.1`) that reads the same files and sends data nowhere. The coworker starts it in the background, waits for `GET /api/health` to answer, then hands you the URL.
- Stop it with Ctrl-C in its terminal, or by killing the `node server/index.mjs` process.

## 7. Connections (optional — you approve each)

| Connection | Why | Tier |
|---|---|---|
| **Gmail** | read recruiter replies; draft follow-up / thank-you emails (sending is approval-gated) | core |
| **Google Calendar** | place interview slots and prep reminders | core |
| **GitHub** | back CV bullets with your public projects and publications | optional |
| **filesystem (MCP)** | mount the project folder explicitly, if you prefer MCP over the built-in file tools | optional |

Connections are declared in the frontmatter's `connectors:` grant and surfaced in the session's connections drawer. Every write or send still asks first.

## 8. Safety model

- **Truthfulness is the product.** A fabricated CV fact can end a hiring process. Every claim traces to your `cv.md`; every tailored bullet is a real thing you did. When unsure whether the CV supports a claim, the coworker leaves it out and flags it.
- **Read-only by default.** Scanning and scoring are free. **Sending email, changing your calendar, writing outside the project, or overwriting `cv.md` are approval-gated** — the coworker states what it will do and waits.
- **Local and private.** Your CV, salary numbers, and reports stay on your machine and are never posted to a connector you did not ask for.

## 9. Scheduling (automations)

The coworker declares `scheduling: true`, so you can set recurring runs in OpenWorker — for example a **morning scan brief** ("every weekday at 8am, scan and give me the top new fits") or a **weekly follow-up sweep**. Runs land in the app with full transcripts; unattended runs park their approval requests in the inbox instead of acting on their own.

## 10. Troubleshooting

- **"No postings found."** Confirm `portals.yml` lists enabled companies/boards, and that your network reaches them (some regional boards are blocked behind a full-tunnel VPN — disconnect it and re-scan). Try `npm run scan -- --dry-run` to preview.
- **A `config/profile.yml` setting seems ignored** (wrong output language, default spend tier). Usually a misspelled key — `node validate-profile.mjs` names it, and `npm run doctor` prints the full setup checklist.
- **The dashboard won't open.** Ensure Node ≥ 18 is installed and port 4317 is free (`PORT=8080 bash web-ui/bin/start.sh`). Check `http://127.0.0.1:4317/api/health`.
- **A tailored CV looks thin.** That is the truthfulness gate working — it will not invent experience. Add the real evidence to `cv.md` (or your GitHub) and re-tailor.
- **The coworker won't send an email.** By design — sends are approval-gated. Approve the check-in, or switch permission mode in OpenWorker if you want fewer prompts (understand the trade-off first).

## 11. Update & uninstall

- **Update:** pull this repo (or re-download `career-ops.md`) and re-import into OpenWorker; the `version:` bump shows a "replaces vN" note.
- **Uninstall:** remove the coworker in OpenWorker's coworkers list. Your `career-ops` project files are untouched — the coworker only ever read and wrote the files you approved.

## 12. FAQ

- **Does it need my data in the cloud?** No. Everything is local; only your chosen model and connectors ever see anything, and only what you approve.
- **Which models work best?** Strong tool-calling models (the frontmatter recommends `anthropic:claude-opus-5` and `openai:gpt-5.5`); a capable local model via Ollama also works.
- **Can it apply to jobs for me?** It prepares everything — the tailored CV, the cover letter, the tracker row, the follow-up — but any outward action (a send) is yours to approve. It is a coworker, not an autopilot.
- **Is this affiliated with OpenWorker?** No. It targets the OpenWorker coworker format and the open-source `career-ops` project; both are MIT-licensed.
