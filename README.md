# dme

Two Claude Code skills that make the whole team work the same way in Linear — plus **automatic
full-transcript export** so finished work is auditable.

- **`/linearthis <idea>`** — turn a rough idea (or a messy backlog) into proper **epics + sub-issues**
  with acceptance criteria. Asks a few questions if it's fuzzy, previews the tree, then creates it. Ready to assign.
- **`/ccthis <epic>`** — the owner executes an epic end-to-end: build with gstack, **one branch / one PR
  per epic**, keep Linear updated, and **auto-attach the full session transcript to the epic** (same
  content as `/export`, no manual step).

Bare commands — `/ccthis`, not `/dme:ccthis`. They're [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills),
distributed the way gstack is: a git repo cloned into `~/.claude/skills/`.

---

## Install

```bash
git clone https://github.com/dmenetwork/dme-cc ~/.claude/skills/dme-cc
~/.claude/skills/dme-cc/setup
```

`setup` registers the transcript hook (backs up `~/.claude/settings.json` first) and adds the Linear MCP.
Then, in Claude Code:

1. `/mcp` → authenticate to Linear (one-time).
2. Make sure **gstack** is installed (the flows call `/spec`, `/code-review`, `/ship`, `/codex`… — if a
   skill is missing they fall back to native `git`/`gh`).

`node` is required (you already have it) — it powers the transcript export.

> The repo is private, so cloning needs GitHub access (`gh auth login`, an SSH key, or a token).

## Use

```
/linearthis add branded share links to Reus     # → creates epic(s)+sub-issues in Linear. Assign them.
/ccthis KIS-160                                  # → build, ship one PR, transcript auto-attached to the epic
```

Works in the Claude Code CLI, the VS Code Claude Code extension, and Conductor.

## Update

```
/dme-upgrade          # pulls latest + re-runs setup
```

Or manually: `cd ~/.claude/skills/dme-cc && git pull && ./setup`. To ship an update, bump the `version:`
in the relevant `SKILL.md`, commit, and push — teammates pick it up with `/dme-upgrade`.

## How the automatic export works (no `/export`)

Claude Code writes every session to `~/.claude/projects/<cwd>/<session>.jsonl` — the exact source
`/export` reads. The session hook records that path (per cwd, so parallel Conductor worktrees don't cross
wires) and installs `transcript-to-md.mjs` to `~/.claude/dme/bin/`. In `/ccthis` Phase 6 the agent renders
that JSONL to markdown and uploads it to the epic via the Linear attachment API (`prepare_attachment_upload`
→ PUT → `create_attachment_from_upload`). No manual `/export`, no re-run.

**Heads-up:** a transcript can contain secrets echoed to the terminal (tokens, `.env`, keys). Phase 6 warns
and asks you to redact before uploading if the epic isn't private.

## Layout

```
ccthis/SKILL.md          # /ccthis — execute an epic + auto-export transcript
linearthis/SKILL.md      # /linearthis — author epics + sub-issues from an idea
dme-upgrade/SKILL.md      # /dme-upgrade — git pull + setup
scripts/
  session-hook.sh        # records the live transcript path + bootstraps the converter (fast, exits 0)
  transcript-to-md.mjs   # JSONL → markdown (same content as /export)
setup                    # registers the hook + Linear MCP (safe, idempotent)
```

## License

MIT — see [LICENSE](LICENSE).
