# 调试排错模式库

## Windows Bash 脚本的换行符兼容排查

> 沉淀于 2026-04-16，来源：在 Windows 环境执行 impl-planner/code-implementer 的 Bash 脚本时频繁遇到 CRLF 报错

**通用场景**: 在 Windows 环境执行跨平台项目的 shell 脚本/配置文件时，bash 解析因换行符不兼容而失败
**识别信号**: 错误信息中出现 `$''`、`syntax error near unexpected token $'do'`、`$'': command not found`
**通用做法**:
1. 快速识别错误根因：Windows CRLF vs Unix LF
2. 评估修复成本：转换所有脚本编码 vs 使用替代工具绕过
3. 若任务紧急，优先用 Python/其他已安装工具替代执行，保证任务不阻塞
4. 在日志和报告中明确标注因环境缺少 X 而跳过 Y 检查
**原因**: 硬等环境配置就绪会阻塞交付；用替代工具绕过是务实的降级策略，但必须有记录和后续补救方案
**避坑**: 不要尝试在 PowerShell 中手动修复大量 .sh 文件的换行符，除非这是本次任务的核心目标
**适用举例**: Windows CI 跑 Linux 项目的初始化脚本、Windows 开发机用 Git Bash 执行 CRLF 编码的脚本、Docker entrypoint 在 Windows 宿主机因换行符构建失败

<details>
<summary>原始案例</summary>

**项目场景**: 本次调用 impl-planner 的 `load-corrections.sh`、`validate-plan.sh` 以及 code-implementer 的相关脚本时，均因 Windows 默认 CRLF 换行导致 bash 解析失败
**具体做法**: 放弃修复脚本换行符，改用 Python 临时脚本完成验证逻辑；在实现报告中注明质量门禁已跳过（原因：环境缺少 mvn/javac）

</details>

## 执行破坏性文件操作前的"三查"清单

> 沉淀于 2026-04-16，来源：用户要求撤回刚生成的代码时，Remove-Item -Recurse 误删了目录下用户已有的实现文件

**通用场景**: 当需要删除、覆盖、撤回文件或目录时，防止"扩大打击面"误删有效资产
**识别信号**: 当你要执行 `rm -rf`、`Remove-Item -Recurse`、覆盖写文件、或 `git reset --hard` 时
**通用做法**:
1. **查范围** — 先用 `ls` / `git status` / `git diff` 确认目标路径下实际有哪些文件
2. **查归属** — 区分"我生成的临时文件"和"用户已有的文件"
3. **查确认** — 明确向用户报告将要删除的文件列表，获得口头确认后再执行
**原因**: 强制删除类操作对未追踪文件是不可逆的，一秒的疏忽可能导致用户已有代码永久丢失
**避坑**: 不要对用户说"我先删掉"然后直接执行递归删除；永远先用非破坏性的 `ls` / `find` / `git status` 做侦察
**适用举例**: 清理构建产物时误删源码目录、回滚迁移脚本时误删生产数据、删除临时分支时误删用户正在开发的功能分支、Docker prune 时误删有数据卷的容器

<details>
<summary>原始案例</summary>

**项目场景**: 用户要求撤回刚生成的 parser 目录代码，但 `Remove-Item -Recurse -Force` 把目录下用户之前已有的实现代码也一并永久删除了
**具体做法**: 应该先执行 `Get-ChildItem` 或 `git status` 查看目录内容，区分"本次新建文件"和"已有文件"，只删除明确属于本次生成的文件

</details>
