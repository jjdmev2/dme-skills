---
name: dme-upgrade
description: "Update the dme skills (/ccthis, /linearthis) to the latest version from GitHub. Use when the user asks to update or upgrade dme. (dme)"
version: 0.2.0
---

# dme-upgrade

Update the dme skills to the latest version.

1. Pull + re-run setup:
   ```bash
   cd ~/.claude/skills/dme-cc && git pull --ff-only && ./setup
   ```
2. Show what changed: `git -C ~/.claude/skills/dme-cc log --oneline -8`.
3. Tell the user the new commands/fixes, and that skills reload on the next session.

If the pull fails because of local edits, tell the user and suggest
`git -C ~/.claude/skills/dme-cc stash` (or `git reset --hard origin/main` to discard) first.
