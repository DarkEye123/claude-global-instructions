# Dependabot Bump Review And Merge

Use this skill for open Dependabot PRs that only bump package versions, lockfiles, or GitHub Actions versions.

## Ground Rules

- Verify current state with `gh` and `git`; do not rely on prior outputs.
- Use `origin/develop` as the expected base in `checkout-frontend` unless the user explicitly says otherwise.
- Do not approve or merge a PR just because it is Dependabot-authored.
- Treat `REVIEW_REQUIRED`/approval-only blocking separately from technical blockers.
- Merge sequentially. Re-query GitHub after each merge because the base branch changes and Dependabot PR mergeability can become `UNKNOWN`, `BEHIND`, `DIRTY`, or redundant.
- Use admin bypass only when the user explicitly permits it and GitHub reports `mergeable: MERGEABLE` or equivalent no-conflict state.
- Never merge if GitHub reports `CONFLICTING`, `DIRTY`, failing required compatibility checks, or an unresolved migration blocker.

## Initial Triage

Run:

```bash
git status --short --branch
gh pr list --state open --author app/dependabot --limit 50 --json number,title,headRefName,baseRefName,author,url,reviewDecision,mergeStateStatus,mergeable
```

Report the open Dependabot PRs grouped by practical state:

- Safe-looking but needs review.
- Blocked only by review approval.
- Behind/unknown and may need branch update.
- Already failing, conflicting, or likely migration-scope.

If the user asks to inspect only blocked/unknown PRs, re-run the query immediately and list the current values exactly.

## Review Each PR

For each PR, inspect the actual diff and package/action impact:

```bash
gh pr view <pr> --json number,title,baseRefName,headRefName,mergeStateStatus,mergeable,reviewDecision,statusCheckRollup,url
gh pr diff <pr> --name-only
gh pr diff <pr>
gh pr checks <pr> --watch=false
```

For npm package bumps, also check as relevant:

```bash
npm view <package>@<old> version dependencies peerDependencies engines license repository dist-tags --json
npm view <package>@<new> version dependencies peerDependencies engines license repository dist-tags --json
npm explain <package>
rg '<package>|<import-name>' package.json package-lock.json src manage-my-booking cypress tools .github -n
```

For GitHub Actions bumps, inspect changed workflow files and the action release notes or repository changelog.

Review release notes or changelogs for:

- Required migration steps.
- Peer dependency changes.
- Engine/runtime changes.
- Semver-major changes.
- Deprecated APIs used by the repo.
- Security or bugfix-only changes.

## Decision Criteria

Approve when all are true:

- Diff is limited to expected package/action/lockfile/workflow version changes.
- No repo usage conflicts with documented breaking/deprecated behavior.
- Peer dependencies and engines are compatible with the repo.
- Existing CI on the PR passed, or the user explicitly permits bypassing pending checks after branch update and GitHub reports no conflict.
- No code/config migration is required.

Block when any are true:

- CI fails with a real package compatibility error.
- Peer dependency or engine requirements are incompatible.
- The bump is semver-major and release notes require migration not present in the PR.
- GitHub reports `CONFLICTING` or `DIRTY`.
- The PR requires paired upgrades, e.g. plugin requires a newer Vite major than the repo has.

When blocking, quote the exact error text from GitHub checks or commands.

## Parallel Review

If the user explicitly allows agents or asks to process multiple PRs, spawn one bounded review agent per PR when capacity permits.

Tell each agent:

- Review one PR only.
- Do not edit files, approve, merge, push, or comment.
- Return `APPROVE` or `BLOCK`, migration-risk assessment, exact commands/evidence, and exact blockers.

Do local review for any PR that cannot be assigned due to agent limits.

## Approval

After safe recommendations are available, approve safe PRs with concise review bodies:

```bash
gh pr review <pr> --approve --body "Reviewed dependency bump: <short reason>; no migration blocker found."
```

Do not approve blocked PRs. Leave them `REVIEW_REQUIRED` and summarize why.

## Updating Branches

If approved PRs are `BEHIND`, update them before merge:

```bash
gh pr update-branch <pr>
```

Then re-query:

```bash
gh pr view <pr> --json number,title,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup,url
```

If GitHub returns `UNKNOWN`, wait briefly and query again. Do not merge from `UNKNOWN`.

## Merge Sequence

Merge safe PRs one at a time. Prefer no bypass when clean:

```bash
gh pr merge <pr> --squash --delete-branch
```

If the user permits bypass and GitHub reports no conflict:

```bash
gh pr merge <pr> --squash --admin --delete-branch
```

After each merge:

```bash
gh pr view <pr> --json state,mergedAt,mergeCommit,title,url
gh pr list --state open --author app/dependabot --limit 50 --json number,title,mergeable,mergeStateStatus,reviewDecision,url
```

Re-evaluate remaining PRs because they may become `UNKNOWN`, `BEHIND`, `DIRTY`, conflict, or redundant after the base branch changes.

## Final Report

Summarize:

- PRs approved and merged, including merge commit SHA.
- PRs approved but not merged, with exact blocker.
- PRs blocked and not approved, with exact technical reason.
- Any admin bypass use.
- Current remaining open Dependabot PRs.
- Local working tree state, including unrelated untracked files if present.
