# model（共享模型）包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：共享模型层
> 所属模块：project-model
> 包路径：`com.company.project.model`

---

## 1. 创建规则

### 什么时候创建
- 定义内外部共享的 DTO、枚举、常量时
- client 和 application/infrastructure 都需要使用的对象时

### 创建什么
- 共享 DTO 类、枚举类、常量类

### 子包结构

```
model/
├── dto/         ← 共享 DTO（Request/Response）
├── enums/       ← 枚举
└── constant/    ← 常量
```

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| DTO | 业务名+DTO | `OrderDTO`, `OrderItemDTO` |
| 枚举 | 业务名+Status/Type | `OrderStatus`, `PaymentType` |
| 常量 | 业务名+Constants | `OrderConstants` |

---

## 3. 代码质量规则

### 【强制】
- 纯 POJO，无业务逻辑
- 不依赖任何技术框架
- DTO 使用 Bean Validation 注解（可被 client 和 application 引用）

### 【禁止】
- 禁止业务逻辑
- 禁止依赖 domain 模块（避免循环依赖）

---

## 4. 依赖规则

### 可引用
- Java 标准库
- Bean Validation 注解

### 禁止引用
- `domain.*`
- `application.*`
- `infrastructure.*`
- Spring 框架

---

## 5. AI 生成检查项

- [ ] 纯 POJO，无业务逻辑
- [ ] 无框架依赖
- [ ] DTO 有 Bean Validation

---

## 6. 代码模板

```java
public class OrderDTO {
    private String orderId;
    private String customerId;
    private String status;
    private List<OrderItemDTO> items;
    private BigDecimal totalAmount;
    // Getters + Setters
}

public enum OrderStatus {
    DRAFT, PLACED, PAID, SHIPPED, COMPLETED, CANCELLED;
}
```
