# 代码片段/模板库

> 沉淀于实际开发，按需使用
> 通过 `/learn` 或 `/learn 记下来` 积累

---

<!-- 新模式追加到文件末尾，使用双层格式（通用层 + 原始案例）：

## <通用片段名称>（不含项目专有名词）

> 沉淀于 YYYY-MM-DD，来源：<对话背景>

**通用场景**: <去掉项目细节后的抽象使用场景>
**识别信号**: <遇到什么特征时应想到此片段>
**代码**: <完整可运行的通用版代码，用泛型/占位符替代项目特有类型>
**用法**: <如何调用/使用>
**依赖**: <需要什么依赖/环境>
**适用举例**: <3+ 个不同领域的同类场景>

<details>
<summary>原始案例</summary>

**项目场景**: <具体项目中的原始代码>
**具体用法**: <项目中的具体使用方式>
</details>

如果无法泛化（纯项目工具函数），标题加 [项目专属] 前缀，省略通用层字段。
-->

## 优先使用操作返回值而非独立查询验证状态

> 沉淀于 2026-04-12，来源：lifecycle E2E 测试中 status() 在 headless 模式失败

**通用场景**: 测试需要验证操作结果，但独立的状态查询 API 依赖特定环境条件（如活跃连接、网络可达、特定运行模式）
**识别信号**: 状态查询 API 在测试环境下不可用或不稳定；操作本身已返回足够的状态信息
**代码**:
```typescript
// 反模式：用独立查询验证状态（查询可能依赖额外环境条件）
const result = await service.doOperation(params);
const status = await service.getStatus(); // ← 可能在测试环境失败
expect(status.state).toBe('active');

// 推荐：直接使用操作返回值验证（无额外依赖）
const result = await service.doOperation(params);
expect(result.state).toBe('active');        // ← 操作本身已返回状态
expect(result.metadata.type).toBe('expected');
```
**用法**: 测试中验证操作结果时，优先用操作的返回值而非独立查询 API
**依赖**: 任何测试框架（Jest/Vitest/Mocha 等）
**适用举例**: 数据库 INSERT 后用返回的 row 而非 SELECT 验证、HTTP POST 后用 response body 而非 GET 验证、文件写入后用 write 返回值而非 stat 验证

<details>
<summary>原始案例</summary>

**项目场景**: `facade.status()` 依赖 `StateCollector` 发送 `Network.getCookies` 等 CDP 命令，headless 无活跃页面时失败。改用 `facade.open()` 返回值中的 `connection.state`、`processInfo.browserType`、`processInfo.debugPort` 验证
**具体用法**:
```typescript
const result = await facade.open('new', {
  browserType: 'chrome',
  debugPort: port,
  headless: true,
  userDataDir: profileDir,
});
expect(result.connection.state).toBe('connected');
expect(result.processInfo.browserType).toBe('chrome');
expect(result.processInfo.debugPort).toBe(port);
```
</details>

## Windows PowerShell 5.1 的 Join-Path 陷阱

> 沉淀于 2026-04-14，来源：用 Shell 工具批量生成 module-test/module-registry 镜像时 PowerShell 脚本崩溃

**通用场景**: 在 Windows 环境下用 PowerShell 脚本拼接多层路径并批量操作文件
**识别信号**: Shell 工具中使用了 3+ 参数的 `Join-Path`；脚本需要在 Windows 默认 PowerShell（非 PowerShell 7）下运行
**代码**:
```powershell
# ❌ 错误：Windows PowerShell 5.1 的 Join-Path 最多只接受 2 个参数
$targetPath = Join-Path $projectDir "doc\module-registry" $relPath
# 报错：找不到接受实际参数 "xxx" 的位置形式参数

# ✅ 正确做法 1：使用 [System.IO.Path]::Combine()（支持多段）
$targetPath = [System.IO.Path]::Combine($projectDir, "doc\module-registry", $relPath)

# ✅ 正确做法 2：字符串拼接（简单场景）
$targetPath = "$projectDir\doc\module-registry\$relPath"

# ✅ 正确做法 3：多次两两拼接
$targetPath = Join-Path (Join-Path $projectDir "doc\module-registry") $relPath

# ✅ 正确做法 4：复杂批量操作改用 Python/Node.js（跨平台更稳定）
# python -c "import shutil; shutil.copytree(...)"
```
**用法**: 在 Windows 环境写 PowerShell 文件操作脚本时，路径拼接超过两段必须避开 3 参数 Join-Path
**依赖**: Windows PowerShell 5.1（Windows 默认自带版本）
**适用举例**: Windows CI 环境中用 PowerShell 批量复制文件、用 Shell 工具递归生成目录镜像、写自动化部署脚本时的路径处理、写 PostToolUse Hook 时处理 Windows 路径

<details>
<summary>原始案例</summary>

**项目场景**: 用 PowerShell 脚本把项目中的 `CLAUDE.md` 和 `*.test.ts` 镜像复制到 `doc/module-registry/` 和 `doc/module-test/`
**具体用法**:
```powershell
# 崩溃代码
$targetPath = Join-Path $projectDir "doc\module-registry" $relPath
# 修正后
$targetPath = "$projectDir\doc\module-registry\$relPath"
# 最终方案：改用 Python 脚本完成复杂路径操作，避免 PowerShell 版本差异
```
</details>

## Controller-First API 文档化工作流

> 沉淀于 2026-04-14，来源：为 Python/Java 双后端生成按 Controller 组织的接口文档

**通用场景**: 前后端分离项目中，需要为 REST API 服务编写/维护接口文档，确保文档与代码一致且易于查找
**识别信号**: 用户要求"写接口文档"、"前后端需要对接文档"、"API 文档在哪"；项目有多个 Controller/Router 文件且缺少统一文档入口
**通用做法**:
1. 在源码目录下建立 `doc/controller/`（或 `docs/api/controller/`），目录结构与 `src/controller/` 保持同构
2. 每个 Controller/Router 对应一份 Markdown 文档，文件名与源码文件同名（如 `ChatController.java` → `ChatController.md`）
3. 每份文档必须包含以下 6 个部分：
   - **接口概览表**：接口 | 方法 | URL | Content-Type | 说明
   - **请求说明**：URL、Headers、请求体字段表（字段名 | 类型 | 必填 | 说明）
   - **响应说明**：字段表、JSON 示例
   - **错误响应**：常见 HTTP 状态码、错误体示例
   - **前端对接说明**：调用方式、状态管理、组件分发等注意事项
   - **与后端兼容性说明**（如存在多后端实现）：协议差异显式标注
4. 文档入口 `README.md` 汇总所有 Controller 文档链接、通用约定、快速验证命令

**原因**: 按 Controller 组织文档与代码目录一一对应，维护成本低；直接从源码（Controller → DTO → 异常处理）生成可避免文档与代码不一致
**避坑**: 不要把所有接口混在一个大文档里，也不要把文档放在与源码无关的目录，否则新增接口时很容易漏写文档
**适用举例**: FastAPI 项目的 router 文档化、Spring Boot 项目的 Controller 文档化、Django REST Framework 的 ViewSet 文档化、Go Gin 的 Handler Group 文档化

<details>
<summary>原始案例</summary>

**项目场景**: `travel-agent`（Python FastAPI）和 `travel-agent-java`（Spring Boot）需要各自维护接口文档，且前端 `travel-web` 要能兼容两套后端。文档目录结构如下：
```
travel-agent/doc/controller/
├── README.md      ← 汇总 + 通用约定 + 快速验证命令
├── chat.md        ← 对应 app/routers/chat.py
travel-agent-java/doc/controller/
├── README.md      ← 汇总 + 通用约定
├── ChatController.md    ← 对应 ChatController.java
├── SessionController.md ← 对应 SessionController.java
└── HealthController.md  ← 对应 HealthController.java
```
**具体做法**:
- Python 版 `chat.md` 详细说明了 `POST /api/chat` 和 `POST /api/chat/stream`（SSE），并标注了与 Java 版 SSE 的差异（`event:` 行 vs 纯 `data:` 行）
- Java 版 `ChatController.md` 详细说明了同步/流式端点，以及 `SseEmitter` 的 60 秒超时机制
- 所有文档的字段表、JSON 示例均直接从 DTO 源码提取，确保一致性
</details>
