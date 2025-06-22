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
- Requires structured context handover to prevent misleading reviews
- Uses checkpoint commits before implementing feedback
- Creates `/code-review-X.md` documentation
- Focuses on security, performance, and best practices

### Important Instruction Reminders
- Preference for editing over creating files
- Avoiding unnecessary documentation creation
- Doing exactly what's asked, nothing more or less

### Subdirectory-Specific Instructions
- Framework for assessing when specialized CLAUDE.md files are needed
- 1-10 recommendation scale based on complexity and uniqueness
- Helps maintain focused guidance for specific areas of complex codebases
- Avoids duplication while providing contextual assistance

## How to Use

1. Clone this repository to your local machine
2. Copy the `CLAUDE.md` file to your project's root directory or `.claude` folder
3. Configure global settings in `~/.claude/settings.json`
4. Use Claude Code aliases for different permission levels:
   - `claude-edit` - Allow file edits without prompts
   - `claude-dev` - Full development mode
   - `claude-safe` - Default permissions
   - `claude-readonly` - Investigation only
   - `claude-full` - Skip all permissions (use carefully!)

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

## Contributing

Feel free to fork this repository and customize the instructions for your specific needs. The framework is designed to be extensible while maintaining core principles of accuracy and quality.