# 大厂通用测试规范

> 综合阿里巴巴、Google、腾讯等权威测试实践
> 最后更新：2026-04-11
> 适用语言：Java / Go / Rust / TypeScript（通用原则）

---

## 一、测试理念与原则

### 1.1 测试金字塔

```
        ╱  E2E 测试  ╲          ~10% — 关键用户路径
       ╱───────────────╲
      ╱   集成测试       ╲        ~20% — 模块交互验证
     ╱───────────────────╲
    ╱     单元测试         ╲      ~70% — 函数/方法级别
   ╱───────────────────────╲
```

- 底层单元测试：数量最多、执行最快、维护成本最低
- 中层集成测试：验证模块间协作、数据库交互、API 接口
- 顶层 E2E 测试：验证完整用户流程，数量最少、速度最慢

> 来源：[Martin Fowler - Test Pyramid](https://martinfowler.com/articles/testPyramid.html)

### 1.2 AIR 原则（阿里巴巴）

- **A — Automatic（自动化）**：测试全自动执行，非交互式，不依赖人工检查
- **I — Independent（独立性）**：测试用例之间不能互相调用或依赖执行顺序
- **R — Repeatable（可重复）**：不受外界环境影响，每次运行结果一致

### 1.3 FIRST 原则（Google）

- **Fast**：测试必须快速执行（单元测试 < 100ms）
- **Independent**：测试之间完全独立
- **Repeatable**：在任何环境都能重复通过
- **Self-validating**：自动判断通过/失败，使用 assert 而非 print
- **Timely**：与代码同步编写，不事后补写

### 1.4 BCDE 原则

- **Border**：边界值测试（循环边界、特殊取值、空值）
- **Correct**：正确输入得到预期结果
- **Design**：与设计文档结合编写测试
- **Error**：强制错误输入（非法数据、异常流程）得到预期结果

---

## 二、单元测试规范

### 2.1 基本要求

- 【强制】测试粒度至多是类级别，一般是方法级别
- 【强制】测试用例使用 assert 验证，禁止使用 `System.out` / `console.log` 人工检查
- 【强制】测试用例之间完全独立，不依赖执行顺序
- 【强制】测试代码写在独立测试目录：`src/test/`, `*_test.go`, `tests/`
- 【强制】核心业务、核心应用、核心模块的增量代码必须通过单元测试

### 2.2 命名规范

```
方法名_测试场景_预期结果

示例：
- createOrder_withValidInput_returnsSuccess
- getUserById_whenNotFound_throwsException
- calculatePrice_withDiscount_appliesDiscount
```

### 2.3 覆盖率要求

| 模块类型 | 语句覆盖率 | 分支覆盖率 |
|---------|-----------|-----------|
| 核心模块（支付/订单/认证） | ≥ 80% | ≥ 70% |
| 普通模块 | ≥ 60% | ≥ 50% |
| 新增/修改代码 | ≥ 70% | ≥ 60% |

> 来源：[阿里巴巴 Java 开发手册 - 单元测试](https://developer.aliyun.com/article/1024437)

### 2.4 测试用例设计

每个方法至少覆盖以下场景：

1. **正常路径（Happy Path）** — 合法输入，预期输出
2. **边界值** — 空值、零值、最大值、最小值
3. **异常路径** — 非法输入、null/undefined、类型错误
4. **并发场景** — 竞态条件（如适用）

### 2.5 各语言单元测试框架

| 语言 | 测试框架 | Mock 框架 | 断言库 |
|------|---------|----------|--------|
| Java | JUnit 5 | Mockito | AssertJ |
| Go | `testing` 包 | testify/mock | testify/assert |
| Rust | `#[test]` | mockall | assert_eq! |
| TypeScript | Jest | jest.fn() | expect() |

#### Java 示例

```java
@Test
@DisplayName("创建订单 - 有效输入 - 返回成功")
void createOrder_withValidInput_returnsSuccess() {
    // Given
    OrderRequest request = new OrderRequest("user123", List.of(item1, item2));

    // When
    OrderResult result = orderService.createOrder(request);

    // Then
    assertThat(result.isSuccess()).isTrue();
    assertThat(result.getOrderId()).isNotNull();
}
```

#### Go 示例

```go
func TestCreateOrder_ValidInput_ReturnsSuccess(t *testing.T) {
    // Given
    req := OrderRequest{UserID: "user123", Items: []Item{item1, item2}}

    // When
    result, err := orderService.CreateOrder(req)

    // Then
    assert.NoError(t, err)
    assert.NotNil(t, result.OrderID)
}
```

#### Rust 示例

```rust
#[test]
fn create_order_with_valid_input_returns_success() {
    // Given
    let request = OrderRequest::new("user123", vec![item1, item2]);

    // When
    let result = order_service.create_order(request);

    // Then
    assert!(result.is_ok());
    assert!(!result.unwrap().order_id.is_empty());
}
```

---

## 三、集成测试规范

### 3.1 集成测试范围

- 数据库交互（CRUD 操作、事务一致性）
- 外部 API 调用（HTTP 接口、gRPC）
- 消息队列（生产者/消费者）
- 缓存层交互（Redis/Memcached）

### 3.2 测试环境管理

- 【推荐】使用 Docker 容器化测试环境（数据库、消息队列等）
- 【推荐】使用 Testcontainers（Java/Go）自动管理容器生命周期
- 【强制】测试数据使用程序插入，禁止手动插入数据库
- 【强制】测试结束后清理数据，或使用事务回滚

### 3.3 API 测试规范

- 【强制】验证 HTTP 状态码
- 【强制】验证响应体结构和数据类型
- 【强制】测试边界条件（空列表、超大分页、特殊字符）
- 【强制】测试错误处理（无效参数、未授权、服务不可用）

```
测试清单：
□ 200 OK — 正常返回
□ 400 Bad Request — 参数校验失败
□ 401 Unauthorized — 未认证
□ 403 Forbidden — 无权限
□ 404 Not Found — 资源不存在
□ 500 Internal Error — 服务端异常
```

---

## 四、端到端（E2E）测试规范

### 4.1 E2E 测试范围

- 【强制】仅覆盖核心业务流程（注册/登录/下单/支付等）
- 【推荐】E2E 测试数量不超过测试总量的 10%
- 【推荐】优先测试高风险、高价值路径

### 4.2 框架推荐

| 框架 | 适用场景 | 推荐度 |
|------|---------|--------|
| Playwright | 跨浏览器、自动化桌面应用 | ★★★★★ |
| Cypress | Web 应用 | ★★★★ |
| Selenium | 传统 Web 应用 | ★★★ |

### 4.3 E2E 最佳实践

- 【强制】使用页面对象模型（Page Object Model）封装页面操作
- 【推荐】使用数据驱动测试（外部数据文件管理测试数据）
- 【推荐】智能等待策略（等待网络空闲、等待元素可见），禁止硬编码 `sleep`
- 【推荐】失败时自动截图/录屏，保留 trace 文件

```typescript
// Page Object Model 示例
class LoginPage {
  constructor(private page: Page) {}

  async login(username: string, password: string) {
    await this.page.fill('[data-testid="username"]', username);
    await this.page.fill('[data-testid="password"]', password);
    await this.page.click('[data-testid="login-btn"]');
    await this.page.waitForURL('/dashboard');
  }
}
```

> 来源：[Google Testing Blog](https://testing.googleblog.com/)

---

## 五、Mock 与 Stub 规范

### 5.1 何时使用 Mock

- 外部 API 调用（第三方服务）
- 数据库操作（单元测试中）
- 文件系统/网络操作
- 时间依赖的测试
- 成本高昂的操作

### 5.2 Mock 原则

- 【强制】只 mock 外部边界，不 mock 被测类本身
- 【强制】不要 mock 值对象（DTO/VO 等）
- 【推荐】优先验证状态（输出结果），而非验证交互（方法调用次数）
- 【推荐】mock 最小化 — mock 过多说明代码耦合过重

```
Mock 决策树：
需要测试的功能依赖外部系统？
├── 是 → 使用 Mock
└── 否 → 使用真实实现
    ├── 真实实现太慢？
    │   ├── 是 → 使用 Mock
    │   └── 否 → 使用真实实现
```

---

## 六、测试数据管理

- 【推荐】使用数据工厂模式创建测试数据

```typescript
// 工厂模式
function createTestUser(overrides?: Partial<User>): User {
  return {
    id: faker.string.uuid(),
    name: faker.person.fullName(),
    email: faker.internet.email(),
    ...overrides,
  };
}
```

- 【推荐】使用 Faker 库生成随机测试数据
- 【强制】测试数据必须有明确标识前缀（如 `TEST_`）
- 【强制】测试结束后清理产生的数据
- 【推荐】不同测试使用独立数据，避免共享状态

---

## 七、CI/CD 中的测试

### 7.1 测试流水线

```
PR 阶段 → 单元测试 + lint
    ↓
合并阶段 → 集成测试
    ↓
部署前 → E2E 测试（核心流程）
    ↓
生产环境 → 冒烟测试 + 监控告警
```

### 7.2 测试门禁

- 【强制】PR 合并前必须通过所有单元测试
- 【强制】代码覆盖率不达标不允许合并
- 【推荐】失败测试自动重试 1-2 次（排除 flaky test）
- 【推荐】定期跟踪测试通过率趋势

---

## 八、性能测试规范

### 8.1 测试类型

| 类型 | 目的 | 频率 |
|------|------|------|
| 基准测试（Benchmark） | 测量函数/方法性能 | 每次提交 |
| 负载测试 | 模拟正常负载下的表现 | 每个版本 |
| 压力测试 | 找到系统极限 | 重大版本 |

### 8.2 各语言 Benchmark 框架

| 语言 | 框架 |
|------|------|
| Java | JMH |
| Go | `testing.B` |
| Rust | `#[bench]` / criterion |
| TypeScript | Benchmark.js / Vitest bench |

```go
// Go benchmark 示例
func BenchmarkCreateOrder(b *testing.B) {
    for i := 0; i < b.N; i++ {
        CreateOrder(testRequest)
    }
}
```

---

## 九、测试反模式

### 必须避免

| 反模式 | 问题 | 正确做法 |
|--------|------|---------|
| 测试实现细节 | 重构即破坏测试 | 测试公共行为/接口 |
| 过度 mock | 测试与实现强耦合 | 只 mock 外部边界 |
| 测试间共享状态 | 顺序依赖、难以调试 | 每个测试独立数据 |
| 硬编码等待时间 | 不稳定、执行慢 | 智能等待（条件满足即继续） |
| 忽略异步测试 | 时序错误被掩盖 | 使用 async/await + 超时 |
| 测试代码不维护 | 逐渐废弃 | 与业务代码同步维护 |
| 测试覆盖率造假 | 数字好看质量差 | 追求有效覆盖（分支+路径） |
| 只测 Happy Path | 边界问题漏测 | 边界+异常全覆盖 |
| Sleep 等待 | 不稳定且慢 | 轮询/事件驱动等待 |
| 截图对比测试 | 一点样式变化就失败 | 只对关键视觉元素做 snapshot |

---

## 参考来源

| 来源 | 质量等级 | 链接 |
|------|---------|------|
| 阿里巴巴 Java 开发手册 - 单元测试 | A | https://developer.aliyun.com/article/1024437 |
| Google Testing Blog - Code Coverage | A | https://testing.googleblog.com/2020/08/code-coverage-best-practices.html |
| 腾讯云 - 测试金字塔 | B | https://cloud.tencent.com/developer/article/2584819 |
| 阿里云 - 单元测试实践 | B | https://developer.aliyun.com/article/1081898 |
| Martin Fowler - Test Pyramid | A | https://martinfowler.com/articles/testPyramid.html |
| Google Testing Blog | A | https://testing.googleblog.com/ |
