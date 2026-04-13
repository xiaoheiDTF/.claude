#!/bin/bash
# 列出已有的执行计划
if [ -d impl-plans ]; then
  ls -1 impl-plans/*.md 2>/dev/null | head -10 || echo '无已有计划'
else
  echo 'impl-plans/ 目录不存在'
fi
