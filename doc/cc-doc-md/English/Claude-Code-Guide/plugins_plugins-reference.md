# Claude-Code / Plugins / Plugins-Reference

> 来源: claudecn.com

# Plugins Reference

Complete technical reference for Claude Code plugin system.

## Plugin Components

### Commands

**Location**: `commands/` directory

### Agents

**Location**: `agents/` directory

### Skills

**Location**: `skills/` directory with `SKILL.md` files

### Hooks

**Location**: `hooks/hooks.json` or inline in `plugin.json`

**Available Events**: `PreToolUse`, `PostToolUse`, `PermissionRequest`, `UserPromptSubmit`, `Stop`, `SessionStart`, `SessionEnd`

### MCP Servers

**Location**: `.mcp.json` or inline in `plugin.json`

### LSP Servers

**Location**: `.lsp.json` or inline in `plugin.json`

---

## Installation Scopes

| Scope | Settings File | Use Case |
| --- | --- | --- |
| `user` | `~/.claude/settings.json` | Personal plugins (default) |
| `project` | `.claude/settings.json` | Team plugins via git |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | `managed-settings.json` | Enterprise managed (read-only) |

---

## plugin.json Schema

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Brief description",
  "author": {"name": "Author"},
  "commands": "./custom/commands/",
  "agents": "./custom/agents/",
  "skills": "./custom/skills/",
  "hooks": "./hooks.json",
  "mcpServers": "./.mcp.json",
  "lspServers": "./.lsp.json"
}
```

---

## Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json      ← Only manifest here
├── commands/            ← At root level
├── agents/
├── skills/
├── hooks/
├── .mcp.json
└── .lsp.json
```

---

## CLI Commands

| Command | Description |
| --- | --- |
| `claude plugin install ` | Install plugin |
| `claude plugin uninstall ` | Remove plugin |
| `claude plugin enable ` | Enable plugin |
| `claude plugin disable ` | Disable plugin |
| `claude plugin update ` | Update plugin |

---

## Debugging

```bash
claude --debug
```

---

## Related Docs
[Create Plugins](../create-plugins/)
[Discover Plugins](../discover-plugins/)
