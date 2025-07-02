# Context-Aware Code Review with Assessment

Perform a comprehensive code review based on the current context, then assess the findings with a decision-helper.

## Context Detection (Main Agent)
I'll gather minimal context to pass to the review task:
- Current branch name: `git branch --show-current`
- Default branch: `git symbolic-ref refs/remotes/origin/HEAD`
- Any specific areas mentioned: $ARGUMENTS

## Review Process (Main Agent Orchestration)

**Flow Overview**: The main agent orchestrates the entire process by:
1. Gathering minimal context
2. Spawning code review task
3. Receiving code review results
4. Spawning decision-helper task with review results
5. Presenting final combined output

### Step 1: Spawn Code Review Task
The main agent will spawn a code review task with minimal context following a handoff pattern:

**Handoff Information** (following HANDOVER.md structure):
```yaml
Work Completed (by Main Agent):
  - Current branch name: obtained via `git branch --show-current`
  - Default branch: obtained via `git symbolic-ref refs/remotes/origin/HEAD`
  - Review focus: extracted from $ARGUMENTS

Current Task (for Code Review Agent):
  - Check if on PR branch and load PR comments via `gh pr view --comments`
  - Load full git diff between branches
  - Extract Linear/Jira issue ID from branch name
  - Analyze all changed files
  - Perform comprehensive code review
  - Create code-review.md with findings

Key Decision:
  - Main agent does NOT pre-analyze changes
  - All heavy lifting delegated to spawned task
  - This prevents duplicate work and improves efficiency
```

### Step 2: Detailed Analysis (Code Review Task)
The spawned code review agent will:
1. **Gather full context**:
   - Check current git branch for PR reference
   - If on a PR branch, run: `gh pr view --comments` to get PR comments
   - Extract Linear/Jira ID from branch name (e.g., feat/LIN-123-feature)
   - Load Linear issue for additional context if available
   - Compare with default: `git diff origin/{default}...HEAD`
   - List changed files: `git diff --name-only origin/{default}...HEAD`
   - Check uncommitted changes: `git status --porcelain`
   - Read and analyze all changed files

2. **Determine review scope**:
   - All changes between current branch and default branch
   - Include both committed and uncommitted changes
   - Focus on areas mentioned in arguments if provided

### Step 3: Comprehensive Code Review
The code review agent will examine all detected changes for:
- Security vulnerabilities
- Performance implications
- Best practices adherence
- Code quality and maintainability
- Potential bugs or edge cases
- Architecture and design patterns
- Testing coverage
- Breaking changes or API compatibility

**Output**: The code review agent will create a `code-review.md` file with all findings, categorized by severity and impact.

**Note**: If a project-specific CLAUDE.md exists, I will also check for and apply any custom review criteria defined there.

### Step 4: Decision-Helper Assessment
After receiving the code review results, the main agent will spawn a decision-helper to:
- Read the `code-review.md` file
- Evaluate each review finding objectively
- Score findings by actual impact (0-10)
- Distinguish between critical issues and preferences
- Provide implementation priorities
- Consider effort vs benefit trade-offs
- Identify which findings block merge vs nice-to-have

**Output**: The decision-helper will create a `decision-helper.md` file with the assessment and scoring of each finding.

## Step 5: Final Summary Creation
After both spawned tasks complete, the main agent will:
1. Read both `code-review.md` and `decision-helper.md`
2. Create a comprehensive `code-review-summary.md` that combines insights from both reports
3. Display key findings in the console for immediate viewing

## Output Files

Three files will be created in the current directory:

### 1. `code-review.md`
Created by the code review agent, containing:
- Context summary (branch, files changed, PR comments if available)
- Detailed findings categorized by severity
- Security, performance, and best practice observations
- Specific code locations and recommendations

### 2. `decision-helper.md`
Created by the decision-helper agent, containing:
- Objective assessment of each code review finding
- Relevance scores (0-10) for each suggestion
- Priority categorization (critical/important/nice-to-have)
- Implementation recommendations
- Merge readiness verdict

### 3. `code-review-summary.md`
Created by the main agent, containing:
- Executive summary combining both perspectives
- Prioritized action items based on decision-helper scores
- Critical issues that must be addressed
- Optional improvements for consideration
- Overall merge recommendation with rationale

**Note**: All three files will be overwritten each time this command is run. Save them elsewhere if you need to keep multiple reviews.