# Claude-Code / Ide-Integration / Vscode

> 来源: claudecn.com

# VS Code Integration

The VS Code extension provides a native graphical interface for Claude Code, integrated directly into your IDE. Features include inline diff preview, @-mentions, and plan review.

## Prerequisites

- VS Code 1.98.0 or later
- Anthropic account (login on first launch)
---

## Installation

### Option 1: Direct Install

- VS Code
- Cursor
### Option 2: Extension Marketplace

- Press Cmd+Shift+X (Mac) or Ctrl+Shift+X (Windows/Linux)
- Search “Claude Code”
- Click Install
---

## Getting Started

### Open Claude Code Panel

**Method 1: Editor Toolbar**
Open any file, click the ✱ icon in the top-right.

**Method 2: Command Palette**
Press `Cmd+Shift+P` / `Ctrl+Shift+P`, type “Claude Code”, select “Open in New Tab”.

**Method 3: Status Bar**
Click “✱ Claude Code” in the bottom-right.

### Send Prompts

Ask Claude about code—explaining, debugging, or modifying.

**Quick Reference**: Select text in editor, press `Alt+K` to insert @-mention with file path and line numbers.

---

## Commands and Shortcuts

| Command | Shortcut | Description |
| --- | --- | --- |
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open conversation in new tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start new conversation (when focused) |
| Insert @-Mention | `Alt+K` | Insert current file reference |

---

## Configuration

### Extension Settings
Press `Cmd+,` / `Ctrl+,`, navigate to Extensions → Claude Code:

| Setting | Description |
| --- | --- |
| Selected Model | Default model for new conversations |
| Use Terminal | Use terminal mode instead of GUI |
| Initial Permission Mode | Control edit/command approval |
| Autosave | Auto-save files before Claude reads/writes |

### Claude Code Settings

Settings in `~/.claude/settings.json` are shared between extension and CLI.

---

## Using Third-Party Providers

For Amazon Bedrock, Google Vertex AI, or Microsoft Foundry:

- Open Settings, search “Claude Code login”
- Enable Disable Login Prompt
- Configure provider in ~/.claude/settings.json
---

## Extension vs CLI Features

| Feature | CLI | VS Code |
| --- | --- | --- |
| Slash commands | Full | Partial |
| MCP server config | Yes | No (use CLI) |
| Checkpoints | Yes | Coming soon |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

---

## Security Considerations

With auto-accept enabled, Claude may modify VS Code config files (like `settings.json`) that can be auto-executed.

For untrusted code:

- Enable Restricted Mode (Workspace Trust)
- Use manual approval mode
- Review changes carefully
---

## Troubleshooting

**Can’t see ✱ icon?**

- Open a file (folder only isn’t enough)
- Check VS Code version ≥ 1.98.0
- Run “Developer: Reload Window”
**Claude not responding?**

- Check network connection
- Start new conversation
- Run claude in terminal for detailed errors
