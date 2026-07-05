---
name: chonchi
description: "Hand the CURRENT session's finished, user-tested work off to the broader team for review. Usually run bare — no ID needed, since you've been building one epic on one branch all session. Moves that Linear issue to In Review, comments a summary, attaches the FULL session transcript as markdown, and adds the GitHub branch/commit/PR link so a nightly code-review agent (e.g. codex) can pick it up from the transcript. Use when the user types /chonchi, or says the work is done + tested + ready for team review. (dme)"
version: 0.3.1
---

# chonchi

The session's work is **done and the user has tested it** — you are now handing it off to the broader
team for review. This is the end-of-session ritual `/ccthis` (the build command) deliberately does NOT do,
because building is a multi-turn conversation and the export must capture the WHOLE session. Run `/chonchi`
once, at the end.

**Target — usually there is NO argument, and that's the normal case.** You've been building ONE epic on ONE
branch this entire session (that's how `/ccthis` works), so the issue is already in context — just use it.
Derive it, in order:
1. the epic/issue `/ccthis` was invoked on in this session;
2. any Linear issue ID already fetched/updated this session;
3. the current git branch name (it usually carries the ID, e.g. `kis-160-share-links` → `KIS-160`).

Use what you find and proceed — don't stop to ask for an ID you can already see. State which issue you're
handing off in your final summary so the user can catch a wrong guess. Only ask the user if NONE of the
above yields an issue (e.g. a fresh session with no `/ccthis` and an uninformative branch). An explicit
`/chonchi KIS-160` overrides everything. Throughout, `<ISSUE>` = that issue.

Do the four things below **in order**. Each is independent — if one fails, still do the rest and say so in
your final summary; never silently skip a step.

## A) Move the issue to In Review
- `get_issue <ISSUE>` to read its current state and team.
- `list_issue_statuses { team: "<team>" }`; find the state named **In Review** (or whose type is `review` —
  some teams call it "Review" / "In Review" / "Ready for Review"). If none exists, use the closest
  review-stage state and note which you picked.
- Only move it if it isn't already there: `save_issue { id: "<ISSUE>", state: "In Review" }`
  (`state` accepts the state name, type, or ID).
- Do NOT move it to Done — Done happens after the team's review/merge, not here.

## B) Comment what happened
Post ONE `save_comment { issueId: "<ISSUE>", body: … }` that lets a reviewer (human or agent) get oriented
without replaying the session. Include:
- **What shipped** — the change in 2–5 bullets (features/fixes, key files/areas touched).
- **Testing done** — what the user verified and how (so the reviewer knows what's already covered).
- **Review focus / risks** — where you most want eyes; anything intentionally left out or deferred.
- **Code** — the GitHub links from step D (run `gh-links.sh` from step D1 first, then paste its output here
  so the branch/commit is one click from the issue).
- A line: _"Full session transcript attached below."_

## C) Attach the FULL session transcript (.md) to the issue
This is the same export `/export` produces — rendered automatically from THIS session. Do NOT ask the user to
run `/export`.

⚠️ **Secrets:** the transcript captures everything printed this session — tokens, `.env` values, keys, signed
URLs. Skim the rendered file and redact obvious secrets before uploading, OR confirm the issue/workspace is
private. Note in your final summary that a full transcript was attached.

1. Render THIS session to markdown. Locate the converter (first that exists — it auto-detects this session):
   ```bash
   CONV="$HOME/.claude/dme/bin/transcript-to-md.mjs"
   [ -f "$CONV" ] || CONV="$HOME/.claude/skills/dme-cc/scripts/transcript-to-md.mjs"
   [ -f "$CONV" ] || CONV="$(find "$HOME/.claude" -name transcript-to-md.mjs 2>/dev/null | head -1)"
   OUT="/tmp/chonchi-<ISSUE>-transcript.md"
   node "$CONV" --out "$OUT"
   ```
   - If it errors "could not identify THIS session's transcript", pass the recorded path explicitly:
     `node "$CONV" --file "$(cat "$HOME/.claude/dme/last-transcript.path")" --out "$OUT"`.
   - If the converter truly can't be found or the output is empty, DON'T skip traceability — ask the user
     to run `/export` and attach the file manually.
2. Verify + measure (do NOT edit/re-render after this): `test -s "$OUT" && wc -c < "$OUT"` → this is `<bytes>` (>0).
3. Upload to `<ISSUE>` via the Linear MCP. Run prepare → PUT **back-to-back with nothing in between**
   (the signed URL expires in 60s):
   - `prepare_attachment_upload { issue: "<ISSUE>", filename: "chonchi-<ISSUE>-transcript.md", contentType: "text/markdown", size: <bytes>, title: "Claude Code transcript (chonchi)" }`
   - PUT the bytes, **single-quoting** every header from `uploadRequest.headers` verbatim (values like
     `Content-Disposition` contain double-quotes, so single-quote them to survive the shell; copy byte-for-byte):
     ```bash
     curl -X PUT --data-binary @"$OUT" \
       -H '<k1>: <v1>' -H '<k2>: <v2>' [...every header...] \
       -w '%{http_code}' -o /dev/null -sS "<uploadRequest.url>"
     ```
     Confirm the printed code is 2xx. If it's 403/expired, re-run `prepare_attachment_upload` and PUT again.
   - Only after a 2xx PUT: `create_attachment_from_upload { issue: "<ISSUE>", assetUrl: "<assetUrl>", title: "Claude Code transcript (chonchi)" }`

## D) Add the direct GitHub branch/commit link
So a nightly reviewer (codex/another agent) can read the transcript, find the code, and review it end-to-end.
1. Compute the links (first script that exists; it reads the repo you're in):
   ```bash
   LINKS="$HOME/.claude/dme/bin/gh-links.sh"
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
   - `save_issue { id: "<ISSUE>", links: [{ url: "<branch or PR url>", title: "<Branch: name / PR #n>" }] }`
     (`links` is append-only — it won't clobber existing links). Use the PR url if there is one; otherwise the
     branch url; otherwise the commit url.

## Finish
One short summary confirming each: **In Review** ✅ · summary comment posted ✅ · **full transcript attached**
✅ · **GitHub branch/commit link on the issue** ✅. Call out anything that failed and what the user should do.
