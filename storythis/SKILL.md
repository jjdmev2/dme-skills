---
name: storythis
description: "Turn FINISHED design/spec work into the right Linear structure for the dev team — adaptively. Creates the subset that fits: a value-framed Project (epic) + a shared design issue + lean, code-verified build stories, OR just some of those. Right-sizes — not everything needs a project: one small change → one issue; a whole module → project + design issue + stories; an existing project/design → add to it; a rough idea → backlog issues. Bakes in the house standard: lean story shape (In scope / Acceptance criteria / Edge cases / Out of scope / Dev context), Feature-vs-Improvement, stories blockedBy the design issue, real-vs-mock honesty, and VERIFY-every-claim-against-the-branch-code (not the design notes). For a DESIGNER handing off to devs — complements /linearthis (which shapes a fuzzy idea YOU will build via /ccthis). Use when the user types /storythis, or says 'turn this design into Linear stories', 'create the backlog for this', or 'hand this off to the devs'. (dme)"
version: 0.4.0
---

# storythis

You just finished a **design** (a feature, a redesign, a spec — on a branch, in a doc, or in this very
session) and now you're handing it to the **dev team** to build. Your job is to land it in Linear as the
**right structure** — no code — so a dev who wasn't in the room can pick it up cold, and a lead can prioritize.

**This is NOT `/linearthis`.** `/linearthis` shapes a fuzzy idea into an `Epic-issue → sub-issues` tree for the
person who'll build it themselves (then `/ccthis`). `/storythis` is the **designer→dev handoff** of *already-
designed* work, with heavier conventions: value-framed **Projects**, a shared **design issue** as the source of
truth, and **lean, code-verified build stories**. If the user actually wants to brainstorm a raw idea, point
them to `/linearthis` (or gstack `/office-hours`) first.

Work the phases in order. Each is independent — if a tool or step fails, do the rest and say so; never
silently skip. **Never write code.** Requires the Linear MCP (`/mcp` to log in).

---

## Phase 0 — Right-size the structure (the adaptive core — do this first)

Do NOT assume "project + design issue + stories." Decide what actually fits, and default to the **lightest
structure that does the job**. Derive from the input; ask only what you genuinely can't infer.

| Situation | Create |
|---|---|
| A whole feature/area, several stories, wants an owner-facing home + prioritization | **Project (epic)** + **design issue** + **build stories** |
| A self-contained change (fits one PR, a couple of ACs) | **One issue** (fold design + build) — no project, no separate design issue |
| The design already lives somewhere (a design issue, a doc, a branch) | **Skip creating a design issue** — point the stories' `blockedBy` at the existing one |
| A project already exists for this area | **Add to it** — don't make a duplicate (`list_projects` to find it) |
| Just capturing rough ideas / a wishlist | **Backlog issues only**, Low priority, each marked "idea / needs design / not critical" |
| Two+ distinct sub-areas (e.g. Users vs Groups) | **Two projects** sharing **one design issue** (stories `blockedBy` it cross-project is fine) |

Rules of thumb: a **Project** earns its keep only when there's enough work to prioritize and a lead needs a
home to reason about it. A **design issue** earns its keep when multiple stories share one design (it's the
thing they all `blockedBy`, and where the transcript/chats attach via `/chonchi`). When unsure, propose the
lighter option and let the user upgrade it.

State your chosen shape in one line before building (e.g. *"1 project + 1 design issue + 6 stories; design
issue already exists → I'll reuse it"*) so the user can catch a wrong call.

## Phase 1 — Gather context (derive, don't interrogate)

- **The design source:** this session / an `/office-hours` or `/spec` thread above / a branch / a doc. Use it.
- **Team + project:** `list_teams`, `list_projects` — offer the real options only if you can't infer them.
- **Related & already-shipped work:** `list_issues` (search by the feature's nouns). **Link, don't duplicate** —
  reference existing backend/frontend/enabler issues as "Builds on" and as an **"Already shipped (referenced,
  not rebuilt)"** note, so devs don't re-spec done work.
- **The code:** if the design is on a branch, **read the relevant files.** You will verify every story claim
  against this in Phase 4 — gathering it now makes that cheap.

## Phase 2 — (if the shape calls for it) The Project, value-framed

A project description must let anyone **prioritize and understand what we're doing** — not just list scope.
Use this template:

```
<one line: what area, who acts, what they do here>

## Why this matters
**For the customer (the buyer / security team):** the real-world problem this solves and why it's worth doing.
**For the user (the admin/operator):** the day-to-day job it enables.
**Value delivered:** the concrete outcomes.

## Priority & sequencing
Which stories are the backbone vs. the payoff vs. lifecycle, and in what order. Call out any BACKEND or
cross-team dependencies that gate value (so leads sequence against them).

## Notes & follow-ups
- Known gaps as VISIBLE notes (what's deliberately not handled yet, and roughly when to revisit).
- Non-critical ideas → a pointer to their backlog issue.

## Structure
- 🎨 UI/UX design — <design issue>  (all design chats attach here)
- 🔧 Build stories — <range>, each blockedBy the design issue
- 💡 Backlog ideas — <low-pri issues>, if any

## Already shipped (referenced, not rebuilt)
<links to the foundation this builds on>
```

Set team, lead, a type label, priority, and a start/target date if known. When the design is done and you're
handing off, also post a **project status update** (`save_status_update`, health `onTrack`): "design complete →
build handoff", what's ready, the suggested sequence, the dependencies.

## Phase 3 — (if the shape calls for it) The design issue (shared source of truth)

One issue the build stories all point at. Body:
- **What was designed** — the decisions, grouped by surface (bullets).
- **Where it lives** — branch, key files, doc links, commit range.
- **Status** — Done only if it's built + pushed + handed off; otherwise In Review/In Progress. **Never move a
  Done issue backwards.**

This is also where `/chonchi` attaches the full session transcript — so a nightly reviewer can see how the
design was produced. Assign to the designer; label `UX/UI` (or your design label).

## Phase 4 — The build stories (the house standard: lean + code-verified)

One story per admin-facing capability, "**Admin <does X>**" voice. Body template — keep it LEAN (a third the
length of a fully-specified ticket): UX behavior + honest real/mock only. **No design rationale, no code
walkthroughs, no per-field minutiae** (that lives in the design + the running UI).

```
**Blocked by:** <design issue> (design) · **Builds on:** <foundation issues, plain IDs>

## In scope
2–3 sentences: what the admin does/sees, the surface/route, and what's a separate story.

## Acceptance criteria
4–6 checkboxes of observable behavior (the happy path). Last line: "Localized (…) and dark-mode correct."

## Edge cases
2–3 checkboxes — only the ones that matter for THIS story (empty vs error, honest states, failure-keeps-state,
double-submit, dedupe, caps).

## Out of scope
One line, each excluded concern → the sibling story BY NAME.

## Dev context
2–3 sentences: the real-vs-mock truth + a pointer "Design lives in <design issue> / branch <name>".
```

- **Label:** `Feature` = net-new capability; `Improvement` = redesign/enhancement of something already shipped.
  Evaluate per story against what exists.
- **`blockedBy`** the design issue. Priority/estimate per story. Assignee unset unless told.
- **Out of scope** points to siblings so single-ownership is explicit and there are no gaps/overlaps.

### ⚠️ Verify every claim against the CURRENT branch code — not the design summary
This is the step that's easy to skip and burns you. Design notes and earlier drafts describe **superseded
iterations**; write from the summary and stale claims slip in (real examples that shipped wrong once: a "Danger
zone" that had been replaced by a swapping footer; a stat header claimed "click to filter" when it's a read-only
readout; a Save gate claimed "until changed" when it's non-empty-name-only). After drafting, **audit each
story's claims against the source files and fix any drift** — for a big set, fan out one verifier per story
(read the live issue + the branch code, report only code-contradicted claims with file:line) and re-check the
high-severity ones yourself. Get real-vs-mock exactly right: don't claim "empty in real mode" for a wired path,
or "persists" for a mock-only one.

## Phase 5 — Ideas & follow-ups

- **Non-critical ideas** → a **Low-priority backlog issue**, body clearly marked "idea / needs design / not
  critical", `relatedTo` the story it extends, intentionally **not** `blockedBy` the design issue if it's
  undesigned. Say so.
- **Known gaps** → a **visible Notes & follow-ups** entry in the project AND a one-line note on the exact story
  it touches, framed with rough effort + timing ("small, low-risk, revisit near the end") so priority is obvious.

## Phase 6 — Preview, create, hand off

- **Preview the plan in chat before creating a lot** (the shape from Phase 0 + the story titles + labels). For a
  big set, create incrementally so the user can catch a wrong call early; **ask before mass changes.**
- Create with the Linear MCP (`save_project`, `save_issue`, `save_status_update`). `blockedBy` is append-only.
- **Report** the created IDs + URLs and the chosen shape. If the design is done, remind the user they can run
  **`/chonchi <design-issue>`** to attach the transcript to it.

---

## Defaults & etiquette
- **Lightest structure that fits.** Never create a project/design-issue "to be thorough" if the work doesn't
  need one.
- **Run bare** where possible — derive the feature from the session/branch; ask only what you can't infer,
  batched (≤4 questions).
- **Create-then-review cadence:** the user reviews as you go; preview before bulk creation; ask before mass edits.
- **Don't reopen Done work;** reference-don't-duplicate; in Linear (dev-facing) middots/em-dashes are fine —
  product-UI copy rules don't apply here.
- **Fallback:** if `/storythis` ever reports "Unknown skill" (some setups don't auto-register skills), run
  its phases manually — this file is a complete prompt, and the Linear MCP still works.
