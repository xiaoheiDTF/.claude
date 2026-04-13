#!/bin/bash
# validate-pipeline.sh — 验证整个流水线的契约一致性
# 用法: bash validate-pipeline.sh <需求根目录>
# 遵循 Harness Engineering 约束执行原则：机械化验证 > 文档指导

ROOT_DIR="$1"
ERRORS=0
WARNINGS=0

if [ -z "$ROOT_DIR" ]; then
    echo "用法: $0 <需求根目录>"
    echo "示例: $0 /doc/ai-coding/20250409-143000-CDP适配器"
    exit 1
fi

if [ ! -d "$ROOT_DIR" ]; then
    echo "❌ 目录不存在: $ROOT_DIR"
    exit 1
fi

echo "=============================="
echo " 流水线契约一致性验证"
echo " 根目录: $ROOT_DIR"
echo "=============================="
echo ""

# ── 检查已完成的阶段 ──────────────────────────────────────
echo "[1/5] 检查已完成阶段..."
STAGES_DONE=0
for STAGE in 01-breakdown 02-reuse 03-plan 04-report 05-test; do
    if [ -d "$ROOT_DIR/$STAGE" ]; then
        echo "  ✅ $STAGE 阶段已完成"
        STAGES_DONE=$((STAGES_DONE+1))
    else
        echo "  ⏸  $STAGE 阶段未执行"
    fi
done

if [ $STAGES_DONE -eq 0 ]; then
    echo "❌ 没有发现任何已完成的阶段"
    exit 1
fi

# ── 检查 manifest.json 存在性 ────────────────────────────
echo ""
echo "[2/5] 检查各阶段 manifest.json..."
for STAGE in 01-breakdown 02-reuse 03-plan 05-test; do
    if [ -d "$ROOT_DIR/$STAGE" ]; then
        if [ ! -f "$ROOT_DIR/$STAGE/manifest.json" ]; then
            echo "  ❌ $STAGE/manifest.json 缺失（已完成阶段必须有契约文件）"
            ERRORS=$((ERRORS+1))
        else
            echo "  ✅ $STAGE/manifest.json 存在"
        fi
    fi
done

# ── 检查跨阶段模块一致性 ──────────────────────────────────
echo ""
echo "[3/5] 检查跨阶段模块一致性..."

# 提取各阶段模块列表
get_modules() {
    local manifest="$1"
    if [ -f "$manifest" ]; then
        python -c "
import json, sys
try:
    with open('$manifest') as f:
        d = json.load(f)
    modules = d.get('modules', [])
    if isinstance(modules, list):
        print(' '.join([str(m.get('id', m) if isinstance(m, dict) else m) for m in modules]))
    else:
        print('')
except Exception as e:
    print('')
" 2>/dev/null
    fi
}

BREAKDOWN_MODULES=""
REUSE_MODULES=""
PLAN_MODULES=""

[ -f "$ROOT_DIR/01-breakdown/manifest.json" ] && BREAKDOWN_MODULES=$(get_modules "$ROOT_DIR/01-breakdown/manifest.json")
[ -f "$ROOT_DIR/02-reuse/manifest.json" ]    && REUSE_MODULES=$(get_modules "$ROOT_DIR/02-reuse/manifest.json")
[ -f "$ROOT_DIR/03-plan/manifest.json" ]     && PLAN_MODULES=$(get_modules "$ROOT_DIR/03-plan/manifest.json")

# 检查拆解 vs 复用
if [ -n "$BREAKDOWN_MODULES" ] && [ -n "$REUSE_MODULES" ]; then
    if [ "$BREAKDOWN_MODULES" = "$REUSE_MODULES" ]; then
        echo "  ✅ 拆解 ↔ 复用：模块列表一致"
    else
        echo "  ⚠️  拆解 ↔ 复用：模块列表可能不一致"
        echo "     拆解: $BREAKDOWN_MODULES"
        echo "     复用: $REUSE_MODULES"
        WARNINGS=$((WARNINGS+1))
    fi
fi

# 检查拆解 vs 计划
if [ -n "$BREAKDOWN_MODULES" ] && [ -n "$PLAN_MODULES" ]; then
    if [ "$BREAKDOWN_MODULES" = "$PLAN_MODULES" ]; then
        echo "  ✅ 拆解 ↔ 计划：模块列表一致"
    else
        echo "  ⚠️  拆解 ↔ 计划：模块列表可能不一致"
        echo "     拆解: $BREAKDOWN_MODULES"
        echo "     计划: $PLAN_MODULES"
        WARNINGS=$((WARNINGS+1))
    fi
fi

# ── 检查需求根目录结构 ────────────────────────────────────
echo ""
echo "[4/5] 检查需求根目录结构..."
ROOT_NAME=$(basename "$ROOT_DIR")
if echo "$ROOT_NAME" | grep -qE "^[0-9]{8}-[0-9]{6}-.+"; then
    echo "  ✅ 需求目录命名格式正确（YYYYMMDD-HHmmss-描述）"
else
    echo "  ⚠️  需求目录命名不符合规范（建议：YYYYMMDD-HHmmss-描述）"
    WARNINGS=$((WARNINGS+1))
fi

# ── 检查测试阶段与计划阶段关联 ─────────────────────────────
echo ""
echo "[5/5] 检查测试阶段关联..."
if [ -f "$ROOT_DIR/05-test/manifest.json" ] && [ -f "$ROOT_DIR/03-plan/manifest.json" ]; then
    PLAN_REF=$(python -c "import json;print(json.load(open('$ROOT_DIR/05-test/manifest.json', encoding='utf-8')).get('source_plan',''))" 2>/dev/null || echo "")
    if [ -n "$PLAN_REF" ]; then
        echo "  ✅ 05-test/source_plan 已声明: $PLAN_REF"
    else
        echo "  ⚠️  05-test/manifest.json 未声明 source_plan"
        WARNINGS=$((WARNINGS+1))
    fi
else
    echo "  ⏸  跳过（缺少 05-test 或 03-plan manifest）"
fi

# ── 结果汇总 ──────────────────────────────────────────────
echo ""
echo "=============================="
echo "  已完成阶段: $STAGES_DONE / 5"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ 流水线契约验证通过"
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  流水线契约验证通过（有 $WARNINGS 个警告）"
else
    echo "❌ 流水线契约验证失败 — $ERRORS 个错误 / $WARNINGS 个警告"
fi
echo "=============================="

exit $ERRORS
