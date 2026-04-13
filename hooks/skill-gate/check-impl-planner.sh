#!/bin/bash
# check-impl-planner.sh — Post-write validation for impl-planner outputs

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

# Check if manifest.json is written when impl-planner completes
if echo "$PATH" | grep -qE "03-plan/manifest\.json$"; then
  PLAN_DIR=$(dirname "$PATH")

  # Validate required files exist
  MISSING=""
  for f in README.md ACCEPTANCE.md manifest.json; do
    if [ ! -f "$PLAN_DIR/$f" ]; then
      MISSING="$MISSING $f"
    fi
  done

  if [ -n "$MISSING" ]; then
    echo "{\"additionalContext\": \"[skill-gate] impl-planner 的 03-plan 缺少必需文件:$MISSING，请补全后再交给下游 Skill\"}"
    exit 1
  fi
fi

exit 0
