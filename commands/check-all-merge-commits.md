# Check All Merge Commits

Run a complete merge-regression audit without requiring the user to enumerate commits manually.

## When To Use

Use this skill when the user asks for:

- full merge regression review for current branch
- review of merge-conflict resolution quality
- detection of branch-only regressions or missed upstream inclusions after merges
- a final report file (`merge-report.md`) covering every changed file

## Non-Negotiable Rules

- Review **every file** changed by the target merge commits.
- Do **not** skip files unless the user explicitly instructs skipping or defines skip categories.
- Allowed default skips only when explicitly requested by user (example: Cypress files, test files, GitHub Actions files).
- Use the per-file 3-way comparison workflow from `check-regression` for each changed file.
- Distinguish branch-introduced issues from upstream-only behavior.
- Generate `merge-report.md` as the final artifact.
- **Never** claim exhaustive review if any non-skipped file was not individually checked.

## Anti-Shortcut Requirement

- Do not "sample" only core/high-risk areas unless the user explicitly asks for sampled review.
- Do not infer unreviewed files as safe based on directory or file type.
- For exhaustive review requests, each non-skipped file must have an explicit per-file outcome in the report.

## Inputs Discovery (Auto)

If the user did not provide explicit commits:

1. Identify merge commits to review on current branch:
   - Prefer merge commits after branch divergence from upstream.
   - Command pattern:
     - `git merge-base HEAD <upstream>`
     - `git log --merges --reverse --format=%H <merge-base>..HEAD`
2. If user provides specific merge commit(s), use those as authoritative.
3. Determine base commit for each merge commit:
   - Default: first parent of merge commit (`<merge>^1`) when no better baseline is specified.
   - If user provides a pre-merge baseline, use that.

## Upstream Target Selection

Resolve upstream in this priority:

1. Explicit user instruction (e.g., `origin/staging`, `origin/main`).
2. Project instructions (if they explicitly define primary branch).
3. `origin/HEAD` symbolic target.
4. Fallback order: `origin/develop`, then `origin/main`, then `origin/master`.

If `staging` is explicitly requested in instructions/user request, use it; otherwise use the primary upstream branch.

## Per-File Review Workflow

For each merge commit and each non-skipped file it changed:

1. Collect file diff in merge path:
   - `git diff <base> <merge> -- <file>`
2. Compare current branch state against upstream:
   - `git diff <upstream> -- <file>`
3. Inspect file content at relevant revisions when needed:
   - `git show <base>:<file>`
   - `git show <merge>:<file>`
   - `git show <upstream>:<file>`
   - `cat <file>` (current)
4. Classify changes:
   - already upstream
   - branch-only
   - likely missing upstream inclusion
   - ambiguous due to unrelated dirty worktree
5. Record findings only when they meet regression standard:
   - appears in reviewed merge path or reflects missing upstream inclusion that should have been carried
   - not explained by upstream alone or unrelated local edits

## Report Format (`merge-report.md`)

Structure:

1. Header
   - branch name
   - upstream target
   - merge commits reviewed
   - explicit skip rules used
   - review date/time
2. Executive summary
   - number of commits reviewed
   - total files changed
   - files skipped (by rule)
   - total files reviewed
   - total findings (by severity)
3. Findings (ordered by severity)
   - include merge commit hash
   - include classification: regression or missing upstream inclusion
   - include why branch-attributable
   - include clickable file references
4. Per-file coverage table (mandatory)
   - one row per reviewed file
   - status: `No findings` or `Has findings`
   - include clickable file path reference
5. Skipped files table (mandatory when skips are used)
   - one row per skipped file
   - include skip reason/rule

Clickable reference format for markdown previews:

- file-level: `[src/path/file.ts](src/path/file.ts)`
- line-level: `[src/path/file.ts:42](src/path/file.ts#L42)`

## Completion Criteria

Task is complete only when:

- all targeted merge commits are reviewed
- all non-skipped files changed by those commits are covered
- no non-skipped file is silently skipped
- `merge-report.md` exists and contains findings, per-file coverage, and skipped-files table (if applicable)
