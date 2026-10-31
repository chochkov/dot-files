## Privacy

Never include real personal information in code, comments, docstrings,
plan files, or examples — this includes email addresses, phone numbers,
names, or any other PII. Use placeholder values instead:
- Emails: user@example.com, admin@example.com
- Names: Alice, Bob (generic)
- Accounts/IDs: 123456789012 (fake AWS account ID), etc.
- Passwords/keys: use clearly fake values, truncated after the first few characters (e.g. `AKIA...` for AWS keys).

This applies even when the user mentions their own details in conversation
for context — do not echo them into files.

## Commit Messages & PR Descriptions

Drop the glossary. Write in plain, direct English. Use short sentences and
active voice. Avoid AI buzzwords, abstract metaphors, and invented terminology.
Explain any technical term you must use.

### Commits: Conventional Commits 1.0.0

Follow https://www.conventionalcommits.org/en/v1.0.0/ :

- Subject: `<type>(<scope>): <description>` — imperative, lower-case, no
  trailing period, at most 72 characters.
- Types: `feat` (new capability) and `fix` (bug fix) as the spec defines them;
  otherwise `docs`, `test`, `refactor`, `perf`, `build`, `ci`, `chore`. Pick by
  the change's intent, not by which files it touches.
- Scope is optional: the area touched (e.g. `rbac`, `schema`). Omit it when the
  change is repo-wide.
- Breaking change: mark the subject with `!` after the type/scope AND add a
  `BREAKING CHANGE:` footer saying what breaks and what callers must do.
- Body: explain why the change exists and what the diff cannot show. Wrap at 72.
- Footers are git trailers (`Refs: #123`, `Co-Authored-By: ...`).

### PR descriptions

- Open with what the PR does and why, readable without the diff.
- Call out behavior changes, breaking changes, and anything a reviewer must not
  miss. If the PR is part of a stack, say where it sits.
- Say what is deliberately out of scope when the scope could be misread.
- Verification: what was actually run and its result (test counts, commands).
  Never claim "should work" — if it was not run, say so.
- Link the issues the PR closes or touches.
