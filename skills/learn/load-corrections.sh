#!/bin/bash
# load-corrections.sh — Load unapplied corrections for a specific skill
# Usage: bash load-corrections.sh <skill-name>
# Returns: Correction records with "已修正: 否" status

SKILL_NAME="$1"

if [ -z "$SKILL_NAME" ]; then
  echo "Error: Skill name required" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CORR_FILE="$SCRIPT_DIR/corrections.md"

# Check if corrections file exists
if [ ! -f "$CORR_FILE" ]; then
  exit 0  # No corrections file, silently exit
fi

# Extract corrections for this skill that are not yet applied
# Pattern: ## 对 <skill-name> 的修正
# Look for "已修正: 否" within the next 20 lines

PATTERN="## 对 ${SKILL_NAME} 的修正"

# Use awk to extract blocks
awk -v pattern="$PATTERN" '
BEGIN { in_block=0; block="" }
$0 ~ pattern { in_block=1; block=$0"\n"; next }
in_block && /^## / { 
  # New section starts, check if previous block has "已修正: 否"
  if (block ~ /已修正: 否/) {
    printf "%s\n", block
  }
  block=""
  in_block=0
}
in_block { block=block$0"\n" }
END {
  # Check last block
  if (in_block && block ~ /已修正: 否/) {
    printf "%s", block
  }
}
' "$CORR_FILE"

exit 0
