# Vue 3 组件开发规则

> 所属框架：Vue 3
> 最后更新：2026-04-11

---

## 1. 创建规则

- 一个组件一个 `.vue` 文件
- 使用 SFC（单文件组件）+ `<script setup lang="ts">`
- 多词组件名（除 App.vue 外）

## 2. SFC 块顺序

```vue
<script setup lang="ts">
// 1. 类型导入
// 2. 模块导入
// 3. 组件导入
// 4. Props/Emits 定义
// 5. Composables
// 6. 响应式状态
// 7. 计算属性
// 8. 侦听器
// 9. 方法/函数
// 10. 生命周期钩子
</script>

<template>
<!-- HTML -->
</template>

<style scoped lang="css">
/* CSS */
</style>
```

## 3. 代码质量规则

### 【强制】
- 使用 `<script setup lang="ts">` 语法
- Props 使用 `defineProps<T>()` 泛型语法
- Emits 使用 `defineEmits<T>()` 类型定义
- 使用 `defineExpose` 显式暴露公共方法
- 组件名使用 PascalCase（多词）

### 【禁止】
- 使用 Options API（新代码一律用 Composition API）
- 使用 `v-html`（除非经过 sanitize）
- 在 `<script setup>` 外部定义响应式状态
- 使用 `$parent` / `$children` 访问组件

### 【推荐】
- 组件文件不超过 200 行
- Props 设置默认值使用 `withDefaults`
- 使用 `computed` 替代模板中的复杂表达式

## 4. 代码模板

```vue
<script setup lang="ts">
import { ref, computed } from 'vue';
import type { Order } from '@/types/order';
import { useOrderList } from '@/composables/useOrderList';
import OrderCard from './OrderCard.vue';

// Props
interface Props {
  userId: string;
  pageSize?: number;
}

const props = withDefaults(defineProps<Props>(), {
  pageSize: 20,
});

// Emits
const emit = defineEmits<{
  selectOrder: [order: Order];
}>();

// Composables
const { orders, isLoading, error, refetch } = useOrderList(
  computed(() => props.userId),
);

// 状态
const selectedId = ref<string | null>(null);

// 方法
const handleSelect = (order: Order) => {
  selectedId.value = order.id;
  emit('selectOrder', order);
};
</script>

<template>
  <div v-if="isLoading" class="loading">加载中...</div>
  <div v-else-if="error" class="error">
    <p>{{ error }}</p>
    <button @click="refetch">重试</button>
  </div>
  <div v-else-if="orders.length === 0" class="empty">暂无订单</div>
  <div v-else class="order-list">
    <OrderCard
      v-for="order in orders"
      :key="order.id"
      :order="order"
      :is-selected="order.id === selectedId"
      @click="handleSelect(order)"
    />
  </div>
</template>

<style scoped>
.order-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
}
</style>
```

## 5. AI 生成检查项

- [ ] `<script setup lang="ts">` 语法
- [ ] Props 使用 `defineProps<T>()`
- [ ] Emits 使用 `defineEmits<T>()`
- [ ] loading / error / empty 三态处理
- [ ] 列表使用 `:key`
- [ ] `<style scoped>`
- [ ] 无 `v-html`

> 来源：[Vue 3 + TypeScript Enterprise Guide](https://eastondev.com/blog/en/posts/dev/20251124-vue3-typescript-best-practices/), [Vue 3 Best Practices](https://medium.com/@ignatovich.dm/vue-3-best-practices-cb0a6e281ef4)
