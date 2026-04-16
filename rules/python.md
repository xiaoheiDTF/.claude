---
paths:
  - "**/*.py"
---

# Python 编码规范

> 综合 PEP 8 / Google Python Style Guide / The Hitchhiker's Guide to Python / Real Python Best Practices

## 命名规范

- 函数和变量：snake_case（`get_user_info`, `is_active`）
- 类：PascalCase（`UserService`, `HttpClient`）
- 常量：UPPER_SNAKE_CASE（`MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT`）
- 模块名：snake_case，简短（`user_service.py`, `auth.py`）；测试文件：`test_<name>.py`
- 私有成员：单下划线前缀（`_internal_method`）；名称修饰：双下划线（`__mangled`）
- 布尔变量以 is/has/can/should 开头（`is_valid`, `has_permission`）
- 避免单字母变量名（循环计数器 `i` 和数学公式例外）
- 命名应描述意图（`user_age` 而非 `ua`，`filtered_users` 而非 `result`）
- 与关键字冲突时加后缀下划线（`class_` 而非 `klass`）
- 类型变量：PascalCase（`T`, `TUser`, `TResponse`）

## 代码格式

- 缩进：4 个空格，不使用 Tab
- 行宽：不超过 88 字符（Black 默认）或 79 字符（PEP 8 严格）
- 使用 `black` 自动格式化，`isort` 排序导入
- 二元运算符在换行时放在新行开头（PEP 8 数学表达式例外）
- 类之间空 2 行，方法之间空 1 行
- 函数内逻辑段落之间空 1 行
- 尾随逗号：多行集合和参数列表末尾加逗号

## 类型注解

- Python 3.10+ 使用内置类型（`list[str]` 而非 `List[str]`，`dict[str, int]` 而非 `Dict[str, int]`）
- 公共函数必须添加类型注解（参数和返回值）
- 使用 `Optional[T]` 或 `T | None` 标注可选参数
- 使用 `Union[A, B]` 或 `A | B` 标注联合类型
- 使用 `typing.Protocol` 定义结构化类型（鸭子类型的类型安全版本）
- 使用 `typing.Final` 标注不应重新赋值的变量
- 使用 `typing.overload` 为不同参数组合提供精确类型
- 复杂类型别名使用 `type Alias = ...`（Python 3.12+）或 `TypeAlias`
- 运行时类型验证使用 Pydantic 或 typeguard
- 配置 `mypy --strict` 或 `pyright --strict` 进行静态检查

## 函数设计

- 参数不超过 4 个；超过时使用关键字参数或 dataclass/pydantic model
- 默认参数不用可变对象（`def fn(items=None)` 然后 `items = items or []`）
- 单一职责，函数体控制在 30 行以内
- 纯函数优先，副作用集中在外层
- 提前返回减少嵌套（guard clauses）
- 使用 `*` 强制关键字参数（`def fn(*, name, age)`）
- 使用 `**kwargs` 仅在包装/代理场景，不作为常规参数传递方式
- 公共 API 添加 docstring（Google 风格或 NumPy 风格，项目内统一）

## 类与数据结构

- 优先使用 `dataclass`（`@dataclass`）定义纯数据容器
- 需要 Pydantic 验证时使用 `BaseModel`
- 普通 `class` 用于有行为的对象
- `__init__` 只做轻量初始化，复杂逻辑使用 `@classmethod` 工厂方法
- 使用 `__repr__` 提供可调试的字符串表示
- 使用 `__eq__` 和 `__hash__` 实现值语义
- 属性（`@property`）用于计算属性，不用于昂贵操作
- 使用 `__slots__` 优化内存（大量实例场景）
- 组合优于继承；继承层次不超过 3 层
- 使用 `abc.ABC` 和 `abc.abstractmethod` 定义抽象基类

## 异常处理

- 不使用裸 `except:`（必须指定异常类型）
- 不使用 `except Exception:` 吞掉所有异常（至少 `logging.exception` 记录）
- 自定义异常继承 `Exception`（非 `BaseException`），形成层次结构
- 使用 `raise ... from err` 保留原始异常链
- 在调用边界统一处理异常（API handler、CLI 入口、任务循环）
- 使用 `try/finally` 或 `contextlib` 确保资源释放
- 异常用于异常流程，不用于正常控制流（用 `if/else` 和返回值）

## 异步编程

- 使用 `async def` 定义协程函数
- I/O 操作（网络、文件、数据库）使用 `async/await`
- 使用 `asyncio.gather()` 并行执行独立协程
- 使用 `asyncio.create_task()` 启动后台任务
- 使用 `async with` 管理异步资源（连接池、锁）
- 使用 `anyio` 或 `asyncio` 的信号量控制并发数
- 避免 CPU 密集型操作阻塞事件循环（用 `asyncio.to_thread` 或 `ProcessPoolExecutor`）
- 异步上下文管理器使用 `@asynccontextmanager`

## 模块与导入

- 绝对导入优先于相对导入（`from package.module import func`）
- 导入顺序：标准库 → 第三方库 → 本地模块，每组空行分隔
- 禁止通配符导入（`from module import *`）
- 每行导入一个模块（`import os, sys` → 分两行）
- `__init__.py` 中使用 `__all__` 控制公开 API
- 包结构：`src/` 布局优于扁平布局
- 循环导入视为架构问题，必须重构
- 使用 `TYPE_CHECKING` 守卫仅类型检查时需要的导入

## 测试规范

- 框架：pytest（推荐）；unittest 仅用于向后兼容
- 测试文件：`test_<module>.py`；测试函数：`test_<behavior>`
- fixture 用于测试准备和清理，scope 按需设置
- 参数化测试使用 `@pytest.mark.parametrize`
- Mock 使用 `unittest.mock.patch` 或 `pytest-mock`
- Mock 外部依赖（网络、数据库），不 mock 被测模块内部函数
- 覆盖率：`pytest-cov`，新代码 ≥ 80%，核心逻辑 ≥ 95%
- 测试独立、幂等、可重复运行
- 使用 `conftest.py` 共享 fixture

## 性能优化

- 大数据集使用生成器（`yield`）代替列表，减少内存
- 优先使用内置函数和标准库（C 实现，更快）
- 字符串拼接使用 `join()`，不使用 `+` 循环拼接
- 字典查找 O(1)，避免在列表中线性搜索
- 使用 `collections.defaultdict` / `Counter` / `deque` 等专用容器
- CPU 密集型任务使用 `multiprocessing`（GIL 绕过）
- 使用 `functools.lru_cache` 缓存纯函数结果
- 数据库批量操作代替逐条插入
- 使用 `cProfile` / `line_profiler` 定位瓶颈，不盲目优化

## 安全规范

- 禁止 `eval()`、`exec()`、`__import__()` 处理不可信输入
- SQL 必须参数化查询（`cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))`）
- 文件路径操作使用 `pathlib`，验证不跳出预期目录
- 密码使用 `bcrypt` / `argon2` 哈希，禁止明文存储
- 使用 `secrets` 模块生成随机 token，不使用 `random`
- 禁止硬编码密钥/token，使用环境变量或密钥管理服务
- 输入验证：类型、长度、范围、格式（使用 Pydantic）
- 敏感日志脱敏（密码、token、个人信息）
- 依赖审计：`pip-audit` / `safety check`

## 魔法变量治理

### 三级判定

| 级别 | 条件 | 做法 |
|------|------|------|
| ① inline | 只在 1~2 处使用，不跨模块 | 直接写在代码中 |
| ② 常量文件 | 跨 3+ 模块使用，或容易拼错 | `constants.py`，`UPPER_SNAKE_CASE` 模块级常量 |
| ③ 类型约束 | 天然属于类型定义 | `StrEnum` / `Literal` 类型 |

**配置数值** → `pydantic-settings` 的 `BaseSettings` + `.env` 环境变量，保留默认值。

### 标准写法

```python
# constants.py — 模块级常量，按域分组
SSE_EVENT_TOKEN = "token"
SSE_EVENT_DONE = "done"
DEFAULT_LOCALE = "zh-CN"
```

### 替换原则

- **纯机械替换**：只改字面量为常量引用，不改变运行时行为
- **值完全一致**：常量值必须与原硬编码完全一致

### 实现顺序

定义常量文件（底层零依赖）→ 替换消费代码 → 同步文档
