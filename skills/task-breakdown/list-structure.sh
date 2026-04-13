#!/bin/bash
# 列出项目结构（根目录 + 各子项目，用于 task-breakdown）
echo "=== 根目录 ==="
find . -maxdepth 1 -not -name '.*' -not -name 'node_modules' | sort
echo ""
for dir in */; do
  if [ -d "$dir" ] && [ "$dir" != "node_modules/" ] && [ "$dir" != "dist/" ] && [ "$dir" != ".git/" ]; then
    echo "=== $dir ==="
    find "$dir" -maxdepth 2 \
      -not -path '*/node_modules/*' \
      -not -path '*/__pycache__/*' \
      -not -path '*/.git/*' \
      -not -path '*/dist/*' \
      -not -path '*/target/*' \
      -not -path '*/.claude/*' \
      | head -30
    echo ""
  fi
done
