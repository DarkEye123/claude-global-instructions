# Claude AI Global Instructions

This repository contains global instructions for Claude AI that apply across all projects and devices.

## Overview

The `CLAUDE.md` file in this repository provides consistent guidance and frameworks for Claude AI when assisting with software development tasks. By placing this file in your projects, you ensure consistent behavior and adherence to best practices.

## What's Included

### Truthfulness Framework
- Ensures Claude verifies file existence before making claims
- Requires exact code copying from files
- Mandates running commands to check actual state
- Promotes transparency when uncertain

### Automatic Code Review Process
- **MANDATORY** for ALL changes (code, docs, configs, even typos)
- **Iterative review loop** continues until both code review and decision-helper approve
- **Decision-helper agent** evaluates suggestions against original task requirements (0-10 scoring)
- **User notification required** at each step of the review process
- Requires structured context handover to prevent misleading reviews
- Uses checkpoint commits before implementing feedback
- Creates `code-reviews/code-review-X.md` and `code-reviews/decision-helper-X.md` documentation for each iteration
- **Creates `code-reviews/code-review-X-implementation.md`** documenting which suggestions were implemented/skipped with reasoning and decision scores
- **Creates `code-reviews/possible-escalations-X.md`** for valid suggestions outside original scope
- Focuses on security, performance, and best practices while maintaining task focus

### Important Instruction Reminders
- Preference for editing over creating files
- Avoiding unnecessary documentation creation
- Doing exactly what's asked, nothing more or less

### Subdirectory-Specific Instructions
- Framework for assessing when specialized CLAUDE.md files are needed
- 1-10 recommendation scale based on complexity and uniqueness
- Helps maintain focused guidance for specific areas of complex codebases
- Avoids duplication while providing contextual assistance

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

## Code Review Context Handover

The enhanced code review process requires structured context to prevent "sidetracking":
- Session context and original user request
- Files modified with reasoning
- Key decisions and code patterns followed
- Testing considerations and blockers

This approach is inspired by the HANDOVER.md pattern for session continuity.

## Task Documentation Requirement

Before implementing any coding task, agents must create `code-reviews/TASK.md` documenting:
- Original user request (exact wording)
- Approved plan/approach
- Explicit scope and constraints
- What is NOT included in the task

This ensures the decision-helper can evaluate suggestions against original requirements.

## Iterative Review Loop

The review process is iterative and continues until approval:
1. Create code-reviews/TASK.md with requirements
2. Implement changes
3. Code review evaluates for quality
4. Decision-helper evaluates against original task (0-10 scoring)
5. Implement critical suggestions (7+ score)
6. Repeat until both agents return APPROVED

Exit criteria:
- Code review returns APPROVED or APPROVED with optional suggestions
- Decision-helper returns APPROVED or APPROVED with optional suggestions
- All critical issues (7+ scores) are addressed

## Implementation Decision Documentation

After each review iteration, agents must document their implementation decisions:
- **What was implemented**: With decision-helper scores and reasoning
- **What was not implemented**: With scores and justification
- **What was deferred to escalations**: Valid suggestions outside original scope

This creates a transparent record of decision-making across all iterations.

## Git Safety Guidelines

- **NEVER use `git add -A`** - Always add files explicitly to avoid staging sensitive files
- Review changes with `git status` before staging
- Add files individually by name
- Ensure .gitignore properly excludes sensitive files