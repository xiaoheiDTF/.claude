# TypeScript/JavaScript 前端开发全局规则

> AI 生成前端 TS/JS 代码时必须遵守的铁律，适用于所有框架（React / Vue）和平台（Web / Electron / 移动端）
> 最后更新：2026-04-11

---

## 一、命名铁律

| 场景 | 规则 | 正确示例 | 错误示例 |
|------|------|---------|---------|
| 文件名（组件） | PascalCase | `OrderList.tsx`, `useAuth.ts` | `orderList.tsx`, `order_list.tsx` |
| 文件名（非组件） | camelCase 或 kebab-case | `formatDate.ts`, `api-client.ts` | `FormatDate.ts` |
| 文件名（样式） | 与组件同名 | `OrderList.module.css`, `OrderList.styles.ts` | `order_list_style.css` |
| 文件名（测试） | 被测文件名 + `.test` | `OrderList.test.tsx` | `test_OrderList.tsx` |
| 组件名 | PascalCase | `OrderList`, `UserAvatar` | `orderList`, `order_list` |
| 函数/方法 | camelCase | `handleSubmit`, `fetchOrders` | `HandleSubmit`, `handle_submit` |
| 变量 | camelCase | `orderList`, `isVisible` | `OrderList`, `order_list` |
| 常量 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `API_BASE_URL` | `maxRetryCount` |
| 布尔变量 | is/has/can/should 前缀 | `isLoading`, `hasError`, `canEdit` | `loading`, `error` |
| 事件处理 | handle/on + 动作 | `handleSubmit`, `onClick` | `submit`, `clickHandler` |
| 类型/接口 | PascalCase | `Order`, `UserProps` | `order`, `IUserProps` |
| 枚举 | PascalCase（枚举名+值） | `enum OrderStatus { Draft, Confirmed }` | `enum ORDER_STATUS { DRAFT }` |
| CSS 类名 | camelCase（CSS Modules）或 kebab-case（BEM） | `.orderList`, `.order-list__item` | `.OrderList` |
| 自定义 Hook | use 前缀 | `useAuth`, `useOrderList` | `authHook`, `getAuth` |
| 工具函数 | camelCase | `formatDate`, `parseJSON` | `FormatDate` |

### 命名补充规则

- 【强制】React 组件文件名与导出的组件名一致
- 【强制】自定义 Hook 必须以 `use` 开头
- 【强制】类型名不加 `I` 前缀（`UserProps` 而非 `IUserProps`）
- 【推荐】布尔状态用 `is`/`has` 前缀：`const [isVisible, setVisible]`
- 【推荐】事件处理函数用 `handle` 前缀：`const handleClick = () => {}`

> 来源：[Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html), [React TypeScript Patterns](https://blog.logrocket.com/react-typescript-10-patterns-writing-better-code/)

---

## 二、TypeScript 类型铁律

### 2.1 绝对禁止

- 【禁止】使用 `any` 类型 — 必须使用 `unknown` 或具体类型
- 【禁止】使用 `@ts-ignore` — 使用 `@ts-expect-error` 并附带注释说明原因
- 【禁止】使用非原始包装类型 `Number`, `String`, `Boolean`, `Object` — 使用 `number`, `string`, `boolean`, `object`
- 【禁止】在类型定义中使用 `enum` 的数字值（应使用字符串枚举或 union type）
- 【禁止】为第三方库创建 `.d.ts` 而不先检查 `@types/xxx` 是否存在
- 【禁止】使用类型断言 `as` 代替类型保护（`typeof`, `instanceof`, `in`）

### 2.2 必须遵守

- 【强制】开启 `strict: true`（`tsconfig.json`）
- 【强制】所有函数参数和返回值必须有类型注解（能推断的除外）
- 【强制】使用 `interface` 定义对象类型，`type` 用于联合/交叉/工具类型
- 【强制】API 响应类型在独立的 `types/` 或 `api/` 目录中定义
- 【强制】组件 Props 使用独立类型定义（不内联）
- 【强制】使用 `readonly` 标记不可变属性
- 【强制】使用 `as const` 定义常量对象/数组

### 2.3 推荐做法

- 【推荐】优先使用 `type` 联合类型而非 `enum`
- 【推荐】使用泛型约束提高类型复用
- 【推荐】使用 Utility Types（`Pick`, `Omit`, `Partial`, `Required`）
- 【推荐】使用 Discriminated Union 处理多状态
- 【推荐】使用 `satisfies` 运算符验证类型而不改变推断类型

```typescript
// 正确：使用 union type 替代 enum
type OrderStatus = 'draft' | 'confirmed' | 'cancelled';

// 正确：使用 Discriminated Union
type ApiResult<T> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: string }
  | { status: 'loading' };

// 正确：使用 satisfies
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
} satisfies Record<string, string | number>;
```

---

## 三、编码铁律（AI 必须遵守）

### 3.1 绝对禁止

- 【禁止】`console.log` 提交到代码中 — 调试用 `console.debug` 或移除
- 【禁止】使用 `var` 声明变量 — 必须使用 `const`（首选）或 `let`
- 【禁止】在循环中创建闭包引用可变变量（使用 `let` 而非 `var`）
- 【禁止】直接修改 props/state — 必须创建新对象
- 【禁止】在 JSX 中使用 `index` 作为 key（除非列表是静态且不会变化的）
- 【禁止】使用内联函数作为 useEffect 依赖（造成无限循环）
- 【禁止】在条件语句中使用 `==` — 必须使用 `===`
- 【禁止】使用 `eval()`, `Function()` 构造器
- 【禁止】直接操作 DOM（除非在非框架环境中）
- 【禁止】未处理的 Promise（必须 catch 或 try-catch async/await）

### 3.2 必须遵守

- 【强制】使用 `const` 作为默认声明方式，只在需要重新赋值时用 `let`
- 【强制】使用可选链 `?.` 和空值合并 `??`
- 【强制】异步操作使用 `async/await`，不用 `.then()` 链
- 【强制】数组方法优先于 for 循环（`map`, `filter`, `reduce`, `find`）
- 【强制】使用模板字符串而非字符串拼接
- 【强制】使用解构赋值
- 【强制】文件末尾有换行符
- 【强制】使用 ES Module（`import/export`），不用 CommonJS（`require`）
- 【强制】导入顺序：React/框架 → 第三方库 → 项目内模块 → 类型导入

### 3.3 推荐做法

- 【推荐】使用早返回（guard clauses）减少嵌套
- 【推荐】使用对象参数代替多个参数
- 【推荐】提取魔法值为常量
- 【推荐】使用 `AbortController` 取消 fetch 请求

---

## 四、组件设计铁律

### 4.1 React 组件

```typescript
// 正确：函数组件 + Props 类型定义
interface OrderListProps {
  orders: Order[];
  isLoading: boolean;
  onSelectOrder: (id: string) => void;
}

const OrderList: React.FC<OrderListProps> = ({ orders, isLoading, onSelectOrder }) => {
  if (isLoading) return <LoadingSpinner />;

  return (
    <ul>
      {orders.map((order) => (
        <li key={order.id} onClick={() => onSelectOrder(order.id)}>
          {order.title}
        </li>
      ))}
    </ul>
  );
};
```

- 【强制】使用函数组件，不用类组件
- 【强制】组件单一职责
- 【强制】Props 类型独立定义
- 【强制】列表使用唯一 `key`
- 【推荐】组件文件不超过 200 行，超过则拆分
- 【推荐】展示组件与容器组件分离

### 4.2 Vue 组件

```vue
<script setup lang="ts">
interface Props {
  orders: Order[];
  isLoading: boolean;
}

const props = defineProps<Props>();
const emit = defineEmits<{
  selectOrder: [id: string];
}>();
</script>
```

- 【强制】使用 `<script setup lang="ts">` 语法
- 【强制】Props 使用 `defineProps<T>()` 泛型语法
- 【强制】Events 使用 `defineEmits<T>()` 类型定义

---

## 五、状态管理铁律

### 5.1 React 状态

- 【强制】局部状态用 `useState` / `useReducer`
- 【强制】跨组件状态用 Context 或状态库（Zustand / Jotai）
- 【强制】服务端状态用 TanStack Query（React Query）
- 【禁止】将整个应用状态放在一个 Context 中
- 【推荐】状态就近管理（与使用组件最近）

### 5.2 Vue 状态

- 【强制】局部状态用 `ref` / `reactive`
- 【强制】跨组件状态用 Pinia
- 【推荐】Composable 封装可复用状态逻辑

---

## 六、异步处理铁律

```typescript
// 正确：async/await + 错误处理
async function fetchOrders(userId: string): Promise<Order[]> {
  try {
    const response = await api.get<Order[]>(`/api/orders?userId=${userId}`);
    return response.data;
  } catch (error) {
    if (error instanceof AxiosError) {
      throw new BusinessError(error.response?.status ?? 500, error.message);
    }
    throw error;
  }
}

// 正确：React 中使用 TanStack Query
function useOrders(userId: string) {
  return useQuery({
    queryKey: ['orders', userId],
    queryFn: () => fetchOrders(userId),
    enabled: !!userId,
  });
}
```

- 【强制】所有 async 函数必须处理错误
- 【强制】React 中使用 TanStack Query 管理服务端状态
- 【强制】组件卸载时取消未完成的请求（使用 AbortController 或 TanStack Query 自动处理）
- 【推荐】loading / error / data 三态统一处理

---

## 七、样式铁律

- 【强制】使用 CSS Modules、CSS-in-JS 或 Tailwind CSS，不用全局 CSS
- 【强制】不使用 `!important`
- 【强制】不使用内联 `style` 属性（动态样式除外）
- 【推荐】使用设计令牌（Design Tokens）管理颜色、间距、字号

---

## 八、安全铁律

- 【强制】不使用 `dangerouslySetInnerHTML`（React）或 `v-html`（Vue），除非经过 sanitize
- 【强制】URL 参数使用 `encodeURIComponent` 编码
- 【强制】Token 不存储在 `localStorage`（使用 HttpOnly Cookie 或内存）
- 【强制】敏感信息（API Key、密码）不硬编码在前端代码中
- 【禁止】信任前端校验 — 后端必须有独立校验

---

## 九、AI 生成自查清单

每次生成前端 TS/JS 代码后，AI 必须逐项检查：

- [ ] 是否有 `any` 类型
- [ ] 是否有 `console.log`
- [ ] 是否使用了 `var`
- [ ] 组件 Props 是否有类型定义
- [ ] 列表是否使用唯一 key
- [ ] 是否有未处理的 Promise / async 错误
- [ ] 是否有 `dangerouslySetInnerHTML` 或 `v-html`
- [ ] 事件处理是否使用 `handle` 前缀
- [ ] 导入顺序是否正确
- [ ] 是否直接修改 state/props
- [ ] CSS 是否使用模块化方案
- [ ] 类型导入是否使用 `import type`

> 核心参考来源：
> - [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html) (A — Google 官方)
> - [TypeScript Do's and Don'ts](https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html) (A — TS 官方)
> - [React TypeScript Patterns](https://blog.logrocket.com/react-typescript-10-patterns-writing-better-code/) (B)
> - [Vue 3 + TypeScript Best Practices](https://eastondev.com/blog/en/posts/dev/20251124-vue3-typescript-best-practices/) (B)
> - [TypeScript Best Practices 2025](https://dev.to/mitu_mariam/typescript-best-practices-in-2025-57hb) (B)
