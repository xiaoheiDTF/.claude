# 启动类开发规则

> 所属模式：单模块 DDD（简化模式）
> 包路径：`com.company.project`

---

## 1-5. 核心规则

- 一个项目一个启动类
- `@SpringBootApplication` 注解
- 不包含业务逻辑
- 配置文件按环境分离

## 6. 代码模板

```java
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```
