# 大厂 TypeScript / 前端编码规范

> 综合 Google、腾讯、阿里、字节跳动等权威编码规范
> 最后更新：2026-04-11

---

## 一、TypeScript 命名规范

| 场景 | 规则 | 正确示例 | 错误示例 |
|------|------|---------|---------|
| 类型/接口 | PascalCase | `UserInfo`, `OrderDetail` | `userInfo`, `IUserInfo` |
| 枚举 | PascalCase（类型和值） | `HttpStatus.Ok` | `httpStatus.ok` |
| 函数 | camelCase | `getUserById`, `createOrder` | `GetUserById`, `get_user_by_id` |
| 变量 | camelCase | `orderList`, `userCount` | `OrderList`, `order_list` |
| 常量 | SCREAMING_SNAKE_CASE | `MAX_RETRY_COUNT` | `maxRetryCount` |
| 组件文件 | PascalCase | `OrderList.vue`, `UserCard.tsx` | `orderList.vue`, `user_card.tsx` |
| 工具文件 | camelCase 或 kebab-case | `dateUtils.ts`, `http-client.ts` | `DateUtils.ts` |
| 目录 | kebab-case 或 camelCase | `user-management/`, `components/` | `UserManagement/` |
| 布尔变量 | is/has/can/should 前缀 | `isValid`, `hasPermission` | `valid`, `permission` |

### 命名补充规则

- 【强制】不要用 `I` 前缀命名接口：`UserInfo` 而非 `IUserInfo`
- 【强制】不要为私有属性添加 `_` 前缀（TypeScript 有 `private` 关键字）
- 【强制】使用完整单词拼写，避免无意义缩写
- 【推荐】布尔变量使用 `is/has/can/should` 前缀
- 【推荐】事件处理函数使用 `on` 前缀：`onClick`, `onSubmit`

> 来源：[Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html), [腾讯 TypeScript 编码风格](https://cloud.tencent.com/developer/article/2190080)

---

## 二、TypeScript 编码实践

### 2.1 类型系统

- 【强制】优先使用 `interface` 定义对象类型，`type` 用于联合类型/工具类型
- 【强制】禁止使用 `any`，使用 `unknown` 替代
- 【强制】启用 `strict` 模式：`"strict": true` in tsconfig.json
- 【推荐】使用类型守卫收窄类型

```typescript
// 正确 — 类型守卫
function process(value: string | number): string {
  if (typeof value === 'string') {
    return value.toUpperCase();
  }
  return value.toFixed(2);
}

// 错误 — 使用 any
function process(value: any): string {
  return value.toUpperCase(); // 不安全
}
```

- 【推荐】使用 `as const` 定义不可变值
- 【推荐】优先使用可选属性 `?` 而非 `| undefined`

### 2.2 空值处理

- 【强制】优先使用 `undefined` 而非 `null`
- 【推荐】使用可选链 `?.` 和空值合并 `??`

```typescript
// 正确
const city = user?.address?.city ?? '未知';

// 错误
const city = user && user.address && user.address.city ? user.address.city : '未知';
```

### 2.3 枚举

- 【推荐】避免使用数字枚举，使用字符串枚举或 union type 替代

```typescript
// 推荐 — union type
type Status = 'pending' | 'active' | 'completed';

// 可接受 — 字符串枚举
enum Status {
  Pending = 'PENDING',
  Active = 'ACTIVE',
  Completed = 'COMPLETED',
}

// 不推荐 — 数字枚举
enum Status {
  Pending,    // 0
  Active,     // 1
  Completed,  // 2
}
```

### 2.4 模块

- 【强制】使用 ES Module（`import/export`），禁止 CommonJS（`require`）
- 【推荐】命名导出优于默认导出（更好的重构支持）

```typescript
// 推荐
export function createUser() { ... }
export function deleteUser() { ... }

// 不推荐 — 默认导出
export default class UserService { ... }
```

### 2.5 异步

- 【强制】使用 `async/await` 而非 `.then()` 链式调用
- 【强制】异步操作必须 `try-catch` 处理错误

```typescript
// 正确
async function fetchUser(id: string): Promise<User> {
  try {
    const response = await api.get(`/users/${id}`);
    return response.data;
  } catch (error) {
    logger.error('Failed to fetch user', error);
    throw new BusinessError('USER_FETCH_FAILED', '获取用户信息失败');
  }
}
```

---

## 三、前端通用规范

### 3.1 HTML 规范

- 【强制】使用语义化标签：`<section>`, `<article>`, `<aside>`, `<header>`, `<footer>`, `<nav>`
- 【推荐】组件多特性分行书写，按 ref → class → 传入 props → 传出 events 排序
- 【推荐】模板中复杂表达式提取为 computed 或 method
- 【强制】避免超过 3 行重复代码，配置数据后循环遍历

### 3.2 CSS/SCSS 规范

- 【强制】class 命名使用 BEM 或 kebab-case：`.order-list__item--active`
- 【强制】属性书写顺序：定位 → 盒模型 → 字体 → 背景 → 其他

```scss
// 属性书写顺序
.element {
  // 1. 定位
  position: fixed;
  top: 0;
  // 2. 盒模型
  display: flex;
  width: 100%;
  padding: 16px;
  // 3. 字体
  font-size: 14px;
  color: #333;
  // 4. 背景
  background-color: #fff;
  // 5. 其他
  border-radius: 4px;
}
```

- 【强制】嵌套不超过 3 层
- 【推荐】使用 `scoped` 约束样式范围
- 【禁止】禁止使用 `!important`（UI 框架覆盖除外）
- 【推荐】可复用属性提取为 SCSS 变量

### 3.3 Vue/React 组件规范

- 【强制】组件文件结构顺序：

```typescript
// Vue 组件顺序
export default {
  name: 'OrderList',       // 组件名
  props: {},               // Props 定义
  components: {},           // 子组件
  emits: [],               // 事件声明
  setup() {},              // Composition API
  data() { return {} },    // 数据
  computed: {},            // 计算属性
  watch: {},               // 监听器
  created() {},            // 生命周期
  mounted() {},
  methods: {},             // 方法
}
```

- 【强制】Props 必须定义类型和默认值
- 【推荐】组件内部方法用 `_` 前缀标识私有方法

---

## 四、工程化规范

### 4.1 代码检查

- 【强制】使用 ESLint + Prettier 统一代码风格
- 【强制】使用 husky + lint-staged 在提交前自动检查
- 【推荐】配置 `.editorconfig` 统一编辑器设置

### 4.2 目录结构

```
src/
├── api/               # 所有 API 接口
│   └── https/         # 封装的请求方法
├── assets/            # 静态资源（images, icons, styles）
├── components/        # 公共组件
│   ├── base/          # 基础组件（Button, Modal 等）
│   └── business/      # 业务组件
├── constants/         # 常量管理
├── hooks/             # 自定义 Hooks
├── router/            # 路由配置
├── store/             # 状态管理
├── types/             # 全局类型定义
├── utils/             # 工具函数
└── views/             # 页面视图
```

### 4.3 Git 规范

- 【强制】分支命名：`feature/xxx`, `bugfix/xxx`, `hotfix/xxx`
- 【强制】Commit 格式：`type(scope): description`
  - `feat`: 新功能
  - `fix`: 修复 bug
  - `docs`: 文档
  - `refactor`: 重构
  - `test`: 测试
  - `chore`: 构建/工具

---

## 五、注释规范

- 【强制】函数注释使用 JSDoc 格式
- 【强制】公共函数/方法必须包含描述、参数、返回值

```typescript
/**
 * 根据用户ID获取用户详情
 * @param userId - 用户ID
 * @param options - 查询选项
 * @returns 用户详情对象
 * @throws {BusinessError} 用户不存在时抛出
 */
async function getUserById(
  userId: string,
  options?: QueryOptions
): Promise<UserDetail> { ... }
```

- 【推荐】文件头注释包含文件描述、作者、日期
- 【推荐】复杂逻辑块上方加行注释

---

## 六、性能优化

- 【推荐】路由懒加载：`() => import('./views/OrderList.vue')`
- 【推荐】长列表使用虚拟列表
- 【推荐】搜索输入使用防抖（300ms）
- 【推荐】resize/scroll 事件使用节流
- 【推荐】图片使用懒加载 + WebP 格式
- 【推荐】使用 `v-once` / `React.memo` 避免不必要的重渲染
- 【推荐】CSS 动画使用 `transform` 和 `opacity`（GPU 加速）

---

## 参考来源

| 来源 | 质量等级 | 链接 |
|------|---------|------|
| Google TypeScript Style Guide | A | https://google.github.io/styleguide/tsguide.html |
| Google gts 工具 | A | https://github.com/google/gts |
| 腾讯 TypeScript 编码风格指南 | B | https://cloud.tencent.com/developer/article/2190080 |
| 腾讯前端代码规范 (TGideas) | A | https://tgideas.qq.com/doc/index.html |
| 百度前端代码规范 | B | https://github.com/ecomfe/spec |
| 前端代码规范（参考腾讯百度字节） | B | https://juejin.cn/post/7217305951551602743 |
| 阿里/腾讯/京东/百度前端规范汇总 | B | https://www.easemob.com/news/5648 |
