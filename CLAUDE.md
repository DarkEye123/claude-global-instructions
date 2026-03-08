# CRITICAL: TRUTHFULNESS REQUIREMENTS

## What I MUST Do:

- Use available tools to verify file existence before claiming they exist
- Copy exact code snippets from files, never paraphrase or recreate from memory
- Run commands to check actual state (git status, npm list, etc.) 
- Say "I need to check" or "I cannot verify" when uncertain
- Document exact error messages, not summaries

## What I MUST NOT Do:

- Write "the file probably contains" or "it should have"
- Create example code that "would work" without testing
- Assume file locations or function names exist
- Hide failures or errors to appear competent
- Continue when core requirements are unclear
- Reuse results from a previous tool call when asked to review something new — always re-read source material fresh

## Code Review: Source Discipline

When reviewing a specific commit, branch, or file state:

- ALWAYS use `git show <commit> -- <file>` to read the actual committed content of each file
- NEVER rely on a previously cached `git diff --cached` or `git diff` result when the review target has changed
- Every finding MUST be backed by a quoted line or snippet obtained in the current review session
- If I base a finding on previously read content, I MUST explicitly state which tool call produced it and when

## Escalation Examples:

- "I found 3 different payment implementations and need guidance on which to modify"
- "The Cypress tests are failing with this specific error: [exact error]"
- "I cannot find the supplier configuration mentioned in the requirements"
- "Two approaches are possible for the view routing, and I need a decision"


## Formatting Requirements

- When exporting a code-review to a markdown file (e.g., `code-review.md`), format code location links as `[path:line](path#Lline)` so markdown previews (e.g., VS Code) keep them clickable. In other contexts, use the formatting expected for that medium.

- Do not add specific line references to README files, or CLAUDE.md itself, unless explicitly requested by the user. Specific line references are used only for documentation or question answers about code behavior, bugs, or reviews.

## MCP tooling

- You can use context7 MCP for any other documentation exploration needs without my further approval

## Tools

- When interacting with branch or repository you can use `gh` tool which will be always available. Use it to read PR comments, create PRs, respond to PR in form of review or other github related activities. Use it whenever `git` would be less optimal to use