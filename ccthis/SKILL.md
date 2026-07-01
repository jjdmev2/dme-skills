---
name: ccthis
description: "Complete a Linear epic (or issue) end-to-end — build with gstack, ship ONE PR per epic, keep Linear updated, and auto-attach the full session transcript to the epic for traceability. Use when the user types /ccthis, says \"cc this issue/epic\", or hands over a Linear ID to execute. (dme)"
version: 0.2.0
---

# ccthis

You are completing Linear work end-to-end. Linear is the single source of truth — keep it
updated the WHOLE time, not just at the end.

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
- **Branch, PR, and the transcript export are per EPIC — NOT per sub-issue.** One epic = one branch =
  one PR = one attached transcript. Sub-issues are the checklist worked inside that single branch.
- **No flat issues.** An epic has ≥2 sub-issues; a childless `[Epic]` title is a bug.
- **Sub-issue body:** `## Problem` / `## Acceptance Criteria` (checkboxes) / `## Non-goals`.
- **Labels:** one type (`Feature`/`Improvement`/`Bug`) + `epic` on epics + `platform:*` / gates as needed.
- **Definition of Done (epic-level):** every sub-issue's acceptance criteria checked · ONE PR linked to
  the epic · full transcript attached to the epic/issue (Phase 6) · merged/deployed or follow-ups filed.

## Phase 0 — Load
- Fetch the target from Linear (`get_issue`); read description + acceptance criteria in full.
- If it's an **EPIC**: list ALL its sub-issues — complete every one on a SINGLE branch. If it's a
  standalone issue with no epic, treat that issue as the unit (attach the transcript to it).
- Read linked specs and relevant code so you follow existing patterns.
- Set the epic **In Progress** (and each sub-issue as you start it); assign it to the user.
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
- Ensure every sub-issue is **Done** with its comment.
- Move the **EPIC** to **Done** once all sub-issues are done and the PR is merged.
- On the **PROJECT**: a high-level **executive-summary** status update (delivered, impact, next).
- Set/clean tags & labels. File follow-up issues for anything deferred.

## Phase 6 — FULL transcript → the epic (automatic, NO /export, NO re-run)
This attaches the same content `/export` would produce — automatically. Do NOT ask the user to run `/export`.
Throughout, `<ISSUE>` = the EPIC (or the standalone issue from Phase 0 if there is no epic).

⚠️ **Secrets:** the transcript captures everything printed this session — including any secrets echoed to
the terminal (tokens, `.env` values, keys, signed URLs). Skim the rendered file and redact obvious secrets
before uploading, OR confirm the epic/workspace is private. Note in your final summary that a full transcript
was attached.

1. Render THIS session to markdown. Locate the converter (first that exists) — it auto-detects this session:
   ```bash
   CONV="$HOME/.claude/dme/bin/transcript-to-md.mjs"
   [ -f "$CONV" ] || CONV="$HOME/.claude/skills/dme-cc/scripts/transcript-to-md.mjs"
   [ -f "$CONV" ] || CONV="$(find "$HOME/.claude" -name transcript-to-md.mjs 2>/dev/null | head -1)"
   OUT="/tmp/ccthis-<ISSUE>-transcript.md"
   node "$CONV" --out "$OUT"
   ```
   - If it errors "could not identify THIS session's transcript", pass the recorded path explicitly:
     `node "$CONV" --file "$(cat "$HOME/.claude/dme/last-transcript.path")" --out "$OUT"`.
   - If the converter truly can't be found or the output is empty, DON'T skip traceability — ask the user
     to run `/export` and attach the file manually.
2. Verify + measure (do NOT edit/re-render after this): `test -s "$OUT" && wc -c < "$OUT"` → this is `<bytes>` (>0).
3. Upload to `<ISSUE>` via the Linear MCP. Run prepare → PUT **back-to-back with nothing in between**
   (the signed URL expires in 60s):
   - `prepare_attachment_upload { issue: "<ISSUE>", filename: "ccthis-<ISSUE>-transcript.md", contentType: "text/markdown", size: <bytes>, title: "Claude Code transcript (ccthis)" }`
   - PUT the bytes, **single-quoting** every header from `uploadRequest.headers` verbatim (values like
     `Content-Disposition` contain double-quotes, so single-quote them to survive the shell; copy byte-for-byte):
     ```bash
     curl -X PUT --data-binary @"$OUT" \
       -H '<k1>: <v1>' -H '<k2>: <v2>' [...every header...] \
       -w '%{http_code}' -o /dev/null -sS "<uploadRequest.url>"
     ```
     Confirm the printed code is 2xx. If it's 403/expired, re-run `prepare_attachment_upload` and PUT again.
   - Only after a 2xx PUT: `create_attachment_from_upload { issue: "<ISSUE>", assetUrl: "<assetUrl>", title: "Claude Code transcript (ccthis)" }`
4. Confirm: issue **Done** ✅ · one PR linked ✅ · executive summary on project ✅ · **full transcript attached** ✅.

Finish with a short summary: epic completed, sub-issues closed, PR link, and the attached transcript.
