# trace-call-chain 参考文件

> 本文件包含 trace-call-chain 的 L3 资源：链路报告模板。

---

## 链路报告模板

文件保存位置：项目根目录下 `trace-reports/YYYYMMDD-HHmmss-<简短描述>.md`

```markdown
# 调用链路追踪报告

> 生成时间: YYYY-MM-DD HH:mm
> Bug 描述: <用户描述的 bug 或需求>

---

## 调用链总览

入口 → 层级2 → ... → **问题所在** → ... → 出口

## 详细调用链

### 1. `<函数名>` — 入口

- **文件**: `D:\...\file1.ts`
- **行号**: 10-25
- **说明**: 该函数的作用简述

```typescript
// D:\...\file1.ts:10-25
export async function handleClick(event: MouseEvent): Promise<void> {
  const selector = buildSelector(event.target);
  const result = await executeAction('click', { selector });
  return result;
}
```

↓ 调用

### 2. `<函数名>` — 中间层

- **文件**: `D:\...\file2.ts`
- **行号**: 45-67
- **说明**: 该函数的作用简述

```typescript
// D:\...\file2.ts:45-67
export async function executeAction(action: string, params: ActionParams): Promise<ToolResult> {
  const page = getActivePage();
  return await actions[action](page, params);
}
```

↓ 调用

### 3. `<函数名>` — **问题所在**

- **文件**: `D:\...\file3.ts`
- **行号**: 100-120
- **说明**: 问题根因分析

```typescript
// D:\...\file3.ts:100-120
export async function click(page: Page, selector: string): Promise<ToolResult> {
  // BUG: 这里缺少等待元素可见的逻辑
  await page.click(selector);
  return { success: true };
}
```

↓ 调用

### 4. `<函数名>` — 底层调用

- **文件**: `D:\...\file4.ts`
- **行号**: 30-50
- **说明**: 该函数的作用简述

```typescript
// D:\...\file4.ts:30-50
// 实际代码内容
```

---

## 影响范围

- **上游影响**: <哪些调用者会受影响，列出文件路径>
- **下游依赖**: <这个 bug 会影响哪些功能>

## 相关文件列表

| 文件绝对路径 | 行号 | 角色 |
|-------------|------|------|
| D:\...\file1.ts | 10-25 | 入口 |
| D:\...\file2.ts | 45-67 | 中间调用 |
| D:\...\file3.ts | 100-120 | 问题所在 |
| D:\...\file4.ts | 30-50 | 底层依赖 |
```
