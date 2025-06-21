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

### When You Make Code Changes:

1. **After implementing** any feature, bugfix, or code modification
2. **Automatically spawn** a code review sub-agent using the Task tool
3. **Code review agent will**:
   - Analyze the changes for security, performance, style, and best practices
   - Create `/code-review.md` (or incremental versions like `/code-review-1.md`, `/code-review-2.md`)
   - Return findings to the main agent
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
