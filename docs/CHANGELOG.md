# Changelog

All notable changes to **career-ops-coworker** are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to [Semantic Versioning](https://semver.org/). The coworker's own `version:` (in `career-ops.md` frontmatter) tracks the major line — OpenWorker shows it as the "replaces vN" note on re-import.

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
