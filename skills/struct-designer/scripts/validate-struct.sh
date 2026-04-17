#!/bin/bash
# validate-struct.sh — 验证结构设计输出文件的完整性
# 用法: bash validate-struct.sh <输出目录路径>

set -euo pipefail

DIR="${1:-.}"
ERRORS=0
WARNINGS=0

echo "=== 结构设计验证 ==="
echo "目录: $DIR"
echo ""

# 1. 检查必要文件
check_file() {
  if [ -f "$DIR/$1" ]; then
    echo "  ✓ $1"
  else
    echo "  ✗ $1 缺失"
    ((ERRORS++))
  fi
}

echo "[1] 必要文件检查"
check_file "manifest.json"
check_file "README.md"
check_file "SUMMARY.md"
check_file "D01-包结构.md"
check_file "D02-数据模型.md"
check_file "D03-接口定义.md"
check_file "D04-类设计.md"
check_file "D05-关键流程.md"
echo ""

# 2. 检查 manifest.json 格式
echo "[2] manifest.json 格式检查"
if [ -f "$DIR/manifest.json" ]; then
  for field in "type" "version" "generated_at" "modules" "total" "entities" "languages"; do
    if grep -q "\"$field\"" "$DIR/manifest.json" 2>/dev/null; then
      echo "  ✓ 字段 $field 存在"
    else
      echo "  ✗ 字段 $field 缺失"
      ((ERRORS++))
    fi
  done

  TYPE=$(cat "$DIR/manifest.json" | grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | grep -o '"[^"]*"$' | tr -d '"')
  if [ "$TYPE" = "struct-designer" ]; then
    echo "  ✓ type = struct-designer"
  else
    echo "  ✗ type 应为 struct-designer，实际为 $TYPE"
    ((ERRORS++))
  fi

  # 检查 total 字段
  for subfield in "classes_count" "interfaces_count" "entities_count"; do
    if grep -q "\"$subfield\"" "$DIR/manifest.json" 2>/dev/null; then
      echo "  ✓ total.$subfield 存在"
    else
      echo "  ✗ total.$subfield 缺失"
      ((ERRORS++))
    fi
  done
else
  echo "  跳过（manifest.json 不存在）"
fi
echo ""

# 3. 检查 README.md 速览卡
echo "[3] README.md 速览卡检查"
if [ -f "$DIR/README.md" ]; then
  if grep -q "速览卡" "$DIR/README.md"; then
    echo "  ✓ 包含速览卡"
  else
    echo "  ✗ 缺少速览卡"
    ((ERRORS++))
  fi
  for keyword in "核心目标" "模块数" "类" "数据模型"; do
    if grep -q "$keyword" "$DIR/README.md"; then
      echo "  ✓ 包含 $keyword"
    else
      echo "  ⚠ 缺少 $keyword"
      ((WARNINGS++))
    fi
  done
else
  echo "  跳过（README.md 不存在）"
fi
echo ""

# 4. 检查数据模型（D02）
echo "[4] 数据模型检查"
if [ -f "$DIR/D02-数据模型.md" ]; then
  # 检查有字段定义（表格形式）
  TABLE_COUNT=$(grep -c "^|.*|.*|.*|" "$DIR/D02-数据模型.md" 2>/dev/null || echo "0")
  if [ "$TABLE_COUNT" -gt 3 ]; then
    echo "  ✓ 包含字段定义表格"
  else
    echo "  ⚠ 字段定义表格可能不完整"
    ((WARNINGS++))
  fi

  # 检查有关系节
  if grep -q "关系" "$DIR/D02-数据模型.md"; then
    echo "  ✓ 包含关系定义"
  else
    echo "  ⚠ 缺少关系定义"
    ((WARNINGS++))
  fi
else
  echo "  跳过（D02-数据模型.md 不存在）"
fi
echo ""

# 5. 检查接口定义（D03）
echo "[5] 接口定义检查"
if [ -f "$DIR/D03-接口定义.md" ]; then
  METHOD_COUNT=$(grep -c "方法" "$DIR/D03-接口定义.md" 2>/dev/null || echo "0")
  if [ "$METHOD_COUNT" -gt 0 ]; then
    echo "  ✓ 包含方法定义"
  else
    echo "  ⚠ 缺少方法定义"
    ((WARNINGS++))
  fi

  # 检查有参数类型
  if grep -qE "\(.*\)" "$DIR/D03-接口定义.md" 2>/dev/null; then
    echo "  ✓ 包含方法签名（含参数类型）"
  else
    echo "  ⚠ 方法签名缺少参数类型"
    ((WARNINGS++))
  fi
else
  echo "  跳过（D03-接口定义.md 不存在）"
fi
echo ""

# 6. 检查时序图（D05）
echo "[6] 时序图检查"
if [ -f "$DIR/D05-关键流程.md" ]; then
  if grep -q "sequenceDiagram" "$DIR/D05-关键流程.md"; then
    DIAGRAM_COUNT=$(grep -c "sequenceDiagram" "$DIR/D05-关键流程.md")
    echo "  ✓ 找到 $DIAGRAM_COUNT 个时序图"
  else
    echo "  ⚠ 缺少时序图"
    ((WARNINGS++))
  fi
else
  echo "  跳过（D05-关键流程.md 不存在）"
fi
echo ""

# 7. 检查包结构（D01）
echo "[7] 包结构检查"
if [ -f "$DIR/D01-包结构.md" ]; then
  if grep -qE "(com\.|org\.|src/|app/)" "$DIR/D01-包结构.md" 2>/dev/null; then
    echo "  ✓ 包含包路径定义"
  else
    echo "  ⚠ 缺少包路径定义"
    ((WARNINGS++))
  fi
else
  echo "  跳过（D01-包结构.md 不存在）"
fi
echo ""

# 总结
echo "=== 验证结果 ==="
echo "错误: $ERRORS"
echo "警告: $WARNINGS"
if [ "$ERRORS" -eq 0 ]; then
  echo "结果: 通过 ✓"
  exit 0
else
  echo "结果: 未通过 ✗"
  exit 1
fi
