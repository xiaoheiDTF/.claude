#!/bin/bash
# 列出已有的复用报告
if [ -d reuse-reports ]; then
  ls -1 reuse-reports/*.md 2>/dev/null | head -10 || echo '无已有报告'
else
  echo 'reuse-reports/ 目录不存在'
fi
