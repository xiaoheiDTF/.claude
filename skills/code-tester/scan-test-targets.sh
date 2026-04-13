#!/bin/bash
# ========================================
# scan-test-targets.sh
# 统一测试扫描工具 — 根据规范判断哪些文件需要写测试
#
# 用法:
#   bash scan-test-targets.sh <目录路径>
#   bash scan-test-targets.sh frontend/src/core/browser/cdp/command
#   bash scan-test-targets.sh .                     # 扫描全项目
#
# 输出格式（JSON）:
#   {
#     "scope": { "path": "...", "subproject": "...", "language": "...", "framework": "..." },
#     "needs_test": [ { "source": "...", "suggested_test": "..." } ],
#     "already_tested": [ ... ],
#     "skipped": [ { "file": "...", "reason": "..." } ]
#   }
# ========================================

set -euo pipefail

TARGET="${1:-.}"
TARGET="${TARGET%/}"  # 去掉末尾斜杠

# ── 颜色输出 ──
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── 第一步：定位子项目根目录 ──
find_subproject_root() {
  local dir="$1"
  # 标记文件，按优先级
  local markers=("package.json" "go.mod" "Cargo.toml" "pom.xml" "build.gradle" "build.gradle.kts" "pyproject.toml" "requirements.txt" "Pipfile" "Gemfile" "composer.json")

  while true; do
    for marker in "${markers[@]}"; do
      if [ -f "$dir/$marker" ]; then
        echo "$dir"
        return
      fi
    done
    # 到达根目录则停止
    [ "$dir" = "/" ] || [ "$dir" = "." ] && break
    dir=$(dirname "$dir")
  done
  echo "."
}

# ── 第二步：检测语言和框架 ──
detect_lang_framework() {
  local root="$1"
  local lang="unknown"
  local framework="unknown"

  if [ -f "$root/package.json" ]; then
    lang="js/ts"
    local deps
    deps=$(cat "$root/package.json" 2>/dev/null)
    if echo "$deps" | grep -q '"vitest"'; then framework="vitest"
    elif echo "$deps" | grep -q '"jest"'; then framework="jest"
    elif echo "$deps" | grep -q '"mocha"'; then framework="mocha"
    else framework="vitest-unknown"
    fi
  elif [ -f "$root/go.mod" ]; then
    lang="go"; framework="testing"
  elif [ -f "$root/Cargo.toml" ]; then
    lang="rust"; framework="cargo-test"
  elif [ -f "$root/pom.xml" ] || [ -f "$root/build.gradle" ] || [ -f "$root/build.gradle.kts" ]; then
    lang="java/kotlin"
    local config=""
    [ -f "$root/pom.xml" ] && config=$(cat "$root/pom.xml" 2>/dev/null)
    [ -f "$root/build.gradle" ] && config="$config $(cat "$root/build.gradle" 2>/dev/null)"
    [ -f "$root/build.gradle.kts" ] && config="$config $(cat "$root/build.gradle.kts" 2>/dev/null)"
    if echo "$config" | grep -qi 'spring-boot'; then framework="spring-boot-test"
    elif echo "$config" | grep -qi 'testng'; then framework="testng"
    else framework="junit5"
    fi
  elif [ -f "$root/pyproject.toml" ] || [ -f "$root/requirements.txt" ] || [ -f "$root/Pipfile" ]; then
    lang="python"
    local reqs=""
    [ -f "$root/requirements.txt" ] && reqs=$(cat "$root/requirements.txt" 2>/dev/null)
    [ -f "$root/pyproject.toml" ] && reqs="$reqs $(cat "$root/pyproject.toml" 2>/dev/null)"
    if echo "$reqs" | grep -qi 'django'; then framework="django-test"
    elif echo "$reqs" | grep -qi 'pytest'; then framework="pytest"
    else framework="pytest-unknown"
    fi
  elif [ -f "$root/Gemfile" ]; then
    lang="ruby"; framework="rspec"
  elif [ -f "$root/composer.json" ]; then
    lang="php"; framework="phpunit"
  fi

  echo "$lang|$framework"
}

# ── 第三步：判断源文件是否需要测试 ──
is_testable_file() {
  local filename="$1"
  local basename="${filename##*/}"

  # 跳过规则（与 convention.md 第三节一致）
  case "$basename" in
    index.ts|index.tsx|index.js|index.jsx)  return 1 ;;  # 纯导出聚合
    *.d.ts)                                  return 1 ;;  # 类型声明
    *.config.*|*.conf.*|tsconfig.*|vite.config.*|jest.config.*|webpack.config.*|rollup.config.*|eslintrc.*|.babelrc.*|babel.config.*|tailwind.config.*|postcss.config.*|next.config.*|nuxt.config.*)
                                              return 1 ;;  # 配置文件
    types.ts|types.tsx|types.js|interfaces.ts|interfaces.tsx)
                                              return 1 ;;  # 纯类型
    constants.ts|constants.js|constant.ts|constant.js)
                                              return 1 ;;  # 纯常量
    README.*|CHANGELOG.*|LICENSE.*)           return 1 ;;  # 文档
    *.test.*|*.spec.*|test_*|*_test.*|*Test.*|*Tests.*)
                                              return 1 ;;  # 已有测试
    __mocks__/*|__fixtures__/*|fixtures/*|mocks/*)
                                              return 1 ;;  # mock/fixture
  esac

  # 只保留代码文件
  case "$filename" in
    *.ts|*.tsx|*.js|*.jsx|*.py|*.java|*.kt|*.go|*.rs|*.cs|*.rb|*.php)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

# ── 第四步：判断文件是否已有测试 ──
has_test_file() {
  local source_file="$1"
  local dir="${source_file%/*}"
  local basename="${source_file##*/}"
  local name="${basename%.*}"

  # 检查同目录下是否有对应测试文件（各框架命名模式）
  for pattern in "${name}.test.*" "${name}.spec.*" "test_${name}.*" "${name}_test.*" "${name}Test.*" "${name}Tests.*"; do
    if compgen -G "$dir/$pattern" > /dev/null 2>&1; then
      return 0
    fi
  done

  # 检查同目录的 __tests__/ 子目录
  if [ -d "$dir/__tests__" ]; then
    for pattern in "${name}.test.*" "${name}.spec.*"; do
      if compgen -G "$dir/__tests__/$pattern" > /dev/null 2>&1; then
        return 0
      fi
    done
  fi

  return 1
}

# ── 第五步：推断测试文件路径 ──
suggest_test_path() {
  local source_file="$1"
  local framework="$2"
  local dir="${source_file%/*}"
  local basename="${source_file##*/}"
  local name="${basename%.*}"
  local ext="${basename##*.}"

  case "$framework" in
    vitest|jest|mocha)
      # 优先 __tests__/
      if [ -d "$dir/__tests__" ]; then
        echo "$dir/__tests__/${name}.test.${ext}"
      else
        echo "$dir/__tests__/${name}.test.${ext}"
      fi
      ;;
    pytest|django-test|pytest-unknown)
      echo "$dir/test_${name}.py"
      ;;
    junit5|testng|spring-boot-test)
      # Java: src/main → src/test 镜像
      local test_dir
      test_dir=$(echo "$dir" | sed 's|src/main/java|src/test/java|')
      echo "$test_dir/${name}Test.java"
      ;;
    testing|testify)
      echo "$dir/${name}_test.go"
      ;;
    cargo-test)
      echo "$dir/${name}_test.rs"
      ;;
    xunit|nunit|mstest)
      echo "$dir/${name}Tests.cs"
      ;;
    rspec)
      local spec_dir
      spec_dir=$(echo "$dir" | sed 's|lib/|spec/|')
      echo "$spec_dir/${name}_spec.rb"
      ;;
    phpunit|pest)
      echo "${dir%/src}/${dir#*/src/}" | sed 's|src/|tests/|'
      echo "tests/${name}Test.php"
      ;;
    *)
      echo "$dir/__tests__/${name}.test.${ext}"
      ;;
  esac
}

# ── 主流程 ──

# 如果是文件，转为目录
if [ -f "$TARGET" ]; then
  TARGET_DIR=$(dirname "$TARGET")
  TARGET_FILE="$TARGET"
else
  TARGET_DIR="$TARGET"
  TARGET_FILE=""
fi

# 定位子项目
SUBPROJECT_ROOT=$(find_subproject_root "$TARGET_DIR")
LANG_FRAMEWORK=$(detect_lang_framework "$SUBPROJECT_ROOT")
LANG="${LANG_FRAMEWORK%%|*}"
FRAMEWORK="${LANG_FRAMEWORK##*|}"

echo -e "${BOLD}━━━ 测试扫描报告 ━━━${NC}"
echo ""
echo -e "  目标路径:     ${CYAN}${TARGET}${NC}"
echo -e "  子项目根:     ${CYAN}${SUBPROJECT_ROOT}${NC}"
echo -e "  语言:         ${CYAN}${LANG}${NC}"
echo -e "  测试框架:     ${CYAN}${FRAMEWORK}${NC}"
echo ""

# 如果指定了单个文件
if [ -n "$TARGET_FILE" ]; then
  if is_testable_file "$TARGET_FILE"; then
    if has_test_file "$TARGET_FILE"; then
      echo -e "  ${YELLOW}[已有测试]${NC} ${TARGET_FILE}"
    else
      local suggested=$(suggest_test_path "$TARGET_FILE" "$FRAMEWORK")
      echo -e "  ${GREEN}[需要测试]${NC} ${TARGET_FILE}"
      echo -e "              ${GRAY}→ ${suggested}${NC}"
    fi
  else
    echo -e "  ${GRAY}[跳过]${NC} ${TARGET_FILE} (非可测试文件)"
  fi
  exit 0
fi

# 扫描目录下直接的代码文件（不递归子目录）
NEEDS_TEST=()
ALREADY_TESTED=()
SKIPPED=()

for file in "$TARGET_DIR"/*; do
  [ -f "$file" ] || continue
  filename="${file##*/}"

  if ! is_testable_file "$filename"; then
    SKIPPED+=("$filename|非可测试文件")
    continue
  fi

  if has_test_file "$file"; then
    ALREADY_TESTED+=("$filename")
    continue
  fi

  suggested=$(suggest_test_path "$file" "$FRAMEWORK")
  NEEDS_TEST+=("$filename|$suggested")
done

# 输出结果
echo -e "${GREEN}${BOLD}需要写测试 (${#NEEDS_TEST[@]} 个文件)${NC}"
echo "─────────────────────────────────"
if [ ${#NEEDS_TEST[@]} -eq 0 ]; then
  echo -e "  ${GRAY}(无)${NC}"
else
  for entry in "${NEEDS_TEST[@]}"; do
    source="${entry%%|*}"
    test_path="${entry##*|}"
    echo -e "  ${source}"
    echo -e "    ${GRAY}→ ${test_path}${NC}"
  done
fi
echo ""

echo -e "${YELLOW}${BOLD}已有测试 (${#ALREADY_TESTED[@]} 个文件)${NC}"
echo "─────────────────────────────────"
if [ ${#ALREADY_TESTED[@]} -eq 0 ]; then
  echo -e "  ${GRAY}(无)${NC}"
else
  for f in "${ALREADY_TESTED[@]}"; do
    echo -e "  ${f}"
  done
fi
echo ""

echo -e "${GRAY}${BOLD}跳过 (${#SKIPPED[@]} 个文件)${NC}"
echo "─────────────────────────────────"
if [ ${#SKIPPED[@]} -eq 0 ]; then
  echo -e "  ${GRAY}(无)${NC}"
else
  for entry in "${SKIPPED[@]}"; do
    f="${entry%%|*}"
    reason="${entry##*|}"
    echo -e "  ${GRAY}${f} — ${reason}${NC}"
  done
fi
echo ""

echo -e "${BOLD}━━━ 汇总 ━━━${NC}"
echo -e "  需要测试: ${GREEN}${#NEEDS_TEST[@]}${NC}  已有测试: ${YELLOW}${#ALREADY_TESTED[@]}${NC}  跳过: ${GRAY}${#SKIPPED[@]}${NC}"
