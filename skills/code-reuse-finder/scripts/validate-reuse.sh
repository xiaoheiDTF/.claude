#!/bin/bash
# validate-reuse.sh — 验证复用报告的质量
# 用法: bash validate-reuse.sh <复用报告目录>
# 遵循 Harness Engineering 约束执行原则：机械化验证 > 文档指导

REPORT_DIR="$1"
ERRORS=0
WARNINGS=0

if [ -z "$REPORT_DIR" ]; then
    echo "用法: $0 <复用报告目录>"
    echo "示例: $0 doc/ai-coding/20250409-143000-CDP适配器/02-reuse"
    exit 1
fi

if [ ! -d "$REPORT_DIR" ]; then
    echo "❌ 目录不存在: $REPORT_DIR"
    exit 1
fi

echo "=============================="
echo " 复用报告质量验证"
echo " 目录: $REPORT_DIR"
echo "=============================="
echo ""

# ── 检查 1：必需文件 ──────────────────────────────────────
echo "[1/5] 检查必需文件..."
for FILE in README.md SUMMARY.md manifest.json; do
    if [ ! -f "$REPORT_DIR/$FILE" ]; then
        echo "  ❌ 缺少文件: $FILE"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✅ $FILE"
    fi
done

# ── 检查 2：模块文件 ──────────────────────────────────────
echo ""
echo "[2/5] 检查模块文件..."
MODULE_COUNT=$(ls "$REPORT_DIR"/R*.md 2>/dev/null | wc -l)
if [ "$MODULE_COUNT" -eq 0 ]; then
    echo "  ❌ 没有找到模块文件（R*.md），至少需要 1 个"
    ERRORS=$((ERRORS+1))
else
    echo "  ✅ 找到 $MODULE_COUNT 个模块文件"
fi

# ── 检查 3：README.md 包含复用密度 ───────────────────────
echo ""
echo "[3/5] 检查 README.md 内容..."
if [ -f "$REPORT_DIR/README.md" ]; then
    if ! grep -q "复用密度\|直接用\|编排组合\|自己写" "$REPORT_DIR/README.md"; then
        echo "  ❌ README.md 缺少复用密度统计"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✅ 复用密度统计存在"
    fi

    if ! grep -q "速览卡\|## 速览" "$REPORT_DIR/README.md"; then
        echo "  ⚠️  README.md 缺少速览卡"
        WARNINGS=$((WARNINGS+1))
    else
        echo "  ✅ 速览卡存在"
    fi
fi

# ── 检查 4：代码引用格式 ──────────────────────────────────
echo ""
echo "[4/5] 检查代码引用格式..."

# 检查是否存在没有行号的"直接用"引用
# 寻找形如 "直接用" 或 "编排组合" 后没有 L[数字] 的代码引用
if grep -rn "直接用\|编排组合" "$REPORT_DIR"/R*.md 2>/dev/null | grep -v "L[0-9]\|行[0-9]\|:[0-9]" | grep -v "^#\|判断\|分类\|类型" | head -3 | grep -q "\."; then
    echo "  ⚠️  部分复用引用可能缺少行号，请检查"
    WARNINGS=$((WARNINGS+1))
else
    echo "  ✅ 代码引用格式检查通过"
fi

# 检查是否内嵌了完整代码块（超过 5 行的代码块是危险信号）
# 统计代码块开始标记
CODE_BLOCK_OPENS=$(grep -r '```' "$REPORT_DIR"/R*.md 2>/dev/null | wc -l)
# 每个代码块有开和关两个 ```, 超过 6 对视为可能内嵌完整代码
if [ "$CODE_BLOCK_OPENS" -gt 12 ]; then
    echo "  ⚠️  检测到大量代码块（$CODE_BLOCK_OPENS 个标记），请确认没有内嵌完整代码"
    echo "     规范：复用代码只标注 文件路径 + 行号 + 一句话说明，不复制完整代码"
    WARNINGS=$((WARNINGS+1))
else
    echo "  ✅ 代码块数量正常（$CODE_BLOCK_OPENS 个标记）"
fi

# ── 检查 5：SUMMARY.md 风险提示 ──────────────────────────
echo ""
echo "[5/5] 检查 SUMMARY.md..."
if [ -f "$REPORT_DIR/SUMMARY.md" ]; then
    if ! grep -q "风险\|Risk\|破坏性\|兼容" "$REPORT_DIR/SUMMARY.md"; then
        echo "  ❌ SUMMARY.md 缺少风险提示区（破坏性复用/版本兼容/并发安全/边界条件）"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✅ 风险提示区存在"
    fi
fi

# ── 结果汇总 ──────────────────────────────────────────────
echo ""
echo "=============================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ 验证通过 — 复用报告质量合格"
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  验证通过（有 $WARNINGS 个警告）"
else
    echo "❌ 验证失败 — $ERRORS 个错误 / $WARNINGS 个警告"
    echo "   请修正上述问题后重新验证"
fi
echo "=============================="

exit $ERRORS
