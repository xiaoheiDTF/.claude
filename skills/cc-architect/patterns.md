# CC 配置常见模式和最佳实践

## 一、典型项目配置组合

### 小型项目（个人开发）

```
CLAUDE.md                          ← 项目概述 + 技术栈
.claude/rules/coding.md            ← 编码规范（无条件）
.claude/rules/testing.md           ← 测试规范（条件 paths）
.claude/settings.local.json        ← 权限配置
```

### 中型项目（小团队）

```
CLAUDE.md                          ← 项目概述 + 架构
.claude/rules/
  ├── coding-standards.md          ← 编码规范
  ├── commit-convention.md         ← 提交规范
  ├── frontend.md                  ← 前端条件规则
  ├── backend.md                   ← 后端条件规则
  └── testing.md                   ← 测试条件规则
.claude/agents/
  ├── code-reviewer.md             ← 代码审查
  └── test-writer.md               ← 测试编写
.claude/settings.json              ← Hooks + 权限
.claude/hooks/
  ├── pre-edit.sh
  └── post-edit.sh
```

### 大型项目（Monorepo）

```
CLAUDE.md                          ← 全局架构 + 约定
.claude/rules/                     ← 多维度条件规则
  ├── frontend.md                  ← paths: "apps/web/**"
  ├── backend.md                   ← paths: "apps/api/**"
  ├── shared.md                    ← paths: "packages/**"
  ├── database.md                  ← paths: "**/prisma/**"
  └── infra.md                     ← paths: "docker*, k8s/**"
.claude/agents/                    ← 专职 Agent
  ├── code-reviewer.md
  ├── test-writer.md
  ├── db-admin.md
  └── api-designer.md
.claude/commands/                  ← 团队共享命令
  ├── deploy.md
  └── review.md
.claude/settings.json              ← 完整配置
apps/web/CLAUDE.md                 ← Web 子项目指令
apps/api/CLAUDE.md                 ← API 子项目指令
services/auth/CLAUDE.md            ← Auth 服务指令
```

---

## 二、Agent 设计模式

### 模式 1：审查者（只读分析）

```
特点：disallowedTools: [Write, Edit, NotebookEdit]
场景：代码审查、架构分析、安全扫描
输出：结构化报告，不修改任何文件
模型：sonnet（速度和质量的平衡）
omitClaudeMd：true（节省 token）
```

### 模式 2：实现者（全工具）

```
特点：tools: [Read, Write, Edit, Grep, Glob, Bash]
场景：功能实现、重构、文件生成
约束：明确的工作流程和输出要求
模型：sonnet 或 inherit
effort：high
```

### 模式 3：搜索者（信息收集）

```
特点：tools: [Read, Grep, Glob]，无写权限
场景：代码搜索、依赖分析、调用链追踪
输出：文件列表 + 分析结论
模型：haiku（简单快速）或 sonnet
```

### 模式 4：编排者（流程管理）

```
特点：有 Bash 权限 + 文件读写
场景：CI/CD、部署、环境搭建
约束：严格按步骤执行，每步确认
maxTurns：限制轮次防止失控
```

---

## 三、Hook 常见组合模式

### 模式 1：编辑即格式化

```json
PostToolUse + matcher: "Edit|Write" + prettier/eslint --fix
```

适合所有有代码格式化需求的项目。

### 模式 2：编辑即暂存

```json
PostToolUse + matcher: "Edit|Write" + git add
```

适合希望 Claude 编辑后自动 stage 的项目。

### 模式 3：安全防护

```json
PreToolUse + matcher: "Edit|Write" + 检查敏感文件
```

适合有敏感文件（.env、密钥等）的项目。

### 模式 4：自动提交

```json
SubagentStop + matcher: "" + git add + git commit
```

适合 Agent 完成后需要自动提交的场景。

---

## 四、Rule 设计原则

### 1. 粒度控制

```
好的 Rule：
  - 每个文件一个关注点
  - 5-15 条规则
  - 具体、可执行

坏的 Rule：
  - 一个文件包含所有规则
  - 50+ 条规则
  - 模糊、抽象
```

### 2. 条件 vs 无条件

```
能用 paths 限定的 → 用条件规则（省 token）
  例：前端规范只在编辑 frontend/ 文件时加载

所有场景都要的 → 用无条件规则
  例：提交规范、TypeScript strict mode
```

### 3. Rule vs CLAUDE.md

```
CLAUDE.md：项目概述、架构、目录结构（上下文信息）
Rules：具体规范、约束、约定（行为指令）
```

---

## 五、工具权限最佳实践

### 最小权限原则

| Agent 角色 | 必要工具 | 禁止工具 |
|-----------|---------|---------|
| 审查者 | Read, Grep, Glob | Write, Edit |
| 实现者 | Read, Write, Edit, Grep, Glob, Bash | — |
| 搜索者 | Read, Grep, Glob | Write, Edit, Bash |
| DB 管理 | Read, Write, Edit, Bash | Agent |

### 全局权限建议

```json
{
  "allow": [
    "Bash(git log*)",
    "Bash(git diff*)",
    "Bash(git status*)",
    "Read",
    "Glob",
    "Grep"
  ],
  "deny": [
    "Bash(rm -rf*)"
  ]
}
```

---

## 六、常见错误和避坑

1. **不要在 Agent 中放业务逻辑** — Agent 定义是配置文件，不是代码文件
2. **description 不要太长** — 它只是告诉主 Agent "何时调用你"，1-2 句话
3. **paths 不要用绝对路径** — 相对于 .claude 的父目录
4. **Hook 命令注意引号嵌套** — JSON 里嵌 JSON 时转义容易出错
5. **修改 settings.json 要先读** — 不要覆盖已有配置
6. **Agent 命名要有意义** — `code-reviewer` 比 `agent1` 好
7. **条件规则不要加太多 paths** — 太宽泛等于无条件规则，浪费 token
8. **omitClaudeMd 只用于只读 Agent** — 需要理解项目上下文的 Agent 不要省略
9. **Hook 脚本注意 Windows 兼容** — 跨平台项目使用 `shell: "powershell"` 或确保 bash 语法兼容
10. **deny 是最终安全底线** — deny 的优先级高于 allow，不可被任何配置绕过
11. **Hooks 是合并不是覆盖** — 不能通过项目配置"禁用"全局 Hook，需在脚本中条件判断
12. **Agent 的 Stop 自动转为 SubagentStop** — 在 Agent frontmatter 中写 Stop 也会正确触发
13. **background Agent 工具池受限** — 后台 Agent 只能使用 ASYNC_AGENT_ALLOWED_TOOLS 子集
14. **Hook stdout 必须是有效 JSON** — 非 JSON 输出会被忽略，用 stderr 做调试输出
15. **maxTurns 先小后大** — 先设较小值试探，根据截断报告决定后续策略
16. **Skill 的 ```! ``` 代码块不能使用 $VAR 变量** — `$CLAUDE_SKILL_DIR`、`$ARGUMENTS` 等变量在 ```! ``` 块中会导致 "Contains simple_expansion" 权限检查错误。**替代方案**：在 SKILL.md 正文中写文字指令（如"第零步"），让 Claude 用 Bash 工具执行脚本
17. **Skill 的 ```! ``` 代码块不能包含复杂 shell 命令** — 多条件 if/for 循环、多重管道等复杂语法会导致 "Unhandled node type: string" 权限检查错误。**替代方案**：把复杂命令写到 `.sh` 脚本文件中，SKILL.md 里用文字指令指示 Claude 调用

---

## 七、生产级配置模板

### 场景 1：前端团队

```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep", "Bash(git*)", "Bash(npm test*)", "Bash(npm run lint*)", "Bash(npm run build*)"],
    "deny": ["Bash(rm -rf*)", "Bash(npm publish*)", "Bash(git push --force*)"],
    "defaultMode": "acceptEdits"
  },
  "agentModel": "sonnet"
}
```

### 场景 2：后端/数据库团队

```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep", "Bash(git*)", "Bash(npx prisma*)", "Bash(docker compose*)", "Bash(curl localhost*)"],
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

### 场景 3：安全审计（严格只读）

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

### 场景 4：CI/CD 自动化

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

---

## 八、Hook 组合模式详解

### 防御性安全链

```
PreToolUse (matcher: "Edit|Write")
  → 检查敏感文件 (.env, credentials) → deny
  → 检查生产目录 → ask
  → 其他 → allow

PostToolUse (matcher: "Edit|Write")
  → eslint --fix + prettier --write (async)
  → git add (async)

SubagentStop (matcher: "")
  → git add -A && git commit (async)
```

### 智能上下文注入

```
UserPromptSubmit (matcher: "")
  → 自动注入：git branch + 最近提交 + 未提交变更
  → 检测关键词 "数据库"/"API" → 加载相关上下文
  → 过滤敏感信息（API Key、密码）

SessionStart (matcher: "")
  → 显示项目信息、环境检查
```

### Agent 全生命周期管理

```
SubagentStart → 加载项目上下文（schema 版本、依赖状态）
PreToolUse → 阻止危险操作（双重安全保障）
PostToolUse → 自动 lint + format + 暂存（async）
PreCompact → 保存进度和关键发现
SubagentStop → 自动提交 + 触发 CI/CD
```

---

## 九、Rule 编写进阶

### paths 模式速查

```yaml
# 1. 精确扩展名
paths: "src/**/*.d.ts"          # 只匹配 .d.ts

# 2. 花括号展开
paths: "{apps/web,apps/mobile}/src/**"  # 多应用联合

# 3. 取反（排除测试文件）
paths:
  - "src/**"
  - "!src/**/*.test.*"
  - "!src/**/*.spec.*"

# 4. 深层嵌套
paths: "**/proto/**"            # 匹配任意深度

# 5. 逗号分隔（等价于列表）
paths: "packages/ui/**, packages/components/**"
```

### 多规则叠加示例

当用户编辑 `apps/web/src/components/Button.tsx` 时，以下规则**同时生效**：

```
✓ .claude/rules/coding-standards.md     （无条件，始终加载）
✓ .claude/rules/commit-convention.md     （无条件，始终加载）
✓ .claude/rules/frontend.md              （paths: "apps/web/**"，匹配）
✓ .claude/rules/testing.md               （不匹配，非测试文件）
✗ .claude/rules/backend.md               （不匹配，非后端文件）
```

### @include 引用技巧

```markdown
<!-- 在 Rule 中引用类型定义 -->
操作 API 路由时请遵循类型约束：@./docs/api-types.ts

<!-- 在 CLAUDE.md 中引用共享规范 -->
共享编码规范见 @./.claude/rules/shared.md

<!-- 引用 Prisma Schema 获取数据模型上下文 -->
当前数据模型：@./prisma/schema.prisma
```

最大嵌套 5 层，支持 60+ 文本格式。

---

## 十、Skill 设计模式

### 模式 1：独立工具型

```
特点：单一职责，无上下游依赖
场景：git-push、trace-call-chain、code-tester
结构：SKILL.md + 辅助脚本
输出：直接在对话中输出或写入指定目录
```

### 模式 2：流水线节点型

```
特点：有上下游依赖，通过 manifest.json 传递数据
场景：task-breakdown → code-reuse-finder → impl-planner → code-implementer
结构：SKILL.md + list-*.sh 脚本
输出：编号子目录 + manifest.json + README.md（速览卡）
关键：上游 manifest 是下游的输入，必须生成
```

### 模式 3：元技能型（Meta Skill）

```
特点：创建/管理其他配置的技能
场景：cc-architect（本 Skill）
结构：SKILL.md + 知识库文件（cc_prompt.md、templates/、patterns.md）
输出：.claude/ 目录下的配置文件
关键：知识库是 L3 资源，按需读取
```

### 模式 4：知识注入型

```
特点：不执行操作，只注入领域知识
场景：编码规范、测试规范、安全规范
结构：SKILL.md 引用 convention.md
适用：当规则文件不够用时，用 Skill 提供更详细的参考
```

---

## 十点五、Skill 触发控制模式

### 自动/手动触发矩阵

| frontmatter 组合 | 用户 `/name` 手动调用 | 模型自动触发 | 适用场景 |
|------|------|------|------|
| 默认（两字段都不写） | 是 | 是 | 通用技能、低风险知识注入 |
| `disable-model-invocation: true` | 是 | 否 | 有副作用流程（如 deploy、发布、批量改写） |
| `user-invocable: false` | 否（菜单隐藏） | 是 | 背景知识类 Skill |

### 子代理隔离执行

```
context: fork + agent: Explore/Plan/...
```

适合大输出、长流程、需隔离上下文的技能；不适合纯风格提示类 Skill。

---

## 十一、Skill 优化实战模式

### 诊断现有 Skill 问题

```
1. SKILL.md 行数检查 → 超过 500 行 → 拆分
2. description 匹配测试 → 模糊 → 重写
3. 流水线 manifest 检查 → 缺失 → 补充
4. ```! ``` 块检查 → 含变量 → 改文字指令
5. allowed-tools 审计 → 冗余 → 精简
6. 模板占比检查 → 超过 30% → 拆到 reference.md
```

### Skill 瘦身策略

| 胖信号 | 瘦身方法 |
|--------|---------|
| 模板占 SKILL.md 50%+ | 拆到 `reference.md`，SKILL.md 只写"按照 reference.md 中的模板" |
| 规范占 SKILL.md 30%+ | 拆到 `convention.md`，SKILL.md 只写"读取 $CLAUDE_SKILL_DIR/convention.md" |
| 多语言适配代码 | 拆到 `convention.md` 的"框架专属映射"节 |
| 日志/编码策略细节 | 拆到 `convention.md` 的"编码策略"节 |

### 创建团队 Skills 索引

当项目有 5+ 个 Skill 时，创建 `.claude/skills/README.md`：

```markdown
# Team Skills Index

## Skills by Category

| Skill | 一句话用途 | 调用方式 |
|-------|----------|---------|
| ... | ... | ... |

## Recommended Combinations

| 任务类型 | 推荐组合 |
|---------|---------|
| ... | ... |

## Maintenance Rules
- 新增/修改 Skill 后必须更新此索引
```

---

## 十二、Skill 使用技巧

### 技巧 1：参数传递

```
/commit fix login bug           → $ARGUMENTS = "fix login bug"
/code-tester src/utils.ts       → $ARGUMENTS = "src/utils.ts"
/task-breakdown 用户登录功能     → $ARGUMENTS = "用户登录功能"
```

### 技巧 2：流水线串联

```
# 完整开发流水线
/task-breakdown 实现CDP浏览器适配器
  → 生成 doc/ai-coding/.../01-breakdown/

/code-reuse-finder doc/ai-coding/.../01-breakdown/
  → 生成 doc/ai-coding/.../02-reuse/

/impl-planner doc/ai-coding/.../01-breakdown/ doc/ai-coding/.../02-reuse/
  → 生成 doc/ai-coding/.../03-plan/

/code-implementer doc/ai-coding/.../03-plan/
  → 生成 doc/ai-coding/.../04-report/
```

### 技巧 3：Skill + Agent 组合

```
# Skill 作为入口，Agent 提供能力
Skill:
  agent: code-reviewer    ← 指向自定义 Agent
  allowed-tools: [...]    ← Skill 级别工具覆盖

Agent 定义:
  model: sonnet           ← Agent 级别模型控制
  disallowedTools: [...]  ← Agent 级别工具限制
```

### 技巧 4：条件加载

```yaml
# 只在编辑 TypeScript 文件时推荐此 Skill
paths:
  - "**/*.ts"
  - "**/*.tsx"
```

paths 不阻止手动调用，只影响自动推荐。

### 技巧 5：commands 向 skills 迁移

```
旧：.claude/commands/review.md
新：.claude/skills/review/SKILL.md
```

迁移收益：
- 可携带参考文件和脚本目录
- 可使用 `context: fork`、`hooks`、`agent` 等高级字段
- 同名时 Skill 会优先于 command，迁移后可平滑替换

---

## 十三、Hooks 配方模式

### 核心原则：提醒型 → 阻断型渐进升级

```
阶段 1：提醒型（stderr 输出警告，不阻止执行）
  → 验证团队接受后 →
阶段 2：阻断型（exit 2 阻止执行，或 permissionDecision: deny）
```

**不要上来就用阻断型**，先用提醒型建立共识，再升级。

### 配方 1：禁止在 main 分支直接编辑（阻断型）

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "[ \"$(git branch --show-current 2>/dev/null)\" != \"main\" ] || { echo '禁止直接编辑 main 分支，请先创建 feature 分支' >&2; exit 2; }",
        "timeout": 5
      }]
    }]
  }
}
```

### 配方 2：console.log 审计（提醒型）

```bash
#!/bin/bash
# PostToolUse + matcher: "Edit|Write"
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')
if [ -n "$FILE" ] && [[ "$FILE" =~ \.(ts|tsx|js|jsx)$ ]]; then
  LOGS=$(grep -n "console\.log" "$FILE" 2>/dev/null || true)
  if [ -n "$LOGS" ]; then
    echo "[Hook] WARNING: console.log found in $FILE" >&2
    echo "$LOGS" | head -5 >&2
  fi
fi
```

### 配方 3：git push 前强制停顿（提醒型）

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "INPUT=$(cat); CMD=$(echo \"$INPUT\" | jq -r '.tool_input.command // empty'); if echo \"$CMD\" | grep -q 'git push'; then echo '[Hook] 即将执行 git push，请确认已检查变更' >&2; fi"
      }]
    }]
  }
}
```

### 配方 4：修改测试文件后自动运行相关测试（自动化）

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "FILE=$(cat | jq -r '.tool_input.file_path // empty'); if [[ \"$FILE\" =~ \\.test\\.(ts|tsx|js|jsx)$ ]]; then npx vitest related \"$FILE\" --passWithNoTests 2>&1 | tail -20; fi",
        "timeout": 90,
        "async": true
      }]
    }]
  }
}
```

### 配方 5：Prompt 类型 Hook 智能停止判断（Stop 事件）

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "prompt",
        "prompt": "评估 Claude 是否应该停止工作。检查：1) 用户要求的所有任务是否完成 2) 是否有未处理的错误 3) 是否需要后续步骤。返回 JSON：{\"ok\": true} 允许停止，{\"ok\": false, \"reason\": \"具体说明\"} 继续工作。",
        "timeout": 30
      }]
    }]
  }
}
```

适合"Agent 任务完成度检查"，使用 Haiku 模型评估，避免提前停止。

---

## 十四、MCP 配置模式

### 模式 1：项目级固化（推荐团队）

```json
// .mcp.json（提交 VCS，团队共享）
{
  "mcpServers": {
    "postgres": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@bytebase/dbhub", "--dsn", "${DATABASE_URL}"]
    }
  }
}
```

密钥放 `.env`（不提交），使用 `${ENV_VAR}` 占位符引用。

### 模式 2：MCP Tool Search 配置（多 MCP 时必备）

```json
// settings.json 或 settings.local.json
{
  "env": {
    "ENABLE_TOOL_SEARCH": "auto:5"
  }
}
```

同时启用超过 5-8 个 MCP 时建议开启，避免上下文被工具描述挤占。

### 模式 3：Agent 专属 MCP（隔离依赖）

```yaml
# agents/db-admin.md frontmatter
mcpServers:
  - "postgres"            # 引用已配置的 MCP
  - analytics:            # 内联定义（仅此 Agent 可用）
      command: "npx my-analytics-server"
requiredMcpServers:
  - "postgres"            # 必须可用，否则 Agent 拒绝启动
```

### 最佳实践速查

| 原则 | 做法 |
|------|------|
| 数量控制 | 同时启用 ≤ 10 个 MCP |
| 密钥安全 | 用 `${ENV_VAR}` 占位符，不硬编码 |
| 团队共享 | 使用项目级 `.mcp.json` 提交 VCS |
| 个人密钥 | 放 `settings.local.json` 或 `.env` |
| 上下文保护 | 多 MCP 时配置 `ENABLE_TOOL_SEARCH` |

---

## 十五、Skill context:fork 隔离模式

### 何时用 context:fork

```
适合使用 fork：
  ✓ 大量输出（测试日志、全仓扫描、PR diff 分析）
  ✓ 高噪声操作（避免污染主对话上下文）
  ✓ 需要固定 agent 类型和工具边界
  ✓ 注入实时数据（配合 !`command` 动态注入）

不适合使用 fork：
  ✗ 纯背景知识/规范注入类 Skill（得不到有效产出）
  ✗ 需要和主对话频繁交互的 Skill
  ✗ 简单的格式化/风格提示类 Skill
```

### 标准配置模式

```yaml
---
name: pr-analysis
description: 分析 PR 改动，生成摘要和风险清单
context: fork
agent: Explore          # 只读探索代理
allowed-tools: Bash(gh:*), Read, Grep
---

## PR 信息（实时注入）
- 改动文件：!`gh pr diff --name-only`
- PR 描述：!`gh pr view --json title,body`

## 分析任务
基于以上信息给出摘要和风险点。

$ARGUMENTS
```

### agent 选项速查

| agent 值 | 模型 | 工具 | 适用场景 |
|----------|------|------|---------|
| `Explore` | Haiku（快速） | 只读 | 搜索、分析、不需修改 |
| `Plan` | 继承 | 只读 | 规划阶段研究 |
| `general-purpose` | 继承 | 所有 | 复杂多步操作 |
| `<自定义>` | Agent 定义 | Agent 定义 | 指向自定义 Agent |
