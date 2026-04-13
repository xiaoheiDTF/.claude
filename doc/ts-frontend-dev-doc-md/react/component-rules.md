# React 组件开发规则

> 所属框架：React
> 适用范围：Web / Electron 渲染进程 / React Native
> 最后更新：2026-04-11

---

## 1. 创建规则

- 一个组件一个文件
- 组件文件名 = 组件名（PascalCase）
- 展示组件与业务组件分离

## 2. 文件命名规则

| 类型 | 命名 | 示例 |
|------|------|------|
| 页面组件 | PascalCase | `OrderPage.tsx` |
| 业务组件 | PascalCase | `OrderList.tsx` |
| UI 组件 | PascalCase | `Button.tsx` |
| Hook | use + PascalCase | `useOrderList.ts` |
| 类型 | 组件名 + .types | `order.types.ts` |
| 测试 | 组件名 + .test | `OrderList.test.tsx` |
| 样式 | 组件名 + .module | `OrderList.module.css` |

## 3. 代码质量规则

### 【强制】
- 使用函数组件，不用类组件
- Props 类型使用独立 interface 定义
- 导出使用命名导出（非 default export），页面级组件可例外
- 组件内逻辑按固定顺序：hooks → 事件处理 → 渲染

### 【禁止】
- 在组件内定义子组件（导致每次渲染都创建新组件）
- 在 JSX 中写复杂表达式（提取为变量或函数）
- 直接修改 props
- 内联复杂样式对象

### 【推荐】
- 组件文件不超过 200 行
- Props 解构在参数位置
- 条件渲染使用早返回

## 4. 代码模板

```tsx
// OrderList.tsx
import { useState } from 'react';
import type { Order } from './order.types';
import { useOrderList } from './useOrderList';
import { OrderCard } from './OrderCard';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import styles from './OrderList.module.css';

interface OrderListProps {
  userId: string;
  onSelectOrder?: (order: Order) => void;
}

export function OrderList({ userId, onSelectOrder }: OrderListProps) {
  const { orders, isLoading, error, refetch } = useOrderList(userId);
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const handleSelect = (order: Order) => {
    setSelectedId(order.id);
    onSelectOrder?.(order);
  };

  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} onRetry={refetch} />;
  if (orders.length === 0) return <EmptyState message="暂无订单" />;

  return (
    <div className={styles.container}>
      {orders.map((order) => (
        <OrderCard
          key={order.id}
          order={order}
          isSelected={order.id === selectedId}
          onSelect={handleSelect}
        />
      ))}
    </div>
  );
}
```

## 5. AI 生成检查项

- [ ] 函数组件
- [ ] Props 类型定义
- [ ] 命名导出
- [ ] loading / error / empty 三态处理
- [ ] 列表使用唯一 key
- [ ] 无内联子组件
- [ ] CSS Modules

> 来源：[React Design Patterns 2025](https://www.telerik.com/blogs/react-design-patterns-best-practices), [React 19 + TypeScript Guide](https://medium.com/@CodersWorld99/react-19-typescript-best-practices-the-new-rules-every-developer-must-follow-in-2025-3a74f63a0baf)
