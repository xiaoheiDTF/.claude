#!/bin/sh
# notification-adapter.sh — 将 Kimi CLI Notification 事件适配为 Claude Code PermissionRequest 格式
# 作用: 让 .claude/hooks/pre-tool-confirm.sh 在 Kimi CLI 下也能正常工作
# Kimi CLI 的 Notification(permission_prompt) 事件对应 Claude Code 的 PermissionRequest 事件

CLAUDE_HOOK=".claude/hooks/pre-tool-confirm.sh"

# 读取 Kimi CLI Notification 输入
INPUT=$(cat)

# 将 Notification 格式转换为 pre-tool-confirm.sh 期望的格式
# pre-tool-confirm.sh 需要: tool_name, tool_input.command
COMPATIBLE=$(python -c "
import json, sys
try:
    d = json.load(sys.stdin)
    # 添加兼容字段，避免原脚本解析失败
    d.setdefault('tool_name', 'Notification')
    d.setdefault('tool_input', {})
    if isinstance(d.get('tool_input'), dict):
        title = d.get('title', '')
        body = d.get('body', '')
        d['tool_input'].setdefault('command', f'{title}: {body}' if title or body else 'permission request')
    json.dump(d, sys.stdout)
except Exception:
    sys.stdout.write(sys.stdin.read())
" 2>/dev/null || echo "$INPUT")

echo "$COMPATIBLE" | sh "$CLAUDE_HOOK"
