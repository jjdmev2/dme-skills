# dme

Claude Code skills that make the whole team work the same way in Linear — plan → build → hand off for
review — plus **automatic full-transcript export** so finished work is auditable.

- **`/linearthis <idea>`** — an **adaptive brainstorming partner** that shapes work *with* you into proper
  **epics + sub-issues** with acceptance criteria. Pressure-tests a fuzzy idea or just confirms a sharp one,
  previews the tree, then creates it (with or without an existing epic). Pairs with gstack `/office-hours`.
  Ready to assign.
- **`/ccthis <epic>`** — the owner **builds** an epic: gstack, **one branch / one PR per epic**, sub-issues
  moved as you go, Linear kept in sync. It's a multi-turn conversation — you review and iterate.
- **`/chonchi <epic>`** — the **review handoff**, run once when the work is tested and ready for the team.
  Moves the issue to **In Review**, comments a summary, **attaches the full session transcript** (same
  content as `/export`, no manual step), and adds the **branch/commit link** so a nightly code-review agent
  (codex/another agent) can pick it up straight from the transcript.

Bare commands — `/ccthis`, not `/dme:ccthis`. They're [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills),
distributed the way gstack is: a git repo cloned into `~/.claude/skills/`.

**Why the split:** building is never one shot — you go back and forth with the agent. If the transcript
exported mid-build it would miss the rest of the session, so the export lives in `/chonchi`, run once at
the end when you're actually done and tested.

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
/ccthis KIS-160                                  # → build + ship one PR (multi-turn; you review as you go)
/chonchi KIS-160                                 # → tested? In Review + full transcript + branch link for the team
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
wires) and installs `transcript-to-md.mjs` + `gh-links.sh` to `~/.claude/dme/bin/`. When you run `/chonchi`
it renders that JSONL to markdown and uploads it to the issue via the Linear attachment API
(`prepare_attachment_upload` → PUT → `create_attachment_from_upload`), then computes the GitHub branch/commit
link with `gh-links.sh` and attaches it too. No manual `/export`, no re-run.

**Heads-up:** a transcript can contain secrets echoed to the terminal (tokens, `.env`, keys). `/chonchi`
warns and asks you to redact before uploading if the issue isn't private.

## Layout

```
linearthis/SKILL.md      # /linearthis — author epics + sub-issues from an idea
ccthis/SKILL.md          # /ccthis — build + ship an epic (one branch / one PR)
chonchi/SKILL.md         # /chonchi — review handoff: In Review + transcript + branch link
dme-upgrade/SKILL.md     # /dme-upgrade — git pull + setup
scripts/
  session-hook.sh        # records the live transcript path + bootstraps the helpers (fast, exits 0)
  transcript-to-md.mjs   # JSONL → markdown (same content as /export)
  gh-links.sh            # current repo → GitHub repo/branch/commit/PR links (best-effort)
setup                    # registers the hook + Linear MCP (safe, idempotent)
```

## License

MIT — see [LICENSE](LICENSE).
