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

## Escalation Examples:

- "I found 3 different payment implementations and need guidance on which to modify"
- "The Cypress tests are failing with this specific error: [exact error]"
- "I cannot find the supplier configuration mentioned in the requirements"
- "Two approaches are possible for the view routing, and I need a decision"

# KNOWN ISSUES & TEMPORARY OBSTACLES

## Piped Commands Permission Bug
**Status**: Active bug (GitHub #1271)

Claude Code doesn't respect allowed permissions for piped commands (`|`), `&&`, or `;` operators.

**Workaround**: Use temporary files instead of pipes
```bash
# AVOID: command1 | command2
# USE: 
command1 > /tmp/temp_output.txt
command2 < /tmp/temp_output.txt
rm /tmp/temp_output.txt
```

**Details**: See `known-problems/piping.md` for full documentation