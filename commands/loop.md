# Auto-Review Loop State Machine

Execute the mandatory self-review state machine for any file modifications made by the agent.

## Command Usage

This command is automatically executed by the agent when:
- ANY file is modified (Edit, Write, MultiEdit, NotebookEdit)
- The user hasn't explicitly requested to skip review
- The task is NOT an external code review

When triggered, the full state machine described below will execute with the prompt:
`$ARGUMENTS` (contains the current task context)

## Command Invocation

When invoked directly by the user:
```
/loop <task_description>
```

The `$ARGUMENTS` variable captures everything after "/loop ". For example:
- User types: `/loop implement user authentication with JWT`
- `$ARGUMENTS` becomes: `"implement user authentication with JWT"`

This task description flows through the entire review process.

---

## The Mandatory Self-Review State Machine

The state machine ensures consistent, thorough review of all changes. Each state has specific actions and transitions. This is not optional - it MUST be followed for every change I make.

### State Machine Overview

I operate according to a strict state machine that ensures quality and completeness. Think of it as a workflow that I MUST follow whenever I modify files.

```yaml
STATES:
  - IDLE                    # Waiting for user input
  - PLAN_PRESENTATION       # Presenting plan in plan mode
  - CREATE_TASK_MD          # Documenting the task
  - IMPLEMENTATION          # Making changes
  - NOTIFY_REVIEW_START     # Announcing review
  - SPAWN_CODE_REVIEW       # Running code review
  - SHARE_REVIEW            # Sharing review results
  - SPAWN_DECISION_HELPER   # Evaluating suggestions
  - SHARE_DECISION          # Sharing decisions
  - UPDATE_ITERATION_SUMMARY # Updating summary
  - IMPLEMENT_SUGGESTIONS   # Implementing feedback
  - CHECK_COMPLETION        # Checking if done
  - EXIT_LOOP               # Completing process
```

### Detailed State Transitions and Actions

Let me explain what happens in each state, when I transition between them, and what you'll see.

#### IDLE State - Waiting for Instructions

This is where I start, waiting for your request.

```yaml
IDLE:
  ON: user_request_involving_files AND plan_mode_active AND NOT external_review_request 
      → GOTO: PLAN_PRESENTATION
  ON: user_request_involving_files AND NOT plan_mode_active AND NOT external_review_request 
      → GOTO: CREATE_TASK_MD
  ON: external_review_request 
      → STAY: IDLE (perform review without state machine)
```

**What this means:**
- If you ask me to do something with files while in plan mode → I present a plan first
- If you ask me to do something with files (not in plan mode) → I create TASK.md and start
- If you ask me to review external code → I stay in IDLE and just do the review

**Examples:**
- "Update the login function" + plan mode → Goes to PLAN_PRESENTATION
- "Fix the bug in main.py" (no plan mode) → Goes to CREATE_TASK_MD
- "Review PR #123" → Stays in IDLE, performs review only

#### PLAN_PRESENTATION State - Presenting the Plan

When in plan mode, I present my implementation plan before making changes.

```yaml
PLAN_PRESENTATION:
  ACTION: Present plan to user using exit_plan_mode tool
  ON: plan_approved → GOTO: CREATE_TASK_MD
  ON: plan_rejected → GOTO: IDLE
```

**What happens:**
1. I analyze your request
2. I create a detailed plan
3. I present it using the exit_plan_mode tool
4. You either approve or reject
5. If approved, I proceed to CREATE_TASK_MD
6. If rejected, I return to IDLE

**Example interaction:**
```
You: "Refactor the authentication system"
Me: [analyzes code, then presents plan via exit_plan_mode]
You: [approves plan]
Me: [proceeds to CREATE_TASK_MD]
```

#### CREATE_TASK_MD State - Documenting the Task

This critical state ensures I document exactly what I'm supposed to do, creating a reference point for all reviews.

```yaml
CREATE_TASK_MD:
  ACTION: Write(./code-reviews/TASK.md)
  TEMPLATE: |
    # Task: {brief_description}
    
    ## Original Request
    $ARGUMENTS
    
    ## Approved Plan
    {implementation_approach}
    
    ## Scope
    {what_to_implement}
    
    ## Out of Scope
    {what_not_to_implement}
  ON: success → GOTO: IMPLEMENTATION
```

**What I do here:**
1. Create `./code-reviews/TASK.md` with your exact request
2. Document the approved approach
3. Clearly define what's in and out of scope
4. This becomes the reference for all subsequent reviews

**Example TASK.md:**
```markdown
# Task: Add Error Handling to User Login

## Original Request
"Add proper error handling to the login function, including rate limiting"

## Approved Plan
- Add try-catch blocks to handle exceptions
- Implement rate limiting with 5 attempts per minute
- Return meaningful error messages to users
- Log errors for debugging

## Scope
- Error handling in login() function
- Rate limiting logic
- User-friendly error messages
- Error logging

## Out of Scope
- Changing authentication mechanism
- Modifying database schema
- Updating UI components
- Adding new authentication methods
```

#### IMPLEMENTATION State - Making Changes

This is where I actually modify files to complete your request.

```yaml
IMPLEMENTATION:
  ON: any_file_modification_by_agent → GOTO: NOTIFY_REVIEW_START
  EXCEPTION: external_review_context → STAY: IMPLEMENTATION (no self-review)
  INCLUDES: [ALL file types - code, docs, configs, CLAUDE.md, README.md, everything]
  CONTEXT_CHECK: If user asked for external code review, skip self-review cycle
```

**Key points:**
- As soon as I modify ANY file, I MUST go to NOTIFY_REVIEW_START
- This applies to ALL file types without exception
- The only exception is if I'm in an external review context

**What triggers the transition:**
- Using Edit tool → immediate transition
- Using Write tool → immediate transition
- Using MultiEdit tool → immediate transition
- Using NotebookEdit tool → immediate transition

#### NOTIFY_REVIEW_START State - Announcing Review

I inform you that I'm starting the review process. This ensures transparency.

```yaml
NOTIFY_REVIEW_START:
  ACTION: output("I've completed the changes. Starting code review now to ensure quality and best practices...")
  ON: complete → GOTO: SPAWN_CODE_REVIEW
```

**What you'll see:**
```
I've completed the changes. Starting code review now to ensure quality and best practices...
```

This message appears immediately after I finish making changes, before the review begins.

#### SPAWN_CODE_REVIEW State - Running Code Review

This is where I spawn a sub-agent to review my changes objectively.

```yaml
SPAWN_CODE_REVIEW:
  IF iteration == 1:
    ACTION: Write(./code-reviews/iteration-summary.md, initial_template)
  ACTION: Task(code_review_prompt)
  PROMPT_TEMPLATE: |
    Please review my changes with this context:
    
    ## Session Context
    **Primary Task**: {task_from_TASK_md}
    **Original Request**: $ARGUMENTS
    **Task Constraints**: {out_of_scope_from_TASK_md}
    
    ## PR Context (if available)
    1. Check current git branch for PR reference (e.g., feat/CHE-1234/description)
    2. If on a PR branch, run: gh pr view --comments
    3. Include relevant PR comments in your review context
    
    ## Work Completed
    ### Files Modified
    {list_of_files_with_changes}
    
    ### Key Decisions & Reasoning
    {implementation_decisions}
    
    ### Code Patterns Followed
    {patterns_used}
    
    ## Testing Considerations
    {test_approach}
    
    ## Blockers/Concerns
    {any_issues}
    
    Review for: security, performance, best practices, and correctness.
    Create code-review-{iteration}.md with findings in the code-reviews directory.
  ON: review_complete → GOTO: SHARE_REVIEW
```

**What happens:**
1. If this is the first iteration, I create iteration-summary.md
2. I spawn a code review task with full context
3. The reviewer checks for security, performance, best practices
4. Creates code-review-1.md (or appropriate number)
5. Returns findings

**Example spawned review context:**
```
Please review my changes with this context:

## Session Context
**Primary Task**: Add Error Handling to User Login
**Original Request**: "Add proper error handling to the login function, including rate limiting"
**Task Constraints**: Not changing auth mechanism, not modifying database

## PR Context (if available)
[Checks current branch and PR comments if applicable]

## Work Completed
### Files Modified
- `/src/auth/login.js`: Added error handling and rate limiting
- `/src/utils/rateLimiter.js`: New rate limiting utility
- `/tests/auth/login.test.js`: Added error handling tests

### Key Decisions & Reasoning
- Used Redis for rate limiting storage (already in stack)
- Chose 5 attempts per minute based on industry standards
- Implemented exponential backoff for repeated failures

...
```

#### SHARE_REVIEW State - Sharing Review Results

I share the code review findings with you.

```yaml
SHARE_REVIEW:
  ACTION: output(review_results)
  ON: complete → GOTO: SPAWN_DECISION_HELPER
```

**What you'll see:**
The complete code review results, including any issues found, suggestions, and positive observations.

#### SPAWN_DECISION_HELPER State - Evaluating Suggestions

This critical state prevents scope creep by evaluating suggestions against the original task.

```yaml
SPAWN_DECISION_HELPER:
  ACTION: output("Code review complete. Now initiating decision-helper assessment to evaluate suggestions against original requirements...")
  THEN: Task(decision_helper_prompt)
  PROMPT_TEMPLATE: |
    Please evaluate these code review suggestions as a neutral third-party:
    
    ## Original Task Context
    **Task Documentation**: See code-reviews/TASK.md for complete original requirements
    **Primary Goal**: {original_goal}
    **Explicit Requirements**: {requirements}
    **Out of Scope**: {out_of_scope}
    
    ## Review History
    **Iteration**: {current_iteration}
    **Previous Reviews**: {list_previous_files}
    
    ## Current Code Review Suggestions
    {copy_all_suggestions}
    
    ## Evaluation Request
    For each suggestion, provide:
    1. **Relevance Score (0-10)**: How essential is this to the original task?
    2. **Reasoning**: Explain why this score was given
    3. **Recommendation**: Implement, defer, or skip
    
    ## Approval Assessment
    Based on all reviews and implementations:
    - Are all critical issues (7+) from THIS review addressed?
    - Does the implementation satisfy the original TASK.md requirements?
    - **Final Verdict** (REQUIRED): APPROVED, APPROVED with optional suggestions, or NEEDS REVISION
    
    Create decision-helper-{iteration}.md with your assessment in the code-reviews directory.
  ON: decision_complete → GOTO: SHARE_DECISION
```

**What happens:**
1. I announce the decision-helper assessment is starting
2. Spawn a neutral evaluator to score each suggestion
3. Each suggestion gets a 0-10 relevance score
4. Decision helper determines if changes are needed
5. Creates decision-helper-1.md (or appropriate number)

**Example decision evaluation:**
```
Suggestion: "Add database connection pooling"
Relevance Score: 3/10
Reasoning: While good practice, this wasn't part of the original error handling request
Recommendation: Defer to possible-escalations-1.md
```

#### SHARE_DECISION State - Sharing Decision Results

I share the decision-helper's assessment with you.

```yaml
SHARE_DECISION:
  ACTION: output(decision_results)
  THEN: UPDATE_ITERATION_SUMMARY
  ON: complete → GOTO: CHECK_COMPLETION
```

**What you'll see:**
The complete decision-helper assessment, including scores and recommendations for each suggestion.

#### UPDATE_ITERATION_SUMMARY State - Updating Summary

This state maintains a running summary of all review iterations. This was missing in previous versions but is critical for tracking progress.

```yaml
UPDATE_ITERATION_SUMMARY:
  ACTION: Edit(./code-reviews/iteration-summary.md)
  UPDATE_WITH: latest_review_and_decision_results
  ON: complete → GOTO: CHECK_COMPLETION
```

**What happens:**
1. I edit the iteration-summary.md file
2. Add the latest review and decision results
3. Update counts and status
4. Maintain history of all iterations

This ensures you always have a high-level view of the review process.

#### CHECK_COMPLETION State - Determining Next Steps

This state uses the verdict matrix to determine whether to continue or exit.

```yaml
CHECK_COMPLETION:
  EVALUATE: verdict_matrix
  ON: action == "EXIT_LOOP" → GOTO: EXIT_LOOP
  ON: action == "IMPLEMENT_CRITICAL_ONLY" → GOTO: IMPLEMENT_SUGGESTIONS
  ON: action == "SKIP_REVISIONS" → GOTO: EXIT_LOOP
```

**The decision is based on this matrix:**

```text
VERDICT_MATRIX:
  | Code_Review        | Decision_Helper    | Action                                     |
  |-------------------|-------------------|-------------------------------------------|
  | APPROVED          | APPROVED          | EXIT_LOOP                                 |
  | APPROVED          | NEEDS_REVISION    | IMPLEMENT_CRITICAL_ONLY (scores >= 7)    |
  | NEEDS_REVISION    | APPROVED          | SKIP_REVISIONS (out of scope)            |
  | NEEDS_REVISION    | NEEDS_REVISION    | IMPLEMENT_CRITICAL_ONLY (scores >= 7)    |
  | APPROVED_OPTIONAL | APPROVED          | EXIT_LOOP                                 |
  | APPROVED_OPTIONAL | NEEDS_REVISION    | IMPLEMENT_CRITICAL_ONLY (scores >= 7)    |
```

**What this means:**
- Both say APPROVED → We're done!
- Code review wants changes but decision helper says they're out of scope → Skip them
- Decision helper says critical changes needed → Implement only those scoring 7+
- This prevents scope creep while ensuring quality

#### IMPLEMENT_SUGGESTIONS State - Implementing Feedback

When critical suggestions need implementation, this state handles them.

```yaml
IMPLEMENT_SUGGESTIONS:
  ACTION: output("Based on the decision-helper scores, I'll implement suggestions scoring 7+ and document others in the escalations file...")
  IMPLEMENT: all suggestions with score >= 7
  CREATE: ./code-reviews/code-review-{iteration}-implementation.md
  CREATE: ./code-reviews/possible-escalations-{iteration}.md (if any scores 4-6)
  INCREMENT: iteration
  ON: complete → GOTO: NOTIFY_REVIEW_START
```

**What happens:**
1. I announce I'm implementing high-priority suggestions
2. Implement ALL suggestions scoring 7 or higher
3. Create implementation documentation
4. Create escalations file for medium-priority items (4-6)
5. Increment iteration counter
6. Loop back to NOTIFY_REVIEW_START for another review

**Example of what you'll see:**
```
Based on the decision-helper scores, I'll implement suggestions scoring 7+ and document others in the escalations file...
[Makes changes]
[Creates documentation]
[Loops back for another review]
```

#### EXIT_LOOP State - Completing the Process

When all critical issues are resolved, we exit the review loop.

```yaml
EXIT_LOOP:
  ACTION: output("Review process complete. All critical issues addressed.")
  RETURN: control to main flow
```

**What you'll see:**
```
Review process complete. All critical issues addressed.
```

At this point, the implementation meets quality standards and original requirements.

### State Machine Trigger Conditions

Let me be absolutely clear about what triggers this state machine:

```yaml
TRIGGER_CONDITIONS:
  PRIMARY_RULE: ANY file modification by agent triggers self-review
  TOOLS_THAT_TRIGGER:
    - Edit → Action: SPAWN_CODE_REVIEW
    - MultiEdit → Action: SPAWN_CODE_REVIEW
    - Write → Action: SPAWN_CODE_REVIEW
    - NotebookEdit → Action: SPAWN_CODE_REVIEW
  APPLIES_TO: ALL files without exception (including CLAUDE.md, README.md, configs, etc.)

TRIGGER_EXCEPTIONS:
  ONLY_EXCEPTION: When in external code review context
  DETECTION: User explicitly requests review of code they provide
  DETECTED_BY: ["review this pr", "do a review", "do a code-review", "review this code", "can you review"]
  THEN: SKIP_SELF_REVIEW_CYCLE
  ACTION: PERFORM_REQUESTED_REVIEW_ONLY
```

**This is non-negotiable**: If I edit ANY file, the state machine MUST activate.

### Plan Mode Special Handling

When plan mode is active, there's a special flow to ensure the plan is approved before creating TASK.md:

```yaml
PLAN_MODE_HANDLING:
  WHEN: plan_mode_active
  THEN: 
    - DEFER: CREATE_TASK_MD until after plan approval
    - ON_PLAN_APPROVAL: 
      - IMMEDIATE: CREATE_TASK_MD
      - THEN: GOTO: IMPLEMENTATION
```

**What this means:**
1. In plan mode, I present the plan first
2. Only after you approve do I create TASK.md
3. Then I immediately proceed to implementation
4. This ensures the task documentation reflects the approved plan

---

## Decision Logic and Scoring System

The decision logic prevents scope creep while ensuring critical issues are addressed. Every suggestion gets scored, and only high-priority items are implemented.

### Understanding the Scoring System

The decision-helper uses a 0-10 scale to evaluate how relevant each code review suggestion is to the original task:

```yaml
SCORE_ACTIONS:
  score >= 7.0:
    ACTION: IMPLEMENT
    PRIORITY: IMMEDIATE
    OPTIONAL: FALSE
  
  score >= 4.0 AND score < 7.0:
    ACTION: DEFER_TO_ESCALATIONS
    FILE: ./code-reviews/possible-escalations-{iteration}.md
    PRIORITY: LOW
    OPTIONAL: TRUE
  
  score < 4.0:
    ACTION: SKIP
    DOCUMENTATION: NOT_REQUIRED
    OPTIONAL: TRUE

DECISION_HELPER_AUTHORITY:
  - PURPOSE: Prevent code review scope creep
  - PRECEDENCE: Overrides code review for scope decisions
  - SCORING: 0-10 scale for task relevance
```

### Score Ranges Explained with Examples

**Scores 7-10: Critical - Must Implement**
These suggestions are essential for the task to be considered complete or correct.

*Example 1: Bug Fix*
- Original Task: "Create script to query number of kittens in area"
- Code Review Finding: "Script queries eagles, not kittens"
- Decision Score: 10/10
- Reasoning: This is a critical bug - the script completely fails its primary purpose
- Action: MUST implement immediately

*Example 2: Security Issue*
- Original Task: "Add user profile update endpoint"
- Code Review Finding: "No input validation, SQL injection possible"
- Decision Score: 9/10
- Reasoning: Security vulnerability that could compromise the system
- Action: MUST implement immediately

**Scores 4-6: Medium Priority - Defer to Escalations**
These are valid improvements but not essential for the current task.

*Example 1: Performance Enhancement*
- Original Task: "Implement a green button on the frontend"
- Code Review Suggestion: "Consider using React.memo for performance"
- Decision Score: 5/10
- Reasoning: Good practice but button works without it
- Action: Document in possible-escalations-1.md for future consideration

*Example 2: Code Structure*
- Original Task: "Fix login error messages"
- Code Review Suggestion: "Refactor error handling into separate module"
- Decision Score: 6/10
- Reasoning: Would improve maintainability but current fix works
- Action: Document in escalations for potential future refactoring

**Scores 0-3: Low Priority - Skip**
These suggestions are outside the task scope or unnecessary.

*Example 1: Feature Expansion*
- Original Task: "Implement a green button on the frontend"
- Code Review Suggestion: "Add database integration for button clicks"
- Decision Score: 2/10
- Reasoning: Database functionality wasn't requested, pure scope creep
- Action: Skip without documentation

*Example 2: Unrelated Improvement*
- Original Task: "Update README with installation steps"
- Code Review Suggestion: "Add CI/CD pipeline configuration"
- Decision Score: 1/10
- Reasoning: Completely unrelated to documentation task
- Action: Skip

### The Verdict Matrix in Action

Here's how the verdicts from code review and decision-helper combine to determine action:

**Scenario 1: Both Approved**
- Code Review: "APPROVED - Code looks good"
- Decision Helper: "APPROVED - Meets all requirements"
- Action: EXIT_LOOP - We're done!

**Scenario 2: Code Review Wants Changes, Decision Helper Says No**
- Code Review: "NEEDS_REVISION - Add caching for performance"
- Decision Helper: "APPROVED - Caching not in original scope"
- Action: SKIP_REVISIONS - Changes are out of scope

**Scenario 3: Decision Helper Identifies Critical Issues**
- Code Review: "APPROVED - Code works"
- Decision Helper: "NEEDS_REVISION - Missing rate limiting (score: 8/10)"
- Action: IMPLEMENT_CRITICAL_ONLY - Implement the rate limiting

**Scenario 4: Both Identify Issues**
- Code Review: "NEEDS_REVISION - Multiple suggestions"
- Decision Helper: "NEEDS_REVISION - 2 critical (8/10), 3 minor (4/10)"
- Action: IMPLEMENT_CRITICAL_ONLY - Only implement the 2 critical items

### Edge Case Handling

**Borderline Scores**
When a suggestion scores exactly on a boundary (like 6.5), I round up and provide detailed reasoning:
- 6.5 → 7 (implement)
- 3.5 → 4 (escalate)

**Conflicting Assessments**
If code review marks something as critical but decision-helper scores it low:
- Use the higher assessment
- Document the conflict
- Output: "Using more critical assessment"

**Multiple Valid Approaches**
When there are multiple ways to implement something:
- Score the approach most aligned with original requirements higher
- Document alternative approaches in escalations if score 4-6

---

## File Templates and Examples

These templates ensure consistency and completeness in all review artifacts. Each template is shown with both the structure and a filled example.

### TASK.md Template

This is ALWAYS the first file created and serves as the source of truth for the task.

```yaml
FILE_TEMPLATES:
  TASK_MD: |
    # Task: {brief_description}
    
    ## Original Request
    {exact_user_message}
    
    ## Approved Plan
    {implementation_approach}
    
    ## Scope
    {what_to_implement}
    
    ## Out of Scope
    {what_not_to_implement}
```

**Filled Example:**
```markdown
# Task: Add Authentication Rate Limiting

## Original Request
"Add rate limiting to prevent brute force attacks on our login endpoint. Limit to 5 attempts per minute per IP"

## Approved Plan
- Implement IP-based rate limiting using Redis
- Add middleware to check rate limits before authentication
- Return 429 status when limit exceeded
- Include retry-after header
- Add configuration for limits

## Scope
- Rate limiting middleware for /api/login endpoint
- Redis integration for tracking attempts
- Error responses with proper status codes
- Configuration in env variables
- Unit tests for rate limiting logic

## Out of Scope
- Rate limiting for other endpoints
- User-based rate limiting (only IP-based)
- Captcha or other additional security measures
- Changes to authentication logic itself
- Database schema modifications
```

### iteration-summary.md Template

This provides a high-level view of the entire review process, updated after each iteration.

```yaml
ITERATION_SUMMARY: |
  # Review Process Summary
  
  Last Updated: {timestamp}
  Current Status: {IN_PROGRESS|COMPLETE}
  Total Iterations: {count}
  
  ## Latest Iteration ({iteration})
  
  ### Code Review Result
  - Verdict: {verdict}
  - Critical Issues Found: {count}
  
  #### Code Review Suggestions:
  {for each suggestion:
    1. **{suggestion_title}**
       - Severity: {severity}
       - Location: {file:line}
       - Issue: {detailed_description}
       - Recommendation: {proposed_fix}
  }
  
  ### Decision-Helper Assessment
  - Verdict: {verdict}
  
  #### Suggestion Evaluations:
  {for each suggestion:
    1. **{suggestion_title}**
       - Relevance Score: {score}/10
       - Reasoning: {full_reasoning}
       - Recommendation: {implement|defer|skip}
       - Category: {high|medium|low} priority
  }
  
  ### Implementation Decisions
  
  #### Implemented ({count}):
  {for each implemented:
    - **{suggestion_title}** [Score: {score}/10]
      - What was done: {implementation_details}
      - Why: {reasoning}
  }
  
  #### Deferred to Escalations ({count}):
  {for each deferred:
    - **{suggestion_title}** [Score: {score}/10]
      - Original suggestion: {full_text}
      - Why deferred: {reasoning}
      - Potential impact: {impact_analysis}
      - Future recommendation: {action_item}
  }
  
  #### Skipped ({count}):
  {for each skipped:
    - **{suggestion_title}** [Score: {score}/10]
      - Why skipped: {reasoning}
  }
  
  ### Next Steps
  {CONTINUING: Another iteration required - implementing scores ≥7 | COMPLETE: All critical issues resolved}
  
  ---
  
  ## All Deferred Proposals (Consolidated)
  
  {for each deferred proposal across all iterations:
    ### {suggestion_title} (Iteration {n}, Score: {score}/10)
    - **Source**: {code_review_reference}
    - **Original Issue**: {full_description}
    - **Suggested Fix**: {proposed_solution}
    - **Decision Rationale**: {why_deferred}
    - **Impact if Implemented**: {detailed_impact}
    - **Recommended Action**: {future_steps}
    - **Priority**: {high|medium|low}
  }
  
  ---
  
  ## Previous Iterations (Detailed)
  {append_previous_iteration_details_with_full_context}
```

**Filled Example (After 2 Iterations):**
```markdown
# Review Process Summary

Last Updated: 2024-01-15 10:45:00 UTC
Current Status: COMPLETE
Total Iterations: 2

## Latest Iteration (2)

### Code Review Result
- Verdict: APPROVED
- Critical Issues Found: 0

#### Code Review Suggestions:
1. **Consider adding request ID to logs**
   - Severity: Low
   - Location: middleware/rateLimiter.js:45
   - Issue: Logs don't include request ID for tracing
   - Recommendation: Add req.id to all log statements

### Decision-Helper Assessment
- Verdict: APPROVED

#### Suggestion Evaluations:
1. **Consider adding request ID to logs**
   - Relevance Score: 4/10
   - Reasoning: While helpful for debugging, logging improvements weren't part of the rate limiting requirement
   - Recommendation: defer
   - Category: medium priority

### Implementation Decisions

#### Implemented (0):
(None in this iteration)

#### Deferred to Escalations (1):
- **Consider adding request ID to logs** [Score: 4/10]
  - Original suggestion: Add request ID to all rate limiter logs
  - Why deferred: Not essential for rate limiting functionality
  - Potential impact: Would improve debugging capabilities
  - Future recommendation: Consider in logging improvement sprint

#### Skipped (0):
(None in this iteration)

### Next Steps
COMPLETE: All critical issues resolved

---

## All Deferred Proposals (Consolidated)

### Add Redis connection pooling (Iteration 1, Score: 5/10)
- **Source**: code-review-1.md
- **Original Issue**: Single Redis connection could be bottleneck
- **Suggested Fix**: Implement connection pooling with min/max connections
- **Decision Rationale**: Current implementation works for expected load
- **Impact if Implemented**: Better performance under high load
- **Recommended Action**: Monitor performance, implement if issues arise
- **Priority**: medium

### Consider adding request ID to logs (Iteration 2, Score: 4/10)
- **Source**: code-review-2.md
- **Original Issue**: Logs lack request correlation
- **Suggested Fix**: Add request ID to all log statements
- **Decision Rationale**: Logging improvements out of scope
- **Impact if Implemented**: Easier debugging and tracing
- **Recommended Action**: Include in logging standards update
- **Priority**: medium

---

## Previous Iterations (Detailed)

### Iteration 1
- Code Review Verdict: NEEDS_REVISION
- Decision Helper Verdict: NEEDS_REVISION
- Critical Issues Found: 2
- Implemented: Missing error handler (8/10), Incorrect status code (9/10)
- Deferred: Redis connection pooling (5/10)
```

### code-review-{iteration}.md Format

Each code review creates a detailed analysis file:

```markdown
# Code Review - Iteration {number}

Date: {timestamp}
Reviewer: Code Review Agent

## Summary
{Overall assessment of the changes}

## Files Reviewed
- {file_path}: {brief description of changes}

## Findings

### Critical Issues
{Issues that must be fixed}

### Suggestions
{Improvements that would be beneficial}

### Positive Observations
{What was done well}

## Security Analysis
{Any security concerns or confirmations}

## Performance Considerations
{Performance impacts or improvements}

## Best Practices
{Adherence to or violations of best practices}

## Final Verdict
{APPROVED|APPROVED_OPTIONAL|NEEDS_REVISION}
```

### decision-helper-{iteration}.md Format

The decision helper creates an assessment of each suggestion:

```markdown
# Decision Helper Assessment - Iteration {number}

Date: {timestamp}
Task Reference: ./code-reviews/TASK.md

## Original Task Summary
{Brief recap of what was requested}

## Code Review Suggestions Analysis

### Suggestion 1: {title}
- **Relevance Score**: {X}/10
- **Reasoning**: {Why this score}
- **Recommendation**: {implement|defer|skip}
- **Priority**: {high|medium|low}

{Repeat for each suggestion}

## Overall Assessment
- Total Suggestions: {count}
- Critical (7+): {count}
- Medium (4-6): {count}
- Low (0-3): {count}

## Implementation Requirements
{What must be implemented based on scores}

## Final Verdict
{APPROVED|APPROVED with optional suggestions|NEEDS_REVISION}
```

### code-review-{iteration}-implementation.md Format

Documents what was actually implemented:

```yaml
IMPLEMENTATION_STATUS: |
  # Code Review Implementation Status
  
  Based on: code-review-{iteration}.md and decision-helper-{iteration}.md
  Date: {timestamp}
  
  ## Implemented Suggestions:
  {implemented_list}
  
  ## Not Implemented (Out of Scope):
  {out_of_scope_list}
  
  ## Not Implemented (Low Priority):
  {low_priority_list}
  
  ## Summary:
  Implemented {implemented_count}/{total_count} suggestions.
  All suggestions with scores >= 7 were implemented.
```

**Filled Example:**
```markdown
# Code Review Implementation Status

Based on: code-review-1.md and decision-helper-1.md
Date: 2024-01-15 09:30:00 UTC

## Implemented Suggestions:
- **Fix missing error handler** [Score: 8/10]
  - Added try-catch block in rateLimiter middleware
  - Now properly catches Redis connection errors
  - Returns 503 when Redis unavailable
  
- **Correct status code** [Score: 9/10]
  - Changed from 403 to 429 for rate limit exceeded
  - Added Retry-After header with remaining time

## Not Implemented (Out of Scope):
- **Add comprehensive API documentation** [Score: 3/10]
  - Suggestion was to document all endpoints
  - Only implementing rate limiting for login endpoint
  - API documentation is separate task

## Not Implemented (Low Priority):
- **Implement Redis connection pooling** [Score: 5/10]
  - Current single connection sufficient for expected load
  - Can be added later if performance issues arise
  - Documented in possible-escalations-1.md

## Summary:
Implemented 2/4 suggestions.
All suggestions with scores >= 7 were implemented.
```

### possible-escalations-{iteration}.md Format

Documents medium-priority items for future consideration:

```yaml
ESCALATIONS: |
  # Possible Escalations from Code Review
  
  Based on: code-review-{iteration}.md and decision-helper-{iteration}.md
  Date: {timestamp}
  Original Task: {task_description}
  
  ## High Priority Escalations (Decision Score 5-6)
  {high_priority_items}
  
  ## Medium Priority Escalations (Decision Score 4)
  {medium_priority_items}
  
  ## Summary
  Total escalations: {count}
  Recommend for future work: {future_count}
```

**Filled Example:**
```markdown
# Possible Escalations from Code Review

Based on: code-review-1.md and decision-helper-1.md
Date: 2024-01-15 09:30:00 UTC
Original Task: Add Authentication Rate Limiting

## High Priority Escalations (Decision Score 5-6)

### 1. Redis Connection Pooling
- **Source**: Code review suggestion #3
- **Decision Score**: 5/10
- **Description**: Implement connection pooling for Redis to handle high load
- **Why Deferred**: Current single connection works for expected traffic
- **Potential Impact**: Under very high load, single connection could bottleneck
- **Recommended Action**: Monitor Redis performance, implement if latency increases

### 2. Add Distributed Rate Limiting
- **Source**: Code review suggestion #5
- **Decision Score**: 6/10
- **Description**: Support rate limiting across multiple server instances
- **Why Deferred**: Currently running single instance, distributed not needed yet
- **Potential Impact**: Rate limits could be bypassed if scaled horizontally
- **Recommended Action**: Implement before horizontal scaling

## Medium Priority Escalations (Decision Score 4)

### 1. Request ID in Logs
- **Source**: Code review suggestion #7
- **Decision Score**: 4/10
- **Description**: Add request correlation ID to all rate limiter logs
- **Why Deferred**: Logging improvements outside current scope
- **Potential Impact**: Harder to trace issues across services
- **Recommended Action**: Include in logging standards initiative

## Summary
Total escalations: 3
Recommend for future work: 2 (Redis pooling, distributed limiting)
Nice-to-have enhancements: 1 (request ID logging)
```

---

## File System Requirements

The code-reviews directory must maintain a specific structure for the process to work correctly.

```yaml
REQUIRED_STRUCTURE:
  ./code-reviews/
    TASK.md                                    # ALWAYS first, no variations
    iteration-summary.md                       # Human-readable summary, updated each iteration
    code-review-{n}.md                         # n = 1,2,3... (integer)
    decision-helper-{n}.md                     # n matches code-review
    code-review-{n}-implementation.md          # created after decisions
    possible-escalations-{n}.md                # only if scores 4-6 exist

FILE_NAMING:
  NO_VARIATIONS_ALLOWED: TRUE
  ITERATION_TYPE: INTEGER
  ITERATION_START: 1
  ZERO_PADDING: FALSE
```

**Critical naming rules:**
- Use integers starting at 1 (not 0)
- No zero padding (use 1, not 01)
- Must match exact naming pattern
- Iteration numbers must be sequential

**Example directory after 2 iterations:**
```
./code-reviews/
  TASK.md
  iteration-summary.md
  code-review-1.md
  decision-helper-1.md
  code-review-1-implementation.md
  possible-escalations-1.md
  code-review-2.md
  decision-helper-2.md
```

---

## Precedence Rules

When there are conflicts between different instructions or assessments, follow this hierarchy:

```yaml
OVERRIDE_HIERARCHY:
  1. User_explicit_instruction
  2. TASK.md_scope_definition
  3. Decision_helper_verdict
  4. Code_review_verdict
  5. CLAUDE.md_rules
  6. Default_behavior

SPECIAL_OVERRIDES:
  IF user_says("skip review"): SKIP_ALL_REVIEW
  IF user_says("implement everything"): IGNORE_SCORES
  IF TASK.md_excludes(feature): NEVER_IMPLEMENT
```

**What this means in practice:**

1. **User explicit instruction** - If you directly tell me "skip the review", I skip it
2. **TASK.md scope** - If TASK.md says "don't modify the database", I never do
3. **Decision helper verdict** - Has authority over code review for scope decisions
4. **Code review verdict** - Suggestions are subject to decision helper evaluation
5. **CLAUDE.md rules** - This document's rules apply unless overridden above
6. **Default behavior** - Standard Claude behavior when nothing else applies

**Examples:**
- Code review says "add caching" but TASK.md excludes it → Don't implement
- User says "implement all suggestions" → Ignore scoring system
- Decision helper says score is 3/10 but code review says critical → Use decision helper's assessment

---

## Error Recovery Procedures

Things don't always go perfectly. Here's how I recover from common issues:

### Missing TASK.md

If I need TASK.md but it doesn't exist (perhaps deleted or never created):

```yaml
MISSING_TASK_MD:
  DETECTION: !exists(./code-reviews/TASK.md)
  ACTION: CREATE_FROM_CONTEXT → RESTART_REVIEW
  MESSAGE: "Creating TASK.md from conversation context"
```

**What I do:**
1. Output: "Creating TASK.md from conversation context"
2. Reconstruct task details from our conversation
3. Create TASK.md with available information
4. Restart the review process

### Review Spawn Failed

If the Task tool fails when spawning a review:

```yaml
REVIEW_SPAWN_FAILED:
  DETECTION: Task_tool_error
  ACTION: RETRY_ONCE → ALERT_USER
  MESSAGE: "Code review failed to spawn. Retrying..."
```

**What I do:**
1. Output: "Code review failed to spawn. Retrying..."
2. Attempt to spawn the review once more
3. If it fails again, alert you and ask for guidance

### Conflicting Scores

When code review severity conflicts with decision helper score:

```yaml
CONFLICTING_SCORES:
  DETECTION: review_says_critical AND score < 7
  ACTION: USE_HIGHER_ASSESSMENT
  MESSAGE: "Using more critical assessment"
```

**What I do:**
1. Output: "Using more critical assessment"
2. Treat the suggestion as critical (score 7+)
3. Implement it to ensure safety

---

## Pre-Commit Validation

Before committing any changes, I must validate that the review process completed successfully:

```yaml
PRE_COMMIT_VALIDATION:
  exists(./code-reviews/TASK.md): REQUIRED
  latest_review_verdict == "APPROVED": REQUIRED
  latest_decision_verdict == "APPROVED": REQUIRED
  all_scores_7plus_implemented(): REQUIRED
  implementation_doc_exists(): REQUIRED
  no_sensitive_files_staged(): REQUIRED
  explicit_file_adds_only(): REQUIRED
  
IF any_validation_fails:
  ACTION: BLOCK_COMMIT
  MESSAGE: "Pre-commit validation failed: {failed_checks}"
```

### Pre-Commit Checklist

Before EVER running git commit, I verify:

- [ ] code-reviews/TASK.md was created at the start
- [ ] Latest code review verdict is "APPROVED" or "APPROVED_OPTIONAL"
- [ ] Latest decision helper verdict is "APPROVED" 
- [ ] All suggestions scoring 7+ have been implemented
- [ ] Implementation documentation exists for each iteration
- [ ] No sensitive files are staged
- [ ] Files were added explicitly (not with -A)
- [ ] code-reviews/ directory is not being committed (unless requested)

**If ANY check fails:** I stop and output what failed, then continue the review loop.

---

## Review Loop Example - Complete Walkthrough

Let me show you a complete example of the review process across multiple iterations:

### Initial Request
User: "Add a green button to the homepage that shows a success message when clicked"

### Iteration 1

**TASK.md Created:**
```markdown
# Task: Add Green Success Button to Homepage

## Original Request
"Add a green button to the homepage that shows a success message when clicked"

## Approved Plan
- Add a green button component to the homepage
- Implement click handler to show success message
- Style button with green color
- Add success message display logic

## Scope
- Create button component
- Add click event handler
- Display success message
- Green styling

## Out of Scope
- Backend integration
- Database changes
- Other pages besides homepage
- Additional button functionality
```

**Implementation:**
- Created GreenButton.jsx component
- Added to Homepage.jsx
- Implemented click handler

**Code Review Results:**
1. Missing accessibility attributes (aria-label)
2. No error boundary for component
3. Success message not dismissible
4. Consider adding loading state for future API calls
5. Hard-coded colors should use theme variables

**Decision Helper Assessment:**
1. Missing accessibility - Score: 9/10 (Critical - implement)
2. No error boundary - Score: 8/10 (Important - implement)
3. Message not dismissible - Score: 7/10 (Important - implement)
4. Loading state - Score: 3/10 (Future consideration - skip)
5. Theme variables - Score: 5/10 (Good practice - escalate)

**Action:** Implement suggestions scoring 7+

### Iteration 2

**Changes Made:**
- Added aria-label to button
- Wrapped component in error boundary
- Made success message dismissible with X button

**Code Review Results:**
1. Dismiss button needs keyboard support
2. Consider adding animation to message appearance

**Decision Helper Assessment:**
1. Keyboard support - Score: 8/10 (Accessibility - implement)
2. Animation - Score: 4/10 (Nice to have - escalate)

**Action:** Implement keyboard support

### Iteration 3

**Changes Made:**
- Added keyboard event handler for Escape key
- Added focus management for dismiss button

**Code Review Results:**
1. Code looks good, well-structured
2. Good accessibility implementation
3. Consider unit tests (already in scope based on TASK.md review)

**Decision Helper Assessment:**
- All requirements met
- Verdict: APPROVED

**Final Status:**
```
Review process complete. All critical issues addressed.
```

**Files Created During Process:**
```
./code-reviews/
  TASK.md
  iteration-summary.md
  code-review-1.md
  decision-helper-1.md
  code-review-1-implementation.md
  possible-escalations-1.md
  code-review-2.md
  decision-helper-2.md
  code-review-2-implementation.md
  possible-escalations-2.md
  code-review-3.md
  decision-helper-3.md
```

---

## Quick Reference - State Transitions

For quick lookup, here's the complete state flow:

1. **IDLE** → User request → **PLAN_PRESENTATION** (if plan mode) or **CREATE_TASK_MD**
2. **PLAN_PRESENTATION** → Plan approved → **CREATE_TASK_MD**
3. **CREATE_TASK_MD** → Task documented → **IMPLEMENTATION**
4. **IMPLEMENTATION** → File modified → **NOTIFY_REVIEW_START**
5. **NOTIFY_REVIEW_START** → Notification sent → **SPAWN_CODE_REVIEW**
6. **SPAWN_CODE_REVIEW** → Review complete → **SHARE_REVIEW**
7. **SHARE_REVIEW** → Results shared → **SPAWN_DECISION_HELPER**
8. **SPAWN_DECISION_HELPER** → Assessment complete → **SHARE_DECISION**
9. **SHARE_DECISION** → Results shared → **UPDATE_ITERATION_SUMMARY**
10. **UPDATE_ITERATION_SUMMARY** → Summary updated → **CHECK_COMPLETION**
11. **CHECK_COMPLETION** → Evaluate verdicts:
    - Both approved → **EXIT_LOOP**
    - Need changes → **IMPLEMENT_SUGGESTIONS**
12. **IMPLEMENT_SUGGESTIONS** → Changes made → **NOTIFY_REVIEW_START** (loop back)
13. **EXIT_LOOP** → Process complete

---

## Implementation Steps

When this command is executed, follow these steps:

1. **Clean Setup**
   - Check if `./code-reviews/` exists
   - If exists: Delete all *.md files
   - If not: Create directory

2. **Initialize State Machine**
   - Set current state to IDLE
   - Set iteration counter to 1
   - Parse the provided prompt

3. **Execute State Machine**
   - Follow state transitions exactly as defined
   - Create all required files with proper naming
   - Use Task tool for spawning review agents
   - Continue until EXIT_LOOP state is reached

4. **Complete Process**
   - Output final status
   - Ensure all documentation is complete
   - Return control to main conversation flow

Remember: This process is MANDATORY for all file modifications unless explicitly overridden by the user.