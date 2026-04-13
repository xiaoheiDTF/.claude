# Vue 3 样式规则

> 所属框架：Vue 3
> 最后更新：2026-04-11

---

## 1. 样式方案

| 方案 | 说明 |
|------|------|
| `<style scoped>` | 默认选择，Vue 原生支持 |
| CSS Modules | 需要动态类名时 |
| Tailwind CSS | 快速开发，与 Vue 兼容好 |

## 2. 代码质量规则

### 【强制】
- 使用 `<style scoped>` 防止样式泄漏
- 不使用全局样式覆盖组件样式
- 不使用 `!important`

### 【推荐】
- 使用 CSS 变量管理设计令牌
- 使用 BEM 或语义化类名

## 3. 模板

```vue
<template>
  <div :class="[$style.container, { [$style.loading]: isLoading }]">
    <div :class="$style.card">
      <slot />
    </div>
  </div>
</template>

<style module lang="css">
.container {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
}

.card {
  padding: var(--spacing-md);
  border-radius: var(--radius-md);
  background: var(--color-bg-primary);
}

.loading {
  opacity: 0.6;
  pointer-events: none;
}
</style>
```
