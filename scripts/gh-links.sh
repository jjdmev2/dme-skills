#!/usr/bin/env bash
# gh-links.sh — best-effort GitHub links for the CURRENT repo state, for /chonchi.
# Prints a small markdown block: repo · branch (if pushed) · latest commit · open PR (if any).
# So a nightly code-review agent reading the attached transcript can jump straight to the code.
# Never fails the caller: always exits 0, prints whatever it can.
#
# Usage:  gh-links.sh [DIR]     (defaults to the current directory)
set -uo pipefail

cd "${1:-.}" 2>/dev/null || true

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "_(not a git repository — no code links)_"; exit 0; }

remote_url="$(git remote get-url origin 2>/dev/null || true)"
# normalise git@host:owner/repo(.git) and ssh://…  →  https://host/owner/repo
web=""
case "$remote_url" in
  git@*:*)          rest="${remote_url#git@}"; web="https://${rest%%:*}/${rest#*:}";;
  ssh://git@*/*)    web="https://${remote_url#ssh://git@}";;
  http://*)         web="https://${remote_url#http://}";;
  https://*)        web="$remote_url";;
  *)                web="$remote_url";;
esac
web="${web%.git}"

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
sha="$(git rev-parse --verify HEAD 2>/dev/null || true)"
short="$(git rev-parse --short HEAD 2>/dev/null || true)"
subject="$(git log -1 --pretty=%s 2>/dev/null || true)"

echo "**Repo:** ${web:-unknown}"

if [ -n "$branch" ] && [ "$branch" != "HEAD" ]; then
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [ -n "$upstream" ] && [ -n "$web" ]; then
    echo "**Branch:** $web/tree/$branch"
  elif [ -n "$web" ]; then
    echo "**Branch:** \`$branch\` _(local only — not pushed; use the commit link below)_"
  fi
fi

if [ -n "$sha" ] && [ -n "$web" ]; then
  echo "**Commit:** $web/commit/$sha  (\`$short\` — $subject)"
elif [ -n "$sha" ]; then
  echo "**Commit:** \`$sha\`  ($subject)"
fi

# open/merged PR for this branch, if gh is available and authenticated
if command -v gh >/dev/null 2>&1; then
  pr="$(gh pr view --json url,number,state -q '"#\(.number) (\(.state)) \(.url)"' 2>/dev/null || true)"
  [ -n "$pr" ] && echo "**PR:** $pr"
fi

exit 0
