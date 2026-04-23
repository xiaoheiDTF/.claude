#!/bin/sh
# pre-tool-confirm.sh — Bring terminal to foreground when permission dialog appears
# Trigger: PermissionRequest (only fires when Claude needs user permission)
# No permission checking needed — Claude Code already decided this needs confirmation

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FOREGROUND_PS1="$SCRIPT_DIR/lib/win32-foreground.ps1"
LOG_FILE="$SCRIPT_DIR/pre-tool-confirm.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Consume stdin (hook input JSON) and log tool info
TOOL_INFO=$(python -c "
import json, sys
try:
    d = json.load(sys.stdin)
    tool = d.get('tool_name', '?')
    cmd = d.get('tool_input', {}).get('command', '') if isinstance(d.get('tool_input'), dict) else ''
    print(tool + ' | ' + cmd[:80])
except Exception as e:
    print('? | ' + str(e))
" 2>/dev/null || echo "? | python-failed")

log "PermissionRequest: $TOOL_INFO"

# Bring window to foreground
if [ -f "$FOREGROUND_PS1" ]; then
    FOREGROUND_WIN_PATH=$(cygpath -w "$FOREGROUND_PS1" 2>/dev/null || echo "$FOREGROUND_PS1")
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$FOREGROUND_WIN_PATH" 2>>"$LOG_FILE"
else
    log "WARNING: win32-foreground.ps1 not found"
fi

exit 0
