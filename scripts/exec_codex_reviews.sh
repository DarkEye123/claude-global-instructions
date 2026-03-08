#!/usr/bin/env bash
set -euo pipefail

claude exec < ~/.claude/prompts/specialized/simple-review-low.md -m gpt-5.3-claude --sandbox workspace-write -c model_reasoning_effort=low &
LOW_PID=$!

claude exec < ~/.claude/prompts/specialized/simple-review-medium.md -m gpt-5.3-claude --sandbox workspace-write -c model_reasoning_effort=medium &
MEDIUM_PID=$!

claude exec < ~/.claude/prompts/specialized/simple-review-high.md -m gpt-5.3-claude --sandbox workspace-write -c model_reasoning_effort=high &
HIGH_PID=$!

wait "$HIGH_PID"

LOW_STATUS=0
MEDIUM_STATUS=0
wait "$LOW_PID" || LOW_STATUS=$?
wait "$MEDIUM_PID" || MEDIUM_STATUS=$?

if [ $LOW_STATUS -ne 0 ]; then
  echo "low effort agent exited with status $LOW_STATUS" >&2
fi

if [ $MEDIUM_STATUS -ne 0 ]; then
  echo "medium effort agent exited with status $MEDIUM_STATUS" >&2
fi

if [ $LOW_STATUS -ne 0 ] || [ $MEDIUM_STATUS -ne 0 ]; then
  exit 1
fi
