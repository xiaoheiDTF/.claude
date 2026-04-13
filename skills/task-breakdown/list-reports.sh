#!/bin/bash
# 列出已有的拆解报告
if [ -d task-breakdown ]; then
  ls -1 task-breakdown/*.md 2>/dev/null | head -10 || echo '无已有报告'
else
  echo 'task-breakdown/ 目录不存在'
fi
