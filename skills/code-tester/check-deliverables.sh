#!/bin/bash
# ========================================
# check-deliverables.sh
# Check that all required test deliverables exist.
#
# Usage:
#   bash check-deliverables.sh <test-dir>
#   bash check-deliverables.sh frontend/tests/core/browser/cdp/command
#
# Exit code: 0 = all present, 1 = missing items
# ========================================

set -euo pipefail

TEST_DIR="${1:-}"

if [ -z "$TEST_DIR" ]; then
  echo "[ERROR] Usage: bash check-deliverables.sh <test-dir>"
  exit 1
fi

# Remove trailing slash
TEST_DIR="${TEST_DIR%/}"

if [ ! -d "$TEST_DIR" ]; then
  echo "[ERROR] Directory not found: $TEST_DIR"
  exit 1
fi

# -- Colors --
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

MISSING=0

echo "========================================"
echo " Deliverables Check: $TEST_DIR"
echo "========================================"
echo ""

# 1. Test files (*.test.*, test_*, *_test.*)
echo -e "${BOLD}[1/6] Test files${NC}"
TEST_COUNT=$(find "$TEST_DIR" -maxdepth 1 \( -name "*.test.*" -o -name "test_*" -o -name "*_test.*" -o -name "*Test.*" -o -name "*Tests.*" \) -type f 2>/dev/null | wc -l)
if [ "$TEST_COUNT" -gt 0 ]; then
  echo -e "  ${GREEN}OK${NC} Found $TEST_COUNT test file(s)"
else
  echo -e "  ${RED}MISSING${NC} No test files found"
  MISSING=1
fi

# 2. run-tests.sh
echo ""
echo -e "${BOLD}[2/6] run-tests.sh${NC}"
if [ -f "$TEST_DIR/run-tests.sh" ]; then
  echo -e "  ${GREEN}OK${NC} $TEST_DIR/run-tests.sh"
else
  echo -e "  ${RED}MISSING${NC} $TEST_DIR/run-tests.sh"
  MISSING=1
fi

# 3. run-tests.ps1
echo ""
echo -e "${BOLD}[3/6] run-tests.ps1${NC}"
if [ -f "$TEST_DIR/run-tests.ps1" ]; then
  echo -e "  ${GREEN}OK${NC} $TEST_DIR/run-tests.ps1"
else
  echo -e "  ${RED}MISSING${NC} $TEST_DIR/run-tests.ps1"
  MISSING=1
fi

# 4. README.md
echo ""
echo -e "${BOLD}[4/6] README.md${NC}"
if [ -f "$TEST_DIR/README.md" ]; then
  echo -e "  ${GREEN}OK${NC} $TEST_DIR/README.md"
else
  echo -e "  ${RED}MISSING${NC} $TEST_DIR/README.md"
  MISSING=1
fi

# 5. BUG-DEFECTS.md
echo ""
echo -e "${BOLD}[5/6] BUG-DEFECTS.md${NC}"
if [ -f "$TEST_DIR/BUG-DEFECTS.md" ]; then
  echo -e "  ${GREEN}OK${NC} $TEST_DIR/BUG-DEFECTS.md"
else
  echo -e "  ${RED}MISSING${NC} $TEST_DIR/BUG-DEFECTS.md"
  MISSING=1
fi

# 6. SECURITY-FINDINGS.md
echo ""
echo -e "${BOLD}[6/6] SECURITY-FINDINGS.md${NC}"
if [ -f "$TEST_DIR/SECURITY-FINDINGS.md" ]; then
  echo -e "  ${GREEN}OK${NC} $TEST_DIR/SECURITY-FINDINGS.md"
else
  echo -e "  ${RED}MISSING${NC} $TEST_DIR/SECURITY-FINDINGS.md"
  MISSING=1
fi

# Summary
echo ""
echo "========================================"
if [ "$MISSING" -eq 0 ]; then
  echo -e " Result: ${GREEN}${BOLD}ALL PASS${NC}"
else
  echo -e " Result: ${RED}${BOLD}INCOMPLETE${NC}"
fi
echo "========================================"

exit $MISSING
