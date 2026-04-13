# React 开发规则 — 总览

> 框架：React 18+ / 19 + TypeScript
> 适用场景：Web SPA、Electron 渲染进程、React Native
> 最后更新：2026-04-11

---

## 目录结构

```
src/
├── app/                    ← 页面路由（Next.js）/ App 入口
├── components/
│   ├── ui/                 ← 通用 UI 组件（Button, Modal, Input）
│   ├── layout/             ← 布局组件（Header, Sidebar, Footer）
│   └── features/           ← 业务功能组件
│       ├── order/
│       │   ├── OrderList.tsx
│       │   ├── OrderDetail.tsx
│       │   ├── OrderCard.tsx
│       │   ├── useOrderList.ts    ← 自定义 Hook
│       │   └── order.types.ts     ← 类型定义
│       └── user/
├── hooks/                  ← 全局自定义 Hooks
├── services/               ← API 调用层
│   ├── api.ts              ← Axios 实例
│   └── orderService.ts
├── stores/                 ← 全局状态（Zustand / Context）
├── types/                  ← 全局类型定义
├── utils/                  ← 工具函数
├── constants/              ← 常量
├── styles/                 ← 全局样式
└── test/                   ← 测试工具和 mock
```

## 规则文件索引

| 文件 | 说明 |
|------|------|
| [component-rules.md](component-rules.md) | 组件开发规则 |
| [hooks-rules.md](hooks-rules.md) | Hooks 规则 |
| [state-rules.md](state-rules.md) | 状态管理规则 |
| [style-rules.md](style-rules.md) | 样式规则 |
| [test-rules.md](test-rules.md) | 测试规则 |
