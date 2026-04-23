#!/bin/sh
# pre-tool-confirm.sh — Bring terminal to foreground when Claude needs permission confirmation
# Trigger: PreToolUse (all tools), filtered by this script
# Behavior: If the tool call is NOT in the allow list, bring window to foreground
# Inspired by claude-notifications-go: always exit 0, never block Claude

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS_FILE="$SCRIPT_DIR/../settings.local.json"
FOREGROUND_PS1="$SCRIPT_DIR/lib/win32-foreground.ps1"
LOG_FILE="$SCRIPT_DIR/pre-tool-confirm.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log "=== pre-tool-confirm started ==="

# Write stdin to a temp file to avoid shell escaping issues with JSON
TEMP_INPUT=$(mktemp 2>/dev/null || echo "/tmp/hook-input-$$")
cat > "$TEMP_INPUT" 2>/dev/null || true

# Wait for file to be written
sleep 0.1 2>/dev/null || true

# Debug: save full raw input for analysis
cp "$TEMP_INPUT" "$SCRIPT_DIR/_debug-last-input.json" 2>/dev/null || true
log "Raw input saved to _debug-last-input.json"

# Log tool info from input (use the same PYTHON_CMD we'll detect below, try python first)
TOOL_INFO=$(python -c "
import json, sys
try:
    with open(sys.argv[1], 'r', encoding='utf-8') as f:
        d = json.load(f)
    tool = d.get('tool_name', '?')
    cmd = d.get('tool_input', {}).get('command', '') if isinstance(d.get('tool_input'), dict) else ''
    print(tool + ' | ' + cmd[:80])
except Exception as e:
    print('? | parse-error: ' + str(e))
" "$TEMP_INPUT" 2>/dev/null || echo "? | python-failed")
log "Tool: $TOOL_INFO"

# Detect available Python command (python3 may be a Windows Store stub on Windows)
PYTHON_CMD=""
for cmd in python3 python py; do
    if command -v "$cmd" >/dev/null 2>&1; then
        # Verify it actually works (Windows Store stub exits with code 49)
        if "$cmd" --version >/dev/null 2>&1; then
            PYTHON_CMD="$cmd"
            log "Python found: $cmd"
            break
        else
            log "Python candidate '$cmd' found but --version failed (likely Windows Store stub)"
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    log "WARNING: No working Python found!"
fi

EXIT_CODE=1
if [ -n "$PYTHON_CMD" ]; then
    "$PYTHON_CMD" "$SCRIPT_DIR/lib/check-permission.py" "$SETTINGS_FILE" "$TEMP_INPUT" 2>>"$LOG_FILE"
    EXIT_CODE=$?
    log "Permission check exit code: $EXIT_CODE (0=allowed, 1=need-confirm)"
fi

# Clean up temp file
rm -f "$TEMP_INPUT" 2>/dev/null || true

# If matched (exit 0), do nothing
if [ "$EXIT_CODE" -eq 0 ]; then
    log "Tool is allowed, no action needed"
    exit 0
fi

# Not in allow list — bring window to foreground
log "Tool NOT in allow list, triggering foreground..."
if [ -f "$FOREGROUND_PS1" ]; then
    FOREGROUND_WIN_PATH=$(cygpath -w "$FOREGROUND_PS1" 2>/dev/null || echo "$FOREGROUND_PS1")
    log "Calling PowerShell foreground: $FOREGROUND_WIN_PATH"
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$FOREGROUND_WIN_PATH" 2>>"$LOG_FILE"
else
    log "WARNING: win32-foreground.ps1 not found at $FOREGROUND_PS1"
fi

exit 0
