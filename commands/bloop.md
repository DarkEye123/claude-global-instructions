# bloop - Complete Loop Review Process

Execute the mandatory self-review process for any file modifications made by the agent. This is a comprehensive, autonomous version of the review flow that can be followed without user intervention.

## Command Handover Context

**Date**: Command definition document
**Purpose**: Define complete autonomous review process
**Primary Goal**: Enable agent to execute full review cycle independently
**Critical Requirement**: Must capture ALL functionality from loop.md without state machine syntax

## Usage and Trigger Conditions

This command is automatically executed by the agent when ANY file is modified using Edit, Write, MultiEdit, or NotebookEdit tools. The process triggers for ALL file types without exception, including code files, documentation, configs, CLAUDE.md, README.md, and any other file type. The only exception is when the user explicitly says "skip review" or when the task is an external code review request.

External review detection happens when the user uses phrases like "review this pr", "do a review", "do a code-review", "review this code", or "can you review". In these cases, perform only the requested review without triggering the self-review cycle.

## Complete Review Process - Detailed Steps

### Step 1: Initial Setup and Directory Preparation

When starting a new conversation or task, check if the ./code-reviews/ directory exists. If it exists, delete all markdown files inside it using rm -f code-reviews/*.md. If it doesn't exist, create it using mkdir -p code-reviews. Output "Starting with clean code-reviews directory" to signal the beginning of the process.

This cleanup ensures no confusion from previous review iterations and provides clear tracking of the current task progress with fresh numbering for review iterations.

### Step 2: Handle Plan Mode if Active

If plan mode is active, you must present your implementation plan before creating TASK.md. Analyze the user's request, create a detailed plan, and present it using the exit_plan_mode tool. Wait for user approval or rejection. If approved, immediately proceed to create TASK.md. If rejected, return to waiting for new instructions. This ensures the task documentation reflects the approved plan.

### Step 3: Create Task Documentation

Create ./code-reviews/TASK.md with the following structure:

```
# Task: [brief description]

## Original Request
[exact user message word-for-word]

## Approved Plan
[implementation approach with bullet points]

## Scope
[what to implement]

## Out of Scope
[what not to implement]
```

This file becomes the single source of truth for all subsequent reviews. Every review will reference this document to ensure changes stay within scope.

### Step 4: Implementation Phase

Implement the requested changes according to TASK.md. The moment you use any file modification tool (Edit, Write, MultiEdit, or NotebookEdit), you trigger the review process. There are no exceptions to this rule. Even a single character change triggers the full review cycle.

### Step 5: Start the Review Cycle

Immediately after making changes, output "I've completed the changes. Starting code review now to ensure quality and best practices..." This message signals to the user that the review process has begun.

### Step 6: Initialize Review Documentation

If this is the first iteration (iteration == 1), create ./code-reviews/iteration-summary.md with initial content showing status as IN_PROGRESS and iteration count as 0. This file will track all review iterations.

### Step 7: Spawn Code Review Agent

Use the Task tool to spawn a code review agent with comprehensive context. The prompt must include:

- Primary task from TASK.md
- Original user request
- Task constraints (out of scope items)
- PR context if on a PR branch (check git branch and run gh pr view --comments if applicable)
- List of all files modified with descriptions
- Key implementation decisions and reasoning
- Code patterns followed
- Testing approach
- Any blockers or concerns

Request the reviewer to examine for security vulnerabilities, performance issues, best practices violations, and correctness problems. The reviewer must create code-review-{iteration}.md with findings.

### Step 8: Share Code Review Results

Display the complete code review results to the user, including all issues found, suggestions made, and positive observations noted. Do not summarize or filter - show everything.

### Step 9: Spawn Decision Helper Agent

Output "Code review complete. Now initiating decision-helper assessment to evaluate suggestions against original requirements..." Then use the Task tool to spawn a decision helper agent.

The decision helper prompt must include:
- Reference to code-reviews/TASK.md for original requirements
- Current iteration number
- List of previous review files if any
- Complete copy of all code review suggestions
- Request to score each suggestion 0-10 for relevance
- Request for reasoning behind each score
- Request for final verdict: APPROVED, APPROVED with optional suggestions, or NEEDS REVISION

The decision helper creates decision-helper-{iteration}.md with the assessment.

### Step 10: Share Decision Helper Results

Display the complete decision helper assessment to the user, showing all scores, reasoning, and recommendations. Again, do not summarize - show everything.

### Step 11: Update Iteration Summary

Edit ./code-reviews/iteration-summary.md to add:
- Latest iteration details
- Code review verdict and findings
- Decision helper scores and evaluations
- Implementation decisions (what will be implemented, deferred, or skipped)
- Consolidated list of all deferred proposals across iterations
- Previous iteration details

This provides a complete history of the review process.

### Step 12: Check Completion Using Verdict Matrix

Evaluate the verdicts according to this matrix:

- Code Review APPROVED + Decision Helper APPROVED = Exit the loop
- Code Review APPROVED + Decision Helper NEEDS_REVISION = Implement suggestions scoring 7+
- Code Review NEEDS_REVISION + Decision Helper APPROVED = Skip revisions (out of scope)
- Code Review NEEDS_REVISION + Decision Helper NEEDS_REVISION = Implement suggestions scoring 7+
- Code Review APPROVED_OPTIONAL + Decision Helper APPROVED = Exit the loop
- Code Review APPROVED_OPTIONAL + Decision Helper NEEDS_REVISION = Implement suggestions scoring 7+

### Step 13: Exit When Complete

If the action from the verdict matrix is to exit, output "Review process complete. All critical issues addressed." The process is now complete.

### Step 14: Implement Critical Suggestions and Loop

If the action requires implementing suggestions, output "Based on the decision-helper scores, I'll implement suggestions scoring 7+ and document others in the escalations file..."

Then:
1. Implement ALL suggestions with scores >= 7
2. Create ./code-reviews/code-review-{iteration}-implementation.md documenting what was implemented
3. Create ./code-reviews/possible-escalations-{iteration}.md for suggestions scoring 4-6
4. Increment the iteration counter
5. **CRITICAL: Loop back to Step 5 (Start the Review Cycle)**

The loop continues until both verdicts are APPROVED.

## Decision Scoring System - Complete Details

The decision helper uses a 0-10 scale with these exact thresholds:

**Scores 7-10: Critical - Must Implement**
These suggestions are essential for the task to be considered complete or correct. Examples include:
- Bug fixes where functionality is broken
- Security vulnerabilities that could compromise the system
- Critical functionality missing from requirements
- Accessibility violations that prevent usage
- Data corruption risks

**Scores 4-6: Medium Priority - Defer to Escalations**
These are valid improvements but not essential for the current task. Examples include:
- Performance optimizations not required by task
- Code structure improvements
- Additional error handling beyond requirements
- Nice-to-have features
- Documentation improvements

**Scores 0-3: Low Priority - Skip**
These suggestions are outside task scope or unnecessary. Examples include:
- Feature additions not requested
- Unrelated improvements to other code
- Style preferences with no functional impact
- Premature optimizations
- Technology changes not required

### Edge Case Handling

When a suggestion scores exactly on a boundary (like 6.5), round up and provide detailed reasoning. So 6.5 becomes 7 (implement) and 3.5 becomes 4 (escalate).

If code review marks something as critical but decision-helper scores it low, use the higher assessment and document the conflict with "Using more critical assessment".

When there are multiple valid implementation approaches, score the approach most aligned with original requirements higher and document alternatives in escalations if they score 4-6.

## File Templates and Requirements

### TASK.md Structure
Must include:
- Task title with brief description
- Original request copied exactly
- Approved plan with implementation steps
- Scope listing what will be implemented
- Out of scope listing what won't be implemented

### iteration-summary.md Structure
Must track:
- Last updated timestamp
- Current status (IN_PROGRESS or COMPLETE)
- Total iteration count
- Latest iteration details with verdicts and findings
- All suggestion evaluations with scores
- Implementation decisions
- Consolidated deferred proposals from all iterations
- Previous iteration history

### code-review-{n}.md Structure
Must contain:
- Date and reviewer identification
- Summary of overall assessment
- Files reviewed with change descriptions
- Findings categorized as critical issues, suggestions, and positive observations
- Security analysis
- Performance considerations
- Best practices evaluation
- Final verdict

### decision-helper-{n}.md Structure
Must include:
- Date and task reference
- Original task summary
- Analysis of each suggestion with score, reasoning, and recommendation
- Overall assessment with counts by priority
- Implementation requirements
- Final verdict

### code-review-{n}-implementation.md Structure
Documents:
- Which suggestions were implemented
- Which were skipped as out of scope
- Which were deferred as low priority
- Summary of implementation status

### possible-escalations-{n}.md Structure
Lists:
- High priority escalations (scores 5-6)
- Medium priority escalations (score 4)
- Total count and recommendations

## File System Requirements

The code-reviews directory must maintain this exact structure:
- TASK.md (always first, no variations)
- iteration-summary.md (updated each iteration)
- code-review-{n}.md where n = 1,2,3... (integer, no zero padding)
- decision-helper-{n}.md (n matches code-review)
- code-review-{n}-implementation.md (created after implementing)
- possible-escalations-{n}.md (only if scores 4-6 exist)

File naming must be exact with no variations. Use integers starting at 1, not 01.

## Precedence Rules

When conflicts arise, follow this hierarchy:
1. User explicit instruction (like "skip review")
2. TASK.md scope definition
3. Decision helper verdict
4. Code review verdict
5. CLAUDE.md rules
6. Default behavior

Special overrides:
- If user says "skip review", skip entire process
- If user says "implement everything", ignore scoring system
- If TASK.md excludes a feature, never implement it regardless of scores

## Error Recovery Procedures

### Missing TASK.md
If TASK.md doesn't exist when needed:
1. Output "Creating TASK.md from conversation context"
2. Reconstruct task details from conversation history
3. Create TASK.md with available information
4. Restart the review process

### Review Spawn Failed
If Task tool fails when spawning review:
1. Output "Code review failed to spawn. Retrying..."
2. Attempt spawn once more
3. If still fails, alert user and ask for guidance

### Conflicting Scores
When code review severity conflicts with decision helper score:
1. Output "Using more critical assessment"
2. Treat suggestion as critical (score 7+)
3. Implement to ensure safety

## Pre-Commit Validation

Before committing any changes, validate:
- TASK.md exists
- Latest code review verdict is APPROVED or APPROVED_OPTIONAL
- Latest decision helper verdict is APPROVED
- All suggestions scoring 7+ are implemented
- Implementation documentation exists
- No sensitive files are staged
- Files were added explicitly, not with -A
- code-reviews/ directory is not being committed (unless requested)

If any validation fails, block commit and continue review loop.

## Complete Review Example Walkthrough

Initial request: "Add error handling to login function"

**Iteration 1:**
1. Create TASK.md documenting the request
2. Implement try-catch blocks in login function
3. Start review cycle
4. Code review finds: missing specific error types, no logging, no rate limiting
5. Decision helper scores: error types 8/10, logging 5/10, rate limiting 2/10
6. Implement specific error types, defer logging, skip rate limiting
7. Loop back to review

**Iteration 2:**
1. Review the error type implementation
2. Code review finds: error messages could be more user-friendly
3. Decision helper scores: user-friendly messages 4/10
4. Both verdicts APPROVED
5. Create escalations file for message improvement
6. Exit loop

Files created:
- TASK.md
- iteration-summary.md
- code-review-1.md
- decision-helper-1.md
- code-review-1-implementation.md
- possible-escalations-1.md
- code-review-2.md
- decision-helper-2.md
- possible-escalations-2.md

## Critical Reminders for Autonomous Execution

1. This process is MANDATORY for ALL file modifications
2. The loop MUST continue until both verdicts are APPROVED
3. Never skip steps or take shortcuts
4. Always use exact file naming conventions
5. Update iteration-summary.md after EVERY cycle
6. Only implement suggestions scoring 7 or higher
7. Create escalation files for scores 4-6
8. Skip suggestions scoring 0-3
9. The decision helper has final authority on scope
10. After implementing suggestions, ALWAYS loop back to review again

## Handover State for Next Instance

**Current State**: Command definition complete
**Implementation Ready**: Yes
**Key Success Factor**: Following the loop back after implementing suggestions
**Common Failure Point**: Stopping after first iteration of fixes
**Critical Path**: Step 14 MUST loop back to Step 5

Remember: This is a LOOP, not a linear process. The review continues until quality standards are met through iterative improvement.