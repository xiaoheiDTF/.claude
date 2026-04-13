#!/bin/bash
# session-end.sh — Stop hook: semantic pattern detection (v2)
# Detects meaningful signals: skill mismatch, design churn, repeatable patterns
# Input: JSON via stdin from Claude Code

INPUT=$(cat)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TRACK_DIR="$PROJECT_DIR/session-tracking"
PENDING_FILE="$TRACK_DIR/pending-reviews.md"

# Parse session_id
SESSION_ID=$(echo "$INPUT" | node -e "
let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
  try{const j=JSON.parse(d);process.stdout.write(j.session_id||'default')}
  catch{process.stdout.write('default')}
})" 2>/dev/null)

if [ -z "$SESSION_ID" ]; then SESSION_ID="default"; fi

TRACK_FILE="$TRACK_DIR/${SESSION_ID}.track"

# No tracking data — nothing to analyze
if [ ! -f "$TRACK_FILE" ]; then exit 0; fi

TOTAL_CALLS=$(wc -l < "$TRACK_FILE")

# Skip very short sessions
if [ "$TOTAL_CALLS" -lt 5 ]; then
  rm -f "$TRACK_FILE"
  exit 0
fi

FINDINGS=""
CONTEXT_HINTS=""

# ──────────────────────────────────────────────────────────────
# SIGNAL 1: Design Churn — same SKILL file edited 3+ times
# This is meaningful: editing a skill repeatedly = getting it wrong repeatedly
# ──────────────────────────────────────────────────────────────
SKILL_EDITS=$(grep "|Edit|" "$TRACK_FILE" | grep "skills/" | cut -d'|' -f3 | sort | uniq -c | sort -rn)
while IFS= read -r line; do
  COUNT=$(echo "$line" | awk '{print $1}')
  FILE=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ *//')
  SKILL_NAME=$(echo "$FILE" | grep -oP 'skills/\K[^/]+')
  if [ -n "$SKILL_NAME" ] && [ "$COUNT" -ge 3 ]; then
    FINDINGS="${FINDINGS}DESIGN_CHURN: /${SKILL_NAME} SKILL.md edited ${COUNT} times — likely iterated to get it right\n"
    CONTEXT_HINTS="${CONTEXT_HINTS}- /${SKILL_NAME} 的配置在本次会话中反复调整，可能找到了更好的写法，值得固化\n"
  fi
done <<< "$SKILL_EDITS"

# ──────────────────────────────────────────────────────────────
# SIGNAL 2: Business file rework — same non-skill file edited 3+ times
# Indicates real rework, not just Skill configuration
# ──────────────────────────────────────────────────────────────
BUSINESS_EDITS=$(grep "|Edit|" "$TRACK_FILE" | grep -v "skills/" | grep -v "\.claude/" | cut -d'|' -f3 | sort | uniq -c | sort -rn)
while IFS= read -r line; do
  COUNT=$(echo "$line" | awk '{print $1}')
  FILE=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ *//')
  SHORT_FILE=$(basename "$FILE")
  if [ -n "$SHORT_FILE" ] && [ "$COUNT" -ge 3 ]; then
    FINDINGS="${FINDINGS}REWORK: ${SHORT_FILE} edited ${COUNT} times — potential design issue or repeated corrections\n"
    CONTEXT_HINTS="${CONTEXT_HINTS}- ${SHORT_FILE} 被反复修改 ${COUNT} 次，可能有值得记录的"怎么避免这类返工"的经验\n"
  fi
done <<< "$BUSINESS_EDITS"

# ──────────────────────────────────────────────────────────────
# SIGNAL 3: Repeatable pattern — same Grep→Read→Edit sequence 3+ times
# Meaningful: could be automated into a Skill
# Only count meaningful chains, not just totals
# ──────────────────────────────────────────────────────────────
GREP_COUNT=$(grep -c "|Grep|" "$TRACK_FILE" 2>/dev/null || echo 0)
READ_COUNT=$(grep -c "|Read|" "$TRACK_FILE" 2>/dev/null || echo 0)
EDIT_COUNT=$(grep -c "|Edit|" "$TRACK_FILE" 2>/dev/null || echo 0)

# Only flag if all three are substantial AND combined > threshold
if [ "$GREP_COUNT" -ge 4 ] && [ "$EDIT_COUNT" -ge 4 ]; then
  FINDINGS="${FINDINGS}AUTOMATABLE: Grep(${GREP_COUNT})+Read(${READ_COUNT})+Edit(${EDIT_COUNT}) — repeated search-and-fix pattern, candidate for new Skill\n"
  CONTEXT_HINTS="${CONTEXT_HINTS}- 反复执行"搜索→读取→修改"的模式，如果是同类任务，可以考虑做成 Skill 一键完成\n"
fi

# ──────────────────────────────────────────────────────────────
# SIGNAL 4: Skill usage with lots of writes afterward
# Indicates a Skill produced something that needed heavy fixing
# ──────────────────────────────────────────────────────────────
# Look for Skill invocations followed by 5+ edits (proxy for "Skill output was wrong")
SKILL_CALLS=$(grep "|Skill|" "$TRACK_FILE" 2>/dev/null | wc -l)
if [ "$SKILL_CALLS" -ge 1 ] && [ "$EDIT_COUNT" -ge 5 ]; then
  RATIO=$((EDIT_COUNT / SKILL_CALLS))
  if [ "$RATIO" -ge 5 ]; then
    FINDINGS="${FINDINGS}SKILL_MISMATCH: ${SKILL_CALLS} Skill call(s) followed by ${EDIT_COUNT} edits — Skill output may not match expectations\n"
    CONTEXT_HINTS="${CONTEXT_HINTS}- Skill 调用后进行了大量手动修改，说明 Skill 输出与预期有偏差，值得用 /learn 修正\n"
  fi
fi

# ──────────────────────────────────────────────────────────────
# Output
# ──────────────────────────────────────────────────────────────
if [ -n "$FINDINGS" ]; then
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
  {
    echo ""
    echo "## Session $(date '+%Y%m%d-%H%M%S')"
    echo "> Time: ${TIMESTAMP} | Total tool calls: ${TOTAL_CALLS}"
    echo ""
    echo -e "$FINDINGS"
    if [ -n "$CONTEXT_HINTS" ]; then
      echo "### 可能值得记录的经验："
      echo -e "$CONTEXT_HINTS"
    fi
    echo "---"
  } >> "$PENDING_FILE"

  # Compact message to Claude — semantic, actionable
  SUMMARY=$(echo -e "$FINDINGS" | head -3 | tr '\n' ' | ')
  echo "{\"additionalContext\": \"[auto-learn] 会话模式分析: ${SUMMARY}详见 .claude/session-tracking/pending-reviews.md\"}"
fi

# Cleanup
rm -f "$TRACK_FILE"
exit 0
