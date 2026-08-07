# dme-skills

Plan work in Linear. Build one work issue. Hand it off with proof.

`dme-skills` is a public [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) pack for a
consistent **plan → build → review** workflow. It keeps Linear, branches, PRs, estimates, code links, and
full session transcripts in sync.

| Command | Result |
|---|---|
| **`/linearthis <idea>`** | Shapes an idea into one standalone work issue, or an epic with work issues. |
| **`/storythis`** | Turns finished design/spec work into code-verified Linear work for developers. |
| **`/ccthis <issue-or-epic>`** | Builds **one work issue** on **one branch + one PR**. Given an epic, it picks one child and tells you which. |
| **`/chonchi`** | Hands the current work issue to review with its summary, actuals, code link, and full transcript. |

Commands are bare: use `/ccthis`, not `/dme:ccthis`.

## Install

```bash
git clone https://github.com/jjdmev2/dme-skills ~/.claude/skills/dme-skills
~/.claude/skills/dme-skills/setup
```

Then:

1. Run `/mcp` in Claude Code and authenticate to Linear.
2. Make sure `node` is installed; it powers transcript export.
3. Install **gstack** for the full workflow. Missing gstack skills fall back to native `git`/`gh` where possible.

The repo is public, so cloning needs no GitHub authentication. The skills work in Claude Code CLI, the
VS Code Claude Code extension, and Conductor.

## Run the workflow

### 1. Plan

```text
/linearthis add branded share links
```

`/linearthis` checks existing Linear work, reads the relevant code, and asks only the decisions that
change scope. It creates either:

- one **standalone work issue** when the outcome is one package; or
- one **epic** with multiple work issues when the outcome needs several packages.

Finished a design first? Run `/storythis` to create the design-to-development handoff instead.

### 2. Build one work issue

```text
/ccthis KIS-160
```

`/ccthis` builds one work issue per run, keeps Linear updated, and ships one branch + one PR. It never
completes untouched siblings or the parent epic.

Building is a conversation: review the work, test it, and iterate before handoff.

### 3. Hand it off

```text
/chonchi
```

When the current work issue is finished and tested, `/chonchi`:

1. Moves the work issue to **In Review**.
2. Attaches the full session transcript and a direct PR, branch, or commit link.
3. Creates or updates one session summary with estimate, session actual, and cumulative actual.
4. Applies `chonchi` only after the transcript and code link succeed.
5. Refreshes one roll-up comment on the parent epic, if any.

This split is deliberate: exporting during `/ccthis` would miss later feedback and revisions.

### Retry and reopen safely

- **Same-session retry:** reuses the marked comment, deterministic transcript attachment, and identical
  code link. The session's hours count once.
- **Later session:** adds one new session record and adds that session's actual once to the cumulative total.
- **Reopened work:** `/ccthis` removes only the stale `chonchi` label, preserves other labels, and returns
  an unstarted or review-stage parent epic to **In Progress**.

## Rules that keep Linear correct

- An **epic** is one coordinated product outcome. A **work issue** is one ownable, reviewable, verifiable
  package.
- A code work issue never spans repositories. One repository may contain several work issues.
- The work issue owns its branch, PR, estimate, actuals, state, and handoff. The epic only aggregates its
  children; one child's data never overwrites the epic.
- A `chonchi` label means the transcript and code link both landed. A child counts as handed off only when
  it also has a review/completed state.
- The epic moves to **In Review** only when every child is handed off. A partial handoff never promotes
  the epic to In Review and never changes untouched siblings.

## Reference

### Update

```text
/dme-upgrade
```

This pulls the latest version and re-runs setup. Manual update:

```bash
cd ~/.claude/skills/dme-skills && git pull && ./setup
```

This repository previously lived at `dmenetwork/dme-cc`. Existing clones keep working through GitHub's
redirect and the skills' legacy-path fallback. New installs should use `jjdmev2/dme-skills`.

### Transcript export and security

Claude Code stores each session as JSONL. The installed session hook records the active transcript path;
`/chonchi` converts it to Markdown, uploads it to Linear, and attaches the current GitHub link. You do not
need to run `/export` manually.

Transcripts can contain secrets printed in the terminal, including tokens, `.env` values, keys, and signed
URLs. Review and redact the transcript before upload unless the Linear workspace and issue are private.

### Layout

```text
linearthis/SKILL.md      # plan: idea → standalone work issue or epic + work issues
storythis/SKILL.md       # design handoff → project, design issue, and build stories
ccthis/SKILL.md          # build: one work issue → one branch + one PR
chonchi/SKILL.md         # review: transcript + code link + actuals + epic roll-up
dme-upgrade/SKILL.md     # update the pack and re-run setup
scripts/
  session-hook.sh        # records the active transcript path
  transcript-to-md.mjs   # converts Claude JSONL to Markdown
  gh-links.sh            # finds the current repo, branch, commit, and PR
setup                    # installs the hook and configures the Linear MCP
```

### License

MIT — see [LICENSE](LICENSE).
