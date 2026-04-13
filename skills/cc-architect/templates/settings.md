# Settings.json 配置模板

> 参考 cc_prompt.md 第七节 "settings.json 配置"

## 配置文件位置

```
/etc/claude-code/settings.json       ← 系统管理配置（优先级 1，最低）
~/.claude/settings.json              ← 用户全局配置（优先级 2）
<project>/.claude/settings.json      ← 项目共享（优先级 3，提交 VCS）
<project>/.claude/settings.local.json ← 项目私有（优先级 4，最高，不提交 VCS）
```

- 配置合并：所有层级**合并**，同名字段高优先级覆盖低优先级
- settings.json 适合团队共享（提交 VCS）
- settings.local.json 适合个人偏好（加入 .gitignore）

---

## 完整配置结构

```json
{
  "permissions": {
    "allow": [],
    "deny": [],
    "defaultMode": "default",
    "additionalDirectories": []
  },
  "hooks": {},
  "mcpServers": {},
  "env": {},
  "agentModel": "inherit",
  "theme": "dark",
  "verbose": false
}
```

---

## 模板 1：权限配置

```json
{
  "permissions": {
    "allow": [
      "Bash(git log*)",
      "Bash(git diff*)",
      "Bash(git status*)",
      "Bash(npm test*)",
      "Bash(npm run*)",
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(curl*|*)",
      "Bash(wget*)"
    ],
    "defaultMode": "default"
  }
}
```

### 权限优先级链

```
deny > allow > defaultMode
（deny 是最终安全底线，不可被任何配置绕过）
```

### defaultMode 全选项

| 值 | 说明 | 适用场景 |
|----|------|---------|
| `default` | 每次操作弹出确认（最安全） | 新项目、探索性工作 |
| `acceptEdits` | 自动接受 Edit/Write，Bash 仍需确认 | 日常开发（最平衡） |
| `plan` | 先出计划，用户确认后再执行 | 重构、架构设计 |
| `auto` | 全自动执行 | CI/CD 自动化 |
| `dontAsk` | 自动执行，使用最合适权限 | 低风险可逆任务 |

### additionalDirectories

```json
{
  "permissions": {
    "additionalDirectories": [
      "/shared/packages/core",
      "../libraries/utils",
      "~/projects/shared-configs"
    ]
  }
}
```

- 支持绝对路径和相对路径
- 默认只能访问当前项目目录
- 适用：多项目共享组件库、引用外部配置

---

## 模板 2：MCP 服务器配置

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost:5432/mydb"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "$GITHUB_TOKEN"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"],
      "env": {}
    }
  }
}
```

### 常用 MCP 服务器

| 名称 | 用途 | command |
|------|------|---------|
| `server-postgres` | PostgreSQL 查询 | `npx -y @modelcontextprotocol/server-postgres` |
| `server-github` | GitHub API | `npx -y @modelcontextprotocol/server-github` |
| `server-filesystem` | 文件系统 | `npx -y @modelcontextprotocol/server-filesystem` |
| `server-brave-search` | 网络搜索 | `npx -y @modelcontextprotocol/server-brave-search` |

- Token 通过环境变量传入（安全）
- MCP 在 Claude Code 启动时初始化
- `{}` 空配置可禁用所有 MCP

---

## 模板 3：环境变量

```json
{
  "env": {
    "CLAUDE_CODE_SUBAGENT_MODEL": "sonnet",
    "NODE_ENV": "development"
  }
}
```

### 可用环境变量

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `CLAUDE_CODE_SUBAGENT_MODEL` | 强制所有子 Agent 使用指定模型 | `sonnet` / `haiku` / `opus` |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | 禁用后台任务 | `true` / `false` |
| `CLAUDE_AUTO_BACKGROUND_TASKS` | 启用自动后台 Agent | `true` / `false` |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | 允许 --add-dir 加载 CLAUDE.md | `true` / `false` |
| `CLAUDE_CODE_AGENT_LIST_IN_MESSAGES` | Agent 列表通过消息注入 | `true` / `false` |
| `CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS` | SDK 禁用内置 Agent | `true` / `false` |
| `CLAUDE_CODE_COORDINATOR_MODE` | 启用 Coordinator 模式 | `true` / `false` |

---

## 模板 4：agentModel 与 theme

```json
{
  "agentModel": "sonnet",
  "theme": "system"
}
```

### agentModel

| 值 | 说明 |
|----|------|
| `inherit` | 继承用户当前模型（默认） |
| `sonnet` | 平衡模型（成本 ~Opus 1/5） |
| `opus` | 最强推理 |
| `haiku` | 最便宜（成本 ~Sonnet 1/5） |

### theme

| 值 | 说明 |
|----|------|
| `dark` | 深色主题 |
| `light` | 浅色主题 |
| `system` | 跟随系统设置 |

---

## 模板 5：verbose 调试

```json
{
  "verbose": true
}
```

启用后显示：
- 工具调用的详细参数
- 模型选择的推理过程
- Hook 触发和执行日志
- MCP 服务器通信详情
- 每轮 token 使用统计和预估成本

用途：调试 Hook、排查权限、理解决策过程
生产环境推荐 `false`

---

## 模板 6：生产级场景配置

### 前端团队

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(git*)",
      "Bash(npm test*)",
      "Bash(npm run lint*)",
      "Bash(npm run build*)"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(npm publish*)",
      "Bash(git push --force*)"
    ],
    "defaultMode": "acceptEdits"
  },
  "agentModel": "sonnet"
}
```

### 后端/数据库团队

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(git*)",
      "Bash(npx prisma*)",
      "Bash(docker compose*)",
      "Bash(curl localhost*)"
    ],
    "defaultMode": "default"
  },
  "agentModel": "opus",
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": { "DATABASE_URL": "postgresql://localhost:5432/mydb" }
    }
  }
}
```

### 安全审计（严格只读）

```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep"],
    "deny": ["Edit", "Write", "Bash(*)"],
    "defaultMode": "default"
  },
  "verbose": true
}
```

### CI/CD 自动化

```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep", "Bash(*)"],
    "defaultMode": "auto"
  },
  "agentModel": "haiku",
  "verbose": false
}
```

### 新开发者（学习模式）

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(git log*)",
      "Bash(git diff*)",
      "Bash(git status*)",
      "Bash(npm test*)"
    ],
    "defaultMode": "default"
  },
  "verbose": true
}
```

---

## 修改 settings.json 注意事项

1. **先 Read 再 Edit** — 必须先读取现有内容
2. **增量修改** — 用 Edit 工具修改特定字段，不要整体覆盖
3. **保留已有配置** — 不要删除用户已有的配置项
4. **JSON 格式正确** — 注意逗号、引号、括号匹配
5. **settings.local.json** — 敏感配置（API key、token）放这里，不提交 VCS
6. **合并行为** — 所有层级的配置会合并，不会互相覆盖（除非同名字段）
7. **hooks 是合并不是覆盖** — 项目级 hooks 不会替代全局 hooks，而是合并执行
