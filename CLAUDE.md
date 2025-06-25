# CLAUDE.md - Claude Code Instructions v3.0 (Comprehensive Edition)

## CRITICAL: This Document is Self-Executing

**IMPORTANT**: I (Claude) MUST follow these instructions automatically for EVERY conversation, without being prompted. These rules are MANDATORY and apply to ALL file operations I perform. There are NO exceptions.

**Key Points**:
- Code review is MANDATORY after ANY file modification I make
- This includes ALL file types: code, docs, configs, even this CLAUDE.md file itself
- The state machine MUST be followed exactly as specified
- I MUST NOT skip steps or make exceptions
- External review requests (reviewing code I didn't write) do NOT trigger self-review

---

## Initial Setup When Starting a Conversation

When I start a new conversation, I need to ensure a clean working environment for code reviews. This prevents confusion from previous sessions and ensures each task starts fresh.

### Why Clean the code-reviews Directory?

The code-reviews directory contains artifacts from the review process. These should be session-specific to avoid confusion between different tasks. Starting clean ensures:
- No confusion from previous review iterations
- Clear tracking of current task progress
- Fresh numbering for review iterations

### Setup Process Specification

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

### What This Means in Practice

When I detect I'm starting a fresh conversation (message count is zero and there's no active task), I will:

1. First check if the `code-reviews/` directory exists
2. If it exists, I delete all markdown files inside it using: `rm -f code-reviews/*.md`
3. If it doesn't exist, I create it using: `mkdir -p code-reviews`
4. I then output: "Starting with clean code-reviews directory"

**Example of what you'll see:**
```
Starting with clean code-reviews directory
```

This happens automatically - you don't need to ask me to do this.

---

## Understanding When to Trigger Self-Review vs External Review

This is a critical distinction that determines whether the full review state machine activates. Getting this wrong means either missing important quality checks or running unnecessary reviews on external code.

### The Core Distinction

**Self-Review**: When I (Claude) create or modify ANY file during our conversation
**External Review**: When you ask me to review code that already exists or that you provide

### Self-Review Triggers - When I MUST Review My Own Work

I MUST trigger the self-review cycle whenever I author changes. This is non-negotiable and includes EVERY file type without exception.

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
```

**In practice, this means:**
- If I use the Edit tool to change even one character → self-review triggers
- If I use Write to create a new file → self-review triggers
- If I use MultiEdit to refactor code → self-review triggers
- If I update documentation → self-review triggers
- There are NO exceptions to this rule

**Example scenarios that MUST trigger self-review:**
1. "Fix the typo in README.md" → I edit the file → self-review activates
2. "Update the config.json file" → I modify the file → self-review activates
3. "Create a new utility function" → I write new code → self-review activates
4. "Fix CLAUDE.md formatting" → I edit this file → self-review activates

### External Review Detection - When I DON'T Self-Review

When you ask me to review code that I didn't write, I perform ONLY the requested review without activating my self-review cycle.

```yaml
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
  THEN: 
    - Perform requested review ONLY, no self-review cycle
    - IF PR_number_available: Use `gh pr view {number} --comments` to check PR comments
    - INCLUDE: PR comments in review context for better understanding
  
CLARIFICATION:
  - Self-review: For changes I MAKE during conversation
  - External review: For code I'm ASKED TO REVIEW but didn't write
```

**Example external review scenarios:**
1. "Review PR #123" → I analyze existing PR → NO self-review
2. "Can you review this code: [paste]" → I review provided code → NO self-review
3. "Do a code review of the changes in main.py" (where I didn't edit main.py) → NO self-review
4. "Check this PR and tell me if it's good" → I review external PR → NO self-review

### The Critical Distinction Explained

```yaml
IMPORTANT_DISTINCTION:
  - "Fix CLAUDE.md" → I edit file → TRIGGERS self-review
  - "Review this PR" → I analyze external code → NO self-review
```

**Why this matters:**
- Self-review ensures my changes meet quality standards
- External review focuses on analyzing existing code without the overhead of self-review
- Mixing these up either skips important checks or adds unnecessary process

---

## The Mandatory Self-Review State Machine

When I (Claude) create or modify ANY file during our conversation, I MUST automatically trigger a comprehensive review process. This process is defined in detail in the `/loop` command.

**AUTOMATIC EXECUTION**: If file modifications are made and the user hasn't explicitly requested to skip review, I will automatically read and execute the `/loop` command with the current task context. This happens without user prompting - I will read `/Users/darkeye/.claude/commands/loop.md` and follow its state machine whenever I modify files.

**Key Points**:
- This applies to ALL file types without exception
- The review continues until all critical issues are resolved
- Only suggestions scoring 7+ are implemented
- External review requests do NOT trigger this process

For full details of the state machine, see: `/Users/darkeye/.claude/commands/loop.md`


## Important Reminders

To summarize the most critical points:

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

**These rules are absolute. There are no exceptions.**

---

## Final Note

This document represents a contract between us. By following these instructions precisely, I ensure:
- Consistent quality across all changes
- Transparent process you can follow
- Protection against scope creep
- Clear documentation of all decisions
- Professional development practices

The review process might seem extensive, but it ensures that every change I make meets high standards and stays within the requested scope. This protects both of us from miscommunication and ensures successful outcomes.

Remember: This process triggers automatically. You don't need to remind me - whenever I modify ANY file, this entire flow activates without prompting.
# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.