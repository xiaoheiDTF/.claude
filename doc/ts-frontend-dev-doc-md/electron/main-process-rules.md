# Electron 主进程开发规则

> 所属层：Main Process（Node.js 环境）
> 最后更新：2026-04-11

---

## 1. 创建规则

- `main.ts` 只做应用启动和窗口创建
- 业务逻辑拆分到 `services/` 和 `ipc/handlers/`
- 主进程代码放在 `electron/` 目录

## 2. 代码质量规则

### 【强制】
- 主进程使用 TypeScript
- 窗口创建使用 `BrowserWindow` 工厂函数
- 安全选项必须配置（contextIsolation、nodeIntegration、sandbox）
- 应用退出时清理所有资源

### 【禁止】
- 在主进程中做 UI 渲染
- 直接暴露 Node.js API 给渲染进程
- 使用已废弃的 `remote` 模块
- 硬编码文件路径

### 【推荐】
- 使用 `electron-builder` 打包
- 使用 `electron-updater` 自动更新
- 日志使用 `electron-log`

## 3. 主入口模板

```typescript
// electron/main.ts
import { app, BrowserWindow } from 'electron';
import path from 'path';
import { registerIpcHandlers } from './ipc/handlers';

let mainWindow: BrowserWindow | null = null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,   // 必须开启
      nodeIntegration: false,   // 必须关闭
      sandbox: true,            // 必须开启
    },
  });

  // 开发环境加载 dev server
  if (process.env.NODE_ENV === 'development') {
    mainWindow.loadURL('http://localhost:5173');
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, '../dist/index.html'));
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.whenReady().then(() => {
  createWindow();
  registerIpcHandlers();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
```

## 4. AI 生成检查项

- [ ] contextIsolation: true
- [ ] nodeIntegration: false
- [ ] sandbox: true
- [ ] preload 脚本配置
- [ ] 开发/生产环境 URL 切换
- [ ] window-all-closed 处理
