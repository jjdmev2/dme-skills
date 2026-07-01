---
name: linearthis
description: "Turn a rough idea or a messy/unstructured backlog into well-formed Linear epic(s) + sub-issues with acceptance criteria — asks a few questions if it's fuzzy, previews the tree, then creates it. Ready to assign and run with /ccthis. Use when the user types /linearthis, wants to structure an idea/backlog, or plan work in Linear. (dme)"
version: 0.2.0
---

# linearthis

You are turning a rough idea into a clean Linear plan that another teammate can pick up and run
with `/ccthis`. Do NOT write code. Your output is Linear structure: epic(s) + sub-issues.

**Input:** whatever the user gave when invoking this skill — a rough idea, a feature name, or a
project name (e.g. `/linearthis add branded share links to Reus`). If nothing was given, use the
current brainstorm in the conversation as the input.

## Tooling — use what's installed, never leave a step empty
Prefer gstack skills when available. If the idea is fuzzy, use `/spec` to harden it into acceptance
criteria. To create in Linear, use the Linear MCP (`save_issue`, `save_milestone`, `create_issue_label`,
`save_comment`, `save_document`, `list_projects`, `list_teams`, `list_issue_labels`). If a skill isn't
installed, do the equivalent inline. Never skip a phase because one tool is missing.

## The standard you are creating to
- Hierarchy: `Project → Milestone → Epic (parent issue, label `epic`) → Sub-issue`.
- **Sizing rule (important):** an epic is shipped by `/ccthis` as **ONE branch / ONE PR**. So size each
  epic to fit in a single reasonable PR. If the idea is bigger than one PR, split it into **multiple
  epics** (a program), each PR-sized — never one giant epic.
- An epic has **≥2 sub-issues**. Sub-issues are the checklist worked inside the epic's one branch.
- **Epic body:** `## Objective` / `## Definition of Done` / `## Children` / `## Invariants` (guardrails/non-goals).
- **Sub-issue body:** `## Problem` / `## Acceptance Criteria` (checkboxes, testable) / `## Non-goals` / `## Notes/Links`.
- **Labels:** one type (`Feature`/`Improvement`/`Bug`) + `epic` on epics + `platform:*` / gates as needed.

## Phase 0 — Understand
- Read the input (or the brainstorm above). Identify the target **project** and **team**; if unclear,
  ask (list_projects / list_teams to offer the real options). Read relevant repo code/specs if it helps scope.

## Phase 1 — Ask a few sharp questions (batch them, ≤4)
Ask only what you can't safely infer. Prefer a single batched set covering:
1. **Outcome** — what does "done" look like for the whole thing? (drives Definition of Done)
2. **Scope / non-goals** — what's explicitly out of scope?
3. **Size** — one epic (PR-sized) or a big thing that should be several epics? Any deadline/milestone?
4. **Acceptance signals** — how will we know each part works? (drives per-sub-issue acceptance criteria)
Use `/spec` if available to deepen this. Keep it tight — don't interrogate.

## Phase 2 — Shape the tree
- Decide: 1 epic, or N epics (each PR-sized). Name them by outcome.
- For each epic: write Objective + Definition of Done + Invariants, and break it into sub-issues.
- For each sub-issue: write Problem + testable Acceptance Criteria (checkboxes) + Non-goals. Assign a
  type label and platform/gate labels. Add a rough estimate (S/M/L) if useful.
- Define the milestone(s) (outcome-based) and map each epic to one.

## Phase 3 — Preview & confirm (DO NOT create yet)
- Show the full proposed tree in chat: `Project → Milestone(s) → Epic(s) → sub-issues`, each with its
  Objective/Problem, acceptance criteria, and non-goals.
- Ask the user to approve or adjust. **Only proceed to Phase 4 after explicit approval.**

## Phase 4 — Create in Linear (after approval)
- Ensure required labels exist (`epic`, type, `platform:*`); `create_issue_label` for any missing.
- Create milestone(s) with `save_milestone` if they don't exist.
- Create each **epic** with `save_issue` (team, project, milestone, `epic` label, epic body template).
- Create each **sub-issue** with `save_issue`, setting `parentId` to its epic, plus body template + labels.
- Leave assignee empty (or assign per the user's instruction).
- Attach the source brief: save the brainstorm/spec as a Linear document or a comment on the epic.

## Phase 5 — Handoff
Report the created **epic IDs + URLs** and their sub-issue counts. Tell the user:
"Assign each epic, then the owner runs **`/ccthis <EPIC-ID>`** to build, ship, and auto-attach the transcript."
