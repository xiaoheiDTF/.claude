# Claude-Code / Plugins / Create-Plugins

> 来源: claudecn.com

# Create Plugins

Plugins let you extend Claude Code with custom slash commands, agents, Skills, Hooks, and MCP servers.

## When to Use Plugins vs Standalone

| Approach | Command Format | Best For |
| --- | --- | --- |
| **Standalone** (`.claude/`) | `/hello` | Personal workflows, quick experiments |
| **Plugins** (`.claude-plugin/`) | `/plugin-name:hello` | Team sharing, community distribution |

---

## Quickstart: Create Your First Plugin

### Step 1: Create Plugin Directory

```bash
mkdir my-first-plugin
mkdir my-first-plugin/.claude-plugin
```

### Step 2: Create Plugin Manifest
Create `my-first-plugin/.claude-plugin/plugin.json`:

```json
{
  "name": "my-first-plugin",
  "description": "A greeting plugin to learn basics",
  "version": "1.0.0"
}
```

### Step 3: Add a Slash Command

```bash
mkdir my-first-plugin/commands
```

Create `my-first-plugin/commands/hello.md`:

```markdown
---
description: Greet the user with a friendly message
---

# Hello Command

Greet the user warmly and ask how you can help today.
```

### Step 4: Test Your Plugin

```bash
claude --plugin-dir ./my-first-plugin
```

```
> /my-first-plugin:hello
```

---

## Plugin Structure

| Directory | Purpose |
| --- | --- |
| `.claude-plugin/` | Contains `plugin.json` manifest (**required**) |
| `commands/` | Custom slash commands |
| `agents/` | Custom subagents |
| `skills/` | Agent Skills |
| `hooks/` | Event hook configurations |
| `.mcp.json` | MCP server definitions |
| `.lsp.json` | LSP server configurations |

**Common mistake**: Don’t put `commands/`, `agents/`, `skills/` inside `.claude-plugin/`. Only `plugin.json` goes there.

---

## Adding Components

### Agents
Create Markdown files in `agents/` directory.

### Skills

Create subdirectories in `skills/`, each with `SKILL.md`.

### Hooks

Create `hooks/hooks.json`:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
      }]
    }]
  }
}
```

### MCP Servers
Create `.mcp.json` at plugin root.

---

## Debugging

```bash
claude --debug
```

---

## Next Steps
[Discover PluginsInstall from marketplaces
](../discover-plugins/)[Plugins ReferenceComplete technical specs
](../plugins-reference/)
