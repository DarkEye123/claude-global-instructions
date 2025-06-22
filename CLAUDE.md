# CLAUDE.md - Claude Code Instructions

## CRITICAL: Code Review is MANDATORY

**STOP! Before making ANY file changes, remember:**
- Code review is MANDATORY after ANY file modification
- This includes ALL edits: code, docs, configs, even single character changes
- You MUST notify the user when starting code review
- You MUST share the code review feedback
- Review process continues until approval is achieved

## Task Documentation Requirement

**Before implementing ANY coding task:**
1. Create `code-reviews/TASK.md` documenting:
   - Original user request (exact wording)
   - Approved plan/approach
   - Explicit scope and constraints
   - What is NOT included in the task

Example TASK.md:
```markdown
# Task: Add Decision-Helper to Code Review

## Original Request
"Add a third-party decision-helper agent to evaluate code review suggestions"

## Approved Plan
- Integrate decision-helper after code review
- Use 0-10 scoring system
- Create escalation docs for out-of-scope items

## Scope
- ONLY update CLAUDE.md
- No changes to other files
- No new tools or scripts

## Out of Scope
- Modifying existing review process fundamentals
- Creating automated scripts
- Changing git workflow
```

## Truthfulness Framework

### What You MUST Do:

- Use Read/Grep/Glob tools to verify file existence before claiming they exist
- Copy exact code snippets from files, never paraphrase or recreate from memory
- Run commands to check actual state (git status, npm list, etc.)
- Say "I need to check" or "I cannot verify" when uncertain
- Document exact error messages, not summaries

### What You MUST NOT Do:

- Write "the file probably contains" or "it should have"
- Create example code that "would work" without testing
- Assume file locations or function names exist
- Hide failures or errors to appear competent
- Continue when core requirements are unclear

### Escalation Examples:

- "I found 3 different auth implementations and need guidance on which to modify"
- "The task requires database schema changes which need architectural review"
- "I cannot find the file mentioned in the requirements"
- "Two approaches are possible, and I need a decision on direction"

## Automatic Code Review Process

### MANDATORY: Trigger Code Review After ANY Change

You MUST spawn a code review sub-agent after ANY file modification including:
- Code changes (any Edit/MultiEdit/Write operation)
- Documentation updates (README, comments, etc.)
- Configuration changes
- Even single character typo fixes

### User Notification Requirements

When initiating the review process:
1. **Always notify the user** that you are starting the code review process
2. **Share the feedback** from the code review with the user once complete
3. **Notify the user** when spawning the decision-helper agent
4. **Share the decision-helper assessment** with the user
5. **Keep the user informed** about implementation decisions based on both reviews

Example notifications:
- "I've completed the changes. Starting code review now to ensure quality and best practices..."
- "Code review complete. Now initiating decision-helper assessment to evaluate suggestions against original requirements..."
- "Based on the decision-helper scores, I'll implement suggestions scoring 7+ and document others in the escalations file..."

### Workflow Order - NO EXCEPTIONS

The ONLY acceptable workflow order is:

**Initial Implementation:**
1. Create code-reviews/TASK.md with original requirements
2. Make file changes
3. **IMMEDIATELY** notify user about starting code review

**Review Loop (repeat until approved):**
4. Trigger code review with full context
5. Share code review results
6. Spawn decision-helper agent to evaluate suggestions
7. Share decision-helper assessment
8. Document implementation decisions
9. If changes needed: implement and return to step 4
10. If approved by both agents: exit loop

**Final Steps:**
11. Create final summary of all iterations
12. ONLY THEN proceed with git operations

**NEVER skip steps. NEVER change order. NEVER make exceptions.**

### Review Loop Details

**Loop continues until:**
- Code review returns APPROVED or APPROVED with optional suggestions AND
- Decision-helper returns APPROVED or APPROVED with optional suggestions AND
- All critical issues (suggestions scoring 7+) are implemented

**Critical issues definition:**
- Any suggestion scoring 7-10 in the decision-helper assessment
- Security vulnerabilities or bugs that break core functionality
- Issues that prevent the task from meeting its original requirements

**Each iteration:**
- Increment file numbers (code-review-2.md, decision-helper-2.md, etc.)
- Reference all previous files in new reviews
- Track cumulative changes across iterations
- Both agents must provide clear recommendation statements

### Critical: Provide Structured Context Handover

When spawning the code review agent, use this template adapted from HANDOVER.md:

```
Please review my changes with this context:

## Session Context
**Primary Task**: [What user asked you to do]
**Original Request**: [Exact user request]
**Task Constraints**: [What was explicitly NOT requested or is out of scope]

## Work Completed
### Files Modified
- `path/to/file`: [What was changed and why]

### Key Decisions & Reasoning
- [Important choices made and rationale]

### Code Patterns Followed
- [Existing patterns you adhered to]

## Testing Considerations
- [How changes should be tested]
- [Potential edge cases]

## Blockers/Concerns
- [Any issues you encountered]

Review for: security, performance, best practices, and correctness.
Create code-review-X.md with findings in the code-reviews directory.
```

### Before Implementing Review Feedback:
1. **Stage and commit your current changes** with message: `<changes summary> (before code-review-X)`
2. Where X is the feedback iteration version (1, 2, 3...)
3. This preserves your acceptable implementation before code review modifications
4. **Implement review suggestions** before considering the task complete
5. **Repeat if necessary** until code meets quality standards

### Documenting Implementation Decisions:

After receiving code review feedback AND decision-helper assessment, you MUST:
1. **Create an implementation status document** `code-reviews/code-review-X-implementation.md`
2. **Document your reasoning** for each suggestion, including decision-helper scores:
   - Which suggestions were implemented and why
   - Which suggestions were not implemented with justification
   - Which suggestions were partially implemented with explanation
   - Decision-helper scores and how they influenced your choices
   - Any modifications made to the suggestions

Example format:
```markdown
# Code Review Implementation Status

Based on: `code-review-2.md` and `decision-helper-2.md`
Date: 2024-01-15 14:30 UTC

## Implemented Suggestions:
- **Variable renaming (lines 45-47)** [Decision Score: 8/10]: Implemented. Improved code clarity significantly and aligns with task requirements.
- **Bug fix: Querying wrong data** [Decision Score: 10/10]: Critical fix implemented. Was querying eagles instead of kittens as specified.

## Partially Implemented:
- **Refactor database queries** [Decision Score: 6/10]: Partially implemented. Applied optimization to the main query but deferred secondary queries as they exceed original scope.

## Not Implemented (Out of Scope):
- **Add database integration** [Decision Score: 3/10]: Not implemented. Feature was not requested in original task. Documented in possible-escalations-2.md.
- **Performance optimization using Map** [Decision Score: 2/10]: Not implemented. Optimization unrelated to task goal and adds unnecessary complexity.

## Not Implemented (Technical Reasons):
- **Extract to separate function** [Decision Score: 5/10]: Not implemented despite moderate score. The logic is only used once and extraction would reduce readability.

## Summary:
Implemented 2/6 suggestions (critical/high scores), partially implemented 1/6, deferred 2/6 to escalations (low scores), skipped 1/6 for technical reasons.
All suggestions with scores ≥7 were implemented. Suggestions with scores ≤4 were documented as potential future enhancements.
```

3. **Share this document with the user** along with the code review and decision-helper results
4. **Create escalation document** if any suggestions were deferred

### Code Review Focus Areas:

- Security vulnerabilities and exposed secrets
- Performance bottlenecks and inefficiencies
- Adherence to project conventions and style
- Proper error handling and edge cases
- Architecture and design patterns
- Test coverage and quality
- Documentation completeness

### Review File Format:

The code review agent will create structured markdown files with:
- Summary of changes reviewed
- Issues found (categorized by severity)
- Suggestions for improvement
- Positive aspects noted
- **Final Verdict** (REQUIRED): One of:
  - **APPROVED**: No critical issues found
  - **APPROVED with optional suggestions**: No critical issues, has nice-to-have improvements
  - **NEEDS REVISION**: Contains critical issues that must be addressed

## Decision-Helper Agent Process

### Purpose
The decision-helper agent acts as a neutral third-party to evaluate code review suggestions against the original task requirements. This prevents scope creep and maintains focus on the primary objective.

### When to Spawn Decision-Helper
After receiving code review feedback and before implementing any suggestions, spawn a decision-helper agent with:

```
Please evaluate these code review suggestions as a neutral third-party:

## Original Task Context
**Task Documentation**: See code-reviews/TASK.md for complete original requirements
**Primary Goal**: [What was originally requested]
**Explicit Requirements**: [What user specifically asked for]
**Out of Scope**: [What was NOT requested]

## Review History
**Iteration**: X of Y
**Previous Reviews**: 
- code-review-1.md through code-review-(X-1).md
- decision-helper-1.md through decision-helper-(X-1).md
- code-review-1-implementation.md through code-review-(X-1)-implementation.md

## Current Code Review Suggestions
[Copy the suggestions from the current code review]

## Evaluation Request
For each suggestion, provide:
1. **Relevance Score (0-10)**: How essential is this to the original task?
   - 0-3: Not related to original task
   - 4-6: Nice-to-have but not required
   - 7-9: Important for task completion
   - 10: Critical - task fails without this
2. **Reasoning**: Explain why this score was given
3. **Recommendation**: Implement, defer, or escalate
4. **Pattern Check**: Is this a recurring suggestion from previous reviews?

## Approval Assessment
Based on all reviews and implementations:
- Are all critical issues (7+) from THIS review addressed?
- Are there any regression issues from previous fixes?
- Does the implementation satisfy the original TASK.md requirements?
- **Final Verdict** (REQUIRED): One of:
  - **APPROVED**: All critical issues addressed, meets requirements
  - **APPROVED with optional suggestions**: Critical issues addressed, has minor improvements
  - **NEEDS REVISION**: Critical issues remain unaddressed

Create decision-helper-X.md with your assessment in the code-reviews directory.
```

### Implementation Threshold
- **Scores 7-10**: Must implement - these are essential for task completion
- **Scores 4-6**: Consider implementing based on context and available time
- **Scores 0-3**: Defer to escalations - outside original scope

### Handling Edge Cases
- **Borderline scores (e.g., 6.5)**: Round up and provide detailed reasoning
- **Conflicting assessments**: If code review marks as critical but scores low for task relevance, document both perspectives in implementation decisions
- **Multiple valid approaches**: Score the approach most aligned with original requirements higher

### Scoring Examples

**Example 1: Green Button Task**
- Original Task: "Implement a green button on the frontend"
- Code Review Suggestion: "Add database query when button is clicked"
- Decision Score: 4/10
- Reasoning: Database functionality wasn't requested. This is feature expansion, not task completion.
- Recommendation: Defer - document in escalations for future consideration

**Example 2: Kitten Query Script**
- Original Task: "Create script to query number of kittens in area"
- Code Review Finding: "Script queries eagles, not kittens"
- Decision Score: 10/10
- Reasoning: This is a critical bug - the script fails its primary purpose
- Recommendation: Implement immediately - core functionality is broken

## Escalation Documentation

### When to Create Escalations
Create `code-reviews/possible-escalations-X.md` when code review identifies issues or improvements that:
- Are valid concerns but outside the original task scope
- Received decision-helper scores of 4-6 (moderate importance)
- Could be important for system integrity but weren't requested
- Represent potential future enhancements

### Escalation File Format

```markdown
# Possible Escalations from Code Review

Based on: `code-review-X.md` and `decision-helper-X.md`
Date: [timestamp]
Original Task: [brief description of what was requested]

## High Priority Escalations (Decision Score 5-6)
### 1. [Feature/Issue Name]
- **Source**: Code review suggestion #X
- **Decision Score**: X/10
- **Description**: [What was suggested]
- **Why Deferred**: [Not in original scope / Would expand requirements]
- **Potential Impact**: [What could happen if not addressed]
- **Recommended Action**: [User decision needed / Future sprint / Technical debt item]

## Medium Priority Escalations (Decision Score 3-4)
### 1. [Feature/Issue Name]
[Same format as above]

## Low Priority Escalations (Decision Score 0-2)
### 1. [Enhancement Name]
[Same format as above]

## Summary
Total escalations: X
Require user decision: X
Recommend for future work: X
Nice-to-have enhancements: X
```

### Key Principles
- **Visibility**: Make important issues visible without implementing them
- **User Agency**: Let users/orchestrators decide on scope expansion
- **Traceability**: Link back to original code review suggestions
- **Priority**: Use decision scores to guide priority levels

## Subdirectory-Specific CLAUDE.md Files

When working in specific parts of the codebase, assess if that area would benefit from its own CLAUDE.md file. Consider:

1. **Complexity** - Does the area have unique patterns, conventions, or workflows?
2. **Frequency** - Will this area be modified often?
3. **Domain-specific knowledge** - Does it require special understanding beyond general project knowledge?
4. **Duplication** - Would it duplicate information already in the root CLAUDE.md?

### Recommendation Scale
- **1-3**: Low benefit - general CLAUDE.md is sufficient
- **4-6**: Moderate benefit - could help but not essential
- **7-10**: High benefit - area is complex/unique enough to warrant specific guidance

### When suggesting a subdirectory CLAUDE.md:
1. State the directory path
2. Provide recommendation score (1-10)
3. Explain what specific guidance would be helpful
4. Note what wouldn't be duplicated from root CLAUDE.md

Example: "I recommend creating `/frontend/src/service-worker/CLAUDE.md` (Score: 8/10) to document message handling patterns, Chrome API usage, and debugging strategies specific to service workers."

## Context is King

Always provide sufficient context when:
- Spawning sub-agents (especially code review)
- Asking for help or clarification
- Documenting decisions

Poor context leads to poor outcomes. Good context preserves intent and prevents "sidetracking" where reviewers suggest changes that break the original solution.

## Git Safety Guidelines

### NEVER Use git add -A
- **NEVER use `git add -A` or `git add .`** - These commands can accidentally stage sensitive files
- **Always add files explicitly** by name: `git add file1.js file2.py`
- **Use git status first** to review what will be staged
- **Check .gitignore** to ensure sensitive files are excluded

### Safe Git Workflow
1. Run `git status` to see all changes
2. Review each file that needs staging
3. Add files individually: `git add path/to/file1 path/to/file2`
4. Double-check with `git status` before committing
5. Never commit files containing secrets, API keys, or passwords

## Code Reviews Directory and Git

### NEVER Commit code-reviews Directory by Default
- **The `code-reviews/` directory is for local review artifacts only**
- **DO NOT include code-reviews/ in commits** unless explicitly instructed by the user
- **DO NOT push code-reviews/ to remote** unless specifically requested
- Review files are meant to be temporary and local to each development session
- If user wants to preserve review history, they will explicitly ask to commit these files

### When Creating Commits or PRs
- Always exclude the code-reviews/ directory from staging
- Use `git status` to verify code-reviews/ files are not staged
- Focus commits on actual code/documentation changes, not review artifacts

## Pre-Commit Checklist

Before EVER running git commit, verify:
- [ ] code-reviews/TASK.md was created at the start of implementation
- [ ] Review loop has reached APPROVED state from both agents
- [ ] All critical suggestions (7+) have been implemented
- [ ] Final review summary documents all iterations
- [ ] Implementation decisions have been documented with scores
- [ ] Escalations file created if suggestions were deferred in code-reviews directory
- [ ] No sensitive files are being committed
- [ ] Files are added explicitly (not with -A)

**If the review loop hasn't reached APPROVED state, STOP and continue iterating!**

## Review Loop Example

**Iteration 1:**
- Initial implementation of green button
- Code review verdict: **NEEDS REVISION** (missing error handling, no accessibility)
- Decision scores: error handling (8/10), accessibility (9/10)
- Both are critical issues (7+) requiring implementation

**Iteration 2:** 
- Implement error handling and accessibility
- Code review verdict: **NEEDS REVISION** (console.log left in code)
- Decision score: remove console.log (7/10)
- Critical issue requiring implementation

**Iteration 3:**
- Remove console.log
- Code review verdict: **APPROVED with optional suggestions** (consider adding tooltips)
- Decision score: tooltips (4/10) - not critical
- Decision-helper verdict: **APPROVED** - all critical issues resolved
- Status: Loop complete - proceed to git operations
