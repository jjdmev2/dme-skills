#!/usr/bin/env bash
# dme-cc MANUAL installer — an ALTERNATIVE to the plugin (do NOT use both).
# If you installed the plugin (/plugin install dme@dmenetwork), skip this: the plugin already
# provides the commands, the session hook, and the Linear MCP. Use this only when you don't want
# the plugin system. Either way the commands are invoked as /dme:ccthis and /dme:linearthis.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
PLUGIN="$ROOT/plugins/dme"

echo "→ Commands → ~/.claude/commands/dme/  (invoked as /dme:ccthis, /dme:linearthis)"
mkdir -p "$HOME/.claude/commands/dme"
cp -f "$PLUGIN/commands/"*.md "$HOME/.claude/commands/dme/"
echo "  ✓ ccthis.md, linearthis.md"

echo "→ Transcript converter + hook → ~/.claude/dme/bin/"
mkdir -p "$HOME/.claude/dme/bin"
cp -f "$PLUGIN/scripts/transcript-to-md.mjs" "$HOME/.claude/dme/bin/transcript-to-md.mjs"
cp -f "$PLUGIN/scripts/session-hook.sh"      "$HOME/.claude/dme/bin/session-hook.sh"
chmod +x "$HOME/.claude/dme/bin/session-hook.sh" 2>/dev/null || true
echo "  ✓ transcript-to-md.mjs, session-hook.sh"

echo "→ Register session hook → ~/.claude/settings.json (backs up first, aborts if unparseable)"
node - "$HOME/.claude/settings.json" "$HOME/.claude/dme/bin/session-hook.sh" <<'NODE'
const fs = require('fs'), path = require('path');
const [file, hook] = process.argv.slice(2);
let s = {};
if (fs.existsSync(file)) {
  const raw = fs.readFileSync(file, 'utf8');
  try { s = JSON.parse(raw); }
  catch { fs.writeFileSync(file + '.bak', raw); console.error('  ! settings.json is not valid JSON — wrote ' + file + '.bak and made NO changes.'); process.exit(1); }
  fs.writeFileSync(file + '.bak', raw); // always back up before touching a valid file
}
s.hooks = s.hooks || {};
const cmd = { type: 'command', command: `bash "${hook}"` };
for (const ev of ['SessionStart', 'UserPromptSubmit']) {
  s.hooks[ev] = s.hooks[ev] || [];
  if (!JSON.stringify(s.hooks[ev]).includes(hook)) s.hooks[ev].push({ hooks: [cmd] });
}
fs.mkdirSync(path.dirname(file), { recursive: true });
fs.writeFileSync(file, JSON.stringify(s, null, 2));
console.log('  ✓ hook registered' + (fs.existsSync(file + '.bak') ? ' (backup: ' + file + '.bak)' : ''));
NODE

echo "→ Linear MCP (user scope)"
if command -v claude >/dev/null 2>&1; then
  claude mcp add --transport http --scope user linear https://mcp.linear.app/mcp 2>/dev/null \
    && echo "  ✓ Linear MCP added" || echo "  (already present — run /mcp in Claude Code to log in)"
else
  echo "  ! Claude Code CLI not found — add it later with:"
  echo "    claude mcp add --transport http --scope user linear https://mcp.linear.app/mcp"
fi

cat <<'NEXT'

Done. In Claude Code:
  1. Run  /mcp   and authenticate to Linear.
  2. Ensure gstack is installed.
Then:  /dme:linearthis <idea>   and   /dme:ccthis <EPIC-ID>
Update later with:  git pull && ./install.sh
NEXT
