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
