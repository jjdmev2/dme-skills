# Changelog

All notable changes to the dme skills. Format loosely follows [Keep a Changelog](https://keepachangelog.com).

## [0.2.0] — 2026-06-30
### Changed
- **Bare commands.** Reworked from a Claude Code plugin (which force-namespaced everything to
  `/dme:ccthis`) into **Agent Skills** distributed as a git repo cloned into `~/.claude/skills/`,
  the way gstack works. Commands are now `/ccthis`, `/linearthis`, `/dme-upgrade`.
- `setup` replaces the old plugin install; registers the transcript hook and Linear MCP.

### Added
- `/dme-upgrade` skill (git pull + setup).

## [0.1.0] — 2026-06-30
### Added
- `/ccthis` — execute a Linear epic end-to-end (one branch/PR per epic) and auto-attach the full
  session transcript to the epic via the Linear attachment API.
- `/linearthis` — turn an idea or messy backlog into epics + sub-issues with acceptance criteria.
- Session hook + `transcript-to-md.mjs` converter (renders the live session JSONL to markdown; image
  placeholders, cwd-matched session selection, coalesced turns).
