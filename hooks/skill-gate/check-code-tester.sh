#!/bin/bash
# check-code-tester.sh — Post-write validation for code-tester outputs
# Input: JSON via stdin

INPUT=$(cat)
TOOL=$(echo "$INPUT" | node -e "
let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
  try{const j=JSON.parse(d);process.stdout.write(j.tool_name||'');}catch{process.stdout.write('')}
})")
PATH=$(echo "$INPUT" | node -e "
let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
  try{const j=JSON.parse(d);const inp=j.tool_input||{};process.stdout.write(inp.file_path||inp.path||'');}catch{process.stdout.write('')}
})")

if [ "$TOOL" != "Write" ]; then
  exit 0
fi

# Detect test file writes in test/ subdirectory
if echo "$PATH" | grep -qE "/test/(test_|.*\.test\.)"; then
  # Infer the mirror path in .claude/module-test/
  PROJECT_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
  REL_PATH=$(echo "$PATH" | sed "s|$PROJECT_DIR/||")
  MIRROR_PATH="$PROJECT_DIR/.claude/module-test/$REL_PATH"

  if [ ! -f "$MIRROR_PATH" ]; then
    echo "{\"additionalContext\": \"[skill-gate] 检测到测试文件 $REL_PATH 已写入，但未在 .claude/module-test/ 中找到镜像备份。请立即运行 module-test 同步。\"}"
    exit 1
  fi
fi

exit 0
