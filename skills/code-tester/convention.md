# 统一测试规范（Universal Testing Convention）

> 综合 Google、Microsoft、Airbnb、Stripe 等大厂实践，形成跨语言统一的测试标准。
> 既是 AI 写测试的依据，也是人工自测的规范，同时是扫描工具判断"哪些文件需要测试"的规则。

---

## 一、核心原则

| # | 原则 | 说明 | 来源 |
|---|------|------|------|
| 1 | **AAA 结构** | 每个测试用例分 Arrange（准备）/ Act（执行）/ Assert（断言）三段 | Microsoft |
| 2 | **单一行为** | 每个测试只验证一个行为，不合并多个场景 | Google |
| 3 | **测试独立** | 任何测试的执行不依赖其他测试的执行顺序 | Google |
| 4 | **测试幂等** | 同一测试运行 N 次结果一致，不受时间/随机数/网络影响 | Google |
| 5 | **命名可读** | 测试名描述行为，让人不看代码就知道测的是什么 | Microsoft |
| 6 | **镜像结构** | 测试文件与源文件的目录结构保持镜像关系 | Google |
| 7 | **公开接口优先** | 只测导出的函数/方法/类，私有方法通过公开接口间接测试 | 通用 |
| 8 | **Mock 外部依赖** | 网络、文件系统、数据库、时间等外部依赖全部 mock | Stripe |

---

## 二、覆盖率维度（每个函数至少覆盖）

```
所有可测函数必须覆盖以下 4 个维度：

┌─────────────────────────────────────────────────────┐
│  正常路径   正确输入 → 正确输出                       │
│  边界情况   空值、零值、极值、默认参数                 │
│  异常情况   非法输入 → 预期错误/异常                   │
│  参数变体   可选参数有/无、不同类型组合                 │
└─────────────────────────────────────────────────────┘
```

Google 的测试金字塔建议：70% 单元测试 / 20% 集成测试 / 10% 端到端测试。
本规范聚焦单元测试层。

---

## 三、文件映射规则（源文件 → 测试文件）

### 3.1 通用规则

```
源文件路径:
  <subproject>/src/a/b/c/module.ext

测试文件路径（按框架优先级选择）:
  优先1: <subproject>/src/a/b/c/__tests__/module.test.ext    （同目录 __tests__/）
  优先2: <subproject>/src/a/b/c/module.test.ext              （同目录平铺）
  优先3: <subproject>/test/a/b/c/module.test.ext             （顶层 test/ 镜像）
```

**选择策略**：
1. 如果该子项目已有测试文件 → 参考已有测试的放置方式
2. 框架有明确约定 → 遵循框架约定（见 3.2）
3. 都没有 → 使用优先1（同目录 `__tests__/`）

### 3.2 框架专属映射

以下框架有强约定，**优先使用框架约定**而非通用规则：

| 语言 | 框架 | 源文件模式 | 测试文件模式 | 测试目录 | 特殊规范 |
|------|------|-----------|------------|---------|---------|
| Java | Spring Boot Test | `src/main/java/**/*Service.java` | `src/test/java/**/*ServiceTest.java` | `src/test/java/` 镜像 | `@SpringBootTest`、`@WebMvcTest`、`@MockBean` |
| Java | JUnit 5 | `src/main/java/**/*.java` | `src/test/java/**/*Test.java` | `src/test/java/` 镜像 | `@Nested` 分组、`@ParameterizedTest` |
| Java | TestNG | `src/main/java/**/*.java` | `src/test/java/**/*Test.java` | `src/test/java/` 镜像 | `@DataProvider` 参数化 |
| Python | pytest | `**/*.py` | `**/test_*.py` | 同目录 | `conftest.py` fixture、`@pytest.mark.parametrize` |
| Python | unittest | `**/*.py` | `**/test_*.py` | 同目录 | `class Test*(TestCase)` |
| Python | Django Test | `**/views.py` | `**/tests.py` 或 `**/test_*.py` | 同目录 | `TestCase`、`Client`、`factory_boy` |
| Go | testing | `**/*.go` | `**/*_test.go` | 同目录 | 同包测试（白盒）+ `_test` 包（黑盒） |
| Go | testify | `**/*.go` | `**/*_test.go` | 同目录 | `suite.TestSuite` |
| Rust | cargo test | `src/**/*.rs` | 内联 `#[test]` 或 `tests/*.rs` | `tests/` | `#[cfg(test)]` 模块 |
| C# | xUnit | `**/*.cs` | `**/*Tests.cs` | 同目录或 `Tests/` | `[Fact]`、`[Theory]`、`[InlineData]` |
| C# | NUnit | `**/*.cs` | `**/*Tests.cs` | 同目录或 `Tests/` | `[Test]`、`[TestCase]` |
| Ruby | RSpec | `lib/**/*.rb` | `spec/**/*_spec.rb` | `spec/` 镜像 | `describe/context/it` 嵌套 |
| PHP | PHPUnit | `src/**/*.php` | `tests/**/*Test.php` | `tests/` | `extends TestCase` |
| JS/TS | Vitest | `src/**/*.ts` | `src/**/*.test.ts` 或 `src/**/__tests__/*.test.ts` | 同目录 | `describe/it/expect` |
| JS/TS | Jest | 同上 | 同上 | 同上 | 全局 API |
| JS/TS | Mocha | 同上 | 同上 | `test/` | `describe/it` + chai/assert |

### 3.3 跳过规则（以下文件不需要测试）

```
不需要写测试的文件：
├── index.ts / index.js        — 纯导出聚合文件（只做 re-export）
├── *.d.ts                     — 类型声明文件
├── *.config.*                 — 配置文件（vite.config、tsconfig 等）
├── types.ts / types.py        — 纯类型/接口定义文件（无逻辑）
├── constants.ts               — 纯常量文件（无逻辑）
├── __tests__/                 — 已有的测试目录
├── **/test_*.py               — 已有的测试文件
├── **/*.test.*                — 已有的测试文件
├── **/*.spec.*                — 已有的测试文件
├── **/*_test.go               — 已有的测试文件
└── **/*Test.java              — 已有的测试文件
```

---

## 四、测试用例命名规范

### 4.1 统一格式

```
测试名 = 「函数名」+「场景描述」

示例：
  ✓ navigate 正常URL跳转
  ✓ navigate 空字符串应抛错
  ✓ parse 超长字符串截断处理
  ✓ login 密码错误返回401
```

### 4.2 各语言实现

| 语言 | 格式 | 示例 |
|------|------|------|
| JS/TS (Vitest/Jest) | `it('函数名 场景描述', () => { ... })` | `it('navigate 正常URL跳转', () => { ... })` |
| Python (pytest) | `def test_函数名_场景描述():` | `def test_navigate_empty_url_raises():` |
| Java (JUnit) | `@Test void 函数名_场景描述()` | `@Test void navigate_emptyUrl_throws()` |
| Go | `func Test函数名_场景描述(t *testing.T)` | `func TestNavigate_EmptyURL(t *testing.T)` |
| Rust | `#[test] fn 函数名_场景描述()` | `#[test] fn navigate_empty_url_panics()` |
| C# | `[Fact] public void 函数名_场景描述()` | `[Fact] public void Navigate_EmptyUrl_Throws()` |

---

## 五、测试文件模板

### 5.1 通用结构

```
测试文件结构：
  ┌─ 导入（被测模块 + 测试框架 + mock 工具）
  ├─ describe / class / module（对应被测模块名）
  │   ├─ beforeEach / setup（公共 Arrange）
  │   ├─ it / test case 1：正常路径
  │   │   └─ 打印：预期 xxx, 实际 xxx
  │   ├─ it / test case 2：边界情况
  │   ├─ it / test case 3：异常情况
  │   └─ it / test case 4：参数变体
  └─ afterEach / teardown（清理）
```

**每个测试用例必须打印预期值和实际值**，方便人工复核：

```
[测试] navigate 正常URL
  预期: Command { type: 'navigate', url: 'https://baidu.com' }
  实际: Command { type: 'navigate', url: 'https://baidu.com' }
  结果: ✓ 通过
```

### 5.2 JS/TS (Vitest) 模板

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { 函数名 } from '../module';

describe('模块名', () => {
  beforeEach(() => { /* Arrange（公共准备） */ });

  it('函数名 正常路径', () => {
    // Arrange
    const input = ...;
    const expected = ...;
    // Act
    const result = 函数名(input);
    // Print
    console.log(`[测试] 函数名 正常路径`);
    console.log(`  预期: ${JSON.stringify(expected)}`);
    console.log(`  实际: ${JSON.stringify(result)}`);
    // Assert
    expect(result).toEqual(expected);
  });

  it('函数名 异常情况', () => {
    const badInput = ...;
    console.log(`[测试] 函数名 异常情况`);
    console.log(`  预期: 抛出 Error`);
    console.log(`  输入: ${JSON.stringify(badInput)}`);
    expect(() => 函数名(badInput)).toThrow();
  });
});
```

### 5.3 Python (pytest) 模板

```python
import pytest
from module import 函数名

class Test模块名:
    """模块名测试"""

    def test_函数名_正常路径(self):
        # Arrange
        input_data = ...
        expected = ...
        # Act
        result = 函数名(input_data)
        # Print
        print(f"\n[测试] 函数名 正常路径")
        print(f"  预期: {expected}")
        print(f"  实际: {result}")
        # Assert
        assert result == expected, f"预期 {expected}, 实际 {result}"

    def test_函数名_异常情况(self):
        bad_input = ...
        print(f"\n[测试] 函数名 异常情况")
        print(f"  预期: 抛出 ValueError")
        print(f"  输入: {bad_input}")
        with pytest.raises(ValueError):
            函数名(bad_input)
```

### 5.4 Java (JUnit 5) 模板

```java
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

class ModuleTest {
    @Test
    void 函数名_正常路径() {
        // Arrange
        var input = ...;
        var expected = ...;
        // Act
        var result = module.函数名(input);
        // Print
        System.out.println("[测试] 函数名 正常路径");
        System.out.println("  预期: " + expected);
        System.out.println("  实际: " + result);
        // Assert
        assertEquals(expected, result);
    }

    @Test
    void 函数名_异常情况() {
        var badInput = ...;
        System.out.println("[测试] 函数名 异常情况");
        System.out.println("  预期: 抛出 IllegalArgumentException");
        System.out.println("  输入: " + badInput);
        assertThrows(IllegalArgumentException.class, () -> module.函数名(badInput));
    }
}
```

### 5.5 Spring Boot Test 专属模板

```java
@WebMvcTest(Controller.class)
class ControllerTest {
    @Autowired MockMvc mockMvc;
    @MockBean ServiceClass service;

    @Test
    void endpoint_正常请求_返回200() throws Exception {
        given(service.method(any())).willReturn(result);
        System.out.println("[测试] GET /api/path 正常请求");
        System.out.println("  预期: 200, field=" + expected);
        mockMvc.perform(get("/api/path"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.field").value(expected))
            .andDo(result -> System.out.println("  实际: " + result.getResponse().getContentAsString()));
    }
}
```

### 5.6 Go testing 模板

```go
func Test函数名_正常路径(t *testing.T) {
    // Arrange
    input := ...
    expected := ...
    // Act
    result := 函数名(input)
    // Print
    t.Logf("[测试] 函数名 正常路径")
    t.Logf("  预期: %v", expected)
    t.Logf("  实际: %v", result)
    // Assert
    if result != expected {
        t.Errorf("预期 %v, 实际 %v", expected, result)
    }
}
```

---

## 七、测试包生成物

每次为某个目录生成测试时，在该目录的测试文件夹下必须生成以下文件：

```
<目标目录>/__tests__/
├── module1.test.ts      ← 测试文件（含预期/实际打印）
├── module2.test.ts
├── run-tests.sh         ← 一键运行脚本（Unix / Git Bash）
├── run-tests.ps1        ← 一键运行脚本（Windows PowerShell）
├── BUG-DEFECTS.md       ← 缺陷清单（必须生成，无缺陷也要写“未发现”）
├── SECURITY-FINDINGS.md ← 漏洞清单（必须生成，无漏洞也要写“未发现”）
├── test-logs/           ← 测试日志目录（运行后自动创建）
│   └── *.log            ← 带时间戳的日志文件
└── README.md            ← 测试说明文档
```

### 7.1 一键测试脚本

生成两个脚本，分别支持 Unix/Git Bash 和 Windows PowerShell。

**核心要求**：
- 实时显示控制台输出（包括 console.log/print 的预期/实际打印）
- 所有输出同时写入日志文件（`test-logs/YYYYMMDD-HHmmss.log`）
- 日志文件保存在测试目录下的 `test-logs/` 子目录
- 显示测试开始/结束时间、耗时、退出码
- **脚本必须 ASCII-only** — run-tests.sh 和 run-tests.ps1 中禁止使用 Unicode box-drawing 字符（`━`、`─`、`═`）或任何非 ASCII 符号。分隔线用 `========================================`（40 个 `=`），注释分隔用 `--`。标签必须用英文（`Test:`、`Start:`、`End:`、`Exit:`、`Log:`），禁止中文，避免在不同终端/编码下乱码
- **强制 UTF-8 编码** — 防止日志文件乱码（Windows 下 GBK/GB2312 与 UTF-8 不匹配是主要原因）

---

#### 7.1.1 run-tests.sh (Unix / Git Bash)

**IMPORTANT**: Script content MUST use **ASCII-only** characters. Do NOT use Unicode box-drawing characters (e.g. `━`, `─`, `═`) or non-ASCII symbols. All labels in echo/printf MUST be English to avoid encoding issues across terminals.

**JS/TS (Vitest)**:
```bash
#!/bin/bash
# run-tests.sh - <module-path>
# Usage: bash run-tests.sh [--verbose] [--coverage]

set -euo pipefail

# -- Encoding: force UTF-8 output --
export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}
export PYTHONIOENCODING=utf-8

# -- Path --
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/test-logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$LOG_DIR/${TIMESTAMP}.log"

# -- Subproject root (relative from script location, e.g. ../../..) --
# IMPORTANT: For Vitest, this MUST point to Vitest's actual root, NOT package.json dir.
# If no vitest.config.*, check tsconfig.json rootDir (e.g. "src" -> use frontend/src/ not frontend/)
SUBPROJECT_ROOT="$(cd "$SCRIPT_DIR/<relative-path-to-subproject-root>" && pwd)"

# -- Header --
echo "========================================"
echo " Test:   <module-path>"
echo " Start:  $(date '+%Y-%m-%d %H:%M:%S')"
echo " Log:    $LOG_FILE"
echo "========================================"
{ echo "========================================"; \
  echo " Test:   <module-path>"; \
  echo " Start:  $(date '+%Y-%m-%d %H:%M:%S')"; \
  echo "========================================"; } >> "$LOG_FILE"

# -- Run tests --
cd "$SUBPROJECT_ROOT"

if [ "${1:-}" = "--coverage" ]; then
  npx vitest run <test-dir> --coverage 2>&1 | tee -a "$LOG_FILE"
elif [ "${1:-}" = "--verbose" ]; then
  npx vitest run <test-dir> --reporter=verbose 2>&1 | tee -a "$LOG_FILE"
else
  npx vitest run <test-dir> 2>&1 | tee -a "$LOG_FILE"
fi

EXIT_CODE=${PIPESTATUS[0]}

# -- Footer --
echo ""
echo "========================================"
echo " End:    $(date '+%Y-%m-%d %H:%M:%S')"
echo " Exit:   $EXIT_CODE"
echo " Log:    $LOG_FILE"
echo "========================================"
{ echo ""; \
  echo "========================================"; \
  echo " End:    $(date '+%Y-%m-%d %H:%M:%S')"; \
  echo " Exit:   $EXIT_CODE"; \
  echo "========================================"; } >> "$LOG_FILE"

exit $EXIT_CODE
```

**Python (pytest)**:
```bash
#!/bin/bash
# run-tests.sh - <module-path>
# Usage: bash run-tests.sh [--verbose] [--coverage]

set -euo pipefail

# -- Encoding: force UTF-8 output --
export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}
export PYTHONIOENCODING=utf-8

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/test-logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$LOG_DIR/${TIMESTAMP}.log"
SUBPROJECT_ROOT="$(cd "$SCRIPT_DIR/<relative-path>" && pwd)"

echo "========================================"
echo " Test:   <module-path>"
echo " Start:  $(date '+%Y-%m-%d %H:%M:%S')"
echo " Log:    $LOG_FILE"
echo "========================================"

cd "$SUBPROJECT_ROOT"

if [ "${1:-}" = "--coverage" ]; then
  pytest <test-dir> -v -s --cov=<src-dir> 2>&1 | tee "$LOG_FILE"
elif [ "${1:-}" = "--verbose" ]; then
  pytest <test-dir> -v -s 2>&1 | tee "$LOG_FILE"
else
  pytest <test-dir> -s 2>&1 | tee "$LOG_FILE"
fi

EXIT_CODE=${PIPESTATUS[0]}
echo ""
echo " Exit: $EXIT_CODE | Log: $LOG_FILE"
exit $EXIT_CODE
```

**Java (JUnit/Maven)**:
```bash
#!/bin/bash
# run-tests.sh - <module-path>
set -euo pipefail

# -- Encoding: force UTF-8 output --
export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}
export PYTHONIOENCODING=utf-8

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/test-logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date +%Y%m%d-%H%M%S).log"
SUBPROJECT_ROOT="$(cd "$SCRIPT_DIR/<relative-path>" && pwd)"

cd "$SUBPROJECT_ROOT"

VERBOSE_FLAG=""
[ "${1:-}" = "--verbose" ] && VERBOSE_FLAG="-X"

mvn test -Dtest=<test-class> $VERBOSE_FLAG 2>&1 | tee "$LOG_FILE"
exit ${PIPESTATUS[0]}
```

**Go**:
```bash
#!/bin/bash
# run-tests.sh - <module-path>
set -euo pipefail

# -- Encoding: force UTF-8 output --
export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}
export PYTHONIOENCODING=utf-8

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/test-logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date +%Y%m%d-%H%M%S).log"

cd "$SCRIPT_DIR/<target-dir>"

if [ "${1:-}" = "--verbose" ]; then
  go test -v ./... 2>&1 | tee "$LOG_FILE"
else
  go test ./... 2>&1 | tee "$LOG_FILE"
fi
exit ${PIPESTATUS[0]}
```

---

#### 7.1.2 run-tests.ps1 (Windows PowerShell)

**IMPORTANT**: Script content MUST use **ASCII-only** characters. Do NOT use Unicode box-drawing characters or non-ASCII symbols. All labels MUST be English.

> **⚠️ Windows PowerShell 5.1 Compatibility Note**: The default Windows PowerShell (v5.1) `Join-Path` cmdlet only accepts **2 arguments**. If you need to combine 3+ path segments, use `[System.IO.Path]::Combine($a, $b, $c)` or string concatenation instead of `Join-Path $a $b $c`.

**JS/TS (Vitest)**:
```powershell
# run-tests.ps1 - <module-path>
# Usage: pwsh run-tests.ps1 [-Verbose] [-Coverage]

$ErrorActionPreference = "Stop"

# -- Encoding: force UTF-8 output --
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $ScriptDir "test-logs"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogFile = Join-Path $LogDir "$Timestamp.log"

# IMPORTANT: For Vitest, this MUST point to Vitest's actual root, NOT package.json dir.
# If no vitest.config.*, check tsconfig.json rootDir (e.g. "src" -> use frontend/src/ not frontend/)
$SubprojectRoot = Resolve-Path (Join-Path $ScriptDir "<relative-path-to-subproject-root>")

Write-Host "========================================"
Write-Host " Test:   <module-path>"
Write-Host " Start:  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host " Log:    $LogFile"
Write-Host "========================================"

Set-Location $SubprojectRoot

$TestDir = "<test-dir>"

if ($args -contains "--coverage") {
    npx vitest run $TestDir --coverage 2>&1 | Tee-Object -FilePath $LogFile
} elseif ($args -contains "--verbose") {
    npx vitest run $TestDir --reporter=verbose 2>&1 | Tee-Object -FilePath $LogFile
} else {
    npx vitest run $TestDir 2>&1 | Tee-Object -FilePath $LogFile
}

Write-Host ""
Write-Host "========================================"
Write-Host " End:    $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host " Log:    $LogFile"
Write-Host "========================================"
```

**Python (pytest)**:
```powershell
# run-tests.ps1 - <module-path>
$ErrorActionPreference = "Stop"

# -- Encoding: force UTF-8 output --
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $ScriptDir "test-logs"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogFile = Join-Path $LogDir "$Timestamp.log"
$SubprojectRoot = Resolve-Path (Join-Path $ScriptDir "<relative-path>")

Set-Location $SubprojectRoot

if ($args -contains "--coverage") {
    python -m pytest <test-dir> -v -s --cov=<src-dir> 2>&1 | Tee-Object $LogFile
} elseif ($args -contains "--verbose") {
    python -m pytest <test-dir> -v -s 2>&1 | Tee-Object $LogFile
} else {
    python -m pytest <test-dir> -s 2>&1 | Tee-Object $LogFile
}
```

**Go**:
```powershell
# run-tests.ps1 - <module-path>
$ErrorActionPreference = "Stop"

# -- Encoding: force UTF-8 output --
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $ScriptDir "test-logs"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogFile = Join-Path $LogDir "$Timestamp.log"

Set-Location (Join-Path $ScriptDir "<target-dir>")

if ($args -contains "--verbose") {
    go test -v ./... 2>&1 | Tee-Object $LogFile
} else {
    go test ./... 2>&1 | Tee-Object $LogFile
}
```

---

#### 7.1.3 日志文件格式

每次运行生成的日志文件包含完整的测试输出：

```
========================================
 Test:    cdp/command
 Start:   2026-04-08 15:30:00
========================================

 ✓ cdp/command > navigate > navigate 正常URL跳转 (5ms)
   [测试] navigate 正常URL
     预期: {"method":"Page.navigate","params":{"url":"https://baidu.com"}}
     实际: {"method":"Page.navigate","params":{"url":"https://baidu.com"}}

 ✓ cdp/command > navigate > navigate 空字符串应抛错 (2ms)
   [测试] navigate 空字符串
     预期: 抛出 Error
     输入: ""

 Test Files  2 passed (2)
      Tests  8 passed (8)
    Start at  15:30:01
    Duration  1.23s

========================================
 End:     2026-04-08 15:30:02
 Exit:    0
========================================
```

### 7.2 测试说明文档（README.md）

生成在测试目录下，说明这个测试包的用途：

```markdown
# <模块名> 测试

> 自动生成于: YYYY-MM-DD HH:mm
> 测试框架: <框架名>
> 关联源码: <源文件列表>

## 测试覆盖

| 源文件 | 测试文件 | 覆盖函数 | 用例数 |
|--------|---------|---------|-------|
| navigate.ts | navigate.test.ts | navigate, reload | 8 |
| click.ts | click.test.ts | click, doubleClick | 6 |

## 运行测试

**Unix / Git Bash**:
  bash __tests__/run-tests.sh              # 运行
  bash __tests__/run-tests.sh --verbose    # 详细输出
  bash __tests__/run-tests.sh --coverage   # 覆盖率

**Windows PowerShell**:
  pwsh __tests__/run-tests.ps1             # 运行
  pwsh __tests__/run-tests.ps1 -Verbose    # 详细输出
  pwsh __tests__/run-tests.ps1 -Coverage   # 覆盖率

## 日志文件

每次运行自动生成日志到 `__tests__/test-logs/` 目录，文件名格式 `YYYYMMDD-HHmmss.log`。
日志包含完整的控制台输出，包括每个用例的预期值和实际值。

## 测试维度说明

每个函数覆盖以下维度：
- **正常路径** — 正确输入的正确返回
- **边界情况** — 空值、零值、极值、默认参数
- **异常情况** — 非法输入的预期错误
- **参数变体** — 可选参数有/无的行为差异

## 输出格式

测试运行时每个用例会打印：
[测试] 函数名 场景描述
  预期: <期望值>
  实际: <实际值>
```

### 7.3 流水线文档产物（05-test）

除测试目录内的交付物外，还必须在 `/doc/ai-coding/<需求目录>/05-test/` 生成：

- `README.md`：测试执行详情与统计
- `SUMMARY.md`：面向决策者的摘要结论
- `BUG-DEFECTS.md`：缺陷汇总（可从测试目录同名文件同步）
- `SECURITY-FINDINGS.md`：漏洞汇总（可从测试目录同名文件同步）
- `manifest.json`：阶段契约文件（用于流水线校验）

若无法定位已有需求目录，需新建 `/doc/ai-coding/YYYYMMDD-HHmmss-<测试主题>/05-test/`。

## 六、参考来源

| 公司/组织 | 核心理念 | 参考 |
|----------|---------|------|
| **Google** | 测试金字塔 70/20/10、按 size/scope 分类、测试独立性 | [Google Testing Blog](https://testing.googleblog.com/) |
| **Microsoft** | AAA 模式、命名规范、一个测试一个断言 | [MS Learn - Unit Testing Best Practices](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices) |
| **Airbnb** | 每个合并分支必须通过测试、快速反馈周期 | [Testing at Airbnb](http://nerds.airbnb.com/testing-at-airbnb/) |
| **Stripe** | 严格测试/生产分离、沙盒环境、API Review 文化 | [Stripe Engineering Culture](https://newsletter.pragmaticengineer.com/p/stripe-part-2) |
| **Uber** | 按需临时测试环境（SLATE） | [Uber SLATE](https://www.uber.com/blog/simplifying-developer-testing-through-slate/) |

---

## 八、Vitest 根目录检测

### 问题背景

没有 `vitest.config.*` 文件时，Vitest 会自动检测根目录。它可能使用 `tsconfig.json` 的 `rootDir`（如 `"src"`）作为根目录，导致 Vitest 根不是 `package.json` 所在目录，而是其子目录（如 `frontend/src/` 而非 `frontend/`）。如果脚本 `cd` 到 `frontend/` 再用 `npx vitest run src/core/...`，实际路径变成 `frontend/src/src/core/...`，Vitest 报 `No test files found`。

### 检测算法

1. 在子项目根目录下查找 `vitest.config.*` 或 `vite.config.*`
2. 如果找到配置文件 → 读取其中 `test.root` 配置，以此为 Vitest 根
3. 如果没找到配置文件 → 读取 `tsconfig.json` 的 `rootDir`
   - `rootDir` 存在（如 `"src"`） → Vitest 根 = 子项目根 + `rootDir`（如 `frontend/src/`）
   - `rootDir` 不存在 → Vitest 根 = 子项目根（如 `frontend/`）
4. 用 `npx vitest run --root <推断路径> --help 2>&1` 快速验证，或直接运行一个测试确认

### 对脚本生成的影响

| 项目 | 旧逻辑（错误） | 新逻辑（正确） |
|------|---------------|---------------|
| `SUBPROJECT_ROOT` | 指向 `package.json` 所在目录 | 指向 Vitest 实际根目录 |
| 测试路径参数 | `src/core/browser/.../__tests__/` | `core/browser/.../__tests__/`（去掉 `src/` 前缀） |
| `__tests__` 到根的相对层级 | 按 `package.json` 目录计算 | 按 Vitest 根目录计算（少一层） |

### 示例

```
子项目根 (package.json): frontend/
tsconfig.json rootDir:   "src"
Vitest 实际根:           frontend/src/

测试目录: frontend/src/core/browser/cdp/command/__tests__/
__tests__ → Vitest 根的相对路径: ../../../../../ (5 级)
测试路径参数: core/browser/cdp/command/__tests__/  (不含 src/)
```
