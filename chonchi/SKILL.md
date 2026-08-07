---
name: chonchi
description: "Hand the CURRENT session's finished, user-tested work issue off to the broader team for review. Usually run bare — no ID needed, since you've been building one work issue on one branch all session. Moves that work issue to In Review, comments a summary with actual-vs-estimate, attaches the FULL session transcript as markdown, adds the GitHub branch/commit/PR link, refreshes ONE roll-up comment on the parent epic (never overwriting the epic's values), and tags the work issue `chonchi` as a success marker so agents can find handed-off work. Use when the user types /chonchi, or says the work is done + tested + ready for team review. (dme)"
version: 0.5.0
---

# chonchi

The session's work is **done and the user has tested it** — you are now handing it off to the broader
team for review. This is the end-of-session ritual `/ccthis` (the build command) deliberately does NOT do,
because building is a multi-turn conversation and the export must capture the WHOLE session. Run `/chonchi`
once, at the end.

**The unit is the WORK ISSUE, never the epic.** `/ccthis` builds one work issue (a sub-issue of an epic,
or a standalone issue) per run — that work issue is what you hand off. The parent epic is touched exactly
once, in step E (the roll-up); its state, estimate and labels are aggregations of its children and are
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
your final summary; never silently skip a step. Step F (the `chonchi` tag) goes LAST because it's the
success marker — it should only land once the transcript and branch link are actually on the issue.

## A) Move the WORK ISSUE to In Review
- `get_issue <WORK_ISSUE>` to read its current state, team, **parent issue** (you'll need it in step E),
  and **current labels** (you'll need those in step F).
- `list_issue_statuses { team: "<team>" }`; find the state named **In Review** (or whose type is `review` —
  some teams call it "Review" / "In Review" / "Ready for Review"). If none exists, use the closest
  review-stage state and note which you picked.
- Only move it if it isn't already there: `save_issue { id: "<WORK_ISSUE>", state: "In Review" }`
  (`state` accepts the state name, type, or ID).
- Do NOT move it to Done — Done happens after the team's review/merge, not here. And do NOT move the
  parent epic's state here — that is step E's decision, by aggregation.

## B) Comment what happened
Post ONE `save_comment { issueId: "<WORK_ISSUE>", body: … }` that lets a reviewer (human or agent) get
oriented without replaying the session. Include:
- **What shipped** — the change in 2–5 bullets (features/fixes, key files/areas touched).
- **Testing done** — what the user verified and how (so the reviewer knows what's already covered).
- **Review focus / risks** — where you most want eyes; anything intentionally left out or deferred.
- **Code** — the GitHub links from step D (run `gh-links.sh` from step D1 first, then paste its output here
  so the branch/commit is one click from the issue).
- **Actual vs estimate** — if the work issue has an `## Estimate`, close the loop that makes it worth
  anything: `Estimate: 6–10 AI-h · Actual: ~14 AI-h (this session ~9 + 5 prior)`.
  - Derive **this session's** hours from the transcript: first to last timestamp of real work, not
    wall-clock with breaks.
  - **A work issue can span several sessions** — `/ccthis` is multi-turn by design — so before writing the
    number, check the WORK ISSUE's existing comments for a prior `Actual:` and report the **cumulative**
    total, showing the split. Reporting only the last session would bias every future estimate low, which
    is the exact failure this loop exists to prevent.
  - The actual lands HERE, on the work issue — never as a number written onto the epic (the epic only ever
    gets the step-E roll-up).
  - If you genuinely can't tell, write `Actual: not measured` rather than a number you invented.
  - Add one line on *why* it diverged when it did — that line is what calibrates the next estimate, not the
    number. `/linearthis` reads these back before estimating new work in the same project.
- A line: _"Full session transcript attached below."_

## C) Attach the FULL session transcript (.md) to the work issue
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
   OUT="/tmp/chonchi-<WORK_ISSUE>-transcript.md"
   node "$CONV" --out "$OUT"
   ```
   - If it errors "could not identify THIS session's transcript", pass the recorded path explicitly:
     `node "$CONV" --file "$(cat "$HOME/.claude/dme/last-transcript.path")" --out "$OUT"`.
   - If the converter truly can't be found or the output is empty, DON'T skip traceability — ask the user
     to run `/export` and attach the file manually.
2. Verify + measure (do NOT edit/re-render after this): `test -s "$OUT" && wc -c < "$OUT"` → this is `<bytes>` (>0).
3. Upload to `<WORK_ISSUE>` via the Linear MCP. Run prepare → PUT **back-to-back with nothing in between**
   (the signed URL expires in 60s):
   - `prepare_attachment_upload { issue: "<WORK_ISSUE>", filename: "chonchi-<WORK_ISSUE>-transcript.md", contentType: "text/markdown", size: <bytes>, title: "Claude Code transcript (chonchi)" }`
   - PUT the bytes, **single-quoting** every header from `uploadRequest.headers` verbatim (values like
     `Content-Disposition` contain double-quotes, so single-quote them to survive the shell; copy byte-for-byte):
     ```bash
     curl -X PUT --data-binary @"$OUT" \
       -H '<k1>: <v1>' -H '<k2>: <v2>' [...every header...] \
       -w '%{http_code}' -o /dev/null -sS "<uploadRequest.url>"
     ```
     Confirm the printed code is 2xx. If it's 403/expired, re-run `prepare_attachment_upload` and PUT again.
   - Only after a 2xx PUT: `create_attachment_from_upload { issue: "<WORK_ISSUE>", assetUrl: "<assetUrl>", title: "Claude Code transcript (chonchi)" }`

## D) Add the direct GitHub branch/commit link
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
2. Put those links in the **step-B comment** (already done above) AND add the branch/PR as a first-class Linear
   link attachment so it's clickable from the issue's Links:
   - `save_issue { id: "<WORK_ISSUE>", links: [{ url: "<branch or PR url>", title: "<Branch: name / PR #n>" }] }`
     (`links` is append-only — it won't clobber existing links). Use the PR url if there is one; otherwise the
     branch url; otherwise the commit url.

## E) Refresh the parent epic's roll-up (only if there IS a parent epic)
The epic **aggregates** its children; one child's handoff never overwrites the epic's own values. If the
work issue is standalone, skip this step entirely.
1. `get_issue` the parent epic and `list_issues { parentId }` (or read its children from the epic) so you
   have every child work issue's state and labels. `list_comments` on the epic.
2. Maintain **ONE roll-up comment**, identified by `<!-- chonchi-rollup -->` as its first line. If a
   comment containing that marker exists, UPDATE it in place (`save_comment` with that comment's `id`);
   otherwise create it. **Never post a second roll-up** — re-running `/chonchi` refreshes it, so repeated
   runs are safe by construction.
3. Roll-up body: the marker line, then one row per child work issue — state · `Actual:` (read from that
   child's step-B comment; `not measured` if absent) · handed off (`chonchi` label present) or not — then
   a line `Total so far: ~N AI-h · K of M work issues handed off`, and a list of what remains.
4. Move the EPIC to In Review **only if every child work issue is now handed off** (has the `chonchi`
   label, counting this one — check, don't assume). Otherwise leave the epic's state, estimate, labels
   and description exactly as they are.
5. Never write an `Actual:` on the epic outside this roll-up, and never touch sibling work issues.

## F) Tag the WORK ISSUE `chonchi` (the success marker)
Apply a Linear label named **`chonchi`** so humans and agents can filter for work that has been handed off —
it means "transcript + branch link are on this issue." Do this **last**, only after C and D actually
succeeded; if either failed, skip the tag and say so (the missing tag is itself the signal that it didn't
fully work).
1. Ensure the label exists (it's a normal Linear label): `list_issue_labels { team: "<team>", name: "chonchi" }`.
   If it's absent, create it once:
   `create_issue_label { name: "chonchi", team: "<team>", color: "#5e6ad2", description: "Handed off for review by /chonchi — full transcript + branch/commit link attached" }`.
2. Add it **without clobbering existing labels.** `save_issue`'s `labels` param REPLACES the whole set, so
   pass the UNION — every label the issue already has (from the `get_issue` in step A) PLUS `chonchi`:
   `save_issue { id: "<WORK_ISSUE>", labels: ["<existing label 1>", "<existing label 2>", …, "chonchi"] }`.
   (If `chonchi` is already there, this is a no-op — fine.)

## Finish
One short summary confirming each: **work issue In Review** ✅ · summary comment (with actual-vs-estimate)
✅ · **full transcript attached** ✅ · **GitHub branch/commit link on the issue** ✅ · **epic roll-up
refreshed** ✅ (or n/a for a standalone) · **`chonchi` label applied** ✅. Name the work issue you handed
off, whether the epic moved (and why), and call out anything that failed and what the user should do.

## Contract — how repeated and partial runs behave

| Scenario | What happens |
|---|---|
| Standalone work issue | Steps A–D + F on it. No epic, no roll-up. |
| Work issue under an epic | A–D + F on the work issue; the epic gets ONE refreshed roll-up (E) and moves to In Review only when its last child is handed off. |
| Epic across repos, some packages done | Only handed-off children are In Review + tagged; siblings and the epic keep their state; the roll-up says what remains. |
| `/chonchi` run twice on the same work issue | State move and label are no-ops, the step-B comment adds the cumulative actual, the roll-up is updated in place — no duplicates, nothing overwritten. |
| Handed an epic ID | Refuses to hand the epic off; resolves to this session's work issue (asks only if it can't tell). |
