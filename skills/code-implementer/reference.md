# code-implementer 参考文件

> 本文件包含 code-implementer 的 L3 资源：质量门禁命令表和实现报告模板。

---

## 质量门禁命令表

每个步骤实现完成后，根据目标文件语言执行对应的质量检查：

| 语言 | 静态检查 | 格式化 | 类型检查 |
|------|---------|--------|---------|
| TypeScript | `npx eslint <file>` | `npx prettier --write <file>` | `npx tsc --noEmit` |
| Python | `ruff check <file>` | `ruff format <file>` | `mypy <file>` |
| Java | `mvn checkstyle:check` | — | `mvn compile` |
| Go | `go vet ./...` | `gofmt -w .` | `go build ./...` |
| Rust | `cargo clippy` | `cargo fmt` | `cargo check` |
| C/C++ | `clang-tidy <file>` | `clang-format -i <file>` | `cmake --build` |
| C# | `dotnet format --verify-no-changes` | `dotnet format` | `dotnet build` |
| PHP | `phpcs <file>` | `phpcbf <file>` | `phpstan analyse <file>` |
| Ruby | `rubocop <file>` | `rubocop -A <file>` | — |
| Swift | `swiftlint lint` | `swiftformat <file>` | `swift build` |
| Kotlin | `./gradlew detekt` | `./gradlew ktlintFormat` | `./gradlew compileKotlin` |
| Shell | `shellcheck <file>` | `shfmt -w <file>` | — |
| Dart | `dart analyze <file>` | `dart format <file>` | `dart analyze` |

**注意事项**：
- 如果项目没有配置对应工具（如没有 eslint），跳过该检查，在报告中注明"未配置 eslint，跳过静态检查"
- 只检查当前步骤修改/创建的文件，不检查整个项目
- 格式化工具使用 `--write` / `-w` 直接修改文件

---

## 模块 CLAUDE.md 模板体系

模块 CLAUDE.md 分为三种模板，根据模块在依赖链中的位置选择：

### 何时选哪种模板

| 条件 | 使用模板 | 架构图要求 |
|------|---------|-----------|
| 模块不依赖任何同级/下级业务模块（叶子节点） | 底层模块模板 | 只描述"我提供什么 + 谁可能用我" |
| 模块依赖了其他业务模块（编排/组合层） | 上层模块模板 | **必须**画出依赖关系图（Mermaid） |
| `frontend/src/core/` 及其直接子目录 | core 专属模板 | 按实际依赖决定 |

**判定方法**：扫描模块的 import 语句，如果存在对项目内其他业务模块的引用 → 上层模块；否则 → 底层模块。

---

### 模板一：底层模块（无外部业务依赖）

```markdown
# <模块名> 模块

> 位置: `<相对项目根的路径>/`

## 简介

<2-3 句话描述模块职责。说明它不依赖什么、能被谁调用。>

## 导出清单

| 导出项 | 类型 | 用途 |
|--------|------|------|
| `functionXxx()` | `(input: Type) => Result` | <一句话> |
| `ClassYyy` | `class` | <一句话> |
| `TYPE_ZZZ` | `type` | <一句话> |

## 谁会用到我（预期消费者）

- `<上层模块A>/` — 用于 <调用场景>
- `<上层模块B>/` — 用于 <调用场景>
- <如有外部 API 或跨项目调用场景也写上>

## 创建文件要求

- <禁止依赖 X>
- <必须遵循 Y>
- <路径别名规则>
- <对外暴露必须有类型签名>

## 代码规范（实现与 Review）

### 实现规范
- <具体的编码规则，如：TypeScript strict: true，禁止 any>
- <函数必须声明返回类型>
- <错误处理规则>

### Review 检查清单
- [ ] 类型安全：无 `any`、无不安全类型断言
- [ ] 边界处理：空值、异常输入均有处理
- [ ] 依赖方向：未引入不该依赖的模块
- [ ] 可测试性：纯函数优先、外部依赖可 mock
- [ ] 导出完整：新增的公开函数/类型已同步到上面的导出清单
```

---

### 模板二：上层模块（有外部业务依赖，必须画架构图）

```markdown
# <模块名> 模块

> 位置: `<相对项目根的路径>/`

## 简介

<2-3 句话描述模块职责和它在整体架构中的角色。>

## 架构图

\```mermaid
graph TD
    本模块["<模块名>"] --> A["<依赖模块A>"]
    本模块 --> B["<依赖模块B>"]
    本模块 --> C["<依赖模块C>"]
    本模块 -.-> D["<可选依赖，虚线>"]

    style 本模块 fill:#4CAF50,color:#fff
\```

> 图例：实线 = 必需依赖，虚线 = 可选依赖。箭头方向 = import 方向（本模块 → 被依赖模块）。

## 目录结构

| 目录 | 用途 |
|------|------|
| `subA/` | <子模块描述> |
| `subB/` | <子模块描述> |
| `index.ts` | 对外统一导出入口 |

## 创建文件要求

- <禁止依赖 X>
- <必须遵循 Y>
- <新增依赖必须先更新上方架构图>

## 代码规范（实现与 Review）

### 实现规范
- <具体的编码规则>
- <编排层只做调用，不写底层逻辑>
- <错误必须向上传播，不在编排层静默吞掉>

### Review 检查清单
- [ ] 架构图同步：新增/删除依赖后，架构图已更新
- [ ] 编排正确性：调用顺序、参数传递、降级路径
- [ ] 类型安全：无 `any`、返回值类型正确
- [ ] 依赖方向：未引入架构图以外的模块
- [ ] 错误处理：每个依赖调用都有异常处理
- [ ] 可测试性：子模块可独立 mock，编排逻辑可隔离测试
```

---

### 模板三：core/ 专属模板

当目标目录是 `frontend/src/core/`（或其直接子目录缺少可执行规范）时，使用以下结构：

```markdown
# CLAUDE.md — core/

## 位置

`frontend/src/core/` — 核心业务逻辑层。

## 简介

不依赖 Electron 进程环境的纯业务逻辑层。包含浏览器自动化引擎、页面感知能力、AI 工具函数。可被主进程直接调用，也方便独立单元测试。

## 架构图

\```mermaid
graph TD
    core["core/"] --> browser["browser/"]
    core --> perception["perception/"]
    core --> tools["tools/"]
    browser --> cdp["browser/cdp/"]
    perception -.-> browser
    tools -.-> browser
    tools -.-> perception

    style core fill:#4CAF50,color:#fff
\```

## 目录结构

| 目录 | 用途 |
|------|------|
| `browser/` | 浏览器自动化引擎（Playwright 封装、CDP 协议封装） |
| `perception/` | 页面感知能力，采集页面状态变化并分级输出给 AI |
| `tools/` | AI 工具函数，封装可供 AI 调用的操作能力 |

## 创建文件要求

- 禁止依赖 Electron API（`BrowserWindow`、`ipcMain` 等），保持进程无关
- 禁止依赖 React 或任何 DOM API
- 文件中使用 `@core/` 路径别名引用同层其他模块
- 导入 CDP 命令必须从 `@core/browser/cdp/command` 获取，禁止自行构造
- 所有对外暴露的函数必须有明确的 TypeScript 类型签名

## 代码规范（实现与 Review）

### 实现规范
- TypeScript 必须 `strict: true`，禁止 `any`，用 `unknown` + 类型守卫
- 函数必须声明返回类型；错误处理禁止空 `catch`
- 单元测试优先覆盖：正常路径、边界输入、异常路径

### Review 检查清单
- [ ] 类型安全：无 `any`、无不安全类型断言
- [ ] 边界处理：空值、异常输入均有处理
- [ ] 依赖方向：未引入 Electron API / React / DOM API
- [ ] CDP 入口一致：修改 `browser/cdp` 时未破坏 `@core/browser/cdp/command` 统一入口
- [ ] 可测试性：纯函数优先、外部依赖可 mock
- [ ] 导出完整：新增的公开函数已出现在模块导出清单中
```

---

## 实现报告模板

```markdown
# 代码实现报告

> 生成时间: YYYY-MM-DD HH:mm
> 关联执行计划: <文件名>（如有）
> 关联拆解报告: <文件名>
> 关联复用报告: <文件名>
> 原始需求: <需求简述>

## 实现总览

| Step | 功能单元 | 类型 | 文件路径 | 行号 | 状态 |
|------|---------|------|---------|------|------|
| 1 | ... | 自己写 | D:\...\file.ts | 10-25 | 已实现 |
| 2 | ... | 编排组合 | D:\...\file.ts | 30-50 | 已实现 |
| — | ... | 直接用 | D:\...\existing.ts | 10-25 | 已有 |

## 实现详情

### Step 1: <功能单元名称> — 自己写

> 功能: <描述>
> 依赖: 无

**文件**: `D:\...\file.ts:10-25`

```typescript
// 实际实现的代码
```

说明: <实现思路>

---

### Step 2: <功能单元名称> — 编排组合

> 功能: <描述>
> 依赖: Step 1

**文件**: `D:\...\file.ts:30-50`

```typescript
// 编排调用逻辑
```

说明: <编排方式，调用了哪些底层功能>

---

### <直接用的功能单元> — 直接用

**复用文件**: `D:\...\existing.ts:10-25`

无需新增代码，直接调用现有实现。

---

## 修改范围确认

实际修改的文件清单（与计划对比）：
- <文件路径> — 计划内
- <文件路径> — 计划外（原因: <说明>）

未修改的计划内文件：
- 无 / <列出跳过的文件及原因>
```
