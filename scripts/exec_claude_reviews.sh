#!/usr/bin/env bash
set -euo pipefail

claude -p < ~/.claude/prompts/specialized/simple-review-low.md --model sonnet  --effort low &
LOW_PID=$!

claude -p < ~/.claude/prompts/specialized/simple-review-medium.md --model sonnet  --effort medium &
MEDIUM_PID=$!

claude -p < ~/.claude/prompts/specialized/simple-review-high.md --model sonnet --effort high &
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
