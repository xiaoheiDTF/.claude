---
paths:
  - "**/*.html"
  - "**/*.htm"
  - "**/*.css"
  - "**/*.scss"
  - "**/*.sass"
  - "**/*.less"
---

# HTML/CSS 编码规范

> 综合 Google HTML/CSS Style Guide / BEM Methodology / CSS Guidelines (Harry Roberts) / MDN Best Practices

## 命名规范

- CSS 类名：kebab-case（`user-card`, `nav-link-active`）或 BEM（`block__element--modifier`）
- ID：kebab-case（仅在必要时使用，优先 class）
- CSS 自定义属性：`--kebab-case`（`--primary-color`, `--font-size-lg`）
- 文件名：kebab-case（`user-card.html`, `nav-styles.css`）
- 图片/资源：kebab-case（`logo-dark.svg`, `icon-arrow-right.png`）
- 组件名：PascalCase（React/Vue/Angular 组件）或 kebab-case（Web Components）

## HTML 规范

- 使用语义化标签（`<header>`, `<nav>`, `<main>`, `<article>`, `<section>`, `<footer>`）
- 文档类型：`<!DOCTYPE html>`
- 使用 `<meta charset="UTF-8">`
- 使用 `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
- 属性使用双引号（`class="user-card"` 而非 `class='user-card'`）
- Boolean 属性不赋值（`<input disabled>` 而非 `<input disabled="true">`）
- 图片必须加 `alt` 属性（`<img src="logo.svg" alt="Company Logo">`）
- 避免内联样式（`style="..."`），使用 class
- 避免内联事件处理器（`onclick="..."`），使用 JS 绑定
- 表单元素关联 `<label>`（`<label for="email">Email</label><input id="email">`）
- 使用 `<template>`, `<slot>` 实现可复用模板
- 嵌套不超过 5 层

## CSS 架构

- 使用方法论组织 CSS（BEM / ITCSS / SMACSS / CUBE CSS）
- BEM 命名：`.block__element--modifier`（`.card__title--large`）
- 使用 CSS 自定义属性（CSS Variables）管理设计 token
- 使用 CSS 嵌套（原生 CSS Nesting 或预处理器）
- 按组件组织样式文件
- 使用 Mobile-First 响应式设计（`@media (min-width: 768px)`）
- 避免使用 `!important`（仅在覆盖第三方样式时使用）

## CSS 格式

- 使用 2 空格缩进
- 左花括号前空格（`.class {`）
- 属性声明每行一个
- 使用简写属性（`margin: 0 auto` 而非 `margin-top: 0; margin-right: auto; ...`）
- 声明顺序：定位 → 盒模型 → 排版 → 视觉 → 动画 → 其他
- 使用 `rem` / `em` 定义字体大小（可访问性）
- 使用 CSS 变量管理主题

## 布局

- 优先使用 Flexbox（一维布局）和 Grid（二维布局）
- 避免使用 `float` 布局（仅用于文字环绕图片）
- 避免使用 `position: absolute` 进行整体布局
- 使用 `gap` 属性设置 Flex/Grid 间距
- 使用 `clamp()` / `min()` / `max()` 实现流式排版
- 使用 Container Queries 组件级响应式

## 性能

- 使用 `will-change` 仅在需要时（过度使用反而降低性能）
- 使用 `contain` 属性优化渲染
- 避免大面积 `box-shadow` 和 `filter`
- 使用 `transform` 和 `opacity` 做动画（GPU 加速）
- 使用 `<link rel="preload">` 预加载关键资源
- CSS 放 `<head>`，JS 放 `</body>` 前
- 关键 CSS 内联（Critical CSS）
- 使用 `content-visibility: auto` 延迟渲染屏幕外内容
- 图片使用 `<picture>` + `srcset` 提供多种分辨率
- 使用 `loading="lazy"` 懒加载图片

## 可访问性（a11y）

- 使用语义化 HTML 标签
- 图片加 `alt` 文本（装饰性图片 `alt=""`）
- 颜色对比度 ≥ 4.5:1（WCAG AA）
- 键盘可导航（focusable 元素，`tabindex`）
- 使用 `aria-*` 属性增强辅助技术支持
- 表单输入关联 `<label>`
- 不依赖颜色传达信息（辅以文字/图标）
- 响应 `prefers-reduced-motion` 减少动画
- 响应 `prefers-color-scheme` 暗色模式

## 安全

- 禁止使用 `javascript:` 协议
- 使用 `rel="noopener noreferrer"` 处理外部链接（`target="_blank"`）
- 使用 `Content-Security-Policy` 头
- 输出编码防 XSS
- 使用 `integrity` 属性验证 CDN 资源（SRI）
- 使用 `HttpOnly` + `Secure` + `SameSite` Cookie 属性
