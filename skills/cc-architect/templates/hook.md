# Hook 配置模板

> 参考 cc_prompt.md 第四节 "Hooks（生命周期钩子）"

## Hook 事件速查

| 事件 | 触发时机 | matcher 匹配对象 | stdin 特有字段 |
|------|---------|-----------------|---------------|
| `PreToolUse` | 工具执行前 | 工具名 | `tool_name`, `tool_input` |
| `PostToolUse` | 工具执行成功后 | 工具名 | + `tool_output`, `tool_result` |
| `PostToolUseFailure` | 工具执行失败后 | 工具名 | + `error` |
| `PermissionRequest` | 弹出权限对话框时 | 工具名 | `tool_name`, `tool_input` |
| `UserPromptSubmit` | 用户提交消息 | 来源 (api/cli) | `source`, `prompt` |
| `SessionStart` | 会话启动 | 来源 | `source` |
| `SessionEnd` | 会话结束 | 退出原因 | `reason` |
| `Setup` | 初始化/维护模式触发 | `init` / `maintenance` | `trigger` |
| `Stop` | Agent 停止 | — | — |
| `SubagentStart` | 子 Agent 启动 | — | — |
| `SubagentStop` | 子 Agent 停止 | — | — |
| `PreCompact` | 上下文压缩前 | — | — |
| `PostCompact` | 上下文压缩后 | — | — |
| `Notification` | 收到通知 | — | — |

## Hook 类型速查

| 类型 | 适用场景 | stdout 控制 |
|------|---------|-----------|
| `command` | 执行 shell 命令 | JSON（permissionDecision/additionalContext） |
| `prompt` | 注入提示词 | 无（只影响 Claude 行为） |
| `agent` | 启动子 Agent | 无（子 Agent 独立运行） |
| `http` | 调用外部 API | 无（发送请求） |

---

## 模板 1：编辑后自动格式化

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | { read -r f; prettier --write \"$f\"; } 2>/dev/null || true",
            "async": true,
            "statusMessage": "Formatting..."
          }
        ]
      }
    ]
  }
}
```

---

## 模板 2：编辑后自动 git add

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path // .tool_input.path // empty' | { read -r f; if [ -n \"$f\" ] && [ -f \"$f\" ]; then git add \"$f\" 2>/dev/null; echo \"{\\\"additionalContext\\\": \\\"Staged: $f\\\"}\"; fi; }",
            "async": true,
            "statusMessage": "Auto-staging..."
          }
        ]
      }
    ]
  }
}
```

---

## 模板 3：编辑前安全检查

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-edit-check.sh",
            "statusMessage": "Security check..."
          }
        ]
      }
    ]
  }
}
```

配套脚本 `.claude/hooks/pre-edit-check.sh`：

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# 检查是否编辑敏感文件
case "$FILE_PATH" in
  *.env|*.secret|*credentials*|*token*)
    echo '{"permissionDecision": "deny", "permissionDecisionReason": "拒绝编辑敏感文件"}'
    ;;
  *node_modules*|*.git/*)
    echo '{"permissionDecision": "deny", "permissionDecisionReason": "拒绝编辑系统目录"}'
    ;;
  *production*|*prod*)
    echo '{"permissionDecision": "ask", "permissionDecisionReason": "生产环境文件需要确认"}'
    ;;
esac
```

---

## 模板 4：Agent 完成后自动提交

```json
{
  "hooks": {
    "SubagentStop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "FILES=$(git diff --name-only); if [ -n \"$FILES\" ]; then git add -A && git commit -m \"chore: automated by agent\" && echo '{\"additionalContext\": \"Auto-committed\"}'; fi",
            "async": true
          }
        ]
      }
    ]
  }
}
```

---

## 模板 5：会话启动时环境检查

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"additionalContext\": \"Node: '\"$(node -v 2>/dev/null || echo 'N/A')\"', Git branch: '\"$(git branch --show-current 2>/dev/null || echo 'N/A')\"'\"}'",
            "statusMessage": "Checking environment..."
          }
        ]
      }
    ]
  }
}
```

---

## 模板 6：工具失败后智能恢复

```json
{
  "hooks": {
    "PostToolUseFailure": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/on-failure.sh",
            "statusMessage": "Analyzing failure..."
          }
        ]
      }
    ]
  }
}
```

配套脚本 `.claude/hooks/on-failure.sh`：

```bash
#!/bin/bash
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
ERROR=$(echo "$INPUT" | jq -r '.error')
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# 记录错误日志
echo "[$(date)] $TOOL failed on $FILE: $ERROR" >> .claude/error-log.txt

# 权限错误：建议替代方案
if echo "$ERROR" | grep -qi "permission\|access\|denied"; then
  echo "{\"additionalContext\": \"Permission error. Try using a local directory or check file permissions.\"}"
fi
```

---

## 模板 7：PermissionRequest 自动决策

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/permission-gate.sh"
          }
        ]
      }
    ]
  }
}
```

`permission-gate.sh` 输出示例：

```json
{
  "decision": "allow"
}
```

可选值：`allow` / `deny` / `pass`

---

## 模板 8：用户消息注入上下文

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"additionalContext\": \"Branch: '\"$(git branch --show-current 2>/dev/null)\"', Uncommitted: '\"$(git status --porcelain 2>/dev/null | wc -l)\"' files\"}'",
            "async": true
          }
        ]
      }
    ]
  }
}
```

---

## 模板 9：Agent 专属 Hook（在 frontmatter 中定义）

```markdown
---
description: TypeScript developer with auto-lint and auto-commit
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: |
            INPUT=$(cat)
            FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
            if [[ "$FILE" == *.ts || "$FILE" == *.tsx ]]; then
              npx eslint --fix "$FILE" 2>/dev/null
              echo "{\"additionalContext\": \"Linted: $FILE\"}"
            fi
          async: true
  SubagentStop:
    - matcher: ""
      hooks:
        - type: command
          command: |
            FILES=$(git diff --name-only)
            if [ -n "$FILES" ]; then
              git add -A
              git commit -m "feat: automated by agent"
              echo '{"additionalContext": "Auto-committed"}'
            fi
          async: true
---

You write TypeScript code...
```

---

## Hook 编写要点

1. **matcher 语法**：用 `|` 分隔多个工具名，如 `"Edit|Write"`；空字符串 `""` 匹配所有
2. **stdin 输入**：command hook 通过 stdin 接收 JSON，用 `jq` 解析
3. **stdout 输出**：
   - `PreToolUse`：`permissionDecision`（allow/deny/ask）+ `updatedInput`（修改参数）
   - `PostToolUse` / `PostToolUseFailure`：`additionalContext`（注入给 Claude 的额外信息）
   - **必须输出有效 JSON**，非 JSON 输出会被忽略
   - stderr 用于调试输出
4. **async: true**：不阻塞主流程，适合格式化、暂存等操作
5. **asyncRewake: true**：后台完成后重新唤醒 Agent（区别于纯 async）
6. **once: true**：只执行一次后自动移除，适合一次性设置（当前仅 Skill hooks 支持）
7. **timeout**：对可能耗时的操作设置超时（秒），防止卡死
8. **Windows 兼容**：默认 bash，Windows 上可用 `"shell": "powershell"`
9. **文件路径提取**：需要处理 `.file_path` 和 `.path` 两种字段名
10. **退出码约定**：
   - `0`：正常
   - `2`：阻断/拒绝（如 PreToolUse、PermissionRequest）
   - 其他：非阻断错误（通常仅记录/提示）

## Hook 配置位置与合并

```
~/.claude/settings.json              → 全局 hooks
<project>/.claude/settings.json      → 项目 hooks
<project>/.claude/settings.local.json → 项目私有 hooks
```

- **合并执行**：同一事件的所有来源 Hook 都会执行（不是覆盖）
- 执行顺序：全局 → 项目 → 项目私有
- Agent 专属 hooks（frontmatter）在全局 hooks 之后执行
- 不能通过项目配置"禁用"全局 Hook，需在脚本中做条件判断

## 注意事项

- Hook 命令中引号转义要小心，JSON 内嵌套 JSON 时注意转义
- 修改 settings.json 的 hooks 时必须保留已有配置（先 Read → Edit 增量修改）
- Hook 脚本必须有执行权限（`chmod +x`）
- 测试 Hook 时先用简单命令验证，确认无误后再用复杂逻辑
- Agent 的 `Stop` hook 会自动转换为 `SubagentStop`
- Hook 脚本建议使用 `$CLAUDE_PROJECT_DIR` 定位项目根目录，避免硬编码路径
- SessionStart 适合轻量初始化；一次性/重型初始化更适合 `Setup`

---

## 模板 10：PermissionRequest 自动决策

在权限弹窗触发时自动决策，无需用户手动确认：

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/permission-gate.sh"
          }
        ]
      }
    ]
  }
}
```

`permission-gate.sh` 示例（自动放行安全命令）：

```bash
#!/bin/bash
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# 放行安全的只读命令
if echo "$CMD" | grep -qE "^(git (log|status|diff|show)|cat |ls |find |grep )"; then
  echo '{"decision": "allow"}'
  exit 0
fi

# 其余走正常权限弹窗
echo '{"decision": "pass"}'
```

输出值：`"allow"` 直接放行 / `"deny"` 拒绝 / `"pass"` 走正常弹窗

---

## 模板 11：Setup Hook（项目初始化）

使用 `--init` 或 `--maintenance` 启动时触发，适合一次性重型初始化（不要放进 SessionStart）：

```json
{
  "hooks": {
    "Setup": [
      {
        "matcher": "init",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/project-init.sh"
          }
        ]
      }
    ]
  }
}
```

`project-init.sh` 示例：

```bash
#!/bin/bash
INPUT=$(cat)
TRIGGER=$(echo "$INPUT" | jq -r '.trigger')

if [ "$TRIGGER" = "init" ]; then
  # 安装依赖、初始化数据库、生成配置等一次性操作
  echo "正在初始化项目环境..." >&2
  npm install 2>/dev/null
  echo "初始化完成" >&2
fi
```

`trigger` 取值：`init`（来自 `--init`/`--init-only`）/ `maintenance`（来自 `--maintenance`）

---

## 模板 12：Prompt 类型 Hook（LLM 智能评估）

使用 Haiku 模型判断是否应该停止，适合 `Stop` 事件：

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "你正在评估 Claude 是否应该停止工作。分析对话内容并判断：1) 用户请求的所有任务是否完成 2) 是否有未处理的错误 3) 是否有待确认的后续步骤。\n\n返回 JSON：{\"ok\": true} 允许停止，或 {\"ok\": false, \"reason\": \"具体原因\"} 让 Claude 继续工作。",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

LLM 必须返回 `{"ok": true}` 或 `{"ok": false, "reason": "..."}` 格式，否则默认允许停止。

---

## 模板 13：SessionStart + CLAUDE_ENV_FILE 环境变量持久化

会话启动时向 Claude 注入环境变量，并持久化到 `CLAUDE_ENV_FILE`：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-setup.sh",
            "statusMessage": "Setting up environment..."
          }
        ]
      }
    ]
  }
}
```

`session-setup.sh` 示例：

```bash
#!/bin/bash
INPUT=$(cat)

# 持久化环境变量（写入 CLAUDE_ENV_FILE，会话内持久生效）
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo "export NODE_ENV=development" >> "$CLAUDE_ENV_FILE"
  echo "export API_BASE_URL=http://localhost:3000" >> "$CLAUDE_ENV_FILE"
fi

# 向 Claude 注入上下文（additionalContext）
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
NODE_VER=$(node -v 2>/dev/null || echo "N/A")

echo "{\"additionalContext\": \"Branch: $BRANCH, Node: $NODE_VER\"}"
```

`CLAUDE_ENV_FILE` 说明：由 CC 注入的临时文件路径，写入此文件的 `export VAR=VAL` 在会话内持久有效。

---

## Hook 输出 JSON 完整字段参考

```json
{
  // 通用字段（所有 Hook 均可返回，exit 0 时生效）
  "continue": true,                 // false = 中止后续处理
  "stopReason": "说明原因",          // continue: false 时向用户展示
  "suppressOutput": false,          // true = 隐藏 stdout（不影响执行）
  "systemMessage": "警告提示",       // 向用户显示的信息

  // PreToolUse 专属
  "permissionDecision": "allow",    // allow / deny / ask
  "permissionDecisionReason": "...", // 决策说明（可选）
  "updatedInput": { "file_path": "/new/path" }, // 修改工具输入参数

  // PostToolUse / PostToolUseFailure 专属
  "additionalContext": "暂存完成",   // 注入给 Claude 的额外上下文

  // PermissionRequest 专属
  "decision": "allow"               // allow / deny / pass
}
```
