---
name: ccthis
description: "Build ONE Linear work issue end-to-end — a sub-issue of an epic, or a standalone issue: set it In Progress, build with gstack, keep Linear updated, and ship it as its own branch + PR. Given an epic ID, it picks ONE work issue to build this run and says which. It completes only the work issue it built and verified — never siblings, never the epic. Building is a multi-turn conversation (you review + give feedback); when the package is tested and ready for the team, hand off with /chonchi. Use when the user types /ccthis, says \"cc this issue/epic\", or hands over a Linear ID to execute. (dme)"
version: 0.5.0
---

# ccthis

You are building Linear work end-to-end. Linear is the single source of truth — keep it
updated the WHOLE time, not just at the end. This is a **multi-turn conversation**: you build, the user
reviews and gives feedback, you iterate. When the work is finished and the user has tested it, they run
**`/chonchi`** to hand off for team review (move to In Review, comment, attach the full transcript, and
add the branch/commit link). Do NOT try to export the transcript or close things out from here — that
belongs to `/chonchi`, at the end.

## The unit — EPIC_ID vs WORK_ISSUE_ID
These are different things, and this skill must never conflate them:
- The **work issue** — a sub-issue of an epic, or a standalone issue — is the unit of building,
  completion and handoff: **one run = one work issue = one branch = one PR.**
- The **epic** is context: the outcome definition, the boundary, the `blockedBy` order. It is read, it
  goes In Progress while any child is being built, and it is NEVER completed or reviewed from here —
  its state aggregates from its children (`/chonchi`'s job).

**Target:** the Linear ID the user gave (e.g. `/ccthis ENG-45`). If it is a **work issue**, build exactly
that. If it is an **EPIC**, list its children and build ONE this run — the work issue the user named, or
the first unblocked one — and tell the user which, and which the later runs will be. If a file path like
`LINEAR.md` was given, read it as the spec. If nothing was given, ask which issue to work. Throughout,
`WORK_ISSUE` = the one being built this run.

## Tooling — use what's installed, never leave a step empty
Prefer gstack skills when available (`/spec`, `/autoplan`, `/investigate`, `/code-review`, `/review`,
`/qa`, `/ship`, `/codex`). If a referenced skill is NOT installed, do the equivalent with native tools
(e.g. no `/ship` → create the PR with `git` + `gh`; no `/code-review` → review the diff yourself).
Never skip a phase because one tool is missing.

## The standard (always enforce)
- The units are `/linearthis`'s: hierarchy `Project → Milestone → Epic (label `epic`) → Work issues`, or
  a standalone work issue when the work is one package. **A code work issue never spans repositories**;
  one repository may have several work issues. Read which repo the WORK_ISSUE targets from the issue
  itself — never assume an organization topology.
- **Branch and PR are per WORK ISSUE.** A multi-package epic ships as one PR per work issue, across
  several runs — never one PR spanning repos, and never a PR that quietly bundles a sibling package.
  Respect the epic's `blockedBy` order: a frontend slice that renders a field the backend has not
  shipped yet will not pass its own acceptance criteria.
- **Work-issue body is `/linearthis`'s template:** `## Summary` / `## Spec` / `## Acceptance criteria` /
  `## Testing steps` / `## Estimate` (a standalone issue adds `## Summary (human)` + `## Why`). If the
  issue you were handed has a different shape, work with what's there — don't reshape it mid-build; use
  `/spec` if the acceptance criteria are too vague to build against, and update the issue.
- **Labels:** one type (`Feature`/`Improvement`/`Bug`) + `epic` on epics + `platform:*` / gates as needed.
- **Completion rule (hard): you may complete ONLY the active work issue, and only once its acceptance
  criteria are verified.** Never mark a sibling work issue Done, never move the epic to Done or In
  Review, never "tidy up" untouched issues on the way out. Untouched siblings belong to other runs; the
  epic's state aggregates from its children.
- **Definition of Done (work-issue level):** its acceptance criteria checked · its PR open and linked ·
  the user has tested it · handed off with `/chonchi` (In Review + full transcript + branch/commit
  link) · merged/deployed or follow-ups filed. The EPIC is done only when every child gets there —
  across runs, not in this one.

## Phase 0 — Load
- Fetch the target from Linear (`get_issue`); resolve the WORK_ISSUE per **The unit** above.
- Read the WORK_ISSUE's description + acceptance criteria in full. If it has a parent epic, read the
  epic's body too (Objective, Declared limit, `blockedBy` order) — that is the boundary you build inside.
- Read linked specs and relevant code so you follow existing patterns.
- Set the WORK_ISSUE **In Progress** and assign it to the user. Set the parent epic In Progress too if it
  hasn't started — a child in progress means the outcome is in progress; that is the ONLY epic state
  change this skill ever makes.
- Create **ONE branch for this work issue** and do all the work on it.

## Phase 1 — Plan (gstack, as needed)
- Fuzzy/missing acceptance criteria → `/spec`, then update the WORK_ISSUE's description in Linear.
- Non-trivial work → `/autoplan` (or `/plan-eng-review`). Post the plan as a comment on the WORK_ISSUE.

## Phase 2 — Build (one WORK ISSUE = one branch = one PR)
Work through the WORK_ISSUE's acceptance criteria on its single branch:
- `/freeze` the directories in play; `/guard` / `/careful` near destructive commands.
- Implement ONLY this work issue's acceptance criteria. No unrelated files, no opportunistic refactors,
  and no reaching into a sibling package because it's "right there" — that is another run.
- `/investigate` to root-cause bugs. Add/update tests when logic/data/permissions/UX change.
- Comment progress on the WORK_ISSUE as milestones land — keep Linear mirroring reality.
- You MAY parallelize with `claude ultracode`, but integrate every agent's work back onto the ONE
  branch before the PR.

## Phase 3 — Review (run whatever is installed; skip missing tools, don't block)
- gstack: `/code-review` (+ `/review` pre-landing) on the branch diff; apply must-fix findings.
- `/codex` as a second reviewer if available; reconcile with gstack.
- Conductor native review if configured; resolve blocking comments.
- Re-run the narrowest useful checks (lint/build/tests) for the files touched.

## Phase 4 — Ship (ONE PR for this work issue)
- Open a SINGLE PR with `/ship`. PR body: what changed, why, link to the WORK_ISSUE (and its epic, if it
  has one), AC checked, risk, how to test, what you intentionally did not do, agent involvement,
  follow-ups. If the epic has sibling work issues, name them and whether their PRs are already out — a
  reviewer must not read a half-outcome as a whole one.
- Attach the PR link to the WORK_ISSUE, and to the EPIC if there is one.

## Phase 5 — Update Linear (source of truth)
- Post the wrap-up comment on the WORK_ISSUE: what changed, which acceptance criteria are checked, what
  remains for the user to test.
- **Leave the WORK_ISSUE In Progress** — completion is downstream: `/chonchi` moves it to In Review once
  the user has tested it, and Done comes after the team's review/merge. If the user explicitly asks you
  to close it now, close ONLY the active work issue, and only with its acceptance criteria verified —
  never a sibling, never the epic.
- On the **PROJECT**: a high-level **executive-summary** status update (delivered, impact, next).
- Set/clean tags & labels. File follow-up issues for anything deferred.

## Phase 6 — Hand off for review (via /chonchi)
When the work is finished and **the user has tested it**, the review handoff is a separate, deliberate step
so the exported transcript captures the WHOLE conversation (not a mid-session snapshot). Do NOT export the
transcript or move the issue to In Review from here.

Tell the user:
> Ready for the team? Run **`/chonchi`** — it moves this work issue to **In Review**, comments a summary,
> attaches the **full session transcript**, adds the **branch/commit link**, and refreshes the roll-up on
> the parent epic, so the nightly code review (codex/another agent) can pick it up.

Finish with a short summary: what was built, the WORK_ISSUE and its state, the PR link, sibling work
issues still open (if any), and the `/chonchi` next step.

## Contract — what a run does and does not do

| Scenario | What this run does |
|---|---|
| Standalone work issue | Builds it on its own branch + PR. There is nothing else to touch. |
| Epic ID, one repo, one child | Resolves to that child and builds it. The epic gets In Progress at most — nothing else. |
| Epic, one repo, several work issues | ONE work issue per run, each on its own branch + PR — even though they share a repo. |
| Epic across repos, partially done | The finished package ships and is handed off individually; untouched siblings and the epic keep their state exactly. |
| Re-run on the same work issue | Continues on its existing branch; never restarts or absorbs siblings. |
