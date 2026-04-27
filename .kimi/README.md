# Kimi CLI Hooks 兼容配置

本目录包含将 `.claude/hooks/` 下的 Claude Code 钩子适配为 **Kimi CLI** 可用的配置和脚本。

## 设计原则

- **零侵入**: 原 Claude Code 钩子文件（`.claude/hooks/` 下）**完全不做修改**
- **薄适配**: 仅通过包装脚本处理事件名和工具名的差异
- **即开即用**: 配置文件中所有路径均为相对路径，直接复制到 `~/.kimi/config.toml` 即可

## 事件映射对照表

| Claude Code 事件 | Kimi CLI 事件 | 原钩子 | 适配方式 |
|-----------------|--------------|--------|---------|
| `PermissionRequest` | `Notification` (permission_prompt) | `pre-tool-confirm.sh` | `notification-adapter.sh` 转换输入格式 |
| `PreToolUse` | `PreToolUse` | `protect-sensitive.sh` | `write-compat-wrapper.sh` 映射工具名 |
| `SessionStart` | `SessionStart` | `session-start.sh` | 直接引用 |
| `PostToolUse` | `PostToolUse` | `session-track.sh` | 直接引用 |
| `PostToolUse` | `PostToolUse` | `skill-gate/skill-gate.sh` | `write-compat-wrapper.sh` 映射工具名 |
| `Stop` | `Stop` | `session-end.sh` | 直接引用 |
| `Stop` | `Stop` | `task-complete-notify.sh` | 直接引用 |

### 工具名映射

Kimi CLI 与 Claude Code 的工具名存在差异，通过 `write-compat-wrapper.sh` 自动转换：

| Kimi CLI | Claude Code |
|---------|------------|
| `WriteFile` | `Write` |
| `StrReplaceFile` | `Edit` |
| `ReadFile` | `Read` |

## 快速启用

将 `config.toml` 的内容追加到 Kimi CLI 配置文件中：

```bash
# Linux/macOS
cat .claude/.kimi/config.toml >> ~/.kimi/config.toml

# Windows (Git Bash)
cat .claude/kimi/config.toml >> ~/.kimi/config.toml
```

验证配置：

```bash
kimi
# 在 Shell 模式下输入:
/hooks
```

## 文件说明

```
kimi/
├── config.toml                     # Kimi CLI hooks 配置（可复制到 ~/.kimi/config.toml）
├── README.md                       # 本文件
└── hooks/
    ├── notification-adapter.sh     # Notification → PermissionRequest 输入格式适配
    └── write-compat-wrapper.sh     # WriteFile/StrReplaceFile → Write/Edit 工具名映射
```
