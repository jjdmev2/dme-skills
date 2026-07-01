#!/usr/bin/env node
// transcript-to-md.mjs — render the CURRENT Claude Code session (JSONL) to readable markdown.
// Same content as /export, produced automatically. Auto-detects the live session transcript,
// and NEVER exports a different session's transcript (it matches the recorded cwd).
//
// Usage:
//   node transcript-to-md.mjs [--out FILE] [--file JSONL] [--include-subagents] [--max-tool-chars N]
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

function arg(name, def = null) {
  const i = process.argv.indexOf(name);
  if (i < 0) return def;
  const v = process.argv[i + 1];
  if (v === undefined || v.startsWith('--')) { console.error(`dme: ${name} requires a value`); process.exit(2); }
  return v;
}
const outPath = arg('--out', null);
const explicit = arg('--file', null);
const includeSidechains = process.argv.includes('--include-subagents');
const MAXTOOL = (() => { const n = parseInt(arg('--max-tool-chars', '2000'), 10); return Number.isFinite(n) ? n : 2000; })();

const slugify = (p) => p.replace(/[^A-Za-z0-9]/g, '-');

// Read only the head of a transcript to learn which cwd recorded it (cheap; cwd is in early lines).
function cwdOf(f) {
  try {
    const fd = fs.openSync(f, 'r');
    const buf = Buffer.alloc(65536);
    const n = fs.readSync(fd, buf, 0, 65536, 0);
    fs.closeSync(fd);
    for (const l of buf.slice(0, n).toString('utf8').split('\n')) {
      if (!l) continue;
      try { const o = JSON.parse(l); if (o.cwd) return o.cwd; } catch { /* partial line */ }
    }
  } catch { /* ignore */ }
  return null;
}

function newestJsonlMatching(dir, wantCwd) {
  if (!fs.existsSync(dir)) return null;
  const files = fs.readdirSync(dir)
    .filter((f) => f.endsWith('.jsonl'))
    .map((f) => path.join(dir, f))
    .sort((a, b) => fs.statSync(b).mtimeMs - fs.statSync(a).mtimeMs);
  for (const f of files) { if (!wantCwd || cwdOf(f) === wantCwd) return f; }
  return null;
}

function resolveTranscript() {
  if (explicit && fs.existsSync(explicit)) return explicit;
  const cwd = process.cwd();
  // 1) exact path recorded by the session hook for THIS cwd
  const hookFile = path.join(os.homedir(), '.claude', 'dme', `transcript-${slugify(cwd)}.path`);
  if (fs.existsSync(hookFile)) {
    const p = fs.readFileSync(hookFile, 'utf8').trim();
    if (p && fs.existsSync(p)) return p;
  }
  // 2) newest jsonl in this cwd's project dir whose recorded cwd matches
  const p2 = newestJsonlMatching(path.join(os.homedir(), '.claude', 'projects', slugify(cwd)), cwd);
  if (p2) return p2;
  // 3) newest jsonl across ALL projects whose recorded cwd matches this cwd — never guess a foreign session
  const root = path.join(os.homedir(), '.claude', 'projects');
  if (fs.existsSync(root)) {
    let best = null, bestM = -1;
    for (const d of fs.readdirSync(root)) {
      const dd = path.join(root, d);
      let st; try { st = fs.statSync(dd); } catch { continue; }
      if (!st.isDirectory()) continue;
      const c = newestJsonlMatching(dd, cwd);
      if (c) { const m = fs.statSync(c).mtimeMs; if (m > bestM) { bestM = m; best = c; } }
    }
    return best; // null if nothing matches -> caller errors out (safer than exporting the wrong session)
  }
  return null;
}

function truncate(s) {
  if (typeof s !== 'string') { try { s = JSON.stringify(s); } catch { s = String(s); } }
  return s.length > MAXTOOL ? s.slice(0, MAXTOOL) + ' …[truncated]' : s;
}

function blockToText(b) {
  if (!b || typeof b !== 'object') return '';
  if (b.type === 'text') return b.text || '';
  if (b.type === 'thinking') return b.thinking ? '> _(thinking)_\n> ' + b.thinking.replace(/\n/g, '\n> ') : '';
  if (b.type === 'image') return `[image: ${(b.source && (b.source.media_type || b.source.type)) || 'attached'}]`;
  if (b.type === 'tool_use') return `**→ tool: \`${b.name}\`**\n\n\`\`\`json\n${truncate(b.input)}\n\`\`\``;
  if (b.type === 'tool_result') {
    let c = b.content;
    if (Array.isArray(c)) {
      c = c.map((x) => {
        if (x && x.type === 'image') return `[image: ${(x.source && x.source.media_type) || 'base64'}]`;
        if (x && x.type === 'text') return x.text;
        return typeof x === 'string' ? x : JSON.stringify(x);
      }).join('\n');
    } else if (typeof c !== 'string') { c = JSON.stringify(c); }
    return `**← tool result${b.is_error ? ' (error)' : ''}**\n\n\`\`\`\n${truncate(c)}\n\`\`\``;
  }
  return '';
}

function textFromContent(content) {
  if (typeof content === 'string') return content;
  if (!Array.isArray(content)) return '';
  return content.map(blockToText).filter((s) => s && s.trim()).join('\n\n');
}

// A user record whose content is entirely tool_result blocks is really TOOL output, not the human.
function classify(role, content) {
  if (role !== 'user') return 'assistant';
  if (Array.isArray(content) && content.length && content.every((b) => b && b.type === 'tool_result')) return 'tool';
  return 'user';
}

const file = resolveTranscript();
if (!file) { console.error('dme: could not identify THIS session\'s transcript (no cwd match). Pass --file explicitly.'); process.exit(2); }

const lines = fs.readFileSync(file, 'utf8').split('\n').filter(Boolean);

// Collect, then coalesce consecutive records that belong to the same logical turn (same message.id),
// so one assistant turn (thinking -> text -> tool_use) renders as ONE section instead of several.
const records = [];
for (const line of lines) {
  let o; try { o = JSON.parse(line); } catch { continue; }
  if (o.isSidechain && !includeSidechains) continue;
  if (o.type !== 'user' && o.type !== 'assistant') continue;
  const msg = o.message || {};
  const role = msg.role || o.type;
  const body = textFromContent(msg.content);
  if (!body || !body.trim()) continue;
  records.push({ kind: classify(role, msg.content), id: msg.id || null, ts: o.timestamp || '', body });
}
const merged = [];
for (const r of records) {
  const last = merged[merged.length - 1];
  if (last && r.id && last.id === r.id && last.kind === r.kind) last.body += '\n\n' + r.body;
  else merged.push({ ...r });
}

const LABEL = { user: '🧑 User', assistant: '🤖 Assistant', tool: '🔧 Tool' };
const parts = ['# Claude Code transcript', '', `_source: ${file}_`, ''];
for (const r of merged) {
  parts.push('---', '', `### ${LABEL[r.kind] || r.kind}${r.ts ? ' · ' + r.ts : ''}`, '', r.body, '');
}
const md = parts.join('\n');
if (outPath) { fs.writeFileSync(outPath, md); console.log(outPath); }
else process.stdout.write(md);
console.error(`dme: rendered ${merged.length} turns from ${file}`);
