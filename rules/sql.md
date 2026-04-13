---
paths:
  - "**/*.sql"
---

# SQL 编码规范

> 综合 SQL Style Guide (Simon Holywell) / Google SQL Style Guide / PostgreSQL Conventions / MySQL Best Practices

## 命名规范

- 表名：snake_case，复数（`users`, `order_items`）或单数（项目统一）
- 列名：snake_case（`user_name`, `created_at`）
- 主键：`id` 或 `<table>_id`（`user_id`）
- 外键列：`<referenced_table>_id`（`user_id` 引用 `users.id`）
- 索引：`idx_<table>_<columns>`（`idx_users_email`）
- 唯一约束：`uk_<table>_<columns>`（`uk_users_email`）
- 检查约束：`ck_<table>_<condition>`（`ck_orders_quantity_positive`）
- 外键约束：`fk_<table>_<referenced>`（`fk_orders_users`）
- 视图：`v_<description>`（`v_active_users`）
- 存储过程/函数：`sp_<action>` / `fn_<action>`（`sp_calculate_order_total`）
- 触发器：`trg_<table>_<event>`（`trg_users_before_insert`）
- 布尔列以 `is_`/`has_`/`can_` 开头（`is_active`, `has_permission`）
- 时间戳列：`created_at`, `updated_at`, `deleted_at`
- 避免使用 SQL 保留字作为列名（`order`, `group`, `select`）

## 格式规范

- 关键字大写（`SELECT`, `FROM`, `WHERE`, `JOIN`）
- 表名和列名小写
- 缩进：子句换行并缩进（2 或 4 空格）
- 逗号放在行首（前端逗号风格）或行尾（保持一致）
- 长查询每列一行
- 使用 `/* comment */` 添加复杂查询的注释
- 使用 CTE（`WITH` 子句）简化复杂查询

```sql
SELECT
    u.id
    , u.name
    , u.email
    , COUNT(o.id) AS order_count
FROM users AS u
LEFT JOIN orders AS o ON o.user_id = u.id
WHERE u.is_active = TRUE
    AND u.created_at >= '2024-01-01'
GROUP BY
    u.id
    , u.name
    , u.email
HAVING COUNT(o.id) > 0
ORDER BY order_count DESC;
```

## 查询设计

- 始终使用参数化查询（Prepared Statements），禁止字符串拼接 SQL
- 避免 `SELECT *`，明确列出所需列
- 使用 `JOIN` 代替子查询（可读性和性能）
- 使用 `LEFT JOIN` 保留左侧所有记录，`INNER JOIN` 仅匹配
- 使用 `EXISTS` 代替 `IN`（大数据集场景）
- 使用 `LIMIT` / `FETCH FIRST` 分页
- 使用 `WITH` (CTE) 拆分复杂查询
- 使用窗口函数（`ROW_NUMBER`, `RANK`, `LAG`, `LEAD`）处理分析查询
- 避免 `OFFSET` 分页（大数据集性能差），使用 seek method

## 表设计

- 每张表必须有主键（推荐自增 ID 或 UUID）
- 标准审计字段：`id`, `created_at`, `updated_at`
- 使用适当的数据类型（`VARCHAR(n)`, `INTEGER`, `TIMESTAMP`, `BOOLEAN`）
- 不使用 `TEXT` 类型存储有限长度字符串
- 使用 `DECIMAL` 存储金额，不使用 `FLOAT`/`DOUBLE`
- 外键约束确保引用完整性
- 适当添加索引（主键自动索引，外键手动加索引）
- 使用 `NOT NULL` + 默认值代替可空列
- 大表使用分区（Partitioning）
- 软删除（`deleted_at`）vs 硬删除（按业务需求）

## 索引优化

- 为 WHERE、JOIN、ORDER BY、GROUP BY 列添加索引
- 复合索引遵循最左前缀原则（选择性高的列放前面）
- 避免过度索引（写性能下降）
- 使用 `EXPLAIN` / `EXPLAIN ANALYZE` 分析查询计划
- 覆盖索引避免回表
- 部分索引（Partial Index）减少索引大小

## 安全规范

- 参数化查询，禁止拼接用户输入
- 最小权限原则：应用账户仅授予必要权限
- 禁止存储明文密码（使用 BCrypt / Argon2）
- 敏感数据加密存储（AES-256）
- 审计日志记录关键操作
- 定期备份和恢复演练
- 使用 `GRANT` 精细控制权限
