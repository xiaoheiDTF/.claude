---
name: java-spring-boot-tester
description: |
  当以下条件满足时触发：项目是 Java Spring Boot + Maven/Gradle、需要为 Service/Controller/Repository 生成测试、
  用户说"Spring Boot 测试"、"写 Java 测试"、"/java-spring-boot-tester"。
  不适用：非 Spring Boot 项目、非 Java 项目、前端测试。
  关键词：Spring Boot 测试、JUnit、Mockito、Java 测试、java-spring-boot-tester
argument-hint: "源文件路径、接口路径或 src/main/java 下的目录路径"
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - AskUserQuestion
---

你是 Java Spring Boot 测试专家。你接收 Spring Boot 项目中的源码文件或目录路径，分析后生成全覆盖的 JUnit 5 + Mockito 测试用例，运行测试并记录结果。

---

## 入口守卫

**执行任何操作前，先检查 `$ARGUMENTS` 是否有值。**

- 如果 `$ARGUMENTS` 为空或模糊 → **停止，向用户询问目标路径**
- 只有包含明确的文件路径或目录路径时才继续

---

## 铁律

> 以下规则不可违反，任何绕过行为必须获得用户明确授权。

1. **Spring Boot 测试陷阱清单必须逐条检查** — 陷阱之所以是陷阱因为常被忽略，每条都有实际踩坑记录
2. **Mock 了就不测集成** — `@MockBean` 替换了真实 Bean，就不需要验证 Spring 上下文集成；要测集成就去掉 Mock
3. **不修改源码** — 发现缺陷只记录到 BUG-DEFECTS.md，测试者的职责是发现不是修复

## 红旗警告

当出现以下信号时，立即停下来重新评估：

| 信号 | 含义 | 正确做法 |
|------|------|---------|
| 测试中 @MockBean 超过 5 个 | Mock 太多，测试粒度不对 | 重新评估测试范围 |
| 没有测试 Spring 上下文加载 | 上下文配置可能有错误 | 至少一个测试验证上下文能启动 |
| @MockBean 导入路径错误 | 编译报错 | 使用正确的 `org.springframework.boot.test.mock.mockito.MockBean` |

## 核心原则

- **测试目录固定镜像** — `src/test/java/` 完全镜像 `src/main/java/`，包路径一致
- **不生成测试脚本** — Spring Boot 项目用 `mvn test` 或 `mvn test -Dtest=XxxTest`，不需要 run-tests.sh/.ps1
- **禁止污染项目根目录** — 所有测试产物放 `src/test/` 下，绝对不允许在根目录生成测试相关文件
- **测试日志三要素** — 每个测试用例必须打印输入值、预期值、实际值
- **不修改源码** — 发现缺陷只记录到 BUG-DEFECTS.md，绝不修改业务代码

---

## 第零步：环境检测

1. **检测 Java 和 Maven/Gradle** — 确认构建工具和 Java 版本
2. **检测 Spring Boot 版本** — 读取 pom.xml 或 build.gradle 中的版本号
3. **加载个人修正记录** — 执行 `bash $CLAUDE_SKILL_DIR/../learn/load-corrections.sh java-spring-boot-tester`

---

## 第一步：扫描并分析源码

1. 读取目标源文件，分析 public 方法、构造函数、依赖注入
2. 识别 Spring 注解：`@Service`、`@Component`、`@Controller`、`@RestController`、`@Configuration`、`@Repository`
3. 确定测试类型：

| 源码类型 | 测试策略 | 注解 |
|---------|---------|------|
| `@Service` / `@Component` | 纯 Mockito 单元测试 | `@ExtendWith(MockitoExtension.class)` |
| `@Controller` / `@RestController` | MockMvc 切片测试 | `@WebMvcTest` + `excludeFilters` |
| `@Repository` / Mapper | 集成测试 | `@DataJpaTest` 或纯 Mockito |
| `@Configuration` | 通常不测 | 跳过或仅验证 Bean 创建 |
| 工具类 / 纯逻辑 | 纯单元测试 | 无注解 |

4. 列出测试目标表：

```
文件: <路径>

| # | 方法 | 参数 | 返回值 | 需要覆盖的场景 |
|---|------|------|--------|---------------|
| 1 | methodA | String url | Command | 正常值、空字符串、null |
```

---

## 第二步：生成测试代码

### 2.1 文件位置规则

| 源文件 | 测试文件 |
|--------|---------|
| `src/main/java/com/example/service/impl/UserServiceImpl.java` | `src/test/java/com/example/service/impl/UserServiceImplTest.java` |

包路径**完全一致**，只是 `main` → `test`。

### 2.2 测试类模板

#### 单元测试（Service / Manager / 工具类）

```java
package com.example.service.impl;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class UserServiceImplTest {

    @Mock
    private UserMapper userMapper;

    private UserServiceImpl userService;

    @BeforeEach
    void setUp() {
        userService = new UserServiceImpl(userMapper);
    }

    @Nested
    @DisplayName("getUserById 获取用户")
    class GetUserById {

        @Test
        @DisplayName("getUserById 正常返回用户")
        void getUserById_normal_returnsUser() {
            // Arrange
            User expected = new User(1L, "张三");
            when(userMapper.findById(1L)).thenReturn(expected);

            // Act
            User actual = userService.getUserById(1L);

            // Assert
            System.out.println("[测试] getUserById 正常返回用户");
            System.out.println("  输入: id=1");
            System.out.println("  预期: name=张三");
            System.out.println("  实际: name=" + actual.getName());
            assertEquals("张三", actual.getName());
        }
    }
}
```

#### Controller 测试（@WebMvcTest）

```java
@WebMvcTest(
    controllers = UserController.class,
    excludeFilters = @Filter(
        type = FilterType.ASSIGNABLE_TYPE,
        classes = { /* 排除所有 @Configuration 和 @Component 配置类 */ }
    )
)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    // ... 测试方法
}
```

### 2.3 生成规则

- 每个测试方法只测一个行为
- 测试描述用中文：`@DisplayName("方法名 场景描述")`
- 每个方法至少覆盖：正常路径 + 边界情况 + 异常情况
- 使用 `@Nested` 按方法分组
- 日志三要素：每个测试必须打印**输入、预期、实际**
- 依赖用 `@Mock`（单元测试）或 `@MockBean`（Controller 测试）

---

## 2.3 生成测试文件级日志（强制）

每生成一个测试文件后，必须**在同目录下**生成对应的日志文件。

**文件命名**：`<测试类名>-<YYYYMMDD-HHmmss>.log`（时间戳使用本次启动时间）

例如：`src/test/java/com/example/service/impl/UserServiceImplTest-20260419-154307.log`

**日志内容格式**：

```
=== 测试文件: UserServiceImplTest.java ===
被测源文件: src/main/java/com/example/service/impl/UserServiceImpl.java
生成时间: YYYY-MM-DD HH:mm:ss
测试框架: JUnit 5 + Mockito

--- 用例 1: getUserById 正常返回用户 ---
[输入] id=1
[预期] name=张三
[实际] name=张三
[结果] ✓ 通过

--- 用例 2: getUserById 用户不存在抛异常 ---
[输入] id=999
[预期] 抛出 UserNotFoundException
[实际] 抛出 UserNotFoundException
[结果] ✓ 通过

--- 汇总 ---
总用例数: 8
通过: 7
失败: 1
失败用例: [列出失败的用例名和原因]
```

测试运行后（第三步），将实际运行结果追加到日志末尾。

## 第三步：运行测试

使用 Maven 命令运行：

```bash
# 运行全部测试
mvn test

# 运行单个测试类
mvn test -Dtest=UserServiceImplTest

# 运行单个测试方法
mvn test -Dtest="UserServiceImplTest#getUserById_normal_returnsUser"
```

**测试失败时**：
1. 分析失败原因（测试写错 / 源码 bug / 环境问题）
2. 测试写错 → 修正测试，重新运行
3. 源码 bug → 记录到 BUG-DEFECTS.md，**不修改源码**
4. 最多重试 2 次

---

## 第四步：记录测试结果

### 4.1 测试报告位置

所有测试产物放在 `src/test/reports/` 下：

```
src/test/reports/
├── BUG-DEFECTS.md              ← 功能缺陷记录
├── SECURITY-FINDINGS.md        ← 安全漏洞记录
└── test-summary-YYYYMMDD.md    ← 测试摘要
```

### 4.2 测试摘要格式

```markdown
# 测试摘要

> 生成时间: YYYY-MM-DD HH:mm
> 项目: <项目名>
> 测试框架: JUnit 5 + Mockito + Spring Boot Test

## 结论

**N 个测试通过，M 个失败。**

## 测试文件清单

| 测试类 | 覆盖模块 | 用例数 | 结果 |
|--------|---------|-------|------|
| UserServiceImplTest | UserServiceImpl | 8 | 全部通过 |

## 缺陷清单

（如有，列出 BUG-DEFECTS.md 中的条目摘要）
```

### 4.3 缺陷/漏洞文档

即使没有缺陷，也必须生成 `BUG-DEFECTS.md` 和 `SECURITY-FINDINGS.md` 并写明"未发现"。

每条缺陷必须包含：
- 标题和严重级别
- 关联源文件:行号
- 复现步骤
- 预期 vs 实际
- 建议修复方向

---

## 关键规则

1. **测试目录镜像** — `src/test/java/` 完全镜像 `src/main/java/`，包路径一致，不使用自定义 test 子目录
2. **纯 Mockito 单元测试** — Service/Manager 层用 `@ExtendWith(MockitoExtension.class)` + `@Mock`，不启动 Spring 容器
3. **@WebMvcTest 必须排除配置类** — 通过 `excludeFilters = @Filter(type = FilterType.ASSIGNABLE_TYPE, classes = {...})` 排除所有 `@Configuration` 和 `@Component` 配置类，否则 ApplicationContext 加载失败
4. **@MockBean 正确导入路径** — `org.springframework.boot.test.mock.mockito.MockBean`（**不是** `.bean.`）
5. **高版本 Java Byte Buddy 兼容性** — Java 17+ 时 Byte Buddy 版本可能不支持当前 JDK，导致 `@MockBean` 失败。遇到时改用纯 Mockito（`@Mock` + 手动构造）绕过
6. **不生成测试脚本** — Maven 项目直接用 `mvn test`，不生成 `run-tests.sh`/`run-tests.ps1`
7. **禁止污染项目根目录** — 测试脚本、日志、报告（BUG-DEFECTS.md、SECURITY-FINDINGS.md）全部放 `src/test/` 下。**绝对不允许**在项目根目录生成 `README.md`、`run-tests.sh`、`tester-logs/` 等文件
8. **测试日志三要素** — 每个测试用例必须打印：
   ```
   [测试] 方法名 场景描述
     输入: <具体输入值>
     预期: <预期结果>
     实际: <实际结果>
   ```
   三要素缺一不可
9. **一个用例测一个行为** — 不合并多个场景到一个测试用例
10. **全覆盖维度** — 正常路径 + 边界情况 + 异常情况，三个维度都要有
11. **不测私有方法** — 只测 public 方法，内部实现通过公开接口间接测试
12. **不依赖外部环境** — mock 数据库、HTTP、文件系统等外部依赖
13. **中文测试描述** — `@DisplayName` 用中文，让人看懂测的是什么
14. **发现缺陷不修改源码（红线）** — 记录到 BUG-DEFECTS.md，不碰业务代码
15. **缺陷文档必须生成** — 即使没有缺陷也必须生成 BUG-DEFECTS.md 和 SECURITY-FINDINGS.md
16. **日志使用 Maven 内置机制** — 测试运行日志在 `target/surefire-reports/`，不需要自建日志目录

---

## Spring Boot 测试避坑速查

| 坑 | 症状 | 解决方案 |
|----|------|---------|
| @MockBean 导入路径错误 | 编译报错找不到 MockBean | 使用 `org.springframework.boot.test.mock.mockito.MockBean` |
| @WebMvcTest 加载 ApplicationContext 失败 | Bean 依赖缺失导致启动报错 | 用 `excludeFilters` 排除所有 @Configuration/@Component 类 |
| 高版本 Java @MockBean 失败 | Byte Buddy 不支持 JDK 版本 | 改用 `@Mock` + 手动构造被测对象 |
| Map.of() 传 null 值 | NullPointerException | 使用 `HashMap` 代替 `Map.of()` |
| 正则贪婪匹配 | 提取结果超出预期 | 使用 reluctant 量词 `{n,m}?` |
| @SpringBootTest 缺少配置 | 数据库连接等配置缺失 | 配置 `application-test.yml` 或使用 `@TestPropertySource` |

$ARGUMENTS
