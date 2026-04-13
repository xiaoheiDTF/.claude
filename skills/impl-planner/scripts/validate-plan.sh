#!/bin/bash
# validate-plan.sh — 验证执行计划的质量
# 用法: bash validate-plan.sh <执行计划目录>
# 遵循 Harness Engineering 约束执行原则：机械化验证 > 文档指导

PLAN_DIR="$1"
ERRORS=0
WARNINGS=0

if [ -z "$PLAN_DIR" ]; then
    echo "用法: $0 <执行计划目录>"
    echo "示例: $0 doc/ai-coding/20250409-143000-CDP适配器/03-plan"
    exit 1
fi

if [ ! -d "$PLAN_DIR" ]; then
    echo "❌ 目录不存在: $PLAN_DIR"
    exit 1
fi

echo "=============================="
echo " 执行计划质量验证"
echo " 目录: $PLAN_DIR"
echo "=============================="
echo ""

# ── 检查 1：必需文件 ──────────────────────────────────────
echo "[1/7] 检查必需文件..."
for FILE in README.md ACCEPTANCE.md manifest.json; do
    if [ ! -f "$PLAN_DIR/$FILE" ]; then
        echo "  ❌ 缺少文件: $FILE"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✅ $FILE"
    fi
done

# RISKS.md 可选但推荐
if [ ! -f "$PLAN_DIR/RISKS.md" ]; then
    echo "  ⚠️  缺少 RISKS.md（推荐创建）"
    WARNINGS=$((WARNINGS+1))
fi

# ── 检查 2：步骤文件 ──────────────────────────────────────
echo ""
echo "[2/7] 检查步骤文件..."
STEP_COUNT=$(ls "$PLAN_DIR"/S*.md 2>/dev/null | wc -l)
if [ "$STEP_COUNT" -eq 0 ]; then
    echo "  ❌ 没有找到步骤文件（S*.md），至少需要 1 个"
    ERRORS=$((ERRORS+1))
else
    echo "  ✅ 找到 $STEP_COUNT 个步骤文件"
fi

# ── 检查 3：README.md 必须包含实现架构图 ─────────────────
echo ""
echo "[3/7] 检查 README.md 实现架构图..."
if [ -f "$PLAN_DIR/README.md" ]; then
    if ! grep -q "mermaid" "$PLAN_DIR/README.md"; then
        echo "  ❌ README.md 缺少实现架构图（mermaid 代码块）"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✅ 实现架构图存在"
    fi

    if ! grep -q "可修改区域\|只读区域\|修改边界" "$PLAN_DIR/README.md"; then
        echo "  ❌ README.md 缺少修改边界定义（可修改区域 / 只读区域）"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✅ 修改边界定义存在"
    fi

    if ! grep -q "速览卡\|## 速览" "$PLAN_DIR/README.md"; then
        echo "  ⚠️  README.md 缺少速览卡"
        WARNINGS=$((WARNINGS+1))
    else
        echo "  ✅ 速览卡存在"
    fi
fi

# ── 检查 4：步骤质量 ──────────────────────────────────────
echo ""
echo "[4/7] 检查步骤文件质量..."

# 检查模糊的目标文件描述
VAGUE_TARGET=$(grep -r "找到合适位置\|适当位置\|合适的文件" "$PLAN_DIR"/S*.md 2>/dev/null | head -3)
if [ -n "$VAGUE_TARGET" ]; then
    echo "  ❌ 发现模糊的目标文件描述（'找到合适位置'等）："
    echo "$VAGUE_TARGET" | sed 's/^/     /'
    ERRORS=$((ERRORS+1))
else
    echo "  ✅ 目标文件描述无明显模糊问题"
fi

# 检查无效验证方式
VAGUE_VERIFY=$(grep -r "验证.*实现完成后\|验证.*完成即可\|验证.*代码写完" "$PLAN_DIR"/S*.md 2>/dev/null | head -3)
if [ -n "$VAGUE_VERIFY" ]; then
    echo "  ❌ 发现无效验证方式（'实现完成后验证'等废话）："
    echo "$VAGUE_VERIFY" | sed 's/^/     /'
    ERRORS=$((ERRORS+1))
else
    echo "  ✅ 步骤验证方式无明显问题"
fi

# 检查步骤是否有目标文件字段
STEPS_WITH_TARGET=$(grep -r "目标文件\|文件路径\|target" "$PLAN_DIR"/S*.md 2>/dev/null | wc -l)
if [ "$STEPS_WITH_TARGET" -eq 0 ]; then
    echo "  ⚠️  步骤文件中没有「目标文件」字段"
    WARNINGS=$((WARNINGS+1))
else
    echo "  ✅ 步骤文件包含目标文件信息"
fi

# ── 检查 5：ACCEPTANCE.md 结构 ────────────────────────────
echo ""
echo "[5/7] 检查 ACCEPTANCE.md 结构..."
if [ -f "$PLAN_DIR/ACCEPTANCE.md" ]; then
    if ! grep -q "P0\|P1\|P2" "$PLAN_DIR/ACCEPTANCE.md"; then
        echo "  ❌ ACCEPTANCE.md 缺少优先级分级（P0/P1/P2）"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✅ 优先级分级存在"
    fi

    if ! grep -q "前置条件\|预期结果\|操作步骤" "$PLAN_DIR/ACCEPTANCE.md"; then
        echo "  ⚠️  ACCEPTANCE.md 场景结构不完整（建议包含：前置条件 + 操作步骤 + 预期结果）"
        WARNINGS=$((WARNINGS+1))
    else
        echo "  ✅ 场景结构完整"
    fi
fi

# ── 检查 6：manifest.json 格式 ────────────────────────────
echo ""
echo "[6/7] 检查 manifest.json..."
if [ -f "$PLAN_DIR/manifest.json" ]; then
    if python -m json.tool "$PLAN_DIR/manifest.json" > /dev/null 2>&1; then
        echo "  ✅ manifest.json 格式正确"
    else
        echo "  ❌ manifest.json JSON 格式错误"
        ERRORS=$((ERRORS+1))
    fi
fi

# ── 检查 7：步骤依赖无环（简单检查）─────────────────────
echo ""
echo "[7/7] 检查步骤编号连续性..."
if [ "$STEP_COUNT" -gt 0 ]; then
    # 检查步骤文件命名是否连续（S01, S02, S03...）
    EXPECTED=1
    for STEP_FILE in $(ls "$PLAN_DIR"/S*.md 2>/dev/null | sort); do
        ACTUAL_NUM=$(basename "$STEP_FILE" | grep -o 'S[0-9]*' | grep -o '[0-9]*' | sed 's/^0*//')
        if [ "$ACTUAL_NUM" != "$EXPECTED" ]; then
            echo "  ⚠️  步骤编号不连续（期望 S$(printf '%02d' $EXPECTED)，发现 $(basename $STEP_FILE)）"
            WARNINGS=$((WARNINGS+1))
        fi
        EXPECTED=$((EXPECTED+1))
    done
    echo "  ✅ 步骤编号检查完成"
fi

# ── 结果汇总 ──────────────────────────────────────────────
echo ""
echo "=============================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ 验证通过 — 执行计划质量合格"
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  验证通过（有 $WARNINGS 个警告）"
    echo "   建议修正上述警告后再进入下一阶段"
else
    echo "❌ 验证失败 — $ERRORS 个错误 / $WARNINGS 个警告"
    echo "   请修正上述问题后重新验证"
fi
echo "=============================="

exit $ERRORS
