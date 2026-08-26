#!/usr/bin/env bash
# ==============================================================================
# career-ops-coworker — one-command installer
# ------------------------------------------------------------------------------
# Prepares everything the Job-Search Coworker drives — the `career-ops` pipeline
# and (optionally) the `career-ops-ui` dashboard — then points you at OpenWorker
# to install the persona itself.
#
#   curl -fsSL https://raw.githubusercontent.com/Fighter90/career-ops-coworker/main/install.sh | bash
#
# It is IDEMPOTENT and NON-DESTRUCTIVE. An already-set-up `career-ops` project or
# an already-installed `web-ui` is DETECTED and REUSED — never overwritten or
# re-cloned. Your cv.md / portals.yml / config are never touched. Re-run it any
# time; it only fills in what is missing.
#
# The coworker ships NO code into OpenWorker — installing the persona is a trust
# event you complete in the app (this script just prints the three ways to do it).
#
# Env overrides:
#   CAREER_OPS_ROOT=/path   use/create the career-ops project here (default: ~/career-ops)
#   SKIP_UI=1               do not set up the web-ui dashboard
#   NO_CLONE_COWORKER=1     do not clone this repo locally (URL/zip install only)
#   NONINTERACTIVE=1        never prompt (assumed under `curl | bash`)
# ==============================================================================
set -euo pipefail

COOP_REPO="https://github.com/Fighter90/career-ops"
UI_REPO="https://github.com/Fighter90/career-ops-ui"
COWORKER_REPO="https://github.com/Fighter90/career-ops-coworker"
ROOT="${CAREER_OPS_ROOT:-$HOME/career-ops}"

# ---- pretty logging (plain when not a TTY, e.g. piped) ----
if [ -t 1 ]; then
  B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; C=$'\033[36m'; X=$'\033[0m'
else
  B='' ; G='' ; Y='' ; R='' ; C='' ; X=''
fi
say()  { printf '%s\n' "${C}▸${X} $*"; }
ok()   { printf '%s\n' "${G}✓${X} $*"; }
warn() { printf '%s\n' "${Y}!${X} $*"; }
die()  { printf '%s\n' "${R}✗ $*${X}" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

printf '%s\n' "${B}career-ops-coworker installer${X}  —  prepares the pipeline the coworker drives"
echo

# ---- 1. preflight ----------------------------------------------------------
say "Preflight"
have git  || die "git is required — https://git-scm.com"
have node || die "Node.js ≥ 18 is required — https://nodejs.org"
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
[ "${NODE_MAJOR:-0}" -ge 18 ] || die "Node.js ≥ 18 required (found $(node -v))"
ok "git and Node $(node -v)"

# ---- 2. career-ops project (DETECT → reuse, else clone) --------------------
# "Looks like career-ops" if it carries the pipeline entrypoint or your data.
looks_like_careerops() {
  [ -f "$1/scan.mjs" ] || [ -f "$1/portals.yml" ] || [ -f "$1/cv.md" ] || \
  { [ -f "$1/package.json" ] && grep -q '"career-ops"' "$1/package.json" 2>/dev/null; }
}

say "career-ops project"
FOUND=""
for cand in "${CAREER_OPS_ROOT:-}" "$PWD" "$ROOT"; do
  [ -n "$cand" ] && [ -d "$cand" ] && looks_like_careerops "$cand" && { FOUND="$cand"; break; }
done

if [ -n "$FOUND" ]; then
  ROOT="$(cd "$FOUND" && pwd)"
  ok "found existing career-ops at ${B}$ROOT${X} — reusing it, your data is untouched"
else
  if [ -e "$ROOT" ] && [ -n "$(ls -A "$ROOT" 2>/dev/null)" ]; then
    die "$ROOT exists but is not a career-ops project — set CAREER_OPS_ROOT to a new/empty path"
  fi
  say "cloning career-ops → $ROOT"
  git clone --depth 1 "$COOP_REPO" "$ROOT"
  ok "cloned career-ops"
fi

# dependencies (only if missing — never re-run needlessly)
if [ -f "$ROOT/package.json" ] && [ ! -d "$ROOT/node_modules" ]; then
  say "installing career-ops dependencies"
  ( cd "$ROOT" && npm install --no-audit --no-fund )
  ok "dependencies installed"
else
  ok "career-ops dependencies already present"
fi

# data files present?
if [ -f "$ROOT/cv.md" ] || [ -f "$ROOT/portals.yml" ]; then
  ok "project data detected (cv.md / portals.yml) — looks configured"
else
  warn "no cv.md / portals.yml yet — add your CV + boards before the first scan"
  warn "  schema: $COOP_REPO   (the coworker never invents these for you)"
fi

# ---- 3. web-ui dashboard (optional; DETECT → reuse, else clone) -------------
if [ "${SKIP_UI:-}" = "1" ]; then
  warn "SKIP_UI=1 — skipping the web-ui dashboard"
else
  say "web-ui dashboard"
  UI_DIR="$ROOT/web-ui"
  if [ -f "$UI_DIR/package.json" ]; then
    ok "web-ui already installed at ${B}$UI_DIR${X} — leaving it as is"
    [ -d "$UI_DIR/node_modules" ] || warn "  (its deps install on first launch via bin/start.sh)"
  else
    say "cloning career-ops-ui → $UI_DIR"
    git clone --depth 1 "$UI_REPO" "$UI_DIR"
    ok "web-ui installed (deps install on first 'open the dashboard' / bin/start.sh)"
  fi
fi

# ---- 4. OpenWorker present? -------------------------------------------------
say "OpenWorker desktop app"
OW_OK=""
case "$(uname -s)" in
  Darwin) [ -d "/Applications/OpenWorker.app" ] && OW_OK=1 ;;
  *)      have openworker && OW_OK=1 ;;
esac
if [ -n "$OW_OK" ]; then
  ok "OpenWorker found"
else
  warn "OpenWorker not detected — install it from https://openworker.com (it runs the coworker)"
fi

# ---- 5. clone the coworker locally (for the Import / folder install paths) --
CW_DIR="$ROOT/career-ops-coworker"
if [ "${NO_CLONE_COWORKER:-}" != "1" ]; then
  if [ -d "$CW_DIR/.git" ]; then
    ( cd "$CW_DIR" && git pull --ff-only -q ) && ok "coworker repo updated ($CW_DIR)"
  else
    git clone --depth 1 "$COWORKER_REPO" "$CW_DIR" && ok "coworker repo cloned ($CW_DIR)"
  fi
fi

# ---- done: install the persona in OpenWorker -------------------------------
cat <<EOF

${G}${B}Environment ready.${X} Install the coworker in OpenWorker — any one of:

  ${B}A. GitHub URL${X}   Install a coworker → GitHub URL, paste:
       ${C}$COWORKER_REPO${X}
  ${B}B. .zip${X}         download career-ops-coworker.zip from the repo's Releases,
                  then use the ".zip" option
  ${B}C. Import file${X}  point it at:
       ${C}$CW_DIR/career-ops.md${X}

OpenWorker shows the coworker's declared capabilities and lands it ${B}disabled
pending your consent${X} — enable it, then open a ${B}Job-Search Coworker${X} session and
pick the folder ${C}$ROOT${X}.

Try:  ${B}"Scan my boards and give me the top 5 fits this week."${X}
EOF
