# Check Regression

Review one file at a time and report merge-induced problems. This includes both direct regressions and missing upstream inclusions where the branch failed to carry forward logic, wiring, guards, helpers, component props, or contract changes that exist in upstream.

## When To Use

Use this skill when the user:

- asks for a file-by-file regression review after a merge or amended merge
- asks whether a merge resolution missed upstream logic, helpers, props, imports, guards, or contract updates
- provides a base commit and one or more merge commits to compare
- wants a 3-way review that distinguishes:
  - what changed across the merge range
  - what is already in `origin/develop`
  - what is currently present in the working tree for that file

Do not use this skill for general code review, feature review, or branch-wide audits without a merge baseline.

## Required Inputs

Before reviewing, identify these values from the user request or repository state:

- base commit
- reviewed merge commit
- file path
- upstream branch to compare against
  - default to `origin/develop` in this repository unless the user says otherwise

If the user mentions that a merge commit was later amended, use the amended merge commit as the primary merge target.

## Workflow

### 1. Gather exact file state

Run commands to inspect:

- `git diff <base> <merge> -- <file>`
- current file contents
- `git diff <upstream> -- <file>`
- upstream file contents

When useful, also inspect:

- `git blame <merge> -- <file>`
- direct call sites or helper definitions needed to verify behavior

Do not infer file contents from memory.

### 2. Classify each observed change

For each meaningful behavior change in the merge range, decide whether it is:

- already present in `origin/develop`
- only present on the reviewed branch
- present in `origin/develop` but missing or only partially incorporated on the reviewed branch
- ambiguous because of ongoing local work or unrelated edits

Only branch-specific issues should become findings. A finding may be either:

- a branch-only regression
- a missing upstream inclusion that should likely have been carried into the branch

### 3. Check regression risk, not style

Prioritize:

- behavioral regressions
- merge drift where upstream introduced behavior that the branch did not fully adopt
- missing helper / util / import / prop / argument propagation after upstream contract changes
- broken wiring after signature changes
- mismatched contracts between caller and callee
- merge-resolution mistakes
- stale imports, removed guards, changed branching, wrong data flow

Ignore pure style churn unless it changes runtime behavior.

### 4. Handle ongoing work carefully

If the worktree is active and current edits make authorship ambiguous:

- say so explicitly
- do not attribute the issue to the merge unless the commit-range comparison supports it

## Output Rules

Lead with findings. If there are none, say exactly that.

Use this structure:

- `No findings in <file>.`

or

- numbered findings ordered by severity
- each finding should state:
  - severity
  - file reference
  - whether it is:
    - a regression introduced by the reviewed merge work, or
    - a likely missing upstream inclusion / merge-drift issue
  - why it belongs to the reviewed branch rather than upstream alone

After findings, optionally add a short note clarifying:

- something is already in `origin/develop`
- something was checked and found safe
- something is ambiguous because of ongoing edits

Keep the answer concise.

## Review Standard

A valid finding must satisfy both:

1. It appears in the reviewed merge path relative to the base commit, or it reflects a meaningful upstream change that should likely have been incorporated but is missing from the reviewed branch state.
2. It is not already explained by `origin/develop` alone or by unrelated ongoing work.

If either condition fails, do not report it as a regression.
