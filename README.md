# dme-skills

We run most of our work through **workflows and agentic processes** — Claude Code, Codex, and harnesses
like Hermes and Buzz — on whatever surface fits the moment: **Conductor** for parallel agents, **VS Code**
at the desk, or the **Codex app** for remote work (touch grass, still ship). Along the way we've settled on
team best practices for that way of working: how we **start a task**, how we keep **Linear up to date**
while an agent builds, how we **brainstorm and define work** as user stories with acceptance criteria, and
how we **hand finished work off** for review with a full audit trail.

**These are our team skills** — that whole flow packaged as
[Agent Skills](https://docs.claude.com/en/docs/claude-code/skills), public so anyone who wants to run the
same processes can install them.

The flow is plan → build → hand off for review, plus **automatic full-transcript export** so finished work
is auditable:

- **`/linearthis <idea>`** — an **adaptive brainstorming partner** that shapes work *with* you into proper
  **epics + sub-issues** with acceptance criteria. Pressure-tests a fuzzy idea or just confirms a sharp one,
  previews the tree, then creates it (with or without an existing epic). Pairs with gstack `/office-hours`.
  Ready to assign.
- **`/storythis`** — the **designer → dev handoff**: turns *finished* design/spec work into the right Linear
  structure, adaptively — a value-framed project + a shared design issue + lean, **code-verified** build
  stories, or just the subset that fits. Cloned from Kaisa's
  [`story-this`](https://github.com/dmenetwork/story-this) and kept in the pack.
- **`/ccthis <epic>`** — the owner **builds** an epic: gstack, **one branch / one PR per epic**, sub-issues
  moved as you go, Linear kept in sync. It's a multi-turn conversation — you review and iterate.
- **`/chonchi <epic>`** — the **review handoff**, run once when the work is tested and ready for the team.
  Moves the issue to **In Review**, comments a summary, **attaches the full session transcript** (same
  content as `/export`, no manual step), adds the **branch/commit link** so a nightly code-review agent
  (codex/another agent) can pick it up straight from the transcript, and tags the issue **`chonchi`** so
  agents can filter for handed-off work.

Bare commands — `/ccthis`, not `/dme:ccthis`. Distributed the way gstack is: a git repo cloned into
`~/.claude/skills/`.

**Why the build/handoff split:** building is never one shot — you go back and forth with the agent. If the
transcript exported mid-build it would miss the rest of the session, so the export lives in `/chonchi`, run
once at the end when you're actually done and tested.

---

## Install

```bash
git clone https://github.com/jjdmev2/dme-skills ~/.claude/skills/dme-skills
~/.claude/skills/dme-skills/setup
```

The repo is public — anyone can clone it. `setup` registers the transcript hook (backs up
`~/.claude/settings.json` first) and adds the Linear MCP. Then, in Claude Code:

1. `/mcp` → authenticate to Linear (one-time).
2. Make sure **gstack** is installed (the flows call `/spec`, `/code-review`, `/ship`, `/codex`… — if a
   skill is missing they fall back to native `git`/`gh`).

`node` is required — it powers the transcript export.

## Use

```
/linearthis add branded share links to Reus     # → creates epic(s)+sub-issues in Linear. Assign them.
/storythis                                       # → finished a design? land it as project + design issue + stories
/ccthis KIS-160                                  # → build + ship one PR (multi-turn; you review as you go)
/chonchi KIS-160                                 # → tested? In Review + full transcript + branch link for the team
```

Works in the Claude Code CLI, the VS Code Claude Code extension, and Conductor.

## Update

```
/dme-upgrade          # pulls latest + re-runs setup
```

Or manually: `cd ~/.claude/skills/dme-skills && git pull && ./setup`. To ship an update, bump the `version:`
in the relevant `SKILL.md`, commit, and push — teammates pick it up with `/dme-upgrade`.

> Previously this repo lived at `dmenetwork/dme-cc`. Old clones in `~/.claude/skills/dme-cc` keep working
> (GitHub redirects the remote), and `/dme-upgrade` and `/chonchi` know both locations — but new installs
> should use the path above.

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
storythis/SKILL.md       # /storythis — designer→dev handoff: project + design issue + code-verified stories
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
