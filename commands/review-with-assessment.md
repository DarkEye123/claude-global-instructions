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
  - Load full git diff between branches
  - Extract Linear/Jira issue ID from branch name
  - Analyze all changed files
  - Perform comprehensive code review

Key Decision:
  - Main agent does NOT pre-analyze changes
  - All heavy lifting delegated to spawned task
  - This prevents duplicate work and improves efficiency
```

### Step 2: Detailed Analysis (Code Review Task)
The spawned code review agent will:
1. **Gather full context**:
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

**Note**: If a project-specific CLAUDE.md exists, I will also check for and apply any custom review criteria defined there.

### Step 4: Decision-Helper Assessment
After receiving the code review results, the main agent will spawn a decision-helper to:
- Evaluate each review finding objectively
- Score findings by actual impact (0-10)
- Distinguish between critical issues and preferences
- Provide implementation priorities
- Consider effort vs benefit trade-offs
- Identify which findings block merge vs nice-to-have

## Output Format

The review results will be:
1. **Displayed in the console/chat** for immediate viewing
2. **Saved to `requested-code-review.md`** in the current directory for future reference

### Content Structure:
1. **Context Summary**
   - Branch: current → default
   - Files changed: X
   - Lines: +X -Y
   - Linear/Jira issue: (if found)

2. **Code Review Findings**
   - Critical issues
   - Important improvements
   - Suggestions

3. **Decision-Helper Assessment**
   - Priority matrix of findings
   - Recommended action items
   - Merge readiness verdict

**Note**: The `requested-code-review.md` file will be overwritten each time this command is run, so save it elsewhere if you need to keep multiple reviews.