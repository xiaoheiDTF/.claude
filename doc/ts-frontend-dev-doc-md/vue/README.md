# Vue 3 开发规则 — 总览

> 框架：Vue 3 + TypeScript + Composition API
> 适用场景：Web SPA、Electron 渲染进程
> 最后更新：2026-04-11

---

## 目录结构

```
src/
├── views/                   ← 页面组件（路由级）
│   └── OrderPage.vue
├── components/
│   ├── common/              ← 通用 UI 组件
│   │   ├── AppButton.vue
│   │   └── AppModal.vue
│   └── business/            ← 业务组件
│       ├── OrderList.vue
│       └── OrderCard.vue
├── composables/             ← 组合式函数（类似 React Hooks）
│   ├── useOrderList.ts
│   └── useAuth.ts
├── stores/                  ← Pinia 状态管理
│   ├── auth.ts
│   └── order.ts
├── services/                ← API 调用层
│   ├── api.ts
│   └── orderService.ts
├── types/                   ← 全局类型定义
├── utils/                   ← 工具函数
├── constants/               ← 常量
├── assets/                  ← 静态资源
├── router/                  ← 路由配置
└── styles/                  ← 全局样式
```

## 规则文件索引

| 文件 | 说明 |
|------|------|
| [component-rules.md](component-rules.md) | 组件开发规则 |
| [composition-rules.md](composition-rules.md) | Composition API 规则 |
| [state-rules.md](state-rules.md) | 状态管理规则（Pinia） |
| [style-rules.md](style-rules.md) | 样式规则 |
