# career-ops-coworker — Agent Instructions

> Guidance for Claude Code (and equivalents) editing this repo. User instructions and `~/.claude/CLAUDE.md` take precedence.

## What this repo is

An **[OpenWorker](https://github.com/andrewyng/openworker) coworker** — a *persona* that steers OpenWorker to run the [`career-ops`](https://github.com/Fighter90/career-ops) job-search pipeline. The deliverable is **[`career-ops.md`](./career-ops.md)**: YAML frontmatter (declared capabilities + recommended connectors) followed by a Markdown system prompt. Everything else is documentation.

**This is not code.** OpenWorker runs nothing in this repo as a program — it snapshots the persona into a managed area and the *instructions* steer the agent. So there is no build, no test runner, no dependencies. The "correctness" bar is: (a) the persona parses and installs, (b) the docs are accurate and in sync, (c) the prompt is safe and honest.

## Hard rules — do NOT violate

1. **`career-ops.md` must stay installable.** It has to pass OpenWorker's own loader (`coworker/personas/manifest.py::parse_manifest` / `load_manifest_file`). After any frontmatter change, re-validate (see below). Known constraints:
   - `id` matches `^[a-z0-9][a-z0-9_-]{0,63}$` (it becomes a directory name).
   - `tools:` are only ids from OpenWorker's **closed** catalog: `code_files, files, git, search, shell, todo`. You cannot add new tool capabilities — third parties get breadth from MCP + recommended connectors, never by inventing catalog entries.
   - `default_permission_mode` ∈ {discuss, plan, interactive, custom, auto, bypass-approvals, auto-approve}; `group` ∈ {general, security}; `team` ∈ {lead, worker} or omitted.
   - **Every connector in `recommends:` must also appear in the `connectors:` grant** ("a recommendation must stay within the grant"). `mcp:` recommendations are exempt. This one bites — validate.
2. **The prompt encodes career-ops doctrine, faithfully.** Truthfulness is the product: never instruct the coworker to invent a CV fact; keep writes/sends approval-gated; keep it local-first and private. Don't add capabilities that would bypass approvals or exfiltrate `cv.md` / salary data.
3. **Reference real commands.** Job-search commands (`npm run scan`, `--dry-run`/`--company`/`--since`, `bin/start.sh`, `npm run cv:verify-facts`) must match the actual `career-ops` / `career-ops-ui` projects. When unsure, tell the prompt to read the project's `package.json` rather than hardcode a guess.
4. **Keep `help/` in sync across all 17 locales.** A change to the workflow, a command, or a section belongs in every `help/<lang>.md`. Keep the `##`/`###` headings identical across locales; translate prose only — never code, file names, CLI flags, or YAML keys.
5. **Docs must not overstate.** Only claim "verified" for things actually tested (installability via the real parser; live scan; dashboard launch). Keep the `README` "Verified" note honest.

## Validate the persona (the one real check)

OpenWorker's loader is Python. To confirm a change still installs, run its `parse_manifest` against the file with a stub catalog (the catalog ids above). A minimal harness: create a package `coworker/personas/manifest.py` (the real file) + `coworker/catalog.py` exposing `CATALOG = {"code_files","files","git","search","shell","todo"}` + stub `coworker/agents/base.py`, then `load_manifest_file("career-ops.md")` — it must return a `PersonaManifest` without raising `ManifestError`, and `.to_agent()` must materialize.

## Conventions

- **Frontmatter fields** mirror `PersonaManifest`: `id, name, icon, tagline, description, tools, requires_folder, subagents, scheduling, messaging, connectors, team, default_permission_mode, recommended_models, skills, mcp, version, recommends, ships, group`.
- **Versioning:** bump `version:` in the frontmatter on a meaningful prompt/behavior change, and add a `CHANGELOG.md` entry. There's no auto-update channel — `version` only drives OpenWorker's "replaces vN" note on re-import.
- **Related projects:** `career-ops` (engine, upstream `Fighter90/career-ops`), `career-ops-ui` (`Fighter90/career-ops-ui`, the dashboard this coworker can launch), `openworker` (`andrewyng/openworker`, the host).
