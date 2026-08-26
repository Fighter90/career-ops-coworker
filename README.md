# career-ops-coworker

**An [OpenWorker](https://github.com/andrewyng/openworker) coworker that runs your job search — end to end, on your machine.**

Scan job boards, score every posting against your CV, tailor a CV + cover letter grounded **only** in your real experience, track applications, draft follow-ups, and open the dashboard — all from OpenWorker. It delivers **finished deliverables**, never fabricates a CV fact, and asks before it sends or writes anything.

It's a thin, **code-free** steering layer over the open-source **[`career-ops`](https://github.com/Fighter90/career-ops)** pipeline (and its web UI, **[`career-ops-ui`](https://github.com/Fighter90/career-ops-ui)**). The whole coworker is one Markdown file — [`career-ops.md`](./career-ops.md).

> ✅ **Verified installable** against OpenWorker's own `parse_manifest` / `load_manifest_file` loader, and the underlying pipeline is verified to pull live vacancies (e.g. 200+ postings from a public Greenhouse board) and to launch the dashboard on `127.0.0.1:4317`.

---

## Quick start

```bash
# 1. Get the OpenWorker app + a model key
#    → https://openworker.com   (macOS / Windows, or run from source)

# 2. Get a career-ops project folder (your data lives here)
git clone https://github.com/Fighter90/career-ops
#    → set up cv.md, config/profile.yml, portals.yml per that repo's README

# 3. Get this coworker
git clone https://github.com/Fighter90/career-ops-coworker
```

Then in OpenWorker: **New coworker → Import** → pick `career-ops.md`, open a **Job-Search Coworker** session, choose your `career-ops` folder, and ask:

> *"Scan my boards and give me the top 5 fits this week."* · *"Tailor my CV for this posting: <URL>."* · *"Who needs a follow-up — draft them."* · *"Open the dashboard."*

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
