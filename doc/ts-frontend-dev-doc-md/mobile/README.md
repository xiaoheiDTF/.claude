# 移动端跨平台开发规则 — 总览

> 适用场景：iOS + Android 跨平台应用
> 技术选型：React Native 或 Capacitor
> 最后更新：2026-04-11

---

## 技术选型对比

| 维度 | React Native | Capacitor (Ionic) |
|------|-------------|-------------------|
| 渲染方式 | 原生组件 | WebView |
| 性能 | 接近原生 | 接近 Web |
| UI 一致性 | 平台原生风格 | 统一 Web 风格 |
| 学习成本 | 需学 RN 组件 | Web 技术栈即可 |
| 原生能力 | 强（需写 Bridge） | 强（插件系统） |
| 适用场景 | 高性能交互应用 | 内容类/管理类应用 |
| 与 Web 共享代码 | 逻辑层可共享 | 几乎完全共享 |

---

## 目录结构

### React Native

```
src/
├── app/                    ← 路由/导航
├── components/
│   ├── ui/                 ← 通用 UI 组件（RN 组件）
│   └── features/           ← 业务组件
├── hooks/                  ← 自定义 Hooks
├── services/               ← API + 原生桥接
├── stores/                 ← 状态管理
├── navigation/             ← 导航配置
├── theme/                  ← 主题/样式常量
├── utils/
├── types/
├── platform/               ← 平台特定代码
│   ├── ios/
│   └── android/
└── assets/
```

### Capacitor

```
src/                        ← 与 Web 项目完全相同
├── components/
├── hooks/
├── services/
├── ...
android/                    ← Capacitor 生成的原生壳
ios/                        ← Capacitor 生成的原生壳
capacitor.config.ts
```

---

## 通用铁律

### 【强制】
- 使用 TypeScript
- 平台特定代码使用 `Platform.select()` 或条件导入
- 样式使用平台无关的单位（dp/pt 或相对单位）
- 触摸目标最小 44x44pt（iOS）/ 48x48dp（Android）

### 【禁止】
- 在 UI 线程做耗时操作
- 硬编码平台特定尺寸
- 忽略平台差异的 UI 设计

### 【推荐】
- 使用 React Navigation（RN）或 Vue Router（Capacitor）
- 深色模式适配
- 国际化支持
- 无障碍适配

---

## React Native 组件模板

```typescript
// components/features/OrderCard.tsx
import { View, Text, Pressable, StyleSheet } from 'react-native';
import type { Order } from '@/types/order';

interface OrderCardProps {
  order: Order;
  onPress: (order: Order) => void;
}

export function OrderCard({ order, onPress }: OrderCardProps) {
  return (
    <Pressable
      style={({ pressed }) => [styles.card, pressed && styles.pressed]}
      onPress={() => onPress(order)}
      accessibilityRole="button"
      accessibilityLabel={`订单 ${order.id}`}
    >
      <Text style={styles.title}>{order.title}</Text>
      <Text style={styles.status}>{order.status}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    padding: 16,
    borderRadius: 8,
    backgroundColor: '#fff',
    marginBottom: 8,
  },
  pressed: {
    opacity: 0.7,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
  },
  status: {
    fontSize: 14,
    color: '#666',
    marginTop: 4,
  },
});
```

---

## Capacitor 原生调用模板

```typescript
// services/nativeService.ts
import { Filesystem, Directory } from '@capacitor/filesystem';
import { Share } from '@capacitor/share';
import { Device } from '@capacitor/device';

export async function getDeviceInfo() {
  const info = await Device.getInfo();
  return {
    platform: info.platform, // 'web' | 'ios' | 'android'
    osVersion: info.osVersion,
    model: info.model,
  };
}

export async function saveFile(filename: string, data: string) {
  await Filesystem.writeFile({
    path: filename,
    data,
    directory: Directory.Documents,
  });
}
```

---

## AI 生成检查项

- [ ] 平台特定代码使用条件导入
- [ ] 触摸目标大小 ≥ 44pt
- [ ] 样式使用平台无关单位
- [ ] 无障碍标签
- [ ] 深色模式考虑
- [ ] TypeScript 类型完整

> 核心参考来源：
> - [Capacitor vs React Native 2025](https://nextnative.dev/blog/capacitor-vs-react-native) (B)
> - [Cross-Platform Development 2025 Guide](https://nexuresoft.com/blog/cross-platform-development-2025) (B)
> - [Capacitor 官方文档](https://capacitorjs.com/) (A)
