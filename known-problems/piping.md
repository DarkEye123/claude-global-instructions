# Piped Commands Permission Issue

## Problem
Claude Code does not honor allowed permissions when commands are combined using pipes (`|`), `&&`, or `;` operators, even if both individual commands are already allowed in settings.json.

## Example
Command that triggers unnecessary permission request:
```bash
gh pr view --json baseRefName 2>/dev/null | jq -r '.baseRefName // empty'
```

Even with both `"Bash(gh:*)"` and `"Bash(jq:*)"` in allowed permissions, the piped combination requires approval.

## GitHub Issue
Tracked as: [#1271 - Respect `allowed-tools` when using combined / piped tool commands](https://github.com/anthropics/claude-code/issues/1271)

## Workarounds

### 1. Split Commands (Recommended)
Instead of:
```bash
command1 | command2
```

Use:
```bash
command1 > temp_file.txt
command2 < temp_file.txt
rm temp_file.txt
```

### 2. Use Temporary Files
```bash
# Instead of: gh pr view --json baseRefName | jq -r '.baseRefName'
gh pr view --json baseRefName > /tmp/pr_info.json
jq -r '.baseRefName // empty' /tmp/pr_info.json
rm /tmp/pr_info.json
```

### 3. Dangerous Skip Mode (Not Recommended)
```bash
claude --dangerously-skip-permissions
```

### 4. Allow All Bash (Very Risky)
Add `"Bash(*)"` to permissions - this bypasses all bash permission checks.

## Impact
This particularly affects Claude 4 as it tends to use more piped commands for parsing output, making workflows less efficient.

## Status
- **Reported**: Yes
- **Fixed**: No (as of 2025-08-22)
- **Severity**: Medium - affects workflow but has workarounds