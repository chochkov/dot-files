---
name: asana-catchup
description: This skill should be used when the user asks to "catch me up on Asana", "what's new in Asana", "asana standup", "asana digest", or otherwise wants a read-only summary of what changed on their Asana workload. Surfaces newly-assigned/recently-active tasks and stale tasks that haven't moved in a while, grouped by project, within the flowkey workspace.
---

# Asana Catch-up

Read-only cross-project digest of the user's Asana workload via `mcp__claude_ai_Asana__*` tools. Never comments, updates, or otherwise mutates anything — this skill only reads and summarizes. If the user wants to act on something surfaced here (comment, reassign, reschedule), that's a separate explicit request (see the `asana-commenting` skill for posting comments).

Scope: this connector is authenticated to a single Asana workspace ("flowkey"). There is currently no way to reach a separate personal Asana account/workspace through this connector — if the user has one, it needs its own connection in claude.ai settings before this skill can cover it.

## Data source

Prefer `search_tasks` (assignee_any=me, completed=false) since it supports server-side date filters directly. If it errors (e.g. workspace isn't on a Premium plan), fall back to `get_my_tasks` with `opt_fields=name,due_on,due_at,created_at,modified_at,permalink_url,projects.name,completed` and paginate via `offset`/`next_page` until enough history is covered, then do the date filtering client-side.

Always fetch `opt_fields` including at minimum: `name,due_on,due_at,created_at,modified_at,permalink_url,projects.name,completed`.

## Buckets

Default lookback windows — adjust if the user asks for a different window (e.g. "stale for over a month"):

- **Newly assigned / active** — incomplete tasks with `created_at` in the last 7 days, OR `modified_at` in the last 3 days. This is a proxy, not a precise "assigned to you" event: the Asana API exposed here has no clean "assigned_at" field, so recently-created-and-assigned-to-you or recently-touched-while-assigned-to-you is the closest available signal. Say so if the user asks how "newly assigned" is determined.
- **Stale, needs a nudge** — incomplete tasks with `modified_at` between 14 and 60 days ago. This window is deliberate: real workloads accumulate years of untouched backlog (tasks from long-closed projects, years-old "someday" items), and a stale bucket with no upper bound gets swamped by that graveyard instead of surfacing what's actually actionable — stuff that went quiet recently enough that a nudge still makes sense. Mention in the output that anything older than 60 days was excluded as long-term backlog, and offer to widen the window if the user asks for it.

Sort "newly assigned" newest-first (by `modified_at` or `created_at`, whichever triggered inclusion). Sort "stale" by `modified_at` descending too — the task that *just* crossed into staleness (closest to 14 days) belongs at the top, since it's the one most likely to still be worth a nudge; a task quiet for 59 days is lower-priority than one quiet for 15.

Cap each bucket at 15 tasks; if more match, say how many were truncated rather than silently dropping them.

## Output

Group each bucket by project (from `projects[].name`; use "No project" if empty). Within each project, one line per task:

- Task name (as a link using `permalink_url` if rendering supports it, else plain text)
- Due date if set
- For "newly assigned": how recently created/touched (e.g. "created 2d ago")
- For "stale": how long since last touched (e.g. "untouched 23d")

Keep it terse — this is a scan-and-triage view, not a report. No preamble, no closing summary paragraph. If a bucket is empty, say so in one line rather than omitting the section silently.
