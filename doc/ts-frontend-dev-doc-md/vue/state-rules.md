# Vue 3 状态管理规则（Pinia）

> 所属框架：Vue 3
> 最后更新：2026-04-11

---

## 1. 状态分类

| 类型 | 方案 | 适用场景 |
|------|------|---------|
| 组件局部 | `ref` / `reactive` | 表单、UI 状态 |
| 跨组件共享 | Pinia Store | 用户信息、购物车 |
| 服务端缓存 | VueQuery / Pinia + action | API 数据 |
| URL 状态 | Vue Router | 筛选、分页 |

## 2. Pinia Store 模板

```typescript
// stores/useOrderStore.ts
import { defineStore } from 'pinia';
import type { Order } from '@/types/order';
import { fetchOrders, createOrder } from '@/services/orderService';

interface OrderState {
  orders: Order[];
  currentOrder: Order | null;
  isLoading: boolean;
  error: string | null;
}

export const useOrderStore = defineStore('order', {
  state: (): OrderState => ({
    orders: [],
    currentOrder: null,
    isLoading: false,
    error: null,
  }),

  getters: {
    pendingOrders: (state) => state.orders.filter((o) => o.status === 'draft'),
    orderCount: (state) => state.orders.length,
  },

  actions: {
    async fetchOrders(userId: string) {
      this.isLoading = true;
      this.error = null;
      try {
        this.orders = await fetchOrders(userId);
      } catch (err) {
        this.error = err instanceof Error ? err.message : '获取订单失败';
      } finally {
        this.isLoading = false;
      }
    },

    async createOrder(data: CreateOrderRequest) {
      const order = await createOrder(data);
      this.orders.push(order);
      return order;
    },
  },
});
```

## 3. Setup Store 模板（推荐）

```typescript
// stores/useAuthStore.ts
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null);
  const token = ref<string | null>(null);

  const isAuthenticated = computed(() => !!token.value);
  const userName = computed(() => user.value?.name ?? '');

  function login(newUser: User, newToken: string) {
    user.value = newUser;
    token.value = newToken;
  }

  function logout() {
    user.value = null;
    token.value = null;
  }

  return { user, token, isAuthenticated, userName, login, logout };
});
```

## 4. 铁律

- 【强制】使用 Pinia，不用 Vuex
- 【推荐】Setup Store 风格（Composition API 风格）
- 【推荐】每个 Store 一个文件
- 【推荐】Store 命名：`use` + 名称 + `Store`
