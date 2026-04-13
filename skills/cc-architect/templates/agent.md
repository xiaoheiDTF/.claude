# Agent 配置模板

> 参考 cc_prompt.md 第三节 "Agents（自定义 Agent）"

## 最小 Agent（只读分析型）

```markdown
---
description: <一句话描述，告诉主 Agent 何时调用>
disallowedTools:
  - Write
  - Edit
  - NotebookEdit
model: sonnet
omitClaudeMd: true
---

<Agent 的行为指令>

## 规则
- <规则 1>
- <规则 2>

## 输出格式
<定义输出格式>
```

**适用场景**：代码审查、分析报告、代码搜索等不需要修改文件的任务。
**关键**：`omitClaudeMd: true` 节省约 90% token（~5000 → ~0），因为只读 Agent 不需要项目上下文。

---

## 标准开发 Agent

```markdown
---
description: <一句话描述>
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
model: sonnet
effort: high
maxTurns: 20
permissionMode: acceptEdits
---

<Agent 的行为指令>

## 工作流程
1. <步骤 1>
2. <步骤 2>
3. <步骤 3>

## 关键约束
- <约束 1>
- <约束 2>
```

**适用场景**：代码实现、重构、文件生成等需要写文件的任务。

---

## 带持久化记忆的 Agent

```markdown
---
description: <一句话描述>
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
model: sonnet
memory: project
---

<Agent 的行为指令>

## 记忆使用
- 首次运行时创建记忆文件记录项目关键信息
- 后续运行时先读取记忆，基于历史上下文工作
```

**适用场景**：需要跨会话积累知识的 Agent（如 DB 管理、API 设计）。

| memory scope | 路径 | 是否提交 VCS |
|-------------|------|------------|
| `user` | `~/.claude/agent-memory/<agentType>/MEMORY.md` | 否 |
| `project` | `.claude/agent-memory/<agentType>/MEMORY.md` | 是 |
| `local` | `.claude/agent-memory-local/<agentType>/MEMORY.md` | 否 |

---

## 带专属 Hook 的 Agent

```markdown
---
description: <一句话描述>
tools:
  - Read
  - Write
  - Edit
  - Bash
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: |
            INPUT=$(cat)
            FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
            if [[ "$FILE" == *.ts ]]; then
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

<Agent 的行为指令>
```

**适用场景**：需要自动化后处理（lint、提交、通知）的 Agent。

---

## 后台隔离 Agent

```markdown
---
description: <一句话描述>
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
model: sonnet
background: true
isolation: worktree
maxTurns: 30
---

<Agent 的行为指令>
```

**适用场景**：独立的大型任务，不影响主工作区。如实验性重构、大规模代码生成、A/B 对比方案。

**注意**：`background: true` 工具池受限为 `ASYNC_AGENT_ALLOWED_TOOLS` 子集。

---

## 带 MCP 和 requiredMcpServers 的 Agent

```markdown
---
description: Database migration specialist
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
model: sonnet
memory: project
mcpServers:
  - "postgres"                      # 引用已配置的 MCP
  - analytics:                      # 内联定义
      command: "npx"
      args: ["-y", "my-analytics-server"]
requiredMcpServers:
  - "postgres"                      # 必须可用，否则 Agent 拒绝启动
---

You manage database schemas and migrations.

## Rules
- Always read the current schema before suggesting changes
- Migration files must be reversible (include down migration)
- Never drop columns without a deprecation period
```

**适用场景**：依赖外部服务的 Agent（数据库、K8s、监控）。

---

## 带 initialPrompt 和 skills 的 Agent

```markdown
---
description: Automated deployment specialist
tools:
  - Read
  - Bash
  - Grep
  - Glob
model: sonnet
permissionMode: acceptEdits
maxTurns: 15
initialPrompt: "/deploy"
skills:
  - "commit"
  - "deploy"
---

You handle automated deployment workflows.
Ensures every deployment follows the standard pipeline.
```

**适用场景**：需要自动启动标准流程的 Agent，`initialPrompt` 确保每次运行从相同状态开始。

---

## Agent 字段速查

| 字段 | 推荐值 | 何时使用 |
|------|--------|---------|
| `model` | `sonnet` | 大多数场景；`haiku` 用于简单任务；`opus` 用于复杂推理 |
| `effort` | `high` | 需要高质量输出；`medium` 用于快速任务；`low` 用于格式化/简单修复 |
| `omitClaudeMd` | `true` | 只读 Agent，节省 ~90% token |
| `memory` | `project` | 需要跨会话记忆，团队共享 |
| `maxTurns` | `20-30` | 功能开发；`5-8` 用于简单查询；`50` 用于大规模任务 |
| `background` | `true` | 不需要用户实时交互的长时间任务 |
| `isolation` | `worktree` | 需要隔离环境，失败可丢弃 |
| `permissionMode` | `acceptEdits` | 日常开发；`default` 用于高风险操作 |
| `disallowedTools` | Write, Edit | 只读 Agent 必须设置 |
| `skills` | `["<skill>"]` | 需要预加载指定 Skills 时使用 |
| `hooks` | `PreToolUse/PostToolUse/...` | 仅 Agent 生命周期内生效的局部 Hook |

### permissionMode 速查

| 值 | 行为 |
|------|------|
| `default` | 标准权限检查 |
| `acceptEdits` | 自动接受文件编辑，命令仍需权限策略判定 |
| `plan` | 规划模式（偏只读） |
| `dontAsk` | 自动拒绝权限提示 |
| `bypassPermissions` | 跳过权限检查（高风险，仅受控环境使用） |

### 模型成本参考

| 模型 | 相对成本 | 适用场景 |
|------|---------|---------|
| `haiku` | 1x | 简单搜索、格式化、快速修复 |
| `sonnet` | 5x | 日常开发、代码审查、功能实现 |
| `opus` | 25x | 安全审计、架构分析、复杂推理 |
| `inherit` | 跟随用户 | 不确定时使用，自动适配 |

## Agent 命名建议

文件名即 Agent 类型名，建议：
- `{功能}-{角色}` 格式，如 `code-reviewer`、`test-writer`
- 简短有意义，不要超过 3 个单词
- 全小写，用短横线连接

## Agent 文件位置与优先级

| 位置 | 路径 | 作用范围 |
|------|------|---------|
| CLI 临时注入 | `claude --agents '<json>'` | 当前会话（最高） |
| 全局 | `~/.claude/agents/*.md` | 所有项目生效 |
| 项目级 | `<project>/.claude/agents/*.md` | 当前项目 |
| 子目录级 | `<subdir>/.claude/agents/*.md` | 子目录范围 |
| 插件 | `<plugin>/agents/*.md` | 启用该插件的项目（最低） |

同名覆盖：CLI > 子目录级 > 项目级 > 全局级 > 插件。不同名全部加载。
