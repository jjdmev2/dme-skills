---
name: ccthis
description: "Build a Linear epic (or issue) end-to-end — set it In Progress, build with gstack, move sub-issues as you go, keep Linear updated, and ship ONE PR per epic. Building is a multi-turn conversation (you review + give feedback); when it's tested and ready for the team, hand off with /chonchi. Use when the user types /ccthis, says \"cc this issue/epic\", or hands over a Linear ID to execute. (dme)"
version: 0.3.0
---

# ccthis

You are building Linear work end-to-end. Linear is the single source of truth — keep it
updated the WHOLE time, not just at the end. This is a **multi-turn conversation**: you build, the user
reviews and gives feedback, you iterate. When the work is finished and the user has tested it, they run
**`/chonchi <ISSUE>`** to hand off for team review (move to In Review, comment, attach the full transcript,
and add the branch/commit link). Do NOT try to export the transcript or close things out from here —
that belongs to `/chonchi`, at the end.

**Target:** the Linear epic or issue ID the user gave when invoking this skill (e.g. `/ccthis ENG-45`
→ `ENG-45`). If a file path like `LINEAR.md` was given, read it as the spec. If nothing was given,
ask which epic/issue to work.

## Tooling — use what's installed, never leave a step empty
Prefer gstack skills when available (`/spec`, `/autoplan`, `/investigate`, `/code-review`, `/review`,
`/qa`, `/ship`, `/codex`). If a referenced skill is NOT installed, do the equivalent with native tools
(e.g. no `/ship` → create the PR with `git` + `gh`; no `/code-review` → review the diff yourself).
Never skip a phase because one tool is missing.

## The standard (always enforce)
- Hierarchy: `Project → Milestone → Epic (parent issue, label `epic`) → Sub-issue`.
- **Branch and PR are per EPIC — NOT per sub-issue.** One epic = one branch = one PR. Sub-issues are the
  checklist worked inside that single branch.
- **No flat issues.** An epic has ≥2 sub-issues; a childless `[Epic]` title is a bug.
- **Sub-issue body:** `## Problem` / `## Acceptance Criteria` (checkboxes) / `## Non-goals`.
- **Labels:** one type (`Feature`/`Improvement`/`Bug`) + `epic` on epics + `platform:*` / gates as needed.
- **Definition of Done (epic-level):** every sub-issue's acceptance criteria checked · ONE PR linked to
  the epic · user has tested it · handed off for review with `/chonchi` (In Review + full transcript +
  branch/commit link) · merged/deployed or follow-ups filed.

## Phase 0 — Load
- Fetch the target from Linear (`get_issue`); read description + acceptance criteria in full.
- If it's an **EPIC**: list ALL its sub-issues — complete every one on a SINGLE branch. If it's a
  standalone issue with no epic, treat that issue as the unit (that's what `/chonchi` hands off later).
- Read linked specs and relevant code so you follow existing patterns.
- Set the epic **In Progress** if it isn't already; assign it to the user. Move sub-issues freely across
  statuses (Todo → In Progress → Done) as you pick them up and finish them — keep Linear mirroring reality.
- Create **ONE branch for the epic** and do all the work on it.

## Phase 1 — Plan (gstack, as needed)
- Fuzzy/missing acceptance criteria → `/spec`, then update the Linear description.
- Non-trivial work → `/autoplan` (or `/plan-eng-review`). Post the plan as a comment on the epic.

## Phase 2 — Build (one EPIC = one branch = one PR)
Work through the epic's sub-issues on the single epic branch:
- `/freeze` the directories in play; `/guard` / `/careful` near destructive commands.
- For each sub-issue: implement ONLY its acceptance criteria. No unrelated files, no opportunistic refactors.
- `/investigate` to root-cause bugs. Add/update tests when logic/data/permissions/UX change.
- As each sub-issue finishes: mark it **Done** in Linear with a short comment (what changed + AC checked).
  **Do NOT open a separate branch or PR per sub-issue.**
- You MAY parallelize with `claude ultracode` (one agent per sub-issue), but integrate every agent's
  work back onto the ONE epic branch before the PR.

## Phase 3 — Review (run whatever is installed; skip missing tools, don't block)
- gstack: `/code-review` (+ `/review` pre-landing) on the epic branch diff; apply must-fix findings.
- `/codex` as a second reviewer if available; reconcile with gstack.
- Conductor native review if configured; resolve blocking comments.
- Re-run the narrowest useful checks (lint/build/tests) for the files touched.

## Phase 4 — Ship (ONE PR for the whole epic)
- Open a SINGLE PR for the epic with `/ship`. PR body: what changed across all sub-issues, why,
  link to the EPIC (list the sub-issues it closes), AC checked, risk, how to test, what you
  intentionally did not do, agent involvement, follow-ups.
- Attach the PR link to the **EPIC**.

## Phase 5 — Update Linear (source of truth)
- Ensure every sub-issue is **Done** with its comment (what changed + AC checked).
- On the **PROJECT**: a high-level **executive-summary** status update (delivered, impact, next).
- Set/clean tags & labels. File follow-up issues for anything deferred.
- **Leave the EPIC In Progress.** Do NOT move it to Done or In Review here — the user still reviews and tests.
  The review handoff (In Review + transcript + branch link) is `/chonchi`'s job, run once at the very end.

## Phase 6 — Hand off for review (via /chonchi)
When the work is finished and **the user has tested it**, the review handoff is a separate, deliberate step
so the exported transcript captures the WHOLE conversation (not a mid-session snapshot). Do NOT export the
transcript or move the issue to In Review from here.

Tell the user:
> Ready for the team? Run **`/chonchi <ISSUE>`** — it moves the issue to **In Review**, comments a summary,
> attaches the **full session transcript**, and adds the **branch/commit link** so the nightly code review
> (codex/another agent) can pick it up.

Finish with a short summary: what was built, sub-issues closed, the PR link, and the `/chonchi <ISSUE>`
next step.
