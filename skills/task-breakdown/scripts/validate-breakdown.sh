#!/bin/bash
# validate-breakdown.sh — 验证拆解报告的质量
# 用法: bash validate-breakdown.sh <拆解报告目录>
# 遵循 Harness Engineering 约束执行原则：机械化验证 > 文档指导

REPORT_DIR="$1"
ERRORS=0
WARNINGS=0

if [ -z "$REPORT_DIR" ]; then
    echo "用法: $0 <拆解报告目录>"
    echo "示例: $0 doc/ai-coding/20250409-143000-CDP适配器/01-breakdown"
    exit 1
fi

if [ ! -d "$REPORT_DIR" ]; then
    echo "❌ 目录不存在: $REPORT_DIR"
    exit 1
fi

echo "=============================="
echo " 拆解报告质量验证"
echo " 目录: $REPORT_DIR"
echo "=============================="
echo ""

# ── 检查 1：必需文件 ──────────────────────────────────────
echo "[1/6] 检查必需文件..."
for FILE in README.md SUMMARY.md manifest.json; do
    if [ ! -f "$REPORT_DIR/$FILE" ]; then
        echo "  ❌ 缺少文件: $FILE"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✅ $FILE"
    fi
done

# ── 检查 2：README.md 结构 ────────────────────────────────
echo ""
echo "[2/6] 检查 README.md 结构..."
if [ -f "$REPORT_DIR/README.md" ]; then
    if ! grep -q "速览卡\|## 速览" "$REPORT_DIR/README.md"; then
        echo "  ❌ README.md 缺少速览卡（## 速览卡 或 ## 速览）"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✅ 速览卡存在"
    fi

    if ! grep -q "mermaid" "$REPORT_DIR/README.md"; then
        echo "  ⚠️  README.md 缺少 Mermaid 架构图"
        WARNINGS=$((WARNINGS+1))
    else
        echo "  ✅ Mermaid 架构图存在"
    fi

    if ! grep -q "| M[0-9]\|M0-\|M1-\|模块" "$REPORT_DIR/README.md"; then
        echo "  ❌ README.md 缺少模块总览表"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✅ 模块总览存在"
    fi
fi

# ── 检查 3：模块文件 ──────────────────────────────────────
echo ""
echo "[3/6] 检查模块文件..."
MODULE_COUNT=$(ls "$REPORT_DIR"/M*.md 2>/dev/null | wc -l)
if [ "$MODULE_COUNT" -eq 0 ]; then
    echo "  ❌ 没有找到模块文件（M*.md），至少需要 1 个"
    ERRORS=$((ERRORS+1))
else
    echo "  ✅ 找到 $MODULE_COUNT 个模块文件"
fi

# ── 检查 4：验收标准质量 ──────────────────────────────────
echo ""
echo "[4/6] 检查验收标准质量..."
BAD_ACCEPTANCE=$(grep -r "验收.*功能正常\|验收.*代码编写完成\|验收.*已完成" "$REPORT_DIR"/M*.md 2>/dev/null | head -3)
if [ -n "$BAD_ACCEPTANCE" ]; then
    echo "  ❌ 发现无效验收标准（过于模糊）："
    echo "$BAD_ACCEPTANCE" | head -3 | sed 's/^/     /'
    ERRORS=$((ERRORS+1))
else
    echo "  ✅ 未发现明显无效验收标准"
fi

# 检查是否有验收标准字段
ACCEPTANCE_COUNT=$(grep -r "验收:" "$REPORT_DIR"/M*.md 2>/dev/null | wc -l)
if [ "$ACCEPTANCE_COUNT" -eq 0 ]; then
    echo "  ❌ 模块文件中没有「验收:」字段"
    ERRORS=$((ERRORS+1))
else
    echo "  ✅ 找到 $ACCEPTANCE_COUNT 个验收标准"
fi

# ── 检查 5：manifest.json 格式 ────────────────────────────
echo ""
echo "[5/6] 检查 manifest.json 格式..."
if [ -f "$REPORT_DIR/manifest.json" ]; then
    if python -m json.tool "$REPORT_DIR/manifest.json" > /dev/null 2>&1; then
        echo "  ✅ manifest.json 格式正确"

        # 检查必需字段
        for FIELD in skill version modules; do
            if ! grep -q "\"$FIELD\"" "$REPORT_DIR/manifest.json"; then
                echo "  ⚠️  manifest.json 缺少字段: $FIELD"
                WARNINGS=$((WARNINGS+1))
            fi
        done
    else
        echo "  ❌ manifest.json JSON 格式错误"
        ERRORS=$((ERRORS+1))
    fi
fi

# ── 检查 6：SUMMARY.md 结构 ───────────────────────────────
echo ""
echo "[6/6] 检查 SUMMARY.md 结构..."
if [ -f "$REPORT_DIR/SUMMARY.md" ]; then
    if ! grep -q "风险\|Risk" "$REPORT_DIR/SUMMARY.md"; then
        echo "  ❌ SUMMARY.md 缺少风险提示区"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✅ 风险提示区存在"
    fi

    if ! grep -q "建议\|简化\|补全" "$REPORT_DIR/SUMMARY.md"; then
        echo "  ⚠️  SUMMARY.md 缺少建议/补全区"
        WARNINGS=$((WARNINGS+1))
    else
        echo "  ✅ 建议区存在"
    fi
fi

# ── 结果汇总 ──────────────────────────────────────────────
echo ""
echo "=============================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ 验证通过 — 拆解报告质量合格"
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  验证通过（有 $WARNINGS 个警告）"
    echo "   建议修正上述警告后再进入下一阶段"
else
    echo "❌ 验证失败 — $ERRORS 个错误 / $WARNINGS 个警告"
    echo "   请修正上述问题后重新验证"
fi
echo "=============================="

exit $ERRORS
