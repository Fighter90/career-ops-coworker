# Changelog

All notable changes to **career-ops-coworker** are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to [Semantic Versioning](https://semver.org/). The coworker's own `version:` (in `career-ops.md` frontmatter) tracks the major line — OpenWorker shows it as the "replaces vN" note on re-import.

## [1.5.0] — 2026-09-27

Parity with `career-ops` v1.34.0 — the coworker writes the tracker the way the project does.

### Changed
- **Track goes through `set-status.mjs`, never a hand-edit.** The persona told the coworker to "append/update the row in `data/applications.md`" directly. The project's own modes (`apply`, `followup`, `tracker`, `outcome`, `patterns`) now all route status changes through **`node set-status.mjs <report#|company> <State>`** and say *never hand-edit the table*: it validates the state against the canonical set, holds the tracker lock, and appends the transition to `data/status-log.tsv` (the ledger `funnel-velocity.mjs` reads). A hand-edit skipped all three. The persona's *Track* helper and loop step 4 now name it, with `--on YYYY-MM-DD` (real event day), `--note`, `--role` and `--dry-run`; a brand-new row goes through the tracker-additions TSV + `npm run merge` (`merge-tracker.mjs`). README "What it does" table updated to match.

### Added
- **Setup helpers in the stage map.** A new *Before the first run* line names `npm run doctor` and **`node validate-profile.mjs`** (new in `career-ops`, 2026-09-25) — a misspelled `config/profile.yml` key otherwise parses cleanly and silently falls back to the default output language / spend tier. It warns, never fails.
- **Scan: discover what the scanners already saw.** `node discover-new-companies.mjs --out <file>` (new, 2026-09-25) lists companies found in `data/scan-history.tsv` that `portals.yml` does not track; `node discover-ats.mjs --in <file> --summary` previews their boards. Writing them into `portals.yml` (`--write`) is flagged approval-gated.
- `npm run cv:verify-ats` named next to `node verify-ats.mjs` in the persona and next to `cv:verify-facts` in the README.
- **Help ×17:** §5 *Track* gains the `set-status.mjs` sentence; §10 Troubleshooting gains a "a `config/profile.yml` setting seems ignored" bullet (`validate-profile.mjs`, `npm run doctor`). Bullets only — heading structure untouched, the 17-locale parity gate stays green. README troubleshooting table gains the same row.

### Verified
- Every script, flag and path the repo references re-checked against `career-ops` v1.34.0 (72 npm scripts): the six documented `npm run` scripts plus `cv:verify-ats`, `doctor`, `merge`; every `scan.mjs` flag (`--dry-run`, `--company`, `--since`, `--posted-after`, `--verify`, `--quiet`); all 19 previously-mapped helpers; the new `set-status.mjs` (`--on`/`--note`/`--role`/`--dry-run`), `validate-profile.mjs`, `discover-new-companies.mjs` (`--out`) and `discover-ats.mjs` (`--in`/`--summary`/`--write`). `career-ops-ui` (v1.237.x → v1.238.0): `bin/start.sh`, default port `4317`, `GET /api/health`, `node server/index.mjs`, Node ≥ 18 — all current. The persona states no source/adapter counts or versions of either project, so nothing there drifted.
- `scripts/validate-persona.py` — INSTALLABLE ✓. Help parity ×17 — 12 H2, unchanged. `bash -n` on `install.sh` and `scripts/build-bundle.sh`.

## [1.4.0] — 2026-08-29

The coworker now knows the project's deterministic helpers for the stages it already performs.

### Added
- **A loop-stage helper map in the persona.** The project ships ~70 npm scripts; the persona documented **6**, and none of them covered stages it explicitly claims to run. Each stage of the loop now names the zero-token CLI that does that job deterministically — so the coworker reaches for the project's own engine instead of reasoning it out from raw files:
  - *Scan* — `check-liveness.mjs` (is the posting still open?), `archive-posting.mjs`.
  - *Score* — `jd-skill-gap.mjs`, `jd-similarity.mjs`.
  - *Tailor* — **`verify-ats.mjs`**, run alongside `cv:verify-facts`, not instead of it: facts checks whether a claim is TRUE, ATS whether a résumé parser can READ it. Two different gates on the same document.
  - *Track* — `dedup-tracker.mjs`, `normalize-statuses.mjs`, `check-table-freshness.mjs`.
  - *Follow up* — **`followup-cadence.mjs`**, the single source of truth for who is due. The persona is now explicit that due-ness comes from its `urgency` field (`urgent` / `overdue` / `waiting` / `cold`) and **never** from the tracker `status` (`applied` / `responded` / `interview`), which answers a different question — a confusion that had already caused a real bug downstream in `career-ops-ui`.
  - *Review* — `weekly-digest.mjs`, `stats.mjs`, `salary-gap.mjs`, `company-history.mjs`.
  The list is marked indicative, not exhaustive; the standing instruction to read `package.json` for current names is unchanged.
- **Help ×17: the ATS gate and the cadence engine.** §5 "The workflow, stage by stage" now names `cv:verify-ats` next to `cv:verify-facts` in *Tailor*, and `followup-cadence.mjs` in *Follow up* with the same status-vs-urgency warning. Heading structure untouched — the 17-locale parity gate stays green.

### Verified
- Full re-audit of every concrete claim in the repo against the live projects: all 6 documented `npm run` scripts and their `.mjs` targets exist in [`Fighter90/career-ops`](https://github.com/Fighter90/career-ops); every `scan.mjs` flag the persona lists (`--dry-run`, `--company`, `--since`, `--posted-after`, `--verify`, `--quiet`) is real; `web-ui/bin/start.sh` and port `4317` are current; `cv.md`, `portals.yml`, `config/{profile.yml,two-pager.yml,memory.md}`, `data/applications.md` all present; the 12 newly-referenced helpers all exist. All six external URLs (openworker.com, the four GitHub repos, the upstream) return 200, as does the `install.sh` raw URL. **No stale claims found** — this release adds capability, it does not correct drift.
- `scripts/validate-persona.py` — INSTALLABLE ✓. Help parity ×17 — 12 H2, unchanged. Install bundle rebuilt.

## [1.3.1] — 2026-08-28

Maintenance — the recommended Anthropic model is current again.

### Changed
- **`recommended_models` now names `anthropic:claude-opus-5`** (was `anthropic:claude-opus-4-8`, a generation behind — the Claude 5 family is current). Updated in the persona frontmatter and in the "which models work best?" FAQ of the help guide ×17. `openai:gpt-5.5` is unchanged. This is a recommendation only: OpenWorker still runs whatever model the user has configured, including a local Ollama one, so no behavior changes for an existing install.

### Verified
- `scripts/validate-persona.py` — INSTALLABLE ✓ (OpenWorker manifest rules).
- Help-bundle parity ×17 — 12 H2 headings, structure unchanged.
- Every technical claim in the persona re-checked line by line against the live projects: all six `npm run` scripts (`scan`, `tracker`, `find`, `patterns`, `verify:portals`, `cv:verify-facts`) and their `.mjs` targets exist in `Fighter90/career-ops`; every `scan.mjs` flag the persona documents (`--dry-run`, `--company`, `--since`, `--posted-after`, `--verify`, `--quiet`) is real; `web-ui/bin/start.sh` and port `4317` are current. No other drift found.

## [1.3.0] — 2026-08-26

One-command install + install straight from the OpenWorker interface.

### Added
- **`install.sh` — one-command installer.** `curl -fsSL …/install.sh | bash` sets up everything the coworker drives — the `career-ops` pipeline and (optionally) the `web-ui` dashboard — then prints the three ways to install the persona in OpenWorker. It is **idempotent and non-destructive**: an already-set-up `career-ops` project or an already-installed `web-ui` is **detected and reused, never overwritten** (your `cv.md` / `portals.yml` / config are never touched); dependencies install only when missing. Overrides: `CAREER_OPS_ROOT`, `SKIP_UI`, `NO_CLONE_COWORKER`.
- **`.zip` install bundle.** `scripts/build-bundle.sh` builds `career-ops-coworker.zip` (the persona as `manifest.md` — OpenWorker's own share format), attached to the release, for the app's **".zip"** install option.

### Changed
- **Install straight from OpenWorker's "Install a coworker" panel — GitHub URL, folder, or .zip — now works.** OpenWorker's repo installer (`install_from_git` → `install_from_dir`) treats **every** top-level `*.md` as a persona and errors on the first non-persona one, so the repo now keeps **`career-ops.md` as the only root Markdown file**: `README.md` moved to `.github/README.md` (GitHub still renders it at the repo root), and `CHANGELOG.md` + `CLAUDE.md` moved to `docs/`. Previously only the single-file Import worked.
- **README rewritten install-first** — a one-command block and a three-method OpenWorker table (GitHub URL · .zip · Import) lead the page; the full manual walkthrough stays below. Help ×17 §3 gains the same one-command + three-methods note (heading structure unchanged — the 17-locale parity gate stays green).

## [1.2.0] — 2026-08-26

Documentation — a full deployment walkthrough.

### Added
- **README: "Deploying & running — full walkthrough"** — a detailed step-by-step guide (prerequisites → install OpenWorker + model key → set up the `career-ops` folder with a concrete `cv.md` / `config/profile.yml` / `portals.yml` schema table → optional dashboard → import the coworker → grant connectors → open a session → first run → updating → verify → troubleshooting). The old Quick start is kept as a TL;DR that links here.
- **Help guide ×17: the files you set up.** Section 2 now carries a `cv.md` / `config/profile.yml` / `portals.yml` / `config/two-pager.yml` schema table (translated in all 17 locales), and section 3 links to the README's full walkthrough. Heading structure unchanged — the 17-locale parity gate stays green.

## [1.1.0] — 2026-08-26

Hardening — install cleanly and stay green.

### Added
- **CI** (`.github/workflows/ci.yml`) — runs `scripts/validate-persona.py` (the OpenWorker installability gate) plus a **help-parity check** that fails if any of the 17 locale guides drifts from the English H2/H3 structure. So a persona or help regression can't merge unnoticed.

### Changed
- **Standardized the pipeline reference on [`Fighter90/career-ops`](https://github.com/Fighter90/career-ops)** across the persona, README, help (×17), and repo docs — the ecosystem the `career-ops-ui` dashboard belongs to, now carrying the full OpenAI-compatible provider roster. Upstream [`santifer/career-ops`](https://github.com/santifer/career-ops) is credited as the project it's based on.
- Confirmed the **launch-the-dashboard** instruction is robust whether `career-ops-ui` lives at `career-ops/web-ui/` or elsewhere (via `CAREER_OPS_ROOT=`).

## [1.0.0] — 2026-08-26

Initial release — the **Job-Search Coworker** for [OpenWorker](https://openworker.com).

### Added
- **`career-ops.md`** — the coworker (a persona: YAML frontmatter + system prompt). Drives an existing [`career-ops`](https://github.com/Fighter90/career-ops) project folder end to end: **scan** boards, **score** each posting 0–5 against the CV, **tailor** a grounded CV + cover letter, **track** applications, **draft** follow-ups. Read-only by default; sends/writes/CV-overwrites are approval-gated; never fabricates CV facts.
- **Launch the dashboard** — a documented capability to start the `career-ops-ui` web UI from OpenWorker (`bash web-ui/bin/start.sh` → `http://127.0.0.1:4317`), long-running, local-only.
- **`help/`** — a 12-section user guide translated into all **17** languages the `career-ops-ui` project ships (en, es, pt-BR, ko-KR, ja, ru, zh-CN, zh-TW, fr, pl, uk, da, ar, de, it, tr, hi).
- **`README.md`** — quick start, docs index, capability table, dashboard-launch, connections, safety model.
- **`CLAUDE.md` + `.claude/`** — guidance and config for editing this repo with Claude Code, including the installability invariant.
- **`LICENSE`** — MIT.

### Verified
- **Installable** against OpenWorker's own `parse_manifest` / `load_manifest_file` loader (id slug, permission mode, group, catalog tool ids `files/search/shell/todo`, and the `recommends ⊆ connectors` grant rule all pass; `to_agent()` materializes).
- **Pulls live vacancies** — the underlying scanner returns real postings from public boards (200+ from a public Greenhouse board in testing), with descriptions capped for consistent filtering.
- **Dashboard launches** — `career-ops-ui` starts on `127.0.0.1:4317` and answers `GET /api/health`.

### Notes
- A coworker ships **no code** — this repo is instructions + docs. OpenWorker snapshots the persona into its managed area on import; re-import to update.
- Recommended connectors (Gmail, Google Calendar, GitHub) and the `filesystem` MCP are declared but optional; every write/send is approval-gated.
