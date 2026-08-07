---
name: chonchi
description: "Hand the CURRENT session's finished, user-tested work issue off to the broader team for review. Usually run bare — no ID needed, since you've been building one work issue on one branch all session. Moves that work issue to In Review, comments a summary with actual-vs-estimate, attaches the FULL session transcript as markdown, adds the GitHub branch/commit/PR link, refreshes ONE roll-up comment on the parent epic (never overwriting the epic's values), and tags the work issue `chonchi` as a success marker so agents can find handed-off work. Use when the user types /chonchi, or says the work is done + tested + ready for team review. (dme)"
version: 0.5.0
---

# chonchi

The session's work is **done and the user has tested it** — you are now handing it off to the broader
team for review. This is the end-of-session ritual `/ccthis` (the build command) deliberately does NOT do,
because building is a multi-turn conversation and the export must capture the WHOLE session. Run `/chonchi`
once, at the end. Before the steps, locate the source transcript filename/path that will be exported and
derive a stable `<SESSION_KEY>` from it (for example, a deterministic hash of that canonical path). Use
that exact key for this run's comment marker and transcript filename; do not derive it from wall-clock time.

**The unit is the WORK ISSUE, never the epic.** `/ccthis` builds one work issue (a sub-issue of an epic,
or a standalone issue) per run — that work issue is what you hand off. The parent epic is touched exactly
once, in step F (the roll-up); its state, estimate and labels are aggregations of its children and are
never overwritten by one child's handoff.

**Target — usually there is NO argument, and that's the normal case.** You've been building ONE work issue
on ONE branch this session (that's how `/ccthis` works), so it is already in context — just use it.
Derive it, in order:
1. the work issue `/ccthis` built this session — if `/ccthis` was invoked on an epic ID, the work issue
   it selected, NOT the epic;
2. any Linear issue ID already fetched/updated this session that matches this branch's work;
3. the current git branch name (it usually carries the ID, e.g. `kis-160-share-links` → `KIS-160`).

**If what you derived — or were explicitly handed — is an EPIC, do not hand the epic off.** Resolve it to
the child work issue this session's branch actually built; ask only if you genuinely can't tell. An
explicit `/chonchi KIS-160` overrides the derivation, subject to the same rule. State which work issue
you're handing off in your final summary so the user can catch a wrong guess. Throughout,
`<WORK_ISSUE>` = that issue.

Do the six steps below **in order**. Each is independent — if one fails, still do the rest and say so in
your final summary; never silently skip a step. Step E (the `chonchi` tag) is the success marker: apply it
only after the transcript attachment and GitHub link both succeed. Step F refreshes the parent epic only
after that state is accurate.

## A) Move the WORK ISSUE to In Review
- `get_issue <WORK_ISSUE>` to read its current state, team, **parent issue** (you'll need it in step F),
  and **current labels** (you'll need those in step E).
- `list_issue_statuses { team: "<team>" }`; find the state named **In Review** (or whose type is `review` —
  some teams call it "Review" / "In Review" / "Ready for Review"). If none exists, use the closest
  review-stage state and note which you picked.
- Only move it if it isn't already there: `save_issue { id: "<WORK_ISSUE>", state: "In Review" }`
  (`state` accepts the state name, type, or ID).
- Do NOT move it to Done — Done happens after the team's review/merge, not here. And do NOT move the
  parent epic's state here — that is step F's decision, by aggregation.

## B) Attach the FULL session transcript (.md) to the work issue
This is the same export `/export` produces — rendered automatically from THIS session. Do NOT ask the user to
run `/export`.

⚠️ **Secrets:** the transcript captures everything printed this session — tokens, `.env` values, keys, signed
URLs. Skim the rendered file and redact obvious secrets before uploading, OR confirm the issue/workspace is
private. Note in your final summary that a full transcript was attached.

1. Render THIS session to markdown. Locate the converter (first that exists — it auto-detects this session):
   ```bash
   CONV="$HOME/.claude/dme/bin/transcript-to-md.mjs"
   [ -f "$CONV" ] || CONV="$HOME/.claude/skills/dme-skills/scripts/transcript-to-md.mjs"
   [ -f "$CONV" ] || CONV="$HOME/.claude/skills/dme-cc/scripts/transcript-to-md.mjs"
   [ -f "$CONV" ] || CONV="$(find "$HOME/.claude" -name transcript-to-md.mjs 2>/dev/null | head -1)"
   SOURCE_TRANSCRIPT="$(cat "$HOME/.claude/dme/last-transcript.path")"
   SESSION_KEY="$(printf '%s' "$SOURCE_TRANSCRIPT" | shasum -a 256 | cut -c1-16)"
   OUT="/tmp/chonchi-<WORK_ISSUE>-transcript-<SESSION_KEY>.md"
   node "$CONV" --file "$SOURCE_TRANSCRIPT" --out "$OUT"
   ```
   - `SOURCE_TRANSCRIPT` must be the filename/path actually passed to the exporter. If its recorded path is
     unavailable, locate the actual source first, then derive `SESSION_KEY` from that path before exporting.
   - If the converter truly can't be found or the output is empty, DON'T skip traceability — ask the user
     to run `/export` and attach the file manually.
2. Verify + measure (do NOT edit/re-render after this): `test -s "$OUT" && wc -c < "$OUT"` → this is `<bytes>` (>0).
3. List/inspect existing issue attachments first. If an attachment already has the exact deterministic
   filename `chonchi-<WORK_ISSUE>-transcript-<SESSION_KEY>.md`, skip upload; otherwise upload it via the
   Linear MCP. Run prepare → PUT **back-to-back with nothing in between**
   (the signed URL expires in 60s):
   - `prepare_attachment_upload { issue: "<WORK_ISSUE>", filename: "chonchi-<WORK_ISSUE>-transcript-<SESSION_KEY>.md", contentType: "text/markdown", size: <bytes>, title: "Claude Code transcript (chonchi, <SESSION_KEY>)" }`
   - PUT the bytes, **single-quoting** every header from `uploadRequest.headers` verbatim (values like
     `Content-Disposition` contain double-quotes, so single-quote them to survive the shell; copy byte-for-byte):
     ```bash
     curl -X PUT --data-binary @"$OUT" \
       -H '<k1>: <v1>' -H '<k2>: <v2>' [...every header...] \
       -w '%{http_code}' -o /dev/null -sS "<uploadRequest.url>"
     ```
     Confirm the printed code is 2xx. If it's 403/expired, re-run `prepare_attachment_upload` and PUT again.
   - Only after a 2xx PUT: `create_attachment_from_upload { issue: "<WORK_ISSUE>", assetUrl: "<assetUrl>", title: "Claude Code transcript (chonchi, <SESSION_KEY>)" }`

## C) Add the direct GitHub branch/commit link
So a nightly reviewer (codex/another agent) can read the transcript, find the code, and review it end-to-end.
1. Compute the links (first script that exists; it reads the repo you're in):
   ```bash
   LINKS="$HOME/.claude/dme/bin/gh-links.sh"
   [ -f "$LINKS" ] || LINKS="$HOME/.claude/skills/dme-skills/scripts/gh-links.sh"
   [ -f "$LINKS" ] || LINKS="$HOME/.claude/skills/dme-cc/scripts/gh-links.sh"
   [ -f "$LINKS" ] || LINKS="$(find "$HOME/.claude" -name gh-links.sh 2>/dev/null | head -1)"
   bash "$LINKS"
   ```
   It prints repo · branch (if pushed) · latest commit · open PR. If the branch isn't pushed, the **commit**
   link is the reliable one — that's exactly the "if there is no branch, link the commit" fallback.
   (No script found? Derive it inline: `git remote get-url origin`, `git rev-parse --abbrev-ref HEAD`,
   `git rev-parse HEAD` → `https://github.com/<owner>/<repo>/tree/<branch>` and `…/commit/<sha>`.)
2. Inspect the issue's existing Links first. If an identical PR, branch, or commit URL already exists, skip
   it; otherwise add it as a first-class Linear link attachment so it is clickable from the issue's Links:
   - `save_issue { id: "<WORK_ISSUE>", links: [{ url: "<branch or PR url>", title: "<Branch: name / PR #n>" }] }`
     (`links` is append-only — it won't clobber existing links). Use the PR URL if there is one; otherwise the
     branch URL; otherwise the commit URL.

## D) Create or update the session handoff comment
1. `list_comments` on the WORK ISSUE. The handoff comment must begin with exactly
   `<!-- chonchi-session:<SESSION_KEY> -->`. Exclude every record with the current `<SESSION_KEY>` from
   prior-session calculation; if an existing current-marker comment is present, update it in place
   (`save_comment` with its `id`) rather than creating another one. For every *other* SESSION_KEY, retain
   at most one marked record (the newest if malformed duplicates exist).
2. The comment lets a reviewer (human or agent) get oriented without replaying the session. Include:
   - **What shipped** — the change in 2–5 bullets (features/fixes, key files/areas touched).
   - **Testing done** — what the user verified and how (so the reviewer knows what's already covered).
   - **Review focus / risks** — where you most want eyes; anything intentionally left out or deferred.
   - **Code** — the GitHub links from step C.
   - **Actual vs estimate** — if the work issue has an `## Estimate`, close the loop. Derive this session's
     hours from the transcript (first to last timestamp of real work, excluding breaks) only when measurable.
     Read only the retained, unique marked records for other SESSION_KEYs; do not treat an arbitrary
     `Actual:` comment as prior session data. Recompute cumulative actual as the sum of those other unique
     `Session actual:` values plus the current session exactly once; do not sum historical cumulative values.
     Then update/create the single current-marker comment. Use explicit fields:
     `Estimate: 6–10 AI-h` (if present), `Session actual: ~9 AI-h`, and
     `Cumulative actual: ~14 AI-h`. If either value cannot be measured, write `Session actual: not measured`
     and/or `Cumulative actual: not measured` — never invent a number. Add one line explaining a material
     estimate divergence.
   - The actual lands HERE, on the work issue — never as a number written onto the epic (the epic only ever
     gets the step-F roll-up).
   - A line: _"Full session transcript attached below."_

## E) Tag the WORK ISSUE `chonchi` (the success marker)
Apply a Linear label named **`chonchi`** so humans and agents can filter for work that has been handed off —
it means "transcript + branch link are on this issue." Do this only after B and C actually succeeded; if
either failed, skip the tag and say so (the missing tag is itself the signal that it did not fully work).
1. Ensure the label exists (it's a normal Linear label): `list_issue_labels { team: "<team>", name: "chonchi" }`.
   If it's absent, create it once:
   `create_issue_label { name: "chonchi", team: "<team>", color: "#5e6ad2", description: "Handed off for review by /chonchi — full transcript + branch/commit link attached" }`.
2. Immediately before adding the label, re-fetch the WORK ISSUE and use its **fresh** labels. `save_issue`'s
   `labels` param REPLACES the whole set, so pass the UNION — every freshly fetched label PLUS `chonchi`:
   `save_issue { id: "<WORK_ISSUE>", labels: ["<fresh label 1>", "<fresh label 2>", …, "chonchi"] }`.
   (If `chonchi` is already there, this is a no-op — fine.)

## F) Refresh the parent epic's roll-up (only if there IS a parent epic)
The epic **aggregates** its children; one child's handoff never overwrites the epic's own values. If the
work issue is standalone, skip this step entirely.
1. `get_issue` the parent epic and `list_issues { parentId }` (or read its children from the epic) so you
   have every child work issue's state and labels. `list_comments` on the epic **and on every child**.
2. Maintain **ONE roll-up comment**, identified by `<!-- chonchi-rollup -->` as its first line. If a
   comment containing that marker exists, UPDATE it in place (`save_comment` with that comment's `id`);
   otherwise create it. **Never post a second roll-up** — re-running `/chonchi` refreshes it, so repeated
   runs are safe by construction.
3. Roll-up body: the marker line, then one row per child work issue — state · `Cumulative actual:` from the
   newest marked `<!-- chonchi-session:... -->` handoff record on that child (`not measured` if absent) ·
   handed off only when the child has the `chonchi` label **and** is in a review/completed state — then
   a line `Total so far: ~N AI-h · K of M work issues handed off` when every included actual is measurable,
   otherwise `Total so far: not measured · K of M work issues handed off`, and a list of what remains.
4. Move the EPIC to In Review **only if every child work issue is now handed off** (has the `chonchi`
   label, counting this one — check, don't assume) **and** is in a review/completed state. Otherwise leave
   the epic's state, estimate, labels and description exactly as they are.
5. Never write an `Actual:` on the epic outside this roll-up, and never touch sibling work issues.

## Finish
One short summary confirming each: **work issue In Review** ✅ · **full transcript attached** ✅ ·
**GitHub branch/commit link on the issue** ✅ · session handoff comment (with `Session actual:` and
`Cumulative actual:`) ✅ · **`chonchi` label applied** ✅ · **epic roll-up refreshed** ✅ (or n/a for a
standalone). Name the work issue you handed
off, whether the epic moved (and why), and call out anything that failed and what the user should do.

## Contract — how repeated and partial runs behave

| Scenario | What happens |
|---|---|
| Standalone work issue | Steps A–E on it. No epic, no roll-up. |
| Work issue under an epic | A–E on the work issue; F refreshes ONE epic roll-up and moves the epic to In Review only when every child is tagged `chonchi` and in a review/completed state. |
| Epic across repos, some packages done | Only children that are tagged `chonchi` and in a review/completed state count as handed off; siblings and the epic otherwise keep their state; the roll-up says what remains. |
| `/chonchi` run twice in the same session | The current-key record is excluded from prior totals, then its single `<!-- chonchi-session:<SESSION_KEY> -->` comment is updated in place; its deterministic transcript attachment and identical link are reused, the session's hours are counted once, and the roll-up is updated in place. |
| `/chonchi` run in a distinct later session | It creates one new marked handoff record and deterministic attachment, then adds that session's actual once to cumulative actual; the roll-up reads the newest marked record. |
| Handed an epic ID | Refuses to hand the epic off; resolves to this session's work issue (asks only if it can't tell). |
