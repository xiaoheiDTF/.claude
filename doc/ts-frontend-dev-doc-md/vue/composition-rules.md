# Vue 3 Composition API 规则

> 所属框架：Vue 3
> 最后更新：2026-04-11

---

## 1. Composable 创建规则

- 文件以 `use` 开头，如 `useOrderList.ts`
- 一个 Composable 一个关注点
- 返回 ref/reactive 值供组件使用

## 2. 代码质量规则

### 【强制】
- Composable 必须以 `use` 开头
- 使用 `ref` / `reactive` 声明响应式状态
- 使用 `onUnmounted` 清理副作用
- 不在条件语句中调用 Composable

### 【推荐】
- 返回对象（非数组），方便解构和语义化
- 参数使用 `MaybeRefOrGetter` 类型以支持灵活使用

## 3. Composable 模板

```typescript
// composables/useOrderList.ts
import { ref, watch, toValue, onScopeDispose } from 'vue';
import type { Ref } from 'vue';
import type { Order } from '@/types/order';
import { fetchOrders } from '@/services/orderService';

export function useOrderList(userId: Ref<string>) {
  const orders = ref<Order[]>([]);
  const isLoading = ref(true);
  const error = ref<string | null>(null);

  let abortController: AbortController | null = null;

  const fetch = async () => {
    abortController?.abort();
    abortController = new AbortController();

    isLoading.value = true;
    error.value = null;

    try {
      orders.value = await fetchOrders(toValue(userId), {
        signal: abortController.signal,
      });
    } catch (err) {
      if (err instanceof DOMException && err.name === 'AbortError') return;
      error.value = err instanceof Error ? err.message : '获取订单失败';
    } finally {
      isLoading.value = false;
    }
  };

  // 监听 userId 变化自动重新获取
  watch(userId, fetch, { immediate: true });

  // 组件卸载时取消请求
  onScopeDispose(() => {
    abortController?.abort();
  });

  return { orders, isLoading, error, refetch: fetch };
}
```

## 4. 响应式选择

| 场景 | 使用 | 说明 |
|------|------|------|
| 基本值 | `ref` | `ref(0)`, `ref('')` |
| 对象 | `reactive` 或 `ref` | 推荐统一使用 `ref` |
| 只读派生 | `computed` | 自动缓存 |
| DOM 引用 | `template ref` | `const el = ref<HTMLElement>()` |

- 【推荐】统一使用 `ref`，避免 `ref` 和 `reactive` 混用
- 【强制】在 `<script setup>` 中访问 `ref` 的值不需要 `.value`（模板中自动解包）
- 【强制】在 JS 中访问必须用 `.value`

> 来源：[Vue Composition API Advanced Patterns](https://yeasirarafat.com/posts/vue-composition-api-advanced-patterns)
