# config 包开发规则

> 所属模式：三层 MVC
> 所属层：配置层
> 包路径：`com.company.project.config`

---

## 1. 创建规则

- 需要自定义 Spring 配置时创建（Redis、DataSource、WebMvc 等）

## 2. 文件命名规则

功能名+Config，如 `RedisConfig`, `WebMvcConfig`。

## 3. 代码质量规则

- 【强制】使用 `@Configuration` 注解
- 【强制】不含业务逻辑
- 【推荐】每个配置领域一个文件

## 4. 依赖规则

- 可引用：Spring 框架、第三方库配置
- 禁止引用：`service.*`, `controller.*`

## 5. AI 生成检查项

- [ ] @Configuration 注解
- [ ] 无业务逻辑

## 6. 代码模板

```java
@Configuration
public class RedisConfig {
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(factory);
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new GenericJackson2JsonRedisSerializer());
        return template;
    }
}
```
