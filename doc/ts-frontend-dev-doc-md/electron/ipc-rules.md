# Electron IPC 通信规则

> 所属层：Main Process ↔ Renderer Process 桥梁
> 最后更新：2026-04-11

---

## 1. IPC 通道定义规则

- 所有通道名称集中定义
- 通道名使用 PascalCase 命名空间格式
- 请求/响应类型强约束

## 2. 代码质量规则

### 【强制】
- 通道名称集中管理，不硬编码字符串
- IPC Handler 参数校验
- Preload 只暴露必要的 API，不暴露整个 ipcRenderer

### 【禁止】
- 使用 `ipcRenderer.send` 做双向通信（用 invoke/handle）
- 在 IPC 中传递函数或 DOM 对象（不可序列化）
- 不校验 IPC 消息内容

### 【推荐】
- 使用 `invoke/handle` 模式（Promise 化）
- 主进程 Handler 按业务领域拆分

## 3. 通道定义模板

```typescript
// electron/ipc/channels.ts

// 通道名常量
export const IPC_CHANNELS = {
  // 文件操作
  FILE_SELECT: 'file:select',
  FILE_READ: 'file:read',
  FILE_WRITE: 'file:write',

  // 订单操作
  ORDER_CREATE: 'order:create',
  ORDER_GET: 'order:get',
  ORDER_LIST: 'order:list',

  // 系统操作
  SYSTEM_INFO: 'system:info',
  APP_VERSION: 'app:version',
} as const;

// 请求/响应类型
export interface IpcRequest {
  [IPC_CHANNELS.FILE_READ]: { path: string };
  [IPC_CHANNELS.FILE_WRITE]: { path: string; content: string };
  [IPC_CHANNELS.ORDER_CREATE]: { userId: string; items: OrderItemInput[] };
  [IPC_CHANNELS.ORDER_GET]: { id: string };
}

export interface IpcResponse {
  [IPC_CHANNELS.FILE_READ]: string;
  [IPC_CHANNELS.FILE_WRITE]: void;
  [IPC_CHANNELS.ORDER_CREATE]: Order;
  [IPC_CHANNELS.ORDER_GET]: Order | null;
}
```

## 4. Preload 脚本模板

```typescript
// electron/preload.ts
import { contextBridge, ipcRenderer } from 'electron';
import { IPC_CHANNELS } from './ipc/channels';

const electronAPI = {
  // 文件操作
  selectFile: () => ipcRenderer.invoke(IPC_CHANNELS.FILE_SELECT),
  readFile: (path: string) => ipcRenderer.invoke(IPC_CHANNELS.FILE_READ, { path }),
  writeFile: (path: string, content: string) =>
    ipcRenderer.invoke(IPC_CHANNELS.FILE_WRITE, { path, content }),

  // 系统信息
  getSystemInfo: () => ipcRenderer.invoke(IPC_CHANNELS.SYSTEM_INFO),

  // 事件监听（单向：主进程 → 渲染进程）
  onMenuAction: (callback: (action: string) => void) => {
    const handler = (_event: Electron.IpcRendererEvent, action: string) => callback(action);
    ipcRenderer.on('menu:action', handler);
    return () => ipcRenderer.removeListener('menu:action', handler);
  },
};

// 通过 contextBridge 安全暴露 API
contextBridge.exposeInMainWorld('electronAPI', electronAPI);
```

## 5. IPC Handler 模板

```typescript
// electron/ipc/handlers/orderHandler.ts
import { ipcMain } from 'electron';
import { IPC_CHANNELS } from '../channels';
import { validateCreateOrderRequest } from '../validators';

export function registerOrderHandlers() {
  ipcMain.handle(IPC_CHANNELS.ORDER_CREATE, async (_event, request) => {
    // 参数校验
    if (!validateCreateOrderRequest(request)) {
      throw new Error('Invalid order request');
    }

    // 业务处理
    const order = await orderService.create(request);
    return order;
  });

  ipcMain.handle(IPC_CHANNELS.ORDER_GET, async (_event, { id }) => {
    if (!id || typeof id !== 'string') {
      throw new Error('Invalid order id');
    }
    return orderService.findById(id);
  });
}
```

```typescript
// electron/ipc/handlers/index.ts
import { registerOrderHandlers } from './orderHandler';
import { registerFileHandlers } from './fileHandler';

export function registerIpcHandlers() {
  registerOrderHandlers();
  registerFileHandlers();
}
```

## 6. AI 生成检查项

- [ ] 通道名集中定义
- [ ] Preload 使用 contextBridge
- [ ] Handler 参数校验
- [ ] 使用 invoke/handle 模式
- [ ] 事件监听有清理函数
- [ ] 类型安全

> 来源：[Electron Security](https://electronjs.org/docs/latest/tutorial/security) (A), [Electron IPC Guide](https://medium.com/@lyzgeorge/understanding-ipc-in-electron-simplified-explanation-and-code-examples-p2-7d744a76719c) (B)
