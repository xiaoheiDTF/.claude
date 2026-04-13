# Electron 渲染进程开发规则

> 所属层：Renderer Process（Chromium 环境）
> 最后更新：2026-04-11

---

## 1. 创建规则

- 渲染进程就是普通的 React/Vue 应用
- 通过 preload 暴露的 API 与主进程通信
- 不直接使用 Node.js API

## 2. 代码质量规则

### 【强制】
- 使用 React/Vue 开发 UI
- 所有原生功能通过 `window.electronAPI` 调用
- 类型安全的 API 定义

### 【禁止】
- 直接使用 `require('electron')`
- 直接使用 `fs`, `path` 等 Node.js 模块
- 在渲染进程中存储敏感信息

### 【推荐】
- 渲染进程代码与纯 Web 项目保持最大兼容
- 使用 Hook/Composable 封装 Electron API 调用

## 3. 类型定义模板

```typescript
// src/types/electron.d.ts
export interface ElectronAPI {
  // 文件操作
  selectFile: () => Promise<string | null>;
  readFile: (path: string) => Promise<string>;
  writeFile: (path: string, content: string) => Promise<void>;

  // 系统信息
  getSystemInfo: () => Promise<SystemInfo>;

  // 窗口控制
  minimizeWindow: () => void;
  maximizeWindow: () => void;
  closeWindow: () => void;

  // 事件监听
  onMenuAction: (callback: (action: string) => void) => () => void;
}

declare global {
  interface Window {
    electronAPI: ElectronAPI;
  }
}
```

## 4. Hook 封装模板

```typescript
// src/hooks/useElectronAPI.ts
import { useState, useCallback } from 'react';

export function useFileSelect() {
  const [filePath, setFilePath] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const selectFile = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const path = await window.electronAPI.selectFile();
      setFilePath(path);
      return path;
    } catch (err) {
      setError(err instanceof Error ? err.message : '选择文件失败');
      return null;
    } finally {
      setIsLoading(false);
    }
  }, []);

  return { filePath, isLoading, error, selectFile };
}
```

## 5. AI 生成检查项

- [ ] 不直接使用 Node.js API
- [ ] 通过 `window.electronAPI` 调用
- [ ] 类型定义完整
- [ ] 错误处理
