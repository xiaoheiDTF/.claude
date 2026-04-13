#!/bin/bash
# 列出各子项目目录结构（排除依赖和构建产物）
for dir in */; do
  if [ -d "$dir" ] && [ "$dir" != "node_modules/" ] && [ "$dir" != "dist/" ] && [ "$dir" != ".git/" ]; then
    echo "=== $dir ==="
    find "$dir" -maxdepth 3 \
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
