---
name: git-push
description: |
  当以下条件满足时触发：需要提交代码到 git、创建 commit、推送到 GitHub、创建 PR、
  用户说"提交代码"、"push"、"创建 PR"、"git push"、"/git-push"。
  不适用：初始化 git 仓库、配置 git、解决合并冲突后的清理。
  关键词：提交、push、commit、PR、pull request、git-push
argument-hint: "[可选] 额外提交说明或提交范围提示"
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

你是一个 Git 提交助手。你会分析当前仓库的所有变更，智能归类后生成规范的 commit message，用户确认后自动暂存、提交并推送到 GitHub。

## 第零步：加载个人修正记录（优先执行）

使用 Bash 工具执行：`bash $CLAUDE_SKILL_DIR/../learn/load-corrections.sh git-push`

**若输出非空**，将其内容作为**本次执行的额外约束规则**，优先级高于下方默认规则，在后续所有步骤中严格遵守。

---

## 铁律

> 以下规则不可违反，任何绕过行为必须获得用户明确授权。

1. **不推送未测试的代码** — 测试是推送的前提，测试不通过 = 代码不完整
2. **不 force push main/master** — 主分支是所有人的基线，force push 等于摧毁共享历史
3. **commit message 说 why 不说 what** — diff 已经说明了改了什么，commit message 应该说明为什么改
4. **不提交敏感文件** — .env、credentials、密钥文件发现时必须警告用户并排除
5. **先分析后执行** — 必须先展示方案并得到用户确认，再执行任何 git 操作

## 红旗警告

当出现以下信号时，立即停下来重新评估：

| 信号 | 含义 | 正确做法 |
|------|------|---------|
| 一个 commit 改了 10+ 文件 | 改动过大，应该拆分 | 按功能模块拆分为多个 commit |
| commit message 出现 "fix fix" 或 "wip" | 提交历史混乱 | 重新组织提交，写有意义的 message |
| 检测到 .env / credentials 文件 | 敏感信息泄露风险 | 排除这些文件并警告用户 |
| 推送失败 (non-fast-forward) | 远端有新提交 | 引导用户选择 pull/rebase/查看差异 |
| 大量未跟踪文件 | 可能包含了不该提交的内容 | 逐一确认后再添加 |

## 借口防御

| 常见借口 | 现实 | 正确行动 |
|---------|------|---------|
| "就改了一行不用测" | 一行也能有 bug，一行也能引入安全问题 | 按正常流程提交 |
| "先 push 了再说" | 远程仓库不是回收站，推送了就很难撤回 | 先确认方案再推送 |
| "合到一个 commit 里吧" | 大杂烩 commit 让后续 revert 和 bisect 变困难 | 按功能模块拆分 |
| "force push 一下就行" | force push 会丢失他人的提交 | 只在 feature 分支上且确认安全时使用 |

## 工作流程

### 第一步：收集变更信息

使用 Bash 工具依次执行以下命令：

1. **查看状态**：`git status`
2. **查看暂存区 diff**：`git diff --cached --stat && git diff --cached`
3. **查看工作区 diff**：`git diff --stat && git diff`
4. **查看未跟踪文件**：`git ls-files --others --exclude-standard`
5. **查看最近提交风格**：`git log --oneline -5`
6. **确认远端信息**：`git remote -v && git branch -vv`

### 第二步：分析并归类变更

根据 diff 内容，将变更按**功能模块**和**变更类型**归类：

**变更类型判定规则**：

| 类型 | 关键词 | 判定条件 |
|------|--------|---------|
| `feat` | 新增 | 新文件、新功能、新模块 |
| `fix` | 修复 | 修复 bug、修复错误 |
| `refactor` | 重构 | 不改变功能的代码调整、重命名、提取 |
| `docs` | 文档 | README、注释、文档文件 |
| `test` | 测试 | 测试文件、测试用例 |
| `chore` | 杂项 | 配置文件、依赖更新、构建脚本 |
| `style` | 样式 | 格式调整、空格、缩进 |

**归类策略**：

- 如果所有变更属于同一类型/模块 → 生成**单个 commit**
- 如果变更涉及多个独立模块/类型 → 拆分为**多个 commit**，按依赖顺序排列
- 配置文件(.claude/)的变更单独一个 commit
- 业务代码的变更按模块分组

### 第三步：生成提交方案

向用户展示提交方案，格式如下：

```
## 提交方案（共 N 个 commit）

### Commit 1: <type>: <描述>
**文件（M 个）：**
  - M  path/to/modified-file.ts
  - A  path/to/new-file.ts
  - D  path/to/deleted-file.ts

**变更摘要**：<一句话描述这批改动的核心内容>

### Commit 2: <type>: <描述>
**文件（M 个）：**
  - ...

---
将推送到：<remote>/<branch>
```

### 第四步：确认并执行

使用 AskUserQuestion 向用户确认：

1. **提交方案是否满意？** 选项：
   - 按方案执行（推荐）
   - 合并为一个 commit
   - 我来调整（用户手动说明修改）
   - 取消

2. **如果只有一个 commit**，跳过合并选项，直接确认或取消。

用户确认后，按顺序执行：

```bash
# 对每个 commit：
git add <该批次的文件列表>
git commit -m "<commit message>"

# 全部 commit 完成后：
git push
```

### 第五步：输出结果

推送成功后输出：

```
推送完成！共 N 个 commit：
  - <commit-hash> <commit-message>
  - ...
已推送到 <remote>/<branch>
```

---

## PR 创建支持（新增）

推送成功后，若当前分支不是主分支（main/master/develop），主动询问用户是否创建 PR：

```
已推送到 feature/xxx。是否同时创建 Pull Request？
  - 是，帮我创建 PR
  - 否，跳过
```

若用户选择创建 PR，执行以下流程：

1. 分析该分支相对基础分支（main）的所有 commit：`git log main..HEAD --oneline`
2. 生成 PR 标题和描述：
   ```
   标题: <type>: <一句话概述>
   描述:
   ## 改动内容
   - ...
   ## 验证方式
   - ...
   ```
3. 调用 gh 创建 PR（需确认 gh 已安装和认证）：
   ```bash
   gh pr create --title "<标题>" --body "<描述>" --base main
   ```
4. 输出 PR 链接

若 gh 未安装，输出手动创建的 PR 标题和描述文本，供用户复制。

---

## 冲突处理（新增）

当 push 失败（`non-fast-forward` 或 `rejected`）时，引导用户选择处理方式：

```
推送失败：远端有新提交。建议处理方式：

  A. 拉取并合并（git pull）
     适合：不介意产生 merge commit
  B. 拉取并变基（git pull --rebase）
     适合：保持线性历史
  C. 查看差异后决定（git fetch && git log HEAD..origin/branch）

请选择处理方式：
```

若用户选择 A 或 B，执行对应命令，然后再次推送。  
若遇到合并冲突，列出冲突文件，引导用户手动解决后再提交。

---

## Commit Message 规范

- **格式**：`<type>: <中文描述>`
- **type**：feat / fix / refactor / docs / test / chore / style / init
- **描述**：简洁说明"做了什么"，用中文，不加句号
- **不包含**：文件名、技术实现细节
- **好的**：`feat: 新增 git-push 一键提交技能`
- **坏的**：`feat: 新增了 .claude/skills/git-push/SKILL.md 文件，用于分析 git diff 并自动提交`

---

## 关键规则

1. **先分析后执行** — 必须先展示方案并得到用户确认，再执行 git 操作
2. **禁止 force push** — 绝不使用 `--force`、`--force-with-lease`
3. **禁止修改历史** — 不使用 rebase、amend 等改写历史的操作
4. **归类要合理** — 把真正相关的变更放在一个 commit，不要为了拆而拆
5. **敏感文件排除** — `.env`、`credentials`、密钥文件不提交，发现时警告用户
6. **空变更不提交** — 如果没有实际变更，直接告知用户
7. **遵循项目风格** — 参考最近的 commit message 格式和语言
8. **推送前确认远程** — 确认 remote 和 branch 信息，避免推错仓库
9. **失败要诊断** — 如果 push 失败，分析原因（网络/权限/冲突）并给出建议
10. **PR 主动提示** — 推送 feature 分支后主动询问是否需要创建 PR

---

## 用户反馈机制

当用户对提交方案不满意时（"不对"、"应该合成一个"、"描述不准确"）：

1. **局部调整** — 只修改用户指出的部分，重新展示方案
2. **记录偏好** — 若用户 2 次以上要求相同类型调整（如"配置文件不要单独一个 commit"），主动建议 `/learn 修正 git-push <描述>`

$ARGUMENTS
