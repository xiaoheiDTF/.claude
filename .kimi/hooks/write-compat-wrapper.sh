#!/bin/sh
# write-compat-wrapper.sh — 将 Kimi CLI 工具名映射为 Claude Code 兼容格式
# 作用: 让依赖 Claude Code 工具名（Write/Edit/Read）的钩子能在 Kimi CLI 下正常工作
# 用法: cat input.json | sh .claude/kimi/hooks/write-compat-wrapper.sh <original_hook_path>

if [ -z "$1" ]; then
    echo "Usage: $0 <original_hook_path>" >&2
    exit 1
fi

ORIGINAL_HOOK="$1"

# 读取 stdin 并转换工具名
COMPATIBLE=$(python -c "
import json, sys
try:
    d = json.load(sys.stdin)
    tn = d.get('tool_name', '')
    # Kimi CLI → Claude Code 工具名映射
    mapping = {
        'WriteFile': 'Write',
        'StrReplaceFile': 'Edit',
        'ReadFile': 'Read',
    }
    if tn in mapping:
        d['tool_name'] = mapping[tn]
    json.dump(d, sys.stdout)
except Exception:
    sys.stdout.write(sys.stdin.read())
" 2>/dev/null || cat)

echo "$COMPATIBLE" | sh "$ORIGINAL_HOOK"
