#!/usr/bin/env bash
# dME session hook — runs on SessionStart + UserPromptSubmit.
# 1) On SessionStart (or when the source changed), installs the helper scripts to a stable path
#    (~/.claude/dme/bin) so /chonchi can call them regardless of where the skill is cached.
# 2) Every prompt: records THIS session's live transcript path so /chonchi can auto-export it (no /export).
# Must be fast and ALWAYS exit 0 (never block the session).
set -uo pipefail
[ -n "${HOME:-}" ] || exit 0   # preserve exit-0 contract even if HOME is unset

payload="$(cat 2>/dev/null || true)"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
dir="$HOME/.claude/dme"
bin="$dir/bin"
mkdir -p "$bin" 2>/dev/null || true

event=""; tp=""; cwd=""
if [ -n "$payload" ] && command -v node >/dev/null 2>&1; then
  parsed="$(printf '%s' "$payload" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const o=JSON.parse(s);process.stdout.write([o.hook_event_name||"",o.transcript_path||"",o.cwd||""].join(""))}catch{process.stdout.write("")}})' 2>/dev/null || true)"
  event="${parsed%%$'\001'*}"; rest="${parsed#*$'\001'}"; tp="${rest%%$'\001'*}"; cwd="${rest#*$'\001'}"
fi

# 1) stable copies of the helper scripts — only when they actually need updating
#    (not every prompt, never onto themselves)
for name in transcript-to-md.mjs gh-links.sh; do
  src="$here/$name"; dst="$bin/$name"
  if [ -n "$here" ] && [ -f "$src" ] && [ ! "$src" -ef "$dst" ]; then
    if [ "$event" = "SessionStart" ] || [ ! -f "$dst" ] || [ "$src" -nt "$dst" ]; then
      cp -f "$src" "$dst" 2>/dev/null || true
    fi
  fi
done

# 2) record the live transcript path (cheap; runs every prompt)
if [ -n "$tp" ]; then
  slug="$(printf '%s' "$cwd" | sed 's#[^A-Za-z0-9]#-#g')"
  printf '%s' "$tp" > "$dir/transcript-$slug.path" 2>/dev/null || true
  printf '%s' "$tp" > "$dir/last-transcript.path" 2>/dev/null || true
fi

exit 0
