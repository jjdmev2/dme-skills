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
  Linear structure — **an epic + work issues, or a single standalone issue** — with acceptance criteria.
  Pressure-tests a fuzzy idea or just confirms a sharp one, previews the tree, then creates it (with or
  without an existing epic). Pairs with gstack `/office-hours`. Ready to assign.
- **`/storythis`** — the **designer → dev handoff**: turns *finished* design/spec work into the right Linear
  structure, adaptively — a value-framed project + a shared design issue + lean, **code-verified** build
  stories, or just the subset that fits. Cloned from Kaisa's
  [`story-this`](https://github.com/dmenetwork/story-this) and kept in the pack.
- **`/ccthis <id>`** — the owner **builds ONE work issue**: gstack, **one branch / one PR per work issue**,
  Linear kept in sync. Given an epic ID it picks one work issue and says which. It completes only what it
  built and verified — never siblings, never the epic. It's a multi-turn conversation — you review and
  iterate.
- **`/chonchi`** — the **review handoff**, run once per work issue when it's tested and ready for the team.
  Moves the **work issue** to **In Review**, comments a summary with actual-vs-estimate, **attaches the
  full session transcript** (same content as `/export`, no manual step), adds the **branch/commit link**
  so a nightly code-review agent (codex/another agent) can pick it up straight from the transcript,
  refreshes a single roll-up comment on the parent epic, and tags the work issue **`chonchi`** so agents
  can filter for handed-off work.

## The model

- An **epic** is one coordinated product outcome. A **work issue** is one ownable, reviewable, verifiable
  package — a sub-issue under an epic, or a **standalone issue** when the work is only one package (no
  epic).
- **A code work issue never spans repositories.** One repo may need several work issues. The default is
  one work issue per repo, grouped by concern — split further only into packages someone can review alone.
- **The work issue is the unit of building, completion and handoff**: one branch + one PR each
  (`/ccthis`), handed off individually (`/chonchi`). The epic aggregates — estimates and actuals live on
  the work issues, the epic carries one roll-up comment, and it moves to In Review only when its last
  child is handed off. One child's result never overwrites the epic's values.
- The skills **discover the affected repositories from the conversation and the code, or ask** — nothing
  about any organization's topology or repository names is baked in.

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
/linearthis add branded share links to Reus     # → creates the epic + work issues (or one standalone issue). Assign them.
/storythis                                       # → finished a design? land it as project + design issue + stories
/ccthis KIS-160                                  # → build + ship ONE work issue: one branch, one PR (multi-turn)
/chonchi                                         # → tested? that work issue goes In Review + transcript + branch link
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
linearthis/SKILL.md      # /linearthis — shape an idea into an epic + work issues (or a standalone issue)
storythis/SKILL.md       # /storythis — designer→dev handoff: project + design issue + code-verified stories
ccthis/SKILL.md          # /ccthis — build + ship ONE work issue (one branch / one PR)
chonchi/SKILL.md         # /chonchi — review handoff: work issue → In Review + transcript + branch link + epic roll-up
dme-upgrade/SKILL.md     # /dme-upgrade — git pull + setup
scripts/
  session-hook.sh        # records the live transcript path + bootstraps the helpers (fast, exits 0)
  transcript-to-md.mjs   # JSONL → markdown (same content as /export)
  gh-links.sh            # current repo → GitHub repo/branch/commit/PR links (best-effort)
setup                    # registers the hook + Linear MCP (safe, idempotent)
```

## License

MIT — see [LICENSE](LICENSE).
