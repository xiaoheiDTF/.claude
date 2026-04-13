# Rust 代码检查规则（Clippy + rustfmt + 质量门禁）

> 适用于所有架构模式
> 最后更新：2026-04-11

---

## 一、工具矩阵

| 工具 | 检查层面 | 核心能力 |
|------|---------|---------|
| **rustfmt** | 代码格式 | 缩进、行宽、空格、import 排序 |
| **clippy** | 代码质量 | 惯用写法、性能、正确性、风格 |
| **cargo test** | 测试 | 单元测试、集成测试 |
| **cargo audit** | 安全审计 | 已知漏洞检查 |
| **cargo outdated** | 依赖检查 | 过期依赖 |
| **cargo nextest** | 增强测试 | 并行测试、更好输出 |
| **Miri** | 未定义行为 | 检测 unsafe 中的 UB |

---

## 二、rustfmt 配置

```toml
# rustfmt.toml
max_width = 100
hard_tabs = false
tab_spaces = 4
newline_style = "Unix"
use_small_heuristics = "Default"
reorder_imports = true
reorder_modules = true
group_imports = "StdExternalCrate"
imports_granularity = "Crate"
```

---

## 三、Clippy 配置

```toml
# .clippy.toml
cognitive-complexity-threshold = 25
type-complexity-threshold = 250
single-char-binding-names-threshold = 4
```

```toml
# Cargo.toml 中配置 lint 级别
[lints.clippy]
# 禁止项
unwrap_used = "warn"
expect_used = "warn"
panic = "warn"
todo = "warn"

# 推荐项
must_use_candidate = "warn"
module_name_repetitions = "allow"
```

### 推荐启用的 Clippy lint

```rust
// lib.rs 顶部
#![warn(clippy::all)]
#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]
#![allow(clippy::module_name_repetitions)]
#![allow(clippy::too_many_arguments)]

// 项目级配置
#![warn(clippy::unwrap_used)]
#![warn(clippy::expect_used)]
#![warn(clippy::panic)]
#![warn(clippy::todo)]
#![warn(clippy::indexing_slicing)]
```

---

## 四、质量门禁阈值

| 指标 | 阻塞 | 告警 |
|------|------|------|
| clippy 错误 | 0 | 0 |
| clippy 警告 | 0 | > 10 |
| 编译警告 | 0 | > 0 |
| unsafe 使用 | 需审查 | 无 SAFETY 注释 |
| cargo audit 漏洞 | 0 Critical/High | > 0 Medium |
| 测试覆盖率 | ≥ 80% | < 70% |

---

## 五、CI 集成模板

```yaml
# GitHub Actions
name: Rust CI
on: [push, pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with:
          components: rustfmt, clippy
      - name: Check formatting
        run: cargo fmt --all -- --check
      - name: Clippy
        run: cargo clippy --all-targets --all-features -- -D warnings
      - name: Build
        run: cargo build --release
      - name: Test
        run: cargo test --all-features
      - name: Audit
        run: cargo install cargo-audit && cargo audit
```

```makefile
# Makefile
.PHONY: fmt clippy test check

fmt:
	cargo fmt --all -- --check

clippy:
	cargo clippy --all-targets --all-features -- -D warnings

test:
	cargo test --all-features

audit:
	cargo audit

check: fmt clippy test
	@echo "All checks passed!"
```

---

## 六、Cargo.toml 模板

```toml
[package]
name = "my-project"
version = "0.1.0"
edition = "2021"
rust-version = "1.75"

[dependencies]
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
anyhow = "1"
tracing = "0.1"
tracing-subscriber = "0.3"

[dev-dependencies]
tokio-test = "0.4"

[profile.release]
lto = true
strip = true
opt-level = 3
```

> 来源：[Clippy Documentation](https://doc.rust-lang.org/clippy/) (A), [Rust Style Guide](https://doc.rust-lang.org/style-guide/) (A)
