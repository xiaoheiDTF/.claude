# React 状态管理规则

> 所属框架：React
> 最后更新：2026-04-11

---

## 1. 状态分类

| 类型 | 方案 | 适用场景 |
|------|------|---------|
| 组件局部状态 | `useState` / `useReducer` | 表单、UI 状态 |
| 跨组件共享状态 | Context / Zustand / Jotai | 主题、用户信息、全局设置 |
| 服务端缓存状态 | TanStack Query (React Query) | API 数据、分页、缓存 |
| URL 状态 | 路由参数 / searchParams | 筛选条件、分页、标签页 |

## 2. 代码质量规则

### 【强制】
- 服务端数据使用 TanStack Query，不用 useState + useEffect
- 全局状态使用 Zustand 或 Context，不通过 props 层层传递
- 状态更新不可变（不直接修改 state）

### 【禁止】
- 将 API 数据存入 Zustand/Context（应由 TanStack Query 管理）
- 在 Context 中存储频繁变化的状态
- Props drilling 超过 2 层

### 【推荐】
- 状态就近管理
- 复杂状态逻辑使用 `useReducer`
- URL 可序列化的状态用路由参数

## 3. Zustand Store 模板

```typescript
// stores/useAuthStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface User {
  id: string;
  name: string;
  email: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  login: (user: User, token: string) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      login: (user, token) => set({ user, token, isAuthenticated: true }),
      logout: () => set({ user: null, token: null, isAuthenticated: false }),
    }),
    { name: 'auth-storage' },
  ),
);
```

## 4. TanStack Query 模板

```typescript
// services/orderService.ts
import { api } from './api';

export const orderKeys = {
  all: ['orders'] as const,
  list: (userId: string) => [...orderKeys.all, userId] as const,
  detail: (id: string) => [...orderKeys.all, id] as const,
};

export function useOrderList(userId: string) {
  return useQuery({
    queryKey: orderKeys.list(userId),
    queryFn: () => api.get<Order[]>(`/orders?userId=${userId}`).then(r => r.data),
    enabled: !!userId,
    staleTime: 5 * 60 * 1000,
  });
}

export function useCreateOrder() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateOrderRequest) => api.post('/orders', data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: orderKeys.all });
    },
  });
}
```
