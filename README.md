# dme-cc — dME Network's Claude Code standard

Two commands that make everyone work the same way in Linear, plus **automatic full-transcript
export** so you (the founder) can later run agents over how the team works.

- **`/dme:linearthis <idea>`** — turn a rough idea (or a messy backlog like RITO) into proper **epics +
  sub-issues** with acceptance criteria. Asks a few questions if the idea is fuzzy. Ready to assign.
- **`/dme:ccthis <EPIC>`** — the owner executes an epic end-to-end: build with gstack, **one branch /
  one PR per epic**, keep Linear updated, and **auto-attach the full Claude Code transcript to the epic**
  (same content as `/export`, no manual step).

> Commands are namespaced by the plugin, so they're `/dme:ccthis` and `/dme:linearthis` (not bare `/ccthis`).

Ships as a **Claude Code plugin marketplace**. Install once; when we push here, everyone updates.

---

## Install (each teammate, once)

In Claude Code (CLI, the VS Code Claude Code extension, or Conductor):

```
/plugin marketplace add dmenetwork/dme-cc
/plugin install dme@dmenetwork
```

Then finish the two prerequisites the commands rely on:

1. **Linear login** — run `/mcp` and authenticate to Linear (the plugin bundles the Linear MCP; you
   just approve + OAuth once).
2. **gstack** — make sure gstack is installed (the flows call `/spec`, `/code-review`, `/ship`, `/codex`…).
   If a gstack skill is missing, the commands fall back to native `git`/`gh`, so it still works.

`node` is required (you already have it) — it powers the transcript export.

## Use it

```
/dme:linearthis add branded share links to Reus     # → creates epic(s)+sub-issues in Linear. Assign them.
/dme:ccthis KIS-160                                 # → owner builds, ships one PR, auto-attaches the transcript
```

## Updates (founder pushes → everyone gets it)

**Versioning:** every release, bump `version` in `plugins/dme/.claude-plugin/plugin.json` — that string
is the update key. Pushing commits **without** bumping it propagates nothing.

- **You (founder):** edit files → bump `plugins/dme/.claude-plugin/plugin.json` `version` → commit + push to `dmenetwork/dme-cc`.
- **Everyone:** third-party plugins don't auto-update by default, so pull an update with:
  ```
  /plugin marketplace update dmenetwork
  /plugin update dme@dmenetwork
  ```
  (or enable auto-update for the `dmenetwork` marketplace once, then it's automatic). Changes apply next session.

## Test it locally before pushing to GitHub

You can add the marketplace straight from this folder:

```
/plugin marketplace add /Users/kisu/dme-cc
/plugin install dme@dmenetwork
```

## What's inside

```
.claude-plugin/marketplace.json        ← the marketplace (lists the "dme" plugin)
plugins/dme/
  .claude-plugin/plugin.json           ← plugin manifest (bump version to ship an update)
  .mcp.json                            ← Linear MCP (auto-loads when the plugin is enabled)
  commands/ccthis.md                   ← execute an epic + auto-export transcript
  commands/linearthis.md               ← author epics + sub-issues from an idea
  hooks/hooks.json                     ← records the live transcript path + bootstraps the converter
  scripts/session-hook.sh              ← the hook body (fast, non-blocking, exits 0)
  scripts/transcript-to-md.mjs         ← JSONL → markdown converter (same content as /export)
install.sh                             ← MANUAL installer (alternative to the plugin — don't use both)
```

## How the automatic export works (no `/export`)

Claude Code writes every session to `~/.claude/projects/<cwd>/<session>.jsonl` — the exact source
`/export` reads. The plugin hook records that path (per cwd, so parallel Conductor worktrees don't cross
wires) and installs `transcript-to-md.mjs` to `~/.claude/dme/bin/`. In `/dme:ccthis` Phase 6, the agent
renders that JSONL to markdown and uploads it to the epic via the Linear attachment API
(`prepare_attachment_upload` → PUT → `create_attachment_from_upload`). No manual `/export`, no re-run.

**Heads-up:** the transcript can contain secrets echoed to the terminal (tokens, `.env`, keys). Phase 6
warns and asks you to redact before uploading if the epic isn't private.

## Manual install (no plugin system — alternative, not in addition)

```
git clone https://github.com/dmenetwork/dme-cc && cd dme-cc && ./install.sh
```

Installs the commands to `~/.claude/commands/dme/` (still `/dme:ccthis`), the converter to
`~/.claude/dme/bin/`, registers the hook (backing up `settings.json` first), and adds the Linear MCP.
Update later with `git pull && ./install.sh`. **Don't run this if you also installed the plugin** — you'd
register the hook twice.
