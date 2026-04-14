#!/bin/bash
# skill-gate.sh — Unified PostToolUse hook for skill output validation
# Routes to specific checkers based on file path patterns
# Input: JSON via stdin from Claude Code

INPUT=$(cat)
PATH=$(echo "$INPUT" | node -e "
let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
  try{const j=JSON.parse(d);const inp=j.tool_input||{};process.stdout.write(inp.file_path||inp.path||'');}catch{process.stdout.write('')}
})")

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GATE_OUTPUT=""

# Route to specific validators
# Only trigger for paths under source directories (src/, lib/, app/, frontend/, etc.)
# Skip doc/, .claude/, docs-learning/ to avoid false positives

IS_SRC_PATH=$(echo "$PATH" | grep -cE "(^|.*/)(src|lib|app|frontend|packages|services|modules)/" 2>/dev/null || echo 0)

if echo "$PATH" | grep -qE "(impl-plans|03-plan)"; then
  OUTPUT=$(echo "$INPUT" | bash "$SCRIPT_DIR/check-impl-planner.sh" 2>/dev/null)
  if [ -n "$OUTPUT" ]; then
    GATE_OUTPUT="$OUTPUT"
  fi
fi

if [ "$IS_SRC_PATH" -gt 0 ] && echo "$PATH" | grep -qE "(__tests__|tests/)"; then
  OUTPUT=$(echo "$INPUT" | bash "$SCRIPT_DIR/check-code-tester.sh" 2>/dev/null)
  if [ -n "$OUTPUT" ]; then
    GATE_OUTPUT="$GATE_OUTPUT $OUTPUT"
  fi
fi

if echo "$PATH" | grep -qE "04-report"; then
  OUTPUT=$(echo "$INPUT" | bash "$SCRIPT_DIR/check-code-implementer.sh" 2>/dev/null)
  if [ -n "$OUTPUT" ]; then
    GATE_OUTPUT="$GATE_OUTPUT $OUTPUT"
  fi
fi

# Output gate result if any
if [ -n "$GATE_OUTPUT" ]; then
  # If multiple outputs, concatenate them into a single JSON
  echo "$GATE_OUTPUT" | head -1
fi

exit 0
