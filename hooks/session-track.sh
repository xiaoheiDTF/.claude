#!/bin/sh
# session-track.sh — PostToolUse hook: lightweight tool usage tracker
# Records each tool call to a session-specific file for pattern detection
# Input: JSON via stdin from Claude Code
# Inspired by claude-notifications-go: always exit 0, never block Claude

INPUT=$(cat)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TRACK_DIR="$PROJECT_DIR/doc/session-tracking"
mkdir -p "$TRACK_DIR" 2>/dev/null || true

# Parse JSON via Node.js process.stdin (works on Windows)
RESULT=$(echo "$INPUT" | node -e "
let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
  try{
    const j=JSON.parse(d);
    const tool=j.tool_name||'';
    const sid=j.session_id||'default';
    const inp=j.tool_input||{};
    const fp=inp.file_path||inp.path||inp.command||'';
    process.stdout.write(tool+'|'+sid+'|'+fp);
  }catch{process.stdout.write('|default|')}
})" 2>/dev/null || echo "|default|")

if [ -z "$RESULT" ]; then
  RESULT="|default|"
fi

TOOL=$(echo "$RESULT" | cut -d'|' -f1)
SESSION_ID=$(echo "$RESULT" | cut -d'|' -f2)
FILE_PATH=$(echo "$RESULT" | cut -d'|' -f3-)

TIMESTAMP=$(date +%s 2>/dev/null || echo "0")

# Append tool usage record: TIMESTAMP|TOOL|FILE_PATH
echo "${TIMESTAMP}|${TOOL}|${FILE_PATH}" >> "$TRACK_DIR/${SESSION_ID}.track" 2>/dev/null || true

# Keep file size reasonable (last 500 entries only)
if [ -f "$TRACK_DIR/${SESSION_ID}.track" ]; then
  LINES=$(wc -l < "$TRACK_DIR/${SESSION_ID}.track" 2>/dev/null || echo "0")
  if [ "$LINES" -gt 500 ]; then
    tail -500 "$TRACK_DIR/${SESSION_ID}.track" > "$TRACK_DIR/${SESSION_ID}.track.tmp" 2>/dev/null || true
    mv "$TRACK_DIR/${SESSION_ID}.track.tmp" "$TRACK_DIR/${SESSION_ID}.track" 2>/dev/null || true
  fi
fi

exit 0
