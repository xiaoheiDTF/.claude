# Skill 设计深度指南

> cc-architect 的 Level 3 资源文件。创建/优化 Skill 时按需读取。
> 基于 Claude Code 官方文档和 Agent 技能体系最佳实践整理。

---

## 一、渐进加载架构（核心设计理念）

### 三层加载模型

```
┌─────────────────────────────────────────────────────┐
│ Level 1: 元数据（启动时加载，~100 tokens/skill）      │
│   = frontmatter 中的 description + name              │
│   = CC 决定"是否使用此 Skill"的依据                   │
├─────────────────────────────────────────────────────┤
│ Level 2: 指令（任务匹配时加载，<5k tokens）            │
│   = SKILL.md 正文（流程 + 规则 + 模板引用）           │
│   = Claude 执行任务时的完整行为指南                    │
├─────────────────────────────────────────────────────┤
│ Level 3: 资源（按需加载，通过文件系统访问）             │
│   = reference.md / convention.md / 脚本文件           │
│   = Claude 用 Read 工具按需读取                       │
└─────────────────────────────────────────────────────┘
```

### Token 预算分配

| 层级 | 预算 | 包含内容 | 加载时机 |
|------|------|---------|---------|
| L1 元数据 | ~100 tokens | name + description | CC 启动时，所有 skill 都加载 |
| L2 指令 | <5k tokens | 工作流程 + 核心规则 + 模板骨架 | 用户调用此 skill 时 |
| L3 资源 | 不限 | 完整模板、代码示例、规范文档 | Claude 用 Read 工具按需读取 |

**设计 implication**：
- description 越精准，L1 token 浪费越少
- SKILL.md 越精简，L2 加载越快
- 复杂内容放 L3（同目录下的 reference.md），用 `$CLAUDE_SKILL_DIR` 引用

---

## 二、Description 编写艺术

description 是 Skill 最重要的字段 — 它是 Claude 决定何时调用此 Skill 的唯一依据。

### 编写公式

```
"[功能描述]. Use when [触发场景] or when the user mentions [关键词]"

中文版："[功能描述]。当 [触发场景] 或用户提到 [关键词] 时使用"
```

### 好的 description（精准匹配）

```yaml
# 精准 — 包含动词 + 场景 + 关键词
description: "根据 bug 修复需求追踪代码调用链路，定位相关文件的绝对路径和行号范围"

# 触发场景明确
description: "为指定源码文件生成全覆盖测试用例，运行测试并记录结果，支持人机协作验证"

# 流水线角色清晰
description: "根据拆解报告和复用报告生成严格的分步执行计划，供 code-implementer 按序执行"
```

### 坏的 description（模糊不匹配）

```yaml
# 太模糊 — 无法被匹配
description: "Helps with stuff"

# 太抽象 — 缺少触发关键词
description: "代码分析工具"

# 太冗长 — 浪费 token
description: "这个技能可以帮助你分析整个项目的代码结构，找出其中的问题，并给出优化建议。它支持多种编程语言，包括 TypeScript、Python、Java 等..."
```

### Description 优化检查

| 检查项 | 标准 |
|--------|------|
| 是否动词开头 | "追踪..."、"生成..."、"分析..." |
| 是否包含触发关键词 | 用户会用到的词（bug、测试、复用、计划） |
| 是否说明输出物 | "定位文件和行号"、"生成测试用例"、"输出执行计划" |
| 长度是否合适 | 1-2 句话，不超过 1024 字符 |
| 是否能区分于其他 Skill | 同一项目的多个 Skill 描述不应重叠 |

---

## 三、SKILL.md 正文结构

### 标准骨架

```markdown
---
name: <skill-name>
description: <精准描述>
argument-hint: "<参数提示>"
user-invocable: true
allowed-tools:
  - <需要的工具>
---

<一句话角色定义 + 核心任务>

## 核心原则
- <3-5 条不可违反的约束>

## 工作流程

### 第一步：收集上下文
### 第二步：分析/处理
### 第三步：生成/执行
### 第四步：验证/输出

## 输出文件结构（如有文件输出）
## 模板（如需要）
## 关键规则（编号列表，简洁）

$ARGUMENTS
```

### 各模块 token 控制

| 模块 | 建议 token 数 | 说明 |
|------|-------------|------|
| 角色定义 | ~50 | 一句话 |
| 核心原则 | ~200 | 3-5 条 |
| 工作流程 | ~2000 | 步骤 + 决策点 |
| 模板 | ~1500 | 放不下就拆到 reference.md |
| 关键规则 | ~300 | 编号列表 |

**总计 <5000 tokens，对应 SKILL.md 约 300-400 行**

---

## 四、流水线设计模式

### 什么是 Skill 流水线

多个 Skill 按顺序协作，前一个的输出是后一个的输入：

```
task-breakdown → code-reuse-finder → impl-planner → code-implementer → code-tester
     ↓                  ↓                  ↓                ↓
 01-breakdown/      02-reuse/        03-plan/         04-report/
```

### 流水线核心机制

#### 1. 目录约定

```
doc/ai-coding/YYYYMMDD-HHmmss-<需求简述>/    ← 需求根目录（整个流水线共享）
├── 01-breakdown/    ← Skill A 生成
├── 02-reuse/        ← Skill B 生成
├── 03-plan/         ← Skill C 生成
├── 04-report/       ← Skill D 生成
└── ...              ← 更多 Skill 继续追加
```

每个 Skill 在同一需求根目录下生成自己的编号子目录。

#### 2. manifest.json 契约

**这是流水线的血液** — 每个 Skill 输出目录中必须包含一个 `manifest.json`，供下游 Skill 快速获取元数据。

```json
{
  "type": "<skill-name>",
  "version": "1.0",
  "generated_at": "YYYY-MM-DD HH:mm",
  "source_<upstream>": "<上游目录名>",
  "modules": [...],
  "languages": [...],
  "statistics": {...}
}
```

**下游 Skill 读取优先级**：
1. 先读上游 `manifest.json`（机器可读，快速获取元数据）
2. 按需读上游 `README.md`（速览卡）
3. 按需读上游详情文件（具体内容）

#### 3. 速览卡

每个 Skill 的 README.md 开头必须有速览卡：

```markdown
## 速览卡

**核心目标**: <一句话>
**规模**: X 个模块 / X 个步骤
**关键约束**: <2-3 条>
```

#### 4. 文件命名规范

```
模块文件: {前缀}{编号}-{简称}.md
  拆解报告: M0-基础设施.md, M1-状态模型.md
  复用报告: R0-基础设施.md, R1-状态模型.md
  执行计划: S01-定义接口.md, S02-实现逻辑.md
  实现报告: I01-接口定义.md, I02-逻辑实现.md
```

前缀按 Skill 类型区分，编号保持与上游一致。

### 设计新流水线 Skill 时

1. 确定在流水线中的位置（上游/下游/独立）
2. 如有上游，定义从上游读取哪些数据
3. 定义输出目录编号和文件结构
4. 设计 manifest.json 的字段
5. 在 SKILL.md 的"工作流程"中明确上游数据读取步骤

---

## 五、Skill 拆分与合并策略

### 何时拆分为多个 Skill

| 信号 | 说明 |
|------|------|
| SKILL.md 超过 500 行 | 强制拆分 |
| 一个 Skill 有多个独立入口 | 拆为多个 Skill |
| 工作流程有明显阶段分界 | 每个阶段一个 Skill |
| 不同用户角色使用不同部分 | 按角色拆分 |

### 何时拆分为多文件（同 Skill）

| 信号 | 说明 |
|------|------|
| 模板内容超过 SKILL.md 的 30% | 模板拆到 `reference.md` |
| 有跨语言规范 | 拆到 `convention.md` |
| 有可执行脚本 | 拆到 `.sh` / `.py` 文件 |

### 拆分方式

```
.claude/skills/<name>/
├── SKILL.md           ← 核心流程 + 规则（< 500 行）
├── reference.md       ← 完整模板、代码示例、输出格式
├── convention.md      ← 跨语言规范、命名约定
├── scan-*.sh          ← 扫描脚本
└── check-*.sh         ← 检查脚本
```

SKILL.md 中引用拆分文件的方式：
- "详细模板见 `$CLAUDE_SKILL_DIR/reference.md`"
- "使用 Bash 工具执行：`bash $CLAUDE_SKILL_DIR/scan-targets.sh <path>`"

---

## 六、常见反模式与修正

### 反模式 1：巨型 SKILL.md

```
问题：SKILL.md 800+ 行，所有内容塞在一个文件
后果：每次调用加载大量 token，慢且贵
修正：拆分为 SKILL.md（流程）+ reference.md（模板）+ convention.md（规范）
```

### 反模式 2：模糊 description

```
问题：description = "代码分析工具"
后果：Claude 无法判断何时该调用，要么永远不用要么乱用
修正：description = "根据 bug 修复需求追踪代码调用链路，定位相关文件的绝对路径和行号范围"
```

### 反模式 3：`` ```! ``` `` 中使用变量

```
问题：```! bash $CLAUDE_SKILL_DIR/script.sh ```
后果：权限预检查报错 "Contains simple_expansion"
修正：改为文字指令 — "使用 Bash 工具执行 bash $CLAUDE_SKILL_DIR/script.sh"
```

### 反模式 4：流水线缺少 manifest.json

```
问题：上下游 Skill 通过解析 Markdown 传递数据
后果：脆弱、慢、容易出错
修正：每个 Skill 输出 manifest.json，下游先读 JSON 获取元数据
```

### 反模式 5：所有规则放一个文件

```
问题：一个 SKILL.md 包含编码规范 + 测试规范 + 部署规范
后果：加载时 token 浪费大
修正：用 paths 条件规则拆分为多个 Rule 文件，按需加载
```

### 反模式 6：重复已有 Skill 功能

```
问题：新 Skill 与现有 Skill 功能重叠
后果：调度混乱，用户不知道用哪个
修正：创建前先检查已有 Skill，复用或扩展现有 Skill
```

---

## 七、Skill 优化检查清单

当用户要求优化现有 Skill 时，按此清单逐项检查：

### 结构检查

- [ ] SKILL.md 是否 < 500 行？（超出则拆分）
- [ ] 是否有 L3 参考文件？（模板/规范是否在独立文件中）
- [ ] 文件目录结构是否清晰？（SKILL.md + 辅助文件）

### 元数据检查

- [ ] description 是否动词开头、包含触发关键词？
- [ ] argument-hint 是否标注了必选 `<>` / 可选 `[]`？
- [ ] allowed-tools 是否最小化？
- [ ] name 是否简短有意义（< 64 字符，kebab-case）？

### 内容检查

- [ ] 是否包含三要素：When to Use / Patterns / Checklist？
- [ ] 工作流程是否分步骤，每步有明确输出？
- [ ] 关键规则是否用编号列表（简洁可执行）？
- [ ] 是否正确使用 `$ARGUMENTS`、`$CLAUDE_SKILL_DIR`？
- [ ] 是否避免了 `` ```! ``` `` 中的变量和复杂语法？

### 流水线检查（如适用）

- [ ] 是否生成 manifest.json？
- [ ] 是否读取上游 manifest.json（如有上游）？
- [ ] 输出目录编号是否与流水线位置一致？
- [ ] README.md 是否有速览卡？
- [ ] 文件命名是否与上游保持对应？

### Token 效率检查

- [ ] description 是否简洁精准（~100 tokens）？
- [ ] SKILL.md 正文是否精简（< 5k tokens）？
- [ ] 大段模板/示例是否拆到 L3 文件？
- [ ] 是否有不必要的重复内容？

---

## 八、Skill 类型与选择指南

| 用户需求 | 推荐类型 | 说明 |
|---------|---------|------|
| 用户主动触发的动作 | Skill（`/command`） | `/commit`、`/test`、`/deploy` |
| 固定流程的多步骤任务 | 目录式 Skill | 带脚本资源的复杂 Skill |
| 被主 Agent 自动调度 | Agent | 需要独立工具集和权限 |
| 一次性的简单命令 | 单文件 Command | `.claude/commands/*.md` |
| 可复用的复杂能力 | 目录式 Skill | `.claude/skills/*/SKILL.md` |
| 多 Skill 协作 | 流水线 | manifest.json 串联 |

### Skill vs Agent 选择

| 维度 | 用 Skill | 用 Agent |
|------|---------|---------|
| 触发方式 | 用户主动 `/` | 主 Agent 自动调度 |
| 执行模式 | 固定流程 | 多轮推理 |
| 权限控制 | allowed-tools | tools / disallowedTools |
| 模型选择 | 跟随用户 | 可独立指定 model |
| 记忆 | 无 | 可配 memory |
| 独立性 | 在主对话中执行 | 独立上下文 |
| 桥梁 | Skill 的 `agent` 字段可指向 Agent | — |

---

## 九、团队 Skills 索引模板

当项目有多个 Skill 时，建议创建 `.claude/skills/README.md` 作为团队索引：

```markdown
# Team Skills Index

## Usage Principles
- 每个 Skill 独立使用，也可组成流水线
- 流水线 Skill 按编号顺序调用

## Skills by Category

| Skill | 一句话用途 | 调用方式 |
|-------|----------|---------|
| task-breakdown | 将功能需求拆解为最小功能单元 | `/task-breakdown 需求描述` |
| code-reuse-finder | 查找可复用的现有代码 | `/code-reuse-finder 拆解报告路径` |
| impl-planner | 生成分步执行计划 | `/impl-planner 拆解报告路径 复用报告路径` |
| code-implementer | 按计划严格实现代码 | `/code-implementer 执行计划路径` |
| code-tester | 生成全覆盖测试用例 | `/code-tester 源文件或目录路径` |
| trace-call-chain | 追踪 bug 调用链路 | `/trace-call-chain bug 描述` |
| git-push | 智能归类提交推送 | `/git-push` |

## Recommended Combinations

| 任务类型 | 推荐组合 |
|---------|---------|
| 新功能开发 | /task-breakdown → /code-reuse-finder → /impl-planner → /code-implementer → /code-tester |
| Bug 修复 | /trace-call-chain → 手动修复 → /code-tester |
| 快速提交 | /git-push |
| 代码测试 | /code-tester <目标路径> |

## Maintenance Rules
- 新增/修改 Skill 后必须更新此索引
- 保持每个 Skill 的 description 与索引中的描述一致
```
