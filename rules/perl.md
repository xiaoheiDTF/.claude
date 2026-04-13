---
paths:
  - "**/*.pl"
  - "**/*.pm"
  - "**/*.t"
---

# Perl 编码规范

> 综合 Perl Best Practices (Damian Conway) / Perl Style Guide / Perl::Critic

## 命名规范

- 变量：snake_case（`$user_name`, `@item_list`, `%user_hash`）
- 函数/子程序：snake_case（`sub get_user_info`）
- 包/模块：PascalCase（`UserService`）或混合（`Net::HTTP`）
- 常量：UPPER_SNAKE_CASE（`use constant MAX_RETRY => 3;`）
- 私有子程序以 `_` 前缀（`sub _internal_helper`）
- 文件名：模块用 PascalCase（`UserService.pm`），脚本用 snake_case（`process_data.pl`）

## 代码格式

- 缩进：4 空格（不使用 Tab）
- 行宽：78 或 80 字符
- 使用 `Perl::Tidy` 自动格式化
- 使用 `Perl::Critic` 静态分析
- 左花括号不换行
- 始终使用 `use strict;` 和 `use warnings;`

## 核心规范

- 始终 `use strict;` 和 `use warnings;`
- 使用 `my` 声明词法变量（避免全局变量）
- 使用三参数 `open`（`open my $fh, '<', $filename`）
- 使用 ` lexical filehandles`（`my $fh` 而非 `FH`）
- 使用 `//`（defined-or）代替 `||` 处理可能为 0 或 '' 的值
- 使用 `q{}` / `qq{}` 代替引号（避免转义混乱）
- 使用 `foreach`（`for`）循环，避免 C 风格 for 循环
- 使用 `say` 代替 `print` + `\n`（`use feature 'say'`）

## 错误处理

- 使用 `eval { ... }` + `$@` 或 `Try::Tiny`
- 使用 `croak` / `confess`（Carp）代替 `die`（提供调用者上下文）
- 使用 `carp` / `cluck` 代替 `warn`
- 检查 `open` / `close` 返回值

## 测试

- 框架：Test::More / Test2
- 测试文件：`<name>.t`
- 使用 `prove` 运行测试
- 覆盖率：Devel::Cover
