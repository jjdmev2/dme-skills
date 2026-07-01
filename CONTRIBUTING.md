# Contributing to dme

## Anatomy of a skill

Each skill is a directory with a `SKILL.md`:

```
ccthis/
  SKILL.md          # frontmatter + executable instructions
```

Frontmatter:

```yaml
---
name: ccthis                       # the bare command → /ccthis
description: "One line. Used to match natural-language intent AND shown in the /menu."
version: 0.2.0                     # bump on every release; /dme-upgrade surfaces it
---
```

The body is **executable instructions**, written as numbered phases. Keep it self-contained.

## Conventions

- **Bare names, no prefix.** The whole point — don't reintroduce a namespace.
- **Degrade gracefully.** If a gstack skill or tool isn't installed, fall back to native `git`/`gh`/manual.
- **Never leave a step empty.** A missing tool is a fallback, not a skipped phase.
- **Test scripts against a real transcript** before committing (`scripts/transcript-to-md.mjs`).

## Releasing

1. Edit the skill / scripts.
2. Bump `version:` in the changed `SKILL.md` and add a `CHANGELOG.md` entry.
3. Commit + push to `main`.
4. Teammates run `/dme-upgrade`.

## Local dev

Your working copy already lives at `~/.claude/skills/dme-cc`, so edits are live next session.
Run `./setup` after changing the hook or scripts.
