# Changelog

All notable changes to the dme skills. Format loosely follows [Keep a Changelog](https://keepachangelog.com).

## [0.5.0] — 2026-08-07

`/linearthis`, `/ccthis` and `/chonchi` move to 0.5.0 together: one workflow contract across the three,
after review on [dme-skills#6](https://github.com/jjdmev2/dme-skills/pull/6). (The pack's 0.4.0 was the
repo rename + `/storythis`; the changes below were first proposed as a parallel 0.4.0 and are
re-versioned here.)

### Changed — the epic/work-issue contract (one model, all three skills)
- **Two units, defined once.** An **epic** is one coordinated product outcome. A **work issue** is one
  ownable, reviewable, verifiable package — a sub-issue under an epic, or a **standalone issue** when the
  work is only one package (no epic; the old "an epic has ≥2 sub-issues" rule is gone, replaced by
  right-sizing: one package → standalone, an epic with a single child should have been standalone).
- **The invariant: a code work issue never spans repositories.** One repository may need several work
  issues. The earlier "one sub-issue per repo" rule is demoted to what it really was — the recommended
  default (group a repo's concerns under headed AC blocks; split only into separately reviewable
  packages; a spike is its own package) — so the per-repo rule, the spike exception and the
  minimum-children rule can no longer contradict each other.
- **Repositories are discovered, not assumed.** `/linearthis` derives the affected repos and surfaces from
  the conversation and the code, or asks — no organization topology or repository names baked into the
  skills.
- **One work-issue template**, defined in `/linearthis` and consumed by `/ccthis`:
  `Summary / Spec / Acceptance criteria / Testing steps / Estimate` (a standalone issue adds
  `Summary (human)` + `Why`). `/ccthis`'s parallel `Problem / AC / Non-goals` template is gone. Epic
  context — `Summary (human)`, `Why`, `Objective`, `Declared limit` — lives on the epic only and is never
  restated per child.
- **`EPIC_ID` ≠ `WORK_ISSUE_ID`.** `/ccthis` builds ONE work issue per run — one branch, one PR — and
  given an epic ID it picks one child and says which. **It completes only the active, verified work
  issue: never a sibling, never the epic.** `/chonchi` hands off the ACTIVE work issue (it refuses to
  hand off an epic): In Review, transcript, branch link, `chonchi` label and actual-vs-estimate all land
  on the work issue.
- **The epic aggregates.** `/chonchi` maintains a single idempotent roll-up comment on the parent epic
  (marked `<!-- chonchi-rollup -->`, updated in place — repeated runs are safe): per-child state and
  actuals, the running total, what remains. The epic moves to In Review only when its last child is
  handed off, and one child's numbers never overwrite the epic's values.
- **Estimates live on work issues**; the epic's `## Estimate` is the labelled sum of its children.
  `/chonchi`'s cumulative actual is tracked per work issue across sessions.
- Each skill now carries a **Contract** table covering the five shapes: a standalone change · one repo /
  one package · one repo / several packages · several repos partially done · repeated `/chonchi` runs.
- **README, ANNOUNCE and `setup` teach the same model** (they previously still said "one branch / one PR
  per epic") and the examples stay generic. `/storythis` was left untouched — its right-sizing table
  already matches the standalone-vs-epic rule, and it has its own author.

### Added (carried from the parallel 0.4.0 proposal)
- **`/linearthis` always asks for the human summary — asking is not optional.** The epic (or the
  standalone issue) carries a `## Summary (human)` in the requester's voice — the one thing the skill
  cannot infer, asked for exactly once, for that container. The skill never hands back a blank: it asks
  two or three questions whose answers *are* the summary (why now · what actually bothers them · what
  they'd tell a teammate) and composes from those; a `[DRAFT]` the user has never seen must not exist.
  The answer is read back through the whole epic — if the user's framing differs, theirs wins and the
  Objective moves with it.
- **Answer in any language, write English.** The user replies in whatever language they think in; every
  Linear field is written in English. No mixed-language bodies.
- **Ask with options, not open questions — grounded in the code first.** Every decision that changes the
  work is offered as 2–4 options with a recommendation; options whose feasibility wasn't verified are
  marked and become spikes instead of estimates. Includes the four recurring misses: storage, coverage
  depth, what the verb actually means (prevent vs remediate vs report), and the declared limit.
- **Search Linear before shaping anything** (Phase 0) — in every state including Backlog and Done — and
  report which case it found: exists / already landed / partial overlap / nothing.
- **`/chonchi` records the actual hours against the estimate**, cumulative across sessions, with one line
  on why it diverged; `/linearthis` reads recent actuals back before estimating new work, and a team with
  no recorded actuals after several epics should drop hours for S/M/L.
- **Locations rot, existence doesn't:** issue bodies never cite line numbers, but DO state what already
  exists, which survives refactors.
- **Titles name the surfaces they touch**, pipe-separated, then the feature; work issues keep the feature
  so they read on their own outside the epic.
- **Phase 3 previews a real body, not a summary of one**, and names the places the shaping is least sure
  about instead of asking for a rubber stamp.

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
