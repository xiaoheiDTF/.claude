#!/bin/bash
# check-code-implementer.sh — Post-write validation for code-implementer outputs
# Input: JSON via stdin with {tool_name, file_path, session_id}

INPUT=$(cat)
TOOL=$(echo "$INPUT" | node -e "
let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
  try{const j=JSON.parse(d);process.stdout.write(j.tool_name||'');}catch{process.stdout.write('')}
})")
PATH=$(echo "$INPUT" | node -e "
let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
  try{const j=JSON.parse(d);const inp=j.tool_input||{};process.stdout.write(inp.file_path||inp.path||'');}catch{process.stdout.write('')}
})")

# Only check on Write operations
if [ "$TOOL" != "Write" ]; then
  exit 0
fi

# Check if this is a report directory file (code-implementer output signal)
if echo "$PATH" | grep -qE "04-report/(README|REPORT|implementation-log)\.md$"; then
  REPORT_DIR=$(dirname "$PATH")
  ERRORS=0

  # Check implementation-log exists
  if [ ! -f "$REPORT_DIR/implementation-logs" ] && [ ! -d "$REPORT_DIR/implementation-logs" ]; then
    # It's a directory, check if any log file exists
    LOG_COUNT=$(find "$REPORT_DIR" -name "implementation-logs" -type d 2>/dev/null | wc -l)
    if [ "$LOG_COUNT" -eq 0 ]; then
      echo "{\"additionalContext\": \"[skill-gate] code-implementer 报告已生成但未发现 implementation-logs 目录，请检查是否遗漏了执行日志\"}"
      ERRORS=$((ERRORS+1))
    fi
  fi

  if [ "$ERRORS" -gt 0 ]; then
    exit 1
  fi
fi

exit 0
