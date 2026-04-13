# Team Skills Index

> zwyAi 项目 Claude Code 技能索引

## Usage Principles

- 每个 Skill 独立使用，也可组成流水线
- 流水线 Skill 按编号顺序调用，上游输出是下游输入
- 所有流水线 Skill 共享同一需求根目录 `/doc/ai-coding/YYYYMMDD-HHmmss-<需求简述>/`

## Skills by Category

### 流水线技能（新功能开发）

按顺序调用，组成完整的"需求→实现"流水线：

| Skill | 一句话用途 | 调用方式 |
|-------|----------|---------|
| task-breakdown | 将功能需求拆解为最小功能单元 | `/task-breakdown 需求描述` |
| code-reuse-finder | 查找可复用的现有代码 | `/code-reuse-finder 拆解报告路径` |
| impl-planner | 生成分步执行计划 | `/impl-planner 拆解报告路径 复用报告路径` |
| code-implementer | 按计划严格实现代码 | `/code-implementer 执行计划路径` |

### 质量保障

| Skill | 一句话用途 | 调用方式 |
|-------|----------|---------|
| code-tester | 生成全覆盖测试用例并运行，沉淀缺陷/漏洞与 05-test 测试报告 | `/code-tester 源文件或目录路径` |

### 持续学习

| Skill | 一句话用途 | 调用方式 |
|-------|----------|---------|
| learn | 从会话中提取可复用模式，沉淀为个人 Skill | `/learn`（回顾）/ `/learn 记下来 <描述>`（即时）/ `/learn 修正 <skill名> <描述>` |

模式库文件（`learn/` 目录下）：
- `debug.md` — 调试排错模式
- `refactor.md` — 重构手法
- `architecture.md` — 架构设计模式
- `snippets.md` — 代码片段/模板

### 网络调研

| Skill | 一句话用途 | 调用方式 |
|-------|----------|---------|
| web-research | 网络调研与资料收集，支持技术调研/通用收集/方案对比 | `/web-research <主题> [tech\|compare\|general] [--save]` |

### 开发辅助

| Skill | 一句话用途 | 调用方式 |
|-------|----------|---------|
| trace-call-chain | 追踪 bug 调用链路 | `/trace-call-chain bug 描述` |
| git-push | 智能归类提交推送 | `/git-push` |
| cc-architect | 创建和管理 CC 配置 | `/cc-architect 需求描述` |

## Recommended Combinations

| 任务类型 | 推荐组合 |
|---------|---------|
| 新功能完整开发 | /task-breakdown → /code-reuse-finder → /impl-planner → /code-implementer → /code-tester |
| 快速功能开发（跳过复用分析） | /task-breakdown → /impl-planner → /code-implementer |
| Bug 修复 | /trace-call-chain → 手动修复 → /code-tester |
| 代码测试 | /code-tester <目标路径> |
| 提交推送 | /git-push |
| CC 配置管理 | /cc-architect <需求> |
| 沉淀开发模式 | /learn（回顾会话）或 /learn 记下来 <描述>（即时捕获） |
| 修正 Skill 行为 | /learn 修正 <skill名> <描述> |
| 技术调研 | /web-research <主题> tech |
| 方案选型对比 | /web-research <主题> compare |
| 通用资料收集 | /web-research <主题> general |

## Pipeline Flow

```
用户需求
  ↓
/task-breakdown ──→ 01-breakdown/ (拆解报告 + manifest.json)
  ↓
/code-reuse-finder ──→ 02-reuse/ (复用报告 + manifest.json)
  ↓
/impl-planner ──→ 03-plan/ (执行计划 + manifest.json)
  ↓
/code-implementer ──→ 04-report/ (实现报告) + 模块 CLAUDE.md 同步（架构图 + Review 清单）
  ↓
/code-tester ──→ 05-test/ (测试报告 + BUG-DEFECTS.md + SECURITY-FINDINGS.md + manifest.json) + 测试文件
```

每个 Skill 输出的 `manifest.json` 是流水线的契约文件，下游 Skill 优先读取它获取元数据。

### 流水线交付物说明

| 阶段 | 关键交付物 | 说明 |
|------|-----------|------|
| 04-report | 模块 CLAUDE.md | code-implementer 完成后必须同步：底层模块写"谁会用我"，上层模块画 Mermaid 依赖图，所有层级包含 Review 检查清单 |
| 05-test | BUG-DEFECTS.md | 测试目录 + `/doc/ai-coding/.../05-test/` 同步，包含关联源文件:行号、建议修复方向 |
| 05-test | SECURITY-FINDINGS.md | 测试目录 + `/doc/ai-coding/.../05-test/` 同步，包含风险级别定义、缓解措施 |

## Maintenance Rules

- 新增/修改 Skill 后必须更新此索引
- 保持每个 Skill 的 description 与索引中的描述一致
- 流水线新增环节时更新 Pipeline Flow 图
- 辅助文件（reference.md、convention.md）变动不影响此索引
