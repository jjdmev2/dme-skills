# Team announcement (copy/paste to Slack)

Hey team — we now have a standard way to work with Claude Code + Linear. Please install it.

**Two commands:**

- **`/dme:ccthis <ISSUE-or-EPIC>`** — takes the issue/epic, runs gstack, completes it, commits + pushes,
  opens one PR for the epic, and **automatically attaches your full working transcript to the issue**
  (same as `/export`, but you don't have to do anything).
- **`/dme:linearthis`** — turns a bad/unstructured issue (like the ones in RITO) into proper **epics with
  sub-issues**, ready to assign so someone can execute it with `/dme:ccthis`. It also helps you brainstorm
  an idea you haven't fully defined yet — once it's clear, it creates the tasks in Linear for you.

**Install (once):**
```
/plugin marketplace add dmenetwork/dme-cc
/plugin install dme@dmenetwork
```
Then run `/mcp` and log in to Linear, and make sure gstack is installed.

**Then just work:**
```
/dme:linearthis <your idea>     → creates the epics + sub-issues. Assign them.
/dme:ccthis <EPIC-ID>           → build, ship, and the transcript lands on the issue automatically.
```

Works in the Claude Code CLI, the VS Code Claude Code extension, and Conductor. When I push updates,
run `/plugin marketplace update dmenetwork && /plugin update dme@dmenetwork` (or turn on auto-update).

⚠️ The transcript is your full session — if you printed secrets (tokens, `.env`) to the terminal, redact
before it uploads, or make sure the epic is private. `/dme:ccthis` reminds you.
