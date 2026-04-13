# Go 代码检查规则（静态分析 & 质量门禁）

> 适用于所有架构模式（标准分层 / Clean Architecture / 微服务）
> 最后更新：2026-04-11

---

## 一、工具矩阵

| 工具 | 检查层面 | 核心能力 |
|------|---------|---------|
| **gofmt / goimports** | 源码格式 | 缩进、import 排序、未使用 import |
| **go vet** | 编译级检查 | Printf 参数、未使用变量、锁拷贝 |
| **staticcheck** | 高级静态分析 | 废弃 API、简化建议、Bug 检测 |
| **golangci-lint** | 综合质量 | 集成 50+ linters，并行运行 |
| **go test -race** | 竞态检测 | 数据竞争、并发安全 |
| **gocover** | 测试覆盖率 | 行/函数覆盖率 |
| **gosec** | 安全扫描 | SQL 注入、硬编码密码、弱加密 |

### 推荐组合

```
最小（小项目）：gofmt + go vet + staticcheck
标准（中项目）：golangci-lint（含 staticcheck + gosec） + go test -race + gocover
完整（大项目）：以上 + 自定义 golangci-lint 规则 + SonarQube + 架构约束检查
```

---

## 二、golangci-lint 核心配置

```yaml
# .golangci.yml
run:
  timeout: 5m
  go: "1.22"

linters:
  enable:
    # 默认启用的
    - errcheck        # 未检查的 error
    - gosimple        # 代码简化建议
    - govet           # go vet 检查
    - ineffassign     # 无效赋值
    - staticcheck     # 高级静态分析
    - unused          # 未使用的代码

    # 推荐额外启用
    - bodyclose       # HTTP Body 关闭检查
    - contextcheck    # context 传递检查
    - dupl            # 重复代码检测
    - errname         # 错误命名规范（Err 前缀）
    - exhaustive      # switch 穷尽检查
    - exportloopref   # 循环变量引用检查
    - funlen          # 函数长度限制
    - gocognit        # 圈复杂度
    - goconst         # 可提取为常量的字符串
    - gocritic        # 综合代码审查
    - gocyclo         # 圈复杂度
    - gofmt           # 格式检查
    - goimports       # import 排序
    - gosec           # 安全检查
    - misspell        # 拼写检查
    - nakedret        # 裸返回检查
    - nilerr          # nil error 检查
    - noctx           # HTTP 请求无 context 检查
    - prealloc        # slice 预分配建议
    - revive          # 综合代码规范
    - unconvert       # 不必要的类型转换
    - unparam         # 未使用的函数参数

linters-settings:
  funlen:
    lines: 80
    statements: 50
  gocyclo:
    min-complexity: 10
  gocognit:
    min-complexity: 10
  dupl:
    threshold: 100
  goconst:
    min-len: 3
    min-occurrences: 3
  revive:
    rules:
      - name: exported
      - name: unused-parameter
      - name: unreachable-code
      - name: context-as-argument
      - name: error-return
      - name: error-strings
      - name: error-naming
      - name: var-naming

issues:
  max-issues-per-linter: 50
  max-same-issues: 10
  exclude-rules:
    - path: _test\.go
      linters:
        - dupl
        - funlen
        - goconst
```

---

## 三、圈复杂度规则

| CC 值 | 等级 | 建议 |
|-------|------|------|
| 1-4 | 低 | 无需处理 |
| 5-7 | 中 | 可接受 |
| 8-10 | 高 | 考虑重构 |
| 11+ | 极高 | **必须重构** |

- 【强制】函数圈复杂度 ≤ 10
- 【推荐】超过 7 触发告警

---

## 四、代码规模阈值

| 指标 | 阈值 | golangci-lint linter |
|------|------|---------------------|
| 函数长度 | ≤ 80 行 | `funlen` |
| 圈复杂度 | ≤ 10 | `gocyclo`, `gocognit` |
| 文件长度 | ≤ 500 行 | 自定义规则 |
| 重复代码 | 阈值 ≤ 100 | `dupl` |
| 单行长度 | 无硬性限制（gofmt 决定） | — |

---

## 五、Go 特有检查规则

### 5.1 错误处理检查

| 规则 | 说明 | linter | 级别 |
|------|------|--------|------|
| 未检查的 error | 所有 error 返回值必须检查 | `errcheck` | 错误 |
| 裸返回 | 中大型函数禁止裸返回 | `nakedret` | 警告 |
| 错误命名 | 哨兵错误用 `Err` 前缀 | `errname` | 警告 |
| nil error | 返回 nil 值作为 error | `nilerr` | 错误 |

### 5.2 并发安全检查

| 规则 | 说明 | 工具 | 级别 |
|------|------|------|------|
| 数据竞争 | 并发读写共享变量 | `go test -race` | 错误 |
| sync 原语拷贝 | Mutex/WaitGroup 拷贝 | `go vet` / `copylocks` | 错误 |
| context 传递 | HTTP 请求不带 context | `noctx` | 警告 |

### 5.3 安全检查

| 规则 | 说明 | linter | 级别 |
|------|------|--------|------|
| SQL 注入 | 字符串拼接 SQL | `gosec` (G201-G203) | 错误 |
| 硬编码密码 | 密码/Token 硬编码 | `gosec` (G101) | 错误 |
| 弱加密 | 使用 MD5/SHA1 | `gosec` (G401-G407) | 错误 |
| 不安全随机 | math/rand 用于安全场景 | `gosec` (G404) | 警告 |
| 文件路径注入 | 用户输入拼文件路径 | `gosec` (G301-G306) | 警告 |

### 5.4 代码规范检查

| 规则 | 说明 | linter |
|------|------|--------|
| 导出符号无注释 | 所有导出类型/函数必须有注释 | `revive` (exported) |
| 错误信息格式 | 小写开头，无标点结尾 | `revive` (error-strings) |
| import 分组 | 标准库/第三方/项目内 | `goimports` |
| 命名规范 | camelCase/PascalCase | `revive` (var-naming) |
| context 参数位置 | context 作为第一个参数 | `revive` (context-as-argument) |

---

## 六、质量门禁阈值

| 指标 | 阻塞 | 告警 |
|------|------|------|
| go vet 错误 | 0 | 0 |
| golangci-lint 错误 | 0 | 0 |
| 数据竞争 | 0 | 0 |
| 安全漏洞 | 0 | 0 |
| 行覆盖率 | ≥ 80% | < 70% |
| 重复代码率 | ≤ 3% | > 5% |
| 圈复杂度（函数） | ≤ 10 | > 7 |
| 技术债务比率 | ≤ 5% | > 10% |

---

## 七、CI 集成模板

```yaml
# GitHub Actions 示例
name: Go CI
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - name: golangci-lint
        uses: golangci/golangci-lint-action@v6
        with:
          version: latest

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - name: Run tests with race detector
        run: go test -race -coverprofile=coverage.out ./...
      - name: Check coverage
        run: |
          go tool cover -func=coverage.out
          # 可选：上传到 Codecov
```

```makefile
# Makefile 集成
.PHONY: lint test vet fmt check

fmt:
	goimports -w .

vet:
	go vet ./...

lint:
	golangci-lint run ./...

test:
	go test -race -coverprofile=coverage.out ./...
	go tool cover -func=coverage.out

check: fmt vet lint test
	@echo "All checks passed!"
```

> 核心参考来源：
> - [golangci-lint 官方文档](https://golangci-lint.run/) (A — 官方)
> - [Go Linters: Essential Tools for Code Quality](https://www.glukhov.org/post/2025/11/linters-for-go/) (B)
> - [Mastering Code Quality in Go with golangci-lint](https://medium.com/@caring_smitten_gerbil_914/mastering-code-quality-in-go-with-golangci-lint-the-swiss-army-knife-for-static-analysis-a3c0eabbd78c) (B)
> - [golangci-lint 配置最佳实践](https://github.com/maratori/golangci-lint-config) (B)
