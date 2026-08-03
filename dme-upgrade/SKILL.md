---
name: dme-upgrade
description: "Update the dme skills (/linearthis, /storythis, /ccthis, /chonchi) to the latest version from GitHub. Use when the user asks to update or upgrade dme. (dme)"
version: 0.4.0
---

# dme-upgrade

Update the dme skills to the latest version.

1. Locate the install (new name first, legacy dir as fallback):
   ```bash
   DME="$HOME/.claude/skills/dme-skills"
   [ -d "$DME" ] || DME="$HOME/.claude/skills/dme-cc"
   ```
2. Pull + re-run setup: `cd "$DME" && git pull --ff-only && ./setup`
3. Show what changed: `git -C "$DME" log --oneline -8`.
4. Tell the user the new commands/fixes, and that skills reload on the next session.

If the pull fails because of local edits, tell the user and suggest
`git -C "$DME" stash` (or `git reset --hard origin/main` to discard) first.
