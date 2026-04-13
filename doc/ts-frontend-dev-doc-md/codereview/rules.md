# 前端 Code Review 规则

> 适用于所有框架（React / Vue）和平台（Web / Electron / 移动端）
> 最后更新：2026-04-11

---

## 一、Review 核心原则

> 只要代码确实改善了系统健康度，就应该批准通过，即使它不完美。
> —— [Google Engineering Practices](https://google.github.io/eng-practices/review/reviewer/standard.html)

- 没有"完美代码"，只有"更好的代码"
- 追求**持续改进**，而非一次到位
- 技术事实和数据优先于个人偏好
- 不影响代码健康度的建议，加 **"Nit:"** 前缀表示可选

---

## 二、Review Checklist

### P0 — 必须检查（阻塞合并）

#### 2.1 功能正确性
- [ ] 代码是否正确实现了需求
- [ ] 边界条件是否处理（空数组、null、undefined）
- [ ] 加载状态（loading）是否展示
- [ ] 错误状态是否处理和展示
- [ ] 空状态是否有占位展示

#### 2.2 安全性
- [ ] 用户输入是否清理（XSS 防护）
- [ ] 是否有 `dangerouslySetInnerHTML` / `v-html` 使用（需确认已 sanitize）
- [ ] 敏感信息是否暴露在前端代码中
- [ ] Token 存储方式是否安全
- [ ] URL 参数是否编码

#### 2.3 性能
- [ ] 列表是否使用唯一 key
- [ ] 是否有不必要的重渲染
- [ ] 图片是否使用懒加载
- [ ] 大组件是否做了代码分割
- [ ] 是否有内存泄漏风险（未清理的定时器、订阅）

### P1 — 重要检查（建议修复）

#### 2.4 TypeScript 类型
- [ ] 是否有 `any` 类型
- [ ] Props 类型是否完整定义
- [ ] API 响应是否有类型定义
- [ ] 是否有 `@ts-ignore`（应使用 `@ts-expect-error` + 注释）

#### 2.5 组件设计
- [ ] 组件是否单一职责
- [ ] Props 命名是否语义化
- [ ] 是否有过度嵌套（超过 3 层）
- [ ] 状态管理是否合理（局部 vs 全局）

#### 2.6 代码质量
- [ ] 是否有 `console.log` 残留
- [ ] 是否有重复代码
- [ ] 命名是否语义化
- [ ] 是否有魔法值
- [ ] 函数是否过长（> 50 行考虑拆分）

### P2 — 建议检查（不阻塞合并）

- [ ] CSS 是否模块化
- [ ] 组件是否可复用
- [ ] 是否有可访问性问题（a11y）
- [ ] 国际化是否处理
- [ ] 测试是否覆盖

---

## 三、前端特有 Review 陷阱

| 陷阱 | 规避方法 |
|------|---------|
| 只看 UI 不看逻辑 | 同时审查状态管理和副作用 |
| 忽视网络异常 | 检查所有 API 调用的 error 处理 |
| 忽视内存泄漏 | 检查 useEffect / onUnmounted 中的清理 |
| 过度优化 | 只在性能瓶颈出现时优化 |
| 过度抽象 | 当前只需要一处使用时不要抽象 |
| 样式全局污染 | 确认使用 CSS Modules 或 scoped |

---

## 四、Review 工具链

| 工具 | 用途 |
|------|------|
| GitHub PR | 代码审查平台 |
| ESLint | 代码规范检查 |
| Prettier | 代码格式化 |
| TypeScript Compiler | 类型检查 |
| Lighthouse | 性能审计 |
| axe / Lighthouse a11y | 无障碍检查 |
| Chromatic / Percy | 视觉回归测试 |

> 来源：[Frontend Code Review Best Practices](https://feature-sliced.design/blog/code-review-best-practices), [Code Review Checklist for JavaScript/React](https://community.ibm.com/community/user/blogs/marina-mascarenhas/2025/07/15/code-review-checklist-for-javascriptreact)
