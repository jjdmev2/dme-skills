# Changelog

All notable changes to the dme skills. Format loosely follows [Keep a Changelog](https://keepachangelog.com).

## [0.4.0] — 2026-08-03
### Added
- **`/storythis`** — Kaisa's designer→dev handoff skill, cloned from
  [`dmenetwork/story-this`](https://github.com/dmenetwork/story-this) (v0.4.0) into the pack. Turns
  *finished* design/spec work into the right Linear structure, adaptively: a value-framed project + a
  shared design issue + lean, **code-verified** build stories — or just the subset that fits.

### Changed
- **Repo renamed, moved, and made public:** `dmenetwork/dme-cc` → **`jjdmev2/dme-skills`**, public so
  anyone can install. Old clones keep working (GitHub redirects the remote); new installs clone into
  `~/.claude/skills/dme-skills`. `/dme-upgrade` and `/chonchi` now check the new path first and fall back
  to the legacy `dme-cc` dir.
- README reframed around how the team works — agentic workflows across Claude Code / Codex / harnesses
  like Hermes and Buzz, on Conductor / VS Code / the Codex app — with `/storythis` added to the flow.

## [0.3.3] — 2026-07-20
### Added
- **`/chonchi` tags the issue `chonchi`** as a success marker (step E), applied last — only after the
  transcript upload and branch/commit link actually land. A `chonchi`-labelled issue reliably means "handed
  off, transcript + code links attached," so agents can filter for it. Applied as the union with the issue's
  existing labels (since `save_issue`'s `labels` replaces the whole set), and the label is auto-created once
  if the team doesn't have it.

## [0.3.2] — 2026-07-05
### Changed
- **`/linearthis` is now an adaptive brainstorming partner**, not just a backlog formatter. It gauges how
  formed the idea is and does the right amount — lightly confirms a sharp idea (e.g. one that came out of
  gstack `/office-hours`), or brainstorms a fuzzy one to clarity before shaping the tree. Works **with or
  without an existing epic** (restructures a malformed epic in place instead of duplicating). Framed as
  complementary to `/office-hours`: that thinks the idea through, `/linearthis` lands it in the right Linear
  form.

## [0.3.1] — 2026-07-04
### Changed
- **`/chonchi` runs bare by default** — no issue ID needed. Since you've been building one epic on one branch
  all session, it derives the issue from context (the epic `/ccthis` was run on → any Linear ID fetched this
  session → the branch name) and proceeds, instead of asking for an ID it can already see. An explicit
  `/chonchi KIS-160` still overrides.

## [0.3.0] — 2026-07-04
### Added
- **`/chonchi`** — the review-handoff skill, run once when work is tested and ready for the team. It
  (A) moves the Linear issue to **In Review**, (B) posts a summary comment, (C) **attaches the full session
  transcript** as markdown, and (D) adds the **GitHub branch/commit/PR link** so a nightly code-review agent
  can pick the work up straight from the transcript.
- `scripts/gh-links.sh` — best-effort GitHub repo/branch/commit/PR links for the current repo state
  (handles `git@`, `ssh://`, and `https` remotes; falls back to the commit link when the branch isn't pushed).

### Changed
- **`/ccthis` is now build-only.** The transcript export and issue close-out moved OUT of `/ccthis` into
  `/chonchi`. `/ccthis` sets the epic **In Progress** (if not already) and moves sub-issues as it goes, but
  no longer force-closes the epic or exports mid-session — because building is a multi-turn conversation and
  the transcript must capture the WHOLE session. It ends by pointing you to `/chonchi`.
- Session hook installs both helpers (`transcript-to-md.mjs` + `gh-links.sh`) to `~/.claude/dme/bin/`.

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
