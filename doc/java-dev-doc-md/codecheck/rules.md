# Java 代码检查规则（静态分析 & 质量门禁）

> 适用于所有架构模式（DDD / MVC）
> 最后更新：2026-04-11

---

## 一、工具矩阵

| 工具 | 检查层面 | 核心能力 |
|------|---------|---------|
| **Checkstyle** | 源码格式/风格 | 缩进、命名、Javadoc、行长度 |
| **PMD** | 源码质量 | 空块、未使用代码、复杂度、优化 |
| **SpotBugs** | 字节码 Bug | 空指针、资源泄漏、并发问题 |
| **SonarQube** | 综合质量 | 集成以上全部 + 趋势追踪 |
| **ArchUnit** | 架构约束 | 分层依赖、包规则 |
| **JaCoCo** | 测试覆盖率 | 行/分支覆盖率 |

### 推荐组合

```
最小（小项目）：Checkstyle + PMD + SpotBugs
标准（中项目）：以上 + JaCoCo + SonarQube
完整（大项目）：以上 + ArchUnit + 自定义 SonarQube 规则
```

---

## 二、圈复杂度规则

| CC 值 | 等级 | 建议 |
|-------|------|------|
| 1-4 | 低 | 无需处理 |
| 5-7 | 中 | 可接受 |
| 8-10 | 高 | 考虑重构 |
| 11+ | 极高 | **必须重构** |

- 【强制】方法圈复杂度 ≤ 10
- 【推荐】超过 7 触发告警

---

## 三、代码规模阈值

| 指标 | 阈值 | PMD/Checkstyle 规则 |
|------|------|---------------------|
| 方法长度 | ≤ 80 行 | `ExcessiveMethodLength` |
| 类字段数 | ≤ 20 个 | `TooManyFields` |
| 方法参数 | ≤ 5 个 | `ExcessiveParameterList` |
| 类方法数 | ≤ 20 个 | `TooManyMethods` |
| 单行长度 | ≤ 120 字符 | `LineLength` |

---

## 四、阿里巴巴 P3C 强制规则 Top 10

1. **禁止**用 `==` 比较包装类对象 → 用 `equals()`
2. **禁止**空 catch 块
3. **强制**重写 `equals()` 同时重写 `hashCode()`
4. **禁止**拆箱前未判空（NPE 风险）
5. **强制** switch 有 default
6. **禁止**魔法值
7. **强制** POJO 用包装类
8. **禁止** foreach 中 remove → 用 Iterator
9. **强制** ThreadPoolExecutor 创建线程池
10. **禁止**在业务代码中用 `System.out.println`

---

## 五、质量门禁阈值

| 指标 | 阻塞 | 告警 |
|------|------|------|
| Blocker Bug | 0 | 0 |
| Critical Bug | 0 | 0 |
| 行覆盖率 | ≥ 80% | < 70% |
| 重复代码率 | ≤ 3% | > 5% |
| 圈复杂度（方法） | ≤ 10 | > 7 |
| 安全漏洞 | 0 | 0 |
| 技术债务比率 | ≤ 5% | > 10% |

---

## 六、异常处理检查

### 必须检查的 PMD/SpotBugs 规则

| 规则 | 说明 | 级别 |
|------|------|------|
| `EmptyCatchBlock` | catch 块不能为空 | 错误 |
| `AvoidCatchingGenericException` | 避免捕获 Exception 基类 | 警告 |
| `DoNotThrowExceptionInFinally` | finally 禁止抛异常 | 错误 |
| `ReturnFromFinallyBlock` | finally 禁止 return | 错误 |
| `NP_ALWAYS_NULL` (SpotBugs) | 必然空指针解引用 | 错误 |
| `OS_OPEN_STREAM` (SpotBugs) | 流未关闭 | 错误 |

### 关键模式

```java
// ❌ finally 中抛异常
try { ... } finally { throw new IOException(); }

// ❌ finally 中 return（吞掉异常）
try { ... } finally { return; }

// ✅ try-with-resources
try (OutputStream out = new FileOutputStream("f")) {
    // ...
}
```

---

## 七、空指针防护

- 【强制】方法签名使用 `@Nullable` / `@NonNull`
- 【强制】返回空集合而非 null
- 【推荐】使用 `Optional` 包装可能为 null 的返回值
- 【推荐】使用 `Objects.requireNonNull()` 校验参数

---

## 八、命名检查规则（Checkstyle）

| 规则 | 说明 | 示例 |
|------|------|------|
| 包名全小写 | `com.company.project` | ✅ `com.example.order` |
| 类名大驼峰 | `UpperCamelCase` | ✅ `OrderService` |
| 方法名小驼峰 | `lowerCamelCase` | ✅ `createOrder` |
| 常量全大写下划线 | `UPPER_SNAKE_CASE` | ✅ `MAX_RETRY_COUNT` |
| import 顺序 | 静态→第三方→项目内 | Checkstyle `ImportOrder` |
| 星号 import | 禁止 | Checkstyle `AvoidStarImport` |

---

## 九、CI 集成模板

```yaml
# GitHub Actions 示例
steps:
  - name: Checkstyle
    run: mvn checkstyle:check
  - name: PMD
    run: mvn pmd:check
  - name: SpotBugs
    run: mvn spotbugs:check
  - name: Tests + Coverage
    run: mvn verify
```

```xml
<!-- Maven POM 集成 -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <version>3.3.1</version>
    <configuration>
        <configLocation>checkstyle.xml</configLocation>
        <failOnViolation>true</failOnViolation>
    </configuration>
</plugin>
<plugin>
    <groupId>com.github.spotbugs</groupId>
    <artifactId>spotbugs-maven-plugin</artifactId>
    <version>4.8.3.0</version>
    <configuration>
        <failOnError>true</failOnError>
    </configuration>
</plugin>
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
</plugin>
```
