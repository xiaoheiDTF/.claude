# application/assembler 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：应用层
> 所属模块：project-application
> 包路径：`com.company.project.application.assembler`

---

## 1. 创建规则

### 什么时候创建
- 需要 Command/DTO ↔ 领域对象（Param）转换时
- 需要 领域对象 → DTO 转换时

### 创建什么
- Assembler/Converter 转换类

### 一个业务对应几个文件
- 一个聚合 = 1 个 Assembler

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 转换类 | 聚合名+Assembler | `OrderAssembler`, `UserAssembler` |

---

## 3. 代码质量规则

### 【强制】
- 转换方法无副作用（纯函数）
- 所有字段都要转换，不能遗漏

### 【推荐】
- 使用 MapStruct 自动生成转换代码
- 手写转换时方法命名：`toDTO()`, `toParam()`, `toEntity()`

---

## 4. 依赖规则

### 可引用
- `domain.model.*`
- `model.dto.*`

### 禁止引用
- `infrastructure.*`

---

## 5. AI 生成检查项

- [ ] 所有字段都被转换
- [ ] 转换方法无副作用
- [ ] 双向转换完整

---

## 6. 代码模板

```java
// MapStruct 方式
@Mapper(componentModel = "spring")
public interface OrderAssembler {
    CreateOrderParam toParam(CreateOrderCommand command);
    OrderDTO toDTO(Order order);
    List<OrderDTO> toDTOList(List<Order> orders);
}
```
