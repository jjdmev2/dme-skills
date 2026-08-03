# Team announcement (copy/paste to Slack)

Hey team — we now have a standard way to work with Claude Code + Linear: **plan → build → hand off for
review**. Please install it.

**Four commands (bare — just type them):**

- **`/linearthis`** — turns a bad/unstructured issue (like the ones in RITO) into proper **epics with
  sub-issues**, ready to assign so someone can run it with `/ccthis`. It also helps you brainstorm an
  idea you haven't fully defined — once it's clear, it creates the tasks in Linear for you.
- **`/storythis`** — finished a **design** and handing it to the devs? Lands it in Linear as the right
  structure — a value-framed project + a shared design issue + lean build stories, each verified against
  the actual branch code.
- **`/ccthis <ISSUE-or-EPIC>`** — takes the issue/epic, runs gstack, **builds** it, commits + pushes, opens
  one PR for the epic, and keeps Linear in sync. This is a back-and-forth: you review and iterate with it —
  it does NOT close things out or export mid-build.
- **`/chonchi <ISSUE-or-EPIC>`** — run this **once, when you've tested it and it's ready for the team**. It
  moves the issue to **In Review**, comments what happened, **attaches your full session transcript** (same
  as `/export`, automatic), and adds the **branch/commit link** — so our **nightly codex review agent** can
  read the transcript, find the code, and review it while you sleep.

**Install (once):**
```bash
git clone https://github.com/jjdmev2/dme-skills ~/.claude/skills/dme-skills
~/.claude/skills/dme-skills/setup
```
Then run `/mcp` and log in to Linear, and make sure gstack is installed. (The repo is public — no GitHub
auth needed to clone.)

**Then just work:**
```
/linearthis <your idea>     → creates the epics + sub-issues. Assign them.
/storythis                  → finished design? → project + design issue + build stories for the devs.
/ccthis <EPIC-ID>           → build + ship (multi-turn — review as you go).
/chonchi <EPIC-ID>          → tested + done? In Review + full transcript + branch link for the team.
```

Works in the Claude Code CLI, the VS Code Claude Code extension, and Conductor. Update anytime with
**`/dme-upgrade`**.

⚠️ The transcript is your full session — if you printed secrets (tokens, `.env`) to the terminal, redact
before it uploads, or make sure the issue is private. `/chonchi` reminds you.
