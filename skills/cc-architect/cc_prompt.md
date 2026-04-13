# Claude Code 用户自定义完全指南

> 基于源码分析，涵盖所有用户可自定义的功能：Rules、Agents、Hooks、Skills、Settings。

---

## 目录

- [一、文件位置总览](#一文件位置总览)
- [二、Rules（规则文件）](#二rules规则文件)
- [三、Agents（自定义 Agent）](#三agents自定义-agent)
- [四、Hooks（生命周期钩子）](#四hooks生命周期钩子)
- [五、Agent 专属 Hooks](#五agent-专属-hooks)
- [六、Skills（技能/斜杠命令）](#六skills技能斜杠命令)
- [七、settings.json 配置](#七settingsjson-配置)
- [八、Memory（记忆系统）](#八memory记忆系统)
- [九、环境变量](#九环境变量)
- [十、用户可主动使用的方法](#十用户可主动使用的方法)

---

## 一、文件位置总览

```
用户全局目录 (~/.claude/)
├── CLAUDE.md                          全局个人指令（所有项目生效）
├── settings.json                      全局配置（hooks、权限、MCP 等）
├── rules/                             全局规则目录
│   ├── coding-style.md                无条件规则（始终生效）
│   └── python.md                      无条件规则
├── agents/                            全局自定义 Agent
│   ├── code-reviewer.md               自定义 Agent 定义
│   └── test-writer.md
├── commands/                          全局斜杠命令（Skills）
│   └── commit.md                      /commit 命令
├── skills/                            全局技能
│   └── refactor.md
├── agent-memory/                      Agent 持久化记忆（user scope）
│   └── code-reviewer/MEMORY.md
└── memory/                            用户自动记忆（auto memory）

项目目录 (<project>/)
├── CLAUDE.md                          项目全局指令（团队共享，提交 VCS）
├── CLAUDE.local.md                    项目私有指令（不提交 VCS）
├── .claude/
│   ├── settings.json                  项目级配置
│   ├── settings.local.json            项目私有配置（不提交 VCS）
│   ├── rules/                         项目级规则
│   │   ├── general.md                 无条件规则
│   │   ├── frontend.md                条件规则（paths 匹配）
│   │   ├── backend.md                 条件规则
│   │   └── testing.md                 条件规则
│   ├── agents/                        项目级自定义 Agent
│   │   ├── db-admin.md
│   │   └── api-designer.md
│   ├── commands/                      项目级斜杠命令
│   ├── skills/                        项目级技能
│   └── hooks/                         Hook 脚本文件
│       ├── pre-edit.sh
│       └── post-edit.sh
├── apps/
│   ├── web/
│   │   ├── CLAUDE.md                  子目录指令（按需加载）
│   │   ├── .claude/rules/             子目录级规则
│   │   └── src/
│   │       └── components/
│   │           └── CLAUDE.md          更深层指令
│   └── api/
│       └── CLAUDE.md
└── services/
    ├── auth/CLAUDE.md
    └── order/CLAUDE.md
```

### 优先级规则

```
加载顺序（从低到高）        优先级
─────────────────────────────────
Managed (/etc/claude-code/)    1  最低
User (~/.claude/)              2
Project (<project>/CLAUDE.md)  3
子目录 CLAUDE.md               4  越深越高
Local (CLAUDE.local.md)        5  最高

后加载的优先级更高，模型更关注后面的内容。
同名 Agent：后注册的覆盖先注册的。
```

---

## 二、Rules（规则文件）

### 2.1 两种规则

| 类型 | 有 `paths` frontmatter | 加载时机 | 适用场景 |
|------|----------------------|---------|---------|
| 无条件规则 | 无 | 启动时全量加载 | 通用规范 |
| 条件规则 | 有 | 操作匹配文件时按需注入 | 特定场景规范 |

### 2.2 文件位置

```bash
~/.claude/rules/*.md                    # 全局规则（所有项目）
<project>/.claude/rules/*.md            # 项目规则
<project>/<subdir>/.claude/rules/*.md   # 子目录规则
```

### 2.3 无条件规则

无 `paths` 的规则文件，启动时始终加载。

```markdown
# 文件: .claude/rules/coding-standards.md

- TypeScript strict mode
- 禁止使用 any
- 所有函数必须有返回类型
- 错误必须处理，不允许空 catch
```

### 2.4 条件规则

通过 frontmatter 的 `paths` 指定触发条件。paths 使用 `.gitignore` 语法。

**YAML 列表写法（推荐）**：

```yaml
---
paths:
  - "frontend/**"
  - "packages/ui/**"
---

# 前端开发规范
- React 18 + TypeScript
- 组件库: shadcn/ui
- 样式: Tailwind CSS
```

**逗号分隔写法**：

```yaml
---
paths: "frontend/**, packages/ui/**"
---

前端规范...
```

**花括号展开**：

```yaml
---
paths: "src/*.{ts,tsx}"
---
# 匹配 src/*.ts 和 src/*.tsx
```

```yaml
---
paths: "{apps/web,apps/mobile}/src/**"
---
# 匹配多个应用
```

**注意**：
- `paths` 相对于**该 .md 文件所在的 .claude 目录的父目录**
- `src/**` 等价于 `src`（`/**` 后缀会自动去掉）
- `**` 表示匹配所有（等同于无条件规则）
- 当 agent 使用 Read/Edit/Write 操作匹配文件时自动触发

### 2.5 @include 指令

CLAUDE.md 和 rules 文件支持 `@` 引用其他文件：

```markdown
<!-- 引用相对路径 -->
详细 API 文档见 @./docs/api-guide.md

<!-- 引用项目内路径 -->
共享规范见 @./.claude/rules/shared.md

<!-- 引用绝对路径 -->
@~/shared-configs/base-rules.md
```

支持的格式：`.md` `.txt` `.json` `.yaml` `.ts` `.py` `.sql` 等 60+ 文本格式。
最大嵌套深度：5 层。

### 2.6 paths 高级模式

**取反模式**（以 `!` 开头排除特定路径）：

```yaml
---
paths:
  - "src/**"
  - "!src/**/*.test.*"
  - "!src/**/*.spec.*"
---
# 匹配 src/ 下所有文件，但排除测试文件
```

执行逻辑：先匹配正向规则，再排除取反的路径。可以实现源码规则和测试规则的分离。

**深层嵌套匹配**（`**/` 在开头）：

```yaml
---
paths:
  - "**/proto/**"
  - "**/*.proto"
---
# 匹配任意深度的 proto 目录和 .proto 文件
```

`**/` 表示从项目根目录开始匹配任意层级子目录，无论文件嵌套多深都能匹配到。

**精确扩展名匹配**：

```yaml
---
paths: "src/**/*.d.ts"
---
# 只匹配 .d.ts 文件，不匹配 .ts 或 .tsx
```

**多应用联合匹配**：

```yaml
# 逗号分隔（适合路径较短时）
paths: "packages/ui/**, packages/design-system/**, packages/components/**"

# 等价的 YAML 列表
paths:
  - "packages/ui/**"
  - "packages/design-system/**"
  - "packages/components/**"
```

**注意事项**：
- `paths` 相对于**该 .md 文件所在的 .claude 目录的父目录**
- `src/**` 等价于 `src`（`/**` 后缀会自动去掉）
- `**` 表示匹配所有（等同于无条件规则）
- 当 agent 使用 Read/Edit/Write 操作匹配文件时自动触发
- 多个条件规则可以**同时生效**

### 2.7 多层级规则优先级

```
优先级（从低到高）：
─────────────────────────────────
全局规则 (~/.claude/rules/)       1  最低
项目规则 (<project>/.claude/rules/)  2
子目录规则 (<subdir>/.claude/rules/) 3
托管策略 (/etc/claude-code/)      4  最高
```

- 后加载的优先级更高，高优先级覆盖低优先级同名规则
- 不同名规则全部叠加生效
- 托管策略由 IT 安全团队管理，不可被覆盖
- 子目录规则的 `paths` 相对于其 `.claude` 目录的父目录

### 2.8 企业级场景

**合规规则**（GDPR、PCI-DSS、SOC2）：

```yaml
# .claude/rules/compliance.md（无条件，始终生效）
---
paths:
  - "**/auth/**"
  - "**/payment/**"
  - "**/user/**"
---
- 禁止在日志中记录 PII（个人身份信息）
- 支付数据必须加密存储
- 所有 API 端点必须有认证中间件
```

**Monorepo 多模块规则**：每个子项目可拥有独立的 `.claude/rules/`，通过条件 paths 限定作用范围。

**微服务架构**：每个服务独立规则，通过共享 proto 包和跨服务规则保持一致性。

### 2.6 典型项目 Rules 配置

```
.claude/rules/
├── coding-standards.md          无 paths → 始终生效
├── commit-convention.md         无 paths → 始终生效
├── frontend.md                  paths: "apps/web/**"
├── backend.md                   paths: "apps/api/**"
├── database.md                  paths: "**/db/**","**/prisma/**"
├── testing.md                   paths: "**/*.test.*","**/*.spec.*"
├── security.md                  paths: "**/auth/**","**/middleware/**"
└── infra.md                     paths: "docker-compose.*","Dockerfile*","k8s/**"
```

---

## 三、Agents（自定义 Agent）

### 3.1 文件位置

```bash
~/.claude/agents/*.md              # 全局 Agent
<project>/.claude/agents/*.md      # 项目 Agent
```

### 3.2 Agent 完整定义

文件名即 Agent 类型名（不含 `.md`）。

```markdown
---
# ============ 必填字段 ============
description: Code review specialist that checks security, performance and code quality

# ============ 工具控制 ============
# tools 和 disallowedTools 二选一，也可以组合使用
tools:                             # 允许的工具白名单（可选，省略=全部）
  - Read
  - Grep
  - Glob
  - Bash
disallowedTools:                   # 禁止的工具黑名单（可选）
  - Write
  - Edit
  - Agent

# ============ 模型控制 ============
model: sonnet                      # sonnet | opus | haiku | inherit（默认 inherit）
effort: high                       # high | medium | low

# ============ 权限控制 ============
permissionMode: acceptEdits        # 权限模式（可选）
maxTurns: 30                       # 最大对话轮次（可选）

# ============ 持久化记忆 ============
memory: project                    # user | project | local（可选）

# ============ MCP 服务器 ============
mcpServers:                        # Agent 专属 MCP 服务器（可选）
  - "my-database"                  # 引用已配置的 MCP
  - reviewTools:                   # 内联定义 MCP
      command: "npx my-review-tools"

# ============ 预加载 Skill ============
skills:                            # 预加载的 skill（可选）
  - "commit"
  - "review"

# ============ 生命周期 Hooks ============
hooks:                             # Agent 专属 hooks（可选，见第五节）
  SubagentStop:
    - matcher: ""
      hooks:
        - type: command
          command: "bash .claude/hooks/after-review.sh"

# ============ 运行模式 ============
background: true                   # 始终作为后台任务运行（可选）
isolation: worktree                # worktree | remote（可选，在隔离环境中运行）

# ============ 其他 ============
initialPrompt: "/review"           # 首轮对话前缀（可选，支持斜杠命令）
omitClaudeMd: false                # 是否省略 CLAUDE.md（可选，只读 agent 建议 true）
requiredMcpServers:                # 必须可用的 MCP（可选，不可用则报错）
  - "database"
---

You are a code review specialist...

## Review checklist
1. Security: XSS, SQL injection, secrets in code
2. Performance: N+1 queries, unnecessary re-renders
3. Error handling: unhandled promises, empty catches

## Output format
- Severity: Critical / Warning / Info
- File: path:line
- Issue: description
- Fix: suggested code change
```

### 3.3 字段详解

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `description` | string | **是** | 一句话描述，告诉主 Agent 何时使用 |
| `tools` | string[] | 否 | 工具白名单，`["*"]` 或省略=全部 |
| `disallowedTools` | string[] | 否 | 工具黑名单，优先级高于 tools |
| `model` | string | 否 | `sonnet` / `opus` / `haiku` / `inherit`（默认 inherit） |
| `effort` | string | 否 | `high` / `medium` / `low`（默认 medium） |
| `permissionMode` | string | 否 | 权限模式（见下方详解） |
| `maxTurns` | number | 否 | 最大对话轮次限制 |
| `memory` | string | 否 | `user` / `project` / `local` |
| `mcpServers` | array | 否 | Agent 专属 MCP 服务器配置 |
| `skills` | string[] | 否 | 启动时预加载的 skill |
| `hooks` | object | 否 | Agent 生命周期 hooks（见第五节） |
| `background` | boolean | 否 | `true` = 始终后台运行 |
| `isolation` | string | 否 | `worktree` = 在 git worktree 中隔离运行 |
| `initialPrompt` | string | 否 | 首轮用户消息前缀（支持 /命令） |
| `omitClaudeMd` | boolean | 否 | `true` = 不加载 CLAUDE.md（省 token） |
| `requiredMcpServers` | string[] | 否 | 必须可用的 MCP，不可用时 Agent 不可用 |
| `color` | string | 否 | Agent 在 UI 中的显示颜色 |

#### 3.3.1 description（必填）

- 唯一必填字段，告诉主 Agent **何时**调用此 Agent
- 写法要求：一句话说清楚功能，包含触发关键词（动词 + 场景）
- 好的 description 精准匹配用户需求，模糊的 description 会导致误触发或永不触发

```
好的：  "Independent code review for security and quality"
坏的：  "Helps with stuff"（无法被匹配）
```

#### 3.3.2 tools 与 disallowedTools

| 方式 | 适合场景 | 特点 |
|------|---------|------|
| 只设 `tools` 白名单 | 需要精确控制可用工具 | 安全性高，未来新增工具不会自动获得 |
| 只设 `disallowedTools` 黑名单 | 只需排除少数工具 | 更灵活，未来新增工具自动可用 |
| 两者组合 | 精细控制 | 黑名单优先级 > 白名单 |

- `tools: ["*"]` 或省略 tools = 所有工具可用
- 优先级：disallowedTools > tools

#### 3.3.3 model 模型选择

| 模型 | 成本倍数 | 适用场景 |
|------|---------|---------|
| `haiku` | 1x | 简单任务：格式化、搜索、快速修复、统计 |
| `sonnet` | 5x | 日常任务：代码审查、功能开发、测试编写（最平衡） |
| `opus` | 25x | 复杂推理：安全审计、架构分析、复杂调试 |
| `inherit` | — | 继承用户当前模型（默认），跟随用户切换自动调整 |

组合建议：
- `effort: low` + `model: haiku` → 极速简单任务
- `effort: high` + `model: opus` → 深度分析任务

#### 3.3.4 effort 推理强度

| 值 | 特点 | 适用场景 |
|----|------|---------|
| `low` | 快速响应，减少推理时间 | 格式化、简单修复、搜索 |
| `medium` | 平衡（默认） | 日常审查、常规开发 |
| `high` | 深度思考，模拟多个并发执行时序 | 安全审计、性能分析、复杂推理 |

- `high` 显著降低漏报率，但耗时更长
- 与 `model` 结合使用效果更佳

#### 3.3.5 maxTurns 最大轮次

限制对话轮次，防止成本失控。达到限制时自动停止并返回进度摘要（完成什么/剩什么/如何继续）。

| 值 | 适用场景 |
|----|---------|
| 5 | 极快：单次搜索、简单查询 |
| 8 | 快速：单文件分析 |
| 15 | 中等：小功能开发 |
| 20 | 常规：标准功能 + 测试修复 |
| 30 | 复杂：多文件重构 |
| 50 | 深度：大规模代码生成 |

建议：功能开发需预留测试和修复的轮次（通常 12-20 轮）；先设较小值试探，根据截断报告决定后续策略。

#### 3.3.6 permissionMode 权限模式

| 值 | 说明 | 适用场景 |
|----|------|---------|
| `default` | 每次操作弹出确认（最安全） | 新项目、探索性工作 |
| `acceptEdits` | 自动接受 Edit/Write/Bash，不逐个确认 | 部署流水线、批量修复 |
| `plan` | 先出计划，用户确认后再执行 | 重构、架构设计（高风险操作） |
| `dontAsk` | 完全自动执行 | 清理临时文件（可逆低风险任务） |

- 风险警告：`dontAsk` 模式允许执行任何操作，需谨慎使用
- `acceptEdits` 是日常开发最平衡的选择

#### 3.3.7 memory 持久化记忆

| scope | 路径 | 是否提交 VCS | 适用场景 |
|-------|------|------------|---------|
| `user` | `~/.claude/agent-memory/<agentType>/MEMORY.md` | 否 | 个人编码习惯、跨项目通用偏好 |
| `project` | `.claude/agent-memory/<agentType>/MEMORY.md` | 是 | 团队约定、项目特定规范 |
| `local` | `.claude/agent-memory-local/<agentType>/MEMORY.md` | 否 | 个人实验、临时笔记 |

- 优先级：`local` > `project` > `user`
- Agent 在运行时使用 Write 工具写入自己的 memory 目录，下次启动同类型 Agent 时自动加载
- 省略 memory 则 Agent 无持久化记忆

#### 3.3.8 mcpServers MCP 服务器

两种写法：
- **引用式**（字符串）：引用已在 settings.json 中配置的 MCP 服务器
- **内联式**（对象）：在 Agent 中直接定义，不影响其他 Agent

```yaml
mcpServers:
  - "my-database"              # 引用已配置的 MCP
  - reviewTools:                # 内联定义
      command: "npx my-review-tools"
```

- 可混合使用引用式和内联式
- 省略则使用主 Agent 的 MCP 服务器

#### 3.3.9 skills 预加载 Skill

- 启动时自动加载指定 Skill，无需用户手动输入
- 与主 Agent 的 Skill 共享：主 Agent 可用的 Skill Agent 也能用
- 预加载失败时优雅降级，其他正常加载的 Skill 不受影响
- 典型场景：`["commit", "deploy"]` 形成"开发→提交→部署"流水线

#### 3.3.10 background 后台运行

- `background: true` 让 Agent 始终在后台运行，主对话不等待
- **工具池受限**：只保留 `ASYNC_AGENT_ALLOWED_TOOLS`（子集）
- Agent 完成后发送通知
- 适用场景：测试套件、代码质量扫描、构建过程、安全审计

#### 3.3.11 isolation 隔离运行

- `isolation: worktree` 在隔离的 git worktree 中运行
- 自动创建临时 worktree，Agent 在其中操作（不影响主目录）
- 完成后可合并或丢弃，主目录代码零风险
- 适用场景：
  - 实验性重构（不确定效果）
  - 大规模代码生成（可能需要大量修改）
  - A/B 对比方案（同时试两种方案）

#### 3.3.12 omitClaudeMd 省略指令

- `omitClaudeMd: true` 不加载 CLAUDE.md 和 rules
- 节省效果：从 ~5000 tokens 降至 ~0，节省约 90%
- 适合：只读查询、通用工具、轻量快速任务（如搜索 API 端点、统计代码行数）
- **不适合**：需要遵循项目规范的 Agent（如代码审查、功能开发）

#### 3.3.13 initialPrompt 首轮前缀

- 在 Agent 首轮对话前注入前缀，确保每次运行都从相同状态开始
- 支持 `/` 开头（斜杠命令）或普通文本
- 典型场景：
  - 代码审查 Agent：`initialPrompt: "/review"` 自动开始审查
  - 安全扫描 Agent：先读取配置文件再扫描
  - 性能检查 Agent：自动分析 bundle

#### 3.3.14 requiredMcpServers 必须 MCP

- 声明必须可用的 MCP 服务器，不可用则 Agent **拒绝启动**（直接报错）
- 与 `mcpServers` 的区别：mcpServers 不可用时 Agent 仍启动，requiredMcpServers 不可用则报错
- 适用场景：数据库管理（无连接无法工作）、部署机器人（需 K8s 连接）

### 3.4 实用 Agent 示例

**代码审查 Agent**（`.claude/agents/code-reviewer.md`）：

```markdown
---
description: Independent code review for security and quality
disallowedTools:
  - Write
  - Edit
  - NotebookEdit
model: sonnet
omitClaudeMd: true
memory: project
---

You are a code review specialist. You ONLY review code, never modify it.

## Review checklist
1. **Security**: XSS, SQL injection, hardcoded secrets, CSRF
2. **Performance**: N+1 queries, missing indexes, memory leaks
3. **Error handling**: unhandled promises, empty catch blocks
4. **TypeScript**: any usage, missing types, unsafe casts
5. **Testing**: missing edge case tests, flaky tests

## Output format
For each issue found:
- **Severity**: Critical / Warning / Info
- **File**: `path:line`
- **Issue**: one-line description
- **Fix**: suggested code (in a code block)

End with a summary: total issues by severity.
```

**数据库管理 Agent**（`.claude/agents/db-admin.md`）：

```markdown
---
description: Database schema management and migration specialist
tools:
  - Read
  - Grep
  - Glob
  - Bash
model: sonnet
permissionMode: acceptEdits
maxTurns: 20
memory: project
---

You manage database schemas and migrations.

## Rules
- Always read the current schema before suggesting changes
- Migration files must be reversible (include down migration)
- Never drop columns without a deprecation period
- All new columns must have sensible defaults
- Use transactions for data migrations

## Workflow
1. Read prisma/schema.prisma to understand current state
2. Analyze the requested change
3. Create migration with both up and down
4. Verify migration SQL before presenting
```

**测试编写 Agent**（`.claude/agents/test-writer.md`）：

```markdown
---
description: Write comprehensive tests for modified code
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
model: sonnet
effort: high
---

You write tests for code changes.

## Rules
- Use Vitest as the testing framework
- Test file: <original>.test.ts, placed next to the source
- Cover: happy path, edge cases, error cases
- Use describe/it blocks, descriptive test names
- Mock external dependencies, not internal modules
- Aim for 80%+ coverage on new code
- Do NOT modify source files, only create/edit test files
```

### 3.5 Agent 的工具池

Agent 启动时，工具池按以下规则组装：

```
1. 取完整工具池（assembleToolPool）
2. 过滤 ALL_AGENT_DISALLOWED_TOOLS（所有 agent 都禁用的）
3. 如果是自定义 agent，过滤 CUSTOM_AGENT_DISALLOWED_TOOLS
4. 如果是后台 agent，只保留 ASYNC_AGENT_ALLOWED_TOOLS
5. 如果 tools 字段有白名单，只保留白名单内的
6. 如果 disallowedTools 有黑名单，移除黑名单内的
```

### 3.6 Agent 文件位置与优先级

| 位置 | 路径 | 作用范围 |
|------|------|---------|
| 全局 | `~/.claude/agents/*.md` | 所有项目生效 |
| 项目级 | `<project>/.claude/agents/*.md` | 当前项目 |
| 子目录级 | `<subdir>/.claude/agents/*.md` | 子目录范围 |

- 同名覆盖：后注册的覆盖先注册的（项目级覆盖全局级，子目录级覆盖项目级）
- 不同名：全部加载，不冲突
- 全局 Agent 适合跨项目复用的通用工具；项目级适合项目特定配置

---

## 四、Hooks（生命周期钩子）

### 4.1 配置位置

```bash
~/.claude/settings.json              # 全局 hooks
<project>/.claude/settings.json      # 项目 hooks
<project>/.claude/settings.local.json # 项目私有 hooks
```

### 4.2 所有 Hook 事件

| 事件 | 触发时机 | matcher 匹配对象 |
|------|---------|----------------|
| `PreToolUse` | 工具执行前 | 工具名（如 `Edit`、`Write`） |
| `PostToolUse` | 工具执行成功后 | 工具名 |
| `PostToolUseFailure` | 工具执行失败后 | 工具名 |
| `PermissionRequest` | 权限对话框显示时 | 工具名 |
| `UserPromptSubmit` | 用户提交消息时 | 来源（如 `api`、`cli`） |
| `SessionStart` | 会话启动或恢复时 | `startup` / `resume` / `clear` / `compact` |
| `SessionEnd` | 会话结束时 | 退出原因 |
| `Stop` | Agent 停止时 | — |
| `SubagentStart` | 子 Agent 启动时 | — |
| `SubagentStop` | 子 Agent 停止时 | — |
| `PreCompact` | 上下文压缩前 | `manual` / `auto` |
| `PostCompact` | 上下文压缩后 | — |
| `Notification` | 收到通知时 | 通知类型（见下方） |
| `Setup` | 初始化/维护模式触发（`--init`/`--maintenance`）| `init` / `maintenance` |

**Notification matcher 速查**：

| 值 | 说明 |
|----|------|
| `permission_prompt` | 权限请求 |
| `idle_prompt` | 空闲超过 60 秒 |
| `auth_success` | 认证成功 |
| `elicitation_dialog` | MCP 工具输入对话框 |

#### matcher 匹配规则

- **PreToolUse / PostToolUse / PostToolUseFailure**：matcher 匹配**工具名**
- **UserPromptSubmit / SessionStart / SessionEnd**：matcher 匹配**来源**（source，如 `api`、`cli`）
- 多工具匹配：用 `|` 分隔，如 `"Edit|Write"`（正则 OR 语法）
- 空字符串 `""` 或 `".*"` = 匹配所有
- 脚本内可做二次过滤：先 matcher 匹配大类，脚本内做细粒度过滤（如 Bash 只拦截危险命令）

#### Hook 配置位置与合并行为

Hooks 在三个位置配置，**合并执行**而非覆盖：

```
~/.claude/settings.json              → 全局 hooks
<project>/.claude/settings.json      → 项目 hooks
<project>/.claude/settings.local.json → 项目私有 hooks
```

- 执行顺序：全局 → 项目 → 项目私有
- 同一事件的所有来源 Hook **都会执行**（合并，不是替换）
- 不能通过项目配置"禁用"全局 Hook，需在脚本中做条件判断
- 建议：全局放通用 hooks（lint、格式化），项目放项目特定 hooks

### 4.3 Hook 类型

#### Command Hook（执行 shell 命令）

```json
{
  "type": "command",
  "command": "bash .claude/hooks/my-script.sh",
  "shell": "bash",
  "timeout": 30,
  "statusMessage": "Running pre-check...",
  "once": false,
  "async": false,
  "asyncRewake": false
}
```

| 字段 | 说明 |
|------|------|
| `command` | Shell 命令 |
| `shell` | `bash` 或 `powershell`（默认 bash） |
| `timeout` | 超时秒数 |
| `statusMessage` | 运行时显示的状态文字 |
| `once` | `true` = 只运行一次后自动移除（当前仅 Skill hooks 支持） |
| `async` | `true` = 后台运行，不阻塞主流程 |
| `asyncRewake` | `true` = 后台完成后重新唤醒 agent |

#### Prompt Hook（LLM 评估型 Hook）

使用轻量级模型（Haiku）评估，适合需要上下文理解的决策（如判断是否应该停止）：

```json
{
  "type": "prompt",
  "prompt": "评估 Claude 是否应该停止：$ARGUMENTS。检查所有任务是否完成。返回 JSON：{\"ok\": true} 允许停止，{\"ok\": false, \"reason\": \"说明\"} 继续工作。",
  "timeout": 30
}
```

LLM 必须返回 JSON `{"ok": true}` 或 `{"ok": false, "reason": "..."}` 格式。适合 `Stop` 事件（智能判断是否完成所有任务）。

#### Agent Hook（启动子 Agent 执行任务）

```json
{
  "type": "agent",
  "agentType": "code-reviewer",
  "prompt": "Review the file that was just modified: {{file_path}}"
}
```

#### HTTP Hook（调用外部 API）

```json
{
  "type": "http",
  "url": "https://api.example.com/webhook",
  "method": "POST",
  "headers": {
    "Authorization": "Bearer $TOKEN"
  }
}
```

### 4.4 Hook 输入（通过 stdin 传入 JSON）

**PreToolUse / PostToolUse**：

```json
{
  "hook_event_name": "PreToolUse",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/project/src/app.ts",
    "old_string": "...",
    "new_string": "..."
  },
  "session_id": "session-uuid",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/project"
}
```

**PostToolUse 额外字段**：

```json
{
  "tool_output": "The file has been edited successfully",
  "tool_result": { ... }
}
```

**PostToolUseFailure 输入**：

```json
{
  "hook_event_name": "PostToolUseFailure",
  "tool_name": "Edit",
  "tool_input": { "file_path": "...", ... },
  "error": "File not found: /project/src/app.ts",
  "session_id": "session-uuid",
  "cwd": "/project"
}
```

**UserPromptSubmit 输入**：

```json
{
  "hook_event_name": "UserPromptSubmit",
  "source": "api",
  "prompt": "用户输入的完整消息文本",
  "session_id": "session-uuid",
  "cwd": "/project"
}
```

**stdin 字段差异速查**：

| 事件 | 特有字段 |
|------|---------|
| PreToolUse | `tool_name`, `tool_input` |
| PostToolUse | `tool_name`, `tool_input`, `tool_output`, `tool_result` |
| PostToolUseFailure | `tool_name`, `tool_input`, `error` |
| UserPromptSubmit | `source`, `prompt` |

**文件路径提取注意**：需要处理 `.file_path` 和 `.path` 两种字段名：
```bash
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')
```

### 4.5 Hook 输出（通过 stdout 返回 JSON）

- 必须输出有效 JSON，非 JSON 输出会被忽略
- stderr 用于调试输出（不影响 Claude）

**PreToolUse 可返回**：

```json
{
  "permissionDecision": "allow",
  "permissionDecisionReason": "Auto-approved for this file type",
  "updatedInput": {
    "file_path": "/modified/path"
  }
}
```

- `permissionDecision`: `"allow"` / `"deny"` / `"ask"` — 控制是否允许执行
- `permissionDecisionReason`: 决策原因说明（可选）
- `updatedInput`: 修改工具的输入参数（如路径重定向）

**PostToolUse / PostToolUseFailure 可返回**：

```json
{
  "additionalContext": "已自动执行 git add，变更已暂存"
}
```

- `additionalContext`: 注入给 Claude 的额外上下文信息

**PermissionRequest 可返回**：

```json
{
  "decision": "allow"
}
```

- `decision`: `"allow"` / `"deny"` / `"pass"` — allow=直接放行，deny=拒绝，pass=走正常权限弹窗

**通用控制字段**（所有事件均可返回，exit 0 时处理）：

```json
{
  "continue": true,
  "stopReason": "任务未完成时的说明",
  "suppressOutput": false,
  "systemMessage": "向用户显示的警告信息"
}
```

| 字段 | 说明 |
|------|------|
| `continue` | `false` 时中止后续处理 |
| `stopReason` | `continue: false` 时向用户展示的原因 |
| `suppressOutput` | `true` 时隐藏 stdout 输出，不影响执行 |
| `systemMessage` | 向用户显示的警告/提示信息 |

**退出码行为速查**：

| 退出码 | 行为 |
|--------|------|
| `0` | 成功，stdout 在 verbose 模式显示 |
| `2` | 阻断/拒绝（PreToolUse 阻止执行；PermissionRequest 拒绝权限；Stop/SubagentStop 阻止停止） |
| 其他 | 非阻断错误，stderr 在 verbose 显示，继续执行 |

### 4.6 settings.json 完整示例

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-edit.sh",
            "statusMessage": "Checking git status..."
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-edit.sh",
            "async": true,
            "statusMessage": "Auto-staging changes..."
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-bash.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/on-stop.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

### 4.7 Hook 脚本示例

**编辑前检查**（`.claude/hooks/pre-edit.sh`）：

```bash
#!/bin/bash
# 从 stdin 读取 hook 输入
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# 检查是否有未提交的变更
if ! git diff --quiet "$FILE_PATH" 2>/dev/null; then
  echo "Warning: $FILE_PATH has uncommitted changes"
fi

# 输出 JSON 控制（可选）
# echo '{"permissionDecision": "allow"}'
```

**编辑后自动暂存**（`.claude/hooks/post-edit.sh`）：

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ]; then
  git add "$FILE_PATH" 2>/dev/null
  echo "{\"additionalContext\": \"Auto-staged: $FILE_PATH\"}"
fi
```

---

## 五、Agent 专属 Hooks

### 5.1 原理

Agent 可以在 frontmatter 中定义自己的 hooks。这些 hooks 在 Agent 启动时注册，Agent 结束时自动清理。

关键机制（源码 `registerFrontmatterHooks.ts`）：
- Agent 的 `Stop` hook 会自动转换为 `SubagentStop`
- hooks 作用域限定在该 Agent 的 session 内
- Agent 结束后 hooks 自动注销

### 5.2 在 Agent frontmatter 中定义 hooks

```markdown
---
description: Code reviewer with automated follow-up
disallowedTools:
  - Write
  - Edit
hooks:
  SubagentStop:
    - matcher: ""
      hooks:
        - type: command
          command: "bash .claude/hooks/after-review.sh"
          async: true
  SubagentStart:
    - matcher: ""
      hooks:
        - type: command
          command: "bash .claude/hooks/before-review.sh"
---

You are a code review specialist...
```

### 5.3 Agent 可用的 Hook 事件

| 事件 | 说明 | 典型用途 |
|------|------|---------|
| `SubagentStart` | Agent 启动时触发（session 创建后，执行任务前） | 加载项目上下文、检查前置条件 |
| `SubagentStop` | Agent 完成时触发 | 自动提交、生成报告、触发 CI/CD |
| `PreToolUse` | Agent 内工具调用前触发 | 权限控制、路径重定向、阻止危险操作 |
| `PostToolUse` | Agent 内工具调用后触发 | 自动 lint/format、测试验证、自动暂存 |
| `PreCompact` | Agent 上下文压缩前触发 | 保存重要进度、持久化关键发现 |
| `Notification` | Agent 收到通知时触发 | 响应任务完成、后台工作流协调 |

**与全局 hooks 的关系**：
- 全局 hooks 先执行，Agent 专属 hooks 后执行
- 任一返回 `deny` → 操作被拒绝（双重安全）
- 推荐 Agent 内 PostToolUse 使用 `async: true` 避免阻塞

**PreCompact 特殊用途**：
- 上下文即将被压缩（超出 token 限制）时触发
- 是保存重要信息的**最后机会**
- 典型：将研究发现注入为摘要、将 git 状态写入进度文件
- 与 Notification 配合可实现可靠的任务队列处理

### 5.4 实用场景

**场景 1：Agent 完成后自动提交**

```markdown
---
description: Feature implementer
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
hooks:
  SubagentStop:
    - matcher: ""
      hooks:
        - type: command
          command: |
            FILES=$(git diff --name-only)
            if [ -n "$FILES" ]; then
              git add -A
              git commit -m "feat: automated implementation"
              echo '{"additionalContext": "Changes auto-committed"}'
            fi
          async: true
---

Implement features based on the specification...
```

**场景 2：Agent 每次编辑后自动 lint**

```markdown
---
description: TypeScript developer
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
---

You write TypeScript code...
```

**场景 3：Agent 启动时加载项目上下文**

```markdown
---
description: Database migration specialist
tools:
  - Read
  - Write
  - Edit
  - Bash
hooks:
  SubagentStart:
    - matcher: ""
      hooks:
        - type: command
          command: |
            echo '{"additionalContext": "Current schema version: '"$(cat prisma/schema.prisma | grep '// version:' | head -1)"'"}'
---

You handle database migrations...
```

---

## 六、Skills（技能/斜杠命令）

### 6.1 文件位置与查找

```bash
~/.claude/commands/*.md              # 全局斜杠命令
~/.claude/skills/*/SKILL.md          # 全局技能（目录式）
<project>/.claude/commands/*.md      # 项目斜杠命令
<project>/.claude/skills/*/SKILL.md  # 项目技能（目录式）
```

- 文件名映射为命令名：`commit.md` → `/commit`
- 查找优先级：**项目级 > 全局级**，同名时项目级覆盖全局级
- 只识别顶层 MD 文件（commands/）或 SKILL.md（skills/），子目录中的其他文件不被识别为命令
- commands/ 和 skills/ 都会注册为斜杠命令，技术角度等价

### 6.2 commands vs skills 区别

| 维度 | commands/ | skills/ |
|------|-----------|---------|
| 组织约定 | 偏向一次性动作 | 偏向可复用能力 |
| 示例 | `/commit`、`/deploy` | `/refactor`、`/code-explain` |
| 文件结构 | 单文件 `.md` | 目录式，可附带脚本 |
| 技术实现 | 完全等价 | 完全等价 |

- 小项目只用 `commands/` 即可
- 需要附带脚本资源时使用 `skills/`（目录结构）

### 6.3 Skill 定义

```markdown
---
description: Generate a commit with conventional commit message
argument-hint: "[optional scope] commit description"
allowed-tools:
  - Bash
  - Read
agent: general-purpose
paths:
  - "**/*.ts"
  - "**/*.tsx"
shell: bash
---

Based on the current git diff, generate a conventional commit message
and commit the changes.

Rules:
- Use Conventional Commits format: type(scope): description
- Types: feat, fix, refactor, docs, test, chore, perf
- Scope is optional
- Description in imperative mood, lowercase, no period
- If there are breaking changes, add BREAKING CHANGE in footer

$ARGUMENTS
```

| 字段 | 说明 |
|------|------|
| `description` | 命令描述（显示在 `/help` 列表），建议动词开头，10-30 个英文单词 |
| `argument-hint` | 参数提示格式，`[]` 标记可选，`<>` 标记必选 |
| `allowed-tools` | 执行时额外允许的工具列表（未指定则继承当前会话默认工具集） |
| `agent` | 使用的 agent 类型（默认 `general-purpose`，可指向自定义 Agent 名称） |
| `model` | Skill 激活时使用的模型（`sonnet` / `opus` / `haiku` / `inherit`） |
| `context` | `fork` 时在隔离的子代理上下文中运行，不污染主对话 |
| `hooks` | 仅在该 Skill 激活时生效的局部 hooks（`once: true` 仅 Skill hooks 支持） |
| `paths` | 条件匹配路径（同 rules 的 paths，控制自动推荐而非阻止手动调用） |
| `shell` | `bash`（默认）或 `powershell` |
| `disable-model-invocation` | `true` 时禁止模型自动触发，只允许用户手动 `/name` 调用 |
| `user-invocable` | `false` 时从 `/` 菜单隐藏，适合背景知识类 Skill |

**$ARGUMENTS 参数传递**：
- `$ARGUMENTS` 在正文中被替换为用户实际输入的参数文本
- 用户无输入时替换为空字符串
- 可在正文中多处使用，支持复杂的自然语言参数解析

**动态上下文注入（先执行再注入）**：

在 Skill 内容中使用内联命令语法，Claude Code 会在将 Skill 发给 Claude **之前**执行命令并替换输出：

```yaml
---
name: pr-summary
description: 汇总当前 PR 改动（使用 GitHub CLI 拉取实时数据）
context: fork
agent: Explore
allowed-tools: Bash(gh:*)
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

## Task
基于以上信息，用中文给出这次 PR 的摘要、风险点与建议验证清单。
```

内联语法：`` !`command` ``（单行，放在任意位置），Claude 看到的是已执行的输出，不是命令本身。

**`context: fork` 隔离执行**：

```yaml
context: fork
agent: Explore    # 可选：Explore / Plan / general-purpose / <自定义Agent名>
```

- 适合高噪声任务（大日志分析、全仓扫描），避免输出污染主对话
- 适合需要固定 agent 类型和工具边界的任务
- **不适合**纯背景知识/规范注入类 Skill（得不到有效产出）
- 主对话只收到摘要，详细输出留在子代理上下文

**触发控制矩阵**：

| frontmatter 组合 | 用户 `/name` 手动调用 | 模型自动触发 | 适用场景 |
|------|------|------|------|
| 默认（两字段都不写） | 是 | 是 | 通用技能、低风险知识注入 |
| `disable-model-invocation: true` | 是 | 否 | 有副作用流程（deploy、发布、批量改写） |
| `user-invocable: false` | 否（菜单隐藏） | 是 | 背景知识类 Skill |

**agent 字段**：
- 指向 `.claude/agents/` 中定义的自定义 Agent
- Agent 的 tools、disallowedTools、model、effort 等配置全部生效
- Agent 不存在时降级为 `general-purpose`

**paths 字段**：
- 与 Rules 的 paths 不同，Skills 的 paths **只影响自动推荐**，不阻止手动 `/command` 调用
- 支持通配符：`**`、`*`、`{a,b}`、`!`
- 不指定 paths 时 Skill 始终可用

**目录式 Skill 结构**：

```
.claude/skills/<name>/
├── SKILL.md          ← 技能定义（必须有）
├── script.py         ← 附带脚本
└── config.json       ← 附带资源
```

- SKILL.md 中用 `$CLAUDE_SKILL_DIR` 引用同目录下的脚本
- 支持嵌入可执行命令：` ```! npm run build ``` ` 和内联 ` !`cat file` `

### 6.3 调用方式

```
/commit                           # 调用 ~/.claude/commands/commit.md
/commit fix login bug             # 带参数调用
```

---

## 七、settings.json 配置

### 7.1 配置文件位置和优先级

```
/etc/claude-code/settings.json       系统管理配置（优先级 1，最低）
~/.claude/settings.json              用户全局配置（优先级 2）
<project>/.claude/settings.json      项目共享配置（优先级 3，提交 VCS）
<project>/.claude/settings.local.json 项目私有配置（优先级 4，最高）
```

- 配置合并规则：所有层级配置**合并**，同名字段高优先级覆盖低优先级
- 数组字段通常合并而非覆盖
- settings.json 适合团队共享（提交 VCS），settings.local.json 适合个人偏好（不提交）

### 7.2 主要配置项

```json
{
  "permissions": {
    "allow": [
      "Bash(git log*)",
      "Bash(git diff*)",
      "Bash(git status*)",
      "Bash(npm test*)",
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(curl*|*)"
    ],
    "defaultMode": "default",
    "additionalDirectories": ["/other/project"]
  },

  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...]
  },

  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "my-mcp-server"],
      "env": {}
    }
  },

  "agentModel": "inherit",
  "theme": "dark",
  "verbose": true
}
```

### 7.3 permissions 权限详解

**优先级链**：`deny` > `allow` > `defaultMode`（deny 是最终安全底线，不可被任何配置绕过）

**defaultMode 全选项**：

| 值 | 说明 | 适用场景 |
|----|------|---------|
| `default` | 每次操作弹出确认（最安全） | 新项目、探索性工作 |
| `acceptEdits` | 自动接受 Edit/Write，Bash 仍需确认 | 日常开发（最平衡） |
| `plan` | 先出计划，用户确认后再执行 | 重构、架构设计 |
| `auto` | 全部自动执行 | CI/CD 自动化 |
| `dontAsk` | 自动执行，使用最合适权限 | 清理临时文件等低风险任务 |

**additionalDirectories**：

- 字符串数组，允许 Claude Code 访问项目根目录之外的目录
- 默认只能访问当前项目目录内的文件
- 支持绝对路径和相对路径（如 `../packages/shared-core`）
- 适用场景：多项目共享组件库、引用外部配置、跨项目搜索

### 7.4 verbose 调试模式

- `verbose: true` 启用详细日志输出，显示：
  - 工具调用的详细参数
  - 模型选择的推理过程
  - Hook 触发和执行日志
  - MCP 服务器通信详情
  - 每轮会话的 token 使用统计和预估成本
- 主要用途：调试 Hook 行为、排查权限问题、理解 Claude 决策过程
- 生产环境推荐关闭，减少噪音

### 7.5 agentModel 与 theme

| agentModel | 说明 |
|------------|------|
| `inherit` | 继承用户当前模型（默认） |
| `sonnet` | 强制使用 Sonnet（成本与能力平衡） |
| `opus` | 强制使用 Opus（最强推理，成本约 Sonnet 5x） |
| `haiku` | 强制使用 Haiku（最便宜，约 Sonnet 1/5） |

| theme | 说明 |
|-------|------|
| `dark` | 深色主题 |
| `light` | 浅色主题 |
| `system` | 跟随系统设置 |

---

## 七·五、MCP 服务器配置

MCP（Model Context Protocol）让 Claude Code 连接数据库、API、浏览器等外部工具。

### MCP 配置文件位置

| 位置 | 路径 | 作用范围 | 是否提交 VCS |
|------|------|---------|------------|
| 本地（默认） | `~/.claude.json`（项目路径下） | 当前项目 | 否 |
| 项目级 | `<project>/.mcp.json` | 当前项目，团队共享 | **是** |
| 用户级 | `~/.claude.json`（用户范围） | 所有项目 | 否 |

同名优先级：**本地 > 项目 > 用户**

### .mcp.json 格式（推荐团队共享）

```json
{
  "mcpServers": {
    "postgres": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@bytebase/dbhub", "--dsn", "${DATABASE_URL}"],
      "env": { "DB_READONLY": "true" }
    },
    "github": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": { "Authorization": "Bearer ${GITHUB_TOKEN}" }
    }
  }
}
```

支持环境变量展开：`${VAR}` 和 `${VAR:-默认值}`

### CLI 管理命令

```bash
# 添加（stdio）
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub --dsn "postgresql://..."

# 添加（HTTP）
claude mcp add --transport http github https://api.example.com/mcp

# 带认证头
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer $TOKEN"

# 指定作用域（local / project / user）
claude mcp add --scope project ...

# 列出、查看、删除
claude mcp list
claude mcp get github
claude mcp remove github

# 在 CC 中检查状态
> /mcp
```

**参数顺序**：所有选项（`--transport`、`--env`、`--scope`、`--header`）必须在服务器名称**之前**。

### 三种传输类型

| 类型 | 配置 | 适用场景 |
|------|------|---------|
| `stdio` | 本地进程（`command` + `args`） | 需要系统访问的本地工具 |
| `http` | 云端 URL（`url` + `headers`） | 远程服务、云端 API |
| `sse` | SSE URL（已弃用） | 优先改用 http |

### MCP Tool Search（避免上下文被挤占）

多个 MCP 时，工具定义可能占用大量上下文窗口。通过 `ENABLE_TOOL_SEARCH` 环境变量控制：

| 值 | 行为 |
|----|------|
| `auto`（默认） | 工具定义超过上下文 10% 时启用按需加载 |
| `auto:5` | 自定义阈值（5%） |
| `true` | 始终启用 |
| `false` | 禁用，始终预加载所有工具 |

```json
// settings.json 中统一配置
{ "env": { "ENABLE_TOOL_SEARCH": "auto:5" } }
```

> 注：Tool Search 需要模型支持 `tool_reference`（Sonnet 4+ / Opus 4+），Haiku 通常不支持。

### 安全最佳实践

- **不要**把真实密钥写进 `.mcp.json`（会提交 VCS）
- 使用 `${ENV_VAR}` 占位符引用真实密钥
- 项目级密钥放 `.env` 文件（加入 `.gitignore`）
- 控制 MCP 数量：建议同时启用不超过 10 个

---

## 八、Memory（记忆系统）

### 8.1 三种记忆

| 类型 | 路径 | 作用范围 | 写入方式 |
|------|------|---------|---------|
| Auto Memory | `~/.claude/memory/MEMORY.md` | 当前用户，所有项目共享 | `/remember` 命令或 Claude 自动识别 |
| Agent Memory | `agent-memory/<agentType>/MEMORY.md` | 特定 Agent 类型，跨项目 | Agent 运行时用 Write 工具写入 |
| 项目 Memory | `CLAUDE.md` / `.claude/rules/` | 项目级，团队共享 | 手动编辑或 `@include` 引用 |

### 8.2 Agent Memory

当 Agent 定义了 `memory` 字段时，该 Agent 会有持久化的记忆目录：

| scope | 路径 | 是否提交 VCS | 适用场景 |
|-------|------|------------|---------|
| `user` | `~/.claude/agent-memory/<agentType>/MEMORY.md` | 否 | 个人编码习惯、跨项目通用经验 |
| `project` | `.claude/agent-memory/<agentType>/MEMORY.md` | 是（团队共享） | 团队约定、项目特定规范 |
| `local` | `.claude/agent-memory-local/<agentType>/MEMORY.md` | 否（需 .gitignore 排除） | 个人实验、临时笔记、敏感信息 |

- 优先级：`local` > `project` > `user`
- Agent 在运行时使用 Write 工具写入自己的 memory 目录，下次启动同类型 Agent 时自动加载
- local scope 可作为实验沙箱，成功后迁移到 project scope

### 8.3 记忆读写机制

**读取（加载顺序）**：
- Auto Memory：会话启动时自动加载
- Agent Memory：Agent 启动时按 `user` → `project` → `local` 顺序加载
- 项目 Memory：按目录层级加载（全局 → 项目 → 子目录）
- 所有记忆同时生效，高优先级覆盖低优先级冲突

**写入**：
- `/remember` 命令：写入 Auto Memory
- Agent 运行时：通过 Write 工具写入自己的 memory 目录
- 手动编辑：直接编辑 MEMORY.md 文件

**完整优先级链**（从低到高）：

```
Auto Memory (~/.claude/memory/)
    ↓
全局 CLAUDE.md (~/.claude/CLAUDE.md)
    ↓
Agent Memory - user scope
    ↓
项目 CLAUDE.md (<project>/CLAUDE.md)
    ↓
CLAUDE.local.md (<project>/CLAUDE.local.md)
    ↓
Agent Memory - project scope
    ↓
子目录 CLAUDE.md
    ↓
Agent Memory - local scope（最高）
```

### 8.4 CLAUDE.md 与 CLAUDE.local.md

| 文件 | 是否提交 VCS | 用途 |
|------|------------|------|
| `CLAUDE.md` | 是 | 团队共享的项目规范、架构说明、开发约定 |
| `CLAUDE.local.md` | 否（需 .gitignore 排除） | 个人偏好、本地环境配置、私有指令 |

- 两者格式完全相同，`CLAUDE.local.md` 优先级更高
- 支持子目录级放置，越深优先级越高
- 支持 `@include` 引用外部文件

---

## 九、环境变量

| 变量 | 说明 |
|------|------|
| `CLAUDE_CODE_SUBAGENT_MODEL` | 强制所有子 agent 使用指定模型 |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | 禁用后台任务 |
| `CLAUDE_AUTO_BACKGROUND_TASKS` | 启用自动后台 agent |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | 允许 --add-dir 目录加载 CLAUDE.md |
| `CLAUDE_CODE_AGENT_LIST_IN_MESSAGES` | Agent 列表通过消息注入（省 cache） |
| `CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS` | SDK 模式下禁用内置 Agent |
| `CLAUDE_CODE_COORDINATOR_MODE` | 启用 Coordinator 模式 |

---

## 十、用户可主动使用的方法

### 10.1 斜杠命令（Slash Commands）

用户可以在对话中直接输入 `/命令名` 来调用：

| 命令 | 说明 | 示例 |
|------|------|------|
| `/commit` | 生成提交信息并提交代码 | `/commit`、`/commit fix login bug` |
| `/review` | 代码审查 | `/review`、`/review src/app.ts` |
| `/loop` | 设置定时循环任务 | `/loop 5m check the deploy` |
| `/config` | 查看或修改简单配置 | `/config` |
| `/update-config` | 修改 settings.json 配置 | `/update-config` |
| `/compact` | 手动压缩上下文 | `/compact` |
| `/clear` | 清空对话历史 | `/clear` |
| `/help` | 查看帮助 | `/help` |
| `/memory` | 查看或管理记忆 | `/memory` |
| `/hooks` | 查看/管理 Hooks | `/hooks` |
| `/status` | 查看当前状态 | `/status` |
| `/cost` | 查看 token 消耗 | `/cost` |
| `/model` | 切换模型 | `/model sonnet` |
| `/permissions` | 查看当前权限 | `/permissions` |
| `/init` | 初始化项目配置 | `/init` |
| `/remember` | 保存记忆 | `/remember 项目使用 Vitest` |
| `/fast` | 切换快速模式 | `/fast` |

### 10.2 主动配置方法

#### CLAUDE.md（项目/全局指令）

主动创建 `.md` 文件注入行为指令：

```
# 用户可以主动操作：
1. 编辑 CLAUDE.md              → 影响所有对话
2. 编辑 CLAUDE.local.md        → 仅本地，不提交
3. 编辑子目录 CLAUDE.md        → 子目录级指令
4. 使用 @include 引用外部文件  → 注入上下文
```

#### Rules（条件规则）

主动创建规则文件控制模型行为：

```bash
# 无条件规则（始终生效）
echo "- 使用 TypeScript strict mode" > .claude/rules/coding.md

# 条件规则（操作特定文件时生效）
cat > .claude/rules/frontend.md << 'EOF'
---
paths:
  - "apps/web/**"
  - "packages/ui/**"
---
- React 18 + TypeScript
- 样式: Tailwind CSS
EOF
```

#### Agents（自定义 Agent）

主动创建 Agent 定义文件：

```bash
# 创建专用 Agent
cat > .claude/agents/reviewer.md << 'EOF'
---
description: Code review specialist
disallowedTools:
  - Write
  - Edit
model: sonnet
---
You are a code reviewer...
EOF
```

使用方式：在对话中让 Claude 调用 `Agent` 工具并指定 `agentType: "reviewer"`。

#### Skills/Commands（自定义技能）

主动创建斜杠命令：

```bash
# 方式 1：单文件命令（commands/）
cat > .claude/commands/deploy.md << 'EOF'
---
description: Deploy the project
allowed-tools:
  - Bash
---
Deploy the project to staging environment.

Steps:
1. Run tests: ```! npm test ```
2. Build: ```! npm run build ```
3. Deploy: ```! npm run deploy:staging ```

$ARGUMENTS
EOF

# 方式 2：目录式技能（skills/）—— 支持附带脚本
mkdir -p .claude/skills/analyze
cat > .claude/skills/analyze/SKILL.md << 'EOF'
---
description: Analyze code metrics
allowed-tools:
  - Bash
  - Read
---
Run analysis scripts:

```! python3 $CLAUDE_SKILL_DIR/analyze.py $ARGUMENTS ```
EOF

# 附带 Python/Shell 脚本
cat > .claude/skills/analyze/analyze.py << 'EOF'
import sys
# ... 分析逻辑
EOF
```

### 10.3 主动运行时操作

#### Shell 命令嵌入（Skill 内使用）

在 Skill 的 `.md` 文件中嵌入可执行命令：

```
# 代码块语法（执行 shell 命令并替换输出）
```! npm run build ```

# 内联语法（单行命令）
当前版本: !`cat package.json | jq -r .version`
```

#### 变量替换（Skill 内使用）

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `$ARGUMENTS` | 用户传入的参数 | `fix login bug` |
| `${CLAUDE_SKILL_DIR}` | 当前 Skill 的目录路径 | `/home/user/.claude/skills/commit` |
| `${CLAUDE_SESSION_ID}` | 当前会话 ID | `abc123-def456` |

#### Hooks（生命周期钩子）

主动配置自动化行为：

```bash
# 编辑 settings.json 添加 hooks
cat > .claude/settings.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.file_path' | { read -r f; prettier --write \"$f\"; } 2>/dev/null || true"
      }]
    }]
  }
}
EOF
```

### 10.4 主动记忆操作

| 操作 | 方法 | 说明 |
|------|------|------|
| 保存记忆 | `/remember 内容` | 主动告诉 Claude 记住某些信息 |
| 查看记忆 | `/memory` | 查看当前保存的所有记忆 |
| 清除记忆 | 编辑 `memory/MEMORY.md` | 手动删除不再需要的记忆条目 |
| Agent 记忆 | Agent 定义 `memory` 字段 | Agent 跨会话持久化记忆 |

### 10.5 权限管理

```bash
# 在 settings.json 中主动配置权限
{
  "permissions": {
    "allow": [
      "Bash(npm:*)",          # 允许所有 npm 命令
      "Bash(git:*)",          # 允许所有 git 命令
      "Read",                 # 允许读取文件
      "Glob",                 # 允许搜索文件
      "Grep"                  # 允许搜索内容
    ],
    "deny": [
      "Bash(rm -rf:*)"       # 禁止 rm -rf
    ],
    "defaultMode": "default"  # default | plan | acceptEdits | dontAsk
  }
}
```

### 10.6 方法速查表

| 想要做到 | 使用方法 | 配置位置 |
|---------|---------|---------|
| 每次对话都遵循的规范 | CLAUDE.md / Rules | `CLAUDE.md` / `.claude/rules/*.md` |
| 操作特定文件时注入规范 | 条件 Rules（paths） | `.claude/rules/*.md` + `paths` |
| 调用专用 Agent | Agent 定义 | `.claude/agents/*.md` |
| 创建自定义命令 | Skill / Command | `.claude/skills/*/SKILL.md` / `.claude/commands/*.md` |
| 自动化工具调用 | Hooks | `.claude/settings.json` → `hooks` |
| 保存跨会话信息 | Memory | `/remember` 或 `memory/MEMORY.md` |
| 控制模型可用工具 | Permissions | `.claude/settings.json` → `permissions` |
| 修改主题/模型等 | Config 工具或 settings.json | `/config` 或编辑配置文件 |
| 定时重复执行任务 | `/loop` | `/loop 5m /check-deploy` |
| 连接外部工具/服务 | MCP Server | `.claude/settings.json` → `mcpServers` |
| 设置环境变量 | Settings | `.claude/settings.json` → `env` |
| 命令行一次性运行 | `claude -p "提示词"` | 终端命令行 |
| 管道模式 | `cat file \| claude -p "分析"` | 终端命令行 |

---

## 附录：快速配置模板

### 最小项目配置

```bash
# 1. 创建项目指令
cat > CLAUDE.md << 'EOF'
# 项目概述
- 技术栈: [填写]
- 目录结构: [填写]
- 开发规范: [填写]
EOF

# 2. 创建条件规则
mkdir -p .claude/rules
cat > .claude/rules/testing.md << 'EOF'
---
paths: "**/*.test.*"
---
测试规范:
- 框架: Vitest
- 覆盖率 ≥ 80%
EOF
```

### 完整项目配置

```bash
# 1. 基础指令
touch CLAUDE.md                     # 项目全局规范

# 2. 规则
mkdir -p .claude/rules
touch .claude/rules/coding.md      # 通用编码规范
touch .claude/rules/frontend.md    # 前端条件规则
touch .claude/rules/backend.md     # 后端条件规则

# 3. 自定义 Agent
mkdir -p .claude/agents
touch .claude/agents/reviewer.md   # 代码审查 Agent
touch .claude/agents/tester.md     # 测试编写 Agent

# 4. Hooks 脚本
mkdir -p .claude/hooks
touch .claude/hooks/pre-edit.sh
touch .claude/hooks/post-edit.sh

# 5. 项目配置
touch .claude/settings.json         # hooks + 权限配置

# 6. 私有配置（不提交）
touch CLAUDE.local.md
touch .claude/settings.local.json

# 7. 为每个子项目添加 CLAUDE.md
for dir in apps/*/ services/*/; do
  if [ -f "$dir/README.md" ]; then
    echo '@./README.md' > "$dir/CLAUDE.md"
  fi
done
```
