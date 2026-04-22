#!/bin/sh
# task-complete-notify.sh — Bring terminal to foreground + show notification when Claude finishes
# Trigger: Stop event
# Behavior: Always bring window to foreground and show a completion notification
# Inspired by claude-notifications-go: always exit 0, never block Claude

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FOREGROUND_PS1="$SCRIPT_DIR/lib/win32-foreground.ps1"

# Convert to Windows path BEFORE passing to PowerShell
WIN_PATH=$(cygpath -w "$FOREGROUND_PS1" 2>/dev/null || echo "$FOREGROUND_PS1")

# Step 1: Bring window to foreground first (synchronous, fast)
if [ -f "$FOREGROUND_PS1" ]; then
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$WIN_PATH" 2>/dev/null || true
fi

# Step 2: Show notification (non-blocking toast, won't steal focus from terminal)
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null

    \$template = @'
<toast>
  <visual>
    <binding template='ToastGeneric'>
      <text>Claude Code</text>
      <text>Task completed.</text>
    </binding>
  </visual>
  <audio silent='true'/>
</toast>
'@

    try {
        \$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        \$xml.LoadXml(\$template)
        \$toast = [Windows.UI.Notifications.ToastNotification]::new(\$xml)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code').Show(\$toast)
    } catch {
        # Fallback: balloon tip style notification
        Add-Type -AssemblyName System.Windows.Forms
        \$notify = New-Object System.Windows.Forms.NotifyIcon
        \$notify.Icon = [System.Drawing.SystemIcons]::Information
        \$notify.Visible = \$true
        \$notify.ShowBalloonTip(3000, 'Claude Code', 'Task completed.', [System.Windows.Forms.ToolTipIcon]::Info)
        Start-Sleep -Milliseconds 3500
        \$notify.Dispose()
    }
" 2>/dev/null &

exit 0
