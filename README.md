# Claude AI Global Instructions

This repository contains global instructions for Claude AI that apply across all projects and devices.

## Overview

The `CLAUDE.md` file in this repository provides consistent guidance and frameworks for Claude AI when assisting with software development tasks. By placing this file in your projects, you ensure consistent behavior and adherence to best practices.

## What's Included

### AI-Optimized State Machine Architecture (v2.0)
- **State-based workflow**: All processes defined as explicit state machines with deterministic transitions
- **Truth tables**: Decision logic expressed as lookup tables, eliminating ambiguity
- **Exact string templates**: No variation allowed in outputs, ensuring consistency
- **Machine-parsable format**: YAML-based configuration blocks for automated processing

### Context Initialization
- **Automatic cleanup**: Code-reviews directory cleared on empty context (new conversations)
- **State guarantees**: Each conversation starts with clean artifacts
- **No cross-contamination**: Complete separation between sessions

### Automatic Code Review Process
- **State-driven execution**: TRIGGER → STATE → ACTION flow for all operations
- **Verdict matrix**: Explicit truth table defining all review outcome combinations
- **Decision-helper authority**: Final arbiter preventing scope creep (overrides code review when out of scope)
- **Score-based actions**: Deterministic thresholds (≥7 = implement, 4-6 = defer, <4 = skip)
- **File structure**: Exact naming patterns with no variations allowed
- **Comprehensive human-readable summary**: `iteration-summary.md` serves as a complete aggregator of all review details, updated in-place after each iteration. Contains full code review suggestions, decision-helper evaluations with reasoning, implementation decisions, and all deferred proposals with context - eliminating the need to check multiple files

### Truthfulness Framework
- **Core principles**: Verify before claiming, escalate when uncertain, document exact findings
- **Clear DO/DON'T lists**: Human-readable guidance on required and forbidden behaviors
- **Practical examples**: Real scenarios showing when to escalate or verify
- **Natural language approach**: Conversational guidelines that are immediately actionable

### Error Recovery
- **Defined error states**: Each error has detection criteria and recovery action
- **No undefined behavior**: All edge cases explicitly handled

### Important Instruction Reminders
- Core principles maintained as boolean rules
- Precedence hierarchy for conflicting instructions
- Git safety rules with explicit forbidden commands

## Benefits

- **Consistency**: Same behavior across all projects and devices
- **Quality**: Built-in code review process ensures high-quality outputs
- **Accuracy**: Truthfulness framework prevents hallucinations and assumptions
- **Efficiency**: Clear guidelines help Claude work more effectively

## Global Settings Configuration

The `settings.json` file allows pre-approving safe commands globally:
- Git commands (excluding `--hard` reset)
- Git worktree operations
- GitHub CLI (gh) commands
- Package managers (npm, npx, yarn, pip)
- Build and test tools
- Safe file operations

## Code Review State Machine

The code review process follows a deterministic state machine:
1. **PLAN_PRESENTATION** (if in plan mode): Present plan using exit_plan_mode tool
2. **CREATE_TASK_MD**: Document exact requirements before any work (immediately after plan approval)
3. **IMPLEMENTATION**: Make changes
4. **SPAWN_CODE_REVIEW**: Trigger review with structured context
5. **SPAWN_DECISION_HELPER**: Evaluate suggestions against original task
6. **CHECK_COMPLETION**: Use verdict matrix to determine next state
7. **EXIT_LOOP** or **IMPLEMENT_SUGGESTIONS**: Based on scores

All transitions are explicit with no room for interpretation.

## Available Commands

### `/loop` - Full State Machine Documentation
The comprehensive state machine documentation with detailed explanations of each state, transitions, file templates, and examples. Use this for understanding the complete review process.

### `/cloop` - Compact Loop Review
A condensed version of the loop command that maintains all essential functionality:
- Same state machine flow and verdict matrix
- Identical scoring system (≥7 implement, 4-6 defer, <4 skip)
- All required file outputs and naming conventions
- Reduced from ~1400 lines to ~150 lines while preserving all critical logic

### `/bloop` - Comprehensive Review Process
A complete implementation of the code review state machine that:
- Executes all review states automatically in sequence
- Generates all required review artifacts (code-review, decision-helper, iteration-summary)
- Implements suggestions based on scores (≥7 = implement, 4-6 = defer, <4 = skip)
- Continues iterations until all critical issues are resolved
- Provides detailed progress tracking and state transitions

All three commands execute the same review process - they differ only in documentation verbosity and execution style.

### `/review-with-assessment` - Context-Aware Code Review with Visual Analysis
An enhanced code review command that:
- Gathers deep context from Linear tickets and GitHub PRs
- **NEW: Analyzes images** from tickets/PRs (screenshots, mockups, diagrams)
- Follows ticket chains and cross-repository references
- Creates intelligent dependency graphs
- Performs comprehensive code review with visual context
- Spawns decision-helper for objective assessment
- Outputs three files: code-review.md, decision-helper.md, and code-review-summary.md

#### Image Analysis Features:
- **Automatic Extraction**: Finds images in Linear tickets, PR descriptions, and comments
- **Smart Caching**: Stores analyzed images in `{TICKET/PR}-images/` folders
- **Visual Intelligence**: Context-aware analysis of UI screenshots, diagrams, mockups, and errors
- **Efficient**: Previously analyzed images are cached and reused
- **Comprehensive**: Tracks processing status (successful, failed, cached)

### `/implement-with-assessment` - Context-Aware Implementation Assistant (EXPERIMENTAL)
⚠️ **EXPERIMENTAL FEATURE - IN ACTIVE DEVELOPMENT** ⚠️

An advanced implementation command that:
- Parallelizes implementation tasks using multiple sub-agents for maximum speed
- Creates persistent context cache in `agentic-help/` folder
- Gathers comprehensive context from Linear issues and GitHub PRs
- Analyzes and caches images from tickets/PRs
- Shares context across all sub-agents for consistency
- Automatically triggers code review after implementation

#### Key Features:
- **Massive Parallelization**: Spawns multiple agents to work on different parts simultaneously
- **Smart Context Caching**: `LINEAR-{ISSUE}.md` and `{BRANCH}.md` files persist between runs
- **Deep Research**: Follows all ticket references, subtasks, comments, and linked issues
- **Visual Context**: Analyzes UI mockups, diagrams, and screenshots with WebFetch
- **Efficient Reuse**: Checks for existing context before gathering (saves API calls)
- **Automatic Review**: Triggers `/loop` command after implementation completes

#### Usage:
```
/implement-with-assessment <task description>
/implement-with-assessment --refresh <task description>  # Force refresh cached context
```

**Note**: This is an experimental command under active development. Behavior may change.

### Plan Mode Handling

When plan mode is active:
- The state machine defers CREATE_TASK_MD until after plan approval
- Upon plan approval, immediately creates TASK.md before starting implementation
- This ensures the code review process always has documented requirements, even when starting from plan mode

## Task Documentation Requirement

Before implementing any coding task, agents must create `code-reviews/TASK.md` documenting:
- Original user request (exact wording)
- Approved plan/approach
- Explicit scope and constraints
- What is NOT included in the task

This ensures the decision-helper can evaluate suggestions against original requirements.

## Verdict Matrix Logic

The review outcome is determined by a truth table:

| Code Review    | Decision Helper | Action                           |
|----------------|-----------------|----------------------------------|
| APPROVED       | APPROVED        | EXIT_LOOP                        |
| APPROVED       | NEEDS_REVISION  | IMPLEMENT_CRITICAL_ONLY (≥7)     |
| NEEDS_REVISION | APPROVED        | SKIP_REVISIONS (out of scope)   |
| NEEDS_REVISION | NEEDS_REVISION  | IMPLEMENT_CRITICAL_ONLY (≥7)     |

Decision-helper has authority to override code review when suggestions are out of scope.

## Score-Based Implementation Rules

```yaml
score >= 7.0: IMPLEMENT (mandatory)
score 4.0-6.9: DEFER_TO_ESCALATIONS
score < 4.0: SKIP
```

Every suggestion receives a 0-10 relevance score from the decision-helper. Implementation is deterministic based on these thresholds with no discretion allowed.

## Git Safety Guidelines

- **NEVER use `git add -A`** - Always add files explicitly to avoid staging sensitive files
- Review changes with `git status` before staging
- Add files individually by name
- Ensure .gitignore properly excludes sensitive files