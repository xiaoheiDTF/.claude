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


## 魔法字符串的三级治理策略

> 沉淀于 2026-04-14，来源：分析 Claude Code 源码常量管理策略后，结合用户 Java 代码中 `map.put("key", ...)` 的魔法字符串问题，提炼的通用规范

**通用场景**: 在项目中处理临时字段名、序列化 key、配置字符串、Map/JSON 字段等字面量时，需要权衡提取成本与维护收益，避免过度工程或失控扩散
**识别信号**: 写 `map.put` / 构造 JSON / 定义 schema / 写日志事件名时，犹豫"这个字符串要不要抽成常量"
**代码**:
```java
// 反模式：为只在单个方法里用一次的 key 单独抽常量类
public class ItemFields {
  public static final String KEY = "key"; // 过度提取，增加无意义的跳转成本
}

// 推荐：根据"使用半径"分级治理
// ① 1~2 处使用 → 直接 inline（Java 可用 enum 或强类型 Map 兜底）
itemMap.put("key", item.getKey());

// ② 跨 3+ 模块用或易拼错 → 抽到零依赖常量文件
// constants/xml.ts
export const BASH_STDOUT_TAG = 'bash-stdout';

// ③ 天然属于 schema / 类型的一部分 → 用类型约束代替字符串常量
// TypeScript
 type Entry =
  | { type: 'summary'; leafUuid: string; summary: string }
  | { type: 'tag'; sessionId: string; tag: string };
```
**用法**: 
1. **只在 1~2 处使用的字符串** → 直接 inline 写死，用类型系统或编译器兜底（如 TypeScript union、Java 强类型枚举）
2. **跨 3+ 模块使用或容易拼错的** → 抽到独立的零依赖常量文件（如 `constants/xml.ts`），让依赖图底层共享
3. **天然属于 schema / 类型的一部分** → 用类型约束（union type、struct、enum、TypedDict）代替字符串常量，让类型系统本身就是约束
**依赖**: 任何支持类型系统或常量模块的语言
**适用举例**: Java Lombok `@FieldNameConstants`、TypeScript union type 约束 JSON 字段、Python `TypedDict` 代替 dict magic keys、Go 的 const block 或 struct tag

<details>
<summary>原始案例</summary>

**项目场景**: Claude Code v2.1.88 源码中对魔法字符串的差异化处理
**具体用法**:
- `sessionStorage.ts` 中对 JSONL entry 的类型判断（`'summary'`、`'tag'`、`'custom-title'`）直接 inline，因为这些字符串只在该文件出现，且 `Entry` union type 已做编译期约束
- `constants/xml.ts` 中把 `BASH_STDOUT_TAG`、`TICK_TAG` 等抽到独立常量文件，因为它们被 `sessionStorage.ts`、`messages.ts`、`tools/` 下多个模块共享
- `configConstants.ts`（21 行）把 `NOTIFICATION_CHANNELS`、`EDITOR_MODES` 等枚举从 1,817 行的 `config.ts` 中抽离成零依赖文件，防止低层模块拉入高层依赖产生循环

</details>
