---
paths:
  - "**"
---

# CLAUDE.md 守护规则

> **目标**: 确保项目中每个包含代码的目录都有规范的 `CLAUDE.md`
> **执行方式**: 通过 `/module-doc` Skill 进行扫描和修复
> **检查时机**: 目录结构变更后、代码实现完成后

---

## 核心约束

### 约束一：有代码就要有 CLAUDE.md

任何包含源码文件（`.py`, `.js`, `.ts`, `.vue`, `.java`, `.go`, `.rs` 等）的目录，**必须**存在 `CLAUDE.md`。

**例外目录**（无需 CLAUDE.md）：
- 依赖目录：`node_modules/`, `.venv/`, `vendor/`
- 构建输出：`dist/`, `build/`, `target/`, `out/`
- 缓存目录：`__pycache__/`, `.pytest_cache/`, `.cache/`
- 版本控制：`.git/`
- 配置目录：`.claude/` 自身
- 纯资源目录：只包含图片、字体、静态资源的目录

### 约束二：CLAUDE.md 必须包含 5 个核心段落

每个 `CLAUDE.md` 至少包含：
1. **位置** — 目录相对路径
2. **简介** — 一句话职责说明
3. **目录结构** — 当前目录下的文件/子目录清单及职责
4. **文件创建要求** — 命名规范、导出方式、特殊约束
5. **代码规范** — 引用 `.claude/rules/<语言>.md` 中的 3-5 条关键约束
6. **Review 检查清单**（可选但强烈推荐）— 至少 5 条可勾选的检查项

### 约束三：CLAUDE.md 必须与代码同步更新

当目录发生以下变更时，必须同步更新 `CLAUDE.md`：
- **新增子目录** → 更新"目录结构"段落
- **新增/删除关键文件** → 更新"目录结构"和"文件创建要求"
- **技术栈变更** → 更新"代码规范"段落
- **职责变更** → 更新"简介"段落

### 约束四：module-registry 必须作为镜像备份

`doc/module-registry/` 的目录结构必须与项目代码目录**完全一致**，其中的 `CLAUDE.md` 是项目中对应 `CLAUDE.md` 的镜像备份：
- 项目中 `travel-agent/app/models/CLAUDE.md` → registry 中 `doc/module-registry/travel-agent/app/models/CLAUDE.md`
- 项目中生成/修改 `CLAUDE.md` 后，**必须**同步复制到 `module-registry` 的对应路径
- `module-registry` 是全局检索、模板恢复和数据备份的数据源

---

## 主动检测信号

当对话中出现以下情况时，**主动提醒**用户检查 CLAUDE.md：

| 信号 | 提醒内容 |
|------|---------|
| 使用 `mkdir` 或 `Write` 新建了包含代码文件的目录 | "检测到新建目录，建议运行 `/module-doc 检查` 确保已生成 CLAUDE.md" |
| `code-implementer` 完成所有步骤 | "代码实现已完成，建议运行 `/module-doc 检查` 扫描 CLAUDE.md 遗漏" |
| `impl-planner` 生成计划并预创建目录 | "计划目录已创建，建议运行 `/module-doc 修复` 同步规范索引" |
| 用户提到"文档不同步"、"规范缺失"、"没有约束" | 立即运行 `/module-doc 检查` 并展示结果 |

---

## 调用规范

使用 `/module-doc` Skill 的三种模式：

```bash
# 检查全项目哪些目录缺少/过时 CLAUDE.md
/module-doc 检查

# 为缺失目录生成 CLAUDE.md 并同步 module-registry
/module-doc 生成

# 检查 + 自动补全不完整内容 + 同步索引
/module-doc 修复
```

---

## 与流水线 Skills 的集成

以下 Skill 必须在其工作流中嵌入对本规则的响应：

- **`code-implementer`**: 第四步"同步模块 CLAUDE.md"完成后，在最终报告中建议 `/module-doc 检查`
- **`impl-planner`**: 第十步"预创建目录和模块 CLAUDE.md"完成后，在最终输出中建议 `/module-doc 修复`
- **`task-breakdown`**: 在"模块设计对齐"步骤中，标注哪些目录需要新建 CLAUDE.md

---

## 质量门禁

机械化检查项（可通过脚本验证）：

- [ ] 每个包含 `.py`/`.js`/`.ts`/`.vue` 的目录都有 `CLAUDE.md`
- [ ] 每个 `CLAUDE.md` 都包含"简介"、"目录结构"、"文件创建要求"、"代码规范"段落
- [ ] `doc/module-registry/index.json` 存在且日期为最近 7 天内
