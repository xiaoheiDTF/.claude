# Rule 配置模板

> 参考 cc_prompt.md 第二节 "Rules（规则文件）"

## 两种类型

| 类型 | 有 paths | 加载时机 | 适用场景 |
|------|---------|---------|---------|
| 无条件规则 | 无 | 启动时始终加载 | 全局编码规范、提交规范 |
| 条件规则 | 有 | 操作匹配文件时注入 | 特定技术栈规范、目录规范 |

---

## 模板 1：无条件规则（始终生效）

```markdown
# 文件: .claude/rules/<name>.md

- <规范 1>
- <规范 2>
- <规范 3>
```

### 示例：编码规范

```markdown
# 文件: .claude/rules/coding-standards.md

- TypeScript strict mode
- 禁止使用 any，必须提供明确类型
- 所有函数必须有返回类型标注
- 错误必须处理，不允许空 catch 块
- 优先使用 const，let 仅在需要重新赋值时使用
- 文件命名: kebab-case
- 导入排序: node 内置 → 外部包 → 内部模块，每组之间空行分隔
```

### 示例：提交规范

```markdown
# 文件: .claude/rules/commit-convention.md

- 使用 Conventional Commits 格式
- Types: feat, fix, refactor, docs, test, chore, perf
- 描述用祈使语气，小写，不加句号
- Breaking changes 在 footer 中标注 BREAKING CHANGE
- 每次提交只做一件事
```

### 示例：安全规范（全局）

```markdown
# 文件: ~/.claude/rules/security.md

- 禁止硬编码密钥、密码、token
- SQL 必须参数化查询
- 所有用户输入必须验证
- 敏感数据传输必须加密
```

---

## 模板 2：条件规则（按文件类型/路径触发）

```markdown
---
paths:
  - "<glob 模式 1>"
  - "<glob 模式 2>"
---

- <规范 1>
- <规范 2>
```

### 示例：前端规则

```markdown
---
paths:
  - "apps/web/**"
  - "packages/ui/**"
---

- React 18 + TypeScript
- 组件: 函数组件 + Hooks，禁止 class 组件
- Props: 使用 interface 定义，以 Props 后缀命名
- 文件名: PascalCase
- 样式: Tailwind CSS，禁止内联 style
- 状态管理: Zustand
- 禁止: 直接操作 DOM、useEffect 条件渲染
```

### 示例：后端规则

```markdown
---
paths:
  - "apps/api/**"
  - "packages/core/**"
---

- Node.js + Fastify + Prisma + Zod
- RESTful: 资源名复数
- Zod 验证所有输入
- 统一响应格式: { code, data, message }
- bcrypt salt ≥ 12
- 参数化查询，禁止拼接 SQL
```

### 示例：测试规则

```markdown
---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/tests/**"
  - "**/__tests__/**"
---

- 框架: Vitest（单元）、Playwright（E2E）、Supertest（API）
- 测试文件放在源文件旁边: <name>.test.ts
- describe 用模块名，it 描述行为
- 覆盖: 新代码 ≥ 80%，关键逻辑 ≥ 95%
- Mock 外部依赖，不 mock 内部模块
- 测试独立，async/await 禁 done callback
```

### 示例：数据库规则

```markdown
---
paths:
  - "**/prisma/**"
  - "**/db/**"
  - "**/migrations/**"
  - "**/schema.prisma"
---

- 模型按分组，必须有 id/createdAt/updatedAt
- 关系显式定义 onDelete/onUpdate
- Migration 必须有 up 和 down
- 数据和 schema 分开迁移
- 禁止删除有数据的列（先 deprecated）
- 外键必建索引
- 唯一约束用 @@unique
```

### 示例：基础设施规则

```markdown
---
paths:
  - "docker-compose.*"
  - "Dockerfile*"
  - "k8s/**"
  - ".github/workflows/**"
---

- Docker: 多阶段构建，node:20-alpine 基础镜像
- 非 root 运行，配置 .dockerignore
- CI/CD: lint → type-check → test → build
- 生产部署需 manual approval
- K8s: 必设 resources requests/limits
- ConfigMap/Secret 分离
```

---

## Paths 语法速查

### 基础模式

```yaml
# 匹配目录下所有文件
paths:
  - "src/**"

# 匹配多种文件扩展名
paths:
  - "src/*.{ts,tsx}"

# 匹配多个目录
paths:
  - "{apps/web,apps/mobile}/src/**"

# 逗号分隔写法
paths: "frontend/**, packages/ui/**"
```

### 高级模式

```yaml
# 取反（排除测试文件）
paths:
  - "src/**"
  - "!src/**/*.test.*"
  - "!src/**/*.spec.*"

# 深层嵌套（匹配任意深度）
paths:
  - "**/proto/**"
  - "**/*.proto"

# 精确扩展名
paths: "src/**/*.d.ts"
```

**注意**：
- `paths` 相对于**该 .md 文件所在的 .claude 目录的父目录**
- `src/**` 等价于 `src`（`/**` 后缀会自动去掉）
- `**` 表示匹配所有（等同于无条件规则）
- 多个条件规则可以**同时生效**
- 当 agent 使用 Read/Edit/Write 操作匹配文件时自动触发

---

## 多层级规则

```
优先级（从低到高）：
─────────────────────────────────
全局规则 (~/.claude/rules/)       1  最低
项目规则 (<project>/.claude/rules/)  2
子目录规则 (<subdir>/.claude/rules/) 3
托管策略 (/etc/claude-code/)      4  最高
```

### 多规则叠加示例

编辑 `apps/web/src/components/Button.tsx` 时：

```
✓ coding-standards.md     无条件，始终加载
✓ commit-convention.md    无条件，始终加载
✓ frontend.md             paths 匹配 "apps/web/**"
✗ backend.md              paths 不匹配
✗ testing.md              非 .test.ts 文件，不匹配
```

---

## @include 引用

```markdown
<!-- 引用类型定义 -->
操作 API 路由时请遵循: @./docs/api-types.ts

<!-- 引用 Schema -->
当前数据模型: @./prisma/schema.prisma

<!-- 引用共享规范 -->
共享配置: @./.claude/rules/shared.md
```

- 最大嵌套 5 层
- 支持 60+ 文本格式

---

## Rule 编写要点

1. **简洁** — 每条规则一行，用 `-` 列表格式
2. **具体** — 写 "使用 Vitest" 而非 "使用测试框架"
3. **可执行** — 规则应该是 Claude 可以遵循的具体指令
4. **按关注点分文件** — 不要把所有规则塞进一个文件（5-15 条/文件）
5. **条件规则优先** — 能用 paths 限定的就不要用无条件规则，节省 token
6. **子目录规则** — paths 相对于其 .claude 目录的父目录
7. **托管策略** — 由 IT 安全团队管理，不可被覆盖，最高优先级
