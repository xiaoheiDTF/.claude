#!/bin/bash
# validate-arch.sh — 验证架构设计输出文件的完整性
# 用法: bash validate-arch.sh <输出目录路径>

set -euo pipefail

DIR="${1:-.}"
ERRORS=0
WARNINGS=0

echo "=== 架构设计验证 ==="
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
check_file "A01-架构总览.md"
check_file "A02-接口契约.md"
check_file "A03-技术选型.md"
echo ""

# 2. 检查 manifest.json 格式
echo "[2] manifest.json 格式检查"
if [ -f "$DIR/manifest.json" ]; then
  # 检查必要字段
  for field in "type" "version" "generated_at" "modules" "tech_stack" "statistics"; do
    if grep -q "\"$field\"" "$DIR/manifest.json" 2>/dev/null; then
      echo "  ✓ 字段 $field 存在"
    else
      echo "  ✗ 字段 $field 缺失"
      ((ERRORS++))
    fi
  done

  # 检查 type 是否正确
  TYPE=$(cat "$DIR/manifest.json" | grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | grep -o '"[^"]*"$' | tr -d '"')
  if [ "$TYPE" = "arch-designer" ]; then
    echo "  ✓ type = arch-designer"
  else
    echo "  ✗ type 应为 arch-designer，实际为 $TYPE"
    ((ERRORS++))
  fi

  # 检查 modules 数组非空
  MODULES_COUNT=$(cat "$DIR/manifest.json" | grep -o '"id"' | wc -l)
  if [ "$MODULES_COUNT" -gt 0 ]; then
    echo "  ✓ modules 数组有 $MODULES_COUNT 个模块"
  else
    echo "  ✗ modules 数组为空"
    ((ERRORS++))
  fi
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

  if grep -q "核心目标" "$DIR/README.md"; then
    echo "  ✓ 包含核心目标"
  else
    echo "  ✗ 缺少核心目标"
    ((WARNINGS++))
  fi
else
  echo "  跳过（README.md 不存在）"
fi
echo ""

# 4. 检查 Mermaid 图
echo "[4] Mermaid 图表检查"
MERMAID_COUNT=$(grep -r "^\s*\`\`\`mermaid" "$DIR"/*.md 2>/dev/null | wc -l)
if [ "$MERMAID_COUNT" -gt 0 ]; then
  echo "  ✓ 找到 $MERMAID_COUNT 个 Mermaid 图"
else
  echo "  ⚠ 未找到 Mermaid 图（建议添加架构图）"
  ((WARNINGS++))
fi
echo ""

# 5. 检查 ADR 目录
echo "[5] ADR 检查"
if [ -d "$DIR/ADR" ]; then
  ADR_COUNT=$(find "$DIR/ADR" -name "*.md" 2>/dev/null | wc -l)
  if [ "$ADR_COUNT" -gt 0 ]; then
    echo "  ✓ 有 $ADR_COUNT 个 ADR"
    # 检查 ADR 格式
    for adr in "$DIR/ADR"/*.md; do
      if [ -f "$adr" ]; then
        ADR_NAME=$(basename "$adr")
        if grep -q "状态" "$adr" && grep -q "决策" "$adr"; then
          echo "  ✓ $ADR_NAME 格式正确"
        else
          echo "  ⚠ $ADR_NAME 缺少必要段落（状态/决策）"
          ((WARNINGS++))
        fi
      fi
    done
  else
    echo "  ⚠ ADR 目录存在但为空（建议至少记录一个重要决策）"
    ((WARNINGS++))
  fi
else
  echo "  ⚠ 无 ADR 目录（建议为重要架构决策创建 ADR）"
  ((WARNINGS++))
fi
echo ""

# 6. 检查循环依赖（简单检测）
echo "[6] 依赖检查"
if [ -f "$DIR/A01-架构总览.md" ]; then
  # 检查是否提到循环依赖
  if grep -qi "循环" "$DIR/A01-架构总览.md"; then
    echo "  ✗ 检测到循环依赖提及"
    ((ERRORS++))
  else
    echo "  ✓ 无循环依赖标记"
  fi
else
  echo "  跳过（A01-架构总览.md 不存在）"
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
