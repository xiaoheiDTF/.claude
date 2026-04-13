#!/bin/bash
# 列出各子项目的技术栈信息
find . -maxdepth 3 \( -name 'package.json' -o -name 'requirements.txt' -o -name 'pyproject.toml' -o -name 'pom.xml' -o -name 'build.gradle' -o -name 'build.gradle.kts' -o -name 'Cargo.toml' -o -name 'go.mod' \) -not -path '*/node_modules/*' | while read f; do
  echo "--- $f ---"
  head -15 "$f"
  echo ""
done
