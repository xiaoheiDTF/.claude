# Claude-Code / Advanced / Mcp-Servers

> 来源: claudecn.com

# MCP Servers

MCP (Model Context Protocol) is an open standard for AI tool integration. Claude Code can connect to hundreds of data sources through MCP servers—databases, APIs, browsers, and more.

## What MCP Enables

- Implement features from issue trackers: “Add the feature described in JIRA ENG-4521 and create a GitHub PR”
- Analyze monitoring data: “Check Sentry and Statsig for usage of the ENG-4521 feature”
- Query databases: “Find 10 random user emails who used the ENG-4521 feature from PostgreSQL”
- Integrate designs: “Update the email template based on the new Figma designs from Slack”
---

## Installing MCP Servers

### Remote HTTP (Recommended)

```bash
# Basic syntax
claude mcp add --transport http <name> <url>

# Example: Connect to Notion
claude mcp add --transport http docs https://your-mcp-server.example.com/mcp

# With authentication
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

### Local stdio

```bash
# Example: Add Airtable server
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

---

## Managing Servers

```bash
# List all configured servers
claude mcp list

# Get specific server details
claude mcp get github

# Remove server
claude mcp remove github

# Check status in Claude Code
> /mcp
```

---

## Installation Scopes

| Scope | Location | Shared? |
| --- | --- | --- |
| **Local** | `~/.claude.json` (per-project) | No |
| **Project** | `.mcp.json` | Yes (git) |
| **User** | `~/.claude.json` | No |
Priority: **Local > Project > User**

---

## OAuth Authentication

Many cloud MCP servers require authentication:

```bash
# 1. Add server requiring auth
claude mcp add --transport http server https://your-mcp-server.example.com/mcp

# 2. Authenticate in Claude Code
> /mcp
# Complete login in browser
```

---

## Popular MCP Servers

### Example: Remote HTTP server

```bash
claude mcp add --transport http server https://your-mcp-server.example.com/mcp/
```

### PostgreSQL

```bash
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub \
  --dsn "postgresql://readonly:pass@prod.db.com:5432/analytics"
```

You can discover additional MCP servers via your team’s internal registry or by searching public registries.

---

## Using MCP Resources

Reference MCP resources with @:

```
# List available resources
> @

# Reference specific resource
> Analyze @github:issue://123 and suggest fixes

# Multiple resources
> Compare @postgres:schema://users and @docs:file://database/user-model
```

---

## Claude Code as MCP Server
Run Claude Code as an MCP server for other apps:

```bash
claude mcp serve
```

Configure in Claude Desktop:

```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"]
    }
  }
}
```

---

## Debugging

```bash
# Enable debug logs
claude --mcp-debug

# Set startup timeout
MCP_TIMEOUT=10000 claude

# Check server status
> /mcp
```
