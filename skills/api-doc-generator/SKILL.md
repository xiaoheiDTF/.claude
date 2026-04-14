---
name: api-doc-generator
description: 根据后端 Controller/Router 源码自动生成按 Controller 组织的接口文档（Markdown），输出到当前服务项目根目录下的 `doc/controller/` 中。适用于 FastAPI、Spring Boot、Django REST、Gin 等框架。当用户说"写接口文档"、"生成 API 文档"、"按 Controller 出文档"、"前后端对接文档"时触发。
---

# API 文档生成器

根据后端 Controller/Router 源码自动生成结构化的接口文档，按 Controller 维度组织，统一存放在 `doc/controller/` 目录。

---

## 输入模式

根据用户输入确定目标：

1. **全量生成**：无具体路径时，扫描项目中的 Controller/Router 目录（如 `src/main/java/.../controller/`、`app/routers/`），为每个 Controller 生成文档
2. **指定生成**：用户提供具体 Controller 文件路径时，仅针对该文件生成文档
3. **更新模式**：`doc/controller/` 已存在文档时，基于最新源码重新生成并覆盖

---

## 工作流程

### 第一步：定位 Controller 源码

使用 Glob 或用户提供的路径找到所有 Controller/Router 文件：
- Java: `**/controller/*Controller.java`
- Python: `**/routers/*.py`
- 其他框架：按常见命名模式搜索

### 第二步：读取关联代码

对每个 Controller，读取以下关联文件以提取接口信息：
1. **Controller 本身** — 提取 URL 映射、HTTP 方法、方法名、参数类型
2. **DTO/Request/Response 模型** — 提取字段名、类型、必填性、说明
3. **异常处理** — 提取全局错误码、错误响应结构
4. **配置文件**（可选）— 提取基础路径、CORS、端口等

### 第三步：生成文档

为每个 Controller 生成一份 Markdown 文件，输出到**当前服务项目根目录**下的 `doc/controller/` 中：
```
<当前服务项目根目录>/doc/controller/
├── README.md              ← 文档入口（汇总 + 通用约定 + 快速验证）
├── ChatController.md      ← 对应 ChatController.java / chat.py
├── SessionController.md   ← 对应 SessionController.java / session.py
└── HealthController.md    ← 对应 HealthController.java / main.py
```

**命名规则**：
- Java 后端：与类名完全一致（`ChatController.java` → `ChatController.md`）
- Python 后端：与模块名一致（`chat.py` → `chat.md`）

### 第四步：生成 README.md 入口

`doc/controller/README.md` 必须包含：
- 文档列表表（文档名 | Controller | 前缀 | 说明）
- 通用约定（基础地址、JSON 命名规范、Content-Type、CORS）
- 错误响应通用结构
- 与多后端兼容性说明（如存在）
- 快速验证命令（curl 示例）

---

## 单份文档结构规范

每份 Controller 文档必须包含以下 6 个部分：

### 1. 接口概览表
```markdown
| 接口 | 方法 | URL | Content-Type | 说明 |
```

### 2. 请求说明
- URL、Headers
- 请求体/路径参数/查询参数表（字段名 | 类型 | 必填 | 说明）
- 请求 JSON 示例

### 3. 响应说明
- 成功响应字段表（字段名 | 类型 | 说明）
- 嵌套对象展开说明（如 MessageVO、CardDTO）
- 响应 JSON 示例

### 4. 错误响应
- 常见 HTTP 状态码及对应 code 表
- 错误体 JSON 示例

### 5. 前端对接说明
- 调用方式建议（fetch / axios）
- 状态管理提示（session_id 持久化）
- 组件分发提示（按 card_type 渲染）
- SSE 特殊处理说明（如适用）

### 6. 多后端兼容性（如适用）
- 若项目存在多语言/多框架后端实现，显式标注协议差异
- 典型差异：SSE 格式、错误结构、字段默认值

---

## JSON 与字段规范

- **字段命名**：文档中的 JSON 字段名必须与后端实际输出一致（`snake_case` 或 `camelCase`，以源码为准）
- **类型标注**：使用通用类型（string / integer / boolean / array / object）
- **必填标识**：请求参数必须标注"是/否"，响应字段标注"可能为 null"（如适用）
- **枚举说明**：若字段是枚举值，列出所有可取值

---

## 多后端兼容处理

当检测到项目存在多个后端实现（如 Python + Java）时：
1. 在每个后端的 `doc/controller/README.md` 中增加"与 X 后端的兼容性"小节
2. 显式列出协议差异点（SSE 事件格式、错误体结构、默认值差异）
3. 不要在单个后端文档中详细描述另一个后端的实现细节，只标注差异即可

---

## 关键规则

1. **文档必须基于源码生成** — 禁止凭空编造字段或 URL，所有信息必须从 Controller、DTO、异常处理代码中提取
2. **按 Controller 维度拆分** — 一个 Controller 对应一份文档，不混写
3. **目录同构** — `doc/controller/` 的结构与 `src/controller/` 保持对应关系
4. **必须包含示例** — 每个接口至少提供一个请求示例和一个响应示例
5. **错误码不可漏** — 全局异常处理器的错误响应必须在文档中体现
6. **敏感信息过滤** — 示例中若出现 API Key、内网 IP、密码等，替换为占位符
7. **前端对接必须有** — 文档不仅是后端自嗨，必须包含前端如何调用的说明
8. **输出目录相对化** — 文档必须生成在当前被文档化的服务项目根目录下，禁止输出到项目外的固定路径
9. **覆盖后更新 README** — 每生成/更新一个 Controller 文档，同步更新 `README.md` 中的文档列表
