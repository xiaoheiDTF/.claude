# Skill / Command 配置模板

> 参考 cc_prompt.md 第六节 "Skills（技能/斜杠命令）"
> 参考 skill-design-guide.md "Skill 设计深度指南"

## 两种形式

| 形式 | 路径 | 特点 | 适用场景 |
|------|------|------|---------|
| 单文件命令 | `.claude/commands/<name>.md` | 无附带脚本，一次性动作 | `/commit`、`/deploy`、`/review` |
| 目录式技能 | `.claude/skills/<name>/SKILL.md` | 支持附带脚本和资源文件 | `/refactor`、`/analyze`（需要脚本） |

技术角度完全等价，区别是组织约定：
- commands/ → 偏向一次性动作（执行后立即返回）
- skills/ → 偏向可复用能力（可能涉及多轮交互、需要脚本资源）
- 小项目只用 `commands/` 即可

## 优先级

- 项目级 > 全局级（同名覆盖）
- 不同名全部加载
- 同名冲突时：`.claude/skills/<name>/SKILL.md` 优先于 `.claude/commands/<name>.md`

---

## 渐进加载设计

创建 Skill 时必须遵循三层加载：

```
Level 1（~100 tokens）: frontmatter — name + description
Level 2（<5k tokens）: SKILL.md 正文 — 流程 + 规则
Level 3（按需加载）: 同目录下的 reference.md / convention.md / 脚本
```

**设计要点**：
- `description` 精准描述功能 + 触发场景（这是 L1 的全部）
- SKILL.md 控制在 500 行以内，超出拆到 L3 文件
- L3 文件用 `$CLAUDE_SKILL_DIR` 引用：`$CLAUDE_SKILL_DIR/reference.md`

### 目录式 Skill 完整结构

```
.claude/skills/<name>/
├── SKILL.md           ← 必须有，核心流程 + 规则（< 500 行）
├── reference.md       ← 可选，完整模板、输出格式、代码示例
├── convention.md      ← 可选，跨语言规范、命名约定
├── scan-*.sh          ← 可选，扫描/分析脚本
├── check-*.sh         ← 可选，质量检查脚本
└── list-*.sh          ← 可选，列表/查询脚本
```

---

## 模板 1：简单命令（单文件）

```markdown
---
description: <命令描述，动词开头，10-30 词，包含触发场景>
argument-hint: "[可选参数提示，[] 标记可选，<> 标记必选]"
disable-model-invocation: false
user-invocable: true
allowed-tools:
  - Bash
  - Read
agent: general-purpose
shell: bash
paths:
  - "**/*.ts"
---

<命令执行逻辑>

$ARGUMENTS
```

### frontmatter 字段速查

| 字段 | 必填 | 说明 |
|------|------|------|
| `description` | 否 | 命令描述，显示在 /help 列表。**最重要** — CC 依此调度 |
| `argument-hint` | 否 | 参数提示格式，帮助用户理解传参 |
| `disable-model-invocation` | 否 | `true` 时禁用模型自动触发，只允许用户手动 `/name` 调用 |
| `user-invocable` | 否 | `false` 时从 `/` 菜单隐藏，适合背景知识类 Skill |
| `allowed-tools` | 否 | 执行时额外允许的工具（未指定则继承默认） |
| `agent` | 否 | 使用的 agent 类型（默认 `general-purpose`，可指向自定义 Agent） |
| `model` | 否 | Skill 触发时使用的模型（如 `sonnet` / `opus` / `haiku` / `inherit`） |
| `context` | 否 | `fork` 时在隔离子代理上下文运行 |
| `hooks` | 否 | 仅在该 Skill 激活时生效的局部 hooks |
| `paths` | 否 | 条件匹配路径（只影响自动推荐，不阻止手动调用） |
| `shell` | 否 | `bash`（默认）或 `powershell` |

### 可用变量

| 变量 | 说明 | 替换时机 |
|------|------|---------|
| `$ARGUMENTS` | 用户传入的参数，无输入时为空字符串 | 加载时替换 |
| `$CLAUDE_SKILL_DIR` | 当前 Skill 的目录绝对路径 | 加载时替换 |
| `$CLAUDE_SESSION_ID` | 当前会话 ID | 加载时替换 |

### `` ```! ``` `` 代码块限制（重要）

| 场景 | 能用 `` ```! ``` `` | 必须改为文字指令 |
|------|---------------------|-----------------|
| 简单固定命令 | `npm test`、`git status`、`date` | — |
| 含 `$VAR` 变量 | - | 改为文字："使用 Bash 执行 `bash $CLAUDE_SKILL_DIR/script.sh`" |
| 复杂 if/for 循环 | - | 改为文字："使用 Bash 按顺序执行以下命令" |
| 需要条件判断 | - | 改为文字指令让 Claude 判断后调用 Bash |

---

## 模板 2：目录式 Skill（标准骨架）

```markdown
---
name: <skill-name>
description: <功能描述。当 [场景] 或用户提到 [关键词] 时使用>
argument-hint: "<必选参数> [可选参数]"
user-invocable: true
disable-model-invocation: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

你是一个<角色定义>。用户输入<输入说明>，你的任务是<核心任务>。

## 第零步：收集上下文（可选）

使用 Bash 工具执行以下命令，收集项目信息：

1. **项目结构**：`bash $CLAUDE_SKILL_DIR/list-structure.sh`
2. **技术栈**：`bash $CLAUDE_SKILL_DIR/list-tech-stack.sh`

## 核心原则

- <原则 1>
- <原则 2>
- <原则 3>

## 工作流程

### 第一步：<阶段名>
### 第二步：<阶段名>
### 第三步：<阶段名>
### 第四步：<阶段名>

## 输出文件结构

<定义输出目录和文件命名规则>

## 关键规则

1. **<规则摘要>** — <详细说明>
2. ...

$ARGUMENTS
```

---

## 模板 3：流水线 Skill（带 manifest.json）

用于需要上下游协作的 Skill。

```markdown
---
name: <skill-name>
description: <功能描述>。接收 <上游 Skill 名称> 的输出，生成 <输出物>
argument-hint: "<上游报告目录路径>"
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

你是一个<角色定义>。你会接收<上游 Skill> 生成的报告目录，<核心任务>。

## 第零步：收集项目上下文

使用 Bash 工具执行以下命令：
1. **项目结构**：`bash $CLAUDE_SKILL_DIR/list-structure.sh`
2. **已有报告**：`bash $CLAUDE_SKILL_DIR/list-reports.sh`

---

## 核心原则

- <原则 1>
- <原则 2>

## 工作流程

### 第一步：读取上游数据

1. **读取上游 manifest.json**（优先）— 快速获取模块、语言、统计数据
2. 读取上游 README.md — 获取速览卡
3. 按需读取上游详情文件

### 第二步：交叉分析/处理

### 第三步：确认输出范围

使用 AskUserQuestion 向用户确认：
1. **报告保存目录**：从上游路径推导需求根目录，输出到 `<需求根目录>/<编号>-<简称>/`
2. **涉及范围**：让用户确认

### 第四步：生成报告文件

先在对话中输出完整结果，然后按文件结构写入。

---

## 输出文件结构

```
<需求根目录>/<编号>-<简称>/
├── README.md          ← 速览卡 + 目录 + 概览
├── <详情文件>.md       ← 各模块/步骤详情
├── SUMMARY.md         ← 汇总 + 建议
└── manifest.json      ← 流水线契约（供下游 Skill 读取）
```

## manifest.json 模板

```json
{
  "type": "<skill-name>",
  "version": "1.0",
  "generated_at": "YYYY-MM-DD HH:mm",
  "source_<upstream>": "<上游目录名>",
  "modules": [...],
  "statistics": {...},
  "languages": [...]
}
```

**用途**：下游 Skill 读取此文件，无需解析 Markdown 即可获取元数据。

## 关键规则

1. **先读 manifest.json** — 优先读取上游契约文件
2. **速览卡必须** — README.md 开头必须有速览卡
3. **文件命名与上游对应** — 编号和简称保持一致
4. **先分析后生成** — 先在对话中输出，再写入文件
5. ...

$ARGUMENTS
```

### 流水线编号约定

| 位置 | 编号 | 示例 |
|------|------|------|
| 第一个 Skill | 01- | `01-breakdown/` |
| 第二个 Skill | 02- | `02-reuse/` |
| 第三个 Skill | 03- | `03-plan/` |
| 第四个 Skill | 04- | `04-report/` |
| ... | 递增 | `05-xxx/` |

---

## 模板 4：带 L3 参考文件的 Skill

当 SKILL.md 正文超过 500 行时，将模板/规范拆到 L3 文件。

**SKILL.md**（精简版，< 500 行）：

```markdown
---
name: <skill-name>
description: <描述>
argument-hint: "<参数>"
allowed-tools: [...]
---

<角色定义 + 核心流程>

## 工作流程

### 第一步：加载规范
读取 `$CLAUDE_SKILL_DIR/convention.md` — 获取跨语言统一规范。

### 第二步：扫描目标
使用 Bash 工具执行：`bash $CLAUDE_SKILL_DIR/scan-targets.sh <path>`

### 第三步：生成内容
按照 `convention.md` 中的模板生成输出。

### 第四步：质量检查
使用 Bash 工具执行：`bash $CLAUDE_SKILL_DIR/check-deliverables.sh <path>`

## 关键规则

1. 所有模板和规范见 `convention.md`
2. ...

$ARGUMENTS
```

**convention.md**（L3 参考文件，不限长度）：

```markdown
# 统一规范

## 一、核心原则
## 二、文件映射规则
## 三、各语言模板
## ...
```

---

## 模板 5：指定自定义 Agent 的 Skill

```markdown
---
description: Pull request review with code-reviewer agent
argument-hint: "<PR number or branch name>"
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
agent: code-reviewer
---

Review the pull request and provide detailed analysis.

$ARGUMENTS
```

---

## 模板 6：在隔离上下文（fork）运行 Skill

```markdown
---
name: <skill-name>
description: <描述>
context: fork
agent: Explore
allowed-tools:
  - Read
  - Grep
  - Glob
---

<在隔离上下文中的任务说明>

$ARGUMENTS
```

适用场景：
- 高噪声任务（大日志、全仓扫描）避免污染主对话
- 需要固定 agent 类型和工具边界的任务

---

## 模板 7：Windows PowerShell Skill

```markdown
---
description: Check project health and dependencies
argument-hint: "[full|quick]"
allowed-tools:
  - Bash
  - Read
shell: powershell
---

Check the project health status.

$ARGUMENTS
```

---

## Skill vs Agent 选择指南

| 场景 | 用 Skill | 用 Agent |
|------|---------|---------|
| 用户主动触发（/命令） | Skill | — |
| 被主 Agent 自动调度 | — | Agent |
| 固定流程执行 | Skill | — |
| 需要多轮对话推理 | — | Agent |
| 需要独立工具集和权限 | — | Agent |
| 简单自动化任务 | Skill | — |
| 复杂分析 + 修改代码 | — | Agent |
| 两者的桥梁 | Skill 的 `agent` 字段可指向 Agent | — |

## Skill 编写要点

1. **description 精准** — 动词开头，10-30 词，包含触发场景和关键词
2. **argument-hint 清晰** — `[]` 可选，`<>` 必选
3. **自动/手动触发要显式控制** — `disable-model-invocation` 与 `user-invocable` 不可混用混乱
4. **allowed-tools 最小化** — 只列真正需要的工具
5. **$ARGUMENTS 放末尾** — 作为用户额外指令的注入点
6. **$CLAUDE_SKILL_DIR 引用资源** — 引用同目录下的脚本和参考文件
7. **SKILL.md < 500 行** — 超出拆到 reference.md / convention.md
8. **流水线必须有 manifest.json** — 上下游通过 JSON 契约传递元数据
9. **速览卡必须** — README.md 开头有统计数据和核心发现
10. **先分析后写入** — 先在对话中输出，再写入文件
11. **避免 `` ```! ``` `` 陷阱** — 不在其中使用变量和复杂语法

---

## 模板 8：动态上下文注入 Skill（!`command` 语法）

在发给 Claude 之前，CC 会执行内联命令并将输出替换到 Skill 内容中：

```markdown
---
name: pr-summary
description: 分析当前 PR 改动，生成摘要和风险清单。使用 GitHub CLI 拉取实时数据。
context: fork
agent: Explore
allowed-tools: Bash(gh:*)
disable-model-invocation: true
---

## Pull Request 实时信息

- **改动文件**：!`gh pr diff --name-only`
- **PR 描述**：!`gh pr view --json title,body -q '"标题: \(.title)\n描述: \(.body)"'`
- **评论摘要**：!`gh pr view --comments --json comments -q '.comments | length | "共 \(.) 条评论"'`

## 分析任务

基于以上实时信息，用中文给出：
1. 改动摘要（不超过 3 句）
2. 风险点（如有）
3. 建议验证清单

$ARGUMENTS
```

**语法说明**：
- `` !`command` `` — 内联语法，单行命令
- Claude 看到的是已执行的输出，不是命令本身
- 只有命令的 stdout 进入上下文，stderr 被忽略
- 适合注入：git diff、gh pr、环境信息、配置文件内容等实时数据

---

## 模板 9：Skill 专属 Hooks（frontmatter 中定义）

Skill 激活期间生效，Skill 结束后自动清理：

```markdown
---
name: safe-editor
description: 带安全检查和自动 lint 的文件编辑 Skill
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: |
            INPUT=$(cat)
            FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
            # 阻止编辑敏感文件
            if [[ "$FILE" =~ \.(env|secret|pem|key)$ ]]; then
              echo "禁止编辑敏感文件: $FILE" >&2
              exit 2
            fi
          once: false
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: |
            INPUT=$(cat)
            FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
            if [[ "$FILE" =~ \.(ts|tsx)$ ]]; then
              npx eslint --fix "$FILE" 2>/dev/null
              echo "{\"additionalContext\": \"Auto-linted: $FILE\"}"
            fi
          async: true
          once: false
---

编辑文件时自动进行安全检查和 lint。

$ARGUMENTS
```

**`once: true` 说明**：仅执行一次后自动移除，适合"首次运行时的一次性检查"（当前仅 Skill hooks 支持，不适用于 agents）。

---

## context:fork 完整决策指南

### 何时用

```
✓ 高噪声操作（大量 stdout，不想污染主对话）
✓ 需要专属工具边界（如只读代理）
✓ 配合 !`command` 注入实时数据
✓ 返回结构化摘要给主对话

✗ 纯背景知识/规范注入（得不到有效产出）
✗ 需要和主对话频繁交互
✗ 简单的格式化/风格提示
```

### 配置组合

```yaml
# 只读探索（最常用）
context: fork
agent: Explore

# 通用多步操作
context: fork
agent: general-purpose

# 指向自定义 Agent
context: fork
agent: code-reviewer     # 引用 .claude/agents/code-reviewer.md

# 不指定 agent（使用默认）
context: fork
```

### 与触发控制结合

```yaml
# 只能手动触发的隔离分析
context: fork
agent: Explore
disable-model-invocation: true   # 防止模型自动触发高成本操作
```
