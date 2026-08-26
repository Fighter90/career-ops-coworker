# Changelog

All notable changes to **career-ops-coworker** are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to [Semantic Versioning](https://semver.org/). The coworker's own `version:` (in `career-ops.md` frontmatter) tracks the major line — OpenWorker shows it as the "replaces vN" note on re-import.

## [1.0.0] — 2026-08-26

Initial release — the **Job-Search Coworker** for [OpenWorker](https://openworker.com).

### Added
- **`career-ops.md`** — the coworker (a persona: YAML frontmatter + system prompt). Drives an existing [`career-ops`](https://github.com/santifer/career-ops) project folder end to end: **scan** boards, **score** each posting 0–5 against the CV, **tailor** a grounded CV + cover letter, **track** applications, **draft** follow-ups. Read-only by default; sends/writes/CV-overwrites are approval-gated; never fabricates CV facts.
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
