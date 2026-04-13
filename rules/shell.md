---
paths:
  - "**/*.sh"
  - "**/*.bash"
---

# Shell/Bash 编码规范

> 综合 Google Shell Style Guide / Bash Best Practices / ShellCheck Rules / IEEE POSIX

## 命名规范

- 变量：UPPER_SNAKE_CASE（环境/全局变量）或 lower_snake_case（局部变量）
- 函数：lower_snake_case（`get_user_info`, `calculate_total`）
- 常量：UPPER_SNAKE_CASE + `readonly`（`readonly MAX_RETRY=3`）
- 文件名：kebab-case（`deploy-app.sh`）或 snake_case
- 布尔变量用 `enable_`/`disable_` 前缀或 `is_`/`has_` 前缀
- 命名表达意图（`input_file` 而非 `f`，`retry_count` 而非 `n`）

## 代码格式

- 缩进：2 空格（Google 推荐）或 4 空格，不使用 Tab
- 行宽：80 字符（终端友好）
- 使用 `shellcheck` 静态分析
- 使用 `shfmt` 自动格式化
- 函数定义后空行

## 基本规范

- 脚本开头：`#!/usr/bin/env bash`
- 使用 `set -euo pipefail`（严格模式）
  - `set -e`：命令失败时退出
  - `set -u`：引用未定义变量时报错
  - `set -o pipefail`：管道中任一命令失败则整体失败
- 使用 `[[ ]]` 代替 `[ ]`（Bash 增强版，更安全）
- 使用 `$(command)` 代替反引号 `` `command` ``
- 变量引用始终加双引号（`"$var"` 而非 `$var`）
- 使用 `$((expression))` 进行算术运算，不使用 `expr` 或 `let`

## 函数设计

- 函数名 snake_case
- 函数必须有 `local` 变量（避免污染全局命名空间）
- 函数返回状态码（0=成功，非0=失败）
- 数据返回用 `echo`，调用方用 `$(function)` 捕获
- 函数体控制在 50 行以内
- 使用 `return` 退出函数，`exit` 退出脚本

## 变量与引用

- 引用变量始终加双引号（`"$var"`, `"${array[@]}"`）
- 命令替换使用 `$()` 而非反引号
- 使用 `${var:-default}` 提供默认值
- 使用 `${var:?error message}` 检查必要变量
- 使用 `readonly` / `declare -r` 定义常量
- 使用 `local` 声明函数内变量

## 错误处理

- 始终检查命令退出状态（`set -e` 或手动 `if ! command; then`）
- 使用 `trap` 清理资源（`trap 'rm -f "$tmpfile"' EXIT`）
- 有意义的错误信息输出到 stderr（`echo "Error: ..." >&2`）
- 返回有意义的退出码（0=成功，1=一般错误，2=误用）
- 使用 `set -e` 但对允许失败的命令使用 `|| true`

## 安全规范

- 变量引用始终加双引号（防止 word splitting 和 globbing）
- 避免使用 `eval`（安全风险）
- 使用 `mktemp` 创建临时文件（`tmpfile=$(mktemp)`）
- 路径操作使用 `realpath` / `dirname` / `basename`
- 避免使用 `source` / `.` 加载不可信脚本
- 文件权限：敏感脚本 `chmod 700`
- 使用 `read -rs` 安全读取密码（不回显）

## 可移植性

- 使用 `#!/usr/bin/env bash` 查找 bash
- 避免 Bashism 如果需要 POSIX 兼容
- 使用 `command -v` 代替 `which`
- 使用 `printf` 代替 `echo`（可移植、行为一致）

## 测试

- 框架：bats-core（Bash Automated Testing System）
- 测试文件：`<name>.bats`
- 使用 `@test "description" { ... }`
- 断言使用 `[ condition ]`
- ShellCheck 作为静态分析
