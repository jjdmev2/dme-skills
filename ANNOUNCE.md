# Team announcement (copy/paste to Slack)

Hey team — we now have a standard way to work with Claude Code + Linear: **plan → build → hand off for
review**. Please install it.

**Four commands (bare — just type them):**

- **`/linearthis`** — turns a bad/unstructured issue into proper Linear structure — **an epic with work
  issues, or a single standalone issue** — ready to assign so someone can run it with `/ccthis`. It also
  helps you brainstorm an idea you haven't fully defined — once it's clear, it creates the tasks in
  Linear for you. (The model: an epic is one outcome; a work issue is one ownable, reviewable package
  that never spans repos — one branch + one PR each.)
- **`/storythis`** — finished a **design** and handing it to the devs? Lands it in Linear as the right
  structure — a value-framed project + a shared design issue + lean build stories, each verified against
  the actual branch code.
- **`/ccthis <ISSUE-or-EPIC>`** — builds **ONE work issue** per run: gstack, commits + pushes, one branch +
  one PR for that package, Linear kept in sync. Given an epic it picks one work issue and says which. It
  completes only what it built — never sibling issues, never the epic — and it does NOT close things out
  or export mid-build. This is a back-and-forth: you review and iterate with it.
- **`/chonchi`** — run this **once per work issue, when you've tested it and it's ready for the team**. It
  moves that work issue to **In Review**, comments what happened (with actual vs estimate), **attaches
  your full session transcript** (same as `/export`, automatic), adds the **branch/commit link** — so our
  **nightly codex review agent** can read the transcript, find the code, and review it while you sleep —
  and keeps one roll-up comment on the epic so its progress aggregates from its children.

**Install (once):**
```bash
git clone https://github.com/jjdmev2/dme-skills ~/.claude/skills/dme-skills
~/.claude/skills/dme-skills/setup
```
Then run `/mcp` and log in to Linear, and make sure gstack is installed. (The repo is public — no GitHub
auth needed to clone.)

**Then just work:**
```
/linearthis <your idea>     → creates the epic + work issues (or one standalone issue). Assign them.
/storythis                  → finished design? → project + design issue + build stories for the devs.
/ccthis <WORK-ISSUE-ID>     → build + ship that package: one branch, one PR (multi-turn — review as you go).
/chonchi                    → tested + done? that work issue goes In Review + transcript + branch link.
```

Works in the Claude Code CLI, the VS Code Claude Code extension, and Conductor. Update anytime with
**`/dme-upgrade`**.

⚠️ The transcript is your full session — if you printed secrets (tokens, `.env`) to the terminal, redact
before it uploads, or make sure the issue is private. `/chonchi` reminds you.
