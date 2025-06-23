# Context-Aware Code Review with Assessment

Perform a comprehensive code review based on the current context, then assess the findings with a decision-helper.

## Context Detection
First, I'll determine what to review by checking:
- Current git branch and its changes
- Default/main branch (auto-detected)
- Any Linear issue reference in branch name
- Uncommitted changes (if any)
- Recent commits on this branch
- Any specific areas mentioned: $ARGUMENTS

## Review Process

### Step 1: Gather Context
1. **Detect default branch**:
   - Check git remote HEAD: `git symbolic-ref refs/remotes/origin/HEAD`
   - Fallback detection: check for origin/main, origin/master, origin/develop
   - Use detected branch as comparison base

2. **Analyze current branch**:
   - Current branch name: `git branch --show-current`
   - Extract Linear/Jira ID if present (e.g., feat/LIN-123-feature)
   - Compare with default: `git diff origin/{default}...HEAD`
   - List changed files: `git diff --name-only origin/{default}...HEAD`
   - Check uncommitted changes: `git status --porcelain`

3. **Determine review scope**:
   - All changes between current branch and default branch
   - Include both committed and uncommitted changes
   - Focus on areas mentioned in $ARGUMENTS if provided

### Step 2: Comprehensive Code Review
Review all detected changes for:
- Security vulnerabilities
- Performance implications
- Best practices adherence
- Code quality and maintainability
- Potential bugs or edge cases
- Architecture and design patterns
- Testing coverage
- Breaking changes or API compatibility

**Note**: If a project-specific CLAUDE.md exists, I will also check for and apply any custom review criteria defined there.

### Step 3: Decision-Helper Assessment
Spawn a decision-helper to:
- Evaluate each review finding objectively
- Score findings by actual impact (0-10)
- Distinguish between critical issues and preferences
- Provide implementation priorities
- Consider effort vs benefit trade-offs
- Identify which findings block merge vs nice-to-have

## Output Format
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