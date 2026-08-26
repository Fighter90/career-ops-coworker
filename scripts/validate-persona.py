#!/usr/bin/env python3
"""Validate a coworker persona the way OpenWorker's loader does — so you know it
will install before you ship it.

Re-implements the rules in openworker's `coworker/personas/manifest.py::parse_manifest`
(it does NOT vendor that file). Run after any frontmatter change:

    python3 scripts/validate-persona.py            # checks career-ops.md
    python3 scripts/validate-persona.py path.md

Requires PyYAML:  python3 -m pip install pyyaml   (or use a venv)
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    import yaml
except ModuleNotFoundError:
    sys.exit("PyYAML is required: python3 -m pip install pyyaml")

# Mirrors openworker manifest.py + catalog.py (the closed, platform-owned capability set).
ID_RE = re.compile(r"^[a-z0-9][a-z0-9_-]{0,63}$")
CATALOG = {"code_files", "files", "git", "search", "shell", "todo"}
MODES = {"discuss", "plan", "interactive", "custom", "auto", "bypass-approvals", "auto-approve"}
GROUPS = {"general", "security"}
TEAM = {"lead", "worker"}
REC_KINDS = {"connector", "mcp"}
REC_TIERS = {"core", "optional"}


def split_frontmatter(text: str):
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if not m:
        raise ValueError("no `---` YAML frontmatter block")
    return yaml.safe_load(m.group(1)) or {}, m.group(2)


def validate(path: Path) -> list[str]:
    meta, body = split_frontmatter(path.read_text(encoding="utf-8"))
    errs: list[str] = []

    pid = str(meta.get("id", "")).strip()
    if not pid:
        errs.append("missing `id`")
    elif not ID_RE.match(pid):
        errs.append(f"`id` {pid!r} invalid (lowercase/digits/-/_, start alnum, <=64)")
    if not str(meta.get("name", "")).strip():
        errs.append("missing `name`")
    if not body.strip():
        errs.append("empty system prompt (body after frontmatter)")

    mode = str(meta.get("default_permission_mode", "interactive")).strip().lower()
    if mode not in MODES:
        errs.append(f"default_permission_mode {mode!r} not in {sorted(MODES)}")
    group = str(meta.get("group", "general") or "general").strip().lower()
    if group not in GROUPS:
        errs.append(f"group {group!r} not in {sorted(GROUPS)}")
    team = str(meta.get("team", "") or "").strip().lower()
    if team and team not in TEAM:
        errs.append(f"team {team!r} not in {sorted(TEAM)} (omit for solo)")

    tools = meta.get("tools", []) or []
    for t in tools:
        if t not in CATALOG:
            errs.append(f"unknown tool capability {t!r} (known: {sorted(CATALOG)})")

    # connectors grant: False | True | list-of-ids
    grant = meta.get("connectors", False)
    granted = set(grant) if isinstance(grant, (list, tuple)) else set()
    grant_all = grant is True

    for r in meta.get("recommends", []) or []:
        kind = "connector" if "connector" in r else "mcp" if "mcp" in r else None
        if kind not in REC_KINDS:
            errs.append(f"recommend {r!r}: kind must be `connector` or `mcp`")
            continue
        tier = str(r.get("tier", "optional")).strip().lower()
        if tier not in REC_TIERS:
            errs.append(f"recommend {r.get(kind)!r}: tier must be core|optional")
        if kind == "connector" and not grant_all and r["connector"] not in granted:
            errs.append(
                f"recommends connector {r['connector']!r} but it is not in the "
                f"`connectors:` grant — a recommendation must stay within the grant"
            )
    return errs


def main() -> int:
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "career-ops.md"
    if not target.exists():
        print(f"not found: {target}")
        return 2
    errs = validate(target)
    if errs:
        print(f"NOT INSTALLABLE ✗  ({target.name})")
        for e in errs:
            print("  -", e)
        return 1
    print(f"INSTALLABLE ✓  ({target.name}) — passes OpenWorker manifest rules")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
