# interfaces/assembler 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：接口层
> 包路径：`com.company.project.interfaces.assembler`

---

## 1. 创建规则

### 什么时候创建
- 需要 Command/Query ↔ 领域对象转换时
- 需要 领域对象 → VO 转换时

### 创建什么
- Assembler 转换类

### 一个业务对应几个文件
- 一个聚合 = 1 个 Assembler

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 转换类 | 业务名+Assembler | `OrderAssembler` |

---

## 3. 代码质量规则

### 【强制】
- 转换方法无副作用
- 所有字段都要转换

### 【推荐】
- 使用 MapStruct

---

## 4. 依赖规则

### 可引用
- `interfaces.dto.*`
- `domain.model.*`（值对象、聚合根类型）
- `domain.model.valueobject.*`

### 禁止引用
- `infrastructure.*`

---

## 5. AI 生成检查项

- [ ] 字段转换完整
- [ ] 无副作用

---

## 6. 代码模板

```java
@Component
public class OrderAssembler {
    public CreateOrderParam toParam(CreateOrderCommand cmd) { ... }
    public OrderVO toVO(OrderDTO dto) { ... }
}
```
