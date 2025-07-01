# cloop - Compact Loop Review State Machine

Execute the mandatory self-review state machine for any file modifications made by the agent.

## Usage

This command is automatically executed when:
- ANY file is modified (Edit, Write, MultiEdit, NotebookEdit)
- The user hasn't explicitly requested to skip review
- The task is NOT an external code review

When triggered: `$PROMPT` (current task context)

---

## State Machine

```yaml
STATES:
  IDLE → CREATE_TASK_MD → IMPLEMENTATION → NOTIFY_REVIEW_START → SPAWN_CODE_REVIEW 
  → SHARE_REVIEW → SPAWN_DECISION_HELPER → SHARE_DECISION → UPDATE_ITERATION_SUMMARY 
  → CHECK_COMPLETION → [EXIT_LOOP | IMPLEMENT_SUGGESTIONS → loop back]

TRIGGERS:
  - ANY file modification by agent → automatic state machine execution
  - External review detection phrases → skip self-review cycle
```

## Key States

### CREATE_TASK_MD
```yaml
ACTION: Write(./code-reviews/TASK.md)
CONTENT:
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

### SPAWN_CODE_REVIEW
```yaml
ACTION: Task("Review my changes with context from TASK.md")
OUTPUT: ./code-reviews/code-review-{iteration}.md
FOCUS: security, performance, best practices, correctness
```

### SPAWN_DECISION_HELPER
```yaml
ACTION: Task("Evaluate code review suggestions against TASK.md")
OUTPUT: ./code-reviews/decision-helper-{iteration}.md
SCORING: 0-10 relevance scale
  ≥7: MUST implement
  4-6: Defer to escalations
  <4: Skip
```

### CHECK_COMPLETION (Verdict Matrix)
```text
| Code Review    | Decision Helper | Action                    |
|----------------|-----------------|---------------------------|
| APPROVED       | APPROVED        | EXIT_LOOP                 |
| APPROVED       | NEEDS_REVISION  | IMPLEMENT_CRITICAL (≥7)   |
| NEEDS_REVISION | APPROVED        | SKIP (out of scope)       |
| NEEDS_REVISION | NEEDS_REVISION  | IMPLEMENT_CRITICAL (≥7)   |
```

## File Structure
```
./code-reviews/
  TASK.md                          # Always first
  iteration-summary.md             # Updated each iteration
  code-review-{n}.md              # n = 1,2,3...
  decision-helper-{n}.md          # Matches code-review
  code-review-{n}-implementation.md
  possible-escalations-{n}.md     # If scores 4-6 exist
```

## Quick Reference

1. **Setup**: Clean `./code-reviews/` directory
2. **Document**: Create TASK.md with exact requirements
3. **Implement**: Make requested changes
4. **Review**: Spawn code review agent
5. **Evaluate**: Decision helper scores suggestions
6. **Act**: Implement scores ≥7, defer 4-6, skip <4
7. **Loop**: Until both verdicts are APPROVED
8. **Exit**: Complete with all critical issues resolved

## Override Hierarchy
```yaml
1. User_explicit_instruction ("skip review")
2. TASK.md_scope_definition
3. Decision_helper_verdict
4. Code_review_verdict
```

## Examples

### Task Creation
```markdown
# Task: Add Error Handling to Login
## Original Request
"Add proper error handling to the login function"
## Approved Plan
- Add try-catch blocks
- Return meaningful errors
## Scope
- Error handling in login()
## Out of Scope
- Authentication changes
```

### Decision Scoring
```
"Add database pooling" → Score: 3/10 → Skip (not requested)
"Fix SQL injection" → Score: 9/10 → Implement (security critical)
"Add request logging" → Score: 5/10 → Escalate (nice to have)
```

Remember: This process is MANDATORY for all file modifications unless explicitly overridden.