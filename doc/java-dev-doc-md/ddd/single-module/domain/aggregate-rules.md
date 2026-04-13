# domain/model/aggregate 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：领域层
> 包路径：`com.company.project.domain.model.aggregate`

---

## 1. 创建规则

与多模块完全一致。每个聚合根一个文件。

## 2. 文件命名规则

业务名词，无后缀。如 `Order`, `Contract`。

## 3. 代码质量规则

与多模块一致：
- 【强制】唯一 ID、充血模型、方法只做内存操作
- 【禁止】Spring 注解、注入 Repository、public setter

## 4. 依赖规则

### 可引用
- `domain.model.entity.*`
- `domain.model.valueobject.*`
- `domain.exception.*`
- `domain.event.*`
- `java.*`

### 禁止引用
- `interfaces.*`
- `application.*`
- `infrastructure.*`
- `org.springframework.*`

## 5. AI 生成检查项

与多模块一致。

## 6. 代码模板

与多模块 aggregate-rules.md 相同，但包路径为 `com.company.project.domain.model.aggregate`。
