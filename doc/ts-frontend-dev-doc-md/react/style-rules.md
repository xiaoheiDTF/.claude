# React 样式规则

> 所属框架：React
> 最后更新：2026-04-11

---

## 1. 方案选型

| 方案 | 适用场景 | 优点 | 缺点 |
|------|---------|------|------|
| CSS Modules | 中小型项目 | 零运行时、隔离性好 | 动态样式需额外处理 |
| Tailwind CSS | 快速开发 | 一致性高、工具链完善 | 类名长、学习成本 |
| CSS-in-JS (Styled) | 复杂动态样式 | 全功能、类型安全 | 运行时开销 |
| Vanilla Extract | 性能敏感项目 | 零运行时、类型安全 | 配置复杂 |

## 2. 代码质量规则

### 【强制】
- 样式与组件同目录
- 不使用全局 CSS
- 不使用 `!important`
- 不使用内联 style（动态值除外）

### 【推荐】
- CSS Modules 作为默认选择
- 设计令牌（Design Tokens）管理颜色/间距/字号

## 3. CSS Modules 模板

```css
/* OrderList.module.css */
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

.card:hover {
  box-shadow: var(--shadow-md);
}

.selected {
  border-color: var(--color-primary);
}
```

```tsx
// 使用
import styles from './OrderList.module.css';

<div className={styles.container}>
  <div className={`${styles.card} ${isSelected ? styles.selected : ''}`}>
    ...
  </div>
</div>
```
