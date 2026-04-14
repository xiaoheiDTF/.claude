#!/bin/bash
# protect-sensitive.sh — PreToolUse hook: block edits to sensitive files
# Prevents accidental modification of .env, credentials, secrets, etc.
# Input: JSON via stdin from Claude Code
# Exit code 2 = block the operation

INPUT=$(cat)

# Extract tool name and file path
RESULT=$(echo "$INPUT" | node -e "
let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
  try{
    const j=JSON.parse(d);
    const tool=j.tool_name||'';
    const inp=j.tool_input||{};
    const fp=inp.file_path||inp.path||'';
    process.stdout.write(tool+'|'+fp);
  }catch{process.stdout.write('|')}
})" 2>/dev/null)

TOOL=$(echo "$RESULT" | cut -d'|' -f1)
FILE_PATH=$(echo "$RESULT" | cut -d'|' -f2-)

# Only check write operations
case "$TOOL" in
  Edit|Write|NotebookEdit) ;;
  *) exit 0 ;;
esac

# Sensitive file patterns (case-insensitive check)
case "$(echo "$FILE_PATH" | tr '[:upper:]' '[:lower:]')" in
  *.env|*.env.*|.env|.env.*)
    echo "{\"decision\":\"block\",\"reason\":\"[protect] 拒绝编辑环境变量文件 ($FILE_PATH)。如需修改，请手动编辑。\"}" >&2
    exit 2
    ;;
  *credential*|*secret*|*token*|*apikey*|*api_key*)
    echo "{\"decision\":\"block\",\"reason\":\"[protect] 拒绝编辑敏感文件 ($FILE_PATH)。如需修改，请手动编辑。\"}" >&2
    exit 2
    ;;
  *id_rsa*|*id_ed25519*|*id_ecdsa*|*.pem|*.key|*.p12|*.jks)
    echo "{\"decision\":\"block\",\"reason\":\"[protect] 拒绝编辑密钥文件 ($FILE_PATH)。如需修改，请手动编辑。\"}" >&2
    exit 2
    ;;
esac

exit 0
