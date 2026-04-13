# React Hooks 开发规则

> 所属框架：React
> 最后更新：2026-04-11

---

## 1. 创建规则

- 可复用逻辑提取为自定义 Hook
- Hook 文件以 `use` 开头
- 一个 Hook 一个关注点

## 2. 代码质量规则

### 【强制】
- 自定义 Hook 必须以 `use` 开头
- 不在条件/循环/嵌套函数中调用 Hooks
- useEffect 必须有正确的依赖数组
- useEffect 中清理副作用（定时器、订阅、AbortController）

### 【禁止】
- useEffect 依赖缺失（会导致 stale closure）
- useEffect 依赖过多（考虑拆分）
- 在 useEffect 中做不必要的 state 设置

### 【推荐】
- 使用 `useCallback` 传递给子组件的函数
- 使用 `useMemo` 计算昂贵值
- 自定义 Hook 返回 `[state, dispatch]` 或对象

## 3. 自定义 Hook 模板

```typescript
// useOrderList.ts
import { useState, useEffect, useCallback } from 'react';
import type { Order } from './order.types';
import { fetchOrders } from '@/services/orderService';

interface UseOrderListReturn {
  orders: Order[];
  isLoading: boolean;
  error: string | null;
  refetch: () => void;
}

export function useOrderList(userId: string): UseOrderListReturn {
  const [orders, setOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetch = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await fetchOrders(userId);
      setOrders(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : '获取订单失败');
    } finally {
      setIsLoading(false);
    }
  }, [userId]);

  useEffect(() => {
    const controller = new AbortController();
    fetch();
    return () => controller.abort();
  }, [fetch]);

  return { orders, isLoading, error, refetch: fetch };
}
```

## 4. 常见 Hook 使用模式

```typescript
// 挂载时执行一次
useEffect(() => {
  fetchData();
}, []);

// 依赖变化时执行
useEffect(() => {
  if (userId) fetchUser(userId);
}, [userId]);

// 清理副作用
useEffect(() => {
  const subscription = subscribe(handler);
  return () => subscription.unsubscribe();
}, []);

// 防抖搜索
useEffect(() => {
  const timer = setTimeout(() => search(query), 300);
  return () => clearTimeout(timer);
}, [query]);
```

## 5. AI 生成检查项

- [ ] Hook 以 `use` 开头
- [ ] useEffect 依赖正确
- [ ] 副作用有清理逻辑
- [ ] 返回类型明确
- [ ] 无条件调用 Hook
