#!/bin/sh
# pre-tool-confirm.sh — Bring terminal to foreground when Claude needs permission confirmation
# Trigger: PreToolUse (all tools), filtered by this script
# Behavior: If the tool call is NOT in the allow list, bring window to foreground
# Inspired by claude-notifications-go: always exit 0, never block Claude

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS_FILE="$SCRIPT_DIR/../settings.local.json"
FOREGROUND_PS1="$SCRIPT_DIR/lib/win32-foreground.ps1"

# Write stdin to a temp file to avoid shell escaping issues with JSON
TEMP_INPUT=$(mktemp 2>/dev/null || echo "/tmp/hook-input-$$")
cat > "$TEMP_INPUT" 2>/dev/null || true

# Detect available Python command (python3 may be a Windows Store stub on Windows)
PYTHON_CMD=""
for cmd in python3 python py; do
    if command -v "$cmd" >/dev/null 2>&1; then
        # Verify it actually works (Windows Store stub exits with code 49)
        if "$cmd" --version >/dev/null 2>&1; then
            PYTHON_CMD="$cmd"
            break
        fi
    fi
done

EXIT_CODE=1
if [ -n "$PYTHON_CMD" ]; then
    "$PYTHON_CMD" "$SCRIPT_DIR/lib/check-permission.py" "$SETTINGS_FILE" "$TEMP_INPUT" 2>/dev/null
    EXIT_CODE=$?
fi

# Clean up temp file
rm -f "$TEMP_INPUT" 2>/dev/null || true

# If matched (exit 0), do nothing
if [ "$EXIT_CODE" -eq 0 ]; then
    exit 0
fi

# Not in allow list — bring window to foreground
if [ -f "$FOREGROUND_PS1" ]; then
    FOREGROUND_WIN_PATH=$(cygpath -w "$FOREGROUND_PS1" 2>/dev/null || echo "$FOREGROUND_PS1")
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$FOREGROUND_WIN_PATH" 2>/dev/null &
fi

exit 0
