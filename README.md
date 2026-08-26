# career-ops-coworker

An **[OpenWorker](https://github.com/andrewyng/openworker) coworker** that runs a full, file-based job search on your desktop — scan boards, score each posting against your CV, tailor a CV + cover letter grounded only in your real experience, track every application, and draft follow-ups. It delivers **finished deliverables**, and never sends or fabricates anything without your say-so.

It's a thin, code-free steering layer on top of the open-source **[`career-ops`](https://github.com/santifer/career-ops)** pipeline (and its web UI, **[`career-ops-ui`](https://github.com/Fighter90/career-ops-ui)**). The whole coworker is one Markdown file — [`career-ops.md`](./career-ops.md).

## What's in the box

| File | What it is |
|---|---|
| [`career-ops.md`](./career-ops.md) | The coworker itself — a persona (YAML frontmatter + a system-prompt body). This is what you install. |
| `README.md` | This file. |
| `LICENSE` | MIT. |

A coworker is **not code** — OpenWorker runs none of this repo as a program. The frontmatter *declares* which vetted capabilities and connectors it wants, and the Markdown body *steers* the agent. (See OpenWorker's install note: "no third-party code runs, but the instructions steer the coworker.")

## Requirements

1. **OpenWorker** installed — [download](https://openworker.com) (macOS / Windows) or run from source. Add a model key (Anthropic/OpenAI/Google or local Ollama).
2. **A `career-ops` project folder** on your machine — the coworker operates *inside* it and drives its files and CLIs:
   ```bash
   git clone https://github.com/santifer/career-ops
   # then set up cv.md, config/profile.yml, portals.yml … per that project's README
   ```
   The coworker points at this folder (`requires_folder: true`) and reads/writes `cv.md`, `config/*`, `portals.yml`, `data/applications.md`, `reports/`.

## Install

**A) As a single file.** Copy `career-ops.md` into OpenWorker's coworkers folder (the app's *New coworker → Import* flow), or point OpenWorker at this repo. On import the file is **snapshotted into OpenWorker's managed area** — later edits here don't change an installed copy; re-import to update (the `version:` field drives the "replaces vN" note).

**B) From plain language.** OpenWorker can also *assemble* a coworker from a description — this file is a ready-made, reviewed version of exactly that, so you can read and adjust the workflow before trusting it with your search.

Then: open a session with the **Job-Search Coworker**, pick your `career-ops` folder as the working folder, and ask for something real — *"scan my boards and give me the top 5 fits for this week,"* or *"tailor my CV for this posting."*

## Recommended connections (optional, you approve each)

| Connection | Why | Tier |
|---|---|---|
| **Gmail** | read recruiter replies; draft follow-up / thank-you emails (**sending is approval-gated**) | core |
| **Google Calendar** | place interview slots + prep reminders | core |
| **GitHub** | back CV bullets with your public projects/publications | optional |
| **filesystem (MCP)** | read the project files if you prefer an explicit MCP mount | optional |

## Safety model (why you can trust it with a real search)

- **Truthfulness is the product.** Every claim on a tailored CV traces to a real fact in your `cv.md`. The coworker is instructed to **never invent** an employer, date, metric, title, or skill, and to flag gaps instead of papering over them.
- **Read-only by default.** Scanning and scoring are free; **sending email, changing your calendar, writing outside the project, or overwriting `cv.md` are approval-gated** — the coworker states what it will do and waits.
- **Local & private.** Your CV, salary numbers, and reports stay on your machine; they're never posted to a connector you didn't ask for.

> ⚠️ **Trust note (from OpenWorker):** only install coworkers from sources you can hold accountable — a coworker runs with access to your system. This one ships no code, but read [`career-ops.md`](./career-ops.md) before installing so you know exactly how it's told to behave.

## License

MIT — see [LICENSE](./LICENSE). Not affiliated with OpenWorker or Andrew Ng; it targets the OpenWorker coworker format and the `career-ops` project.
