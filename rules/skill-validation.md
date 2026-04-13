---
paths:
  - "**"
---

# Skill 输出强制验证规则

> **目标**: 将 Skill 的事后检查从"建议执行"升级为"强制触发"
> **机制**: Hook 机械检查 + Skill 内部脚本调用 + 用户明确确认
> **原则**: 约束 > 指导 | 验证失败则阻断下游

---

## 核心约束

### 约束一：每个流水线 Skill 必须有后置验证

以下 Skill 执行完毕后，**必须**通过验证才能视为完成：

| Skill | 验证方式 | 触发时机 | 失败处理 |
|------|---------|---------|---------|
| `task-breakdown` | `validate-breakdown.sh` | 生成文件后 | 修正报告后再进入复用阶段 |
| `code-reuse-finder` | `validate-reuse.sh` | 生成文件后 | 补充复用分析后再进入计划阶段 |
| `impl-planner` | `validate-plan.sh` + `skill-gate` Hook | 生成 manifest.json 时 | 补全缺失文件后再进入实现阶段 |
| `code-implementer` | 每步质量门禁 + `skill-gate` Hook | 每步完成后 + 报告生成后 | 重试 3 次仍失败则停止并记录 |
| `code-tester` | `check-deliverables.sh` + `skill-gate` Hook | 测试文件写入后 + 最终交付前 | 补全缺失项后再标记完成 |

### 约束二：Hook 自动触发不可绕过

`.claude/hooks/skill-gate/` 中的脚本会在 `PostToolUse` Hook 中自动运行：
- `impl-planner` 写入 `03-plan/manifest.json` → 自动检查必需文件完整性
- `code-tester` 写入 `*/test/` 下测试文件 → 自动检查 `.claude/module-test/` 镜像是否存在
- `code-implementer` 写入 `04-report/` 下报告 → 自动检查 `implementation-logs/` 是否存在

**Hook 输出非空时**，视为验证警告，必须在对话中向用户明确说明，并在修正后才能继续下游操作。

### 约束三：验证失败时的处理流程

当验证未通过时，按以下优先级处理：

1. **自动修复**（如格式化失败自动重跑）
2. **局部修正**（只修改有问题的部分，不返工整个 Skill 输出）
3. **记录修正**（如果问题反映了 Skill 本身的缺陷，写入 `corrections.md`）
4. **人工确认**（3 次自动修复仍失败，停下来向用户报告）

### 约束四：Skill 优化采用"记录 → 下次生效"模式

当用户对 Skill 输出不满意时：

- **单次对话中**：先修正当前输出，确保用户任务不中断
- **对话末尾或自然停顿点**：自动分析根因，如果属于 Skill 规则缺陷，记录到 `corrections.md`
- **下次调用该 Skill 时**：`load-corrections.sh` 自动加载，行为立即改变
- **积累 3 条以上**：主动提示用户运行 `/learn 应用修正` 固化到 SKILL.md

**为什么不在单次对话中"先优化 Skill 再执行"？**
- 打断当前任务流，用户体验差
- Skill 的修正可能需要重写 SKILL.md，属于较重的配置变更
- "记录 → 下次生效"既能保证任务完成，又能实现持续进化

**例外**：如果当前错误是**结构性/安全性问题**（如生成了错误目录、遗漏了必要交付物），必须**立即停止**，修正 Skill 规则后重新执行。

---

## 主动触发机制

以下信号出现时，本规则配合 `auto-learn.md` 和 `learn` Skill 自动工作：

| 信号 | 检测方 | 动作 |
|------|--------|------|
| 用户说"不对"、"重做"、"少了" | `auto-learn.md` | 提示记录修正，写入 `corrections.md` |
| 验证脚本返回非零 | `skill-gate` Hook | 输出警告，要求修正后才能继续 |
| 同一文件被编辑 3+ 次 | `session-end.sh` | 写入 `pending-reviews.md`，提示 Skill 可能不匹配 |
| 修正记录满 3 条 | `learn` Skill | 主动提示 `/learn 应用修正` |

---

## 关键原则

- **Hook 是机械约束，Skill 是逻辑约束，用户确认是最终约束**
- **验证失败不是终点，而是修正的起点**
- **不完美的输出 + 及时的修正记录 > 完美的输出 + 没有进化**
