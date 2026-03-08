# Review Context Handover (review-context.md)

Purpose: Produce a complete, truthful, and reproducible handover that equips a code‑review agent to review this change efficiently and safely.

Follow these instructions exactly. Do not speculate; verify everything you write.

## Truthfulness Requirements
- Verify file existence before referencing them; never assume.
- Copy exact error messages and command outputs; do not paraphrase.
- Run commands to check actual state (e.g., `git status`, `git rev-parse`, `rg`, test/lint tasks).
- Say "I need to check" or "I cannot verify" when uncertain.
- Re-run checks when asked; do not rely on memory.

## Formatting Rules
- Export to `review-context.md` in the repository root unless directed otherwise.
- When linking code locations, use `[path:line](path#Lline)` so links remain clickable in editors.
- Use concise bullets; avoid long paragraphs. Keep every section present; if not applicable, write `None`.

## Required Metadata
- Timestamp (UTC): `<YYYY-MM-DD HH:MM>`
- Executor: `<your name or agent id>`
- Repository: output of ``git config --get remote.origin.url`` (if available)
- Current branch: ``git rev-parse --abbrev-ref HEAD``
- Target/base branch: from PR metadata or project docs; if unknown, state how you inferred it.
- HEAD commit: ``git rev-parse --short=12 HEAD``
- Compare range used: `<base>...<head>` you actually reviewed

## Inputs You Must Gather
- PR/ticket references and acceptance criteria (Linear/PR body). Quote them verbatim where relevant.
- Any feature flags, migrations, env vars, secrets, or config toggles touched.
- Test strategy (unit/integration/e2e) and how to run them locally.

## How To Gather Context (run these, verify outputs)
1) Sync comparison base
   - `git fetch --all --prune`
   - Determine base branch (PR base or documented default).
2) Produce a clean diff of what changed
   - `git diff --name-status <base>...HEAD`
   - `git diff --stat <base>...HEAD`
   - For large diffs, group by directory: `git diff --name-only <base>...HEAD | awk -F/ '{print $1}' | sort | uniq -c | sort -nr`
3) Identify generated/ignored files and exclude them from scope (verify via `.gitignore`).
4) Run validation checks that inform risk
   - Lint: project‑specific command (e.g., `npm run lint`, `ruff`, `golangci-lint`).
   - Tests: run the relevant subset and capture exact summaries.
   - Build/typecheck as applicable.

## Document Structure (fill every section)

### 1) Executive Summary
- One paragraph describing the intent of the change and the primary outcomes.
- High‑level risk rating: `Low | Medium | High | Critical` with one‑line justification.

### 2) Scope
- In‑scope: bullets of features/areas modified.
- Out‑of‑scope: bullets to prevent review churn.

### 3) Change List (grouped)
- Group by component or directory. Example:
  - `api/`: new endpoint `POST /x`, tightened validation
  - `web/`: UI state fix for modal race
  - `infra/`: CI step for smoke tests

### 4) Key Decisions & Rationale
- Decision: `<what>` — Rationale: `<why>` — Alternatives considered: `<alts>`
- Repeat per notable decision.

### 5) Risks & Mitigations
- Risk: `<what could break>` — Mitigation: `<how it’s reduced>` — Detection: `<metrics/logs>` — Rollback: `<git or config toggle>`

### 6) Testing Performed
- Commands executed and their exact outputs (succinct). Quote failures verbatim.
- Test coverage focus areas and important gaps, if any.

### 7) Reproduction / Verification Steps
- Step‑by‑step commands for a reviewer to validate behavior locally. Include seed data or fixtures when needed.

### 8) Performance, Security, Accessibility
- Performance: input size limits, Big‑O changes, hotspots touched.
- Security: authz/authn changes, input validation, secrets handling.
- Accessibility: user‑visible changes and WCAG considerations.

### 9) Observability
- New/updated logs, metrics, traces. How to verify in staging/prod dashboards.

### 10) Migrations & Ops
- DB/schema migrations, backfills, data shape changes.
- Feature flags, env vars, config toggles including defaults and rollout plan.

### 11) CI/CD Status
- Link to latest pipeline run, status, and key artifacts. Note flaky tests if observed.

### 12) Impacted Files (clickable locations)
- Use `[path:line](path#Lline)` format. Include only human‑relevant hotspots (constructors, public APIs, complex conditionals, tricky loops, error handling).

### 13) Open Questions / Escalations
- Unresolved items requiring decision, each with a one‑line proposed path forward.

### 14) Appendix: Diff Signals
- `git diff --stat <base>...HEAD` pasted
- `git diff --name-status <base>...HEAD` pasted

## Acceptance Criteria (for this handover to be “done”)
- Every section above is present and either filled or marked `None`.
- All facts are verified via commands or artifacts; exact errors quoted.
- At least 5–10 clickable code location links to the most critical changes.
- Compare range `<base>...HEAD` is explicitly stated and actually used.

## Minimal Example (shortened)

Timestamp: 2025-09-25 23:59 UTC  
Executor: `agent@example`  
Repo: `git@github.com:org/repo.git`  
Branch: `feat/CHE-1224/custom-pricing`  
Base: `main` (from PR #123)  
HEAD: `a1b2c3d4e5f6`  
Compare: `main...a1b2c3d4e5f6`

1) Executive Summary
- Adds custom pricing rules; fixes rounding bug in invoice calc. Risk: Medium (monetization path).

2) Scope
- In: `pricing/`, `api/invoice.ts`
- Out: legacy `billing/v1/`

3) Change List
- `api/invoice.ts`: new `applyCustomRules()` [api/invoice.ts:88](api/invoice.ts#L88)
- `pricing/rules.ts`: strategy pattern extraction [pricing/rules.ts:12](pricing/rules.ts#L12)

6) Testing Performed
- `npm run test -w api` → 128 passed, 0 failed (12.3s)

7) Verification Steps
- `docker compose up db`; `npm run seed`; POST `/v2/invoice` with payload X → total=199.99

12) Impacted Files
- [api/invoice.ts:88](api/invoice.ts#L88) [pricing/rules.ts:12](pricing/rules.ts#L12)

13) Open Questions
- Should rounding switch to bankers’ rounding for EU locales?

Use this template to create `review-context.md` before running the full code review prompt.
