# Electron 开发规则 — 总览

> 适用场景：跨平台桌面应用
> 技术栈：Electron + TypeScript（主进程） + React/Vue（渲染进程）
> 最后更新：2026-04-11

---

## 核心架构

```
┌─────────────────────────────────────────────────┐
│ Electron Application                            │
│                                                 │
│  ┌──────────────────┐  ┌──────────────────────┐ │
│  │  Main Process    │  │  Renderer Process     │ │
│  │  (Node.js)       │  │  (Chromium)           │ │
│  │                  │  │                       │ │
│  │  - 窗口管理      │  │  - React/Vue UI      │ │
│  │  - 文件系统      │  │  - 用户交互           │ │
│  │  - 原生 API      │  │  - 页面渲染           │ │
│  │  - 系统托盘      │  │                       │ │
│  └────────┬─────────┘  └──────────┬────────────┘ │
│           │     IPC (ipcMain/     │              │
│           │     ipcRenderer)      │              │
│           └───────────────────────┘              │
│                                                 │
│  ┌──────────────────┐                           │
│  │  Preload Script  │                           │
│  │  (安全桥梁)       │                           │
│  └──────────────────┘                           │
└─────────────────────────────────────────────────┘
```

## 目录结构

```
project-root/
├── electron/                    ← 主进程代码
│   ├── main.ts                  ← 主入口
│   ├── preload.ts               ← Preload 脚本
│   ├── ipc/
│   │   ├── handlers/            ← IPC 处理器
│   │   │   ├── orderHandler.ts
│   │   │   └── fileHandler.ts
│   │   └── channels.ts          ← IPC 通道定义
│   ├── services/                ← 主进程服务
│   │   ├── windowManager.ts
│   │   └── trayManager.ts
│   └── utils/                   ← 主进程工具
├── src/                         ← 渲染进程代码（React/Vue）
│   ├── components/
│   ├── hooks/ (或 composables/)
│   ├── services/
│   │   └── ipcService.ts        ← IPC 客户端
│   └── ...
├── resources/                   ← 静态资源（图标等）
├── electron-builder.yml         ← 打包配置
├── package.json
├── tsconfig.json                ← 渲染进程 TS 配置
└── tsconfig.electron.json       ← 主进程 TS 配置
```

## 安全铁律

- 【强制】开启 `contextIsolation: true`
- 【强制】开启 `nodeIntegration: false`
- 【强制】开启 `sandbox: true`
- 【强制】所有 IPC 通信通过 preload 暴露的 API
- 【强制】不使用 `remote` 模块
- 【禁止】在渲染进程中直接使用 Node.js API

## 规则文件索引

| 文件 | 说明 |
|------|------|
| [main-process-rules.md](main-process-rules.md) | 主进程开发规则 |
| [renderer-rules.md](renderer-rules.md) | 渲染进程开发规则 |
| [ipc-rules.md](ipc-rules.md) | IPC 通信规则 |

> 核心参考来源：
> - [Electron Security](https://electronjs.org/docs/latest/tutorial/security) (A — Electron 官方)
> - [Electron IPC Patterns](https://medium.com/@lyzgeorge/understanding-ipc-in-electron-simplified-explanation-and-code-examples-p2-7d744a76719c) (B)
> - [Slack Engineering: Sharing Code Between Web & Electron](https://slack.engineering/interops-labyrinth-sharing-code-between-web-electron-apps/) (B)
