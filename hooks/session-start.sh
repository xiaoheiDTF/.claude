#!/bin/bash
# session-start.sh — SessionStart hook: check pending reviews from last session
# Reads pending-reviews.md and injects as additionalContext if it exists

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PENDING_FILE="$PROJECT_DIR/doc/session-tracking/pending-reviews.md"

# No pending reviews — silent exit
if [ ! -f "$PENDING_FILE" ]; then
  exit 0
fi

# Read first 20 lines (avoid flooding context)
CONTENT=$(head -20 "$PENDING_FILE")

if [ -n "$CONTENT" ]; then
  # Escape for JSON
  ESCAPED=$(echo "$CONTENT" | node -e "
  let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
    process.stdout.write(JSON.stringify(d.trim()))
  })" 2>/dev/null)

  echo "{\"additionalContext\": \"[session-start] 上次会话检测到以下模式，请在对话初期主动提及：\\n${ESCAPED}\"}"
fi

exit 0
