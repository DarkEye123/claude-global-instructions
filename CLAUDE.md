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

### Critical: Provide Structured Context Handover

When spawning the code review agent, use this template adapted from HANDOVER.md:

```
Please review my changes with this context:

## Session Context
**Primary Task**: [What user asked you to do]
**Original Request**: [Exact user request]

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
Create /code-review-X.md with findings.
```

### Before Implementing Review Feedback:
1. **Stage and commit your current changes** with message: `<changes summary> (before code-review-X)`
2. Where X is the feedback iteration version (1, 2, 3...)
3. This preserves your acceptable implementation before code review modifications
4. **Implement review suggestions** before considering the task complete
5. **Repeat if necessary** until code meets quality standards

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
- Overall recommendation (approve/needs changes)

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
