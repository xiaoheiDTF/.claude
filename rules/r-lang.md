---
paths:
  - "**/*.r"
  - "**/*.R"
  - "**/*.Rmd"
---

# R 编码规范

> 综合 Google R Style Guide / Tidyverse Style Guide / R Coding Standards (Bioconductor)

## 命名规范

- 变量和函数：snake_case（`get_user_info`, `item_count`）
- 函数名动词开头（`calculate_mean`, `filter_data`）
- 常量：UPPER_SNAKE_CASE（`MAX_ITERATIONS`）
- 类/对象：PascalCase（`DataProcessor`, `LinearModel`）
- 文件名：kebab-case 或 snake_case（`data-processor.R`, `data_processor.R`）
- 私有函数以 `.` 前缀（`.internal_helper`）
- 布尔变量以 `is_`/`has_`/`can_` 开头（`is_valid`, `has_missing`）

## 代码格式

- 缩进：2 空格（不使用 Tab）
- 行宽：80 字符
- 使用 `styler` / `formatR` 自动格式化
- 使用 `lintr` 静态分析
- 赋值使用 `<-`（不使用 `=`）
- 左括号前不空格（`mean(x)` 而非 `mean (x)`）
- 逗号后空格（`c(1, 2, 3)` 而非 `c(1,2,3)`）

## 核心规范

- 使用 `library()` 加载包（不使用 `require()`）
- 使用管道 `%>%`（magrittr）或 `|>`（R 4.1+）链式操作
- 向量化操作优先于循环（`apply` 家族）
- 使用 `data.table` 或 `dplyr` 处理数据
- 使用 `ggplot2` 可视化
- 避免使用 `attach()` / `detach()`
- 使用 `::` 显式指定包函数（`dplyr::filter()`）
- 使用 `here::here()` 管理项目路径

## 错误处理

- 使用 `stop()` 抛出错误
- 使用 `warning()` 发出警告
- 使用 `message()` 输出信息
- 使用 `tryCatch()` 捕获错误
- 使用 `purrr::safely()` / `purrr::possibly()` 安全执行

## 测试

- 框架：testthat
- 测试文件：`test-<name>.R`（`test-data-processor.R`）
- 使用 `test_that("description", { ... })`
- 覆盖率：covr
