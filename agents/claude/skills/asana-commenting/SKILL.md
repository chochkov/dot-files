---
name: asana-commenting
description: This skill should be used when the user asks to "comment on this Asana task", "add a comment to this task", "post an update on Asana", "leave a comment on the task", or otherwise asks Claude to post to an Asana task's activity feed. Encodes the user's personal tone, mention, and formatting preferences for Asana comments.
---

# Asana Commenting

Personal conventions for posting comments to Asana tasks via the Asana MCP tools (`mcp__claude_ai_Asana__*`).

## When to Comment

Only post a comment when explicitly asked to. Never proactively add a comment to Asana as a side effect of finishing other work (e.g. completing a task, updating a plan) unless directly requested in that moment.

Before calling `add_comment`, check whether the task's project is private:

1. Get the task's project(s) (from `get_task`'s `projects`/`memberships` fields, or the `project_id` already in hand).
2. Call `mcp__claude_ai_Asana__get_project` with `opt_fields` including `privacy_setting` (and `team`/`members` if `privacy_setting` alone is ambiguous).
3. If the project is private (only the user, or an explicit small member list — not shared with a team or public to the workspace), post directly without confirmation.
4. If the project is team-shared or public to the workspace, show the drafted comment text to the user and get confirmation before posting — this is visible to other people.
5. If a task belongs to multiple projects with mixed privacy, treat it as shared and confirm.
6. If privacy can't be determined (e.g. `get_project` fails or `privacy_setting` is missing), default to confirming first.

This check is skipped only if the user has already dictated the exact wording to post *and* confirmed they want it posted as-is.

## Tone and Format

- Terse status update, not a narrative. State what happened/what's needed, nothing more.
- Casual register, not formal.
- Write in first person, as the task owner (e.g. "Done, moving this to review" not "Claude has completed this task").
- Avoid verbosity: no restating the task, no preamble, no closing pleasantries. Prefer one or two short sentences/lines over paragraphs.
- No throat-clearing intros or boilerplate framing phrases — e.g. "Where things stand:", "Quick update:", "Just wanted to note that...". Go straight to the substance, first word.
- Use `html_text` freely for structure, not just when a mention forces it: `<strong>` to emphasize key words/status, `<ul>`/`<li>` bullet lists to break up multiple points, and headings (`<strong>` on a short line, since Asana comments don't render `<h1>`-style headings) to separate sections when a comment covers more than one topic. Favor bullets and bold over a single dense paragraph whenever there's more than one point to make.
- Plain text is still fine for a single short one-line update with nothing to emphasize or list — don't force structure onto a trivial comment.

## Converting Names to @-Mentions

When the comment text (as given by the user) contains a person's name — e.g. "Hey Philip, please close this once you're done" — replace that name with a real Asana @-mention instead of leaving it as plain text, provided a matching contributor can be found.

Procedure:

1. Call `mcp__claude_ai_Asana__get_users` (optionally scoped with `team`) to list workspace/team members, or `mcp__claude_ai_Asana__get_user` if the exact email is already known.
2. Match the name in the comment against the returned `name` fields (case-insensitive, first-name match is fine — "Philip" matching "Philip Müller" is enough).
3. If exactly one match is found, build the comment with `html_text` and reference the user's `gid` via `<a data-asana-gid="USER_GID"/>` — the API expands this into a proper @-mention automatically. Do not hand-construct href/name; let Asana resolve it from the gid.
4. If no match is found, leave the name as plain text and mention to the user that no matching contributor was found (don't silently guess).
5. If multiple plausible matches are found (e.g. two people named "Philip"), ask the user which one before posting rather than guessing.

Example: for a request to post "Hey Philip, please close this task once you're done", and `get_users` returns a Philip with gid `987654321`, post via `html_text`:

```
<body>Hey <a data-asana-gid="987654321"/>, close this once you're done</body>
```

Note the terse rewrite — the source phrasing gets tightened to match the terse/casual tone above, not copied verbatim.
