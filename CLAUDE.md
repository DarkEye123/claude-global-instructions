# CLAUDE.md - Claude Code Instructions v2.0

## Context Initialization

```yaml
ON_CONVERSATION_START:
  IF message_count == 0 AND no_active_task:
    ACTION: CLEANUP_CODE_REVIEWS
    CLEANUP_PROCESS:
      1. CHECK: exists(/code-reviews/)
      2. IF exists: DELETE all *.md files
      3. ELSE: CREATE /code-reviews/
    LOG: "Starting with clean code-reviews directory"
```

## Self-Review vs External Review Detection

```yaml
SELF_REVIEW_SCOPE:
  TRIGGER_FOR: ANY change authored by agent
  INCLUDING:
    - Code files (*.js, *.py, *.ts, etc.)
    - Configuration files (*.json, *.yaml, *.toml)
    - Documentation (*.md including CLAUDE.md and README.md)
    - Scripts, tests, any file type
  WHEN: Agent uses Edit, MultiEdit, Write, or NotebookEdit tools
  THEN: ALWAYS trigger self-review cycle

EXTERNAL_REVIEW_DETECTION:
  TRIGGER_PHRASES:
    - "review this pr"
    - "do a review"
    - "do a code-review"
    - "review this code"
    - "can you review"
    - "check this pr"
    - "analyze this code"
  WHEN_DETECTED: User is asking for review of EXTERNAL code
  THEN: Perform requested review ONLY, no self-review cycle
  
CLARIFICATION:
  - Self-review: For changes I MAKE during conversation
  - External review: For code I'm ASKED TO REVIEW but didn't write
```

## State Machine Definition

```yaml
STATES:
  - IDLE
  - PLAN_PRESENTATION
  - CREATE_TASK_MD
  - IMPLEMENTATION
  - NOTIFY_REVIEW_START
  - SPAWN_CODE_REVIEW
  - SHARE_REVIEW
  - SPAWN_DECISION_HELPER
  - SHARE_DECISION
  - IMPLEMENT_SUGGESTIONS
  - CHECK_COMPLETION
  - EXIT_LOOP

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
  
IMPORTANT_DISTINCTION:
  - "Fix CLAUDE.md" → I edit file → TRIGGERS self-review
  - "Review this PR" → I analyze external code → NO self-review

PLAN_MODE_HANDLING:
  WHEN: plan_mode_active
  THEN: 
    - DEFER: CREATE_TASK_MD until after plan approval
    - ON_PLAN_APPROVAL: 
      - IMMEDIATE: CREATE_TASK_MD
      - THEN: GOTO: IMPLEMENTATION

STATE_TRANSITIONS:
  IDLE:
    ON: user_request_involving_files AND plan_mode_active AND NOT external_review_request → GOTO: PLAN_PRESENTATION
    ON: user_request_involving_files AND NOT plan_mode_active AND NOT external_review_request → GOTO: CREATE_TASK_MD
    ON: external_review_request → STAY: IDLE (perform review without state machine)
  
  PLAN_PRESENTATION:
    ACTION: Present plan to user using exit_plan_mode tool
    ON: plan_approved → GOTO: CREATE_TASK_MD
    ON: plan_rejected → GOTO: IDLE
  
  CREATE_TASK_MD:
    ACTION: Write(/code-reviews/TASK.md)
    TEMPLATE: |
      # Task: {brief_description}
      
      ## Original Request
      {exact_user_message}
      
      ## Approved Plan
      {implementation_approach}
      
      ## Scope
      {what_to_implement}
      
      ## Out of Scope
      {what_not_to_implement}
    ON: success → GOTO: IMPLEMENTATION
  
  IMPLEMENTATION:
    ON: any_file_modification_by_agent → GOTO: NOTIFY_REVIEW_START
    EXCEPTION: external_review_context → STAY: IMPLEMENTATION (no self-review)
    INCLUDES: [ALL file types - code, docs, configs, CLAUDE.md, README.md, everything]
    CONTEXT_CHECK: If user asked for external code review, skip self-review cycle
  
  NOTIFY_REVIEW_START:
    ACTION: output("I've completed the changes. Starting code review now to ensure quality and best practices...")
    ON: complete → GOTO: SPAWN_CODE_REVIEW
  
  SPAWN_CODE_REVIEW:
    IF iteration == 1:
      ACTION: Write(/code-reviews/iteration-summary.md, initial_template)
    ACTION: Task(code_review_prompt)
    PROMPT_TEMPLATE: |
      Please review my changes with this context:
      
      ## Session Context
      **Primary Task**: {task_from_TASK_md}
      **Original Request**: {exact_user_request}
      **Task Constraints**: {out_of_scope_from_TASK_md}
      
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
  
  SHARE_REVIEW:
    ACTION: output(review_results)
    ON: complete → GOTO: SPAWN_DECISION_HELPER
  
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
  
  SHARE_DECISION:
    ACTION: output(decision_results)
    THEN: UPDATE_ITERATION_SUMMARY
    ON: complete → GOTO: CHECK_COMPLETION
  
  UPDATE_ITERATION_SUMMARY:
    ACTION: Edit(/code-reviews/iteration-summary.md)
    UPDATE_WITH: latest_review_and_decision_results
    ON: complete → GOTO: CHECK_COMPLETION
  
  CHECK_COMPLETION:
    EVALUATE: verdict_matrix
    ON: action == "EXIT_LOOP" → GOTO: EXIT_LOOP
    ON: action == "IMPLEMENT_CRITICAL_ONLY" → GOTO: IMPLEMENT_SUGGESTIONS
    ON: action == "SKIP_REVISIONS" → GOTO: EXIT_LOOP
  
  IMPLEMENT_SUGGESTIONS:
    ACTION: output("Based on the decision-helper scores, I'll implement suggestions scoring 7+ and document others in the escalations file...")
    IMPLEMENT: all suggestions with score >= 7
    CREATE: /code-reviews/code-review-{iteration}-implementation.md
    CREATE: /code-reviews/possible-escalations-{iteration}.md (if any scores 4-6)
    INCREMENT: iteration
    ON: complete → GOTO: NOTIFY_REVIEW_START
  
  EXIT_LOOP:
    ACTION: output("Review process complete. All critical issues addressed.")
    RETURN: control to main flow
```

## Decision Logic

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

SCORE_ACTIONS:
  score >= 7.0:
    ACTION: IMPLEMENT
    PRIORITY: IMMEDIATE
    OPTIONAL: FALSE
  
  score >= 4.0 AND score < 7.0:
    ACTION: DEFER_TO_ESCALATIONS
    FILE: /code-reviews/possible-escalations-{iteration}.md
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

## String Templates

```yaml
NOTIFICATIONS:
  REVIEW_START: "I've completed the changes. Starting code review now to ensure quality and best practices..."
  DECISION_START: "Code review complete. Now initiating decision-helper assessment to evaluate suggestions against original requirements..."
  IMPLEMENTATION_START: "Based on the decision-helper scores, I'll implement suggestions scoring 7+ and document others in the escalations file..."
  
COMMIT_MESSAGES:
  BEFORE_REVIEW: "{change_summary} (before code-review-{iteration})"
  FINAL: |
    {change_summary}
    
    Generated with [Claude Code](https://claude.ai/code)
    
    Co-Authored-By: Claude <noreply@anthropic.com>

FILE_TEMPLATES:
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

## File System Requirements

```yaml
REQUIRED_STRUCTURE:
  /code-reviews/
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

## Precedence Rules

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

## Error Recovery

```yaml
ERROR_STATES:
  MISSING_TASK_MD:
    DETECTION: !exists(/code-reviews/TASK.md)
    ACTION: CREATE_FROM_CONTEXT → RESTART_REVIEW
    MESSAGE: "Creating TASK.md from conversation context"
  
  REVIEW_SPAWN_FAILED:
    DETECTION: Task_tool_error
    ACTION: RETRY_ONCE → ALERT_USER
    MESSAGE: "Code review failed to spawn. Retrying..."
  
  CONFLICTING_SCORES:
    DETECTION: review_says_critical AND score < 7
    ACTION: USE_HIGHER_ASSESSMENT
    MESSAGE: "Using more critical assessment"
```

## Git Operations

```yaml
COMMIT_RULES:
  NEVER_USE: ["git add -A", "git add ."]
  ALWAYS_USE: "git add {explicit_file_paths}"
  
PRE_COMMIT_SEQUENCE:
  1. git status
  2. git add {file1} {file2} ...
  3. git commit -m "$(cat <<'EOF'
     {commit_message}
     EOF
     )"

EXCLUDED_FROM_COMMITS:
  - /code-reviews/*.md
  - Any file containing: ["password", "secret", "key", "token"]
```

## Validation Checklist

```yaml
PRE_COMMIT_VALIDATION:
  exists(/code-reviews/TASK.md): REQUIRED
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

## Truthfulness Framework

### Core Principles
- Verify before claiming
- Escalate when uncertain
- Document exact findings

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

### When to Escalate:
- Multiple valid approaches exist and you need guidance
- Core requirements are ambiguous or conflicting
- Tests fail with errors you cannot resolve
- You find conflicting implementations in the codebase

### Escalation Examples:
- "I found 3 different auth implementations and need guidance on which to modify"
- "The tests are failing with this specific error: [exact error]"
- "I cannot find the file mentioned in the requirements"
- "Two approaches are possible, and I need a decision on direction"

## Important Reminders

```yaml
CORE_PRINCIPLES:
  - Do exactly what was asked, nothing more
  - Prefer editing to creating files
  - Never create documentation unless requested
  - Self-review is MANDATORY after ANY file change by agent (including CLAUDE.md)
  - External review requests should NOT trigger self-review cycle
  - Decision-helper has final say on scope
  - In plan mode: Present plan first, then CREATE_TASK_MD immediately after approval
  
REVIEW_TRIGGER_RULES:
  - ANY_AGENT_CHANGE: If I edit/write ANY file → ALWAYS self-review
  - EXTERNAL_REVIEW: If user asks me to review external code → NO self-review
  - NO_EXCEPTIONS: Even CLAUDE.md and README.md changes trigger self-review
```