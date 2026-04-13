# Skills 体系导航

> **定位**: Claude Code Skills 的导航地图（Harness Engineering 原则：地图 > 手册）  
> **原则**: 约束 > 指导 | 机械化验证 > 文档规范 | 渐进式披露  
> **理论基础**: `.claude/doc/harness-engineering/`

---

## 流水线 Skills（按顺序执行）

五个 Skills 组成完整的 AI 辅助开发流水线：

```
需求描述
    ↓
[1] task-breakdown      → 01-breakdown/
    ↓
[2] code-reuse-finder   → 02-reuse/
    ↓
[3] impl-planner        → 03-plan/
    ↓
[4] code-implementer    → 04-report/ + 实际代码
    ↓
[5] code-tester         → 05-test/ + 测试文件 + 缺陷/漏洞记录
```

### 1. task-breakdown — 需求拆解

| 项目 | 内容 |
|------|------|
| **触发** | `/task-breakdown <功能需求描述>` |
| **输入** | 功能需求文字描述 |
| **输出** | `01-breakdown/` 目录（README.md + M*.md + SUMMARY.md + manifest.json） |
| **验证** | `bash task-breakdown/scripts/validate-breakdown.sh <报告目录>` |
| **文档** | `task-breakdown/SKILL.md` |

### 2. code-reuse-finder — 代码复用查找

| 项目 | 内容 |
|------|------|
| **触发** | `/code-reuse-finder <拆解报告目录>` |
| **输入** | 拆解报告目录路径 |
| **输出** | `02-reuse/` 目录（README.md + R*.md + SUMMARY.md + manifest.json） |
| **验证** | `bash code-reuse-finder/scripts/validate-reuse.sh <报告目录>` |
| **文档** | `code-reuse-finder/SKILL.md` |

### 3. impl-planner — 执行计划生成

| 项目 | 内容 |
|------|------|
| **触发** | `/impl-planner <拆解报告目录> <复用报告目录>` |
| **输入** | 拆解报告目录 + 复用报告目录 |
| **输出** | `03-plan/` 目录（README.md + S*.md + ACCEPTANCE.md + manifest.json） |
| **验证** | `bash impl-planner/scripts/validate-plan.sh <报告目录>` |
| **文档** | `impl-planner/SKILL.md` |

### 4. code-implementer — 代码实现

| 项目 | 内容 |
|------|------|
| **触发** | `/code-implementer <执行计划目录>` |
| **输入** | 执行计划目录路径 |
| **输出** | `04-report/` 目录 + 实际代码文件 |
| **验证** | 每步完成后运行质量门禁（见 `code-implementer/SKILL.md`） |
| **文档** | `code-implementer/SKILL.md` |

### 5. code-tester — 测试验证与缺陷沉淀

| 项目 | 内容 |
|------|------|
| **触发** | `/code-tester <源码目录或文件路径>` |
| **输入** | 源码目录路径 / 源文件路径 / 接口路径 |
| **输出** | 测试目录（测试文件 + `run-tests.*` + README） + `05-test/`（测试报告 + 缺陷清单 + 漏洞清单 + manifest.json） |
| **验证** | `bash code-tester/check-deliverables.sh <测试目录>` |
| **文档** | `code-tester/SKILL.md` |

---

## 流水线契约验证

验证整个流水线各阶段的 manifest.json 契约一致性：

```bash
bash .claude/skills/scripts/validate-pipeline.sh <需求根目录>
```

示例：
```bash
bash .claude/skills/scripts/validate-pipeline.sh /doc/ai-coding/20250409-143000-CDP适配器
```

---

## 独立 Skills

| Skill | 触发 | 用途 |
|-------|------|------|
| **cc-architect** | `/cc-architect <需求>` | Claude Code 配置专家（agents/hooks/skills/rules） |
| **code-tester** | `/code-tester <路径>` | 为源码生成测试并沉淀缺陷/漏洞记录 |
| **git-push** | `/git-push` | 智能分析变更、生成 commit、推送 + PR |
| **trace-call-chain** | `/trace-call-chain <bug描述>` | 追踪代码调用链路，定位文件和行号 |
| **web-research** | `/web-research <主题>` | 网络调研，生成结构化报告 |
| **learn** | `/learn [模式]` | 从会话中提取模式，管理修正记录 |

---

## 闭环学习机制

每个 Skill 都内置了**第零步：加载修正记录**机制：

```bash
# 每次 Skill 启动时自动执行
bash $CLAUDE_SKILL_DIR/../learn/load-corrections.sh <skill-name>
```

**工作流程**：
1. 用户对 Skill 输出不满意 → 说"不对"/"重做"
2. `auto-learn.md` 规则检测到信号 → 提示记录修正
3. 修正写入 `learn/corrections.md`
4. 下次 Skill 启动时自动加载修正 → 行为改变
5. 积累 3 条后 → `/learn 应用修正` 固化到 SKILL.md

---

## Harness Engineering 原则

本 Skills 体系基于 Harness Engineering 理论设计：

| 原则 | 实现方式 |
|------|---------|
| **约束 > 指导** | 验证脚本（validate-*.sh）机械化检查 |
| **地图 > 手册** | 本文件（AGENTS.md）作为导航地图 |
| **渐进式披露** | SKILL.md 主文件 + reference.md 详情 |
| **仓库即操作系统** | 所有约束编码到脚本，版本化管理 |
| **闭环学习** | corrections.md + load-corrections.sh |

详细理论：`.claude/doc/harness-engineering/`

---

## 快速参考

### 完整流水线执行顺序

```bash
# 1. 需求拆解
/task-breakdown 实现用户登录功能

# 2. 复用查找（输入上一步的输出目录）
/code-reuse-finder /doc/ai-coding/20250409-143000-用户登录/01-breakdown

# 3. 执行计划（输入前两步的输出目录）
/impl-planner /doc/ai-coding/20250409-143000-用户登录/01-breakdown /doc/ai-coding/20250409-143000-用户登录/02-reuse

# 4. 代码实现（输入计划目录）
/code-implementer /doc/ai-coding/20250409-143000-用户登录/03-plan

# 5. 测试验证（输入源码目录）
/code-tester /src/core/xxx

# 验证整个流水线
bash .claude/skills/scripts/validate-pipeline.sh /doc/ai-coding/20250409-143000-用户登录
```

### 修正记录管理

```bash
/learn 查看修正          # 查看所有待应用修正
/learn 应用修正          # 批量应用修正到 SKILL.md
/learn 修正 task-breakdown 拆解粒度太细  # 手动记录修正
```
